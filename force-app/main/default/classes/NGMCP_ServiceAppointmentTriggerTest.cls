@IsTest
private class NGMCP_ServiceAppointmentTriggerTest {
    @TestSetup
    static void setupData() {
        // Create a user with a profile that can hold the FSL permission set
        // Use an existing Profile Id appropriate for tests (e.g., Standard User)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User u = new User(
            FirstName = 'Test',
        LastName = 'FSL',
        Alias = 'tfsl',
        Email = 'test.fsl@example.com',
        Username = 'test.fsl@example.com.test',
        TimeZoneSidKey = 'Asia/Kolkata',
        LocaleSidKey = 'en_IN',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ProfileId = p.Id
            );
        insert u;
        
        // Assign the FSL permission set that grants access to Work Rules
        // Replace with the exact API Name in your org
        // Common names (examples, verify in your org):
        // - 'FSL_Admin' (Field Service Admin)
        // - 'Field_Service_Dispatcher'
        // - 'Field_Service_Scheduler'
        PermissionSet ps = [
            SELECT Id, Name
            FROM PermissionSet
            WHERE Name IN ('FSL_Admin_Permissions')
            LIMIT 1
        ];
        if (ps != null) {
            insert new PermissionSetAssignment(AssigneeId  = u.Id, PermissionSetId = ps.Id);
        }
    }
    
    @IsTest
    static void test_NoSRorNoRequest_NoNotifications1() {
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'test.fsl%@example.com.test' LIMIT 1];
        
        System.runAs(testUser) {
            // Prepare a minimal ServiceAppointment that won’t trip extra validations
            // IMPORTANT: set fields you need for your logic, but avoid triggering scheduling if not necessary
            Account a = new Account(Name = 'No SR Account');
            insert a;
            
            WorkOrder woNoSr = new WorkOrder(
                Subject   = 'WO without SR',
            AccountId = a.Id
                
            );
            insert woNoSr;
            ServiceAppointment sa = new ServiceAppointment(
                ParentRecordId = woNoSr.Id,     // Mandatory
            EarliestStartTime = System.now().addDays(1),
            DueDate = System.now().addDays(2),
            Status = 'None'              // Common default SA status
                );
            insert sa;
            System.debug('sa'+sa);
            Test.starttest();
            NGMCP_ServiceAppointmentTriggerHelper.fetchSessionId();
            test.stopTest();
            // Assertions here...
        }
    }
    
    @IsTest
    static void test_NoSRorNoRequest_NoNotifications() {
        
        Account a = new Account(Name = 'No SR Account');
        insert a;
        NGMCP_Request__c req = new NGMCP_Request__c(NGMCP_SR_Ticket__c = '1965056');
        insert req;
        WorkOrder woNoSr = new WorkOrder(
            Subject   = 'WO without SR',
        AccountId = a.Id, NGMCP_Service_Request_Number__c = '1965056'
            
        );
        insert woNoSr;
        ServiceAppointment sa = new ServiceAppointment(
            ParentRecordId = woNoSr.Id,     // Mandatory
        EarliestStartTime = System.now().addDays(1),
        DueDate = System.now().addDays(2),
        Status = 'None'             // Common default SA status
            );
        insert sa;
        Id saId = sa.Id;
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
    }
    private static ServiceAppointment buildOldSA(Id saId, String oldStatus) {
        ServiceAppointment oldSa = new ServiceAppointment();
        oldSa.Id = saId;
        oldSa.Status = oldStatus;
        return oldSa;
    }
    private static ServiceAppointment buildNewSA(Id saId, String newStatus, Id woId) {
        ServiceAppointment sa = new ServiceAppointment();
        sa.Id = saId;
        sa.Status = newStatus;
        sa.FFA_Work_Order__c = woId;  // required by helper
        return sa;
    }
    
}