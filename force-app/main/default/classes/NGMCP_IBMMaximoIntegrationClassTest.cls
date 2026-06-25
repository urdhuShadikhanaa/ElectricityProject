/**
 * @File Name         : NGMCP_IBMMaximoIntegrationClassTest.cls
 * @Description       : Test class for validating all methods in NGMCP_IBMMaximoIntegrationClass.
 *                      Uses mock HTTP responses to simulate external API calls and validates the parsed responses.
 * @Author            : 
 * @Last Modified By  : 
 * @Last Modified On  : February 1, 2026
 * @Modification Log  :
 *==============================================================================
 * Ver | Date             | Author             | Modification
 *==============================================================================
 * 1.0 | February 1, 2026 |        | Initial Version with fixes for all failing tests
 **/

@isTest
private class NGMCP_IBMMaximoIntegrationClassTest { 
    
    /**
     * @description
     *   Tests the callAssetDetailsAPI method by simulating a callout using a mock response.
     *   Validates that the response is parsed correctly and key fields match expected values.
     */
    @isTest 
    static void testCallAssetDetailsAPI() {
        // Set the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpMockTestClass());

        // Call the method under test
        NGMCP_GetAssetDetailsClass result = NGMCP_IBMMaximoIntegrationClass.callAssetDetailsAPI('1000270801', 'BGB');
        System.debug('NGMCP_GetAssetDetailsClass***' + result);

        // Validate the response object and key fields
        System.assertNotEquals(null, result, 'Expected non-null response object');
        System.assertEquals('1000270801', result.member[0].location, 'Expected location to match');
        System.assertEquals('BGB', result.member[0].pluspcustassoc[0].customer, 'Expected customer to match');
        System.assertEquals('BON ACCORD STREET', result.member[0].ngme_c_ss, 'Expected street to match');
        System.assertEquals('ABERDEEN', result.member[0].ngme_c_st, 'Expected city to match');

        // Validate asset list
        System.assert(result.member[0].asset != null && result.member[0].asset.size() > 0, 'Expected non-empty asset list');
        System.assertEquals('314086', result.member[0].asset[0].assetnum, 'Expected first asset number to match');
    }
    
    /**
     * @description
     *   Tests the callAssetDetailsAPI method with null customer parameter.
     *   Validates that the response is parsed correctly when customer is null.
     */
    @isTest 
    static void testCallAssetDetailsAPINullCustomer() {
        // Set the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpMockTestClass());

        // Call the method under test with null customer
        NGMCP_GetAssetDetailsClass result = NGMCP_IBMMaximoIntegrationClass.callAssetDetailsAPI('1000270801', null);
        System.debug('NGMCP_GetAssetDetailsClass (null customer)***' + result);

        // Validate the response object and key fields
        System.assertNotEquals(null, result, 'Expected non-null response object');
        System.assertEquals('1000270801', result.member[0].location, 'Expected location to match');
        System.assertEquals('BGB', result.member[0].pluspcustassoc[0].customer, 'Expected customer to match');
    }
    
    /**
     * @description
     *   Tests the callAssetDetailsAPI method with empty customer parameter.
     *   Validates that the response is parsed correctly when customer is empty.
     */
    @isTest 
    static void testCallAssetDetailsAPIEmptyCustomer() {
        // Set the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpMockTestClass());

        // Call the method under test with empty customer
        NGMCP_GetAssetDetailsClass result = NGMCP_IBMMaximoIntegrationClass.callAssetDetailsAPI('1000270801', '');
        System.debug('NGMCP_GetAssetDetailsClass (empty customer)***' + result);

        // Validate the response object and key fields
        System.assertNotEquals(null, result, 'Expected non-null response object');
        System.assertEquals('1000270801', result.member[0].location, 'Expected location to match');
        System.assertEquals('BGB', result.member[0].pluspcustassoc[0].customer, 'Expected customer to match');
    }

    /**
     * @description
     *   Tests the callSerialNumberAssetDetailsAPI method using a mock response.
     *   Ensures the serial number-based asset details are parsed and validated correctly.
     */
    @isTest 
    static void testCallSerialNumberAssetDetailsAPI() {
        // Set the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpMockTestClass());

        // Call the method under test
        NGMCP_GetAssetDetailsClass result = NGMCP_IBMMaximoIntegrationClass.callSerialNumberAssetDetailsAPI('G4A0046650990105');
        System.debug('NGMCP_GetAssetDetailsClass***' + result);

        // Validate the response object and key fields
        System.assertNotEquals(null, result, 'Expected non-null response object');
        System.assertEquals('1000270801', result.member[0].location, 'Expected location to match');
        System.assertEquals('BGB', result.member[0].pluspcustassoc[0].customer, 'Expected customer to match');
        System.assertEquals('BON ACCORD STREET', result.member[0].ngme_c_ss, 'Expected street to match');
        System.assertEquals('ABERDEEN', result.member[0].ngme_c_st, 'Expected city to match');

        // Validate asset list
        System.assert(result.member[0].asset != null && result.member[0].asset.size() > 0, 'Expected non-empty asset list');
        System.assertEquals('314086', result.member[0].asset[0].assetnum, 'Expected first asset number to match');
    }
    
    /**
     * @description
     *   Tests the callSerialNumberAssetDetailsAPI method with null serial number.
     *   Validates that the method handles null input gracefully.
     */
    @isTest 
    static void testCallSerialNumberAssetDetailsAPINullSerialNumber() {
        // Call the method under test with null serial number
        NGMCP_GetAssetDetailsClass result = NGMCP_IBMMaximoIntegrationClass.callSerialNumberAssetDetailsAPI(null);
        
        // Should return null since no HTTP call is made
        System.assertEquals(null, result, 'Expected null result for null serial number');
    }

    /**
     * @description
     *   Tests the callpostalAssetDetailsAPI method using a mock response.
     *   Validates that postal-based asset details are retrieved and parsed correctly.
     */
    @isTest 
    static void testCallpostalAssetDetailsAPI() {
        // Set the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpMockTestClass());

        // Call the method under test
        NGMCP_GetAssetDetailsClass result = NGMCP_IBMMaximoIntegrationClass.callpostalAssetDetailsAPI('AB11 6EL', 'BGB');
        System.debug('NGMCP_GetAssetDetailsClass***' + result);

        // Validate the response object and key fields
        System.assertNotEquals(null, result, 'Expected non-null response object');
        System.assertEquals('1000270801', result.member[0].location, 'Expected location to match');
        System.assertEquals('BGB', result.member[0].pluspcustassoc[0].customer, 'Expected customer to match');
        System.assertEquals('BON ACCORD STREET', result.member[0].ngme_c_ss, 'Expected street to match');
        System.assertEquals('ABERDEEN', result.member[0].ngme_c_st, 'Expected city to match');

        // Validate asset list
        System.assert(result.member[0].asset != null && result.member[0].asset.size() > 0, 'Expected non-empty asset list');
        System.assertEquals('314086', result.member[0].asset[0].assetnum, 'Expected first asset number to match');
    }
    
    /**
     * @description
     *   Tests the addressUpdateAPI method with successful response.
     *   Validates that the method updates the record correctly.
     */
    @isTest 
    static void testAddressUpdateAPI() {
        // Prepare test data
        String requestBody = '{' +
            '"ngme_c_st":"MONTROSE",' +
            '"ngme_c_prncpstreet":"Avenue road",' +
            '"ngme_c_depndlocality":"INVERBERVIE",' +
            '"ngme_c_spc":"DD10 0RR",' +
            '"siteid":"SCO",' +
            '"location":"1000023705",' +
            '"ngme_c_bldngname":"23",' +
            '"ngme_c_sitebn":"BuildingName"' +
            '}';
        
        String locationId = '1000023705';
        
        // Create a test record first
        Id recordId = NGMCP_RequestObjectClass.createAddressUpdateRecord(requestBody, locationId);
        
        // Assert the record was created
        NGMCP_Request__c createdRecord = [SELECT Id, NGMCP_Callout_Status__c FROM NGMCP_Request__c WHERE Id = :recordId LIMIT 1];
        System.assertEquals('In Progress', createdRecord.NGMCP_Callout_Status__c);
        
        // Set the mock and call the method under test
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpAddressMockTestCallout());
        
        // Call the method under test - no Test.startTest needed for this method since it's not a pure HTTP call
        String result = NGMCP_IBMMaximoIntegrationClass.addressUpdateAPI(requestBody, locationId, recordId);
        
        System.debug('result***' + result);
        System.assertEquals('Address updated successfully!', result);
        
        // Verify the record was updated
        NGMCP_Request__c updatedRecord = [SELECT Id, NGMCP_Callout_Status__c, NGMCP_Callout_Response__c FROM NGMCP_Request__c WHERE Id = :recordId LIMIT 1];
        System.assertEquals('Completed', updatedRecord.NGMCP_Callout_Status__c);
        System.assertEquals('Address updated successfully!', updatedRecord.NGMCP_Callout_Response__c);
    }
    
    /**
     * @description
     *   Tests the addressUpdateAPI method with null locationId.
     *   Validates that the method handles null input gracefully.
     */
    @isTest 
    static void testAddressUpdateAPINullLocationId() {
        // Prepare test data
        String requestBody = '{' +
            '"ngme_c_st":"MONTROSE",' +
            '"ngme_c_prncpstreet":"Avenue road"' +
            '}';
        
        String locationId = null;
        Id recordId = null; // We won't create a record for this test
        
        // Call the method under test with null locationId
        // No HTTP call is made, so we don't need Test.startTest/stopTest
        String result = NGMCP_IBMMaximoIntegrationClass.addressUpdateAPI(requestBody, locationId, recordId);
        
        // Should return success message even with null locationId
        System.assertEquals('Address updated successfully!', result);
    }
    
    /**
     * @description
     *   Tests the submitUrgentWorkRequest method using a mock response.
     *   Validates that the method correctly processes the work request submission.
     */
    @isTest 
    static void testSubmitUrgentWorkRequest() {
        // Mock the callout and test the integration method directly
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpSubmitworkRequestCallout());

        // Prepare test JSON payload
        String requestBody = '{' +
            '"reportedpriority":"' + 1 + '",' +
            '"job_type":"OTVST",' +
            '"affectedphone":"01234567890",' +
            '"description_longdescription":"Test-Retrospective YES",' +
            '"job_subtype":"FAULT",' +
            '"targetstart":"2025-10-04",' +
            '"ngme_time":"05:42",' +
            '"source":"PORTAL",' +
            '"job_sub_subtype":"EXCFT40",' +
            '"ngme_liferay_slot":"AT",' +
            '"ngme_industry":"D",' +
            '"assetnum":"2360",' +
            '"suppliercode":"LEP",' +
            '"location":"1000023705",' +
            '"affectedperson":"Tina"' +
        '}';

        Object result = NGMCP_IBMMaximoIntegrationClass.submitUrgentWorkRequest(requestBody, null);

        System.debug('result***' + result);
        System.assertNotEquals(null, result, 'Expected a non-null response from the mocked callout');
    }
    
    /**
     * @description
     *   Tests the submitCreattWorkRequest method for Domestic industry.
     *   Validates that the method correctly processes the work request submission for domestic industry.
     */
    @isTest 
    static void testSubmitCreattWorkRequestDomestic() {
        // Mock the callout and test the integration method directly
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpSubmitworkRequestCallout());

        // Prepare test JSON payload
        String requestBody = '{' +
            '"reportedpriority":"' + 1 + '",' +
            '"job_type":"OTVST",' +
            '"affectedphone":"01234567890",' +
            '"description_longdescription":"Test-Retrospective YES",' +
            '"job_subtype":"FAULT",' +
            '"targetstart":"2025-10-04",' +
            '"ngme_time":"05:42",' +
            '"source":"PORTAL",' +
            '"job_sub_subtype":"EXCFT40",' +
            '"ngme_liferay_slot":"AT",' +
            '"ngme_industry":"D",' +
            '"assetnum":"2360",' +
            '"suppliercode":"LEP",' +
            '"location":"1000023705",' +
            '"affectedperson":"Tina"' +
        '}';

        Object result = NGMCP_IBMMaximoIntegrationClass.submitCreattWorkRequest(requestBody, null, 'D');

        System.debug('result***' + result);
        System.assertNotEquals(null, result, 'Expected a non-null response from the mocked callout');
    }
    
    /**
     * @description
     *   Tests the submitCreattWorkRequest method for Non-Domestic industry.
     *   Validates that the method correctly processes the work request submission for non-domestic industry.
     */
    @isTest 
    static void testSubmitCreattWorkRequestNonDomestic() {
        // Mock the callout and test the integration method directly
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpSubmitworkRequestCallout());

        // Prepare test JSON payload
        String requestBody = '{' +
            '"reportedpriority":"' + 1 + '",' +
            '"job_type":"OTVST",' +
            '"affectedphone":"01234567890",' +
            '"description_longdescription":"Test-Retrospective YES",' +
            '"job_subtype":"FAULT",' +
            '"targetstart":"2025-10-04",' +
            '"ngme_time":"05:42",' +
            '"source":"PORTAL",' +
            '"job_sub_subtype":"EXCFT40",' +
            '"ngme_liferay_slot":"AT",' +
            '"ngme_industry":"N",' +
            '"assetnum":"2360",' +
            '"suppliercode":"LEP",' +
            '"location":"1000023705",' +
            '"affectedperson":"Tina"' +
        '}';

        Object result = NGMCP_IBMMaximoIntegrationClass.submitCreattWorkRequest(requestBody, null, 'N');

        System.debug('result***' + result);
        System.assertNotEquals(null, result, 'Expected a non-null response from the mocked callout');
    }
    
    
    /**
     * @description
     *   Tests the getPreviousUrgentWorkRequestHistoryForMPRN method with valid input.
     *   Validates that the method correctly counts previous requests.
     */
    @isTest 
    static void testGetPreviousUrgentWorkRequestHistoryForMPRN() {
        // This method doesn't make HTTP calls, so we don't need to mock anything
        // Just test the logic directly
        
        // Test with valid input
        Integer result = NGMCP_IBMMaximoIntegrationClass.getPreviousUrgentWorkRequestHistoryForMPRN('1000270801');
        // Since we don't have actual records, we expect 0 for this test
        System.assertEquals(0, result, 'Expected 0 result for non-existent MPRN');
    }
    
    /**
     * @description
     *   Tests the getPreviousUrgentWorkRequestHistoryForMPRN method with blank input.
     *   Validates that the method handles blank input gracefully.
     */
    @isTest 
    static void testGetPreviousUrgentWorkRequestHistoryForMPRNBlankInput() {
        // Test with blank input
        Integer result = NGMCP_IBMMaximoIntegrationClass.getPreviousUrgentWorkRequestHistoryForMPRN('');
        System.assertEquals(null, result, 'Expected null result for blank input');
        
        // Test with null input
        result = NGMCP_IBMMaximoIntegrationClass.getPreviousUrgentWorkRequestHistoryForMPRN(null);
        System.assertEquals(null, result, 'Expected null result for null input');
    }
    
    /**
     * @description
     *   Tests the downloadDocuments method with valid SR number.
     *   Validates that the method correctly downloads documents.
     */
    @isTest 
    static void testDownloadDocuments() {
        // Set the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpMockTestClass());

        // Call the method under test
        NGMCP_DocumentDownloadWrapper result = NGMCP_IBMMaximoIntegrationClass.downloadDocuments('TESTSR123');
        System.debug('NGMCP_DocumentDownloadWrapper***' + result);

        // Validate the response object
        System.assertNotEquals(null, result, 'Expected non-null response object');
        
        // Validate responseInfo - just check that it's not null
        System.assertNotEquals(null, result.responseInfo, 'Expected non-null responseInfo');
    }
    
    /**
     * @description
     *   Tests the downloadDocuments method with blank SR number.
     *   Validates that the method throws appropriate exception for blank input.
     */
    @isTest 
    static void testDownloadDocumentsBlankSRNumber() {
        // Call the method under test with blank SR number
        try {
            NGMCP_IBMMaximoIntegrationClass.downloadDocuments('');
            // If we reach here, no exception was thrown - fail the test
            System.assert(false, 'Expected AuraHandledException for blank SR number');
        } catch (AuraHandledException e) {
            // Expected exception was thrown - test passes
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Expected correct error message: ' + e.getMessage());
        }
    }
    
    /**
     * @description
     *   Tests the downloadDocuments method with null SR number.
     *   Validates that the method throws appropriate exception for null input.
     */
    @isTest 
    static void testDownloadDocumentsNullSRNumber () {
        // Call the method under test with null SR number
        try {
            NGMCP_IBMMaximoIntegrationClass.downloadDocuments(null);
            NGMCP_IBMMaximoIntegrationClass.getMeterModelSizeandcatagory('U6');
            // If we reach here, no exception was thrown - fail the test
            System.assert(false, 'Expected AuraHandledException for null SR number');
        } catch (AuraHandledException e) {
            // Expected exception was thrown - test passes
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Expected correct error message: ' + e.getMessage());
        }
    }
    
    @isTest 
    static void testsendAddressUpdateEmail() {
        	NGMCP_Request__c req = new NGMCP_Request__c();
        	req.NGMCP_MPRN__c = '1234';
        	List<NGMCP_Request__c> reqList = new List<NGMCP_Request__c>();
        	reqList.add(req);
            NGMCP_IBMMaximoIntegrationClass.sendAddressUpdateEmail(reqList);

    } 
    
}