trigger Updateownerandcreatedby on Permit_To_Work__c (before insert, before update) {



for(Permit_To_Work__c ptw: Trigger.new)
    {
     
     if(trigger.isBefore && trigger.isInsert)
     ptw.OwnerId = '0052o00000AD5IRAA1';

    }
}