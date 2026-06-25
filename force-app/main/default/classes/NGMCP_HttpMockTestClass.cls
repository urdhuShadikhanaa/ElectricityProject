/**
 * @File Name : NGMCP_HttpMockTestClasscls
 * @Description :
 * @Author :P Shabbir Ali Khan
 * @Last Modified By :
 * @Last Modified On : October 13, 2025
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | October 13, 2025 |   | Initial Version
 **/
@isTest
public class NGMCP_HttpMockTestClass implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        // JSON string without line breaks
        String responseBody = 
            '{' +
                '"member": [' +
                    '{' +
                        '"ngme_c_ss": "BON ACCORD STREET",' +
                        '"ngme_c_st": "ABERDEEN",' +
                        '"ngme_lf_mksctcd": "I",' +
                        '"ngme_pssrband": "LP",' +
                        '"ngme_pssrband_description": "Low Pressure",' +
                        '"pluspcustassoc": [' +
                            '{' +
                                '"ngme_effective_to_date": "9999-12-31T00:00:00+00:00",' +
                                '"ngme_faux_rental": false,' +
                                '"ngme_effective_from_date": "2007-05-13T00:00:00+00:00",' +
                                '"ngme_primarycust": false,' +
                                '"ownerid": 6042748,' +
                                '"ownertable": "LOCATIONS",' +
                                '"type": "MCOS",' +
                                '"isprimary": true,' +
                                '"type_description": "Manual Change of Supplier",' +
                                '"customer": "BGB"' +
                            '}' +
                        '],' +
                        '"ngme_mktseccode": "I",' +
                        '"ngme_lf_mksctcd_description": "Industrial & Commercial",' +
                        '"ngme_mktseccode_description": "Industrial & Commercial",' +
                        '"ngme_conversionfactor": 1.02264,' +
                        '"pluspcustomer": "BGB",' +
                        '"ngme_c_prncpstreet": "BON ACCORD STREET",' +
                        '"ngme_c_spc": "AB11 6EL",' +
                        '"ngme_prsrtier": "LP",' +
                        '"ngme_c_sitebn": "40",' +
                        '"siteid": "SCO",' +
                        '"location": "1000270801",' +
                        '"ngme_prsrtier_description": "Low Pressure",' +
                        '"asset": [' +
                            '{' +
                                '"status_description": "Operating",' +
                                '"assettype_description": "System",' +
                                '"assetnum": "314086",' +
                                '"ngme_conversionfactor": "1",' +
                                '"assettype": "SYSTEM",' +
                                '"status": "OPERATING"' +
                            '},' +
                            '{' +
                                '"status_description": "Operating",' +
                                '"assettype_description": "Engineering Line Diagram",' +
                                '"assetnum": "12859050",' +
                                '"ngme_conversionfactor": "1",' +
                                '"assettype": "ELD",' +
                                '"status": "OPERATING"' +
                            '},' +
                            '{' +
                                '"status_description": "LIVE",' +
                                '"installdate": "2025-05-05T00:00:00+00:00",' +
                                '"serialnum": "G4A0046650990105",' +
                                '"assettype_description": "Meter",' +
                                '"assetnum": "1934918",' +
                                '"ngme_conversionfactor": "1",' +
                                '"ngme_pymttype": "PP",' +
                                '"assettype": "Z001",' +
                                '"ngme_pymttype_description": "Pre Payment",' +
                                '"pluscmodelnum": "G4",' +
                                '"status": "LI"' +
                            '}' +
                        ']' +
                    '}' +
                '],' +
                '"responseInfo": {' +
                    '"href": "http://main.manage.metering-uat.suite.maximo.com/maximo/api/os/NGME_MPRN_ASSET?relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1&oslc.where=LOCATION=\\"1000270801\\"&oslc.select=*&pluspcustassoc.pluspcustassoc.where=customer=\\"BGB\\"&ignorers=1"' +
                '}' +
            '}';

        res.setBody(responseBody);
        return res;
    }
}