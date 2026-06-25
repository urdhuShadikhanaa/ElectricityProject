@isTest
public class logouteventtriggertest {

public static testmethod void lgoutevetTriggersTest(){
LogoutEventStream event = new LogoutEventStream();
event.Username = 'clara';

Test.startTest(); 
EventBus.publish(new LogoutEventStream()); 
Test.stopTest();
}
}