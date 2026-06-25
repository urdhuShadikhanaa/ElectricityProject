public without sharing class MFILoginController { 

    @AuraEnabled
    public static String initiateLogin(String email) {
        User user = [SELECT Id FROM User WHERE Email = :email AND IsPortalEnabled = true LIMIT 1];
        System.debug('user initiate login >>'+ user);
        if (user == null) {
            throw new AuraHandledException('User not found with the given email.');
        }
        return UserManagement.initPasswordlessLogin(
            user.Id, 
            Auth.VerificationMethod.EMAIL 
        );
    }

    @AuraEnabled
    public static String verifyLogin(String email, String identifier, String code) {
        User user = [SELECT Id FROM User WHERE Email = :email AND IsPortalEnabled = true LIMIT 1];
        System.debug('user verify login>>'+ user);
        if (user == null) {
            throw new AuraHandledException('User not found.');
        }
        Auth.VerificationResult result = UserManagement.verifyPasswordlessLogin(
            user.Id,
            Auth.VerificationMethod.EMAIL,
            identifier,
            code,
            '/home/'
        );
        return result.redirect.getUrl() ;
    }
}