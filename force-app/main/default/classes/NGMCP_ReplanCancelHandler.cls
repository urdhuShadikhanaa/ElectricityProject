public with sharing class NGMCP_ReplanCancelHandler {
    
    @AuraEnabled
    /**
     * Submit a Replan/Cancel Job (Service Request create) to Maximo.
     * Writes back the SR ticket id and full response to NGMCP_Request__c for auditability.
     *
     * Performance:
     * - Captures duration for troubleshooting downstream latency.
     *
     * @param requestBody JSON body defining the SR payload.
     * @param requestId   NGMCP_Request__c Id to store status/response/ticket id.
     * @return Raw response body string on success.
     * @throws AuraHandledException on non-2xx responses.
     */
    public static Object  submitCancelJob(String requestBody, Id requestId, String ticketuid, String reportedEmail) {
        String relativePath;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        if (!String.isEmpty(requestBody)) {
            relativePath = '/NGME_CNRPN_ADI_RSMT/' + ticketuid + '?relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1&ignorers=1';
        }
        request.setEndpoint('callout:NGMCP_Maximo_Named_Credential' + relativePath);
        request.setMethod('POST');
        request.setHeader('properties', 'ticketid, ticketuid');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-method-override', 'PATCH');
        request.setHeader('patchtype', 'MERGE');
        request.setBody(requestBody);
        request.setTimeout(120000);
        
        // Start time
        Long startTime = System.currentTimeMillis();
        
        HttpResponse response = http.send(request);
        
        Long endTime = System.currentTimeMillis();
        Long duration = endTime - startTime;
        // 200/201 treated as success for create
        if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            //Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<NGMCP_Request__c> updateRequest =[
                SELECT Id, NGMCP_Callout_Status__c, NGMCP_Callout_Response__c, NGMCP_SR_Ticket__c,
                NGMCP_Target_Start__c, NGMCP_Time__c,NGMCP_Reported_Email__c, NGMCP_Reason__c,
                NGMCP_Status__c
                FROM NGMCP_Request__c
                WHERE Id = :requestId 
                with user_mode
                LIMIT 1
            ];
            // Update request tracking record if it is completed
            
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);

            if (!updateRequest.isEmpty() && !payload.isEmpty()) {
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
        			updateRequest[0].NGMCP_Status__c = (String) payload.get('action') == 'CANCELLED' ? 'Cancelled' : (String) payload.get('action') == 'REQUESTED CANCEL' ? 'Cancellation Requested' : (String) payload.get('action') == 'REPLAN' ? 'Replanned' : (String) payload.get('action') == 'REQUESTED REPLAN' ? 'Replan Requested' : '';
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Target_Start__c.isUpdateable()){
                   updateRequest[0].NGMCP_Target_Start__c = String.isNotBlank((String) payload.get('target1start')) ? (String) payload.get('target1start') : updateRequest[0].NGMCP_Target_Start__c; 
                }
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Time__c.isUpdateable()){
                   updateRequest[0].NGMCP_Time__c = String.isNotBlank((String) payload.get('ngme_time')) ? (String) payload.get('ngme_time') : updateRequest[0].NGMCP_Time__c; 
                }
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Reason__c.isUpdateable()){
                   updateRequest[0].NGMCP_Reason__c = (String) payload.get('reason');
                }
                
                //updateRequest[0].NGMCP_Callout_Response__c = response.getBody();
                //updateRequest[0].NGMCP_SR_Ticket__c = String.valueOf(result.get('ticketid'));
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Reported_Email__c.isUpdateable()){
                   updateRequest[0].NGMCP_Reported_Email__c = reportedEmail; 
                }
                
                try {
                    if(Schema.sObjectType.NGMCP_Request__c.isUpdateable()){
                    	update updateRequest;
                    }
                } catch (Exception e) {
                    // Even if update fails, we still want to return the response body
                }
            }
            return response.getBody();
        } else {
            // Surface a user-friendly exception to Lightning consumers
            throw new AuraHandledException('Failed to replan/cancel job. Status: ' + response.getStatus() + ' - ' + response.getBody());
        }
    }

      /**
     * @method updateNSRequest
     * @description Update NS NGMCP_Request__c record in Salesforce.
     * @param requestBody - JSON string containing data query details.
     * @return Id - The Id of the newly created NGMCP_Request__c record.
     */

        @AuraEnabled
        public static NGMCP_Request__c  updateNSRequest(String requestBody, Id requestId, String reportedEmail) {
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            //List<NGMCP_Request__c>
            List<NGMCP_Request__c> requestObjList = [
                SELECT Id,NGMCP_Callout_Status__c,NGMCP_Status__c,
                NGMCP_Target_Start__c, NGMCP_Time__c,NGMCP_Reported_Email__c, NGMCP_Reason__c
                FROM NGMCP_Request__c
                WHERE Id = :requestId 
                with user_mode
                LIMIT 1
            ];
            
            if (!payload.isEmpty() && !requestObjList.isEmpty()) { 
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                   requestObjList[0].NGMCP_Status__c = (String) payload.get('action') == 'CANCELLED' ? 'Cancelled' : (String) payload.get('action') == 'REQUESTED CANCEL' ? 'Cancellation Requested' : (String) payload.get('action') == 'REPLAN' ? 'Replanned' : (String) payload.get('action') == 'REQUESTED REPLAN' ? 'Replan Requested' : ''; 
                }
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Target_Start__c.isUpdateable()){
                   requestObjList[0].NGMCP_Target_Start__c = String.isNotBlank((String) payload.get('target1start')) ? (String) payload.get('target1start') : requestObjList[0].NGMCP_Target_Start__c;
                }
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Time__c.isUpdateable()){
                   requestObjList[0].NGMCP_Time__c = String.isNotBlank((String) payload.get('ngme_time')) ? (String) payload.get('ngme_time') : requestObjList[0].NGMCP_Time__c;
                }
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Reason__c.isUpdateable()){
                   requestObjList[0].NGMCP_Reason__c = (String) payload.get('reason');
                }
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Reported_Email__c.isUpdateable()){
                   requestObjList[0].NGMCP_Reported_Email__c = reportedEmail; 
                }
                
                if(Schema.sObjectType.NGMCP_Request__c.isUpdateable()){
                	update requestObjList[0];
                }
                return requestObjList[0];
            }else{
                return null;
            }

                
        }

        @AuraEnabled
        public static List<ServiceAppointment> getSA(Id requestid){
            List<string> statuses = new List<string>();
            statuses.add('None');
            //statuses.add('Enroute');
            statuses.add('Scheduled');
            List<ServiceAppointment> saList = [SELECT Id, Status, ParentRecordId FROM ServiceAppointment 
            WHERE ParentRecordId IN (SELECT Id FROM WorkOrder WHERE NGMCP_Request_Number__c = :requestId)
            AND Status in :statuses
            with user_mode];
            if(!saList.isEmpty()){
                return saList;
            }
            else{
                return null;
            }
        }

        @AuraEnabled
        public static NGMCP_Request__c getRequest(Id requestid) {
       List<NGMCP_Request__c> reqList = [SELECT Id, Name, NGMCP_Callout_Status__c, NGMCP_Callout_Response__c, 
       NGMCP_SR_Ticket__c, NGMCP_Ticketuid__c, NGMCP_Comment__c, NGMCP_Target_Start__c, NGMCP_Status__c, NGMCP_Meter_Type__c,
       NGMCP_Time__c,NGMCP_Reported_Email__c, NGMCP_Job_Type__c, NGMCP_Job_SubType__c, NGMCP_Resolution_Date__c,NGMCP_SLA_Date__c,
       NGMCP_Job_Sub_Sub_Type__c,NGMCP_Non_Standard__c,NGMCP_Quotation_Status__c,NGMCP_Enquiry_Type__c,NGMCP_Current_Meter_Type__c,
       NGMCP_ADI_expries_on__c, NGMCP_ADI_Status__c,RecordTypeId,RecordType.DeveloperName,(SELECT ID From Work_Orders__r), NGMCP_Model__c, NGMCP_Current_Meter_Model__c,
       NGMCP_MIcro_Buisness__c, NGMCP_Market_Sector_Code__c,NGMCP_Industry__c                                  

                FROM NGMCP_Request__c
                WHERE Id = :requestId 
                with user_mode
                LIMIT 1]; 
        if(!reqList.isEmpty()){
            return reqList[0];
        }
        else{
            return null;
        }
    
    }

    @AuraEnabled
    /**
     * Submit a Accept/Reject Quotation (Service Request create) to Maximo.
     * Writes back the SR ticket id and full response to NGMCP_Request__c for auditability.
     *
     * Performance:
     * - Captures duration for troubleshooting downstream latency.
     *
     * @param requestBody JSON body defining the SR payload.
     * @param requestId   NGMCP_Request__c Id to store status/response/ticket id.
     * @return Raw response body string on success.
     * @throws AuraHandledException on non-2xx responses.
     */
    public static Object  submitAcceptRejectQuotation(String requestBody, Id requestId) {
        String relativePath;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        if (!String.isEmpty(requestBody)) {
            relativePath = '/NGME_LFRAY_MODIFYWO';
        }
        request.setEndpoint('callout:NGMCP_Maximo_Integration_Accept_Reject_Quotation' + relativePath);
        request.setMethod('POST');
        request.setHeader('properties', 'ticketid, ticketuid');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);
        request.setTimeout(120000);
        
        // Start time
        Long startTime = System.currentTimeMillis();
        
        HttpResponse response = http.send(request);
        System.debug('response: '+response);
        System.debug('response body: '+response.getBody());
        Long endTime = System.currentTimeMillis();
        Long duration = endTime - startTime;
        
        // 200/201 treated as success for create
        if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            //Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<NGMCP_Request__c> updateRequest =[
                SELECT Id, NGMCP_Callout_Status__c, NGMCP_Callout_Response__c, NGMCP_SR_Ticket__c,
                NGMCP_Comment__c,NGMCP_Quotation_Status__c
                FROM NGMCP_Request__c
                WHERE Id = :requestId 
                with user_mode
                LIMIT 1
            ];
            // Update request tracking record if it is completed
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);

            if (!updateRequest.isEmpty() && !payload.isEmpty()) {
                updateRequest[0].NGMCP_Quotation_Status__c = (String) payload.get('status');
                updateRequest[0].NGMCP_Comment__c = (String) payload.get('comment');
                
                //updateRequest[0].NGMCP_Callout_Response__c = response.getBody();
             
                update updateRequest;
            }
            return response.getBody();
        } else {
            // Surface a user-friendly exception to Lightning consumers
            throw new AuraHandledException('Failed to accept/reject quotation. Status: ' + response.getBody());
        }
    }

     @AuraEnabled
    public static Id uploadAndLinkFileToRequest(String requestId, String fileName, String base64Data) {
        // Strengthened validation: explicit null checks + blank checks
        if (requestId == null || String.isBlank(requestId) || String.isBlank(fileName) || String.isBlank(base64Data)) {
            throw new AuraHandledException('Missing required parameters.');
        }

        // Ensure requestId is a valid Id that exists and is of expected sObject type
        Id reqId;
        try {
            reqId = (Id) requestId;
        } catch (Exception e) {
            throw new AuraHandledException('Missing required parameters.');
        }

        // Create ContentVersion
        ContentVersion cv = new ContentVersion();
        if(Schema.sObjectType.ContentVersion.fields.Title.isCreateable()){
        	cv.Title = fileName;
        }
        if(Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable()){
        	cv.PathOnClient = '/' + fileName;
        }
        if(Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable()){
        	cv.VersionData = EncodingUtil.base64Decode(base64Data);
        }
        if(Schema.sObjectType.ContentVersion.isCreateable()){
        	insert cv;
        }
        

        // Query back ContentDocumentId
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id with user_mode];

        // Link document to NGMCP_Request__c
        ContentDocumentLink cdl = new ContentDocumentLink();
        if(Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isCreateable()){
        	cdl.ContentDocumentId = cv.ContentDocumentId;
        }
        if(Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()){
        	cdl.LinkedEntityId = reqId;
        }
        if(Schema.sObjectType.ContentDocumentLink.fields.ShareType.isCreateable()){
        	cdl.ShareType = 'V'; 
        }
        if(Schema.sObjectType.ContentDocumentLink.fields.Visibility.isCreateable()){
        	cdl.Visibility = 'AllUsers';
        }
        if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
        	insert cdl;
        }
        

        return cv.ContentDocumentId;
    }

    @AuraEnabled
    public static Object callViewCompletionDetailsAPI(String ticketid){
        String relativePath = '/NGME_LFRAY_GETCOMDET?ticketid=' + ticketid;
        HTTP http = new HTTP();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:NGMCP_Maximo_Integration_Accept_Reject_Quotation' + relativePath);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            
            return response.getBody();
        } else {
            throw new AuraHandledException('Failed to fetch completion details: ' + response.getStatus());
        }
    }

}