@isTest
private class NGMCP_gdprMessageTest {
    @isTest
    static void testGetGdprMessage() {
        Test.startTest();
        String result = NGMCP_gdprMessage.getConsentMessage();
        Test.stopTest();

        String expectedMessage = 'Please tick here to confirm that consent has been obtained from the named individual for their personal data to be passed to third parties, for the purposes of performing the specified works, by means of a suitable Data Privacy Notice and explicit consent agreement.';
        
        System.assertEquals(expectedMessage, result, 'Unexpected GDPR message');
    }
}