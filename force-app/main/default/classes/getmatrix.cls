public class getmatrix {
 Integer count = 0;
          
    public PageReference incrementCounter() {
        count++;
        return null;
    }
        public Integer getCount() {
        return count;
    }

public list <Team_Capability_Matrix__c> getList ()

{

List <Team_Capability_Matrix__c> teamlist = Database.query('Select Id, Name, Commercialityim__c, Contract_Managementim__c, Customerim__c, Data_Managementim__c, Performance_Excellenceim__c, Project_Managementim__c,	Stakeholderim__c From Team_Capability_Matrix__c') ;

return teamlist;
}
}