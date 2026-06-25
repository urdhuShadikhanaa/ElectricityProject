//////////////////////////////////////////////////////////////
/*          SAP-FFA SCHEDULE/ACKNOWLEDGE INTERFACE TEST     */
/*          Author: Ankit Tomar                             */ 
/*          Company: Wipro Technologies                     */
/*          Created Date: 20/08/2019                        */
//////////////////////////////////////////////////////////////

@isTest
public class FFAWorkOrderAssignedTest{
    @isTest
    static void testMethodForDuplicateWOInSch(){
        //Response Fake
        string JsonBody = '{"Schedule":[{"WorkOrderNo":"00000","EngineerID":"bp@w1.com","AppointmentDate":""},{"WorkOrderNo":"1234","EngineerID":"bp@w1.com","AppointmentDate":""},{"WorkOrderNo":"1234","EngineerID":"bp@w1.com","AppointmentDate":""},{"WorkOrderNo":"","EngineerID":"bp@w1.com","AppointmentDate":""}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderAssigned.doPost();
    }
    
    @isTest
    static void testMethodForDuplicateWOInUnassign(){
        //Response Fake
        string JsonBody = '{"Unassign":[{"WorkOrderNo":"00000"},{"WorkOrderNo":"1234"},{"WorkOrderNo":"1234"},{"WorkOrderNo":""}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderAssigned.doPost();
    }
    /*
    @isTest(SeeAllData=true)
    static void testMethodOne(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        Profile pr = [select Id,Name from Profile where Name = 'FFA Service Provider Engineer'];
        User users = [select Id, Username, ProfileId from User where ProfileId =: pr.id limit 1];
        string EngineerUsername = users.Username;
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId from ServiceTerritoryMember where ServiceTerritoryId!=null limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo1 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='1918233', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo1.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa;
        AssignedResource ar = new AssignedResource();
        if(stm!=null){ar.ServiceResourceId = stm.ServiceResourceId;}
            ar.ServiceAppointmentId=sa.Id;
            insert ar;
        sa.status = 'Scheduled';
        update sa;
        list<WorkOrder> workOrder = [select id , WorkOrderNumber from WorkOrder where Id =: wo1.Id limit 1];
        string WorkOrderName = string.valueOf(workOrder[0].WorkOrderNumber);
        
        Workorder wo2 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='19182334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo2;
        ServiceAppointment sa2 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo2.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa2;
        list<WorkOrder> workOrder2 = [select id , WorkOrderNumber from WorkOrder where Id =: wo2.Id limit 1];
        string WorkOrderName2 = string.valueOf(workOrder2[0].WorkOrderNumber);
        
        Workorder wo3 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo3;
        ServiceAppointment sa3 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo3.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa3;
        list<WorkOrder> workOrder3 = [select id , WorkOrderNumber from WorkOrder where Id =: wo3.Id limit 1];
        string WorkOrderName3 = string.valueOf(workOrder3[0].WorkOrderNumber);
        
        Workorder wo4 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='PHOENIX',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo4;
        ServiceAppointment sa4 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo4.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa4;
        list<WorkOrder> workOrder4 = [select id , WorkOrderNumber from WorkOrder where Id =: wo4.Id limit 1];
        string WorkOrderName4 = string.valueOf(workOrder4[0].WorkOrderNumber);
        
        Workorder wo5 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo5;
        ServiceAppointment sa5 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo5.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa5;
        list<WorkOrder> workOrder5 = [select id , WorkOrderNumber from WorkOrder where Id =: wo5.Id limit 1];
        string WorkOrderName5 = string.valueOf(workOrder5[0].WorkOrderNumber);
        
        Workorder wo6 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='PHOENIX',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo6;
        ServiceAppointment sa6 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo6.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa6;
        list<WorkOrder> workOrder6 = [select id , WorkOrderNumber from WorkOrder where Id =: wo6.Id limit 1];
        string WorkOrderName6 = string.valueOf(workOrder6[0].WorkOrderNumber);
        
        Workorder wo7 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo7;
        ServiceAppointment sa7 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo7.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa7;
        ServiceAppointment sa77 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo7.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa77;
        list<WorkOrder> workOrder7 = [select id , WorkOrderNumber from WorkOrder where Id =: wo7.Id limit 1];
        string WorkOrderName7 = string.valueOf(workOrder7[0].WorkOrderNumber);
        
        Workorder wo8 = new Workorder(Status = 'In Progress',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='PHOENIX',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo8;
        ServiceAppointment sa8 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo8.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa8;
        list<WorkOrder> workOrder8 = [select id , WorkOrderNumber from WorkOrder where Id =: wo8.Id limit 1];
        string WorkOrderName8 = string.valueOf(workOrder8[0].WorkOrderNumber);
        
        //Response Fake
        string JsonBody = '{"Unassign":[{"WorkOrderNo":""},{"WorkOrderNo":"'+WorkOrderName2+'"},{"WorkOrderNo":"'+WorkOrderName+'"},{"WorkOrderNo":"1234"},{"WorkOrderNo":"1234"},{"WorkOrderNo":"12345"}],'+
            '"Schedule":[{"WorkOrderNo":"'+WorkOrderName3+'","EngineerID":"","AppointmentDate":"2020-01-01","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName4+'","EngineerID":"xyx@abc.com","AppointmentDate":"","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName5+'","EngineerID":"xyx@abc.com","AppointmentDate":"2020-01-01","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName7+'","EngineerID":"xyx@abc.com","AppointmentDate":"2020-01-01","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName8+'","EngineerID":"xyx@abc.com","AppointmentDate":"2020-01-01","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName6+'","EngineerID":"xyx@abc.com","AppointmentDate":"","AppointmentTimeSlot":""}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost(); 
        Test.stopTest();
    }
    */
    @isTest(SeeAllData=true)
    static void testMethodTen(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        Profile pr = [select Id,Name from Profile where Name = 'FFA Service Provider Engineer'];
        User users = [select Id, Username, ProfileId from User where ProfileId =: pr.id limit 1];
        string EngineerUsername = users.Username;
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        Workorder wo9 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='PHOENIX',FFA_RequestedAppointmentDate__c=datetime.newInstance(2050,03,02),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo9;
        ServiceAppointment sa9 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo9.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa9;
        list<WorkOrder> workOrder9 = [select id , WorkOrderNumber from WorkOrder where Id =: wo9.Id limit 1];
        string WorkOrderName9 = string.valueOf(workOrder9[0].WorkOrderNumber);
        
        Workorder wo10 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',FFA_RequestedAppointmentDate__c=datetime.newInstance(2050,03,02),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo10;
        ServiceAppointment sa10 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo10.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa10;
        list<WorkOrder> workOrder10 = [select id , WorkOrderNumber from WorkOrder where Id =: wo10.Id limit 1];
        string WorkOrderName10 = string.valueOf(workOrder10[0].WorkOrderNumber);
        
        Workorder wo11 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='PHOENIX',FFA_RequestedAppointmentDate__c=datetime.newInstance(2050,03,02),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo11;
        ServiceAppointment sa11 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo11.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa11;
        list<WorkOrder> workOrder11 = [select id , WorkOrderNumber from WorkOrder where Id =: wo11.Id limit 1];
        string WorkOrderName11 = string.valueOf(workOrder11[0].WorkOrderNumber);
        
        Workorder wo12 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',FFA_RequestedAppointmentDate__c=datetime.newInstance(2050,03,02),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo12;
        ServiceAppointment sa12 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo12.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa12;
        list<WorkOrder> workOrder12 = [select id , WorkOrderNumber from WorkOrder where Id =: wo12.Id limit 1];
        string WorkOrderName12 = string.valueOf(workOrder12[0].WorkOrderNumber);
        
        //Response Fake
        
        string JsonBody = '{"Schedule":[{"WorkOrderNo":"'+WorkOrderName9+'","EngineerID":"'+EngineerUsername+'","AppointmentDate":"","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName10+'","EngineerID":"'+EngineerUsername+'","AppointmentDate":"","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName11+'","EngineerID":"bp@w1.com","AppointmentDate":"","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName12+'","EngineerID":"bp@w1.com","AppointmentDate":"","AppointmentTimeSlot":""}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost(); 
    }
   
    @isTest(SeeAllData=true)
    static void testMethodTwo(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo3 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823343', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo3;
        ServiceAppointment sa3 = new ServiceAppointment(Status = 'Completed', Duration=120,DurationType='Hours',ParentRecordId=wo3.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa3;
        list<WorkOrder> workOrder3 = [select id , WorkOrderNumber from WorkOrder where Id =: wo3.Id limit 1];
        string WorkOrderName3 = string.valueOf(workOrder3[0].WorkOrderNumber);
        
        //Response Fake
        
        string JsonBody = '{"Unassign":[{"WorkOrderNo":"'+WorkOrderName3+'"},{"WorkOrderNo":""},{"WorkOrderNo":""},{"WorkOrderNo":""},{"WorkOrderNo":"1234"},{"WorkOrderNo":"1234"},{"WorkOrderNo":"12345"}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost(); 
    }
    
    @isTest(SeeAllData=true)
    static void testMethodThree(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo3 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823343', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo3;
        ServiceAppointment sa3 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo3.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa3;
        sa3.status = 'Scheduled';
        update sa3;
        list<WorkOrder> workOrder3 = [select id , WorkOrderNumber from WorkOrder where Id =: wo3.Id limit 1];
        string WorkOrderName3 = string.valueOf(workOrder3[0].WorkOrderNumber);
        
        //Response Fake
        
        string JsonBody = '{"Unassign":[{"WorkOrderNo":"'+WorkOrderName3+'"},{"WorkOrderNo":""},{"WorkOrderNo":""},{"WorkOrderNo":""},{"WorkOrderNo":"1234"},{"WorkOrderNo":"1234"},{"WorkOrderNo":"12345"}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost(); 
    }
    
    @isTest(SeeAllData=true)
    static void testMethodFour(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo3 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823343', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo3;
        list<WorkOrder> workOrder3 = [select id , WorkOrderNumber from WorkOrder where Id =: wo3.Id limit 1];
        string WorkOrderName3 = string.valueOf(workOrder3[0].WorkOrderNumber);
        
        
        
        //Response Fake
        
        string JsonBody = '{"Unassign":[{"WorkOrderNo":"'+WorkOrderName3+'"},{"WorkOrderNo":""},{"WorkOrderNo":""},{"WorkOrderNo":""},{"WorkOrderNo":"1234"},{"WorkOrderNo":"1234"},{"WorkOrderNo":"12345"}],'+
            '"Schedule":[{"WorkOrderNo":"","EngineerID":"xyx@abc.com","AppointmentDate":"2020-01-01","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"1234","EngineerID":"xyx@abc.com","AppointmentDate":"2020-01-01","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"1234","EngineerID":"xyx@abc.com","AppointmentDate":"2020-01-01","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"2345","EngineerID":"xyx@abc.com","AppointmentDate":"2020-01-01","AppointmentTimeSlot":""}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost(); 
    }
    
    /*@isTest(SeeAllData=true)*/
    static void testMethodFive(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo13 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='PHOENIX',FFA_RequestedAppointmentDate__c=datetime.newInstance(2050,03,02),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo13;
        ServiceAppointment sa13 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo13.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa13;
        AssignedResource ar13 = new AssignedResource();
        if(stm!=null){ar13.ServiceResourceId = stm.ServiceResourceId;}
            ar13.ServiceAppointmentId=sa13.Id;
            insert ar13;
        sa13.status = 'Scheduled';
        update sa13;
        list<WorkOrder> workOrder13 = [select id , WorkOrderNumber from WorkOrder where Id =: wo13.Id limit 1];
        string WorkOrderName13 = string.valueOf(workOrder13[0].WorkOrderNumber);
        
        Workorder wo14 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',FFA_RequestedAppointmentDate__c=datetime.newInstance(2050,03,02),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo14;
        ServiceAppointment sa14 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo14.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa14;
        AssignedResource ar14 = new AssignedResource();
        if(stm!=null){ar14.ServiceResourceId = stm.ServiceResourceId;}
            ar14.ServiceAppointmentId=sa14.Id;
            insert ar14;
        sa14.status = 'Scheduled';
        update sa14;
        list<WorkOrder> workOrder14 = [select id , WorkOrderNumber from WorkOrder where Id =: wo14.Id limit 1];
        string WorkOrderName14 = string.valueOf(workOrder14[0].WorkOrderNumber);
        
        
        
        string JsonBody = '{"Schedule":[{"WorkOrderNo":"'+WorkOrderName13+'","EngineerID":"xyx@abc.com","AppointmentDate":"","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName14+'","EngineerID":"xyx@abc.com","AppointmentDate":"","AppointmentTimeSlot":""}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost();
    }
    
    /*@isTest(SeeAllData=true)*/
    static void testMethodEleven(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        Workorder wo15 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='PHOENIX',FFA_RequestedAppointmentDate__c=datetime.newInstance(2050,03,02),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo15;
        ServiceAppointment sa15 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo15.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa15;
        AssignedResource ar15 = new AssignedResource();
        if(stm!=null){ar15.ServiceResourceId = stm.ServiceResourceId;}
            ar15.ServiceAppointmentId=sa15.Id;
            insert ar15;
        sa15.status = 'Scheduled';
        update sa15;
        list<WorkOrder> workOrder15 = [select id , WorkOrderNumber from WorkOrder where Id =: wo15.Id limit 1];
        string WorkOrderName15 = string.valueOf(workOrder15[0].WorkOrderNumber);
        
        Workorder wo16 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',FFA_RequestedAppointmentDate__c=datetime.newInstance(2050,03,02),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo16;
        ServiceAppointment sa16 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo16.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa16;
        AssignedResource ar16 = new AssignedResource();
        if(stm!=null){ar16.ServiceResourceId = stm.ServiceResourceId;}
            ar16.ServiceAppointmentId=sa16.Id;
            insert ar16;
        sa16.status = 'Scheduled';
        update sa16;
        list<WorkOrder> workOrder16 = [select id , WorkOrderNumber from WorkOrder where Id =: wo16.Id limit 1];
        string WorkOrderName16 = string.valueOf(workOrder16[0].WorkOrderNumber);
        
        string JsonBody = '{"Schedule":[{"WorkOrderNo":"'+WorkOrderName15+'","EngineerID":"bp@w1.com","AppointmentDate":"","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName16+'","EngineerID":"bp@w1.com","AppointmentDate":"","AppointmentTimeSlot":""}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost();
    }
    
    @isTest(SeeAllData=true)
    static void testMethodSix(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo4 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='PHOENIX',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo4;
        ServiceAppointment sa4 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo4.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa4;
        list<WorkOrder> workOrder4 = [select id , WorkOrderNumber from WorkOrder where Id =: wo4.Id limit 1];
        string WorkOrderName4 = string.valueOf(workOrder4[0].WorkOrderNumber);
        
        Workorder wo5 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='PHOENIX',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo5;
        ServiceAppointment sa5 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo5.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa5;
        list<WorkOrder> workOrder5 = [select id , WorkOrderNumber from WorkOrder where Id =: wo5.Id limit 1];
        string WorkOrderName5 = string.valueOf(workOrder5[0].WorkOrderNumber);
        
        Workorder wo6 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='PHOENIX',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo6;
        ServiceAppointment sa6 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo6.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa6;
        list<WorkOrder> workOrder6 = [select id , WorkOrderNumber from WorkOrder where Id =: wo6.Id limit 1];
        string WorkOrderName6 = string.valueOf(workOrder6[0].WorkOrderNumber);
        
        Workorder wo7 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='PHOENIX',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo7;
        ServiceAppointment sa7 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo7.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa7;
        list<WorkOrder> workOrder7 = [select id , WorkOrderNumber from WorkOrder where Id =: wo7.Id limit 1];
        string WorkOrderName7 = string.valueOf(workOrder7[0].WorkOrderNumber);
        
        Workorder wo8 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',Notification_Type__c='',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo8;
        ServiceAppointment sa8 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo8.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa8;
        list<WorkOrder> workOrder8 = [select id , WorkOrderNumber from WorkOrder where Id =: wo8.Id limit 1];
        string WorkOrderName8 = string.valueOf(workOrder8[0].WorkOrderNumber);
        
        Workorder wo9 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',Notification_Type__c='Y3',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo9;
        ServiceAppointment sa9 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo9.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa9;
        list<WorkOrder> workOrder9 = [select id , WorkOrderNumber from WorkOrder where Id =: wo9.Id limit 1];
        string WorkOrderName9 = string.valueOf(workOrder9[0].WorkOrderNumber);
        
        
        
        string JsonBody = '{"Schedule":[{"WorkOrderNo":"'+WorkOrderName4+'","EngineerID":"xyx@abc.com","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName5+'","EngineerID":"xyx@abc.com","AppointmentDate":"2050-05-01","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName6+'","EngineerID":"xyx@abc.com","AppointmentDate":"2050-05-01","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName7+'","EngineerID":"xyx@abc.com","AppointmentDate":"2050-09-01","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName8+'","EngineerID":"xyx@abc.com","AppointmentDate":"2050-09-01","AppointmentTimeSlot":"ee"},'+
            '{"WorkOrderNo":"'+WorkOrderName9+'","EngineerID":"xyx@abc.com","AppointmentDate":"2050-09-01","AppointmentTimeSlot":"AM"}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost();
    }
    
    /*@isTest(SeeAllData=true)*/
    static void testMethodTwelve(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        Workorder wo13 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='PHOENIX',FFA_RequestedAppointmentDate__c=datetime.newInstance(2050,03,02),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo13;
        ServiceAppointment sa13 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo13.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa13;
        AssignedResource ar13 = new AssignedResource();
        if(stm!=null){ar13.ServiceResourceId = stm.ServiceResourceId;}
            ar13.ServiceAppointmentId=sa13.Id;
            insert ar13;
        sa13.status = 'Scheduled';
        update sa13;
        list<WorkOrder> workOrder13 = [select id , WorkOrderNumber from WorkOrder where Id =: wo13.Id limit 1];
        string WorkOrderName13 = string.valueOf(workOrder13[0].WorkOrderNumber);
        
        Workorder wo14 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',FFA_RequestedAppointmentDate__c=datetime.newInstance(2050,03,02),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo14;
        ServiceAppointment sa14 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo14.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa14;
        AssignedResource ar14 = new AssignedResource();
        if(stm!=null){ar14.ServiceResourceId = stm.ServiceResourceId;}
            ar14.ServiceAppointmentId=sa14.Id;
            insert ar14;
        sa14.status = 'Scheduled';
        update sa14;
        list<WorkOrder> workOrder14 = [select id , WorkOrderNumber from WorkOrder where Id =: wo14.Id limit 1];
        string WorkOrderName14 = string.valueOf(workOrder14[0].WorkOrderNumber);
        
        string JsonBody = '{"Schedule":[{"WorkOrderNo":"'+WorkOrderName13+'","EngineerID":"xyx@abc.com","AppointmentDate":"","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName14+'","EngineerID":"xyx@abc.com","AppointmentDate":"","AppointmentTimeSlot":""}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost();
    }
    
    /*@isTest(SeeAllData=true)*/
    static void testMethodFourteen(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        Workorder wo15 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='PHOENIX',FFA_RequestedAppointmentDate__c=datetime.newInstance(2050,03,02),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo15;
        ServiceAppointment sa15 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo15.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa15;
        AssignedResource ar15 = new AssignedResource();
        if(stm!=null){ar15.ServiceResourceId = stm.ServiceResourceId;}
            ar15.ServiceAppointmentId=sa15.Id;
            insert ar15;
        sa15.status = 'Scheduled';
        update sa15;
        list<WorkOrder> workOrder15 = [select id , WorkOrderNumber from WorkOrder where Id =: wo15.Id limit 1];
        string WorkOrderName15 = string.valueOf(workOrder15[0].WorkOrderNumber);
        
        Workorder wo16 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',FFA_RequestedAppointmentDate__c=datetime.newInstance(2050,03,02),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo16;
        ServiceAppointment sa16 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo16.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa16;
        AssignedResource ar16 = new AssignedResource();
        if(stm!=null){ar16.ServiceResourceId = stm.ServiceResourceId;}
            ar16.ServiceAppointmentId=sa16.Id;
            insert ar16;
        sa16.status = 'Scheduled';
        update sa16;
        list<WorkOrder> workOrder16 = [select id , WorkOrderNumber from WorkOrder where Id =: wo16.Id limit 1];
        string WorkOrderName16 = string.valueOf(workOrder16[0].WorkOrderNumber);
        
        string JsonBody = '{"Schedule":[{"WorkOrderNo":"'+WorkOrderName15+'","EngineerID":"xyx@abc.com","AppointmentDate":"","AppointmentTimeSlot":""},'+
            '{"WorkOrderNo":"'+WorkOrderName16+'","EngineerID":"xyx@abc.com","AppointmentDate":"","AppointmentTimeSlot":""}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost();
    }
    
    /*@isTest(SeeAllData=true)*/
    static void testMethodSeven(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo5 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',Notification_Type__c='Y3',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo5;
        ServiceAppointment sa5 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo5.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa5;
        list<WorkOrder> workOrder5 = [select id , WorkOrderNumber from WorkOrder where Id =: wo5.Id limit 1];
        string WorkOrderName5 = string.valueOf(workOrder5[0].WorkOrderNumber);
        
        Workorder wo6 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',Notification_Type__c='Y3',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo6;
        ServiceAppointment sa6 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo6.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa6;
        list<WorkOrder> workOrder6 = [select id , WorkOrderNumber from WorkOrder where Id =: wo6.Id limit 1];
        string WorkOrderName6 = string.valueOf(workOrder6[0].WorkOrderNumber);
        
        Workorder wo7 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',Notification_Type__c='Y3',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo7;
        ServiceAppointment sa7 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo7.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa7;
        AssignedResource ar7 = new AssignedResource();
        if(stm!=null){ar7.ServiceResourceId = stm.ServiceResourceId;}
            ar7.ServiceAppointmentId=sa7.Id;
            insert ar7;
        sa7.status = 'Scheduled';
        update sa7;
        list<WorkOrder> workOrder7 = [select id , WorkOrderNumber from WorkOrder where Id =: wo7.Id limit 1];
        string WorkOrderName7 = string.valueOf(workOrder7[0].WorkOrderNumber);
        
        
        
        string JsonBody = '{"Schedule":[{"WorkOrderNo":"'+WorkOrderName5+'","AppointmentDate":"2050-09-01"},'+
            '{"WorkOrderNo":"'+WorkOrderName6+'","EngineerID":"","AppointmentDate":"2050-09-01"},'+
            '{"WorkOrderNo":"'+WorkOrderName7+'","EngineerID":"xyx@abc.com","AppointmentDate":""}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost();
    }
    
    @isTest(SeeAllData=true)
    static void testMethodThriteen(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo9 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',Notification_Type__c='Y3',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo9;
        ServiceAppointment sa9 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo9.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa9;
        AssignedResource ar9 = new AssignedResource();
        if(stm!=null){ar9.ServiceResourceId = stm.ServiceResourceId;}
            ar9.ServiceAppointmentId=sa9.Id;
            insert ar9;
        sa9.status = 'Scheduled';
        update sa9;
        list<WorkOrder> workOrder9 = [select id , WorkOrderNumber from WorkOrder where Id =: wo9.Id limit 1];
        string WorkOrderName9 = string.valueOf(workOrder9[0].WorkOrderNumber);
        
        string JsonBody = '{"Schedule":[{"WorkOrderNo":"'+WorkOrderName9+'","EngineerID":"xyx@abc.com"}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost();
    }
    
    @isTest(SeeAllData=true)
    static void testMethodSixteen(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo8 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',Notification_Type__c='Y3',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo8;
        ServiceAppointment sa8 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo8.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa8;
        AssignedResource ar8 = new AssignedResource();
        if(stm!=null){ar8.ServiceResourceId = stm.ServiceResourceId;}
            ar8.ServiceAppointmentId=sa8.Id;
            insert ar8;
        sa8.status = 'Scheduled';
        update sa8;
        list<WorkOrder> workOrder8 = [select id , WorkOrderNumber from WorkOrder where Id =: wo8.Id limit 1];
        string WorkOrderName8 = string.valueOf(workOrder8[0].WorkOrderNumber);
        string JsonBody = '{"Schedule":[{"WorkOrderNo":"'+WorkOrderName8+'","EngineerID":"xyx@abc.com"}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost();
    }
    
    @isTest(SeeAllData=true)
    static void testMethodFifteen(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        Workorder wo10 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',FFA_RequestedAppointmentDate__c=datetime.newInstance(2050,03,02),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo10;
        ServiceAppointment sa10 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo10.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa10;
        list<WorkOrder> workOrder10 = [select id , WorkOrderNumber from WorkOrder where Id =: wo10.Id limit 1];
        string WorkOrderName10 = string.valueOf(workOrder10[0].WorkOrderNumber);
        
        Workorder wo11 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='Customer Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',FFA_RequestedAppointmentDate__c=datetime.newInstance(2050,03,02),
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo11;
        ServiceAppointment sa11 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo11.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa11;
        list<WorkOrder> workOrder11 = [select id , WorkOrderNumber from WorkOrder where Id =: wo11.Id limit 1];
        string WorkOrderName11 = string.valueOf(workOrder11[0].WorkOrderNumber);
        string JsonBody = '{"Schedule":[{"WorkOrderNo":"'+WorkOrderName10+'","EngineerID":"xyx@abc.com"},'+
            '{"WorkOrderNo":"'+WorkOrderName11+'","EngineerID":"xyx@abc.com"}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost();
    }
    
    @isTest(SeeAllData=true)
    static void testMethodEight(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo5 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',Notification_Type__c='Y3',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo5;
        ServiceAppointment sa5 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo5.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa5;
        list<WorkOrder> workOrder5 = [select id , WorkOrderNumber from WorkOrder where Id =: wo5.Id limit 1];
        string WorkOrderName5 = string.valueOf(workOrder5[0].WorkOrderNumber);
        
        Workorder wo6 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',Notification_Type__c='Y3',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo6;
        ServiceAppointment sa6 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo6.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa6;
        list<WorkOrder> workOrder6 = [select id , WorkOrderNumber from WorkOrder where Id =: wo6.Id limit 1];
        string WorkOrderName6 = string.valueOf(workOrder6[0].WorkOrderNumber);
        
        string JsonBody = '{"Schedule":[{"WorkOrderNo":"'+WorkOrderName5+'","AppointmentDate":"2050-09-01"},'+
            '{"WorkOrderNo":"'+WorkOrderName6+'","EngineerID":"","AppointmentDate":"2050-09-01"}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost();
    }
    
    @isTest(SeeAllData=true)
    static void testMethodNine(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo5 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',Notification_Type__c='Y3',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo5;
        ServiceAppointment sa5 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo5.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa5;
        AssignedResource ar9 = new AssignedResource();
        if(stm!=null){ar9.ServiceResourceId = stm.ServiceResourceId;}
            ar9.ServiceAppointmentId=sa5.Id;
            insert ar9;
        list<WorkOrder> workOrder5 = [select id , WorkOrderNumber from WorkOrder where Id =: wo5.Id limit 1];
        string WorkOrderName5 = string.valueOf(workOrder5[0].WorkOrderNumber);
        
        Workorder wo6 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',Notification_Type__c='Y3',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo6;
        ServiceAppointment sa6 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo6.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa6;
        list<WorkOrder> workOrder6 = [select id , WorkOrderNumber from WorkOrder where Id =: wo6.Id limit 1];
        string WorkOrderName6 = string.valueOf(workOrder6[0].WorkOrderNumber);
        
        
        string JsonBody = '{"Schedule":[{"WorkOrderNo":"'+WorkOrderName5+'","AppointmentDate":"2050-09-01"},{"WorkOrderNo":"'+WorkOrderName6+'","AppointmentDate":"2050-09-01"}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost();
    }
    
    @isTest(SeeAllData=true)
    static void testMethodNineteen(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        Workorder wo6 = new Workorder(Status = 'Assigned',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',Notification_Type__c='Y3',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo6;
        ServiceAppointment sa6 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo6.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa6;
        list<WorkOrder> workOrder6 = [select id , WorkOrderNumber from WorkOrder where Id =: wo6.Id limit 1];
        string WorkOrderName6 = string.valueOf(workOrder6[0].WorkOrderNumber);
        
        
        string JsonBody = '{"Schedule":{"WorkOrderNo":"'+WorkOrderName6+'","AppointmentDate":"2050-09-01"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost();
    }
    
    @isTest(SeeAllData=true)
    static void testMethodTwenty(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bp@w1.com');
        insert u;
        Profile pr = [select Id,Name from Profile where Name = 'FFA Service Provider Engineer'];
        User users = [select Id, Username, ProfileId from User where ProfileId =: pr.id limit 1];
        string EngineerUsername = users.Username;
        ServiceTerritoryMember stm = [select id,ServiceTerritoryId,ServiceResourceId,ServiceResource.IsActive from ServiceTerritoryMember where ServiceTerritoryId!=null AND ServiceResource.isactive=true  limit 1];
       
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGkdirtGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo5 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='191823334', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-ffdhf',Job_Category__c='NGM Initiated Job',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',FFA_Sender_ID__c='RAINBOW',Notification_Type__c='Y3',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_UnplannedPolicyStartDate__c=datetime.newInstance(2050,03,01),FFA_UnplannedPolicyEndDate__c=datetime.newInstance(2050,12,31));
        insert wo5;
        ServiceAppointment sa5 = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo5.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa5;
        
        list<WorkOrder> workOrder5 = [select id , WorkOrderNumber from WorkOrder where Id =: wo5.Id limit 1];
        string WorkOrderName5 = string.valueOf(workOrder5[0].WorkOrderNumber);
        
        string JsonBody = '{"Schedule":{"WorkOrderNo":"'+WorkOrderName5+'","EngineerID":"'+EngineerUsername+'","AppointmentDate":"2050-09-01"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        FFAWorkOrderAssigned.doPost();
    }
    
    @isTest
    static void testMethodForAcknownledge(){ 
        
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        
        Account acc = new Account(Name='NGG22222D_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo1 = new Workorder(ExternalId__c='6280010',Status = 'New',FFA_ServiceNotificationNumber__c='629', Batch_No__c = 'hhshgfhjhfd-sfdgdgs-sg-f',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id, Sync_Status__c='Fetched',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT', FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1; 
        //Response Fake
        string JsonBody = '{"Acknowledge":[{"BatchID":"hhshgfhjhfd-sfdgdgs-sg-f"},{"BatchID":"dfg"},{"BatchID":""}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderAssigned.doPost(); 
    }
    
    @isTest
    static void testMethodForAcknownledgeOne(){ 
        //Response Fake
        string JsonBody = '{"Acknowledge":{"BatchID":"hhshgfhjhfd"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderAssigned.doPost(); 
    }
    
    @isTest
    static void testMethodForAcknownledgeTwo(){ 
        //Response Fake
        string JsonBody = '{"Acknowledge":{"BatchID":""}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderAssigned.doPost(); 
    }
    
    @isTest
    static void testMethodForUnassignThree(){ 
        //Response Fake
        string JsonBody = '{"Unassign":{"WorkOrderNo":"000001234"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderAssigned.doPost(); 
    }
    
    @isTest
    static void testMethodForInvalidJSON(){ 
        //Response Fake
        string JsonBody = '{"Unassign":{WorkOrderNo":"000001234"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFAScheduleWork/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
        FFAWorkOrderAssigned.doPost(); 
    }
    
    
}