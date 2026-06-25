@isTest
private class NGMCP_uwrContactControllerTest {
    
    @isTest
    static void testGetContactDetails() {
        Test.startTest();
        NGMCP_uwrContactController.ContactWrapper contact = NGMCP_uwrContactController.getContactDetails();
        Test.stopTest();

        System.assertNotEquals(null, contact, 'ContactWrapper should not be null');
        System.assertEquals('', contact.name, 'Name should be empty');
        System.assertEquals('', contact.contactNumber, 'Contact number should be empty');
        System.assertEquals('', contact.email, 'Email should be empty');
    }

    @isTest
    static void testSaveContactDetails() {
        NGMCP_uwrContactController.ContactWrapper contactData = new NGMCP_uwrContactController.ContactWrapper();
        contactData.name = 'John Doe';
        contactData.contactNumber = '1234567890';
        contactData.email = 'john.doe@example.com';

        Test.startTest();
        NGMCP_uwrContactController.saveContactDetails(contactData);
        Test.stopTest();

        // Since the method only logs the data, we can assert that no exception was thrown
        System.assert(true, 'saveContactDetails executed without error');
    }
}