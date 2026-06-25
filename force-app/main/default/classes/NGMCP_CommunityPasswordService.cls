public with sharing class NGMCP_CommunityPasswordService {
    @AuraEnabled
    public static Boolean sendResetFromSite(String username) {
        try {
            // Find the community user by Username. You might want to further restrict to Portal/Community users if needed.
            User u = [
                SELECT Id, Username, IsActive
                FROM User
                WHERE Username = :username WITH USER_MODE
                LIMIT 1
            ];

            if (!u.IsActive) {
                return false;
            }
            // Send the reset email = true
            System.resetPassword(u.Id, true);
            return true;
        } catch (QueryException qe) {
            return false;
        } catch (Exception ex) {
            return false;
        }
    }
}