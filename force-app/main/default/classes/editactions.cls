// This apex class is related to BusinessChange Application

public class editactions {
@AuraEnabled
    public static List<Actions__c> getActions(){
        return [SELECT Id, Complete__c, Action__c,indicator__c,TYpe__c, Name, Assignee__c, Due_Date__c FROM Actions__c WHERE Complete__c < 100 ORDER BY Due_Date__c ASC];
    }
    @AuraEnabled
    public static boolean updateActions(List<Actions__c> accList){
        try {
            update accList;
            return true;
        } catch(Exception e) {
            return false;
        }
    }
}