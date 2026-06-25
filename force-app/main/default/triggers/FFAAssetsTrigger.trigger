trigger FFAAssetsTrigger on FFA_NGV_Asset__c (after Insert,after update) {
     if(trigger.isInsert){
      if(RecursiveTriggerHandler.isFirstTime){
        RecursiveTriggerHandler.isFirstTime = false;
         Boolean updateEvent=false;
         FFAAssetActivityHandler.doProcessActivityTypes(Trigger.new,Trigger.oldMap,updateEvent);
       }
    }
    if(trigger.isUpdate){
        System.debug('Test check1 == '+RecursiveTriggerHandler.isFirstTime);
      if(RecursiveTriggerHandler.isFirstTime){
          System.debug('Test check2 == '+RecursiveTriggerHandler.isFirstTime);
        RecursiveTriggerHandler.isFirstTime = false;
         Boolean updateEvent=True;
         FFAAssetActivityHandler.doProcessActivityTypes(Trigger.new,Trigger.oldMap,updateEvent);
       }
    }
}