/**
 * @File Name         : NGMCP_HttpAddressMockTestCalloutTest.cls
 * @Description       : Test class for validating NGMCP_HttpAddressMockTestCallout functionality.
 *                      This test class follows the established patterns in the project.
 * @Author            : P Shabbir Ali Khan
 * @Last Modified By  : 
 * @Last Modified On  : January 30, 2026
 * @Modification Log  :
 *==============================================================================
 * Ver | Date             | Author             | Modification
 *==============================================================================
 * 1.0 | January 30, 2026 | P Shabbir Ali Khan | Initial Version
 **/

@isTest
private class NGMCP_HttpAddressMockTestCalloutTest {

    /**
     * @description
     *   Tests the respond method of NGMCP_HttpAddressMockTestCallout.
     *   Validates that the mock returns a proper HTTP response with expected content.
     */
    @isTest 
    static void testRespondMethod() {
        // Create an instance of the mock callout
        NGMCP_HttpAddressMockTestCallout mock = new NGMCP_HttpAddressMockTestCallout();
        
        // Create a dummy HTTP request
        HttpRequest req = new HttpRequest();
        
        // Call the respond method
        HttpResponse res = mock.respond(req);
        
        // Validate the response
        System.assertNotEquals(null, res, 'Expected non-null response');
        System.assertEquals(200, res.getStatusCode(), 'Expected status code 200');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Expected JSON content type');
        
        // Validate response body contains expected data
        String responseBody = res.getBody();
        System.assert(responseBody.contains('"ngme_c_st":"MONTROSE"'), 'Response body should contain expected street data');
        System.assert(responseBody.contains('"ngme_c_prncpstreet":"Avenue road"'), 'Response body should contain expected street data');
        System.assert(responseBody.contains('"ngme_c_depndlocality":"INVERBERVIE"'), 'Response body should contain expected locality data');
        System.assert(responseBody.contains('"ngme_c_spc":"DD10 0RR"'), 'Response body should contain expected postcode data');
        System.assert(responseBody.contains('"siteid":"SCO"'), 'Response body should contain expected siteid data');
        System.assert(responseBody.contains('"location":"1000023705"'), 'Response body should contain expected location data');
        System.assert(responseBody.contains('"ngme_c_bldngname":"23"'), 'Response body should contain expected building name data');
        
        // Validate asset data in response
        System.assert(responseBody.contains('"serialnum":"00600790"'), 'Response body should contain expected serial number');
        System.assert(responseBody.contains('"assetnum":"13517737"'), 'Response body should contain expected asset number');
    }
}