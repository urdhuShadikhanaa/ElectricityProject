public with sharing class NGMCP_NotificationController {

    @AuraEnabled
    public static List<NGMCP_Notification__c> getUnreadNotifications() {

        Id currentUserId = UserInfo.getUserId();
        return [
            SELECT Id,
                   Message__c,
                   SA_Id__c,
                   Is_Read__c,
                   CreatedDate
            FROM NGMCP_Notification__c
            WHERE User__c = :currentUserId
              AND Is_Read__c = false WITH USER_MODE
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];
    }


    @AuraEnabled
    public static void markRead(Id notifId) {        
         List<NGMCP_Notification__c> notifs = [
            SELECT Id FROM NGMCP_Notification__c
            WHERE User__c = :UserInfo.getUserId()
            AND Is_Read__c = false WITH USER_MODE
        ];

        for (NGMCP_Notification__c n : notifs) {
            n.Is_Read__c = true;
        }

        if (!notifs.isEmpty()){
            Database.update(notifs, false, AccessLevel.USER_MODE);
        }
    }
}