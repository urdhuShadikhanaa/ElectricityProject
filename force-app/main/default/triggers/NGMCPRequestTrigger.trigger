trigger NGMCPRequestTrigger on NGMCP_Request__c (after update,after insert, before insert, before update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        NGMCPRequestTriggerHandler.handleAfterUpdate(
            Trigger.new,
        Trigger.oldMap
            );       
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        List<NGMCP_Request__c> changedToCompleted = new List<NGMCP_Request__c>();        
        for (NGMCP_Request__c newRec : Trigger.new) {
            NGMCP_Request__c oldRec = (NGMCP_Request__c) Trigger.oldMap.get(newRec.Id);
            if(oldRec == null){
                continue;
            }            
            if (oldRec.NGMCP_Status__c != newRec.NGMCP_Status__c && newRec.NGMCP_Status__c == 'Completed') {
                changedToCompleted.add(newRec);
            }
        }        
        if (!changedToCompleted.isEmpty()) {
            // Pass only relevant records to your integration class
            NGMCP_IBMMaximoIntegrationClass.sendAddressUpdateEmail(changedToCompleted);
        }
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        NGMCPRequestTriggerHandler.handleAfterInsert(Trigger.new);
    }
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        system.debug('before update');
        boolean isupdateflage = Trigger.isInsert ? true : false;
        NGMCPRequestTriggerHandler.dateFormatFix(Trigger.new, isupdateflage);
        pw_ccpro.CountryValidator2.Validate(Trigger.new, Trigger.oldMap);
    }
    
}