/*
** Description: This class is used in CRM**
*/
global class inboundfinanceemail implements Messaging.InboundEmailHandler{
global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    
String inputString= email.subject;
String sub=inputString.substringAfter('ACC');
    String sub2=sub.substringBefore('CO');
sub = sub.trim();
    sub2 = sub2.trim();
Case co = [Select id, CRM_Complaint_Reference__c, Good_Will_Cheque_Sent__c from Case where id=:sub2];

co.Good_Will_Cheque_Sent__c = TRUE;

update co;

result.success = true;
System.debug(result);
return result;
}
}