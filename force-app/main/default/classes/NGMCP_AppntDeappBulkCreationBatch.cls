public with sharing class NGMCP_AppntDeappBulkCreationBatch
    implements Database.Batchable<SObject>, Database.Stateful {

    private List<Id> brIds;
    private String action;
    private String mode;
    private Id userId;

    public NGMCP_AppntDeappBulkCreationBatch(
        List<Id> brIds, String action, String mode, Id userId
    ) {
        this.brIds = brIds;
        this.action = action;
        this.mode = mode;
        this.userId = userId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id
            FROM NGMCP_Bulk_Request__c
            WHERE Id IN :brIds
            with user_mode
            ORDER BY CreatedDate ASC
        ]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        if (!Test.isRunningTest()) {
            System.enqueueJob(
                new NGMCP_AppntDeappQueueable(
                    brIds, 0, action, mode, userId
                )
            );
        }
    }

    public void finish(Database.BatchableContext bc) {}
}