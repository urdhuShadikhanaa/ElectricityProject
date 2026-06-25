@IsTest
global class NGMCP_MaximoDocDownloadMock implements HttpCalloutMock {
    // Simple toggles to return success or failure
    public Integer statusCode;
    public String body;

    public NGMCP_MaximoDocDownloadMock(Integer statusCode, String body) {
        this.statusCode = statusCode;
        this.body = body;
    }

    global HTTPResponse respond(HTTPRequest req) {
        // Basic checks (optional)
        System.assert(req.getEndpoint().contains('callout:NGMCP_Maximo_Named_Credential'),
                      'Endpoint must use NGMC Maximo Named Credential');
        System.assertEquals('GET', req.getMethod());

        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        // Minimal status text
        res.setStatus(statusCode == 200 ? 'OK' : 'ERROR');
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        return res;
    }
}