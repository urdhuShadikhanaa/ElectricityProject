// Description : Test class for Update_EmailMessage_LinkWithCRHandler
// Description : Test class for UpdateChangeRequestInBCEmailHandler
// Description : Test class for Update_bcEmail_LinkToCRTrigger
// Description : Test class for Update_CR_EmailMessage
@isTest
public class Update_EmailMessage_HandlerTest {
   public static testMethod void testInsert(){
       
       Change_Request__c change = new Change_Request__c();
       change.Name = 'suresh';
       insert change;
       
       

        BC_Email__c bcEmail = new BC_Email__c();
        bcEmail.Related_CR__c = change.Id;
        bcEmail.Subject__c = 'Test';
        
        insert bcEmail;
       
      EmailMessage emailMSG = new EmailMessage();
      
       emailMSG.Subject = 'Test';
       emailMSG.FromAddress = 'suresh.kokkeragadda@wipro.com';
       emailMSG.Parent_BC_Email__c = bcEmail.Id;
       emailMSG.Parent_CR__c = change.Id;
       
       insert emailMSG;
    }
     
}