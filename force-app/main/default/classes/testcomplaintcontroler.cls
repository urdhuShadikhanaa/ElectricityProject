@isTest 
public class testcomplaintcontroler {


 static testMethod void testMethod1() 
 {
 Case testCase = new Case();
 testCase.Subject='Test Case' ;
 insert testCase;
 
 Test.StartTest(); 
 
  PageReference pageRef = Page.CaseDetailComplaint; 
  pageRef.getParameters().put('id', String.valueOf(testCase.Id));
  Test.setCurrentPage(pageRef);
 
  complaintcontroller testcomplaintcontroller1 = new complaintcontroller();
     
 testcomplaintcontroller1.getName();    
 testcomplaintcontroller1.getCase(); 
testcomplaintcontroller1.save(); 
 Test.StopTest();
 }
}