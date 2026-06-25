/////////////////////////////////////////////////
/*          SAP-FFA UPDATE INTERFACE TEST      */
/*          Author: Ankit Tomar                */ 
/*          Company: Wipro Technologies        */
/*          Created Date: 01/07/2019           */
/////////////////////////////////////////////////
/*
** Description: This class is used in FFA**
*/
@isTest
public class WorkorderUpdateHandlerTest {

// FOR CANCEL UPDATE TEST    
    // For Cancel Updation with values with success response
    @isTest public static void WorkorderUpdateHandlerTestMethod1(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site1');
        insert site;
        
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo = new Workorder(ExternalId__c='51000971580010',Status = 'New',FFA_ServiceNotificationNumber__c='5100097158',
                                     FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                     Site__c = site.id );
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(Status='None',ParentRecordId = wo.Id);
        insert sa;
        
        string CancelJsonBody = '{"Header":{"TransactionType":"ST","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:50:02","GenerationNumber":"839243"},"Job":{"ServiceNotificationNumber":"5100097158","OperationNumber":"0010"}},"Trailer":{"TransactionType":"ST","RecordCount":"1"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(CancelJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
        Test.StopTest();
    }
    @isTest public static void WorkorderUpdateHandlerTestMethod11(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site1');
        insert site;
        
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo = new Workorder(ExternalId__c='51000971580010',Status = 'New',FFA_ServiceNotificationNumber__c='5100097158',
                                     FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,FFA_Sender_ID__c='RAINBOW',
                                     Site__c = site.id );
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(Status='None',ParentRecordId = wo.Id);
        insert sa;
        
        string CancelJsonBody = '{"Header":{"TransactionType":"ST","SenderID":"RAINBOW","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:50:02","GenerationNumber":"839243"},"Job":{"ServiceNotificationNumber":"5100097158","OperationNumber":"0010"}},"Trailer":{"TransactionType":"ST","RecordCount":"1"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(CancelJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
        Test.StopTest();
    }
    @isTest public static void WorkorderUpdateHandlerTestMethod111(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site1');
        insert site;
        
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo = new Workorder(ExternalId__c='51000971580010',Status = 'Cancelled',FFA_ServiceNotificationNumber__c='5100097158',
                                     FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,FFA_Sender_ID__c='RAINBOW',
                                     Site__c = site.id );
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(Status='None',ParentRecordId = wo.Id);
        insert sa;
        
        string CancelJsonBody = '{"Header":{"TransactionType":"ST","SenderID":"RAINBOW","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:50:02","GenerationNumber":"839243"},"Job":{"ServiceNotificationNumber":"5100097158","OperationNumber":""}},"Trailer":{"TransactionType":"ST","RecordCount":"1"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(CancelJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
        Test.StopTest();
    }
    
    // For Cancel Updation with wrong workorder response
    @isTest public static void WorkorderUpdateHandlerTestMethod6(){
       string CancelJsonBody = '{"Header":{"TransactionType":"ST","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:50:02","GenerationNumber":"839243"},"Job":{"ServiceNotificationNumber":"510009cvf7158","OperationNumber":"0010"}},"Trailer":{"TransactionType":"ST","RecordCount":"1"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(CancelJsonBody);
        RestContext.request = req;
        RestContext.response = res; 
        string strres;
        strres= req.requestBody.tostring();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
        Test.StopTest();
    }
    // For Cancel Updation with Wrong workorder status
    @isTest public static void cancelUpdateWithWrongStatus(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site1');
        insert site;
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo = new Workorder(Status ='Completed',FFA_ServiceNotificationNumber__c='5100097158',
                                     FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.id,
                                     Site__c = site.id );
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(Status='None',ParentRecordId = wo.Id);
        insert sa;
        
        string CancelJsonBody = '{"Header":{"TransactionType":"ST","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:50:02","GenerationNumber":"839243"},"Job":{"ServiceNotificationNumber":"5100097158","OperationNumber":"0010"}},"Trailer":{"TransactionType":"ST","RecordCount":"1"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(CancelJsonBody);
        RestContext.request = req;
        RestContext.response = res; 
        string strres;
        strres= req.requestBody.tostring();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
        Test.StopTest();
    }
    // For Cancel Updation with Wrong workorder status
    @isTest public static void cancelUpdateWithWrongStatus1(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site1');
        insert site;
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo = new Workorder(Status ='In Progress',FFA_ServiceNotificationNumber__c='5100097158',
                                     FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.id,
                                     Site__c = site.id );
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(Status='None',ParentRecordId = wo.Id);
        insert sa;
        
        string CancelJsonBody = '{"Header":{"TransactionType":"ST","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:50:02","GenerationNumber":"839243"},"Job":{"ServiceNotificationNumber":"5100097158","OperationNumber":"0010"}},"Trailer":{"TransactionType":"ST","RecordCount":"1"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(CancelJsonBody);
        RestContext.request = req;
        RestContext.response = res; 
        string strres;
        strres= req.requestBody.tostring();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
        Test.StopTest();
    }
    // For Cancel Updation with Wrong SA status
    @isTest public static void cancelUpdateWithWrongSAStatus(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site1');
        insert site;
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo = new Workorder(Status ='New',FFA_ServiceNotificationNumber__c='5100097158',
                                     FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.id,
                                     Site__c = site.id );
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(Status='Cancelled',ParentRecordId = wo.Id);
        insert sa;
        
        string CancelJsonBody = '{"Header":{"TransactionType":"ST","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:50:02","GenerationNumber":"839243"},"Job":{"ServiceNotificationNumber":"5100097158","OperationNumber":"0010"}},"Trailer":{"TransactionType":"ST","RecordCount":"1"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(CancelJsonBody);
        RestContext.request = req;
        RestContext.response = res; 
        string strres;
        strres= req.requestBody.tostring();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
        Test.StopTest();
    }
    // For Cancel Updation with Wrong SA status
    @isTest public static void cancelUpdateWithWrongSAStatus1(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site1');
        insert site;
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo = new Workorder(Status ='New',FFA_ServiceNotificationNumber__c='5100097158',
                                     FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.id,
                                     Site__c = site.id );
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(Status='Completed',ParentRecordId = wo.Id);
        insert sa;
        
        string CancelJsonBody = '{"Header":{"TransactionType":"ST","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:50:02","GenerationNumber":"839243"},"Job":{"ServiceNotificationNumber":"5100097158","OperationNumber":"0010"}},"Trailer":{"TransactionType":"ST","RecordCount":"1"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(CancelJsonBody);
        RestContext.request = req;
        RestContext.response = res; 
        string strres;
        strres= req.requestBody.tostring();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
        Test.StopTest();
    }
    // For Cancel Updation without SA
    @isTest public static void cancelUpdateWithoutSA(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site1');
        insert site;
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo = new Workorder(Status ='New',FFA_ServiceNotificationNumber__c='5100097158',
                                     FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.id,
                                     Site__c = site.id );
        insert wo;
        string CancelJsonBody = '{"Header":{"TransactionType":"ST","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:50:02","GenerationNumber":"839243"},"Job":{"ServiceNotificationNumber":"5100097158","OperationNumber":"0010"}},"Trailer":{"TransactionType":"ST","RecordCount":"1"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(CancelJsonBody);
        RestContext.request = req;
        RestContext.response = res; 
        string strres;
        strres= req.requestBody.tostring();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
        Test.StopTest();
    }
    
// FOR REPLAN UPDATE TEST    
    // For Replan Updation with error response 
    @isTest public static void WorkorderUpdateHandlerTestMethod5(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo1 = new Workorder(ExternalId__c='530005417345630010',Status = 'New',FFA_ServiceNotificationNumber__c='5100097158',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status='None',ParentRecordId = wo1.Id);
        insert sa;
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SR","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:46:44","GenerationNumber":"841367"},"Job":{"ServiceNotificationNumber":"5300054173","OperationNumber":"0010","RequestedAppointmentDate":"'+datetimevalue+'","RequestedAppointmentTimeslot":"AT"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    @isTest public static void WorkorderUpdateHandlerTestMethod55(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo1 = new Workorder(ExternalId__c='53000541',Status = 'New',FFA_ServiceNotificationNumber__c='51000987158',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,FFA_Sender_ID__c='RAINBOW',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.now().addDays(3));
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status='None',ParentRecordId = wo1.Id);
        insert sa;
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SR","SenderID":"RAINBOW","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:46:44","GenerationNumber":"841367"},"Job":{"ServiceNotificationNumber":"51000987158","OperationNumber":"","RequestedAppointmentDate":"'+datetimevalue+'","RequestedAppointmentTimeslot":"AT"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    @isTest public static void WorkorderUpdateHandlerTestMethod56(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo1 = new Workorder(ExternalId__c='53000541',Status = 'Cancelled',FFA_ServiceNotificationNumber__c='51000987158',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,FFA_Sender_ID__c='RAINBOW',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.now().addDays(3));
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status='None',ParentRecordId = wo1.Id);
        insert sa;
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SR","SenderID":"RAINBOW","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:46:44","GenerationNumber":"841367"},"Job":{"ServiceNotificationNumber":"51000987158","OperationNumber":"","RequestedAppointmentDate":"'+datetimevalue+'","RequestedAppointmentTimeslot":"AT"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    // For Replan Updation with values with success response
    @isTest public static void WorkorderUpdateHandlerTestMethod2(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo1 = new Workorder(ExternalId__c='53000541790010',Status = 'New',FFA_ServiceNotificationNumber__c='5300054179',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status='None',ParentRecordId = wo1.Id);
        insert sa;
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SR","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:46:44","GenerationNumber":"841367"},"Job":{"ServiceNotificationNumber":"5300054179 ","OperationNumber":"0010","RequestedAppointmentDate":"'+datetimevalue+'","RequestedAppointmentTimeslot":"AT"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    // For Replan Updation with wrong WO status 
    @isTest public static void replanUpdateWithWorngStatus(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo1 = new Workorder(ExternalId__c='53000541790010',Status = 'Completed',FFA_ServiceNotificationNumber__c='5300054179',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status='None',ParentRecordId = wo1.Id);
        insert sa;
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SR","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:46:44","GenerationNumber":"841367"},"Job":{"ServiceNotificationNumber":"5300054179 ","OperationNumber":"0010","RequestedAppointmentDate":"'+datetimevalue+'","RequestedAppointmentTimeslot":"AT"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    // For Replan Updation with wrong WO status 
    @isTest public static void replanUpdateWithWorngStatus1(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo1 = new Workorder(ExternalId__c='53000541790010',Status = 'In Progress',FFA_ServiceNotificationNumber__c='5300054179',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status='None',ParentRecordId = wo1.Id);
        insert sa;
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SR","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:46:44","GenerationNumber":"841367"},"Job":{"ServiceNotificationNumber":"5300054179 ","OperationNumber":"0010","RequestedAppointmentDate":"'+datetimevalue+'","RequestedAppointmentTimeslot":"AT"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    // For Replan Updation with wrong SA status 
    @isTest public static void replanUpdateWithWorngSAStatus(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo1 = new Workorder(ExternalId__c='53000541790010',Status = 'New',FFA_ServiceNotificationNumber__c='5300054179',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status='Cancelled',ParentRecordId = wo1.Id);
        insert sa;
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SR","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:46:44","GenerationNumber":"841367"},"Job":{"ServiceNotificationNumber":"5300054179 ","OperationNumber":"0010","RequestedAppointmentDate":"'+datetimevalue+'","RequestedAppointmentTimeslot":"AT"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    // For Replan Updation with wrong SA status 
    @isTest public static void replanUpdateWithWorngSAStatus1(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo1 = new Workorder(ExternalId__c='53000541790010',Status = 'New',FFA_ServiceNotificationNumber__c='5300054179',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        ServiceAppointment sa = new ServiceAppointment(Status='Completed',ParentRecordId = wo1.Id);
        insert sa;
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SR","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:46:44","GenerationNumber":"841367"},"Job":{"ServiceNotificationNumber":"5300054179 ","OperationNumber":"0010","RequestedAppointmentDate":"'+datetimevalue+'","RequestedAppointmentTimeslot":"AT"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    // For Replan Updation without SA  
    @isTest public static void replanUpdateWithoutSA(){
        //list<Account> acc =[select Id , Name from Account];
        
        FFA_Site__c site = new FFA_Site__c(name='test site');
        insert site;
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        Workorder wo1 = new Workorder(ExternalId__c='53000541790010',Status = 'New',FFA_ServiceNotificationNumber__c='5300054179',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SR","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:46:44","GenerationNumber":"841367"},"Job":{"ServiceNotificationNumber":"5300054179 ","OperationNumber":"0010","RequestedAppointmentDate":"'+datetimevalue+'","RequestedAppointmentTimeslot":"AT"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    // For Replan Updation with wrong Workorder 
    @isTest public static void replanUpdateWithWrongWO(){
        string ReplanJsonBody = '{"Header":{"TransactionType":"SR","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:46:44","GenerationNumber":"841367"},"Job":{"ServiceNotificationNumber":"530cfv0054179 ","OperationNumber":"0010","RequestedAppointmentDate":"2020-12-01","RequestedAppointmentTimeslot":"AT"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    
    
// FOR AMEND UPDATE TEST
    // For Amend Success Test with Meter
    @isTest public static void WorkorderUpdateHandlerTestMethod3(){
        //list<Account> acc =[select Id , Name from Account];
        
        
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        FFA_Site__c site = new FFA_Site__c(FFA_Title__c='Mr',FFA_Initials__c='d',FFA_Surname__c='test',FFA_ContactTelephoneNumber__c='90888',Name='test Site',FFA_BuildingName__c='Building',FFA_SubBuildingName__c='Building',FFA_BuildingNumber__c='Building',FFA_DependentStreet__c='street',
                                           FFA_PrincipalStreet__c='s',FFA_DependentLocality__c='s',FFA_DoubleDependantLocality__c='s',FFA_PostTown__c='s',FFA_County__c='s',FFA_PostcodeOutcode__c='s',FFA_PostcodeIncode__c='s',FFA_GPSEasting__c='s',FFA_GPSNorthing__c='s',
                                           FFA_AccessInstructions__c='s',FFA_CorrespondenceAddress__c='s',FFA_DoesTheSiteContainAsbestos__c=false);
        insert site;
        
        Workorder wo1 = new Workorder(ExternalId__c='530005417340010',Status = 'New',FFA_ServiceNotificationNumber__c='53000541734',
                                      Transaction_Type__c='SA', FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        FFA_NGV_Asset__c meter = new FFA_NGV_Asset__c(FFA_Serial_Number__c='23456',FFA_Asset_Type__c='Meter',Work_Order__c=wo1.id);
        insert meter;
        
        
        
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SA","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:42:03","GenerationNumber":"823390"},"Job":{"ServiceNotificationNumber":"53000541734","OperationNumber":"0010"},"Meter":{"MeterSerialNumber":"458781512","MeterManufacturer":"wert","MeterModel":"3213"},"Site":{"Title":"a","Initials":"a","Surname":"a","ContactTelephoneNumber":"a","SiteName":"a","BuildingName":"a","SubBuildingName":"a","BuildingNumber":"a","DependentStreet":"a","PrincipalStreet":"a","DependentLocality":"a","DoubleDependantLocality":"a","PostTown":"a","County":"a","PostcodeOutcode":"a","PostcodeIncode":"a","GPSEasting":"a","GPSNorthing":"a","AccessInstructions":"a","CorrespondenceAddress":"a","DoesTheSiteContainAsbestos":"False","AsbestosDetails":"a"}}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    @isTest public static void WorkorderUpdateHandlerTestMethod33(){
        //list<Account> acc =[select Id , Name from Account];
        
        
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        FFA_Site__c site = new FFA_Site__c(FFA_Title__c='Mr',FFA_Initials__c='d',FFA_Surname__c='test',FFA_ContactTelephoneNumber__c='90888',Name='test Site',FFA_BuildingName__c='Building',FFA_SubBuildingName__c='Building',FFA_BuildingNumber__c='Building',FFA_DependentStreet__c='street',
                                           FFA_PrincipalStreet__c='s',FFA_DependentLocality__c='s',FFA_DoubleDependantLocality__c='s',FFA_PostTown__c='s',FFA_County__c='s',FFA_PostcodeOutcode__c='s',FFA_PostcodeIncode__c='s',FFA_GPSEasting__c='s',FFA_GPSNorthing__c='s',
                                           FFA_AccessInstructions__c='s',FFA_CorrespondenceAddress__c='s',FFA_DoesTheSiteContainAsbestos__c=false);
        insert site;
        
        Workorder wo1 = new Workorder(ExternalId__c='530005417340010',Status = 'New',FFA_ServiceNotificationNumber__c='53000541734',
                                      Transaction_Type__c='SA', FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,FFA_Sender_ID__c='RAINBOW',
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        FFA_NGV_Asset__c meter = new FFA_NGV_Asset__c(FFA_Serial_Number__c='23456',FFA_Asset_Type__c='Meter',Work_Order__c=wo1.id);
        insert meter;
        
        
        
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SA","SenderID":"RAINBOW","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:42:03","GenerationNumber":"823390"},"Job":{"ServiceNotificationNumber":"53000541734","OperationNumber":""},"Meter":{"MeterSerialNumber":"458781512","MeterManufacturer":"wert","MeterModel":"3213"},"Site":{"Title":"a","Initials":"a","Surname":"a","ContactTelephoneNumber":"a","SiteName":"a","BuildingName":"a","SubBuildingName":"a","BuildingNumber":"a","DependentStreet":"a","PrincipalStreet":"a","DependentLocality":"a","DoubleDependantLocality":"a","PostTown":"a","County":"a","PostcodeOutcode":"a","PostcodeIncode":"a","GPSEasting":"a","GPSNorthing":"a","AccessInstructions":"a","CorrespondenceAddress":"a","DoesTheSiteContainAsbestos":"False","AsbestosDetails":"a"}}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    @isTest public static void WorkorderUpdateHandlerTestMethod34(){
        //list<Account> acc =[select Id , Name from Account];
        
        
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        
        
        Workorder wo1 = new Workorder(ExternalId__c='530005417340010',Status = 'New',FFA_ServiceNotificationNumber__c='53000541734',
                                      Transaction_Type__c='SA', FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,FFA_Sender_ID__c='RAINBOW',
                                      FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SA","SenderID":"RAINBOW","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:42:03","GenerationNumber":"823390"},"Job":{"ServiceNotificationNumber":"53000541734","OperationNumber":""},"Meter":{"MeterSerialNumber":"458781512","MeterManufacturer":"wert","MeterModel":"3213"},"Site":{"Title":"a","Initials":"a","Surname":"a","ContactTelephoneNumber":"a","SiteName":"a","BuildingName":"a","SubBuildingName":"a","BuildingNumber":"a","DependentStreet":"a","PrincipalStreet":"a","DependentLocality":"a","DoubleDependantLocality":"a","PostTown":"a","County":"a","PostcodeOutcode":"a","PostcodeIncode":"a","GPSEasting":"a","GPSNorthing":"a","AccessInstructions":"a","CorrespondenceAddress":"a","DoesTheSiteContainAsbestos":"False","AsbestosDetails":"a"}}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    // For Amend Success Test with Convertor
    @isTest public static void amendUpdateWithConvertor(){
        //list<Account> acc =[select Id , Name from Account];
        
        
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        FFA_Site__c site = new FFA_Site__c(FFA_Title__c='Mr',FFA_Initials__c='d',FFA_Surname__c='test',FFA_ContactTelephoneNumber__c='90888',Name='test Site',FFA_BuildingName__c='Building',FFA_SubBuildingName__c='Building',FFA_BuildingNumber__c='Building',FFA_DependentStreet__c='street',
                                           FFA_PrincipalStreet__c='s',FFA_DependentLocality__c='s',FFA_DoubleDependantLocality__c='s',FFA_PostTown__c='s',FFA_County__c='s',FFA_PostcodeOutcode__c='s',FFA_PostcodeIncode__c='s',FFA_GPSEasting__c='s',FFA_GPSNorthing__c='s',
                                           FFA_AccessInstructions__c='s',FFA_CorrespondenceAddress__c='s',FFA_DoesTheSiteContainAsbestos__c=false);
        insert site;
        
        Workorder wo1 = new Workorder(ExternalId__c='530005417340010',Status = 'New',FFA_ServiceNotificationNumber__c='53000541734',
                                      Transaction_Type__c='SA', FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        
        
        
        
        FFA_NGV_Asset__c Con = new FFA_NGV_Asset__c(FFA_Serial_Number__c='234562',FFA_Asset_Type__c='Converter',Work_Order__c=wo1.id);
        insert con;
        
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SA","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:42:03","GenerationNumber":"823390"},"Job":{"ServiceNotificationNumber":"53000541734","OperationNumber":"0010"},"Convertor":{"ConvertorSerialNumber":"34354747","ConvertorManufacturer":"54764574","ConvertorModel":"4565"},"Site":{"Title":"a","Initials":"a","Surname":"a","ContactTelephoneNumber":"a","SiteName":"a","BuildingName":"a","SubBuildingName":"a","BuildingNumber":"a","DependentStreet":"a","PrincipalStreet":"a","DependentLocality":"a","DoubleDependantLocality":"a","PostTown":"a","County":"a","PostcodeOutcode":"a","PostcodeIncode":"a","GPSEasting":"a","GPSNorthing":"a","AccessInstructions":"a","CorrespondenceAddress":"a","DoesTheSiteContainAsbestos":"False","AsbestosDetails":"a"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    // For Amend Success Test with Flowcomputer
    @isTest public static void amendUpdateWithFlowcomputer(){
        //list<Account> acc =[select Id , Name from Account];
        
        
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        FFA_Site__c site = new FFA_Site__c(FFA_Title__c='Mr',FFA_Initials__c='d',FFA_Surname__c='test',FFA_ContactTelephoneNumber__c='90888',Name='test Site',FFA_BuildingName__c='Building',FFA_SubBuildingName__c='Building',FFA_BuildingNumber__c='Building',FFA_DependentStreet__c='street',
                                           FFA_PrincipalStreet__c='s',FFA_DependentLocality__c='s',FFA_DoubleDependantLocality__c='s',FFA_PostTown__c='s',FFA_County__c='s',FFA_PostcodeOutcode__c='s',FFA_PostcodeIncode__c='s',FFA_GPSEasting__c='s',FFA_GPSNorthing__c='s',
                                           FFA_AccessInstructions__c='s',FFA_CorrespondenceAddress__c='s',FFA_DoesTheSiteContainAsbestos__c=false);
        insert site;
        
        Workorder wo1 = new Workorder(ExternalId__c='530005417340010',Status = 'New',FFA_ServiceNotificationNumber__c='53000541734',
                                      Transaction_Type__c='SA', FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        
        
        FFA_NGV_Asset__c flow = new FFA_NGV_Asset__c(FFA_Serial_Number__c='234561',FFA_Asset_Type__c='Flow Computer',Work_Order__c=wo1.id);
        insert flow;
        
        
        
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SA","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:42:03","GenerationNumber":"823390"},"Job":{"ServiceNotificationNumber":"53000541734","OperationNumber":"0010"},"FlowComputer":{"FlowComputerSerialNumber":"325454376","FlowComputerManufacturer":"546546","FlowComputerModel":"6546"},"Site":{"Title":"a","Initials":"a","Surname":"a","ContactTelephoneNumber":"a","SiteName":"a","BuildingName":"a","SubBuildingName":"a","BuildingNumber":"a","DependentStreet":"a","PrincipalStreet":"a","DependentLocality":"a","DoubleDependantLocality":"a","PostTown":"a","County":"a","PostcodeOutcode":"a","PostcodeIncode":"a","GPSEasting":"a","GPSNorthing":"a","AccessInstructions":"a","CorrespondenceAddress":"a","DoesTheSiteContainAsbestos":"False","AsbestosDetails":"a"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    // For Amend Success with wrong workorder
    @isTest public static void amendUpdateWithWrongWO(){
        
        string ReplanJsonBody = '{"Header":{"TransactionType":"SA","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:42:03","GenerationNumber":"823390"},"Job":{"ServiceNotificationNumber":"53000dfd541734","OperationNumber":"0010"},"FlowComputer":{"FlowComputerSerialNumber":"325454376","FlowComputerManufacturer":"546546","FlowComputerModel":"6546"},"Site":{"Title":"a","Initials":"a","Surname":"a","ContactTelephoneNumber":"a","SiteName":"a","BuildingName":"a","SubBuildingName":"a","BuildingNumber":"a","DependentStreet":"a","PrincipalStreet":"a","DependentLocality":"a","DoubleDependantLocality":"a","PostTown":"a","County":"a","PostcodeOutcode":"a","PostcodeIncode":"a","GPSEasting":"a","GPSNorthing":"a","AccessInstructions":"a","CorrespondenceAddress":"a","DoesTheSiteContainAsbestos":"False","AsbestosDetails":"a"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    // For Amend Success Test with wrong WO Status
    @isTest public static void amendUpdateWithWorngStatus(){
        //list<Account> acc =[select Id , Name from Account];
        
        
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        FFA_Site__c site = new FFA_Site__c(FFA_Title__c='Mr',FFA_Initials__c='d',FFA_Surname__c='test',FFA_ContactTelephoneNumber__c='90888',Name='test Site',FFA_BuildingName__c='Building',FFA_SubBuildingName__c='Building',FFA_BuildingNumber__c='Building',FFA_DependentStreet__c='street',
                                           FFA_PrincipalStreet__c='s',FFA_DependentLocality__c='s',FFA_DoubleDependantLocality__c='s',FFA_PostTown__c='s',FFA_County__c='s',FFA_PostcodeOutcode__c='s',FFA_PostcodeIncode__c='s',FFA_GPSEasting__c='s',FFA_GPSNorthing__c='s',
                                           FFA_AccessInstructions__c='s',FFA_CorrespondenceAddress__c='s',FFA_DoesTheSiteContainAsbestos__c=false);
        insert site;
        
        Workorder wo1 = new Workorder(ExternalId__c='530005417340010',Status = 'Completed',FFA_ServiceNotificationNumber__c='53000541734',
                                      Transaction_Type__c='SA', FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        
        
        
        
        FFA_NGV_Asset__c Con = new FFA_NGV_Asset__c(FFA_Serial_Number__c='234562',FFA_Asset_Type__c='Converter',Work_Order__c=wo1.id);
        insert con;
        
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SA","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:42:03","GenerationNumber":"823390"},"Job":{"ServiceNotificationNumber":"53000541734","OperationNumber":"0010"},"Convertor":{"ConvertorSerialNumber":"34354747","ConvertorManufacturer":"54764574","ConvertorModel":"4565"},"Site":{"Title":"a","Initials":"a","Surname":"a","ContactTelephoneNumber":"a","SiteName":"a","BuildingName":"a","SubBuildingName":"a","BuildingNumber":"a","DependentStreet":"a","PrincipalStreet":"a","DependentLocality":"a","DoubleDependantLocality":"a","PostTown":"a","County":"a","PostcodeOutcode":"a","PostcodeIncode":"a","GPSEasting":"a","GPSNorthing":"a","AccessInstructions":"a","CorrespondenceAddress":"a","DoesTheSiteContainAsbestos":"False","AsbestosDetails":"a"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    // For Amend Success Test without Site
    @isTest public static void amendUpdateWithoutSite(){
        //list<Account> acc =[select Id , Name from Account];
        
        
        Account acc = new Account(Name='NGGD_WM');
        insert acc;
        axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
        insert axsyfomlist;
        
        WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
        insert WType;
        
        
        
        Workorder wo1 = new Workorder(ExternalId__c='530005417340010',Status = 'New',FFA_ServiceNotificationNumber__c='53000541734',
                                      Transaction_Type__c='SA', FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
        insert wo1;
        
        
        
        
        
        FFA_NGV_Asset__c Con = new FFA_NGV_Asset__c(FFA_Serial_Number__c='234562',FFA_Asset_Type__c='Converter',Work_Order__c=wo1.id);
        insert con;
        
        string datetimevalue = string.valueOf(wo1.FFA_RequestedAppointmentDate__c);
        string ReplanJsonBody = '{"Header":{"TransactionType":"SA","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:42:03","GenerationNumber":"823390"},"Job":{"ServiceNotificationNumber":"53000541734","OperationNumber":"0010"},"Convertor":{"ConvertorSerialNumber":"34354747","ConvertorManufacturer":"54764574","ConvertorModel":"4565"},"Site":{"Title":"a","Initials":"a","Surname":"a","ContactTelephoneNumber":"a","SiteName":"a","BuildingName":"a","SubBuildingName":"a","BuildingNumber":"a","DependentStreet":"a","PrincipalStreet":"a","DependentLocality":"a","DoubleDependantLocality":"a","PostTown":"a","County":"a","PostcodeOutcode":"a","PostcodeIncode":"a","GPSEasting":"a","GPSNorthing":"a","AccessInstructions":"a","CorrespondenceAddress":"a","DoesTheSiteContainAsbestos":"False","AsbestosDetails":"a"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/NGupdateJOB/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(ReplanJsonBody);
        RestContext.request = req;
        RestContext.response = res;
        string strres;
        strres= req.requestBody.tostring();
        WorkorderUpdateHandler.parse(strres);
        WorkorderUpdateHandler.UpdateWorkOrder();
    }
    
    
    
    
    
    
    
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}