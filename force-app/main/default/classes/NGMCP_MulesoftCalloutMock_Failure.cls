@IsTest
global class NGMCP_MulesoftCalloutMock_Failure implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String ep = req.getEndpoint() == null ? '' : req.getEndpoint();

        // Force failures based on path to exercise exception branches
        if (ep.contains('callout:NGMCP_Mulesoft_Named_Credential')
            && ep.contains('createOnlineWorkRequest')) {
            res.setStatusCode(400);
            res.setBody('{"error":"Bad Request"}');
            return res;
        }
        if (ep.contains('callout:NGMCP_Mulesoft_Named_Credential')
            && ep.contains('cancelWorkRequest')) {
            res.setStatusCode(500);
            res.setBody('{"error":"Server down"}');
            return res;
        }

        res.setStatusCode(400);
        res.setBody('{"error":"Unknown"}');
        return res;
    }
}