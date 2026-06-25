public with sharing class NGMCP_JobRequestCalloutQueueable implements Queueable, Database.AllowsCallouts  {
    private String requestBody;
    private Id requestId;

    public NGMCP_JobRequestCalloutQueueable(String requestBody, Id requestId) {
        this.requestBody = requestBody;
        this.requestId = requestId;
    }

    public void execute(QueueableContext context) {
        String relativePath;
        HttpRequest request = new HttpRequest();
         relativePath = '/NGME_SR_CRT?relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1&ignorers=1';
        request.setEndpoint('callout:NGMCP_Maximo_Named_Credential' + relativePath);
       request.setMethod('POST');
       // request.setHeader('x-method-override', 'PATCH');
         request.setHeader('properties', 'TICKETID');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);
        request.setTimeout(120000);

        Http http = new Http();
        HttpResponse res = http.send(request);

        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            NGMCP_Request__c record = [
                SELECT Id, NGMCP_Callout_Status__c, NGMCP_Callout_Response__c, NGMCP_SR_Ticket__c FROM NGMCP_Request__c WHERE Id = :requestId LIMIT 1
            ];
            record.NGMCP_Callout_Status__c = 'Completed';
            record.NGMCP_Callout_Response__c = res.getBody();
            record.NGMCP_SR_Ticket__c = (String)result.get('ticketid');
            update record;
        } else {
            // Handle error
        }
    }

}