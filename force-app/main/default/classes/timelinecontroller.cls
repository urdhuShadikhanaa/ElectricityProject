public class timelinecontroller {

    

public List<CRM_Content__c> timList{get;set;}
    
    {
    timList = [SELECT id, Story__c,Publish__c,   RecordType.Name FROM CRM_Content__c WHERE Publish__c= TRUE AND RecordType.Name = 'Timeline' LIMIT 2];

    }
}