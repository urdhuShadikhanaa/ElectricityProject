public with sharing class NGMCP_AMRUpdateClass {
	
    public static List<NGMCP_AMRClass.ObjListClass> fetchAMRRecords() {
        NGMCP_Mulesoft_Access_Code__c MAC = NGMCP_MulesoftIntegrationController.getMAC();
        
        String relativePath = '/v1/getDetails';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String requestBody = '{}';
       	
       	if (!String.isEmpty(requestBody)) {
        
        
        }
        request.setEndpoint('callout:NGMCP_Mulesoft_Named_Credential' + relativePath);
        request.setMethod('POST');
        request.setHeader('client_id', System.Label.NGMCP_Mulesoft_Username);
        request.setHeader('client_secret', System.Label.NGMCP_Mulesoft_Password);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Content-Length', String.valueOf(requestBody.length()));
        request.setHeader('Authorization', MAC.NGMCP_Token_Type__c + ' ' + MAC.NGMCP_Access_Code__c);
        request.setBody(requestBody);
        request.setTimeout(120000);
        
        HttpResponse response;
        List<NGMCP_AMRClass.ObjListClass> records;
        
        try {
            response = http.send(request);
            
            Integer statusCode = response.getStatusCode();
            
            if(statusCode == 200){
                
                NGMCP_AMRClass req = NGMCP_AMRClass.parse(response.getBody());
                
                if(!req.objList.isEmpty()){
                    records = req.objList;
                }
                
                
            }
        } catch (Exception e) {
            
            throw new CalloutException('Get request callout failed: ' + e.getMessage());
        }

        return (records == null) ? new List<NGMCP_AMRClass.ObjListClass>() : records;
    }
    
    public static List<NGMCP_AMRClass.ObjListClass> fetchAMRScheduler() {
        NGMCP_Mulesoft_Access_Code__c MAC = NGMCP_MulesoftIntegrationController.getMAC();
        
        String relativePath = '/v1/getCWRDetails?p_MPRN=';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String requestBody = '{}';
       	
       	if (!String.isEmpty(requestBody)) {
        
        
        }
        request.setEndpoint('callout:NGMCP_Mulesoft_Named_Credential' + relativePath);
        request.setMethod('POST');
        request.setHeader('client_id', System.Label.NGMCP_Mulesoft_Username);
        request.setHeader('client_secret', System.Label.NGMCP_Mulesoft_Password);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Content-Length', String.valueOf(requestBody.length()));
        request.setHeader('Authorization', MAC.NGMCP_Token_Type__c + ' ' + MAC.NGMCP_Access_Code__c);
        request.setBody(requestBody);
        request.setTimeout(120000);
        
        HttpResponse response;
        List<NGMCP_AMRClass.ObjListClass> records;
        
        try {
            response = http.send(request);
            
            Integer statusCode = response.getStatusCode();
            
            if(statusCode == 200){
                
                NGMCP_AMRClass req = NGMCP_AMRClass.parse(response.getBody());
                
                if(!req.objList.isEmpty()){
                    records = req.objList;
                }
                
                
            }
        } catch (Exception e) {
            
            throw new CalloutException('Get request callout failed: ' + e.getMessage());
        }

        return (records == null) ? new List<NGMCP_AMRClass.ObjListClass>() : records;
    }
    
    
	
    public static String toDdMmYyyy(String isoLocalDateTime) {
        if (String.isBlank(isoLocalDateTime)) return null;
        try {
            // Take only the date segment: "yyyy-MM-dd"
            String datePart = isoLocalDateTime.substring(0, 10);
            Date d = Date.valueOf(datePart);
    
            // Convert Date -> Datetime (00:00:00) and format with pattern
            Datetime dt = Datetime.newInstance(d, Time.newInstance(0, 0, 0, 0));
            return dt.format('dd/MM/yyyy');   // e.g., "18/01/2024"
        } catch (Exception e) {
            return null; // or throw, based on your preference
        }
	}

    public class CalloutException extends Exception {}
}