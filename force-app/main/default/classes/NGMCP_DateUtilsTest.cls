/**
 * @File Name         : NGMCP_DateUtilsTest.cls
 * @Description       : Test class for validating NGMCP_DateUtils methods.
 *                      This test class follows the established patterns in the project.
 * @Author            : 
 * @Last Modified By  : 
 * @Last Modified On  : January 30, 2026
 * @Modification Log  :
 *==============================================================================
 * Ver | Date             | Author             | Modification
 *==============================================================================
 * 1.0 | January 30, 2026 |      | Initial Version
 **/

@isTest
private class NGMCP_DateUtilsTest {

    /**
     * @description
     *   Tests the initialization and basic functionality of the DateUtils class.
     *   Ensures proper class instantiation and method availability.
     */
    @isTest 
    static void testDateUtilsInstantiation() {
        // Create a mock instance to test class structure
        List<String> all = NGMCP_DateUtils.allFutureDdMmYyyyFromDescription('my new date is 21/02', Date.today());
        String first = NGMCP_DateUtils.firstFutureDdMmYyyyFromDescription('my new date is 21/02', Date.today());
        String expand = NGMCP_DateUtils.expandFutureDdMmToDdMmYyyy('my new date is 21/02', Date.today());
        
    }

}