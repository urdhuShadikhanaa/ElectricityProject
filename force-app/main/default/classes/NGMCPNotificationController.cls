public with sharing class NGMCPNotificationController {
    
    /* =========================================================
Get unread notifications (Last 7 days)
========================================================= */
    @AuraEnabled
    public static List<NGMCP_Notification__c> getUnreadNotifications() {
        // --- Object access ---
        Boolean objAccess = Schema.sObjectType.NGMCP_Notification__c.isAccessible();
        DateTime sevenDaysAgo = System.now().addDays(-7);
        if (!objAccess) {
            return new List<NGMCP_Notification__c>();
        }
        
        // --- SOQL execution ---
        List<NGMCP_Notification__c> notifications = [
            SELECT Id,
            Message__c,
            CreatedDate,
            NGMCP_Request__c,
            Is_Read__c
            FROM NGMCP_Notification__c
            WHERE User__c = :UserInfo.getUserId()
            AND Is_Read__c = false
            AND CreatedDate >= :sevenDaysAgo WITH USER_MODE
            ORDER BY CreatedDate DESC
        ];        
        // --- FLS enforcement ---
        SObjectAccessDecision decision =
            Security.stripInaccessible(AccessType.READABLE, notifications);
        
        List<NGMCP_Notification__c> safeRecords =
            (List<NGMCP_Notification__c>) decision.getRecords();
        
        if (decision.getRemovedFields() != null && !decision.getRemovedFields().isEmpty()) {
            decision.getRemovedFields();
        } 
        
        return safeRecords;
    }
    
    
    /* =========================================================
Mark selected notifications as read (Bulk-safe)
========================================================= */
    @AuraEnabled
    public static void markAsRead(List<Id> notificationIds) {
        
        if (notificationIds == null || notificationIds.isEmpty()) {
            return;
        }
        
        if (!Schema.sObjectType.NGMCP_Notification__c.isUpdateable()) {
            return;
        }
        
        List<NGMCP_Notification__c> toUpdate = new List<NGMCP_Notification__c>();
        
        for (NGMCP_Notification__c n : [
            SELECT Id, Is_Read__c
            FROM NGMCP_Notification__c
            WHERE Id IN :notificationIds WITH USER_MODE
        ]) {
            if (!n.Is_Read__c) {
                n.Is_Read__c = true;
                toUpdate.add(n);
            }
        }
        
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
    
    /* =========================================================
Create notification from replay event (Bulk-safe logic)
========================================================= */
    @AuraEnabled
    public static Id createNotificationFromEvent(
        String message,
        Long replayId,
        Id targetUserId
    ) {
        if (String.isBlank(message) || replayId == null) {
            return null;
        }
        
        if (!Schema.sObjectType.NGMCP_Notification__c.isCreateable()) {
            return null;
        }
        
        String replayKey = String.valueOf(replayId);
        
        // Check for existing record (idempotent)
        List<NGMCP_Notification__c> existing = [
            SELECT Id
            FROM NGMCP_Notification__c
            WHERE Event_Replay_Id__c = :replayKey WITH USER_MODE
            LIMIT 1
        ];
        
        if (!existing.isEmpty()) {
            return existing[0].Id;
        }
        
        NGMCP_Notification__c notif = new NGMCP_Notification__c(
            Message__c        = message,
            User__c           = targetUserId,
            OwnerId           = targetUserId,
            Event_Replay_Id__c= replayKey,
            Is_Read__c        = false
        );
        
        insert notif;
        return notif.Id;
    }
}