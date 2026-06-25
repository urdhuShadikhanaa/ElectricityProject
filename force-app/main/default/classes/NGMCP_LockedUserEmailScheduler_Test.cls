@isTest
public class NGMCP_LockedUserEmailScheduler_Test {

    private static final String TEST_USER_EMAIL = 'testuser@example.com';

    @testSetup
    static void setupData() {

        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'NGMCP_Gas Supplier Agent'
            LIMIT 1
        ];

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'contact@test.com',
            AccountId = acc.Id
        );
        insert con;

        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = TEST_USER_EMAIL,
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            Alias = 'tusr',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,
            ContactId = con.Id,
            Lock_Email_Sent__c = false
        );
        insert u;
    }

    @isTest
    static void testProcessLockedUsers() {

        Test.startTest();

        
        NGMCP_LockedUserEmailScheduler.processLockedOrFrozenUsers(10, true);

        Test.stopTest();

        User u = [
            SELECT Lock_Email_Sent__c
            FROM User
            WHERE Email = :TEST_USER_EMAIL
            LIMIT 1
        ];

        System.assertEquals(
            false,
            u.Lock_Email_Sent__c,
            'Flag should remain false in test context because no locked UserLogin records can be simulated'
        );
    }

    @isTest
    static void testResetFlag() {

        User u = [
            SELECT Id, Email, Lock_Email_Sent__c, Profile.Name
            FROM User
            WHERE Email = :TEST_USER_EMAIL
            LIMIT 1
        ];

        u.Lock_Email_Sent__c = true;
        update u;

        Test.startTest();

        NGMCP_LockedUserEmailScheduler.resetEmailFlagForUnlockedUsers();

        Test.stopTest();

        User updatedUser = [
            SELECT Lock_Email_Sent__c
            FROM User
            WHERE Email = :TEST_USER_EMAIL
            LIMIT 1
        ];

        System.assertEquals(
            false,
            updatedUser.Lock_Email_Sent__c,
            'Flag should reset to false because test user is not actually locked'
        );
    }

  
}