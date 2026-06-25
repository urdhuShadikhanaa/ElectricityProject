public with sharing class gdprMessage {
    @AuraEnabled(cacheable=true)
    public static String getConsentMessage() {
        NGMCP_GDPR_Message__mdt consent = [
            SELECT Consent_Message__c FROM NGMCP_GDPR_Message__mdt WHERE DeveloperName = 'Default_GDPR_Message' LIMIT 1
        ];
        return consent.Consent_Message__c;
    }
}