public with sharing class accountcontroller {
   @AuraEnabled
    public static List<Account> getAccounts() {
        List<Account> Accounts =
                [SELECT Id, Name, Overall_Feedback__c, Average_feedback_rating__c, Asset_Procurement__c FROM Account where Asset_Procurement__c= true order by Average_feedback_rating__c nulls last];
       
        return Accounts;
    }
}