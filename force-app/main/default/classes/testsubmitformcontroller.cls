@isTest
public class testsubmitformcontroller {
public static testmethod  void testsubmitFormCustomObjectController(){
       Robot_Tracking_Entry__c re = new Robot_Tracking_Entry__c();
        re.NGM_AMR_Requests__c = 20;
        re.Comments__c = 'Hello';
    re.Performance_Month__c = date.parse('4/01/2020');
    re.TQ_TFM__c = 10;
    re.dual_supplier_deappoint_process__c = 100;
    re.Working_days__c = 21;
    

     submitFormCustomObjectController.getRobot(re);  
     System.assertNotEquals(null, re);
}
        
}