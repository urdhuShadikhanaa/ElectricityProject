@isTest
public class testinboundslareporthandler {
public static String[] csvFileLinesi;
    public static Blob csvFileBodyi;
 static testmethod void Testagentemail2()
   
   {
           VCC_Reporting_Object__c vc2 = new VCC_Reporting_Object__c();
       
       String csvRecordDatai = 'Skill_Name__c,Date__c,Name,a,s,d,f,g,h,j,k,l,z,x,v,c,In_SLA__c,Out_SLA__c,Service_Level__c\n'+String.Valueof(vc2.id)+',amr,2022 03,john,0,0,0,0,0,0,0,0,0,0,0,0,0,34,23,good';
insert vc2;
   String stri = csvRecordDatai + csvRecordDatai;
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
  attachment.body = blob.valueOf(stri);
  attachment.fileName = 'textfileone.csv';
  attachment.mimeTypeSubType = 'application/vnd.ms-excel';
       email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };{
  csvFileBodyi = Blob.valueOf(stri);
        String csvAsStringi = csvFileBodyi.toString();
        csvFileLinesi = csvAsStringi.split('\n'); 
  
   
  // call the email service class and test it with the data in the testMethod
  inboundslareporthandler  agenti =new inboundslareporthandler ();
  agenti.handleInboundEmail(email, env);
           test.stopTest(); 
         }
       }
}