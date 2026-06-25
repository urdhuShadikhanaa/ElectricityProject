/*
** Description: This testclass is used in CRM**
*/
@isTest
public class testdisplaymprnsummary {
static testMethod void testMethod1() 
	{
		MPRN_Summary__c MSS = new MPRN_Summary__c();
		MSS.Address__c = 'Hello';
        MSS.Name = 'Test';
		insert MSS;
		
 {
        
        String searchKey ='Test';
        displaymprnsummary.fetchMPRNS(searchKey);
    }

}
    

}