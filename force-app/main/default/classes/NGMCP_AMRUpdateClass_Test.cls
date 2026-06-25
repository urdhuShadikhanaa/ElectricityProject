@IsTest
private class NGMCP_AMRUpdateClass_Test {

    @testSetup
    static void setup() {
        // Insert a minimal MAC record so header formation does not NPE.
        // Do NOT set Name (likely Auto Number).
        NGMCP_Mulesoft_Access_Code__c mac = new NGMCP_Mulesoft_Access_Code__c(
            NGMCP_Token_Type__c = 'Bearer',
            NGMCP_Access_Code__c = 'test_access_token'
        );
        insert mac;
    }

    // ==== Callout Mocks ====

    // Non-200 response: exercise path that skips parsing and returns empty list.
    private class MockNon200 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error":"Upstream failure"}');
            return res;
        }
    }

    // 200 OK with empty objList: exercises the status==200 branch safely.
    private class Mock200_EmptyList implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            // Your code reads NGMCP_AMRClass.parse(...).objList; provide that property.
            res.setBody('{"objList":[]}');
            return res;
        }
    }

    // 200 OK with one minimal item: covers "!req.objList.isEmpty()" => true branch.
    private class Mock200_WithItem implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            // Minimal item is fine; fields default to null in deserialization.
            res.setBody('{"objList":[{}]}');
            return res;
        }
    }

    // 200 OK but malformed JSON: forces parse exception => caught and rethrown as CalloutException.
    private class Mock200_ParseError implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{'); // malformed JSON to trigger parse failure
            return res;
        }
    }

    // ==== Tests ====

    @IsTest
    static void test_Non200_ReturnsEmptyList() {
        Test.setMock(HttpCalloutMock.class, new MockNon200());

        Test.startTest();
        List<NGMCP_AMRClass.ObjListClass> out = NGMCP_AMRUpdateClass.fetchAMRRecords();
        Test.stopTest();

        System.assertNotEquals(null, out, 'Method must not return null.');
        System.assertEquals(0, out.size(), 'Non-200 responses should yield an empty list.');
    }

    @IsTest
    static void test_200_EmptyList_ParsesAndReturnsEmpty() {
        Test.setMock(HttpCalloutMock.class, new Mock200_EmptyList());

        Test.startTest();
        List<NGMCP_AMRClass.ObjListClass> out = NGMCP_AMRUpdateClass.fetchAMRRecords();
        Test.stopTest();

        System.assertNotEquals(null, out, 'Method must not return null.');
        System.assertEquals(0, out.size(), 'Empty objList should result in empty return.');
    }

    @IsTest
    static void test_200_WithItem_ParsesAndReturnsItem() {
        Test.setMock(HttpCalloutMock.class, new Mock200_WithItem());

        Test.startTest();
        List<NGMCP_AMRClass.ObjListClass> out = NGMCP_AMRUpdateClass.fetchAMRRecords();
        List<NGMCP_AMRClass.ObjListClass> out2 = NGMCP_AMRUpdateClass.fetchAMRScheduler();
        Test.stopTest();

        System.assertNotEquals(null, out, 'Method must not return null.');
        System.assertEquals(1, out.size(), 'With one item in objList, one record must be returned.');
    }

    @IsTest
    static void test_200_ParseError_ThrowsCustomException() {
        Test.setMock(HttpCalloutMock.class, new Mock200_ParseError());

        try {
            Test.startTest();
            // Do NOT use (void) cast in Apex; just call it and expect exception.
            NGMCP_AMRUpdateClass.fetchAMRRecords();
            Test.stopTest();
            System.assert(false, 'Expected NGMCP_AMRUpdateClass.CalloutException to be thrown.');
        } catch (NGMCP_AMRUpdateClass.CalloutException ex) {
            System.assert(ex.getMessage().contains('Get request callout failed'),
                          'Should rethrow custom CalloutException on parse failure.');
        }
    }

    @IsTest
    static void test_toDdMmYyyy_AllBranches() {
        // Valid input (yyyy-MM-dd)
        System.assertEquals('18/01/2024', NGMCP_AMRUpdateClass.toDdMmYyyy('2024-01-18'));

        // Blank -> null
        System.assertEquals(null, NGMCP_AMRUpdateClass.toDdMmYyyy(''));

        // Invalid -> caught and returns null
        System.assertEquals(null, NGMCP_AMRUpdateClass.toDdMmYyyy('not-a-date'));
    }
}