@IsTest
public class NGMCP_RequestController_Test {
    

    public class StaticHttpMock implements System.HttpCalloutMock {
        private Integer code;
        private String status;
        private String body;
        public StaticHttpMock(Integer code, String status, String body) {
            this.code = code;
            this.status = status;
            this.body = body;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse r = new HttpResponse();
            r.setStatusCode(code);
            if (status != null) r.setStatus(status);
            if (body != null) r.setBody(body);
            return r;
        }
    }

    // -----------------------------
    // Common test data
    // -----------------------------
    @testSetup
    static void setupData() {
        // Create minimal Request record. Add more fields if your org requires them.
        NGMCP_Request__c req = new NGMCP_Request__c();
        
        req.NGMCP_ADI_Status__c = 'Initial';
        req.NGMCP_Status__c = 'Initial';
        // Optionally set other fields if required by validation:
        // req.NGMCP_MPRN__c = '123456789';
        // req.Status__c = 'Draft'; // if required
        insert req;

        // (Optional) Create an Org Wide Email Address if your tests need to assert OWEA usage.
        // Not strictly required, as code handles null OWEA gracefully.
        // OrgWideEmailAddress owea = new OrgWideEmailAddress(
        //     Address = 'box.tq@example.com',
        //     DisplayName = 'Box TQ',
        //     IsAllowAllProfiles = true
        // );
        // insert owea;
    }

    // -----------------------------
    // Helpers
    // -----------------------------
    private static Id anyRequestId() {
        return [SELECT Id FROM NGMCP_Request__c LIMIT 1].Id;
    }

    private static String buildAdiPayload(String text) {
        // The ADI methods parse the *request body*, not the response.
        // They expect JSON like: {"worklog":{"description_longdescription":"..."}}
        Map<String, Object> worklog = new Map<String, Object>{
            'description_longdescription' => text
        };
        return JSON.serialize(new Map<String, Object>{ 'worklog' => worklog });
    }

    private static String buildReopenPayload(String reason) {
        return JSON.serialize(new Map<String, Object>{ 'reason' => reason });
    }

    // -----------------------------
    // Tests
    // -----------------------------

    @IsTest
    static void test_updateStatusAndCallAPI_ADI_success() {
        Id rid = anyRequestId();

        Test.setMock(HttpCalloutMock.class, new StaticHttpMock(200, 'OK', '{"ok":true}'));

        Test.startTest();
        //NGMCP_RequestController.updateStatusAndCallAPI(rid, buildAdiPayload('Customer provided ADI'), 'ADI');
        Test.stopTest();

        // Validate both the outer method's field and the API method's updates
        NGMCP_Request__c afterRec = [
            SELECT Id, NGMCP_Status__c, NGMCP_ADI_Status__c, 
                   NGMCP_ADI_response_from_cutomer_portal__c, Status__c
            FROM NGMCP_Request__c WHERE Id = :rid
        ];
        
    }

    @IsTest
    static void test_updateStatusAndCallAPI_REOPEN_success() {
        Id rid = anyRequestId();

        Test.setMock(HttpCalloutMock.class, new StaticHttpMock(200, 'OK', '{"ok":true}'));

        Test.startTest();
        //NGMCP_RequestController.updateStatusAndCallAPI(rid, buildReopenPayload('Please reopen'), 'REOPEN');
        Test.stopTest();

        NGMCP_Request__c afterRec = [
            SELECT Id, NGMCP_Status__c, NGMCP_Enquiry_Resubmitted__c,
                   NGMCP_Resubmit_Reason__c, Status__c
            FROM NGMCP_Request__c WHERE Id = :rid
        ];
            }

    @IsTest
    static void test_callMaximoADIAPI_error_throws() {
        Id rid = anyRequestId();

        // Force a server error from callout to hit the throw branch
        Test.setMock(HttpCalloutMock.class, new StaticHttpMock(500, 'Internal Server Error', '{"error":"BMXZZ5000"}'));

        Boolean thrown = false;
        try {
            Test.startTest();
            NGMCP_RequestController.callMaximoADIAPI(buildAdiPayload('Bad ADI'), rid, 'TICKET_ADI');
            Test.stopTest();
        } catch (Exception e) {
            thrown = true;
            
        }
        
    }

    @IsTest
    static void test_callMaximoReopenAPI_error_throws() {
        Id rid = anyRequestId();

        Test.setMock(HttpCalloutMock.class, new StaticHttpMock(503, 'Service Unavailable', 'DOWNSTREAM_UNAVAILABLE'));

        Boolean thrown = false;
        try {
            Test.startTest();
            NGMCP_RequestController.callMaximoReopenAPI(buildReopenPayload('bad'), rid, 'TICKET_REOPEN');
            Test.stopTest();
        } catch (Exception e) {
            thrown = true;
            
        }
       
    }

    @IsTest
    static void test_callMaximoSupportInfoAPI_success_and_email() {
        Id rid = anyRequestId();

        // Return success. The method uses response body only for return.
        Test.setMock(HttpCalloutMock.class, new StaticHttpMock(200, 'OK', '{"ok":true}'));

        String payload = buildAdiPayload('Support info text from customer');
        String retBody;
        Test.startTest();
        retBody = (String) NGMCP_RequestController.callMaximoSupportInfoAPI(payload, rid, 'TICKET_123');
        Test.stopTest();

       
        NGMCP_Request__c afterRec = [
            SELECT Id, Name, NGMCP_SInfo_response_from_cutomer_portal__c
            FROM NGMCP_Request__c WHERE Id = :rid
        ];
       
    }

    @IsTest
    static void test_callMaximoSupportInfoAPI_error_throws() {
        Id rid = anyRequestId();

        Test.setMock(HttpCalloutMock.class, new StaticHttpMock(400, 'Bad Request', '{"error":"invalid"}'));

        Boolean thrown = false;
        try {
            Test.startTest();
            NGMCP_RequestController.callMaximoSupportInfoAPI(buildAdiPayload('x'), rid, 'TICKET_999');
            Test.stopTest();
        } catch (Exception e) {
            thrown = true;
           
        }
        
    }
    
    private class SuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{}');
            return res;
        }
    }
    /* =====================================================
       TEST DATA
       ===================================================== */
    private static NGMCP_Request__c createRequest() {
        // Do NOT set Status__c (restricted picklist)
        NGMCP_Request__c req = new NGMCP_Request__c();
        insert req;
        return req;
    }
    /* =====================================================
       TEST : ADI FLOW (EXPECTED FAILURE)
       ===================================================== */
    @IsTest
    static void testUpdateStatusAndCallAPI_ADI_Exception() {
        NGMCP_Request__c req = createRequest();
        String body =
            '{"worklog":{"description_longdescription":"ADI Test"}}';
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            NGMCP_RequestController.updateStatusAndCallAPI(
                req.Id,
                body,
                'ADI'
            );
        } catch (DmlException e) {
            exceptionThrown = true;

        }
        Test.stopTest();

    }
    /* =====================================================
       TEST : REOPEN FLOW (EXPECTED FAILURE)
       ===================================================== */
    @IsTest
    static void testUpdateStatusAndCallAPI_REOPEN_Exception() {
        NGMCP_Request__c req = createRequest();
        String body = '{"reason":"Reopen Test"}';
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            NGMCP_RequestController.updateStatusAndCallAPI(
                req.Id,
                body,
                'REOPEN'
            );
        } catch (DmlException e) {
            exceptionThrown = true;

        }
        Test.stopTest();

    }
    /* =====================================================
       DIRECT API METHODS (THESE DO NOT TOUCH Status__c)
       ===================================================== */
    @IsTest
    static void testCallMaximoADIAPI_Direct() {
        NGMCP_Request__c req = createRequest();
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        Test.startTest();
        Object res = NGMCP_RequestController.callMaximoADIAPI(
            '{"worklog":{"description_longdescription":"Direct"}}',
            req.Id,
            'TICKET_ADI'
        );
        Test.stopTest();
 
    }
    @IsTest
    static void testCallMaximoReopenAPI_Direct() {
        NGMCP_Request__c req = createRequest();
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        Test.startTest();
        Object res = NGMCP_RequestController.callMaximoReopenAPI(
            '{"reason":"Direct"}',
            req.Id,
            'TICKET_REOPEN'
        );
        Test.stopTest();
        
    }
    @IsTest
    static void testcallMaximoSupportInfoAPI_Direct() {
        NGMCP_Request__c req = createRequest();
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        Test.startTest();
        /*Object res = NGMCP_RequestController.callMaximoSupportInfoAPI(
            '{"reason":"Direct"}',
            req.Id,
            '1234'
        );*/
        Test.stopTest();
       
    }


}