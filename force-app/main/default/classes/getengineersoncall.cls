public class getengineersoncall {
@AuraEnabled
    public static List<Tech_Engineer_Support__c> getEngineer(){
        return [SELECT Id, Engineer_Name__r.Name,From__c,To__c,	support__c,Engineer_on_Call__c,	Tech_Support__c,Standby_Engineer__r.Name FROM Tech_Engineer_Support__c WHERE support__c  ='no' ORDER BY From__c ASC LIMIT 30];
    }
       @AuraEnabled
    public static boolean updateEngineer(List<Tech_Engineer_Support__c> engList){
        try {
            update engList;
            return true;
        } catch(Exception e) {
            return false;
        }

}
}