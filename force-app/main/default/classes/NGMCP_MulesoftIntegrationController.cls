public with sharing class NGMCP_MulesoftIntegrationController {
    
    public class CalloutException extends Exception {}

    /**
     * POST with application/x-www-form-urlencoded
     */
    public static String postFormUrlEncoded(String endpoint, Map<String,String> formData, Map<String,String> headers) {
        if (String.isBlank(endpoint)) throw new IllegalArgumentException('Endpoint is required.');
        if (formData == null || formData.isEmpty()) throw new IllegalArgumentException('formData must not be empty.');

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(20000);

        if (headers != null) {
            for (String k : headers.keySet()) {
                req.setHeader(k, headers.get(k));
            }
        }

        req.setBody(buildBody(formData));
        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
        } catch (System.CalloutException ex) {
            throw new CalloutException('HTTP callout failed: ' + ex.getMessage());
        }

        Integer sc = res.getStatusCode();
        if (sc < 200 || sc >= 300) {
            //throw new CalloutException('Non-success: ' + sc + ' ' + res.getStatus() + ' — ' + truncate(res.getBody(), 3000));
            throw new CalloutException('Non-success: ' + sc + ' ' + res.getStatus() + ' —body- ' + res);
        }
        return res.getBody();
    }

    public static String buildBody(Map<String,String> data) {
        List<String> parts = new List<String>();
        for (String key : data.keySet()) {
            parts.add(
                EncodingUtil.urlEncode(key, 'UTF-8') + '=' +
                EncodingUtil.urlEncode(data.get(key) == null ? '' : data.get(key), 'UTF-8')
            );
        }
        return String.join(parts, '&');
    }

    public static String truncate(String s, Integer n) {
        if (s == null) return null;
        return s.length() > n ? s.substring(0, n) + '…' : s;
    }
    
    
    public static NGMCP_Mulesoft_Access_Code__c getMAC() {
        //String orgId = UserInfo.getOrganizationId();
        List<NGMCP_Mulesoft_Access_Code__c> rows = [
            SELECT Id, NGMCP_Expires_At__c, NGMCP_Access_Code__c, NGMCP_Callout_Response__c,NGMCP_Token_Type__c
            FROM NGMCP_Mulesoft_Access_Code__c 
            with user_mode
            Order by createddate desc
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    public static void upsertMAC(String token, String type, DateTime expiresAt, String raw) {
        //String orgId = UserInfo.getOrganizationId();
        NGMCP_Mulesoft_Access_Code__c row = getMAC();
        if (row == null) {
            row = new NGMCP_Mulesoft_Access_Code__c();
        }
        if(Schema.sObjectType.NGMCP_Mulesoft_Access_Code__c.fields.NGMCP_Access_Code__c.isCreateable()){
        	row.NGMCP_Access_Code__c = token;
        }
        if(Schema.sObjectType.NGMCP_Mulesoft_Access_Code__c.fields.NGMCP_Expires_At__c.isCreateable()){
        	row.NGMCP_Expires_At__c = expiresAt;
        }
        if(Schema.sObjectType.NGMCP_Mulesoft_Access_Code__c.fields.NGMCP_Token_Type__c.isCreateable()){
        	row.NGMCP_Token_Type__c = type;
        }
        if(Schema.sObjectType.NGMCP_Mulesoft_Access_Code__c.fields.NGMCP_Callout_Response__c.isCreateable()){
        	row.NGMCP_Callout_Response__c = raw;
        }
        
        if(Schema.sObjectType.NGMCP_Mulesoft_Access_Code__c.isCreateable() || Schema.sObjectType.NGMCP_Mulesoft_Access_Code__c.isUpdateable()){
        	upsert row;
        }
    }
/*
    private static String truncate(String s, Integer n) {
        if (s == null) return null;
        return s.length() > n ? s.substring(0, n) + '…' : s;
    }

*/
}