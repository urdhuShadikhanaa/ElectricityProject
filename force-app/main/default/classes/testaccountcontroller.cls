@isTest
public class testaccountcontroller {


static testMethod void testMethod1() 
	{
		Account Acc = new Account();
		Acc.Asset_Procurement__c = true;
        Acc.Name = 'Test';
       
       
		insert Acc;
		
 {
        
        String searchKey ='Test';
        accountcontroller.getAccounts();
    }

}
}