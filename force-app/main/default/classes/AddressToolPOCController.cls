public with sharing class AddressToolPOCController {

    public class SaveResult {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String addressJson;
    }

    @AuraEnabled
    public static SaveResult saveVerifiedAddress(String addressJson) {
        if (String.isBlank(addressJson)) {
            throw new AuraHandledException('Address JSON is required.');
        }

        Map<String, Object> addressData =
            (Map<String, Object>) JSON.deserializeUntyped(addressJson);

        if (addressData == null || addressData.isEmpty()) {
            throw new AuraHandledException('Address data is required.');
        }

        String status = normalizeStatus(getString(addressData, 'status'));
        if (status != 'Verified') {
            throw new AuraHandledException('Only verified addresses can be saved.');
        }

        NGMCP_REQUESTS__c request = new NGMCP_REQUESTS__c();
        request.Street__c = getString(addressData, 'street');
        request.Postal_Town__c = getString(addressData, 'city');
        request.Postal_code__c = getString(addressData, 'postalcode');
        request.Dependent_Locally__c = getString(addressData, 'county');
        request.Status__c = status;

        insert request;

        SaveResult result = new SaveResult();
        result.recordId = request.Id;
        result.addressJson = addressJson;
        return result;
    }

    private static String getString(Map<String, Object> data, String key) {
        Object value = data.get(key);
        return value == null ? null : String.valueOf(value);
    }

    private static String normalizeStatus(String status) {
        return status == null ? '' : status.replace('\u200B', '').trim();
    }
}