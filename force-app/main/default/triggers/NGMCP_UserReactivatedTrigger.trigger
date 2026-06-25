trigger NGMCP_UserReactivatedTrigger
on NGMCP_User_Reactivated__e (after insert) {
   for (NGMCP_User_Reactivated__e evt : Trigger.New) {
       NGMCP_ResetEmailService.send(evt.Username__c);
   }
}