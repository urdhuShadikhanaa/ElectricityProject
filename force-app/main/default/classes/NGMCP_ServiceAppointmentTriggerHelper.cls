public with sharing class NGMCP_ServiceAppointmentTriggerHelper {

    private static final Set<String> VALID_STATUSES = new Set<String>{
        'Cannot Complete', 'Completed', 'Cancelled', 'Enroute', 'Arrived'
    };

    public static void handleAfterUpdate(List<ServiceAppointment> newList, Map<Id, ServiceAppointment> oldMap) {
        if (newList == null || newList.isEmpty() || oldMap == null) {
            return;
        }

        Map<Id, Id> saToWo = new Map<Id, Id>();
        Map<Id, String> saToSRNumber = new Map<Id, String>();  
        for (ServiceAppointment sa : newList) {


            ServiceAppointment oldSa = oldMap.get(sa.Id);

            if (oldSa == null) {
                continue;
            }

            if (sa.Status == null) {
                continue;
            }

            if (sa.Status == oldSa.Status) {
                continue;
            }

            if (!VALID_STATUSES.contains(sa.Status)) {
                continue;
            }

            if (sa.FFA_Work_Order__c == null) {
                continue;
            }


            saToWo.put(sa.Id, sa.FFA_Work_Order__c);
        }

        if (saToWo.isEmpty()) {
            return;
        }


        List<WorkOrder> woList = [
            SELECT Id, NGMCP_Service_Request_Number__c
            FROM WorkOrder
            WHERE Id IN :saToWo.values()
        ];

        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>();
        for (WorkOrder wo : woList) {
            woMap.put(wo.Id, wo);
        }

        if (woMap.isEmpty()) {
            return;
        }

        Set<String> srNumbers = new Set<String>();
        for (WorkOrder w : woList) {
            if (w.NGMCP_Service_Request_Number__c != null) {
                srNumbers.add(w.NGMCP_Service_Request_Number__c);
            }
        }


        List<NGMCP_Request__c> reqList = [
            SELECT Id, Name, CreatedById, NGMCP_SR_Ticket__c
            FROM NGMCP_Request__c
            WHERE NGMCP_SR_Ticket__c IN :srNumbers
        ];

        Map<String, NGMCP_Request__c> srToRequest = new Map<String, NGMCP_Request__c>();
        for (NGMCP_Request__c req : reqList) {
            srToRequest.put(req.NGMCP_SR_Ticket__c, req);
        }

        
        List<NGMCP_Notification_Event__e> eventsToPublish = new List<NGMCP_Notification_Event__e>();       

        for (Id saId : saToWo.keySet()) {


            WorkOrder wo = woMap.get(saToWo.get(saId));
            if (wo == null) {
                continue;
            }

            String srNumber = wo.NGMCP_Service_Request_Number__c;
            if (srNumber == null) {
                continue;
            }


            NGMCP_Request__c req = srToRequest.get(srNumber);
            if (req == null) {
                continue;
            }


            ServiceAppointment updatedSA;
            for (ServiceAppointment newSa : newList) {
                if (newSa.Id == saId) {
                    updatedSA = newSa;
                    break;
                }
            }

            String statusText = updatedSA != null ? updatedSA.Status : '';
            Id targetUserId = req.CreatedById;

            String finalMsg = 'Your Service Request "' + srNumber +
                              '" has been now updated to "' + statusText +
                              '". To view the request, please use the SR Number search on the home page.';


            NGMCP_Notification_Event__e evt = new NGMCP_Notification_Event__e(
                NGMCP_Message__c = finalMsg,
                NGMCP_Service_Appointment_Id__c = saId,
                NGMCP_User_Id__c = String.valueOf(targetUserId)
            );

            eventsToPublish.add(evt);
            
        }

        if (!eventsToPublish.isEmpty()) {
            EventBus.publish(eventsToPublish);
        } 
    }

    @AuraEnabled(cacheable=true)
    public static String fetchSessionId() {
        return UserInfo.getSessionId();
    }
}