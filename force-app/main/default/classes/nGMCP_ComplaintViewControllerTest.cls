@IsTest
private class nGMCP_ComplaintViewControllerTest {

    // Utility to create a ContentDocument and link to a given record
    private static ContentDocumentLink createLinkedFile(Id linkedRecordId, String fileName) {
        // Insert a ContentVersion (auto-creates ContentDocument)
        ContentVersion cv = new ContentVersion(
            Title = fileName,
            PathOnClient = fileName + '.txt',
            VersionData = Blob.valueOf('Sample file content for testing'),
            IsMajorVersion = true
        );
        insert cv;

        // Retrieve ContentDocumentId from the inserted ContentVersion
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        // Link the document to the target record
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = linkedRecordId,
            ShareType = 'V',      // Viewer access
            Visibility = 'AllUsers'
        );
        insert cdl;

        return cdl;
    }

    @IsTest
    static void testGetFiles_withLinkedDocuments() {
        // Create a host record to link files to (using Account as a generic sObject)
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create and link a test file
        ContentDocumentLink createdLink = createLinkedFile(acc.Id, 'TestFile');

        Test.startTest();
        List<ContentDocumentLink> results = nGMCP_ComplaintViewController.getFiles(acc.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(0, results.size(), 'Expected at least one linked file.');
        System.assertEquals(1, results.size(), 'Expected exactly one linked file.');

        ContentDocumentLink first = results[0];

        // Basic field checks
        System.assertEquals(createdLink.ContentDocumentId, first.ContentDocumentId, 'ContentDocumentId should match.');
        System.assertNotEquals(null, first.ContentDocument, 'Related ContentDocument should be populated via relationship.');
        System.assertEquals('TestFile', first.ContentDocument.Title, 'Title should match the inserted version.');
        System.assertNotEquals(null, first.ContentDocument.FileExtension, 'FileExtension should be set.');
        System.assertNotEquals(null, first.ContentDocument.FileType, 'FileType should be set.');
        System.assertNotEquals(null, first.ContentDocument.LatestPublishedVersionId, 'LatestPublishedVersionId should be populated.');
    }

    @IsTest
    static void testGetFiles_noLinkedDocuments() {
        // Create a host record with no linked files
        Account acc = new Account(Name = 'Lonely Account');
        insert acc;

        Test.startTest();
        List<ContentDocumentLink> results = nGMCP_ComplaintViewController.getFiles(acc.Id);
        Test.stopTest();

        // Assertions
        System.assertEquals(0, results.size(), 'Expected no results when no documents are linked.');
    }
}