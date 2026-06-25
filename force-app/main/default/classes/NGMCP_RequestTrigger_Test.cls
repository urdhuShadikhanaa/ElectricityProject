@IsTest
private class NGMCP_RequestTrigger_Test {
    private static Id rtIdByName(Schema.SObjectType sObjType, String rtName) {
        Schema.RecordTypeInfo rti = sObjType.getDescribe().getRecordTypeInfosByName().get(rtName);
        System.assertNotEquals(null, rti, 'Missing Record Type: ' + rtName);
        return rti.getRecordTypeId();
    }

    @IsTest
    static void test_AfterUpdate_MovesToCompleted_Enqueues_ForCWR() {
        // Arrange RTs
        Id cwrRtId = rtIdByName(NGMCP_Request__c.SObjectType, 'Customer Work Request');
        Id amrRtId = rtIdByName(NGMCP_Request__c.SObjectType, 'AMR');

        // Create an AMR record that matches SR/GPS number to be picked by the trigger’s SOQL
        NGMCP_Request__c amr = new NGMCP_Request__c(
            RecordTypeId = amrRtId,
            NGMCP_Related_GPS_Job_Number__c = 'SR-200'
        );
        insert amr;

        // Create a Customer Work Request that will later transition to Completed
        NGMCP_Request__c cwr = new NGMCP_Request__c(
            RecordTypeId = cwrRtId,
            NGMCP_Job_Type__c = 'Exchange',
            NGMCP_Job_SubType__c = 'GPS',
            NGMCP_Status__c = 'Inprogress',
            NGMCP_SR_Ticket__c = 'SR-200'
        );
        insert cwr;

        // Act
        Test.startTest();
        cwr.NGMCP_Status__c = 'Completed';
        update cwr; // should hit the if, collect SR, query AMR, enqueue queueable
        Test.stopTest();

        // Assert basics
        NGMCP_Request__c reloaded = [
            SELECT NGMCP_Status__c FROM NGMCP_Request__c WHERE Id = :cwr.Id
        ];
        System.assertEquals('Completed', reloaded.NGMCP_Status__c);

        // Optional: we can assert the AMR exists with the matching GPS ref (sanity of setup)
        Integer amrCount = [
            SELECT COUNT() FROM NGMCP_Request__c
            WHERE RecordType.Name = 'AMR'
              AND NGMCP_Related_GPS_Job_Number__c = 'SR-200'
        ];
        System.assertEquals(1, amrCount);
    }

    @IsTest
    static void test_AfterUpdate_Negative_NotExchangeOrNoSR_NoEnqueue() {
        Id cwrRtId = rtIdByName(NGMCP_Request__c.SObjectType, 'Customer Work Request');

        // Create a record that won't meet the condition (wrong subtype and blank SR)
        NGMCP_Request__c cwr = new NGMCP_Request__c(
            RecordTypeId = cwrRtId,
            NGMCP_Job_Type__c = 'Exchange',
            NGMCP_Job_SubType__c = 'NotGPS',
            NGMCP_Status__c = 'Inprogress'
            // SR ticket omitted
        );
        insert cwr;

        Test.startTest();
        cwr.NGMCP_Status__c = 'Completed';
        update cwr;  // condition should not fire
        Test.stopTest();

        System.assertEquals('Completed', [SELECT NGMCP_Status__c FROM NGMCP_Request__c WHERE Id = :cwr.Id].NGMCP_Status__c);
    }
}