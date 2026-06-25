/*
 * @File Name : NGMCP_WorkRequestController .cls
 * @Description :
 * @Author :P Shabbir Ali Khan
 * @Last Modified By :
 * @Last Modified On : November 11, 2025
 * @Modification Log :
 * @Purpose:
 *   This class provides methods to fetch Custom Metadata records for Meter Model Configuration.
 *   It is designed for use with Lightning Web Components (LWC) or Aura components.
 *
 * @Key Features:
 *   - Uses cacheable=true for better performance with @wire in LWC.
 *   - Fetches all records from NGMCP_Meter_Model_Configuration__mdt.
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | November 11, 2025 |   | Initial Version
 */

public with sharing class NGMCP_WorkRequestController {
    private static final Set<String> ALLOWED_FIELDS_THIRDPARTY = new Set<String>{
        'NGMCP_Manufacturer_Name__c',
        'NGMCP_Meter_Model__c'
    };
    private static final Set<String> ALLOWED_FIELDS_VALIDATIONLOGIC = new Set<String>{
        // Common
        'RecordTypeId',
        'NGMCP_MPRN__c',
        'NGMCP_Supplier_Id__c',
        'NGMCP_Status__c',
        
        // AMR / Customer / Urgent
        'NGMCP_Job_Type__c',
        'NGMCP_Job_SubType__c',
        
        // Enquiry
        'NGMCP_Enquiry_Reason_Code__c',
        'NGMCP_Enquiry_Category__c',
        
        // Third Party
        'NGMCP_Manufacturer_Name__c',
        'NGMCP_Meter_Model__c'
    };
    private static final Set<String> ALLOWED_FIELDS_ASSET_PAYMENT = new Set<String>{
        'NGMCP_Manufacturer_Name__c',
        'NGMCP_Meter_Model__c'
    };
    private static final Set<String> ALLOWED_FIELDS = new Set<String>{
        'DeveloperName',
        'NGMCP_MX_SERVICEGRP__c',
        'NGMCP_MX_SERVICETYPE__c',
        
        // Job details
        'NGMCP_Job_Type__c',
        'NGMCP_Job_Sub_category__c',
        
        // Payment & Mechanism
        'NGMCP_Payment_Mechanism__c',
        'NGMCP_Payment_Method__c',
        
        // Meter details
        'NGMCP_Meter_Model__c',
        'NGMCP_Meter_Size__c',
        'NGMCP_Pressure_Tier__c',
        'NGMCP_Meter_Bypass__c',
        'NGMCP_Meter_Bypass__c',
        
        // Housing details
        'NGMCP_Housing_Required__c',
        'NGMCP_Housing_Type__c',
        
        // Service & installation options
        'NGMCP_Purging__c',
        'NGMCP_Service_Location__c',
        'NGMCP_Twin_Stream__c',
        'NGMCP_Electric_Interface__c',
        'NGMCP_Converter_Required__c',
        'NGMCP_Base_Required__c',
        'NGMCP_Pickup_Equipment__c',
        
        // Flags & conditions
        'NGMCP_Damage_Limited__c',
        'NGMCP_With_in_TwoMeters__c',
        'NGMCP_Is_New_Connection__c',
        'NGMCP_Is_Reconnection__c',
        'NGMCP_Is_Reconnection_Debt__c',
        
        // Others
        'NGMCP_Crime_Reference_Number__c'
    };
    
    /**
     * @description Fetch all Meter Model Configuration records from Custom Metadata.
     * @return List of NGMCP_Meter_Model_Configuration__mdt records.
     * @AuraEnabled(cacheable=true) allows LWC to use @wire for reactive data.
     */
    @AuraEnabled(cacheable=true)
    public static List<NGMCP_Meter_Model_Configuration__mdt> getAllMeterModelConfigs() {
        try {
            // SOQL Query to fetch required fields from Custom Metadata
            return [
                            SELECT NGMCP_Minimum_Kwh__c,
                            NGMCP_Maximum_Kwh__c,
                            NGMCP_Minimum_Outlet_Pressure__c,
                            NGMCP_Maximum_Outlet_Pressure__c,
                            NGMCP_Meter_Model__c
                            FROM NGMCP_Meter_Model_Configuration__mdt WITH USER_MODE
                        ];
        } catch (Exception ex) {
            // Log error for debugging
            System.debug('Error fetching Meter Model Configurations: ' + ex.getMessage());
            throw new AuraHandledException('Unable to fetch Meter Model Configurations.');
        }
    }
    
    /**
     * Fetch DeveloperName and Housing Model from
     * NGMCP_HousingModel_Configuration__mdt custom metadata type.
     * Returns the queried records directly to LWC.
     */
    @AuraEnabled(cacheable=true)
    public static List<NGMCP_HousingModel_Configuration__mdt> geAlltHousingModels() {
        try {
            // Query custom metadata records
            return [
                SELECT DeveloperName, NGMCP_Housing_Model__c
                FROM NGMCP_HousingModel_Configuration__mdt WITH USER_MODE
            ];
        } catch (Exception e) {
            // Log the error for debugging
            System.debug('Error fetching Housing Models: ' + e.getMessage());
            
            // Return an empty list if an error occurs
            return new List<NGMCP_HousingModel_Configuration__mdt>();
        }
    }
    
    /*@description Fetches all records from the custom metadata type
     *              NGMCP_Assest_Master_Data__mdt and returns them to the LWC.
     *              This method is cacheable for better performance.
     *
     * @return List<NGMCP_Assest_Master_Data__mdt> - List of custom metadata records.
     */
    
    @AuraEnabled(cacheable=true)
    public static List<NGMCP_Assest_Master_Data__mdt > geAllAssestMasterData() {
        try {
            // Query custom metadata records
            return [
                SELECT Id, DeveloperName, NGMCP_Manufacturer_Name__c, NGMCP_Meter_Model__c, NGMCP_Type__c
                FROM NGMCP_Assest_Master_Data__mdt WITH USER_MODE
            ];
        } catch (Exception e) {
            // Log the error for debugging
            System.debug('Error fetching AssestMaster Data: ' + e.getMessage());
            
            // Return an empty list if an error occurs
            return new List<NGMCP_Assest_Master_Data__mdt>();
        }
    }
    @AuraEnabled
    public static List<NGMCP_CWR_Pricing_Meta_Data__mdt> getPrice(String payload) {
        if (String.isBlank(payload)) {
            return new List<NGMCP_CWR_Pricing_Meta_Data__mdt>();
        }
        
        Map<String, Object> filters =
            (Map<String, Object>) JSON.deserializeUntyped(payload);
        
        String baseQuery =
            'SELECT DeveloperName, ' +
            'NGMCP_MX_SERVICEGRP__c, ' +
            'NGMCP_MX_SERVICETYPE__c, ' +
            'NGMCP_Job_Price__c, ' +
            'NGMCP_Main_Price__c, NGMCP_Additional_Price__c, NGMCP_SLA_Days__c, NGMCP_Valid_From__c, NGMCP_Valid_To__c ' +
            'FROM NGMCP_CWR_Pricing_Meta_Data__mdt';
        
        Map<String, Schema.SObjectField> fieldMap =
            NGMCP_CWR_Pricing_Meta_Data__mdt.SObjectType
            .getDescribe()
            .fields
            .getMap();
        
        List<String> conditions = new List<String>();
        Map<String, Object> bindVariables = new Map<String, Object>();
        Integer index = 0;
        
        for (String key : filters.keySet()) {
            
            if (!fieldMap.containsKey(key) || !ALLOWED_FIELDS.contains(key)) {
                continue;
            }
            
            Object value = filters.get(key);
            if (value == null) {
                continue;
            }
            
            String bindName = 'val' + index;
            Schema.DisplayType fieldType =
                fieldMap.get(key).getDescribe().getType();
            
            Object convertedValue = convertValueByFieldType(value, fieldType);
            
            conditions.add(key + ' = :' + bindName);
            bindVariables.put(bindName, convertedValue);
            index++;
        }
        
        String finalQuery = baseQuery +
            (conditions.isEmpty() ? '' : ' WHERE ' + String.join(conditions, ' AND '));
        
        return (List<NGMCP_CWR_Pricing_Meta_Data__mdt>)
            Database.queryWithBinds(
            finalQuery,
        bindVariables,
        AccessLevel.USER_MODE
            );
    }
    private static Object convertValueByFieldType(
        Object value,
    Schema.DisplayType fieldType
    ) {
        if (value == null) {
            return null;
        }
        
        switch on fieldType {
            
            when STRING, TEXTAREA, EMAIL, PHONE, URL, PICKLIST, MULTIPICKLIST, ID {
                return String.valueOf(value);
            }
            
            when BOOLEAN {
                return (value instanceof Boolean)
                    ? value
                    : Boolean.valueOf(String.valueOf(value));
            }
            
            when INTEGER {
                return (value instanceof Integer)
                    ? value
                    : Integer.valueOf(String.valueOf(value));
            }
            
            when DOUBLE, CURRENCY, PERCENT {
                return (value instanceof Decimal)
                    ? value
                    : Decimal.valueOf(String.valueOf(value));
            }
            
            when DATE {
                return (value instanceof Date)
                    ? value
                    : Date.valueOf(String.valueOf(value));
            }
            
            when DATETIME {
                return (value instanceof Datetime)
                    ? value
                    : Datetime.valueOf(String.valueOf(value));
            }
            
            when else {
                return String.valueOf(value);
            }
        }
    }
    
    /**
     * Fetches Third Party Asset metadata records based on filter values
     * provided in the JSON payload.
     *
     * Only whitelisted fields are used to build the query.
     * Returns an empty list if payload is null, empty, or invalid.
     *
     * @param payload JSON string containing filter field names and values
     * @return List of matching NGMCP_Third_Party_Assest_Data__mdt records
     */
    
    @AuraEnabled
    public static List<NGMCP_Third_Party_Assest_Data__mdt> getThirdPartyAsset(String payload) {
        if (String.isBlank(payload)) {
            return new List<NGMCP_Third_Party_Assest_Data__mdt>();
        }
        Map<String, Object> filters = (Map<String, Object>) JSON.deserializeUntyped(payload);
        if (filters == null || filters.isEmpty()) {
            return new List<NGMCP_Third_Party_Assest_Data__mdt>();
        }
        String baseQuery =
            'SELECT DeveloperName, ' +
            'NGMCP_Manufacturer_Name__c, ' +
            'NGMCP_Model__c, ' +
            'NGMCP_Type__c, ' +
            'NGMCP_Metric_Imperial__c, ' +
            'NGMCP_Capacity__c, ' +
            'NGMCP_Dials__c, ' +
            'NGMCP_Factor__c, ' +
            'NGMCP_Year_From__c, ' +
            'NGMCP_Year_To__c, ' +
            'NGMCP_Manufacturer_Code__c ' +
            'FROM NGMCP_Third_Party_Assest_Data__mdt';
        
        Map<String, Schema.SObjectField> fieldMap = NGMCP_Third_Party_Assest_Data__mdt.SObjectType.getDescribe().fields.getMap();
        List<String> conditions = new List<String>();
        Map<String, Object> bindVariables = new Map<String, Object>();
        Integer index = 0;
        for (String key : filters.keySet()) {
            
            if (!fieldMap.containsKey(key) || !ALLOWED_FIELDS_THIRDPARTY.contains(key)) {
                continue;
            }
            Object value = filters.get(key);
            if (value == null) {
                continue;
            }
            Schema.DisplayType fieldType = fieldMap.get(key).getDescribe().getType();
            String bindName = 'val' + index;
            try {
                Object convertedValue = convertValueByFieldType(value, fieldType);
                conditions.add(key + ' = :' + bindName);
                bindVariables.put(bindName, convertedValue);
                index++;
            } catch (Exception ex) {
                System.debug('Skipping field due to conversion issue: ' + key + ' - ' + ex.getMessage());
            }
        }
        String finalQuery = baseQuery +(conditions.isEmpty() ? '': ' WHERE ' + String.join(conditions, ' AND '));
        return (List<NGMCP_Third_Party_Assest_Data__mdt>)
            Database.queryWithBinds(finalQuery, bindVariables, AccessLevel.USER_MODE);
    }
    
    
    /**
     * Returns Asset Payment Mechanism metadata records
     * based on filter values passed in the JSON payload.
     *
     * Uses whitelisted fields and bind variables
     * to prevent SOQL injection.
     *
     * @param payload JSON string with filter criteria
     * @return List of matching NGMCP_Asset_Payment_Mechanism__mdt records
     */
    
    @AuraEnabled
    public static List<NGMCP_Asset_Payment_Mechanism__mdt> getTypeandPaymentMechanism(String payload) {
        if (String.isBlank(payload)) {
            return new List<NGMCP_Asset_Payment_Mechanism__mdt>();
        }
        Map<String, Object> filters = (Map<String, Object>) JSON.deserializeUntyped(payload);
        if (filters == null || filters.isEmpty()) {
            return new List<NGMCP_Asset_Payment_Mechanism__mdt>();
        }
        String baseQuery =
            'SELECT DeveloperName, ' +
            'NGMCP_Manufacturer_Name__c, ' +
            'NGMCP_Meter_Model__c, ' +
            'NGMCP_Type__c, ' +
            'NGMCP_Payment_Mechanism__c ' +
            'FROM NGMCP_Asset_Payment_Mechanism__mdt';
        
        Map<String, Schema.SObjectField> fieldMap = NGMCP_Asset_Payment_Mechanism__mdt.SObjectType.getDescribe().fields.getMap();
        List<String> conditions = new List<String>();
        Map<String, Object> bindVars = new Map<String, Object>();
        Integer idx = 0;
        for (String key : filters.keySet()) {
            if (!ALLOWED_FIELDS_ASSET_PAYMENT.contains(key) || !fieldMap.containsKey(key)) {
                continue;
            }
            Object value = filters.get(key);
            if (value == null) {
                continue;
            }
            String bindName = 'val' + idx;
            conditions.add(key + ' = :' + bindName);
            bindVars.put(bindName, value);
            idx++;
        }
        String finalQuery =
            baseQuery +
            (conditions.isEmpty() ? '' : ' WHERE ' + String.join(conditions, ' AND '));
        
        return (List<NGMCP_Asset_Payment_Mechanism__mdt>)
            Database.queryWithBinds(finalQuery, bindVars, AccessLevel.USER_MODE);
    }
    
    
    /**
     * Validates duplicate NGMCP_Request__c records based on dynamic filters.
     *
     * - Accepts JSON payload from UI
     * - Dynamically builds SOQL using allowed fields only
     * - Handles Record Type filtering
     * - Supports Status NOT IN condition
     * - Uses bind variables to prevent SOQL injection
     *
     * @param payload  JSON string containing filter criteria
     * @return List of matching NGMCP_Request__c records (duplicates)
     */
    
    
    @AuraEnabled
    public static List<NGMCP_Request__c> validateDeuplicateRequest(String payload) {
        
        if (String.isBlank(payload)) {
            return new List<NGMCP_Request__c>();
        }
        
        Map<String, Object> filters =
            (Map<String, Object>) JSON.deserializeUntyped(payload);
        
        if (filters == null || filters.isEmpty()) {
            return new List<NGMCP_Request__c>();
        }
        
        String baseQuery =
            'SELECT Id, Name, NGMCP_SR_Ticket__c, NGMCP_Supplier_Id__c, ' +
            'NGMCP_MPRN__c, NGMCP_Status__c, NGMCP_Job_Type__c, NGMCP_Job_SubType__c ' +
            'FROM NGMCP_Request__c';
        
        Map<String, Schema.SObjectField> fieldMap =
            NGMCP_Request__c.SObjectType.getDescribe().fields.getMap();
        
        List<String> conditions = new List<String>();
        Map<String, Object> bindVars = new Map<String, Object>();
        Integer idx = 0;
        
        // Handle Record Type Name
        if (filters.containsKey('recordTypeName')) {
            String rtName = (String) filters.get('recordTypeName');
            Schema.RecordTypeInfo rtInfo =
                NGMCP_Request__c.SObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get(rtName);
            
            if (rtInfo != null) {
                conditions.add('RecordTypeId = :rtId');
                bindVars.put('rtId', rtInfo.getRecordTypeId());
            }
            filters.remove('recordTypeName');
        }
        
        // Handle Status NOT IN
        if (filters.containsKey('NGMCP_Status__c')) {
            List<Object> statusList = (List<Object>) filters.get('NGMCP_Status__c');
            List<String> statuses = new List<String>();
            
            for (Object s : statusList) {
                statuses.add(String.valueOf(s));
            }
            
            if (!statuses.isEmpty()) {
                conditions.add('NGMCP_Status__c NOT IN :statusList');
                bindVars.put('statusList', statuses);
            }
            filters.remove('NGMCP_Status__c');
        }
        
        // Handle remaining filters
        for (String fieldName : filters.keySet()) {
            
            if (!ALLOWED_FIELDS_VALIDATIONLOGIC.contains(fieldName) ||
            !fieldMap.containsKey(fieldName)) {
                continue;
            }
            
            Object value = filters.get(fieldName);
            if (value == null) {
                continue;
            }
            
            String bindName = 'val' + idx;
            conditions.add(fieldName + ' = :' + bindName);
            bindVars.put(bindName, value);
            idx++;
        }
        
        String finalQuery =
            baseQuery +
            (conditions.isEmpty() ? '' : ' WHERE ' + String.join(conditions, ' AND '));
        
        return (List<NGMCP_Request__c>)
            Database.queryWithBinds(finalQuery, bindVars, AccessLevel.USER_MODE);
    }
}