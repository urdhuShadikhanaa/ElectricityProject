global class PermitToWorkEmailHandler implements Messaging.InboundEmailHandler 
{
  global Messaging.InboundEmailResult handleInboundEmail(
  Messaging.InboundEmail email,
  Messaging.InboundEnvelope envelope)
  {
    String fromAddress = email.fromAddress;
    String inSubject = email.subject;
    String htmlBody = email.htmlBody;
    
    String permitToWorkID = '';
      
    try {
        if (inSubject.indexOf('ref:') > -1 && inSubject.indexOf(':ref') > -1)
        {
            permitToWorkID = inSubject.substring(inSubject.indexOf('ref:') + 4, inSubject.indexOf(':ref')) ; 
            permitToWorkID = permitToWorkID.trim();
        }
    
        if (permitToWorkID != '' && (permitToWorkID.length() == 15 || permitToWorkID.length() == 18) &&
           [SELECT count() FROM Permit_To_Work__c WHERE Id = :permitToWorkID] > 0)
        {
            Permit_To_Work__c permit = [SELECT Id,Name,Our_Work_Order_Ref__c, Status__c FROM Permit_To_Work__c WHERE Id = :permitToWorkID LIMIT 1];
            
            if (permit.Status__c == 'Waiting_For_Job_Closure' && htmlBody.indexOf('JOB COMPLETE') > -1)
            {
                permit.Status__c = 'Job_Completed';
                update permit;
            }
            
            EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
            emailMsg.ToAddress= email.toAddresses[0];
            emailMsg.FromAddress = email.fromAddress;
            
            if (email.ccAddresses != null && email.ccAddresses.size() > 0)
                emailMsg.CcAddress = email.ccAddresses[0];
            
            emailMsg.Subject=email.subject;
            
            if (email.htmlBody != null && email.htmlBody != '')
	            emailMsg.HtmlBody=email.htmlBody;
            else
            	emailMsg.TextBody=email.plainTextBody;
            
            emailMsg.MessageDate = system.now();
            emailMsg.Status = '0';
            emailMsg.RelatedToId = permitToWorkID;
            
            insert emailMsg;
            
            if(email.binaryAttachments != null)
            {
                Attachment[] attachments = new Attachment[]{};
                    Attachment attachment=null;
                for(Integer i=0;i < email.binaryAttachments.size();i++)
                {
                    attachment= new Attachment();
                    attachment.Name = email.binaryAttachments[i].fileName;
                    attachment.Body = email.binaryAttachments[i].body;
                    //attachment.ParentId = emailMsg.Id; 
                    // add attachment directly to permit so all files in one place and no need to go into each email
                    attachment.ParentId = permit.Id;
                    attachments.add(attachment);
                }
                insert attachments;
            }
            
            return null;            
        }
        else
        {
            Messaging.InboundEmailresult result = new Messaging.InboundEmailResult();
            result.message = 'We couldn\'t locate your Permit To Work request. Please only respond by replying to the original email received from us that confirmed your Permit To Work request.\n\nRegards\n\nThe National Grid Metering Team';
            result.success = false;
            return result;
        }
    }
    catch (Exception e)
    {
        Messaging.InboundEmailresult result = new Messaging.InboundEmailResult();
        result.message = 'We were unable to process your email. Please only respond by replying to the original email received from us that confirmed your Permit To Work request.\n\nRegards\n\nThe National Grid Metering Team';
        result.success = false;
        return result;
    }
  }
}