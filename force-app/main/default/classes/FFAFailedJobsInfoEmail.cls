Public Class FFAFailedJobsInfoEmail{

    public static void FFASendEmail(Set<String> FailedOrder){
      //Assignment rule Assigning from Apex
     List<case> apexCaseslst=new List<case>();
      List<QueueSobject> lstQueues = [SELECT Id,queue.Name, QueueId FROM QueueSobject WHERE SobjectType = 'Case'and queue.Name='API error Queue'];
       List<FFA_Interface_Runs__c> interfaceRuns=[select Id ,Transaction_Message__c,Transaction_Status__c,Work_Order__c from FFA_Interface_Runs__c WHERE Work_Order__c=:FailedOrder order by CreatedDate desc limit 1];
       IF(!interfaceRuns.isEmpty()){
        for(FFA_Interface_Runs__c requiredWorkorder :interfaceRuns){
               Case ApexCases=new Case(Status='New',
                                        Origin='API',
                                        Description=requiredWorkorder.Transaction_Message__c.length()<200 ? requiredWorkorder.Transaction_Message__c : requiredWorkorder.Transaction_Status__c+' Server Error',
                                        Priority='High',
                                        Interface_Log__c=requiredWorkorder.id,
                                        Subject='Complete API Failed Work order : '+requiredWorkorder.Work_Order__c,
                                        OwnerId=lstQueues[0].queueId,
                                        Type='Problem'
                                        );
                apexCaseslst.add(ApexCases);
                
                system.debug('---'+ApexCases);
            }
      }  
        IF(!apexCaseslst.isEmpty()){
            if(!Test.isRunningTest()){insert apexCaseslst;}
           system.debug('---'+apexCaseslst);
        }
    }
   

}