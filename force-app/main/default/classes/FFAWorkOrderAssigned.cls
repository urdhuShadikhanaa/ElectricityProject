@RestResource(urlMapping='/ScheduleAcknowledgeWorkOrdersFFA/*')
global with sharing class FFAWorkOrderAssigned {
    
    @HttpPost
    global static void doPost(){
        try{
            FFA_Integration_Limit__mdt maxFetchLimit=[Select MasterLabel,limit__c from FFA_Integration_Limit__mdt where MasterLabel=:'WorkOrderAssigned' limit 1];
            final Integer BATCH_LIMIT;
            if(maxFetchLimit!=null){
                BATCH_LIMIT = integer.valueOf(maxFetchLimit.limit__c);
                System.debug(BATCH_LIMIT);
            }else{
                BATCH_LIMIT = 100;
            }
            
            // Defining vairables
            RestRequest req =  RestContext.request;
            ProcessingStatus processingStatusWrapper = new ProcessingStatus();
            
            list<WorkOrder> woToUpdate = new list<WorkOrder>();
            list<Schedule> bodySchedules= new list<Schedule>();
            list<String> wosInRequestBody = new list<String>();
            set<String> wosInRequestBodySet = new set<String>(); // Var for handling duplicate WO - 25-06-2020
            list<String> DuplicateWOsNumberList = new list<String>(); // Var for handling duplicate WO - 25-06-2020
            list<String> DuplicateUnassignWOsNumberList = new list<String>(); // Var for handling duplicate WO - 25-06-2020
            list<Unassign> bodyOfUnassign = new list<Unassign>();
            list<string> FailureResponseTextList = new list<string>();
            list<String> engineerIdsInRequestBody= new list<String>();
            list<String> wosInUnassignRequestBody = new list<String>();
            set<String> wosInUnassignRequestBodySet = new set<String>(); // Var for handling duplicate WO - 25-06-2020
            list<WorkOrder> unassignWorkOrderList = new list<WorkOrder>();
            list<String> WorkOrderNumberFromJsonlist = new list<String>();
            list<String> WorkOrderNumberFromQuerylist = new list<String>();
            list<AssignedResource> arUnassign = new list<AssignedResource>();
            list<oldAssignResources> oldARList = new list<oldAssignResources>();
            list<ServiceAppointment> saToUpdate = new list<ServiceAppointment>();
            list<AssignedResource> assignedResToUpdate = new list<AssignedResource>();
            list<ServiceAppointment> unassignServiceAppointment = new list<ServiceAppointment>();
            list<SchedulingResponse> scheduleProcessingStatusList = new list<SchedulingResponse>();
            list<FailedSchedulingResults> FailureResponseList = new list<FailedSchedulingResults>();
            list<FailedSchedulingResults> schFailureResponseList = new list<FailedSchedulingResults>();
            list<FailedSchedulingResults> schFailureResponseListAll = new list<FailedSchedulingResults>();
            
            Map<String,Object> unassignObjectMap;
            Map<String,Object> scheduleObjectMap;
            Map<String, WorkOrder> ffaWorkOrderMapUnassign = new Map<String, WorkOrder>();
            Map<string,string> mapForOldScheduleStartAndEndTime = new Map<string,string>();
            Map<String, Object> reqBodyMap = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
            Map<String,String> validEngineersIdMap = new Map<String,String>();
            
            String responseBody;
            String schWorkOrderNumber;
            String workOrdersForSchedule= JSON.serialize(reqBodyMap.get('Schedule'));
            String workOrdersForAck = JSON.serialize(reqBodyMap.get('Acknowledge'));
            String workOrdersForUnAssign = JSON.serialize(reqBodyMap.get('Unassign'));
            
            Boolean isAssignResourceDelete = false;
            Boolean isSuccessResponseForAcknowledge = false;
            
            Set<Id> ServiceApptIds = new set<Id>();
            
            
            // Handling empty payload, here
            if (String.isEmpty(req.requestBody.toString())){
                String responseBody1= JSON.serialize('{"Error":"Request Payload is empty. Execution terminated."}');
                system.debug('Empty Response'+responseBody1);
                CreateHTTPResponse(responseBody,responseBody1,'400','Request Payload empty','Failure');
                return;
            }
            
            // For Unassigned operation.
            if(workOrdersForUnAssign.length()>4){
                if (reqBodyMap.get('Unassign')instanceof List<Object>){
                    bodyOfUnassign = (List<Unassign>)JSON.deserialize(workOrdersForUnAssign, List<Unassign>.class);
                    system.debug(bodyOfUnassign);
                }else{
                    Unassign bodyUnassign = (Unassign)JSON.deserialize(workOrdersForUnAssign, Unassign.class); 
                    system.debug('bodyunassign ' + bodyUnassign);
                    bodyOfUnassign.add(bodyUnassign);
                    system.debug(bodyOfUnassign);
                }
                boolean checkUnassginDuplicateWOs; // Var for handling duplicate WO - 25-06-2020
                string removeUnassignDuplicateWOs;// Var for handling duplicate WO - 25-06-2020
                for(Unassign ua : bodyOfUnassign){
                    unassignObjectMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(ua));
                    system.debug(unassignObjectMap);
                    checkUnassginDuplicateWOs = wosInUnassignRequestBodySet.add(unassignObjectMap.get('WorkOrderNo').toString()); // To ignore duplicate values of WO - 25/06/2020
                    if(!checkUnassginDuplicateWOs){
                        DuplicateUnassignWOsNumberList.add(unassignObjectMap.get('WorkOrderNo').toString());  // To collect duplicate WOs Number - 25-06-2020
                        removeUnassignDuplicateWOs = unassignObjectMap.get('WorkOrderNo').toString(); // Create for duplicate WO number to use to remove WO number from string set - 25=06-2020
                    }
                    if(string.isNotBlank(removeUnassignDuplicateWOs)){wosInUnassignRequestBodySet.remove(removeUnassignDuplicateWOs);} //Here we remove duplicate WO number from set - 25-06-2020
                    WorkOrderNumberFromJsonlist.add(unassignObjectMap.get('WorkOrderNo').toString());
                    system.debug(wosInUnassignRequestBodySet);
                }
                String workOrderNoUnassign = unassignObjectMap.get('WorkOrderNo').toString();
                list<WorkOrder> ffaWorkOrderUnassign = [select id ,WorkOrderNumber, Status, Sync_Status__c ,Batch_No__c ,FFA_UnplannedPolicyStartDate__c,FFA_UnplannedPolicyEndDate__c,Job_Category__c,FFA_Sender_ID__c,
                                                        (select Id, AppointmentNumber,Status,EarliestStartTime,SchedStartTime,SchedEndTime,DueDate,FFAAssignedAPI__c from SERVICEAPPOINTMENTS WHERE Status != 'Cancelled') from WorkOrder 
                                                        where WorkOrderNumber in :wosInUnassignRequestBodySet];
                
                
                System.debug(ffaWorkOrderUnassign.size());
                WorkOrder ffaWorkOrderUnassigned;
                set<Id> requiredServiceAptts=new set<Id>();
                for(WorkOrder reqSAP:ffaWorkOrderUnassign){
                    ffaWorkOrderMapUnassign.put(reqSAP.WorkOrderNumber,reqSAP);
                    ffaWorkOrderUnassigned = ffaWorkOrderMapUnassign.get(reqSAP.WorkOrderNumber);
                    list<ServiceAppointment> activeServiceAppointmentUnassignedList = ffaWorkOrderUnassigned.ServiceAppointments;
                    for(ServiceAppointment activeServiceAppointmentUnassigned : activeServiceAppointmentUnassignedList){
                        requiredServiceAptts.add(activeServiceAppointmentUnassigned.Id);
                    }
                }
                system.debug(requiredServiceAptts.size());
                list<AssignedResource> newAssignedResourceListForDelete = new list<AssignedResource>();
                newAssignedResourceListForDelete=[SELECT Id, ServiceAppointmentId FROM AssignedResource Where ServiceAppointmentId=:requiredServiceAptts];
                System.debug(newAssignedResourceListForDelete.size());
                if(!ffaWorkOrderUnassign.isEmpty() && wosInUnassignRequestBodySet!=null){ 
                    for(WorkOrder wo : ffaWorkOrderUnassign){
                        if(!DuplicateUnassignWOsNumberList.contains(wo.WorkOrderNumber)){  // check if duplicate list does not contains any WO - 25-06-2020
                            WorkOrderNumberFromQuerylist.add(wo.WorkOrderNumber);
                            if(wo.status == 'Assigned' || wo.Status == 'In Progress'){
                                wo.Status = 'Unassigned';
                                wo.Sync_Status__c = 'Pending';
                                wo.Batch_No__c = '';
                                unassignWorkOrderList.add(wo);
                                //ffaWorkOrderMapUnassign.put (wo.WorkOrderNumber,wo);
                                ffaWorkOrderUnassigned = ffaWorkOrderMapUnassign.get(wo.WorkOrderNumber);
                                list<ServiceAppointment> activeServiceAppointmentUnassignedlist = ffaWorkOrderUnassigned.ServiceAppointments;
                                if(!activeServiceAppointmentUnassignedlist.isEmpty()){
                                    if(string.isNotBlank(workOrderNoUnassign)){
                                        for(ServiceAppointment activeServiceAppointmentUnassigned : activeServiceAppointmentUnassignedlist){
                                            system.debug(activeServiceAppointmentUnassigned.Status);
                                            if(activeServiceAppointmentUnassigned.Status == 'Scheduled' || activeServiceAppointmentUnassigned.Status == 'Enroute'){
                                                system.debug(activeServiceAppointmentUnassigned.Status);
                                                if(ffaWorkOrderUnassigned.FFA_Sender_ID__c=='RAINBOW' && activeServiceAppointmentUnassigned.Status=='Enroute'){
                                                    activeServiceAppointmentUnassigned.FFAAssignedAPI__c='Unassigned';
                                                }
                                                activeServiceAppointmentUnassigned.Status = 'None';
                                                Id srId = activeServiceAppointmentUnassigned.Id;
                                                if(ffaWorkOrderUnassigned.Job_Category__c == 'NGM Initiated Job' || ffaWorkOrderUnassigned.Job_Category__c == 'NGM Initiated - Maintenance Job' || ffaWorkOrderUnassigned.Job_Category__c == 'NGM Initiated - Non Maintenance Job'){
                                                    if(ffaWorkOrderUnassigned.FFA_UnplannedPolicyStartDate__c!=null && ffaWorkOrderUnassigned.FFA_UnplannedPolicyEndDate__c!=null){
                                                        activeServiceAppointmentUnassigned.SchedStartTime = ffaWorkOrderUnassigned.FFA_UnplannedPolicyStartDate__c;
                                                        activeServiceAppointmentUnassigned.SchedEndTime = ffaWorkOrderUnassigned.FFA_UnplannedPolicyEndDate__c;
                                                    }                            
                                                }
                                                unassignServiceAppointment.add(activeServiceAppointmentUnassigned);
                                                if(!newAssignedResourceListForDelete.isEmpty()){
                                                    isAssignResourceDelete=true;
                                                }else{
                                                    //To-do Failure response
                                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                                    fr.WorkOrderNo = workOrderNoUnassign;
                                                    fr.Status = 'Failure';
                                                    fr.SupportingInfo = 'Assigned engineer not available in Service appointment.';
                                                    schFailureResponseListAll.add(fr);
                                                }
                                            }else{
                                                FailedSchedulingResults fr = new FailedSchedulingResults();
                                                fr.WorkOrderNo = activeServiceAppointmentUnassigned.AppointmentNumber;
                                                fr.Status = 'Failure';
                                                fr.SupportingInfo = 'Provided workorder service appointment status is not correct.';
                                                schFailureResponseListAll.add(fr);
                                            }
                                        }
                                    }
                                }else{
                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                    fr.WorkOrderNo = wo.WorkOrderNumber;
                                    fr.Status = 'Failure';
                                    fr.SupportingInfo = 'No active service appointment found in database.';
                                    schFailureResponseListAll.add(fr);
                                }
                            }else{
                                FailedSchedulingResults fr = new FailedSchedulingResults();
                                fr.WorkOrderNo = wo.WorkOrderNumber;
                                fr.Status = 'Failure';
                                fr.SupportingInfo = 'Work Order does not exist or invalid status.';
                                schFailureResponseListAll.add(fr);
                            }
                            
                            // Error handling for duplicate WO - 25-06-2020
                        }else{
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = wo.WorkOrderNumber;
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'Duplicate Work Orders found in the Unassign request.';
                            schFailureResponseListAll.add(fr);
                        }
                    }
                }else{
                    //To-do Failure response
                    FailedSchedulingResults fr = new FailedSchedulingResults();
                    fr.WorkOrderNo = workOrderNoUnassign;
                    fr.Status = 'Failure';
                    fr.SupportingInfo = 'Work Order does not exist or invalid status.';
                    schFailureResponseListAll.add(fr);
                    system.debug('Status not found == ');
                }
                
                system.debug('Delete list == '+newAssignedResourceListForDelete.size());
                List<SchedulingResponse> databaseUpdateUnassignSAWOResponse = new List<SchedulingResponse>();
                if(!unassignServiceAppointment.isEmpty() && !unassignWorkOrderList.isEmpty() && !newAssignedResourceListForDelete.isEmpty() && isAssignResourceDelete==true){
                    databaseUpdateUnassignSAWOResponse = UpdateSAWORecords(unassignServiceAppointment,unassignWorkOrderList,newAssignedResourceListForDelete,isAssignResourceDelete,null,schFailureResponseListAll);
                    scheduleProcessingStatusList.addAll(databaseUpdateUnassignSAWOResponse);
                    processingStatusWrapper.SchedulingResults = scheduleProcessingStatusList;
                }
                
                
                if(!WorkOrderNumberFromJsonlist.isEmpty() && !WorkOrderNumberFromQuerylist.isEmpty()){
                    for(string WONumbers : WorkOrderNumberFromJsonlist){
                        // Here is a main error message handling for duplicate WO.  - 25-06-2020
                        if(DuplicateUnassignWOsNumberList!=null && DuplicateUnassignWOsNumberList.contains(WONumbers) && string.isNotBlank(WONumbers)){
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = WONumbers;
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'Duplicate Work Orders found in the Unassign request.';
                            schFailureResponseListAll.add(fr);
                            system.debug('Duplicate check two ====');
                        }
                        if(!WorkOrderNumberFromQuerylist.contains(WONumbers) && !DuplicateUnassignWOsNumberList.contains(WONumbers) && string.isNotBlank(WONumbers)){
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = WONumbers;
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'Invalid Work Order Number, Workorder cannot be Unassigned.'; //Invalid Status ,Workorder cannot be Unassigned.
                            schFailureResponseListAll.add(fr);
                            system.debug('Invalid WO one ===');
                        }
                        if(string.isEmpty(WONumbers)){
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = WONumbers;
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'Work order number is empty in unassign request.';
                            schFailureResponseListAll.add(fr);
                            system.debug('Empty WO one ===');
                        }
                    }
                }
                
                if(!WorkOrderNumberFromJsonlist.isEmpty() && WorkOrderNumberFromQuerylist.isEmpty()){
                    for(string WONumbers : WorkOrderNumberFromJsonlist){
                        if(DuplicateUnassignWOsNumberList.contains(WONumbers)){
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = WONumbers;
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'Duplicate Work Orders found in the Unassign request.';
                            schFailureResponseListAll.add(fr);
                            system.debug('Duplicate check three ====');
                        }else{
                            if(string.isNotBlank(WONumbers)){
                                FailedSchedulingResults fr = new FailedSchedulingResults();
                                fr.WorkOrderNo = WONumbers;
                                fr.Status = 'Failure';
                                fr.SupportingInfo = 'Invalid Work Order Number, Workorder cannot be Unassigned.';
                                schFailureResponseListAll.add(fr);
                            }else{
                                FailedSchedulingResults fr = new FailedSchedulingResults();
                                fr.WorkOrderNo = WONumbers;
                                fr.Status = 'Failure';
                                fr.SupportingInfo = 'Work order number is empty in unassign request.';
                                schFailureResponseListAll.add(fr);
                            }
                        }
                        
                    }
                }
            }
            
            // FOR Schedule operation
            list<String> allScheduleDuplicateWONumber = new list<String>();
            if(workOrdersForSchedule.length()>4){
                
                //Create a List of Service Appointments as received in the request body for processing
                if (reqBodyMap.get('Schedule')instanceof List<Object>){
                    system.debug(reqBodyMap.get('Schedule'));            
                    bodySchedules = (List<Schedule>)JSON.deserialize(workOrdersForSchedule, List<Schedule>.class);
                }else{    
                    Schedule bodySchedule = (Schedule)JSON.deserialize(workOrdersForSchedule, Schedule.class); 
                    system.debug('bodySchedule ' + bodySchedule);
                    bodySchedules.add(bodySchedule);
                }
                boolean checkScheduleDuplicateWOs; // Var for handling duplicate WO - 25-06-2020
                string RemoveDuplicateWos; // Var for handling duplicate WO - 25-06-2020
                for(Schedule sched: bodySchedules){
                    scheduleObjectMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(sched));
                    //wosInRequestBody.add(scheduleObjectMap.get('WorkOrderNo').toString());
                    checkScheduleDuplicateWOs = wosInRequestBodySet.add(scheduleObjectMap.get('WorkOrderNo').toString());  // Using set here to avoid to assign duplicate WO number - 25-06-2020
                    if(!checkScheduleDuplicateWOs){                                                                         // Checking if duplicate found - 25-06-2020
                        DuplicateWOsNumberList.add(scheduleObjectMap.get('WorkOrderNo').toString());                       // Assigning duplicate values in list - 25-06-2020
                        RemoveDuplicateWos = scheduleObjectMap.get('WorkOrderNo').toString();                              // Assign a single WO number to use for remove duplicate WO number from set - 25-06-2020
                    }
                    if(string.isNotBlank(RemoveDuplicateWos)){wosInRequestBodySet.remove(RemoveDuplicateWos);}             // Here we removed duplicate WO number from set to avoid query - 25-06-2020
                    allScheduleDuplicateWONumber.add(scheduleObjectMap.get('WorkOrderNo').toString());
                    if(scheduleObjectMap.get('EngineerID')!=null){engineerIdsInRequestBody.add(scheduleObjectMap.get('EngineerID').toString());}
                }
                system.debug(wosInRequestBodySet.size());
                //If workorder count in the request payload > BATCH LIMIT, stop execution and throw error message.
                if (wosInRequestBody.size()>BATCH_LIMIT){
                    FailedSchedulingResults fr = new FailedSchedulingResults();
                    fr.WorkOrderNo = '';
                    fr.Status = 'Failure';
                    fr.SupportingInfo = 'Request exceeds the Batch Limit of  ' + BATCH_LIMIT + '. Execution terminated.';
                    schFailureResponseListAll.add(fr);
                }
                
                //SOQL query for fetching WorkOrder/Service Appointment/Service Resource/Assigned Resource/User for aggregation & updating.
                List<User> ffaEngineers = [SELECT Id, UserName, (SELECT ID, RelatedRecordId, Name FROM ServiceResources) FROM USER WHERE USERNAME in :engineerIdsInRequestBody];
                List<WorkOrder> ffaWorkOrders = [SELECT Id, WorkOrderNumber, Status,FFA_Sender_ID__c, FFA_EmergencyFlag__c, Batch_No__c,Job_Category__c, Sync_Status__c,PolicyReplanJob__c,FFA_RequestedAppointmentDate__c,
                                                 (SELECT Id, AppointmentNumber, Status,EarliestStartTime,SchedStartTime,SchedEndTime,DueDate,FFAAssignedAPI__c 
                                                  FROM SERVICEAPPOINTMENTS WHERE STATUS IN ('None','Scheduled','Enroute'))
                                                 FROM WORKORDER WHERE WORKORDERNUMBER in :wosInRequestBodySet AND STATUS IN ('New','Scheduled','Assigned','Unassigned','In Progress')];
                
                // First we remove Assign resources if scheduled work order contain service resources
                if(ffaEngineers!=null){
                    for(User FFAUsers : ffaEngineers){
                        string FFAUsername = FFAUsers.Username;
                        validEngineersIdMap.put(FFAUsername.toUpperCase(),FFAUsername.toUpperCase());
                    }
                }
                WorkOrder ffaWorkOrderUnassigned;
                schWorkOrderNumber = scheduleObjectMap.get('WorkOrderNo').toString();
                set<Id> requiredServiceAptts=new set<Id>();
                system.debug(ffaWorkOrders.size());
                for(WorkOrder wo:ffaWorkOrders){
                    ffaWorkOrderMapUnassign.put(wo.WorkOrderNumber,wo);
                    ffaWorkOrderUnassigned = ffaWorkOrderMapUnassign.get(wo.WorkOrderNumber);
                    list<ServiceAppointment> activeServiceAppointmentUnassignedList = ffaWorkOrderUnassigned.ServiceAppointments;
                    for(ServiceAppointment activeServiceAppointmentUnassigned : activeServiceAppointmentUnassignedList){
                        requiredServiceAptts.add(activeServiceAppointmentUnassigned.Id);
                        mapForOldScheduleStartAndEndTime.put(activeServiceAppointmentUnassigned.Id,string.valueOf(activeServiceAppointmentUnassigned.SchedStartTime+'=='+activeServiceAppointmentUnassigned.SchedEndTime));
                    }
                }
                // For old Assign resources delete operation
                if(!requiredServiceAptts.isEmpty()){
                    system.debug(requiredServiceAptts);
                    oldARList=toDeleteServiceResources(requiredServiceAptts,ffaWorkOrders);
                }
                
                //Create a Map of FFAWorkOrders with Key as WorkOrderNo and Value as the WorkOrder Object
                Map<String, WorkOrder> ffaWorkOrderMap = new Map<String, WorkOrder>();
                if(!ffaWorkOrders.isEmpty()){
                    for (WorkOrder wo: ffaWorkOrders){
                        ffaWorkOrderMap.put (wo.WorkOrderNumber,wo);
                    }
                    system.debug('ffaWorkOrderMap is ' + ffaWorkOrderMap);
                    
                    for(Schedule sched: bodySchedules){
                        if(string.isNotEmpty(sched.WorkOrderNo)){
                            if(!DuplicateWOsNumberList.contains(sched.WorkOrderNo)){
                                //Here, checking for WO if it is not available in duplicate WO number list - 25-06-2020
                                system.debug(sched.WorkOrderNo);
                                schFailureResponseList = UpdateServiceApptWorkOrderRecords(sched, ffaWorkOrderMap, ffaEngineers,saToUpdate, woToUpdate,assignedResToUpdate, scheduleProcessingStatusList,oldARList,mapForOldScheduleStartAndEndTime,ServiceApptIds,validEngineersIdMap);
                                schFailureResponseListAll.addAll(schFailureResponseList);
                                system.debug(schFailureResponseListAll.size());
                                // Here we are handling error message for duplicate WO number if found in list - 25-06-2020
                            }else{
                                if(DuplicateWOsNumberList.contains(sched.WorkOrderNo)){
                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                    fr.WorkOrderNo = sched.WorkOrderNo;
                                    fr.Status = 'Failure';
                                    fr.SupportingInfo = 'Duplicate Work Orders found in the Schedule request.';
                                    schFailureResponseListAll.add(fr);
                                }
                            }
                        }else{
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = sched.WorkOrderNo;
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'Work Order number is empty in the Schedule request.';
                            schFailureResponseListAll.add(fr);
                        }
                    }
                    List<SchedulingResponse> databaseUpdateSAWOResponse = new List<SchedulingResponse>();
                    databaseUpdateSAWOResponse = UpdateSAWORecords(saToUpdate,woToUpdate,assignedResToUpdate,false,ServiceApptIds,schFailureResponseListAll);
                    system.debug(schFailureResponseListAll.size());
                    scheduleProcessingStatusList.addAll(databaseUpdateSAWOResponse);
                    processingStatusWrapper.SchedulingResults = scheduleProcessingStatusList;
                    
                }else{
                    //To-do Failure response
                    if(wosInRequestBodySet!=null){
                        for(string WorkOrderNumbers : allScheduleDuplicateWONumber){
                            if(wosInRequestBodySet.contains(WorkOrderNumbers)){
                                if(string.isNotEmpty(WorkOrderNumbers)){
                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                    fr.WorkOrderNo = WorkOrderNumbers;
                                    fr.Status = 'Failure';
                                    fr.SupportingInfo = 'Work Order number is invalid or incorrect status. Please check the work order number and ensure it can be scheduled.';
                                    schFailureResponseListAll.add(fr);
                                }else{
                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                    fr.WorkOrderNo = WorkOrderNumbers;
                                    fr.Status = 'Failure';
                                    fr.SupportingInfo = 'Work Order number is empty in the Schedule request.';
                                    schFailureResponseListAll.add(fr);
                                }
                            }
                        }
                    }
                    
                    // here we handling all duplicate WO and send the particular response - 25-06-2020
                    if(DuplicateWOsNumberList!=null){
                        for(string WONumber : allScheduleDuplicateWONumber){
                            if(DuplicateWOsNumberList.contains(WONumber)){
                                FailedSchedulingResults fr = new FailedSchedulingResults();
                                fr.WorkOrderNo = WONumber;
                                fr.Status = 'Failure';
                                fr.SupportingInfo = 'Duplicate Work Orders found in the Schedule request.';
                                schFailureResponseListAll.add(fr);
                            }
                        }
                    } 
                }
            }
            
            //For BatchID Acknowledgement operation
            if(workOrdersForAck.length()>4){
                Map<String,Object> AcknowledgeObjectMap;
                list<string> ackWorkOrderNumberList = new list<string>();
                list<string> ackWorkOrderNumberQueryList = new list<string>();
                List<Acknowledge> bodyAcknowledges= new List<Acknowledge>();
                
                if (reqBodyMap.get('Acknowledge')instanceof List<Object>){
                    system.debug(reqBodyMap.get('Acknowledge'));            
                    bodyAcknowledges = (List<Acknowledge>)JSON.deserialize(workOrdersForAck, List<Acknowledge>.class);
                }else{
                    Acknowledge bodyAcknowledge = (Acknowledge)JSON.deserialize(workOrdersForAck, Acknowledge.class);
                    bodyAcknowledges.add(bodyAcknowledge);
                }
                for(Acknowledge ackn : bodyAcknowledges){
                    AcknowledgeObjectMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(ackn));
                    ackWorkOrderNumberList.add(AcknowledgeObjectMap.get('BatchID').toString());
                }
                List<WorkOrder> workOrdersAck = [SELECT ID, WorkOrderNumber, Batch_No__c,  Sync_Status__c from WORKORDER WHERE Batch_No__c in : ackWorkOrderNumberList];
                if(!workOrdersAck.isEmpty()){
                    for(WorkOrder wo : workOrdersAck){
                        ackWorkOrderNumberQueryList.add(wo.Batch_No__c);
                    }
                    List<AcknowledgementResponse>ackProcessingStatusList =  AcknowledgeWorkOrderBatch(reqBodyMap);
                    processingStatusWrapper.AcknowledgementResults = ackProcessingStatusList;
                    string AckBodyReturnValue = string.valueOf(processingStatusWrapper);
                    System.debug(AckBodyReturnValue);
                    if(!AckBodyReturnValue.contains('BatchID=N/A')){
                        if(!ackProcessingStatusList.isEmpty()){
                            isSuccessResponseForAcknowledge = true;
                        }else{
                            //To-do Failure response
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = '';
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'Acknowledge payload is empty.';
                            schFailureResponseListAll.add(fr);
                        }
                    }else{
                        //To-do Failure response
                        FailedSchedulingResults fr = new FailedSchedulingResults();
                        fr.WorkOrderNo = '';
                        fr.Status = 'Failure';
                        fr.SupportingInfo = 'Batch id is not available in payload.';
                        schFailureResponseListAll.add(fr);
                    }
                }else{
                    FailedSchedulingResults fr = new FailedSchedulingResults();
                    fr.WorkOrderNo = '';
                    fr.Status = 'Failure';
                    fr.SupportingInfo = 'Provided batch Id not found in database.';
                    schFailureResponseListAll.add(fr);
                }
                boolean isAckWONumberValid;
                if(!ackWorkOrderNumberQueryList.isEmpty() && !ackWorkOrderNumberList.isEmpty()){
                    for(string str : ackWorkOrderNumberList){
                        if(ackWorkOrderNumberQueryList.contains(str)){
                            isAckWONumberValid = true;
                        }else{
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = '';
                            fr.Status = 'Failure';
                            fr.SupportingInfo = str+' == Provided batch Id is not correct or it is not in database.';
                            schFailureResponseListAll.add(fr);
                        }
                    }
                }
            }
            
            processingStatusWrapper.FailSchedulingResults = schFailureResponseListAll;
            system.debug('Fail sch size=='+schFailureResponseListAll.size());
            // Only when Operation get Success response for Schedule, Acknowledge and Unassign
            if(processingStatusWrapper!=null){
                responseBody= JSON.serialize(processingStatusWrapper);
                CreateHTTPResponse(req.requestBody.toString(), responseBody,'200','Transaction Submitted Successfully.','Success');
                return;
            }else{
                responseBody= JSON.serialize(processingStatusWrapper);
                CreateHTTPResponse(req.requestBody.toString(), responseBody,'400','Transaction Failed and error code for failure.','Failure');
                return;
            }
        }catch(Exception e){
            System.debug(e.getMessage()+'Failed due to line num=='+e.getLineNumber());
            if(e.getMessage().contains('Invalid date')){
                CreateHTTPResponse('Null','Null','400','Format of date is invalid in the given JSON.','Failure');
                return;
            }else{
                CreateHTTPResponse('Null','Null','400','Invalid JSON or problem with salesforce system, Please Contact respective team','Failure');
                return;
            }
            
        }
    }
    
    static List<FailedSchedulingResults> UpdateServiceApptWorkOrderRecords(Schedule sched, Map<String,WorkOrder> ffaWorkOrderMap,List<User> ffaEngineers, 
                                                                           List<ServiceAppointment>saToUpdate, List<WorkOrder>woToUpdate,List<AssignedResource>assignedResToUpdate,
                                                                           List<SchedulingResponse> scheduleProcessingStatusList,list<oldAssignResources> oldARList,
                                                                           map<string,string> mapForOldScheduleStartAndEndTime,Set<Id> ServiceApptIds, Map<String,String> validEngineersIdMap){
                                                                               
                                                                               list<FailedSchedulingResults> FailureResponseList=new list<FailedSchedulingResults>();
                                                                               Map<String,Object> scheduleObjectMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(sched));
                                                                               
                                                                               String workOrderNo;
                                                                               string EngineerID;
                                                                               boolean isSAStatusValid;
                                                                               set<string> appTimeSlotSet = new set<String>();
                                                                               list<FFAServiceAppointmentSlots__mdt> FFAAppointmentSlotsList = [select MasterLabel,DeveloperName,Slot__c,SenderID__c from FFAServiceAppointmentSlots__mdt];
                                                                               for(FFAServiceAppointmentSlots__mdt appTimeSlots : FFAAppointmentSlotsList){
                                                                                   appTimeSlotSet.add(appTimeSlots.Slot__c);
                                                                               }
                                                                               workOrderNo = scheduleObjectMap.get('WorkOrderNo').toString();
                                                                               WorkOrder ffaWorkOrder;
                                                                               ServiceAppointment activeServiceAppointment =new ServiceAppointment();
                                                                               if(ffaWorkOrderMap.containsKey(workOrderNo)){
                                                                                   ffaWorkOrder = ffaWorkOrderMap.get(workOrderNo);
                                                                                   system.debug(ffaWorkOrder.WorkOrderNumber);
                                                                                   if(!ffaWorkOrder.ServiceAppointments.isEmpty()){
                                                                                       if(ffaWorkOrder.ServiceAppointments.size()==1){
                                                                                           activeServiceAppointment = ffaWorkOrder.ServiceAppointments;
                                                                                           isSAStatusValid = true;
                                                                                       }else{
                                                                                           FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                           fr.WorkOrderNo = workOrderNo;
                                                                                           fr.Status = 'Failure';
                                                                                           fr.SupportingInfo = 'More than 1 service appointment active.';
                                                                                           FailureResponseList.add(fr);
                                                                                       }
                                                                                   }
                                                                               }
                                                                               
                                                                               
                                                                               
                                                                               boolean isWorkOrderNumberValid;
                                                                               boolean isJobCategoryChecked;
                                                                               DateTime appointmentDateTime;
                                                                               boolean isEngineerFound;
                                                                               boolean isSRNotAvailableForRainbowNGM;
                                                                               
                                                                               
                                                                               if(string.isNotBlank(workOrderNo) && isSAStatusValid == true){
                                                                                   if(!String.isEmpty(ffaWorkOrder.WorkOrderNumber)){
                                                                                       if(ffaWorkOrder.ServiceAppointments.size()>0){
                                                                                           if(ffaWorkOrder.ServiceAppointments.size()==1){
                                                                                               isWorkOrderNumberValid =true;
                                                                                           }else{
                                                                                               isWorkOrderNumberValid =false;
                                                                                           }
                                                                                       }else{
                                                                                           FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                           fr.WorkOrderNo = workOrderNo;
                                                                                           fr.Status = 'Failure';
                                                                                           fr.SupportingInfo = 'It is not allowed to make changes to in progress, completed or cancelled Service Appointments.';
                                                                                           FailureResponseList.add(fr);
                                                                                       }
                                                                                   }else{
                                                                                       FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                       fr.WorkOrderNo = workOrderNo;
                                                                                       fr.Status = 'Failure';
                                                                                       fr.SupportingInfo = 'No work order found in database.';
                                                                                       FailureResponseList.add(fr);
                                                                                   }
                                                                               }else{
                                                                                   FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                   fr.WorkOrderNo = workOrderNo;
                                                                                   fr.Status = 'Failure';
                                                                                   fr.SupportingInfo = 'Work order number is invalid or incorrect status. Please check the work order number and ensure it can be scheduled.';
                                                                                   FailureResponseList.add(fr);
                                                                               }
                                                                               
                                                                               if(isWorkOrderNumberValid==true){
                                                                                   if((ffaWorkOrder.Job_Category__c=='NGM initiated Job' || ffaWorkOrder.Job_Category__c == 'NGM Initiated - Maintenance Job' || ffaWorkOrder.Job_Category__c == 'NGM Initiated - Non Maintenance Job') && activeServiceAppointment.Status=='None'){
                                                                                       if(scheduleObjectMap.get('AppointmentDate')!=null){
                                                                                           system.debug('Policy job');
                                                                                           string AppointmentDateString = scheduleObjectMap.get('AppointmentDate').toString();
                                                                                           if(string.isNotBlank(AppointmentDateString) || !string.isEmpty(AppointmentDateString)){
                                                                                               appointmentDateTime = convertDateStringToDateTime(AppointmentDateString);
                                                                                               if(appointmentDateTime != null){  // && appointmentDateTime.date() >= System.date.today()){   //update as per discussion with mahesh on 22-03-2021
                                                                                                   if(activeServiceAppointment.SchedStartTime!=null && activeServiceAppointment.SchedEndTime!=null){
                                                                                                     //  if(appointmentDateTime.date()>=activeServiceAppointment.SchedStartTime.date() && appointmentDateTime.date() <=activeServiceAppointment.SchedEndTime.date()){ //update as per discussion with mahesh on 22-03-2021
                                                                                                           activeServiceAppointment.EarliestStartTime= appointmentDateTime; 
                                                                                                           activeServiceAppointment.SchedStartTime = appointmentDateTime; 
                                                                                                           activeServiceAppointment.SchedEndTime =appointmentDateTime.addHours(23).addMinutes(59);
                                                                                                           activeServiceAppointment.DueDate = appointmentDateTime;
                                                                                                           ffaWorkOrder.FFA_RequestedAppointmentDate__c =appointmentDateTime;
                                                                                                           system.debug('Policy job'+activeServiceAppointment.SchedStartTime+'=='+activeServiceAppointment.SchedEndTime);
                                                                                                           if(scheduleObjectMap.get('AppointmentTimeSlot')!=null && ffaWorkOrder.FFA_Sender_ID__c=='RAINBOW'){
                                                                                                               string newAppTimeSlot = scheduleObjectMap.get('AppointmentTimeSlot').toString();
                                                                                                               if(String.isNotBlank(newAppTimeSlot)){
                                                                                                                   if(appTimeSlotSet.contains(newAppTimeSlot)){
                                                                                                                       system.debug(newAppTimeSlot);
                                                                                                                       ffaWorkOrder.FFA_RequestedAppointmentTimeslot__c = newAppTimeSlot;
                                                                                                                       system.debug(ffaWorkOrder.FFA_RequestedAppointmentTimeslot__c);
                                                                                                                       ServiceApptIds.add(activeServiceAppointment.Id);
                                                                                                                   }else{
                                                                                                                       FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                       fr.WorkOrderNo = workOrderNo;
                                                                                                                       fr.Status = 'Failure';
                                                                                                                       fr.SupportingInfo = 'Invalid appointment time slot in schedule request.';
                                                                                                                       FailureResponseList.add(fr);
                                                                                                                       isJobCategoryChecked = false;
                                                                                                                   }
                                                                                                               }
                                                                                                           }
                                                                                                           if(isJobCategoryChecked!=false){isJobCategoryChecked = true;}
                                                                                                           // }//update as per discussion with mahesh on 22-03-2021
                                                                                                       /*else{ 
                                                                                                           system.debug('Date come here===3');
                                                                                                           FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                           fr.WorkOrderNo = workOrderNo;
                                                                                                           fr.Status = 'Failure';
                                                                                                           fr.SupportingInfo = 'Appointment Date is not within the AppointmentStartDate & AppointmentEndDate range of the Service Appointment or Appointment Date is in Past or it is a Customer initiated job. Please use the correct date and ensure the job is not a Customer initiated job.';
                                                                                                           FailureResponseList.add(fr);
                                                                                                       }*/
                                                                                                   }else{
                                                                                                       FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                       fr.WorkOrderNo = workOrderNo;
                                                                                                       fr.Status = 'Failure';
                                                                                                       fr.SupportingInfo = 'Schedule Start date and Schedule End date is not available.Please provide the correct value.';
                                                                                                       FailureResponseList.add(fr);
                                                                                                   }
                                                                                               }else{
                                                                                                   system.debug('Date come here===2');
                                                                                                   FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                   fr.WorkOrderNo = workOrderNo;
                                                                                                   fr.Status = 'Failure';
                                                                                                   fr.SupportingInfo = 'Appointment Date is not within the AppointmentStartDate & AppointmentEndDate range of the Service Appointment or Appointment Date is in Past or it is a Customer initiated job. Please use the correct date and ensure the job is not a Customer initiated job.';
                                                                                                   FailureResponseList.add(fr);
                                                                                               }
                                                                                           }else{
                                                                                               FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                               fr.WorkOrderNo = workOrderNo;
                                                                                               fr.Status = 'Failure';
                                                                                               fr.SupportingInfo = 'Appointment Date is required for NGM Initiated Jobs. Please provide the schedule date and try again.';
                                                                                               FailureResponseList.add(fr);
                                                                                           }
                                                                                       }else{
                                                                                           FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                           fr.WorkOrderNo = workOrderNo;
                                                                                           fr.Status = 'Failure';
                                                                                           fr.SupportingInfo = 'Appointment Date is required for NGM Initiated Jobs. Please provide the schedule date and try again.';
                                                                                           FailureResponseList.add(fr);
                                                                                       }
                                                                                   }else if(ffaWorkOrder.Job_Category__c=='Customer Initiated Job'){
                                                                                       if(scheduleObjectMap.get('AppointmentDate')!=null){
                                                                                           string AppointmentDateString = scheduleObjectMap.get('AppointmentDate').toString();
                                                                                           if(string.isNotBlank(AppointmentDateString)){
                                                                                               FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                               fr.WorkOrderNo = workOrderNo;
                                                                                               fr.Status = 'Failure';
                                                                                               fr.SupportingInfo = 'Appointment Date is not required for a Customer Initiated Job. Please remove this date and try again. ';
                                                                                               FailureResponseList.add(fr);
                                                                                           }else{
                                                                                               if(activeServiceAppointment.SchedStartTime!=null && activeServiceAppointment.SchedEndTime!=null && ffaWorkOrder.FFA_RequestedAppointmentDate__c!=null){
                                                                                                   /*if(activeServiceAppointment.SchedStartTime.date() <= ffaWorkOrder.FFA_RequestedAppointmentDate__c.date() && ){
if(ffaWorkOrder.FFA_EmergencyFlag__c==true && ffaWorkOrder.FFA_Sender_ID__c!='RAINBOW'){
activeServiceAppointment.SchedStartTime = System.Datetime.now(); 
activeServiceAppointment.SchedEndTime =System.Datetime.now();
ffaWorkOrder.FFA_RequestedAppointmentDate__c =System.Datetime.now();
ServiceApptIds.add(activeServiceAppointment.Id);
}*/
                                                                                                   isJobCategoryChecked=true;
                                                                                                   system.debug(ffaWorkOrder.WorkOrderNumber);
                                                                                                   //}
                                                                                               }else{
                                                                                                   FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                   fr.WorkOrderNo = workOrderNo;
                                                                                                   fr.Status = 'Failure';
                                                                                                   fr.SupportingInfo = 'Schedule Start date and Schedule End date is not available. Please check the dates in SA.';
                                                                                                   FailureResponseList.add(fr);
                                                                                               }
                                                                                           }
                                                                                       }else{
                                                                                           if(activeServiceAppointment.SchedStartTime!=null && activeServiceAppointment.SchedEndTime!=null && ffaWorkOrder.FFA_RequestedAppointmentDate__c!=null){
                                                                                               //Commented As Discusced with MH 5/5/2020
                                                                                               // if(activeServiceAppointment.SchedStartTime.date() <= ffaWorkOrder.FFA_RequestedAppointmentDate__c.date() && activeServiceAppointment.SchedEndTime.date() >= ffaWorkOrder.FFA_RequestedAppointmentDate__c.date()){
                                                                                               /* if(ffaWorkOrder.FFA_EmergencyFlag__c==true && ffaWorkOrder.FFA_Sender_ID__c!='RAINBOW'){
activeServiceAppointment.SchedStartTime = System.Datetime.now(); 
activeServiceAppointment.SchedEndTime =System.Datetime.now();
ffaWorkOrder.FFA_RequestedAppointmentDate__c =System.Datetime.now();
ServiceApptIds.add(activeServiceAppointment.Id);
}*/
                                                                                               isJobCategoryChecked=true;
                                                                                               // }
                                                                                           }else{
                                                                                               FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                               fr.WorkOrderNo = workOrderNo;
                                                                                               fr.Status = 'Failure';
                                                                                               fr.SupportingInfo = 'Schedule Start date and Schedule End date is not available. Please check the dates in SA.';
                                                                                               FailureResponseList.add(fr);
                                                                                           }
                                                                                       }
                                                                                       
                                                                                   }else if((ffaWorkOrder.Job_Category__c=='NGM initiated Job' || ffaWorkOrder.Job_Category__c == 'NGM Initiated - Maintenance Job' || ffaWorkOrder.Job_Category__c == 'NGM Initiated - Non Maintenance Job') && (activeServiceAppointment.Status=='Scheduled' || activeServiceAppointment.Status=='Enroute')){
                                                                                       if(activeServiceAppointment.SchedStartTime!=null && activeServiceAppointment.SchedEndTime!=null){
                                                                                           system.debug('Date come here');
                                                                                           if(scheduleObjectMap.get('AppointmentDate')!=null){
                                                                                               string AppointmentDateString = scheduleObjectMap.get('AppointmentDate').toString();
                                                                                               if(string.isNotBlank(AppointmentDateString)){
                                                                                                   isJobCategoryChecked=true;
                                                                                               }else{
                                                                                                   isJobCategoryChecked=true;
                                                                                               }
                                                                                           }else{
                                                                                               isJobCategoryChecked=true;
                                                                                           }
                                                                                           /* if(string.isNotBlank(AppointmentDateString)){
date jsonAppointmentDate = date.valueOf(AppointmentDateString);
if(jsonAppointmentDate >= activeServiceAppointment.SchedStartTime.date() && jsonAppointmentDate <= activeServiceAppointment.SchedEndTime.date()){
isJobCategoryChecked=true;
}else{
system.debug('Date come here===1');
FailedSchedulingResults fr = new FailedSchedulingResults();
fr.WorkOrderNo = workOrderNo;
fr.Status = 'Failure';
fr.SupportingInfo = 'Appointment Date is not within the AppointmentStartDate & AppointmentEndDate range of the Service Appointment or Appointment Date is in Past or it is a Customer initiated job. Please use the correct date and ensure the job is not a Customer initiated job.';
FailureResponseList.add(fr);
}
}else{
FailedSchedulingResults fr = new FailedSchedulingResults();
fr.WorkOrderNo = workOrderNo;
fr.Status = 'Failure';
fr.SupportingInfo = 'Appointment date is required for NGM Initiated job while reassigning an engineer.';
FailureResponseList.add(fr);
} */
                                                                                           
                                                                                       }else{
                                                                                           FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                           fr.WorkOrderNo = workOrderNo;
                                                                                           fr.Status = 'Failure';
                                                                                           fr.SupportingInfo = 'Schedule Start date and Schedule End date is not available in service appointment of the work order.';
                                                                                           FailureResponseList.add(fr);
                                                                                       }
                                                                                       
                                                                                   }else{
                                                                                       FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                       fr.WorkOrderNo = workOrderNo;
                                                                                       fr.Status = 'Failure';
                                                                                       fr.SupportingInfo = 'No Job category found.';
                                                                                       FailureResponseList.add(fr);
                                                                                   }
                                                                                   
                                                                                   // Validate the Engineer ID here if user provide the incorrect engineer ID which not belongs from database
                                                                                   boolean IsEngineerValid;
                                                                                   String ValidDomesticNGMEngineerID;
                                                                                   if(scheduleObjectMap.get('EngineerID')!=null){
                                                                                       ValidDomesticNGMEngineerID = scheduleObjectMap.get('EngineerID').toString();
                                                                                       string checkEngineerUsername=scheduleObjectMap.get('EngineerID').toString();
                                                                                       if(validEngineersIdMap!=null){
                                                                                           if(validEngineersIdMap.containsKey(checkEngineerUsername.toUpperCase())){
                                                                                               IsEngineerValid=true;
                                                                                           }
                                                                                       }
                                                                                   }
                                                                                   
                                                                                   
                                                                                   
                                                                                   if(isJobCategoryChecked==true){
                                                                                       system.debug(ffaWorkOrder.WorkOrderNumber);
                                                                                       if((scheduleObjectMap.get('EngineerID')!=null && ffaWorkOrder.Job_Category__c.contains('NGM') && ffaWorkOrder.FFA_Sender_ID__c!='RAINBOW') ||
                                                                                          (scheduleObjectMap.get('EngineerID')!=null && ffaWorkOrder.Job_Category__c.contains('Customer') && ffaWorkOrder.FFA_Sender_ID__c!='RAINBOW')){
                                                                                              EngineerID = scheduleObjectMap.get('EngineerID').toString();
                                                                                              if(string.isNotBlank(EngineerID) && IsEngineerValid==true){
                                                                                                  if(ffaEngineers.size()!=0){
                                                                                                      for(User u: ffaEngineers){
                                                                                                          if(u.Username == EngineerID){
                                                                                                              if(!u.ServiceResources.isEmpty()){
                                                                                                                  AssignedResource newAssignedResource = new AssignedResource();
                                                                                                                  newAssignedResource.ServiceAppointmentId = activeServiceAppointment.Id;
                                                                                                                  if(!test.isrunningtest()){newAssignedResource.ServiceResourceId = u.ServiceResources[0].Id;}
                                                                                                                  assignedResToUpdate.add(newAssignedResource);
                                                                                                                  isEngineerFound=true;
                                                                                                                  
                                                                                                              }else{
                                                                                                                  system.debug('1 ====');
                                                                                                                  if(oldARList.size()>0){
                                                                                                                      for(oldAssignResources OldAR : oldARList){
                                                                                                                          if(OldAR.ServiceAppointmentId == activeServiceAppointment.Id){
                                                                                                                              AssignedResource newAssignedResource = new AssignedResource();
                                                                                                                              newAssignedResource.ServiceAppointmentId = activeServiceAppointment.Id;
                                                                                                                              if(!test.isrunningtest()){newAssignedResource.ServiceResourceId = OldAR.ServiceResourceId;}
                                                                                                                              assignedResToUpdate.add(newAssignedResource);
                                                                                                                          }
                                                                                                                      }
                                                                                                                  }
                                                                                                                  FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                  fr.WorkOrderNo = workOrderNo;
                                                                                                                  fr.Status = 'Failure';
                                                                                                                  fr.SupportingInfo = 'Invalid Engineer Id or Engineer does not exist in FFA. Please ensure the engineer is setup correctly and the Engineer Id (FFA User Name) is correct.';
                                                                                                                  FailureResponseList.add(fr);
                                                                                                                  system.debug(FailureResponseList);
                                                                                                              }
                                                                                                          }
                                                                                                      }
                                                                                                  }
                                                                                              }else{
                                                                                                  system.debug('4 ====');
                                                                                                  if(oldARList.size()>0){
                                                                                                      for(oldAssignResources OldAR : oldARList){
                                                                                                          if(OldAR.ServiceAppointmentId == activeServiceAppointment.Id){
                                                                                                              AssignedResource newAssignedResource = new AssignedResource();
                                                                                                              newAssignedResource.ServiceAppointmentId = activeServiceAppointment.Id;
                                                                                                              if(!test.isrunningtest()){newAssignedResource.ServiceResourceId = OldAR.ServiceResourceId;}
                                                                                                              assignedResToUpdate.add(newAssignedResource);
                                                                                                          }
                                                                                                      }
                                                                                                  }
                                                                                                  FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                  fr.WorkOrderNo = workOrderNo;
                                                                                                  fr.Status = 'Failure';
                                                                                                  fr.SupportingInfo = 'Engineer Id is requried for scheduing. Please provide a valid EngineerId and try again.';
                                                                                                  FailureResponseList.add(fr);
                                                                                                  system.debug(FailureResponseList);
                                                                                              }
                                                                                          }else if((scheduleObjectMap.get('EngineerID') != null && ffaWorkOrder.Job_Category__c.contains('NGM') && ffaWorkOrder.FFA_Sender_ID__c == 'RAINBOW' && (activeServiceAppointment.Status == 'Scheduled' || activeServiceAppointment.Status == 'Enroute')) ||
                                                                                                   (scheduleObjectMap.get('EngineerID') != null && ffaWorkOrder.Job_Category__c.contains('Customer') && ffaWorkOrder.FFA_Sender_ID__c == 'RAINBOW')){
                                                                                                       EngineerID = scheduleObjectMap.get('EngineerID').toString();
                                                                                                       if(string.isNotBlank(EngineerID) && IsEngineerValid==true){
                                                                                                           if(ffaEngineers.size()!=0){
                                                                                                               for(User u: ffaEngineers){
                                                                                                                   system.debug(u.Username+' username & EngineerID '+EngineerID);
                                                                                                                   if(u.Username == EngineerID){
                                                                                                                       if(!u.ServiceResources.isEmpty()){
                                                                                                                           AssignedResource newAssignedResource = new AssignedResource();
                                                                                                                           newAssignedResource.ServiceAppointmentId = activeServiceAppointment.Id;
                                                                                                                           if(!test.isrunningtest()){newAssignedResource.ServiceResourceId = u.ServiceResources[0].Id;}
                                                                                                                           assignedResToUpdate.add(newAssignedResource);
                                                                                                                           isEngineerFound=true;
                                                                                                                           
                                                                                                                       }else{
                                                                                                                           system.debug('5 ====');
                                                                                                                           if(oldARList.size()>0){
                                                                                                                               for(oldAssignResources OldAR : oldARList){
                                                                                                                                   if(OldAR.ServiceAppointmentId == activeServiceAppointment.Id){
                                                                                                                                       AssignedResource newAssignedResource = new AssignedResource();
                                                                                                                                       newAssignedResource.ServiceAppointmentId = activeServiceAppointment.Id;
                                                                                                                                       if(!test.isrunningtest()){newAssignedResource.ServiceResourceId = OldAR.ServiceResourceId;}
                                                                                                                                       assignedResToUpdate.add(newAssignedResource);
                                                                                                                                   }
                                                                                                                               }
                                                                                                                           }
                                                                                                                           FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                           fr.WorkOrderNo = workOrderNo;
                                                                                                                           fr.Status = 'Failure';
                                                                                                                           fr.SupportingInfo = 'Invalid Engineer Id or Engineer does not exist in FFA. Please ensure the engineer is setup correctly and the Engineer Id (FFA User Name) is correct.';
                                                                                                                           FailureResponseList.add(fr);
                                                                                                                           system.debug(ffaWorkOrder.WorkOrderNumber);
                                                                                                                           system.debug(FailureResponseList);
                                                                                                                       }
                                                                                                                   }
                                                                                                               }
                                                                                                           }
                                                                                                       }else{
                                                                                                           system.debug('8 ====');
                                                                                                           if(oldARList.size()>0){
                                                                                                               for(oldAssignResources OldAR : oldARList){
                                                                                                                   if(OldAR.ServiceAppointmentId == activeServiceAppointment.Id){
                                                                                                                       AssignedResource newAssignedResource = new AssignedResource();
                                                                                                                       newAssignedResource.ServiceAppointmentId = activeServiceAppointment.Id;
                                                                                                                       if(!test.isrunningtest()){newAssignedResource.ServiceResourceId = OldAR.ServiceResourceId;}
                                                                                                                       assignedResToUpdate.add(newAssignedResource);
                                                                                                                   }
                                                                                                               }
                                                                                                           }
                                                                                                           FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                           fr.WorkOrderNo = workOrderNo;
                                                                                                           fr.Status = 'Failure';
                                                                                                           fr.SupportingInfo = 'Invalid Engineer Id or Engineer does not exist in FFA. Please ensure the engineer is setup correctly and the Engineer Id (FFA User Name) is correct.';
                                                                                                           FailureResponseList.add(fr);
                                                                                                           system.debug(FailureResponseList);
                                                                                                       }
                                                                                                   }else if((String.isEmpty(ValidDomesticNGMEngineerID) && ffaWorkOrder.Job_Category__c.contains('NGM') && ffaWorkOrder.FFA_Sender_ID__c=='RAINBOW' && activeServiceAppointment.Status=='None')){
                                                                                                       if(oldARList.size()>0){
                                                                                                           for(oldAssignResources OldAR : oldARList){
                                                                                                               if(OldAR.ServiceAppointmentId == activeServiceAppointment.Id){
                                                                                                                   AssignedResource newAssignedResource = new AssignedResource();
                                                                                                                   newAssignedResource.ServiceAppointmentId = activeServiceAppointment.Id;
                                                                                                                   if(!test.isrunningtest()){newAssignedResource.ServiceResourceId = OldAR.ServiceResourceId;}
                                                                                                                   assignedResToUpdate.add(newAssignedResource);
                                                                                                                   isEngineerFound=true;
                                                                                                                   isSRNotAvailableForRainbowNGM=true;
                                                                                                                   ffaWorkOrder.PolicyReplanJob__c =false;
                                                                                                                   ffaWorkOrder.FFA_RequestedAppointmentDate__c = appointmentDateTime;
                                                                                                                   system.debug('Policy job'+activeServiceAppointment.SchedStartTime+'=='+activeServiceAppointment.SchedEndTime);
                                                                                                               }
                                                                                                           }
                                                                                                       }else{
                                                                                                           system.debug('Policy job'+activeServiceAppointment.SchedStartTime+'=='+activeServiceAppointment.SchedEndTime);
                                                                                                           isEngineerFound=true;
                                                                                                           isSRNotAvailableForRainbowNGM=true;
                                                                                                           ffaWorkOrder.FFA_RequestedAppointmentDate__c = appointmentDateTime;
                                                                                                           if(ffaWorkOrder.Job_Category__c == 'NGM Initiated - Non Maintenance Job'){ffaWorkOrder.PolicyReplanJob__c =true;system.debug('Policy job'+activeServiceAppointment.SchedStartTime+'=='+activeServiceAppointment.SchedEndTime);}else{ffaWorkOrder.PolicyReplanJob__c =false;}
                                                                                                       }
                                                                                                   }else if((scheduleObjectMap.get('EngineerID')==null && ffaWorkOrder.Job_Category__c.contains('NGM') && ffaWorkOrder.FFA_Sender_ID__c=='RAINBOW' && activeServiceAppointment.Status=='None')){
                                                                                                       if(oldARList.size()>0){
                                                                                                           for(oldAssignResources OldAR : oldARList){
                                                                                                               if(OldAR.ServiceAppointmentId == activeServiceAppointment.Id){
                                                                                                                   AssignedResource newAssignedResource = new AssignedResource();
                                                                                                                   newAssignedResource.ServiceAppointmentId = activeServiceAppointment.Id;
                                                                                                                   if(!test.isrunningtest()){newAssignedResource.ServiceResourceId = OldAR.ServiceResourceId;}
                                                                                                                   assignedResToUpdate.add(newAssignedResource);
                                                                                                                   isEngineerFound=true;
                                                                                                                   isSRNotAvailableForRainbowNGM=true;
                                                                                                                   ffaWorkOrder.PolicyReplanJob__c =false;
                                                                                                                   ffaWorkOrder.FFA_RequestedAppointmentDate__c = appointmentDateTime;
                                                                                                                   system.debug('Policy job'+activeServiceAppointment.SchedStartTime+'=='+activeServiceAppointment.SchedEndTime);
                                                                                                               }
                                                                                                           }
                                                                                                       }else{
                                                                                                           system.debug('Policy job'+activeServiceAppointment.SchedStartTime+'=='+activeServiceAppointment.SchedEndTime);
                                                                                                           isEngineerFound=true;
                                                                                                           isSRNotAvailableForRainbowNGM=true;
                                                                                                           ffaWorkOrder.FFA_RequestedAppointmentDate__c = appointmentDateTime;
                                                                                                           if(ffaWorkOrder.Job_Category__c == 'NGM Initiated - Non Maintenance Job'){ffaWorkOrder.PolicyReplanJob__c =true;system.debug('Policy job'+activeServiceAppointment.SchedStartTime+'=='+activeServiceAppointment.SchedEndTime);}else{ffaWorkOrder.PolicyReplanJob__c =false;}
                                                                                                       }
                                                                                                   }else if((scheduleObjectMap.get('EngineerID')!=null && ffaWorkOrder.Job_Category__c.contains('NGM') && ffaWorkOrder.FFA_Sender_ID__c=='RAINBOW' && activeServiceAppointment.Status=='None')){
                                                                                                       EngineerID = scheduleObjectMap.get('EngineerID').toString();
                                                                                                       if(string.isNotBlank(EngineerID) && IsEngineerValid==true){
                                                                                                           if(ffaEngineers.size()!=0){
                                                                                                               for(User u: ffaEngineers){
                                                                                                                   if(u.Username == EngineerID){
                                                                                                                       if(!u.ServiceResources.isEmpty()){
                                                                                                                           AssignedResource newAssignedResource = new AssignedResource();
                                                                                                                           newAssignedResource.ServiceAppointmentId = activeServiceAppointment.Id;
                                                                                                                           if(!test.isrunningtest()){newAssignedResource.ServiceResourceId = u.ServiceResources[0].Id;}
                                                                                                                           assignedResToUpdate.add(newAssignedResource);
                                                                                                                           isEngineerFound=true;
                                                                                                                           ffaWorkOrder.PolicyReplanJob__c =false;
                                                                                                                       }else{
                                                                                                                           system.debug('5 ====');
                                                                                                                           if(oldARList.size()>0){
                                                                                                                               for(oldAssignResources OldAR : oldARList){
                                                                                                                                   if(OldAR.ServiceAppointmentId == activeServiceAppointment.Id){
                                                                                                                                       AssignedResource newAssignedResource = new AssignedResource();
                                                                                                                                       newAssignedResource.ServiceAppointmentId = activeServiceAppointment.Id;
                                                                                                                                       if(!test.isrunningtest()){newAssignedResource.ServiceResourceId = OldAR.ServiceResourceId;}
                                                                                                                                       assignedResToUpdate.add(newAssignedResource);
                                                                                                                                       ffaWorkOrder.PolicyReplanJob__c =false;
                                                                                                                                   }
                                                                                                                               }
                                                                                                                           }
                                                                                                                           FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                           fr.WorkOrderNo = workOrderNo;
                                                                                                                           fr.Status = 'Failure';
                                                                                                                           fr.SupportingInfo = 'Invalid Engineer Id or Engineer does not exist in FFA. Please ensure the engineer is setup correctly and the Engineer Id (FFA User Name) is correct.';
                                                                                                                           FailureResponseList.add(fr);
                                                                                                                           ffaWorkOrder.PolicyReplanJob__c =false;
                                                                                                                           system.debug(FailureResponseList);
                                                                                                                       }
                                                                                                                   }
                                                                                                               }
                                                                                                           }
                                                                                                       }else{
                                                                                                           system.debug('55 ====');
                                                                                                           if(oldARList.size()>0){
                                                                                                               for(oldAssignResources OldAR : oldARList){
                                                                                                                   if(OldAR.ServiceAppointmentId == activeServiceAppointment.Id){
                                                                                                                       AssignedResource newAssignedResource = new AssignedResource();
                                                                                                                       newAssignedResource.ServiceAppointmentId = activeServiceAppointment.Id;
                                                                                                                       if(!test.isrunningtest()){newAssignedResource.ServiceResourceId = OldAR.ServiceResourceId;}
                                                                                                                       assignedResToUpdate.add(newAssignedResource);
                                                                                                                       isEngineerFound=true;
                                                                                                                       isSRNotAvailableForRainbowNGM=true;
                                                                                                                       ffaWorkOrder.PolicyReplanJob__c =false;
                                                                                                                       ffaWorkOrder.FFA_RequestedAppointmentDate__c = appointmentDateTime;
                                                                                                                   }
                                                                                                               }
                                                                                                           }
                                                                                                               FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                               fr.WorkOrderNo = workOrderNo;
                                                                                                               fr.Status = 'Failure';
                                                                                                               fr.SupportingInfo = 'Invalid Engineer Id or Engineer does not exist in FFA. Please ensure the engineer is setup correctly and the Engineer Id (FFA User Name) is correct.';
                                                                                                               FailureResponseList.add(fr);
                                                                                                               system.debug(FailureResponseList);
                                                                                                       }
                                                                                                   }else{
                                                                                                       system.debug('9 ====');
                                                                                                       if(oldARList.size()>0){
                                                                                                           for(oldAssignResources OldAR : oldARList){
                                                                                                               if(OldAR.ServiceAppointmentId == activeServiceAppointment.Id){
                                                                                                                   AssignedResource newAssignedResource = new AssignedResource();
                                                                                                                   newAssignedResource.ServiceAppointmentId = activeServiceAppointment.Id;
                                                                                                                   if(!test.isrunningtest()){newAssignedResource.ServiceResourceId = OldAR.ServiceResourceId;}
                                                                                                                   assignedResToUpdate.add(newAssignedResource);
                                                                                                               }
                                                                                                           }
                                                                                                       }
                                                                                                       FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                       fr.WorkOrderNo = workOrderNo;
                                                                                                       fr.Status = 'Failure';
                                                                                                       fr.SupportingInfo = 'Engineer Id is requried for scheduing. Please provide a valid EngineerId and try again.';
                                                                                                       FailureResponseList.add(fr);
                                                                                                       system.debug(FailureResponseList);
                                                                                                   }
                                                                                       
                                                                                       if(isEngineerFound==true){
                                                                                           if(isSRNotAvailableForRainbowNGM==true){
                                                                                               activeServiceAppointment.Status='None';
                                                                                               ffaWorkOrder.Status ='New';
                                                                                               activeServiceAppointment.FFAAssignedAPI__c = '';
                                                                                           }else{
                                                                                               system.debug('In main code SA status is 856== '+activeServiceAppointment.Status);
                                                                                               activeServiceAppointment.Status='Scheduled';
                                                                                               ffaWorkOrder.Status ='Assigned';
                                                                                           }
                                                                                           system.debug('Policy job'+activeServiceAppointment.SchedStartTime+'=='+activeServiceAppointment.SchedEndTime);
                                                                                           system.debug('Eng found=='+isEngineerFound);
                                                                                           saToUpdate.add(activeServiceAppointment);
                                                                                           ffaWorkOrder.Sync_Status__c='Acknowledged';
                                                                                           woToUpdate.add(ffaWorkOrder);
                                                                                       }
                                                                                   }
                                                                               }
                                                                               
                                                                               return FailureResponseList;   
                                                                           }
    
    static List<AcknowledgementResponse> AcknowledgeWorkOrderBatch(Map<String,Object> reqBodyMap){
        List<Acknowledge> bodyAcks= new List<Acknowledge>();
        
        RestRequest req = RestContext.request;
        String workOrdersForAck= JSON.serialize(reqBodyMap.get('Acknowledge'));
        
        //Create a List of Service Appointments as received in the request body for processing
        if (reqBodyMap.get('Acknowledge')instanceof List<Object>) //If an array of objects
        {
            bodyAcks = (List<Acknowledge>)JSON.deserialize(workOrdersForAck, List<Acknowledge>.class);
        }       
        else
        {    
            Acknowledge bodyAck = (Acknowledge)JSON.deserialize(workOrdersForAck, Acknowledge.class); 
            bodyAcks.add(bodyAck);
        }
        
        List<String> reqBatchIDs = new List<String>();
        for (Acknowledge ack: bodyAcks)
        {
            Map<String,Object> ackMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(ack));
            
            String batchID=(String)ackMapObject.get('BatchID');
            if (!String.isEmpty(batchID))
            {
                reqBatchIDs.add(batchID);
                system.debug(reqBatchIDs);
            }
        }
        list<string> woBatchNumberfromQuery = new list<string>();
        List<AcknowledgementResponse> ackResponseList = new List<AcknowledgementResponse> ();
        List<WorkOrder> workOrdersAck = [SELECT ID, WorkOrderNumber, Batch_No__c, Sync_Status__c from WORKORDER WHERE Sync_Status__c = 'Fetched' AND Batch_No__c in : reqBatchIDs];
        if(workOrdersAck.size()==0)
        {
            AcknowledgementResponse ackResponse = new AcknowledgementResponse();
            ackResponse.BatchId='N/A';
            ackResponse.ProcessingStatus='Failed';
            ackResponse.SupportingInfo='Batch Ids do not exist.';
            ackResponseList.add(ackResponse);
            return ackResponseList;
        }
        List<WorkOrder>acksToUpdate = new List<WorkOrder>();
        if(!workOrdersAck.isEmpty()){
            for (WorkOrder wo: workOrdersAck){
                woBatchNumberfromQuery.add(wo.Batch_No__c);
                wo.Sync_Status__c= 'Acknowledged';
                //wo.Status = 'New';// Update by Ankit -- 19/08/2019 according the requirement
                acksToUpdate.add(wo);
            }
        }
        ackResponseList = UpdateWorkOrderAcknowledgmentRecords(acksToUpdate);
        return ackResponseList;
    }
    
    static List<SchedulingResponse> UpdateSAWORecords(List<ServiceAppointment> saToUpdate,List<WorkOrder> woToUpdate, List<AssignedResource>assignedResToUpdate,Boolean isAssignResourceDelete,Set<Id> ServiceApptIds,list<FailedSchedulingResults> schFailureResponseList){
        boolean afterAllUpdatesCheck=false;
        //Update Service Appointment Records
        List<SchedulingResponse> schedResList = new List<SchedulingResponse>();
        Database.SaveResult[] srARList;
        Database.DeleteResult[] srARListDelete;
        if(isAssignResourceDelete==false){
            srARList = Database.insert(assignedResToUpdate,false);
            System.debug(''+srARList.size());
        }else{
            srARListDelete = Database.delete(assignedResToUpdate);
            System.debug(''+srARListDelete.size());
        }
        //system.debug('saveresult AR is ' +srARList);
        //system.debug('DeleteResult AR is ' +srARListDelete.size());
        system.debug('saToUpdate is ' + saToUpdate.size());
        Database.SaveResult[] srSchedList = Database.update(saToUpdate,false);
        system.debug('saveresult SA is ' +srSchedList.size());
        
        Database.SaveResult[] srWOList = Database.update(woToUpdate,false);
        system.debug('saveresult WO is ' +srWOList.size());
        
        // for(Database.SaveResult sr : srSchedList){
        // for (Integer i = 0; i > woToUpdate.size(); i++) { 30/07 21:49  This line was the culprit for not showing 
        for (Integer i = 0; i < woToUpdate.size(); i++) {
            Database.SaveResult srSA;
            if(srSchedList[i]!=null){ srSA = srSchedList[i];}
            
            Database.SaveResult srWO = srWOList[i];
            
            Database.DeleteResult srARD;
            
            if(srARListDelete!=null){
                srARD = srARListDelete[i];
                System.debug(srARD);
            }
            
            ServiceAppointment origSARecord = saToUpdate[i];
            WorkOrder origWORecord = woToUpdate[i];
            //AssignedResource origARRecord = assignedResToUpdate[i];
            
            SchedulingResponse schedResponse = new SchedulingResponse();
            schedResponse.WorkOrderNo= woToUpdate[i].WorkOrderNumber;
            schedResponse.WorkOrderStatus= woToUpdate[i].Status;
            
            schedResponse.ServiceAppointmentNo = saToUpdate[i].AppointmentNumber;
            schedResponse.ServiceAppointmentStatus = saToUpdate[i].Status;
            schedResponse.AppointmentDate =  String.valueOf(saToUpdate[i].SchedStartTime);
            // schedResponse.AssignedEngineer = assignedResToUpdate[i].
            if(srARD!=null){
                if(srARD.isSuccess()){
                    if(srSA.isSuccess()){
                        if(srWO.isSuccess()){
                            afterAllUpdatesCheck=true;
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully updated record. Record ID: ' + srSA.getId());
                            schedResponse.ProcessingStatus='Success';
                            schedResponse.SupportingInfo='Workorder Unassign sucessfully';
                            schedResList.add(schedResponse); 
                            system.debug('scheduleProcessingStatusList ' + schedResList); 
                        }
                    }
                }else{
                    for(Database.Error err : srARD.getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                        FailedSchedulingResults fr = new FailedSchedulingResults();
                        fr.WorkOrderNo = woToUpdate[i].WorkOrderNumber;
                        fr.Status = 'Failure';
                        fr.SupportingInfo = err.getMessage() + ' Fields that affected this error: ' + err.getFields();
                        schFailureResponseList.add(fr);
                        //schedResponse.ProcessingStatus = 'Workorder Update Failed';
                        //schedResponse.SupportingInfo = 'The following error has occurred: ' + err.getMessage() + 'Fields that affected this error: ' + err.getFields();
                        //schedResList.add(schedResponse);
                    }  
                }}
            
            if(srARD==null){
                if (srSA.isSuccess()){
                    if(srWO.isSuccess())
                    {
                        afterAllUpdatesCheck=true;
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully updated record. Record ID: ' + srSA.getId());
                        schedResponse.ProcessingStatus='Success';
                        schedResponse.SupportingInfo='Workorder scheduled sucessfully';
                        schedResList.add(schedResponse); 
                        system.debug('scheduleProcessingStatusList ' + schedResList); 
                        
                    }
                    else
                    {
                        for(Database.Error err : srWO.getErrors()){
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('fields that affected this error: ' + err.getFields());
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = woToUpdate[i].WorkOrderNumber;
                            fr.Status = 'Failure';
                            fr.SupportingInfo = err.getMessage() + ' Fields that affected this error: ' + err.getFields();
                            schFailureResponseList.add(fr);
                            //schedResponse.ProcessingStatus = 'Workorder Update Failed';
                            //schedResponse.SupportingInfo = 'The following error has occurred: ' + err.getMessage() + 'Fields that affected this error: ' + err.getFields();
                            //schedResList.add(schedResponse);
                        }
                    }
                    
                }else{
                    // Operation failed, so get all errors                
                    for(Database.Error err : srSA.getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                        FailedSchedulingResults fr = new FailedSchedulingResults();
                        fr.WorkOrderNo = woToUpdate[i].WorkOrderNumber;
                        fr.Status = 'Failure';
                        fr.SupportingInfo = err.getMessage() + ' Fields that affected this error: ' + err.getFields();
                        schFailureResponseList.add(fr);
                        //schedResponse.ProcessingStatus = 'Service Appointment Update Failed';
                        //schedResponse.SupportingInfo = 'The following error has occurred: ' + err.getMessage() + 'Fields that affected this error: ' + err.getFields();
                        //schedResList.add(schedResponse);
                    }
                }}
            
        } 
        if(isAssignResourceDelete==false){
            if(!srARList.isEmpty()){
                for(Integer i = 0; i < srARList.size(); i++){
                    Database.SaveResult srAR;
                    srAR = srARList[i];
                    SchedulingResponse schedResponse = new SchedulingResponse();
                    if(srAR!=null){
                        if(srAR.isSuccess()){
                            afterAllUpdatesCheck=true;
                            boolean isAssignResourceUpdated = true;
                            system.debug(isAssignResourceUpdated);
                        }
                    }
                    else
                    {
                        for(Database.Error err : srAR.getErrors()){
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('fields that affected this error: ' + err.getFields());
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = woToUpdate[i].WorkOrderNumber;
                            fr.Status = 'Failure';
                            fr.SupportingInfo = err.getMessage() + ' Fields that affected this error: ' + err.getFields();
                            schFailureResponseList.add(fr);
                            //schedResponse.ProcessingStatus = 'Workorder Update Failed';
                            //schedResponse.SupportingInfo = 'The following error has occurred: ' + err.getMessage() + 'Fields that affected this error: ' + err.getFields();
                            //schedResList.add(schedResponse);
                        }  
                    }
                }
            }
        }
        
        if(ServiceApptIds!=null && afterAllUpdatesCheck==true){if(!ServiceApptIds.isEmpty()){
            FFAServiceAppointmentSlotsHandler.changeServiceApptTime(ServiceApptIds);
        }}
        
        System.debug(schedResList);
        return  schedResList;
    }
    
    static List<AcknowledgementResponse> UpdateWorkOrderAcknowledgmentRecords(List<WorkOrder>ackToUpdate){
        
        List<AcknowledgementResponse> ackResList;
        //Update Batch Id field in the Workorder object
        Database.SaveResult[] srAckList = Database.update(ackToUpdate,false);
        ackResList= new List<AcknowledgementResponse>();
        
        //  for(Database.SaveResult sr : srAckList){
        for (Integer i= 0; i<ackToUpdate.size();i++) {
            
            WorkOrder ackOriginalRecord = ackToUpdate[i];
            Database.SaveResult srAck = srAckList[i];
            
            AcknowledgementResponse ackRes = new AcknowledgementResponse();
            if (srAck.isSuccess()){
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated record. Record ID: ' + srAck.getId());
                ackRes.WorkOrderNo = ackToUpdate[i].WorkOrderNumber;
                ackRes.BatchId = ackToUpdate[i].Batch_No__c;
                ackRes.ProcessingStatus = 'Success';
                ackRes.SupportingInfo ='Workorder acknowledged';
                ackResList.add(ackRes);
                
            }else{
                // Operation failed, so get all errors                
                for(Database.Error err : srAck.getErrors()){
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('fields that affected this error: ' + err.getFields());
                    ackRes.WorkOrderNo = ackToUpdate[i].WorkOrderNumber;
                    ackRes.BatchId = ackToUpdate[i].Batch_No__c;
                    ackRes.ProcessingStatus = 'Failed';
                    ackRes.SupportingInfo = 'The following error has occurred: ' + err.getMessage() + 'Fields that affected this error: ' + err.getFields();
                    ackResList.add(ackRes);
                }
            }
        } 
        return ackResList;
    }
    
    static datetime convertDateStringToDateTime(string appointmentDateString){
        String stringDate;
        DateTime appointmentDateTime;
        Date checkApointmentDateValid;
        if(string.isNotBlank(appointmentDateString)){
            stringDate = appointmentDateString.substring(0,10) +' 00:00:00.0000z';  //'-' + 
        }
        
        if(string.isnotBlank(stringDate)){
            appointmentDateTime = datetime.valueOf(stringDate);
            Date dateValue = Date.valueOf(appointmentDateTime);
            checkApointmentDateValid = dateValue.addDays(1); //
        }
        return appointmentDateTime;
    }
    
    static list<oldAssignResources> toDeleteServiceResources(set<Id> requiredServiceAptts,list<WorkOrder> ffaWorkOrders){
        String oldSAStatus;
        DateTime oldScheduleStartTime;
        DateTime oldScheduleEndTime;
        boolean isAssignResIsDeleted;
        list<oldAssignResources> oldARList = new list<oldAssignResources>();
        list<ServiceAppointment> oldSAList = new list<ServiceAppointment>();
        list<AssignedResource> oldARDeleteList = new list<AssignedResource>();
        if(requiredServiceAptts!=null){
            list<AssignedResource> newAssignedResourceListForDelete = new list<AssignedResource>();
            newAssignedResourceListForDelete=[SELECT Id, ServiceAppointmentId,ServiceResourceId FROM AssignedResource Where ServiceAppointmentId=:requiredServiceAptts];
            for(AssignedResource ar : newAssignedResourceListForDelete){
                oldAssignResources oldAR = new oldAssignResources();
                oldAR.ServiceResourceId = ar.ServiceResourceId;
                oldAR.ServiceAppointmentId = ar.ServiceAppointmentId;
                oldARList.add(oldAR);
                oldARDeleteList.add(ar);
            }
            for(WorkOrder wo : ffaWorkOrders){
                //ServiceAppointment activeServiceAppointment;
                if(!wo.ServiceAppointments.isEmpty()){
                    for(ServiceAppointment activeServiceAppointment : wo.ServiceAppointments){
                        if(requiredServiceAptts.contains(activeServiceAppointment.Id)){
                            oldScheduleStartTime = activeServiceAppointment.SchedStartTime;
                            oldScheduleEndTime = activeServiceAppointment.SchedEndTime;
                            oldSAStatus=activeServiceAppointment.Status;
                        }
                        activeServiceAppointment.SchedStartTime=oldScheduleStartTime;
                        activeServiceAppointment.SchedEndTime=oldScheduleEndTime;
                        if(activeServiceAppointment.Status == 'Enroute' && wo.FFA_Sender_ID__c=='RAINBOW'){
                            activeServiceAppointment.FFAAssignedAPI__c = 'Assigned';
                        }else{
                            activeServiceAppointment.FFAAssignedAPI__c = '';
                        }
                        if(oldSAStatus != 'None'){activeServiceAppointment.Status = 'Scheduled';}
                        oldSAList.add(activeServiceAppointment);
                    }
                }
            }
            
            
            if(!oldARDeleteList.isEmpty()){
                delete oldARDeleteList;
                isAssignResIsDeleted=true;
            }
            if(isAssignResIsDeleted==true){
                system.debug('before SR delete SA status is ==='+oldSAList[0].Status);
                system.debug('Duplicate Id Check == '+oldSAList.size());
                update oldSAList;
                system.debug('After SR delete SA status is ==='+oldSAList[0].Status);
            }
        }
        return oldARList;
    }
    
    static System.RestResponse CreateHTTPResponse(string RequestPayLoad,string ResponsePayLoad,string StatusCode,string TransactionMessage,string TransactionStatus){
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json;charset=UTF-8');
        SystemTransactionWrapper resWrappers = new SystemTransactionWrapper();
        resWrappers.TransactionStatus = TransactionStatus;
        resWrappers.TransactionMessage = TransactionMessage;
        resWrappers.RequestPayLoad = RequestPayLoad;
        resWrappers.ResponsePayLoad = ResponsePayLoad;
        resWrappers.StatusCode = StatusCode;
        res.responseBody=  Blob.valueOf(JSON.serialize(resWrappers)); 
        system.debug('resWrap---'+JSON.serialize(resWrappers));
        res.responseBody=  Blob.valueOf(JSON.serialize(resWrappers));
        FFA_Interface_Runs__c InterfaceLogs = new FFA_Interface_Runs__c(Interface_Name__c='/FFAAssignedWork',Transaction_Message__c=JSON.serialize(resWrappers), Transaction_Status__c = TransactionStatus);
        insert InterfaceLogs;
        Blob payLoadBlob;
        if(string.isNotBlank(ResponsePayLoad)){
            payLoadBlob = Blob.valueOf(ResponsePayLoad);
        }else{
            payLoadBlob = Blob.valueOf(RequestPayLoad);
        }
        CreateHttpResponseFile(payLoadBlob,InterfaceLogs.id);
        return res;
    }
    
    public static void CreateHttpResponseFile(blob Payload,ID interfaceRunID){
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'WorkorderAssigned.txt'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = interfaceRunID; // Display name of the files
        conVer.VersionData = Payload; // converting your binary string to Blog
        insert conVer;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId =interfaceRunID ; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'InternalUsers';
        insert cDe;
        system.debug(conVer);
        system.debug(cDe);
    }
    
    public class Schedule{
        public string WorkOrderNo;
        public string EngineerID;
        public string AppointmentDate;
        public string AppointmentTimeSlot;
        public Schedule(){}
    }
    
    public class SchedulingResponse{
        public String ProcessingStatus;
        public String SupportingInfo;
        
        public String WorkOrderNo;
        public String WorkOrderStatus;
        
        public String ServiceAppointmentNo;
        public String ServiceAppointmentStatus;
        public String AppointmentDate;
        //public String AssignedEngineer;
        
        public SchedulingResponse(){}
        
    }
    
    public class Acknowledge{
        public string BatchID;
        public Acknowledge(){}
    }
    
    public class Unassign{
        public string WorkOrderNo;
    }
    
    public class FailedSchedulingResults{
        public string WorkOrderNo;
        public string Status;
        public string SupportingInfo;
        public FailedSchedulingResults(){}
    }
    
    public class AcknowledgementResponse{
        public String BatchID;
        public String WorkOrderNo;
        public String ProcessingStatus;
        public String SupportingInfo;
        public AcknowledgementResponse(){}
    }
    
    public class ProcessingStatus{
        public List<SchedulingResponse> SchedulingResults;
        public List<AcknowledgementResponse> AcknowledgementResults;
        public List<FailedSchedulingResults> FailSchedulingResults;
        public ProcessingStatus(){}
    }
    
    public class SystemTransactionWrapper{
        
        public string RequestPayLoad {get; set;}
        public string ResponsePayLoad {get;set;}
        public string StatusCode {get; set;}
        public string TransactionMessage {get; set;}
        public string TransactionStatus {get; set;}
    }
    
    public class oldAssignResources{
        public string ServiceResourceId;
        public string ServiceAppointmentId;
    }
    
}