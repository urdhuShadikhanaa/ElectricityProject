trigger NGMCP_RequestTrigger on NGMCP_Request__c (before insert, before update, after insert, 
                                                  after update, before delete, after delete) {
    System.debug('Inside NGMCP_RequestTrigger');
    if (Trigger.isBefore && Trigger.isUpdate) {
        NGMCP_RequestTriggerHandler.updateTQ(trigger.new, trigger.oldMap); 
    }                                                                                                                                                   
    if(trigger.isAfter && trigger.isUpdate){
        System.debug('Inside NGMCP_RequestTrigger after update if block');
        NGMCP_RequestTriggerHandler.submitOnHoldAMRs(trigger.new, trigger.oldMap);
        NGMCP_RequestTriggerHandler.createTQAndOnHoldAMR(trigger.new, trigger.oldMap);
        NGMCP_RequestTriggerHandler.updateOnHoldRemoveAMRs(trigger.new, trigger.oldMap);
    }
                                                      
                                                                
}