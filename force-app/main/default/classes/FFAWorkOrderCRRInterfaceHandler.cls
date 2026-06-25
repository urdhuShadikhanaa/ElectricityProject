/////////////////////////////////////////////////
/*          SAP-FFA Reject Update INTERFACE    */
/*          Author: Ankit Tomar                */ 
/*          Company: Wipro Technologies        */
/*          Created Date: 20/01/2020           */
/////////////////////////////////////////////////
@RestResource(urlMapping='/ReplanRejectCancelWorkOrdersFFA/*') 
global with sharing class FFAWorkOrderCRRInterfaceHandler {
    @Httppost
    global static void doPost(){
        try{
            RestRequest req =  RestContext.request;
            list<FailedSchedulingResults> schFailureResponseList = new list<FailedSchedulingResults>();
            list<FailedSchedulingResults> schFailureResponseListAll = new list<FailedSchedulingResults>();
            Map<String, Object> reqBodyMap = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
            String workOrdersForCancel= JSON.serialize(reqBodyMap.get('Cancel'));
            String workOrdersForReplan = JSON.serialize(reqBodyMap.get('Replan'));
            string workOrdersForReject = JSON.serialize(reqBodyMap.get('Reject'));
            string operationName;
            Map<String,WorkOrder> ffaWorkOrderMap = new Map<String,WorkOrder>();
            Map<Id,string> replanServiceAppointmentMap = new Map<Id,String>();
            Map<Id,string> rejectServiceAppointmentMap = new Map<Id,String>();
            Map<Id,string> CancelServiceAppointmentMap = new Map<Id,String>();
            list<WorkOrder> updateWorkOrderList = new list<WorkOrder>();
            list<ServiceAppointment> updateServiceAppointment = new list<ServiceAppointment>();
            Map<string,DateTime> mapAppointmentDate = new Map<string,DateTime>();
            list<Id> WorkOrderIDsList = new list<Id>();
            // This variables is use for Success and Failue response for Cancel, Replan and Reject operation.
            ProcessingStatus processingStatusWrapper = new ProcessingStatus();
            String responseBody;
            
            // define variable for Cancel operation.
            List<SchedulingResponse> scheduleProcessingStatusList = new List<SchedulingResponse>();
            Map<String,Object> cancelObjectMap;
            list<Cancel> bodyOfCancel = new list<Cancel>();
            Set<String> cancelWONumbersSet = new Set<String>();
            List<String> duplicateCancelWOsNumberList = new List<String>();
            List<String> afterQueryCancelWONumbersList = new List<String>();
            List<String> allCancelWONumbersList = new List<String>();
            Map<String,String> ServiceAppJobCodeAndTextMap = new Map<String,String>();
            Map<String,String> ServiceAppJobCodeAndTransactionType = new Map<String,String>();
			//added to avoid soql in for loops
			Map<Id,ServiceAppointment> esistingWoRelatedServiceAppts = new Map<Id,ServiceAppointment>();
            
            boolean IsWONumberDuplicate;
            string removeCancelDuplcateWONumber;
            
            list<FFAWorkOrderFixJobCode__mdt> FFASAJobCodeList = new list<FFAWorkOrderFixJobCode__mdt>();
            FFASAJobCodeList = [select MasterLabel,DeveloperName,Job_Reason__c,Transaction_Type__c,IsActive__c from FFAWorkOrderFixJobCode__mdt where IsActive__c = true];
            if(!FFASAJobCodeList.isEmpty()){
                for(FFAWorkOrderFixJobCode__mdt jobcodestr : FFASAJobCodeList){
                    ServiceAppJobCodeAndTextMap.put(jobcodestr.DeveloperName,jobcodestr.Job_Reason__c);
                    ServiceAppJobCodeAndTransactionType.put(jobcodestr.DeveloperName,jobcodestr.Transaction_Type__c);
                }
            }
            
            // For Cancel operation.
            if(workOrdersForCancel.length()>4){
                if (reqBodyMap.get('Cancel')instanceof List<Object>){
                    bodyOfCancel = (List<Cancel>)JSON.deserialize(workOrdersForCancel, List<Cancel>.class);
                    system.debug(bodyOfCancel);
                }else{
                    Cancel bodyCancel = (Cancel)JSON.deserialize(workOrdersForCancel, Cancel.class); 
                    system.debug('bodycancel ' + bodyCancel);
                    bodyOfCancel.add(bodyCancel);
                    system.debug(bodyOfCancel);
                }
                
                for(Cancel ua : bodyOfCancel){
                    cancelObjectMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(ua));
                    system.debug(cancelObjectMap);
                    IsWONumberDuplicate=cancelWONumbersSet.add(cancelObjectMap.get('WorkOrderNo').toString());
                    if(!IsWONumberDuplicate){
                        duplicateCancelWOsNumberList.add(cancelObjectMap.get('WorkOrderNo').toString());
                        removeCancelDuplcateWONumber=cancelObjectMap.get('WorkOrderNo').toString();
                    }
                    if(string.isNotBlank(removeCancelDuplcateWONumber)){
                        cancelWONumbersSet.remove(removeCancelDuplcateWONumber);
                    }
                    allCancelWONumbersList.add(cancelObjectMap.get('WorkOrderNo').toString());
                    system.debug(cancelWONumbersSet);
                }
                
                if(!cancelWONumbersSet.isEmpty()){
                    list<WorkOrder> ffaWorkOrderCancel = [select id ,WorkOrderNumber, Status, Sync_Status__c ,FFA_Sender_ID__c,FFA_CompletedTerminatedCancelledText__c ,FFA_TerminatedCancelledReasonCode__c
                                                          from WorkOrder where WorkOrderNumber in :cancelWONumbersSet];
                    if(!ffaWorkOrderCancel.isEmpty()){
                        if(!FFASAJobCodeList.isEmpty()){
                            for(WorkOrder wo : ffaWorkOrderCancel){
                                ffaWorkOrderMap.put(wo.WorkOrderNumber,wo);
                                afterQueryCancelWONumbersList.add(wo.WorkOrderNumber);
                                CancelServiceAppointmentMap.put(wo.Id,'Cancel');
                            }
							list<ServiceAppointment> existingSAs = new list<ServiceAppointment>();
							//added to avoid soql in for loops
							if(!CancelServiceAppointmentMap.isEmpty()){
							  existingSAs = [select Id, AppointmentNumber,Status,EarliestStartTime,SchedStartTime,SchedEndTime,DueDate,ParentRecordId from ServiceAppointment WHERE ParentRecordId in:CancelServiceAppointmentMap.keyset()];
                                if(!existingSAs.isEmpty()){
                                   system.debug('**********WO TO BE Cancelled******'+existingSAs.size()+'****WO TO BE Cancelled****'+existingSAs);

                                }
																
							}
                            for(Cancel cancelValue : bodyOfCancel){
                                operationName = 'Cancel';
                                schFailureResponseList=updateOperationOfWORecords(operationName,null,null,cancelValue,ffaWorkOrderMap,ServiceAppJobCodeAndTextMap,ServiceAppJobCodeAndTransactionType,updateServiceAppointment,updateWorkOrderList,null,null,null,existingSAs);
                                schFailureResponseListAll.addAll(schFailureResponseList);
                            }
                        }else{
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = '';
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'Empty cancellation code, Job cannot be cancelled.';
                            schFailureResponseListAll.add(fr);
                        }
                    }else{
                        FailedSchedulingResults fr = new FailedSchedulingResults();
                        fr.WorkOrderNo = '';
                        fr.Status = 'Failure';
                        fr.SupportingInfo = FFA_Constants.UPDATE_WO_NOT_FOUND;
                        schFailureResponseListAll.add(fr);
                    }
                }else{
                    FailedSchedulingResults fr = new FailedSchedulingResults();
                    fr.WorkOrderNo = '';
                    fr.Status = 'Failure';
                    fr.SupportingInfo = 'WorkOrder Number is Empty in Request Payload.';
                    schFailureResponseListAll.add(fr);
                }
                
                if(allCancelWONumbersList!=null){
                    for(string WorkOrderNos : allCancelWONumbersList){
                        if(duplicateCancelWOsNumberList.contains(WorkOrderNos)){
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = WorkOrderNos;
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'Duplicate Work Orders found in the Cancel request.';
                            schFailureResponseListAll.add(fr);
                        }
                        if(!afterQueryCancelWONumbersList.contains(WorkOrderNos) && !duplicateCancelWOsNumberList.contains(WorkOrderNos)){
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = WorkOrderNos;
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'WorkOrder number in cancel request is invalid or empty.';
                            schFailureResponseListAll.add(fr);
                        }
                    }
                }
            }
            
            //For Replan operation
            //This all variable is use for Replan operation.
            Map<String,Object> replanObjectMap;
            list<Replan> bodyOfReplan = new list<Replan>();
            Set<String> replanWONumbersSet = new Set<String>();
            List<String> duplicateReplanWONumberList = new List<String>();
            List<String> allReplanWONumbersList = new List<String>();
            List<String> afterQueryReplanWONumberList = new List<String>();
            Set<Id> ServiceApptIds = new set<Id>();
            boolean isAppTimeSlotAvailable=false;
            
            boolean IsReplanWODuplicate;
            string removeReplanWONumber;
            
            if(workOrdersForReplan.length()>4){
                if (reqBodyMap.get('Replan')instanceof List<Object>){
                    bodyOfReplan = (List<Replan>)JSON.deserialize(workOrdersForReplan, List<Replan>.class);
                    system.debug(bodyOfReplan);
                }else{
                    Replan bodyReplan = (Replan)JSON.deserialize(workOrdersForReplan, Replan.class); 
                    system.debug('bodyReplan ' + bodyReplan);
                    bodyOfReplan.add(bodyReplan);
                    system.debug(bodyOfReplan);
                }
                
                for(Replan re : bodyOfReplan){
                    replanObjectMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(re));
                    system.debug(replanObjectMap);
                    IsReplanWODuplicate=replanWONumbersSet.add(replanObjectMap.get('WorkOrderNo').toString());
                    if(!IsReplanWODuplicate){
                        duplicateReplanWONumberList.add(replanObjectMap.get('WorkOrderNo').toString());
                        removeReplanWONumber=replanObjectMap.get('WorkOrderNo').toString();
                    }
                    if(string.isNotBlank(removeReplanWONumber)){
                        replanWONumbersSet.remove(removeReplanWONumber);
                    }
                    allReplanWONumbersList.add(replanObjectMap.get('WorkOrderNo').toString());
                    system.debug(replanWONumbersSet);
                }
                
                
                if(!replanWONumbersSet.isEmpty()){
                    list<WorkOrder> ffaWorkOrderReplan = [select id ,WorkOrderNumber,FFA_RequestedAppointmentDate__c,FFA_Sender_ID__c,Job_Category__c,FFA_Service_Provider_Replan__c,FFA_Replan_Date_Time__c,FFA_RequestedAppointmentTimeslot__c, Status, Sync_Status__c ,FFA_JobReplanReasonText__c ,FFA_JobReplanReasonCode__c,FFA_UnplannedPolicyStartDate__c,FFA_UnplannedPolicyEndDate__c
                                                          from WorkOrder where WorkOrderNumber in :replanWONumbersSet];
                    system.debug('Replan =='+ffaWorkOrderReplan.size());
                    if(!ffaWorkOrderReplan.isEmpty()){
                        if(!FFASAJobCodeList.isEmpty()){
                            for(WorkOrder wo : ffaWorkOrderReplan){
                                ffaWorkOrderMap.put(wo.WorkOrderNumber,wo);
                                afterQueryReplanWONumberList.add(wo.WorkOrderNumber);
                                replanServiceAppointmentMap.put(wo.Id,'Replan');
                            }
							list<ServiceAppointment> existingSAs = new List<ServiceAppointment>();
                            //added to avoid soql in for loops
							if(!replanServiceAppointmentMap.isEmpty()){
								existingSAs = [select Id, AppointmentNumber,Status,EarliestStartTime,SchedStartTime,SchedEndTime,DueDate,ParentRecordId from ServiceAppointment WHERE ParentRecordId in:replanServiceAppointmentMap.keyset()];
                                if(!existingSAs.isEmpty()){
                                    system.debug('**********WO TO BE replanned******'+existingSAs.size()+'***********WO TO BE replanned******'+existingSAs);
       
                                }
								
							}
							
                            for(Replan replanValue : bodyOfReplan){
                                operationName = 'Replan';
                                schFailureResponseList=updateOperationOfWORecords(operationName,replanValue,null,null,ffaWorkOrderMap,ServiceAppJobCodeAndTextMap,ServiceAppJobCodeAndTransactionType,updateServiceAppointment,updateWorkOrderList,ServiceApptIds,WorkOrderIDsList,mapAppointmentDate,existingSAs);
                                schFailureResponseListAll.addAll(schFailureResponseList);
                            }
                        }else{
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = '';
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'Empty Replan Code, Job cannot be replanned.';
                            schFailureResponseListAll.add(fr);
                        }
                    }else{
                        FailedSchedulingResults fr = new FailedSchedulingResults();
                        fr.WorkOrderNo = '';
                        fr.Status = 'Failure';
                        fr.SupportingInfo = FFA_Constants.UPDATE_WO_NOT_FOUND;
                        schFailureResponseListAll.add(fr);
                    }
                }else{
                    FailedSchedulingResults fr = new FailedSchedulingResults();
                    fr.WorkOrderNo = '';
                    fr.Status = 'Failure';
                    fr.SupportingInfo = 'WorkOrder Number is Empty in Request Payload.';
                    schFailureResponseListAll.add(fr);
                }
                
                if(allReplanWONumbersList!=null){
                    for(string WorkOrderNos : allReplanWONumbersList){
                        if(duplicateReplanWONumberList.contains(WorkOrderNos)){
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = WorkOrderNos;
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'Duplicate Work Orders found in the replan request.';
                            schFailureResponseListAll.add(fr);
                        }
                        if(!afterQueryReplanWONumberList.contains(WorkOrderNos) && !duplicateReplanWONumberList.contains(WorkOrderNos)){
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = WorkOrderNos;
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'WorkOrder number in replan request is invalid or empty.';
                            schFailureResponseListAll.add(fr);
                        }
                    }
                }
            }
            
            //For Reject Operation
            ////This all variable is use for Reject operation.
            Map<String,Object> rejectObjectMap;
            list<Reject> bodyOfReject = new list<Reject>();
            Set<String> rejectWONumbersSet = new Set<String>();
            List<String> duplicateRejectWONumberList = new List<String>();
            List<String> afterQueryRejectWONumberList = new List<String>();
            List<String> allRejectWONumberList = new List<String>();
            List<String> wosInRejectRequestBody = new List<String>();
            
            boolean IsRejectWODuplicate;
            String removeRejectDuplicateWONumber;
            
            
            // For Reject operation.
            if(workOrdersForReject.length()>4){
                if (reqBodyMap.get('Reject')instanceof List<Object>){
                    bodyOfReject = (List<Reject>)JSON.deserialize(workOrdersForReject, List<Reject>.class);
                    system.debug(bodyOfReject);
                }else{
                    Reject bodyReject = (Reject)JSON.deserialize(workOrdersForReject, Reject.class); 
                    system.debug('bodyReject ' + bodyReject);
                    bodyOfReject.add(bodyReject);
                    system.debug(bodyOfReject);
                }
                
                Map<String, WorkOrder> ffaWorkOrderMapReject = new Map<String, WorkOrder>();
                for(Reject ua : bodyOfReject){
                    rejectObjectMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(ua));
                    system.debug(rejectObjectMap);
                    IsRejectWODuplicate=rejectWONumbersSet.add(rejectObjectMap.get('WorkOrderNo').toString());
                    if(!IsRejectWODuplicate){
                        duplicateRejectWONumberList.add(rejectObjectMap.get('WorkOrderNo').toString());
                        removeRejectDuplicateWONumber=rejectObjectMap.get('WorkOrderNo').toString();
                    }
                    if(string.isNotBlank(removeRejectDuplicateWONumber)){
                        rejectWONumbersSet.remove(removeRejectDuplicateWONumber);
                    }
                    allRejectWONumberList.add(rejectObjectMap.get('WorkOrderNo').toString());
                    system.debug(rejectWONumbersSet);
                }
                
                if(!rejectWONumbersSet.isEmpty()){
                    list<WorkOrder> ffaWorkOrderReject = [select id ,WorkOrderNumber, Status, Sync_Status__c,FFA_Sender_ID__c ,FFA_RejectReasonCode__c,FFA_RejectReasonText__c,FFA_CompletedTerminatedCancelledText__c ,FFA_TerminatedCancelledReasonCode__c
                                                          from WorkOrder where WorkOrderNumber in :rejectWONumbersSet];
                    if(!ffaWorkOrderReject.isEmpty()){
                        if(!FFASAJobCodeList.isEmpty()){
                            for(WorkOrder wo : ffaWorkOrderReject){
                                ffaWorkOrderMap.put (wo.WorkOrderNumber,wo);
                                afterQueryRejectWONumberList.add(wo.WorkOrderNumber);
                                rejectServiceAppointmentMap.put(wo.Id,'Reject');
                            }
							list<ServiceAppointment> existingSAs = new list<ServiceAppointment>();
                            //added to avoid soql in for loops
							if(!rejectServiceAppointmentMap.isEmpty()){
							 existingSAs = [select Id, AppointmentNumber,Status,EarliestStartTime,SchedStartTime,SchedEndTime,DueDate,ParentRecordId from ServiceAppointment WHERE ParentRecordId in:rejectServiceAppointmentMap.keyset()];
                                if(!existingSAs.isEmpty()){
                                   system.debug('**********WO TO BE rejected******'+existingSAs.size()+'**********WO TO BE rejected******'+existingSAs);

                                }
															
							}
							
                            for(Reject rejectValue : bodyOfReject){
                                operationName = 'Reject';
                                schFailureResponseList=updateOperationOfWORecords(operationName,null,rejectValue,null,ffaWorkOrderMap,ServiceAppJobCodeAndTextMap,ServiceAppJobCodeAndTransactionType,updateServiceAppointment,updateWorkOrderList,null,null,null,existingSAs);
                                schFailureResponseListAll.addAll(schFailureResponseList);
                            }
                        }else{
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = '';
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'Empty Reject code, Job cannot be rejected.';
                            schFailureResponseListAll.add(fr);
                        }
                    }else{
                        FailedSchedulingResults fr = new FailedSchedulingResults();
                        fr.WorkOrderNo = '';
                        fr.Status = 'Failure';
                        fr.SupportingInfo = FFA_Constants.UPDATE_WO_NOT_FOUND;
                        schFailureResponseListAll.add(fr);
                    }
                }else{
                    FailedSchedulingResults fr = new FailedSchedulingResults();
                    fr.WorkOrderNo = '';
                    fr.Status = 'Failure';
                    fr.SupportingInfo = 'WorkOrder Number is Empty in Request Payload.';
                    schFailureResponseListAll.add(fr);
                }
                
                if(allRejectWONumberList!=null){
                    for(string WorkOrderNos : allRejectWONumberList){
                        if(duplicateRejectWONumberList.contains(WorkOrderNos)){
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = WorkOrderNos;
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'Duplicate Work Orders found in the reject request.';
                            schFailureResponseListAll.add(fr);
                        }
                        if(!afterQueryRejectWONumberList.contains(WorkOrderNos) && !duplicateRejectWONumberList.contains(WorkOrderNos)){
                            FailedSchedulingResults fr = new FailedSchedulingResults();
                            fr.WorkOrderNo = WorkOrderNos;
                            fr.Status = 'Failure';
                            fr.SupportingInfo = 'WorkOrder number in reject request is invalid or empty.';
                            schFailureResponseListAll.add(fr);
                        }
                    }
                }
            }
            List<SchedulingResponse> databaseUpdateCancelSAWOResponse = new List<SchedulingResponse>();
            if(!updateServiceAppointment.isEmpty() && !updateWorkOrderList.IsEmpty()){
                databaseUpdateCancelSAWOResponse = UpdateSAWORecords(updateServiceAppointment,updateWorkOrderList,null,schFailureResponseListAll);
                scheduleProcessingStatusList.addAll(databaseUpdateCancelSAWOResponse);
                //REPLAN BUG FIX:This Will stop further SA Updations
                Set<String> WorkorderNo=new Set<String>();
                For(SchedulingResponse successWOIDs:databaseUpdateCancelSAWOResponse){
                    IF(successWOIDs.ProcessingStatus=='Success'){
                        WorkorderNo.add(successWOIDs.WorkOrderNo);
                    }
                }
                Set<Id> FailedWorkordersExtract=New Set<Id>();
                IF(!WorkorderNo.isEmpty()){
                    List<workorder> WorkorderstoCompare=[SELECT id,WorkOrderNumber from workorder WHERE WorkOrderNumber=:WorkorderNo];
                    For(workorder WorkorderprocesscedMap:WorkorderstoCompare){
                        FailedWorkordersExtract.add(WorkorderprocesscedMap.Id);
                    }
                }
                
                processingStatusWrapper.SchedulingResults = scheduleProcessingStatusList;
                system.debug('Replan WO list == '+WorkOrderIDsList);
				List<WorkOrder> sasToCreateForWosForReplan = new List<WorkOrder>();
				if(!WorkOrderIDsList.isEmpty()){
					sasToCreateForWosForReplan = [Select id,FFA_ServiceProvider__c from workorder WHERE id in:WorkOrderIDsList]; 
				}
                /*if(!WorkOrderIDsList.isEmpty()){
                    for(Id woIds : WorkOrderIDsList){
                        DateTime reqAppDate = mapAppointmentDate.get(woIds);
                        system.debug('Replan Date check here ==='+reqAppDate);
                        system.debug('Failed Work Order Extract list size == '+FailedWorkordersExtract.size());
                        IF(FailedWorkordersExtract.contains(woIds)){
                            createServiceAppointment(reqAppDate,woIds);
                        }
                        mapAppointmentDate.remove(woIds);
                    }
                }*/
				//Added to to avoid DML in for lopp
				List<ServiceAppointment> saToBeCreatedLst = new List<ServiceAppointment>();
				if(!sasToCreateForWosForReplan.isEmpty()){
                    for(WorkOrder woIds : sasToCreateForWosForReplan){
                        DateTime reqAppDate = mapAppointmentDate.get(woIds.Id);
                        system.debug('Replan Date check here ==='+reqAppDate);
                        system.debug('Failed Work Order Extract list size == '+FailedWorkordersExtract.size());
                        IF(FailedWorkordersExtract.contains(woIds.Id)){
                            ServiceAppointment saToBeCreated = createServiceAppointment(reqAppDate,woIds);
							saToBeCreatedLst.add(saToBeCreated);
                        }
                        mapAppointmentDate.remove(woIds.Id);
                    }
					if(!saToBeCreatedLst.isEmpty()){
						Database.SaveResult[] srList = Database.insert(saToBeCreatedLst,false);
						for(Database.SaveResult sr : srList){
							if (sr.isSuccess()){
								// Operation was successful, so get the ID of the record that was processed
								System.debug('Successfully inserted record. Record ID: ' + sr.getId());
							}else{
								// Operation failed, so get all errors                
								for(Database.Error err : sr.getErrors()){
									System.debug('The following error has occurred.');                    
									System.debug(err.getStatusCode() + ': ' + err.getMessage());
									System.debug('fields that affected this error: ' + err.getFields());
								}
							}
						}
					}
                }
            }
            processingStatusWrapper.FailSchedulingResults = schFailureResponseListAll;
            system.debug('Fail sch size=='+schFailureResponseListAll.size());
            // Only when Operation get Success response for Cancel, Replan and Reject
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
            CreateHTTPResponse('Null','Null','400','Invalid JSON or problem with salesforce system, Please Contact respective team','Failure');
            return;
        }
        
    }
    //added extra parameter to avoid soql in for loops
    static list<FailedSchedulingResults> updateOperationOfWORecords(String operationName,Replan repl,Reject rej,Cancel cnl,map<String,WorkOrder> ffaWorkOrderMap,Map<String,String> ServiceAppJobCodeAndTextMap,Map<String,String> ServiceAppJobCodeAndTransactionType,
                                                                    list<ServiceAppointment> updateServiceAppointment,list<WorkOrder> updateWorkOrderList,Set<Id> ServiceApptIds,list<Id> WorkOrderIDsList,Map<string,DateTime> mapAppointmentDate,List<ServiceAppointment> existingWoSAppts){
                                                                        set<Id> WOsIDs = new Set<Id>(); string WONumberForFailure;
                                                                        boolean isAppTimeSlotAvailable=false;
                                                                        list<FailedSchedulingResults> schFailureResponseListAll=new list<FailedSchedulingResults>();
                                                                        Map<String,Object> replanObjectMap1 = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(repl));
                                                                        Map<String,Object> rejectObjectMap1 = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(rej));
                                                                        Map<String,Object> cancelObjectMap1 = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(cnl));
                                                                        String workOrderNo;
                                                                        Map<String,String> ServiceAppointmentSlotsMap = new Map<String,String>();
                                                                        
																		//avoiding SOQL to fetch custom metadata dynamicalt
																		list<FFAServiceAppointmentSlots__mdt> FFAAppointmentSlotsList = new List<FFAServiceAppointmentSlots__mdt>();
																		
                                                                        FFAAppointmentSlotsList = [select MasterLabel,DeveloperName,Slot__c,SenderID__c from FFAServiceAppointmentSlots__mdt];
                                                                        if(!FFAAppointmentSlotsList.isEmpty()){
                                                                            for(FFAServiceAppointmentSlots__mdt appSlotsStr : FFAAppointmentSlotsList){
                                                                                ServiceAppointmentSlotsMap.put(appSlotsStr.Slot__c,appSlotsStr.SenderID__c);
                                                                            }
                                                                        }
                                                                        if(operationName=='Replan'){
                                                                            workOrderNo = replanObjectMap1.get('WorkOrderNo').toString();
                                                                        }else if(operationName=='Reject'){
                                                                            workOrderNo = rejectObjectMap1.get('WorkOrderNo').toString();
                                                                        }else if(operationName=='Cancel'){
                                                                            workOrderNo = cancelObjectMap1.get('WorkOrderNo').toString();
                                                                        }
                                                                        WorkOrder wo = ffaWorkOrderMap.get(workOrderNo);
                                                                        if(wo!=null){
                                                                            if(operationName=='Replan' && wo!=null){
                                                                                if(!string.isEmpty(workOrderNo)){
                                                                                    if(wo.FFA_Sender_ID__c == 'RAINBOW'){
                                                                                        if(wo.Status!=FFA_Constants.WORKORDER_STATUS_CANCEL){
                                                                                            if(wo.Status!=FFA_Constants.WORKORDER_STATUS_COMPLETED){
                                                                                                if(wo.Status!=FFA_Constants.DOMSTATUSReject){
                                                                                                    if(wo.Status!=FFA_Constants.WORKORDER_STATUS_INPROGRESS){
                                                                                                        DateTime stringDate;
                                                                                                        boolean IsAppointmentDateValid;
                                                                                                        if(replanObjectMap1.get('NewAppointmentDate')!=null){
                                                                                                            string appDateValue = replanObjectMap1.get('NewAppointmentDate').toString();//ReplanAppDateRequestBody.get(wo.WorkOrderNumber);
                                                                                                            System.debug('Check App Date =='+appDateValue);
                                                                                                            if(string.isNotBlank(appDateValue)){
                                                                                                                IsAppointmentDateValid=ValidateJsonDate(appDateValue);
                                                                                                                if(IsAppointmentDateValid==true){
                                                                                                                    stringDate=convertDateStringToDateTime(appDateValue);
                                                                                                                    System.debug('Check App Date =='+stringDate+'=='+appDateValue);
                                                                                                                }
                                                                                                            }
                                                                                                            if(stringDate!=null){
                                                                                                                system.debug('appointmentDateTime ' + stringDate);
                                                                                                                Date checkDateValid = Date.valueOf(stringDate);
                                                                                                                if(checkDateValid >= System.Date.today()){
                                                                                                                    if(!String.isBlank(wo.Job_Category__c)){
                                                                                                                        if(wo.Job_Category__c.contains('Customer') || (wo.Job_Category__c.contains('NGM') && wo.FFA_UnplannedPolicyStartDate__c!=null && wo.FFA_UnplannedPolicyEndDate__c!=null && checkDateValid >= wo.FFA_UnplannedPolicyStartDate__c.date() && wo.FFA_UnplannedPolicyEndDate__c.date() >= checkDateValid)){
                                                                                                                            wo.FFA_RequestedAppointmentDate__c = Datetime.newInstance(checkDateValid.year(), checkDateValid.Month(), checkDateValid.Day(), 00, 00, 00);
                                                                                                                            system.debug('Database date req app date'+ wo.FFA_RequestedAppointmentDate__c);
                                                                                                                            mapAppointmentDate.put(wo.Id,wo.FFA_RequestedAppointmentDate__c);
                                                                                                                            wo.Status = 'New';
                                                                                                                            wo.Sync_Status__c = 'Pending';
                                                                                                                            wo.FFA_Service_Provider_Replan__c ='Yes';
                                                                                                                            wo.FFA_Replan_Date_Time__c=system.now();
                                                                                                                            if(replanObjectMap1.get('ReplanReasonCode')!=null){
                                                                                                                                string replanReasonCode = replanObjectMap1.get('ReplanReasonCode').toString();
                                                                                                                                //ReplanCodeRequestBody.put(replanObjectMap.get('WorkOrderNo').toString(),replanObjectMap.get('ReplanReasonCode').toString());
                                                                                                                                if(ServiceAppJobCodeAndTextMap!=null){
                                                                                                                                    if(string.isNotBlank(replanReasonCode)){
                                                                                                                                        string TransactionTypeValueForReplan = ServiceAppJobCodeAndTransactionType.get(replanReasonCode);
                                                                                                                                        set<string> FinalJobCodeSet = new set<string>();
                                                                                                                                        FinalJobCodeSet = ServiceAppJobCodeAndTextMap.keySet();
                                                                                                                                        if(FinalJobCodeSet.contains(replanReasonCode) && TransactionTypeValueForReplan == 'Replan'){
                                                                                                                                            wo.FFA_JobReplanReasonCode__c = replanReasonCode;
                                                                                                                                            if(replanObjectMap1.get('ReplanReasonText')!=null){
                                                                                                                                                string replanReasonText = replanObjectMap1.get('ReplanReasonText').toString();
                                                                                                                                                //ReplanTextRequestBody.put(replanObjectMap1.get('WorkOrderNo').toString(),replanObjectMap.get('ReplanReasonText').toString());
                                                                                                                                                if(string.isNotBlank(replanReasonText)){
                                                                                                                                                    string textReason = replanReasonText;
                                                                                                                                                    string textReasonFinal;
                                                                                                                                                    if(textReason.length() > 99){
                                                                                                                                                        textReasonFinal = textReason.substring(0,99);
                                                                                                                                                    }else{
                                                                                                                                                        textReasonFinal = textReason;
                                                                                                                                                    }
                                                                                                                                                    wo.FFA_JobReplanReasonText__c = textReasonFinal;
                                                                                                                                                }else{
                                                                                                                                                    string finalJobCodeReason = ServiceAppJobCodeAndTextMap.get(wo.FFA_JobReplanReasonCode__c);
                                                                                                                                                    wo.FFA_JobReplanReasonText__c = finalJobCodeReason;
                                                                                                                                                }
                                                                                                                                            }else{
                                                                                                                                                string finalJobCodeReason = ServiceAppJobCodeAndTextMap.get(wo.FFA_JobReplanReasonCode__c);
                                                                                                                                                wo.FFA_JobReplanReasonText__c = finalJobCodeReason;
                                                                                                                                            }
                                                                                                                                            
                                                                                                                                            if(replanObjectMap1.get('NewAppointmentTimeSlot')!=null && (wo.Job_Category__c=='Customer Initiated Job' || wo.Job_Category__c=='NGM Initiated - Non Maintenance Job' ||
                                                                                                                                                                                                        wo.Job_Category__c=='NGM Initiated - Maintenance Job' || wo.Job_Category__c=='NGM initiated Job')){
                                                                                                                                                                                                            String newAppTimeSlot = replanObjectMap1.get('NewAppointmentTimeSlot').toString();
                                                                                                                                                                                                            if(string.isNotBlank(newAppTimeSlot)){
                                                                                                                                                                                                                if(ServiceAppointmentSlotsMap!=null){
                                                                                                                                                                                                                    set<string> FinalAppSlotSet = new set<string>();
                                                                                                                                                                                                                    FinalAppSlotSet = ServiceAppointmentSlotsMap.keySet();
                                                                                                                                                                                                                    if(FinalAppSlotSet.contains(newAppTimeSlot)){
                                                                                                                                                                                                                        wo.FFA_RequestedAppointmentTimeslot__c = newAppTimeSlot;
                                                                                                                                                                                                                        isAppTimeSlotAvailable=true;
                                                                                                                                                                                                                    }else{
                                                                                                                                                                                                                        FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                                                                                                                        fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                                                                                                                                        fr.Status = 'Failure';
                                                                                                                                                                                                                        fr.SupportingInfo = 'Provided new appointment slot value is invalid or incorrect.';
                                                                                                                                                                                                                        schFailureResponseListAll.add(fr);
                                                                                                                                                                                                                    }
                                                                                                                                                                                                                }else{
                                                                                                                                                                                                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                                                                                                                    fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                                                                                                                                    fr.Status = 'Failure';
                                                                                                                                                                                                                    fr.SupportingInfo = 'Appointment slots not available in database. Please check with admin.';
                                                                                                                                                                                                                    schFailureResponseListAll.add(fr);
                                                                                                                                                                                                                }
                                                                                                                                                                                                            }else{
                                                                                                                                                                                                                isAppTimeSlotAvailable=true;
                                                                                                                                                                                                            }
                                                                                                                                                                                                        }else{
                                                                                                                                                                                                            isAppTimeSlotAvailable=true;
                                                                                                                                                                                                        }
                                                                                                                                            
                                                                                                                                            if(isAppTimeSlotAvailable==true){
                                                                                                                                                wo.Transaction_Type__c = 'SR';
                                                                                                                                                WOsIDs.add(wo.Id);
                                                                                                                                                WorkOrderIDsList.add(wo.Id);
                                                                                                                                                updateWorkOrderList.add(wo);
                                                                                                                                                system.debug(updateWorkOrderList.size());
                                                                                                                                            }
                                                                                                                                        }else{
                                                                                                                                            FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                                            fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                                                            fr.Status = 'Failure';
                                                                                                                                            fr.SupportingInfo = 'ReplanReasonCode is Invalid or Empty.';
                                                                                                                                            schFailureResponseListAll.add(fr);
                                                                                                                                        }
                                                                                                                                    }else{
                                                                                                                                        FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                                        fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                                                        fr.Status = 'Failure';
                                                                                                                                        fr.SupportingInfo = 'ReplanReasonCode is Empty or Invalid.';
                                                                                                                                        schFailureResponseListAll.add(fr);
                                                                                                                                    }
                                                                                                                                }else{
                                                                                                                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                                    fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                                                    fr.Status = 'Failure';
                                                                                                                                    fr.SupportingInfo = 'ReplanReasonCode is Empty or Invalid.';
                                                                                                                                    schFailureResponseListAll.add(fr);
                                                                                                                                }
                                                                                                                            }else{
                                                                                                                                FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                                fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                                                fr.Status = 'Failure';
                                                                                                                                fr.SupportingInfo = 'Invalid JSON, make sure ReplanReasonCode is required.';
                                                                                                                                schFailureResponseListAll.add(fr);
                                                                                                                            }
                                                                                                                        }else{
                                                                                                                            FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                            fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                                            fr.Status = 'Failure';
                                                                                                                            fr.SupportingInfo = 'New Requested appointment Date can only be selected within the range of unplanned policy dates for NGM initiated jobs';
                                                                                                                            schFailureResponseListAll.add(fr);
                                                                                                                        }
                                                                                                                    }else{
                                                                                                                        FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                        fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                                        fr.Status = 'Failure';
                                                                                                                        fr.SupportingInfo = 'Job Category is Empty or Invalid.';
                                                                                                                        schFailureResponseListAll.add(fr);
                                                                                                                        //CreateHTTPResponse(req.requestBody.toString(),'Null',FFA_Constants.FAILURE_CODE,'Provided appointment date should be greater than today.',FFA_Constants.FAILURE_STATUS);
                                                                                                                        //return;
                                                                                                                    }
                                                                                                                }else{
                                                                                                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                    fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                                    fr.Status = 'Failure';
                                                                                                                    fr.SupportingInfo = 'Appointment Date is not within the AppointmentStartDate & AppointmentEndDate range of the Service Appointment.';
                                                                                                                    schFailureResponseListAll.add(fr);
                                                                                                                }
                                                                                                            }else{
                                                                                                                FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                                fr.Status = 'Failure';
                                                                                                                fr.SupportingInfo = 'Appointment date is Empty or Invalid.';
                                                                                                                schFailureResponseListAll.add(fr);
                                                                                                                //CreateHTTPResponse(req.requestBody.toString(),'Null',FFA_Constants.FAILURE_CODE,'Appointment date node is empty.',FFA_Constants.FAILURE_STATUS);
                                                                                                                // return;
                                                                                                            }
                                                                                                        }else{
                                                                                                            FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                            fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                            fr.Status = 'Failure';
                                                                                                            fr.SupportingInfo = 'Invalid JSON, make sure AppointmentDate is required.';
                                                                                                            schFailureResponseListAll.add(fr);
                                                                                                        }
                                                                                                    }else{
                                                                                                        FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                        fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                        fr.Status = 'Failure';
                                                                                                        fr.SupportingInfo = 'It is not allowed to Replan jobs for in progress, completed, cancelled or rejected status.';
                                                                                                        schFailureResponseListAll.add(fr);
                                                                                                        // CreateHTTPResponse(req.requestBody.toString(),'Null',FFA_Constants.FAILURE_CODE,FFA_Constants.UPDATE_ERROR_BY_STATUS,FFA_Constants.FAILURE_STATUS);
                                                                                                        //return;
                                                                                                    }
                                                                                                }else{
                                                                                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                    fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                    fr.Status = 'Failure';
                                                                                                    fr.SupportingInfo = 'It is not allowed to Replan jobs for in progress, completed, cancelled or rejected status.';
                                                                                                    schFailureResponseListAll.add(fr);
                                                                                                    //CreateHTTPResponse(req.requestBody.toString(),'Null',FFA_Constants.FAILURE_CODE,FFA_Constants.UPDATE_ERROR_BY_STATUS,FFA_Constants.FAILURE_STATUS);
                                                                                                    //return;
                                                                                                }
                                                                                            }else{
                                                                                                FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                fr.Status = 'Failure';
                                                                                                fr.SupportingInfo = 'It is not allowed to Replan jobs for in progress, completed, cancelled or rejected status.';
                                                                                                schFailureResponseListAll.add(fr);
                                                                                                //CreateHTTPResponse(req.requestBody.toString(),'Null',FFA_Constants.FAILURE_CODE,FFA_Constants.UPDATE_ERROR_BY_STATUS,FFA_Constants.FAILURE_STATUS);
                                                                                                // return;
                                                                                            }
                                                                                        }else{
                                                                                            FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                            fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                            fr.Status = 'Failure';
                                                                                            fr.SupportingInfo = 'It is not allowed to Replan jobs for in progress, completed, cancelled or rejected status.';
                                                                                            schFailureResponseListAll.add(fr);
                                                                                            //CreateHTTPResponse(req.requestBody.toString(),'Null',FFA_Constants.FAILURE_CODE,FFA_Constants.UPDATE_ERROR_BY_STATUS,FFA_Constants.FAILURE_STATUS);
                                                                                            //return;
                                                                                        }
                                                                                    }else{
                                                                                        FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                        fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                        fr.Status = 'Failure';
                                                                                        fr.SupportingInfo = 'It is not allowed to replan I&C jobs.';
                                                                                        schFailureResponseListAll.add(fr);
                                                                                    }
                                                                                }else{
                                                                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                    fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                    fr.Status = 'Failure';
                                                                                    fr.SupportingInfo = 'Work order not found in payload.';
                                                                                    schFailureResponseListAll.add(fr);
                                                                                }
                                                                            }
                                                                            if(operationName=='Reject' && wo!=null){
                                                                                if(wo.FFA_Sender_ID__c == 'RAINBOW'){
                                                                                    if(wo.Status!=FFA_Constants.WORKORDER_STATUS_CANCEL){
                                                                                        if(wo.Status!=FFA_Constants.WORKORDER_STATUS_COMPLETED){
                                                                                            if(wo.Status!=FFA_Constants.DOMSTATUSReject){
                                                                                                if(wo.Status!=FFA_Constants.WORKORDER_STATUS_INPROGRESS){
                                                                                                    if(wo.Status!=FFA_Constants.WORKORDER_STATUS_ASSIGN){
                                                                                                        wo.Status = 'Rejected';
                                                                                                        wo.Sync_Status__c = 'Pending';
                                                                                                        if(rejectObjectMap1.get('RejectReasonCode')!=null){
                                                                                                            string rejectReasonCode=rejectObjectMap1.get('RejectReasonCode').toString();
                                                                                                            system.debug('Reject Reason code=='+rejectReasonCode);
                                                                                                            if(ServiceAppJobCodeAndTextMap!=null){
                                                                                                                if(string.isNotBlank(rejectReasonCode)){
                                                                                                                    string TransactionTypeValueForReject = ServiceAppJobCodeAndTransactionType.get(rejectReasonCode);
                                                                                                                    set<string> FinalJobCodeSet = new set<string>();
                                                                                                                    FinalJobCodeSet = ServiceAppJobCodeAndTextMap.keySet();
                                                                                                                    system.debug('Reject Reason code=='+FinalJobCodeSet);
                                                                                                                    if(FinalJobCodeSet.contains(rejectReasonCode) && TransactionTypeValueForReject == 'Rejected'){
                                                                                                                        wo.FFA_RejectReasonCode__c = rejectReasonCode;
                                                                                                                        if(rejectObjectMap1.get('RejectReasonText')!=null){
                                                                                                                            string rejectReasonText=rejectObjectMap1.get('RejectReasonText').toString();
                                                                                                                            if(string.isNotBlank(rejectReasonText)){
                                                                                                                                string textReason = rejectReasonText;
                                                                                                                                string textReasonFinal;
                                                                                                                                if(textReason.length() > 99){
                                                                                                                                    textReasonFinal = textReason.substring(0,99);
                                                                                                                                }else{
                                                                                                                                    textReasonFinal = textReason;
                                                                                                                                }
                                                                                                                                wo.FFA_RejectReasonText__c = textReasonFinal;
                                                                                                                            }else{
                                                                                                                                string finalJobCodeReason = ServiceAppJobCodeAndTextMap.get(wo.FFA_RejectReasonCode__c);
                                                                                                                                wo.FFA_RejectReasonText__c=finalJobCodeReason;
                                                                                                                            }
                                                                                                                        }else{
                                                                                                                            string finalJobCodeReason = ServiceAppJobCodeAndTextMap.get(wo.FFA_RejectReasonCode__c);
                                                                                                                            wo.FFA_RejectReasonText__c=finalJobCodeReason;
                                                                                                                        }
                                                                                                                        
                                                                                                                        WOsIDs.add(wo.Id);
                                                                                                                        updateWorkOrderList.add(wo);
                                                                                                                    }else{
                                                                                                                        FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                        fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                                        fr.Status = 'Failure';
                                                                                                                        fr.SupportingInfo = 'RejectReasonCode is Invalid or Empty.';
                                                                                                                        schFailureResponseListAll.add(fr);
                                                                                                                    }
                                                                                                                }else{
                                                                                                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                    fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                                    fr.Status = 'Failure';
                                                                                                                    fr.SupportingInfo = 'RejectReasonCode is Empty or Invalid.';
                                                                                                                    schFailureResponseListAll.add(fr);
                                                                                                                }
                                                                                                            }else{
                                                                                                                FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                                fr.Status = 'Failure';
                                                                                                                fr.SupportingInfo = 'RejectReasonCode is Empty or Invalid.';
                                                                                                                schFailureResponseListAll.add(fr);
                                                                                                            }
                                                                                                        }else{
                                                                                                            FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                            fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                            fr.Status = 'Failure';
                                                                                                            fr.SupportingInfo = 'Invalid JSON, make sure RejectReasonCode is required.';
                                                                                                            schFailureResponseListAll.add(fr);
                                                                                                        }
                                                                                                    }else{
                                                                                                        FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                        fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                        fr.Status = 'Failure';
                                                                                                        fr.SupportingInfo = 'It is not allowed to Reject jobs for in progress, completed, cancelled, rejected or assigned status.';
                                                                                                        schFailureResponseListAll.add(fr);
                                                                                                    }
                                                                                                }else{
                                                                                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                    fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                    fr.Status = 'Failure';
                                                                                                    fr.SupportingInfo = 'It is not allowed to Reject jobs for in progress, completed, cancelled, rejected or assigned status.';
                                                                                                    schFailureResponseListAll.add(fr);
                                                                                                    //CreateHTTPResponse(req.requestBody.toString(),'Null',FFA_Constants.FAILURE_CODE,FFA_Constants.UPDATE_ERROR_BY_STATUS,FFA_Constants.FAILURE_STATUS);
                                                                                                    //return;
                                                                                                }
                                                                                            }else{
                                                                                                FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                fr.Status = 'Failure';
                                                                                                fr.SupportingInfo = 'It is not allowed to Reject jobs for in progress, completed, cancelled, rejected or assigned status.';
                                                                                                schFailureResponseListAll.add(fr);
                                                                                                //CreateHTTPResponse(req.requestBody.toString(),'Null',FFA_Constants.FAILURE_CODE,FFA_Constants.UPDATE_ERROR_BY_STATUS,FFA_Constants.FAILURE_STATUS);
                                                                                                //return;
                                                                                            }
                                                                                        }else{
                                                                                            FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                            fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                            fr.Status = 'Failure';
                                                                                            fr.SupportingInfo = 'It is not allowed to Reject jobs for in progress, completed, cancelled, rejected or assigned status.';
                                                                                            schFailureResponseListAll.add(fr);
                                                                                            //CreateHTTPResponse(req.requestBody.toString(),'Null',FFA_Constants.FAILURE_CODE,FFA_Constants.UPDATE_ERROR_BY_STATUS,FFA_Constants.FAILURE_STATUS);
                                                                                            //return;
                                                                                        }
                                                                                    }else{
                                                                                        FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                        fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                        fr.Status = 'Failure';
                                                                                        fr.SupportingInfo = 'It is not allowed to Reject jobs for in progress, completed, cancelled, rejected or assigned status.';
                                                                                        schFailureResponseListAll.add(fr);
                                                                                        //CreateHTTPResponse(req.requestBody.toString(),'Null',FFA_Constants.FAILURE_CODE,FFA_Constants.UPDATE_ERROR_BY_STATUS,FFA_Constants.FAILURE_STATUS);
                                                                                        //return;
                                                                                    }
                                                                                }else{
                                                                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                    fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                    fr.Status = 'Failure';
                                                                                    fr.SupportingInfo = 'Reject operation can be performed only for domestic jobs.';
                                                                                    schFailureResponseListAll.add(fr);
                                                                                }
                                                                            }
                                                                            if(operationName=='Cancel' && wo!=null){
                                                                                if(wo.FFA_Sender_ID__c!=null && wo.FFA_Sender_ID__c.containsOnly('RAINBOW')){
                                                                                    if(wo.Status!=FFA_Constants.WORKORDER_STATUS_CANCEL){
                                                                                        if(wo.Status!=FFA_Constants.WORKORDER_STATUS_COMPLETED){
                                                                                            if(wo.Status!=FFA_Constants.DOMSTATUSReject){
                                                                                                if(wo.Status!=FFA_Constants.WORKORDER_STATUS_INPROGRESS){
                                                                                                    wo.Status = FFA_Constants.WORKORDER_STATUS_CANCEL;
                                                                                                    wo.Sync_Status__c = 'Pending';
                                                                                                    WONumberForFailure = wo.WorkOrderNumber;
                                                                                                    if(cancelObjectMap1.get('CancelReasonCode')!=null){
                                                                                                        string cancelReasonCode = cancelObjectMap1.get('CancelReasonCode').toString();
                                                                                                        if(!ServiceAppJobCodeAndTextMap.isEmpty()){
                                                                                                            if(string.isNotBlank(cancelReasonCode)){
                                                                                                                string TransactionTypeValueForCancel = ServiceAppJobCodeAndTransactionType.get(cancelReasonCode);
                                                                                                                set<string> FinalJobCodeSet = new set<string>();
                                                                                                                FinalJobCodeSet = ServiceAppJobCodeAndTextMap.keySet();
                                                                                                                if(FinalJobCodeSet.contains(cancelReasonCode) && TransactionTypeValueForCancel == 'Cancelled'){
                                                                                                                    wo.FFA_TerminatedCancelledReasonCode__c = cancelReasonCode;
                                                                                                                    if(cancelObjectMap1.get('CancelReasonText')!=null){
                                                                                                                        string cancelReasonText=cancelObjectMap1.get('CancelReasonText').toString();
                                                                                                                        if(string.isNotBlank(cancelReasonText)){
                                                                                                                            string textReason = cancelReasonText;
                                                                                                                            string textReasonFinal;
                                                                                                                            if(textReason.length() > 39){
                                                                                                                                textReasonFinal = textReason.substring(0,39);
                                                                                                                            }else{
                                                                                                                                textReasonFinal = textReason;
                                                                                                                            }
                                                                                                                            wo.FFA_CompletedTerminatedCancelledText__c = textReasonFinal;
                                                                                                                        }else{
                                                                                                                            string finalJobCodeReason = ServiceAppJobCodeAndTextMap.get(wo.FFA_TerminatedCancelledReasonCode__c);
                                                                                                                            wo.FFA_CompletedTerminatedCancelledText__c = finalJobCodeReason;
                                                                                                                        }
                                                                                                                    }else{
                                                                                                                        string finalJobCodeReason = ServiceAppJobCodeAndTextMap.get(wo.FFA_TerminatedCancelledReasonCode__c);
                                                                                                                        wo.FFA_CompletedTerminatedCancelledText__c = finalJobCodeReason;
                                                                                                                    }
                                                                                                                    wo.Transaction_Type__c = 'ST';
                                                                                                                    WOsIDs.add(wo.Id);
                                                                                                                    updateWorkOrderList.add(wo);
                                                                                                                }else{
                                                                                                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                    fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                                    fr.Status = 'Failure';
                                                                                                                    fr.SupportingInfo = 'CancelReasonCode is Empty or Invalid.';
                                                                                                                    schFailureResponseListAll.add(fr);
                                                                                                                }
                                                                                                            }else{
                                                                                                                FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                                fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                                fr.Status = 'Failure';
                                                                                                                fr.SupportingInfo = 'CancelReasonCode is Empty or Invalid.';
                                                                                                                schFailureResponseListAll.add(fr);
                                                                                                            }
                                                                                                        }else{
                                                                                                            FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                            fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                            fr.Status = 'Failure';
                                                                                                            fr.SupportingInfo = 'CancelReasonCode is Empty or Invalid.';
                                                                                                            schFailureResponseListAll.add(fr);
                                                                                                        }
                                                                                                    }else{
                                                                                                        FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                        fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                        fr.Status = 'Failure';
                                                                                                        fr.SupportingInfo = 'Invalid JSON, make sure CancelReasonCode is required.';
                                                                                                        schFailureResponseListAll.add(fr);
                                                                                                    }
                                                                                                }else{
                                                                                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                    fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                    fr.Status = 'Failure';
                                                                                                    fr.SupportingInfo = 'It is not allowed to Cancel jobs for in progress, completed, cancelled or rejected status.';
                                                                                                    schFailureResponseListAll.add(fr);
                                                                                                    //CreateHTTPResponse(req.requestBody.toString(),'Null',FFA_Constants.FAILURE_CODE,FFA_Constants.UPDATE_ERROR_BY_STATUS,FFA_Constants.FAILURE_STATUS);
                                                                                                    //return;
                                                                                                }
                                                                                            }else{
                                                                                                FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                                fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                                fr.Status = 'Failure';
                                                                                                fr.SupportingInfo = 'It is not allowed to Cancel jobs for in progress, completed, cancelled or rejected status.';
                                                                                                schFailureResponseListAll.add(fr);
                                                                                                // CreateHTTPResponse(req.requestBody.toString(),'Null',FFA_Constants.FAILURE_CODE,FFA_Constants.UPDATE_ERROR_BY_STATUS,FFA_Constants.FAILURE_STATUS);
                                                                                                // return;
                                                                                            }
                                                                                        }else{
                                                                                            FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                            fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                            fr.Status = 'Failure';
                                                                                            fr.SupportingInfo = 'It is not allowed to Cancel jobs for in progress, completed, cancelled or rejected status.';
                                                                                            schFailureResponseListAll.add(fr);
                                                                                            // CreateHTTPResponse(req.requestBody.toString(),'Null',FFA_Constants.FAILURE_CODE,FFA_Constants.UPDATE_ERROR_BY_STATUS,FFA_Constants.FAILURE_STATUS);
                                                                                            //return;
                                                                                        }
                                                                                    }else{
                                                                                        FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                        fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                        fr.Status = 'Failure';
                                                                                        fr.SupportingInfo = 'It is not allowed to Cancel jobs for in progress, completed, cancelled or rejected status.';
                                                                                        schFailureResponseListAll.add(fr);
                                                                                        //CreateHTTPResponse(req.requestBody.toString(),'Null',FFA_Constants.FAILURE_CODE,FFA_Constants.UPDATE_ERROR_BY_STATUS,FFA_Constants.FAILURE_STATUS);
                                                                                        //return;
                                                                                    }
                                                                                }else{
                                                                                    FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                    fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                    fr.Status = 'Failure';
                                                                                    fr.SupportingInfo = 'Cancel operation can be performed only for domestic jobs.';
                                                                                    schFailureResponseListAll.add(fr);
                                                                                }
                                                                            }
																			system.debug('*********Existing WO SERVICEAPP******'+existingWoSAppts+'******EXISTING SA IS*******'+existingWoSAppts);
																			//added to avoid soql in for loops
																			if(!existingWoSAppts.isEmpty()){
																				for(ServiceAppointment activeServiceAppointmentReplan : existingWoSAppts){
																					if(WOsIDs.contains(activeServiceAppointmentReplan.ParentRecordId)){
																						
																						if(activeServiceAppointmentReplan.Status != FFA_Constants.WORKORDER_STATUS_CANCEL){
																							
																							if(activeServiceAppointmentReplan.Status != FFA_Constants.WORKORDER_STATUS_COMPLETED){
																								
																								activeServiceAppointmentReplan.Status = FFA_Constants.WORKORDER_STATUS_CANCEL;
																								if(operationName=='Replan'){if(isAppTimeSlotAvailable==true){ServiceApptIds.add(activeServiceAppointmentReplan.Id);}
																														   }
																								updateServiceAppointment.add(activeServiceAppointmentReplan);
																								system.debug(updateServiceAppointment.size());
																							}
																						}
																						
																						/*if(activeServiceAppointmentReplan.Status!=FFA_Constants.WORKORDER_STATUS_CANCEL){
																							if(activeServiceAppointmentReplan.Status!=FFA_Constants.WORKORDER_STATUS_COMPLETED){
																								activeServiceAppointmentReplan.Status = FFA_Constants.WORKORDER_STATUS_CANCEL;
																								if(operationName=='Replan'){if(isAppTimeSlotAvailable==true){ServiceApptIds.add(activeServiceAppointmentReplan.Id);}
																														   }
																								updateServiceAppointment.add(activeServiceAppointmentReplan);
																								system.debug(updateServiceAppointment.size());
																							}
																						}*/
																					}
																					
																				}
																			}
																			
                                                                            /*list<ServiceAppointment> newSAListRecords = [select Id, AppointmentNumber,Status,EarliestStartTime,SchedStartTime,SchedEndTime,DueDate,ParentRecordId from ServiceAppointment WHERE ParentRecordId=:WOsIDs];
                                                                            system.debug(''+newSAListRecords);
                                                                            for(ServiceAppointment activeServiceAppointmentReplan : newSAListRecords){
                                                                                if(activeServiceAppointmentReplan.Status!=FFA_Constants.WORKORDER_STATUS_CANCEL){
                                                                                    if(activeServiceAppointmentReplan.Status!=FFA_Constants.WORKORDER_STATUS_COMPLETED){
                                                                                        activeServiceAppointmentReplan.Status = FFA_Constants.WORKORDER_STATUS_CANCEL;
                                                                                        if(operationName=='Replan'){if(isAppTimeSlotAvailable==true){ServiceApptIds.add(activeServiceAppointmentReplan.Id);}
                                                                                                                   }
                                                                                        updateServiceAppointment.add(activeServiceAppointmentReplan);
                                                                                        system.debug(updateServiceAppointment.size());
                                                                                    }
                                                                                }
                                                                            }*/
                                                                            if(updateServiceAppointment.size()==0 && schFailureResponseListAll.isEmpty()){
                                                                                FailedSchedulingResults fr = new FailedSchedulingResults();
                                                                                fr.WorkOrderNo = wo.WorkOrderNumber;
                                                                                fr.Status = 'Failure';
                                                                                fr.SupportingInfo = 'No active SA found in provided work order.';
                                                                                schFailureResponseListAll.add(fr);
                                                                            }
                                                                        }
                                                                        system.debug(updateServiceAppointment.size());
                                                                        return schFailureResponseListAll;
                                                                    }
    
    static List<SchedulingResponse> UpdateSAWORecords(List<ServiceAppointment> saToUpdate,List<WorkOrder> woToUpdate,Set<Id> ServiceApptIds,list<FailedSchedulingResults> schFailureResponseList){
        //Update Service Appointment Records
        List<SchedulingResponse> schedResList = new List<SchedulingResponse>();
        Database.SaveResult[] srARList;
        Database.DeleteResult[] srARListDelete;
		
		Set<Id> WoSuccessIds = new Set<Id>();
		Map<Id,ServiceAppointment> sasRelatedToWos = new Map<Id,ServiceAppointment>();
		list<ServiceAppointment> finalSARecordList = new list<ServiceAppointment>();
        
        system.debug('saToUpdate is ' + saToUpdate.size());
        system.debug('Work Order is ' + woToUpdate.size());
        
        Database.SaveResult[] srWOList = Database.update(woToUpdate,false);
        system.debug('saveresult WO is ' +srWOList);
		
		for(Integer i = 0; i < woToUpdate.size(); i++){
			Database.SaveResult srWO = srWOList[i];
			if (srWO.isSuccess()){
				WoSuccessIds.add(srWO.getId());
			}
		}
		
		for(ServiceAppointment saRecords:saToUpdate){
			if(WoSuccessIds.contains(saRecords.ParentRecordId)){
				finalSARecordList.add(saRecords);
			}
		}
		
		if(!finalSARecordList.isEmpty()){
			Database.SaveResult[] srSchedList = Database.update(finalSARecordList,false);
		}
		
		for(Integer i = 0; i < woToUpdate.size(); i++){
			Database.SaveResult srWO = srWOList[i];
			if (srWO.isSuccess()){
				WoSuccessIds.add(srWO.getId());
					WorkOrder origWORecord = woToUpdate[i];
					SchedulingResponse schedResponse = new SchedulingResponse();
					schedResponse.WorkOrderNo= woToUpdate[i].WorkOrderNumber;
					schedResponse.WorkOrderStatus= woToUpdate[i].Status;
					
					// Operation was successful, so get the ID of the record that was processed
					System.debug('Successfully updated record. Record ID: ' + srWO.getId());
					schedResponse.ProcessingStatus='Success';
					schedResponse.SupportingInfo='Work Order Updated Successfully.';
					schedResList.add(schedResponse); 
					system.debug('scheduleProcessingStatusList ' + schedResList); 
				
			}
			else{
				for(Database.Error err : srWO.getErrors()){                  
                    System.debug('fields that affected this error*** ' + err.getFields()+'error Message is*****'+err.getMessage()+'error status code****'+err.getStatusCode());
                    FailedSchedulingResults fr = new FailedSchedulingResults();
                    fr.WorkOrderNo = woToUpdate[i].WorkOrderNumber;
                    fr.Status = 'Failure';
                    IF(err.getMessage()!=null && err.getMessage().contains(FFA_Constants.REPLAN_SLOTS_EXPIRED)){
                        fr.SupportingInfo =FFA_Constants.REPLAN_SLOTS_EXPIRED;
                    }else{
                        fr.SupportingInfo = err.getMessage() + ' Fields that affected this error: ' + err.getFields();
                    }
                    
                    schFailureResponseList.add(fr);
                    //schedResponse.ProcessingStatus = 'Workorder Update Failed';
                    //schedResponse.SupportingInfo = 'The following error has occurred: ' + err.getMessage() + 'Fields that affected this error: ' + err.getFields();
                    //schedResList.add(schedResponse);
                }
			}
		}
		
		if(ServiceApptIds!=null){if(!ServiceApptIds.isEmpty()){
            system.debug(ServiceApptIds.size());
            FFAServiceAppointmentSlotsHandler.changeServiceApptTime(ServiceApptIds);
        }}
        System.debug(schedResList);
        return  schedResList;
		
		
        
        /*for (Integer i = 0; i < woToUpdate.size(); i++) {
            Database.SaveResult srWO = srWOList[i];
            
            WorkOrder origWORecord = woToUpdate[i];
            SchedulingResponse schedResponse = new SchedulingResponse();
            schedResponse.WorkOrderNo= woToUpdate[i].WorkOrderNumber;
            schedResponse.WorkOrderStatus= woToUpdate[i].Status;
            
            if(srWO.isSuccess()){
                // After WO success, proceed to update the SA
                list<ServiceAppointment> finalSARecordList = new list<ServiceAppointment>();
                System.debug('Check here == '+srWO.getId());
                Id WorkOrderId = srWO.getId();
                System.debug('Check Here == '+WorkOrderId);
                if(saToUpdate!=null){
                    for(ServiceAppointment saRecords : saToUpdate){
                        if(saRecords.ParentRecordId == WorkOrderId){
                            finalSARecordList.add(saRecords);
                        }
                    }
                    if(finalSARecordList!=null){
                        system.debug('saToUpdate is ' + finalSARecordList.size());
                        Database.SaveResult[] srSchedList = Database.update(finalSARecordList,false);
                        for(Integer j = 0; j < finalSARecordList.size(); j++){
                            Database.SaveResult srSA = srSchedList[j];
                            ServiceAppointment origSARecord = saToUpdate[j];
                        }
                    }
                }
                
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated record. Record ID: ' + srWO.getId());
                schedResponse.ProcessingStatus='Success';
                schedResponse.SupportingInfo='Work Order Updated Successfully.';
                schedResList.add(schedResponse); 
                system.debug('scheduleProcessingStatusList ' + schedResList); 
            }else{
                for(Database.Error err : srWO.getErrors()){
                    system.debug(err);
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('fields that affected this error: ' + err.getFields());
                    FailedSchedulingResults fr = new FailedSchedulingResults();
                    fr.WorkOrderNo = woToUpdate[i].WorkOrderNumber;
                    fr.Status = 'Failure';
                    IF(err.getMessage()!=null && err.getMessage().contains(FFA_Constants.REPLAN_SLOTS_EXPIRED)){
                        fr.SupportingInfo =FFA_Constants.REPLAN_SLOTS_EXPIRED;
                    }else{
                        fr.SupportingInfo = err.getMessage() + ' Fields that affected this error: ' + err.getFields();
                    }
                    
                    schFailureResponseList.add(fr);
                    //schedResponse.ProcessingStatus = 'Workorder Update Failed';
                    //schedResponse.SupportingInfo = 'The following error has occurred: ' + err.getMessage() + 'Fields that affected this error: ' + err.getFields();
                    //schedResList.add(schedResponse);
                }
            }
        } 
        
        if(ServiceApptIds!=null){if(!ServiceApptIds.isEmpty()){
            system.debug(ServiceApptIds.size());
            FFAServiceAppointmentSlotsHandler.changeServiceApptTime(ServiceApptIds);
        }}
        System.debug(schedResList);
        return  schedResList;*/
    }
    
    // Creating Service Appointment here in case of available service appointment got cancelled in case of Replan
    /*static void createServiceAppointment(DateTime ReqAppointDate,ID WorkOrderId){
        list<ServiceAppointment> serviceApList = new list<ServiceAppointment>();
        workorder relatedWoSp=[Select id,FFA_ServiceProvider__c from workorder WHERE id=:WorkOrderId limit 1];
        if(WorkOrderId!=null){
            ServiceAppointment serviceAp = new ServiceAppointment();
            serviceAp.ParentRecordId = WorkOrderId;
            serviceAp.FFA_Work_Order__c=WorkOrderId;
            if(ReqAppointDate!=null){
                serviceAp.EarliestStartTime = Datetime.newInstance(ReqAppointDate.year(), ReqAppointDate.Month(), ReqAppointDate.Day(), 00, 00, 00);//ReqAppointDate.addHours(-1).addMinutes(0).addSeconds(0);
                serviceAp.DueDate = Datetime.newInstance(ReqAppointDate.year(), ReqAppointDate.Month(), ReqAppointDate.Day(), 23, 59, 00);//ReqAppointDate.addHours(22).addMinutes(59).addSeconds(0);
                serviceAp.SchedStartTime = Datetime.newInstance(ReqAppointDate.year(), ReqAppointDate.Month(), ReqAppointDate.Day(), 00, 00, 00);
                serviceAp.SchedEndTime = Datetime.newInstance(ReqAppointDate.year(), ReqAppointDate.Month(), ReqAppointDate.Day(), 23, 59, 00);
            }
            if(relatedWoSp.FFA_ServiceProvider__c!=null){
                serviceAp.FFA_SP_ID__c=relatedWoSp.FFA_ServiceProvider__c;
            }
            serviceAp.Status = 'None';
            serviceApList.add(serviceAp);
        }
        system.debug('New Service Appointment Created value ==='+serviceApList);
        Database.SaveResult[] srList = Database.insert(serviceApList,false);
        for(Database.SaveResult sr : srList){
            if (sr.isSuccess()){
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted record. Record ID: ' + sr.getId());
            }else{
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()){
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('fields that affected this error: ' + err.getFields());
                }
            }
        }
    }*/
	
	// Creating Service Appointment here in case of available service appointment got cancelled in case of Replan
	static ServiceAppointment createServiceAppointment(DateTime ReqAppointDate,WorkOrder WorkOrderId){
        workorder relatedWoSp=WorkOrderId;
         ServiceAppointment serviceAp = new ServiceAppointment();
        if(WorkOrderId!=null){
            serviceAp.ParentRecordId = WorkOrderId.Id;
            serviceAp.FFA_Work_Order__c=WorkOrderId.Id;
            if(ReqAppointDate!=null){
                serviceAp.EarliestStartTime = Datetime.newInstance(ReqAppointDate.year(), ReqAppointDate.Month(), ReqAppointDate.Day(), 00, 00, 00);//ReqAppointDate.addHours(-1).addMinutes(0).addSeconds(0);
                serviceAp.DueDate = Datetime.newInstance(ReqAppointDate.year(), ReqAppointDate.Month(), ReqAppointDate.Day(), 23, 59, 00);//ReqAppointDate.addHours(22).addMinutes(59).addSeconds(0);
                serviceAp.SchedStartTime = Datetime.newInstance(ReqAppointDate.year(), ReqAppointDate.Month(), ReqAppointDate.Day(), 00, 00, 00);
                serviceAp.SchedEndTime = Datetime.newInstance(ReqAppointDate.year(), ReqAppointDate.Month(), ReqAppointDate.Day(), 23, 59, 00);
            }
            if(relatedWoSp.FFA_ServiceProvider__c!=null){
                serviceAp.FFA_SP_ID__c=relatedWoSp.FFA_ServiceProvider__c;
            }
            serviceAp.Status = 'None';
        }
		return serviceAp;
        
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
        FFA_Interface_Runs__c InterfaceLogs = new FFA_Interface_Runs__c(Interface_Name__c='/FFARejectHandlerWork',Transaction_Message__c=JSON.serialize(resWrappers), Transaction_Status__c = TransactionStatus);
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
        conVer.PathOnClient = 'WorkorderRejectHandler.txt'; // The files name, extension is very important here which will help the file in preview.
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
    
    static datetime convertDateStringToDateTime(string appointmentDateString){
        String stringDate;
        DateTime appointmentDateTime;
        Date checkApointmentDateValid;
        
        
        if(string.isNotBlank(appointmentDateString)){
            stringDate = appointmentDateString.substring(0,10) +' 00:00:00.0000z';  //'-' + 
        }
        
        if(string.isnotBlank(stringDate)){
            date checkdatevalue = date.valueOf(stringDate);
            Time myTime = Time.newInstance(0, 0, 0, 0);
            appointmentDateTime = DateTime.newInstanceGMT(checkdatevalue, myTime);
            system.debug('Check converted date here=='+checkdatevalue+'=='+appointmentDateTime+'=='+stringDate+'=='+appointmentDateString);
            Date dateValue = Date.valueOf(appointmentDateTime);
            checkApointmentDateValid = dateValue.addDays(1); //
        }
        return appointmentDateTime;
    }
    
    Public static Boolean ValidateJsonDate(String JSONDate){
       Boolean Valid;
       Try{
           Date dt=date.valueof(JSONDate);
           Valid=true;
       }
       Catch(exception e){
           Valid=False;
       }
       return Valid;
    }
    
    public class Cancel{
        public string WorkOrderNo;
        public string CancelReasonCode;
        public string CancelReasonText;
    }
    
    public class Replan{
        public string WorkOrderNo;
        public string NewAppointmentDate;
        public string NewAppointmentTimeSlot;
        public string ReplanReasonCode;
        public string ReplanReasonText;
    }
    
    public class Reject{
        public string WorkOrderNo;
        public string RejectReasonCode;
        public string RejectReasonText;
    }
    
    public class SchedulingResponse
    {
        public String ProcessingStatus;
        public String SupportingInfo;
        
        public String WorkOrderNo;
        public String WorkOrderStatus;
        
        //public String ServiceAppointmentNo;
        //public String ServiceAppointmentStatus;
        public SchedulingResponse(){}
        
    }
    
    public class FailedSchedulingResults{
        public string WorkOrderNo;
        public string Status;
        public string SupportingInfo;
        public FailedSchedulingResults(){}
    }
    
    public class ProcessingStatus
    {
        public List<SchedulingResponse> SchedulingResults;
        public List<FailedSchedulingResults> FailSchedulingResults;
        public ProcessingStatus(){}
    }
    
    public class SystemTransactionWrapper {
        
        public string RequestPayLoad {get; set;}
        public string ResponsePayLoad {get;set;}
        public string StatusCode {get; set;}
        public string TransactionMessage {get; set;}
        public string TransactionStatus {get; set;}
    }
    
    
}