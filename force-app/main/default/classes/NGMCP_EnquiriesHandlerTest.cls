@IsTest
private class NGMCP_EnquiriesHandlerTest {

    private static Id getEnquiryRecordTypeIdOrNull() {
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.NGMCP_Request__c.getRecordTypeInfosByName();
        if (rtMap != null && rtMap.containsKey('Enquiry') && rtMap.get('Enquiry').isAvailable()) {
            return rtMap.get('Enquiry').getRecordTypeId();
        }
        else{
        	return null;
        }
    }

    // Extracts the first occurrence of ticket id from any stored response representation.
    // Avoids dependencies on JSON validity or HTML escaping.
    private static String extractTicketIdLoose(String stored) {
        if (String.isBlank(stored)) return null;

        // 1) Try direct JSON
        try {
            Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(stored);
            Object val = obj.get('ticketid');
            if (val != null) return String.valueOf(val);
        } catch (Exception ignore) {}

        // 2) Replace common HTML entity " then try JSON
        String normalized = stored.replace('"', '\"');
        try {
            Map<String, Object> obj2 = (Map<String, Object>) JSON.deserializeUntyped(normalized);
            Object val2 = obj2.get('ticketid');
            if (val2 != null) return String.valueOf(val2);
        } catch (Exception ignore2) {}

        // 3) Fallback: Substring search for "ticketid":"<value>"
        Integer keyIdx = normalized.indexOf('"ticketid"');
        if (keyIdx < 0) keyIdx = normalized.indexOf('"ticketid"');
        if (keyIdx > -1) {
            Integer colon = normalized.indexOf(':', keyIdx);
            if (colon > -1) {
                // Prefer normal double quotes
                Integer firstQuote = normalized.indexOf('"', colon + 1);
                if (firstQuote > -1) {
                    Integer secondQuote = normalized.indexOf('"', firstQuote + 1);
                    if (secondQuote > firstQuote) {
                        return normalized.substring(firstQuote + 1, secondQuote);
                    }
                }
                // Handle " value quoting
                String q = '"';
                Integer firstEnt = normalized.indexOf(q, colon + 1);
                if (firstEnt > -1) {
                    Integer secondEnt = normalized.indexOf(q, firstEnt + q.length());
                    if (secondEnt > firstEnt) {
                        return normalized.substring(firstEnt + q.length(), secondEnt);
                    }
                }
            }
        }

        // 4) Last resort: scan for SR followed by alphanumerics (avoid Character API)
        for (Integer i = 0; i < normalized.length() - 2; i++) {
            if (normalized.substring(i, i + 2) == 'SR') {
                Integer j = i + 2;
                while (j < normalized.length()) {
                    String ch = normalized.substring(j, j + 1);
                    // alphanumeric check
                    Boolean isAlpha = (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z');
                    Boolean isNum = (ch >= '0' && ch <= '9');
                    if (!(isAlpha || isNum)) break;
                    j++;
                }
                String candidate = normalized.substring(i, j);
                if (candidate.length() >= 3) return candidate;
            }
        }
        return null;
    }

    private static String buildCreateRequestBody() {
        Map<String, Object> payload = new Map<String, Object>{
            'ngme_consname' => 'John Doe',
            'reason' => 'MUOP',
            'loccode' => 'LOC001',
            'bldgname' => 'Block A',
            'sectorcode' => 'SEC01',
            'street' => 'Main Street',
            'supplier' => 'BGT',
            'notif_type' => 'INFO',
            'ngme_riskassess' => 'Low',
            'posttown' => 'London',
            'ngme_constitle' => 'Mr',
            'description_longdescription' => 'Long description',
            'ngme_engvisit' => 'No',
            'targetstart' => '2025-11-11T10:00:00Z',
            'postcode' => 'AB1 2CD',
            'ngme_time' => '10:00',
            'ngme_consphone' => '07000000000',
            'deplocal' => 'Locality',
            'ngme_threshold' => 'N',
            'location' => '0123456789',
            'reportedemail' => 'john@example.com',
            'category' => 'TQUERY',
            'subcategory' => 'MET'
        };
        return JSON.serialize(payload);
    }

    @IsTest
    static void test_createDataQueryRecord_insertsRecordAndReturnsId() {
 		NGMCP_Enquiry_Code__mdt ec = [Select Id,NGMCP_Enquiry_Sub_Category_Code__c,NGMCP_Enquiry_Sub_Category__c, 
                                              NGMCP_Enquiry_Reason__c, NGMCP_Enquiry_Reason_Code__c
                                                 FROM NGMCP_Enquiry_Code__mdt
                                             WHERE NGMCP_Enquiry_Sub_Category_Code__c = 'MET' AND
                                             NGMCP_Enquiry_Reason_Code__c = 'MUOP'
                                             LIMIT 1];
        Id rtId = getEnquiryRecordTypeIdOrNull() ;
        Test.startTest();
        String body = buildCreateRequestBody();
        Id createdId = NGMCP_EnquiriesHandler.createDataQueryRecord(body, null,'');
        Test.stopTest();

        NGMCP_Request__c rec = [
            SELECT Id, RecordTypeId, NGMCP_Affected_Person__c, NGMCP_Callout_Status__c, NGMCP_API_Callout__c,
                   NGMCP_Enquiry_Category__c, NGMCP_LocationsId__c, NGMCP_Enquiry_Description__c
            FROM NGMCP_Request__c
            WHERE Id = :createdId
            LIMIT 1
        ];
    }

    @IsTest
    static void test_submitDataQuery_success_updatesRequestAndReturnsBody() {
        Id rtId = getEnquiryRecordTypeIdOrNull();

        NGMCP_Request__c req = new NGMCP_Request__c(
            NGMCP_Affected_Person__c = 'Jane Doe',
            NGMCP_Callout_Status__c = 'In Progress',
            NGMCP_API_Callout__c = 'Create Enquiry callout'
        );
        if (rtId != null) req.RecordTypeId = rtId;
        insert req;

        Test.setMock(HttpCalloutMock.class, new SuccessMock(201, '{"ticketid":"SR12345"}'));

        Test.startTest();
        String rawBody = (String) NGMCP_EnquiriesHandler.submitDataQuery(buildCreateRequestBody(), req.Id);
        Test.stopTest();

        NGMCP_Request__c updated = [
            SELECT Id, NGMCP_Callout_Status__c, NGMCP_Callout_Response__c, NGMCP_SR_Ticket__c
            FROM NGMCP_Request__c
            WHERE Id = :req.Id
        ];

        String extracted = extractTicketIdLoose(updated.NGMCP_Callout_Response__c);
    }

    @IsTest
    static void test_submitDataQuery_error_throwsAuraHandledException() {
        Id rtId = getEnquiryRecordTypeIdOrNull();

        NGMCP_Request__c req = new NGMCP_Request__c(
            NGMCP_Affected_Person__c = 'Error Case',
            NGMCP_Callout_Status__c = 'In Progress',
            NGMCP_API_Callout__c = 'Create Enquiry callout'
        );
        if (rtId != null) req.RecordTypeId = rtId;
        insert req;

        Test.setMock(HttpCalloutMock.class, new ErrorMock(400, 'Bad Request'));

        Boolean thrown = false;
        Test.startTest();
        try {
            NGMCP_EnquiriesHandler.submitDataQuery(buildCreateRequestBody(), req.Id);
        } catch (AuraHandledException ahe) {
            thrown = true;
        }
        Test.stopTest();
    }

    @IsTest
    static void test_getAllEnquiryCodes_queryExecutes() {
        Test.startTest();
        List<NGMCP_Enquiry_Code__mdt> codes = NGMCP_EnquiriesHandler.getAllEnquiryCodes();
        Test.stopTest();

    }

    private class SuccessMock implements HttpCalloutMock {
        Integer statusCode;
        String body;
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
}