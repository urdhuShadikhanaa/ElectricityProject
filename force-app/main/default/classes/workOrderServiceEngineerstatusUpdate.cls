/*
** Description: This class is used in FFA**
*/
public class workOrderServiceEngineerstatusUpdate{
   
    @Future(callout=true)
    public static void CompletedWorkorders(String toDeserialize,string EnStatus){
        String catchPayload;
        Try{   
            Set<id> SerializeSAppIDS= new Set<id>();
            if(toDeserialize!=null)
            SerializeSAppIDS=(Set<Id>)System.JSON.deserialize(toDeserialize, Set<ID>.class);
            system.debug(SerializeSAppIDS.size());
            list<ServiceAppointment> serviceAppointmentList = [select id,ParentRecordId,FFA_Long_Job_Ind__c,FFA_Return_Job_Ind__c,Onsite__c,Enroute__c,status,FFA_Long_Job_Date_Time__c,FFA_Job_Returned_Date_Time__c,ParentRecordType,FFAAssignedAPI__c from ServiceAppointment where Id =: SerializeSAppIDS AND ParentRecordType='WorkOrder' limit 1];
            System.debug('Query=='+serviceAppointmentList);
            Id WOrderId = serviceAppointmentList[0].ParentRecordId;
            string JobStatusValue;
            string JobStatus;
            if(EnStatus=='Enroute' && EnStatus!=null ){
                JobStatusValue = 'I';
                JobStatus='Enroute';
            }else if(EnStatus=='Arrived' && EnStatus!=null){
                JobStatusValue = 'A';
                JobStatus='Arrived';
            }else if(EnStatus=='LongJob' && EnStatus!=null ){
                JobStatusValue = 'L';
                JobStatus='Long Job';
            }else if( EnStatus=='ReturnJob' || EnStatus=='Assigned'|| EnStatus=='Unassigned'){
                JobStatusValue = 'J';
                JobStatus='Return Job';
            }
            System.debug('JobStatusValue'+JobStatusValue+'=='+JobStatus);
            workOrderServiceEngineerstatusUpdate.WrapperBody Wrpbody=new workOrderServiceEngineerstatusUpdate.WrapperBody();
            workOrderServiceEngineerstatusUpdate.Header Headers=new workOrderServiceEngineerstatusUpdate.Header();
            workOrderServiceEngineerstatusUpdate.Record Jobs_toSend = new workOrderServiceEngineerstatusUpdate.Record();
            workOrderServiceEngineerstatusUpdate.WorkStatus WoStatus = new workOrderServiceEngineerstatusUpdate.WorkStatus();
            
            List<WorkOrder> WorkOrderList=[Select id,WorkOrderNumber,FFA_PurgingCompleted__c,FFA_PartialCompletion__c,FFA_ServiceProviderWorkReferenceNumber__c,
                                    FFA_EngineerContactNumber__c,FFA_ContractorID__c,FFA_Sender_ID__c,FFA_EngineerResourceID__c,FFA_NewAppointmentTimeSlot__c,
                                    FFA_NewAppointmentDate__c,FFA_JobReplanReasonText__c,FFA_JobReplanReasonCode__c,FFA_CompletedTerminatedCancelledText__c,
                                    FFA_StatusReasonCode__c,FFA_TerminatedCancelledReasonCode__c,FFA_Job_Returned_Date_Time__c,
                                    FFA_ArrivalTime__c,FFA_ArrivalDate__c,FFA_MeterPointReferenceNumber__c,FFA_ShipperID__c,FFA_SiteID__c,
                                    FFA_ServiceNotificationNumber__c,FFA_RequestedAppointmentDate__c,FFA_RequestCreatedDate__c,FFA_RequestedAppointmentTimeslot__c,
                                    FFA_OperationNumber__c,FFA_JobCode__c,Discount,Status,Service_Provider__r.Name,Sync_Status__c from WorkOrder Where id=:WOrderId limit 1]; 
            
            system.debug('WorkOrderList----'+WorkOrderList);
            for(WorkOrder Wraplist: WorkOrderList){
                if(Wraplist!=null){
                    // Header Value assigned here
                    headers.TransactionType = 'N64';
                    headers.InterfaceName = 'SF-UPDATE';
                    headers.SenderID = 'FFA'; 
                    headers.ReceiverID = Wraplist.FFA_Sender_ID__c;
                    headers.FileType = 'SF-UPDATE';
                    headers.CreationDate = '';//string.valueof(system.today())
                    headers.CreationTime = '';
                    
                    // Jobs value assigned here in wrappper
                    WoStatus.ServiceNotificationNumber = Wraplist.FFA_ServiceNotificationNumber__c;
                    WoStatus.OperationNumber = Wraplist.FFA_OperationNumber__c;
                    WoStatus.MeterPointReferenceNumber = Wraplist.FFA_MeterPointReferenceNumber__c;
                    WoStatus.ServiceProvider = Wraplist.Service_Provider__r.Name;
                    WoStatus.ServiceProviderJobNumber = Wraplist.WorkOrderNumber;
                    if(string.isNotBlank(JobStatusValue)){
                        WoStatus.JobStatus = JobStatusValue;
                        WoStatus.JobStatusReason = JobStatus;
                        
                    }
                    if(EnStatus=='Arrived' && serviceAppointmentList[0].Onsite__c!=null){
                        string JobStatusDateValue = convertDateFormattoSAP(date.valueOf(serviceAppointmentList[0].Onsite__c));
                        if(string.isNotBlank(JobStatusDateValue)){
                            WoStatus.JobStatusDate = JobStatusDateValue;
                        }
                        string JobStatusTimeValue = convertTimeFormatToSAP(serviceAppointmentList[0].Onsite__c);
                        if(string.isNotBlank(JobStatusTimeValue)){
                            WoStatus.JobStatusTime = JobStatusTimeValue;
                        }
                    }
                    if(EnStatus=='Enroute' && serviceAppointmentList[0].Enroute__c!=null  ){
                        string JobStatusDateValue = convertDateFormattoSAP(date.valueOf(serviceAppointmentList[0].Enroute__c));
                        if(string.isNotBlank(JobStatusDateValue)){
                            WoStatus.JobStatusDate = JobStatusDateValue;
                        }
                        string JobStatusTimeValue = convertTimeFormatToSAP(serviceAppointmentList[0].Enroute__c);
                        if(string.isNotBlank(JobStatusTimeValue)){
                            WoStatus.JobStatusTime = JobStatusTimeValue;
                        }
                    }
                    if(JobStatus=='Long Job' && serviceAppointmentList[0].FFA_Long_Job_Date_Time__c!=null){
                        string JobStatusDateValue = convertDateFormattoSAP(date.valueOf(serviceAppointmentList[0].FFA_Long_Job_Date_Time__c));
                        if(string.isNotBlank(JobStatusDateValue)){
                            WoStatus.JobStatusDate = JobStatusDateValue;
                        }
                        string JobStatusTimeValue = convertTimeFormatToSAP(serviceAppointmentList[0].FFA_Long_Job_Date_Time__c);
                        if(string.isNotBlank(JobStatusTimeValue)){
                            WoStatus.JobStatusTime = JobStatusTimeValue;
                        }
                    }
                    
                    // As per discussion with Mahesh on 22-04-2020, Return date and Time value is null then current date and time should be send to the SAP
                    // for both the secenario Assigned and Unassigned, i.e, modified by ankit
                    if((JobStatus=='Return Job' && serviceAppointmentList[0].FFA_Job_Returned_Date_Time__c!=null) || 
                       (JobStatus=='Return Job' && serviceAppointmentList[0].FFA_Job_Returned_Date_Time__c==null)){
                           string JobStatusDateValue;
                           if(serviceAppointmentList[0].FFA_Job_Returned_Date_Time__c!=null){
                               JobStatusDateValue = convertDateFormattoSAP(date.valueOf(serviceAppointmentList[0].FFA_Job_Returned_Date_Time__c));
                           }else{
                               JobStatusDateValue = convertDateFormattoSAP(System.Date.today());
                           }
                           system.debug('Date Time for Return Job =='+JobStatusDateValue);
                           if(string.isNotBlank(JobStatusDateValue)){
                               system.debug('Date Time for Return Job =='+JobStatusDateValue);
                               WoStatus.JobStatusDate = JobStatusDateValue;
                               system.debug('Date Time for Return Job =='+WoStatus.JobStatusDate);
                           }
                           string JobStatusTimeValue;
                           if(serviceAppointmentList[0].FFA_Job_Returned_Date_Time__c!=null){
                               JobStatusTimeValue = convertTimeFormatToSAP(serviceAppointmentList[0].FFA_Job_Returned_Date_Time__c);
                           }else{
                               JobStatusTimeValue = convertTimeFormatToSAP(system.Datetime.now());
                           }  
                           
                           if(string.isNotBlank(JobStatusTimeValue)){
                               WoStatus.JobStatusTime = JobStatusTimeValue;
                           }
                           
                       }
                    WoStatus.ProcessIndicator = Wraplist.Sync_Status__c;//Need proper mapping
                        
                }
            
        }
        
            string JSONPayload;
            Jobs_toSend.WorkStatus = WoStatus;
            Wrpbody.Record = Jobs_toSend;
            Wrpbody.Header = headers;
            system.debug('---Json---->>>>'+JSON.serialize(Wrpbody));
            JSONPayload = JSON.serialize(Wrpbody);
            //Blob headerValue = Blob.valueOf(label.FFA_Integration_UserName + ':' + label.FFA_Integration_Password);
            //String authorizationHeader = 'Basic '+EncodingUtil.base64Encode(headerValue);
            Httprequest request = new HttpRequest();
            Http http = new Http();
            request.setMethod('POST');
            //request.setEndpoint(label.FFA_StatusIntegrationEndPointURL);
            request.setEndpoint('callout:NG_ServiceAppointment_Status_Update_From_Salesforce_NC');
            request.setTimeout(120000);
            //request.setHeader('Content-Type', 'application/json');
            //request.setHeader('Authorization', authorizationHeader);
            request.setBody(JSONPayload);          
            HttpResponse response = http.send(request);  
            System.debug('responseBody: '+response.getBody());
            System.debug('Resp code--->'+response.getStatusCode());
            FFA_Interface_Runs__c InterfaceLogs = new FFA_Interface_Runs__c(Interface_Name__c='/FFAServiceEnggStatusInterface',Transaction_Message__c=JSON.serialize(Wrpbody), Transaction_Status__c = string.valueOf(response.getStatusCode()));
            insert InterfaceLogs;
            catchPayload=JSON.serialize(Wrpbody);
        }
        catch(Exception e){
            system.debug('Exception In StatusUpdate Interface at Line No----:'+e.getMessage()+'Exception at Line'+e.getLineNumber());
            FFA_Interface_Runs__c InterfaceLogs = new FFA_Interface_Runs__c(Interface_Name__c='/FFAServiceEnggStatusInterface',
                                                                            Transaction_Message__c=catchPayload, 
                                                                            Transaction_Status__c ='400',
                                                                            Interface_Exception__c=e.getMessage()+'Exception at Line'+e.getLineNumber() );
            IF(InterfaceLogs.Interface_Exception__c.contains('Read timed')){
                 InterfaceLogs.Transaction_Status__c='503';
            }                                                                
            insert InterfaceLogs;
        } 
    }
    
    public static string convertDateFormattoSAP(date SFDateToConvert){
        String Convereteddate;
        if(SFDateToConvert!=null){
            Convereteddate=string.valueof(SFDateToConvert);
            Convereteddate=Convereteddate.substring(0,4) + '-' + 
                Convereteddate.substring(5,7) + '-' +
                Convereteddate.substring(8,10);
        }
        return Convereteddate;
    }
    
    public static string convertTimeFormatToSAP(dateTime SFTimeToConvert){
        string convertTime;
        if(SFTimeToConvert!=null){
            convertTime = string.valueOf(SFTimeToConvert);
            convertTime = convertTime.substring(11,19);
        }
        return convertTime;
    }

    public class WrapperBody{
        public Header Header { get; set; }
        public Record Record { get; set; }
    }
    public class Header{
        public string TransactionType { get; set; }
        public string SenderID { get; set; }
        public string ReceiverID { get; set; }
        public string InterfaceName { get; set; }
        public string ServiceProvider { get; set; }
        public string FileType { get; set; }
        public string CreationDate { get; set; }
        public string CreationTime { get; set; }
    }
    public class Record{
        public WorkStatus WorkStatus {get; set;}
    }
    
    public class WorkStatus{
        public string ServiceNotificationNumber { get; set; }
        public string OperationNumber { get; set; }
        public string MeterPointReferenceNumber { get; set; }
        public string ServiceProvider { get; set; }
        public string ServiceProviderJobNumber{get;set;}
        //public string JobNumber { get; set; }
        public string JobStatus { get; set; }
        public string JobStatusReason { get; set; }
        public string ReplanCode { get; set; }
        public string ReplanReason { get; set; }
        public string ReplanDate { get; set; }
        public string ReplanTimeSlot { get; set; }
        public string JobStatusDate { get; set; }
        public string JobStatusTime { get; set; }
        public string ProcessIndicator { get; set; }
    }
    
}