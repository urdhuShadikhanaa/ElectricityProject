public class FFAFailedJobsDMLOperation {
    
    
    public static void doDmlOperation(list<WorkOrder> FailedWorkorders,list<FFA_Interface_Runs__c> FFAInterfaceRuns,List<FFA_Interface_Runs__c> newFFAInterfaceRuns ){
         if(!FailedWorkorders.isEmpty()){
                update FailedWorkorders;
         } 
         IF(!FFAInterfaceRuns.isEmpty()){
            Update FFAInterfaceRuns;
         }  
         IF(!newFFAInterfaceRuns.isEmpty()){
             insert newFFAInterfaceRuns;
         }   
         }                            
    }