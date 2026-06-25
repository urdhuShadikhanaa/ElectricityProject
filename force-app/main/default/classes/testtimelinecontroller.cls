@isTest
public class testtimelinecontroller {


 @isTest static void  testtimMethod()
    {
        List<CRM_Content__c> selecttimList = new List<CRM_Content__c>();
       CRM_Content__c selecttimObj = new CRM_Content__c();
        selecttimObj.Name = 'Test';
        selecttimObj.Story__c = 'Hello';
        selecttimList.add(selecttimObj);
        timelinecontroller timelinecontrollertest = new timelinecontroller();
        timelinecontrollertest.timList = selecttimList;        
    }
}