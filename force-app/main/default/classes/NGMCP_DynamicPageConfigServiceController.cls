public with sharing class NGMCP_DynamicPageConfigServiceController {
    
    /**
     * Builds section configuration JSON for a given Record Type name.
     *
     * - Fetches configuration from NGMCP_Dynamic_Page_Configuration__mdt
     * - Groups fields under section headers
     * - Orders sections based on configured sequence
     * - Returns JSON used by LWC to render dynamic sections
     *
     * @param recordTypeName  Record Type Name (Label)
     * @return JSON string containing section labels and field lists
     */
    
    @AuraEnabled(cacheable=true)
    public static String buildSectionConfigJsonByRtName(String recordTypeName) {
        if (String.isBlank(recordTypeName)) {
            throw new AuraHandledException('recordTypeName is required.');
        }
        
        List<NGMCP_Dynamic_Page_Configuration__mdt> rows = [
            SELECT Id,
            NGMCP_Sectionos__c,
            NGMCP_Fields__c,
            NGMCP_Sequence__c
            
            FROM NGMCP_Dynamic_Page_Configuration__mdt
            WHERE NGMCP_Dynamic_Record_Page_Configuration__r.NGMCP_Record_Type_Name__c = :recordTypeName WITH USER_MODE
            ORDER BY NGMCP_Sequence__c ASC, NGMCP_Sectionos__c ASC
        ];
        // Build sections in the exact sequence order.
        List<Map<String, Object>> sections = new List<Map<String, Object>>();
        for (NGMCP_Dynamic_Page_Configuration__mdt row : rows) {
            // Skip if no label.
            if (String.isBlank(row.NGMCP_Sectionos__c)) {
                continue;
            }
            // Parse comma-separated field API names: trim, dedupe, skip empties.
            List<String> fieldList = new List<String>();
            Set<String> dedupe = new Set<String>();
            if (!String.isBlank(row.NGMCP_Fields__c)) {
                for (String f : row.NGMCP_Fields__c.split('\\s*,\\s*')) {
                    if (!String.isBlank(f) && dedupe.add(f)) {
                        fieldList.add(f);
                    }
                }
            }
            // (Optional) Skip empty sections (no fields). Remove this guard if you want headers without fields.
            if (fieldList.isEmpty()) {
                continue;
            }
            
            sections.add(new Map<String, Object>{
                'label'  => row.NGMCP_Sectionos__c,
                'fields' => fieldList
                    
            });
        }
        
        // Root key "Default" (as per your current LWC expectation).
        Map<String, Object> root = new Map<String, Object>{
            'Default' => sections
        };
        return JSON.serialize(root);
    }
    
    /**
     * Optional helper:
     * Build sectionConfigJson by a recordId/objectApiName.
     * Resolves the record's RecordType *Name* (label) and delegates to buildSectionConfigJsonByRtName.
     * Use this if you want your LWC to call Apex with only recordId/objectApiName.
     */
    @AuraEnabled(cacheable=true)
    public static String buildSectionConfigJsonForRecordId(Id recordId, String objectApiName) {
        if (recordId == null || String.isBlank(objectApiName)) {
            return buildSectionConfigJsonByRtName('Default');
        }
        String recordTypeName = 'Default';
        try {
            Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(objectApiName);
            
            if (sobjectType == null) {
                return buildSectionConfigJsonByRtName('Default');
            }
            Schema.DescribeSObjectResult describeResult = recordId.getSObjectType().getDescribe();
            Id recordTypeId = recordId.getSObjectType().getDescribe().getRecordTypeInfosById().keySet().iterator().next();
            Schema.RecordTypeInfo rti =  describeResult.getRecordTypeInfosById().get(recordTypeId);
            if (rti != null && !String.isBlank(rti.getName())) {
                recordTypeName = rti.getName();
            }
            
        } catch (Exception e) {
            recordTypeName = 'Default';
        }
        
        return buildSectionConfigJsonByRtName(recordTypeName);
    }
    
    /**
     * Returns the Object API name for the given record Id.
     *
     * - Uses Schema Describe to resolve the object type
     * - Safe to call from LWC/Aura
     * - Returns null if recordId is invalid or cannot be resolved
     *
     * @param recordId  Salesforce record Id
     * @return Object API name (e.g., NGMCP_Request__c) or null
     */
    
    @AuraEnabled
    public static String getObjectApiName(Id recordId) {
        if (recordId == null) return null;
        try {
            return recordId.getSObjectType().getDescribe().getName();
        } catch (Exception e) {
            // If the Id is malformed or not an sObject Id
            return null;
        }
    }
    
    /**
     * Fetches Notes and Files related to a given record.
     *
     * - Retrieves files linked via ContentDocumentLink
     * - Returns file details such as title, type, created date, and owner
     * - Results are ordered by most recent files first
     *
     * @param recordId  Salesforce record Id
     * @return List of ContentDocumentLink records
     */
    
    @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> getNotesAndFiles(Id recordId) {
        return [
            SELECT
            ContentDocumentId,
            ContentDocument.Title,
            ContentDocument.FileType,
            ContentDocument.CreatedDate,
            ContentDocument.CreatedBy.Name,
            ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId WITH USER_MODE
            ORDER BY ContentDocument.CreatedDate DESC
        ];
    }
}