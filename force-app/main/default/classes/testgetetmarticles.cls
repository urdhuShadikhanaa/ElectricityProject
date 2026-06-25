@isTest
public class testgetetmarticles {





    static testMethod void testarticleList (){
    List<Knowledge__kav> k = new List<Knowledge__kav>();
    for (Integer count = 0; count < 5; count++) {
        k.add(new Knowledge__kav (Group__c = 'SLA',Summary = 'Hello'+count, Title ='Test'+count, UrlName = 'Arse'+count));
    }
        
    insert k;
   
    Test.startTest();
        getetmarticles.getknowledge();
    Test.stopTest();
    Knowledge__kav KV = [select Id from Knowledge__kav LIMIT 1];
    
    
}

}