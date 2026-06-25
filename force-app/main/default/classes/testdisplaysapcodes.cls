@isTest
public class testdisplaysapcodes {
static testMethod void testMethod1() 
	{
		SAP_Codes_and_Items__c SAP = new SAP_Codes_and_Items__c();
		SAP.Description__c = 'Hello';
        SAP.Name = 'Test';
		insert SAP;
		
 {
        
        String searchKey ='Test';
        displaysapcodes.fetchSAPCodes(searchKey);
    }

}
    
}