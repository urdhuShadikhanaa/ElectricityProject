public with sharing class NGMCP_gdprMessage {
    @AuraEnabled(cacheable=true)
    public static String getConsentMessage() {
        NGMCP_GDPR_Message__mdt consent = [
            SELECT Consent_Message__c FROM NGMCP_GDPR_Message__mdt WHERE DeveloperName = 'Default_GDPR_Message' WITH USER_MODE LIMIT 1
        ];
        return consent.Consent_Message__c;
    }
}