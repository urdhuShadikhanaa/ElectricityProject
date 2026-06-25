/**
 * @File Name : NGMCP_HttpSubmitworkRequestCalloutTest.cls
 * @Description : Test class for validating NGMCP_HttpSubmitworkRequestCallout functionality.
 *                This test class follows the established patterns in the project.
 * @Author : P Shabbir Ali Khan
 * @Last Modified By : 
 * @Last Modified On : January 30, 2026
 * @Modification Log :
 *==============================================================================
 * Ver | Date             | Author             | Modification
 *==============================================================================
 * 1.0 | January 30, 2026 | P Shabbir Ali Khan | Initial Version
 **/

@isTest
private class NGMCP_HttpSubmitworkRequestCalloutTest {

    /**
     * @description
     *   Tests the respond method of NGMCP_HttpSubmitworkRequestCallout.
     *   Validates that the mock returns a proper HTTP response with expected content.
     */
    @isTest 
    static void testRespondMethod() {
        // Create an instance of the mock callout
        NGMCP_HttpSubmitworkRequestCallout mock = new NGMCP_HttpSubmitworkRequestCallout();
        
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
        
        // Validate all expected fields are present in the response
        System.assert(responseBody.contains('"reportedpriority":"1"'), 'Response body should contain reportedpriority');
        System.assert(responseBody.contains('"job_type":"OTVST"'), 'Response body should contain job_type');
        System.assert(responseBody.contains('"affectedphone":"01234567890"'), 'Response body should contain affectedphone');
        System.assert(responseBody.contains('"description_longdescription":"Test-Retrospective YES"'), 'Response body should contain description_longdescription');
        System.assert(responseBody.contains('"job_subtype":"FAULT"'), 'Response body should contain job_subtype');
        System.assert(responseBody.contains('"targetstart":"2025-10-04"'), 'Response body should contain targetstart');
        System.assert(responseBody.contains('"ngme_time":"05:42"'), 'Response body should contain ngme_time');
        System.assert(responseBody.contains('"source":"PORTAL"'), 'Response body should contain source');
        System.assert(responseBody.contains('"job_sub_subtype":"EXCFT40"'), 'Response body should contain job_sub_subtype');
        System.assert(responseBody.contains('"ngme_liferay_slot":"AT"'), 'Response body should contain ngme_liferay_slot');
        System.assert(responseBody.contains('"ngme_industry":"D"'), 'Response body should contain ngme_industry');
        System.assert(responseBody.contains('"assetnum":"2360"'), 'Response body should contain assetnum');
        System.assert(responseBody.contains('"suppliercode":"LEP"'), 'Response body should contain suppliercode');
        System.assert(responseBody.contains('"location":"1000023705"'), 'Response body should contain location');
        System.assert(responseBody.contains('"affectedperson":"Tina"'), 'Response body should contain affectedperson');
        
        // Validate that the JSON is parseable
        try {
            // Try to deserialize the JSON to verify it's valid
            Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.assert(parsedJson.containsKey('reportedpriority'), 'Parsed JSON should contain reportedpriority key');
            System.assert(parsedJson.containsKey('job_type'), 'Parsed JSON should contain job_type key');
            System.assert(parsedJson.containsKey('affectedphone'), 'Parsed JSON should contain affectedphone key');
            System.assert(parsedJson.containsKey('description_longdescription'), 'Parsed JSON should contain description_longdescription key');
            System.assert(parsedJson.containsKey('job_subtype'), 'Parsed JSON should contain job_subtype key');
            System.assert(parsedJson.containsKey('targetstart'), 'Parsed JSON should contain targetstart key');
            System.assert(parsedJson.containsKey('ngme_time'), 'Parsed JSON should contain ngme_time key');
            System.assert(parsedJson.containsKey('source'), 'Parsed JSON should contain source key');
            System.assert(parsedJson.containsKey('job_sub_subtype'), 'Parsed JSON should contain job_sub_subtype key');
            System.assert(parsedJson.containsKey('ngme_liferay_slot'), 'Parsed JSON should contain ngme_liferay_slot key');
            System.assert(parsedJson.containsKey('ngme_industry'), 'Parsed JSON should contain ngme_industry key');
            System.assert(parsedJson.containsKey('assetnum'), 'Parsed JSON should contain assetnum key');
            System.assert(parsedJson.containsKey('suppliercode'), 'Parsed JSON should contain suppliercode key');
            System.assert(parsedJson.containsKey('location'), 'Parsed JSON should contain location key');
            System.assert(parsedJson.containsKey('affectedperson'), 'Parsed JSON should contain affectedperson key');
            System.debug('Successfully parsed mock response JSON');
        } catch (Exception e) {
            System.assert(false, 'Mock response body should be valid JSON: ' + e.getMessage());
        }
    }
    
    /**
     * @description
     *   Tests that the mock can be used in a test context similar to how it's used
     *   in other test classes.
     */
    @isTest 
    static void testMockIntegrationScenario() {
        // Set the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpSubmitworkRequestCallout());
        
        // Create a mock HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://test.example.com');
        req.setMethod('GET');
        
        // Create HTTP client and send request
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // Validate response
        System.assertEquals(200, res.getStatusCode(), 'Mock should return 200 status');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Mock should return JSON content type');
        System.assertNotEquals(null, res.getBody(), 'Mock should return non-null body');
        
        // Validate body contains expected structure
        String responseBody = res.getBody();
        System.assert(responseBody.contains('"reportedpriority":"1"'), 'Mock response should contain reportedpriority');
        System.assert(responseBody.contains('"job_type":"OTVST"'), 'Mock response should contain job_type');
    }
}