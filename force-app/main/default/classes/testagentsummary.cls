@isTest
public class testagentsummary {
public static String[] csvFileLinesa;
    public static Blob csvFileBodya;
 static testmethod void Testagentemail()
   
   {
           VCC_Reporting_Object__c vc = new VCC_Reporting_Object__c();
       
       String csvRecordDataa = 'Agent_Id__c,Agent_Name1__c,Name,Inbound_Contacts__c,Outbound_contacts__c,Field1,Feild2,Feild3,Field4,Unavailable_Time__c,Available_Time__c,Refused__c\n'+String.Valueof(vc.id)+',123,john,john,30,25,0,0,0,0,456,666,2';
insert vc;
   String str = csvRecordDataa + csvRecordDataa;
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
  attachment.body = blob.valueOf(str);
  attachment.fileName = 'textfileone.csv';
  attachment.mimeTypeSubType = 'application/vnd.ms-excel';
       email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };{
  csvFileBodya = Blob.valueOf(str);
        String csvAsStringa = csvFileBodya.toString();
        csvFileLinesa = csvAsStringa.split('\n'); 
  
   
  // call the email service class and test it with the data in the testMethod
  agentsummary  agent=new agentsummary ();
  agent.handleInboundEmail(email, env);
           test.stopTest(); 
         }
       }}