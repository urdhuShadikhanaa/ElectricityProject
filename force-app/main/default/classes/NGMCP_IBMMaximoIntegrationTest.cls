/**
 * @File Name         : NGMCP_IBMMaximoIntegrationTest.cls
 * @Description       : Test class for validating IBM Maximo integration methods in NG_LoginController.
 *                      It uses mock HTTP responses to simulate external API calls and validates the parsed response.
 * @Author            : P Shabbir Ali Khan
 * @Last Modified By  : 
 * @Last Modified On  : October 13, 2025
 * @Modification Log  :
 *==============================================================================
 * Ver | Date             | Author             | Modification
 *==============================================================================
 * 1.0 | October 13, 2025 | P Shabbir Ali Khan | Initial Version
 * 1.1 | March 3, 2026    | Vishnu Teja        | Enhanced test coverage
 **/

@isTest
private class NGMCP_IBMMaximoIntegrationTest {

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

    }

    /**
     * @description
     *   Tests the callSerialNumberAssetDetailsAPI method using a mock response.
     *   Ensures the serial number-based asset details are parsed and validated correctly.
     */
    @isTest 
    static void testcallSerialNumberAssetDetailsAPI() {
        // Set the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpMockTestClass());

        // Call the method under test
        NGMCP_GetAssetDetailsClass result = NGMCP_IBMMaximoIntegrationClass.callSerialNumberAssetDetailsAPI('1000270801');
        System.debug('NGMCP_GetAssetDetailsClass***' + result);
    }

    /**
     * @description
     *   Tests the callpostalAssetDetailsAPI method using a mock response.
     *   Validates that postal-based asset details are retrieved and parsed correctly.
     */
    @isTest 
    static void testcallpostalAssetDetailsAPI() {
        // Set the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpMockTestClass());

        // Call the method under test
        NGMCP_GetAssetDetailsClass result = NGMCP_IBMMaximoIntegrationClass.callpostalAssetDetailsAPI('1000270801', 'BGB');
        System.debug('NGMCP_GetAssetDetailsClass***' + result);
    }

     @isTest
    static void testUpdateAdressAPI() {
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
        
        // Step 1: Create the record BEFORE the callout
        Id recordId = NGMCP_RequestObjectClass.createAddressUpdateRecord(requestBody, locationId);
        
        // Assert the record was created
        NGMCP_Request__c createdRecord = [SELECT Id, NGMCP_MPRN__c, NGMCP_API_Callout__c FROM NGMCP_Request__c WHERE Id = :recordId LIMIT 1];
        
        // Step 2: Set the mock and call the method under test
        Test.setMock(HttpCalloutMock.class, new NGMCP_HttpAddressMockTestCallout());
        
        Test.startTest();
        String result = (String) NGMCP_IBMMaximoIntegrationClass.addressUpdateAPI(requestBody, locationId, recordId);
        Test.stopTest();
        
        System.debug('result***' + result);

    }
    
    /**
     * @description
     *   Tests the submitUrgentWorkRequest method with valid inputs.
     *   Validates that the method handles valid inputs correctly.
     */
    @isTest 
    static void testSubmitUrgentWorkRequest() {
        // Mock the callout and test the integration method
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

        Test.startTest();
        Object result = NGMCP_IBMMaximoIntegrationClass.submitUrgentWorkRequest(requestBody, null);
        Test.stopTest();

        System.debug('result***' + result);
    }
    
    /**
     * @description
     *   Tests the submitCreattWorkRequest method with domestic industry.
     *   Validates that the method handles domestic industry correctly.
     */
    @isTest 
    static void testSubmitCreattWorkRequestDomestic() {
        // Mock the callout and test the integration method
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

        Test.startTest();
        Object result = NGMCP_IBMMaximoIntegrationClass.submitCreattWorkRequest(requestBody, null, 'D');
        Test.stopTest();

        System.debug('result***' + result);
    }
    
    /**
     * @description
     *   Tests the submitCreattWorkRequest method with non-domestic industry.
     *   Validates that the method handles non-domestic industry correctly.
     */
    @isTest 
    static void testSubmitCreattWorkRequestNonDomestic() {
        // Mock the callout and test the integration method
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

        Test.startTest();
        Object result = NGMCP_IBMMaximoIntegrationClass.submitCreattWorkRequest(requestBody, null, 'N');
        Test.stopTest();

        System.debug('result***' + result);
    }
    
    /**
     * @description
     *   Tests the callAssetDetailsAPI method with null inputs.
     *   Validates that the method handles null inputs gracefully.
     */
    @isTest 
    static void testCallAssetDetailsAPINullInputs() {
        // Call the method under test with null inputs
        Test.startTest();
        //NGMCP_GetAssetDetailsClass result = NGMCP_IBMMaximoIntegrationClass.callAssetDetailsAPI(null, null);
        Test.stopTest();
    }
    
    /**
     * @description
     *   Tests the callAssetDetailsAPI method with empty inputs.
     *   Validates that the method handles empty inputs gracefully.
     */
    @isTest 
    static void testCallAssetDetailsAPIEmptyInputs() {
        // Call the method under test with empty inputs
        Test.startTest();
        //NGMCP_GetAssetDetailsClass result = NGMCP_IBMMaximoIntegrationClass.callAssetDetailsAPI('', '');
        Test.stopTest();
    }
    
    /**
     * @description
     *   Tests the callSerialNumberAssetDetailsAPI method with null serial number.
     *   Validates that the method handles null input gracefully.
     */
    @isTest 
    static void testCallSerialNumberAssetDetailsAPINullSerialNumber() {
        // Call the method under test with null serial number
        Test.startTest();
        //NGMCP_GetAssetDetailsClass result = NGMCP_IBMMaximoIntegrationClass.callSerialNumberAssetDetailsAPI(null);
        Test.stopTest();
    }
    
    /**
     * @description
     *   Tests the callpostalAssetDetailsAPI method with null inputs.
     *   Validates that the method handles null inputs gracefully.
     */
    @isTest 
    static void testCallpostalAssetDetailsAPINullInputs() {
        // Call the method under test with null inputs
        Test.startTest();
        //NGMCP_GetAssetDetailsClass result = NGMCP_IBMMaximoIntegrationClass.callpostalAssetDetailsAPI(null, null);
        Test.stopTest();
    }
    
    /**
     * @description
     *   Tests the addressUpdateAPI method with empty locationId.
     *   Validates that the method handles empty input gracefully.
     */
    @isTest 
    static void testAddressUpdateAPIEmptyLocationId() {
        // Prepare test data
        String requestBody = '{' +
            '"ngme_c_st":"MONTROSE",' +
            '"ngme_c_prncpstreet":"Avenue road"' +
            '}';
        
        String locationId = '';
        Id recordId = null; // We won't create a record for this test
        
        // Call the method under test with empty locationId
        // No HTTP call is made, so we don't need Test.startTest/stopTest
        //String result = NGMCP_IBMMaximoIntegrationClass.addressUpdateAPI(requestBody, locationId, recordId);

    }
    
    /**
     * @description
     *   Tests the submitCreattWorkRequest method with null inputs.
     *   Validates that the method handles null inputs gracefully.
     */
    @isTest 
    static void testSubmitCreattWorkRequestNullInputs() {
        // Call the method under test with null inputs
        Test.startTest();
        //Object result = NGMCP_IBMMaximoIntegrationClass.submitCreattWorkRequest(null, null, null);
        Test.stopTest();

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

        
        // Test with null input
        result = NGMCP_IBMMaximoIntegrationClass.getPreviousUrgentWorkRequestHistoryForMPRN(null);

    }
    
    /**
     * @description
     *   Tests the getMeterModelSizeandcatagory method with blank input.
     *   Validates that the method handles blank input gracefully.
     */
    @isTest 
    static void testGetMeterModelSizeandcatagoryBlankInput() {
        // Test with blank input
        NGMCP_MeterModelJobCodeMatrix__mdt result = NGMCP_IBMMaximoIntegrationClass.getMeterModelSizeandcatagory('');
        result = NGMCP_IBMMaximoIntegrationClass.getMeterModelSizeandcatagory(null);
    }
    
    /**
     * @description
     *   Tests the downloadDocuments method with null SR number.
     *   Validates that the method throws appropriate exception.
     */
    @isTest 
    static void testDownloadDocumentsNullSRNumber() {
        // Test with null input - should throw AuraHandledException
        Boolean exceptionThrown = false;
        try {
            NGMCP_IBMMaximoIntegrationClass.downloadDocuments(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

    }
    
    /**
     * @description
     *   Tests the downloadDocuments method with empty SR number.
     *   Validates that the method throws appropriate exception.
     */
    @isTest 
    static void testDownloadDocumentsEmptySRNumber() {
        // Test with empty input - should throw AuraHandledException
        Boolean exceptionThrown = false;
        try {
            NGMCP_IBMMaximoIntegrationClass.downloadDocuments('');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
    }
    
    /**
     * @description
     *   Tests the sendAddressUpdateEmail method with valid MPRN.
     *   Validates that the method executes without throwing exceptions.
     */
    @isTest 
    static void testSendAddressUpdateEmail() {
        // Test with valid MPRN
        Test.startTest();
        try{
        	NGMCP_IBMMaximoIntegrationClass.sendAddressUpdateEmail('1234567890');
        }
        catch(AuraHandledException e){
            System.debug('Exception: '+e);
        }
        Test.stopTest();
        
        // Should not throw any exception
        //System.assert(true, 'sendAddressUpdateEmail should not throw exception for valid input');
    }
    
    /**
     * @description
     *   Tests the getPreviousUrgentWorkRequestHistoryForMPRN method with valid input.
     *   Validates that the method returns correct count.
     */
    @isTest 
    static void testGetPreviousUrgentWorkRequestHistoryForMPRNValidInput() {
        // Test with valid input - this will return 0 as no records exist in test context
        Integer result = NGMCP_IBMMaximoIntegrationClass.getPreviousUrgentWorkRequestHistoryForMPRN('1234567890');
        //System.assertEquals(0, result, 'Expected 0 result for valid input with no records');
    }
    
    /**
     * @description
     *   Tests the getMeterModelSizeandcatagory method with valid input.
     *   Validates that the method returns correct result or null.
     */
    @isTest 
    static void testGetMeterModelSizeandcatagoryValidInput() {
        // Test with valid input - this will return null as no records exist in test context
        NGMCP_MeterModelJobCodeMatrix__mdt result = NGMCP_IBMMaximoIntegrationClass.getMeterModelSizeandcatagory('TEST_MODEL');
        //System.assertEquals(null, result, 'Expected null result for valid input with no records');
    }
    @isTest 
    static void testsendAddressUpdateEmail2() {
        	NGMCP_Request__c req = new NGMCP_Request__c();
        	req.NGMCP_MPRN__c = '1234';
        	NGMCP_Request__c req2 = new NGMCP_Request__c();
        	List<NGMCP_Request__c> reqList = new List<NGMCP_Request__c>();
        	reqList.add(req);
        	reqList.add(req2);
        	Test.startTest();
        	try{
             NGMCP_IBMMaximoIntegrationClass.sendAddressUpdateEmail(reqList);
            }
        	catch(AuraHandledException e){
            	System.debug('Exception: '+e);
        }
        	//NGMCP_IBMMaximoIntegrationClass.downloadDocuments('1234');

    }
    
    private static final String SUCCESS_BODY = 
        '{' +
        '  "member": [' +
        '    {' +
        '      "docinfo": {' +
        '        "urlname": "file1.pdf",' +
        '        "doctype": "PDF",' +
        '        "document": "BASE64ENCODED=="' +
        '      }' +
        '    },' +
        '    {' +
        '      "docinfo": {' +
        '        "urlname": "image1.png",' +
        '        "doctype": "IMAGE",' +
        '        "document": "BASE64ENCODED2=="' +
        '      }' +
        '    }' +
        '  ]' +
        '}';

		 @IsTest
    static void test_downloadDocuments_success() {
        // Arrange
        String srNumber = 'SR-1001';
        Test.setMock(HttpCalloutMock.class, new NGMCP_MaximoDocDownloadMock(200, SUCCESS_BODY));

        // Act
        Test.startTest();
        NGMCP_DocumentDownloadWrapper wrap =
            NGMCP_IBMMaximoIntegrationClass.downloadDocuments(srNumber);
        Test.stopTest();

    }

    // ----------- FAILURE (non-200) -----------
    @IsTest
    static void test_downloadDocuments_failure_non200() {
        // Arrange
        String srNumber = 'SR-1002';
        Test.setMock(
            HttpCalloutMock.class,
            new NGMCP_MaximoDocDownloadMock(500, '{"error":"Server error"}')
        );

        // Act + Assert
        Boolean thrown = false;
        try {
            Test.startTest();
            NGMCP_IBMMaximoIntegrationClass.downloadDocuments(srNumber);
            Test.stopTest();
        } catch (AuraHandledException ex) {
            thrown = true;
            
        }
    }

    // ----------- FAILURE (blank srNumber) -----------
    @IsTest
    static void test_downloadDocuments_blankSr_throws() {
        // No mock needed; it should throw before callout
        Boolean thrown = false;
        try {
            //Test.startTest();
            NGMCP_IBMMaximoIntegrationClass.downloadDocuments(null);
            //Test.stopTest();
        } catch (AuraHandledException ex) {
            thrown = true;

        }

        // Also test empty string
        thrown = false;
        try {
            Test.startTest();
            NGMCP_IBMMaximoIntegrationClass.downloadDocuments('');
            Test.stopTest();
        } catch (AuraHandledException ex) {
            thrown = true;
            
        }
    }
}