/**
* ───────────────────────────────────────────────────────────────────┐
* Author      - Venkat Pattapu
* Organisation- Wipro
* TriggerName - serviceAppointmentTrigger
* Description - This will trigger Status Update to SAP and also define Schedule start and EndTime
*               based on slots in workorder and custom Metadata 
* Enhancements-
*              Tasks No:
* ────────────────────────────────────────────────────────────────────
*/
Trigger serviceAppointmentTrigger on ServiceAppointment (before Update,after Insert,after Update) {
    Set<id> SerializeApptIDS= new  Set<Id>();
    Set<ID> ServiceApptIds=new Set<ID>();
    
    if( Trigger.isAfter && Trigger.isUpdate ){
 		// ***  NOTIFICATION LOGIC ***
        NGMCP_ServiceAppointmentTriggerHelper.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        for(ServiceAppointment ServiceApptstatus :Trigger.new){
        System.debug('Size of new list in trigger=='+trigger.new.size());
            
            //To Priortize the sequence in Mobile Offline Mode
            
            IF((ServiceApptstatus.Status=='Enroute' && Trigger.oldMap.get(ServiceApptstatus.Id).Status!='Enroute'  && Trigger.oldMap.get(ServiceApptstatus.Id).Status!='' )){
                  String serailizedWorkorderJSON='['+json.serialize(ServiceApptstatus.id)+']';
                  String FFAStatus='Enroute';
                 workOrderServiceEngineerstatusUpdate.CompletedWorkorders(serailizedWorkorderJSON,FFAStatus);
            }
            IF((ServiceApptstatus.Status=='Arrived' && Trigger.oldMap.get(ServiceApptstatus.Id).Status!='Arrived'  && Trigger.oldMap.get(ServiceApptstatus.Id).Status!='' )){
                  String serailizedWorkorderJSON='['+json.serialize(ServiceApptstatus.id)+']';
                  String FFAStatus='Arrived';
                 workOrderServiceEngineerstatusUpdate.CompletedWorkorders(serailizedWorkorderJSON,FFAStatus);
            }
            IF(ServiceApptstatus.FFA_Long_Job_Ind__c=='Yes' && Trigger.oldMap.get(ServiceApptstatus.Id).FFA_Long_Job_Ind__c!='Yes'){
                  String serailizedWorkorderJSON='['+json.serialize(ServiceApptstatus.id)+']';
                  String FFAStatus='LongJob';
                 workOrderServiceEngineerstatusUpdate.CompletedWorkorders(serailizedWorkorderJSON,FFAStatus);
            }
            IF(ServiceApptstatus.FFA_Return_Job_Ind__c=='Yes' && Trigger.oldMap.get(ServiceApptstatus.Id).FFA_Return_Job_Ind__c!='Yes'){
                  String serailizedWorkorderJSON='['+json.serialize(ServiceApptstatus.id)+']';
                  String FFAStatus='ReturnJob';
                 workOrderServiceEngineerstatusUpdate.CompletedWorkorders(serailizedWorkorderJSON,FFAStatus);
            }
            IF(ServiceApptstatus.FFAAssignedAPI__c=='Assigned' && Trigger.oldMap.get(ServiceApptstatus.Id).FFAAssignedAPI__c!='Assigned'){
                  String serailizedWorkorderJSON='['+json.serialize(ServiceApptstatus.id)+']';
                  String FFAStatus='Assigned';
                 workOrderServiceEngineerstatusUpdate.CompletedWorkorders(serailizedWorkorderJSON,FFAStatus);
            }
            IF(ServiceApptstatus.FFAAssignedAPI__c=='Unassigned' && Trigger.oldMap.get(ServiceApptstatus.Id).FFAAssignedAPI__c!='Unassigned'){
                  String serailizedWorkorderJSON='['+json.serialize(ServiceApptstatus.id)+']';
                  String FFAStatus='Unassigned';
                 workOrderServiceEngineerstatusUpdate.CompletedWorkorders(serailizedWorkorderJSON,FFAStatus);
            }
            
            If(ServiceApptstatus.Status=='Scheduled' && Trigger.oldMap.get(ServiceApptstatus.Id).status!='Scheduled'){
                ServiceApptIds.add(ServiceApptstatus.id);
            }
        }
    }
     IF(Trigger.isAfter && Trigger.isInsert){
        FOR(ServiceAppointment reqServiceApptstatus :Trigger.new){
        system.debug('---In');
            IF(reqServiceApptstatus.Status=='None' ){
            ServiceApptIds.add(reqServiceApptstatus.id);
            }
        }
    }
    
    IF(!SerializeApptIDS.IsEmpty()){
        String serailizedAppointmentsJSON=json.serialize(SerializeApptIDS);
        system.debug('serailizedWorkorderJSON:--'+serailizedAppointmentsJSON);
           workOrderServiceEngineerstatusUpdate.CompletedWorkorders(serailizedAppointmentsJSON,null);
        }
    IF(!ServiceApptIds.isEmpty()){
        FFAServiceAppointmentSlotsHandler.changeServiceApptTime(ServiceApptIds);
        system.debug('WOIDsSent----'+ServiceApptIds);
        
    }    
}