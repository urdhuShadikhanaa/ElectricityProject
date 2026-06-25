/*
** Description: This class is used in FFA**
*/
public class UpdateAccountIdsBCM
{
    @InvocableMethod
    public static void UpdateAccountIds(List<String> varBCM)
    {

        //Get all BCM jobs
        List<Domestic_BCM_Jobs__c> lstBcmRecords =[SELECT AccountId__c, receiverid__c, WorkTypeId__c, Job_Type__c
                                                   FROM Domestic_BCM_Jobs__c
                                                   WHERE isProcessed__c = FALSE];
        System.debug('Total BCM Records: ' + lstBcmRecords.size());
        
        //Get all account ids of the BCM jobs
        List<Account> lstBcmAccounts = [SELECT Id, Name, Supplier_ID__c FROM Account];
        System.debug('Total matching Account Records: ' + lstBcmAccounts.size());
        
        //Maintain a list of records to be updated
        List<Domestic_BCM_Jobs__c> lstRecordsToUpdate = new List<Domestic_BCM_Jobs__c>(); 
        
           for(Domestic_BCM_Jobs__c recBCM: lstBcmRecords){
               //System.debug('BCM Account name: ' + recBCM.receiverid__c);
               
               //Find Matching Accounts
               for(Account recAcc: lstBcmAccounts){
                    //System.debug('Account name: ' + recAcc.name);
                   if (recBCM.receiverid__c == recAcc.name){
                       System.debug('Matching account name: ' + recAcc.name);
                       recBCM.AccountId__c = recAcc.Id;
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