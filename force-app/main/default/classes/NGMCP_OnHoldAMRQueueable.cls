public with sharing class NGMCP_OnHoldAMRQueueable  implements Queueable, Database.AllowsCallouts{
	
    public class JobItem {
        public Id createdTQId;
        public String payload;
        public NGMCP_Request__c onHoldAMR;
        
        public JobItem(Id createdTQId, String payload, NGMCP_Request__c onHoldAMR) {
            this.createdTQId = createdTQId;
            this.onHoldAMR = onHoldAMR;
            this.payload = payload;
        }
    }
    
    public final List<JobItem> items;
    
    public NGMCP_OnHoldAMRQueueable(List<JobItem> items) {
        this.items = items;
    }
    
    public void execute(QueueableContext qc){
        List<NGMCP_Request__c> tqToUpdate = new List<NGMCP_Request__c>();
        List<NGMCP_Request__c> onHoldAMRToCreate = new List<NGMCP_Request__c>();
        for(JobItem ji : items){
           	String relativePath;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            if (!String.isEmpty(ji.payload)) {
                relativePath = '/NGME_LR_CREATE_ENQ?relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1';
            }
            request.setEndpoint('callout:NGMCP_Maximo_Named_Credential' + relativePath);
            request.setMethod('POST');
            request.setHeader('properties', 'ticketid,ticketuid,targetstart,targetfinish');
            //request.setHeader('properties', 'ticketuid');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(ji.payload);
            request.setTimeout(120000);
            
            // Start time
            Long startTime = System.currentTimeMillis();
            
            HttpResponse response = http.send(request);
            
            Long endTime = System.currentTimeMillis();
            Long duration = endTime - startTime;
            // 200/201 treated as success for create
            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<NGMCP_Request__c> updateRequest =[
                    SELECT Id, NGMCP_Callout_Status__c, NGMCP_Callout_Response__c, NGMCP_SR_Ticket__c, NGMCP_Status__c
                    FROM NGMCP_Request__c
                    WHERE Id = :ji.createdTQId
                    with user_mode
                    LIMIT 1
                ];
                // Update request tracking record if still in-progress
                if (!updateRequest.isEmpty()) {
                    updateRequest[0].NGMCP_Callout_Status__c = 'Completed';
                    updateRequest[0].NGMCP_Callout_Response__c = response.getBody();
                    updateRequest[0].NGMCP_SR_Ticket__c = String.valueOf(result.get('ticketid'));
                    updateRequest[0].NGMCP_Ticketuid__c = String.valueOf(result.get('ticketuid'));
                    updateRequest[0].NGMCP_Status__c = 'Submitted';
                    tqToUpdate.add(updateRequest[0]);
                    
                    ji.onHoldAMR.NGMCP_Related_GPS_Job_Number__c = String.valueOf(result.get('ticketid'));
                    onHoldAMRToCreate.add(ji.onHoldAMR);
                }
            }
        }
        if(tqToUpdate != null && onHoldAMRToCreate != null){
            update tqToUpdate;
            insert onHoldAMRToCreate;
        }
    }
}