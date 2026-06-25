/////////////////////////////////////////////////
/*          SAP-FFA CREATE INTERFACE (F1)      */
/*          Author: VENKAT PATTAPU             */ 
/*          Company: Wipro Technologies        */
/*          Created Date: 01/07/2019           */
/*          Datails: Creates Data from SAP     */
/////////////////////////////////////////////////
/////////////////////////////////////////////////
/* Code Updates:                               */
/////////////////////////////////////////////////

@RestResource(urlMapping='/FFACreateInterface/*') //NGcreateJOB
global with sharing class FFACreateInterfaceHandler{
    
    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        FFA_CreateInterfaceModel.SystemResponseWrapper resWrapper = new FFA_CreateInterfaceModel.SystemResponseWrapper();
        String reqPayload= req.requestBody.toString();
        System.debug('Request Body: ' + reqPayload);
        FFA_CreateInterfaceModel.wrapperClass wc = new FFA_CreateInterfaceModel.wrapperClass();
        System.debug('wc:'+wc);
        
     try{
          if(reqPayload!=null){
            Map<String, Object> reqPayloadMap = (Map<String, Object>) JSON.deserializeUntyped(reqPayload);
            Record_Type__mdt[] configObjTypes = [Select MasterLabel from Record_Type__mdt where MasterLabel not in('Job','Site')];
            System.debug('reqPayloadMap-deserializedintoJson: ' + reqPayloadMap);
            System.debug('Payload RecordType MDTs Body: ' + configObjTypes);
            List<String> serializedReqBodyForRecordTypeList=new List<String>();
            List<FFA_NGV_Asset__c> assets = new List<FFA_NGV_Asset__c>();
            /*Get Header Details */
            FFA_CreateInterfaceModel.Header headerBody= (FFA_CreateInterfaceModel.Header) JSON.deserialize(JSON.serialize(reqPayloadMap.get('Header')),FFA_CreateInterfaceModel.Header.class);
            System.debug('Header Body Value==='+headerBody);
            wc.HeaderMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(headerBody));
            string SENDERIDVALUE = wc.HeaderMapObject.get('SenderID').toString();
            string TRANSACTIONTYPEVALUE = wc.HeaderMapObject.get('TransactionType').toString();
            System.debug('Sender Value from Header ==='+SENDERIDVALUE);
            /*Create new Workorder */
            Job jobBody = (Job)JSON.deserialize(JSON.serialize(reqPayloadMap.get(FFA_Constants.FFA_JOB_RECORD_TYPE)),Job.Class);
            System.debug('Job jobBody ' + jobBody);
            wc.jobMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(jobBody));
            System.debug('wc.jobMapObject ' +  wc.jobMapObject.get('ServiceNotificationNumber'));
            
            String serviceNotifNo= wc.jobMapObject.get(FFA_Constants.SERVICE_NOTIFICATION).toString();
            String operationNo;
            if(SENDERIDVALUE=='RAINBOW'){
                operationNo='';
            }
            if(SENDERIDVALUE=='PHOENIX'){
                operationNo=wc.jobMapObject.get(FFA_Constants.OPERATION_NO).toString();
            }
            system.debug('SENDERIDVALUE--'+SENDERIDVALUE);
            String WOSTATUSREJECT=FFA_Constants.DOMSTATUSReject;
            integer workorderCount;
            if(SENDERIDVALUE=='PHOENIX'){
                workorderCount = Database.countQuery('SELECT COUNT() FROM WorkOrder where FFA_ServiceNotificationNumber__c = :serviceNotifNo AND FFA_OperationNumber__c = :operationNo');
            }
            else{
                workorderCount = Database.countQuery('SELECT COUNT() FROM WorkOrder where FFA_ServiceNotificationNumber__c = :serviceNotifNo AND status!=:WOSTATUSREJECT');
            }
            System.debug('WorkOrder Count: ' + workorderCount+'of'+SENDERIDVALUE);
            string ServiceProviderId;
            //Duplicate workorder check
            Boolean isPayloadValid;
            if(workorderCount==0){
                boolean isMandtoryNullValueChecked = isValidatePayLoad(wc.jobMapObject,SENDERIDVALUE);
         
                if(isMandtoryNullValueChecked){
                    String JobCodeValue = string.valueOf(wc.jobMapObject.get('JobCode'));
                    String ServiceProviderValue = String.valueOf(wc.jobMapObject.get('ServiceProvider'));
                    string RequestedAppointmentDates = string.valueOf(wc.jobMapObject.get('RequestedAppointmentDate'));
                    string ServiceNotificationNumbers = string.valueOf(wc.jobMapObject.get('ServiceNotificationNumber'));
                    string OperationNumbers = string.valueOf(wc.jobMapObject.get('OperationNumber'));
                    string UnplannedPolicyStartDates = string.valueOf(wc.jobMapObject.get('UnplannedPolicyStartDate'));
                    string UnplannedPolicyEndDates = string.valueOf(wc.jobMapObject.get('UnplannedPolicyEndDate'));
                    list<Date> datelist = new list<Date>();
                    Date ReqAppointmentDates;
                    Date unplanStartDate;
                    Date UnplanEndDate;
                    if(string.isNotBlank(RequestedAppointmentDates)){
                        ReqAppointmentDates = Date.ValueOf(RequestedAppointmentDates);}
                    if(string.isNotBlank(UnplannedPolicyStartDates)){
                        unplanStartDate = Date.ValueOf(UnplannedPolicyStartDates);}
                    if(string.isNotBlank(UnplannedPolicyEndDates)){
                        UnplanEndDate = Date.ValueOf(UnplannedPolicyEndDates);}
                    
                    list<WorkType> wot=[Select id,name from WorkType where Name =: JobCodeValue limit 1];
                    list<Account> acc = [select Id, Name from Account where Name =: ServiceProviderValue limit 1];
                    
                    if(!wot.isEmpty()){
                        system.debug('Job code value ==='+wot.size());
                        if(!acc.isEmpty()){
                            ServiceProviderId = acc[0].name;
                            system.debug('service provider value ==='+acc.size());
                            if(ReqAppointmentDates >= System.today() || (unplanStartDate>=System.Today() && UnplanEndDate>=unplanStartDate)){
                                datelist.add(ReqAppointmentDates);
                            }else{
                                CreateResponse('Failure',FFA_Constants.REQAPPOINTMENTDATE_NOTVALID,serviceNotifNo,operationNo,wc.newJobRecord.WorkOrderNumber,'400',reqPayload);
                                return;
                            }
                        }else{
                            CreateResponse('Failure',FFA_Constants.SERVICE_PROVIDER_NOTVALID,serviceNotifNo,operationNo,wc.newJobRecord.WorkOrderNumber,'400',reqPayload);
                            return;
                        }
                        isPayloadValid = true;
                    }else{
                        CreateResponse('Failure',FFA_Constants.JOBCODE_NOTVALID_OR_MISSING,serviceNotifNo,operationNo,wc.newJobRecord.WorkOrderNumber,'400',reqPayload);
                        return;
                    }
                }else{
                    CreateResponse('Failure',FFA_Constants.MANDATORY_DATA_MISSING,serviceNotifNo,operationNo,wc.newJobRecord.WorkOrderNumber,'400',reqPayload);
                    return;
                }
                
                
                if(isPayloadValid){
                    System.debug('isPayloadValid: ' + isPayloadValid);
                    FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(FFA_Constants.FFA_JOB_RECORD_TYPE);
                    FFA_Site siteBody = (FFA_Site)JSON.deserialize(JSON.serialize(reqPayloadMap.get(FFA_Constants.FFA_SITE_RECORD_TYPE)),FFA_Site.Class);
                    wc.siteMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(siteBody));
                    System.debug('---SZ'+mappings.size());
                    if(mappings.size()>0){
                        System.debug('wo mappings: ' + mappings);
                        wc.newJobRecord = CreateNewWORecord(wc.jobMapObject,wc.siteMapObject,SENDERIDVALUE,mappings);
                        System.debug('wc.newJobRecord: ' + wc.newJobRecord);
                    }else{
                        // Failure response when FFA_INTEGRATION_CONFIG_MISSING
                        CreateResponse('Failure',FFA_Constants.FFA_INTEGRATION_CONFIG_MISSING,serviceNotifNo,operationNo,wc.newJobRecord.WorkOrderNumber,'400',reqPayload);
                        return;
                    }
                }else{
                    // failure Response when Mandatory Field is missing
                    CreateResponse('Failure',FFA_Constants.MANDATORY_DATA_MISSING,serviceNotifNo,operationNo,wc.newJobRecord.WorkOrderNumber,'400',reqPayload);
                    return;
                }
            }else{
                // Failure response when duplicate work order is found
                CreateResponse('Failure',FFA_Constants.DUPLICATE_WORKORDER,serviceNotifNo,operationNo,wc.newJobRecord.WorkOrderNumber,'400',reqPayload);
                return;
            }
            Id newWorkOrderId=wc.newJobRecord != null ? wc.newJobRecord.Id : null; 
            System.debug('newWorkOrderId: '+newWorkOrderId);
            if(newWorkOrderId!=null){
                Id WOIds = wc.newJobRecord.Id;
                system.debug('Work Order Id ==='+WOIds);
                List<WorkOrder> workorderList=[select id,DSEAR_Status__c,Full_DSEAR__c,Full_DSEAR_Id__c,DSEAR_Lookup__c,FFA_Work_Type_Name__c,Service_Provider__c,FFA_ServiceProvider__c,FFA_RequestedAppointmentDate__c,FFA_RequestedAppointmentEndDate__c,FFA_UnplannedPolicyEndDate__c,FFA_UnplannedPolicyStartDate__c,FFA_RequestCreatedDate__c,FFA_MeterPointReferenceNumber__c from WorkOrder where id =: WOIds];
                Id DsearLookupId;
                if(!workorderList.isEmpty()){
                    WorkOrder workorder=workorderList[0];
                    workorder.Status='New';
                    //workorder.Site__c=wc.newSiteRecord.Id;
                    workorder.FFA_Sender_ID__c = SENDERIDVALUE;
                    workorder.Transaction_Type__c = TRANSACTIONTYPEVALUE;
                    
                    // For DSEAR logic,
                    String getDsearIdAndValues;
                    String WorkTypeValue = WorkOrder.FFA_Work_Type_Name__c;
                    String MPRNValue = WorkOrder.FFA_MeterPointReferenceNumber__c;
                    if(SENDERIDVALUE.contains('PHOENIX')){
                        if(!WorkTypeValue.contains('EPCXXXX')){
                            if( !WorkTypeValue.contains('EPNXXXX')){
                                if(!WorkTypeValue.contains('EPDXXXX')){
                                    if(!WorkTypeValue.contains('EPUXXXX')){
                                        if(!WorkTypeValue.contains('EPRXXXX')){
                                            if(!WorkTypeValue.contains('EPTXXXX')){
                                                getDsearIdAndValues = FFAGetDSEARWorkOrder.getDsearWorkOrderId(MPRNValue);
                                                system.debug(getDsearIdAndValues);
                                                if(String.isNotBlank(getDsearIdAndValues) && getDsearIdAndValues.contains('@') && !getDsearIdAndValues.contains('Null')){
                                                    System.debug(getDsearIdAndValues);System.debug('======>>>> 1');
                                                    String DsearId = getDsearIdAndValues.substringBefore('@');
                                                    System.debug(DsearId);
                                                    string DsearMPRNValue = getDsearIdAndValues.substringAfter('@');
                                                    System.debug(DsearMPRNValue);
                                                    if(!DsearId.contains('null') && string.isNotBlank(DsearMPRNValue) && !DsearMPRNValue.contains('null')){
                                                        if(WorkOrder.FFA_MeterPointReferenceNumber__c == DsearMPRNValue){
                                                            WorkOrder.Full_DSEAR__c = DsearId;
                                                            WorkOrder.DSEAR_Status__c = 'F';
                                                           /* list<DSEAR__c> dsearValueList = [select Id , Name from DSEAR__c where Name =: DsearId limit 1];
                                                            if(dsearValueList!=null){
                                                                WorkOrder.Full_DSEAR_Id__c = DsearId;
                                                                //WorkOrder.Full_DSEAR__c = dsearValueList[0].Id;
                                                            }*/
                                                            // Create Blank DSEAR record
                                                            DSEAR__c dsearRecord = new DSEAR__c();
                                                            dsearRecord.Work_Order__c = WorkOrder.Id;
                                                            insert dsearRecord;
                                                            DsearLookupId = dsearRecord.Id;
                                                        }
                                                    }
                                                }else{
                                                    if(String.isNotBlank(getDsearIdAndValues) && getDsearIdAndValues.contains('*') && !getDsearIdAndValues.contains('Null')){
                                                        string DsearMPRNValue = getDsearIdAndValues.substringAfter('*');
                                                        System.debug('======>>>> 2');
                                                        system.debug(WorkOrder.FFA_MeterPointReferenceNumber__c+' === '+DsearMPRNValue);
                                                        if(WorkOrder.FFA_MeterPointReferenceNumber__c == DsearMPRNValue){
                                                            WorkOrder.DSEAR_Status__c = 'S';
                                                            
                                                            // Create Blank DSEAR record
                                                            DSEAR__c dsearRecord = new DSEAR__c();
                                                            dsearRecord.Work_Order__c = WorkOrder.Id;
                                                            insert dsearRecord;
                                                            DsearLookupId = dsearRecord.Id;
                                                        }
                                                    }else{
                                                        // Create Blank DSEAR record
                                                        DSEAR__c dsearRecord = new DSEAR__c();
                                                        dsearRecord.Work_Order__c = WorkOrder.Id;
                                                        insert dsearRecord;
                                                        DsearLookupId = dsearRecord.Id;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }   
                
                    
                    Date checkReqApointmentdates;
                    Date checkReqApointmentEndDates;
                    if(workorder.FFA_RequestedAppointmentDate__c!=null){
                        Date checkReqApointmentdate = workorder.FFA_RequestedAppointmentDate__c.date();//date.valueOf(workorder.FFA_RequestedAppointmentDate__c);
                        checkReqApointmentdates = checkReqApointmentdate;
                        system.debug(checkReqApointmentdates);
                    }
                    
                    if(workorder.FFA_RequestedAppointmentEndDate__c!=null && workorder.FFA_RequestedAppointmentEndDate__c != workorder.FFA_RequestedAppointmentDate__c){
                        Date checkReqAppointmentEndDate = date.valueOf(workorder.FFA_RequestedAppointmentEndDate__c);
                        checkReqApointmentEndDates = checkReqAppointmentEndDate;
                        system.debug(checkReqApointmentEndDates);
                    }
                    
                    system.debug('Checking Date value for Emergency Flag==='+checkReqApointmentdates+'==='+System.today()); 
                    if(checkReqApointmentdates!=null && checkReqApointmentdates==System.date.today()){
                        system.debug('checkReqApointmentdate==='+checkReqApointmentdates);
                        workorder.FFA_EmergencyFlag__c=True;
                        system.debug('Checkinnn ==='+workorder.FFA_EmergencyFlag__c);
                    }
                    workorder.Sync_status__c = 'Pending';
                    if(workorder.FFA_UnplannedPolicyEndDate__c!=null){
                        workorder.FFA_UnplannedPolicyEndDate__c = Datetime.newInstance(workorder.FFA_UnplannedPolicyEndDate__c.year(), workorder.FFA_UnplannedPolicyEndDate__c.Month(), workorder.FFA_UnplannedPolicyEndDate__c.Day(), 23, 59, 00);
                    }
                    System.debug(workorder.FFA_UnplannedPolicyStartDate__c);
                    System.debug(workorder.FFA_UnplannedPolicyEndDate__c);
                    //system.debug('workorder.FFA_SiteID__c====='+wc.newSiteRecord.Id);
                    update workorder; //Write some validation here
                    FFA_Constants.WorkOrderIdsForAsset = workorder.Id;
                    ServiceAppointment sa = new ServiceAppointment();
                    System.debug('before workorder.FFA_RequestedAppointmentDate__c: '+workorder.FFA_RequestedAppointmentDate__c);
                    System.debug('before workorder.FFA_RequestedAppointmentEndDate__c: '+workorder.FFA_RequestedAppointmentEndDate__c);
                    if(workorder.FFA_RequestedAppointmentDate__c!=null || (workorder.FFA_UnplannedPolicyStartDate__c!=null &&
                                                                           workorder.FFA_UnplannedPolicyEndDate__c!=null)){
                        if(workorder.FFA_UnplannedPolicyStartDate__c!=null && workorder.FFA_UnplannedPolicyEndDate__c!=null){
                            System.debug(workorder.FFA_UnplannedPolicyStartDate__c);
                            System.debug(workorder.FFA_UnplannedPolicyEndDate__c);
                            sa = createServiceAppointment(workorder.FFA_RequestedAppointmentDate__c,workorder.FFA_RequestedAppointmentEndDate__c,
                                                     workorder.FFA_UnplannedPolicyStartDate__c,workorder.FFA_UnplannedPolicyEndDate__c,
                                                     workorder.Id);
                            System.debug('sa: '+sa);
                        }else{
                            if(workorder.FFA_RequestedAppointmentEndDate__c!=null && workorder.FFA_RequestedAppointmentEndDate__c != workorder.FFA_RequestedAppointmentDate__c){
                                System.debug('workorder.FFA_RequestedAppointmentEndDate__c: '+workorder.FFA_RequestedAppointmentEndDate__c);
                                sa = createServiceAppointment(workorder.FFA_RequestedAppointmentDate__c,workorder.FFA_RequestedAppointmentEndDate__c,
                                                         null,null,workorder.Id);
                                System.debug('sa: '+sa);
                            }else{
                                sa = createServiceAppointment(workorder.FFA_RequestedAppointmentDate__c,workorder.FFA_RequestedAppointmentEndDate__c,null,null,workorder.Id);
                                System.debug('sa: '+sa);
                            }
                            
                        }
                    }else{
                        System.debug(workorder.FFA_UnplannedPolicyStartDate__c);
                        System.debug(workorder.FFA_UnplannedPolicyEndDate__c);
                        sa = createServiceAppointment(null,null,workorder.FFA_UnplannedPolicyStartDate__c,workorder.FFA_UnplannedPolicyEndDate__c,workorder.Id);
                        System.debug('sa: '+sa);
                    }
                    System.debug('Final sa from FFACreateInterfaceHandler: '+sa);
                    /*Create New Site & Asset records for the Workorder */
                    if(wc.newJobRecord!= null){
                        /*Create new Site for the Workorder */
                        FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(FFA_Constants.FFA_SITE_RECORD_TYPE);
                        FFA_Site siteBody = (FFA_Site)JSON.deserialize(JSON.serialize(reqPayloadMap.get(FFA_Constants.FFA_SITE_RECORD_TYPE)),FFA_Site.Class);
                        wc.siteMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(siteBody));
                        System.debug('wc.siteMapObject ' +  wc.siteMapObject);
                        System.debug('wc.Job Record ====' +  wc.newJobRecord.FFA_MeterPointReferenceNumber__c);
                        wc.newSiteRecord = CreateNewSiteRecord(wc.newJobRecord,wc.siteMapObject,mappings);
                        System.debug('wc.newSiteRecord===='+wc.newSiteRecord);
                        //TO-DO: Add further Site related validations
                        
                        /*Create new asset records for the Workorder
//Fetch the configured Object Types (such as Meter, Regulator etc.) from Custom MDT settings and do the following
//      1. Serialie JSON body for the object type- fetch the body for the corresponding object type
//      2. Add the above JSON body into a list
//     3. if the JSON body is not null, invoke CreateNewAssets method for further processing */
                        //      
                        for(Record_Type__mdt configObjType: configObjTypes){
                            String recordType = configObjType.MasterLabel;
                            String serializedReqBodyForRecordType = JSON.serialize(reqPayloadMap.get(recordType));
                            System.debug('serializedReqBodyForRecordType is ' + serializedReqBodyForRecordType.length());
                            
                            //serializedReqBodyForRecordTypeList.add(serializedReqBodyForRecordType);
                            if(serializedReqBodyForRecordType.length()>4){
                                List<FFA_NGV_Asset__c> newAssets = CreateNewAssets(wc,reqPayloadMap,serializedReqBodyForRecordType,recordType,ServiceProviderId);
                                if(newAssets.size()==0){
                                    // Failure Response when Assets are not created
                                    CreateResponse('Failure','Assets are not created',serviceNotifNo,operationNo,wc.newJobRecord.WorkOrderNumber,'400',reqPayload);
                                    return;
                                }
                            }
                        }
                    }
                    
                    // Update Site Id in WorkOrder here,
                    if(DsearLookupId!=null){
                        workorder.DSEAR_Lookup__c = DsearLookupId;
                    }
                    workorder.Site__c=wc.newSiteRecord.Id;
                    update workorder;
                    
                    system.debug('update workorder====='+workorder);
                    if(wc.newSiteRecord!=null){
                        list<FFA_Site__c> updateSiteList = [select id,FFA_SP_ID__c from FFA_Site__c where id=:wc.newSiteRecord.Id];
                        if(!updateSiteList.isEmpty()){
                            FFA_site__c sites = updateSiteList[0];
                            sites.Name = workorder.FFA_MeterPointReferenceNumber__c;
                            sites.FFA_SP_ID__c=workorder.FFA_ServiceProvider__c;
                            update sites;
                        }
                    }
                    // success response here after creating work order 
                    CreateResponse('Success','Work Order created Successfully',wc.newJobRecord.FFA_ServiceNotificationNumber__c,wc.newJobRecord.FFA_OperationNumber__c,wc.newJobRecord.WorkOrderNumber,'201',reqPayload);
                    //WHEN WO CREATED ,LATEST SETPOINTS WILL BE CREATED
                    SetpointsforWorkorder(workorder.FFA_MeterPointReferenceNumber__c,workorder.id,wc.newSiteRecord.Id);
                }
            }
          }  
        }catch (Exception e){
            System.debug('Try catch===='+e.getMessage()+'=='+e.getLineNumber());
            string SystemErrorMessage = e.getMessage()+'=='+e.getLineNumber();
            // System Failure response here
            CreateResponse('Failure',SystemErrorMessage,wc.newJobRecord.FFA_ServiceNotificationNumber__c,wc.newJobRecord.FFA_OperationNumber__c,wc.newJobRecord.WorkOrderNumber,'400',reqPayload);
        }
    }
    @testVisible
    static ServiceAppointment createServiceAppointment(DateTime ReqAppointDate,DateTime ReqAppointEndDate, DateTime UnplannedPolicyStartDate,
                                         DateTime UnplannedPolicyEndDate,ID WorkOrderId){
        System.debug('ReqAppointDate: '+ReqAppointDate);
        System.debug('ReqAppointEndDate: '+ReqAppointEndDate);
        System.debug('UnplannedPolicyStartDate: '+UnplannedPolicyStartDate);
        System.debug('UnplannedPolicyEndDate: '+UnplannedPolicyEndDate);
        System.debug('WorkOrderId: '+WorkOrderId);
        list<ServiceAppointment> serviceApList = new list<ServiceAppointment>();
        ServiceTerritory Territory=[Select id,name from ServiceTerritory where name='NG UK Territory' limit 1];
        if(WorkOrderId!=null){
            Workorder relatedWorkorder=[Select id,FFA_ServiceProvider__c from Workorder Where id=:WorkOrderId];
            ServiceAppointment serviceAp = new ServiceAppointment();
            serviceAp.ParentRecordId = WorkOrderId;
            if(ReqAppointDate!=null ){
                //serviceAp.SchedStartTime = ReqAppointDate.addHours(0).addMinutes(0).addSeconds(0);
               // serviceAp.SchedEndTime = ReqAppointDate.addHours(23).addMinutes(59).addSeconds(0);
                serviceAp.SchedStartTime= Datetime.newInstance(ReqAppointDate.year(), ReqAppointDate.Month(), ReqAppointDate.Day(),
                                                               00, 00, 00);
                System.debug('serviceAp.SchedStartTime: '+serviceAp.SchedStartTime);
                if(ReqAppointEndDate!=null){
                    serviceAp.SchedEndTime =Datetime.newInstance(ReqAppointEndDate.year(), ReqAppointEndDate.Month(),
                                                                 ReqAppointEndDate.Day(), 23, 59, 00);
                    System.debug('serviceAp.SchedEndTime: '+serviceAp.SchedEndTime);
                }else{
                    serviceAp.SchedEndTime= Datetime.newInstance(ReqAppointDate.year(), ReqAppointDate.Month(), 
                                                                 ReqAppointDate.Day(), 23, 59, 00);
                    System.debug('serviceAp.SchedEndTime: '+serviceAp.SchedEndTime);
                }
                
            }
            if(UnplannedPolicyStartDate!=null){
                //serviceAp.SchedStartTime = UnplannedPolicyStartDate.addHours(0).addMinutes(0).addSeconds(0);
                serviceAp.SchedStartTime = Datetime.newInstance(UnplannedPolicyStartDate.year(), UnplannedPolicyStartDate.Month(),
                                                                UnplannedPolicyStartDate.Day(), 00, 00, 00);
                system.debug('before SchedStartTime=='+UnplannedPolicyStartDate);
                System.debug('serviceAp.SchedStartTime: '+serviceAp.SchedStartTime);
                
            }
            
            if(UnplannedPolicyEndDate!=null){
                //serviceAp.SchedEndTime = UnplannedPolicyEndDate.addHours(23).addMinutes(59).addSeconds(0);
                serviceAp.SchedEndTime = Datetime.newInstance(UnplannedPolicyEndDate.year(), UnplannedPolicyEndDate.Month(),
                                                              UnplannedPolicyEndDate.Day(), 23, 59, 00);
                System.debug('serviceAp.SchedEndTime: '+serviceAp.SchedEndTime);
                system.debug('before SchedEndTime==='+UnplannedPolicyEndDate);
                system.debug('After SchedEndTime==='+UnplannedPolicyEndDate.addHours(23).addMinutes(59).addSeconds(0));
            }
            serviceAp.Status = 'None';
            if(relatedWorkorder.FFA_ServiceProvider__c!=null){
            serviceAp.FFA_SP_ID__c=relatedWorkorder.FFA_ServiceProvider__c;
            }
            if(Territory!=null){
              serviceAp.ServiceTerritoryId=Territory.id;
            }
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
        return serviceApList[0];
    }
    
    /*Check if mandatory fields are missing or do not have values*/
    @testVisible
    static Boolean isValidatePayLoad (Map<String,Object>m,String SENDERVALUE)
    {
        //TO-DO: Implement necessary logic here
        String JobCodeValue = string.valueOf(m.get('JobCode'));
        String ServiceProviderValue = String.valueOf(m.get('ServiceProvider'));
        string RequestedAppointmentDates = string.valueOf(m.get('RequestedAppointmentDate'));
        string ServiceNotificationNumbers = string.valueOf(m.get('ServiceNotificationNumber'));
        string OperationNumbers;
        if(SENDERVALUE=='RAINBOW'){
            OperationNumbers='';
        }
        else{
            OperationNumbers = string.valueOf(m.get('OperationNumber'));
        }
        string UnplannedPolicyStartDates = string.valueOf(m.get('UnplannedPolicyStartDate'));
        string UnplannedPolicyEndDates = string.valueOf(m.get('UnplannedPolicyEndDate'));
        list<Date> datelist = new list<Date>();
        //System.debug('Mandtory Values for Creating Job === '+JobCodeValue+'=='+ServiceProviderValue+'=='+RequestedAppointmentDates+'=='+ServiceNotificationNumbers+'=='+OperationNumbers);
        if(string.isNotBlank(ServiceNotificationNumbers) && string.isNotBlank(OperationNumbers) && string.isNotBlank(JobCodeValue) 
           && string.isNotBlank(ServiceProviderValue) && (string.isNotBlank(RequestedAppointmentDates) || string.isNotBlank(UnplannedPolicyStartDates) || string.isNotBlank(UnplannedPolicyEndDates) )){
               return true;
           }
           else if(string.isNotBlank(ServiceNotificationNumbers) && SENDERVALUE=='RAINBOW' && string.isNotBlank(JobCodeValue)
           && string.isNotBlank(ServiceProviderValue) && (string.isNotBlank(RequestedAppointmentDates) || string.isNotBlank(UnplannedPolicyStartDates) || string.isNotBlank(UnplannedPolicyEndDates) )){
               return true; 
           }else{
               return false; 
           }
    }
    
    
    static System.RestResponse CreateResponse(string TransactionStatus,string TransactionMessage,string ServiceNotificationNumber,string OperationNumber,string WorkOrderNumber,string HTTP_Status_Code,string payload){
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json;charset=UTF-8');
        FFA_CreateInterfaceModel.SystemResponseWrapper resWrappers = new FFA_CreateInterfaceModel.SystemResponseWrapper();
        resWrappers.TransactionStatus = TransactionStatus;
        resWrappers.TransactionMessage = TransactionMessage;
        resWrappers.ServiceNotificationNumber = ServiceNotificationNumber;
        if(string.isNotBlank(OperationNumber)){
            resWrappers.OperationNumber = OperationNumber;
        }else{
            resWrappers.OperationNumber = '';
        }
        if(string.isNotBlank(WorkOrderNumber)){
            resWrappers.WorkOrderNumber= WorkOrderNumber;
        }else{
            resWrappers.WorkOrderNumber= '';
        }
        resWrappers.HTTP_Status_Code= HTTP_Status_Code;
        res.responseBody=  Blob.valueOf(JSON.serialize(resWrappers)); 
        system.debug('resWrap---'+JSON.serialize(resWrappers));
        res.responseBody=  Blob.valueOf(JSON.serialize(resWrappers));
        FFA_Interface_Runs__c InterfaceLogs = new FFA_Interface_Runs__c(Interface_Name__c='/FFACreateInterface',Transaction_Message__c=JSON.serialize(resWrappers), Transaction_Status__c = TransactionStatus);
        insert InterfaceLogs;
        Blob payLoadBlob = Blob.valueOf(payload);
        CreateHttpResponseFile(payLoadBlob,InterfaceLogs.id);
        return res;
             
    }
    
    /* For each recordType (Meter, Regulator etc.), do the following
    //     1.  Dynamically fetch the Class Type for each record Type
    //     2.  Get all the SAP Field values & mappings( SAP Field names, FFA Field names) using MDT Mappings
    //     3.  Check if the JSON body is an instance of List(array of objects) or just an object (scalar)
    //          a.  Deserialize the JSON body using deserialze method with type as List<recordTypeClassName> into a List
    //          b. OR if the body is just an object, deserialize using the recordTypeClassName into an object
    //          c. Add the de-serialized body into a List
    //          d. Iterate through the list and do the following
    //             i) Create a Map object by serializig the body- this will be used for dynamically fetching the field values
    //            ii) Invoke Create New Asset Record method passing the record Type, Map object, MDT Mappings     
    */
    @TestVisible
    static List<FFA_NGV_Asset__c> CreateNewAssets(FFA_CreateInterfaceModel.wrapperClass wc, Map<String,Object> originalRequestPayload, String payloadSerializedJSONForRecordType, String recordType,String ServiceProviderIdValue){
        
        // try 
        // {
        //  
        List<FFA_NGV_Asset__c> assets = new List<FFA_NGV_Asset__c>();
        String typeForNameString ='List<'+ recordType + '>';
        Type typ = Type.forName(typeForNameString);
        System.debug('recordtype: ' + recordType);
        if (recordType==FFA_Constants.FFA_VALVES_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            System.debug('mappings: ' + mappings);
            
            List<Valves> bodyValves= new List<Valves>();
            if(originalRequestPayload.get(FFA_Constants.FFA_VALVES_RECORD_TYPE)instanceof List<Object>){
                System.debug('payloadSerializedJSONForRecordType: ' + payloadSerializedJSONForRecordType);
                bodyValves= (List<Valves>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
                System.debug('bodyValves: ' + bodyValves);
            }else{
                Valves bodyValve= (Valves)JSON.deserialize(payloadSerializedJSONForRecordType, Valves.class); 
                System.debug('bodyValve: ' + bodyValve);
                bodyValves.add(bodyValve);
            }
            System.debug('Before List of Valves Loop');
            for(Valves body: bodyValves){
                wc.valveMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.valveMapObject,mappings,ServiceProviderIdValue);
                wc.newAssetRecord.FFA_Asset_Type__c ='Valve';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_SLAMSHUT_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<SlamShut> bodySlamShuts= new List<SlamShut>();
            if (originalRequestPayload.get(FFA_Constants.FFA_SLAMSHUT_RECORD_TYPE)instanceof List<Object>){
                bodySlamShuts= (List<SlamShut>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                SlamShut bodySlamShut= (SlamShut)JSON.deserialize(payloadSerializedJSONForRecordType, SlamShut.class); 
                bodySlamShuts.add(bodySlamShut);
            }
            for(SlamShut body: bodySlamShuts){
                wc.slamShutMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.slamShutMapObject,mappings,ServiceProviderIdValue);
                wc.newAssetRecord.FFA_Asset_Type__c ='Slamshut';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_METER_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<Meter> bodyMeters= new List<Meter>();
            if(originalRequestPayload.get(FFA_Constants.FFA_METER_RECORD_TYPE)instanceof List<Object>){
                bodyMeters= (List<Meter>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                Meter bodyMeter= (Meter)JSON.deserialize(payloadSerializedJSONForRecordType, Meter.class); 
                bodyMeters.add(bodyMeter);
            }
            for(Meter body: bodyMeters){
                wc.meterMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.meterMapObject,mappings,ServiceProviderIdValue);
                system.debug('Adding Meter Record Here ==='+wc.newAssetRecord);
                wc.newAssetRecord.FFA_Asset_Type__c ='Meter';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_FILTER_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<Filters> bodyFilters= new List<Filters>();
            if (originalRequestPayload.get(FFA_Constants.FFA_FILTER_RECORD_TYPE)instanceof List<Object>){
                bodyFilters= (List<Filters>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                Filters bodyFilter= (Filters)JSON.deserialize(payloadSerializedJSONForRecordType, Filters.class); 
                bodyFilters.add(bodyFilter);
            }
            for(Filters body: bodyFilters){
                wc.filterMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.filterMapObject,mappings,ServiceProviderIdValue);
                wc.newAssetRecord.FFA_Asset_Type__c ='Filter';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_CONVERTOR_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<Convertor> bodyConvertors= new List<Convertor>();
            if (originalRequestPayload.get(FFA_Constants.FFA_CONVERTOR_RECORD_TYPE)instanceof List<Object>){
                bodyConvertors= (List<Convertor>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                Convertor bodyConvertor= (Convertor)JSON.deserialize(payloadSerializedJSONForRecordType, Convertor.class); 
                bodyConvertors.add(bodyConvertor);
            }
            for(Convertor body: bodyConvertors){
                wc.convertorMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.convertorMapObject,mappings,ServiceProviderIdValue);
                system.debug('Adding Converter Record Here ==='+wc.newAssetRecord);
                wc.newAssetRecord.FFA_Asset_Type__c ='Converter';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_REGULATOR_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<Regulator> bodyRegulators= new List<Regulator>();
            if (originalRequestPayload.get(FFA_Constants.FFA_REGULATOR_RECORD_TYPE)instanceof List<Object>){
                bodyRegulators= (List<Regulator>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                Regulator bodyRegulator= (Regulator)JSON.deserialize(payloadSerializedJSONForRecordType, Regulator.class); 
                bodyRegulators.add(bodyRegulator);
            }
            for(Regulator body: bodyRegulators){
                wc.regulatorMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.regulatorMapObject,mappings,ServiceProviderIdValue);
                wc.newAssetRecord.FFA_Asset_Type__c ='Regulator';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_FLOWCOMPUTER_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<FlowComputer> bodyFlowComputers= new List<FlowComputer>();
            if (originalRequestPayload.get(FFA_Constants.FFA_FLOWCOMPUTER_RECORD_TYPE)instanceof List<Object>){
                bodyFlowComputers= (List<FlowComputer>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                FlowComputer bodyFlowComputer= (FlowComputer)JSON.deserialize(payloadSerializedJSONForRecordType, FlowComputer.class); 
                bodyFlowComputers.add(bodyFlowComputer);
            }
            for(FlowComputer body: bodyFlowComputers){
                wc.flowComputerMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.flowComputerMapObject,mappings,ServiceProviderIdValue);
                system.debug('Adding Flow Computer Record Here ==='+wc.newAssetRecord);
                wc.newAssetRecord.FFA_Asset_Type__c ='Flow Computer';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_CREEPRELIEF_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<CreepRelief> bodyCreepReliefs= new List<CreepRelief>();
            if (originalRequestPayload.get(FFA_Constants.FFA_CREEPRELIEF_RECORD_TYPE)instanceof List<Object>){
                bodyCreepReliefs= (List<CreepRelief>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                CreepRelief bodyCreepRelief= (CreepRelief)JSON.deserialize(payloadSerializedJSONForRecordType, CreepRelief.class); 
                bodyCreepReliefs.add(bodyCreepRelief);
            }
            for(CreepRelief body: bodyCreepReliefs){
                wc.creepReliefMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.creepReliefMapObject,mappings,ServiceProviderIdValue);
                wc.newAssetRecord.FFA_Asset_Type__c ='Creep Relief';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_AUXRELIEF_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<AuxillaryRelief> bodyAuxillaryReliefs= new List<AuxillaryRelief>();
            if (originalRequestPayload.get(FFA_Constants.FFA_AUXRELIEF_RECORD_TYPE)instanceof List<Object>){
                bodyAuxillaryReliefs= (List<AuxillaryRelief>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                AuxillaryRelief bodyAuxillaryRelief= (AuxillaryRelief)JSON.deserialize(payloadSerializedJSONForRecordType, AuxillaryRelief.class); 
                bodyAuxillaryReliefs.add(bodyAuxillaryRelief);
            }
            for(AuxillaryRelief body: bodyAuxillaryReliefs){
                wc.auxillaryReliefMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.auxillaryReliefMapObject,mappings,ServiceProviderIdValue);
                wc.newAssetRecord.FFA_Asset_Type__c ='Auxillary Relief';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_AUXCONTROL_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<AuxillaryControl> bodyAuxillaryControls= new List<AuxillaryControl>();
            if (originalRequestPayload.get(FFA_Constants.FFA_AUXCONTROL_RECORD_TYPE)instanceof List<Object>){
                bodyAuxillaryControls= (List<AuxillaryControl>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                AuxillaryControl bodyAuxillaryControl= (AuxillaryControl)JSON.deserialize(payloadSerializedJSONForRecordType, AuxillaryControl.class); 
                bodyAuxillaryControls.add(bodyAuxillaryControl);
            }
            for(AuxillaryControl body: bodyAuxillaryControls){
                wc.auxillaryControlMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.auxillaryControlMapObject,mappings,ServiceProviderIdValue);
                wc.newAssetRecord.FFA_Asset_Type__c ='Auxillary Control';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_BOILER_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<Boiler> bodyBoilers= new List<Boiler>();
            if (originalRequestPayload.get(FFA_Constants.FFA_BOILER_RECORD_TYPE)instanceof List<Object>){
                bodyBoilers= (List<Boiler>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                Boiler bodyBoiler= (Boiler)JSON.deserialize(payloadSerializedJSONForRecordType, Boiler.class); 
                bodyBoilers.add(bodyBoiler);
            }
            for(Boiler body: bodyBoilers){
                wc.boilerMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.boilerMapObject,mappings,ServiceProviderIdValue);
                wc.newAssetRecord.FFA_Asset_Type__c ='Boiler';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_CHROMATOGRAPH_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<Chromatograph> bodyChromatographs= new List<Chromatograph>();
            if (originalRequestPayload.get(FFA_Constants.FFA_CHROMATOGRAPH_RECORD_TYPE)instanceof List<Object>){
                bodyChromatographs= (List<Chromatograph>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                Chromatograph bodyChromatograph= (Chromatograph)JSON.deserialize(payloadSerializedJSONForRecordType, Chromatograph.class); 
                bodyChromatographs.add(bodyChromatograph);
            }
            for(Chromatograph body: bodyChromatographs){
                wc.chromatographMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.chromatographMapObject,mappings,ServiceProviderIdValue);
                wc.newAssetRecord.FFA_Asset_Type__c ='Chromatograph';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_DENSITOMETER_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<Densitometer> bodyDensitometers= new List<Densitometer>();
            if (originalRequestPayload.get(FFA_Constants.FFA_DENSITOMETER_RECORD_TYPE)instanceof List<Object>){
                bodyDensitometers= (List<Densitometer>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                Densitometer bodyDensitometer= (Densitometer)JSON.deserialize(payloadSerializedJSONForRecordType, Densitometer.class); 
                bodyDensitometers.add(bodyDensitometer);
            }
            for(Densitometer body: bodyDensitometers){
                wc.densitometerMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.densitometerMapObject,mappings,ServiceProviderIdValue);
                wc.newAssetRecord.FFA_Asset_Type__c ='Densitometer';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_PIPEWORK_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<Pipework> bodyPipeworks= new List<Pipework>();
            if(originalRequestPayload.get(FFA_Constants.FFA_PIPEWORK_RECORD_TYPE)instanceof List<Object>){
                bodyPipeworks= (List<Pipework>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                Pipework bodyPipework= (Pipework)JSON.deserialize(payloadSerializedJSONForRecordType, Pipework.class); 
                bodyPipeworks.add(bodyPipework);
            }
            for(Pipework body: bodyPipeworks){
                wc.pipeworkMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.pipeworkMapObject,mappings,ServiceProviderIdValue);
                wc.newAssetRecord.FFA_Asset_Type__c ='Pipework';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_CATHODICPROTECTION_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<CathodicProtection> bodyCathodicProtections= new List<CathodicProtection>();
            if(originalRequestPayload.get(FFA_Constants.FFA_CATHODICPROTECTION_RECORD_TYPE)instanceof List<Object>){
                bodyCathodicProtections= (List<CathodicProtection>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                CathodicProtection bodyCathodicProtection= (CathodicProtection)JSON.deserialize(payloadSerializedJSONForRecordType, CathodicProtection.class); 
                bodyCathodicProtections.add(bodyCathodicProtection);
            }
            for(CathodicProtection body: bodyCathodicProtections){
                wc.cathodicProtectionMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.CathodicProtectionMapObject,mappings,ServiceProviderIdValue);
                wc.newAssetRecord.FFA_Asset_Type__c ='Cathodic Protection';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_WATERBATHHEATER_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<WaterBathHeaters> bodyWaterBathHeaters= new List<WaterBathHeaters>();
            if (originalRequestPayload.get(FFA_Constants.FFA_WATERBATHHEATER_RECORD_TYPE)instanceof List<Object>){
                bodyWaterBathHeaters= (List<WaterBathHeaters>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                WaterBathHeaters bodyWaterBathHeater= (WaterBathHeaters)JSON.deserialize(payloadSerializedJSONForRecordType, WaterBathHeaters.class); 
                bodyWaterBathHeaters.add(bodyWaterBathHeater);
            }
            for(WaterBathHeaters body: bodyWaterBathHeaters){
                wc.waterBathHeaterMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.waterBathHeaterMapObject,mappings,ServiceProviderIdValue);
                wc.newAssetRecord.FFA_Asset_Type__c ='Water Bath Heater';
                assets.add(wc.newAssetRecord); 
            }
        }else if(recordType==FFA_Constants.FFA_SHELLANDTUBE_RECORD_TYPE){ 
            FFA_Integration_Mappings__mdt[] mappings = GetFieldMappings(recordType);
            List<ShellandTube> bodyShellandTubes= new List<ShellandTube>();
            if (originalRequestPayload.get(FFA_Constants.FFA_SHELLANDTUBE_RECORD_TYPE)instanceof List<Object>){
                bodyShellandTubes= (List<ShellandTube>)JSON.deserialize(payloadSerializedJSONForRecordType, typ); 
            }else{
                ShellandTube bodyShellandTube= (ShellandTube)JSON.deserialize(payloadSerializedJSONForRecordType, ShellandTube.class); 
                bodyShellandTubes.add(bodyShellandTube);
            }
            for(ShellandTube body: bodyShellandTubes){
                wc.shellandTubeMapObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(body));
                wc.newAssetRecord = CreateNewAssetRecord(wc.newJobRecord,recordType,wc.shellandTubeMapObject,mappings,ServiceProviderIdValue);
                wc.newAssetRecord.FFA_Asset_Type__c ='Shell & Tube';
                assets.add(wc.newAssetRecord); 
            }
        }  
        
        Database.SaveResult[] srList = Database.insert(assets,false);
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
        // } 
        
        // catch (Exception err) {
        //   return false;  
        // }
        return assets;
    }
    
    /*Get MDT Field values for each record Type*/ 
    static FFA_Integration_Mappings__mdt[] GetFieldMappings(String recordType){
        //To-DO query all mappings once and then cache them into a map for later use
        FFA_Integration_Mappings__mdt[] mappings = Database.query('Select SAP_Field_Name__c,FFA_Field_Name__c,FFA_Data_Type__c from FFA_Integration_Mappings__mdt where RecordType__c= :recordType');
        return mappings;
    }
    
    /*Method to create new Asset Record- this method just returns an instance of the FFA_NGV_Asset__c object- 
actual record creation happens in bulk in the calling method*/
   @TestVisible
    static FFA_NGV_Asset__c CreateNewAssetRecord(Workorder workorder, String recordType,Map<String,Object> m,FFA_Integration_Mappings__mdt[] mappings,string ServiceProviderId){
        FFA_CreateInterfaceModel.wrapperClass wc = new FFA_CreateInterfaceModel.wrapperClass();
        FFA_NGV_Asset__c newAsset = new FFA_NGV_Asset__c();
        system.debug('Work Order ID for the Assets ==='+workorder);
        for (FFA_Integration_Mappings__mdt mapping: mappings)
        {
            try{
                String sapFieldName= mapping.SAP_Field_Name__c;
                String ffaFieldName= mapping.FFA_Field_Name__c;
                String ffaFieldDataType = mapping.FFA_Data_Type__c;
                
                if(ffaFieldDataType==FFA_Constants.STRING_DATA_TYPE){
                    string sapFieldValueStr = string.valueOf(m.get(sapFieldName));
                    if(String.isNotBlank(sapFieldValueStr)){
                        newAsset.put(ffaFieldName,sapFieldValueStr);
                    }
                    System.debug('String Value ===='+ffaFieldName+'==='+sapFieldValueStr);
                }
                
                if(ffaFieldDataType==FFA_Constants.NUMBER_DATA_TYPE && sapFieldName != 'Qmax'){
                    Integer sapFieldValueInt = Integer.valueOf(m.get(sapFieldName));
                    if(sapFieldValueInt!=null){
                        newAsset.put(ffaFieldName,sapFieldValueInt);
                    }
                    System.debug('String Value ===='+ffaFieldName+'==='+sapFieldValueInt);
                }
                
                //Req13-qmax value population if it cames from SAP
                if(ffaFieldDataType == FFA_Constants.NUMBER_DATA_TYPE && sapFieldName == 'Qmax' && m.containsKey(sapFieldName)){
					Integer sapFieldValueInt = Integer.valueOf(m.get(sapFieldName));
					if(sapFieldValueInt != NULL){
						newAsset.put(ffaFieldName,sapFieldValueInt);
					}
					System.debug('qmax Value ===='+ffaFieldName+'==='+sapFieldValueInt);
				}
                
                
                if(ffaFieldDataType==FFA_Constants.DATE_DATA_TYPE){
                    string strdate = string.valueOf(m.get(sapFieldName));
                    system.debug('Checking dare Format=='+strdate);
                    Date sapFieldValueDateTime;
                    //Date sapFieldValueDateTimeOne;
                    if(String.isNotBlank(strdate)){
                        sapFieldValueDateTime = date.valueOf(strdate);
                        system.debug('Checking dare Format=='+sapFieldValueDateTime);
                        //sapFieldValueDateTimeOne = date.valueOf(sapFieldValueDateTime);
                    }
                    if(sapFieldValueDateTime!=null){
                        newAsset.put(ffaFieldName,sapFieldValueDateTime);
                    }
                    System.debug('String Value ===='+ffaFieldName+'==='+sapFieldValueDateTime);
                }
                newAsset.Work_Order__c = workorder.Id;
                if(string.isNotBlank(ServiceProviderId)){
                 newAsset.FFA_SP_ID__c = ServiceProviderId;
                }
            }catch(Exception e){
                System.debug('Try catch===='+e.getMessage()+'=='+e.getLineNumber());
            }
        }
        wc.newAssetRecord = newAsset;
        return wc.newAssetRecord ;
    }
    
    /*Method to create new Workorder record*/
    @TestVisible
    static WorkOrder createNewWORecord(Map<String,Object> m,Map<String,Object> o, String sender, list<FFA_Integration_Mappings__mdt> mappings){
        FFA_CreateInterfaceModel.wrapperClass wc = new FFA_CreateInterfaceModel.wrapperClass();
        WorkOrder newWorkOrder = new WorkOrder();
        system.debug('MAp---'+mappings);
		system.debug('m: '+m) ;  
        system.debug('o: '+o) ;  
        system.debug('sender: '+sender) ;  
        // Get Job code from Work Type object
        string WorktypeJobecode;
        WorktypeJobecode = string.valueOf(m.get('JobCode'));
        list<WorkType> wot=[Select id,name,Job_Category__c from WorkType where Name =: WorktypeJobecode limit 1];
        
        // Mapping all JSON values with Workorder fields 
        for (FFA_Integration_Mappings__mdt mapping: mappings)
        {
            
            String sapFieldName= mapping.SAP_Field_Name__c;
            String ffaFieldName= mapping.FFA_Field_Name__c;
            String ffaFieldDataType = mapping.FFA_Data_Type__c;
            
            string serviceProviderName;
            ID getWorkTypeId;
            ID getAccountId;
            
            
            
            if(ffaFieldDataType==FFA_Constants.STRING_DATA_TYPE){
                string sapFieldValueStr = string.valueOf(m.get(sapFieldName));
                if(String.isNotBlank(sapFieldValueStr)){
                    newWorkOrder.put(ffaFieldName,sapFieldValueStr);
                }
                System.debug('String Value ===='+ffaFieldName+'==='+sapFieldValueStr);
                if(!wot.isEmpty()){
                    getWorkTypeId = wot[0].id;
                    if(getWorkTypeId!=null){
                        newWorkOrder.WorkTypeId = getWorkTypeId;
                        //newWorkOrder.Job_Category__c = wot[0].Job_Category__c!='' ? wot[0].Job_Category__c:'';
                    }
                }
                
                serviceProviderName = string.valueOf(m.get('ServiceProvider'));
                list<Account> acc = [select Id, Name from Account where Name =: serviceProviderName limit 1];
                if(!acc.isEmpty()){
                    getAccountId=acc[0].Id;
                    if(getAccountId!=null){
                        newWorkOrder.Service_Provider__c = getAccountId;
                    }
                }
            }
            if(ffaFieldDataType==FFA_Constants.NUMBER_DATA_TYPE){
                Integer sapFieldValueInt = Integer.valueOf(m.get(sapFieldName))!=null ? Integer.valueOf(m.get(sapFieldName)):null;
                if(sapFieldValueInt!=null){
                    newWorkOrder.put(ffaFieldName,sapFieldValueInt);
                }
            }
            if(ffaFieldDataType==FFA_Constants.DECIMAL_DATA_TYPE){
                system.debug('Decimal Value === '+string.valueOf(m.get(sapFieldName)));
                decimal sapFieldValueDec = decimal.valueOf(string.valueOf(m.get(sapFieldName)))!=null ? decimal.valueOf(string.valueOf(m.get(sapFieldName))):null;
                if(sapFieldValueDec!=null){
                    newWorkOrder.put(ffaFieldName,sapFieldValueDec);
                }
            }
            if(ffaFieldDataType==FFA_Constants.DATETIME_DATA_TYPE){
                string strdate = string.valueOf(m.get(sapFieldName));
                if(string.isNotBlank(strdate)){
                    DateTime sapFieldValueDateTime = date.valueOf(strdate);
                    System.debug(sapFieldValueDateTime);
                    if(sapFieldValueDateTime!=null){
                        newWorkOrder.put(ffaFieldName,Datetime.newInstance(sapFieldValueDateTime.year(), sapFieldValueDateTime.Month(), sapFieldValueDateTime.Day(), 00, 00, 00));
                    }
                }
            }
        }
        newWorkOrder.Status='New';  // Update by Ankit -- 19/08/2019 according the requirement
        System.debug('Job: '+ m);
        System.debug('AMR Flag: '+ m.get('AMRFlag'));
        System.debug('Microbusiness: '+ m.get('Microbusiness'));
        System.debug('FaultReason: '+ m.get('FaultReason'));
        
        newWorkOrder.NGMCP_Service_Request_Number__c = String.isNotBlank(string.valueOf(m.get('ServiceRequestnum'))) ? string.valueOf(m.get('ServiceRequestnum')):'';
        newWorkOrder.NGMCP_AMR_Flag__c = m.get('AMRFlag') != null ? (Boolean) m.get('AMRFlag') : false;
        newWorkOrder.NGMCP_FaultReason__c = String.isNotBlank(string.valueOf(m.get('FaultReason'))) ? string.valueOf(m.get('FaultReason')):'';
        newWorkOrder.NGMCP_Microbusiness__c = m.get('Microbusiness') != null && m.get('Microbusiness') == true ? 'Yes' : m.get('Microbusiness') != null && m.get('Microbusiness') == false ? 'No' : '';
        newWorkOrder.NGMCP_Building_Number__c = String.isNotBlank(string.valueOf(o.get('BuildingNumber'))) ? string.valueOf(o.get('BuildingNumber')):'';
        newWorkOrder.NGMCP_Building_Name__c = String.isNotBlank(string.valueOf(o.get('BuildingName'))) ? string.valueOf(o.get('BuildingName')):'';
        newWorkOrder.NGMCP_Sub_Building_Name__c = String.isNotBlank(string.valueOf(o.get('SubBuildingName'))) ? string.valueOf(o.get('SubBuildingName')):'';
        newWorkOrder.NGMCP_Principal_Street__c = String.isNotBlank(string.valueOf(o.get('PrincipalStreet'))) ? string.valueOf(o.get('PrincipalStreet')):'';
        newWorkOrder.NGMCP_Dependent_Street__c = String.isNotBlank(string.valueOf(o.get('DependentStreet'))) ? string.valueOf(o.get('DependentStreet')):'';
        newWorkOrder.NGMCP_Dependent_Locality__c = String.isNotBlank(string.valueOf(o.get('DependentLocality'))) ? string.valueOf(o.get('DependentLocality')):'';
        newWorkOrder.NGMCP_Double_Dependant_Locality__c = String.isNotBlank(string.valueOf(o.get('DoubleDependantLocality'))) ? string.valueOf(o.get('DoubleDependantLocality')):'';
        newWorkOrder.NGMCP_Post_Town__c = String.isNotBlank(string.valueOf(o.get('PostTown'))) ? string.valueOf(o.get('PostTown')):'';
        newWorkOrder.NGMCP_Postcode_Outcode__c = String.isNotBlank(string.valueOf(o.get('PostcodeOutcode'))) ? string.valueOf(o.get('PostcodeOutcode')):'';
        newWorkOrder.NGMCP_Postcode_Incode__c = String.isNotBlank(string.valueOf(o.get('PostcodeIncode'))) ? string.valueOf(o.get('PostcodeIncode')):'';
        String notificationType = String.isNotBlank(string.valueOf(m.get('NotificationType'))) ? string.valueOf(m.get('NotificationType')):'';
        String slot = String.isNotBlank(string.valueOf(m.get('RequestedAppointmentTimeslot'))) ? string.valueOf(m.get('RequestedAppointmentTimeslot')):'';
        if(String.isNotBlank(sender)){
            FFAServiceAppointmentSlots__mdt appointmentSlot = [SELECT ID,SenderID__c,Slot__c,StartTime__c,EndTime__c,Hours__c,Notification_Type__c
            FROM FFAServiceAppointmentSlots__mdt 
            where SenderID__c =: sender AND
            Notification_Type__c =: notificationType AND
            Slot__c =: slot
            LIMIT 1];
            System.debug('notificationType: '+notificationType);
            System.debug('appointmentSlot: '+appointmentSlot);
            System.debug('before newWorkOrder.FFA_RequestedAppointmentDate__c: '+newWorkOrder.FFA_RequestedAppointmentDate__c);
            System.debug('before newWorkOrder.FFA_RequestedAppointmentEndDate__c: '+newWorkOrder.FFA_RequestedAppointmentEndDate__c);
            System.debug('before newWorkOrder.FFA_UnplannedPolicyStartDate__c: '+newWorkOrder.FFA_UnplannedPolicyStartDate__c);
            System.debug('before newWorkOrder.FFA_UnplannedPolicyEndDate__c: '+newWorkOrder.FFA_UnplannedPolicyEndDate__c);
            if(String.isNotBlank(appointmentSlot.Slot__c)){
                System.debug('Inside appointmentSlot slot if: ');
                String[] FFASlotTimesStart    = appointmentSlot.StartTime__c.split(':');
                String[] FFASlotTimesEnd    = appointmentSlot.EndTime__c.split(':');
                String SchStartDateHours=FFASlotTimesStart[0];
                String SchStartDateMins=FFASlotTimesStart[1];
                String SchEndDateHours=FFASlotTimesEnd[0];
                String SchEndDateMins=FFASlotTimesEnd[1];
                newWorkOrder.NGMCP_Scheduled_Start__c = newWorkOrder.FFA_RequestedAppointmentDate__c != null ? Datetime.newInstance(Integer.valueof(newWorkOrder.FFA_RequestedAppointmentDate__c.year()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentDate__c.month()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentDate__c.day()), Integer.valueof(SchStartDateHours), Integer.valueof(SchStartDateMins), 00) : null;
                newWorkOrder.NGMCP_Scheduled_End__c = newWorkOrder.FFA_RequestedAppointmentEndDate__c != null ? Datetime.newInstance(Integer.valueof(newWorkOrder.FFA_RequestedAppointmentEndDate__c.year()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentEndDate__c.month()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentEndDate__c.day()), Integer.valueof(SchEndDateHours), Integer.valueof(SchEndDateMins), 00) : null;
                System.debug('Inside appointmentSlot slot if: '+newWorkOrder.NGMCP_Scheduled_Start__c);
                System.debug('Inside appointmentSlot slot if: '+newWorkOrder.NGMCP_Scheduled_End__c);
            }
            else{
                if(notificationType == 'Y3' || notificationType == 'Z4'){
                    System.debug('Inside appointmentSlot slot else - y3/z4: ');
                    String[] FFAHour=newWorkOrder.FFA_RequestCreatedTime__c.split(':');
                    Integer FinalHours=Integer.valueof(FFAHour[0])+Integer.valueof(appointmentSlot.Hours__c);
                    newWorkOrder.NGMCP_Scheduled_Start__c = newWorkOrder.FFA_RequestedAppointmentDate__c != null ? Datetime.newInstance(Integer.valueof(newWorkOrder.FFA_RequestedAppointmentDate__c.year()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentDate__c.month()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentDate__c.day()), Integer.valueof(FFAHour[0]), Integer.valueof(FFAHour[1]), 00) : null;
                    newWorkOrder.NGMCP_Scheduled_End__c  = newWorkOrder.FFA_RequestedAppointmentEndDate__c != null ? Datetime.newInstance(Integer.valueof(newWorkOrder.FFA_RequestedAppointmentEndDate__c.year()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentEndDate__c.month()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentEndDate__c.day()), Integer.valueof(FinalHours), Integer.valueof(FFAHour[1]), 00) : newWorkOrder.FFA_RequestCreatedDate__c != null ? Datetime.newInstance(Integer.valueof(newWorkOrder.FFA_RequestCreatedDate__c.year()), Integer.valueof(newWorkOrder.FFA_RequestCreatedDate__c.month()), Integer.valueof(newWorkOrder.FFA_RequestCreatedDate__c.day()), Integer.valueof(FinalHours), Integer.valueof(FFAHour[1]), 00) : null;
                	System.debug('Inside appointmentSlot slot else - y3/z4: '+newWorkOrder.NGMCP_Scheduled_Start__c);
                	System.debug('Inside appointmentSlot slot else - y3/z4: '+newWorkOrder.NGMCP_Scheduled_End__c);
                }
                else{
                    System.debug('Inside appointmentSlot slot else - not y3/z4: ');
                    if(newWorkOrder.FFA_UnplannedPolicyStartDate__c != null && newWorkOrder.FFA_UnplannedPolicyEndDate__c != null){
                        String dateTimeStart =newWorkOrder.FFA_UnplannedPolicyStartDate__c.format('HH:mm:ss');
                        String dateTimeEnd =newWorkOrder.FFA_UnplannedPolicyEndDate__c.format('HH:mm:ss');
                        String[] FFAHourStart=dateTimeStart.split(':');
                        String[] FFAHourEnd=dateTimeEnd.split(':');
                        //Integer FinalHours=Integer.valueof(FFAHour[0])+Integer.valueof(appointmentSlot.Hours__c);
                        newWorkOrder.NGMCP_Scheduled_Start__c = newWorkOrder.FFA_UnplannedPolicyStartDate__c != null ? Datetime.newInstance(Integer.valueof(newWorkOrder.FFA_UnplannedPolicyStartDate__c.year()), Integer.valueof(newWorkOrder.FFA_UnplannedPolicyStartDate__c.month()), Integer.valueof(newWorkOrder.FFA_UnplannedPolicyStartDate__c.day()), Integer.valueof(FFAHourStart[0]), Integer.valueof(FFAHourStart[1]), 00) : null;
                        newWorkOrder.NGMCP_Scheduled_End__c  = newWorkOrder.FFA_UnplannedPolicyEndDate__c != null ? Datetime.newInstance(Integer.valueof(newWorkOrder.FFA_UnplannedPolicyEndDate__c.year()), Integer.valueof(newWorkOrder.FFA_UnplannedPolicyEndDate__c.month()), Integer.valueof(newWorkOrder.FFA_UnplannedPolicyEndDate__c.day()),23,59, 00) : null;
                        System.debug('Inside appointmentSlot slot else - not y3/z4: '+newWorkOrder.NGMCP_Scheduled_Start__c);
                        System.debug('Inside appointmentSlot slot else - not y3/z4: '+newWorkOrder.NGMCP_Scheduled_End__c);
                    }
                    else if(newWorkOrder.FFA_RequestedAppointmentEndDate__c != null){
                       	newWorkOrder.NGMCP_Scheduled_Start__c = newWorkOrder.FFA_RequestedAppointmentDate__c != null ? Datetime.newInstance(Integer.valueof(newWorkOrder.FFA_RequestedAppointmentDate__c.year()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentDate__c.month()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentDate__c.day()),00,00, 00) : null;
                        newWorkOrder.NGMCP_Scheduled_End__c  = newWorkOrder.FFA_RequestedAppointmentEndDate__c != null ? Datetime.newInstance(Integer.valueof(newWorkOrder.FFA_RequestedAppointmentEndDate__c.year()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentEndDate__c.month()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentEndDate__c.day()),23,59, 00) : null;
                        System.debug('Inside appointmentSlot slot else if: '+newWorkOrder.NGMCP_Scheduled_Start__c);
                        System.debug('Inside appointmentSlot slot else if: '+newWorkOrder.NGMCP_Scheduled_End__c); 
                    }
                    else{
                       	newWorkOrder.NGMCP_Scheduled_Start__c = newWorkOrder.FFA_RequestedAppointmentDate__c != null ? Datetime.newInstance(Integer.valueof(newWorkOrder.FFA_RequestedAppointmentDate__c.year()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentDate__c.month()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentDate__c.day()),00,00, 00) : null;
                        newWorkOrder.NGMCP_Scheduled_End__c  = newWorkOrder.FFA_RequestedAppointmentDate__c != null ? Datetime.newInstance(Integer.valueof(newWorkOrder.FFA_RequestedAppointmentDate__c.year()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentDate__c.month()), Integer.valueof(newWorkOrder.FFA_RequestedAppointmentDate__c.day()),23,59, 00) : null;
                        System.debug('Inside appointmentSlot slot else: '+newWorkOrder.NGMCP_Scheduled_Start__c);
                        System.debug('Inside appointmentSlot slot else: '+newWorkOrder.NGMCP_Scheduled_End__c); 
                    }
                }
            }
        }
        system.debug('newWorkOrder--->'+newWorkOrder);   
        
        Database.SaveResult sr = Database.insert(newWorkOrder,false);
        if (sr.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug('Successfully inserted record. Record ID: ' + sr.getId());
            wc.newJobRecord = [Select WorkOrderNumber,FFA_ServiceNotificationNumber__c,FFA_OperationNumber__c,FFA_MeterPointReferenceNumber__c, NGMCP_Service_Request_Number__c,
            NGMCP_Building_Number__c,NGMCP_Building_Name__c,NGMCP_Sub_Building_Name__c,NGMCP_Principal_Street__c,NGMCP_Dependent_Street__c,NGMCP_Dependent_Locality__c,
            NGMCP_Double_Dependant_Locality__c,NGMCP_Post_Town__c,NGMCP_Postcode_Outcode__c,NGMCP_Postcode_Incode__c, NGMCP_AMR_Flag__c
            from WorkOrder where Id=:sr.getId()];
            System.debug('wc.newJobRecord ' + wc.newJobRecord);
        }
        else {
            // Operation failed, so get all errors                
            for(Database.Error err : sr.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('fields that affected this error: ' + err.getFields()); 
                wc.newJobRecord = null;
            }
        }
        return wc.newJobRecord ;
    }
    
    /*Method to create new Site record*/
   /* static FFA_Site__c CreateNewSiteRecord(WorkOrder workorder, Map<String,Object> m,FFA_Integration_Mappings__mdt[] mappings){
        system.debug('WorkOrder===='+workorder);
        try{
            FFA_CreateInterfaceModel.wrapperClass wc = new FFA_CreateInterfaceModel.wrapperClass();
           
   // 1) Try to reuse an existing Site by Name = MPRN
        FFA_Site__c siteRec;
        String mprn = (workorder != null) ? workorder.FFA_MeterPointReferenceNumber__c : null;

        if (String.isNotBlank(mprn)) {
            List<FFA_Site__c> existing = [
                SELECT Id, Name
                FROM FFA_Site__c
                WHERE Name = :mprn
                WITH SECURITY_ENFORCED
                LIMIT 1
                
            ];
            if (!existing.isEmpty()) {
                siteRec = existing[0]; // Reuse existing Site

     }
        }

        // 2) If not found, create a new Site
        if (siteRec == null) {
            siteRec = new FFA_Site__c();
        }

        // 3) Map incoming fields from MDT (this will update existing or set for new)

 for (FFA_Integration_Mappings__mdt mapping: mappings) {
            String sapFieldName   = mapping.SAP_Field_Name__c;
            String ffaFieldName   = mapping.FFA_Field_Name__c;
            String ffaFieldType   = mapping.FFA_Data_Type__c;
                
            if (ffaFieldType == FFA_Constants.STRING_DATA_TYPE) {
                String val = String.valueOf(m.get(sapFieldName));

   if (String.isNotBlank(val)) {
                    siteRec.put(ffaFieldName, val);
                    }
                }
            }

        // 4) Ensure Name = MPRN (your convention)
        if (String.isNotBlank(mprn)) {
            siteRec.Name = mprn;
        }


        if (siteRec.Id == null) {
            insert siteRec;
        } else {
            update siteRec;
        }

        wc.newSiteRecord = siteRec;
            return wc.newSiteRecord;

    } catch (Exception e) {
        System.debug('CreateNewSiteRecord error: ' + e.getMessage() + ' line ' + e.getLineNumber());
            return null;
        }
    }   
*/    
@testVisible
static FFA_Site__c CreateNewSiteRecord(
    WorkOrder workorder,
    Map<String, Object> m,
    FFA_Integration_Mappings__mdt[] mappings
) {
    try {

        FFA_CreateInterfaceModel.wrapperClass wc =
            new FFA_CreateInterfaceModel.wrapperClass();

        // 1) Try to reuse existing Site by MPRN
        FFA_Site__c siteRec;
        String mprn = (workorder != null)
            ? workorder.FFA_MeterPointReferenceNumber__c
            : null;

        if (String.isNotBlank(mprn)) {
            List<FFA_Site__c> existing = [
                SELECT Id, Name
                FROM FFA_Site__c
                WHERE Name = :mprn
                LIMIT 1
            ];
            if (!existing.isEmpty()) {
                siteRec = existing[0];
            }
        }

        // 2) Determine create vs update
        Boolean isNewSite = false;

        if (siteRec == null) {
            if (!Schema.sObjectType.FFA_Site__c.isCreateable()) {
                System.debug('No create access to FFA_Site__c');
                return null;
            }
            siteRec = new FFA_Site__c();
            isNewSite = true;
        } else {
            if (!Schema.sObjectType.FFA_Site__c.isUpdateable()) {
                System.debug('No update access to FFA_Site__c');
                return siteRec;
            }
        }

        // 3) SAFE field mapping with FLS checks
        Map<String, Schema.SObjectField> fieldMap =
            Schema.SObjectType.FFA_Site__c.fields.getMap();

        for (FFA_Integration_Mappings__mdt mapping : mappings) {
            String sapFieldName = mapping.SAP_Field_Name__c;
            String ffaFieldName = mapping.FFA_Field_Name__c;

            if (
                String.isBlank(ffaFieldName) ||
                !fieldMap.containsKey(ffaFieldName) ||
                !m.containsKey(sapFieldName)
            ) {
                continue;
            }

            Object val = m.get(sapFieldName);
            if (val == null) continue;

            Schema.DescribeFieldResult d =
                fieldMap.get(ffaFieldName).getDescribe();

            // Respect Create vs Update permission at FIELD LEVEL
            if (
                (isNewSite && d.isCreateable()) ||
                (!isNewSite && d.isUpdateable())
            ) {
if (d.getType() == Schema.DisplayType.String ||
    d.getType() == Schema.DisplayType.TextArea ||
    d.getType() == Schema.DisplayType.Picklist||
	d.getType() == Schema.DisplayType.Phone) {

    siteRec.put(ffaFieldName, String.valueOf(val));
}

            }
        }

        // 4) Ensure Name = MPRN (with FLS check)
        if (
            String.isNotBlank(mprn) &&
            Schema.SObjectType.FFA_Site__c.fields.Name.isCreateable()
        ) {
            siteRec.Name = mprn;
        }

        // 5) DML (guarded)
        if (siteRec.Id == null) {
            insert siteRec;
        } else {
            update siteRec;
        }

        wc.newSiteRecord = siteRec;
        return wc.newSiteRecord;

    } catch (Exception e) {
        System.debug(
            'CreateNewSiteRecord error: ' +
            e.getMessage() +
            ' line ' +
            e.getLineNumber()
        );
        throw e;
    }
}


       
         /*This function will create a File with data of JSON
        //which SAP send and will attached to 
        //Interface run Object related record */
      public static void CreateHttpResponseFile(blob Payload,ID interfaceRunID){
     
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'Workorder.txt'; // The files name, extension is very important here which will help the file in preview.
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
     
     //SetpointsforWorkorder(workorder.FFA_MeterPointReferenceNumber__c,workorder.id,wc.newSiteRecord.Id);
     public static void SetpointsforWorkorder(String SiteMPRN,id Workorderid,id SiteID){
     list<Operational_Settings__c> newOplist=new list<Operational_Settings__c>();
     list<workorder> setPoints=[Select id,createddate,Site__r.id,Site__r.name,
                                      (SELECT ID,Asset_Type__c,Set_Point__c,Stream_No__c,Primary_Function__c,Lockup_Pressure__c from Operational_Settings__r) 
                                      from workorder WHERE Site__r.name=:SiteMPRN order by createddate desc limit 2];
     if(!setPoints.isEmpty()){
                for(workorder relatedsetpointWorkorders:setPoints){
                    if(relatedsetpointWorkorders.Operational_Settings__r!=null){
                        for(Operational_Settings__c opSettings:relatedsetpointWorkorders.Operational_Settings__r){
                            Operational_Settings__c OpSett= new Operational_Settings__c(Asset_Type__c=opSettings.Asset_Type__c,Lockup_Pressure__c=opSettings.Lockup_Pressure__c,
                                                                                           Primary_Function__c=opSettings.Primary_Function__c,Set_Point__c=opSettings.Set_Point__c,
                                                                                           Site__c=SiteID,Work_Order__c=WorkOrderID,Stream_No__c=opSettings.Stream_No__c);
                            newOplist.add(OpSett) ;                                                          
                         }
                    } 
                }
                if(!newOplist.isEmpty()){
                    INSERT newOplist;
                    system.debug('Inserted List--'+newOplist);
                }                    
            }
       }
    
}