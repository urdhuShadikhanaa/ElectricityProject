/**
 * @File Name : NGMCPPasswordlessLogin.cls
 * @Description :
 * @Author :
 * @Last Modified By :
 * @Last Modified On : December 4, 2025
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | December 4, 2025 |   | Initial Version
 **/

public without sharing class NGMCPPasswordlessLogin {
    
    @AuraEnabled
    public static String initiateLogin(String identifier, String authorizationMethod, String password){
        try{
            User userRecord;
            String response;
            if(identifier != null) {
                if(authorizationMethod == 'Email') {
                    if (String.isBlank(identifier) || String.isBlank(password)) {
                        return 'INVALID_PASSWORD';
                    }
                    // First validate Username + Password
                    Boolean isPasswordValid = validateUserPassword(identifier, password);
                    
                    if (!isPasswordValid) {
                        return 'INVALID_PASSWORD';
                    }
                    
                    userRecord = [SELECT Id , Name , Email , HasUserVerifiedPhone , HasUserVerifiedEmail FROM USER 
                                  WHERE Username=:identifier LIMIT 1];
                    if(userRecord.HasUserVerifiedEmail == TRUE) {
                        if (Test.isRunningTest()) {
                            response = 'TEST_PASSWORDLESS_TOKEN';
                        } else {
                            response = UserManagement.initPasswordlessLogin(userRecord.Id,Auth.VerificationMethod.Email);
                        }
                        return response;
                    } else {
                        // This will send a Welcome Email / Verification Email to Enable Passwordless for Email by sending an email
                        // in their registered email and User's have to click on the link from Email to Enable. Then they can do normal login again
                        if (!Test.isRunningTest()) {
                            Boolean sendEmail = UserManagement.sendAsyncEmailConfirmation(userRecord.Id, null, null, null);
                        }
                        return 'Email Sent , please click on link to enable passwordless login.';
                    }
                }                
            }
            return response;
        } catch(Exception e) {
            return 'Error ' + e.getMessage();
        }
    }
    
    @AuraEnabled
    public static String verifyPasswordlessLogin(String identifier , String otp, String authorizationMethod , String token){
        try{
            Auth.VerificationResult authResponse;
            User userRecord;
            System.PageReference pageRef ;
            String response;
            if(token != null) {
                if(authorizationMethod == 'Email') {
                    String communityPath = Label.NGMCP_CommunityPath;
                    userRecord = [SELECT Id , Name , Email , HasUserVerifiedPhone , HasUserVerifiedEmail FROM USER 
                                  WHERE Username=:identifier LIMIT 1];
                    authResponse = UserManagement.verifyPasswordlessLogin(userRecord.Id, Auth.VerificationMethod.EMAIL, token, otp, communityPath);
                    if (authResponse.success == TRUE && authResponse.redirect != null) {
                        pageRef = authResponse.redirect;
                        return authResponse.redirect.getUrl();
                    } else {
                        response = authResponse.message;
                        return 'Error: ' + authResponse.message;
                    }                    
                }
            }
            return response;
        } catch(Exception e) {
            return 'Error '+ e.getMessage();
        }
    }
    
    public static Boolean validateUserPassword(String username, String password) {
        if (Test.isRunningTest()) {
            return true;
        }
        try {
            ApexPages.PageReference loginResult = Site.login(username, password, null);
            return (loginResult != null);
        } catch (Exception e) {
            return false;
        }
    }
    
}