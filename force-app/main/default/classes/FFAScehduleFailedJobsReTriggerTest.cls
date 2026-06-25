@isTest
public class FFAScehduleFailedJobsReTriggerTest {
    
    @isTest static void doTestMethod(){
        Test.StartTest();
        FFAScehduleFailedJobsReTrigger sh1 = new FFAScehduleFailedJobsReTrigger();

         String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); Test.stopTest(); 
    }

}