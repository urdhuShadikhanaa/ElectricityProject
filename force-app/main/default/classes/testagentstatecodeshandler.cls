@isTest
public class testagentstatecodeshandler {
public static String[] csvFileLinesc;
    public static Blob csvFileBodyc;
 static testmethod void Testagentemail1()
   
   {
           VCC_Reporting_Object__c vc1 = new VCC_Reporting_Object__c();
       
       String csvRecordDatac = 'Agent_Id__c,Date__c,Name,Agent_state_code__c,Duration__c\n'+String.Valueof(vc1.id)+',123,2022 03,john,lunch';
insert vc1;
   String strc = csvRecordDatac + csvRecordDatac;
     // create a new email and envelope object
  Test.startTest();   
   Messaging.InboundEmail email = new Messaging.InboundEmail() ;
   Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
   Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();   
   
   // setup the data for the email
   
  email.subject = 'Test';
  email.fromAddress = 'someaddress@email.com';
  email.plainTextBody='email body';
 
  // add an Binary attachment
  Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
  attachment.body = blob.valueOf(strc);
  attachment.fileName = 'textfileone.csv';
  attachment.mimeTypeSubType = 'application/vnd.ms-excel';
       email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };{
  csvFileBodyc = Blob.valueOf(strc);
        String csvAsStringc = csvFileBodyc.toString();
        csvFileLinesc = csvAsStringc.split('\n'); 
  
   
  // call the email service class and test it with the data in the testMethod
  agentstatecodeshandler  agentc =new agentstatecodeshandler ();
  agentc.handleInboundEmail(email, env);
           test.stopTest(); 
         }
       }
}