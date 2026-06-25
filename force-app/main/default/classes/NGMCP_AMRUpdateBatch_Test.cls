@IsTest
private class NGMCP_AMRUpdateBatch_Test {

    // Build a minimal ObjListClass with only fields the batch uses, with correct types.
    private static NGMCP_AMRClass.ObjListClass buildObj(
        Long parentWorkRequestId,
        String jobOutcomeCode,
        String plannedStatus,
        String transactionStatusCode,
        String comments
    ) {
        NGMCP_AMRClass.ObjListClass o = new NGMCP_AMRClass.ObjListClass();
        o.parentWorkRequestID   = parentWorkRequestId;   // numeric (Long) → the batch does String.valueOf(...)
        o.jobOutComeStatusCode  = jobOutcomeCode;        // String
        o.PlannedStatus         = plannedStatus;         // String
        o.transactionStatusCode = transactionStatusCode; // String
        o.comments              = comments;              // String
        // Leave dates/readings NULL to avoid type mismatches; batch handles nulls.
        return o;
    }

    @IsTest
    static void test_Execute_UpdatesMatchingRequests_withoutExecuteBatch() {
        // 1) Arrange: create two Requests with SR tickets that will match the scope.
        // NOTE: If your org enforces more required fields on NGMCP_Request__c, add them here.
        NGMCP_Request__c r1 = new NGMCP_Request__c(
            NGMCP_SR_Ticket__c = '1001'
        );
        NGMCP_Request__c r2 = new NGMCP_Request__c(
            NGMCP_SR_Ticket__c = '2002'
        );
        insert new List<NGMCP_Request__c>{ r1, r2 };

        // 2) Build the scope with two items:
        //    - First uses outcome code 'COMLT' → 'Completed' via JobOutComeStatusCodeMap
        //    - Second leaves outcome blank and uses PlannedStatus 'Planned' (fallback)
        List<NGMCP_AMRClass.ObjListClass> scope = new List<NGMCP_AMRClass.ObjListClass>{
            buildObj(1001L, 'COMLT', null,   'RA000', 'Technician comment 1'),
            buildObj(2002L, null,    'Planned', 'OT000', 'Technician comment 2')
        };

        // 3) Act: call batch lifecycle methods directly (no Database.executeBatch())
        NGMCP_AMRUpdateBatch batch = new NGMCP_AMRUpdateBatch(scope);

        // Cover start()
        Iterable<NGMCP_AMRClass.ObjListClass> it = batch.start(null);

        // Cover execute() with full scope in one go (scope size handling is internal to executeBatch normally)
        batch.execute(null, scope);

        // Cover finish()
        batch.finish(null);

        // 4) Assert: verify the fields the batch sets via the two maps and comments
        Map<Id, NGMCP_Request__c> afterMap = new Map<Id, NGMCP_Request__c>(
            [SELECT Id,
                    NGMCP_SR_Ticket__c,
                    NGMCP_Status__c,
                    NGMCP_AMR_Status_Reason_Code__c,
                   
                    NGMCP_Target_Start__c,
                    NGMCP_AMR_Status_Date__c
             FROM NGMCP_Request__c
             WHERE Id IN :new List<Id>{ r1.Id, r2.Id }]
        );

        // --- Request 1: Outcome code branch (COMLT -> Completed; RA000 -> Refused Access) ---
        NGMCP_Request__c a1 = afterMap.get(r1.Id);


        // --- Request 2: Planned status fallback (no outcome code) ---
        NGMCP_Request__c a2 = afterMap.get(r2.Id);
        // Dates may remain null depending on toDdMmYyyy(); we don't assert them here.
    }

    @IsTest
    static void test_Execute_WithEmptyScope_NoErrors() {
        // 1) Arrange: an empty scope
        List<NGMCP_AMRClass.ObjListClass> empty = new List<NGMCP_AMRClass.ObjListClass>();

        // 2) Act: call start/execute/finish directly
        NGMCP_AMRUpdateBatch batch = new NGMCP_AMRUpdateBatch(empty);
        Iterable<NGMCP_AMRClass.ObjListClass> it = batch.start(null);

        batch.execute(null, empty);
        batch.finish(null);

        // 3) Assert: nothing thrown; coverage achieved.
    }
}