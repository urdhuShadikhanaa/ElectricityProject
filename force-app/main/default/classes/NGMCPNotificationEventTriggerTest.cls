@isTest
public class NGMCPNotificationEventTriggerTest {

    @TestSetup
    static void setupTestData() {
        Profile stdProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];

        String unique = String.valueOf(DateTime.now().getTime());
        insert new User(
            FirstName         = 'NGMCP',
            LastName          = 'NotifyUser',
            Alias             = ('n' + unique).substring(0, 8).toLowerCase(),
            Email             = 'ngmcp.notify+' + unique + '@example.com',
            Username          = 'ngmcp.notify+' + unique + '@example.com',
            TimeZoneSidKey    = 'Asia/Kolkata',
            LocaleSidKey      = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey  = 'UTF-8',
            ProfileId         = stdProfile.Id,
            IsActive          = true
        );
    }

    private static User getTestUser() {
        return [
            SELECT Id
            FROM User
            WHERE LastName = 'NotifyUser'
            AND IsActive = true
            LIMIT 1
        ];
    }

    @isTest
    static void testNotificationEventCreatesRecord() {
        User u = getTestUser();

        NGMCP_Notification_Event__e evt = new NGMCP_Notification_Event__e(
            NGMCP_Message__c    = 'Test Notification',
            NGMCP_User_Id__c    = String.valueOf(u.Id),
            NGMCP_Request_Id__c = null
        );

        Test.startTest();
        EventBus.publish(evt);
        Test.stopTest();

        List<NGMCP_Notification__c> records = [
            SELECT Id, Message__c, User__c, Is_Read__c, Event_Replay_Id__c
            FROM NGMCP_Notification__c
            WHERE User__c = :u.Id
            AND Message__c = 'Test Notification'
        ];

        System.assertEquals(1, records.size(), 'One notification should be created');
        System.assertEquals('Test Notification', records[0].Message__c);
        System.assertEquals(false, records[0].Is_Read__c);
        System.assertNotEquals(null, records[0].Event_Replay_Id__c);
    }

    @isTest
    static void testNullUserIdDoesNotCreateRecord() {
        NGMCP_Notification_Event__e evt = new NGMCP_Notification_Event__e(
            NGMCP_Message__c = 'Missing User Notification',
            NGMCP_User_Id__c = null
        );

        Test.startTest();
        EventBus.publish(evt);
        Test.stopTest();

        Integer countRecords = [
            SELECT COUNT()
            FROM NGMCP_Notification__c
            WHERE Message__c = 'Missing User Notification'
        ];

        System.assertEquals(0, countRecords, 'Events without a user id should be skipped');
    }

    @isTest
    static void testMultipleEventsCreateMultipleRecords() {
        User u = getTestUser();

        Test.startTest();
        EventBus.publish(new NGMCP_Notification_Event__e(
            NGMCP_Message__c = 'First Notification',
            NGMCP_User_Id__c = String.valueOf(u.Id)
        ));
        EventBus.publish(new NGMCP_Notification_Event__e(
            NGMCP_Message__c = 'Second Notification',
            NGMCP_User_Id__c = String.valueOf(u.Id)
        ));
        Test.stopTest();

        Integer countRecords = [
            SELECT COUNT()
            FROM NGMCP_Notification__c
            WHERE User__c = :u.Id
            AND Message__c IN ('First Notification', 'Second Notification')
        ];

        System.assertEquals(2, countRecords, 'Each published event should create one record');
    }
}