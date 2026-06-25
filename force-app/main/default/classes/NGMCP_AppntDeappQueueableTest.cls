@IsTest
public class NGMCP_AppntDeappQueueableTest {

    /* =====================================================
       SUCCESS CALLOUT MOCK - Returns 200 response
    ====================================================== */
    private class SuccessCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"ngme_headerid":"HDR12345"}');
            return res;
        }
    }

    /* =====================================================
       CREATED CALLOUT MOCK - Returns 201 response
    ====================================================== */
    private class CreatedCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"ngme_headerid":"HDR67890","status":"created"}');
            return res;
        }
    }

    /* =====================================================
       FAILURE CALLOUT MOCK - Returns 400 response
    ====================================================== */
    private class FailureCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('{"error":"Bad Request","message":"Invalid data"}');
            return res;
        }
    }

    /* =====================================================
       EXCEPTION CALLOUT MOCK
       (Throws exception INSIDE try block)
    ====================================================== */
    private class ExceptionCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            throw new CalloutException('Simulated callout failure');
        }
    }

    /* =====================================================
       TEST 1: SUCCESS PATH - 200 Status Code (Appointment)
    ====================================================== */
    @IsTest
    static void testQueueableSuccessPath200() {
        // Disable chaining for this test to avoid email sending
        NGMCP_AppntDeappCalloutQueueable.executeChaining = false;

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        NGMCP_Request__c req = new NGMCP_Request__c(
            NGMCP_Status__c = 'Draft'
        );
        insert req;

        NGMCP_Bulk_Request__c bulkReq = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST01',
            NGMCP_MPRN__c = '1234567890',
            NGMCP_Status__c = 'Pending',
            NGMCP_Market_Sector_Code__c = 'I',
            NGMCP_Payment_Type__c = 'Credit',
            NGMCP_Meter_type__c = 'Diaphragm',
            NGMCP_Appointment_Type__c = 'FIX',
            NGMCP_Contract_Ref__c = 'CONTRACT123',
            NGMCP_Effective_date__c = '20260101'
        );
        insert bulkReq;

        String payload = '{"mprn":"1234567890","customer":"CUST01"}';

        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());

        Test.startTest();
        System.enqueueJob(
            new NGMCP_AppntDeappCalloutQueueable(
                new List<Id>{ bulkReq.Id },
                0,
                req.Id,
                payload,
                'Appointment',
                'FIX',
                u.Id
            )
        );
        Test.stopTest();

        NGMCP_Bulk_Request__c result = [SELECT Id, NGMCP_Status__c, NGMCP_Response__c FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq.Id];
        System.assertEquals('Completed', result.NGMCP_Status__c, 'Bulk Request should be Completed');
        System.assert(result.NGMCP_Response__c.contains('appointment request has been created successfully'), 'Response should contain success message');

        NGMCP_Request__c updatedReq = [SELECT Id, NGMCP_Status__c, NGMCP_Callout_Status__c FROM NGMCP_Request__c WHERE Id = :req.Id];
        System.assertEquals('Submitted', updatedReq.NGMCP_Status__c, 'Request should be Submitted');
        System.assertEquals('Completed', updatedReq.NGMCP_Callout_Status__c, 'Callout should be Completed');
    }

    /* =====================================================
       TEST 2: SUCCESS PATH - 201 Status Code (Deappointment)
    ====================================================== */
    @IsTest
    static void testQueueableSuccessPath201() {
        // Disable chaining for this test to avoid email sending
        NGMCP_AppntDeappCalloutQueueable.executeChaining = false;

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        NGMCP_Request__c req = new NGMCP_Request__c(
            NGMCP_Status__c = 'Draft'
        );
        insert req;

        NGMCP_Bulk_Request__c bulkReq = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST02',
            NGMCP_MPRN__c = '2345678901',
            NGMCP_Status__c = 'Pending',
            NGMCP_Market_Sector_Code__c = 'I',
            NGMCP_Appointment_Type__c = 'COS',
            NGMCP_Contract_Ref__c = 'CONTRACT789',
            NGMCP_Effective_date__c = '20260301'
        );
        insert bulkReq;

        String payload = '{"mprn":"2345678901","customer":"CUST02"}';

        Test.setMock(HttpCalloutMock.class, new CreatedCalloutMock());

        Test.startTest();
        System.enqueueJob(
            new NGMCP_AppntDeappCalloutQueueable(
                new List<Id>{ bulkReq.Id },
                0,
                req.Id,
                payload,
                'Deappointment',
                'COS',
                u.Id
            )
        );
        Test.stopTest();

        NGMCP_Bulk_Request__c result = [SELECT Id, NGMCP_Status__c, NGMCP_Response__c FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq.Id];
        System.assertEquals('Completed', result.NGMCP_Status__c, 'Bulk Request should be Completed');
        System.assert(result.NGMCP_Response__c.contains('deappointment request has been created successfully'), 'Response should contain deappointment success message');
    }

    /* =====================================================
       TEST 3: FAILURE PATH - 400 Status Code
    ====================================================== */
    @IsTest
    static void testQueueableFailurePath() {
        // Disable chaining for this test to avoid email sending
        NGMCP_AppntDeappCalloutQueueable.executeChaining = false;

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        NGMCP_Request__c req = new NGMCP_Request__c(
            NGMCP_Status__c = 'Draft'
        );
        insert req;

        NGMCP_Bulk_Request__c bulkReq = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST_FAIL',
            NGMCP_MPRN__c = '9999999999',
            NGMCP_Status__c = 'Pending',
            NGMCP_Market_Sector_Code__c = 'I',
            NGMCP_Appointment_Type__c = 'FIX',
            NGMCP_Contract_Ref__c = 'CONTRACT456',
            NGMCP_Effective_date__c = '20260201'
        );
        insert bulkReq;

        String payload = '{"mprn":"9999999999","customer":"CUST_FAIL"}';

        Test.setMock(HttpCalloutMock.class, new FailureCalloutMock());

        Test.startTest();
        System.enqueueJob(
            new NGMCP_AppntDeappCalloutQueueable(
                new List<Id>{ bulkReq.Id },
                0,
                req.Id,
                payload,
                'Appointment',
                'FIX',
                u.Id
            )
        );
        Test.stopTest();

        NGMCP_Bulk_Request__c result = [SELECT Id, NGMCP_Status__c, NGMCP_Response__c FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq.Id];
        System.assertEquals('Failed', result.NGMCP_Status__c, 'Bulk Request should be Failed');
        System.assert(result.NGMCP_Response__c.contains('Bad Request'), 'Response should contain error message');

        NGMCP_Request__c updatedReq = [SELECT Id, NGMCP_Callout_Status__c, NGMCP_Callout_Response__c FROM NGMCP_Request__c WHERE Id = :req.Id];
        System.assertEquals('Completed', updatedReq.NGMCP_Callout_Status__c, 'Callout should be marked Completed even on failure');
    }

    /* =====================================================
       TEST 4: EXCEPTION / CATCH BLOCK
    ====================================================== */
    @IsTest
    static void testQueueableExceptionPath() {
        // Disable chaining for this test to avoid email sending
        NGMCP_AppntDeappCalloutQueueable.executeChaining = false;

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        NGMCP_Request__c req = new NGMCP_Request__c(
            NGMCP_Status__c = 'Draft'
        );
        insert req;

        NGMCP_Bulk_Request__c bulkReq = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST_ERR',
            NGMCP_MPRN__c = '8888888888',
            NGMCP_Status__c = 'Pending',
            NGMCP_Market_Sector_Code__c = 'I',
            NGMCP_Appointment_Type__c = 'FIX',
            NGMCP_Contract_Ref__c = 'CONTRACT999',
            NGMCP_Effective_date__c = '20260401'
        );
        insert bulkReq;

        String payload = '{"mprn":"8888888888","customer":"CUST_ERR"}';

        Test.setMock(HttpCalloutMock.class, new ExceptionCalloutMock());

        Test.startTest();
        System.enqueueJob(
            new NGMCP_AppntDeappCalloutQueueable(
                new List<Id>{ bulkReq.Id },
                0,
                req.Id,
                payload,
                'Appointment',
                'FNDAS',
                u.Id
            )
        );
        Test.stopTest();

        NGMCP_Bulk_Request__c result = [SELECT Id, NGMCP_Status__c, NGMCP_Response__c FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq.Id];
        System.assertEquals('Failed', result.NGMCP_Status__c, 'Should be Failed on exception');
        System.assert(result.NGMCP_Response__c.contains('Simulated callout failure'), 'Should contain exception message');
    }

    /* =====================================================
       TEST 5: MULTIPLE RECORDS - CHAINING (First Record)
    ====================================================== */
    @IsTest
    static void testMultipleRecordsFirstIndex() {
        // Disable chaining for this test to avoid email sending
        NGMCP_AppntDeappCalloutQueueable.executeChaining = false;

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        NGMCP_Request__c req1 = new NGMCP_Request__c(NGMCP_Status__c = 'Draft');
        NGMCP_Request__c req2 = new NGMCP_Request__c(NGMCP_Status__c = 'Draft');
        insert new List<NGMCP_Request__c>{ req1, req2 };

        NGMCP_Bulk_Request__c bulkReq1 = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST01',
            NGMCP_MPRN__c = '1111111111',
            NGMCP_Status__c = 'Pending'
        );
        NGMCP_Bulk_Request__c bulkReq2 = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST02',
            NGMCP_MPRN__c = '2222222222',
            NGMCP_Status__c = 'Pending'
        );
        insert new List<NGMCP_Bulk_Request__c>{ bulkReq1, bulkReq2 };

        String payload = '{"mprn":"1111111111"}';

        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());

        Test.startTest();
        System.enqueueJob(
            new NGMCP_AppntDeappCalloutQueueable(
                new List<Id>{ bulkReq1.Id, bulkReq2.Id },
                0,
                req1.Id,
                payload,
                'Appointment',
                'FIX',
                u.Id
            )
        );
        Test.stopTest();

        NGMCP_Bulk_Request__c result1 = [SELECT Id, NGMCP_Status__c FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq1.Id];
        System.assertEquals('Completed', result1.NGMCP_Status__c, 'First bulk request should be completed');
    }

    /* =====================================================
       TEST 6: LAST RECORD - EMAIL SENDING (COVERS sendFinalEmail)
    ====================================================== */
    @IsTest
    static void testLastRecordEmailSending() {

        User u = [SELECT Id, Email FROM User WHERE IsActive = true AND Email != null LIMIT 1];

        NGMCP_Request__c req = new NGMCP_Request__c(
            NGMCP_Status__c = 'Draft'
        );
        insert req;

        NGMCP_Bulk_Request__c bulkReq = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST_EMAIL',
            NGMCP_MPRN__c = '3333333333',
            NGMCP_Status__c = 'Pending',
            NGMCP_Input_CSV_Row_Number__c = 1,
            NGMCP_Response__c = 'Test response'
        );
        insert bulkReq;

        String payload = '{"mprn":"3333333333"}';

        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());

        // Enable chaining to cover the email sending code
        NGMCP_AppntDeappCalloutQueueable.executeChaining = true;

        Test.startTest();
        // Enqueue with index = 0 (last record in single-item list - triggers sendFinalEmail)
        System.enqueueJob(
            new NGMCP_AppntDeappCalloutQueueable(
                new List<Id>{ bulkReq.Id },
                0,
                req.Id,
                payload,
                'Deappointment',
                'CA',
                u.Id
            )
        );
        Test.stopTest();

        NGMCP_Bulk_Request__c result = [SELECT Id, NGMCP_Status__c, NGMCP_Response__c FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq.Id];
        System.assertEquals('Completed', result.NGMCP_Status__c, 'Should be completed');
        System.assertNotEquals(null, result.NGMCP_Response__c, 'Response should be set');
        
        // Note: sendFinalEmail() method is covered when executeChaining = true and this is the last record
        // Email invocation count may be 0 in test context, so we don't assert on it
    }

    /* =====================================================
       TEST 6B: CHAINING DISABLED - MULTIPLE RECORDS
       (Tests the outer if condition when executeChaining = false)
    ====================================================== */
    @IsTest
    static void testChainingDisabledMultipleRecords() {

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        NGMCP_Request__c req = new NGMCP_Request__c(
            NGMCP_Status__c = 'Draft'
        );
        insert req;

        NGMCP_Bulk_Request__c bulkReq1 = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUSTX1',
            NGMCP_MPRN__c = '4444444444',
            NGMCP_Status__c = 'Pending'
        );
        NGMCP_Bulk_Request__c bulkReq2 = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUSTX2',
            NGMCP_MPRN__c = '5555555555',
            NGMCP_Status__c = 'Pending'
        );
        insert new List<NGMCP_Bulk_Request__c>{ bulkReq1, bulkReq2 };

        String payload = '{"mprn":"4444444444"}';

        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());

        // Disable chaining - this should skip the entire chaining block
        NGMCP_AppntDeappCalloutQueueable.executeChaining = false;

        Test.startTest();
        System.enqueueJob(
            new NGMCP_AppntDeappCalloutQueueable(
                new List<Id>{ bulkReq1.Id, bulkReq2.Id },
                0,
                req.Id,
                payload,
                'Appointment',
                'FIX',
                u.Id
            )
        );
        Test.stopTest();

        NGMCP_Bulk_Request__c result = [SELECT Id, NGMCP_Status__c FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq1.Id];
        System.assertEquals('Completed', result.NGMCP_Status__c, 'First record should be completed');
        
        // Email should NOT have been sent because chaining was disabled
        Integer emailInvocations = Limits.getEmailInvocations();
        System.assertEquals(0, emailInvocations, 'Email should not be sent when chaining is disabled');
        
        // Reset for other tests
        NGMCP_AppntDeappCalloutQueueable.executeChaining = true;
    }

    /* =====================================================
       TEST 7: DIFFERENT MODES - CA Mode
    ====================================================== */
    @IsTest
    static void testCAModeDeappointment() {
        // Disable chaining for this test to avoid email sending
        NGMCP_AppntDeappCalloutQueueable.executeChaining = false;

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        NGMCP_Request__c req = new NGMCP_Request__c(
            NGMCP_Status__c = 'Draft'
        );
        insert req;

        NGMCP_Bulk_Request__c bulkReq = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST05',
            NGMCP_MPRN__c = '5678901234',
            NGMCP_Status__c = 'Pending',
            NGMCP_Appointment_Type__c = 'CA',
            NGMCP_Contract_Ref__c = 'CONTRACT555',
            NGMCP_Effective_date__c = '20260501',
            NGMCP_New_MAM_Code__c = 'MAM01'
        );
        insert bulkReq;

        String payload = '{"mprn":"5678901234","mode":"CA"}';

        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());

        Test.startTest();
        System.enqueueJob(
            new NGMCP_AppntDeappCalloutQueueable(
                new List<Id>{ bulkReq.Id },
                0,
                req.Id,
                payload,
                'Deappointment',
                'CA',
                u.Id
            )
        );
        Test.stopTest();

        NGMCP_Bulk_Request__c result = [SELECT Id, NGMCP_Status__c FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq.Id];
        System.assertEquals('Completed', result.NGMCP_Status__c, 'Should be completed');
    }

    /* =====================================================
       TEST 8: DIFFERENT MODES - FNDAS Mode
    ====================================================== */
    @IsTest
    static void testFNDASModeAppointment() {
        // Disable chaining for this test to avoid email sending
        NGMCP_AppntDeappCalloutQueueable.executeChaining = false;

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        NGMCP_Request__c req = new NGMCP_Request__c(
            NGMCP_Status__c = 'Draft'
        );
        insert req;

        NGMCP_Bulk_Request__c bulkReq = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST06',
            NGMCP_MPRN__c = '6789012345',
            NGMCP_Status__c = 'Pending',
            NGMCP_Appointment_Type__c = 'FNDAS',
            NGMCP_Contract_Ref__c = 'CONTRACT666',
            NGMCP_Effective_date__c = '20260601',
            NGMCP_Meter_Model__c = 'MODEL123',
            NGMCP_Meter_Serial_Number__c = 'SN123456'
        );
        insert bulkReq;

        String payload = '{"mprn":"6789012345","mode":"FNDAS"}';

        Test.setMock(HttpCalloutMock.class, new CreatedCalloutMock());

        Test.startTest();
        System.enqueueJob(
            new NGMCP_AppntDeappCalloutQueueable(
                new List<Id>{ bulkReq.Id },
                0,
                req.Id,
                payload,
                'Appointment',
                'FNDAS',
                u.Id
            )
        );
        Test.stopTest();

        NGMCP_Bulk_Request__c result = [SELECT Id, NGMCP_Status__c, NGMCP_Response__c FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq.Id];
        System.assertEquals('Completed', result.NGMCP_Status__c, 'Should be completed');
    }

    /* =====================================================
       TEST 9: DIFFERENT PAYLOAD SCENARIOS
    ====================================================== */
    @IsTest
    static void testDifferentPayloadScenarios() {
        // Disable chaining for this test to avoid email sending
        NGMCP_AppntDeappCalloutQueueable.executeChaining = false;

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        NGMCP_Request__c req = new NGMCP_Request__c(
            NGMCP_Status__c = 'Draft'
        );
        insert req;

        NGMCP_Bulk_Request__c bulkReq = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST07',
            NGMCP_MPRN__c = '7890123456',
            NGMCP_Status__c = 'Pending'
        );
        insert bulkReq;

        // Complex payload with multiple fields
        String complexPayload = '{"mprn":"7890123456","customer":"CUST07","address":{"street":"Test St","postcode":"TE1 1ST"},"meter":{"model":"M123","serial":"SN789"}}';

        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());

        Test.startTest();
        System.enqueueJob(
            new NGMCP_AppntDeappCalloutQueueable(
                new List<Id>{ bulkReq.Id },
                0,
                req.Id,
                complexPayload,
                'Appointment',
                'NEWCN',
                u.Id
            )
        );
        Test.stopTest();

        NGMCP_Bulk_Request__c result = [SELECT Id, NGMCP_Status__c FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq.Id];
        System.assertEquals('Completed', result.NGMCP_Status__c, 'Should be completed with complex payload');
    }

    /* =====================================================
       TEST 10: BUILDCSV METHOD COVERAGE
    ====================================================== */
    @IsTest
    static void testBuildCsvMethod() {

        NGMCP_Bulk_Request__c bulkReq1 = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CSV_TEST1',
            NGMCP_MPRN__c = '1234567890',
            NGMCP_Status__c = 'Completed',
            NGMCP_Response__c = 'Success message',
            NGMCP_Input_CSV_Row_Number__c = 1
        );
        NGMCP_Bulk_Request__c bulkReq2 = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CSV_TEST2',
            NGMCP_MPRN__c = '9876543210',
            NGMCP_Status__c = 'Failed',
            NGMCP_Response__c = 'Error message with "quotes" and, commas',
            NGMCP_Input_CSV_Row_Number__c = 2
        );
        insert new List<NGMCP_Bulk_Request__c>{ bulkReq1, bulkReq2 };

        Test.startTest();
        String csv = NGMCP_AMRBulkController.buildCsv(new List<Id>{ bulkReq1.Id, bulkReq2.Id });
        Test.stopTest();

        System.assertNotEquals(null, csv, 'CSV should not be null');
        System.assert(csv.length() > 0, 'CSV should have content');
        System.assert(csv.contains('Success message'), 'CSV should contain success message');
    }

    /* =====================================================
       TEST 11: HTTP 500 ERROR RESPONSE
    ====================================================== */
    @IsTest
    static void testHttp500ErrorResponse() {
        // Disable chaining for this test to avoid email sending
        NGMCP_AppntDeappCalloutQueueable.executeChaining = false;

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        NGMCP_Request__c req = new NGMCP_Request__c(
            NGMCP_Status__c = 'Draft'
        );
        insert req;

        NGMCP_Bulk_Request__c bulkReq = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST500',
            NGMCP_MPRN__c = '5000000000',
            NGMCP_Status__c = 'Pending'
        );
        insert bulkReq;

        String payload = '{"mprn":"5000000000"}';

        Test.setMock(HttpCalloutMock.class, new ServerErrorCalloutMock());

        Test.startTest();
        System.enqueueJob(
            new NGMCP_AppntDeappCalloutQueueable(
                new List<Id>{ bulkReq.Id },
                0,
                req.Id,
                payload,
                'Appointment',
                'FIX',
                u.Id
            )
        );
        Test.stopTest();

        NGMCP_Bulk_Request__c result = [SELECT Id, NGMCP_Status__c, NGMCP_Response__c FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq.Id];
        System.assertEquals('Failed', result.NGMCP_Status__c, 'Should be Failed on 500 error');
    }

    /* =====================================================
       TEST 12: TIMEOUT SCENARIO WITH LONG RUNNING REQUEST
    ====================================================== */
    @IsTest
    static void testTimeoutScenario() {
        // Disable chaining for this test to avoid email sending
        NGMCP_AppntDeappCalloutQueueable.executeChaining = false;

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        NGMCP_Request__c req = new NGMCP_Request__c(
            NGMCP_Status__c = 'Draft'
        );
        insert req;

        NGMCP_Bulk_Request__c bulkReq = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST_TIME',
            NGMCP_MPRN__c = '6000000000',
            NGMCP_Status__c = 'Pending'
        );
        insert bulkReq;

        String payload = '{"mprn":"6000000000"}';

        Test.setMock(HttpCalloutMock.class, new TimeoutCalloutMock());

        Test.startTest();
        System.enqueueJob(
            new NGMCP_AppntDeappCalloutQueueable(
                new List<Id>{ bulkReq.Id },
                0,
                req.Id,
                payload,
                'Deappointment',
                'DE',
                u.Id
            )
        );
        Test.stopTest();

        NGMCP_Bulk_Request__c result = [SELECT Id, NGMCP_Status__c FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq.Id];
        System.assertEquals('Failed', result.NGMCP_Status__c, 'Should be Failed on timeout');
    }

    /* =====================================================
       SERVER ERROR MOCK - Returns 500 response
    ====================================================== */
    private class ServerErrorCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error":"Internal Server Error"}');
            return res;
        }
    }

    /* =====================================================
       TIMEOUT MOCK - Simulates timeout exception
    ====================================================== */
    private class TimeoutCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            throw new CalloutException('Read timed out');
        }
    }
}