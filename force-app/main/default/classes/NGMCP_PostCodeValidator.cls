public with sharing class NGMCP_PostCodeValidator {
    @AuraEnabled(cacheable=true)
    public static Boolean validatePostCode(String postCode) {
        if (String.isBlank(postCode)) return false;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:RoyalMailAPI/deliveryoffice/v1/postcode/' + EncodingUtil.urlEncode(postCode, 'UTF-8'));
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setHeader('X-Api-Key', '4rgdrs1350p8b4i8po570ghogcd5ugqba34amf1q'); // Optional if not set in Named Credential

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return result.containsKey('deliveryOffice'); // Adjust based on actual response
        }
        return false;
    }
}