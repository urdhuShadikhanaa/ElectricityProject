// Description : Test class Update_EmailMessage_HandlerTest
public class Update_EmailMessage_LinkWithCRHandler {
    
    Public void insertEmailMessages(List<EmailMessage> EmailMessages){
        List<Change_Request__c> fetchCRDetails = [Select id,CR_Number__c from Change_Request__c ];        
        string subject;
        for(Change_Request__c cr : fetchCRDetails){
            for(EmailMessage eMessage : EmailMessages){
                subject = cr.CR_Number__c;              
                if(eMessage.Subject.contains(subject) && eMessage.Parent_CR__c == Null){
                    eMessage.Parent_CR__c = cr.Id;                   
                }   
            }
        }
        
    }
}