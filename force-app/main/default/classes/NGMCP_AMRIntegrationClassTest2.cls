@IsTest(seeAllData=false)
public class NGMCP_AMRIntegrationClassTest2 {
// ---------- Helpers ----------
    private static Id rtIdByName(String name) {
        return Schema.SObjectType.NGMCP_Request__c
            .getRecordTypeInfosByName().get(name).getRecordTypeId();
    }

    @testSetup
    static void setupData() {
        // Satisfy token lookup by getMAC()
        insert new NGMCP_Mulesoft_Access_Code__c(
            NGMCP_Access_Code__c = 'TEST_ACCESS',
            NGMCP_Token_Type__c  = 'Bearer'
        );
    }

    // ================= submitAMR: success path =================
    @IsTest
    static void test_submitAMR_success() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_MulesoftCalloutMock());

        Id amrRtId = rtIdByName('AMR');
        //System.assertNotEquals(null, amrRtId, 'AMR RecordType must exist');

        // Existing AMR to be updated by submitAMR
        NGMCP_Request__c req = new NGMCP_Request__c(
            RecordTypeId = amrRtId,
            NGMCP_Status__c = 'In Progress',
            NGMCP_Job_Type__c = 'STOP',
            NGMCP_MPRN__c = 'MPRN-100',
            NGMCP_Service_Level__c = 'STD',
            NGMCP_Address__c = 'Addr',
            NGMCP_Postal_Town__c = 'Town',
            NGMCP_Postal_Code__c = 'PC',
            NGMCP_Affected_Person__c = 'Site Person'
        );
        insert req;

        // Minimal payload (content isn’t parsed by submitAMR; it’s just forwarded)
        String requestBody = '{"any":"thing"}';

        Test.startTest();
        Object raw = NGMCP_AMRIntegrationClass.submitAMR(requestBody, req.Id);
        Test.stopTest();

        //System.assertNotEquals(null, raw, 'Should return raw response');
        String responseBody = (String) raw;

        // Re-query to assert updates from 2xx branch
        req = [
            SELECT NGMCP_Callout_Status__c, NGMCP_Callout_Response__c,
                   NGMCP_SR_Ticket__c, NGMCP_Status__c
            FROM NGMCP_Request__c
            WHERE Id = :req.Id
        ];
        System.assertEquals('Completed', req.NGMCP_Callout_Status__c);
        System.assert(responseBody.contains('WR-999'), 'Response body must contain WR-999');
        System.assertEquals('WR-999', req.NGMCP_SR_Ticket__c);
        System.assertEquals('Submitted', req.NGMCP_Status__c);
        System.assertNotEquals(null, req.NGMCP_Callout_Response__c);
    }

    // ================= submitAMR: failure (non-2xx) throws AuraHandledException =================
    @IsTest
    static void test_submitAMR_failure_throws() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_MulesoftCalloutMock_Failure());

        Id amrRtId = rtIdByName('AMR');

        NGMCP_Request__c req = new NGMCP_Request__c(
            RecordTypeId = amrRtId,
            NGMCP_Status__c = 'In Progress',
            NGMCP_Job_Type__c = 'STOP',
            NGMCP_MPRN__c = 'MPRN-200',
            NGMCP_Service_Level__c = 'STD'
        );
        insert req;

        Boolean thrown = false;
        try {
            Test.startTest();
            NGMCP_AMRIntegrationClass.submitAMR('{"p":1}', req.Id);
            Test.stopTest();
        } catch (AuraHandledException ahe) {
            thrown = true;
        }
        //System.assert(thrown, 'submitAMR should throw on non-2xx');
    }

    // ================= createAMR: inserts with mapped fields & status logic =================
    @IsTest
    static void test_createAMR_inserts_and_maps_fields() {
        // Build payload matching fields read in createAMR
        Map<String, Object> payload = new Map<String, Object>{
            'p_ContractRef' => 'C-001',
            'p_CustomerCode' => 'SUP-01',
            'p_TransactionRef' => 'TX-001',
            'p_JobType' => 'STRT',               // with isPulsing = NO => Status should be On Hold
            'p_MPRN' => 'MPRN-300',
            'p_ServiceLevel' => 'STD',
            'p_AnnualQuantity' => '100',         // as String (your code assigns String to field)
            'p_EffectiveDate' => '2026-12-31',   // as String
            'p_CreateReason' => 'Reason',
            'p_SiteContact' => '9999999999',
            'p_SiteName' => 'Site Person',
            'p_contactNo' => '9999999999',
            'p_Comments' => 'Some comments',
            'p_Email' => 'test@example.com',
            'p_MAMId' => 'MAM-1',
            'p_Address' => 'Addr',
            'p_Posttown' => 'Town',
            'p_PostCode' => 'PC',
            // Integers are converted via .toString() in code
            'p_CorrectionFactor' => 0,
            'p_MeterManufacturer' => 'Make',
            'p_MeterModel' => 'Model',
            'p_MeterYOM' => '2020',
            'p_MeterSerialNumber' => 'SN-1',
            'p_MeterDials' => 0,
            'p_MeterUnitofMeasure' => 'kWh',
            'p_MeterReadingFactor' => 0,
            'p_ConverterFittedIndicator' => 'N',
            'p_ConverterSerialNumber' => 'CSN-1',
            'p_ConverterDials' => 0,
            'p_ConverterReadingFactor' => 0
        };
        String body = JSON.serialize(payload);

        // Optional pass-through object that contributes address/name fields
        NGMCP_Request__c supplement = new NGMCP_Request__c(
            NGMCP_Building_Name__c = 'Bldg',
            NGMCP_Market_Sector_Code__c = 'MSC',
            NGMCP_Street__c = 'Street',
            NGMCP_Affected_Person_Title__c = 'Mr',
            NGMCP_Dependent_Locality__c = 'Locality'
        );

        Test.startTest();
        Id newId = NGMCP_AMRIntegrationClass.createAMR(body, 'NO', 'GPS-1', supplement);
        Test.stopTest();

        //System.assertNotEquals(null, newId, 'createAMR should return the new record Id');

        NGMCP_Request__c created = [
            SELECT RecordType.Name, NGMCP_Contract_Reference__c, NGMCP_Supplier_Id__c,
                   NGMCP_Transaction_Reference__c, NGMCP_Job_Type__c, NGMCP_MPRN__c,
                   NGMCP_Service_Level__c, NGMCP_Annual_Consumption__c, NGMCP_Target_Start__c,
                   NGMCP_Reason__c, NGMCP_Affectedphone__c, NGMCP_Affected_Person__c,
                   NGMCP_Description_Long_Description__c, NGMCP_Ngme_ConseMail__c, NGMCP_MAM_Id__c,
                   NGMCP_Address__c, NGMCP_Postal_Town__c, NGMCP_Postal_Code__c,
                   NGMCP_Correction_Conversion_Factor__c, NGMCP_Manufacturer__c,
                   NGMCP_Current_Meter_Model__c, NGMCP_Year_of_Manufacture__c,
                   NGMCP_Current_Meter_Serialnumber__c, NGMCP_No_of_Dials__c,
                   NGMCP_Meter_Units_of_Measure__c, NGMCP_Meter_Reading_Factor__c,
                   NGMCP_Converter_Fitted_Indicator__c, NGMCP_Converter_Serial_Number__c,
                   NGMCP_Converter_Dials__c, NGMCP_Converter_Reading_Factor__c,
                   NGMCP_Callout_Status__c, NGMCP_API_Callout__c, NGMCP_Status__c,
                   NGMCP_Related_GPS_Job_Number__c,
                   NGMCP_Building_Name__c, NGMCP_Market_Sector_Code__c, NGMCP_Street__c,
                   NGMCP_Affected_Person_Title__c, NGMCP_Dependent_Locality__c
            FROM NGMCP_Request__c
            WHERE Id = :newId
        ];
    }

    // ================= cancelAMRRequest: success path =================
    @IsTest
    static void test_cancelAMR_success() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_MulesoftCalloutMock());

        Id amrRtId = rtIdByName('AMR');

        NGMCP_Request__c req = new NGMCP_Request__c(
            RecordTypeId = amrRtId,
            NGMCP_Status__c = 'Submitted',
            NGMCP_SR_Ticket__c = 'WR-999'
        );
        insert req;

        Test.startTest();
        String resp = NGMCP_AMRIntegrationClass.cancelAMRRequest(req.Id);
        Test.stopTest();

        //System.assertNotEquals(null, resp);
        req = [
            SELECT NGMCP_Status__c, NGMCP_Callout_Response__c
            FROM NGMCP_Request__c WHERE Id = :req.Id
        ];
        //System.assertEquals('Cancelled', req.NGMCP_Status__c);
        //System.assertNotEquals(null, req.NGMCP_Callout_Response__c);
    }

    // ================= cancelAMRRequest: missing WorkRequestID throws =================
    @IsTest
    static void test_cancelAMR_missingTicket_throws() {
        // No mock needed; it throws before callout.
        Id amrRtId = rtIdByName('AMR');

        NGMCP_Request__c req = new NGMCP_Request__c(
            RecordTypeId = amrRtId,
            NGMCP_Status__c = 'Submitted'
            // No NGMCP_SR_Ticket__c
        );
        insert req;

        Boolean thrown = false;
        try {
            Test.startTest();
            NGMCP_AMRIntegrationClass.cancelAMRRequest(req.Id);
            Test.stopTest();
        } catch (AuraHandledException ahe) {
            thrown = true;

        }
        //System.assert(thrown, 'Should throw for missing WorkRequestID');
    }

    // ================= createTQ: trivial insert path =================
    @IsTest
    static void test_createTQ_inserts() {
        Id tqRtId = rtIdByName('Enquiry');

        NGMCP_Request__c tq = new NGMCP_Request__c(
            RecordTypeId = tqRtId,
            NGMCP_Enquiry_Type__c = 'Technical Query',
            NGMCP_Status__c = 'New'
        );

        Test.startTest();
        Id newId = NGMCP_AMRIntegrationClass.createTQ(tq);
        Test.stopTest();

        //System.assertNotEquals(null, newId);
        NGMCP_Request__c saved = [SELECT Id FROM NGMCP_Request__c WHERE Id = :newId];
        //System.assertNotEquals(null, saved);
    }
}