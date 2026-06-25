@isTest
public class NGMCP_RequestSearchControllerTest {
    
    @isTest
    static void testGetParentAccountFilesWithValidWorkOrderId() {
        // Create a test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Type = 'Customer'
        );
        insert testAccount;
        
        // Create a service provider account (child of testAccount)
        Account serviceProvider = new Account(
            Name = 'Service Provider',
            ParentId = testAccount.Id,
            Type = 'Service Provider'
        );
        insert serviceProvider;
        
        // Create a work order (do not assign non-writable fields)
        WorkOrder testWorkOrder = new WorkOrder(
            Service_Provider__c = serviceProvider.Id
        );
        insert testWorkOrder;

        // Create a ContentVersion first (this will create ContentDocument automatically)
        ContentVersion testVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'Test Document.pdf',
            VersionData = Blob.valueOf('Test data')
        );
        insert testVersion;

        // Query the created ContentDocumentId via ContentVersion
        testVersion = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :testVersion.Id
            LIMIT 1
        ];

        // Link the generated ContentDocument to the parent Account
        ContentDocumentLink testLink = new ContentDocumentLink(
            ContentDocumentId = testVersion.ContentDocumentId,
            LinkedEntityId = testAccount.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert testLink;
        
        // Test the method
        List<ContentVersion> result = NGMCP_RequestSearchController.getParentAccountFiles(testWorkOrder.Id);
        
        // Verify the result
        System.assertNotEquals(null, result);
        System.assert(result.size() > 0, 'Should return at least one ContentVersion');
    }
    
    @isTest
    static void testGetParentAccountFilesWithNullWorkOrderId() {
        // Test with null work order ID
        List<ContentVersion> result = NGMCP_RequestSearchController.getParentAccountFiles(null);
        
        // Should return empty list
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size(), 'Should return empty list for null work order ID');
    }
    
    @isTest
    static void testGetParentAccountFilesWithNonExistentWorkOrderId() {
        // Test with non-existent work order ID
        Id fakeId = Id.valueOf('000000000000000AAA'); // Invalid ID format
        List<ContentVersion> result = NGMCP_RequestSearchController.getParentAccountFiles(fakeId);
        
        // Should return empty list
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size(), 'Should return empty list for non-existent work order ID');
    }
    
    @isTest
    static void testGetParentAccountFilesWithWorkOrderWithoutServiceProvider() {
        // Create a work order without service provider (do not assign non-writable fields)
        WorkOrder testWorkOrder = new WorkOrder();
        insert testWorkOrder;
        
        // Test the method
        List<ContentVersion> result = NGMCP_RequestSearchController.getParentAccountFiles(testWorkOrder.Id);
        
        // Should return empty list
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size(), 'Should return empty list for work order without service provider');
    }
    
    @isTest
    static void testGetParentAccountFilesWithWorkOrderWithoutParentAccount() {
        // Create a service provider account without parent
        Account serviceProvider = new Account(
            Name = 'Service Provider Without Parent',
            Type = 'Service Provider'
        );
        insert serviceProvider;
        
        // Create a work order (do not assign non-writable fields)
        WorkOrder testWorkOrder = new WorkOrder(
            Service_Provider__c = serviceProvider.Id
        );
        insert testWorkOrder;
        
        // Test the method
        List<ContentVersion> result = NGMCP_RequestSearchController.getParentAccountFiles(testWorkOrder.Id);
        
        // Should return empty list
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size(), 'Should return empty list for work order with service provider without parent account');
    }

    @isTest
    static void testGetParentAccountFilesWithInternalUsersAccountLink() {
        Account testAccount = new Account(
            Name = 'Test Account Internal',
            Type = 'Customer'
        );
        insert testAccount;

        Account serviceProvider = new Account(
            Name = 'Service Provider Internal',
            ParentId = testAccount.Id,
            Type = 'Service Provider'
        );
        insert serviceProvider;

        WorkOrder testWorkOrder = new WorkOrder(
            Service_Provider__c = serviceProvider.Id
        );
        insert testWorkOrder;

        ContentVersion testVersion = new ContentVersion(
            Title = 'RAMS Document',
            PathOnClient = 'RAMS Document.pdf',
            VersionData = Blob.valueOf('RAMS test data')
        );
        insert testVersion;

        testVersion = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :testVersion.Id
            LIMIT 1
        ];

        ContentDocumentLink accountLink = new ContentDocumentLink(
            ContentDocumentId = testVersion.ContentDocumentId,
            LinkedEntityId = testAccount.Id,
            ShareType = 'V',
            Visibility = 'InternalUsers'
        );
        insert accountLink;

        List<ContentVersion> result = NGMCP_RequestSearchController.getParentAccountFiles(testWorkOrder.Id);

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size(), 'Should return file even when account CDL is InternalUsers');
        System.assertEquals('RAMS Document', result[0].Title);

        List<ContentDocumentLink> woLinks = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :testWorkOrder.Id
              AND ContentDocumentId = :testVersion.ContentDocumentId
        ];
        System.assertEquals(1, woLinks.size(), 'Should create AllUsers CDL on Work Order for portal download');
    }
}