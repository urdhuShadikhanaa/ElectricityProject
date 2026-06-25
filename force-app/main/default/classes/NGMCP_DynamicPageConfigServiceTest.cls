@isTest
private class NGMCP_DynamicPageConfigServiceTest {

    @isTest
    static void testBuildSectionConfigJsonByRtName() {
        // Test that the method executes without throwing exception for valid input
        String result = NGMCP_DynamicPageConfigServiceController.buildSectionConfigJsonByRtName('Test Record Type');
        System.assert(result != null, 'Result should not be null for valid input');
    }
    
    @isTest
    static void testBuildSectionConfigJsonForRecordId() {
        // Test that the method executes without throwing exception for valid inputs
        String result = NGMCP_DynamicPageConfigServiceController.buildSectionConfigJsonForRecordId(null, 'Account');
        System.assert(result != null, 'Result should not be null for valid inputs');
    }
    
    @isTest
    static void testGetObjectApiName() {
        // Test with null input - this should not throw an exception
        String nullResult = NGMCP_DynamicPageConfigServiceController.getObjectApiName(null);
        System.assert(nullResult == null, 'Result should be null for null input');
    }

    @IsTest
    static void testGetNotesAndFiles() {
        NGMCP_Request__c acc = new NGMCP_Request__c(NGMCP_MPRN__c = '1027203901');
        insert acc;
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test file content')
        );
        insert cv;
        ContentVersion insertedCv = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ];
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = insertedCv.ContentDocumentId,
            LinkedEntityId = acc.Id,
            Visibility = 'AllUsers',
            ShareType = 'V'
        );
        insert cdl;
        Test.startTest();
        List<ContentDocumentLink> result =
            NGMCP_DynamicPageConfigServiceController.getNotesAndFiles(acc.Id);
        String objename = NGMCP_DynamicPageConfigServiceController.getObjectApiName(acc.Id);
        String jsonData = NGMCP_DynamicPageConfigServiceController.buildSectionConfigJsonForRecordId(acc.Id,objename);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'One file should be returned');
        System.assertEquals(
            'Test File',
            result[0].ContentDocument.Title,
            'File title should match'
        );
        System.assertNotEquals(
            null,
            result[0].ContentDocument.LatestPublishedVersionId,
            'Latest version should exist'
        );
    }

}