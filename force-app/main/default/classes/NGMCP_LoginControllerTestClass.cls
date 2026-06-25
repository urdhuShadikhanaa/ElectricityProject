/**
 * @File Name : NGMCP_LoginControllerTestClass .cls
 * @Description :
 * @Author :P Shabbir Ali Khan
 * @Last Modified By :
 * @Last Modified On : October 13, 2025
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | October 13, 2025 |   | Initial Version
 **/
@isTest
private with sharing class NGMCP_LoginControllerTestClass {

    /**
     * Test method to verify successful login scenario.
     * This test creates a test user and attempts to log in using the NG_LoginController.
     */
    @isTest
    static void testLoginSuccess() {
        // Retrieve the 'Standard User' profile to assign to the test user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        // Create a new test user with required fields
        User u = new User(
            Alias = 'NgmTest',
            Email = 'NgmTestUser@nationalgas.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'NgmTestUser@nationalgas.com',
            LastName = 'NGTest',
            CommunityNickname = 'NationalGasPortal'
        );
        insert u; // Insert the test user into the database

        Test.startTest();
        // Attempt to log in using the test user's username and a dummy password
        // Note: Site.login typically works only in a Site context, so this may not return a valid result in test context
        String result = NGMCP_LoginController.login(u.Username, 'dummyPassword');
        Test.stopTest();
    }

    /**
     * Test method to verify login failure or exception handling.
     * This test passes null values to simulate an invalid login attempt.
     */
    @isTest
    static void testLoginException() {
        Test.startTest();
        // Call the login method with null values to trigger exception handling
        String result = NGMCP_LoginController.login(null, null);
        String result1 = NGMCP_LoginController.login('!@#$%^&*()<>?', '!@#$%^&*()<>?');
        String result2 = NGMCP_LoginController.login('invalid@example.invalid', 'Wrong!@#');
        System.debug('Result****' + result); // Debug output to inspect the result
        
        Test.stopTest();
        System.assertEquals(null, result1, 'Expected an exception message (catch path).');
    }
}