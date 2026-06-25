public class NGMCP_MaimoAddress {
    public static void updateAddress(String jobId, String newAddress) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('Enter the APi endpoint for Maximo'); // Use Named Credential
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> payload = new Map<String, Object>();
        payload.put('jobId', jobId);
        payload.put('address', newAddress);

        req.setBody(JSON.serialize(payload));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            System.debug('Failed to update address: ' + res.getBody());
        }
    }
}