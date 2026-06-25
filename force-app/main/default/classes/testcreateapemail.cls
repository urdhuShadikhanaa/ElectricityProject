/*
** Description: This testclass is used in CRM**
*/
@isTest
private class testcreateapemail {
    
    static testMethod void testcreate() {
        AP_Email__c ap = new AP_Email__c(); 
        ap.Subject__c = 'hello'; 
        ap.Name = 'hello'; 
        ap.Email_Body__c = 'plain text'; 
        ap.Email_Body_html__c = 'html text'; 
        ap.From_Email__c = 'clara@clara.com';
        ap.cc_email_s__c = 'test@test.com';
        ap.To_Address__c = 'test@test1.com';
        ap.Sent__c = True;
        insert ap;  
        
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        email.fromAddress = 'box.ngmbusinesschange@nationalgas.com';
        email.subject = 'test';
        env.fromAddress = 'user@hello.com';
        email.plainTextBody = 'this is a plain text body';
        email.htmlBody = 'this is an html  body';
        Messaging.InboundEmail.BinaryAttachment battachment = new Messaging.InboundEmail.BinaryAttachment();
        bAttachment.body = blob.valueOf('my attachment text');
        bAttachment.fileName = 'textfileone.txt';
        bAttachment.mimeTypeSubType = 'text/plain';
        ContentVersion cVersion = new ContentVersion();
        cVersion.VersionData = Blob.valueOf('my attachment text');
        cVersion.Title = 'textfileone.txt';
        cVersion.FirstPublishLocationId = ap.Id;
        cVersion.ContentLocation = 'S'; 
        cVersion.PathOnClient  = 'this is the file';
        
       
        
        email.BinaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { bAttachment };
            
            createapemail createapemailObj = new createapemail();
        createapemailObj.handleInboundEmail(email, env );
        
    }
    
    
}