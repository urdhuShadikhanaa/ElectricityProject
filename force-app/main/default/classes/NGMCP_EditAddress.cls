public with sharing class NGMCP_EditAddress {

    @AuraEnabled
    public static String editAddress(
        String buildingNumber,
        String buildingName,
        String street,
        String postCode,
        String postalTown,
        String dependentLocality,   
        String location,
        String serialNum,
        String assetNum
    ) {
        try {
            
    System.debug('--- Incoming Parameters ---');
            System.debug('Building Number: ' + buildingNumber);
            System.debug('Building Name: ' + buildingName);
            System.debug('Street: ' + street);
            System.debug('Post Code: ' + postCode);
            System.debug('Postal Town: ' + postalTown);
            System.debug('Dependent Locality: ' + dependentLocality);
            System.debug('Location: ' + location);
            System.debug('Serial Number: ' + serialNum);
            System.debug('Asset Number: ' + assetNum);

            Http http = new Http();
            HttpRequest request = new HttpRequest();

            String relativePath = '/6080344' +
                '?relativeuri=1' +
                '&lean=1' +
                '&ignorekeyref=1' +
                '&ignorecollectionref=1';

            String endpoint = 'callout:NGMCP_Maximo_Integration' + relativePath;
            request.setEndpoint(endpoint);

            request.setMethod('POST'); 
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('x-method-override', 'PATCH');
            request.setHeader('patchtype', 'MERGE');

            // Build dynamic payload
            Map<String, Object> assetData = new Map<String, Object>{
                'ngme_c_st' => postalTown,
                'ngme_c_prncpstreet' => street,
                'ngme_c_depndlocality' => dependentLocality,
                'ngme_c_spc' => postCode,
                'siteid' => 'REE',
                'location' => location,
                'ngme_amrtag' => 'false',
                'ngme_microbusiness' => 'false',
                'locationsid' => '6080344',
                'ngme_c_bldngname' => buildingName,
                 'ngme_c_sitebn' => buildingNumber,
                'asset' => new List<Object>{
                    new Map<String, Object>{
                        'serialnum' => serialNum,
                        'assetnum' => assetNum
                    }
                }
            };

            Map<String, Object> wrappedPayload = new Map<String, Object>{
                'NGME_MPRN_ASSET' => assetData
            };

            String payload = JSON.serialize(wrappedPayload);
            request.setBody(payload);
            request.setTimeout(120000);

            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200 || response.getStatusCode() == 204) {
                return 'Address updated successfully.';
            } else {
                return 'Failed to update address. Status: ' + response.getStatus() + ' - ' + response.getBody();
            }

        } catch (Exception ex) {
            return 'Exception occurred: ' + ex.getMessage();
        }
    }
}