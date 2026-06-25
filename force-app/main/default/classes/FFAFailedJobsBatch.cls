global class FFAFailedJobsBatch implements Database.Batchable<sObject>,   Database.AllowsCallouts {

global Database.QueryLocator start(Database.BatchableContext BC){
        string InterfaceName = '/FFACompleteInterface';
        String query = 'Select Id,Interface_Name__c,Transaction_Status__c,Work_Order__c,Transaction_Message__c,FFA_Re_Triggered__c,CreatedDate from FFA_Interface_Runs__c where (Interface_Name__c LIKE \'%'+InterfaceName+'%\') AND (Transaction_Status__c >= \'500\' AND Transaction_Status__c <= \'510\') AND FFA_Re_Triggered__c=False';
        system.debug('query : - '+query);
        return Database.getQueryLocator(query);
     }

     global void execute(Database.BatchableContext BC, List<FFA_Interface_Runs__c> scope){
         String WONUMBER;
         List<FFA_Interface_Runs__c> newFFAInterfaceRuns=new List<FFA_Interface_Runs__c>() ;
         Try{
            Map<String,String> JSONData=new Map<String,String>();         
            Set<string>WorkordersFailed=new Set<string>();
            List<FFA_Interface_Runs__c> FFAInterfaceRuns=new List<FFA_Interface_Runs__c>() ;
            List<Workorder> FailedWorkorders=new List<Workorder>() ;
            for(FFA_Interface_Runs__c InterfaceRuns:scope){
                IF(InterfaceRuns.Work_Order__c!=null){
                    //Fetching Workorder Data and Its JSON
                    WorkordersFailed.add(InterfaceRuns.Work_Order__c);
                    InterfaceRuns.FFA_Re_Triggered__c=True;
                    //Adding related data to List  to avoid umcommited work pending error 
                    //and this list will be sent to handler class and a DML operation will be performed
                    FFAInterfaceRuns.add(InterfaceRuns);
               }
            }
          
          //Getting related WO and Making Updated to check how many time it re-trigger to SAP
          IF(WorkordersFailed!=null){
            for(WorkOrder FFAWorkOrder: [SELECT ID,WorkOrderNumber,FFA_Re_Triggered__c FROM Workorder WHERE WorkOrderNumber=:WorkordersFailed]){
               IF(FFAWorkOrder!=null){
                    IF(FFAWorkOrder.FFA_Re_Triggered__c=='No'){
                        FFAWorkOrder.FFA_Re_Triggered__c='Once';
                    } 
                    ELSE IF(FFAWorkOrder.FFA_Re_Triggered__c=='Once'){
                       FFAWorkOrder.FFA_Re_Triggered__c='Twice';
                    } 
                    ELSE If(FFAWorkOrder.FFA_Re_Triggered__c=='Twice'){
                       FFAWorkOrder.FFA_Re_Triggered__c='Mail Sent to Admin';
                       //RetriggerPause=True;
                    }else{
                       FFAWorkOrder.FFA_Re_Triggered__c='Mail Sent to Admin';
                   }
                 //Adding related data to List  to avoid umcommited work pending error 
                 //and this list will be sent to handler class and a DML operation will be performed  
                 FailedWorkorders.add(FFAWorkOrder);      
               }
            }  
          }
          //Callout 
          for(FFA_Interface_Runs__c InterfaceRuns:scope){
                IF(InterfaceRuns.Work_Order__c!=null){
                    Httprequest request = new HttpRequest();
                    Http http = new Http();
                    request.setMethod('PUT');
                    request.setEndpoint('callout:FFA_CompleteInterface_Authentication');
                    request.setBody(InterfaceRuns.Transaction_Message__c);
                    HttpResponse response = http.send(request);  
                    System.debug('Respcode--->'+response.getStatusCode());
                    FFA_Interface_Runs__c InterfaceLogs = new FFA_Interface_Runs__c(Interface_Name__c='/FFACompleteInterface',Transaction_Message__c=InterfaceRuns.Transaction_Message__c, Transaction_Status__c = string.valueOf(response.getStatusCode()),Work_Order__c=InterfaceRuns.Work_Order__c);
                    newFFAInterfaceRuns.add(InterfaceLogs); 
                    //system.debug('Interfaceid'+InterfaceLogs.id);
                }
          }
           FFAFailedJobsDMLOperation.doDmlOperation(FailedWorkorders,FFAInterfaceRuns,newFFAInterfaceRuns);
       }
       catch(Exception e){
            system.debug('==Try Catch==='+e.getLineNumber()+'=='+e.getMessage());
            FFA_Interface_Runs__c InterfaceLogs = new FFA_Interface_Runs__c(Interface_Name__c='/FFACompleteInterface',Transaction_Message__c=e.getMessage()+'Exception at Line'+e.getLineNumber(), Transaction_Status__c ='400',Work_Order__c=WONUMBER);
            If(e.getMessage().contains('Read timed outException')){
                 InterfaceLogs.Transaction_Status__c='503';
            }
            insert InterfaceLogs;
            
        }
       
    } 
     //Finish Method 
     global void finish(Database.BatchableContext BC){
        //A Unique ScheduleJob will be created as CronJobdetailName should be unique 
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,5);
        FFA_Schedule_Configuration__mdt mdt=[Select id,label,Minutes__c from FFA_Schedule_Configuration__mdt  WHERE Masterlabel='Failed Jobs Schedule' limit 1 ];
        DateTime SchDateTime;
        IF(mdt.Minutes__c!=null){
         SchDateTime=System.now().addMinutes(Integer.valueof(mdt.Minutes__c));
        }else{
         SchDateTime=System.now().addMinutes(5);
        }
       
        String CronExp='0 '+SchDateTime.minute()+' '+SchDateTime.hour()+' '+'* * ? *';
        List<CronTrigger> scheduledJobs = [SELECT Id, CronJobDetail.Name, CreatedDate FROM CronTrigger WHERE CronJobDetail.Name Like 'FFA FailedJobs Schedul%' ORDER BY CreatedDate Asc ];
        System.schedule('FFA FailedJobs Schedule '+guid, CronExp, new FFAScehduleFailedJobsReTrigger());
        IF(scheduledJobs.Size()>3 && !scheduledJobs.isEmpty()){
            List<CronTrigger> oldScheduledJobsdel = [SELECT Id, CronJobDetail.Name, CreatedDate FROM CronTrigger WHERE CronJobDetail.Name Like 'FFA FailedJobs Schedul%' ORDER BY CreatedDate Asc limit 2];  
            For(CronTrigger cronTrig:oldScheduledJobsdel){
                 System.abortJob(cronTrig.id);
              } 
        }
    }
  }