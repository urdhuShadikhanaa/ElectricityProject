@IsTest
private class NGMCP_WorkRequestController_Test {
    // Utility: serialize a Map<String, Object> to JSON
    private static String toJson(Map<String, Object> m) {
        return JSON.serialize(m);
    }

    @IsTest
    static void test_getAllMeterModelConfigs() {
        Test.startTest();
        List<NGMCP_Meter_Model_Configuration__mdt> res =
            NGMCP_WorkRequestController.getAllMeterModelConfigs();
        Test.stopTest();

        System.assertNotEquals(null, res, 'Should return a (possibly empty) list');
    }

    @IsTest
    static void test_geAlltHousingModels() {
        Test.startTest();
        List<NGMCP_HousingModel_Configuration__mdt> res =
            NGMCP_WorkRequestController.geAlltHousingModels();
        Test.stopTest();

        System.assertNotEquals(null, res, 'Should return a (possibly empty) list');
    }

    @IsTest
    static void test_geAllAssestMasterData() {
        Test.startTest();
        List<NGMCP_Assest_Master_Data__mdt> res =
            NGMCP_WorkRequestController.geAllAssestMasterData();
        Test.stopTest();

        System.assertNotEquals(null, res, 'Should return a (possibly empty) list');
    }

    @IsTest
    static void test_getPrice_string_and_numeric_filters() {
        // Build payload with both string and numeric filters.
        // Use fields that exist in the SELECT list of the CMDT:
        // - NGMCP_MX_SERVICEGRP__c (String)
        // - NGMCP_SLA_Days__c (likely Number)
        Map<String, Object> filters = new Map<String, Object>{
            'NGMCP_MX_SERVICEGRP__c' => 'GrpA',
            'NGMCP_SLA_Days__c'      => 5
        };

        Test.startTest();
        List<NGMCP_CWR_Pricing_Meta_Data__mdt> res =
            NGMCP_WorkRequestController.getPrice(toJson(filters));
        Test.stopTest();

        System.assertNotEquals(null, res, 'Should return a (possibly empty) list');
    }

    @IsTest
    static void test_getPrice_empty_filters_object() {
        // Empty JSON -> no WHERE clause path
        String payload = '{}';

        Test.startTest();
        List<NGMCP_CWR_Pricing_Meta_Data__mdt> res =
            NGMCP_WorkRequestController.getPrice(payload);
        Test.stopTest();

        System.assertNotEquals(null, res, 'Should return a (possibly empty) list without WHERE');
    }

    @IsTest
static void test_getTypeandPaymentMechanism_blank_payloads() {
    // Arrange
    // Nothing to set up

    // Act
    Test.startTest();
    // 1) Null payload
    List<NGMCP_Asset_Payment_Mechanism__mdt> resNull =
        NGMCP_WorkRequestController.getTypeandPaymentMechanism(null);

    // 2) Blank string payload
    List<NGMCP_Asset_Payment_Mechanism__mdt> resBlank =
        NGMCP_WorkRequestController.getTypeandPaymentMechanism('');

    // 3) Empty JSON object payload
    List<NGMCP_Asset_Payment_Mechanism__mdt> resEmptyObj =
        NGMCP_WorkRequestController.getTypeandPaymentMechanism('{}');
    Test.stopTest();

    // Assert
    System.assertEquals(0, resNull.size(),  'Null payload should return empty list');
    System.assertEquals(0, resBlank.size(), 'Blank payload should return empty list');
    System.assertEquals(0, resEmptyObj.size(), 'Empty JSON object should return empty list');
}
    @IsTest
    static void test_getTypeandPaymentMechanism_with_string_filters() {
        // Use string-based keys present in the SELECT list for this CMDT
        Map<String, Object> filters = new Map<String, Object>{
            'NGMCP_Manufacturer_Name__c' => 'AnyManufacturer',
            'NGMCP_Meter_Model__c'       => 'AnyModel',
            'NGMCP_Type__c'              => 'AnyType'
        };

        Test.startTest();
        List<NGMCP_Asset_Payment_Mechanism__mdt> res =
            NGMCP_WorkRequestController.getTypeandPaymentMechanism(toJson(filters));
        Test.stopTest();

        System.assertNotEquals(null, res, 'Should return a (possibly empty) list');
    }

    @IsTest
    static void test_validateDuplicateRequest_with_status_not_in_and_fields() {
        // Build payload exercising:
        // - status NOT IN (list)
        // - additional equality conditions
        Map<String, Object> filters = new Map<String, Object>{
            'NGMCP_Status__c'     => new List<String>{ 'Closed', 'Cancelled' },
            'NGMCP_MPRN__c'       => '123456789',
            'NGMCP_Job_Type__c'   => 'Install',
            'NGMCP_Job_SubType__c'=> 'Meter'
            
        };

        Test.startTest();
        List<NGMCP_Request__c> res =
            NGMCP_WorkRequestController.validateDeuplicateRequest(toJson(filters));
        Test.stopTest();

        System.assertNotEquals(null, res, 'Should return a (possibly empty) list');
    }

    @IsTest
    static void test_validateDuplicateRequest_only_fields_no_status() {
        // Exercise path without status list
        Map<String, Object> filters = new Map<String, Object>{
            'NGMCP_MPRN__c'        => '987654321',
            'NGMCP_Job_Type__c'    => 'Exchange',
            'NGMCP_Job_SubType__c' => 'Meter'
        };

        Test.startTest();
        List<NGMCP_Request__c> res =
            NGMCP_WorkRequestController.validateDeuplicateRequest(toJson(filters));
        Test.stopTest();

        System.assertNotEquals(null, res, 'Should return a (possibly empty) list');
    }
     @isTest
    static void testMethodForThirdPartyAssest() {
        Map<String, Object> filters = new Map<String, Object>{
            'NGMCP_Manufacturer_Name__c' => 'ACTARIS',
            'NGMCP_Model__c'             => 'MRA25A',
            'NGMCP_Type__c'              => 'Rotary Displacement'
        };
        Test.startTest();
        List<NGMCP_Third_Party_Assest_Data__mdt> result = NGMCP_WorkRequestController.getThirdPartyAsset(toJson(filters));
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() >= 0, 'Result should have records or be empty');
    }
     private static String buildJson(Map<String, Object> filters) {
        return JSON.serialize(filters == null ? new Map<String, Object>() : filters);
    }
}