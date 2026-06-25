// This apex class is related to CRM Application
// 1/05/2024 : Updated by Swati (Remediation Project)
// Description: Code quality Check Part of 'user is authorized' Updated Lines 25 ,42 ,55 ,59
// Updated above lines DML with as user
global class createapemail implements Messaging.InboundEmailHandler{
    List<string> ccEmailAddresss = new List<string>();
    List<string> toAddresss = new List<string>();
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        List<Attachment> attachmentList = new List<Attachment>();
        ccEmailAddresss = email.ccAddresses;
        toAddresss = email.toAddresses;
        AP_Email__c ap = new AP_Email__c(); 
        ap.cc_email_s__c = string.valueOf(ccEmailAddresss);
        ap.To_Address__c = string.valueOf(toAddresss);
        ap.Subject__c = email.Subject; 
        ap.Name = email.fromAddress; 
        ap.Email_Body__c = email.plainTextBody; 
        ap.Email_Body_html__c = email.htmlBody; 
        ap.From_Email__c = email.fromAddress; 
        ap.In_Reply_To__c = email.inReplyTo; 
        ap.Classification__c = 'Inbox'; 
        
         try{
            insert as user ap; // old Code :  insert ap;
        }catch(exception e){
            system.debug('exception Message--->'+e.getMessage());
             system.debug('exception Message--->'+e.getLineNumber());
        }
        
       
        
        // Save attachments, if any
        if(email.textAttachments!=null) {
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                ContentVersion cVersion = new ContentVersion();
                cVersion.PathOnClient  = tAttachment.fileName;
                cVersion.FirstPublishLocationId = ap.Id;
                cVersion.Title  = tAttachment.fileName;
                cVersion.VersionData  = Blob.valueOf(tAttachment.body);
                cVersion.ContentLocation = 'S'; 
                insert as user cVersion; // old Code :  insert cVersion;
            }
        }
        
        //Save any Binary Attachment
        if(email.binaryAttachments!=null){
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                ContentVersion cVersion = new ContentVersion();
                cVersion.PathOnClient  = bAttachment.fileName;
                cVersion.FirstPublishLocationId = ap.Id;
                cVersion.Title  = bAttachment.fileName;
                cVersion.VersionData  = bAttachment.body;
                cVersion.ContentLocation = 'S'; 
                insert as user cVersion;} // old Code :  insert cVersion;
        }
        
        if(!attachmentList.isEmpty()){
            insert as user attachmentList; // old Code :  insert attachmentList;
        }
        
        result.success = true;
        return result;
    }
}