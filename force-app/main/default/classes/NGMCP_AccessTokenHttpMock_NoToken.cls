@isTest
global class NGMCP_AccessTokenHttpMock_NoToken implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"token_type":"Bearer","expires_in":3600}');
        return res;
    }
}