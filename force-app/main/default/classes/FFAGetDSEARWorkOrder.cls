/////////////////////////////////////////////////
/*          SAP-FFA CREATE INTERFACE (F1)      */
/*          Author: ANKIT TOMAR                */ 
/*          Company: Wipro Technologies        */
/*          Created Date: 08/09/2020           */
/*          Datails: Used in Create Interface  */
/////////////////////////////////////////////////
public with sharing class FFAGetDSEARWorkOrder {
    
    public static string getDsearWorkOrderId(String MPRN){
        String MPRNValue = String.escapeSingleQuotes(MPRN);
        list<WorkOrder> WOsFullDsearList = [select Id , WorkOrderNumber ,FFA_MeterPointReferenceNumber__c, Full_DSEAR__c ,Full_DSEAR_Id__c,DSEAR_Status__c, CreatedDate from WorkOrder 
                                            where DSEAR_Status__c='F' AND Full_DSEAR__c!=null AND FFA_MeterPointReferenceNumber__c =: MPRNValue  order by createddate DESC limit 1];
        
        
        string DsearIdAndFullOrShort;
        system.debug('======>>>> 10'+WOsFullDsearList.size());
        if(WOsFullDsearList.size() == 1){
            System.debug('======>>>> 11');
            DsearIdAndFullOrShort = WOsFullDsearList[0].Full_DSEAR__c+'@'+WOsFullDsearList[0].FFA_MeterPointReferenceNumber__c;
            system.debug(DsearIdAndFullOrShort);
            return DsearIdAndFullOrShort;
        }else{
            list<WorkOrder> WOsShortDsearListTwo = [select Id , WorkOrderNumber ,FFA_MeterPointReferenceNumber__c, Full_DSEAR__c ,DSEAR_Status__c, CreatedDate from WorkOrder 
                                                    where DSEAR_Status__c='S' AND FFA_MeterPointReferenceNumber__c =: MPRNValue order by createddate DESC limit 1];
            
            if(WOsShortDsearListTwo.size() == 1){
                System.debug('======>>>> 16');
                DsearIdAndFullOrShort = '*'+WOsShortDsearListTwo[0].FFA_MeterPointReferenceNumber__c;
                system.debug(DsearIdAndFullOrShort);
                return DsearIdAndFullOrShort;
            }
        }
        return 'Null';
    }  
}