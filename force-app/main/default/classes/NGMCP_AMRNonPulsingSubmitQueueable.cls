public  with sharing class NGMCP_AMRNonPulsingSubmitQueueable implements Queueable, Database.AllowsCallouts  {
    public class JobItem {
        public Id requestId;
        public String payload;
        public JobItem(Id requestId, String payload) {
            this.requestId = requestId;
            this.payload = payload;
        }
    }
    public final List<JobItem> items;
    
    public NGMCP_AMRNonPulsingSubmitQueueable(List<JobItem> items) {
        this.items = items;
    }
    
    public void execute(QueueableContext qc){
        
        List<NGMCP_Request__c> reqListToUpdate = new List<NGMCP_Request__c>();
        for(JobItem ji : items){
            
            NGMCP_Mulesoft_Access_Code__c MAC = NGMCP_MulesoftIntegrationController.getMAC();
            
            String relativePath;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            if (!String.isEmpty(ji.payload)) {
                relativePath = '/v1/workRequest/createOnlineWorkRequest';
                
            }
            request.setEndpoint('callout:NGMCP_Mulesoft_Named_Credential' + relativePath);
            request.setMethod('POST');
           
            
            request.setHeader('client_id', System.Label.NGMCP_Mulesoft_Username);
            request.setHeader('client_secret', System.Label.NGMCP_Mulesoft_Password);
    
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            
            request.setHeader('Authorization', MAC.NGMCP_Token_Type__c + ' ' + MAC.NGMCP_Access_Code__c);
            request.setBody(ji.payload);
            request.setTimeout(120000);
            
            // Start time
            Long startTime = System.currentTimeMillis();
            
            HttpResponse response = http.send(request);
          
            Long endTime = System.currentTimeMillis();
            Long duration = endTime - startTime;
            System.debug('response: '+response.getBody());
            // 200/201 treated as success for create
            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                Map<String, Object> obj = (Map<String, Object>) result.get('obj');
                
                List<NGMCP_Request__c> updateRequest =[
                    SELECT Id, NGMCP_Callout_Status__c, NGMCP_Callout_Response__c, NGMCP_SR_Ticket__c, 
                    NGMCP_Status__c, NGMCP_Job_Type__c
                    FROM NGMCP_Request__c
                    WHERE Id = :ji.requestId 
                    WITH USER_MODE
                    //AND NGMCP_Callout_Status__c = 'In Progress'
                    LIMIT 1
                ];
                
               
				

                // Update request tracking record if still in-progress
                if (!updateRequest.isEmpty()) {
                    updateRequest[0].NGMCP_Callout_Status__c = 'Completed';
                    updateRequest[0].NGMCP_Callout_Response__c = response.getBody();
                    updateRequest[0].NGMCP_SR_Ticket__c = obj.get('p_WorkRequestID').toString();
                    updateRequest[0].NGMCP_Status__c = 'Submitted';
                    //updateRequest[0].NGMCP_Job_Type__c = String.valueOF(obj.get('p_JobType'));
                    //update updateRequest;
                    reqListToUpdate.add(updateRequest[0]);
                }
            } 
        }
        if(reqListToUpdate != null && !reqListToUpdate.isEmpty()){
            update reqListToUpdate;
        }
    }

}