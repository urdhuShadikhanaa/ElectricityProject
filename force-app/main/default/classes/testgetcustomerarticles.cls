@isTest
public class testgetcustomerarticles {
    static testMethod void testarticleList (){
    List<Knowledge__kav> k = new List<Knowledge__kav>();
    for (Integer count = 0; count < 5; count++) {
        k.add(new Knowledge__kav (Group__c = 'Frequently asked questions (FAQs)',Summary = 'Hello'+count, Title ='Test'+count, UrlName = 'Arse'+count));
    }
        
    insert k;
   
    Test.startTest();
        getcustomerarticles.getknowledge();
    Test.stopTest();
    Knowledge__kav KV = [select Id from Knowledge__kav LIMIT 1];
    
    
}


}