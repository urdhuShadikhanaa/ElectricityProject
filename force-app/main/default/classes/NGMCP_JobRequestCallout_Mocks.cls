@IsTest
public class NGMCP_JobRequestCallout_Mocks {

    // 201 Success mock
    public class SuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setHeader('Content-Type', 'application/json');
            // Body includes ticketid that your queueable will store in NGMCP_SR_Ticket__c
            res.setBody('{"ticketid":"SR-12345","ticketuid":"999999"}');
            return res;
        }
    }

    // 400 Error mock
    public class ErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error":"bad request"}');
            return res;
        }
    }
}