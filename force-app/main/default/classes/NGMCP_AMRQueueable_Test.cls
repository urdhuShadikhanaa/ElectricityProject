@IsTest
public class NGMCP_AMRQueueable_Test {

     /* =====================================================
       SUCCESS CALLOUT MOCK
    ====================================================== */
    private class SuccessCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(
                '{"obj":{"p_WorkRequestID":"AMR12345"}}'
            );
            return res;
        }
    }

    /* =====================================================
       EXCEPTION CALLOUT MOCK
    ====================================================== */
    private class ExceptionCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            throw new CalloutException('Forced callout failure');
        }
    }

    /* =====================================================
       TEST 1: SUCCESS PATH (STRT + Pulsing YES)
    ====================================================== */
    @IsTest
    static void testAMRSuccessPath() {

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        NGMCP_Bulk_Request__c bulkReq = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST01',
            NGMCP_MPRN__c = '1234567890',
            NGMCP_Status__c = 'Pending'
        );
        insert bulkReq;

        NGMCP_Request__c req = new NGMCP_Request__c();
        insert req;

        String amrPayload =
            '{"p_ContractRef":"CR1","p_CustomerCode":"SUP1","p_TransactionRef":"TX1","p_MPRN":"123","p_ServiceLevel":"STD"}';

        NGMCP_AMRQueueable.JobItem ji =
            new NGMCP_AMRQueueable.JobItem(
                bulkReq,
                req.Id,
                amrPayload,
                u.Id,
                'YES',
                null
            );

        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());

        Test.startTest();
        System.enqueueJob(
            new NGMCP_AMRQueueable(
                new List<NGMCP_AMRQueueable.JobItem>{ ji },
                new List<Id>{ bulkReq.Id },
                'AMR',
                'STRT'
            )
        );
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq.Id]
        );
    }

    /* =====================================================
       TEST 2: EXCEPTION PATH (catch block)
    ====================================================== */
    @IsTest
    static void testAMRExceptionPath() {

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        NGMCP_Bulk_Request__c bulkReq = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST_ERR',
            NGMCP_MPRN__c = '9999999999',
            NGMCP_Status__c = 'Pending'
        );
        insert bulkReq;

        NGMCP_Request__c req = new NGMCP_Request__c();
        insert req;

        String amrPayload = '{"force":"exception"}';

        NGMCP_AMRQueueable.JobItem ji =
            new NGMCP_AMRQueueable.JobItem(
                bulkReq,
                req.Id,
                amrPayload,
                u.Id,
                'YES',
                null
            );

        Test.setMock(HttpCalloutMock.class, new ExceptionCalloutMock());

        Test.startTest();
        System.enqueueJob(
            new NGMCP_AMRQueueable(
                new List<NGMCP_AMRQueueable.JobItem>{ ji },
                new List<Id>{ bulkReq.Id },
                'AMR',
                'STRT'
            )
        );
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq.Id]
        );
    }
    
    @IsTest
    static void testAMRSuccessPath2() {

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        NGMCP_Bulk_Request__c bulkReq = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST01',
            NGMCP_MPRN__c = '1234567890',
            NGMCP_Status__c = 'Pending'
        );
        insert bulkReq;

        NGMCP_Request__c req = new NGMCP_Request__c();
        insert req;

        String amrPayload =
            '{"p_ContractRef":"CR1","p_CustomerCode":"SUP1","p_TransactionRef":"TX1","p_MPRN":"123","p_ServiceLevel":"STD","p_CorrectionFactor":1,"p_MeterDials":1,"p_MeterReadingFactor":1,"p_ConverterDials":1,"p_ConverterReadingFactor":1 }';

        NGMCP_AMRQueueable.JobItem ji =
            new NGMCP_AMRQueueable.JobItem(
                bulkReq,
                req.Id,
                amrPayload,
                u.Id,
                'YES',
                null
            );

        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());

        Test.startTest();
        System.enqueueJob(
            new NGMCP_AMRQueueable(
                new List<NGMCP_AMRQueueable.JobItem>{ ji },
                new List<Id>{ bulkReq.Id },
                'AMR',
                'RMVE'
            )
        );
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq.Id]
        );
    }
    
    @IsTest
    static void testAMRSuccessPath3() {

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        NGMCP_Bulk_Request__c bulkReq = new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c = 'CUST01',
            NGMCP_MPRN__c = '1234567890',
            NGMCP_Status__c = 'Pending'
        );
        insert bulkReq;

        NGMCP_Request__c req = new NGMCP_Request__c();
        insert req;

        String amrPayload =
            '{"p_ContractRef":"CR1","p_CustomerCode":"SUP1","p_TransactionRef":"TX1","p_MPRN":"123","p_ServiceLevel":"STD","p_CorrectionFactor":1,"p_MeterDials":1,"p_MeterReadingFactor":1,"p_ConverterDials":1,"p_ConverterReadingFactor":1 }';
        String tqPayload = '{"ngme_consname":"test","reason":"MUOP","loccode":"","bldgname":"test","sectorcode":"I","street":"street","supplier":"ABC","notif_type":"TQ","ngme_riskassess":"N","posttown":"test","ngme_constitle":"I","description_longdescription":"street","ngme_engvisit":"N","targetstart":"","postcode":"ABC","ngme_time":"","ngme_consphone":"12445","deplocal":"street","ngme_threshold":"N","location":"1234","ngme_consemail":"test@gmail.com","reportedemail":"test@gmail.com","category":"TQUERY","subcategory":"MET"}';
        NGMCP_AMRQueueable.JobItem ji =
            new NGMCP_AMRQueueable.JobItem(
                bulkReq,
                req.Id,
                amrPayload,
                u.Id,
                'NO',
                tqPayload
            );

        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());

        Test.startTest();
        System.enqueueJob(
            new NGMCP_AMRQueueable(
                new List<NGMCP_AMRQueueable.JobItem>{ ji },
                new List<Id>{ bulkReq.Id },
                'AMR',
                'STRT'
            )
        );
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM NGMCP_Bulk_Request__c WHERE Id = :bulkReq.Id]
        );
    }


}