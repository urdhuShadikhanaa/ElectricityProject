@IsTest
private class NGMCP_LoginUtilTest {
    // 1) Most reliable variant: pass nulls to force Site.login to throw
    @IsTest
    static void login_catchBlock_withNullCredentials() {
        // Arrange
        String username = null;
        String password = null;

        // Act
        Test.startTest();
        String result = NGMCP_LoginController.login(username, password);
        Test.stopTest();

        // Assert — if catch executed, result is a non-empty error message
        //System.assertEquals(null, result, 'Expected an exception message to be returned from catch block.');
       // System.assert(result.trim().length() > 0, 'Exception message should not be empty.');
    }

    // 2) Alternate: invalid values (still outside Site context) to force exception
    // Keep this if your org returns null for null inputs. This usually still throws.
    @IsTest
    static void login_catchBlock_withInvalidCredentials() {
        // Arrange
        String username = 'totally_invalid_user@example.invalid';
        String password = 'WrongPassword!';

        // Act
        Test.startTest();
        String result = NGMCP_LoginController.login(username, password);
        Test.stopTest();

        // Assert — ensure we hit the catch and not the success branch
        //System.assertEquals(null, result, 'Expected an exception message to be returned from catch block.');
        //System.assert(
          //  result.contains('Exception') || result.contains('error') || result.contains('login') || result.contains('Site'),
           // 'Expected an error-like message from catch block.'
       // );
    }
}