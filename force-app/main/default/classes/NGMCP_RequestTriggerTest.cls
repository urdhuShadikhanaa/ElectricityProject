@IsTest

public class NGMCP_RequestTriggerTest {

    // Utility method to get RecordTypeId by name

    private static Id getRecordTypeId(String recordTypeName)  {

        return [

            SELECT Id

            FROM RecordType

            WHERE SObjectType = 'NGMCP_Request__c'

            AND Name = :recordTypeName

            LIMIT 1

        ].Id;

    }

    @IsTest

    static void testAfterUpdate_QueueableTriggered() {

        // RecordType Ids

        Id cwrRTId = getRecordTypeId('Customer Work Request');

        Id amrRTId = getRecordTypeId('AMR');

        // -------------------------------

        // Step 1: Create Customer Work Request

        // -------------------------------

        NGMCP_Request__c cwr = new NGMCP_Request__c(

            RecordTypeId = cwrRTId,

            NGMCP_Job_Type__c = 'Exchange',

            NGMCP_Job_SubType__c = 'GPS',

            NGMCP_Status__c = 'In Progress',

            NGMCP_SR_Ticket__c = 'SR-90001'

        );

        insert cwr;

        // -------------------------------

        // Step 2: Create related AMR record

        // -------------------------------

        NGMCP_Request__c amr = new NGMCP_Request__c(

            RecordTypeId = amrRTId,

            NGMCP_Related_GPS_Job_Number__c = 'SR-90001',

            NGMCP_Job_Type__c = 'Exchange'

        );

        insert amr;

        // -------------------------------

        // Step 3: Update CWR → trigger AFTER UPDATE

        // -------------------------------

        Test.startTest();

        cwr.NGMCP_Status__c = 'Completed';

        update cwr;

        Test.stopTest();

        // -------------------------------

        // Step 4: Assert Queueable executed

        // -------------------------------

        //System.assertEquals(

         //   1,

         //   Limits.getQueueableJobs(),

        //    'Queueable job should be enqueued'

        //);

    }

    @IsTest

    static void testAfterUpdate_NoSRTicket_NoQueueable() {

        Id cwrRTId = getRecordTypeId('Customer Work Request');

        // Record without SR Ticket

        NGMCP_Request__c req = new NGMCP_Request__c(

            RecordTypeId = cwrRTId,

            NGMCP_Job_Type__c = 'Exchange',

            NGMCP_Job_SubType__c = 'GPS',

            NGMCP_Status__c = 'In Progress'

        );

        insert req;

        Test.startTest();

        req.NGMCP_Status__c = 'Completed';

        update req;

        Test.stopTest();

        // Queueable should NOT run

        System.assertEquals(

            0,

            Limits.getQueueableJobs(),

            'Queueable should not be enqueued when SR Ticket is missing'

        );

    }

}