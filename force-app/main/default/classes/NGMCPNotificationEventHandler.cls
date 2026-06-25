public with sharing class NGMCPNotificationEventHandler {

    public static void handleAfterInsert(
        List<NGMCP_Notification_Event__e> events
    ) {
        if (events == null || events.isEmpty()) {
            return;
        }

        // CRUD check
        if (!Schema.sObjectType.NGMCP_Notification__c.isCreateable()) {
            return;
        }

        List<NGMCP_Notification__c> notificationsToUpsert =
            new List<NGMCP_Notification__c>();

        for (NGMCP_Notification_Event__e evt : events) {

            // Null safety
            if (evt == null || evt.ReplayId == null || evt.NGMCP_User_Id__c == null) {
                continue;
            }

            notificationsToUpsert.add(new NGMCP_Notification__c(
                Event_Replay_Id__c = String.valueOf(evt.ReplayId), // Unique
                Message__c         = evt.NGMCP_Message__c,
                User__c            = evt.NGMCP_User_Id__c,
                OwnerId            = (Id) evt.NGMCP_User_Id__c,
                NGMCP_Request__c   = evt.NGMCP_Request_Id__c,
                Is_Read__c         = false
            ));
        }

        if (!notificationsToUpsert.isEmpty()) {
            try {
                upsert notificationsToUpsert Event_Replay_Id__c;
            } catch (DmlException e) {
                System.debug(
                    'NGMCP Notification upsert failed: ' + e.getMessage()
                );
            }
        }
    }
}