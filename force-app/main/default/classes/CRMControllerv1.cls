/*
** Description: This testclass is used in CRM**
*/public class CRMControllerv1 {
    

public List<CRM_Content__c> conList{get;set;}
    
    {
    conList = [SELECT id, Story__c,Publish__c, 	RecordType.Name FROM CRM_Content__c WHERE Publish__c= TRUE AND RecordType.Name = 'Story' LIMIT 2];

    }
}