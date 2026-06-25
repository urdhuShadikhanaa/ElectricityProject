@isTest(seeAllData=false)
public class UpdateownerandcreatedbyTestClass {
    static testMethod void validateUpdateownerandcreatedby() {
       Permit_To_Work__c p = new Permit_To_Work__c(OwnerId='0052o000009nS2tAAE', MPRN__c='666',Site_Postcode__c='B30 3AB', risk_lifting_operations__c=TRUE, Contact_Email__c='test@nationalgrid.com', Confirm_Contact_Email__c='test@nationalgrid.com',Expected_End_Date__c = Date.today(),Expected_Start_Date__c = Date.today(),Our_Work_Order_Ref__c = '123455',Service_Provider__c = 'Penspen',Site_Name__c = 'Lion Pub',Site_Address__c = '1 high st, solihull',Engineers_Full_Name__c = 'Alan Engineer',Contact_Phone_Number__c = '0121123456');
       System.debug('owner id before creation:' + p.OwnerId);

       // Insert new record
       insert p;
    
       // Retrieve the new record
       p = [SELECT OwnerId FROM Permit_To_Work__c p];
       System.debug('owner after trigger fired:' + p.OwnerId);

      
    }
}