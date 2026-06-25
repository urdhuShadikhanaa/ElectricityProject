/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Author      - Venkat Pattapu
* Organisation- WIPRO
* TriggerName - workorderTrigger
* TestClass   -
* Description - This Trigger will trigger after insert and Update events.  
*               when JOB is completed,Teminated,Further Work Required,Cancelled,Rejected It will 
*               make HTTP RestCall to SAP Via OAG.
*               When JOB replanned from Mobile It will add Business Days based on condition.
* Enhancements-
*              Tasks No:
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

Trigger workorderTrigger on WorkOrder (after Insert,after update,before Update) {
    
    Set<id> jobstoSendtoSAP= new  Set<Id>();
    Set<id> replanServiceAppts= new  Set<Id>();
    Set<id> Jobcodes= new  Set<Id>();
    Set<string> FailedWorkorders=new Set<string>();
    Set<id> refreshAssets= new  Set<Id>();
    
   
    if((Trigger.isAfter && Trigger.isUpdate) ){
        for(WorkOrder requiredWO :Trigger.new){
             //FOR TERMINATED ,FWR,COMPLETED TRIGGER HANDLER CLASS WITH WORKORDER IDS,DATA WILL BE SENT SAP 
             IF((requiredWO.Status=='Terminated' && Trigger.oldMap.get(requiredWO.Id).Status!='Terminated')
             ||(requiredWO.Status=='Further Work Required' && Trigger.oldMap.get(requiredWO.Id).Status!='Further Work Required')
             ||(requiredWO.Status=='Completed' && Trigger.oldMap.get(requiredWO.Id).Status!='Completed') ){
                 
                 //jobstoSendtoSAP.add(requiredWO.id); //As per issue on 19-01-21, Not able to send terminated WO to SAP, by Ankit
                 String serailizedWorkorderJSON='['+json.serialize(requiredWO.id)+']';
                 FFA_WorkOrderCompleteInterface.CompletedWorkorders(serailizedWorkorderJSON);
            
             }
            //FOR BULK SCENARIOS 'CANCEL ,REJECT,REPLAN'SAP HANDLES 1 AT A TIME
            IF((requiredWO.Status=='Cancelled' && Trigger.oldMap.get(requiredWO.Id).Status!='Cancelled')
            ||(requiredWO.Status=='Rejected' && Trigger.oldMap.get(requiredWO.Id).Status!='Rejected') 
            ||(requiredWO.FFA_Service_Provider_Replan__c=='Yes' && Trigger.oldMap.get(requiredWO.Id).FFA_Service_Provider_Replan__c!='Yes')
            ||(requiredWO.SAP_Replan__c=='Yes' && Trigger.oldMap.get(requiredWO.Id).SAP_Replan__c!='Yes')
            || (requiredWO.PolicyReplanJob__c==true && Trigger.oldMap.get(requiredWO.Id).PolicyReplanJob__c != true)){
                 String serailizedWorkorderJSON='['+json.serialize(requiredWO.id)+']';
                 FFA_WorkOrderCompleteInterface.CompletedWorkorders(serailizedWorkorderJSON); 
           }
           //FOR MOBILE REPLAN CASE:CHANGING SA DATES
           IF(requiredWO.FFA_Service_Provider_Replan__c=='Yes' && Trigger.oldMap.get(requiredWO.Id).FFA_Service_Provider_Replan__c!='Yes'
           && requiredWO.FFA_Replan_Days__c!=null && requiredWO.FFA_Replan_Days__c!=0 ){
                system.debug('--->reqTrig'+requiredWO.FFA_Service_Provider_Replan__c+Trigger.oldMap.get(requiredWO.Id).FFA_Service_Provider_Replan__c);
               replanServiceAppts.add(requiredWO.id);
        
           }
           //JOBCODES POPULATED BASED ON CUSTOM METADATA
           IF(Trigger.oldMap.get(requiredWO.Id).FFA_Code_Combination__c!=Trigger.newMap.get(requiredWO.Id).FFA_Code_Combination__c
           ||Trigger.oldMap.get(requiredWO.Id).FFA_JOC_3_Code_Combination__c!=Trigger.newMap.get(requiredWO.Id).FFA_JOC_3_Code_Combination__c){
              
               Jobcodes.add(requiredWO.Id);
          }
          IF(Trigger.newMap.get(requiredWO.Id).FFA_Re_Triggered__c=='Mail Sent to Admin' && Trigger.oldMap.get(requiredWO.Id).FFA_Re_Triggered__c!='Mail Sent to Admin'){
          FailedWorkorders.add(requiredWO.WorkOrderNumber);
          }
        
      }
    }
    //UPDATES
        IF(!replanServiceAppts.isEmpty()){
            FFAReplanServiceAppointment serviceAppts=new FFAReplanServiceAppointment();
            serviceAppts.setServiceAppointmentDates(replanServiceAppts);
        }
    //As per issue on 19-01-21, Not able to send terminated WO to SAP, by Ankit
     /*   IF(!jobstoSendtoSAP.IsEmpty()){
            String serailizedWorkorderJSON=json.serialize(jobstoSendtoSAP);
            system.debug(serailizedWorkorderJSON);
             FFA_WorkOrderCompleteInterface.CompletedWorkorders(serailizedWorkorderJSON);
             
        } */
        IF(!Jobcodes.isEmpty()){
             FFAJOCcodes codes=new FFAJOCcodes();
             codes.JOCcodesToPoppulates(Jobcodes);
        }
        IF(!FailedWorkorders.isEmpty()){
           FFAFailedJobsInfoEmail.FFASendEmail(FailedWorkorders);
        }
    //REFRESH ASSETS
     IF((Trigger.isbefore && Trigger.isUpdate) ){
       for(WorkOrder requiredWO :Trigger.new){ 
            IF(requiredWO.Status!=null){
                IF(requiredWO.Form_Response_Completed__c==True && Trigger.oldMap.get(requiredWO.Id).Form_Response_Completed__c!=True){
                    refreshAssets.add(requiredWO.id);
                }
              }
         }   
    }
    IF(!refreshAssets.isEmpty()){
        FFAAssetActivityFromWOrkorderHandler.astActivitiesbeforeFormResponse(refreshAssets);
        System.debug('--->'+refreshAssets);
    }
        
        
        
    
   }