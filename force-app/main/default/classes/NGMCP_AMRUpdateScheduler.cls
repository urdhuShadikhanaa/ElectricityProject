global with sharing class NGMCP_AMRUpdateScheduler implements Schedulable {

    //  Test hook used only by tests. If set during a test, we enqueue this instead of the real queueable.
    @TestVisible static System.Queueable TEST_QUEUEABLE;

    global void execute(SchedulableContext sc) {
        // In tests, if a dummy/stub queueable is provided, enqueue that and return.
        if (Test.isRunningTest() && TEST_QUEUEABLE != null) {
            System.enqueueJob(TEST_QUEUEABLE);
            return;
        }

        // Production / normal path (unchanged)
        System.enqueueJob(new NGMCP_AMRUpdateQueueable());
        System.enqueueJob(new NGMCP_AMRCWRQueuable());
    }
}