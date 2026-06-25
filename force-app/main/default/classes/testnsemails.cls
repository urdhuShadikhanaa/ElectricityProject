@isTest
public class testnsemails {
public static String[] csvFileLinesa;
    public static Blob csvFileBodya;
 static testmethod void Testnsemail()
   
   {
           Case c = new Case();
       
       String csvRecordDataa = 'Origin,Status,Residence_Type__c,Priority,SuppliedEmail,Subject\n'+String.Valueof(c.id)+'Email - Non Standard,In progress,Commercial,Medium,robot.three@nationalgrid.com,AMR GPS Non standard 03.08.22';
insert c;
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
  nsemails ns=new nsemails ();
  ns.handleInboundEmail(email, env);
           test.stopTest(); 
         }
       }
}