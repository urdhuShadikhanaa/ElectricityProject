// Description : Test class Update_EmailMessage_HandlerTest
public class UpdateChangeRequestInBCEmailHandler {
    
    string CRsubject;
    set<string> bcSubject = new set<string>();   
    Public void insertBCEmail(List<BC_Email__c> bcEmailList){
        
        List<Change_Request__c> fetchCRDetails = [Select id,CR_Number__c from Change_Request__c];
        
        List<BC_Email__c> updateBCEmail = new List<BC_Email__c>();
        Map<id, BC_Email__c> oldMap = new Map<id, BC_Email__c>();
        for(Change_Request__c crDetails : fetchCRDetails ){
            for(BC_Email__c bcEmail : bcEmailList){
                CRsubject = crDetails.CR_Number__c;                          
                if(bcEmail.Subject__c.contains(CRsubject) && bcEmail.Related_CR__c == Null){                   
                    bcEmail.Related_CR__c = crDetails.id;           
                }
            }
        }
        
    }
   
}