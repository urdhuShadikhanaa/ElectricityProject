@isTest
public class NGMCP_PostCodeValidatorTest {
    
    /**
     * @description Tests the validatePostCode method with a valid postcode
     *              This test mocks a successful API response from Royal Mail
     */
    @isTest
    static void testValidatePostCodeWithValidPostCode() {
        // Create a mock HTTP response for a valid postcode
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"deliveryOffice": {"name": "London"}}');
        
        // Create a mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new PostCodeValidatorMock(mockResponse));
        
        // Test with a valid postcode
        Test.startTest();
        Boolean result = NGMCP_PostCodeValidator.validatePostCode('SW1A 1AA');
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should return true for valid postcode');
    }
    
    /**
     * @description Tests the validatePostCode method with an invalid postcode
     *              This test mocks an unsuccessful API response from Royal Mail
     */
    @isTest
    static void testValidatePostCodeWithInvalidPostCode() {
        // Create a mock HTTP response for an invalid postcode
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(404);
        mockResponse.setBody('{"error": "Not Found"}');
        
        // Create a mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new PostCodeValidatorMock(mockResponse));
        
        // Test with an invalid postcode
        Test.startTest();
        Boolean result = NGMCP_PostCodeValidator.validatePostCode('INVALID');
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for invalid postcode');
    }
    
    /**
     * @description Tests the validatePostCode method with null postcode
     *              This test verifies the method handles null input correctly
     */
    @isTest
    static void testValidatePostCodeWithNullPostCode() {
        // Test with null postcode
        Test.startTest();
        Boolean result = NGMCP_PostCodeValidator.validatePostCode(null);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for null postcode');
    }
    
    /**
     * @description Tests the validatePostCode method with empty postcode
     *              This test verifies the method handles empty input correctly
     */
    @isTest
    static void testValidatePostCodeWithEmptyPostCode() {
        // Test with empty postcode
        Test.startTest();
        Boolean result = NGMCP_PostCodeValidator.validatePostCode('');
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for empty postcode');
    }
    
    /**
     * @description Tests the validatePostCode method with whitespace-only postcode
     *              This test verifies the method handles whitespace-only input correctly
     */
    @isTest
    static void testValidatePostCodeWithWhitespacePostCode() {
        // Test with whitespace-only postcode
        Test.startTest();
        Boolean result = NGMCP_PostCodeValidator.validatePostCode('   ');
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false for whitespace-only postcode');
    }
    
    /**
     * @description Tests the validatePostCode method with a postcode that has a 500 error
     *              This test verifies the method handles HTTP errors correctly
     */
    @isTest
    static void testValidatePostCodeWithHttpError() {
        // Create a mock HTTP response for a server error
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(500);
        mockResponse.setBody('{"error": "Internal Server Error"}');
        
        // Create a mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new PostCodeValidatorMock(mockResponse));
        
        // Test with a postcode when server returns error
        Test.startTest();
        Boolean result = NGMCP_PostCodeValidator.validatePostCode('SW1A 1AA');
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false when HTTP error occurs');
    }
    
    /**
     * @description Tests the validatePostCode method with a postcode that has no delivery office
     *              This test verifies the method handles responses without delivery office correctly
     */
    @isTest
    static void testValidatePostCodeWithNoDeliveryOffice() {
        // Create a mock HTTP response without delivery office
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"otherData": "someValue"}');
        
        // Create a mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new PostCodeValidatorMock(mockResponse));
        
        // Test with a postcode that has no delivery office
        Test.startTest();
        Boolean result = NGMCP_PostCodeValidator.validatePostCode('SW1A 1AA');
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should return false when no delivery office is found');
    }
    
    // Mock class for HTTP callouts
    private class PostCodeValidatorMock implements HttpCalloutMock {
        private HttpResponse httpResponse;
        
        public PostCodeValidatorMock(HttpResponse response) {
            this.httpResponse = response;
        }
        
        public HttpResponse respond(HttpRequest request) {
            return this.httpResponse;
        }
    }
}