/*
** Description: This class is used in CRM**
*/
public class getadvocacycomment {

    

public List<Account> AList{get;set;}
    
    {
    AList = [SELECT id, Date_of_Advocacy_Score__c,CRM_Advocacy_Comment__c, Name FROM Account LIMIT 1];

    }
}