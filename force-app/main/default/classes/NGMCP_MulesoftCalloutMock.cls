@IsTest
global class NGMCP_MulesoftCalloutMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String ep = req.getEndpoint() == null ? '' : req.getEndpoint();

        // Success responses
        if (ep.contains('callout:NGMCP_Mulesoft_Named_Credential')
            && ep.contains('createOnlineWorkRequest')) {
            // submitAMR success
            res.setStatusCode(201);
            // Shape expected by submitAMR: result.obj.p_WorkRequestID
            res.setBody('{"obj":{"p_WorkRequestID":"WR-999","p_JobType":"STOP"}}');
            return res;
        }
        if (ep.contains('callout:NGMCP_Mulesoft_Named_Credential')
            && ep.contains('cancelWorkRequest')) {
            // cancelAMR success
            res.setStatusCode(200);
            res.setBody('{"success":true,"message":"cancelled"}');
            return res;
        }

        // Fallback
        res.setStatusCode(200);
        res.setBody('{"ok":true}');
        return res;
    }
}