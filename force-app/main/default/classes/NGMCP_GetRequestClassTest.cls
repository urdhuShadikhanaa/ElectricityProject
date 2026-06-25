@IsTest
private class NGMCP_GetRequestClassTest {

    // Positive Mock: returns 200 with JSON matching NGMCP_RequestClass schema
    private class GetRequestPositiveMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assert(req.getEndpoint().contains('callout:NGMCP_Maximo_Named_Credential'), 'Unexpected endpoint: ' + req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');

            String body = ''
            + '{'
            + '  "member": ['
            + '    {'
            + '      "ticketuid": "TCK-100",'
            + '      "status_description": "Open",'
            + '      "ngme_justify": true,'
            + '      "ngme_resub": false,'
            + '      "actualstart": "2025-01-02T10:30:00Z",'
            + '      "targetfinish": "2025-01-12T18:00:00Z",'
            + '      "ngme_resolutionletter": "Reso-1",'
            + '      "worklog": ['
            + '        {'
            + '          "logtype": "QUESTION",'
            + '          "createdate": "2025-01-03T09:00:00Z",'
            + '          "description": "Question 1",'
            + '          "description_longdescription": "Question 1 Long",'
            + '          "ngme_adi_expdate": "2025-01-20T00:00:00Z"'
            + '        }'
            + '      ],'
            + '      "relatedrecord": ['
            + '        {'
            + '          "workorder": ['
            + '            {'
            + '              "wonum": "1000",'
            + '              "status": "WCUSTQAPPR",'
            + '              "status_description": "Waiting for Customer approval",'
            + '              "ngme_ofmat_result_description": "OFMAT-DESC-1",'
            + '              "woactivity": ['
            + '                {'
            + '                  "taskid": 10,'
            + '                  "ngme_task_code": "TGEN",'
            + '                  "description": "Task Gen Desc 1"'
            + '                }'
            + '              ]'
            + '            }'
            + '          ]'
            + '        }'
            + '      ]'
            + '    },'
            + '    {'
            + '      "ticketuid": "TCK-200",'
            + '      "status_description": "In Progress",'
            + '      "ngme_justify": false,'
            + '      "ngme_resub": true,'
            + '      "actualstart": "2025-02-05T08:00:00Z",'
            + '      "targetfinish": "2025-02-15T17:00:00Z",'
            + '      "ngme_resolutionletter": "Reso-2",'
            + '      "worklog": ['
            + '        {'
            + '          "logtype": "QUESTION",'
            + '          "createdate": "2025-02-06T10:00:00Z",'
            + '          "description": "Old Question",'
            + '          "description_longdescription": "Old Question Long",'
            + '          "ngme_adi_expdate": "2025-02-20T00:00:00Z"'
            + '        },'
            + '        {'
            + '          "logtype": "QUESTION",'
            + '          "createdate": "2025-02-08T11:15:00Z",'
            + '          "description": "Latest Question",'
            + '          "description_longdescription": "Latest Question Long",'
            + '          "ngme_adi_expdate": "2025-02-25T00:00:00Z"'
            + '        }'
            + '      ],'
            + '      "relatedrecord": ['
            + '        {'
            + '          "workorder": ['
            + '            {'
            + '              "wonum": "2000",'
            + '              "status": "CUSTQAPPR",'
            + '              "status_description": "Customer approved quotation",'
            + '              "ngme_ofmat_result_description": "OFMAT-DESC-2A",'
            + '              "woactivity": ['
            + '                { "taskid": 3, "ngme_task_code": "TGEN", "description": "Older TGEN" },'
            + '                { "taskid": 7, "ngme_task_code": "TGEN", "description": "Latest TGEN" }'
            + '              ]'
            + '            },'
            + '            {'
            + '              "wonum": "1500",'
            + '              "status": "CUSTQREJ",'
            + '              "status_description": "Customer Rejected quotation",'
            + '              "ngme_ofmat_result_description": "OFMAT-DESC-2B",'
            + '              "woactivity": []'
            + '            }'
            + '          ]'
            + '        }'
            + '      ]'
            + '    }'
            + '  ],'
            + '  "responseInfo": { "href": "/some/href" }'
            + '}';

            res.setBody(body);
            return res;
        }
    }

    // Negative Mock: simulate parse error to trigger catch and CalloutException
    private class GetRequestErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "member": [ { "ticketuid": "X"  '); // malformed JSON
            return res;
        }
    }

    @IsTest
    static void fetchRequestRecords_positive_parsesMembers() {
        Test.setMock(HttpCalloutMock.class, new GetRequestPositiveMock());
        Test.startTest();
        List<NGMCP_RequestClass.MemberClass> members = NGMCP_GetRequestClass.fetchRequestRecords();
        Test.stopTest();

        System.assertNotEquals(null, members, 'Members should not be null');
        System.assertEquals(2, members.size(), 'Expected two members');

        // Spot-check first member
        NGMCP_RequestClass.MemberClass m0 = members[0];
        System.assertEquals('TCK-100', m0.ticketuid);
        System.assertEquals('Open', m0.status_description);
        System.assertEquals(true, m0.ngme_justify);
        System.assertEquals(false, m0.ngme_resub);
        System.assertEquals('2025-01-02T10:30:00Z', m0.actualstart);
        System.assertEquals('2025-01-12T18:00:00Z', m0.targetfinish);
        System.assertEquals('Reso-1', m0.ngme_resolutionletter);
        System.assertNotEquals(null, m0.worklog);
        System.assertEquals(1, m0.worklog.size());
        System.assertEquals('QUESTION', m0.worklog[0].logtype);

        // Spot-check second member with multiple worklogs and related data
        NGMCP_RequestClass.MemberClass m1 = members[1];
        System.assertEquals('TCK-200', m1.ticketuid);
        System.assertEquals('In Progress', m1.status_description);
        System.assertEquals(false, m1.ngme_justify);
        System.assertEquals(true, m1.ngme_resub);
        System.assertEquals(2, m1.worklog.size());
        System.assertNotEquals(null, m1.relatedrecord);
        System.assertEquals(1, m1.relatedrecord.size());
        System.assertNotEquals(null, m1.relatedrecord[0].workorder);
        System.assertEquals(2, m1.relatedrecord[0].workorder.size());
    }

    @IsTest
    static void fetchRequestRecords_negative_throwsCalloutException() {
        Test.setMock(HttpCalloutMock.class, new GetRequestErrorMock());
        Test.startTest();
        Boolean threw = false;
        try {
            NGMCP_GetRequestClass.fetchRequestRecords();
        } catch (NGMCP_GetRequestClass.CalloutException ex) {
            threw = true;
            System.assert(ex.getMessage().contains('Get request callout failed'), 'Unexpected exception message: ' + ex.getMessage());
        }
        Test.stopTest();
        System.assertEquals(true, threw, 'Expected CalloutException to be thrown');
    }

    @IsTest
    static void changeDateFormat_and_changeDateTimeFormat_helpers() {
        // Avoid parsing locale-formatted string. Compare via DateTime.valueOf on an ISO string that the method will convert to same Date.
        String out1 = NGMCP_GetRequestClass.changeDateFormat('2025-12-06T07:30:00Z',false);
        // Instead of Date.valueOf(out1) which may fail if out1 is locale-formatted, validate idempotence by feeding back through Date.valueOf on a known ISO date
        // Assert the returned string represents the same calendar date as expected using Date.format() on the expected date.
        Date expected = Date.newInstance(2025, 12, 6);
        System.assertEquals(expected.format(), out1, 'Expected same calendar date as returned by helper');

        String out2 = NGMCP_GetRequestClass.changeDateFormat('2025-12-06T07:30:00+01:00', false);
        System.assertEquals(expected.format(), out2, 'Expected same calendar date for offset input');

        // Null and empty cases
        System.assertEquals('', NGMCP_GetRequestClass.changeDateFormat(null, false));
        System.assertEquals('', NGMCP_GetRequestClass.changeDateFormat('', false));

        // DateTime conversion
        DateTime dt1 = NGMCP_GetRequestClass.changeDateTimeFormat('2025-12-06T07:30:00Z');
        System.assertNotEquals(null, dt1, 'Expected a valid datetime');

        DateTime dt2 = NGMCP_GetRequestClass.changeDateTimeFormat('2025-12-06T07:30:00+01:00');
        System.assertNotEquals(null, dt2, 'Expected a valid datetime');

        System.assertEquals(null, NGMCP_GetRequestClass.changeDateTimeFormat(null));
        System.assertEquals(null, NGMCP_GetRequestClass.changeDateTimeFormat(''));
    }
}