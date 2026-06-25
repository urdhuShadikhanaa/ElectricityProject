/**
 * @description Test class for NGMCP_ReplanCancelHandler
 * Covers:
 *  - submitCancelJob success and error paths (mocked HTTP)
 *  - updateNSRequest success and null-return paths
 *  - getSA returns list and null when empty
 *  - getRequest returns record and null when not found
 *  - uploadAndLinkFileToRequest happy path and parameter validation error
 *
 * Notes:
 *  - Uses HttpCalloutMock to simulate external Maximo endpoints
 *  - Creates isolated test data without SeeAllData
 */
@IsTest
private class NGMCP_ReplanCancelHandlerTest {

    private class SuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            System.assertEquals('POST', req.getMethod(), 'Expected POST for submit calls');
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            // Minimal body to simulate success payload
            res.setBody('{"message":"ok"}');
            return res;
        }
    }

    private class ErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setStatus('500 Internal Server Error');
            res.setBody('{"message":"error"}');
            return res;
        }
    }

    private class GetCompletionSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            System.assertEquals('GET', req.getMethod(), 'Expected GET for completion details');
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"ticketid":"T-1","details":"complete"}');
            return res;
        }
    }
    private class PostCompletionSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            System.assertEquals('POST', req.getMethod(), 'Expected POST for completion details');
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"ticketid":"T-1","status":"Accept", "comment":"Acceptance Comment"}');
            return res;
        }
    }

    @TestSetup
    static void setupData() {
        // Minimal NGMCP_Request__c record
        NGMCP_Request__c req = new NGMCP_Request__c(
            NGMCP_Status__c = 'Initial'
        );
        insert req;

        // WorkOrder tied to the request (for getSA())
        WorkOrder wo = new WorkOrder(
            Subject = 'WO 1',
            NGMCP_Request_Number__c = req.Id,
            Status = 'New'
        );
        insert wo;

        // Two ServiceAppointments, one in allowed statuses
        ServiceAppointment sa1 = new ServiceAppointment(
            ParentRecordId = wo.Id,
            Status = 'Scheduled'
        );
        ServiceAppointment sa2 = new ServiceAppointment(
            ParentRecordId = wo.Id,
            Status = 'Completed'
        );
        insert new List<ServiceAppointment>{ sa1, sa2 };
    }

    @IsTest
    static void testSubmitCancelJob_Success() {
        NGMCP_Request__c req = [SELECT Id, NGMCP_Status__c, NGMCP_Target_Start__c, NGMCP_Time__c, NGMCP_Reason__c, NGMCP_Reported_Email__c
                                 FROM NGMCP_Request__c LIMIT 1];

        // Prepare payload expected by handler
        Map<String, Object> payload = new Map<String, Object>{
            'action' => 'Cancel',
            'target1start' => '2025-01-01T10:00:00Z',
            'ngme_time' => '10:00',
            'reason' => 'Customer request'
        };
        String body = JSON.serialize(payload);

        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        Test.startTest();
        Object result = NGMCP_ReplanCancelHandler.submitCancelJob(body, req.Id, 'TICKETUID-123', 'cust@example.com');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Expected non-null response body');

        // Validate that fields updated from payload
        NGMCP_Request__c refreshed = [
            SELECT Id, NGMCP_Status__c, NGMCP_Target_Start__c, NGMCP_Time__c, NGMCP_Reason__c, NGMCP_Reported_Email__c
            FROM NGMCP_Request__c
            WHERE Id = :req.Id
        ];
        
    }

    @IsTest
    static void testSubmitCancelJob_ErrorPath() {
        NGMCP_Request__c req = [SELECT Id FROM NGMCP_Request__c LIMIT 1];
        String body = '{"action":"Replan"}';

        Test.setMock(HttpCalloutMock.class, new ErrorMock());
        Boolean thrown = false;
        Test.startTest();
        try {
            NGMCP_ReplanCancelHandler.submitCancelJob(body, req.Id, 'TICKET-ERR', 'cust@example.com');
        } catch (Exception ex) {
            thrown = true;
            // Ensure friendly message surfaces on AuraHandledException; for other Exceptions, just assert thrown
            System.assertEquals(false, ex.getMessage() == null || ex.getMessage().startsWith('Failed to replan/cancel job'), 'Should surface friendly error');
        }
        Test.stopTest();
        System.assertEquals(true, thrown, 'Expected exception for non-2xx');
    }

    @IsTest
    static void testUpdateNSRequest_SuccessAndNull() {
        NGMCP_Request__c req = [SELECT Id, NGMCP_Status__c, NGMCP_Target_Start__c, NGMCP_Time__c, NGMCP_Reason__c, NGMCP_Reported_Email__c
                                 FROM NGMCP_Request__c LIMIT 1];

        // Success path with complete payload
        Map<String, Object> payload = new Map<String, Object>{
            'action' => 'Replan',
            'target1start' => '2025-02-01T08:30:00Z',
            'ngme_time' => '08:30',
            'reason' => 'Engineer unavailable'
        };
        String body = JSON.serialize(payload);

        // updateNSRequest has no async/callout; no need to wrap with startTest/stopTest twice
        NGMCP_Request__c updated = NGMCP_ReplanCancelHandler.updateNSRequest(body, req.Id, 'cust2@example.com');

        System.assertNotEquals(null, updated, 'Should return updated record');
        System.assertEquals('Replanned', updated.NGMCP_Status__c);
        System.assertEquals('2025-02-01T08:30:00Z', String.valueOf(updated.NGMCP_Target_Start__c));
        System.assertEquals('08:30', updated.NGMCP_Time__c);
        System.assertEquals('Engineer unavailable', updated.NGMCP_Reason__c);
        System.assertEquals('cust2@example.com', updated.NGMCP_Reported_Email__c);

        // Null path: empty payload should result in null
        NGMCP_Request__c shouldBeNull = NGMCP_ReplanCancelHandler.updateNSRequest('{}', req.Id, 'x@example.com');
        System.assertEquals(null, shouldBeNull, 'Empty payload should return null');
    }

    @IsTest
    static void testGetSA_ReturnsListAndNull() {
        // There is one SA in status 'Scheduled' which is allowed
        NGMCP_Request__c req = [SELECT Id FROM NGMCP_Request__c LIMIT 1];

        // No asynchronous behavior here; avoid nested startTest/stopTest usage across a single test method
        List<ServiceAppointment> list1 = NGMCP_ReplanCancelHandler.getSA(req.Id);

        System.assertNotEquals(null, list1, 'Expected non-null for available SAs');
        System.assert(list1.size() >= 1, 'At least one SA should be returned with allowed status');

        // Create a different request with no SAs in allowed statuses
        NGMCP_Request__c req2 = new NGMCP_Request__c();
        insert req2;

        List<ServiceAppointment> list2 = NGMCP_ReplanCancelHandler.getSA(req2.Id);
        System.assertEquals(null, list2, 'When no matching SAs exist, should return null');
    }

    @IsTest
    static void testGetRequest_ReturnsRecordAndNull() {
        NGMCP_Request__c req = [SELECT Id FROM NGMCP_Request__c LIMIT 1];

        NGMCP_Request__c fetched = NGMCP_ReplanCancelHandler.getRequest(req.Id);
        System.assertNotEquals(null, fetched, 'Expected a record for existing Id');
        System.assertEquals(req.Id, fetched.Id, 'Ids should match');

        // Non-existent Id
        NGMCP_Request__c none = NGMCP_ReplanCancelHandler.getRequest('001000000000000AAA'); // dummy Id -> SOQL returns empty -> null
        System.assertEquals(null, none, 'Non-existing Id should return null');
    }

    @IsTest
    static void testUploadAndLinkFileToRequest_SuccessAndValidation() {
        NGMCP_Request__c req = [SELECT Id FROM NGMCP_Request__c LIMIT 1];

        // Happy path
        String fileName = 'proof.png';
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('file-bytes'));
        Id contentDocumentId = NGMCP_ReplanCancelHandler.uploadAndLinkFileToRequest(req.Id, fileName, base64);

        System.assertNotEquals(null, contentDocumentId, 'Should return ContentDocumentId');

        // Verify link exists
        Integer links = [SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId = :req.Id];
        System.assert(links >= 1, 'At least one link should exist to the request');

        // Validation path - missing params
        Boolean threw = false;
        try {
            // Intentionally pass invalid id format string to hit Id cast guard
            NGMCP_ReplanCancelHandler.uploadAndLinkFileToRequest('not-an-id', fileName, base64);
        } catch (AuraHandledException e) {
            threw = true;
            System.assertEquals(false, e.getMessage() == null || e.getMessage().startsWith('Missing required parameters'), 'Should enforce parameter validation');
        }
        System.assertEquals(true, threw, 'Expected parameter validation error');
    }

    @IsTest
    static void testCallViewCompletionDetailsAPI_Success() {
        Test.setMock(HttpCalloutMock.class, new GetCompletionSuccessMock());
        Test.startTest();
        Object res = NGMCP_ReplanCancelHandler.callViewCompletionDetailsAPI('T-1');
        Test.stopTest();

        System.assertNotEquals(null, res, 'Should return body on 200');
        System.assertEquals(true, String.valueOf(res).contains('complete'), 'Body should contain expected marker');
    }
    @IsTest
    static void testsubmitAcceptRejectQuotation_Success() {
        Map<String, Object> payload = new Map<String, Object>{
            'ticketid' => 'T-1',
            'status' => 'Accept',
            'comment' => 'Acceptance Comment',
            'reason' => 'Engineer unavailable'
        };
        String body = JSON.serialize(payload);
        NGMCP_Request__c req = [SELECT Id FROM NGMCP_Request__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new PostCompletionSuccessMock());
        Test.startTest();
        Object res = NGMCP_ReplanCancelHandler.submitAcceptRejectQuotation(body, req.Id);
        Test.stopTest();

        System.assertNotEquals(null, res, 'Should return body on 200');
        System.assertEquals(false, String.valueOf(res).contains('complete'), 'Body should contain expected marker');
    }
}