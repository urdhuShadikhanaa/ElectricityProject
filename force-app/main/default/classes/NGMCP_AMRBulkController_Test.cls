@IsTest
public class NGMCP_AMRBulkController_Test {

    private static String getValidAmrPayload() {
        Map<String, Object> row = new Map<String, Object>{
            'Customer' => 'Cust1',
            'Trans Ref' => 'TR-001',
            'Contract Ref' => 'CR-001',
            'Job Type' => 'STRT',
            'MPRN' => '123456789',
            'Service Level' => 'Gold',
            'Site Contact' => 'John',
            'Contact Mechanism Value' => '987654321',
            'Access Instructions' => 'Gate open',
            'MAM ID' => 'MAM1',
            'Building Number' => '12',
            'Building Name' => 'Test Building',
            'Street' => 'Main Street',
            'Dependent Locality' => 'Local',
            'Post Town' => 'Town',
            'Post Code' => 'AB12CD',
            'Meter Manufacturer' => 'ABC',
            'Meter Model' => 'Model1',
            'Meter YOM' => '2020',
            'Meter Serial Number' => 'SN001',
            'Meter Dials' => '6',
            'Meter Unit Of Measure' => 'm3',
            'Converter Fitted Indicator' => 'Y'
        };

        return JSON.serialize(new List<Object>{ row });
    }

    @IsTest
    static void testStartBulkProcess_AMR_Success() {
        String payload = getValidAmrPayload();
		
NGMCP_Bulk_Request__c br = new NGMCP_Bulk_Request__c(
    NGMCP_Customer__c = 'Cust1',
    NGMCP_Trans_Ref__c = 'TR-001',
    NGMCP_Contract_Ref__c = 'CR-001',
    NGMCP_Job_Type__c = 'STRT',
    NGMCP_MPRN__c = '123456789',
    NGMCP_Service_Level__c = 'Gold',
    NGMCP_Site_Contact__c = 'John',
    NGMCP_Contact_Mechanism_Value__c = '987654321',
    NGMCP_Post_Code__c = 'AB12CD',
    NGMCP_Callout_Type__c = 'AMR',
    NGMCP_Status__c = 'New'
);
insert br;

        Test.startTest();
        Id jobId = NGMCP_AMRBulkController.startBulkProcess(
            payload,
            'AMR',
            'STRT',
            UserInfo.getUserId()
        );
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Batch Job Id should be returned');

        List<NGMCP_Bulk_Request__c> reqs =
            [SELECT Id, NGMCP_Status__c, NGMCP_Callout_Type__c
             FROM NGMCP_Bulk_Request__c];

    }

    @IsTest
    static void testStartBulkProcess_MissingField() {

        Map<String, Object> badRow = new Map<String, Object>{
            'Customer' => 'Cust1' 
        };

        String payload = JSON.serialize(new List<Object>{ badRow });

        Test.startTest();
        NGMCP_AMRBulkController.startBulkProcess(
            payload,
            'AMR',
            'STRT',
            UserInfo.getUserId()
        );
        Test.stopTest();

        NGMCP_Bulk_Request__c req =
            [SELECT NGMCP_Response__c FROM NGMCP_Bulk_Request__c LIMIT 1];

    }

    @IsTest
    static void testStartBulkProcess_BlankPayload() {
        try {
            NGMCP_AMRBulkController.startBulkProcess(
                '',
                'AMR',
                'STRT',
                UserInfo.getUserId()
            );

        } catch (AuraHandledException e) {
            System.assertNotEquals('Test failed', e.getMessage());
        }
    }

    @IsTest
    static void testToYYYYMMDD() {
        System.assertEquals(
            '20260330',
            NGMCP_AMRBulkController.toYYYYMMDD('30/03/2026')
        );

        System.assertEquals(
            '20260330',
            NGMCP_AMRBulkController.toYYYYMMDD('2026-03-30')
        );

        System.assertEquals(
            null,
            NGMCP_AMRBulkController.toYYYYMMDD('invalid')
        );
    }

    @IsTest
    static void testBuildCsv() {

        NGMCP_Bulk_Request__c br = new NGMCP_Bulk_Request__c(
            NGMCP_Input_CSV_Row_Number__c = 2,
            NGMCP_Response__c = 'Error Message'
        );
        insert br;

        String csv = NGMCP_AMRBulkController.buildCsv(
            new List<Id>{ br.Id }
        );

    }

    @IsTest
    static void testUploadFile() {

        Id rtId = Schema.SObjectType.NGMCP_Request__c
            .getRecordTypeInfosByName()
            .get('Customer Work Request')
            .getRecordTypeId();

        String base64Data =
            EncodingUtil.base64Encode(Blob.valueOf('Test File'));

        Test.startTest();
        Id reqId = NGMCP_AMRBulkController.uploadFile(
            'test.txt',
            base64Data,
            'SUP001',
            'AMR'
        );
        Test.stopTest();

        ContentDocumentLink cdl =
            [SELECT Id FROM ContentDocumentLink
             WHERE LinkedEntityId = :reqId LIMIT 1];

    }
}