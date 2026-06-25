/**
 * @File Name : NGMCP_HttpMockTestClassTest.cls
 * @Description : Test class for validating the NGMCP_HttpMockTestClass implementation.
 *                This class tests that the HttpCalloutMock implementation properly returns
 *                the expected mock response structure for IBM Maximo API calls.
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
public class NGMCP_HttpMockTestClassTest {
    
    /**
     * @description
     *   Tests that the NGMCP_HttpMockTestClass properly implements HttpCalloutMock
     *   and returns a valid HttpResponse with expected structure and content.
     */
    @isTest 
    static void testHttpCalloutMockImplementation() {
        // Create an instance of the mock class
        NGMCP_HttpMockTestClass mock = new NGMCP_HttpMockTestClass();
        
        // Create a mock HTTP request (required for the respond method)
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://test.example.com');
        req.setMethod('GET');
        
        // Call the respond method
        HttpResponse res = mock.respond(req);
        
        // Validate the response
        System.assertNotEquals(null, res, 'HttpResponse should not be null');
        
        // Validate status code
        System.assertEquals(200, res.getStatusCode(), 'Expected status code 200');
        
        // Validate content type header
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Expected Content-Type header');
        
        // Validate response body is not null or empty
        System.assertNotEquals(null, res.getBody(), 'ResponseBody should not be null');
        System.assertNotEquals('', res.getBody(), 'ResponseBody should not be empty');
        
        // Validate that the response body contains expected JSON structure
        String responseBody = res.getBody();
        System.assert(responseBody.contains('"member"'), 'Response body should contain member array');
        System.assert(responseBody.contains('"responseInfo"'), 'Response body should contain responseInfo object');
        System.assert(responseBody.contains('"ngme_c_ss"'), 'Response body should contain street information');
        System.assert(responseBody.contains('"ngme_c_st"'), 'Response body should contain city information');
        System.assert(responseBody.contains('"asset"'), 'Response body should contain asset array');
        
        // Validate that the JSON is parseable
        try {
            // Try to deserialize the JSON to verify it's valid
            Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.assert(parsedJson.containsKey('member'), 'Parsed JSON should contain member key');
            System.assert(parsedJson.containsKey('responseInfo'), 'Parsed JSON should contain responseInfo key');
            System.debug('Successfully parsed mock response JSON');
        } catch (Exception e) {
            System.assert(false, 'Mock response body should be valid JSON: ' + e.getMessage());
        }
    }
    
    /**
     * @description
     *   Tests that the mock response contains all expected fields for asset details.
     *   This validates that the mock data matches the expected structure from Maximo API.
     */
    @isTest 
    static void testMockResponseStructure() {
        // Create an instance of the mock class
        NGMCP_HttpMockTestClass mock = new NGMCP_HttpMockTestClass();
        
        // Create a mock HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://test.example.com');
        req.setMethod('GET');
        
        // Call the respond method
        HttpResponse res = mock.respond(req);
        
        // Parse the response body to validate structure
        Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        
        // Validate member array exists and has data
        List<Object> members = (List<Object>) parsedJson.get('member');
        System.assert(members != null && members.size() > 0, 'Member array should exist and contain data');
        
        // Validate first member has expected fields
        Map<String, Object> firstMember = (Map<String, Object>) members[0];
        System.assert(firstMember.containsKey('ngme_c_ss'), 'First member should contain ngme_c_ss');
        System.assert(firstMember.containsKey('ngme_c_st'), 'First member should contain ngme_c_st');
        System.assert(firstMember.containsKey('pluspcustassoc'), 'First member should contain pluspcustassoc');
        System.assert(firstMember.containsKey('asset'), 'First member should contain asset');
        System.assert(firstMember.containsKey('siteid'), 'First member should contain siteid');
        System.assert(firstMember.containsKey('location'), 'First member should contain location');
        
        // Validate pluspcustassoc array
        List<Object> custAssocs = (List<Object>) firstMember.get('pluspcustassoc');
        System.assert(custAssocs != null && custAssocs.size() > 0, 'pluspcustassoc should exist and contain data');
        
        // Validate first customer association
        Map<String, Object> firstCustAssoc = (Map<String, Object>) custAssocs[0];
        System.assert(firstCustAssoc.containsKey('customer'), 'Customer association should contain customer');
        System.assert(firstCustAssoc.containsKey('type'), 'Customer association should contain type');
        System.assert(firstCustAssoc.containsKey('isprimary'), 'Customer association should contain isprimary');
        
        // Validate asset array
        List<Object> assets = (List<Object>) firstMember.get('asset');
        System.assert(assets != null && assets.size() > 0, 'Asset array should exist and contain data');
        
        // Validate first asset
        Map<String, Object> firstAsset = (Map<String, Object>) assets[0];
        System.assert(firstAsset.containsKey('assetnum'), 'Asset should contain assetnum');
        System.assert(firstAsset.containsKey('assettype'), 'Asset should contain assettype');
        System.assert(firstAsset.containsKey('status'), 'Asset should contain status');
        
        // Validate responseInfo
        Map<String, Object> responseInfo = (Map<String, Object>) parsedJson.get('responseInfo');
        System.assert(responseInfo != null, 'responseInfo should exist');
        System.assert(responseInfo.containsKey('href'), 'responseInfo should contain href');
    }
    
    /**
     * @description
     *   Tests that the mock handles different HTTP request methods correctly.
     *   Although the mock implementation doesn't use the request, we should still
     *   verify it can handle various request configurations.
     */
    @isTest 
    static void testMockWithDifferentHttpRequests() {
        // Create an instance of the mock class
        NGMCP_HttpMockTestClass mock = new NGMCP_HttpMockTestClass();
        
        // Test with GET request
        HttpRequest getRequest = new HttpRequest();
        getRequest.setEndpoint('https://test.example.com/get');
        getRequest.setMethod('GET');
        HttpResponse getResponse = mock.respond(getRequest);
        System.assertEquals(200, getResponse.getStatusCode(), 'GET request should return 200');
        
        // Test with POST request
        HttpRequest postRequest = new HttpRequest();
        postRequest.setEndpoint('https://test.example.com/post');
        postRequest.setMethod('POST');
        HttpResponse postResponse = mock.respond(postRequest);
        System.assertEquals(200, postResponse.getStatusCode(), 'POST request should return 200');
        
        // Test with PUT request
        HttpRequest putRequest = new HttpRequest();
        putRequest.setEndpoint('https://test.example.com/put');
        putRequest.setMethod('PUT');
        HttpResponse putResponse = mock.respond(putRequest);
        System.assertEquals(200, putResponse.getStatusCode(), 'PUT request should return 200');
        
        // Verify all responses have the same structure
        System.assertEquals('application/json', getResponse.getHeader('Content-Type'), 'GET response should have correct Content-Type');
        System.assertEquals('application/json', postResponse.getHeader('Content-Type'), 'POST response should have correct Content-Type');
        System.assertEquals('application/json', putResponse.getHeader('Content-Type'), 'PUT response should have correct Content-Type');
        
        // Verify all responses have bodies
        System.assertNotEquals(null, getResponse.getBody(), 'GET response should have body');
        System.assertNotEquals(null, postResponse.getBody(), 'POST response should have body');
        System.assertNotEquals(null, putResponse.getBody(), 'PUT response should have body');
    }
    
    /**
     * @description
     *   Tests that the mock can be used in a test context similar to how it's used
     *   in NGMCP_IBMMaximoIntegrationTest class.
     */
    @isTest 
    static void testMockIntegrationScenario() {
        // This test simulates how the mock would be used in a real test scenario
        
        // Set the mock HTTP response (similar to NGMCP_IBMMaximoIntegrationTest)
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpMockTestClass());
        
        // Create a mock HTTP request to verify the mock works
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
        System.assert(responseBody.contains('"member"'), 'Mock response should contain member array');
        System.assert(responseBody.contains('"responseInfo"'), 'Mock response should contain responseInfo object');
    }
}