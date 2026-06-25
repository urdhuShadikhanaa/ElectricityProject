public with sharing class AddressDetailController {
    @AuraEnabled
    public static void createAddressDetail(Map<String, Object> addressFields) {
        NGMCP_REQUESTS__c address = new NGMCP_REQUESTS__c();

        address.Building_Name_Number__c = (String)addressFields.get('Building_Name_Number__c');
        address.Dependent_Locally__c = (String)addressFields.get('Dependent_Locally__c');
        address.Postal_Town__c = (String)addressFields.get('Postal_Town__c');
        address.Postal_code__c = (String)addressFields.get('Postal_code__c');
        address.Street__c = (String)addressFields.get('Street__c');

        insert address;
    }
}