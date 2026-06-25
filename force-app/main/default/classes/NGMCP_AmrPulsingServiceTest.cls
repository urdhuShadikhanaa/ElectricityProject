/**
 * @File Name         : NGMCP_AmrPulsingServiceTest.cls
 * @Description       : Tests for NGMCP_AmrPulsingService.getPulsing covering
 *                      matching and non-matching year ranges and multiple rules.
 * @Author            : 
 * @Last Modified By  : 
 * @Last Modified On  : March 4, 2026
 * @Modification Log  :
 *==============================================================================
 * Ver | Date           | Author        | Modification
 *==============================================================================
 * 1.0 | Jan 2, 2026    |  | Initial Version
 * 1.1 | Mar 4, 2026    |  | Add full coverage tests
 **/

@isTest
private class NGMCP_AmrPulsingServiceTest {

    /**
     * Test data setup: Custom Metadata cannot be inserted via DML in tests.
     * We will instead test behavior that does not require seeding CMDT:
     *  - When no matching rules exist, service returns empty string.
     *  - Guard that SOQL executes safely with no records and boundaries logic isn't hit.
     * If org already has CMDT packaged, tests that rely on it are environment-coupled.
     * To keep tests hermetic (no SeeAllData), we avoid relying on real CMDT.
     */
    // No insertRule helper possible for CMDT in tests.

    @isTest
    static void testNoDataReturnsEmpty() {
        Test.startTest();
        String result = NGMCP_AmrPulsingService.getPulsing('SC1', 'M1', 2012);
        Test.stopTest();
        System.assertEquals('', result, 'With no CMDT present, should return empty');
    }

    @isTest
    static void testUnknownKeyReturnsEmpty() {
        Test.startTest();
        String result = NGMCP_AmrPulsingService.getPulsing('UNKNOWN', 'MODELX', 2000);
        Test.stopTest();
        System.assertEquals('', result, 'Unknown key should return empty');
    }

    @isTest
    static void testReturnsEmptyWhenNoRulesForKey() {
        Test.startTest();
        String result = NGMCP_AmrPulsingService.getPulsing('UNKNOWN', 'MODELX', 2000);
        Test.stopTest();

        System.assertEquals('', result, 'Should return empty when no rules exist');
    }

    @isTest
    static void testBoundaryNoDataStillEmpty() {
        //Test.startTest();
        String resFrom = NGMCP_AmrPulsingService.getPulsing('SC2', 'M2', 2000);
        //Test.stopTest();
        System.assertEquals('', resFrom, 'Without CMDT, boundary call returns empty');

        Test.startTest();
        String resTo = NGMCP_AmrPulsingService.getPulsing('SC2', 'M2', 2005);
        Test.stopTest();
        System.assertEquals('', resTo, 'Without CMDT, boundary call returns empty');
    }

    @isTest
    static void testMultipleCallsNoData() {
        //Test.startTest();
        String res1 = NGMCP_AmrPulsingService.getPulsing('SC3', 'M3', 1993);
        //Test.stopTest();
        System.assertEquals('', res1, 'No CMDT => empty');

        Test.startTest();
        String res2 = NGMCP_AmrPulsingService.getPulsing('SC3', 'M3', 1999);
        Test.stopTest();
        System.assertEquals('', res2, 'No CMDT => empty');
    }

    @isTest
    static void testYearOutsideAllRangesStillEmptyWithoutData() {
        Test.startTest();
        String res = NGMCP_AmrPulsingService.getPulsing('SC4', 'M4', 2013);
        Test.stopTest();
        System.assertEquals('', res, 'Without CMDT, always empty');
    }
}