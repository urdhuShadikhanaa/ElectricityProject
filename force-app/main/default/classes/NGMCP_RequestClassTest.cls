@IsTest
private class NGMCP_RequestClassTest {

    @IsTest
    static void test_parse_valid_minimal() {
        // Minimal valid JSON with responseInfo + one member object and nested structures
        String json = '{' +
            '"responseInfo":{"href":"/maximo/api/os/mbo"},' +
            '"member":[{' +
                '"ngme_resub":true,' +
                '"commodity":"GAS",' +
                '"ngme_resubreason":"Reason",' +
                '"ngme_resolutionletter":"Yes",' +
                '"status_description":"In Progress",' +
                '"classstructureid":123.0,' +
                '"ticketuid":"UID-1",' +
                '"commoditygroup":"UTIL",' +
                '"class_description":"Desc",' +
                '"targetstart":"2025-01-01T10:00:00Z",' +
                '"changedate":"2025-01-01T11:00:00Z",' +
                '"relatedrecord":[{' +
                    '"relatedrecwonum":"WO-1",' +
                    '"relatedrecordid":"RR-1",' +
                    '"workorder":[{' +
                        '"targstartdate":"2025-01-02T09:00:00Z",' +
                        '"status_description":"WO In Progress",' +
                        '"actstart":"2025-01-02T09:15:00Z",' +
                        '"reportdate":"2025-01-01",' +
                        '"siteid":"NG",' +
                        '"changedate":"2025-01-02T08:50:00Z",' +
                        '"targcompdate":"2025-01-02T12:00:00Z",' +
                        '"woactivity":[{' +
                            '"apptrequired":false,' +
                            '"plusgqualitycritical":false,' +
                            '"parent":"WO-1",' +
                            '"historyflag":false' +
                        '}],' +
                        '"status":"WIP",' +
                        '"wonum":"1001",' +
                        '"ngme_ofmat_result_description":"OK",' +
                        '"ngme_ofmat_result":"OK"' +
                    '}]' +
                '}],' +
                '"targetfinish":"2025-01-01T12:00:00Z",' +
                '"ngme_justify":false,' +
                '"assetnum":"ASSET-1",' +
                '"actualstart":"2025-01-01T10:05:00Z",' +
                '"location":"LOC-1",' +
                '"locations":[{' +
                    '"ngme_lf_mksctcd":"A1",' +
                    '"ngme_mktseccode":"M1",' +
                    '"ngme_lf_mksctcd_description":"A1 Desc",' +
                    '"ngme_mktseccode_description":"M1 Desc",' +
                    '"siteid":"NG",' +
                    '"location":"LOC-1"' +
                '}],' +
                '"worklog":[{' +
                    '"modifyby":"u1",' +
                    '"logtype":"NOTE",' +
                    '"description_longdescription":"Long desc",' +
                    '"createdate":"2025-01-01T10:10:00Z",' +
                    '"description":"Short desc",' +
                    '"worklogid":"WL-1",' +
                    '"ngme_adi_expdate":"2025-12-31",' +
                    '"logtype_description":"Note"' +
                '}],' +
                '"np_statusmemo":"memo",' +
                '"ticketid":"SR-1",' +
                '"status":"QUEUED"' +
            '}]' +
        '}';

        Test.startTest();
        NGMCP_RequestClass parsed = NGMCP_RequestClass.parse(json);
        Test.stopTest();

        System.assertNotEquals(null, parsed, 'Parsed object should not be null for valid JSON');
        System.assertNotEquals(null, parsed.responseInfo, 'responseInfo should be parsed');
        System.assertEquals('/maximo/api/os/mbo', parsed.responseInfo.href);

        System.assertNotEquals(null, parsed.member, 'member list should be parsed');
        System.assertEquals(1, parsed.member.size());

        NGMCP_RequestClass.MemberClass m = parsed.member[0];
        System.assertEquals(true, m.ngme_resub);
        System.assertEquals('GAS', m.commodity);
        System.assertEquals('SR-1', m.ticketid);
        System.assertEquals('QUEUED', m.status);

        // Nested worklog
        System.assertNotEquals(null, m.worklog);
        System.assertEquals(1, m.worklog.size());
        System.assertEquals('NOTE', m.worklog[0].logtype);

        // Nested locations
        System.assertNotEquals(null, m.locations);
        System.assertEquals(1, m.locations.size());
        System.assertEquals('LOC-1', m.locations[0].location);

        // Related record and workorder
        System.assertNotEquals(null, m.relatedrecord);
        System.assertEquals(1, m.relatedrecord.size());
        System.assertNotEquals(null, m.relatedrecord[0].workorder);
        System.assertEquals(1, m.relatedrecord[0].workorder.size());
        System.assertEquals('1001', m.relatedrecord[0].workorder[0].wonum);

        // WO activity list exists
        System.assertNotEquals(null, m.relatedrecord[0].workorder[0].woactivity);
        System.assertEquals(1, m.relatedrecord[0].workorder[0].woactivity.size());
    }

    @IsTest
    static void test_parse_handles_unknown_fields_and_sparse_payload() {
        // Include unknown fields and omit most optional lists to ensure deserializer tolerates it
        String json = '{' +
            '"responseInfo":{"href":"/link"},' +
            '"member":[{' +
                '"ticketid":"SR-2",' +
                '"status":"DONE",' +
                '"unknownField":"ignored",' +
                '"worklog":null,' +
                '"locations":null,' +
                '"relatedrecord":null' +
            '}]' +
        '}';

        Test.startTest();
        NGMCP_RequestClass parsed = NGMCP_RequestClass.parse(json);
        Test.stopTest();

        System.assertNotEquals(null, parsed);
        System.assertEquals('/link', parsed.responseInfo.href);
        System.assertEquals(1, parsed.member.size());
        System.assertEquals('SR-2', parsed.member[0].ticketid);
        System.assertEquals('DONE', parsed.member[0].status);
        // Null lists should remain null, not throw
        System.assertEquals(null, parsed.member[0].worklog);
        System.assertEquals(null, parsed.member[0].locations);
        System.assertEquals(null, parsed.member[0].relatedrecord);
    }

    @IsTest
    static void test_parse_invalid_json_returns_null() {
        String badJson = '{ not-valid-json ';
        Test.startTest();
        NGMCP_RequestClass parsed = NGMCP_RequestClass.parse(badJson);
        Test.stopTest();
        System.assertEquals(null, parsed, 'Invalid JSON should be caught and return null');
    }

    @IsTest
    static void test_parse_empty_json_returns_null() {
        // Empty string causes JSON parser exception which should be handled and return null
        String emptyJson = '';
        Test.startTest();
        NGMCP_RequestClass parsed = NGMCP_RequestClass.parse(emptyJson);
        Test.stopTest();
        System.assertEquals(null, parsed, 'Empty input should return null');
    }

    @IsTest
    static void test_parse_empty_object_structure_minimum() {
        // Valid empty object with only required top-level properties
        String json = '{ "responseInfo": { "href": "" }, "member": [] }';
        Test.startTest();
        NGMCP_RequestClass parsed = NGMCP_RequestClass.parse(json);
        Test.stopTest();
        System.assertNotEquals(null, parsed, 'Valid empty object should parse');
        System.assertNotEquals(null, parsed.responseInfo);
        System.assertEquals('', parsed.responseInfo.href);
        System.assertNotEquals(null, parsed.member);
        System.assertEquals(0, parsed.member.size());
    }
}