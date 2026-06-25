global class FFADeleteIntefaceOldData implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        FFA_Integration_Limit__mdt maxFetchLimit=[Select MasterLabel,limit__c from FFA_Integration_Limit__mdt where MasterLabel=:'ScheduleBatchclassdataDeleteLimit' limit 1];
            final Integer BATCH_LIMIT;
            if(maxFetchLimit!=null){
                BATCH_LIMIT = integer.valueOf(maxFetchLimit.limit__c);
                System.debug(BATCH_LIMIT);
            }else{
                BATCH_LIMIT = 60;
            }
        Integer i=BATCH_LIMIT;    
        String query = 'Select Id,Transaction_Status__c,CreatedDate from FFA_Interface_Runs__c where (Transaction_Status__c=\'200\' OR Transaction_Status__c=\'Success\') AND CreatedDate <= LAST_N_DAYS:'+i+'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<FFA_Interface_Runs__c> scope){
        set<id> InterfaceRunIds=new set<id>();
        For(FFA_Interface_Runs__c IRuns: scope){
            InterfaceRunIds.add(IRuns.id);
        }
        List<ContentDocument> listFiles = new List<ContentDocument>();
            for (ContentDocumentLink cdl: [SELECT ContentDocumentId, Id, LinkedEntityId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =:InterfaceRunIds]) {
                listFiles.add(new ContentDocument(Id = cdl.ContentDocumentId));
            }
        IF(!listFiles.IsEmpty()){
            delete listFiles;
        }
        If(!scope.isEmpty()){
            delete scope;
        }
   }
    global void finish(Database.BatchableContext BC){  
    
    }
}