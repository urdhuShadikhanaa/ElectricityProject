@IsTest
global class NGMCP_AllCalloutsMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String ep = req.getEndpoint() == null ? '' : req.getEndpoint();

        // MuleSoft queueable
        if (ep.contains('callout:NGMCP_Mulesoft_Named_Credential')) {
            res.setStatusCode(201);
            res.setBody('{"obj":{"p_WorkRequestID":"WR-999"}}');
            return res;
        }

        // Maximo queueable
        if (ep.contains('callout:NGMCP_Maximo_Named_Credential')) {
            res.setStatusCode(200);
            res.setBody('{"ticketid":"TICK-001","ticketuid":"UID-001","targetstart":"2026-06-04","targetfinish":"2026-06-09"}');
            return res;
        }

        res.setStatusCode(200);
        res.setBody('{"ok":true}');
        return res;
    }
}