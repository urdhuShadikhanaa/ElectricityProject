@isTest
global class NGMCP_AccessTokenHttpMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');

        response.setBody(
            '{"access_token":"test_access_token",' +
            '"token_type":"Bearer",' +
            '"expires_in":3600}'
        );

        return response;
    }
}