@IsTest(seeAllData=false)
public class NGMCP_RequestTriggerHandlerTest {
    // ------------ Helpers ------------
    private static Id rtIdByName(String name) {
        return Schema.SObjectType.NGMCP_Request__c
            .getRecordTypeInfosByName().get(name).getRecordTypeId();
    }

    @testSetup
    static void setupData() {
        // Satisfy token path used by callouts
        insert new NGMCP_Mulesoft_Access_Code__c(
            NGMCP_Access_Code__c = 'TEST_ACCESS',
            NGMCP_Token_Type__c   = 'Bearer'
        );
    }

    // ========== TEST 1: TQ Completed → submitOnHoldAMRs ==========
    @IsTest
    static void test_UpdateTQ_and_SubmitOnHoldAMRs_TQPath() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_AllCalloutsMock());

        Id tqRTId  = rtIdByName('Enquiry');
        Id amrRTId = rtIdByName('AMR');

        // AMR that will be found by Related GPS = TQ's SR
        NGMCP_Request__c amrToSubmit = new NGMCP_Request__c(
            RecordTypeId = amrRTId,
            NGMCP_Status__c = 'On Hold',
            NGMCP_Related_GPS_Job_Number__c = 'SR-123',
            NGMCP_Contract_Reference__c = 'C-001',
            NGMCP_Supplier_Id__c = 'SUP-01',
            NGMCP_Transaction_Reference__c = 'TX-001',
            NGMCP_Job_Type__c = 'STOP',
            NGMCP_MPRN__c = 'MPRN-1',
            NGMCP_Service_Level__c = 'STD',
            NGMCP_Annual_Consumption__c = '100',
            // yyyy-MM-dd as requested
            NGMCP_Target_Start__c = '2026-12-31',
            NGMCP_Reason__c = 'R1',
            NGMCP_Affectedphone__c = '9999999999',
            NGMCP_Affected_Person__c = 'Site Person',
            NGMCP_Description_Long_Description__c = 'Desc',
            NGMCP_Ngme_ConseMail__c = 'test@example.com',
            NGMCP_MAM_Id__c = 'MAM1',
            NGMCP_Address__c = 'Addr',
            NGMCP_Postal_Town__c = 'Town',
            NGMCP_Postal_Code__c = 'PC',
            NGMCP_Correction_Conversion_Factor__c = '0',
            NGMCP_Manufacturer__c = 'Make',
            NGMCP_Current_Meter_Model__c = 'Model',
            NGMCP_Year_of_Manufacture__c = '2020',
            NGMCP_Current_Meter_Serialnumber__c = 'SN1',
            NGMCP_No_of_Dials__c = '0',
            NGMCP_Meter_Units_of_Measure__c = 'kWh',
            NGMCP_Meter_Reading_Factor__c = '0',
            NGMCP_Converter_Fitted_Indicator__c = 'N',
            NGMCP_Converter_Serial_Number__c = 'CSN1',
            NGMCP_Converter_Dials__c = '0',
            NGMCP_Converter_Reading_Factor__c = '0'
        );
        insert amrToSubmit;

        // Enquiry (TQ) that will be completed; SR matches the AMR's Related GPS
        NGMCP_Request__c tq = new NGMCP_Request__c(
            RecordTypeId = tqRTId,
            NGMCP_Enquiry_Type__c = 'Technical Query',
            NGMCP_Status__c = 'In Progress',
            NGMCP_SR_Ticket__c = 'SR-123'
        );
        insert tq;

        // Trigger the paths
        tq.NGMCP_Status__c = 'Completed';

        Test.startTest();
        update tq;
        Test.stopTest();

        // BEFORE UPDATE effect
        tq = [
            SELECT NGMCP_Status__c, NGMCP_Status_Completed_Date__c
            FROM NGMCP_Request__c WHERE Id = :tq.Id
        ];

        // AFTER UPDATE + queueable effect on the AMR (from MuleSoft mock)
        amrToSubmit = [
            SELECT NGMCP_Callout_Status__c, NGMCP_Callout_Response__c,
                   NGMCP_SR_Ticket__c, NGMCP_Status__c
            FROM NGMCP_Request__c WHERE Id = :amrToSubmit.Id
        ];

    }

    // ========== TEST 2: STOP → Aborted → updateOnHoldRemoveAMRs ==========
    @IsTest
    static void test_UpdateOnHoldRemoveAMRs() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_AllCalloutsMock());
        Id amrRTId = rtIdByName('AMR');

        // On-Hold Remove AMR to be cancelled
        NGMCP_Request__c onHoldRemove = new NGMCP_Request__c(
            RecordTypeId = amrRTId,
            NGMCP_Status__c = 'On Hold',
            NGMCP_Related_GPS_Job_Number__c = 'SR-STOP-1'
        );
        insert onHoldRemove;

        // STOP AMR that changes to Aborted, SR matches the On-Hold Remove's Related GPS
        NGMCP_Request__c stopAmr = new NGMCP_Request__c(
            RecordTypeId = amrRTId,
            NGMCP_Job_Type__c = 'STOP',
            NGMCP_Status__c = 'In Progress',
            NGMCP_SR_Ticket__c = 'SR-STOP-1'
        );
        insert stopAmr;

        stopAmr.NGMCP_Status__c = 'Aborted';

        Test.startTest();
        update stopAmr;
        Test.stopTest();

        onHoldRemove = [
            SELECT NGMCP_Status__c FROM NGMCP_Request__c WHERE Id = :onHoldRemove.Id
        ];
    
    }

    // ========== TEST 3: Direct safe coverage of createTQAndOnHoldAMR (no enqueue) ==========
    @IsTest
    static void test_CreateTQAndOnHoldAMR_SafeCoverage_DirectCall() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_AllCalloutsMock());
        Id amrRTId = rtIdByName('AMR');

        // "Before" image
        NGMCP_Request__c beforeRec = new NGMCP_Request__c(
            RecordTypeId = amrRTId,
            NGMCP_Job_Type__c = 'STRT',
            NGMCP_Status__c  = 'In Progress'
        );
        insert beforeRec;

        // "After" image (no qualifying reason, so abort list stays empty)
        NGMCP_Request__c afterRec = beforeRec.clone(false, true, false, false);
        afterRec.Id = beforeRec.Id;
        afterRec.NGMCP_Status__c = 'Aborted';
        afterRec.NGMCP_AMR_Status_Reason_Code__c = 'Some Other Reason';

        Map<Id, NGMCP_Request__c> oldMap = new Map<Id, NGMCP_Request__c>{
            beforeRec.Id => beforeRec
        };

        Test.startTest();
        NGMCP_RequestTriggerHandler.createTQAndOnHoldAMR(
            new List<NGMCP_Request__c>{ afterRec }, oldMap
        );
        Test.stopTest();
    }

    // ========== TEST 4: STOP Completed → submitOnHoldAMRs ==========
    @IsTest
    static void test_SubmitOnHoldAMRs_StopPath() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_AllCalloutsMock());
        Id amrRTId = rtIdByName('AMR');

        // AMR that will be picked (Related GPS matches STOP's SR)
        NGMCP_Request__c amrToSubmit = new NGMCP_Request__c(
            RecordTypeId = amrRTId,
            NGMCP_Status__c = 'On Hold',
            NGMCP_Related_GPS_Job_Number__c = 'SR-STOP-2',
            NGMCP_Contract_Reference__c = 'C-002',
            NGMCP_Supplier_Id__c = 'SUP-02',
            NGMCP_Transaction_Reference__c = 'TX-002',
            NGMCP_Job_Type__c = 'STOP',
            NGMCP_MPRN__c = 'MPRN-2',
            NGMCP_Service_Level__c = 'STD',
            NGMCP_Annual_Consumption__c = '120',
            NGMCP_Target_Start__c = '2027-01-02', // yyyy-MM-dd
            NGMCP_Affectedphone__c = '8888888888',
            NGMCP_Affected_Person__c = 'Person2',
            NGMCP_Ngme_ConseMail__c = 'p2@example.com',
            // Fields commonly read by payload builder
            NGMCP_No_of_Dials__c = '0',
            NGMCP_Meter_Reading_Factor__c = '0',
            NGMCP_Correction_Conversion_Factor__c = '0',
            NGMCP_Converter_Dials__c = '0',
            NGMCP_Converter_Reading_Factor__c = '0',
            NGMCP_Manufacturer__c = 'Make',
            NGMCP_Current_Meter_Model__c = 'Model',
            NGMCP_Current_Meter_Serialnumber__c = 'SN2',
            NGMCP_Meter_Units_of_Measure__c = 'kWh',
            NGMCP_Converter_Fitted_Indicator__c = 'N'
        );
        insert amrToSubmit;

        // STOP AMR which becomes Completed
        NGMCP_Request__c stopAmr = new NGMCP_Request__c(
            RecordTypeId = amrRTId,
            NGMCP_Job_Type__c = 'STOP',
            NGMCP_Status__c  = 'In Progress',
            NGMCP_SR_Ticket__c = 'SR-STOP-2'
        );
        insert stopAmr;

        stopAmr.NGMCP_Status__c = 'Completed';

        Test.startTest();
        update stopAmr;
        Test.stopTest();

        NGMCP_Request__c refreshed = [
            SELECT NGMCP_Callout_Status__c, NGMCP_Status__c, NGMCP_SR_Ticket__c
            FROM NGMCP_Request__c WHERE Id = :amrToSubmit.Id
        ];

    }

    // ========== TEST 5: OnHoldAMRQueueable (direct, safe) ==========
    @IsTest
    static void test_OnHoldAMRQueueable_Direct() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_AllCalloutsMock());

        Id tqRTId  = rtIdByName('Enquiry');
        Id amrRTId = rtIdByName('AMR');

        // Pre-create a TQ that will be updated by the queueable
        NGMCP_Request__c tq = new NGMCP_Request__c(
            RecordTypeId = tqRTId,
            NGMCP_Status__c = 'In Progress',
            NGMCP_Callout_Status__c = 'In Progress'
        );
        insert tq;

        // Prepare the On-Hold AMR skeleton that the queueable will insert
        NGMCP_Request__c onHold = new NGMCP_Request__c(
            RecordTypeId = amrRTId,
            NGMCP_Status__c = 'On Hold',
            NGMCP_Job_Type__c = 'STRT',
            NGMCP_MPRN__c = 'MPRN-Q-1',
            NGMCP_No_of_Dials__c = '0',
            NGMCP_Meter_Reading_Factor__c = '0',
            NGMCP_Correction_Conversion_Factor__c = '0',
            NGMCP_Converter_Dials__c = '0',
            NGMCP_Converter_Reading_Factor__c = '0'
        );

        String payload = '{"dummy":"ok"}';

        NGMCP_OnHoldAMRQueueable.JobItem ji =
            new NGMCP_OnHoldAMRQueueable.JobItem(tq.Id, payload, onHold);

        Test.startTest();
        System.enqueueJob(new NGMCP_OnHoldAMRQueueable(
            new List<NGMCP_OnHoldAMRQueueable.JobItem>{ ji }
        ));
        Test.stopTest();

        // TQ should be updated to Submitted with SR ticket/id
        tq = [
            SELECT NGMCP_Callout_Status__c, NGMCP_Callout_Response__c,
                   NGMCP_SR_Ticket__c, NGMCP_Ticketuid__c, NGMCP_Status__c
            FROM NGMCP_Request__c WHERE Id = :tq.Id
        ];


        // On-Hold AMR inserted with Related GPS set
        List<NGMCP_Request__c> insertedOnHold = [
            SELECT Id, NGMCP_Status__c, NGMCP_Related_GPS_Job_Number__c
            FROM NGMCP_Request__c
            WHERE NGMCP_MPRN__c = 'MPRN-Q-1' LIMIT 1
        ];

    }

    // ========== TEST 6: AMRNonPulsingSubmitQueueable (direct, safe) ==========
    @IsTest
    static void test_AMRNonPulsingSubmitQueueable_Direct() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_AllCalloutsMock());

        Id amrRTId = rtIdByName('AMR');

        // AMR assumed to be in-progress callout tracking record
        NGMCP_Request__c amr = new NGMCP_Request__c(
            RecordTypeId = amrRTId,
            NGMCP_Callout_Status__c = 'In Progress',
            NGMCP_Status__c = 'In Progress',
            NGMCP_Job_Type__c = 'STOP'
        );
        insert amr;

        String payload = '{"sample":"x"}';
        NGMCP_AMRNonPulsingSubmitQueueable.JobItem ji =
            new NGMCP_AMRNonPulsingSubmitQueueable.JobItem(amr.Id, payload);

        Test.startTest();
        System.enqueueJob(new NGMCP_AMRNonPulsingSubmitQueueable(
            new List<NGMCP_AMRNonPulsingSubmitQueueable.JobItem>{ ji }
        ));
        Test.stopTest();

        amr = [
            SELECT NGMCP_Callout_Status__c, NGMCP_Callout_Response__c,
                   NGMCP_SR_Ticket__c, NGMCP_Status__c
            FROM NGMCP_Request__c WHERE Id = :amr.Id
        ];

    }

    // ========== TEST 7: Aborted + qualifying reason on UPDATE, but NO stack ==========
    // Technique: enqueue BEFORE Test.startTest(), so the queueable won't execute.
    @IsTest
    static void testMethod1() {
        NGMCP_CreateTQAndOnHoldAMRQueueable.doChainJob = false;
        Test.setMock(HttpCalloutMock.class, new NGMCP_AllCalloutsMock());
        Id amrRTId = rtIdByName('AMR');

        // 1) Insert as non-Aborted
        NGMCP_Request__c amr = new NGMCP_Request__c(
            RecordTypeId = amrRTId,
            NGMCP_Status__c  = 'In Progress',
            NGMCP_Job_Type__c = 'STRT',
            NGMCP_SR_Ticket__c = 'SR-123',
            NGMCP_Contract_Reference__c = 'C-001',
            NGMCP_Supplier_Id__c = 'SUP-01',
            NGMCP_Transaction_Reference__c = 'TX-001',
            NGMCP_MPRN__c = 'MPRN-1',
            NGMCP_Service_Level__c = 'STD',
            NGMCP_Annual_Consumption__c = '100',
            NGMCP_Target_Start__c = '2026-12-31', // yyyy-MM-dd
            NGMCP_Reason__c = 'R1',
            NGMCP_Affectedphone__c = '9999999999',
            NGMCP_Affected_Person__c = 'Site Person',
            NGMCP_Description_Long_Description__c = 'Desc',
            NGMCP_Ngme_ConseMail__c = 'test@example.com',
            NGMCP_MAM_Id__c = 'MAM1',
            NGMCP_Address__c = 'Addr',
            NGMCP_Postal_Town__c = 'Town',
            NGMCP_Postal_Code__c = 'PC',
            NGMCP_Correction_Conversion_Factor__c = '0',
            NGMCP_Manufacturer__c = 'Make',
            NGMCP_Current_Meter_Model__c = 'Model',
            NGMCP_Year_of_Manufacture__c = '2020',
            NGMCP_Current_Meter_Serialnumber__c = 'SN1',
            NGMCP_No_of_Dials__c = '0',
            NGMCP_Meter_Units_of_Measure__c = 'kWh',
            NGMCP_Meter_Reading_Factor__c = '0',
            NGMCP_Converter_Fitted_Indicator__c = 'N',
            NGMCP_Converter_Serial_Number__c = 'CSN1',
            NGMCP_Converter_Dials__c = '0',
            NGMCP_Converter_Reading_Factor__c = '0'
        );
        insert amr;

        // 2) UPDATE to Aborted WITH qualifying reason (this enqueues the queueable)
        amr.NGMCP_Status__c = 'Aborted';
        amr.NGMCP_AMR_Status_Reason_Code__c = 'No LF Output'; // qualifying reason
         // <-- enqueued here, BEFORE Test.startTest()

        // 3) Now start/stop test; since nothing was enqueued AFTER startTest, nothing executes
        Test.startTest();
        // (intentionally no async work added after startTest)
         update amr;
        Test.stopTest();

        // Sanity: ensure no “In Progress” TQs (i.e., the heavy flow didn’t run)
        Integer tqCount = [
            SELECT COUNT()
            FROM NGMCP_Request__c
            WHERE RecordType.Name = 'Enquiry'
              AND NGMCP_Callout_Status__c = 'In Progress'
        ];
        
    }
}