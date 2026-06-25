@isTest
private class NGMCP_AccessCodeQueueableTest {

    /**
     * ✅ Positive path – executes Queueable + Callout
     */
    @isTest
    static void testQueueableExecuteSuccess() {

        // Register HTTP Mock
        Test.setMock(HttpCalloutMock.class, new NGMCP_AccessTokenHttpMock());

        Test.startTest();
        System.enqueueJob(new NGMCP_AccessCodeQueueable());
        Test.stopTest();

        // ✅ Verify a Custom Setting record was created/updated
        List<NGMCP_Mulesoft_Access_Code__c> records =
            [SELECT Id FROM NGMCP_Mulesoft_Access_Code__c];

        System.assert(
            records.size() > 0,
            'Access token custom setting should be created'
        );
    }

    /**
     * ✅ Exception path – missing access_token
     */
    @isTest
    static void testQueueableExecuteMissingAccessToken() {

        Test.setMock(HttpCalloutMock.class, new NGMCP_AccessTokenHttpMock_NoToken());

        Test.startTest();
        try {
            System.enqueueJob(new NGMCP_AccessCodeQueueable());
            Test.stopTest();
            System.assert(false, 'Exception should have been thrown');
        } catch (Exception ex) {
            System.assert(
                ex.getMessage().contains('access_token'),
                'Expected access token missing exception'
            );
        }
    }

    /**
     * ✅ Instantiation coverage
     */
    @isTest
    static void testQueueableInstantiation() {
        NGMCP_AccessCodeQueueable q = new NGMCP_AccessCodeQueueable();
        System.assertNotEquals(null, q);
    }
}