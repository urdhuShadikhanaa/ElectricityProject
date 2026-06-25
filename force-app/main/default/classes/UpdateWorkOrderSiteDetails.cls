public class UpdateWorkOrderSiteDetails
/* Wipro 25/06/2020
 * This class is used by the Schedule flow
 * It updates the PII data contained in the FFA Site Object
 * All Site PII specific fields will be set to null/blank value
 * --- 05/10/2020 --- DSEAR email removal included as part of this process
*/
{
    @InvocableMethod
    public static void UpdateWorkOrderSite(List< WorkOrder > lstWO)
    {

        //Only process if there are any records found
        Set<ID> setSiteIds = New Set<ID>();
        Set<ID> setDsearIds = New Set<ID>();
        List<WorkOrder> lstWorkOrdersToUpdate = New List<WorkOrder>();
        if(lstWo.size() > 0){
            //Get unique Site and DSEAR Ids from Work Orders
            for(WorkOrder varWO : lstWO){
                //Print WO details
                system.debug('Work Order Total, WO No, Site Id & DSEAR Id: ' + lstWo.size() + ' --- ' + varWO.WorkOrderNumber + ' - ' + varWO.Site__c + ' - ' + varWO.DSEAR_Lookup__c);
                setSiteIds.add(varWO.Site__c);
                If(varWO.DSEAR_Lookup__c != Null)
                	setDsearIds.add(varWO.DSEAR_Lookup__c);
                //maintain a list of processed Work Orders
                varWO.FFA_Personal_Details_Executed__c = True;
                lstWorkOrdersToUpdate.add(varWO);
            }
        }
        
        //Get all Sites records from the Map of Site ids
        List<FFA_Site__c> lstSiteRecords =[SELECT Name, Site_Name__c,FFA_ContactTelephoneNumber__c
                                                   FROM FFA_Site__c
                                                   WHERE id IN : setSiteIds];
        System.debug('Total Site Records: ' + lstSiteRecords.size());
        
        //Maintain a list of Site records to update
        List<FFA_Site__c> lstSitesToUpdate = new List<FFA_Site__c>(); 
        for(FFA_Site__c varSite : lstSiteRecords){
            varSite.FFA_Title__c = '';
            varSite.FFA_Title2__c = '';
            varSite.FFA_Initials__c = '';
            varSite.FFA_Initials2__c = '';
            varSite.FFA_Surname__c = '';
            varSite.FFA_Surname2__c = '';
            varSite.FFA_ContactTelephoneNumber__c = '';
            varSite.FFA_ContactTelephoneNumber2__c = '';
            varSite.FFA_AdditionalContactTelephoneNumber__c = '';
            varSite.FFA_AdditionalContactTelephoneNumber2__c = '';
            varSite.FFA_Vulnerable_Customer_Information__c = '';
            varSite.FFA_AccessInstructions__c = '';
            varSite.FFA_AccessRestrictions__c = '';
            lstSitesToUpdate.add(varSite);                   
        }
     
        System.debug('Total number of sites to be updated: ' + lstSitesToUpdate.size());
        
        //Update Site Records by removing the PII data
        if(lstSitesToUpdate.size() > 0){
            try{
                update lstSitesToUpdate;   
                update lstWorkOrdersToUpdate;
            }catch(DMLexception e){
                System.debug('Error: ' + e.getMessage( ) + ' LINE_NUMBER : ' + e.getLineNumber( ) );
            }
        }
        
        //Get all DSEAR records from the Map of DSEAR ids
        List<DSEAR__c> lstDsearRecords =[SELECT Consumer_email_address__c
                                                   FROM DSEAR__c
                                                   WHERE id IN : setDsearIds];
        System.debug('Total DSEAR Records: ' + lstDsearRecords.size());
        
        If(lstDsearRecords.size() > 0){
            //Maintain a list of DSEAR records to update
            List<DSEAR__c> lstDsearToUpdate = new List<DSEAR__c>(); 
            for(DSEAR__c varDsear : lstDsearRecords){
                //Update DSEAR Records by removing the PII data
                varDsear.Consumer_email_address__c = '';
                lstDsearToUpdate.add(varDsear);                   
            }
        
            System.debug('Total number of DSEAR to be updated: ' + lstDsearToUpdate.size());
            //Update DSEAR Records
            if(lstDsearToUpdate.size() > 0){
                try{
                    update lstDsearToUpdate;   
                }catch(DMLexception e){
                    System.debug('Error: ' + e.getMessage( ) + ' LINE_NUMBER : ' + e.getLineNumber( ) );
                }
            }
        }
  
    }
      
}