//************************************************************************************************
//   Name        : NG_SRE_CaseTrigger
//   Created By  : SRE Team - Wipro
//   Created Date: 26/11/2024
//   Description : Basic trigger, all logic handled in the NG_TriggerFactoryClass
//************************************************************************************************
Trigger NG_SRE_CaseTrigger on Case(before insert, before update, before delete, after insert, after update, after delete) {
    
        if(Trigger.isBefore && Trigger.isupdate){
            NG_SRE_CaseTriggerHandler.handlingWithInsertAndUpdate(Trigger.new);
        }       
    
}