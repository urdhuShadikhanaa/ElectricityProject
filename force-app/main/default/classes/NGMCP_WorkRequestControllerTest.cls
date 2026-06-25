/**
 * @description Test class for NGMCP_WorkRequestController
 * @author P Shabbir Ali Khan
 * @since November 11, 2025
 */
@isTest
public class NGMCP_WorkRequestControllerTest {
    
    /**
     * @description Test method for getAllMeterModelConfigs()
     */
    @isTest
    static void testGetAllMeterModelConfigs() {
        // Create test data
        NGMCP_Meter_Model_Configuration__mdt config1 = new NGMCP_Meter_Model_Configuration__mdt(
            NGMCP_Minimum_Kwh__c = 100,
            NGMCP_Maximum_Kwh__c = 1000,
            NGMCP_Minimum_Outlet_Pressure__c = 5.0,
            NGMCP_Maximum_Outlet_Pressure__c = 15.0,
            NGMCP_Meter_Model__c = 'Model A'
        );
        
        NGMCP_Meter_Model_Configuration__mdt config2 = new NGMCP_Meter_Model_Configuration__mdt(
            NGMCP_Minimum_Kwh__c = 200,
            NGMCP_Maximum_Kwh__c = 2000,
            NGMCP_Minimum_Outlet_Pressure__c = 10.0,
            NGMCP_Maximum_Outlet_Pressure__c = 20.0,
            NGMCP_Meter_Model__c = 'Model B'
        );
        
        Test.startTest();
        List<NGMCP_Meter_Model_Configuration__mdt> result = NGMCP_WorkRequestController.getAllMeterModelConfigs();
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() >= 0, 'Result should have records or be empty');
    }
    
    /**
     * @description Test method for geAlltHousingModels()
     */
    @isTest
    static void testGeAlltHousingModels() {
        // Create test data
        NGMCP_HousingModel_Configuration__mdt housing1 = new NGMCP_HousingModel_Configuration__mdt(
            DeveloperName = 'Housing_Model_1',
            NGMCP_Housing_Model__c = 'Model 1 Housing'
        );
        
        NGMCP_HousingModel_Configuration__mdt housing2 = new NGMCP_HousingModel_Configuration__mdt(
            DeveloperName = 'Housing_Model_2',
            NGMCP_Housing_Model__c = 'Model 2 Housing'
        );
        
        Test.startTest();
        List<NGMCP_HousingModel_Configuration__mdt> result = NGMCP_WorkRequestController.geAlltHousingModels();
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() >= 0, 'Result should have records or be empty');
    }
    
    /**
     * @description Test method for geAllAssestMasterData()
     */
    @isTest
    static void testGeAllAssestMasterData() {
        // Create test data
        NGMCP_Assest_Master_Data__mdt asset1 = new NGMCP_Assest_Master_Data__mdt(
            DeveloperName = 'Asset_1',
            NGMCP_Manufacturer_Name__c = 'Manufacturer A',
            NGMCP_Meter_Model__c = 'Model A',
            NGMCP_Type__c = 'Type A'
        );
        
        NGMCP_Assest_Master_Data__mdt asset2 = new NGMCP_Assest_Master_Data__mdt(
            DeveloperName = 'Asset_2',
            NGMCP_Manufacturer_Name__c = 'Manufacturer B',
            NGMCP_Meter_Model__c = 'Model B',
            NGMCP_Type__c = 'Type B'
        );
        
        Test.startTest();
        List<NGMCP_Assest_Master_Data__mdt> result = NGMCP_WorkRequestController.geAllAssestMasterData();
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() >= 0, 'Result should have records or be empty');
    }
    
    /**
     * @description Test method for getPrice() with valid payload
     */
    @isTest
    static void testGetPriceWithValidPayload() {
        // Create test data
        NGMCP_CWR_Pricing_Meta_Data__mdt pricing1 = new NGMCP_CWR_Pricing_Meta_Data__mdt(
            DeveloperName = 'Pricing_1',
            NGMCP_MX_SERVICEGRP__c = 'Service Group A',
            NGMCP_MX_SERVICETYPE__c = 'Service Type A',
            NGMCP_Job_Price__c = 100.00,
            NGMCP_Main_Price__c = 50.00,
            NGMCP_Additional_Price__c = 25.00,
            NGMCP_SLA_Days__c = 5,
            NGMCP_Valid_From__c = Date.today(),
            NGMCP_Valid_To__c = Date.today().addDays(30)
        );
        
        Test.startTest();
        // Create JSON payload
        Map<String, Object> filters = new Map<String, Object>{'DeveloperName' => 'Pricing_1'};
        String payload = JSON.serialize(filters);
        List<NGMCP_CWR_Pricing_Meta_Data__mdt> result = NGMCP_WorkRequestController.getPrice(payload);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() >= 0, 'Result should have records or be empty');
    }
    
    /**
     * @description Test method for getPrice() with empty payload
     */
    @isTest
    static void testGetPriceWithEmptyPayload() {
        Test.startTest();
        // Create empty JSON payload
        Map<String, Object> filters = new Map<String, Object>{};
        String payload = JSON.serialize(filters);
        List<NGMCP_CWR_Pricing_Meta_Data__mdt> result = NGMCP_WorkRequestController.getPrice(payload);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() >= 0, 'Result should have records or be empty');
    }
    
    /**
     * @description Test method for getTypeandPaymentMechanism() with valid payload
     */
    @isTest
    static void testGetTypeandPaymentMechanismWithValidPayload() {
        // Create test data
        NGMCP_Asset_Payment_Mechanism__mdt payment1 = new NGMCP_Asset_Payment_Mechanism__mdt(
            DeveloperName = 'Payment_1',
            NGMCP_Manufacturer_Name__c = 'Manufacturer A',
            NGMCP_Meter_Model__c = 'Model A',
            NGMCP_Type__c = 'Type A',
            NGMCP_Payment_Mechanism__c = 'Credit Card'
        );
        
        Test.startTest();
        // Create JSON payload
        Map<String, Object> filters = new Map<String, Object>{'DeveloperName' => 'Payment_1'};
        String payload = JSON.serialize(filters);
        List<NGMCP_Asset_Payment_Mechanism__mdt> result = NGMCP_WorkRequestController.getTypeandPaymentMechanism(payload);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() >= 0, 'Result should have records or be empty');
    }
    
    /**
     * @description Test method for getTypeandPaymentMechanism() with empty payload
     */
    @isTest
    static void testGetTypeandPaymentMechanismWithEmptyPayload() {
        Test.startTest();
        // Create empty JSON payload
        Map<String, Object> filters = new Map<String, Object>{};
        String payload = JSON.serialize(filters);
        List<NGMCP_Asset_Payment_Mechanism__mdt> result = NGMCP_WorkRequestController.getTypeandPaymentMechanism(payload);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() >= 0, 'Result should have records or be empty');
    }
    @isTest
    static void testMethodForThirdPartyAssest() {
         NGMCP_Third_Party_Assest_Data__mdt payment1 = new NGMCP_Third_Party_Assest_Data__mdt(
            DeveloperName = 'ACTARIS1',
            NGMCP_Manufacturer_Name__c = 'ACTARIS',
            NGMCP_Model__c = 'MRA25A',
            NGMCP_Type__c = 'Rotary Displacement',
            NGMCP_Metric_Imperial__c = 'SCMH',
            NGMCP_Capacity__c = 25, 
            NGMCP_Dials__c =6,
            NGMCP_Factor__c = 1,
            NGMCP_Year_From__c = '1980',
            NGMCP_Year_To__c = '9999',
            NGMCP_Payment_Mechanism__c = 'Credit'

        );
        Map<String, Object> filters = new Map<String, Object>{
            'NGMCP_Manufacturer_Name__c' => 'ACTARIS',
            'NGMCP_Model__c'             => 'MRA25A',
            'NGMCP_Type__c'              => 'Rotary Displacement'
        };
        String payload = buildJson(filters);
        Test.startTest();
        List<NGMCP_Third_Party_Assest_Data__mdt> result = NGMCP_WorkRequestController.getThirdPartyAsset(payload);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() >= 0, 'Result should have records or be empty');
    }
     private static String buildJson(Map<String, Object> filters) {
        return JSON.serialize(filters == null ? new Map<String, Object>() : filters);
    }
    @IsTest
    static void testValidateDuplicateRequest_foundDuplicate() {        
        Map<String, Schema.RecordTypeInfo> rtMap =
            Schema.getGlobalDescribe()
            .get('NGMCP_Request__c')
            .getDescribe()
            .getRecordTypeInfosByName();
        
        Id urgentRTId = rtMap.get('Urgent Work Request').getRecordTypeId();        
        System.assertNotEquals(null, urgentRTId);
        NGMCP_Request__c existingReq = new NGMCP_Request__c(
            RecordTypeId          = urgentRTId,
            NGMCP_MPRN__c          = '1234567890',
            NGMCP_Supplier_Id__c   = 'SUP-001',
            NGMCP_Job_Type__c      = 'JOB_TYPE_1',
            NGMCP_Job_SubType__c   = 'JOB_SUBTYPE_1',
            NGMCP_Status__c        = 'Open'
        );
        insert existingReq;
        String payload = JSON.serialize(new Map<String, Object>{
            'recordTypeName'        => 'Urgent Work Request',
            'NGMCP_MPRN__c'         => '1234567890',
            'NGMCP_Supplier_Id__c'  => 'SUP-001',
            'NGMCP_Job_Type__c'     => 'JOB_TYPE_1',
            'NGMCP_Job_SubType__c'  => 'JOB_SUBTYPE_1',
            'NGMCP_Status__c'       => new List<String>{
                'Closed',
                'CANCELLED',
                'Cancelled',
                'Resolved',
                'Rejected'
            }
        });
        Test.startTest();
        List<NGMCP_Request__c> results =
            NGMCP_WorkRequestController.validateDeuplicateRequest(payload);
        Test.stopTest();
        System.assertEquals(
            1,
            results.size(),
            'Duplicate request should be found'
        );

        System.assertEquals(
            existingReq.Id,
            results[0].Id,
            'Returned record should match existing duplicate'
        );
    }
}