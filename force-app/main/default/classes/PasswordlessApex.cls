public with sharing class PasswordlessApex {
    @AuraEnabled
    public static String verifyPwlessAndGetRedirect(Id userId, String identifier, String code, String startUrl) {
        try {
            // Call Salesforce passwordless verification API
            Auth.VerificationResult vr = System.UserManagement.verifyPasswordlessLogin(
                userId,
                Auth.VerificationMethod.EMAIL,
                identifier,
                code,
                startUrl
            );

            // vr has public fields: success (Boolean), redirect (PageReference), message (String)
            if (vr == null) {
                return 'ERROR: No verification result returned';
            }

            if (vr.success == true) {
                // If a PageReference (redirect) is present, return its URL; otherwise return startUrl or success flag
                if (vr.redirect != null) {
                    return vr.redirect.getUrl();
                } else if (!String.isBlank(startUrl)) {
                    return startUrl;
                } else {
                    return '/s/'; // fallback to site root
                }
            } else {
                // verification failed — return message for UI
                String msg = vr.message != null ? vr.message : 'Verification failed';
                return 'VERIFY_FAILED:' + msg;
            }
        } catch (Exception ex) {
            // Bubble up a clear message to the client
            throw new AuraHandledException('VERIFY_ERROR: ' + ex.getMessage());
        }
    }
}