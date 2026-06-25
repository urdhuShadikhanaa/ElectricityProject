@IsTest
private class NGMCP_AMRClass_Test {

    // Build a representative JSON payload with one item in objList
    private static String buildJsonWithOneItem() {
        return '{'
        + '"status":"OK",'
        + '"message":"Success",'
        + '"objList":[{'
            + '"amrWorkRequestId":12345,'
            + '"ngmReference":"NGM-1",'
            + '"mprn":1234567890,'
            + '"amrJobTypeCode":"INSTALL",'
            + '"meterReading":"100",'
            + '"readingFactor":2,'
            + '"pulseSignificance":1.5,'
            + '"converterReading":"200",'
            + '"unCorrectedReading":"90",'
            + '"amrMeterReading":"110",'
            + '"amrConverterReading":"210",'
            + '"readFlagCode":"R",'
            + '"resynchReasonCode":"N/A",'
            + '"departMeterReading":"120",'
            + '"departConverterReading":"220",'
            + '"departUnCorrectedRead":"95",'
            + '"departAMRMeterRead":"125",'
            + '"departAMRConvertedRead":"225",'
            + '"jobOutComeStatusCode":"COMPLETED",'
            + '"jobOutComeDate":"2026-02-14T12:00:00.000Z",'
            + '"meterInspection":"Y",'
            + '"batteryChange":"N",'
            + '"masterAssetDataChange":"N",'
            + '"transactionStatusCode":"TS",'
            + '"comments":"All good",'
            + '"parentWorkRequestID":98765,'
            + '"approvedBy":"Ops",'
            + '"jobPlannedDate":"2026-02-10T09:00:00.000Z",'
            + '"lastModifiedDate":"2026-02-14T13:00:00.000Z",'
            + '"lastModifiedUser":"user1",'
            + '"requestGeneratedDate":"2026-02-09T08:00:00.000Z",'
            + '"primaryErrorCode":"E1",'
            + '"secondaryErrorCode":"E2",'
            + '"wrStatusCode":"WIP",'
            + '"fileName":"file.csv",'
            + '"svstResponseSent":true,'
            + '"readFrequency":"DAILY",'
            + '"requestNGMReference":"REQ-1",'
            + '"wipStatusCode":"W1",'
            + '"assignedTo":"tech1",'
            + '"wipActionComment":"Done",'
            + '"wipStatusDate":"2026-02-14T14:00:00.000Z",'
            + '"wipType":"TYPE-A",'
            + '"meterSerialNumber":"MSN-123",'
            + '"converterSerialNumber":"CSN-123",'
            + '"meterManufacturer":"ACME",'
            + '"meterModel":"M100",'
            + '"meterDials":6,'
            + '"converterDials":6,'
            + '"amrSerialNumber":"AMR-999",'
            + '"imperialMetricIndicator":"M",'
            + '"yearofManufacture":"2024",'
            + '"wipActionSPReference":"SP-REF",'
            + '"supplierTransactionStatus":"STS",'
            + '"supplierComments":"OK",'
            + '"driftPercentage":5,'
            + '"billSiteVisit":false,'
            + '"responseReceivedDate":"2026-02-14T15:00:00.000Z",'
            + '"amrModelCode":"AMC1",'
            + '"amrYearofManufacturer":"2024",'
            + '"ocrSerialNumber":"OCR-1",'
            + '"gps":"28.6,77.3",'
            + '"conDriftPercentage":3,'
            + '"responseFileName":"resp.csv",'
            + '"plannedStatus":"Planned",'
            + '"raisedBy":"CSR",'
            + '"expectedDataFromCustomer":"None",'
            + '"serviceProvider":"SP1",'
            + '"microbusiness":true,'
            + '"jobPlannedSlot":"PM",'
            + '"jobOutcomeTime":"12:30"'
        + '}]'
        + '}';
    }

    @IsTest
    static void testParse_WithOneItem() {
        String jsonStr = buildJsonWithOneItem();

        Test.startTest();
        NGMCP_AMRClass wrapper = NGMCP_AMRClass.parse(jsonStr);
        Test.stopTest();

        System.assertNotEquals(null, wrapper, 'Wrapper should not be null after successful parse.');
        System.assertEquals('OK', wrapper.status);
        System.assertEquals('Success', wrapper.message);
        System.assertNotEquals(null, wrapper.objList, 'objList should be initialized.');
        System.assertEquals(1, wrapper.objList.size());

        NGMCP_AMRClass.ObjListClass rec = wrapper.objList[0];
        System.assertEquals('MSN-123', rec.meterSerialNumber);
        System.assertEquals(2L, rec.readingFactor);                 // Long field
        System.assertEquals(1.5, rec.pulseSignificance);            // Double field
        System.assertEquals(true, rec.svstResponseSent);            // Boolean field
        System.assertEquals(true, rec.microbusiness);               // Boolean field
        System.assertEquals(Datetime.valueOfGmt('2026-02-14 12:00:00'), rec.jobOutComeDate); // Datetime field
    }

    @IsTest
    static void testParse_EmptyObjList() {
        String jsonStr = '{"status":"OK","message":"Empty","objList":[]}';

        NGMCP_AMRClass wrapper = NGMCP_AMRClass.parse(jsonStr);

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.objList, 'objList should not be null when present as [].');
        System.assertEquals(0, wrapper.objList.size(), 'Empty array should yield size 0.');
    }

    @IsTest
    static void testParse_NoObjListProperty() {
        String jsonStr = '{"status":"OK","message":"No objList"}';

        NGMCP_AMRClass wrapper = NGMCP_AMRClass.parse(jsonStr);

        System.assertNotEquals(null, wrapper, 'Wrapper should still deserialize.');
        System.assertEquals(null, wrapper.objList, 'objList should be null when property is absent.');
    }

    @IsTest
    static void testParse_MalformedJson_ReturnsNull() {
        String jsonStr = '{'; // malformed JSON

        NGMCP_AMRClass wrapper = NGMCP_AMRClass.parse(jsonStr);

        System.assertEquals(null, wrapper,
            'Malformed JSON should return null per implementation of parse() inside catch.');
    }
}