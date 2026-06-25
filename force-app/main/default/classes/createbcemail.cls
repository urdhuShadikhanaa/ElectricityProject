// This apex class is related to BusinessChange Application
// 1/04/2024 : Updated by Naveen (Remediation Project)
// Description: Code quality Check Part of 'user is authorized' Updated Lines 23 ,37 ,50 ,55
global class createbcemail implements Messaging.InboundEmailHandler{
    List<string> ccEmailAddresss = new List<string>();
    List<string> toAddresss = new List<string>();
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        List<Attachment> attachmentList = new List<Attachment>();
        ccEmailAddresss = email.ccAddresses;
        toAddresss = email.toAddresses;
        BC_Email__c bc = new BC_Email__c(); 
        bc.cc_email_s__c = string.valueOf(ccEmailAddresss); 
        bc.To_Address__c = string.valueOf(toAddresss);
        bc.Subject__c = email.Subject; 
        bc.Name = email.fromAddress; 
        bc.Email_Body__c = email.plainTextBody; 
        bc.Email_Body_html__c = email.htmlBody; 
        bc.From_Email__c = email.fromAddress; 
        bc.In_Reply_To__c = email.inReplyTo; 
        bc.Classification__c = 'Inbox';                     
        try{            
            insert as user bc;  // old Code :  insert bc;
        }catch(exception e){
            system.debug('exception Message--->'+e.getMessage());
            system.debug('exception Message--->'+e.getLineNumber());
        }               
        // Save attachments, if any
        if(email.textAttachments!=null) {
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                ContentVersion cVersion = new ContentVersion();
                cVersion.PathOnClient  = tAttachment.fileName;
                cVersion.FirstPublishLocationId = bc.Id;
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
                cVersion.FirstPublishLocationId = bc.Id;
                cVersion.Title  = bAttachment.fileName;
                cVersion.VersionData  = bAttachment.body;
                cVersion.ContentLocation = 'S'; 
                insert as user cVersion; // old Code :  insert cVersion;
            }
        }
        
        if(!attachmentList.isEmpty()){
            insert as user attachmentList; // old Code :  insert attachmentList;
        }
        
        result.success = true;
        return result;
    }
}