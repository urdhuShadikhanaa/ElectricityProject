/*
** Description: This class is used in FFA**
*/
@isTest(seeAllData=false)
public class TestLookupResponsibleTerritory 
{
	public static testmethod void ValidTestLookupResponsibleTerritory() 
	{
        Responsible_Territory__c rt = new Responsible_Territory__c(Name='TestTerritory',Postcode_Coverage__c='|N|NG|B|E|');
        insert rt;
        
		Test.startTest();
        
        System.debug('Valid: Before High Risk Activity insert');
        
        Permit_To_Work__c ptw = new Permit_To_Work__c(Our_Work_Order_Ref__c='NGM-5001', Service_Provider__c='Penspen',MPRN__c='123456789',Contact_Phone_Number__c='0121123456', Contact_Email__c='adam.pinder@nationalgrid.com',Confirm_Contact_Email__c='adam.pinder@nationalgrid.com', Engineers_Full_Name__c='Adam P',Site_Name__c='Test', Site_Address__c='test site address', Site_Postcode__c='N1 7GE', Expected_Start_Date__c=Date.today(),Expected_End_Date__c=Date.today(), Risk_Hot_Works__c=true);
        insert ptw;

        System.debug('Valid: After High Risk Activity insert');
        
        ptw = [select Id,Territory__c from Permit_To_Work__c where Id = :ptw.Id limit 1];

        System.debug('Valid: Retrieved High Risk Activity, checking for Territory');

        if (ptw.Territory__c != null)
        {
            System.debug('Valid: Lookup Territory Id: '+ptw.Territory__c);
            
            if(([select count() from Responsible_Territory__c where Id = :ptw.Territory__c]) > 0)
            {
                Responsible_Territory__c lookupTer = [select Id,Name from Responsible_Territory__c where Id = :ptw.Territory__c LIMIT 1];
    
                System.debug('Valid: Retrieved Territory Name: '+lookupTer.Name);
    
                System.assert(true,'Valid: Territory Name associated: '+lookupTer.Name);            
            }
            else
            {
                System.debug('Valid: Territory not null but no Lookup Territory found');
                
                System.assert(false,'Valid: Territory not null but no Lookup Territory found');            
            }
        }
        else
        {
            System.debug('Valid: No Lookup Territory');
            
        	System.assert(false,'Valid: No Territory Name associated');            
        }        

        Test.stopTest();
    }
	public static testmethod void InvalidTestLookupResponsibleTerritory() 
	{
        Responsible_Territory__c rt = new Responsible_Territory__c(Name='TestTerritory',Postcode_Coverage__c='|N|NG|B|E|');
        insert rt;
        
		Test.startTest();

        System.debug('Invalid: Before High Risk Activity insert');
        
        Permit_To_Work__c ptw = new Permit_To_Work__c(Our_Work_Order_Ref__c='NGM-5002', Service_Provider__c='Penspen',MPRN__c='123456789',Contact_Phone_Number__c='0121123456', Contact_Email__c='adam.pinder@nationalgrid.com',Confirm_Contact_Email__c='adam.pinder@nationalgrid.com', Engineers_Full_Name__c='Adam P',Site_Name__c='Test', Site_Address__c='test site address', Site_Postcode__c='SS1 7GE', Expected_Start_Date__c=Date.today(),Expected_End_Date__c=Date.today(), Risk_Hot_Works__c=true);
        insert ptw;

        System.debug('Invalid: After High Risk Activity insert');
        
        ptw = [select Id,Territory__c from Permit_To_Work__c where Id = :ptw.Id limit 1];

        System.debug('Invalid: Retrieved High Risk Activity, checking for Territory');

        if (ptw.Territory__c != null)
        {
            System.debug('Invalid: Lookup Territory associated when it should not be.');            
            
        	System.assert(false,'Invalid: Territory Name associated in error');            
        }
        else
        {
            System.debug('Invalid: No Lookup Territory');
            
        	System.assert(true,'Invalid: No Territory Name associated');            
        }            

        Test.stopTest();
    }
}