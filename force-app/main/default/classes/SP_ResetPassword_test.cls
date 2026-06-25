@isTest
public class SP_ResetPassword_test {
@isTest
    Static void testResetUserPasswords(){
      
        User testUser=new user(FirstName='Test',LastName='User',Username='testResetPassworduser@test.com',Email='testuser@test.com',Alias='TUser',CommunityNickname='testuser',isActive=true,ProfileId=[SELECT Id FROM Profile WHERE Name='Standard User'].Id,TimeZoneSidKey='GMT',LocaleSidKey='en_US',EmailEncodingKey=
'UTF-8',LanguageLocaleKey='en_US');
       
        insert testUser;
   Test.startTest();   
        
        SP_Reset_Password.ResetUserPasswords(new List<Id>{testUser.Id});
        
   Test.stopTest();
        
        
       // User Updateduser=[SELECT Id,Name,IsActive FROM User WHERE Id=:testUser.Id];
                
    }
}