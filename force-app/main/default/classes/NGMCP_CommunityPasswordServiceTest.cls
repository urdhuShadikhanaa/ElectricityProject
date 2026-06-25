@IsTest
private class NGMCP_CommunityPasswordServiceTest {
    // Utility: create a unique internal user (active by default)
    private static User createUser(Boolean isActive) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String suffix = String.valueOf(DateTime.now().getTime()) + Math.mod(Crypto.getRandomInteger(), 100000);
        User u = new User(
            FirstName         = 'Test',
            LastName          = 'ResetPwd',
            Alias             = ('tr' + suffix).substring(0, 8),
            Email             = 'reset+' + suffix + '@example.com',
            Username          = 'reset+' + suffix + '@example.com',
            TimeZoneSidKey    = 'Asia/Kolkata',
            LocaleSidKey      = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey  = 'UTF-8',
            ProfileId         = p.Id,
            IsActive          = isActive
            // If your org requires additional fields on User, add them here.
            // Example: CompanyName, FederationIdentifier, etc.
        );
        insert u;
        return u;
    }

    @IsTest
    static void test_sendResetFromSite_activeUser_returnsTrue() {
        // Arrange: create an active user
        User u = createUser(true);

        Test.startTest();
        Boolean result = NGMCP_CommunityPasswordService.sendResetFromSite(u.Username);
        Test.stopTest();

        System.assertEquals(true, result, 'Active user should return true after resetPassword call.');
    }

    @IsTest
    static void test_sendResetFromSite_inactiveUser_returnsFalse() {
        // Arrange: create an inactive user
        User u = createUser(false);

        Test.startTest();
        Boolean result = NGMCP_CommunityPasswordService.sendResetFromSite(u.Username);
        Test.stopTest();

        System.assertEquals(false, result, 'Inactive user should return false and skip resetPassword.');
    }

    @IsTest
    static void test_sendResetFromSite_userNotFound_returnsFalse() {
        // Arrange: clearly non-existent username
        String nonexistentUsername = 'does.not.exist+' + DateTime.now().getTime() + '@example.com';

        Test.startTest();
        Boolean result = NGMCP_CommunityPasswordService.sendResetFromSite(nonexistentUsername);
        Test.stopTest();

        System.assertEquals(false, result, 'Non-existent user should return false (QueryException handled).');
    }
}