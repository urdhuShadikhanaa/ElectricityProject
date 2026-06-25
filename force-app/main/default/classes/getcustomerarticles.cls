public with sharing class getcustomerarticles {
    @AuraEnabled
    public static List<Knowledge__kav> getknowledge() {
        return [SELECT Id, ArticleTotalViewCount, ArticleCreatedDate, UrlName,test__c,	Group__c, 	Full_Description__c, IsLatestVersion,	PublishStatus, 	Summary, Title FROM Knowledge__kav WHERE  PublishStatus='Online'AND Group__c includes ('Frequently asked questions (FAQs)')ORDER BY Title ASC];
    }
}