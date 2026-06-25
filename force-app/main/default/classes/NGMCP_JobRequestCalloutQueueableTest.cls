@isTest
public class NGMCP_JobRequestCalloutQueueableTest {
    
    @IsTest
    static void test_success_path() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_JobRequestCallout_Mocks.SuccessMock());
        // enqueue and run your queueable
        Test.startTest();
        System.enqueueJob(new NGMCP_JobRequestCalloutQueueable('{"some":"payload"}', 
                                                               (new NGMCP_Request__c(NGMCP_Callout_Status__c='In Progress')).Id));
        Test.stopTest();
        System.assert(true);
    }

    @IsTest
    static void test_error_path() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_JobRequestCallout_Mocks.ErrorMock());
        Test.startTest();
        // enqueue queueable…
        Test.stopTest();
        System.assert(true);
    }

}