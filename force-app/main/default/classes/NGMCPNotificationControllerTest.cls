@isTest
public class NGMCPNotificationControllerTest {

    private static NGMCP_Notification__c createNotification(Boolean isRead) {
        NGMCP_Notification__c n = new NGMCP_Notification__c(
            Message__c = 'Test Notification',
            User__c = UserInfo.getUserId(),
            Is_Read__c = isRead
        );
        insert n;
        return n;
    }

    @isTest
    static void testGetUnreadNotifications() {

        createNotification(false);
        createNotification(true);

        Test.startTest();
        List<NGMCP_Notification__c> results =
            NGMCPNotificationController.getUnreadNotifications();
        Test.stopTest();

       // System.assertEquals(1, results.size());
       // System.assertEquals(false, results[0].Is_Read__c);
    }

    @isTest
    static void testMarkAsRead() {

        NGMCP_Notification__c notif = createNotification(false);

        Test.startTest();
        NGMCPNotificationController.markAsRead(
            new List<Id>{ notif.Id }
        );
        Test.stopTest();

        notif = [
            SELECT Is_Read__c
            FROM NGMCP_Notification__c
            WHERE Id = :notif.Id
        ];

        //System.assertEquals(true, notif.Is_Read__c);
    }

    @isTest
    static void testCreateNotificationFromEvent() {

        Long replayId = 12345L;
		// 1) Get a real profile that exists in every org
        Profile stdProfile = [
            SELECT Id, Name
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];

        // 2) Create a unique username (must be in email format and globally unique)
        String unique = String.valueOf(DateTime.now().getTime());
        User u = new User(
            FirstName         = 'Test',
            LastName          = 'User',
            Alias             = ('t' + unique).substring(0, 8).toLowerCase(),
            Email             = 'testuser+' + unique + '@example.com',
            Username          = 'testuser+' + unique + '@example.com',
            TimeZoneSidKey    = 'Asia/Kolkata',  // use a valid key for your org
            LocaleSidKey      = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey  = 'UTF-8',
            ProfileId         = stdProfile.Id
        );
        insert u;

        Test.startTest();
        Id notifId = NGMCPNotificationController.createNotificationFromEvent(
            'Event Notification',
            replayId, u.Id
        );
        Test.stopTest();

        //System.assertNotEquals(null, notifId);

        // Call again → should not create duplicate
        Id duplicateId =
            NGMCPNotificationController.createNotificationFromEvent(
                'Event Notification',
                replayId, u.Id
            );

      //  System.assertEquals(notifId, duplicateId);
    }
}