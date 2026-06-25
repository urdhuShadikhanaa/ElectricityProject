@IsTest
private class NGMCP_UwrRetrospectiveJobHandler_Tests {
    // Helper to create a user for realistic runAs context
    private static User makeUser(String unamePrefix, String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        return new User(
            Alias = (unamePrefix.length() >= 5 ? unamePrefix.substring(0,5) : unamePrefix) ,
            Email = unamePrefix + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = unamePrefix + '+' + System.currentTimeMillis() + '@example.com',
            ProfileId = p.Id
        );
    }

    @IsTest
    static void defaultBypass_returnsTrue_dueToTestContext() {
        // Covers the try block + early-return path
        User u = makeUser('uwr_def', 'Standard User');
        System.runAs(u) {
            // Ensure default flags (early return)
            NGMCP_UwrRetrospectiveJobHandler.forceQueryInTests = false;
            NGMCP_UwrRetrospectiveJobHandler.forceExceptionInTests = false;

            Test.startTest();
            Boolean result = NGMCP_UwrRetrospectiveJobHandler.hasRetrospectivePermission();
            Test.stopTest();

            System.assertEquals(true, result,
                'In test context and without forcing query, method should return true.');
        }
    }

    @IsTest
    static void queryBranch_returnsFalse_whenNoPermissionSetAssignment() {
        // Drives the SOQL path (without relying on org data)
        User u = makeUser('uwr_qry', 'Standard User');
        System.runAs(u) {
            NGMCP_UwrRetrospectiveJobHandler.forceQueryInTests = true;
            NGMCP_UwrRetrospectiveJobHandler.forceExceptionInTests = false;

            Test.startTest();
            Boolean result = NGMCP_UwrRetrospectiveJobHandler.hasRetrospectivePermission();
            Test.stopTest();

            // No PSA created in test DB, so list is empty => false
            System.assertEquals(false, result,
                'Without a PSA, query branch should return false.');
        }
        // Clean up flags
        NGMCP_UwrRetrospectiveJobHandler.forceQueryInTests = false;
        NGMCP_UwrRetrospectiveJobHandler.forceExceptionInTests = false;
    }

    @IsTest
    static void catchBlock_returnsFalse_whenForcedException() {
        // Exercises the catch block deterministically
        User admin = makeUser('uwr_err', 'System Administrator');
        System.runAs(admin) {
            NGMCP_UwrRetrospectiveJobHandler.forceQueryInTests = true;
            NGMCP_UwrRetrospectiveJobHandler.forceExceptionInTests = true;

            Test.startTest();
            Boolean result = NGMCP_UwrRetrospectiveJobHandler.hasRetrospectivePermission();
            Test.stopTest();

            System.assertEquals(false, result,
                'Forced exception should trigger catch block returning false.');
        }
        // Reset flags to avoid side effects
        NGMCP_UwrRetrospectiveJobHandler.forceQueryInTests = false;
        NGMCP_UwrRetrospectiveJobHandler.forceExceptionInTests = false;
    }
}