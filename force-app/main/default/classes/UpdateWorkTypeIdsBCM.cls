/*
** Description: This class is used in FFA**
*/
public class UpdateWorkTypeIdsBCM
{
    @InvocableMethod
    public static void UpdateWorkTypeIds(List<String> varBCM)
    {

        //Get all BCM jobs
        List<Domestic_BCM_Jobs__c> lstBcmRecords =[SELECT AccountId__c, receiverid__c, WorkTypeId__c, Job_Type__c, AxsyFormId__c
                                                   FROM Domestic_BCM_Jobs__c
                                                   WHERE isProcessed__c = FALSE];
        System.debug('Total BCM Records: ' + lstBcmRecords.size());

        //Get all WorkType ids of the BCM jobs
        List<WorkType> lstBcmWT = [SELECT Id, Name, Axsy_Form__c FROM WorkType];
        System.debug('Total Work Types Records: ' + lstBcmWT.size());
        
        //Maintain a list of records to be updated
        List<Domestic_BCM_Jobs__c> lstRecordsToUpdate = new List<Domestic_BCM_Jobs__c>(); 
        
           for(Domestic_BCM_Jobs__c recBCM: lstBcmRecords){
               //System.debug('BCM Account name: ' + recBCM.receiverid__c);
               
               //Find Matching WorkTypes
               for(WorkType recWT: lstBcmWT){
                    //System.debug('WorkType name: ' + recWT.name);
                   if (recBCM.Job_Type__c == recWT.name){
                       System.debug('Matching WorkType name: ' + recBCM.Job_Type__c);
                       recBCM.WorkTypeId__c = recWT.Id;
                       recBCM.AxsyFormId__c = recWT.Axsy_Form__c;
                       lstRecordsToUpdate.add(recBCM);                   
                   }
               }
           }
     
        System.debug('lstRecordsToUpdate: ' + lstRecordsToUpdate.size());
       //Update BCM records.
        if(lstRecordsToUpdate.size() > 0){
            System.debug('lstRecordsToUpdate: ' + lstRecordsToUpdate);
            update lstRecordsToUpdate;            
        }
       }
}