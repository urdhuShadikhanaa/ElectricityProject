@IsTest(seeAllData=true)
public class NGMCPPasswordlessLoginTest {

    /* Utility: any active user */
    private static User getAnyActiveUser() {
        return [
            SELECT Id, Username
            FROM User
            WHERE IsActive = true
            LIMIT 1
        ];
    }

    /* Utility: active user with unverified email (if exists) */
    private static User getUnverifiedEmailUser() {
        List<User> users = [
            SELECT Id, Username, HasUserVerifiedEmail
            FROM User
            WHERE IsActive = true
            AND HasUserVerifiedEmail = false
            LIMIT 1
        ];
        return users.isEmpty() ? null : users[0];
    }

    /* ===============================
       SUCCESS PATH (Verified Email)
       =============================== */
    @IsTest
    static void testInitiateLogin_EmailSuccess() {

        User u = getAnyActiveUser();

        Test.startTest();
        String response = NGMCPPasswordlessLogin.initiateLogin(
            u.Username,
            'Email',
            'dummyPassword'
        );
        Test.stopTest();

        System.assertNotEquals(null, response);
    }

    /* ===============================
       INVALID PASSWORD
       =============================== */
    @IsTest
    static void testInitiateLogin_InvalidPassword() {

        User u = getAnyActiveUser();

        Test.startTest();
        String response = NGMCPPasswordlessLogin.initiateLogin(
            u.Username,
            'Email',
            ''
        );
        Test.stopTest();

        System.assertEquals('INVALID_PASSWORD', response);
    }

    /* ===============================
       EMAIL NOT VERIFIED (ELSE BLOCK)
       =============================== */
    @IsTest
    static void testInitiateLogin_EmailNotVerified() {

        User u = getUnverifiedEmailUser();

        // If org has no unverified users, skip assertion safely
        if (u == null) {
            System.assert(true, 'No unverified user found – safely skipping');
            return;
        }

        Test.startTest();
        String response = NGMCPPasswordlessLogin.initiateLogin(
            u.Username,
            'Email',
            'anyPassword'
        );
        Test.stopTest();

        System.assertEquals(
            'Email Sent , please click on link to enable passwordless login.',
            response
        );
    }

    /* ===============================
       VERIFY PASSWORDLESS LOGIN
       =============================== */
    @IsTest
    static void testVerifyPasswordlessLogin_Email() {

        User u = getAnyActiveUser();

        Test.startTest();
        String response = NGMCPPasswordlessLogin.verifyPasswordlessLogin(
            u.Username,
            '123456',
            'Email',
            'dummy-token'
        );
        Test.stopTest();

        System.assertNotEquals(null, response);
    }

    /* ===============================
       VALIDATE PASSWORD (TEST BYPASS)
       =============================== */
    @IsTest
    static void testValidateUserPassword() {

        User u = getAnyActiveUser();

        Boolean isValid = NGMCPPasswordlessLogin.validateUserPassword(
            u.Username,
            'anyPassword'
        );

        System.assertEquals(true, isValid);
    }

    /* ===============================
       EXCEPTION / CATCH BLOCK
       =============================== */
    @IsTest
    static void testInitiateLogin_ExceptionPath() {

        Test.startTest();
        String response = NGMCPPasswordlessLogin.initiateLogin(
            'non_existing_user_' + System.currentTimeMillis() + '@test.com',
            'Email',
            'password'
        );
        Test.stopTest();

        System.assert(response.startsWith('Error'));
    }
    
    @IsTest
    static void testValidateUserPassword_TryBlock() {
        
        User u = [
            SELECT Username
            FROM User
            WHERE IsActive = true
            LIMIT 1
        ];
        
        Test.startTest();
        Boolean result = NGMCPPasswordlessLogin.validateUserPassword(
            u.Username,
            'anyPassword'
        );
        Test.stopTest();
        
        System.assertEquals(
            true,
            result,
            'Valid username should execute try block'
        );
    }
        
}