@isTest
public class testdisplaycontractreg {
static testMethod void testMethod1() 
	{
		Non_Meter_Items__c NMI = new Non_Meter_Items__c();
		NMI.np_Make__c = 'Hello';
        NMI.Name = 'Test';
        NMI.amalgam_for_search__c = 'Blah';
        NMI.Supplier_Price__c = 100;
        NMI.np_Model__c = 'This';
        NMI.Classification__c = 'Regulators';
		insert NMI;
		
 {
        
        String searchKey ='Test';
        displaycontractreg.fetchContracts(searchKey);
    }

}

}