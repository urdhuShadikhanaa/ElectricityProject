public with sharing class NGMCP_BulkRequestBatch implements Database.Batchable<SObject>, Database.Stateful{
   
    private List<NGMCP_Bulk_Request__c> brList;
    private Set<Id> insertedIds = new Set<Id>();
    private Id user;
    private String mode;
    private String action;
   
    public NGMCP_BulkRequestBatch(List<NGMCP_Bulk_Request__c> brList, String action, String mode, Id user) {
        this.brList = brList;
        this.user = user;
        this.action = action;
        this.mode = mode;
    }
 
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Email FROM User WHERE Id = :user'); 
    }

    public void execute(Database.BatchableContext bc, List<SObject> dummyScope) {
        System.debug('brList: ' + brList);
        if (!brList.isEmpty()) {
             
            
            Database.SaveResult[] sr = Database.insert(brList, false);
            for (Integer i = 0; i < sr.size(); i++) {
                if (sr[i].isSuccess()) {
                    insertedIds.add(sr[i].getId());
                	System.debug('Inserted NGMCP_Bulk_Request__c: ' + insertedIds);
                } else {
                    System.debug('Error inserting NGMCP_Bulk_Request__c: ' + sr[i].getErrors()[0].getMessage());
                } 
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        
        if (insertedIds.isEmpty()) return;
        if(action == 'AMR'){
        	NGMCP_AMRBulkCreationBatch b2 = new NGMCP_AMRBulkCreationBatch(new List<Id>(insertedIds), action, mode, user);
            Database.executeBatch(b2, 25);
        }
        else{
           NGMCP_AppntDeappBulkCreationBatch b2 = new NGMCP_AppntDeappBulkCreationBatch(new List<Id>(insertedIds), action, mode, user); 
           Database.executeBatch(b2,90);
        }
        
        
    }




}