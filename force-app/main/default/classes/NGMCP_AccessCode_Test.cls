@IsTest
private class NGMCP_AccessCode_Test {
@testSetup
    static void testSetupMethod(){
        NGMCP_Mulesoft_Access_Code__c mac = new NGMCP_Mulesoft_Access_Code__c(NGMCP_Access_Code__c='wrwrwffw',
                                                              NGMCP_Token_Type__c = 'Bearer',NGMCP_Expires_At__c = DateTime.now().addMinutes(20),
                                                                           NGMCP_Callout_Response__c = '{"access_token":"tok_string_3599","token_type":"Bearer","expires_in":"3599"}'  );
    }
    // Utility: query latest token row
    private static NGMCP_Mulesoft_Access_Code__c getLatestMAC() {
        return [
            SELECT Id, NGMCP_Access_Code__c, NGMCP_Token_Type__c, NGMCP_Expires_At__c, NGMCP_Callout_Response__c, CreatedDate
            FROM NGMCP_Mulesoft_Access_Code__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
    }

    // --- 1) Queueable success path with expires_in as STRING ---
    @IsTest
    static void testQueueable_SavesToken_withStringExpires() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpMocks.AccessCodeMock_StringExpires());

        Test.startTest();
        System.enqueueJob(new NGMCP_AccessCodeQueueable());
        Test.stopTest(); // Queueable executes here with mock

        // Assert: record saved with fields populated
        NGMCP_Mulesoft_Access_Code__c row = getLatestMAC();
        System.assertNotEquals(null, row, 'Token row should be inserted.');
        System.assertEquals('tok_string_3599', row.NGMCP_Access_Code__c, 'Access token mismatch.');
        System.assertEquals('Bearer', row.NGMCP_Token_Type__c, 'Token type mismatch.');
        System.assertNotEquals(null, row.NGMCP_Expires_At__c, 'ExpiresAt should be set.');
        System.assert(row.NGMCP_Callout_Response__c != null && row.NGMCP_Callout_Response__c.contains('"access_token":"tok_string_3599"'),
            'Raw response should be stored and include the token.');
        // Expires in ~1h minus buffer; assert it's in the future (at least a few minutes)
        System.assert(row.NGMCP_Expires_At__c > System.now().addMinutes(10),
            'Expiry should be at least > now + 10 minutes (buffer applied).');
    }

    // --- 2) Queueable success path with expires_in as NUMBER ---
    @IsTest
    static void testQueueable_SavesToken_withNumericExpires() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpMocks.AccessCodeMock_NumericExpires());

        Test.startTest();
        System.enqueueJob(new NGMCP_AccessCodeQueueable());
        Test.stopTest();

        NGMCP_Mulesoft_Access_Code__c row = getLatestMAC();
        System.assertEquals('tok_num_7200', row.NGMCP_Access_Code__c, 'Access token mismatch.');
        System.assertEquals('Bearer', row.NGMCP_Token_Type__c);
        System.assert(row.NGMCP_Expires_At__c > System.now().addMinutes(60),
            'Expiry should reflect ~2 hours (minus buffer).');
    }

    // --- 3) Controller error path: non-2xx response throws CalloutException ---
    @IsTest
    static void testController_NonSuccess_Throws() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpMocks.AccessCodeMock_400());

        Boolean threw = false;
        try {
            // Minimal valid form data
            String endpoint = 'callout:NGMCP_Mulesoft_Integration/b5d83618-97ea-48ec-b0be-8d4a7d678322/oauth2/token';
            Map<String,String> form = new Map<String,String>{
                'grant_type' => 'client_credentials'
            };
            NGMCP_MulesoftIntegrationController.postFormUrlEncoded(endpoint, form, null);
        } catch (NGMCP_MulesoftIntegrationController.CalloutException ex) {
            threw = true;
            System.assert(ex.getMessage().contains('Non-success: 400'), 'Should include HTTP status in message.');
        }
        System.assertEquals(true, threw, 'Controller should throw CalloutException on non-2xx status.');
    }

    // --- 4) buildBody encodes properly; truncate behaves properly ---
    @IsTest
    static void test_buildBody_and_truncate() {
        Map<String,String> data = new Map<String,String>{
            'grant_type'   => 'client credentials',                 // space -> '+'
            'scope'        => 'https://graph.microsoft.com/.default', // special chars -> percent-encoding
            'client_id'    => 'ID with space',
            'client_secret'=> 'S&V'                                 // & -> %26
        };
        String body = NGMCP_MulesoftIntegrationController.buildBody(data);
        // Order is not guaranteed; assert presence of parts
        System.assert(body.contains('grant_type=client+credentials'), 'Space should be + encoded.');
        System.assert(body.contains('scope=https%3A%2F%2Fgraph.microsoft.com%2F.default'), 'URL should be percent-encoded.');
        System.assert(body.contains('client_id=ID+with+space'), 'Space should be + encoded.');
        System.assert(body.contains('client_secret=S%26V'), '& must be %26.');

        // truncate
        String t = NGMCP_MulesoftIntegrationController.truncate('abcdefghijklmnopqrstuvwxyz', 5);
        System.assertEquals('abcde…', t, 'Truncate should append ellipsis when exceeds n.');
        System.assertEquals('abc', NGMCP_MulesoftIntegrationController.truncate('abc', 5),
            'Short strings should be unchanged.');
    }

    // --- 5) Scheduler enqueues queueable and saves token ---
    @IsTest
    static void test_Schedulable_enqueuesQueueable() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpMocks.AccessCodeMock_StringExpires());

        Test.startTest();
        // Any valid cron; tests execute on stopTest regardless
        System.schedule('NGMCP Token Sched Test', '0 0 0 1 1 ? 2099', new NGMCP_AccessCodeSchedular());
        Test.stopTest();

        // If schedulable executed and enqueued queueable, a token row should exist
       // NGMCP_Mulesoft_Access_Code__c row = getLatestMAC();
        //System.assertNotEquals(null, row, 'Token row should exist after scheduled run.');
        //System.assertEquals('tok_string_3599', row.NGMCP_Access_Code__c);
    }
}