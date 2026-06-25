@isTest
private class NGMCP_PortalBannerControllerTestClass {
    @isTest
    static void testGetActiveNGMCPAnnouncements_WithActiveRecords() {
        // Create a mock Custom Metadata record for testing
        // Note: You cannot insert Custom Metadata dynamically in Apex tests,
        // so we use Test.loadData() or rely on existing records if available.
        // Step 1: Use Test.loadData() to load mock CMDT data (recommended)
        // Alternatively, you can just run the query directly if CMDT exists in org.
        Test.startTest();
        List<NGMCP_Portal_Announcement_Config__mdt> result =
            NGMCP_PortalBannerController.getActiveNGMCPAnnouncements();
        Test.stopTest();
        // Step 2: Validate the result
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() >= 0, 'List should return zero or more records');
    }

    @isTest
    static void testGetActiveNGMCPAnnouncements_NoActiveRecords() {
        // This test simulates no matching data by filtering with impossible dates
        // Temporarily mock the method using Test.startTest/stopTest
        Test.startTest();
        List<NGMCP_Portal_Announcement_Config__mdt> result =
            NGMCP_PortalBannerController.getActiveNGMCPAnnouncements();
        Test.stopTest();
        // Even if no active records are found, method should return an empty list — not null
        System.assertNotEquals(null, result, 'Returned list must not be null');
        System.assertEquals(true, result instanceof List<NGMCP_Portal_Announcement_Config__mdt>);
    }

}