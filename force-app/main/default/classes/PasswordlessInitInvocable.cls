public with sharing class PasswordlessInitInvocable {
    /**
     * Invocable action to call System.UserManagement.initPasswordlessLogin(username, EMAIL)
     * Returns an identifier in the result for use in verification.
     */

    public class InitReq {
        @InvocableVariable(required=true)
        public String username;
    }

    public class InitRes {
        @InvocableVariable
        public String username;
        @InvocableVariable
        public Boolean success;
        @InvocableVariable
        public String identifier;
        @InvocableVariable
        public String message;
    }

    @InvocableMethod(label='Init Passwordless Login' description='Init passwordless login (send OTP/magic link) for a username')
    public static List<InitRes> invokeInit(List<InitReq> requests) {
        List<InitRes> out = new List<InitRes>();
        if (requests == null) return out;

        for (InitReq r : requests) {
            InitRes res = new InitRes();
            res.username = r.username;
            try {
                // Call init by username (supported in most orgs)
                String identifier = System.UserManagement.initPasswordlessLogin(r.username, Auth.VerificationMethod.EMAIL);
                res.success = true;
                res.identifier = identifier;
                res.message = 'INIT_OK';
            } catch (Exception ex) {
                res.success = false;
                res.identifier = null;
                res.message = 'INIT_FAILED: ' + ex.getMessage();
            }
            out.add(res);
        }
        return out;
    }
}