@isTest
public class testdisplaybasedonpicklistchoice {

static testMethod void testMethod1() 
	{
		Flange_Size__c FS = new Flange_Size__c();
		FS.Bolt_Size__c = '5';
        FS.Name = 'Test';
        FS.Number_of_Bolts__c= '5';
        FS.Class__c= 'PN16';
        FS.Flange_Diameter__c= '200';
		insert FS;
		
 {
        
        String searchKey ='PN16';
     DisplayBasedOnPicklistC.getFlangeName();
        DisplayBasedOnPicklistC.getAllflanges();
     DisplayBasedOnPicklistC.getflanges(searchKey);
    }

}
    
}