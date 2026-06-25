trigger NGMCPNotificationEventTrigger
    on NGMCP_Notification_Event__e (after insert) {

    if (Trigger.isAfter && Trigger.isInsert) {
        NGMCPNotificationEventHandler.handleAfterInsert(Trigger.new);
    }
}