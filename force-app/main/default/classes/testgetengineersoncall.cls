@isTest
public class testgetengineersoncall {
 static testMethod void testengList (){
    List<Tech_Engineer_Support__c> e = new List<Tech_Engineer_Support__c>();
    for (Integer count = 0; count < 3; count++) {
        e.add(new Tech_Engineer_Support__c (Name = 'Hello'+count));
    }
        
    insert e;
   
    Test.startTest();
        getengineersoncall.getEngineer();
    Test.stopTest();
    Tech_Engineer_Support__c TE = [select Id from Tech_Engineer_Support__c LIMIT 1];
 }
    @isTest
  public static void testupdateDetails() {
       List<Tech_Engineer_Support__c> TE = getengineersoncall.getEngineer();
         System.assertEquals(true, getengineersoncall.updateEngineer(TE));   
}
}