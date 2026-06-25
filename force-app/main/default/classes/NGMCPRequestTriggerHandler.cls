public with sharing class NGMCPRequestTriggerHandler {
    
    public static void handleAfterUpdate(
        List<NGMCP_Request__c> newList,
        Map<Id, NGMCP_Request__c> oldMap
    ) {
        if (newList == null || newList.isEmpty()) {
            return;
        }
        
        Map<Id, Schema.RecordTypeInfo> rtMap =
            NGMCP_Request__c.SObjectType.getDescribe().getRecordTypeInfosById();
        List<NGMCP_Notification_Event__e> eventsToPublish = new List<NGMCP_Notification_Event__e>();
        
        for (NGMCP_Request__c req : newList) {
            
            NGMCP_Request__c oldReq = oldMap.get(req.Id);
            if (oldReq == null) continue;
            
            String recordTypeName = rtMap.containsKey(req.RecordTypeId)
                ? rtMap.get(req.RecordTypeId).getDeveloperName()
                : null;
            
            if (String.isBlank(recordTypeName)) continue;
            
            String message;
            
            /* -------- DATA & TECHNICAL QUERY STATUS NOTIFICATIONS -------- */
            if (
                recordTypeName == 'NGMCP_Enquiry' &&
                req.NGMCP_Status__c != oldReq.NGMCP_Status__c
            ) {
                
                if (req.NGMCP_Status__c == 'Resolved') {
                    message = 'Your Service Request ' + req.NGMCP_SR_Ticket__c +
                        ' has been now updated to Resolved. To view the request, please use the SR Number search on the home page.';
                }
                else if (req.NGMCP_Status__c == 'Additional Information Requested') {
                    message = 'Additional Information Requested for Service Request number ' +
                        req.NGMCP_SR_Ticket__c + '. To view the request and respond, please use the SR Number search on the home page.';
                }
                else if (req.NGMCP_Status__c == 'Reminder for Additional Information') {
                    message = 'Reminder for Additional Information for Service Request number ' +
                        req.NGMCP_SR_Ticket__c + '. To view the request and respond, please use the SR Number search on the home page.';
                }
            }
            
            
            /* ---------------- QUOTATION STATUS ---------------- */
            else if (
                req.NGMCP_Quotation_Status__c != oldReq.NGMCP_Quotation_Status__c
            ) {
                
                if (req.NGMCP_Quotation_Status__c == 'Customer approved quotation') {
                    message = 'The quotation for Service Request number ' +
                        req.NGMCP_SR_Ticket__c +
                        ' has been successfully accepted on your behalf.';
                }
                else if (
                    req.NGMCP_Quotation_Status__c ==
                    'Waiting for Customer\'s Quote Approval'
                ) {
                    message = 'A quotation in Service Request ' + req.NGMCP_SR_Ticket__c +
                        ' is ready for your review. To view the request and respond, please use the SR Number search on the home page.';
                }
                else if (
                    req.NGMCP_Quotation_Status__c ==
                    'Customer Rejected quotation'
                ) {
                    message = 'The quotation for Service Request number ' +
                        req.NGMCP_SR_Ticket__c +
                        ' has been successfully rejected on your behalf';
                }
            }
            else if (
                recordTypeName == 'AMR' &&
                req.NGMCP_Status__c != oldReq.NGMCP_Status__c
            ) {
                /* -------- NEW CONDITION : On Hold -> Submitted -------- */
                if (
                    oldReq.NGMCP_Status__c == 'On Hold' &&
                    req.NGMCP_Status__c == 'Submitted'
                ) {
                    
                    
                    if (req.NGMCP_Job_Type__c == 'RMVE') {
                        
                        message =
                            'AMR Stop is Processed and AMR Remove Request ' +
                            req.NGMCP_SR_Ticket__c +
                            ' is Submitted';
                        
                    }
                    else if (req.NGMCP_Job_Type__c == 'STRT') {
                        
                        message =
                            'Exchange of Non Pulsing Meter Processed and AMR Install Request ' +
                            req.NGMCP_SR_Ticket__c +
                            ' is Submitted';
                        
                    }
                    
                }
                
                /* -------- EXISTING CONDITIONS -------- */
                else if (req.NGMCP_Status__c == 'Terminated') {
                    
                    message = 'AMR request ' + req.NGMCP_SR_Ticket__c +
                        ' has been aborted due to no pulse output. To view the request, please use the SR Number search on the home page';
                    
                }
                
                else if (req.NGMCP_Status__c == 'Completed') {
                    
                    message = 'AMR request ' + req.NGMCP_SR_Ticket__c +
                        ' has been completed. To view the request, please use the SR Number search on the home page';
                    
                }
                
            }
            if (String.isBlank(message)) continue;
            /* ---------------- PUBLISH PLATFORM EVENT ---------------- */
            eventsToPublish.add(
                new NGMCP_Notification_Event__e(
                    NGMCP_Message__c = message,
                    NGMCP_User_Id__c = req.CreatedById,
                    NGMCP_Request_Id__c = req.Id
                )
            );
        }
        if (!eventsToPublish.isEmpty()) {
            EventBus.publish(eventsToPublish);
        } 
    }
    public static void handleAfterInsert(List<NGMCP_Request__c> newList){
        List<NGMCP_Request__c> updateList = new List<NGMCP_Request__c>();
        for(NGMCP_Request__c req : newList){
            if(req.NGMCP_Send_Job_to_RICO__c == 'Yes'){
                NGMCP_Request__c reqToUpdate = new NGMCP_Request__c();
                
                reqToUpdate.Id = req.Id;
                
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_SR_Ticket__c.isUpdateable()){
                    reqToUpdate.NGMCP_SR_Ticket__c = req.Name;
                }
                
                updateList.add(reqToUpdate);
            }
        }
        if(!updateList.isEmpty() && Schema.sObjectType.NGMCP_Request__c.isUpdateable()){
            update updateList;
        }
    }
   public static void dateFormatFix(List<NGMCP_Request__c> newRecords, Boolean isInsert) {
    for (NGMCP_Request__c req : newRecords) {
        formatDateField(req, isInsert, 'NGMCP_Target_Start__c');
        formatDateField(req, isInsert, 'NGMCP_Target_Finish_Date__c');
    }
}
 
private static void formatDateField(NGMCP_Request__c req, Boolean isInsert, String fieldName) {
    String newValue = (String) req.get(fieldName);
 
    if (String.isBlank(newValue)) {
        return;
    }
 
    if (isInsert) {
        req.put(fieldName, NGMCP_EnquiriesHandler.formatToDDMMYYYY(newValue));
    } else {
        NGMCP_Request__c oldRecord = (NGMCP_Request__c) Trigger.oldMap.get(req.Id);
        String oldValue = (String) oldRecord.get(fieldName);
 
        if (newValue != oldValue) {
            req.put(fieldName, NGMCP_EnquiriesHandler.formatToDDMMYYYY(newValue));
        }
    }
} 
}