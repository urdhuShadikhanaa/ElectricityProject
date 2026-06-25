public with sharing class NGMCP_AMRQueueable implements Queueable, Database.AllowsCallouts {
 
    public class JobItem {
        public NGMCP_Bulk_Request__c bulkRec;
        public Id requestId;
        public String amrPayload;
        public String tqPayload;
        public Id user;
        public String pulsing;
        public JobItem(NGMCP_Bulk_Request__c bulkRec, Id requestId, String amrPayload, Id user, String pulsing, String tqPayload) {
            this.bulkRec = bulkRec;
            this.requestId = requestId;
            this.amrPayload = amrPayload;
            this.user = user;
            this.pulsing = pulsing;
            this.tqPayload = tqPayload;
        }
    }

    private final List<JobItem> items;
    private final List<Id> brIds;
    private final String action;
    Private final String mode;

    public NGMCP_AMRQueueable(List<JobItem> items, List<Id> brIds, String action, String mode) {
        this.items = items;
        this.brIds = brIds;
        this.action = action;
        this.mode = mode;
    }

    public void execute(QueueableContext qc) {
        // Accumulators to run DML AFTER all callouts
        Map<Id,NGMCP_Bulk_Request__c> bulkUpdates = new Map<Id,NGMCP_Bulk_Request__c>();
        List<NGMCP_Request__c>      reqUpdates  = new List<NGMCP_Request__c>();
		List<NGMCP_Request__c>      reqCreates  = new List<NGMCP_Request__c>();
        Set<String> tickets = new Set<String>();
        Map<String,NGMCP_Bulk_Request__c> srNumBulkIdMap = new Map<String,NGMCP_Bulk_Request__c>();
	
        for (JobItem ji : items) {
            if(ji.requestId != null && action == 'AMR' && ((mode == 'STRT' && ji.Pulsing == 'YES') ||
               mode == 'STOP' || mode == 'SVST' || mode == 'RMVE') ){
                
NGMCP_Mulesoft_Access_Code__c mac;

if (Test.isRunningTest()) {
    mac = new NGMCP_Mulesoft_Access_Code__c(
        NGMCP_Token_Type__c = 'Bearer',
        NGMCP_Access_Code__c = 'DUMMY_TOKEN'
    );
} else {
    mac = NGMCP_MulesoftIntegrationController.getMAC();
}

                Boolean tokenUsable = mac != null 
                && !String.isBlank(mac.NGMCP_Token_Type__c) 
                && !String.isBlank(mac.NGMCP_Access_Code__c);
                String newStatus;
                String resp;
                String srticket = '';
    
                if (!tokenUsable) {
                    // No callout; we just stage the result (DML later)
                    newStatus = 'Failed';
                    resp = 'Submit error: Access token not available (or expired).';
                    bulkUpdates.put(ji.bulkRec.Id,new NGMCP_Bulk_Request__c(
                        Id = ji.bulkRec.Id,
                        NGMCP_Status__c = newStatus,
                        NGMCP_Response__c = resp
                    ));
                    // Optionally also mark the request
                    reqUpdates.add(new NGMCP_Request__c(
                        Id = ji.requestId,
                        NGMCP_Callout_Status__c = 'Failed',
                        NGMCP_Callout_Response__c = resp
                    ));
                    continue;
                }
    
                // -----------------
                // Callout (no DML!)
                // -----------------
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:NGMCP_Mulesoft_Named_Credential/v1/workRequest/createOnlineWorkRequest');
                req.setMethod('POST');
                req.setHeader('Content-Type',  'application/json');
                req.setHeader('Accept',        'application/json');
    
                // If you can, move client_id/secret to Named Credential (custom headers/params) and remove from code
                req.setHeader('client_id',     System.Label.NGMCP_Mulesoft_Username);
                req.setHeader('client_secret', System.Label.NGMCP_Mulesoft_Password);
    			if(Schema.sObjectType.NGMCP_Mulesoft_Access_Code__c.fields.NGMCP_Token_Type__c.isUpdateable() 
                   && Schema.sObjectType.NGMCP_Mulesoft_Access_Code__c.fields.NGMCP_Access_Code__c.isUpdateable()){
                	req.setHeader('Authorization', mac.NGMCP_Token_Type__c + ' ' + mac.NGMCP_Access_Code__c);
                }
                req.setBody(ji.amrPayload);
                req.setTimeout(120000);
    
                HttpResponse httpRes;
                try {
                    httpRes = new Http().send(req);
                    resp = httpRes.getBody();
                    System.debug('response in try: '+resp);
                    newStatus = 'Completed';
                } catch (Exception ex) {
                    newStatus = 'Submission Failed';
                    resp = 'Submit exception: ' + ex.getMessage();
    				System.debug('response in catch: '+resp);
                    // Stage updates (no DML yet)
                    bulkUpdates.put(ji.bulkRec.Id,new NGMCP_Bulk_Request__c(
                        Id = ji.bulkRec.Id,
                        NGMCP_Status__c = newStatus,
                        NGMCP_Response__c = resp
                    ));
                    reqUpdates.add(new NGMCP_Request__c(
                        Id = ji.requestId,
                        NGMCP_Callout_Status__c = 'Completed',
                        NGMCP_Callout_Response__c = resp
                    ));
                    continue;
                }
    			String responseBody = '';
                if (httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201) {
                    // Parse for ticket
                    String body = httpRes.getBody();
                    Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(body);
                    Map<String, Object> obj    = parsed != null ? (Map<String, Object>) parsed.get('obj') : null;
                    String ticket = (obj != null && obj.get('p_WorkRequestID') != null) ? String.valueOf(obj.get('p_WorkRequestID')) : null;
    				srticket = ticket;
                    NGMCP_Request__c amrRemove = new NGMCP_Request__c();
                    // Stage NGMCP_Request__c updates
                    tickets.add(ticket);
                    srNumBulkIdMap.put(ticket,ji.bulkRec);
                    if(mode == 'RMVE'){
                        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(ji.amrPayload);
                        NGMCP_Request__c requestObj = new NGMCP_Request__c();
                        requestObj.NGMCP_Contract_Reference__c = (String) m.get('p_ContractRef');
                        requestObj.NGMCP_Supplier_Id__c = (String) m.get('p_CustomerCode');
                        requestObj.NGMCP_Transaction_Reference__c = (String) m.get('p_TransactionRef');
                        requestObj.NGMCP_Job_Type__c = 'RMVE';
                        requestObj.NGMCP_MPRN__c = (String) m.get('p_MPRN');
                        requestObj.NGMCP_Service_Level__c = (String) m.get('p_ServiceLevel');
                        requestObj.NGMCP_Annual_Consumption__c = '1';
                        requestObj.NGMCP_Target_Start__c = (String) m.get('p_EffectiveDate');
                        requestObj.NGMCP_Reason__c = (String) m.get('p_CreateReason');
                        requestObj.NGMCP_Affectedphone__c = (String) m.get('p_SiteContact');
                        requestObj.NGMCP_Affected_Person__c = (String) m.get('p_SiteName');
                        requestObj.NGMCP_Affectedphone__c = (String) m.get('p_contactNo');
                        requestObj.NGMCP_Description_Long_Description__c = (String) m.get('p_Comments');
                        requestObj.NGMCP_Ngme_ConseMail__c = (String) m.get('p_Email');
                        requestObj.NGMCP_MAM_Id__c = (String) m.get('p_MAMId');
                        requestObj.NGMCP_Address__c = (String) m.get('p_Address');
                        requestObj.NGMCP_Postal_Town__c = (String) m.get('p_Posttown');
                        requestObj.NGMCP_Postal_Code__c = (String) m.get('p_PostCode');
                        requestObj.NGMCP_Correction_Conversion_Factor__c = m.get('p_CorrectionFactor').toString();
                        requestObj.NGMCP_Manufacturer__c = (String) m.get('p_MeterManufacturer');
                        requestObj.NGMCP_Current_Meter_Model__c = (String) m.get('p_MeterModel');
                        requestObj.NGMCP_Year_of_Manufacture__c = (String) m.get('p_MeterYOM');
                        requestObj.NGMCP_Current_Meter_Serialnumber__c = (String) m.get('p_MeterSerialNumber');
                        requestObj.NGMCP_No_of_Dials__c =  m.get('p_MeterDials').toString();
                        requestObj.NGMCP_Meter_Units_of_Measure__c = (String) m.get('p_MeterUnitofMeasure');
                        requestObj.NGMCP_Meter_Reading_Factor__c =  m.get('p_MeterReadingFactor').toString();
                        requestObj.NGMCP_Converter_Fitted_Indicator__c = (String) m.get('p_ConverterFittedIndicator');
                        requestObj.NGMCP_Converter_Serial_Number__c = (String) m.get('p_ConverterSerialNumber');
                        requestObj.NGMCP_Converter_Dials__c =  m.get('p_ConverterDials').toString();
                        requestObj.NGMCP_Converter_Reading_Factor__c =  m.get('p_ConverterReadingFactor').toString();
                        requestObj.NGMCP_Callout_Status__c = 'In Progress';
                        requestObj.NGMCP_API_Callout__c = 'Create AMR callout';
                        requestObj.NGMCP_Status__c = 'On Hold';
                        requestObj.NGMCP_Related_GPS_Job_Number__c = ticket;
                        Id amrRTId = Schema.SObjectType.NGMCP_Request__c.getRecordTypeInfosByName().get('AMR').getRecordTypeId();
        				requestObj.RecordTypeId = amrRTId;
                        reqCreates.add(requestObj);
                    }
    
                    // Stage bulk row update
                    newStatus = 'Completed';
                    
                    if(mode == 'STRT' || mode == 'STOP' || mode == 'SVST'){
                       responseBody = 'The AMR request has been created successfully.\n' + 
                           'The reference number is ' + ticket + '.';
                    }
                    
                    resp = body;
                    System.debug('responseBody: '+ responseBody);
                    reqUpdates.add(new NGMCP_Request__c(
                        Id = ji.requestId,
                        NGMCP_Callout_Status__c   = 'Completed',
                        NGMCP_Callout_Response__c = resp,
                        NGMCP_Status__c = 'Submitted',
                        NGMCP_SR_Ticket__c = ticket
                    ));
                } 
                else {
                    newStatus = 'Failed';
                    resp = 'Submit error: ' + httpRes.getBody();
    
                    // Stage request update (optional)
                    reqUpdates.add(new NGMCP_Request__c(
                        Id = ji.requestId,
                        NGMCP_Callout_Status__c   = 'Completed',
                        NGMCP_Callout_Response__c = resp
                    ));
                }
    
                bulkUpdates.put(ji.bulkRec.Id,new NGMCP_Bulk_Request__c(
                    Id = ji.bulkRec.Id,
                    NGMCP_Status__c = newStatus,
                    NGMCP_Response__c = responseBody,
                    NGMCP_Request_Id__c = ji.requestId,
                    NGMCP_Service_Request_Number__c = srticket
                ));
            }
            else if (ji.requestId != null && action == 'AMR' && mode == 'STRT' && ji.Pulsing == 'NO'){
                String newStatus;
                String resp;
                String relativePath;
                String srticket = '';
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                System.debug('TQ Request Body: ' + ji.tqPayload);
                if (!String.isEmpty(ji.tqPayload)) {
                    relativePath = '/NGME_LR_CREATE_ENQ?relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1';
                    System.debug('relativePath: ' + relativePath);
                }
                request.setEndpoint('callout:NGMCP_Maximo_Named_Credential' + relativePath);
                request.setMethod('POST');
                request.setHeader('properties', 'ticketid,ticketuid,targetstart,targetfinish');
                request.setHeader('Content-Type', 'application/json');
                request.setBody(ji.tqPayload);
                request.setTimeout(120000);
                
                // Start time
                Long startTime = System.currentTimeMillis();
                
                HttpResponse response; //= http.send(request);
                
               try {
                    response = http.send(request);
                    resp = response.getBody();
                    System.debug('response: '+resp);
                    newStatus = 'Completed';
                } 
                catch (Exception ex) {
                    newStatus = 'Submission Failed';
                    resp = 'Submit exception: ' + ex.getMessage();
    
                    // Stage updates (no DML yet)
                    bulkUpdates.put(ji.bulkRec.Id,new NGMCP_Bulk_Request__c(
                        Id = ji.bulkRec.Id,
                        NGMCP_Status__c = newStatus,
                        NGMCP_Response__c = resp
                    ));
                    reqUpdates.add(new NGMCP_Request__c(
                        Id = ji.requestId,
                        NGMCP_Callout_Status__c = 'Completed',
                        NGMCP_Callout_Response__c = resp
                    ));
                    continue;
                }
                 if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                    // Parse for ticket
                    String body = response.getBody();
                    Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(body);
                    String ticket = String.valueOf(parsed.get('ticketid'));
                    srticket = ticket;
                    tickets.add(ticket);
                    srNumBulkIdMap.put(ticket,ji.bulkRec);
                    // Stage NGMCP_Request__c updates
                    reqUpdates.add(new NGMCP_Request__c(
                        Id = ji.requestId,
                        NGMCP_Callout_Status__c   = 'Completed',
                        NGMCP_Callout_Response__c = body,
                        NGMCP_SR_Ticket__c        = ticket,
                        NGMCP_Status__c           = 'Submitted',
                        NGMCP_Ticketuid__c        = String.valueOf(parsed.get('ticketuid'))
                    ));
                    	Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(ji.amrPayload);
                        NGMCP_Request__c requestObj = new NGMCP_Request__c();
                     	if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Contract_Reference__c.isCreateable()){
        					requestObj.NGMCP_Contract_Reference__c = (String) m.get('p_ContractRef');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Supplier_Id__c.isCreateable()){
        					requestObj.NGMCP_Supplier_Id__c = (String) m.get('p_CustomerCode');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Transaction_Reference__c.isCreateable()){
        					requestObj.NGMCP_Transaction_Reference__c = (String) m.get('p_TransactionRef');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Job_Type__c.isCreateable()){
        					requestObj.NGMCP_Job_Type__c = 'STRT';
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_MPRN__c.isCreateable()){
        					requestObj.NGMCP_MPRN__c = (String) m.get('p_MPRN');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Service_Level__c.isCreateable()){
        					requestObj.NGMCP_Service_Level__c = (String) m.get('p_ServiceLevel');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Annual_Consumption__c.isCreateable()){
        					requestObj.NGMCP_Annual_Consumption__c = '1';
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Target_Start__c.isCreateable()){
        					requestObj.NGMCP_Target_Start__c = (String) m.get('p_EffectiveDate');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Reason__c.isCreateable()){
        					requestObj.NGMCP_Reason__c = (String) m.get('p_CreateReason');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Affectedphone__c.isCreateable()){
        					requestObj.NGMCP_Affectedphone__c = (String) m.get('p_SiteContact');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Affected_Person__c.isCreateable()){
        					requestObj.NGMCP_Affected_Person__c = (String) m.get('p_SiteName');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Affectedphone__c.isCreateable()){
        					requestObj.NGMCP_Affectedphone__c = (String) m.get('p_contactNo');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Description_Long_Description__c.isCreateable()){
        					requestObj.NGMCP_Description_Long_Description__c = (String) m.get('p_Comments');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Ngme_ConseMail__c.isCreateable()){
        					requestObj.NGMCP_Ngme_ConseMail__c = (String) m.get('p_Email');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_MAM_Id__c.isCreateable()){
        					requestObj.NGMCP_MAM_Id__c = (String) m.get('p_MAMId');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Address__c.isCreateable()){
        					requestObj.NGMCP_Address__c = (String) m.get('p_Address');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Postal_Town__c.isCreateable()){
        					requestObj.NGMCP_Postal_Town__c = (String) m.get('p_Posttown');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Postal_Code__c.isCreateable()){
        					requestObj.NGMCP_Postal_Code__c = (String) m.get('p_PostCode');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Correction_Conversion_Factor__c.isCreateable()){
        					requestObj.NGMCP_Correction_Conversion_Factor__c = m.get('p_CorrectionFactor').toString();
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Manufacturer__c.isCreateable()){
        					requestObj.NGMCP_Manufacturer__c = (String) m.get('p_MeterManufacturer');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Current_Meter_Model__c.isCreateable()){
        					requestObj.NGMCP_Current_Meter_Model__c = (String) m.get('p_MeterModel');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Year_of_Manufacture__c.isCreateable()){
        					requestObj.NGMCP_Year_of_Manufacture__c = (String) m.get('p_MeterYOM');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Current_Meter_Serialnumber__c.isCreateable()){
        					requestObj.NGMCP_Current_Meter_Serialnumber__c = (String) m.get('p_MeterSerialNumber');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_No_of_Dials__c.isCreateable()){
        					requestObj.NGMCP_No_of_Dials__c =  m.get('p_MeterDials').toString();
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Meter_Units_of_Measure__c.isCreateable()){
        					requestObj.NGMCP_Meter_Units_of_Measure__c = (String) m.get('p_MeterUnitofMeasure');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Meter_Reading_Factor__c.isCreateable()){
        					requestObj.NGMCP_Meter_Reading_Factor__c =  m.get('p_MeterReadingFactor').toString();
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Converter_Fitted_Indicator__c.isCreateable()){
        					requestObj.NGMCP_Converter_Fitted_Indicator__c = (String) m.get('p_ConverterFittedIndicator');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Converter_Serial_Number__c.isCreateable()){
        					requestObj.NGMCP_Converter_Serial_Number__c = (String) m.get('p_ConverterSerialNumber');
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Converter_Dials__c.isCreateable()){
        					requestObj.NGMCP_Converter_Dials__c =  m.get('p_ConverterDials').toString();
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Converter_Reading_Factor__c.isCreateable()){
        					requestObj.NGMCP_Converter_Reading_Factor__c =  m.get('p_ConverterReadingFactor').toString();
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Callout_Status__c.isCreateable()){
        					requestObj.NGMCP_Callout_Status__c = 'In Progress';
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_API_Callout__c.isCreateable()){
        					requestObj.NGMCP_API_Callout__c = 'Create AMR callout';
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isCreateable()){
        					requestObj.NGMCP_Status__c = 'On Hold';
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Related_GPS_Job_Number__c.isCreateable()){
        					requestObj.NGMCP_Related_GPS_Job_Number__c = ticket;
        				}
                        
                     	Id amrRTId = Schema.SObjectType.NGMCP_Request__c.getRecordTypeInfosByName().get('AMR').getRecordTypeId();
                     	if(Schema.sObjectType.NGMCP_Request__c.fields.RecordTypeId.isCreateable()){
        					requestObj.RecordTypeId = amrRTId;
        				}
        				
                        reqCreates.add(requestObj);
                } 
                else {
                    newStatus = 'Failed';
                    resp = 'Submit error: ' + response.getBody();
    
                    // Stage request update (optional)
                    reqUpdates.add(new NGMCP_Request__c(
                        Id = ji.requestId,
                        NGMCP_Callout_Status__c   = 'Completed',
                        NGMCP_Callout_Response__c = resp
                    ));
                }
    
                bulkUpdates.put(ji.bulkRec.Id,new NGMCP_Bulk_Request__c(
                    Id = ji.bulkRec.Id,
                    NGMCP_Status__c = newStatus,
                    NGMCP_Response__c = resp,
                    NGMCP_Request_Id__c = ji.requestId,
                    NGMCP_Service_Request_Number__c = srticket
                ));
                
            }
        }
		System.debug('reqUpdates: '+reqUpdates);
        System.debug('bulkUpdates: '+bulkUpdates);
        System.debug('reqCreates: '+reqCreates);
        // --------------------
        // DML after callouts 
        // --------------------
        if (!reqUpdates.isEmpty())  Database.update(reqUpdates,  false);
        
        if (!reqCreates.isEmpty() && Schema.sObjectType.NGMCP_Request__c.isCreateable()) Database.insert(reqCreates, false);
        
        if(tickets != null && srNumBulkIdMap != null){
            List<NGMCP_Request__c> amrList = [Select Id, Name, NGMCP_Related_GPS_Job_Number__c
            FROM NGMCP_Request__c
            WHERE NGMCP_Related_GPS_Job_Number__c IN: tickets with user_mode];
            if(amrList != null){
                for(NGMCP_Request__c amr : amrList){
                    if(srNumBulkIdMap.containsKey(amr.NGMCP_Related_GPS_Job_Number__c)){
                        
                        String response = '';
                        if(mode == 'STRT'){
                            response = 'The AMR Request has been created Successfully and is currently on hold due to the existing meter being non-pulsing.\n' +
                        'The reference number is ' + amr.Name + '.\n' +
                        'NGM will arrange for the exchange of the non-pulsing meter and process the AMR request once complete.\n' +
                        'The reference number is ' + amr.NGMCP_Related_GPS_Job_Number__c + '.';
                        }
                        if(mode == 'RMVE'){
                          response = 'The AMR Removal Request has been created Successfully and is currently on hold to Process the AMR Stop.\n' +
                            'The reference number is ' + amr.Name + '.\n' +
                            'NGM will process the AMR Stop and process the AMR Removal request once complete.\n' +
                            'The reference number is ' + amr.NGMCP_Related_GPS_Job_Number__c + '.';  
                        }
                        bulkUpdates.put(srNumBulkIdMap.get(amr.NGMCP_Related_GPS_Job_Number__c).Id,
                                        new NGMCP_Bulk_Request__c( 
                        Id = srNumBulkIdMap.get(amr.NGMCP_Related_GPS_Job_Number__c).Id,
                        NGMCP_Status__c = 'Completed',
                        NGMCP_Response__c = response,
                        NGMCP_Service_Request_Number__c = amr.NGMCP_Related_GPS_Job_Number__c));
                    }
                }
            }
        }

        if (!bulkUpdates.isEmpty()) Database.update(bulkUpdates.values(), false);
        Boolean alreadySent = false;
        if (alreadySent == false && !Test.isRunningTest()) {
            String csv = NGMCP_AMRBulkController.buildCsv(brIds);
            System.debug('csv: '+csv);
            // Email to initiator
            User u = [SELECT Id, Email, Name FROM User WHERE Id = :items[0].user with user_mode LIMIT 1];
    
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(u.Id);
            mail.setSaveAsActivity(false);
            mail.setSubject('AMR Bulk Results (' + Datetime.now().format() + ')');
            mail.setPlainTextBody('Please find the attached results.');
            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
            att.setFileName('AMR_Bulk_Result.csv'); // Excel will open CSV fine
            att.setContentType('text/csv');
            att.setInline(false);
            att.setBody(Blob.valueOf(csv));
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { att });
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
            
            alreadySent = true;
            System.debug('alreadySent'+alreadySent);
        }
    }
}