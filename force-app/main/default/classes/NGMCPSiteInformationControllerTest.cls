@IsTest
private class NGMCPSiteInformationControllerTest {

    @TestSetup
    static void setupData() {
        // Create minimal site
        FFA_Site__c site = new FFA_Site__c(
            Name = 'Test Site',
            FFA_Title__c = 'Mr',
            FFA_ContactTelephoneNumber__c = '0123456789',
            FFA_AccessInstructions__c = 'Gate code 1234'
        );
        insert site;

        // Create WorkOrder linked to site
        WorkOrder woWithSite = new WorkOrder(
            Subject = 'WO with Site',
            Status = 'New',
            Site__c = site.Id,
            NGMCP_Site_contact_details__c = 'Yes'
        );
        insert woWithSite;

        // Create WorkOrder without site to test exception path
        WorkOrder woNoSite = new WorkOrder(
            Subject = 'WO with no Site',
            Status = 'New'
        );
        insert woNoSite;
    }

    private static WorkOrder getAnyWorkOrderWithSite() {
        return [
            SELECT Id, Site__c, NGMCP_Site_contact_details__c
            FROM WorkOrder
            WHERE Site__c != null
            LIMIT 1
        ];
    }

    private static WorkOrder getAnyWorkOrderWithoutSite() {
        return [
            SELECT Id, Site__c
            FROM WorkOrder
            WHERE Site__c = null
            LIMIT 1
        ];
    }

    @IsTest
    static void test_getWorkOrderDetails_success() {
        WorkOrder wo = getAnyWorkOrderWithSite();

        Test.startTest();
        NGMCPSiteInformationController.WOWrapper wrap =
            NGMCPSiteInformationController.getWorkOrderDetails(wo.Id);
        Test.stopTest();

        System.assertNotEquals(null, wrap, 'Wrapper should not be null');
        System.assertEquals(wo.Id, wrap.workOrderId, 'WorkOrder Id should match');
        System.assertNotEquals(null, wrap.siteId, 'Site Id should be populated');
        System.assertNotEquals(null, wrap.name, 'Site Name should be populated');
        // Title/Phone/Access come from site
        System.assertNotEquals(null, wrap.title);
        System.assertNotEquals(null, wrap.phone);
        System.assertNotEquals(null, wrap.access);
        // Flag is copied from WorkOrder
        System.assertEquals(wo.NGMCP_Site_contact_details__c, wrap.flag);
    }

    @IsTest
    static void test_getWorkOrderDetails_noSite_throws() {
        WorkOrder wo = getAnyWorkOrderWithoutSite();

        Boolean threw = false;
        Test.startTest();
        try {
            NGMCPSiteInformationController.getWorkOrderDetails(wo.Id);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();

        System.assertEquals(true, threw, 'Should throw for WO without Site');
    }

    @IsTest
    static void test_updateSiteDetails_success_updatesSiteAndWorkOrder() {
        // Prepare fresh site + work order
        FFA_Site__c site = new FFA_Site__c(
            Name = 'Update Site',
            FFA_Title__c = 'Ms',
            FFA_ContactTelephoneNumber__c = '0987654321',
            FFA_AccessInstructions__c = 'Back door'
        );
        insert site;

        WorkOrder wo = new WorkOrder(
            Subject = 'To Update',
            Status = 'New',
            Site__c = site.Id,
            NGMCP_Site_contact_details__c = 'Yes'
        );
        insert wo;

        // Prepare changes for site
        FFA_Site__c siteUpdate = new FFA_Site__c(
            Id = site.Id,
            FFA_Title__c = 'Dr',
            FFA_ContactTelephoneNumber__c = '0111222333',
            FFA_AccessInstructions__c = 'Front door'
        );

        Test.startTest();
        String result = NGMCPSiteInformationController.updateSiteDetails(siteUpdate, wo.Id);
        Test.stopTest();

        System.assertEquals('SUCCESS', result, 'Expected SUCCESS');

        // Validate Site updated
        FFA_Site__c afterSite = [
            SELECT Id, FFA_Title__c, FFA_ContactTelephoneNumber__c, FFA_AccessInstructions__c
            FROM FFA_Site__c
            WHERE Id = :site.Id
        ];
        System.assertEquals('Dr', afterSite.FFA_Title__c);
        System.assertEquals('0111222333', afterSite.FFA_ContactTelephoneNumber__c);
        System.assertEquals('Front door', afterSite.FFA_AccessInstructions__c);

        // Validate WorkOrder flag set to 'No'
        WorkOrder afterWo = [
            SELECT Id, NGMCP_Site_contact_details__c
            FROM WorkOrder
            WHERE Id = :wo.Id
        ];
        System.assertEquals('No', afterWo.NGMCP_Site_contact_details__c, 'WorkOrder flag should be set to No');
    }

    @IsTest
    static void test_updateSiteDetails_dmlException_onInvalidSite() {
        // Use a valid site Id but set an overlong field value to violate field length and trigger DML exception
        FFA_Site__c site = new FFA_Site__c(
            Name = 'DML Fail Site',
            FFA_Title__c = 'Mx',
            FFA_ContactTelephoneNumber__c = '0700000000',
            FFA_AccessInstructions__c = 'OK'
        );
        insert site;

        WorkOrder wo = new WorkOrder(
            Subject = 'DML Fail WO',
            Status = 'New',
            Site__c = site.Id,
            NGMCP_Site_contact_details__c = 'Yes'
        );
        insert wo;

        // Build an excessively long phone number to exceed likely field length (e.g., 255+)
        String longPhone = String.valueOf(Crypto.generateDigest('SHA-256', Blob.valueOf('x'))); // 32-byte hex
        // Expand to a very long string
        longPhone = longPhone.repeat(20);

        FFA_Site__c badUpdate = new FFA_Site__c(
            Id = site.Id,
            FFA_ContactTelephoneNumber__c = longPhone
        );

        Boolean threw = false;
        Test.startTest();
        try {
            NGMCPSiteInformationController.updateSiteDetails(badUpdate, wo.Id);
        } catch (AuraHandledException e) {
            threw = true; // Expect DML wrapped in AuraHandledException: 'Update failed: ...'
        }
        Test.stopTest();

        System.assertEquals(true, threw, 'Should throw DML exception for invalid Site update (field length)');
    }

    @IsTest
    static void test_updateSiteDetails_generalException_onNullWorkOrderId() {
        // Create a valid site to update
        FFA_Site__c site = new FFA_Site__c(
            Name = 'Err Site',
            FFA_Title__c = 'Mr',
            FFA_ContactTelephoneNumber__c = '0700000000',
            FFA_AccessInstructions__c = 'Call first'
        );
        insert site;

        // Valid site update
        FFA_Site__c siteUpdate = new FFA_Site__c(
            Id = site.Id,
            FFA_Title__c = 'Prof'
        );

        Boolean threw = false;
        Test.startTest();
        try {
            NGMCPSiteInformationController.updateSiteDetails(siteUpdate, null);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();

        System.assertEquals(true, threw, 'Should throw general exception when workOrderId is null');
    }
}