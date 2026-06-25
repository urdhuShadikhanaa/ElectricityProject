/**
 * @File Name         : NGMCP_NotificationControllerTest.cls
 * @Description       : Test class for NGMCP_NotificationController.
 * @Author            : Vishnu
 * @Last Modified By  : 
 * @Last Modified On  : January 2, 2026
 * @Modification Log  :
 *==============================================================================
 * Ver | Date             | Author             | Modification
 *==============================================================================
 * 1.0 | January 2, 2026  | vishnu      | Initial Version
 **/

@isTest
public class NGMCP_NotificationControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test users
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser1 = new User(
            Alias = 'tsusr1',
            Email = 'testuser112345@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            Username = 'testuser112345@sfvbsjadvbjxb.com',
            TimeZoneSidKey = 'America/New_York'
        );
        
        User testUser2 = new User(
            Alias = 'tsusr2',
            Email = 'testuser1234562@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            Username = 'testuser112345@dsafvjhsdavchj.com',
            TimeZoneSidKey = 'America/New_York'
        );
        
        insert new List<User>{testUser1, testUser2};
        
        // Create test notifications - only create notifications for user1
        // This way, user2 should have 0 unread notifications
        List<NGMCP_Notification__c> notifications = new List<NGMCP_Notification__c>();
        
        // Create 2 unread notifications for user 1
        notifications.add(new NGMCP_Notification__c(
            Message__c = 'Test notification 1 for user 1',
            User__c = testUser1.Id,
            Is_Read__c = false
        ));
        
        notifications.add(new NGMCP_Notification__c(
            Message__c = 'Test notification 2 for user 1',
            User__c = testUser1.Id,
            Is_Read__c = false
        ));
        
        // Create 1 read notification for user 1
        notifications.add(new NGMCP_Notification__c(
            Message__c = 'Test notification 3 for user 1 (read)',
            User__c = testUser1.Id,
            Is_Read__c = true
        ));
        
        insert notifications;
    }
    
    /**
     * @description Tests the getUnreadNotifications method
     *              This test verifies that the method returns only unread notifications 
     *              for the current user, ordered by CreatedDate descending
     */
    @isTest
    static void testGetUnreadNotifications() {
        // Get the test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser112345@example.com' LIMIT 1];
        
        // Switch to test user context
        System.runAs(testUser) {
            Test.startTest();
            List<NGMCP_Notification__c> result = NGMCP_NotificationController.getUnreadNotifications();
            Test.stopTest();
            
            // Verify results
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(2, result.size(), 'Should return 2 unread notifications for user 1');
            
            // Verify all returned notifications are unread
            for (NGMCP_Notification__c notification : result) {
                System.assertEquals(false, notification.Is_Read__c, 'All returned notifications should be unread');
            }
            
            // Verify ordering (most recent first)
            if (result.size() > 1) {
                System.assert(result[0].CreatedDate >= result[1].CreatedDate, 'Notifications should be ordered by CreatedDate descending');
            }
        }
    }
    
    /**
     * @description Tests the getUnreadNotifications method with no unread notifications
     *              This test verifies that the method returns an empty list when there are no unread notifications
     */
    @isTest
    static void testGetUnreadNotificationsWithNoUnread() {
        // Get the test user who has no unread notifications
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser1234562@example.com' LIMIT 1];
        
        // Switch to test user context
        System.runAs(testUser) {
            Test.startTest();
            List<NGMCP_Notification__c> result = NGMCP_NotificationController.getUnreadNotifications();
            Test.stopTest();
            
            // Verify results
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(0, result.size(), 'Should return 0 unread notifications for user 2');
        }
    }
    
    /**
     * @description Tests the markRead method
     *              This test verifies that the method marks notifications as read
     */
    @isTest
    static void testMarkRead() {
        // Get the test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser112345@example.com' LIMIT 1];
        
        // Get unread notifications for the user
        List<NGMCP_Notification__c> unreadNotifications = [
            SELECT Id FROM NGMCP_Notification__c 
            WHERE User__c = :testUser.Id 
            AND Is_Read__c = false
            LIMIT 10
        ];
        
        System.assertNotEquals(null, unreadNotifications, 'Should have unread notifications to test');
        System.assert(unreadNotifications.size() > 0, 'Should have at least one unread notification');
        
        // Store the first notification ID
        Id notificationId = unreadNotifications[0].Id;
        
        // Switch to test user context
        System.runAs(testUser) {
            Test.startTest();
            NGMCP_NotificationController.markRead(notificationId);
            Test.stopTest();
            
            // Verify the notification was marked as read
            NGMCP_Notification__c updatedNotification = [
                SELECT Id, Is_Read__c FROM NGMCP_Notification__c 
                WHERE Id = :notificationId 
                LIMIT 1
            ];
            
            System.assertEquals(true, updatedNotification.Is_Read__c, 'Notification should be marked as read');
        }
    }
    
    /**
     * @description Tests the markRead method with no matching notifications
     *              This test verifies that the method handles cases where no notifications match the criteria
     */
    @isTest
    static void testMarkReadWithNoMatchingNotifications() {
        // Get a test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser1234562@example.com' LIMIT 1];
        
        // Create a fake notification ID that doesn't exist or doesn't belong to this user
        Id fakeNotificationId = '0NQ000000000001';
        
        // Switch to test user context
        System.runAs(testUser) {
            Test.startTest();
            NGMCP_NotificationController.markRead(fakeNotificationId);
            Test.stopTest();
            
            // Should not throw any exceptions
            System.assert(true, 'Method should not throw exception when no matching notifications exist');
        }
    }
}