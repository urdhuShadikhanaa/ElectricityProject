/////////////////////////////////////////////////
/*          SAP-FFA CRR INTERFACE TEST      */
/*          Author: Ankit Tomar                */ 
/*          Company: Wipro Technologies        */
/*          Created Date: 20/08/2019           */
/////////////////////////////////////////////////
@isTest
public class FFAWorkOrderCRRInterfaceHandlerTest {
    
    // Cancel Test
    // Cancel operation test for single work order with success response
    @isTest
    static void testMethodForDuplicateWOs(){
        string JsonBody = '{"Cancel":[{"WorkOrderNo":"1234","CancelReasonCode":"CC","CancelReasonText":"ffffffff"},'+
            '{"WorkOrderNo":"1234","CancelReasonCode":"CC","CancelReasonText":"ffffffff"}],'+
            '"Replan":[{"WorkOrderNo":"1234","ReplanReasonCode":"CR","ReplanReasonText":"","NewAppointmentDate":"2020-01-01","NewAppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"1234","ReplanReasonCode":"CR","ReplanReasonText":"","NewAppointmentDate":"2020-01-01","NewAppointmentTimeSlot":""}],'+
            '"Reject":[{"WorkOrderNo":"1234","RejectReasonCode":"WR","RejectReasonText":""},'+
            '{"WorkOrderNo":"1234","RejectReasonCode":"WR","RejectReasonText":""}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    
    @isTest
    static void testMethodForCancelForSingle(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Cancel":{"WorkOrderNo":"'+WorkOrderName+'","CancelReasonCode":"CS","CancelReasonText":"ffffffff"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    @isTest
    static void testMethodForCancelForSingle11(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Cancel":{"WorkOrderNo":"'+WorkOrderName+'","CancelReasonCode":"CS","CancelReasonText":"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    @isTest
    static void testMethodForCancelForSingle12(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Cancel":{"WorkOrderNo":"'+WorkOrderName+'","CancelReasonCode":"CS","CancelReasonText":""}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    @isTest
    static void testMethodForCancelForSingle13(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Cancel":{"WorkOrderNo":"'+WorkOrderName+'","CancelReasonCode":"CS"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    @isTest
    static void testMethodForCancelForSingle14(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Cancel":{"WorkOrderNo":"'+WorkOrderName+'"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    
    // Cancel operation without WO number failure response
    @isTest
    static void testMethodForCancelWithoutWO(){
        string JsonBody = '{"Cancel":{"WorkOrderNo":"","CancelReasonCode":"CS","CancelReasonText":"ffffffff"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
        
    }
    
    // Cancel operation test for Multiple work order with failure and success response
    @isTest
    static void testMethodForCancelForMulti(){
        set<Id> workOrderIdsSet = new set<Id>();
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        workOrderIdsSet.add(wo1.Id);
        
        Workorder wo2 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918234', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='PHONEIX');
        insert wo2;
        ServiceAppointment sa2 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo2.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa2;
        workOrderIdsSet.add(wo2.Id);
        
        Workorder wo3 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918235', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo3;
        ServiceAppointment sa3 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo3.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa3;
        wo3.Status = 'Cancelled';
        update wo3;
        workOrderIdsSet.add(wo3.Id);
        
        Workorder wo4 = new Workorder(Status = 'In Progress',FFA_ServiceNotificationNumber__c='1918236', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo4;
        ServiceAppointment sa4 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo4.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa4;
        wo4.Status = 'Completed';
        update wo4;
        workOrderIdsSet.add(wo4.Id);
        
        Workorder wo5 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918237', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo5;
        ServiceAppointment sa5 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo5.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa5;
        wo5.Status = 'Rejected';
        update wo5;
        workOrderIdsSet.add(wo5.Id);
        
        Workorder wo6 = new Workorder(Status = 'In Progress',FFA_ServiceNotificationNumber__c='1918238', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo6;
        ServiceAppointment sa6 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo6.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa6;
        workOrderIdsSet.add(wo6.Id);
        
        Workorder wo7 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918239', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo7;
        ServiceAppointment sa7 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo7.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa7;
        workOrderIdsSet.add(wo7.Id);
        
        Workorder wo8 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918239', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo8;
        ServiceAppointment sa8 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo8.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa8;
        workOrderIdsSet.add(wo8.Id);
        
        Workorder wo9 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='19182391', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo9;
        ServiceAppointment sa9 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo9.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa9;
        workOrderIdsSet.add(wo9.Id);
        
        Workorder wo10 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='19182392', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo10;
        ServiceAppointment sa10 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo10.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa10;
        workOrderIdsSet.add(wo10.Id);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: workOrderIdsSet ];
        string WorkOrderName1 = string.valueOf(workOrder[0].WorkOrderNumber);
        string WorkOrderName2 = string.valueOf(workOrder[1].WorkOrderNumber);
        string WorkOrderName3= string.valueOf(workOrder[2].WorkOrderNumber);
        string WorkOrderName4 = string.valueOf(workOrder[3].WorkOrderNumber);
        string WorkOrderName5 = string.valueOf(workOrder[4].WorkOrderNumber);
        string WorkOrderName6 = string.valueOf(workOrder[5].WorkOrderNumber);
        string WorkOrderName7 = string.valueOf(workOrder[6].WorkOrderNumber);
        string WorkOrderName8 = string.valueOf(workOrder[7].WorkOrderNumber);
        string WorkOrderName9 = string.valueOf(workOrder[8].WorkOrderNumber);
        string WorkOrderName10 = string.valueOf(workOrder[9].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName1);
        //Response Fake
        string JsonBody = '{"Cancel":[{"WorkOrderNo":"'+WorkOrderName1+'","CancelReasonCode":"CS","CancelReasonText":"ffffffff"},'+
            '{"WorkOrderNo":"'+WorkOrderName2+'","CancelReasonCode":"CS","CancelReasonText":"ffffffff"},'+
            '{"WorkOrderNo":"'+WorkOrderName3+'","CancelReasonCode":"CS","CancelReasonText":"ffffffff"},'+
            '{"WorkOrderNo":"'+WorkOrderName4+'","CancelReasonCode":"CS","CancelReasonText":"ffffffff"},'+
            '{"WorkOrderNo":"'+WorkOrderName5+'","CancelReasonCode":"CS","CancelReasonText":"ffffffff"},'+
            '{"WorkOrderNo":"'+WorkOrderName6+'","CancelReasonCode":"CS","CancelReasonText":"ffffffff"},'+
            '{"WorkOrderNo":"'+WorkOrderName7+'","CancelReasonCode":"p","CancelReasonText":"ffffffff"},'+
            '{"WorkOrderNo":"'+WorkOrderName8+'","CancelReasonCode":"CS","CancelReasonText":""},'+
            '{"WorkOrderNo":"0000001120001","CancelReasonCode":"","CancelReasonText":""},'+
            '{"WorkOrderNo":"'+WorkOrderName9+'","CancelReasonCode":"CS","CancelReasonText":"jhfdhfdhfdhjfdjjfhjhfdhfdhjhdfjhjfhdjhfdjhfdjhjhfhfjdhjhdfjhjfdhjhfdjhjfhjhfdjhjfdhjhfdjhzsfdgfdgzfgfd"},'+
            '{"WorkOrderNo":"'+WorkOrderName10+'","CancelReasonCode":"","CancelReasonText":"hfhgfgfh"}]}';
            
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    
    // Replan Test
    // Replan operation test for single work order with success response
    @isTest
    static void testMethodForReplanForSingle(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Replan":{"WorkOrderNo":"'+WorkOrderName+'","ReplanReasonCode":"FM","ReplanReasonText":"Replan reason text","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    @isTest
    static void testMethodForReplanForSingle11(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated - Non Maintenance Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Replan":{"WorkOrderNo":"'+WorkOrderName+'","ReplanReasonCode":"FM","ReplanReasonText":"Replan reason text ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    @isTest
    static void testMethodForReplanForSingle12(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Replan":{"WorkOrderNo":"'+WorkOrderName+'","ReplanReasonCode":"FM","ReplanReasonText":"","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    @isTest
    static void testMethodForReplanForSingle13(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Replan":{"WorkOrderNo":"'+WorkOrderName+'","ReplanReasonCode":"FM","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    @isTest
    static void testMethodForReplanForSingle14(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Replan":{"WorkOrderNo":"'+WorkOrderName+'","ReplanReasonCode":"FM","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":""}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    @isTest
    static void testMethodForReplanForSingle15(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated - Maintenance Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Replan":{"WorkOrderNo":"'+WorkOrderName+'","ReplanReasonCode":"FM","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":""}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    @isTest
    static void testMethodForReplanForSingle16(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Replan":{"WorkOrderNo":"'+WorkOrderName+'","ReplanReasonCode":"FM","NewAppointmentDate":"2030-12-31"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    @isTest
    static void testMethodForReplanForSingle17(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Replan":{"WorkOrderNo":"'+WorkOrderName+'","ReplanReasonCode":"","NewAppointmentDate":"2030-12-31"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    @isTest
    static void testMethodForReplanForSingle18(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Replan":{"WorkOrderNo":"'+WorkOrderName+'","NewAppointmentDate":"2030-12-31"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    
    // Replan operation without WO number failure response
    @isTest
    static void testMethodForReplanWithoutWO(){
        string JsonBody = '{"Replan":{"WorkOrderNo":"","ReplanReasonCode":"FM","ReplanReasonText":"Replan reason text","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
        
    }
    
    // Replan operation test for Multiple work order with failure and success response
    @isTest
    static void testMethodForReplanForMulti(){
        set<Id> workOrderIdsSet = new set<Id>();
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        workOrderIdsSet.add(wo1.Id);
        
        Workorder wo2 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918234', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='PHONEIX');
        insert wo2;
        ServiceAppointment sa2 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo2.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa2;
        workOrderIdsSet.add(wo2.Id);
        
        Workorder wo3 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918235', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo3;
        ServiceAppointment sa3 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo3.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa3;
        wo3.Status = 'Cancelled';
        update wo3;
        workOrderIdsSet.add(wo3.Id);
        
        Workorder wo4 = new Workorder(Status = 'In Progress',FFA_ServiceNotificationNumber__c='1918236', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo4;
        ServiceAppointment sa4 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo4.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa4;
        wo4.Status = 'Completed';
        update wo4;
        workOrderIdsSet.add(wo4.Id);
        
        Workorder wo5 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918237', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo5;
        ServiceAppointment sa5 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo5.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa5;
        wo5.Status = 'Rejected';
        update wo5;
        workOrderIdsSet.add(wo5.Id);
        
        Workorder wo6 = new Workorder(Status = 'In Progress',FFA_ServiceNotificationNumber__c='1918238', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo6;
        ServiceAppointment sa6 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo6.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa6;
        workOrderIdsSet.add(wo6.Id);
        
        Workorder wo7 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918239', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo7;
        ServiceAppointment sa7 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo7.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa7;
        workOrderIdsSet.add(wo7.Id);
        
        Workorder wo8 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918239', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo8;
        ServiceAppointment sa8 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo8.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa8;
        workOrderIdsSet.add(wo8.Id);
        
        Workorder wo9 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='19182391', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo9;
        ServiceAppointment sa9 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo9.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa9;
        workOrderIdsSet.add(wo9.Id);
        
        Workorder wo10 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='19182392', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo10;
        ServiceAppointment sa10 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo10.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa10;
        workOrderIdsSet.add(wo10.Id);
        
        Workorder wo11 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='19182392', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo11;
        ServiceAppointment sa11 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo11.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa11;
        workOrderIdsSet.add(wo11.Id);
        
        Workorder wo12 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='19182392', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo12;
        ServiceAppointment sa12 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo12.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa12;
        workOrderIdsSet.add(wo12.Id);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: workOrderIdsSet ];
        string WorkOrderName1 = string.valueOf(workOrder[0].WorkOrderNumber);
        string WorkOrderName2 = string.valueOf(workOrder[1].WorkOrderNumber);
        string WorkOrderName3= string.valueOf(workOrder[2].WorkOrderNumber);
        string WorkOrderName4 = string.valueOf(workOrder[3].WorkOrderNumber);
        string WorkOrderName5 = string.valueOf(workOrder[4].WorkOrderNumber);
        string WorkOrderName6 = string.valueOf(workOrder[5].WorkOrderNumber);
        string WorkOrderName7 = string.valueOf(workOrder[6].WorkOrderNumber);
        string WorkOrderName8 = string.valueOf(workOrder[7].WorkOrderNumber);
        string WorkOrderName9 = string.valueOf(workOrder[8].WorkOrderNumber);
        string WorkOrderName10 = string.valueOf(workOrder[9].WorkOrderNumber);
        string WorkOrderName11 = string.valueOf(workOrder[10].WorkOrderNumber);
        string WorkOrderName12 = string.valueOf(workOrder[11].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName1);
        //Response Fake
        string JsonBody = '{"Replan":[{"WorkOrderNo":"'+WorkOrderName1+'","ReplanReasonCode":"FM","ReplanReasonText":"Replan reason text","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"},'+
            '{"WorkOrderNo":"'+WorkOrderName2+'","ReplanReasonCode":"FM","ReplanReasonText":"Replan reason text","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"},'+
            '{"WorkOrderNo":"'+WorkOrderName3+'","ReplanReasonCode":"FM","ReplanReasonText":"Replan reason text","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"},'+
            '{"WorkOrderNo":"'+WorkOrderName4+'","ReplanReasonCode":"FM","ReplanReasonText":"Replan reason text","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"},'+
            '{"WorkOrderNo":"'+WorkOrderName5+'","ReplanReasonCode":"FM","ReplanReasonText":"Replan reason text","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"},'+
            '{"WorkOrderNo":"'+WorkOrderName6+'","ReplanReasonCode":"FM","ReplanReasonText":"Replan reason text","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"},'+
            '{"WorkOrderNo":"'+WorkOrderName7+'","ReplanReasonCode":"R","ReplanReasonText":"Replan reason text","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"},'+
            '{"WorkOrderNo":"'+WorkOrderName8+'","ReplanReasonCode":"FM","ReplanReasonText":"","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"},'+
            '{"WorkOrderNo":"0000001120001","ReplanReasonCode":"FM","ReplanReasonText":"Replan reason text","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"},'+
            '{"WorkOrderNo":"'+WorkOrderName9+'","ReplanReasonCode":"FM","ReplanReasonText":"hdshjhfdsjhjfsdhgjhfgdjhjfghjhgjfhjhjfgdhjhfgdjhjhajhgajhgfhjhgjhfjhgjdhfjghfdhjhgjhfdhjgfhdjhsjgfhojhdfohgojfdhojhgfdjhjghvjghfsdojhgojhsjdfhgjhdfsojghojsfdhgojhdojfhgjofhdsjhgojfdhgojhsdojfhgohdsfgojhsdfojhgojsdhjghojfsdhgojdh","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"},'+
            '{"WorkOrderNo":"'+WorkOrderName10+'","ReplanReasonCode":"","ReplanReasonText":"Replan reason text","NewAppointmentDate":"2030-12-31","NewAppointmentTimeSlot":"AT"},'+
            '{"WorkOrderNo":"'+WorkOrderName11+'","ReplanReasonCode":"FM","ReplanReasonText":"Replan reason text","NewAppointmentDate":"2019-12-31","NewAppointmentTimeSlot":"AT"},'+
            '{"WorkOrderNo":"'+WorkOrderName12+'","ReplanReasonCode":"FM","ReplanReasonText":"Replan reason text","NewAppointmentDate":"","NewAppointmentTimeSlot":"AT"}]}';
            
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        Test.startTest();
        FFAWorkOrderCRRInterfaceHandler.doPost();
        Test.stopTest();
    }
    
    // Reject Test
    // Reject operation test for single work order with success response
    @isTest
    static void testMethodForRejectForSingle(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Reject":{"WorkOrderNo":"'+WorkOrderName+'","RejectReasonCode":"WM01","RejectReasonText":"ffffffff"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    @isTest
    static void testMethodForRejectForSingle11(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fakefffffffff
        string JsonBody = '{"Reject":{"WorkOrderNo":"'+WorkOrderName+'","RejectReasonCode":"WM01","RejectReasonText":"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    @isTest
    static void testMethodForRejectForSingle12(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Reject":{"WorkOrderNo":"'+WorkOrderName+'","RejectReasonCode":"WM01","RejectReasonText":""}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    @isTest
    static void testMethodForRejectForSingle13(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName);
        //Response Fake
        string JsonBody = '{"Reject":{"WorkOrderNo":"'+WorkOrderName+'","RejectReasonCode":"WM01"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    
    // Reject operation without WO number failure response
    @isTest
    static void testMethodForRejectWithoutWO(){
        string JsonBody = '{"Reject":{"WorkOrderNo":"","RejectReasonCode":"WM01","RejectReasonText":"ffffffff"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
        
    }
    
    // Reject operation test for Multiple work order with failure and success response
    @isTest
    static void testMethodForRejectForMulti(){
        set<Id> workOrderIdsSet = new set<Id>();
        FFA_Site__c site = new FFA_Site__c(name='test site',FFA_PostTown__c = 'MILTON KEYNES',FFA_PostcodeIncode__c='3PF',FFA_PostcodeOutcode__c='MK2',FFA_BuildingName__c='somex',FFA_BuildingNumber__c='30',FFA_PrincipalStreet__c='LAGGAN COURT');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW',FFA_JobCode__c='MIS D900R');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        workOrderIdsSet.add(wo1.Id);
        
        Workorder wo2 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918234', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='PHONEIX');
        insert wo2;
        ServiceAppointment sa2 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo2.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa2;
        workOrderIdsSet.add(wo2.Id);
        
        Workorder wo3 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918235', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo3;
        ServiceAppointment sa3 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo3.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa3;
        wo3.Status = 'Cancelled';
        update wo3;
        workOrderIdsSet.add(wo3.Id);
        
        Workorder wo4 = new Workorder(Status = 'In Progress',FFA_ServiceNotificationNumber__c='1918236', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo4;
        ServiceAppointment sa4 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo4.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa4;
        wo4.Status = 'Completed';
        update wo4;
        workOrderIdsSet.add(wo4.Id);
        
        Workorder wo5 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918237', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo5;
        ServiceAppointment sa5 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo5.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa5;
        wo5.Status = 'Rejected';
        update wo5;
        workOrderIdsSet.add(wo5.Id);
        
        Workorder wo6 = new Workorder(Status = 'In Progress',FFA_ServiceNotificationNumber__c='1918238', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo6;
        ServiceAppointment sa6 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo6.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa6;
        workOrderIdsSet.add(wo6.Id);
        
        Workorder wo7 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918239', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo7;
        ServiceAppointment sa7 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo7.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa7;
        workOrderIdsSet.add(wo7.Id);
        
        Workorder wo8 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918239', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo8;
        ServiceAppointment sa8 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo8.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa8;
        workOrderIdsSet.add(wo8.Id);
        
        Workorder wo9 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='19182391', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo9;
        ServiceAppointment sa9 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo9.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa9;
        workOrderIdsSet.add(wo9.Id);
        
        Workorder wo10 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='19182392', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo10;
        ServiceAppointment sa10 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo10.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa10;
        workOrderIdsSet.add(wo10.Id);
        
        Workorder wo11 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='19182392', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo11;
        ServiceAppointment sa11 = new ServiceAppointment(Status = 'Scheduled', Duration=120,DurationType='Hours',ParentRecordId=wo11.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=System.Datetime.now(),SchedEndTime=System.Datetime.now().addHours(23));
        insert sa11;
        workOrderIdsSet.add(wo11.Id);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: workOrderIdsSet ];
        string WorkOrderName1 = string.valueOf(workOrder[0].WorkOrderNumber);
        string WorkOrderName2 = string.valueOf(workOrder[1].WorkOrderNumber);
        string WorkOrderName3= string.valueOf(workOrder[2].WorkOrderNumber);
        string WorkOrderName4 = string.valueOf(workOrder[3].WorkOrderNumber);
        string WorkOrderName5 = string.valueOf(workOrder[4].WorkOrderNumber);
        string WorkOrderName6 = string.valueOf(workOrder[5].WorkOrderNumber);
        string WorkOrderName7 = string.valueOf(workOrder[6].WorkOrderNumber);
        string WorkOrderName8 = string.valueOf(workOrder[7].WorkOrderNumber);
        string WorkOrderName9 = string.valueOf(workOrder[8].WorkOrderNumber);
        string WorkOrderName10 = string.valueOf(workOrder[9].WorkOrderNumber);
        string WorkOrderName11 = string.valueOf(workOrder[10].WorkOrderNumber);
        system.debug('Work ORder Number === '+WorkOrderName1);
        //Response Fake
        string JsonBody = '{"Reject":[{"WorkOrderNo":"'+WorkOrderName1+'","RejectReasonCode":"WM01","RejectReasonText":"ffffffff"},'+
            '{"WorkOrderNo":"'+WorkOrderName2+'","RejectReasonCode":"WM01","RejectReasonText":"ffffffff"},'+
            '{"WorkOrderNo":"'+WorkOrderName3+'","RejectReasonCode":"WM01","RejectReasonText":"ffffffff"},'+
            '{"WorkOrderNo":"'+WorkOrderName4+'","RejectReasonCode":"WM01","RejectReasonText":"ffffffff"},'+
            '{"WorkOrderNo":"'+WorkOrderName5+'","RejectReasonCode":"WM01","RejectReasonText":"ffffffff"},'+
            '{"WorkOrderNo":"'+WorkOrderName6+'","RejectReasonCode":"WM01","RejectReasonText":"ffffffff"},'+
            '{"WorkOrderNo":"'+WorkOrderName7+'","RejectReasonCode":"re","RejectReasonText":"ffffffff"},'+
            '{"WorkOrderNo":"'+WorkOrderName8+'","RejectReasonCode":"WM01","RejectReasonText":""},'+
            '{"WorkOrderNo":"0000001120001","RejectReasonCode":"","RejectReasonText":""},'+
            '{"WorkOrderNo":"'+WorkOrderName9+'","RejectReasonCode":"WM01","RejectReasonText":"jhfdhfdhfdhjfdjjfhjhfdhfdhjhdfjhjfhdjhfdjhfdjhjhfhfjdhjhdfjhjfdhjhfdjhjfhjhfdjhjfdhjhfdjhzsfdgfdgzfgfdjsdfhaghhghahgvhawuerhtjhdjsaogaospdjfgashdiguhagduyfgauysdgufgyagdsuygfugadsgfyadgsfygysad"},'+
            '{"WorkOrderNo":"'+WorkOrderName10+'","RejectReasonCode":"","RejectReasonText":"hfhgfgfh"},'+
            '{"WorkOrderNo":"'+WorkOrderName11+'","RejectReasonCode":"","RejectReasonText":"hfhgfgfh"}]}';
            
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    
    //Cancel/Replan/Reject operation Test
    @isTest
    static void testMethodForAll(){
        set<Id> workOrderIdsSet = new set<Id>();
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        workOrderIdsSet.add(wo1.Id);
        
        Workorder wo2 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918234', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='PHONEIX');
        insert wo2;
        ServiceAppointment sa2 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo2.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa2;
        workOrderIdsSet.add(wo2.Id);
        
        Workorder wo3 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918235', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo3;
        ServiceAppointment sa3 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo3.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa3;
        
        workOrderIdsSet.add(wo3.Id);
        
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: workOrderIdsSet ];
        string WorkOrderName1 = string.valueOf(workOrder[0].WorkOrderNumber);
        string WorkOrderName2 = string.valueOf(workOrder[1].WorkOrderNumber);
        string WorkOrderName3= string.valueOf(workOrder[2].WorkOrderNumber);
        
        system.debug('Work ORder Number === '+WorkOrderName1);
        //Response Fake
        string JsonBody = '{"Reject":{"WorkOrderNo":"'+WorkOrderName1+'","RejectReasonCode":"WM01","RejectReasonText":"ffffffff"},'+
            '"Cancel":{"WorkOrderNo":"'+WorkOrderName2+'","CancelReasonCode":"CS","CancelReasonText":"ffffffff"},'+
            '"Replan":{"WorkOrderNo":"'+WorkOrderName3+'","ReplanReasonCode":"FM","ReplanReasonText":"Replan reason text","NewAppointmentDate":"2030-12-31","NewAppointmentSlot":"AT"}}';
            
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    
    //Cancel/Replan operation Test
    @isTest
    static void testMethodForCancelAndReplan(){
        set<Id> workOrderIdsSet = new set<Id>();
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        workOrderIdsSet.add(wo1.Id);
        
        Workorder wo2 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918234', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='PHONEIX');
        insert wo2;
        ServiceAppointment sa2 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo2.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa2;
        workOrderIdsSet.add(wo2.Id);
        
        Workorder wo3 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918235', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo3;
        ServiceAppointment sa3 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo3.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa3;
        
        workOrderIdsSet.add(wo3.Id);
        
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: workOrderIdsSet ];
        //string WorkOrderName1 = string.valueOf(workOrder[0].WorkOrderNumber);
        string WorkOrderName2 = string.valueOf(workOrder[1].WorkOrderNumber);
        string WorkOrderName3= string.valueOf(workOrder[2].WorkOrderNumber);
        
        system.debug('Work ORder Number === '+WorkOrderName2);
        //Response Fake
        string JsonBody = '{"Cancel":{"WorkOrderNo":"'+WorkOrderName2+'","CancelReasonCode":"CS","CancelReasonText":"ffffffff"},'+
            '"Replan":{"WorkOrderNo":"'+WorkOrderName3+'","ReplanReasonCode":"FM","ReplanReasonText":"Replan reason text","NewAppointmentDate":"2030-12-31","NewAppointmentSlot":"AT"}}';
            
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    
    //Cancel/Reject operation Test
    @isTest
    static void testMethodForCancelAndReject(){
        set<Id> workOrderIdsSet = new set<Id>();
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        workOrderIdsSet.add(wo1.Id);
        
        Workorder wo2 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918234', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='PHONEIX');
        insert wo2;
        ServiceAppointment sa2 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo2.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa2;
        workOrderIdsSet.add(wo2.Id);
        
        Workorder wo3 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918235', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo3;
        ServiceAppointment sa3 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo3.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa3;
        
        workOrderIdsSet.add(wo3.Id);
        
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: workOrderIdsSet ];
        string WorkOrderName1 = string.valueOf(workOrder[0].WorkOrderNumber);
        string WorkOrderName2 = string.valueOf(workOrder[1].WorkOrderNumber);
        string WorkOrderName3= string.valueOf(workOrder[2].WorkOrderNumber);
        
        system.debug('Work ORder Number === '+WorkOrderName1);
        //Response Fake
        string JsonBody = '{"Reject":{"WorkOrderNo":"'+WorkOrderName1+'","RejectReasonCode":"WM01","RejectReasonText":"ffffffff"},'+
            '"Cancel":{"WorkOrderNo":"'+WorkOrderName2+'","CancelReasonCode":"CS","CancelReasonText":"ffffffff"}}';
            
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    
    //Replan/Reject operation Test
    @isTest
    static void testMethodForReplanAndReject(){
        set<Id> workOrderIdsSet = new set<Id>();
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGGDxzvcxz_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType; 
        
        Workorder wo1 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        workOrderIdsSet.add(wo1.Id);
        
        Workorder wo2 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918234', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='PHONEIX');
        insert wo2;
        ServiceAppointment sa2 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo2.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa2;
        workOrderIdsSet.add(wo2.Id);
        
        Workorder wo3 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='1918235', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_UnplannedPolicyStartDate__c=System.datetime.now(),FFA_UnplannedPolicyEndDate__c=System.datetime.now().addMonths(6),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_Sender_ID__c='RAINBOW');
        insert wo3;
        ServiceAppointment sa3 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo3.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa3;
        
        workOrderIdsSet.add(wo3.Id);
        
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: workOrderIdsSet ];
        string WorkOrderName1 = string.valueOf(workOrder[0].WorkOrderNumber);
        string WorkOrderName2 = string.valueOf(workOrder[1].WorkOrderNumber);
        string WorkOrderName3= string.valueOf(workOrder[2].WorkOrderNumber);
        
        system.debug('Work ORder Number === '+WorkOrderName1);
        //Response Fake
        string JsonBody = '{"Reject":{"WorkOrderNo":"'+WorkOrderName1+'","RejectReasonCode":"WM01","RejectReasonText":"ffffffff"},'+
            '"Replan":{"WorkOrderNo":"'+WorkOrderName3+'","ReplanReasonCode":"FM","ReplanReasonText":"Replan reason text","NewAppointmentDate":"2030-12-31","NewAppointmentSlot":"AT"}}';
            
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAWOCRRHandlerInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderCRRInterfaceHandler.doPost();
    }
    
    
}