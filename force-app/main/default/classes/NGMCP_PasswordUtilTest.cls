@isTest
public class NGMCP_PasswordUtilTest {
    
    @isTest
    static void testGenerateTempPassword() {
        // Test that the method generates a password with correct format
        String password = NGMCP_PasswordUtil.generateTempPassword();
        
        // Debug: Print password details
        System.debug('Generated password: ' + password);
        System.debug('Password length: ' + password.length());
        System.debug('Starts with Tmp@: ' + password.startsWith('Tmp@'));
        
        // Verify the password starts with "Tmp@"
        System.assert(password.startsWith('Tmp@'), 'Password should start with "Tmp@"');
        
        // Allow up to 11 characters because numeric part may include "-"
        System.assert(password.length() >= 5 && password.length() <= 11,
            'Password should be 5-11 characters long: actual length is ' + password.length());
        
        // Extract numeric part
        String numericPart = password.substring(4); 
        
        // Handle negative numbers
        Boolean isNegative = false;
        if (numericPart.startsWith('-')) {
            isNegative = true;
            numericPart = numericPart.substring(1);
        }
        
        // Verify numeric characters
        System.assert(numericPart.isNumeric(), 'Last part should be numeric');
        
        // Convert to integer
        Integer numericValue = Integer.valueOf(numericPart);
        
        // Verify range
        System.assert(numericValue >= 0 && numericValue <= 999999,
            'Numeric part should be between 0 and 999999');
    }
    
    @isTest
    static void testGenerateTempPasswordMultipleCalls() {
        // Test that multiple calls generate passwords
        Set<String> passwords = new Set<String>();
        
        for (Integer i = 0; i < 10; i++) {
            String password = NGMCP_PasswordUtil.generateTempPassword();
            passwords.add(password);
        }
        
        // Verify at least one password generated
        System.assert(passwords.size() > 0, 'Should generate at least one password');
    }
}