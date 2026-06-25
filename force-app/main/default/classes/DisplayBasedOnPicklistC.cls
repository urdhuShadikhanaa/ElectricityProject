public class DisplayBasedOnPicklistC {
  @AuraEnabled
    public static List<String> getFlangeName(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Flange_Size__c.Class__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List<Flange_Size__c> getflanges(String cClass) {
        List<Flange_Size__c> flanges = [SELECT Id, Name, Class__c, Bolt_Size__c, Flange_Diameter__c, Number_of_Bolts__c, PCD__c, Size__c, Thickness_Cast_Iron__c, Thickness_Copper_Alloy__c, Thickness_Steel__c FROM Flange_Size__c WHERE Name=:cClass];
        return flanges;
    }
    
    @AuraEnabled
    public static List<Flange_Size__c> getAllflanges() {
        List<Flange_Size__c> allflanges = [SELECT Id, Name,Class__c, Bolt_Size__c, Flange_Diameter__c, Number_of_Bolts__c, PCD__c,Size__c, Thickness_Cast_Iron__c, Thickness_Copper_Alloy__c, Thickness_Steel__c FROM Flange_Size__c];
        return allflanges;
    }
}