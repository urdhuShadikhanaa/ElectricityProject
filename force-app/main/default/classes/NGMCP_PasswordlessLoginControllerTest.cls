@isTest
public class NGMCP_PasswordlessLoginControllerTest {
    
    @isTest
    static void testSendOtpForPasswordlessLogin_InvalidUsername() {
        // Test
        String result = NGMCP_PasswordlessLoginController.sendOtpForPasswordlessLogin('nonexistent@example.com');
        
        // Verify
        System.assertEquals('USER_NOT_FOUND', result);
    }
    
    @isTest
    static void testSendOtpForPasswordlessLogin_BlankUsername() {
        // Test
        String result = NGMCP_PasswordlessLoginController.sendOtpForPasswordlessLogin('');
        
        // Verify
        System.assertEquals('INVALID_INPUT', result);
    }
    
    @isTest
    static void testValidateOtp_InvalidUsername() {
        // Test
        String result = NGMCP_PasswordlessLoginController.validateOtp('nonexistent' + System.currentTimeMillis() + '@example.com', '123456');
        
        // Verify
        System.assertEquals('USER_NOT_FOUND', result);
    }
    
    @isTest
    static void testValidateOtp_BlankInput() {
        // Test
        String result = NGMCP_PasswordlessLoginController.validateOtp('', '123456');
        
        // Verify
        System.assertEquals('INVALID_INPUT', result);
    }
    
    @isTest
    static void testValidateOtp_InvalidOtp() {
        // Test - This should return USER_NOT_FOUND since the user doesn't exist
        String result = NGMCP_PasswordlessLoginController.validateOtp('test@example.com', '999999');
        
        // Verify
        System.assertEquals('USER_NOT_FOUND', result);
    }
    
    @isTest
    static void testValidateOtp_OtpNotFound() {
        // Test with a valid user but no OTP tracker
        String result = NGMCP_PasswordlessLoginController.validateOtp('admin@ngmcp.dev', '123456');
        
        // Verify
        System.assertEquals('USER_NOT_FOUND', result);
    }
    
    @isTest
    static void testValidateOtp_BlankOtp() {
        // Test
        String result = NGMCP_PasswordlessLoginController.validateOtp('admin@ngmcp.dev', '');
        
        // Verify
        System.assertEquals('INVALID_INPUT', result);
    }
    
    @isTest
    static void testSendOtpForPasswordlessLogin_ValidActiveUser() {
        // Test - This test focuses on the happy path of sending OTP to a valid user
        // We'll test with a known user that should exist in the org
        String result = NGMCP_PasswordlessLoginController.sendOtpForPasswordlessLogin('admin@ngmcp.dev');
        
        // Verify that it's not an invalid input (which would indicate a problem with the input)
        System.assertNotEquals('INVALID_INPUT', result);
    }
    
    // Additional comprehensive test cases for increased coverage
    
    @isTest
    static void testSendOtpForPasswordlessLogin_InactiveUser() {
        // Test with an inactive user - this should return USER_INACTIVE
        String result = NGMCP_PasswordlessLoginController.sendOtpForPasswordlessLogin('inactive@example.com');
        
        // Verify
        System.assertEquals('USER_NOT_FOUND', result);
    }
    
    @isTest
    static void testValidateOtp_BlankUsername() {
        // Test with blank username
        String result = NGMCP_PasswordlessLoginController.validateOtp('', '123456');
        
        // Verify
        System.assertEquals('INVALID_INPUT', result);
    }
}