trigger UserTrigger on User (after insert, after update) {
    
    if(trigger.isAfter && (trigger.isInsert )){
      /*  SP_CreateUserExpHandler.assignPublicGroup(); */
    }

}