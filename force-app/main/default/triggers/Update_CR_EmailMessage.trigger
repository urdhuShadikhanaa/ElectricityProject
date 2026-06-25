// Description : Test class Update_EmailMessage_HandlerTest
trigger Update_CR_EmailMessage on EmailMessage (before insert, before update, after insert, after update) {
  
    Update_EmailMessage_LinkWithCRHandler handler = new Update_EmailMessage_LinkWithCRHandler();
     if(trigger.isinsert && trigger.isbefore || trigger.isupdate && Trigger.isbefore){
        handler.insertEmailMessages(Trigger.new);
    }
   
}