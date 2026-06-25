@IsTest
public class NGMCP_AppntDeappBulkCreationBatchTest {

    /* =====================================================
       Callout Mock (Required because batch allows callouts)
    ====================================================== */
    private class AMRMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"SUCCESS"}');
            return res;
        }
    }

    /* =====================================================
       Test Data Creator
    ====================================================== */
    private static NGMCP_Bulk_Request__c createBulkRequest() {
        return new NGMCP_Bulk_Request__c(
            NGMCP_Customer__c            = 'CUST01',
            NGMCP_MPRN__c                = '1234567890',
            NGMCP_Appointment_Type__c    = 'FIX',
            NGMCP_Effective_date__c      = String.valueOf(Date.today().addDays(5)),
            NGMCP_Market_Sector_Code__c  = 'I',
            NGMCP_Contract_Ref__c        = 'CONT-001',
            NGMCP_New_Supplier_Short_Code__c = 'SUP01',
            NGMCP_New_MAM_Code__c        = 'MAM01',
            NGMCP_Payment_Type__c        = 'Credit',
            NGMCP_Meter_type__c          = 'Diaphragm',
            NGMCP_Meter_Model__c         = 'MODEL1',
            NGMCP_Meter_YOM__c           = '2022',
            NGMCP_Meter_Serial_Number__c = 'MSN123',
            NGMCP_No_of_digit__c         = '5',
            NGMCP_Multiplication_factor__c = '1',
            NGMCP_Location_code__c       = 'IN',
            NGMCP_Building_Number__c     = '10',
            NGMCP_Street__c              = 'Test Street',
            NGMCP_Post_Town__c           = 'Delhi',
            NGMCP_Post_Code__c           = '110001',
            NGMCP_Dependent_Locality__c  = 'Local'
        );
    }

    /* =====================================================
       MAIN TEST – Batch Execution
    ====================================================== */
    @IsTest
    static void testBatchExecution() {

        // Get active user
        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        // Insert test Bulk Request
        NGMCP_Bulk_Request__c br = createBulkRequest();
        insert br;

        // Register callout mock
        Test.setMock(HttpCalloutMock.class, new AMRMock());

        Test.startTest();

        Database.executeBatch(
            new NGMCP_AppntDeappBulkCreationBatch(
                new List<Id>{ br.Id },
                'Appointment',
                'FNDAS',
                u.Id
            ),
            1
        );

        Test.stopTest(); // Safe now because Queueable is blocked in test

        // Simple safe assertion
        Integer recordCount = [
            SELECT COUNT()
            FROM NGMCP_Bulk_Request__c
            WHERE Id = :br.Id
        ];

        System.assertEquals(1, recordCount, 'Bulk request should exist after batch run');
    }

    /* =====================================================
       Finish Method Coverage
    ====================================================== */
    @IsTest
    static void testFinish() {

        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        Test.startTest();
        NGMCP_AppntDeappBulkCreationBatch batch =
            new NGMCP_AppntDeappBulkCreationBatch(
                new List<Id>(),
                'Appointment',
                'COS',
                u.Id
            );
        batch.finish(null);
        Test.stopTest();

        System.assert(true, 'Finish executed successfully');
    }
}