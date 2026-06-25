@isTest
public class NGMCP_EditAddressTest {

    // Mock for Success Response
    private class NGNCP_editaddressMockSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"message":"Success"}');
            return res;
        }
    }

    // Mock for Failure Response
    private class NGNCP_editaddressMockFailure implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error":"Internal Server Error"}');
            return res;
        }
    }

    // ✅ Test Success Scenario
    @isTest
    static void testEditAddressSuccess() {
        Test.setMock(HttpCalloutMock.class, new NGNCP_editaddressMockSuccess());

        Test.startTest();
        String result = NGMCP_editaddress.editAddress(
            '123', 'Building A', 'Main Street', 'AB12 3CD', 'PostalTown',
            'DependentLocality', 'LocationX', 'Serial123', 'Asset456'
        );
        Test.stopTest();

        System.assertEquals('Address updated successfully.', result);
    }

    // ✅ Test Failure Scenario
    @isTest
    static void testEditAddressFailure() {
        Test.setMock(HttpCalloutMock.class, new NGNCP_editaddressMockFailure());

        Test.startTest();
        String result = NGMCP_editaddress.editAddress(
            '123', 'Building A', 'Main Street', 'AB12 3CD', 'PostalTown',
            'DependentLocality', 'LocationX', 'Serial123', 'Asset456'
        );
        Test.stopTest();

        System.assert(result.startsWith('Failed to update address'), 'Expected failure message');
    }

    // ✅ Test Exception Scenario
    @isTest
    static void testEditAddressException() {
        // No mock set → will throw exception because endpoint is invalid
        Test.startTest();
        String result = NGMCP_editaddress.editAddress(null, null, null, null, null, null, null, null, null);
        Test.stopTest();

        System.assert(result.startsWith('Exception occurred'), 'Expected exception message');
    }
}