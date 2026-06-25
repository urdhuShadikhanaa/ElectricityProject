@IsTest
public class NGMCP_AMRBulkCreationBatch_Test {

    private static NGMCP_Bulk_Request__c createBulkRequest(Integer rowNum) {
    NGMCP_Bulk_Request__c br = new NGMCP_Bulk_Request__c(
        NGMCP_Callout_Type__c = 'AMR',
        NGMCP_Callout_Sub_Type__c = 'STRT',
        NGMCP_Status__c = 'Pending',
        NGMCP_Input_CSV_Row_Number__c = rowNum,
        NGMCP_Response__c = '',
        NGMCP_Customer__c = 'CUST01',
        NGMCP_Job_Type__c = 'STRT',
        NGMCP_MPRN__c = '123456789',
        NGMCP_Meter_Manufacturer__c = 'ABC',
        NGMCP_Meter_Model__c = 'M1',
        NGMCP_Meter_YOM__c = '2023',   //  MUST be valid number
        NGMCP_Meter_Dials__c = '6',
        NGMCP_Meter_Unit_Of_Measure__c = 'm3',
        NGMCP_Post_Code__c = 'AB12CD',
        NGMCP_Post_Town__c = 'Town',

        
        NGMCP_Contact_Mechanism_Value__c = '987654321',
        NGMCP_Site_Contact__c = 'John',
        NGMCP_Contract_Ref__c = 'CR-001',
        NGMCP_Trans_Ref__c = 'TR-001'
    );

    insert br;
    return br;
}
    @IsTest
    static void testBatchSingleRecord() {

        NGMCP_Bulk_Request__c br = createBulkRequest(2);

        Test.startTest();
        Database.executeBatch(
            new NGMCP_AMRBulkCreationBatch(
                new List<Id>{ br.Id },
                'AMR',
                'STRT',
                UserInfo.getUserId()
            ),
            200 
        );
        Test.stopTest();

        NGMCP_Bulk_Request__c refreshed =
            [SELECT NGMCP_Status__c FROM NGMCP_Bulk_Request__c WHERE Id = :br.Id];

        System.assertNotEquals(null, refreshed);
    }

    @IsTest
    static void testBatchMultipleRecordsSameChunk() {

        List<NGMCP_Bulk_Request__c> records = new List<NGMCP_Bulk_Request__c>();
        for (Integer i = 2; i <= 4; i++) {
            records.add(createBulkRequest(i));
        }

        List<Id> ids = new List<Id>();
        for (NGMCP_Bulk_Request__c r : records) {
            ids.add(r.Id);
        }

        Test.startTest();
        Database.executeBatch(
            new NGMCP_AMRBulkCreationBatch(
                ids,
                'AMR',
                'STRT',
                UserInfo.getUserId()
            ),
            200
        );
        Test.stopTest();

        System.assertEquals(
            3,
            [SELECT COUNT() FROM NGMCP_Bulk_Request__c WHERE Id IN :ids]
        );
    }
    
    @isTest
    static void testBatch() {
        NGMCP_Bulk_Request__c br = new NGMCP_Bulk_Request__c(
            NGMCP_Callout_Type__c = 'AMR',
            NGMCP_Callout_Sub_Type__c = 'STRT',
            NGMCP_Status__c = 'Pending',
            NGMCP_Response__c = '',
            NGMCP_Customer__c = 'CUST01',
            NGMCP_Job_Type__c = 'STRT',
            NGMCP_MPRN__c = '123456789',
            NGMCP_Meter_Manufacturer__c = 'ACTARIS',
            NGMCP_Meter_Model__c = 'G4',
            NGMCP_Meter_YOM__c = '1999',
            NGMCP_Meter_Dials__c = '6',
            NGMCP_Meter_Unit_Of_Measure__c = 'm3',
            NGMCP_Post_Code__c = 'AB12CD',
            NGMCP_Post_Town__c = 'Town',
            NGMCP_Input_CSV_Row_Number__c = 2
        );
        insert br;

        Test.startTest();
        Database.executeBatch(
            new NGMCP_AMRBulkCreationBatch(
                new List<Id>{ br.Id },
                'AMR',
                'STRT',
                UserInfo.getUserId()
            ),
            200 
        );
        Test.stopTest();
    }
}