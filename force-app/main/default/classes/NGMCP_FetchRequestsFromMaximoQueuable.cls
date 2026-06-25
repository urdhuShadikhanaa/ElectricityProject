public with sharing class NGMCP_FetchRequestsFromMaximoQueuable implements Queueable,
Database.AllowsCallouts{
    public void execute(QueueableContext qc) {
        List<NGMCP_RequestClass.MemberClass> records;
        try {
            records = NGMCP_GetRequestClass.fetchRequestRecords();
        } catch (NGMCP_GetRequestClass.CalloutException e) {
            System.debug('External call failed: ' + e.getMessage() + ' @line: ' + e.getLineNumber());
            return;
        }

        // 2) Kick off batch to update SF
        Integer scopeSize = 200; // adjust if needed
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(records), scopeSize);
    }

    
}