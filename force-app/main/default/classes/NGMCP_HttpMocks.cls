@IsTest
public class NGMCP_HttpMocks {

    public class AccessCodeMock_StringExpires implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"tok_string_3599","token_type":"Bearer","expires_in":"3599"}');
            return res;
        }
    }

    public class AccessCodeMock_NumericExpires implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"tok_num_7200","token_type":"Bearer","expires_in":7200}');
            return res;
        }
    }

    public class AccessCodeMock_400 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error":"invalid_client"}');
            return res;
        }
    }
}