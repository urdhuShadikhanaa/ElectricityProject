public with sharing class NGMCP_AMRUpdateQueueable implements Queueable, Database.AllowsCallouts {

    public void execute(QueueableContext qc) {
        List<NGMCP_AMRClass.ObjListClass> records;
        try {
            records = NGMCP_AMRUpdateClass.fetchAMRRecords();
        } catch (NGMCP_AMRUpdateClass.CalloutException e) {
            return;
        }

        // SAFE FIX – does NOT affect functionality
        if (records == null) {
            records = new List<NGMCP_AMRClass.ObjListClass>();
        }

        Integer scopeSize = 200;
        Database.executeBatch(new NGMCP_AMRUpdateBatch(records), scopeSize);
    }
}