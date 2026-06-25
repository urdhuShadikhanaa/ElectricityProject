@IsTest
private class NGMCP_ServiceAppointmentTriggerTest2 {
     @testSetup
    static void createTestData(){
        
		OperatingHours oh = new OperatingHours(Name = 'Test Operating Hours',TimeZone = 'America/Los_Angeles');
        insert oh;
		
        ServiceTerritory st = new ServiceTerritory(Name = 'Test Territory',OperatingHoursId = oh.Id,
                                              IsActive = true);
        insert st;
        
        Account acct = new Account(Name = 'Test Account');
        insert acct;

		WorkOrder wo = new WorkOrder(Subject = 'WO for Service Appointment tests',AccountId = acct.Id,
                                     Status = 'New');
        insert wo;
        
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User u = new User(
            FirstName = 'Test',LastName = 'User',Alias = 'tuser',
            Email = 'testServiceAppTest@example.com',Username = 'testServiceAppTest@example.com',
            CommunityNickname = 'testuser_' + 123,TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',ProfileId = p.Id,IsActive = true);
        insert u;
		
        ServiceAppointment sa = new ServiceAppointment(
            ParentRecordId     = wo.Id, // Link to Work Order (or Work Order Line Item)
            ServiceTerritoryId = st.Id,
            //Status             = 'Scheduled',
            EarliestStartTime  = System.now().addHours(1),
            DueDate            = System.now().addHours(3),
            // Optional scheduling fields, set if your handler relies on them:
            SchedStartTime     = System.now().addHours(1),
            SchedEndTime       = System.now().addHours(2),
            // ArrivalWindowStart = now.addMinutes(60),
            // ArrivalWindowEnd   = now.addMinutes(120),
            Description        = 'SA created by test factory',
            //FFA_Long_Job_Ind__c = 'No',
            //FFA_Return_Job_Ind__c='No',
            FFAAssignedAPI__c='Unassigned',
            FFA_Work_Order__c = wo.Id
        );
        insert sa;
        ServiceAppointment sa2 = new ServiceAppointment(
            ParentRecordId     = wo.Id, // Link to Work Order (or Work Order Line Item)
            ServiceTerritoryId = st.Id,
            //Status             = 'Scheduled',
            EarliestStartTime  = System.now().addHours(1),
            DueDate            = System.now().addHours(3),
            // Optional scheduling fields, set if your handler relies on them:
            SchedStartTime     = System.now().addHours(1),
            SchedEndTime       = System.now().addHours(2),
            // ArrivalWindowStart = now.addMinutes(60),
            // ArrivalWindowEnd   = now.addMinutes(120),
            Description        = 'SA created by test factory',
            //FFA_Long_Job_Ind__c = 'No',
            //FFA_Return_Job_Ind__c='No',
            FFAAssignedAPI__c='Assigned',
            FFA_Work_Order__c = wo.Id
        );
        insert sa2;
	}
    
    @isTest
    static void testSATrigger(){
        //Map<Id, ServiceAppointment> oldMap = new Map<Id, ServiceAppointment>();
        //List<ServiceAppointment> newList = new List<ServiceAppointment>();
        WorkOrder wo = [Select id from workorder limit 1];
        List<Serviceappointment> saList = [Select Id, Status, FFA_Work_Order__c,FFA_Long_Job_Ind__c,
                                 FFA_Return_Job_Ind__c,FFAAssignedAPI__c,FFA_Long_Job_Date_Time__c
                                 from ServiceAppointment];
        //sa.Status = 'Arrived';
        /*newList.add(sa);
        System.debug('sa: '+sa);
        System.debug('newList: '+newList);
        Serviceappointment saNew = new Serviceappointment();
        saNew.FFA_Long_Job_Ind__c = 'Yes';
        saNew.FFA_Return_Job_Ind__c='Yes' ;
        saNew.FFAAssignedAPI__c = 'Assigned';
        saNew.FFA_Long_Job_Date_Time__c = System.now();
        saNew.Id = sa.Id;*/
        //saNew.FFA_Work_Order__c = wo.Id;
        
       // oldMap.put(saNew.Id,saNew);
        //System.debug('oldMap: '+oldMap);
        //
        for(ServiceAppointment sa : saList){
        sa.FFA_Long_Job_Ind__c = 'Yes';
        sa.FFA_Return_Job_Ind__c='Yes' ;
        sa.FFAAssignedAPI__c = sa.FFAAssignedAPI__c == 'Assigned' ? 'Unassigned' : 'Assigned';
        sa.Status = 'Scheduled';
        sa.FFA_Long_Job_Date_Time__c = System.now();
        }
        Test.startTest();
        	update saList;
        Test.stopTest();
		
       // NGMCP_ServiceAppointmentTriggerHelper.fetchSessionId();
       // NGMCP_ServiceAppointmentTriggerHelper.handleAfterUpdate(newList, oldMap);
        
    }

    
}