/**
 * @class NGMCP_RequestObjectClass
 * @description
 * This Apex class is responsible for creating and tracking request records
 * in Salesforce for different types of API callouts to external systems
 * (for example, IBM Maximo).
 *
 * PURPOSE:
 * - Maintain a tracking record for API requests initiated from Salesforce.
 * - Support auditing, troubleshooting, and operational monitoring.
 * - Persist request payload data into Salesforce custom objects.
 *
 * KEY FEATURES:
 * - Exposes @AuraEnabled methods for LWC and Aura usage.
 * - Deserializes JSON payloads dynamically.
 * - Maps request data to custom object fields.
 * - Supports multiple request types using Record Types.
 *
 * USE CASES:
 * - Address Update API callout tracking
 * - Urgent Work Request / Customer Work Request tracking
 *
 * SECURITY:
 * - Declared as "with sharing" to respect Salesforce sharing rules.
 *
 * LIMITATIONS:
 * - Assumes valid JSON payload structure.
 * - Minimal validation and exception handling.
 *
 * @author  Shabbir Ali Khan Patan
 * @date    26-Oct-2025
 */
public with sharing class NGMCP_RequestObjectClass {
    
    /* =========================================================
     * ADDRESS UPDATE REQUEST CREATION
     * ========================================================= */
    
    /**
     * @method createAddressUpdateRecord
     * @description
     * Creates an Address Update request record in Salesforce.
     * This method parses the incoming JSON payload and maps
     * address-related fields to the NGMCP_Request__c object.
     *
     * @param requestBody  JSON string containing address details
     * @param locationId   Location identifier to associate with the request
     * @return Id          Id of the newly created NGMCP_Request__c record
     */
    @AuraEnabled
    public static Id createAddressUpdateRecord(String requestBody, String locationId) {
        
        Map<String, Object> payload =
            (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        
        List<NGMCP_Request__c> requestObjList =
            new List<NGMCP_Request__c>();
        
        Id recordTypeId =
            Schema.SObjectType.NGMCP_Request__c
            .RecordTypeInfosByName
            .get('Address Update')
            .RecordTypeId;
        
        if (!payload.isEmpty()) {
            
            // Convert locationId to Integer via Double
            Double d = Double.valueOf(locationId);
            Integer locationInteger = d.intValue();
            
            // Create request record
            NGMCP_Request__c requestObj = new NGMCP_Request__c();
            if(Schema.sObjectType.NGMCP_Request__c.fields.RecordTypeId.isCreateable()){
        		requestObj.RecordTypeId                    = recordTypeId;
        	}
            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_MPRN__c.isCreateable()){
        		requestObj.NGMCP_MPRN__c                   = (String) payload.get('location');
        	}
            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Supplier_Id__c.isCreateable()){
        		requestObj.NGMCP_Supplier_Id__c            = (String) payload.get('siteid');
        	}
            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Building_Number__c.isCreateable()){
        		requestObj.NGMCP_Building_Number__c        = (String) payload.get('ngme_c_bldngname');
        	}
            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Building_Name__c.isCreateable()){
        		requestObj.NGMCP_Building_Name__c          = (String) payload.get('ngme_c_sitebn');
        	}
            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Street__c.isCreateable()){
        		requestObj.NGMCP_Street__c                 = (String) payload.get('ngme_c_prncpstreet');
        	}
            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Dependent_Locality__c.isCreateable()){
        		requestObj.NGMCP_Dependent_Locality__c     = (String) payload.get('ngme_c_depndlocality');
        	}
            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Postal_Town__c.isCreateable()){
        		requestObj.NGMCP_Postal_Town__c            = (String) payload.get('ngme_c_st');
        	}
            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Postal_Code__c.isCreateable()){
        		requestObj.NGMCP_Postal_Code__c            = (String) payload.get('ngme_c_spc');
        	}
            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_API_Callout__c.isCreateable()){
        		requestObj.NGMCP_API_Callout__c            = 'Address Update';
        	}
            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Callout_Status__c.isCreateable()){
        		requestObj.NGMCP_Callout_Status__c         = 'In Progress';
        	}
            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_LocationsId__c.isCreateable()){
        		requestObj.NGMCP_LocationsId__c            = String.valueOf(locationInteger);
        	}
            
            
            requestObjList.add(requestObj);
        }
        
        // Insert record if available
        if (!requestObjList.isEmpty() && Schema.sObjectType.NGMCP_Request__c.isCreateable()) {
            insert requestObjList;
        }
        
        // Return created record Id
        return requestObjList[0].Id;
    }
    
    /* =========================================================
     * RESPONSE DTO
     * ========================================================= */
    
    /**
     * @class RequestResponseDTO
     * @description
     * Data Transfer Object used to return minimal response
     * details back to LWC/Aura after record creation.
     */
    public class RequestResponseDTO {
        
        @AuraEnabled public Id     id;
        @AuraEnabled public String name;
        
        /**
         * @constructor
         * @param id    Record Id
         * @param name  Record Name
         */
        public RequestResponseDTO(Id id, String name) {
            this.id   = id;
            this.name = name;
        }
    }
    
    /* =========================================================
     * URGENT / CUSTOMER WORK REQUEST CREATION
     * ========================================================= */
    
    /**
     * @method createUrgentWorkRequestRecord
     * @description
     * Creates an Urgent Work Request or Customer Work Request
     * record based on the provided Record Type value.
     *
     * Features:
     * - Dynamically resolves Record Type
     * - Maps fixed payload fields
     * - Dynamically maps additionalinfo name/value pairs
     * - Performs type-safe field assignment using describe metadata
     *
     * @param requestBody      JSON string containing request data
     * @param recordTypeValue  Record Type name to apply
     * @return RequestResponseDTO  Contains Id and Name of created record
     */
    @AuraEnabled
    public static RequestResponseDTO createUrgentWorkRequestRecord(
        String requestBody,
    String recordTypeValue
    ) {
        
        Map<String, Object> payload =
            (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        
        if (payload == null || payload.isEmpty()) {
            return null;
        }
        
        // Resolve Record Type Id
        Id recordTypeId =
            Schema.SObjectType.NGMCP_Request__c
            .getRecordTypeInfosByName()
            .get(recordTypeValue)
            .getRecordTypeId();
        
        // Create request record
        NGMCP_Request__c requestObj = new NGMCP_Request__c();
        if(Schema.sObjectType.NGMCP_Request__c.fields.RecordTypeId.isCreateable()){
        	requestObj.RecordTypeId = recordTypeId;
        }
        
        
        /* -------- Fixed field mappings -------- */
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Reportedpriority__c.isCreateable()){
        	requestObj.NGMCP_Reportedpriority__c = String.valueOf((Integer) payload.get('reportedpriority'));
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Job_Type__c.isCreateable()){
        	requestObj.NGMCP_Job_Type__c =  (String) payload.get('job_type');
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Affectedphone__c.isCreateable()){
        	requestObj.NGMCP_Affectedphone__c = (String) payload.get('ngme_consphone');
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Description_Long_Description__c.isCreateable()){
        	requestObj.NGMCP_Description_Long_Description__c = (String) payload.get('description_longdescription');
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Job_SubType__c.isCreateable()){
        	requestObj.NGMCP_Job_SubType__c  = (String) payload.get('job_subtype');
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Target_Start__c.isCreateable()){
        	requestObj.NGMCP_Target_Start__c  = (String) payload.get('targetstart');
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Time__c.isCreateable()){
        	requestObj.NGMCP_Time__c = (String) payload.get('ngme_time');
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Source__c.isCreateable()){
        	requestObj.NGMCP_Source__c = (String) payload.get('source');
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Job_Sub_Sub_Type__c.isCreateable()){
        	requestObj.NGMCP_Job_Sub_Sub_Type__c  = (String) payload.get('job_sub_subtype');
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Liferay_Slot__c.isCreateable()){
        	requestObj.NGMCP_Liferay_Slot__c  = (String) payload.get('ngme_liferay_slot');
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Asset_Number__c.isCreateable()){
        	requestObj.NGMCP_Asset_Number__c  = (String) payload.get('assetnum');
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Supplier_Id__c.isCreateable()){
        	requestObj.NGMCP_Supplier_Id__c   = (String) payload.get('suppliercode');
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Industry__c.isCreateable()){
        	requestObj.NGMCP_Industry__c  = (String) payload.get('ngme_lf_mksctcd');
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Affected_Person__c.isCreateable()){
        	requestObj.NGMCP_Affected_Person__c  =(String) payload.get('ngme_consname');
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_MPRN__c.isCreateable()){
        	requestObj.NGMCP_MPRN__c = (String) payload.get('location');
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Callout_Status__c.isCreateable()){
        	requestObj.NGMCP_Callout_Status__c = 'In Progress';
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isCreateable()){
        	requestObj.NGMCP_Status__c  = 'Submitted';
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_API_Callout__c.isCreateable()){
        	requestObj.NGMCP_API_Callout__c = recordTypeValue == 'Customer Work Request' ? 'Customer Work Request Callout' : 'Urgent Work Request callout';
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Ngme_Constitle__c.isCreateable()){
        	requestObj.NGMCP_Ngme_Constitle__c  = (String) payload.get('ngme_constitle');
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Ngme_ConseMail__c.isCreateable()){
        	requestObj.NGMCP_Ngme_ConseMail__c  = (String) payload.get('ngme_consemail');
        }
         if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Reported_Email__c.isCreateable()){
        	requestObj.NGMCP_Reported_Email__c  = (String) payload.get('reportedemail');
        }
        
        /* -------- Dynamic additionalinfo mapping -------- */
        
        List<Object> addInfoList = (List<Object>) payload.get('additionalinfo');
        
        if (addInfoList != null && !addInfoList.isEmpty()) {
            
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.NGMCP_Request__c.fields.getMap();
            
            for (Object o : addInfoList) {
                Map<String, Object> row = (Map<String, Object>) o;
                
                String apiName = (String) row.get('name');
                Object rawValue = row.get('value');
                
                if (String.isBlank(apiName) || !fieldMap.containsKey(apiName)) {
                    continue;
                }
                
                try {
                    Schema.DescribeFieldResult dfr =
                        fieldMap.get(apiName).getDescribe();
                    
                    Object typedValue;
                    String s =
                        rawValue == null ? null : String.valueOf(rawValue);
                    
                    switch on dfr.getType() {
                        when Date {
                            typedValue =
                                String.isBlank(s) ? null : Date.valueOf(s);
                        }
                        when DateTime {
                            typedValue =
                                String.isBlank(s)
                                ? null
                                : DateTime.valueOf(s);
                        }
                        when Boolean {
                            typedValue = String.isBlank(s) ? null : s.toLowerCase() == 'true' || s == '1'|| s.toLowerCase() == 'yes';
                        }
                        when Integer {
                            typedValue = String.isBlank(s) ? null : Integer.valueOf(s);
                        }
                        when Double, Percent, Currency {
                            typedValue =  String.isBlank(s) ? null : Double.valueOf(s);
                        }
                        when else {
                            typedValue = s;
                        }
                    }
                    if(apiName=='NGMCP_sla__c'){
                        Date slaDate =  getSlaDueDate(Integer.valueOf(typedValue));
                        requestObj.put('NGMCP_SLA_Date__c', slaDate);
                    }
                    requestObj.put(apiName, typedValue);
                    
                } catch (Exception e) {
                }
            }
        }
        
        /* -------- Insert record -------- */
        if(Schema.sObjectType.NGMCP_Request__c.isCreateable()){
        	insert requestObj;
        }
        
        /* -------- Query to fetch Name -------- */
        
        NGMCP_Request__c insertedRec = [SELECT Id, Name FROM NGMCP_Request__c WHERE Id = :requestObj.Id with user_mode LIMIT 1];
        
        return new RequestResponseDTO(
            insertedRec.Id,
        insertedRec.Name
            );
    }
    
    public static Date getSlaDueDate(Integer slaBusinessDays) {
        if (slaBusinessDays == null || slaBusinessDays <= 0) {
            // You can change this to return null if preferred.
            return Date.today();
        }
        Date start = Date.today();
        Date endDate = start.addDays(60);
        Set<Date> holidaySet = new Set<Date>(HolidayService.getHolidaysBetween(start, endDate));
        return addBusinessDays(start, slaBusinessDays, holidaySet);
    }
    /**
     * Core utility: Adds 'businessDaysToAdd' business days to 'startDate'
     * skipping Saturdays, Sundays, and any dates present in 'holidays'.
     * The count starts from the day *after* startDate.
     *
     * For example:
     *   startDate: 2026-02-28
     *   businessDaysToAdd: 5
     *   no holidays/weekends in counted days
     *   => returns 2026-03-05
     */
    public static Date addBusinessDays(Date startDate, Integer businessDaysToAdd, Set<Date> holidays) {
        if (startDate == null || businessDaysToAdd == null || businessDaysToAdd <= 0) {
            return startDate;
        }
        
        Date d = startDate;
        Integer added = 0;
        while (added < businessDaysToAdd) {
            d = d.addDays(1);
            if (isBusinessDay(d, holidays)) {
                added++;
            }
        }
        return d;
    }
    
    // ---- helpers ----
    
    private static Boolean isBusinessDay(Date d, Set<Date> holidays) {
        return !isWeekend(d) && (holidays == null || !holidays.contains(d));
    }
    
    private static Boolean isWeekend(Date d) {
        if (d == null){
            return false;
        } 
        Date startOfWeek = d.toStartOfWeek(); 
        Integer offset = startOfWeek.daysBetween(d);
        return offset == 0 || offset == 6;
    }
    
    
    /**
     * @class FileWrapper
     * @description
     * Wrapper class to receive file payload from LWC.
     */
    public class FileWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String base64;
        @AuraEnabled public String type;
        @AuraEnabled public Integer size;
        @AuraEnabled public String dType;
    }
    
    /**
     * @method uploadFiles
     * @description
     * Creates Salesforce Files (ContentVersion) and links them
     * to the given record.
     *
     * @param recordId Target record Id
     * @param files    List of file payloads
     * @return Boolean true if upload succeeds
     */
    
    @AuraEnabled
    public static Boolean uploadFiles(Id recordId, String files) {
        
        if (String.isBlank(files)) {
            throw new AuraHandledException('No files provided');
        }
        
        // Process the JSON array one file at a time and insert each file
        // immediately, instead of decoding every file into a list of Blobs and
        // inserting them all at once. Holding every decoded Blob (plus the raw
        // input string) on the heap simultaneously is what exceeded the Apex
        // heap limit. By inserting and then dropping each Blob reference, only a
        // single file's data is ever live, so heap stays roughly constant
        // regardless of how many files are uploaded.
        Integer uploadedCount = 0;
        JSONParser parser = JSON.createParser(files);
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() != JSONToken.START_OBJECT) {
                continue;
            }
            
            FileWrapper fw = (FileWrapper) parser.readValueAs(FileWrapper.class);
            if (fw == null || String.isBlank(fw.base64)) {
                continue;
            }
            
            Blob body;
            try {
                body = EncodingUtil.base64Decode(fw.base64);
            } catch (Exception e) {
                fw.base64 = null;
                continue;
            }
            // Free this file's base64 string as soon as it is decoded so we
            // don't keep both the base64 text AND the decoded Blob on the heap.
            fw.base64 = null;
            
            if (body == null || body.size() == 0) {
                continue;
            }
            
            ContentVersion cv = new ContentVersion();
            cv.Title = stripExtension(fw.name);
            cv.PathOnClient = fw.name;
            cv.VersionData = body;
            cv.FirstPublishLocationId = recordId;
            insert cv;

            shareFileWithPortalUsers(cv.Id, recordId);
            uploadedCount++;
            
            // Drop references so this file's Blob can be garbage collected
            // before the next file is decoded.
            cv = null;
            body = null;
            fw = null;
        }
        
        if (uploadedCount == 0) {
            throw new AuraHandledException('No valid files to upload');
        }
        
        return true;
    }
    
    // Helper: make Title cleaner; not strictly required
    @TestVisible
    private static String stripExtension(String fileName) {
        if (String.isBlank(fileName)) return 'file';
        Integer dot = fileName.lastIndexOf('.');
        return (dot > 0 ? fileName.substring(0, dot) : fileName);
    }

    /**
     * Ensures a file linked to a request is visible to portal users (GSA/GSM).
     * FirstPublishLocationId creates an InternalUsers link for CRM uploads;
     * portal users cannot see those via getNotesAndFiles (WITH USER_MODE).
     */
    @TestVisible
    private static void shareFileWithPortalUsers(Id contentVersionId, Id recordId) {
        if (contentVersionId == null || recordId == null) {
            return;
        }

        ContentVersion cv = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentVersionId
            WITH USER_MODE
            LIMIT 1
        ];

        List<ContentDocumentLink> links = [
            SELECT Id, Visibility, ShareType
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :cv.ContentDocumentId
            AND LinkedEntityId = :recordId
            WITH USER_MODE
        ];

        if (!links.isEmpty()) {
            List<ContentDocumentLink> toUpdate = new List<ContentDocumentLink>();
            for (ContentDocumentLink link : links) {
                if (link.Visibility == 'AllUsers' && link.ShareType == 'V') {
                    continue;
                }
                if (Schema.sObjectType.ContentDocumentLink.fields.Visibility.isUpdateable()) {
                    link.Visibility = 'AllUsers';
                }
                if (Schema.sObjectType.ContentDocumentLink.fields.ShareType.isUpdateable()) {
                    link.ShareType = 'V';
                }
                toUpdate.add(link);
            }
            if (!toUpdate.isEmpty() && Schema.sObjectType.ContentDocumentLink.isUpdateable()) {
                update toUpdate;
            }
            return;
        }

        ContentDocumentLink cdl = new ContentDocumentLink();
        if (Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isCreateable()) {
            cdl.ContentDocumentId = cv.ContentDocumentId;
        }
        if (Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()) {
            cdl.LinkedEntityId = recordId;
        }
        if (Schema.sObjectType.ContentDocumentLink.fields.ShareType.isCreateable()) {
            cdl.ShareType = 'V';
        }
        if (Schema.sObjectType.ContentDocumentLink.fields.Visibility.isCreateable()) {
            cdl.Visibility = 'AllUsers';
        }
        if (Schema.sObjectType.ContentDocumentLink.isCreateable()) {
            insert cdl;
        }
    }
    
    /**
     * Upload multiple documents to Maximo as a JSON array body.
     * @param files    JSON string: List<FileWrapper> [{ name, base64 }, ...]
     * @param srticket Optional: SR ticket id (added as header if provided)
     * @return         Raw response body from Maximo
     */
    @AuraEnabled
    
    public static String uploadDocumentToMaximo(String files, String srticket, String uid, String doctype)  {
        // ---- Validate inputs ----
        uid = uid.contains('.') ? uid.split('\\.')[0] : uid;
        
        if (String.isBlank(srticket)) {
            throw new AuraHandledException('srticket (ticketuid) is required.');
        }
        if (String.isBlank(files)) {
            throw new AuraHandledException('No files provided (empty JSON string).');
        }
        
        final String RELATIVE_PATH =
            '/MXAPISR/' + EncodingUtil.urlEncode(uid, 'UTF-8') +
            '?relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1&ignorers=1';
        
        // ---- Send one file per callout instead of one large combined body ----
        // Putting every file's base64 into a single request body forces all of
        // that data (plus the serialized copy of it) onto the heap at once,
        // which exceeded the Apex heap limit. Here we stream-parse the input one
        // file at a time and send a separate Maximo PATCH/MERGE callout per file
        // (each MERGE simply appends its doclink to the ticket). Only one file's
        // base64 is ever live, so heap stays roughly constant regardless of how
        // many files are uploaded.
        Http http = new Http();
        Integer uploadedCount = 0;
        String lastResponseBody = '';
        
        JSONParser parser = JSON.createParser(files);
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() != JSONToken.START_OBJECT) {
                continue;
            }
            
            FileWrapper fw = (FileWrapper) parser.readValueAs(FileWrapper.class);
            if (fw == null || String.isBlank(fw.name) || String.isBlank(fw.base64)) {
                continue;
            }
            
            // Build the body for this single file.
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            gen.writeStringField('ticketuid', uid);
            gen.writeStringField('ticketid', srticket); // or Integer if API requires numeric
            gen.writeFieldName('doclinks');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('copylinktowo', '0');
            gen.writeStringField('doctype', 'Attachments');
            gen.writeStringField('documentdata', fw.base64); // Base64 string
            gen.writeStringField('urltype', 'FILE');
            gen.writeStringField('ngme_doctype', fw.dType ?? doctype);
            gen.writeStringField('upload', '1');
            gen.writeStringField('document', 'Doc1');
            gen.writeStringField('description', fw.name);
            gen.writeStringField('addinfo', '1');
            gen.writeStringField('ownertable', 'SR');
            gen.writeStringField('urlname', fw.name);
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
            
            // Free this file's base64 before materializing the body string.
            fw.base64 = null;
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:NGMCP_Maximo_Named_Credential' + RELATIVE_PATH);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-method-override', 'PATCH');
            req.setHeader('patchtype', 'MERGE');
            req.setHeader('properties', 'ticketid');
            req.setBody(gen.getAsString());
            req.setTimeout(120000);
            
            HttpResponse res;
            try {
                res = http.send(req);
            } catch (Exception e) {
                throw new AuraHandledException('Maximo callout failed: ' + e.getMessage());
            }
            
            Integer code = res.getStatusCode();
            lastResponseBody = res.getBody();
            
            if (code < 200 || code >= 300) {
                throw new AuraHandledException('Upload failed for "' + fw.name + '": ' + code + ' - ' + lastResponseBody);
            }
            
            uploadedCount++;
            
            // Drop references so this file's data can be garbage collected
            // before the next file is parsed.
            gen = null;
            req = null;
            res = null;
            fw = null;
        }
        
        if (uploadedCount == 0) {
            throw new AuraHandledException('No valid files to upload (invalid or empty base64).');
        }
        
        return lastResponseBody;
    }
    
    
    
}