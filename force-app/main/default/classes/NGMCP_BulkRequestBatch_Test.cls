@IsTest
public class NGMCP_BulkRequestBatch_Test {

    private static NGMCP_Bulk_Request__c buildInvalidBulkRequest(Id existingId) {
        NGMCP_Bulk_Request__c br = new NGMCP_Bulk_Request__c();
        br.Id = existingId; 
        br.NGMCP_Status__c = 'Pending';
        return br;
    }

    @IsTest
    static void testBulkRequestBatch_InsertFailure_Path() {

        Id userId = UserInfo.getUserId();

        NGMCP_Bulk_Request__c existing = new NGMCP_Bulk_Request__c(
            NGMCP_Status__c = 'Existing'
        );
        insert existing;

        List<NGMCP_Bulk_Request__c> invalidList = new List<NGMCP_Bulk_Request__c>{
            buildInvalidBulkRequest(existing.Id)
        };

        Test.startTest();

        Database.executeBatch(
            new NGMCP_BulkRequestBatch(
                invalidList,
                'AMR',
                'STRT',
                userId
            ),
            200 
        );

        Test.stopTest();

        NGMCP_Bulk_Request__c check =
            [SELECT Id, NGMCP_Status__c FROM NGMCP_Bulk_Request__c WHERE Id = :existing.Id];

        System.assertEquals('Existing', check.NGMCP_Status__c);
    }

    @IsTest
    static void testBulkRequestBatch_NonAMR_Action() {

        Id userId = UserInfo.getUserId();

        NGMCP_Bulk_Request__c existing = new NGMCP_Bulk_Request__c(
            NGMCP_Status__c = 'Existing'
        );
        insert existing;

        List<NGMCP_Bulk_Request__c> badList = new List<NGMCP_Bulk_Request__c>{
            buildInvalidBulkRequest(existing.Id)
        };

        Test.startTest();

        Database.executeBatch(
            new NGMCP_BulkRequestBatch(
                badList,
                'Appointment', 
                'COS',
                userId
            ),
            200
        );

        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM NGMCP_Bulk_Request__c WHERE Id = :existing.Id]
        );
    }
}