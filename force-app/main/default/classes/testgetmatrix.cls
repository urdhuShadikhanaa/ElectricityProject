@istest
public class testgetmatrix {

public static testMethod void getList(){
    
   getmatrix getmat = new getmatrix();  
List<Team_Capability_Matrix__c> mlist = new List<Team_Capability_Matrix__c>();

for(Integer i=0 ;i<50;i++){
Team_Capability_Matrix__c m = new Team_Capability_Matrix__c(Name='Clara');
mlist.add(m);
     PageReference pageRef = Page.TeamCapabilityMatrix;
     
	  pageRef.getParameters().put('id', String.valueOf(m.Id));
	  
        Test.setCurrentPage(pageRef);
    getmat.incrementCounter();
    getmat.getCount();
}

getmat.getList();
List<Team_Capability_Matrix__c> matlist = Database.query('select Name from Team_Capability_Matrix__c');
System.debug(matlist);
    
    
}
}