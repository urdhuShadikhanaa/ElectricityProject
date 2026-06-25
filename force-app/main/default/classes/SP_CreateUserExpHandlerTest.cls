@isTest
public class SP_CreateUserExpHandlerTest {
    
    @testSetup
    private static void testData(){
        Account acct = new Account(Name='group account', SP_Account_Type__c='NTP');
        insert acct;
        Contact c = new Contact(FirstName='test', LastName='contacttest', Email = 'test@contact.com', AccountId=acct.id);
        insert c;
        
        String ref = c.id;
    }

    @isTest
    private static void testCreateFFAUserWithConId(){
        
        Account acct = new Account(Name='test accounttest');
        insert acct;
        Contact c = new Contact(FirstName='test', LastName='contacttest1', Email = 'test@contact1.com', AccountId=acct.id);
        insert c;
        List<id> ids = new List<id>();
        ids.add(c.Id);
        Test.startTest();
        SP_CreateUserExpHandler.createFFAUser(ids);
        Test.stopTest();
    }
    
     @isTest
    private static void testCreateFFAUserWithoutConId(){
        List<id> ids = new List<id>();
        Test.startTest();
        SP_CreateUserExpHandler.createFFAUser(ids);
        Test.stopTest();
    }
     
    @isTest
    private static void testAssignPublicGroup(){
        
        /*
         * 
         * 
        Account acct = new Account(Name='group account', SP_Account_Type__c='NTP');
        insert acct;
        Contact c = new Contact(FirstName='test', LastName='contacttest', Email = 'test@contact.com', AccountId=acct.id);
        insert c;
        */
        //Group g = new Group(Name='SP TestOnly');
        //insert g;
        Contact c = [select id, firstname, lastname, email, Account.SP_Account_Type__c from contact where lastname =: 'contacttest' and Account.SP_Account_Type__c='NTP' limit 1];
        system.debug('+++'+c.id);
        String ffaProfile = 'FFA Exp Site Service Partner Back Office';
        Profile profileFFA = [select id, name from profile where name =: ffaProfile];
             
        Test.startTest();
        User u = new User();
        u.FirstName = c.FirstName;
        u.LastName= c.LastName;
        u.Email= c.Email;
        u.Username= c.Email;
        u.ContactId = c.Id;
        u.Alias = c.LastName.left(8);
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'Europe/London';
        u.ProfileId = profileFFA.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        
        insert u;
        Test.stopTest();
    }

}