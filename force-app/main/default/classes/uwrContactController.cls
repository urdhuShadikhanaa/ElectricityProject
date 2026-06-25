public with sharing class uwrContactController {
    @AuraEnabled(cacheable=true)
    public static ContactWrapper getContactDetails() {
        // Fetch from DB or API
        ContactWrapper contact = new ContactWrapper();
        contact.name = '';
        contact.contactNumber = '';
        contact.email = '';
        return contact;
    }

    @AuraEnabled
    public static void saveContactDetails(ContactWrapper contactData) {
        // Save logic here (DB or API call)
        System.debug('Saving contact: ' + contactData);
    }

    public class ContactWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String contactNumber;
        @AuraEnabled public String email;
    }
}