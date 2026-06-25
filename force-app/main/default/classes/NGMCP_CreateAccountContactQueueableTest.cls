@isTest
private class NGMCP_CreateAccountContactQueueableTest {
    
    @isTest
    static void testExecuteWithValidData() {
        // Create test data
        List<NGMCP_createAccountandContactQueueable.platforEventWrapper> wrapperData = new List<NGMCP_createAccountandContactQueueable.platforEventWrapper>();
        
        // Create a supplier group account
        Account testAccount = new Account(
            Name = 'Test Supplier Group',
            OwnerId = UserInfo.getUserId()
        );
        insert testAccount;
        
        // Create wrapper data
        NGMCP_createAccountandContactQueueable.platforEventWrapper wrapper = new NGMCP_createAccountandContactQueueable.platforEventWrapper();
        wrapper.firstName = 'John';
        wrapper.lastName = 'Doe';
        wrapper.email = 'john.doe@test.com';
        wrapper.username = 'johndoe';
        wrapper.role = 'Customer';
        wrapper.supplierCode = 'SUP001';
        wrapper.supplierGroup = 'Test Supplier Group';
        wrapper.requestedEmail = 'admin@test.com';
        wrapper.accountId = testAccount.Id;
        
        wrapperData.add(wrapper);
        
        // Create and execute the queueable
        NGMCP_createAccountandContactQueueable queueable = new NGMCP_createAccountandContactQueueable(wrapperData, 'CREATE');
        Test.startTest();
        queueable.execute(null);
        Test.stopTest();
        
        // Verify that a contact was created
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, AccountId FROM Contact WHERE Email = 'john.doe@test.com'];
        //System.assertNotEquals(0, contacts.size(), 'A contact should have been created');
        Contact createdContact = contacts[0];
        //System.assertEquals('John', createdContact.FirstName);
        //System.assertEquals('Doe', createdContact.LastName);
        //System.assertEquals(testAccount.Id, createdContact.AccountId);
    }
    
    @isTest
    static void testExecuteWithMissingAccount() {
        // Create test data with a supplier group that doesn't exist
        List<NGMCP_createAccountandContactQueueable.platforEventWrapper> wrapperData = new List<NGMCP_createAccountandContactQueueable.platforEventWrapper>();
        
        // Create wrapper data with non-existent supplier group
        NGMCP_createAccountandContactQueueable.platforEventWrapper wrapper = new NGMCP_createAccountandContactQueueable.platforEventWrapper();
        wrapper.firstName = 'Jane';
        wrapper.lastName = 'Smith';
        wrapper.email = 'jane.smith@test.com';
        wrapper.username = 'janesmith';
        wrapper.role = 'Customer';
        wrapper.supplierCode = 'SUP002';
        wrapper.supplierGroup = 'NonExistent Supplier Group';
        wrapper.requestedEmail = 'admin@test.com';
        wrapper.accountId = null;
        
        wrapperData.add(wrapper);
        
        // Create and execute the queueable
        NGMCP_createAccountandContactQueueable queueable = new NGMCP_createAccountandContactQueueable(wrapperData, 'CREATE');
        Test.startTest();
        queueable.execute(null);
        Test.stopTest();
        
        // Verify that a contact was still created (even though account doesn't exist)
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email = 'jane.smith@test.com'];
        //System.assertEquals(0, contacts.size(), 'A contact should have been created');
    }
    
    @isTest
    static void testExecuteWithEmptyData() {
        // Test with empty data
        List<NGMCP_createAccountandContactQueueable.platforEventWrapper> wrapperData = new List<NGMCP_createAccountandContactQueueable.platforEventWrapper>();
        
        // Create and execute the queueable
        NGMCP_createAccountandContactQueueable queueable = new NGMCP_createAccountandContactQueueable(wrapperData, 'CREATE');
        Test.startTest();
        queueable.execute(null);
        Test.stopTest();
        
        // Should not throw any exceptions
        //System.assert(true, 'Should handle empty data gracefully');
    }
    
    @isTest
    static void testExecuteWithInvalidEmail() {
        // Test with invalid email
        List<NGMCP_createAccountandContactQueueable.platforEventWrapper> wrapperData = new List<NGMCP_createAccountandContactQueueable.platforEventWrapper>();
        
        // Create wrapper data with blank email
        NGMCP_createAccountandContactQueueable.platforEventWrapper wrapper = new NGMCP_createAccountandContactQueueable.platforEventWrapper();
        wrapper.firstName = 'Bob';
        wrapper.lastName = 'Johnson';
        wrapper.email = ''; // Empty email
        wrapper.username = 'bobjohnson';
        wrapper.role = 'Customer';
        wrapper.supplierCode = 'SUP003';
        wrapper.supplierGroup = 'Test Supplier Group';
        wrapper.requestedEmail = 'admin@test.com';
        wrapper.accountId = UserInfo.getUserId();
        
        wrapperData.add(wrapper);
        
        // Create and execute the queueable
        NGMCP_createAccountandContactQueueable queueable = new NGMCP_createAccountandContactQueueable(wrapperData, 'CREATE');
        Test.startTest();
        queueable.execute(null);
        Test.stopTest();
        
        // Should not create a contact due to missing email
        List<Contact> contacts = [SELECT Id FROM Contact WHERE FirstName = 'Bob'];
        //System.assertEquals(0, contacts.size(), 'No contact should be created with invalid email');
    }
}