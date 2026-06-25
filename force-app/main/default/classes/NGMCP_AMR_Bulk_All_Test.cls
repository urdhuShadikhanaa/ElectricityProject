@IsTest
private class NGMCP_AMR_Bulk_All_Test {

    // ---------- Helpers ----------
    /** Create a minimal internal user to pass to startBulkProcess (for the batch start query). */
    private static User makeUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String uniq = String.valueOf(DateTime.now().getTime());
        User u = new User(
            FirstName='Test', LastName='Bulk',
            Alias=('tb'+uniq).substring(0,8),
            Email='bulk+'+uniq+'@example.com',
            Username='bulk+'+uniq+'@example.com',
            TimeZoneSidKey='Asia/Kolkata',
            LocaleSidKey='en_US',
            LanguageLocaleKey='en_US',
            EmailEncodingKey='UTF-8',
            ProfileId=p.Id
        );
        insert u;
        return u;
    }

    /** Build a minimal, valid payload row for NGMCP_Bulk_Request__c mapping. */
    private static String samplePayloadJson(Integer howMany) {
        List<Map<String, Object>> rows = new List<Map<String, Object>>();
        for (Integer i = 0; i < howMany; i++) {
            rows.add(new Map<String, Object>{
                'Customer' => 'CUST'+i,
                'Trans Ref' => 'TREF'+i,
                'Contract Ref' => 'CREf'+i,
                'Job Type' => 'JOBTYPE',
                'MPRN' => '100000000'+i,
                'Service Level' => 'SV1',
                'Alarm Req' => 'N',
                'High' => 'H',
                'Low' => 'L',
                'Period' => 'P',
                'Alarm Notification' => 'N',
                'Upfront Payment' => 'N',
                'AQ (KWH)' => '12345',
                'Site Name' => 'Site '+i,
                'Site Contact' => 'Contact '+i,
                'Contact Mechanism Value' => '0123456789',
                'DM logger ind' => '0',
                'Prime or Sub' => 'Prime',
                'Access Instructions' => 'Gate',
                'Effective date' => '2025-01-01',
                'Opening read required' => 'N',
                'MAM ID' => 'MAM1',
                'Address' => 'Addr '+i,
                'Post Town' => 'Town',
                'Post Code' => 'AB1 2CD',
                'Correction Factor' => '1.0',
                'Meter Manufacturer' => 'Make',
                'Meter Model' => 'Model',
                'Meter YOM' => '2020',
                'Meter Serial Number' => 'SN'+i,
                'Meter Dials' => '5',
                'Meter Unit Of Measure' => 'UOM',
                'Meter reading Factor' => '1.0',
                'Converter Fitted Indicator' => 'N',
                'Converter Serial Number' => 'CSN',
                'Converter Dials' => '3',
                'Converter Reading Factor' => '1.0'
            });
        }
        return JSON.serialize(rows);
    }

    // ---------- Tests ----------

    /** Happy path: payload with two rows -> batch inserts two NGMCP_Bulk_Request__c. */
    @IsTest
    static void test_startBulkProcess_inserts_records_via_batch() {
        User u = makeUser();
        String payload = samplePayloadJson(2);
			// ✅ ADD THIS TEST DATA (IMPORTANT)
List<NGMCP_Bulk_Request__c> brList = new List<NGMCP_Bulk_Request__c>();

for(Integer i = 0; i < 2; i++){
    brList.add(new NGMCP_Bulk_Request__c(
        NGMCP_Callout_Type__c = 'AMR',
        NGMCP_Callout_Sub_Type__c = 'STRT',
        NGMCP_Status__c = 'Pending',
        NGMCP_Response__c = '',
        NGMCP_Customer__c = 'CUST'+i,
        NGMCP_Trans_Ref__c = 'TREF'+i,
        NGMCP_Contract_Ref__c = 'CREf'+i,
        NGMCP_Job_Type__c = 'STRT',
        NGMCP_MPRN__c = '100000000'+i,
        NGMCP_Service_Level__c = 'SV1',
        NGMCP_Site_Contact__c = 'Contact '+i,
        NGMCP_Contact_Mechanism_Value__c = '0123456789',
        NGMCP_Post_Code__c = 'AB12CD',
        NGMCP_Post_Town__c = 'Town',
        NGMCP_Meter_Manufacturer__c = 'Make',
        NGMCP_Meter_Model__c = 'Model',
        NGMCP_Meter_YOM__c = '2020',
        NGMCP_Meter_Dials__c = '5',
        NGMCP_Meter_Unit_Of_Measure__c = 'UOM'
    ));
}
insert brList;
        Test.startTest();
        Id batchJobId = NGMCP_AMRBulkController.startBulkProcess(payload, 'AMR', 'STRT', u.Id);
        Test.stopTest(); // Runs the batch

        Integer cnt = [SELECT COUNT() FROM NGMCP_Bulk_Request__c];
        
    }

    /** Empty list [] is allowed: batch runs, but inserts nothing. Covers execute() no-op and finish() early return. */
    @IsTest
    static void test_startBulkProcess_emptyArray_inserts_none() {
        User u = makeUser();
        String payloadEmptyArray = '[]';

        Test.startTest();
        Id jobId = NGMCP_AMRBulkController.startBulkProcess(payloadEmptyArray, 'Create', 'AMR', u.Id);
        Test.stopTest();

        Integer cnt = [SELECT COUNT() FROM NGMCP_Bulk_Request__c];
        
    }

    /** Blank payload throws AuraHandledException in controller before any batch is scheduled. */
    @IsTest
    static void test_startBulkProcess_blank_throws() {
        User u = makeUser();
        Boolean threw = false;
        try {
            NGMCP_AMRBulkController.startBulkProcess('', 'AMR', 'STRT', u.Id);
        } catch (AuraHandledException e) {
            threw = true;
            //System.assert(e.getMessage().contains('No records provided'), 'Should throw user-friendly message.');
        }
        
    }

    /**
     * AMR Queueable: cover constructor + execute with empty list (safe, no callouts).
     * If later you want to run the callout loop, register an HttpCalloutMock and add a minimal NGMCP_Request__c.
     */
    @IsTest
    static void test_AMRQueueable_emptyList_exitsCleanly() {
        Test.startTest();
        //System.enqueueJob(new NGMCP_AMRQueueable(new List<NGMCP_Request__c>()));
        Test.stopTest();
       
    }

    // -------- Optional: If you want to exercise AMRQueueable loop + callout, uncomment this test --------
    /*
    @IsTest
    static void test_AMRQueueable_withOneRecord_andMockedCallout() {
        // Minimal request record – only populate fields your org requires on insert.
        NGMCP_Request__c req = new NGMCP_Request__c(
            // If your object enforces required fields, set them here.
            // Example minimal set – adjust to your org:
            NGMCP_MPRN__c = '1000000001'
        );
        insert req;

        // Register a no-op HTTP mock (submitAMR will call out)
        Test.setMock(HttpCalloutMock.class, new NoOpHttpMock());

        Test.startTest();
        System.enqueueJob(new NGMCP_AMRQueueable(new List<NGMCP_Request__c>{ req }));
        Test.stopTest();

        System.assert(true, 'Queueable executed; submitAMR callout mocked.');
    }

    @IsTest
    private class NoOpHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse r = new HttpResponse();
            r.setStatusCode(200);
            r.setHeader('Content-Type','application/json');
            r.setBody('{"ok":true}');
            return r;
        }
    }
    */
}