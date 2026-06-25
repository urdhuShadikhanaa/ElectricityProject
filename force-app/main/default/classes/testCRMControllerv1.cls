/*
** Description: This testclass is used in CRM**
*/
@isTest
public class testCRMControllerv1 {
 @isTest static void  testCRMMethod()
    {
        List<CRM_Content__c> selectCRMList = new List<CRM_Content__c>();
       CRM_Content__c selectCRMObj = new CRM_Content__c();
        selectCRMObj.Name = 'Test';
        selectCRMObj.Story__c = 'Hello';
        selectCRMList.add(selectCRMObj);
        CRMControllerv1 CRMControllerv1test = new CRMControllerv1();
        CRMControllerv1test.conList = selectCRMList;        
    }
}