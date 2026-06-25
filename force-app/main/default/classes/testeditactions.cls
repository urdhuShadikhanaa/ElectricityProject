// This apex class is related to BusinessChange Application

@isTest
public class testeditactions {
static testmethod void  testactions()
{
 
       Actions__c a = new Actions__c(Name = 'Hello', Action__c = 'test');
        insert a;
 List<Actions__c> acc = editactions.getActions(); 
        System.assert(acc != null);
}
    @isTest
  public static void testupdateDetails() {
       List<Actions__c> acc = editactions.getActions();
         System.assertEquals(true, editactions.updateActions(acc)); 
      
      acc = null;
       System.assertEquals(false, editactions.updateActions(acc));
      acc = null;
      System.assertEquals(false, editactions.updateActions(acc));
  }
}