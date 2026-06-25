@isTest
public class testeditrota {
static testmethod void  testrota()
{
 
       BCHubAgenda__c H = new BCHubAgenda__c(Scribe__c = 'Me');
        insert H;
 List<BCHubAgenda__c> bch = editrota.getAgenda(); 
        System.assert(bch != null);
}
    @isTest
  public static void testupdateDetails() {
       List<BCHubAgenda__c> bch = editrota.getAgenda();
         System.assertEquals(true, editrota.updateAgenda(bch)); 
      
      bch = null;
       System.assertEquals(false, editrota.updateAgenda(bch));
      bch = null;
      System.assertEquals(false, editrota.updateAgenda(bch));
  }
}