trigger NGMCP_UserMangementEvent on NGMCP_User_Management__e (after insert) {

    List<NGMCP_CreatePortalUserJob.UserEventWrapper> userEvents =
        new List<NGMCP_CreatePortalUserJob.UserEventWrapper>();

    List<NGMCP_createAccountandContactQueueable.platforEventWrapper> rows =
        new List<NGMCP_createAccountandContactQueueable.platforEventWrapper>();

    // Take action type from first event (PE batches normally consistent)
    String actionType = Trigger.New[0].NGMCP_Action__c;

    for (NGMCP_User_Management__e evt : Trigger.New) {       

        // ---------------- DEACTIVATE ----------------
        if (evt.NGMCP_Action__c == 'Deactivate' || evt.NGMCP_Action__c == 'Change' || evt.NGMCP_Action__c == 'Reactivate') {
            System.debug('evt.Username__c,'+evt.NGMCP_Email__c);
            userEvents.add(
                new NGMCP_CreatePortalUserJob.UserEventWrapper(
                    (Id) evt.NGMCP_ContactId__c,
                    evt.NGMCP_Role__c,
                    evt.NGMCP_User_Name__c,
                    evt.Email__c,
                    evt.NGMCP_Suppler_Code__c,
                    evt.NGMCP_Supplier_Group__c
                )
            );
        }
        // ---------------- CREATE ----------------
        else if (evt.NGMCP_Action__c == 'Create') {

            NGMCP_createAccountandContactQueueable.platforEventWrapper r =
                new NGMCP_createAccountandContactQueueable.platforEventWrapper();
            r.firstName     = evt.NGMCP_First_Name__c;
            r.lastName      = evt.NGMCP_Last_Name__c;
            r.email         = evt.NGMCP_Email__c != null ? evt.NGMCP_Email__c :'';
            r.username      = evt.NGMCP_User_Name__c != null ? evt.NGMCP_User_Name__c : '';
            r.role          = evt.NGMCP_Role__c != null ? evt.NGMCP_Role__c : '';
            r.supplierCode  = evt.NGMCP_Suppler_Code__c != null ? evt.NGMCP_Suppler_Code__c : '';
            r.supplierGroup = evt.NGMCP_Supplier_Group__c != null ? evt.NGMCP_Supplier_Group__c : '';
            r.requestedEmail = evt.NGMCP_Requester_Email__c !=null ? evt.NGMCP_Requester_Email__c : '';
            r.accountId = evt.NGMCP_Account_owneId__c;
            rows.add(r);
        }
    }
    // ---------------- ENQUEUE ONCE ----------------
    if (!userEvents.isEmpty()) {
        System.enqueueJob(new NGMCP_CreatePortalUserJob(userEvents, actionType));
    }
    system.debug('rows'+rows.size());
    if (!rows.isEmpty()) {
        System.enqueueJob(new NGMCP_createAccountandContactQueueable(rows, actionType));
    }
}