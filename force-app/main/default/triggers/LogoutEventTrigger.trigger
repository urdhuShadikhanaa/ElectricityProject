trigger LogoutEventTrigger on LogoutEventStream (after insert) {
  List<logout_event__c> eventList = new List<logout_event__c>();
    For(LogoutEventStream event : Trigger.new){
        logout_event__c record = new logout_event__c();
       
        record.User__c = event.UserId;
     
        record.event_date__c = event.EventDate;
      
        eventList.add(record);
    }
    insert eventList;
}