public with sharing  class NGMCP_NotificationEventHandler {
    
    public static void handleEvent(List<NGMCP_Notification_Event__e> events) {        
        List<NGMCP_Notification__c> notifRecords = new List<NGMCP_Notification__c>();
        
        for (NGMCP_Notification_Event__e evt : events) {
            
            System.debug(' Received Event: ' + evt);
            
            NGMCP_Notification__c notif = new NGMCP_Notification__c(
                Message__c = evt.NGMCP_Message__c,
            SA_Id__c = evt.NGMCP_Service_Appointment_Id__c,
            User__c = evt.NGMCP_User_Id__c,
            OwnerId = (Id) evt.NGMCP_User_Id__c,
            Is_Read__c = false
                );
            
            notifRecords.add(notif);
        }
        
        if (!notifRecords.isEmpty()) {
            Database.insert(notifRecords, false, AccessLevel.USER_MODE);
        }
    }
}