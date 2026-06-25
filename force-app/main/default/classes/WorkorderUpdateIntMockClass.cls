/*
** Description: This class is used in FFA**
*/
@isTest
global class WorkorderUpdateIntMockClass implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"Header":{"TransactionType":"ST","SenderID":"NGM","ReceiverID":"NGGD_WM","InterfaceName":"SF02","FileType":"SF-UPDATE","CreationDate":"2019-06-20","CreationTime":"12:50:02","GenerationNumber":"839243"},"Body":{"Job":{"ServiceNotificationNumber":"5300054173","OperationNumber":"0010"}},"Trailer":{"TransactionType":"ST","RecordCount":"1"}}');
        response.setStatusCode(200);
        return response; 
    }
}