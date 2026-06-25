/////////////////////////////////////////////////
/*          SAP-FFA UPDATE INTERFACE           */
/*          Author: Ankit Tomar                */ 
/*          Company: Wipro Technologies        */
/*          Created Date: 01/07/2019           */
/////////////////////////////////////////////////
/*
** Description: This class is used in FFA**
*/
@RestResource(urlMapping='/FFAUpdateInterface/*') //NGupdateJOB
global with sharing class WorkorderUpdateHandler {
    @Httppost
    global static void UpdateWorkOrder(){
        RestRequest req = RestContext.request;
        //RestResponse res = RestContext.response;
        string reqPayload =  req.requestBody.tostring();
        string OperationNumberId;
        string ServiceNotificationNumberId;
        string WorkOrderName;
        ID WorkOrderID;
        DateTime ReqApointmentDate;
        
        
        // List of Objects 
        list<ServiceAppointment> serviceAppointmentList = new list<ServiceAppointment>();
        list<FFA_NGV_Asset__c> meterlist = new list<FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c> convertorlist = new list<FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c> flowComputerlist = new list<FFA_NGV_Asset__c>();
        list<FFA_Site__c> SiteList = new list<FFA_Site__c>();
        system.debug('reqPayload======='+reqPayload);
        string resPayload = reqPayload;
        //parsing response json to main class
        WorkorderUpdateHandler jsonConsumeWrap =  WorkorderUpdateHandler.parse(reqPayload);
        system.debug('WorkorderUpdateHandler jsonConsumeWrap ====='+jsonConsumeWrap);
        try{
            //When Header Trasaction Type is ST(Cancel) From JSON
            //It Will Cancel Appointment and Workorder status will be updated as Cancel
            if(jsonConsumeWrap!=null && jsonConsumeWrap.Header.TransactionType == FFA_Constants.FFA_TRANSACTIONTYPE_CANCEL){
                WorkorderUpdateHandler.header headers = new WorkorderUpdateHandler.header();
                headers.TransactionType = jsonConsumeWrap.Header.TransactionType!='' ? jsonConsumeWrap.Header.TransactionType:'';
                headers.CreationDate = jsonConsumeWrap.Header.CreationDate!='' ? jsonConsumeWrap.Header.CreationDate:''; 
                headers.CreationTime = jsonConsumeWrap.Header.CreationTime!='' ? jsonConsumeWrap.Header.CreationTime:'';
                headers.FileType = jsonConsumeWrap.Header.FileType!='' ? jsonConsumeWrap.Header.FileType:'';
                headers.GenerationNumber = jsonConsumeWrap.Header.GenerationNumber!='' ? jsonConsumeWrap.Header.GenerationNumber:'';
                headers.ReceiverID = jsonConsumeWrap.Header.ReceiverID!='' ? jsonConsumeWrap.Header.ReceiverID:'';
                headers.SenderID = jsonConsumeWrap.Header.SenderID!='' ? jsonConsumeWrap.Header.SenderID:'';
                headers.InterfaceName = jsonConsumeWrap.Header.InterfaceName!='' ? jsonConsumeWrap.Header.InterfaceName:'';
                
                system.debug('jsonConsumeWrap.Job====='+jsonConsumeWrap.Job);
                //Updating Work Order here
                if((jsonConsumeWrap.Job!=null && string.isNotBlank(jsonConsumeWrap.Job.ServiceNotificationNumber) && string.isNotBlank(jsonConsumeWrap.Job.OperationNumber)) ||
                    (jsonConsumeWrap.Job!=null && string.isNotBlank(jsonConsumeWrap.Job.ServiceNotificationNumber) && headers.SenderID=='RAINBOW')
                ){
                    ServiceNotificationNumberId=jsonConsumeWrap.Job.ServiceNotificationNumber;
                    if(headers.SenderID=='RAINBOW'){
                    OperationNumberId = '';
                    }
                    else{
                    OperationNumberId=jsonConsumeWrap.Job.OperationNumber;
                    }
                    string finalServiceNotificationNumberId = ServiceNotificationNumberId.trim();
                    string finalOperationNumberId= OperationNumberId.trim();
                    list<Workorder> workOrders=new list<Workorder>();
                    if(headers.SenderID=='RAINBOW'){
                    string WOREJECTSTATUS=FFA_Constants.DOMSTATUSReject;
                        workOrders = [select Id,WorkOrderNumber,Transaction_Type__c,FFA_RequestedAppointmentDate__c,Sync_Status__c, Status,FFA_ServiceNotificationNumber__c,FFA_OperationNumber__c from WorkOrder where FFA_ServiceNotificationNumber__c =:finalServiceNotificationNumberId AND status!=:WOREJECTSTATUS limit 1];
                    System.debug(workOrders);
                    }
                    else{
                        workOrders = [select Id,WorkOrderNumber,Transaction_Type__c,FFA_RequestedAppointmentDate__c,Sync_Status__c, Status,FFA_ServiceNotificationNumber__c,FFA_OperationNumber__c from WorkOrder where FFA_ServiceNotificationNumber__c =:finalServiceNotificationNumberId AND FFA_OperationNumber__c =:finalOperationNumberId limit 1];
                    }
                    if(!workOrders.isEmpty()){
                        System.debug(workOrders[0].Status);
                        if(workOrders[0].Status != FFA_Constants.WORKORDER_STATUS_CANCEL){
                            if(workOrders[0].Status != FFA_Constants.WORKORDER_STATUS_COMPLETED){
                                if(workOrders[0].Status != FFA_Constants.WORKORDER_STATUS_INPROGRESS){
                                    workOrders[0].Status = FFA_Constants.WORKORDER_STATUS_CANCEL;
                                    workOrders[0].Sync_Status__c = FFA_Constants.WORKORDER_SYNC_STATUS_PENDING;
                                    System.debug(workOrders);
                                    workOrders[0].Transaction_Type__c = headers.TransactionType;
                                    WorkOrderID = workOrders[0].Id;
                                    WorkOrderName = workOrders[0].WorkOrderNumber;
                                    system.debug('ST====='+workOrders);
                                    
                                    boolean isStatusChecked;
                                    string checkStatusValue;
                                    // process of updating Service Appointment Status 
                                    if(WorkOrderID!=null){
                                        list<ServiceAppointment> ServiceAppointmentQueryRecords = new list<ServiceAppointment>();
                                        ServiceAppointmentQueryRecords = [select Id, ParentRecordType,ParentRecordId, Status from ServiceAppointment where ParentRecordId =:WorkOrderID];
                                        if(!ServiceAppointmentQueryRecords.isEmpty()){
                                            for(ServiceAppointment ServiceAppointments : ServiceAppointmentQueryRecords){
                                                system.debug('Test Value === '+ServiceAppointments);
                                                if(ServiceAppointments.Status != FFA_Constants.WORKORDER_STATUS_CANCEL){
                                                    if(ServiceAppointments.Status != FFA_Constants.WORKORDER_STATUS_COMPLETED){
                                                        checkStatusValue = ServiceAppointments.Status;
                                                        ServiceAppointments.Status = FFA_Constants.WORKORDER_STATUS_CANCEL;
                                                        serviceAppointmentList.add(ServiceAppointments);
                                                        isStatusChecked = true;
                                                    }else{
                                                        isStatusChecked = false;
                                                    }
                                                }else{
                                                    isStatusChecked = false;
                                                }
                                            }
                                            if(isStatusChecked == false && string.isBlank(checkStatusValue)){
                                                CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_WO_SA_NOTVALID_STATUS,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.FAILURE_CODE,resPayload);
                                                return;
                                            }
                                        }else{
                                            CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_WO_SA_NOT_FOUND,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.FAILURE_CODE,resPayload);
                                            return;
                                        }
                                        
                                        // performing Update dml for the service appointment here and sending the success response 
                                        if(!serviceAppointmentList.isEmpty()){
                                            update workOrders;
                                            if(!test.isrunningtest()){update serviceAppointmentList;}
                                            system.debug('ST(Service Apointment)====='+serviceAppointmentList);
                                            //Success Response when Work Order Cancelled Successfully
                                            CreateResponse(FFA_Constants.SUCCESS_STATUS,FFA_Constants.UPDATE_WORKORDER_MESSAGE,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.SUCESS_CODE,resPayload);
                                            return;
                                        }
                                    }
                                }else{
                                    CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_ERROR_BY_STATUS,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.FAILURE_CODE,resPayload);
                                    return;
                                }
                            }else{
                                CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_ERROR_BY_STATUS,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.FAILURE_CODE,resPayload);
                                return;
                            }
                        }else{
                            // Failure Response Structure when status already Cancelled or Completed
                            CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_ERROR_BY_STATUS,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.FAILURE_CODE,resPayload);
                            return;
                        }
                        
                    }else{
                        CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_WO_NOT_FOUND,ServiceNotificationNumberId,OperationNumberId,'',FFA_Constants.FAILURE_CODE,resPayload);
                        return;
                    }
                }
            }
            
            //When Trasaction is SR(Replan) From JSON
            if(jsonConsumeWrap!=null && jsonConsumeWrap.Header.TransactionType == FFA_Constants.FFA_TRANSACTIONTYPE_REPLAN){
                WorkorderUpdateHandler.header headers = new WorkorderUpdateHandler.header();
                headers.TransactionType = jsonConsumeWrap.Header.TransactionType!='' ? jsonConsumeWrap.Header.TransactionType:'';
                headers.CreationDate = jsonConsumeWrap.Header.CreationDate!='' ? jsonConsumeWrap.Header.CreationDate:''; 
                headers.CreationTime = jsonConsumeWrap.Header.CreationTime!='' ? jsonConsumeWrap.Header.CreationTime:'';
                headers.FileType = jsonConsumeWrap.Header.FileType!='' ? jsonConsumeWrap.Header.FileType:'';
                headers.GenerationNumber = jsonConsumeWrap.Header.GenerationNumber!='' ? jsonConsumeWrap.Header.GenerationNumber:'';
                headers.ReceiverID = jsonConsumeWrap.Header.ReceiverID!='' ? jsonConsumeWrap.Header.ReceiverID:'';
                headers.SenderID = jsonConsumeWrap.Header.SenderID!='' ? jsonConsumeWrap.Header.SenderID:'';
                headers.InterfaceName = jsonConsumeWrap.Header.InterfaceName!='' ? jsonConsumeWrap.Header.InterfaceName:'';
                
                //Process for updating Work order here
                if((jsonConsumeWrap.Job!=null && string.isNotBlank(jsonConsumeWrap.Job.ServiceNotificationNumber) && string.isNotBlank(jsonConsumeWrap.Job.OperationNumber)) ||
                    (jsonConsumeWrap.Job!=null && string.isNotBlank(jsonConsumeWrap.Job.ServiceNotificationNumber) && headers.SenderID=='RAINBOW')
                ){
                    ServiceNotificationNumberId=jsonConsumeWrap.Job.ServiceNotificationNumber;
                    IF(headers.SenderID=='RAINBOW'){
                        OperationNumberId = '';
                    }
                    else{
                        OperationNumberId = jsonConsumeWrap.Job.OperationNumber;
                    }
                    string newReqAppointmentDate = jsonConsumeWrap.Job.RequestedAppointmentDate;
                    //Added New RequestedAppointmentEndDate as Part of Enhancements
                    string newReqAppointmentDateEndDate= jsonConsumeWrap.Job.RequestedAppointmentEndDate;
                    string finalServiceNotificationNumberId = ServiceNotificationNumberId.trim();
                    system.debug('finalServiceNotificationNumberId ==='+finalServiceNotificationNumberId);
                    string finalOperationNumberId= OperationNumberId.trim();
                    list<Workorder> workOrders=new list<Workorder> ();
                    string WOREJECTSTATUS=FFA_Constants.DOMSTATUSReject;
                    IF(headers.SenderID=='RAINBOW'){
                        workOrders = [select Id,WorkOrderNumber,FFA_Sender_ID__c,Transaction_Type__c,FFA_JobReplanReasonCode__c,Job_Category__c,FFA_Replan_Date_Time__c,FFA_Service_Provider_Replan__c,SAP_Replan__c,FFA_EmergencyFlag__c,FFA_RequestedAppointmentDate__c,FFA_RequestedAppointmentEndDate__c,FFA_UnplannedPolicyEndDate__c,FFA_UnplannedPolicyStartDate__c,FFA_RequestCreatedDate__c,Sync_Status__c, Status,FFA_ServiceNotificationNumber__c,FFA_OperationNumber__c from WorkOrder where FFA_ServiceNotificationNumber__c =:finalServiceNotificationNumberId AND Status!=:WOREJECTSTATUS limit 1];
                    }else{
                        workOrders = [select Id,WorkOrderNumber,FFA_Sender_ID__c,Transaction_Type__c,FFA_EmergencyFlag__c,Job_Category__c,FFA_Replan_Date_Time__c,FFA_RequestedAppointmentDate__c,FFA_UnplannedPolicyEndDate__c,FFA_UnplannedPolicyStartDate__c,FFA_RequestCreatedDate__c,FFA_RequestedAppointmentEndDate__c,Sync_Status__c, Status,FFA_ServiceNotificationNumber__c,FFA_OperationNumber__c from WorkOrder where FFA_ServiceNotificationNumber__c =:finalServiceNotificationNumberId AND FFA_OperationNumber__c =:finalOperationNumberId limit 1]; 
                    }
                    if(!WorkOrders.isEmpty()){
                        if(WorkOrders[0].Status != FFA_Constants.WORKORDER_STATUS_CANCEL){
                            if(workOrders[0].Status != FFA_Constants.WORKORDER_STATUS_COMPLETED){
                                if(workOrders[0].Status != FFA_Constants.WORKORDER_STATUS_INPROGRESS){
                                    date reqAppdateValue = Date.valueOf(jsonConsumeWrap.Job.RequestedAppointmentDate!='' ? jsonConsumeWrap.Job.RequestedAppointmentDate:'');
                                    date reqAppEnddateValue;
                                    IF(jsonConsumeWrap.Job.RequestedAppointmentEndDate!=null){
                                        reqAppEnddateValue=Date.valueOf(jsonConsumeWrap.Job.RequestedAppointmentEndDate!='' ? jsonConsumeWrap.Job.RequestedAppointmentEndDate:'');
                                    }
                                    WorkOrders[0].FFA_RequestedAppointmentDate__c = DateTime.newInstance(reqAppdateValue.year(),reqAppdateValue.month(),reqAppdateValue.day(),00,00,00);
                                    WorkOrders[0].FFA_RequestedAppointmentTimeslot__c = string.valueOf(jsonConsumeWrap.Job.RequestedAppointmentTimeslot!='' ? jsonConsumeWrap.Job.RequestedAppointmentTimeslot:'');
                                    WorkOrders[0].FFA_RequestedAppointmentEndDate__c=reqAppEnddateValue!=null ? DateTime.newInstance(reqAppEnddateValue.year(),reqAppEnddateValue.month(),reqAppEnddateValue.day(),00,00,00) : null;
                                    workOrders[0].Sync_Status__c = FFA_Constants.WORKORDER_SYNC_STATUS_PENDING;
                                    workOrders[0].Status = 'New'; // Update on 9/4/2019 - as per given issue I-386566
                                    if(workOrders[0].FFA_Sender_ID__c=='RAINBOW'){
                                        workOrders[0].SAP_Replan__c = 'Yes';
                                        workOrders[0].FFA_JobReplanReasonCode__c='';
                                        IF(workOrders[0].Job_Category__c!=null){
                                            IF(workOrders[0].Job_Category__c.contains('NGM')){
                                            workOrders[0].FFA_UnplannedPolicyStartDate__c= DateTime.newInstance(reqAppdateValue.year(),reqAppdateValue.month(),reqAppdateValue.day(),00,00,00);
                                            }
                                        } 
                                    }
                                    DateTime replanDate = system.now();
                                    IF(headers.CreationTime==null || headers.CreationTime==''){
                                    headers.CreationTime='00:00:00';
                                    }
                                    String[] jsonReplanTime = headers.CreationTime.split(':');
                                    if(replanDate!=null){
                                        DateTime replanDateAndTimeValue = DateTime.newInstance(replanDate.year(),replanDate.month(),replanDate.day(), Integer.valueof(jsonReplanTime[0]),Integer.valueof(jsonReplanTime[1]),replanDate.second());
                                        workOrders[0].FFA_Replan_Date_Time__c= replanDateAndTimeValue;//replanDateAndTimeValue;
                                    }
                                    //Emergency Flag Update
                                    Date NewCheckReqApointmentdate;
                                    if(string.isNotBlank(newReqAppointmentDate)){
                                        NewCheckReqApointmentdate = Date.valueOf(newReqAppointmentDate);
                                    }
                                    System.debug('Checking Date value here == New Date =='+NewCheckReqApointmentdate+'== Today Date =='+System.today());
                                    if(NewCheckReqApointmentdate!=null && NewCheckReqApointmentdate == System.today()){  //update on 10/11/2019 - by Ankit
                                        workOrders[0].FFA_EmergencyFlag__c=True;
                                    }else{
                                        workOrders[0].FFA_EmergencyFlag__c=False;
                                    }
                                    workOrders[0].Transaction_Type__c = headers.TransactionType;
                                    
                                    //workOrders[0].FFA_Service_Provider_Replan__c = 'Yes'; // updated by ankit, on 10-02-2020 as per discussion with venkat.
                                    WorkOrderID = WorkOrders[0].Id;
                                    WorkOrderName=WorkOrders[0].WorkOrderNumber;
                                    ReqApointmentDate =WorkOrders[0].FFA_RequestedAppointmentDate__c;
                                    System.debug('SR====='+WorkOrders);
                                    
                                    // process of updating the Service Appointment Status
                                    string checkStatusValue; 
                                    boolean isStatusChecked;
                                    if(WorkOrderID!=null){
                                        list<ServiceAppointment> ServiceAppointmentQueryRecords = new list<ServiceAppointment>();
                                        ServiceAppointmentQueryRecords = [select Id, ParentRecordType,ParentRecordId, Status from ServiceAppointment where ParentRecordId =:WorkOrderID];
                                        if(!ServiceAppointmentQueryRecords.isEmpty()){
                                            for(ServiceAppointment ServiceAppointments : ServiceAppointmentQueryRecords){
                                                system.debug('Test Value === '+ServiceAppointments);
                                                if(ServiceAppointments.Status != FFA_Constants.WORKORDER_STATUS_CANCEL){
                                                    if(ServiceAppointments.Status != FFA_Constants.WORKORDER_STATUS_COMPLETED){
                                                        checkStatusValue=ServiceAppointments.Status;
                                                        ServiceAppointments.Status = FFA_Constants.WORKORDER_STATUS_CANCEL;
                                                        serviceAppointmentList.add(ServiceAppointments);
                                                        isStatusChecked = true;
                                                    }else{
                                                        isStatusChecked = false;
                                                    }
                                                }else{
                                                    isStatusChecked = false;
                                                }
                                            }
                                            if(isStatusChecked == false && string.isBlank(checkStatusValue)){
                                                CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_WO_SA_NOTVALID_STATUS,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.FAILURE_CODE,resPayload);
                                                return;
                                            }
                                        }else{
                                            CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_WO_SA_NOT_FOUND,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.FAILURE_CODE,resPayload);
                                            return;
                                        }
                                        // call update dml operation for the service appointment here and sending the success response 
                                        if(!serviceAppointmentList.isEmpty() && !WorkOrders.isEmpty()){
                                            update WorkOrders;
                                            system.debug('RequestApptdate--->'+WorkOrders[0].FFA_RequestedAppointmentDate__c);
                                            if(!test.isrunningtest()){ update serviceAppointmentList;}
                                            System.debug('SR(serviceAppointmentList)====='+serviceAppointmentList);
                                            createServiceAppointment(ReqApointmentDate,WorkOrderID);
                                            //Success Response when work order updated for replan successfully
                                            CreateResponse(FFA_Constants.SUCCESS_STATUS,FFA_Constants.UPDATE_REPLAN_SUCCESS_MESSAGE,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.SUCESS_CODE,resPayload);
                                            return;
                                        }
                                    }
                                }else{
                                    // Failure Response Structure when status already Cancelled or Completed
                                    CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_ERROR_BY_STATUS,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.FAILURE_CODE,resPayload);
                                    return;
                                }
                            }else{
                                // Failure Response Structure when status already Cancelled or Completed
                                CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_ERROR_BY_STATUS,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.FAILURE_CODE,resPayload);
                                return;
                            }
                        }else{
                            // Failure Response Structure when status already Cancelled or Completed
                            CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_ERROR_BY_STATUS,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.FAILURE_CODE,resPayload);
                            return;
                        }
                    }else{
                        // Failure response, If workdorder not found in Salesforce database
                        CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_WO_NOT_FOUND,ServiceNotificationNumberId,OperationNumberId,'',FFA_Constants.FAILURE_CODE,resPayload);
                        return;
                    }
                }
            }
            
            //When Trasaction is SA(Amend) From JSON
            if(jsonConsumeWrap!=null && jsonConsumeWrap.Header.TransactionType == FFA_Constants.FFA_TRANSACTIONTYPE_AMEND){
                WorkorderUpdateHandler.header headers = new WorkorderUpdateHandler.header();
                headers.TransactionType = jsonConsumeWrap.Header.TransactionType!='' ? jsonConsumeWrap.Header.TransactionType:'';
                headers.CreationDate = jsonConsumeWrap.Header.CreationDate!='' ? jsonConsumeWrap.Header.CreationDate:''; 
                headers.CreationTime = jsonConsumeWrap.Header.CreationTime!='' ? jsonConsumeWrap.Header.CreationTime:'';
                headers.FileType = jsonConsumeWrap.Header.FileType!='' ? jsonConsumeWrap.Header.FileType:'';
                headers.GenerationNumber = jsonConsumeWrap.Header.GenerationNumber!='' ? jsonConsumeWrap.Header.GenerationNumber:'';
                headers.ReceiverID = jsonConsumeWrap.Header.ReceiverID!='' ? jsonConsumeWrap.Header.ReceiverID:'';
                headers.SenderID = jsonConsumeWrap.Header.SenderID!='' ? jsonConsumeWrap.Header.SenderID:'';
                headers.InterfaceName = jsonConsumeWrap.Header.InterfaceName!='' ? jsonConsumeWrap.Header.InterfaceName:'';
                
                string SiteId;
                boolean isWorkOrderAmend = false;
                // process of Updating Work order here 
                if((jsonConsumeWrap.Job!=null && (string.isNotBlank(jsonConsumeWrap.Job.ServiceNotificationNumber) && string.isNotBlank(jsonConsumeWrap.Job.OperationNumber))) ||
                    jsonConsumeWrap.Job!=null && (string.isNotBlank(jsonConsumeWrap.Job.ServiceNotificationNumber) && headers.SenderID=='RAINBOW'  )){
                    ServiceNotificationNumberId=jsonConsumeWrap.Job.ServiceNotificationNumber;
                    IF(headers.SenderID=='RAINBOW'){
                        OperationNumberId = '';
                    }else{
                        OperationNumberId = jsonConsumeWrap.Job.OperationNumber;
                    }
                    string finalServiceNotificationNumberId = ServiceNotificationNumberId.trim();
                    system.debug('finalServiceNotificationNumberId==='+finalServiceNotificationNumberId);
                    string finalOperationNumberId= OperationNumberId.trim();
                    system.debug('finalOperationNumberId==='+finalServiceNotificationNumberId+''+finalOperationNumberId);
                    list<Workorder> workOrders=new list<Workorder> ();
                    IF(headers.SenderID=='RAINBOW'){
                    String WOREJECTSTATUS= FFA_Constants.DOMSTATUSReject;
                        workOrders = [select Id,WorkOrderNumber,Transaction_Type__c, Status,FFA_ServiceNotificationNumber__c,FFA_OperationNumber__c,Site__c,FFA_ShipperID__c,FFA_ShipperName__c from WorkOrder where FFA_ServiceNotificationNumber__c =:finalServiceNotificationNumberId AND status!=:WOREJECTSTATUS limit 1];
                        system.debug('Query on workOrder---'+WorkOrders);
                    }else{
                        workOrders = [select Id,WorkOrderNumber,Transaction_Type__c, Status,FFA_ServiceNotificationNumber__c,FFA_OperationNumber__c,Site__c,FFA_ShipperID__c,FFA_ShipperName__c from WorkOrder where FFA_ServiceNotificationNumber__c =:finalServiceNotificationNumberId AND FFA_OperationNumber__c =:finalOperationNumberId limit 1];
                        system.debug('Query on workOrder---'+WorkOrders);
                    }
                    if(!WorkOrders.isEmpty()){
                        if(WorkOrders[0].Status!=FFA_Constants.WORKORDER_STATUS_CANCEL){
                            if(workOrders[0].Status!=FFA_Constants.WORKORDER_STATUS_COMPLETED){
                                WorkOrderID = WorkOrders[0].Id;
                                WorkOrderName = WorkOrders[0].WorkOrderNumber;
                                workOrders[0].Transaction_Type__c = headers.TransactionType;
                                workOrders[0].Sync_Status__c = FFA_Constants.WORKORDER_SYNC_STATUS_PENDING;
                                workOrders[0].FFA_ShipperID__c = jsonConsumeWrap.Job.supplierid != null && jsonConsumeWrap.Job.supplierid != '' ? jsonConsumeWrap.Job.supplierid : workOrders[0].FFA_ShipperID__c;
                                workOrders[0].FFA_ShipperName__c = jsonConsumeWrap.Job.supplierid != null && jsonConsumeWrap.Job.supplierid != '' ? getSupplierName(jsonConsumeWrap.Job.supplierid) : workOrders[0].FFA_ShipperName__c;
                                SiteId = workOrders[0].Site__c;
                                update workOrders;
                                system.debug('SA====='+WorkOrderID);
                                
                                
                                
                                //Operation for Updating Site,Here
                                if(jsonConsumeWrap.Site !=null && string.isNotBlank(SiteId)){
                                    for(FFA_Site__c Sites : [select Id,FFA_Title__c,FFA_Initials__c,FFA_Surname__c,FFA_ContactTelephoneNumber__c,Name,FFA_BuildingName__c,FFA_SubBuildingName__c,FFA_BuildingNumber__c,FFA_DependentStreet__c,
                                                             FFA_PrincipalStreet__c,FFA_DependentLocality__c,FFA_DoubleDependantLocality__c,FFA_PostTown__c,FFA_County__c,FFA_PostcodeOutcode__c,FFA_PostcodeIncode__c,FFA_GPSEasting__c,FFA_GPSNorthing__c,
                                                             FFA_AccessInstructions__c,FFA_CorrespondenceAddress__c,FFA_DoesTheSiteContainAsbestos__c from FFA_Site__c where Id =: SiteId]){
                                                                 if(Sites!=null){
                                                                     System.debug('site List value --->>'+Sites);
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.Title)){Sites.FFA_Title__c = jsonConsumeWrap.Site.Title;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.Initials)){Sites.FFA_Initials__c = jsonConsumeWrap.Site.Initials;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.Surname)){Sites.FFA_Surname__c = jsonConsumeWrap.Site.Surname;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.ContactTelephoneNumber)){Sites.FFA_ContactTelephoneNumber__c = jsonConsumeWrap.Site.ContactTelephoneNumber;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.SiteName)){Sites.Name = jsonConsumeWrap.Site.SiteName;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.BuildingName)){Sites.FFA_BuildingName__c = jsonConsumeWrap.Site.BuildingName;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.SubBuildingName)){Sites.FFA_SubBuildingName__c = jsonConsumeWrap.Site.SubBuildingName;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.BuildingNumber)){Sites.FFA_BuildingNumber__c = jsonConsumeWrap.Site.BuildingNumber;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.DependentStreet)){Sites.FFA_DependentStreet__c = jsonConsumeWrap.Site.DependentStreet;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.PrincipalStreet)){Sites.FFA_PrincipalStreet__c = jsonConsumeWrap.Site.PrincipalStreet;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.DependentLocality)){Sites.FFA_DependentLocality__c = jsonConsumeWrap.Site.DependentLocality;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.DoubleDependantLocality)){Sites.FFA_DoubleDependantLocality__c = jsonConsumeWrap.Site.DoubleDependantLocality;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.PostTown)){Sites.FFA_PostTown__c = jsonConsumeWrap.Site.PostTown;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.County)){Sites.FFA_County__c = jsonConsumeWrap.Site.County;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.PostcodeOutcode)){Sites.FFA_PostcodeOutcode__c = jsonConsumeWrap.Site.PostcodeOutcode;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.PostcodeIncode)){Sites.FFA_PostcodeIncode__c = jsonConsumeWrap.Site.PostcodeIncode;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.GPSEasting)){Sites.FFA_GPSEasting__c = jsonConsumeWrap.Site.GPSEasting;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.GPSNorthing)){Sites.FFA_GPSNorthing__c = jsonConsumeWrap.Site.GPSNorthing;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.AccessInstructions)){Sites.FFA_AccessInstructions__c = jsonConsumeWrap.Site.AccessInstructions;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.CorrespondenceAddress)){Sites.FFA_CorrespondenceAddress__c = jsonConsumeWrap.Site.CorrespondenceAddress;}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.DoesTheSiteContainAsbestos)){Sites.FFA_DoesTheSiteContainAsbestos__c =boolean.valueOf(jsonConsumeWrap.Site.DoesTheSiteContainAsbestos);}
                                                                     if(string.isNotBlank(jsonConsumeWrap.Site.AsbestosDetails)){}
                                                                     SiteList.add(Sites);
                                                                 }
                                                             }
                                    if(!SiteList.isEmpty()){
                                        update SiteList;
                                        system.debug('SA(Sites)====='+SiteList);
                                    }
                                }
                                //Operation for updating Asset(Meter) Here
                                if(jsonConsumeWrap.Meter!=null && WorkOrderID!=null){
                                    for(FFA_NGV_Asset__c Assets : [select id ,Work_Order__c,FFA_Asset_Type__c,FFA_Serial_Number__c from FFA_NGV_Asset__c where Work_Order__c =: WorkOrderID AND FFA_Asset_Type__c = 'Meter']){
                                        system.debug('Meter Value====='+Assets);
                                        if(Assets!=null){
                                            if(string.isNotBlank(jsonConsumeWrap.Meter.MeterSerialNumber)){
                                                Assets.FFA_Serial_Number__c = jsonConsumeWrap.Meter.MeterSerialNumber!='' ? jsonConsumeWrap.Meter.MeterSerialNumber:'';}
                                            if(string.isNotBlank(jsonConsumeWrap.Meter.MeterManufacturer)){
                                                Assets.FFA_Manufacturer__c = jsonConsumeWrap.Meter.MeterManufacturer!='' ? jsonConsumeWrap.Meter.MeterManufacturer:'';}
                                            if(string.isNotBlank(jsonConsumeWrap.Meter.MeterModel)){
                                                Assets.FFA_Model__c = jsonConsumeWrap.Meter.MeterModel!='' ? jsonConsumeWrap.Meter.MeterModel:'';}
                                            MeterList.add(Assets);
                                        }else{
                                            // Failure Response Structure when Asset(Meter) is not found in salesforce database
                                            CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_ASSET_NOT_FOUND,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.FAILURE_CODE,resPayload);
                                            return;
                                            
                                        }
                                    }
                                    // call for update dml operation for Asset(Meter) update 
                                    if(!Meterlist.isEmpty()){
                                        update Meterlist;
                                        system.debug('SA(Meterlist)====='+Meterlist);
                                        //Success Response when Asset(Meter) updated Successfully
                                        //CreateResponse(FFA_Constants.SUCCESS_STATUS,FFA_Constants.UPDATE_AMEND_SUCCESS_MESSAGE,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.SUCESS_CODE,resPayload);
                                        //return;
                                    }
                                }
                                // Operation for updating Convertor Asset Here
                                if(jsonConsumeWrap.Convertor!=null && WorkOrderID!=null){
                                    system.debug('Amend Convertor===='+jsonConsumeWrap.Convertor);
                                    system.debug('Amend WorkOrderID===='+WorkOrderID);
                                    for(FFA_NGV_Asset__c Assets : [select id ,Work_Order__c,FFA_Asset_Type__c,FFA_Serial_Number__c from FFA_NGV_Asset__c where Work_Order__c =: WorkOrderID AND FFA_Asset_Type__c = 'Converter' limit 1]){
                                        system.debug('Convertor Value====='+Assets);
                                        if(Assets!=null){
                                            if(string.isNotBlank(jsonConsumeWrap.Convertor.ConvertorSerialNumber)){
                                                Assets.FFA_Serial_Number__c = jsonConsumeWrap.Convertor.ConvertorSerialNumber!='' ? jsonConsumeWrap.Convertor.ConvertorSerialNumber:'';}
                                            if(string.isNotBlank(jsonConsumeWrap.Convertor.ConvertorManufacturer)){
                                                Assets.FFA_Manufacturer__c = jsonConsumeWrap.Convertor.ConvertorManufacturer!='' ? jsonConsumeWrap.Convertor.ConvertorManufacturer:'';}
                                            if(string.isNotBlank(jsonConsumeWrap.Convertor.ConvertorModel)){
                                                Assets.FFA_Model__c = jsonConsumeWrap.Convertor.ConvertorModel!='' ? jsonConsumeWrap.Convertor.ConvertorModel:'';}
                                            Convertorlist.add(Assets);
                                        }else{
                                            // Failure Response Structure when Asset(Convertor) is not found in salesforce database
                                            CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_ASSET_NOT_FOUND,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.FAILURE_CODE,resPayload);
                                            return;
                                        }
                                    }
                                    //Call for update dml operation here for Asset(Convertor)
                                    if(!Convertorlist.isEmpty()){
                                        update Convertorlist;
                                        system.debug('SA(Convertorlist)====='+Convertorlist);
                                        //Success Response when Asset(Convertor) updated Successfully
                                        //CreateResponse(FFA_Constants.SUCCESS_STATUS,FFA_Constants.UPDATE_AMEND_SUCCESS_MESSAGE,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.SUCESS_CODE,resPayload);
                                       // return;
                                    }
                                }
                                // Operation for updating Flow Computer Asset Here
                                if(jsonConsumeWrap.FlowComputer!=null && WorkOrderID!=null){
                                    system.debug('Amend Flow Computer===='+jsonConsumeWrap.FlowComputer);
                                    system.debug('Amend WorkOrderID===='+WorkOrderID);
                                    for(FFA_NGV_Asset__c Assets : [select id ,Work_Order__c,FFA_Asset_Type__c,FFA_Serial_Number__c from FFA_NGV_Asset__c where Work_Order__c =: WorkOrderID AND FFA_Asset_Type__c = 'Flow Computer']){
                                        system.debug('FlowComputer Value====='+Assets);
                                        if(Assets != null){
                                            if(string.isNotBlank(jsonConsumeWrap.FlowComputer.FlowComputerSerialNumber)){
                                                Assets.FFA_Serial_Number__c = jsonConsumeWrap.FlowComputer.FlowComputerSerialNumber!='' ? jsonConsumeWrap.FlowComputer.FlowComputerSerialNumber:'';}
                                            if(string.isNotBlank(jsonConsumeWrap.FlowComputer.FlowComputerManufacturer)){
                                                Assets.FFA_Manufacturer__c = jsonConsumeWrap.FlowComputer.FlowComputerManufacturer!='' ? jsonConsumeWrap.FlowComputer.FlowComputerManufacturer:'';}
                                            if(string.isNotBlank(jsonConsumeWrap.FlowComputer.FlowComputerModel)){
                                                Assets.FFA_Model__c = jsonConsumeWrap.FlowComputer.FlowComputerModel!='' ? jsonConsumeWrap.FlowComputer.FlowComputerModel:'';}
                                            FlowComputerlist.add(Assets);
                                        }else{
                                            // Failure Response Structure when Asset(Flow Computer) is not found in salesforce database
                                            CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_ASSET_NOT_FOUND,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.FAILURE_CODE,resPayload);
                                            return;
                                        }
                                    }
                                    //Call for update dml operation here for Asset(Flow Computer)
                                    if(!FlowComputerlist.isEmpty()){
                                        update FlowComputerlist;
                                        system.debug('SA(FlowComputerlist)====='+FlowComputerlist);
                                        //Success Response when Asset(Flow Computer) updated Successfully
                                       // CreateResponse(FFA_Constants.SUCCESS_STATUS,FFA_Constants.UPDATE_AMEND_SUCCESS_MESSAGE,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.SUCESS_CODE,resPayload);
                                        //return;
                                    }
                                }
                                
                                isWorkOrderAmend = true;
                            }else{
                                // Failure Response Structure when status already Cancelled or Completed
                                CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_ERROR_BY_STATUS,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.FAILURE_CODE,resPayload);
                                return;
                            }
                        }else{
                            // Failure Response Structure when status already Cancelled or Completed
                            CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_ERROR_BY_STATUS,ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.FAILURE_CODE,resPayload);
                            return;
                        }
                    }else{
                        // Failure response, If workdorder not found in Salesforce database
                        CreateResponse(FFA_Constants.FAILURE_STATUS,FFA_Constants.UPDATE_WO_NOT_FOUND,ServiceNotificationNumberId,OperationNumberId,'',FFA_Constants.FAILURE_CODE,resPayload);
                        return;
                    }
                }
                
                if(isWorkOrderAmend == true){
                    CreateResponse(FFA_Constants.SUCCESS_STATUS,'Work Order Amend Succesfully',ServiceNotificationNumberId,OperationNumberId,WorkOrderName,FFA_Constants.SUCESS_CODE,resPayload);
                    return;
                }
            }
        }catch(Exception e){
            system.debug('The following exception has occurred: ' +e.getLineNumber()+' : - '+ e.getMessage());
            CreateResponse(FFA_Constants.FAILURE_STATUS,e.getLineNumber()+' : - '+ e.getMessage(),ServiceNotificationNumberId,OperationNumberId,'',FFA_Constants.FAILURE_CODE,resPayload);
            return;
        }
    }
    
    // jSON Deserialize here
    public static WorkorderUpdateHandler parse(String json) {
        return (WorkorderUpdateHandler) System.JSON.deserialize(json, WorkorderUpdateHandler.class);
    }
    
    // Creating Service Appointment here in case of available service appointment got cancelled in case of Replan
    static void createServiceAppointment(DateTime ReqAppointDate,ID WorkOrderId){
        list<ServiceAppointment> serviceApList = new list<ServiceAppointment>();
        workorder relatedWo=[Select id,FFA_ServiceProvider__c,FFA_RequestedAppointmentEndDate__c from workorder WHERE id=:WorkOrderId limit 1];
        if(WorkOrderId!=null){
            ServiceAppointment serviceAp = new ServiceAppointment();
            serviceAp.ParentRecordId = WorkOrderId;
            if(ReqAppointDate!=null){
                serviceAp.EarliestStartTime = DateTime.newInstance(ReqAppointDate.year(),ReqAppointDate.month(),ReqAppointDate.day(),00,00,00);
                serviceAp.DueDate = DateTime.newInstance(ReqAppointDate.year(),ReqAppointDate.month(),ReqAppointDate.day(),23,59,00);
                serviceAp.SchedStartTime = DateTime.newInstance(ReqAppointDate.year(),ReqAppointDate.month(),ReqAppointDate.day(),00,00,00);
                IF(relatedWo.FFA_RequestedAppointmentEndDate__c!=null){
                    serviceAp.SchedEndTime = DateTime.newInstance(relatedWo.FFA_RequestedAppointmentEndDate__c.year(),relatedWo.FFA_RequestedAppointmentEndDate__c.month(),relatedWo.FFA_RequestedAppointmentEndDate__c.day(),23,59,00);
                }
                else{
                serviceAp.SchedEndTime = DateTime.newInstance(ReqAppointDate.year(),ReqAppointDate.month(),ReqAppointDate.day(),23,59,00);
                }
            }
            if(relatedWo.FFA_ServiceProvider__c!=null){
                serviceAp.FFA_SP_ID__c=relatedWo.FFA_ServiceProvider__c;
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
    }
    
    // Method for sending Success/Failure Response after update operation
    static System.RestResponse CreateResponse(string TransactionStatus,string TransactionMessage,string ServiceNotificationNumber,string OperationNumber,string WorkOrderNumber,string HTTP_Status_Code,string payload){
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json;charset=UTF-8');
        WorkorderUpdateHandler.ResponseStruct resWrappers = new WorkorderUpdateHandler.ResponseStruct();
        resWrappers.TransactionStatus = TransactionStatus;
        resWrappers.TransactionMessage = TransactionMessage;
        resWrappers.ServiceNotificationNumber = ServiceNotificationNumber;
        resWrappers.OperationNumber = OperationNumber;
        resWrappers.WorkOrderNumber= WorkOrderNumber;
        resWrappers.HTTP_Status_Code= HTTP_Status_Code;
        res.responseBody=  Blob.valueOf(JSON.serialize(resWrappers)); 
        system.debug('resWrap---'+JSON.serialize(resWrappers));
        res.responseBody=  Blob.valueOf(JSON.serialize(resWrappers));
        FFA_Interface_Runs__c InterfaceLogs = new FFA_Interface_Runs__c(Interface_Name__c='/FFAUpdateInterface',Transaction_Message__c=JSON.serialize(resWrappers), Transaction_Status__c = TransactionStatus);
        insert InterfaceLogs;
        Blob payLoadBlob = Blob.valueOf(payload);
        CreateHttpResponseFile(payLoadBlob,InterfaceLogs.id);
        return res;
    }
    
    public static void CreateHttpResponseFile(blob Payload,ID interfaceRunID){
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'Workorderupdate.txt'; // The files name, extension is very important here which will help the file in preview.
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
    
    public static String getSupplierName(String supplierid){
        if(supplierid == null || supplierid == ''){
            return '';
        }
        NGMCP_Supplier_Information__mdt supplier = [Select id, NGMCP_Supplier_Full_Name__c 
                                                    from NGMCP_Supplier_Information__mdt
                                                   where MasterLabel =:supplierid
                                                   limit 1];
        if(supplier != null){
            return supplier.NGMCP_Supplier_Full_Name__c;
        }
        else{
            return '';
        }
    }
    
    // Wrapper structure 
    public class ResponseStruct{
        public string TransactionMessage; 
        public string TransactionStatus;
        public string ServiceNotificationNumber;
        public string OperationNumber;
        public string WorkOrderNumber;
        public string HTTP_Status_Code;
    }
    
    public Header Header { get; set; }
    public Job Job { get; set; }
    public Site Site {get; set;}
    public Meter Meter { get; set; }
    public Convertor Convertor { get; set; }
    public FlowComputer FlowComputer { get; set; }
    public Trailer Trailer { get; set; }
    
    public class Header{
        public string TransactionType { get; set; }
        public string SenderID { get; set; }
        public string ReceiverID { get; set; }
        public string InterfaceName { get; set; }
        public string FileType { get; set; }
        public string CreationDate { get; set; }
        public string CreationTime { get; set; }
        public string GenerationNumber { get; set; }
    }
    
    public class Job{
        public string ServiceNotificationNumber { get; set; }
        public string OperationNumber { get; set; }
        public string RequestedAppointmentDate { get; set; }
        public string RequestedAppointmentTimeslot { get; set; }
        public string RequestedAppointmentEndDate { get; set; }
        public String supplierid {get; set;}
    }
    
    public class Site{
        public string Title {get; set;}
        public string Initials {get; set;}
        public string Surname {get; set;}
        public string ContactTelephoneNumber {get; set;}
        public string SiteName {get; set;}
        public string BuildingName {get; set;}
        public string SubBuildingName {get; set;}
        public string BuildingNumber {get; set;}
        public string DependentStreet {get; set;}
        public string PrincipalStreet {get; set;}
        public string DependentLocality {get; set;}
        public string DoubleDependantLocality {get; set;}
        public string PostTown {get; set;}
        public string County {get; set;}
        public string PostcodeOutcode {get; set;}
        public string PostcodeIncode {get; set;}
        public string GPSEasting {get; set;}
        public string GPSNorthing {get; set;}
        public string AccessInstructions {get; set;}
        public string CorrespondenceAddress {get; set;}
        public string DoesTheSiteContainAsbestos {get; set;}
        public string AsbestosDetails {get; set;}
    }
    
    public class Meter{
        public string MeterSerialNumber { get; set; }
        public string MeterManufacturer;
        public string MeterModel;
    }
    
    public class Convertor{
        public string ConvertorSerialNumber { get; set; }
        public string ConvertorManufacturer;
        public string ConvertorModel;
    }
    
    public class FlowComputer{
        public string FlowComputerSerialNumber;
        public string FlowComputerManufacturer;
        public string FlowComputerModel;
    }
    
    public class Trailer{
        public string TransactionType { get; set; }
        public string RecordCount { get; set; }
    }
}