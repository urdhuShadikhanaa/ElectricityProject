public class editrota {
@AuraEnabled
    public static List<BCHubAgenda__c> getAgenda(){
        return [SELECT Id, Host__r.FirstName,Scribe__c,Dateofhub__c,Hub_Host__c, Is_Agenda__c, In_the_past__c FROM BCHubAgenda__c WHERE In_the_past__c = FALSE AND Is_Agenda__c = TRUE ORDER BY Dateofhub__c ASC];
    }
    @AuraEnabled
    public static boolean updateAgenda(List<BCHubAgenda__c> hubList){
        try {
            update hubList;
            return true;
        } catch(Exception e) {
            return false;
        }
    }
}