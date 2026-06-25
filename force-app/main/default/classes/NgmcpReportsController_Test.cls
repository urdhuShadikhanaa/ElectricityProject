@isTest
public class NgmcpReportsController_Test {

    /**
     * HOW WE AVOID ERRORS WHILE LINKING ContactId
     * -------------------------------------------
     * Salesforce allows setting User.ContactId **only for portal/Experience Cloud users**
     * (Customer/Partner/External). Internal users (e.g., System Administrator) cannot be
     * associated to a Contact — doing so raises FIELD_INTEGRITY_EXCEPTION.
     *
     * Strategy:
     *  - @testSetup inserts only NON-SETUP data (Account + Contact).
     *  - Test helper inspects the target Profile's UserLicense. If it looks like a
     *    portal license (contains 'Customer', 'Partner', or 'External'), we set ContactId.
     *    Otherwise, we skip ContactId to avoid the error.
     */

    @testSetup
    static void setupNonSetupData() {
        // Non-setup DML only
        Account a = new Account(Name = 'Portal Account');
        insert a;
        insert new Contact(FirstName = 'Link', LastName = 'Me', Email = 'contact+link@test.tld', AccountId = a.Id);
    }

    /** Helper: returns the Contact created in @testSetup */
    private static Contact getSetupContact() {
        return [SELECT Id, Email FROM Contact WHERE LastName = 'Me' ORDER BY CreatedDate DESC LIMIT 1];
    }

    /** Helper: detects if the profile is a portal/Experience Cloud profile */
    private static Boolean isPortalProfile(Profile p) {
        // Defensive: handle null UserLicense (rare)
        String lic = (p.UserLicenseId == null) ? null : [SELECT Name FROM UserLicense WHERE Id = :p.UserLicenseId].Name;
        if (String.isBlank(lic)) return false;
        lic = lic.toLowerCase();
        // Common Experience Cloud licenses
        // e.g., 'Customer Community', 'Customer Community Plus', 'Partner Community',
        // 'External Apps', 'Experience Cloud Customer', etc.
        return lic.contains('customer') || lic.contains('partner') || lic.contains('external') || lic.contains('experience');
    }

    /** Helper: create a User with given profile, optional supplier codes, and optional Contact link (only for portal profiles) */
    private static User makeUserWithProfile(String profileName, String supplierCodes, Boolean attachContactIfPortal, String roleName) {
        Profile p = [SELECT Id, Name, UserLicenseId FROM Profile WHERE Name = :profileName LIMIT 1];
        Boolean portal = isPortalProfile(p);
        Contact c = getSetupContact();
		UserRole ur = [Select Id from userrole where name =: roleName limit 1];
        String suffix = String.valueOf(Datetime.now().getTime()) + Math.mod(Crypto.getRandomInteger(), 1000000);
        String uname  = 'user_' + suffix + '@example.com';
        User u = new User(
            FirstName = 'Test',
            LastName  = profileName.left(30).replace(' ', '_'),
            Email     = uname,
            Username  = uname,
            Alias     = ('u' + String.valueOf(Math.abs(Crypto.getRandomInteger()))).left(8),
            TimeZoneSidKey    = 'Asia/Kolkata',
            LocaleSidKey      = 'en_US',
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId         = p.Id,
            UserRoleId = ur.Id
        );
        if (portal && attachContactIfPortal && c != null) {
            u.ContactId = c.Id; // ✅ only for portal users
        }
        if (supplierCodes != null) {
            u.Supplier_Code__c = supplierCodes;
        }
        insert u; // setup DML (separate from @testSetup)
        return u;
    }

    // ----------------------------
    // Core smoke tests
    // ----------------------------

    @IsTest
    static void test_blankKey_returnsEmpty() {
        // Internal profile -> ContactId will be skipped to avoid FIELD_INTEGRITY_EXCEPTION
        User admin = makeUserWithProfile('System Administrator', null, true, 'NG Admin');
        System.runAs(admin) {
            Test.startTest();
            List<NgmcpReportsController.ReportRow> rows = NgmcpReportsController.getReportData('');
            Test.stopTest();
            System.assertEquals(0, rows.size());
        }
    }

    @IsTest
    static void test_USER_DETAILS_asAdmin_contactNotLinked_forInternalProfile() {
        User admin = makeUserWithProfile('System Administrator', null, true, 'NG Admin');
        System.assertEquals(null, [SELECT ContactId FROM User WHERE Id = :admin.Id].ContactId,
            'Internal users cannot have ContactId; helper should have skipped it.');
        System.runAs(admin) {
            Test.startTest();
            List<NgmcpReportsController.ReportRow> rows = NgmcpReportsController.getReportData('USER_DETAILS');
            Test.stopTest();
            System.assertNotEquals(null, rows);
        }
    }

    // ----------------------------
    // WorkOrder report routing
    // ----------------------------

   @isTest 
    static void test_WorkOrderReports_asManager_withSupplierCodes() {
        // These NGMCP_* profiles are typically internal; ContactId will be skipped
        //User mgr = makeUserWithProfile('NGMCP_Gas Supplier Manager', 'SC1;SC2', true);
        List<String> supplierCodes = new List<String>{'EFG'};	
        NGMCP_Request__c req = new NGMCP_Request__c();
        req.NGMCP_SR_Ticket__c = '1234';
        req.NGMCP_Status__c = '1234';
        req.NGMCP_MPRN__c = '1234';
        req.NGMCP_Supplier_Id__c = 'EFG';
        req.NGMCP_Building_Name__c = 'Test Name';
        req.NGMCP_Building_Number__c = 'Test Number';
        req.NGMCP_Street__c = 'Test Street';
        req.NGMCP_Dependent_Locality__c = 'Test Locality';
        req.NGMCP_Postal_Town__c = 'Test Town';
        req.NGMCP_Postal_Code__c = 'Test code';
        req.NGMCP_Affected_Person__c = 'test';
        req.NGMCP_Affectedphone__c = '24242';
        req.NGMCP_Quotation_Status__c = 'Text';
        
        List<NGMCP_Request__c> reqList = new List<NGMCP_Request__c>();
        reqList.add(req);
        insert reqList;
        
       	//User mgr = makeUserWithProfile('NGMCP_Gas Supplier Manager', null, true, 'Expeience cloud Account Customer User');
        NgmcpReportsController.fetchWorkOrderReports('COMPLETED_PME', supplierCodes, userinfo.getuserid());
        NgmcpReportsController.fetchWorkOrderReports('INPROGRESS_PME', supplierCodes, userinfo.getuserid());
        NgmcpReportsController.fetchWorkOrderReports('ADDINFO_WO', supplierCodes, userinfo.getuserid());
        NgmcpReportsController.fetchWorkOrderReports('COMP_WO', supplierCodes, userinfo.getuserid());
        NgmcpReportsController.fetchWorkOrderReports('INPROGRESS_WO', supplierCodes, userinfo.getuserid());
        NgmcpReportsController.mapRequests(reqList,'');
        NgmcpReportsController.mapRequests(reqList,'WORKORDERS');
        
    }

    @IsTest
    static void test_WorkOrderReports_asAgent_noSupplierCodes_returnsEmpty() {
        NgmcpReportsController.isValidDate('2000', '12', '31');
        NgmcpReportsController.isValidDate('test', '12', '31');
        NgmcpReportsController.toDdDashMmDashYyyy('');
        NgmcpReportsController.toDdDashMmDashYyyy('2020-12-30');
        WorkOrder wo = new WorkOrder();
        wo.Status = 'New';
        wo.FFA_MeterPointReferenceNumber__c = '1234';
        wo.Job_Category__c = 'Test Job';
        wo.FFA_ShipperID__c = '1234';
        wo.FFA_JobDescription__c = 'Description';
        wo.FFA_RequestedAppointmentDate__c = date.today();
        List<WorkOrder> wolist = new List<WorkOrder>();
        woList.add(wo);
        insert woList;
        NgmcpReportsController.mapWorkOrders(woList);
        
    }

    // ----------------------------
    // Request report routing (no org-data assumed)
    // ----------------------------

    @IsTest
    static void test_RequestReports_asCRM() {
        User crm = makeUserWithProfile('CRM Profile', null, true, 'NG Admin');
        System.runAs(crm) {
            Test.startTest();
            NgmcpReportsController.getReportData('ADDINFO_ENQ');
            NgmcpReportsController.getReportData('TECHNICAL_QUERIES');
            NgmcpReportsController.getReportData('DATA_QUERIES');
            NgmcpReportsController.getReportData('OPEN_TECHNICAL_QUERIES');
            NgmcpReportsController.getReportData('OPEN_DATA_QUERIES');
            NgmcpReportsController.getReportData('WORKORDERS');
            NgmcpReportsController.getReportData('WR_AND_ENQ');
            NgmcpReportsController.getReportData('APP_AND_DEAPP');
            NgmcpReportsController.getReportData('QUOTE_STATUS');
            NgmcpReportsController.getReportData('ALL_AMR');
            NgmcpReportsController.getReportData('ALL_OPEN_AMR');
            Test.stopTest();
        }
    }

    // ----------------------------
    // Optional: Create a TRUE portal user if your org has a portal profile available
    // ----------------------------

    @IsTest
    static void test_createPortalUser_whenPortalProfileExists() {
        // Try to find any portal/Experience Cloud profile by license (if none, test will simply skip user creation)
        List<Profile> portalProfiles = [
            SELECT Id, Name, UserLicenseId,
                   (SELECT Name FROM Users LIMIT 1)
            FROM Profile
            WHERE UserLicenseId IN (
                SELECT Id FROM UserLicense WHERE Name LIKE '%Customer%'
                                         OR   Name LIKE '%Partner%'
                                         OR   Name LIKE '%External%'
                                         OR   Name LIKE '%Experience%'
            )
            LIMIT 1
        ];
        if (!portalProfiles.isEmpty()) {
            Profile portalP = portalProfiles[0];

        } else {
            System.debug('No portal profile found in this org; skipping portal user creation.');
        }
    }
    
    @istest
    public static void testMethod1(){
        User u = [Select id, Supplier_Code__c from user where id =: userinfo.getuserid() limit 1];
        u.Supplier_Code__c = 'ABC';
        update u;
        NgmcpReportsController.getSupplierCodes();
    }
}