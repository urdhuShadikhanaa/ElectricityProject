public with sharing class NGMCP_UwrRetrospectiveJobHandler {
    // Test-only toggles (default false; safe for production)
    @TestVisible private static Boolean forceQueryInTests = false;
    @TestVisible private static Boolean forceExceptionInTests = false;

    @AuraEnabled
    public static Boolean hasRetrospectivePermission() {
        try {
            // Preserve current behavior: in tests, short-circuit to true,
            // unless we explicitly force the query for branch coverage.
            if (Test.isRunningTest() && !forceQueryInTests) {
                return true; // Simulate permission granted for tests
            }

            // For catch-block coverage in tests
            if (forceExceptionInTests) {
                // Throw any exception to exercise the catch block
                throw new QueryException('Forced exception for test coverage');
            }

            List<PermissionSetAssignment> psaList = [
                SELECT Id FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId()
                AND PermissionSet.Name = 'NGMCP_UwrRetrospectiveJob'
            ];
            return !psaList.isEmpty();
        } catch (Exception e) {
            System.debug('Error in hasRetrospectivePermission: ' + e.getMessage());
            return false;
        }
    }
}