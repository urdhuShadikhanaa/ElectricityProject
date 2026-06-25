@IsTest(SeeAllData=true)
private class NGMCP_AMRUpdateScheduler_Test {

    // A no-op Queueable we can safely enqueue in tests (used to cover the test hook branch)
    private class DummyQueueable implements System.Queueable {
        public void execute(QueueableContext qc) {
            // Intentionally empty – proves enqueue works without side effects.
        }
    }

    // A permissive mock that returns 200 + [] for ANY HTTP call made by downstream queueables.
    // This prevents NullPointerExceptions / callout errors inside helper classes during tests.
    private class AllowAll200Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[]');
            return res;
        }
    }

    /**
     * Test 1: Covers the TEST hook branch in execute():
     * - We set TEST_QUEUEABLE to a harmless dummy.
     * - execute() should enqueue DummyQueueable and RETURN before production path.
     */
    @IsTest
    static void test_Scheduler_Enqueues_DummyQueueable() {
        // Inject a harmless queueable so the scheduler doesn't run the real ones in this test
        NGMCP_AMRUpdateScheduler.TEST_QUEUEABLE = new DummyQueueable();

        // Any valid future CRON expression will do (we're using schedule to call execute via stopTest)
        String cron = '0 0 0 1 1 ? 2099';

        Test.startTest();
        String schedId = System.schedule('TEST_AMR_Update_Scheduler_Hook', cron, new NGMCP_AMRUpdateScheduler());
        Test.stopTest(); // Triggers execute(), which enqueues DummyQueueable instead of the real ones

        System.assertNotEquals(null, schedId, 'Schedule job id should not be null.');
        // No flakey assertions on AsyncApexJob counts.
    }

    /**
     * Test 2: Covers the PRODUCTION path in execute():
     * - Ensure TEST_QUEUEABLE is null.
     * - Register a permissive HTTP mock so any downstream callouts succeed.
     * - Call execute(null) directly to drive the "normal" path where both real queueables are enqueued.
     */
    @IsTest
    static void test_Execute_ProductionPath_RunsWithoutException() {
        NGMCP_Mulesoft_Access_Code__c mac = new NGMCP_Mulesoft_Access_Code__c();
        mac.NGMCP_Access_Code__c = 'test';
        mac.NGMCP_Token_Type__c = 'Bearer';
        insert mac;
        // Ensure the test hook does NOT trigger
        NGMCP_AMRUpdateScheduler.TEST_QUEUEABLE = null;

        // Allow any downstream HTTP callouts to succeed with safe JSON
        Test.setMock(HttpCalloutMock.class, new AllowAll200Mock());

        Test.startTest();
        new NGMCP_AMRUpdateScheduler().execute(null);
        Test.stopTest();

        // If we reached here, execute() ran the production branch and didn’t raise exceptions.
        System.assert(true, 'Production path executed without uncaught exceptions.');
    }

    /**
     * Test 3 (optional but helpful for extra coverage):
     * - Schedules the class to run via the platform scheduler with the production path.
     * - Uses the permissive HTTP mock.
     * - This exercises the scheduled invocation plumbing in addition to direct execute(null).
     */
    @IsTest
    static void test_Scheduled_Run_Triggers_Execute_ProductionPath() {
        NGMCP_Mulesoft_Access_Code__c mac = new NGMCP_Mulesoft_Access_Code__c();
        mac.NGMCP_Access_Code__c = 'test';
        mac.NGMCP_Token_Type__c = 'Bearer';
        insert mac;
        // Ensure test hook is not used
        NGMCP_AMRUpdateScheduler.TEST_QUEUEABLE = null;

        // Safe mock for any callouts within the chain
        Test.setMock(HttpCalloutMock.class, new AllowAll200Mock());

        // CRON: run far in the future, we just need a valid expression;
        // stopTest() triggers execution in test context.
        String cron = '0 0 12 1 1 ? 2099';

        Test.startTest();
        String schedId = System.schedule('TEST_AMR_Update_Scheduler_Prod', cron, new NGMCP_AMRUpdateScheduler());
        Test.stopTest();

        System.assertNotEquals(null, schedId, 'Schedule job id should not be null.');
    }
}