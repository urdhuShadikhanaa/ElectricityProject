// Description : Test class Update_EmailMessage_HandlerTest
trigger Update_bcEmail_LinkToCRTrigger on BC_Email__c (before insert, before update, after insert, after update) {
   
    UpdateChangeRequestInBCEmailHandler handelerClass = new UpdateChangeRequestInBCEmailHandler();
    if(trigger.isinsert && trigger.isbefore || trigger.isupdate && Trigger.isbefore){
        handelerClass.insertBCEmail(Trigger.new);
    }
  
}