// This apex class is related to BusinessChange Application

@isTest
private class testcreatbcpemail {
    
    static testMethod void testcreate() {
        BC_Email__c bc = new BC_Email__c(); 
        bc.Subject__c = 'hello'; 
        bc.Name = 'hello@test.com'; 
        bc.Email_Body__c = 'plain text'; 
        bc.Email_Body_html__c = 'html text'; 
        bc.From_Email__c = 'clara@clara.com';
        bc.Classification__c = 'Inbox';
        bc.cc_email_s__c = 'test@test.com';
        bc.To_Address__c = 'test@test1.com';         
        bc.Status__c = 'Valid';
        insert bc; 
        
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        
        email.subject = 'test';
        env.fromAddress = 'user@hello.com';
        email.plainTextBody = 'this is a plain text body';
        email.htmlBody = 'this is an html  body';
        Messaging.Inboundemail.BinaryAttachment bAttachment = new Messaging.Inboundemail.BinaryAttachment();
        bAttachment.body = blob.valueOf('my attachment text');
        bAttachment.fileName = 'textfileone.txt';
        bAttachment.mimeTypeSubType = 'text/plain';
        ContentVersion cVersion = new ContentVersion();
        cVersion.VersionData = Blob.valueOf('my attachment text');
        cVersion.Title = 'textfileone.txt';
        cVersion.FirstPublishLocationId = bc.Id;
        cVersion.ContentLocation = 'S'; 
        cVersion.PathOnClient  = 'this is the file';
        
        email.BinaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { bAttachment };
            
            
            
            createbcemail createbcemailObj = new createbcemail();
        createbcemailObj.handleInboundEmail(email, env );
        
    }
    
}