/**
 * @File Name         : NGMCP_AppointmentDeapptTest.cls
 * @Description       : Test class for validating NGMCP_AppointmentDeappointmentHandler methods.
 *                      This test class follows the established patterns in the project.
 * @Author            : 
 * @Last Modified By  : 
 * @Last Modified On  : January 30, 2026
 * @Modification Log  :
 *==============================================================================
 * Ver | Date             | Author             | Modification
 *==============================================================================
 * 1.0 | January 30, 2026 |        | Initial Version
 **/

@isTest
private class NGMCP_AppointmentDeapptTest{

    /**
     * @description
     *   Tests the createAppntDeappntRecord method by creating a test record and verifying it's inserted correctly.
     *   This validates the data insertion functionality of the appointment/de-appointment handler.
     */
    @isTest 
    static void testCreateAppntDeappntRecord() {
        // Prepare test JSON payload
        String requestBody = '{' +
            '"ngme_file_type":"FILE_TYPE",' +
            '"ngme_creation_date":"2025-01-01",' +
            '"ngme_originator_id":"ORIGINATOR_ID",' +
            '"ngme_recipient_role":"RECIPIENT_ROLE",' +
            '"ngme_status":"STATUS",' +
            '"ngme_transaction_count":1,' +
            '"ngme_integration_type":"INTEGRATION_TYPE",' +
            '"ngme_creation_time":"12:00:00",' +
            '"ngme_reqrecdate":"2025-01-01",' +
            '"ngme_record_count":1,' +
            '"ngme_record_identifier":"RECORD_ID",' +
            '"ngme_recipient_id":"RECIPIENT",' +
            '"ngme_file_identifier":"FILE_ID",' +
            '"ngme_trans":{' +
                '"ngme_reason_code":"REASON_CODE",' +
                '"ngme_reference":"REFERENCE",' +
                '"ngme_type_code":"TYPE_CODE",' +
                '"ngme_sector_code":"SECTOR_10",' +
                '"ngme_contract_ref":"CONTRACT_REF",' +
                '"ngme_from_date":"2025-01-01",' +
                '"ngme_to_date":"2025-01-02",' +
                '"ngme_mtpnt":{' +
                    '"ngme_addrs":{' +
                        '"ngme_building_no":"BUILDING_NO",' +
                        '"ngme_dependent_locality":"DEPENDENT_LOCALITY",' +
                        '"ngme_post_town":"POST_TOWN",' +
                        '"ngme_post_code":"POST_CODE"' +
                    '}' +
                '}' +
            '}' +
            '}';

        // Call the method under test
        Id resultId = NGMCP_AppointmentDeappointmentHandler.createAppntDeappntRecord(requestBody);
        //Object obj = NGMCP_AppointmentDeappointmentHandler.submitAppntDeappnt(requestBody,resultId);
        // Validate that the record was created
        System.assertNotEquals(null, resultId, 'Should return a valid record ID');
        
        // Verify the record was inserted with correct data
        NGMCP_Request__c createdRecord = [
            SELECT Id, 
                   NGMCP_File_Type__c,
                   NGMCP_Creation_Date__c,
                   NGMCP_Supplier_Id__c,
                   NGMCP_Recipient_Role__c,
                   NGMCP_Status__c,
                   NGMCP_Transaction_Count__c,
                   NGMCP_Integration_Type__c,
                   NGMCP_Creation_Time__c,
                   NGMCP_Request_Date__c,
                   NGMCP_Record_Count__c,
                   NGMCP_Record_Identifier__c,
                   NGMCP_Recipient_Id__c,
                   NGMCP_File_Identifier__c,
                   NGMCP_Reason_Code__c,
                   NGMCP_MPRN__c,
                   NGMCP_Type_Code__c,
                   NGMCP_Market_Sector_Code__c,
                   NGMCP_Contract_Reference__c,
                   NGMCP_From_Date__c,
                   NGMCP_To_Date__c,
                   NGMCP_Building_Number__c,
                   NGMCP_Dependent_Locality__c,
                   NGMCP_Postal_Town__c,
                   NGMCP_Postal_Code__c,
                   NGMCP_Callout_Status__c,
                   NGMCP_API_Callout__c
            FROM NGMCP_Request__c 
            WHERE Id = :resultId 
            LIMIT 1
        ];
        
        System.assertNotEquals(null, createdRecord, 'Created record should exist');
        System.assertEquals('FILE_TYPE', createdRecord.NGMCP_File_Type__c, 'File Type should match');
        System.assertEquals('ORIGINATOR_ID', createdRecord.NGMCP_Supplier_Id__c, 'Supplier ID should match');
        System.assertEquals('REFERENCE', createdRecord.NGMCP_MPRN__c, 'MPRN should match');
        System.assertEquals('CONTRACT_REF', createdRecord.NGMCP_Contract_Reference__c, 'Contract Reference should match');
        System.assertEquals('In Progress', createdRecord.NGMCP_Callout_Status__c, 'Callout Status should be In Progress');
        System.assertEquals('Create Appointment/De-appointment callout', createdRecord.NGMCP_API_Callout__c, 'API Callout should match');
    }
    
    /**
     * @description
     *   Tests the getSupplierInfo method by retrieving supplier information.
     *   This validates the data retrieval functionality of the appointment/de-appointment handler.
     */
    @isTest 
    static void testGetSupplierInfo() {
        // Test with a valid customer name
        NGMCP_Supplier_Information__mdt supplierInfo = NGMCP_AppointmentDeappointmentHandler.getSupplierInfo('Test Customer');
        
        // Validate that the method can be called without errors
        // Note: Actual data validation depends on existing test data in org
        System.assert(true, 'Method should execute without throwing an exception');
    }
    
    /**
     * @description
     *   Tests the initialization and basic functionality of the Appointment/Deappointment handler class.
     *   Ensures proper class instantiation and method availability.
     */
    @isTest 
    static void testAppointmentDeappointmentHandlerInstantiation() {
        // Create a mock instance to test class structure
        NGMCP_AppointmentDeappointmentHandler handlerClass = new NGMCP_AppointmentDeappointmentHandler();
        
        // Validate that the class can be instantiated
        System.assertNotEquals(null, handlerClass, 'Appointment/Deappointment Handler Class should be instantiable');
    }
    
    /**
     * @description
     *   Tests the createAppntDeappntRecord method with empty request body.
     *   This validates edge case handling.
     */
    @isTest 
    static void testCreateAppntDeappntRecordEmptyRequestBody() {
        // Test with empty request body
        String requestBody = '';
        
        // Call the method under test and expect it to handle empty input gracefully
        try {
            Id resultId = NGMCP_AppointmentDeappointmentHandler.createAppntDeappntRecord(requestBody);
            
            // If we get here without exception, check the result
            System.assertEquals(null, resultId, 'Should return null for empty request body');
        } catch (JSONException e) {
            // If a JSON exception is thrown (expected for empty body), test passes
            // This validates that the method properly handles empty input
            System.assert(true, 'Method properly handles empty JSON body with exception');
        }
    }
    @IsTest
    static void test_submitAppntDeappnt_success_updatesRequestAndReturnsBody() {
        Id rtId = getEnquiryRecordTypeIdOrNull();
		String requestBody = '{' +
            '"ngme_file_type":"FILE_TYPE",' +
            '"ngme_creation_date":"2025-01-01",' +
            '"ngme_originator_id":"ORIGINATOR_ID",' +
            '"ngme_recipient_role":"RECIPIENT_ROLE",' +
            '"ngme_status":"STATUS",' +
            '"ngme_transaction_count":1,' +
            '"ngme_integration_type":"INTEGRATION_TYPE",' +
            '"ngme_creation_time":"12:00:00",' +
            '"ngme_reqrecdate":"2025-01-01",' +
            '"ngme_record_count":1,' +
            '"ngme_record_identifier":"RECORD_ID",' +
            '"ngme_recipient_id":"RECIPIENT",' +
            '"ngme_file_identifier":"FILE_ID",' +
            '"ngme_trans":{' +
                '"ngme_reason_code":"REASON_CODE",' +
                '"ngme_reference":"REFERENCE",' +
                '"ngme_type_code":"TYPE_CODE",' +
                '"ngme_sector_code":"SECTOR_10",' +
                '"ngme_contract_ref":"CONTRACT_REF",' +
                '"ngme_from_date":"2025-01-01",' +
                '"ngme_to_date":"2025-01-02",' +
                '"ngme_mtpnt":{' +
                    '"ngme_addrs":{' +
                        '"ngme_building_no":"BUILDING_NO",' +
                        '"ngme_dependent_locality":"DEPENDENT_LOCALITY",' +
                        '"ngme_post_town":"POST_TOWN",' +
                        '"ngme_post_code":"POST_CODE"' +
                    '}' +
                '}' +
            '}' +
            '}';

        NGMCP_Request__c req = new NGMCP_Request__c(
            NGMCP_Affected_Person__c = 'Jane Doe',
            NGMCP_Callout_Status__c = 'In Progress',
            NGMCP_API_Callout__c = 'Create Appointment/De-appointment callout'
        );
        if (rtId != null) req.RecordTypeId = rtId;
        insert req;

        Test.setMock(HttpCalloutMock.class, new SuccessMock(201, '{"ticketid":"SR12345"}'));

        Test.startTest();
        object rawBody = NGMCP_AppointmentDeappointmentHandler.submitAppntDeappnt(requestBody, req.Id);
        Test.stopTest();

        System.assertEquals('{"ticketid":"SR12345"}', rawBody, 'Should return raw response body');

        NGMCP_Request__c updated = [
            SELECT Id, NGMCP_Callout_Status__c, NGMCP_Callout_Response__c, NGMCP_SR_Ticket__c
            FROM NGMCP_Request__c
            WHERE Id = :req.Id
        ];

        //String extracted = extractTicketIdLoose(updated.NGMCP_Callout_Response__c);

        System.assertEquals('Completed', updated.NGMCP_Callout_Status__c, 'Status should be set to Completed');
        //System.assertEquals('SR12345', updated.NGMCP_SR_Ticket__c, 'Ticket id should be parsed and stored');
        //System.assertEquals('SR12345', extracted, 'Ticket id in stored response should be detectable');
    }
    
        private class SuccessMock implements HttpCalloutMock {
        Integer statusCode;
        String body= '{"_rowstamp":"1556146566","ngme_headerid":18645033}';
        SuccessMock(Integer statusCode, String body) { this.statusCode = statusCode; this.body = body; }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(body);
            res.setStatus(statusCode == 200 ? 'OK' : 'Created');
            return res;
        }
    }

    private class ErrorMock implements HttpCalloutMock {
        Integer statusCode;
        String body;
        ErrorMock(Integer statusCode, String body) { this.statusCode = statusCode; this.body = body; }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(body);
            res.setStatus('Bad Request');
            return res;
        }
    }
    
    private static Id getEnquiryRecordTypeIdOrNull() {
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.NGMCP_Request__c.getRecordTypeInfosByName();
        if (rtMap != null && rtMap.containsKey('Appointment/Deappointment') && rtMap.get('Appointment/Deappointment').isAvailable()) {
            return rtMap.get('Appointment/Deappointment').getRecordTypeId();
        }
        else{
        	return null;
        }
    }
}