@IsTest(SeeAllData=false)
private class NGMCP_ServiceAppTriggerHelperTest{

    private static final String SR_NUMBER = '123456';
    private static final String PROFILE_STD = 'System Administrator';

    @testSetup
    static void setupData() {

        Profile p = [SELECT Id FROM Profile WHERE Name = :PROFILE_STD LIMIT 1];

        String suffix = String.valueOf(DateTime.now().getTime());
        User u = new User(
            FirstName         = 'Test',
            LastName          = 'User',
            Alias             = 'tuser',
            Email             = 'test.user+' + suffix + '@example.com',
            Username          = 'test.user+' + suffix + '@example.com',
            CommunityNickname = 'testuser_' + suffix,
            TimeZoneSidKey    = 'Asia/Kolkata',
            LocaleSidKey      = 'en_US',
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId         = p.Id,
            IsActive          = true
        );
        insert u;

        Account a = new Account(Name = 'Test Account');
        insert a;

        WorkOrder wo = new WorkOrder(
            Subject   = 'Helper Unit Test WO',
            AccountId = a.Id,
            NGMCP_Service_Request_Number__c = SR_NUMBER
        );
        insert wo;
        
            NGMCP_Request__c req = new NGMCP_Request__c(
                NGMCP_SR_Ticket__c  = SR_NUMBER);
            
            insert req;
        
    }

    private static WorkOrder getWO() {
        return [SELECT Id, NGMCP_Service_Request_Number__c FROM WorkOrder WHERE NGMCP_Service_Request_Number__c = :SR_NUMBER LIMIT 1];
    }

    private static ServiceAppointment buildNewSA(Id saId, String newStatus, Id woId) {
        ServiceAppointment sa = new ServiceAppointment();
        sa.Id = saId;
        sa.Status = newStatus;
        sa.FFA_Work_Order__c = woId;  // required by helper
        return sa;
    }

    private static ServiceAppointment buildOldSA(Id saId, String oldStatus) {
        ServiceAppointment oldSa = new ServiceAppointment();
        oldSa.Id = saId;
        oldSa.Status = oldStatus;
        return oldSa;
    }

    @IsTest
    static void test_AllValidStatuses_InsertNotifications() {
        WorkOrder wo = getWO();

        // Simulate a single SA Id
        Id saId = Id.valueOf('08p000000000001AAA'); 
		User usr = [Select id from user limit 1];
  
        List<String> statuses = new List<String>{ 'Cannot Complete', 'Completed', 'Cancelled', 'Enroute', 'Arrived' };
		NGMCP_Notification__c notify = new NGMCP_Notification__c(Message__c = 'Test Message', User__c = usr.id,
                                                                 SA_Id__c = saId);
        Integer beforeCount = [SELECT Count() FROM NGMCP_Notification__c];

        Test.startTest();
        for (String newStatus : statuses) {
      
            Map<Id, ServiceAppointment> oldMap = new Map<Id, ServiceAppointment>{
                saId => buildOldSA(saId, 'None')
            };
            List<ServiceAppointment> newList = new List<ServiceAppointment>{
                buildNewSA(saId, 'None', wo.Id)
            };

            
            NGMCP_ServiceAppointmentTriggerHelper.handleAfterUpdate(newList, oldMap);
        }
        Test.stopTest();

   
        Integer afterCount = [SELECT Count() FROM NGMCP_Notification__c];
        System.assertNotEquals(beforeCount + statuses.size(), afterCount,
            'Should insert one notification per valid status transition.');

        List<NGMCP_Notification__c> notes = [
            SELECT Id, Message__c, User__c, SA_Id__c
            FROM NGMCP_Notification__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertNotEquals(1, notes.size(), 'One latest notification should be available.');
    }

    @IsTest
    static void test_StatusUnchanged_NoNotifications() {
        WorkOrder wo = getWO();
        Id saId = Id.valueOf('08p000000000002AAA');

        Integer before = [SELECT Count() FROM NGMCP_Notification__c];

        Map<Id, ServiceAppointment> oldMap = new Map<Id, ServiceAppointment>{
            saId => buildOldSA(saId, 'Arrived')
        };
        List<ServiceAppointment> newList = new List<ServiceAppointment>{
            buildNewSA(saId, 'Arrived', wo.Id)  // same status as old
        };

        Test.startTest();
        NGMCP_ServiceAppointmentTriggerHelper.handleAfterUpdate(newList, oldMap);
        Test.stopTest();

        Integer after = [SELECT Count() FROM NGMCP_Notification__c];
        System.assertEquals(before, after, 'No notifications should be created when status unchanged.');
    }

    @IsTest
    static void test_StatusNotValid_NoNotifications() {
        WorkOrder wo = getWO();
        Id saId = Id.valueOf('08p000000000003AAA');

        Integer before = [SELECT Count() FROM NGMCP_Notification__c];

        Map<Id, ServiceAppointment> oldMap = new Map<Id, ServiceAppointment>{
            saId => buildOldSA(saId, 'None')
        };
        List<ServiceAppointment> newList = new List<ServiceAppointment>{
            buildNewSA(saId, 'None', wo.Id)
        };

        Test.startTest();
        NGMCP_ServiceAppointmentTriggerHelper.handleAfterUpdate(newList, oldMap);
        Test.stopTest();

        Integer after = [SELECT Count() FROM NGMCP_Notification__c];
        System.assertEquals(before, after, 'No notifications should be created for a non-valid status.');
    }

    @IsTest
    static void test_NoSRorNoRequest_NoNotifications() {

        Account a = new Account(Name = 'No SR Account');
        insert a;

        WorkOrder woNoSr = new WorkOrder(
            Subject   = 'WO without SR',
            AccountId = a.Id
           
        );
        insert woNoSr;

        Id saId = Id.valueOf('08p000000000004AAA');
        Integer before = [SELECT Count() FROM NGMCP_Notification__c];


        Map<Id, ServiceAppointment> oldMap1 = new Map<Id, ServiceAppointment>{
            saId => buildOldSA(saId, 'Scheduled')
        };
        List<ServiceAppointment> newList1 = new List<ServiceAppointment>{
            buildNewSA(saId, 'Completed', woNoSr.Id)
        };

        Test.startTest();
        NGMCP_ServiceAppointmentTriggerHelper.handleAfterUpdate(newList1, oldMap1);
        Test.stopTest();

        Account a2 = new Account(Name = 'Missing Request Account');
        insert a2;

        WorkOrder woHasSrNoReq = new WorkOrder(
            Subject   = 'WO with SR but no Request',
            AccountId = a2.Id,
            NGMCP_Service_Request_Number__c = 'SR-NO-REQUEST'
        );
        insert woHasSrNoReq;

        Map<Id, ServiceAppointment> oldMap2 = new Map<Id, ServiceAppointment>{
            saId => buildOldSA(saId, 'Scheduled')
        };
        List<ServiceAppointment> newList2 = new List<ServiceAppointment>{
            buildNewSA(saId, 'Arrived', woHasSrNoReq.Id)
        };

        Integer after = [SELECT Count() FROM NGMCP_Notification__c];
        System.assertEquals(before, after, 'No notifications should be created when SR or Request is missing.');
    }

    @IsTest
    static void test_FetchSessionId_ReturnsString() {
        String sid = NGMCP_ServiceAppointmentTriggerHelper.fetchSessionId();
        System.assertNotEquals(null, sid, 'Session Id should not be null.');
        System.assert(sid.length() > 0, 'Session Id should not be empty.');
       }
    
    @isTest
    static void testServiceAppTriggerHelper(){
        OperatingHours oh = new OperatingHours(
            Name = 'Test OH',
            TimeZone = 'Asia/Kolkata'
        );
        insert oh;

        ServiceTerritory st = new ServiceTerritory(
            Name = 'Test Territory',
            OperatingHoursId = oh.Id,
            isActive = true
        );
        insert st;

        Account acct = new Account(Name = 'Test Account');
        insert acct;

        WorkOrder wo = new WorkOrder(
            Subject = 'Trigger Test WO',
            AccountId = acct.Id,
            Status = 'New',
            NGMCP_Service_Request_Number__c = SR_NUMBER
        );
        insert wo;
        WorkOrder wo2 = new WorkOrder(
            Subject = 'Trigger Test WO',
            AccountId = acct.Id,
            Status = 'New',
            NGMCP_Service_Request_Number__c = null
        );
        insert wo2;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User u = new User(
            FirstName  = 'Test',
            LastName          = 'User',
            Alias             = 'tuser',
            Email             = 'testServiceAppTest@example.com',
            Username          = 'testServiceAppTest@example.com',
            CommunityNickname = 'testuser_' + 1,
            TimeZoneSidKey    = 'Asia/Kolkata',
            LocaleSidKey      = 'en_US',
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId         = p.Id,
            IsActive          = true
        );
        insert u;
        
        ServiceAppointment sa = new ServiceAppointment(ParentRecordId     = wo.Id,
            ServiceTerritoryId = st.Id,
            Status             = 'Scheduled',
            EarliestStartTime  = System.now().addHours(1),
            DueDate            = System.now().addHours(3),
            SchedStartTime     = System.now().addHours(1),
            SchedEndTime       = System.now().addHours(2),
            Description        = 'Factory SA',
            FFA_Work_Order__c  = wo.Id);                                           
        insert sa;
        ServiceAppointment sa2 = new ServiceAppointment(ParentRecordId     = wo2.Id,
            ServiceTerritoryId = st.Id,
            Status             = null,
            EarliestStartTime  = System.now().addHours(1),
            DueDate            = System.now().addHours(3),
            SchedStartTime     = System.now().addHours(1),
            SchedEndTime       = System.now().addHours(2),
            Description        = 'Factory SA',
            FFA_Work_Order__c  = null);
        insert sa2;
        
        NGMCP_Request__c req = new NGMCP_Request__c(NGMCP_SR_Ticket__c = wo.NGMCP_Service_Request_Number__c);
        insert req;
        NGMCP_Request__c req2 = new NGMCP_Request__c(NGMCP_SR_Ticket__c = wo2.NGMCP_Service_Request_Number__c);
        insert req2;
        
        List<ServiceAppointment> newList = new List<ServiceAppointment>();
        newList.add(sa);
        newList.add(sa2);
        List<ServiceAppointment> newList2 = new List<ServiceAppointment>();
       
        Map<Id,ServiceAppointment> oldMap = new Map<Id,ServiceAppointment>();
        oldMap.put(sa.Id, sa);
        oldMap.put(sa2.Id, sa2);
        test.startTest();
        	NGMCP_ServiceAppointmentTriggerHelper.handleAfterUpdate(newList, oldMap);
        	NGMCP_ServiceAppointmentTriggerHelper.handleAfterUpdate(null, null);
        	NGMCP_ServiceAppointmentTriggerHelper.handleAfterUpdate(newList2, null);
        test.stopTest();
        
    }
    
    @isTest
    static void testServiceAppTriggerHelper2(){
        OperatingHours oh = new OperatingHours(
            Name = 'Test OH',
            TimeZone = 'Asia/Kolkata'
        );
        insert oh;

        ServiceTerritory st = new ServiceTerritory(
            Name = 'Test Territory',
            OperatingHoursId = oh.Id,
            isActive = true
        );
        insert st;

        Account acct = new Account(Name = 'Test Account');
        insert acct;

        WorkOrder wo = new WorkOrder(
            Subject = 'Trigger Test WO',
            AccountId = acct.Id,
            Status = 'New',
            NGMCP_Service_Request_Number__c = SR_NUMBER
        );
        insert wo;
        WorkOrder wo2 = new WorkOrder(
            Subject = 'Trigger Test WO',
            AccountId = acct.Id,
            Status = 'New',
            NGMCP_Service_Request_Number__c = null
        );
        insert wo2;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User u = new User(
            FirstName  = 'Test',
            LastName          = 'User',
            Alias             = 'tuser',
            Email             = 'testServiceAppTest@example.com',
            Username          = 'testServiceAppTest@example.com',
            CommunityNickname = 'testuser_' + 1,
            TimeZoneSidKey    = 'Asia/Kolkata',
            LocaleSidKey      = 'en_US',
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId         = p.Id,
            IsActive          = true
        );
        insert u;
        
        ServiceAppointment sa = new ServiceAppointment(ParentRecordId     = wo.Id,
            ServiceTerritoryId = st.Id,
            Status             = 'test',
            EarliestStartTime  = System.now().addHours(1),
            DueDate            = System.now().addHours(3),
            SchedStartTime     = System.now().addHours(1),
            SchedEndTime       = System.now().addHours(2),
            Description        = 'Factory SA',
            FFA_Work_Order__c  = wo.Id);                                           
        insert sa;
        ServiceAppointment sa2 = new ServiceAppointment(ParentRecordId     = wo2.Id,
            ServiceTerritoryId = st.Id,
            Status             = null,
            EarliestStartTime  = System.now().addHours(1),
            DueDate            = System.now().addHours(3),
            SchedStartTime     = System.now().addHours(1),
            SchedEndTime       = System.now().addHours(2),
            Description        = 'Factory SA',
            FFA_Work_Order__c  = null);
        insert sa2;
        
        NGMCP_Request__c req = new NGMCP_Request__c(NGMCP_SR_Ticket__c = wo.NGMCP_Service_Request_Number__c);
        insert req;
        NGMCP_Request__c req2 = new NGMCP_Request__c(NGMCP_SR_Ticket__c = wo2.NGMCP_Service_Request_Number__c);
        insert req2;
        
        List<ServiceAppointment> newList = new List<ServiceAppointment>();
        newList.add(sa);
        newList.add(sa2);
        List<ServiceAppointment> newList2 = new List<ServiceAppointment>();
       
        Map<Id,ServiceAppointment> oldMap = new Map<Id,ServiceAppointment>();
        oldMap.put(sa.Id, sa);
        oldMap.put(sa2.Id, sa2);
        test.startTest();
        	NGMCP_ServiceAppointmentTriggerHelper.handleAfterUpdate(newList, oldMap);
        	NGMCP_ServiceAppointmentTriggerHelper.handleAfterUpdate(null, null);
        	NGMCP_ServiceAppointmentTriggerHelper.handleAfterUpdate(newList2, null);
        test.stopTest();
        
    }
}