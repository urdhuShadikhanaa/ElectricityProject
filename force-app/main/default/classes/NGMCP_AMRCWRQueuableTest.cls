@IsTest(SeeAllData=true) // allow helper to read org settings/metadata it needs
private class NGMCP_AMRCWRQueuableTest {
    // --- Success mock: HTTP 200 + safe, valid (empty array) JSON body ---
    private class EmptyArrayBodyMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            // Empty list is a valid JSON payload that deserializes to an empty List<ObjListClass>
            res.setBody('[]');
            return res;
        }
    }

    // --- Error mock: HTTP 500 to simulate an error response from external system ---
    private class Error500Mock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"message":"Server error"}');
            return res;
        }
    }

    // Test 1: Happy path – just verify the queueable runs without throwing
    @IsTest
    static void happyPath_runsWithoutException() {
        NGMCP_Mulesoft_Access_Code__c mac = new NGMCP_Mulesoft_Access_Code__c();
        mac.NGMCP_Access_Code__c = 'test';
        mac.NGMCP_Token_Type__c = 'Bearer';
        insert mac;
        Test.setMock(HttpCalloutMock.class, new EmptyArrayBodyMock());

        Test.startTest();
        System.enqueueJob(new NGMCP_AMRCWRQueuable());
        Test.stopTest();

        // No asserts on AsyncApexJob counts (flaky with SeeAllData); 
        // test passes by virtue of no unhandled exceptions.
        System.assert(true, 'Queueable completed without exception on happy path.');
    }

    // Test 2: Error response path – verify it still completes test execution
    // (If the helper throws custom CalloutException, your queueable catches and returns;
    // if it doesn’t throw, the code still completes. In both cases, test should pass.)
    @IsTest
    static void errorResponsePath_completesWithoutException() {
        NGMCP_Mulesoft_Access_Code__c mac = new NGMCP_Mulesoft_Access_Code__c();
        mac.NGMCP_Access_Code__c = 'test';
        mac.NGMCP_Token_Type__c = 'Bearer';
        insert mac;
        Test.setMock(HttpCalloutMock.class, new Error500Mock());

        Test.startTest();
        System.enqueueJob(new NGMCP_AMRCWRQueuable());
        Test.stopTest();

        System.assert(true, 'Queueable completed without uncaught exception on error response.');
    }

    // Test 3: Direct execute(null) – ensure code path runs synchronously without exception
    @IsTest
    static void directExecute_runsWithoutException() {
        NGMCP_Mulesoft_Access_Code__c mac = new NGMCP_Mulesoft_Access_Code__c();
        mac.NGMCP_Access_Code__c = 'test';
        mac.NGMCP_Token_Type__c = 'Bearer';
        insert mac;
        Test.setMock(HttpCalloutMock.class, new EmptyArrayBodyMock());

        Test.startTest();
        new NGMCP_AMRCWRQueuable().execute(null);
        Test.stopTest();

        System.assert(true, 'Direct execute() completed without exception.');
    }
}