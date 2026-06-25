@isTest(SeeAllData=false)
public class TestPermitToWorkEmailHandler {
public static testMethod void EmailWithAttachmentTester()
{
        Permit_To_Work__c permit = new Permit_To_Work__c();
    	permit.Contact_Email__c = 'adam.pinder@nationalgrid.com';
    	permit.Confirm_Contact_Email__c = 'adam.pinder@nationalgrid.com';
    	permit.Contact_Phone_Number__c = '0121123456';
    	permit.Engineers_Full_Name__c = 'Alan Engineer';
    	permit.Expected_End_Date__c = Date.today();
    	permit.Expected_Start_Date__c = Date.today();
    	permit.risk_asphyxiating__c = true;
    	permit.MPRN__c = '1234567890';
    	permit.Our_Work_Order_Ref__c = '123455';
    	permit.Service_Provider__c = 'Penspen';
    	permit.Site_Name__c = 'Lion Pub';
    	permit.Site_Address__c = '1 high st, solihull';
    	permit.Site_Postcode__c = 'NG1 1LA';
    
        insert permit;
        
        // Create a new email, envelope object and Attachment
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

    	Messaging.InboundEmail email = new Messaging.InboundEmail();
        
        email.subject = 'Permit To Work: 12345 [ref:' + permit.Id + ' :ref]';
    
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye';
    	email.toAddresses = new String[]{'adam.pinder@nationalgrid.com'};
    	email.fromAddress = 'adam.pinder@nationalgrid.com';
        envelope.fromAddress = 'adam.pinder@nationalgrid.com';

    	Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
		
    	binaryAttachment.Filename = 'test.pdf';
        binaryAttachment.body = blob.valueOf('my attachment text');

    	email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
        
        PermitToWorkEmailHandler permitHandler = new PermitToWorkEmailHandler();
    
        Messaging.InboundEmailResult result = permitHandler.handleInboundEmail(email, envelope);
		if (result == null)
            System.assert(true);
    	else
            System.assert(false);
    }
public static testMethod void EmailWithRefErrorTester()
{
        Permit_To_Work__c permit = new Permit_To_Work__c();
    	permit.Contact_Email__c = 'adam.pinder@nationalgrid.com';
    	permit.Confirm_Contact_Email__c = 'adam.pinder@nationalgrid.com';
    	permit.Contact_Phone_Number__c = '0121123456';
    	permit.Engineers_Full_Name__c = 'Alan Engineer';
    	permit.Expected_End_Date__c = Date.today();
    	permit.Expected_Start_Date__c = Date.today();
    	permit.risk_asphyxiating__c = true;
    	permit.MPRN__c = '1234567890';
    	permit.Our_Work_Order_Ref__c = '123455';
    	permit.Service_Provider__c = 'Penspen';
    	permit.Site_Name__c = 'Lion Pub';
    	permit.Site_Address__c = '1 high st, solihull';
    	permit.Site_Postcode__c = 'NG1 1LA';
    
        insert permit;
        
        // Create a new email, envelope object and Attachment
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

    	Messaging.InboundEmail email = new Messaging.InboundEmail();
        
        email.subject = 'Permit To Work: 12345 [ref:' + permit.Id + ' ref]';
    
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye';
    	email.toAddresses = new String[]{'adam.pinder@nationalgrid.com'};
    	email.fromAddress = 'adam.pinder@nationalgrid.com';
        envelope.fromAddress = 'adam.pinder@nationalgrid.com';

    	Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
		
    	binaryAttachment.Filename = 'test.pdf';
        binaryAttachment.body = blob.valueOf('my attachment text');

    	email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
        
        PermitToWorkEmailHandler permitHandler = new PermitToWorkEmailHandler();
    
        Messaging.InboundEmailResult result = permitHandler.handleInboundEmail(email, envelope);
		if (result != null)
            System.assert(true);
    	else
            System.assert(false);
    }
public static testMethod void EmailWithRefLengthErrorTester()
{
        Permit_To_Work__c permit = new Permit_To_Work__c();
    	permit.Contact_Email__c = 'adam.pinder@nationalgrid.com';
    	permit.Confirm_Contact_Email__c = 'adam.pinder@nationalgrid.com';
    	permit.Contact_Phone_Number__c = '0121123456';
    	permit.Engineers_Full_Name__c = 'Alan Engineer';
    	permit.Expected_End_Date__c = Date.today();
    	permit.Expected_Start_Date__c = Date.today();
    	permit.risk_asphyxiating__c = true;
    	permit.MPRN__c = '1234567890';
    	permit.Our_Work_Order_Ref__c = '123455';
    	permit.Service_Provider__c = 'Penspen';
    	permit.Site_Name__c = 'Lion Pub';
    	permit.Site_Address__c = '1 high st, solihull';
    	permit.Site_Postcode__c = 'NG1 1LA';
    
        insert permit;
        
        // Create a new email, envelope object and Attachment
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

    	Messaging.InboundEmail email = new Messaging.InboundEmail();
        
        email.subject = 'Permit To Work: 12345 [ref:' + permit.Id + 'aa :ref]';
    
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye';
    	email.toAddresses = new String[]{'adam.pinder@nationalgrid.com'};
    	email.fromAddress = 'adam.pinder@nationalgrid.com';
        envelope.fromAddress = 'adam.pinder@nationalgrid.com';

    	Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
		
    	binaryAttachment.Filename = 'test.pdf';
        binaryAttachment.body = blob.valueOf('my attachment text');

    	email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
        
        PermitToWorkEmailHandler permitHandler = new PermitToWorkEmailHandler();
    
        Messaging.InboundEmailResult result = permitHandler.handleInboundEmail(email, envelope);
		if (result != null)
            System.assert(true);
    	else
            System.assert(false);
    }

}