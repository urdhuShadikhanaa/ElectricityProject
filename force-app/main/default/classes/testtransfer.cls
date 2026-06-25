@isTest
public class testtransfer {
public static String[] csvFileLinesa;
    public static Blob csvFileBodya;
 static testmethod void Testagentemail()
   
   {
           VCC_Reporting_Object__c vc = new VCC_Reporting_Object__c();
       
       String csvRecordDataa = 'a,s,d,Agent_Id__c,g,Transferred_Skill__c,j,transferred_agent_to_Id__c,l,z,x,Date__c\n'+String.Valueof(vc.id)+',0,0,0,123,0,DM,0,john,0,0,0,2022 03,0,0,0,2022 03';
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
 transfer agent = new transfer ();
  agent.handleInboundEmail(email, env);
           test.stopTest(); 
         }
       }
}