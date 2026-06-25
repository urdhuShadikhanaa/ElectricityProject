/////////////////////////////////////////////////
/*          SAP-FFA FETCHED INTERFACE TEST      */
/*          Author: Ankit Tomar                */ 
/*          Company: Wipro Technologies        */
/*          Created Date: 20/08/2019           */
/////////////////////////////////////////////////
@isTest
public class FFAWorkOrdersTest {
    @isTest static void doGetTestMethod1(){
         FFA_Site__c site = new FFA_Site__c(name='test site');
         insert site;
         
         Account acc = new Account(Name='NGGD_WM');
         insert acc;
         
         axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
         insert axsyfomlist;
         
         WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
         insert WType;
         
         Workorder wo1 = new Workorder(Batch_No__c='345678',Transaction_Type__c='',Description='',FFA_AbortSuspendReplan__c='',FFA_ArrivalDate__c=system.datetime.now(),
                FFA_ArrivalTime__c=system.datetime.now(),FFA_CompletedTerminatedCancelledText__c='',FFA_CompletionDateAndTime__c=system.datetime.now(),
                FFA_ContractorID__c=null,FFA_EmergencyFlag__c=false,FFA_EngineerContactNumber__c='',FFA_EngineerResourceID__c=null,
                FFA_JobCode__c='I1261',FFA_JobDescription__c='',FFA_JobNotes__c='',FFA_JobReplanReasonCode__c='',FFA_JobReplanReasonText__c='',
                FFA_MeterPointReferenceNumber__c='12245',FFA_MeterProvider__c='',FFA_NewAppointmentDate__c=system.datetime.now(),
                FFA_NewAppointmentTimeSlot__c='',FFA_OperationNumber__c='0010',FFA_PartialCompletion__c='',
                FFA_PurgingCompleted__c='',FFA_RequestCreatedDate__c=system.datetime.now(),FFA_RequestCreatedTime__c='',
                FFA_RequestedAppointmentDate__c=system.datetime.now(),FFA_RequestedAppointmentTimeslot__c='', 
                FFA_ServiceNotificationNumber__c='643',FFA_ServiceProviderWorkReferenceNumber__c=234,FFA_ServiceProvider__c='',
                FFA_ShipperID__c='',FFA_ShipperName__c='',Site__c=site.id,FFA_StatusReasonCode__c='',FFA_SuspendReason__c='',
                FFA_TerminatedCancelledReasonCode__c='',FFA_TerminatedReasonCode_customer__c='',
                FFA_TerminatedReasonCode_maintenence__c='',FFA_UnplannedPolicyEndDate__c=system.datetime.now(),
                FFA_UnplannedPolicyStartDate__c=system.datetime.now(),Service_Provider__c=acc.id,FFA_SiteID__c='',Status='New',WorkTypeId=WType.Id,Sync_Status__c = 'Pending');
         system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
         insert wo1;
        ServiceAppointment sa1 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa1;
         FFA_NGV_Asset__c assets = new FFA_NGV_Asset__c(FFA_Asset_Type__c='Meter',Work_Order__c=wo1.Id,FFA_Serial_Number__c='123456');
         insert assets;
       
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWorkorders/*';
        req.httpMethod = 'GET';
        //req.requestBody= Blob.valueof(CancelJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        FFAWorkOrders.doGet();
    }
    
    @isTest static void doGetTestMethod2(){
         FFA_Site__c site = new FFA_Site__c(name='test site');
         insert site;
         
         Account acc = new Account(Name='NGGD_WM');
         insert acc;
         
         axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
         insert axsyfomlist;
         
         WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
         insert WType;
         
         Workorder wo1 = new Workorder(Batch_No__c='',Transaction_Type__c='',Description='',FFA_AbortSuspendReplan__c='',FFA_ArrivalDate__c=system.datetime.now(),
                FFA_ArrivalTime__c=system.datetime.now(),FFA_CompletedTerminatedCancelledText__c='',FFA_CompletionDateAndTime__c=system.datetime.now(),
                FFA_ContractorID__c=null,FFA_EmergencyFlag__c=false,FFA_EngineerContactNumber__c='',FFA_EngineerResourceID__c=null,
                FFA_JobCode__c='I1261',FFA_JobDescription__c='',FFA_JobNotes__c='',FFA_JobReplanReasonCode__c='',FFA_JobReplanReasonText__c='',
                FFA_MeterPointReferenceNumber__c='12245',FFA_MeterProvider__c='',FFA_NewAppointmentDate__c=system.datetime.now(),
                FFA_NewAppointmentTimeSlot__c='',FFA_OperationNumber__c='0010',FFA_PartialCompletion__c='',
                FFA_PurgingCompleted__c='',FFA_RequestCreatedDate__c=system.datetime.now(),FFA_RequestCreatedTime__c='',
                FFA_RequestedAppointmentDate__c=system.datetime.now(),FFA_RequestedAppointmentTimeslot__c='', 
                FFA_ServiceNotificationNumber__c='643',FFA_ServiceProviderWorkReferenceNumber__c=234,FFA_ServiceProvider__c='',
                FFA_ShipperID__c='',FFA_ShipperName__c='',Site__c=site.id,FFA_StatusReasonCode__c='',FFA_SuspendReason__c='',
                FFA_TerminatedCancelledReasonCode__c='',FFA_TerminatedReasonCode_customer__c='',
                FFA_TerminatedReasonCode_maintenence__c='',FFA_UnplannedPolicyEndDate__c=system.datetime.now(),
                FFA_UnplannedPolicyStartDate__c=system.datetime.now(),Service_Provider__c=acc.id,FFA_SiteID__c='',Status='New',WorkTypeId=WType.Id,Sync_Status__c = 'Pending');
         system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
         insert wo1;
        
         
       
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWorkorders/*';
        req.httpMethod = 'GET';
        //req.requestBody= Blob.valueof(CancelJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        FFAWorkOrders.doGet();
    }
}