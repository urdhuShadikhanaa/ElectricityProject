/////////////////////////////////////////////////////////
/*          Service Provider Workorder Fetch API       */
/*          Author: Venkat                       */ 
/*          Company: Wipro Technologies                */
/*          Created Date: 22/07/2019                   */
/////////////////////////////////////////////////////////

@RestResource(urlMapping='/FetchWorkOrdersFFA/*')
global with sharing class FFAWorkOrders{
    @HttpGet
    global static void doGet()
    {
        FFA_Integration_Limit__mdt maxFetchLimit=[Select MasterLabel,limit__c from FFA_Integration_Limit__mdt where MasterLabel=:'WorkOrdersFetch' limit 1];
        final Integer WORKORDER_BATCH_LIMIT = Integer.valueof(maxFetchLimit.limit__c); //To-DO, Create a custom settings and fetch this value- to ensure this is configurable. 
        final String SYNC_STATUS_FETCHED ='Fetched';
        final String HTTP_SUCCESS_MESSAGE = 'Workorders successfully fetched';
        final String HTTP_ERROR_MESSAGE= '';
        final String HTTP_NO_WORKORDER_FOUND = 'No workorders pending for Fetch';
        
        try{
            
            //Get all fields for each required Object to build a dynamic query string. 
            //Although all the fields are retrieved, the ones mapped in the class FFA_WorkOrder will 
            //only be sent to Service Provider
            
            //TO-DO: Optimize performance 
            String workOrderFields = GetObjectFields('WorkOrder'); 
            //String assetFields = GetObjectFields('FFA_NGV_Asset__c');
            String siteFields = GetObjectFields('FFA_Site__c');
            String serviceApptFields = GetObjectFields('ServiceAppointment');
            String jobInformationFields = GetObjectFields('Job_Information__c');
            
            
            //Get Emergency & Non Emergency Workorders count to fit into a batch of value equal to the Custom Settings
            Integer totalBatchCount = 0;
            List<Id> qualifyingWorkOrderIds = new List<Id>();
            List<Id> emerUnAssignedWOIds = new List<Id>(new Map<Id,WorkOrder>([SELECT Id FROM WORKORDER WHERE 
                                                                               FFA_EMERGENCYFLAG__c=true AND 
                                                                               SYNC_STATUS__c='PENDING' AND 
                                                                               STATUS IN ('New','Unassigned','Cancelled') 
                                                                               LIMIT :WORKORDER_BATCH_LIMIT]).keySet());
            
            totalBatchCount+=emerUnAssignedWOIds.size();
            system.debug('totalEmerUnAssignedWOs: ' + totalBatchCount);
            qualifyingWorkOrderIds.addAll(emerUnAssignedWOIds);
            
            if(totalBatchCount<WORKORDER_BATCH_LIMIT){
                //   string emerUpdatedWOQuery = ' + (200-totalBatchCount);
                List<Id> emerUpdatedWOIds =new List<Id>(new Map<Id,WorkOrder>([SELECT Id FROM WORKORDER WHERE 
                                                                               FFA_EMERGENCYFLAG__c=true AND 
                                                                               STATUS IN ('Assigned','Further Work Required','In Progress','Completed','Terminated','Rejected') AND 
                                                                               SYNC_STATUS__c='PENDING' 
                                                                               LIMIT :WORKORDER_BATCH_LIMIT-totalBatchCount]).keySet());
                totalBatchCount+=emerUpdatedWOIds.size();
                qualifyingWorkOrderIds.addAll(emerUpdatedWOIds);
                system.debug('totalEmerUpdatedWOs: ' + emerUpdatedWOIds.size());
                if (totalBatchCount<WORKORDER_BATCH_LIMIT)
                {
                    List<Id> nonEmerUnAssignedWOIds  = new List<Id>(new Map<Id,WorkOrder>([SELECT Id FROM WORKORDER 
                                                                                           WHERE FFA_EMERGENCYFLAG__c=false AND 
                                                                                           SYNC_STATUS__c='PENDING' AND 
                                                                                           STATUS IN ('New','Unassigned','Cancelled') 
                                                                                           LIMIT :WORKORDER_BATCH_LIMIT-totalBatchCount]).keySet());
                    totalBatchCount+=nonEmerUnAssignedWOIds.size();
                    qualifyingWorkOrderIds.addAll(nonEmerUnAssignedWOIds);
                    system.debug('totalNonEmerUnAssignedWOs: ' + nonEmerUnAssignedWOIds.size());
                    
                    if (totalBatchCount<WORKORDER_BATCH_LIMIT)
                    {
                        List<Id> nonEmerUpdatedWOIds = new List<Id>(new Map<Id,WorkOrder>([SELECT Id FROM WORKORDER 
                                                                                           WHERE FFA_EMERGENCYFLAG__c=false AND 
                                                                                           STATUS IN ('Assigned','Further Work Required','In Progress','Completed','Terminated','Rejected') 
                                                                                           AND SYNC_STATUS__c='PENDING' LIMIT :WORKORDER_BATCH_LIMIT-totalBatchCount]).keySet());
                        totalBatchCount+=nonEmerUpdatedWOIds.size();
                        qualifyingWorkOrderIds.addAll(nonEmerUpdatedWOIds);
                        system.debug('totalNonEmerUpdatedWOIds: ' + nonEmerUpdatedWOIds.size());
                    }
                }
            }
            
            system.debug('Total Batch Count ' + totalBatchCount);
            system.debug('Qualifying WorkOrder IDs ' +qualifyingWorkOrderIds );
            
            String SOQL_IDs = '';
            for(Id id : qualifyingWorkOrderIds){
                String id_in_quotes = '\''+id+'\'';
                if (SOQL_IDs!='') { SOQL_IDs+=','; }  //  add a comma if this isn't the first one
                SOQL_IDs += id_in_quotes;
            }
            
            system.debug('soql ids ' + SOQL_IDs);
            string resPayLoad = '';
            List<FFA_WorkOrder> workOrderList = new List<FFA_WorkOrder>();
            FFA_WorkOrders response = new FFA_WorkOrders();
            
            if (totalBatchCount!=0)
            {
                //Formulate bulkified SOQL query to fetch Workorders and related Assets, Site & Service Appointment records
                String dynamicQuery = 'SELECT ' + workOrderFields + ', ' + siteFields  + ', ' +
                    //  ' (SELECT ' + assetFields + ' FROM FFA_Assets__r)  ,' +
                    ' (SELECT ' + jobInformationFields + ' FROM Job_Informations__r LIMIT 1)  ,' +
                    ' (SELECT ' + serviceApptFields + ' FROM ServiceAppointments)' +
                    ' FROM WORKORDER WHERE Id in (' + SOQL_IDs + ')' ;
                
                
                List<WorkOrder>wosToUpdate= new List<WorkOrder>(); //list to hold Workorders for which the Sync Status and Batch no needs to be updated
                
                //Add Batching Logic ( create & assign a batch no for new workorders. Workorders already sent once as part of a batch will retain their batch nos.)
                
                //Generate a unique batch ID 
                Blob b = Crypto.GenerateAESKey(128);
                String h = EncodingUtil.ConvertTohex(b);
                String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
                system.debug(guid);
                
                
                system.debug('dynamic query is ' + dynamicQuery);
                //TO-DO- check if a map could be used instead of this.
                for (WorkOrder wo : Database.query(dynamicQuery)){
                    if(wo.Axsy_Form__c!=null){
                        FFA_WorkOrder ffaWorkOrder= new FFA_WorkOrder();
                        ffaWorkOrder.WorkOrderNo= wo.WORKORDERNUMBER;
                        ffaWorkOrder.TransactionType= wo.Transaction_Type__c;
                        ffaWorkOrder.WorkOrderStatus= wo.Status;
                        ffaWorkOrder.ServiceProviderID = wo.FFA_ServiceProvider__c;
                        //ffaWorkOrder.SiteID = wo.FFA_SiteID__c;
                        ffaWorkOrder.ShipperID = wo.FFA_ShipperID__c;
                        ffaWorkOrder.ShipperName = wo.FFA_ShipperName__c;
                        ffaWorkOrder.MeterProvider = wo.FFA_MeterProvider__c;
                        ffaWorkOrder.WorkOrderNo = wo.WorkOrderNumber; //Duplicate
                        ffaWorkOrder.JobCode = wo.FFA_JobCode__c;
                        ffaWorkOrder.JobCodeDesc = wo.FFA_JobDescription__c;
                        ffaWorkOrder.JobNotes = wo.FFA_JobNotes__c; 
                        //ffaWorkOrder.RequestedAppointmentDate = Date.valueof(wo.FFA_RequestedAppointmentDate__c);
                        //ffaWorkOrder.RequestedAppointmentEndDate = Date.valueOf(wo.FFA_RequestedAppointmentEndDate__c);
                        //ffaWorkOrder.RequestedAppointmentTimeSlot = wo.FFA_RequestedAppointmentTimeslot__c;
                        ffaWorkOrder.WorkOrderStatus = wo.Status;
                        ffaWorkOrder.ServiceNotificationNumber = wo.FFA_ServiceNotificationNumber__c;
                        ffaWorkOrder.OperationNumber = wo.FFA_OperationNumber__c;
                        ffaWorkOrder.CompletedTerminatedCancelledText = wo.FFA_CompletedTerminatedCancelledText__c;
                        ffaWorkOrder.JobReplanReasonText = wo.FFA_JobReplanReasonText__c;
                        ffaWorkOrder.MPRN = wo.FFA_MeterPointReferenceNumber__c;
                        //ffaWorkOrder.UnPlannedPolicyStartDate = Date.valueOf(wo.FFA_UnplannedPolicyStartDate__c);
                        //ffaWorkOrder.UnPlannedPolicyEndDate = Date.valueOf(wo.FFA_UnplannedPolicyEndDate__c);
                        ffaWorkOrder.EmergencyFlag = wo.FFA_EmergencyFlag__c==true?'Emergency':'Routine';
                        ffaWorkOrder.JobCategory = wo.Job_Category__c;
                        ffaWorkOrder.BusinessArea=wo.FFA_Sender_ID__c=='RAINBOW' ? 'DOM':'IC';
                        //JobInformation safety Checks for SP
                        for(Job_Information__c jobInfo:wo.Job_Informations__r){
                            ffaWorkOrder.SafetyCheck=jobInfo.FFA_Safety_Check_Complete__c;
                            ffaWorkOrder.SafetyCheckReasonCode=jobInfo.FFA_Safety_Check_Reason_Code__c;
                            ffaWorkOrder.SafetyCheckReasonText=jobInfo.FFA_Safety_Check_Reason_Text__c;
                            ffaWorkOrder.ReportIndicator=jobInfo.Report_Indicator__c;
                        }
                        ffaWorkOrder.FinalJobReport=wo.FFA_Final_Job_Report__c;
                        ffaWorkOrder.JOC1=wo.FFA_JOC1__c;
                        ffaWorkOrder.JOC2=wo.FFA_JOC2__c;
                        ffaWorkOrder.JOC3=wo.FFA_JOC3__c;
                        //ffaWorkOrder.NumberofArrivalsInHours='Y'; // 13/02/2020 removed as per discussion
                        //ffaWorkOrder.NumberofArrivalsOutofHours='Y'; // 13/02/2020 removed as per discussion
                        
                        //Update Sync Status to 'Fetched'
                        wo.Sync_Status__c =SYNC_STATUS_FETCHED;
                        //if(wo.Batch_No__c==null)
                        //{
                        wo.Batch_No__c=guid;
                        //ffaWorkOrder.BatchID = guid;
                        //}
                        //ffaWorkOrder.BatchID = wo.Batch_No__c;
                        
                        wosToUpdate.add(wo);
                        
                        //Add Site record to the response
                        ffaWorkOrder.Site = GetSiteRecord(wo);
                        
                        //Add Service Appointments to the response
                        ffaWorkOrder.serviceAppointments= new List<FFA_ServiceAppointment>();
                        for (ServiceAppointment saApp:wo.ServiceAppointments)
                        {
                            FFA_ServiceAppointment sa = GetServiceApptRecord(saApp);
                            if(sa.Status!='Cancelled'){sa.AppointmentTimeSlot=wo.FFA_RequestedAppointmentTimeslot__c;}
                            ffaWorkOrder.ServiceAppointments.add(sa); 
                        } 
                        workOrderList.add(ffaWorkOrder);
                    }
                    
                }
                
                //Added Header record to the response. 
                //TO-DO : Add a wrapper class for the header record to show the following counts: Timestamp, Total, Unassigned, Assigned, Dispatched, In Progress, Completed, Cancelled, Terminated, Replan_Required
                Header headerRecord = new Header();
                headerRecord.WorkOrderStatuses= new List<AggregateResult>();
                
                headerRecord.WorkOrderStatuses=  [SELECT STATUS,COUNT(ID) Total FROM WORKORDER WHERE STATUS!=null GROUP BY STATUS];
                //response.HeaderRecord= headerRecord.WorkOrderStatuses;
                
                response.Work_Orders = workOrderList;
                headerRecord.TransactionStatus ='Success';
                headerRecord.TransactionMessage='Workorders fetched';
                headerRecord.WorkOrderCount= workOrderList.size();
                response.header = headerRecord;
                
                
                //To-do: Dont prettify- it consumes a lot of CPU time in the current context
                resPayLoad = Json.serializePretty(response,true);
                
                if(!wosToUpdate.isEmpty()){
                    Database.SaveResult[] srList = Database.update(wosToUpdate,false);
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
                
                CreateResponse('Success',HTTP_SUCCESS_MESSAGE,guid,'200',workOrderList);
            }
            
            else
                
            {
                CreateResponse('Success',HTTP_NO_WORKORDER_FOUND,'Null','200', workOrderList);
            }
            
            system.debug('resPayLoad is ' + resPayLoad);    
            
            
        }
        catch(Exception ex){
            system.debug('Try Catch ==='+ex.getMessage()+'==='+ex.getLineNumber());
            CreateResponse('Failure',ex.getMessage()+'==='+ex.getLineNumber(),null,'500',null);
            
        } 
        
    }
    
    static System.RestResponse CreateResponse(string TransactionStatus,string TransactionMessage, string BatchID, string HttpStatusCode, List<FFA_WorkOrder> workOrderList){
        RestResponse res = RestContext.response;
        
        res.statusCode= Integer.valueOf(HttpStatusCode);
        res.addHeader('Content-Type', 'application/json;charset=UTF-8');
        FFA_WorkOrders resWrappers = new FFA_WorkOrders();
        resWrappers.Header = new Header();
        
        resWrappers.Header.RunAt = TimeZoneconversion(DateTime.now());
        resWrappers.Header.TransactionStatus = TransactionStatus;
        resWrappers.Header.TransactionMessage = TransactionMessage;
        resWrappers.Header.BatchId = BatchId;
        resWrappers.Header.WorkOrderStatuses= new List<AggregateResult>();
        
        resWrappers.Header.WorkOrderStatuses=  [SELECT STATUS,COUNT(ID) Total FROM WORKORDER WHERE STATUS!=null GROUP BY STATUS];
        
        resWrappers.Work_Orders = workOrderList;
        
        res.responseBody= Blob.valueOf(Json.serialize(resWrappers,true));
        
        FFA_Interface_Runs__c InterfaceLogs = new FFA_Interface_Runs__c(Interface_Name__c='/FFAWorkorders',
                                                                        Transaction_Message__c=TransactionMessage, 
                                                                        Transaction_Status__c = TransactionStatus, Invoked_By__c=UserInfo.getUserName(), Invoked_At__c=String.valueOf(DateTime.Now()));
        insert InterfaceLogs;
        Blob payLoadBlob = Blob.valueOf(JSON.serialize(resWrappers));
        UpdateInterfaceRuns(payLoadBlob,InterfaceLogs.id);
        
        return res;
    }
    
    public static void UpdateInterfaceRuns(Blob responseBody,Id InterfaceRunsId){
        //TO-DO Insert record nto FFA Interface runs
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'ServiceProvider.txt'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = InterfaceRunsId; // Display name of the files
        conVer.VersionData = responseBody; // converting your binary string to Blog
        insert conVer;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId =InterfaceRunsId ; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'InternalUsers';
        insert cDe;
        system.debug(conVer);
        system.debug(cDe);
    }
    
    public static String GetObjectFields(String FFA_Object){
        String objectFields='';
        if (FFA_Object=='WorkOrder')
        {
            objectFields = 'Batch_No__c,Transaction_Type__c,Description,FFA_AbortSuspendReplan__c,FFA_ArrivalDate__c,'+
                'FFA_ArrivalTime__c,FFA_CompletedTerminatedCancelledText__c,FFA_CompletionDateAndTime__c,Job_Category__c,' +
                'FFA_ContractorID__c,FFA_EmergencyFlag__c,FFA_EngineerContactNumber__c,FFA_EngineerResourceID__c,' +
                'FFA_JobCode__c,FFA_JobDescription__c,FFA_JobNotes__c,FFA_JobReplanReasonCode__c,FFA_JobReplanReasonText__c,' +
                'FFA_MeterPointReferenceNumber__c,FFA_MeterProvider__c,FFA_NewAppointmentDate__c,' +
                'FFA_NewAppointmentTimeSlot__c,FFA_OperationNumber__c,FFA_PartialCompletion__c,' +
                'FFA_PurgingCompleted__c,FFA_RequestCreatedDate__c,FFA_RequestCreatedTime__c,' +
                'FFA_RequestedAppointmentDate__c,FFA_RequestedAppointmentTimeslot__c,Axsy_Form__c,' + 
                'FFA_ServiceNotificationNumber__c,FFA_ServiceProviderWorkReferenceNumber__c,FFA_ServiceProvider__c,' +
                'FFA_ShipperID__c,FFA_ShipperName__c,FFA_SiteID__c,FFA_StatusReasonCode__c,FFA_SuspendReason__c,' +
                'FFA_TerminatedCancelledReasonCode__c,FFA_TerminatedReasonCode_customer__c,' +
                'FFA_TerminatedReasonCode_maintenence__c,FFA_UnplannedPolicyEndDate__c,FFA_JOC1__c,FFA_JOC2__c,FFA_JOC3__c,' +
                'FFA_UnplannedPolicyStartDate__c,FFA_Sender_ID__c,FFA_Final_Job_Report__c,Service_Provider__c,Site__c,Status,WorkOrderNumber,WorkTypeId,FFA_RequestedAppointmentEndDate__c';    
        }
        else if (FFA_Object=='FFA_Site__c')
        {
            objectFields = 'Site__r.Name,Site__r.FFA_AccessInstructions__c, Site__r.FFA_AccessRestrictions__c,Site__r.FFA_Vulnerable_Customer_Information__c,'+
                'Site__r.FFA_AdditionalContactTelephoneNumber2__c,  Site__r.FFA_AdditionalContactTelephoneNumber__c,'+
                'Site__r.FFA_BuildingName__c,   Site__r.FFA_BuildingNumber__c,  Site__r.FFA_ContactTelephoneNumber2__c,' +
                'Site__r.FFA_ContactTelephoneNumber__c, Site__r.FFA_ConversionFactor__c,' +
                'Site__r.FFA_CorrespondenceAddress__c,Site__r.FFA_County__c,'+
                'Site__r.FFA_DependentLocality__c,  Site__r.FFA_DependentStreet__c,' +
                'Site__r.FFA_DoesTheSiteContainAsbestos__c, Site__r.FFA_DoubleDependantLocality__c,'+
                'Site__r.FFA_GPSEasting__c, Site__r.FFA_GPSNorthing__c, Site__r.FFA_Initials2__c,' +
                'Site__r.FFA_Initials__c,   Site__r.FFA_InletPressure__c,   Site__r.FFA_Location_of_Mpoint__c,' +
                'Site__r.FFA_Notes__c,  Site__r.FFA_OutletPressure__c,  Site__r.FFA_PostcodeIncode__c,  ' +
                'Site__r.FFA_PostcodeOutcode__c,    Site__r.FFA_PostTown__c,    Site__r.FFA_PressureTier__c, ' +
                'Site__r.FFA_PrincipalStreet__c,    Site__r.FFA_SubBuildingName__c, Site__r.FFA_Surname2__c, ' +
                'Site__r.FFA_Surname__c, Site__r.FFA_Title2__c,Site__r.FFA_Title__c,Site__r.Site_Name__c ';
        }
        else if (FFA_Object=='Job_Information__c')
        {
            objectFields = 'FFA_Safety_Check_Complete__c,Report_Indicator__c,FFA_Safety_Check_Reason_Code__c,FFA_Safety_Check_Reason_Text__c' ;
        } 
        
        else if (FFA_Object=='ServiceAppointment')
        {
            objectFields = 'AppointmentNumber,FFA_Return_Job_Comments__c,FFA_Long_Job_Ind__c,FFA_Job_Returned_Date_Time__c,FFA_Return_Job_Ind__c,FFA_Long_Job_Date_Time__c,Onsite__c,Scheduled__c,Dispatched__c,Enroute__c,Status,Started_Work__c,Completed__c,Cannot_Complete__c,SchedStartTime,SchedEndTime,DueDate' ;
        }
        return objectFields;
        
        
        
    }
    
    public static FFA_Site GetSiteRecord(WorkOrder wo)
    {
        FFA_Site siteRecord = new FFA_Site();
        siteRecord.SiteName =  wo.Site__r.Site_Name__c;// Updated 11/11/2019 as per the discusion with Mahesh
        siteRecord.CustomerSurname =  wo.Site__r.FFA_Surname__c;
        siteRecord.CustomerTitle =  wo.Site__r.FFA_Title__c;
        siteRecord.CustomerInitials =  wo.Site__r.FFA_Initials__c;
        siteRecord.BuildingNumber =  wo.Site__r.FFA_BuildingNumber__c;
        siteRecord.BuildingName =  wo.Site__r.FFA_BuildingName__c;
        siteRecord.SubBuildingName =  wo.Site__r.FFA_SubBuildingName__c;
        siteRecord.PrincipalStreet =  wo.Site__r.FFA_PrincipalStreet__c;
        siteRecord.DependentLocality =  wo.Site__r.FFA_DependentLocality__c;
        siteRecord.DoubleDependantLocality =  wo.Site__r.FFA_DoubleDependantLocality__c;
        siteRecord.DependentStreet =  wo.Site__r.FFA_DependentStreet__c;
        siteRecord.PostTown =  wo.Site__r.FFA_PostTown__c;
        siteRecord.PostcodeIncode =  wo.Site__r.FFA_PostcodeIncode__c;
        siteRecord.PostcodeOutcode =  wo.Site__r.FFA_PostcodeOutcode__c;
        siteRecord.County =  wo.Site__r.FFA_County__c;
        siteRecord.GPSEasting =  wo.Site__r.FFA_GPSEasting__c;
        siteRecord.GPSNorthing =  wo.Site__r.FFA_GPSNorthing__c;
        siteRecord.ContactTelephoneNumber =  wo.Site__r.FFA_ContactTelephoneNumber__c;
        siteRecord.ContactTelephoneNumber2 =  wo.Site__r.FFA_ContactTelephoneNumber2__c;
        siteRecord.CorrespondenceAddress =  wo.Site__r.FFA_CorrespondenceAddress__c;
        siteRecord.PressureTier =  wo.Site__r.FFA_PressureTier__c;
        siteRecord.InletPressure =  wo.Site__r.FFA_InletPressure__c;
        siteRecord.OutletPressure =  wo.Site__r.FFA_OutletPressure__c;
        siteRecord.AccessInstructions =  wo.Site__r.FFA_AccessInstructions__c;
        siteRecord.AccessRestrictions =  wo.Site__r.FFA_AccessRestrictions__c;
        siteRecord.ConversionFactor =  wo.Site__r.FFA_ConversionFactor__c;
        siteRecord.DoesTheSiteContainAsbestos =   wo.Site__r.FFA_DoesTheSiteContainAsbestos__c;
        siteRecord.Location_of_Mpoint =  wo.Site__r.FFA_Location_of_Mpoint__c;
        siteRecord.Notes =  wo.Site__r.FFA_Notes__c;
        siteRecord.MPRN = wo.FFA_MeterPointReferenceNumber__c;// Update 11/11/2019 as per mahesh email.
        siteRecord.VulnerableCustomerInformation=wo.Site__r.FFA_Vulnerable_Customer_Information__c;
        siteRecord.AdditionalAddressInformation=null;
        
        return siteRecord;
    }
    
    
    public static FFA_ServiceAppointment GetServiceApptRecord(ServiceAppointment sa)
    {
        //DAY LIGHTSAVINGS FOR UK
        /* Timezone UKTimeZone = Timezone.getTimeZone('Europe/London');
Boolean dayLightSavings=False;
IF(sa.SchedStartTime!=Null){
If(UKTimeZone.getOffset(sa.SchedStartTime)==0){
dayLightSavings=True;
}
else{
dayLightSavings=False;
}
}*/
        
        FFA_ServiceAppointment saRecord = new FFA_ServiceAppointment();
        saRecord.AppointmentNumber  = sa.AppointmentNumber;
        saRecord.Status  = sa.Status;
        
        IF(sa.SchedStartTime!=Null){
            saRecord.AppointmentStartDate  = TimeZoneconversion(sa.SchedStartTime);
        }
        IF(sa.SchedEndTime!=Null){
            saRecord.AppointmentEndDate  =  TimeZoneconversion(sa.SchedEndTime);
        }
        IF(sa.Enroute__c!=Null){
            saRecord.Enroute  =  TimeZoneconversion(sa.Enroute__c);
        }
        IF(sa.Onsite__c!=Null){
            saRecord.Onsite  =  TimeZoneconversion(sa.Onsite__c);
        }
        IF(sa.Started_Work__c!=Null){
            saRecord.StartedWork  =  TimeZoneconversion(sa.Started_Work__c);
        }
        IF(sa.Completed__c!=Null){
            saRecord.Completed  = TimeZoneconversion(sa.Completed__c);
        }
        IF(sa.FFA_Long_Job_Date_Time__c!=Null){
            saRecord.LongJobStartTime= TimeZoneconversion(sa.FFA_Long_Job_Date_Time__c);
        }
        IF(sa.FFA_Job_Returned_Date_Time__c!=Null){
            saRecord.ReturnJobStartTime= TimeZoneconversion(sa.FFA_Job_Returned_Date_Time__c);
        }
        IF(sa.FFA_Long_Job_Ind__c=='Yes'){
            saRecord.LongJob='Y';
        }
        
        IF(sa.FFA_Return_Job_Ind__c=='Yes'){
            saRecord.ReturnJob='Y';
        }
        saRecord.ReturnJobComments=sa.FFA_Return_Job_Comments__c;
        return saRecord;
    }
    
    
    
    
    public class FFA_Site
    {
        public string SiteName { get; set; }
        public string CustomerSurname { get; set; }
        public string CustomerSurname2 { get; set; }
        public string CustomerTitle { get; set; }
        public string CustomerTitle2 { get; set; }
        public string CustomerInitials { get; set; }
        //public string CustomerInitials2 { get; set; }
        public string BuildingNumber { get; set; }
        public string BuildingName { get; set; }
        public string SubBuildingName { get; set; }
        public string PrincipalStreet { get; set; }
        public string DependentLocality { get; set; }
        public string DoubleDependantLocality { get; set; }
        public string DependentStreet { get; set; }
        public string PostTown { get; set; }
        public string PostcodeIncode { get; set; }
        public string PostcodeOutcode { get; set; }
        public string County { get; set; }
        public string GPSEasting { get; set; }
        public string GPSNorthing { get; set; }
        public string ContactTelephoneNumber { get; set; }
        public string ContactTelephoneNumber2 { get; set; }
        // public string AdditionalContactTelephoneNumber { get; set; }
        // public string AdditionalContactTelephoneNumber2 { get; set; }
        public string CorrespondenceAddress { get; set; }
        public string PressureTier { get; set; }
        public decimal InletPressure { get; set; }
        public decimal OutletPressure { get; set; }
        public string AccessInstructions { get; set; }
        public string AccessRestrictions { get; set; }
        public string ConversionFactor { get; set; }
        public boolean DoesTheSiteContainAsbestos{ get; set; }
        public string Location_of_Mpoint { get; set; }
        public string Notes { get; set; }
        public String MPRN {get;set;}
        public String VulnerableCustomerInformation {get;set;}
        public String AdditionalAddressInformation {get;set;}
        
    } 
    
    public class FFA_ServiceAppointment
    {
        public string AppointmentNumber {get;set;}
        public string Status {get;set;}
        public DateTime AppointmentStartDate {get;set;}
        public DateTime AppointmentEndDate {get;set;}
        public string AppointmentTimeSlot {get;set;}
        public DateTime Enroute {get;set;}
        public DateTime Onsite {get;set;}
        public DateTime StartedWork {get;set;}
        public DateTime Completed {get;set;}
        public string LongJob {get;set;}
        public DateTime LongJobStartTime {get;set;}
        public string ReturnJob{get;set;}
        public DateTime ReturnJobStartTime{get;set;}
        public string ReturnJobComments{get;set;}
    }
    
    public class FFA_WorkOrder
    {
        //Workorder Wrapper
        public String TransactionType {get;set;}
        public String BatchId   {get;set;} 
        public String ServiceProviderID {get;set;}
        public string JobCategory {get;set;}
        public String MPRN {get;set;}
        public String ShipperID {get;set;}
        public String ShipperName {get;set;}
        public String MeterProvider {get;set;}
        public String WorkOrderNo {get;set;}
        public String JobCode {get;set;}
        public String JobCodeDesc {get;set;}
        public String JobNotes {get;set;}
        public String WorkOrderStatus {get;set;}
        public string ServiceNotificationNumber {get;set;}
        public string Operationnumber {get; set;}
        public string JobReplanReasonText {get;set;}
        public string CompletedTerminatedCancelledText {get;set;}
        public string SafetyCheck {get;set;}
        public string SafetyCheckReasonCode {get;set;}
        public string SafetyCheckReasonText {get;set;}
        public string ReportIndicator {get;set;}
        public string FinalJobReport {get;set;}
        public string JOC1 {get;set;}
        public string JOC2 {get;set;}
        public string JOC3 {get;set;}
        //public string NumberofArrivalsInHours {get;set;}   //13/02/2020 removed as per discussion
        //public string NumberofArrivalsOutofHours {get;set;}
        public String EmergencyFlag {get; set;}
        public String BusinessArea {get; set;}
        
        
        //Site Object Wrapper
        public FFA_Site Site {get;set;}
        
        //Asset Array of Objects Wrapper
        // public List<FFA_Asset> Assets {get;set;}
        
        public List<FFA_NGV_Asset__c>AssetList;
        
        //Service Appointments Array of Objects Wrapper
        public List<FFA_ServiceAppointment> ServiceAppointments {get;set;}
        
    }
    
    //HTTP Response Wrapper Class- for a successful request
    public class FFA_WorkOrders
    {
        //public string TransactionMessage,TransactionStatus;
        public Header Header; //TO-DO Write wrapper class to prettify!
        //public Integer WorkOrderCount;
        public List<FFA_WorkOrder> Work_Orders;
    } 
    
    public class Header
    {
        public DateTime RunAt;
        public List<AggregateResult> WorkOrderStatuses;
        public string TransactionMessage,TransactionStatus;
        public Integer WorkOrderCount;
        public string BatchId;
    }
    
    //HTTP Response Wrapper class for a unsuccessful request
    public class ErrorResponse
    {
        public string ErrorCode;
        public string ErrorDescription;
    }
    
    public static dateTime TimeZoneconversion(DateTime FFADateTime){
        //DAY LIGHTSAVINGS FOR UK
        Timezone UKTimeZone = Timezone.getTimeZone('Europe/London');
        DateTime convertedTime;
        Boolean dayLightSavings=False;
        IF(FFADateTime!=Null){
            If(UKTimeZone.getOffset(FFADateTime)==0){
                dayLightSavings=True;
                convertedTime=FFADateTime;
                system.debug(UKTimeZone.getOffset(FFADateTime));
            }
            else{
                dayLightSavings=False;
                convertedTime=FFADateTime.addHours(1);
                system.debug(UKTimeZone.getOffset(FFADateTime));
            }
            
        }
        return convertedTime;
    }
}