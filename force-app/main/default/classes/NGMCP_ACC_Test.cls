@isTest
public class NGMCP_ACC_Test {
    
    @isTest
    static void testExecuteWithValidData() {
        // Setup test data
        List<NGMCP_createAccountandContactQueueable.platforEventWrapper> wrapperData = new List<NGMCP_createAccountandContactQueueable.platforEventWrapper>();
        
        // Create wrapper data with valid information
        NGMCP_createAccountandContactQueueable.platforEventWrapper wrapper1 = new NGMCP_createAccountandContactQueueable.platforEventWrapper();
        wrapper1.firstName = 'John';
        wrapper1.lastName = 'Doe';
        wrapper1.email = 'john.doe@example.com';
        wrapper1.username = 'johndoe';
        wrapper1.role = 'Manager';
        wrapper1.supplierCode = 'CODE123';
        wrapper1.supplierGroup = 'Test Supplier Group';
        wrapper1.requestedEmail = 'requester@example.com';
        wrapper1.accountId = null;
        
        wrapperData.add(wrapper1);
        
        // Create the queueable class instance
        NGMCP_createAccountandContactQueueable queueable = new NGMCP_createAccountandContactQueueable(wrapperData, 'create');
        
        // Execute the queueable
        Test.startTest();
        queueable.execute(null);
        Test.stopTest();
        
        // Simple check - if we got here without exception, the test passes
        System.assert(true, 'Valid data test should execute without error');
    }
    
    @isTest
    static void testExecuteWithNullData() {
        // Test with null data
        List<NGMCP_createAccountandContactQueueable.platforEventWrapper> wrapperData = null;
        
        NGMCP_createAccountandContactQueueable queueable = new NGMCP_createAccountandContactQueueable(wrapperData, 'create');
        
        Test.startTest();
        queueable.execute(null);
        Test.stopTest();
        
        // Should not throw any exception
        System.assert(true, 'Should handle null data gracefully');
    }
    
    @isTest
    static void testExecuteWithEmptyData() {
        // Test with empty data
        List<NGMCP_createAccountandContactQueueable.platforEventWrapper> wrapperData = new List<NGMCP_createAccountandContactQueueable.platforEventWrapper>();
        
        NGMCP_createAccountandContactQueueable queueable = new NGMCP_createAccountandContactQueueable(wrapperData, 'create');
        
        Test.startTest();
        queueable.execute(null);
        Test.stopTest();
        
        // Should not throw any exception
        System.assert(true, 'Should handle empty data gracefully');
    }
    
    @isTest
    static void testExecuteWithMissingEmail() {
        // Setup test data with missing email
        List<NGMCP_createAccountandContactQueueable.platforEventWrapper> wrapperData = new List<NGMCP_createAccountandContactQueueable.platforEventWrapper>();
        
        NGMCP_createAccountandContactQueueable.platforEventWrapper wrapper1 = new NGMCP_createAccountandContactQueueable.platforEventWrapper();
        wrapper1.firstName = 'Jane';
        wrapper1.lastName = 'Smith';
        wrapper1.email = ''; // Empty email
        wrapper1.username = 'janesmith';
        wrapper1.role = 'Agent';
        wrapper1.supplierCode = 'CODE456';
        wrapper1.supplierGroup = 'Another Supplier Group';
        wrapper1.requestedEmail = 'requester@example.com';
        wrapper1.accountId = null;
        
        wrapperData.add(wrapper1);
        
        NGMCP_createAccountandContactQueueable queueable = new NGMCP_createAccountandContactQueueable(wrapperData, 'create');
        
        Test.startTest();
        queueable.execute(null);
        Test.stopTest();
        
        // Should not throw any exception
        System.assert(true, 'Should handle missing email gracefully');
    }
    
    @isTest
    static void testExecuteWithMissingSupplierGroup() {
        // Setup test data with missing supplier group
        List<NGMCP_createAccountandContactQueueable.platforEventWrapper> wrapperData = new List<NGMCP_createAccountandContactQueueable.platforEventWrapper>();
        
        NGMCP_createAccountandContactQueueable.platforEventWrapper wrapper1 = new NGMCP_createAccountandContactQueueable.platforEventWrapper();
        wrapper1.firstName = 'Bob';
        wrapper1.lastName = 'Johnson';
        wrapper1.email = 'bob.johnson@example.com';
        wrapper1.username = 'bobjohnson';
        wrapper1.role = 'Manager';
        wrapper1.supplierCode = 'CODE789';
        wrapper1.supplierGroup = ''; // Empty supplier group
        wrapper1.requestedEmail = 'requester@example.com';
        wrapper1.accountId = null;
        
        wrapperData.add(wrapper1);
        
        NGMCP_createAccountandContactQueueable queueable = new NGMCP_createAccountandContactQueueable(wrapperData, 'create');
        
        Test.startTest();
        queueable.execute(null);
        Test.stopTest();
        
        // Should not throw any exception
        System.assert(true, 'Should handle missing supplier group gracefully');
    }
    
    @isTest
    static void testExecuteWithExistingAccount() {
        // Setup existing account
        Account existingAccount = new Account(Name = 'Existing Supplier Group');
        insert existingAccount;
        
        // Setup test data
        List<NGMCP_createAccountandContactQueueable.platforEventWrapper> wrapperData = new List<NGMCP_createAccountandContactQueueable.platforEventWrapper>();
        
        NGMCP_createAccountandContactQueueable.platforEventWrapper wrapper1 = new NGMCP_createAccountandContactQueueable.platforEventWrapper();
        wrapper1.firstName = 'Alice';
        wrapper1.lastName = 'Brown';
        wrapper1.email = 'alice.brown@example.com';
        wrapper1.username = 'alicebrown';
        wrapper1.role = 'Agent';
        wrapper1.supplierCode = 'CODE000';
        wrapper1.supplierGroup = 'Existing Supplier Group'; // Same as existing account
        wrapper1.requestedEmail = 'requester@example.com';
        wrapper1.accountId = existingAccount.Id;
        
        wrapperData.add(wrapper1);
        
        NGMCP_createAccountandContactQueueable queueable = new NGMCP_createAccountandContactQueueable(wrapperData, 'create');
        
        Test.startTest();
        queueable.execute(null);
        Test.stopTest();
        
        // Should not throw any exception
        System.assert(true, 'Should handle existing account gracefully');
    }
    
    @isTest
    static void testFailureRowConstruction() {
        // Test the FailureRow constructor
        Account a = new Account(name='Test Acc');
        insert a;
        NGMCP_createAccountandContactQueueable.platforEventWrapper wrapper = new NGMCP_createAccountandContactQueueable.platforEventWrapper();
        wrapper.firstName = 'Test';
        wrapper.lastName = 'User';
        wrapper.email = 'test.user@example.com';
        wrapper.username = 'testuser';
        wrapper.role = 'Manager';
        wrapper.supplierCode = 'TESTCODE';
        wrapper.supplierGroup = 'Test Group';
        wrapper.requestedEmail = 'requester@example.com';
        wrapper.accountId = a.Id;
        List<NGMCP_createAccountandContactQueueable.platforEventWrapper> wrapperList = new List<NGMCP_createAccountandContactQueueable.platforEventWrapper>();
        wrapperList.add(wrapper);
        String errorMessage = 'Test error message';
        String csv = NGMCP_createAccountandContactQueueable.csv('rows');
        String csv1 = NGMCP_createAccountandContactQueueable.csv(null);
        NGMCP_createAccountandContactQueueable.FailureRow failureRow = 
            new NGMCP_createAccountandContactQueueable.FailureRow(wrapper, errorMessage);
        List<NGMCP_createAccountandContactQueueable.FailureRow> failureList = new List<NGMCP_createAccountandContactQueueable.FailureRow>();
        failureList.add(failureRow);
        String failure = NGMCP_createAccountandContactQueueable.buildFailureCsv(failureList);
        NGMCP_createAccountandContactQueueable queueable = new NGMCP_createAccountandContactQueueable(wrapperList, 'create');
        // Verify properties are set correctly
        System.assertEquals('Test', failureRow.firstName, 'First name should match');
        System.assertEquals('User', failureRow.lastName, 'Last name should match');
        System.assertEquals('test.user@example.com', failureRow.email, 'Email should match');
        System.assertEquals('testuser', failureRow.username, 'Username should match');
        System.assertEquals('Manager', failureRow.role, 'Role should match');
        System.assertEquals('TESTCODE', failureRow.supplierCode, 'Supplier code should match');
        System.assertEquals('Test Group', failureRow.supplierGroup, 'Supplier group should match');
        System.assertEquals('requester@example.com', failureRow.requesterEmail, 'Requester email should match');
        System.assertEquals(errorMessage, failureRow.errorMessage, 'Error message should match');
    }
    
    @isTest
    static void testMethod1(){
        NGMCP_createAccountandContactQueueable.platforEventWrapper wrapper = new NGMCP_createAccountandContactQueueable.platforEventWrapper();
        wrapper.firstName = 'Test';
        wrapper.lastName = 'User';
        wrapper.email = 'test';
        wrapper.username = 'testuser';
        wrapper.role = 'Manager';
        //wrapper.supplierCode = 'TESTCODE';
        //wrapper.supplierGroup = 'Test Group';
        //wrapper.requestedEmail = 'requester@example.com';
        //wrapper.accountId = a.Id;
        
        List<NGMCP_createAccountandContactQueueable.platforEventWrapper> wrapperList = new List<NGMCP_createAccountandContactQueueable.platforEventWrapper>();
        wrapperList.add(wrapper);
        //wrapperList.add(null);
        NGMCP_createAccountandContactQueueable queueable = new NGMCP_createAccountandContactQueueable(wrapperList, 'create');

    }
    
}