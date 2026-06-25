@isTest
private class NGMCP_DocLinksControllerTest {
    
    /* =====================================================
       TESTS FOR getRows METHOD
       ===================================================== */
    
    @isTest
    static void testGetRowsWithNullParentId() {
        // Test that getRows returns empty list when parentId is null
        List<NGMCP_DocLinksController.DocRow> result = NGMCP_DocLinksController.getRows(null);
        
        System.assertEquals(0, result.size(), 'Should return empty list when parentId is null');
    }
    
    @isTest
    static void testGetRowsWithNoContentDocumentLinks() {
        // Test that getRows returns empty list when no ContentDocumentLinks exist for the parent
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
		Blob fileBody = Blob.valueOf('Sample PDF content for testing');
        ContentVersion cv = new ContentVersion(
            Title         = 'Test File',
            PathOnClient  = 'test.pdf',
            VersionData   = fileBody,
            IsMajorVersion = true
        );
        insert cv;
		
		cv = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
            LIMIT 1
        ];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = testAccount.Id;
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        List<NGMCP_DocLinksController.DocRow> result = NGMCP_DocLinksController.getRows(testAccount.Id);
        
        System.assertEquals(1, result.size(), 'Should return empty list when no ContentDocumentLinks exist');
    }
    
    /* =====================================================
       EDGE CASE TESTS
       ===================================================== */
    
    @isTest
    static void testGetRowsWithInvalidParentId() {
        // Test with a non-existent parent ID
        List<NGMCP_DocLinksController.DocRow> result = NGMCP_DocLinksController.getRows('000000000000000AAA');
        String label = NGMCP_DocLinksController.inferLabel('');
        String label2 = NGMCP_DocLinksController.inferLabel('Test Document QRF');
        String label3 = NGMCP_DocLinksController.inferLabel('Test Document ARF');
        String code = NGMCP_DocLinksController.inferCode('');
        String code2 = NGMCP_DocLinksController.inferCode('Test Document QRF');
        String code3 = NGMCP_DocLinksController.inferCode('Test Document ARF');
        Boolean fileType = NGMCP_DocLinksController.isImageType(null);
        Boolean fileType2 = NGMCP_DocLinksController.isImageType('test.png');
        NGMCP_DocLinksController.DocRow row1 = new NGMCP_DocLinksController.DocRow();
        row1.code = 'QRF';
        row1.label = 'Test Document QRF';
        row1.fileName = 'test.png';
        NGMCP_DocLinksController.DocRow row2 = new NGMCP_DocLinksController.DocRow();
        row1.code = 'ARF';
        row1.label = 'Test Document ARF';
        row1.fileName = 'test.png';
		NGMCP_DocLinksController.DocRowComparator drc = new NGMCP_DocLinksController.DocRowComparator();
        drc.compare(row1,row2);
        
		NGMCP_DocLinksController.DocRow row3 = new NGMCP_DocLinksController.DocRow();
        row1.code = 'QRF';
        row1.label = null;
        row1.fileName = null;
        NGMCP_DocLinksController.DocRow row4 = new NGMCP_DocLinksController.DocRow();
        row1.code = 'ARF';
        row1.label = null;
        row1.fileName = null; 
        drc.compare(row3,row4);
        System.assertEquals(0, result.size(), 'Should return empty list for invalid parent ID');
    }
}