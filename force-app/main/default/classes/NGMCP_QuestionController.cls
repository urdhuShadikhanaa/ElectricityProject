public with sharing class NGMCP_QuestionController {
    @AuraEnabled(cacheable=true)
    public static List<NGMCP_Complaint_Questionnaire__mdt> getQuestions() {
        return [SELECT Question__c, Input_Type__c, Sort_Order__c
                FROM NGMCP_Complaint_Questionnaire__mdt 
                ORDER BY Sort_Order__c ASC];
    }
}