@IsTest
private class NGMCPAppointmentDeappointmentTest {
   // Build minimal JSON payload for createAppntDeappntRecord with constrained lengths
    private static String buildCreateRequestBody() {
        String uniq = String.valueOf(System.now().getTime()).right(6);
        String todayStr = Date.today().format();
        String tomorrowStr = Date.today().addDays(1).format();
        String fromDate = Date.today().addDays(2).format();
        String toDate = Date.today().addDays(3).format();

        Map<String, Object> payload = new Map<String, Object>();
        payload.put('ngme_file_type', 'APPT');
        payload.put('ngme_creation_date', todayStr);
        payload.put('ngme_originator_id', ('OR' + uniq).left(10));
        payload.put('ngme_recipient_role', ('RL' + uniq).left(10));
        payload.put('ngme_status', 'NEW');
        payload.put('ngme_transaction_count', '1');
        payload.put('ngme_integration_type', ('IT' + uniq).left(10));
        payload.put('ngme_creation_time', '12:00:00');
        payload.put('ngme_reqrecdate', tomorrowStr);
        payload.put('ngme_record_count', '1');
        payload.put('ngme_record_identifier', ('REC' + uniq).left(10)); // <= 10
        payload.put('ngme_recipient_id', ('RC' + uniq).left(10));
        payload.put('ngme_file_identifier', ('FL' + uniq).left(10));

        Map<String, Object> trans = new Map<String, Object>();
        trans.put('ngme_reason_code', ('R' + uniq).left(10));
        trans.put('ngme_reference', '0123456789');
        trans.put('ngme_type_code', ('T' + uniq).left(10));
        trans.put('ngme_sector_code', 'S');
        trans.put('ngme_contract_ref', ('C' + uniq).left(10));
        trans.put('ngme_from_date', fromDate);
        trans.put('ngme_to_date', toDate);

        Map<String, Object> addrs = new Map<String, Object>();
        addrs.put('ngme_building_no', '1');
        addrs.put('ngme_dependent_locality', ('Loc' + uniq).left(20));
        addrs.put('ngme_post_town', ('Town' + uniq).left(20));
        addrs.put('ngme_post_code', 'AB1 2CD');

        Map<String, Object> mtpnt = new Map<String, Object>();
        mtpnt.put('ngme_addrs', addrs);

        trans.put('ngme_mtpnt', mtpnt);
        payload.put('ngme_trans', trans);

        return JSON.serialize(payload);
    }

    @IsTest
    static void test_createAppntDeappntRecord_insertsRequestWithFields() {
        String body = buildCreateRequestBody();
        Id newId = NGMCP_AppointmentDeappointmentHandler.createAppntDeappntRecord(body);

        NGMCP_Request__c rec = [
            SELECT Id, RecordTypeId, NGMCP_File_Type__c, NGMCP_Creation_Date__c, NGMCP_Supplier_Id__c,
                   NGMCP_Recipient_Role__c, NGMCP_Status__c, NGMCP_Transaction_Count__c, NGMCP_Integration_Type__c,
                   NGMCP_Creation_Time__c, NGMCP_Request_Date__c, NGMCP_Record_Count__c, NGMCP_Record_Identifier__c,
                   NGMCP_Recipient_Id__c, NGMCP_File_Identifier__c, NGMCP_Reason_Code__c, NGMCP_MPRN__c,
                   NGMCP_Type_Code__c, NGMCP_Market_Sector_Code__c, NGMCP_Contract_Reference__c, NGMCP_From_Date__c,
                   NGMCP_To_Date__c, NGMCP_Building_Number__c, NGMCP_Dependent_Locality__c, NGMCP_Postal_Town__c,
                   NGMCP_Postal_Code__c, NGMCP_Callout_Status__c, NGMCP_API_Callout__c
            FROM NGMCP_Request__c
            WHERE Id = :newId
        ];

        System.assertNotEquals(null, rec, 'Request should be inserted');
        System.assertEquals('APPT', rec.NGMCP_File_Type__c);
        System.assertEquals('In Progress', rec.NGMCP_Callout_Status__c);
        System.assertEquals('Create Appointment/De-appointment callout', rec.NGMCP_API_Callout__c);
        System.assertNotEquals(null, rec.NGMCP_Reason_Code__c);
        System.assertNotEquals(null, rec.NGMCP_MPRN__c);
        System.assertNotEquals(null, rec.NGMCP_Postal_Town__c);
        System.assertNotEquals(null, rec.NGMCP_Postal_Code__c);
        System.assert(rec.NGMCP_Record_Identifier__c != null && rec.NGMCP_Record_Identifier__c.length() <= 10);
    }

    @IsTest
    static void test_submitAppntDeappnt_success_200_updatesRequestAndReturnsBody() {
        String body = buildCreateRequestBody();
        Id reqId = NGMCP_AppointmentDeappointmentHandler.createAppntDeappntRecord(body);

        String hdrId = ('HDR' + String.valueOf(System.now().getTime()).right(8)).left(12);

        Test.setMock(HttpCalloutMock.class, new SuccessMock(200, '{"ngme_headerid":"'+ hdrId +'","result":"ok"}'));

        Test.startTest();
        Object result = NGMCP_AppointmentDeappointmentHandler.submitAppntDeappnt('{"any":"payload"}', reqId);
        Test.stopTest();

        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(result));
        System.assertEquals(hdrId, (String) parsed.get('ngme_headerid'), 'Header id should match');

        NGMCP_Request__c after = [
            SELECT NGMCP_Callout_Status__c, NGMCP_Callout_Response__c, NGMCP_Header_Id__c
            FROM NGMCP_Request__c WHERE Id = :reqId
        ];
        System.assertEquals('Completed', after.NGMCP_Callout_Status__c);
        System.assert(after.NGMCP_Callout_Response__c != null && after.NGMCP_Callout_Response__c.contains(hdrId));
        
    }

    @IsTest
    static void test_submitAppntDeappnt_success_201_updatesRequestAndReturnsBody() {
        String body = buildCreateRequestBody();
        Id reqId = NGMCP_AppointmentDeappointmentHandler.createAppntDeappntRecord(body);

        String hdrId = ('HDR' + String.valueOf(System.now().getTime()).right(8) + '201').left(15);

        Test.setMock(HttpCalloutMock.class, new SuccessMock(201, '{"ngme_headerid":"'+ hdrId +'","status":"created"}'));

        Test.startTest();
        Object result = NGMCP_AppointmentDeappointmentHandler.submitAppntDeappnt('{"any":"payload"}', reqId);
        Test.stopTest();

        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(result));
        System.assertEquals(hdrId, (String) parsed.get('ngme_headerid'));

        NGMCP_Request__c after = [
            SELECT NGMCP_Callout_Status__c, NGMCP_Callout_Response__c, NGMCP_Header_Id__c
            FROM NGMCP_Request__c WHERE Id = :reqId
        ];
        System.assertEquals('Completed', after.NGMCP_Callout_Status__c);
        System.assert(after.NGMCP_Callout_Response__c != null && after.NGMCP_Callout_Response__c.contains(hdrId));
       
    }

    @IsTest
    static void test_submitAppntDeappnt_non2xx_throwsAuraHandledException() {
        String body = buildCreateRequestBody();
        Id reqId = NGMCP_AppointmentDeappointmentHandler.createAppntDeappntRecord(body);

        Test.setMock(HttpCalloutMock.class, new ErrorMock(400, 'Bad Request'));

        Test.startTest();
        Boolean thrown = false;
        try {
            NGMCP_AppointmentDeappointmentHandler.submitAppntDeappnt('{"any":"payload"}', reqId);
        } catch (AuraHandledException ex) {
            thrown = true;
            // Just assert an AuraHandledException was thrown (message can vary)
        }
        Test.stopTest();

        System.assertEquals(true, thrown, 'AuraHandledException should be thrown for non-2xx');
    }

    @IsTest
    static void test_getSupplierInfo_whenNoMatch_returnsNull() {
        Test.startTest();
        NGMCP_Supplier_Information__mdt info = NGMCP_AppointmentDeappointmentHandler.getSupplierInfo('NO_' + String.valueOf(System.now().getTime()).right(6));
        Test.stopTest();
        System.assertEquals(null, info, 'Should return null when no matching mdt exists');
    }

    // Mocks

    private class SuccessMock implements HttpCalloutMock {
        Integer statusCode;
        String body;
        SuccessMock(Integer sc, String b) {
            this.statusCode = sc;
            this.body = b;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(body);
            return res;
        }
    }

    private class ErrorMock implements HttpCalloutMock {
        Integer statusCode;
        String body;
        ErrorMock(Integer sc, String b) {
            this.statusCode = sc;
            this.body = b;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(body);
            return res;
        }
    }
}