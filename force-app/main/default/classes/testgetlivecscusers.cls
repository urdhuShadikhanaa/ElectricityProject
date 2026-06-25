@istest
public class testgetlivecscusers {

public static testMethod void getList(){
    
   getlivecscusers getthem = new getlivecscusers();  
List<User> ulist = new List<User>();

for(Integer i=0 ;i<50;i++){
User u = new User(FirstName='Clara'+i,On_a_call__c=TRUE, LastName='Peters', Username='arseface@nob.com', Email='hello@hello.com',Alias='hello',TimeZoneSidKey='Europe/London',LocaleSidKey = 'en_GB', EmailEncodingKey = 'ISO-8859-1', ProfileId = '00e1t000001Yc3x', LanguageLocaleKey='en_US');
ulist.add(u);
     PageReference pageRef = Page.ListCallCentreUsers;
     
	  pageRef.getParameters().put('id', String.valueOf(u.Id));
	  
        Test.setCurrentPage(pageRef);
    getthem.incrementCounter();
    getthem.getCount();
}

getthem.getList();
List<user> userlist = Database.query('select FirstName,On_a_call__c from User');
System.debug(userlist);
    
    
}
}