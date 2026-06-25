/**
 * @File Name : NGMCP_HttpAddressMockTestCallout
 * @Description :
 * @Author :P Shabbir Ali Khan
 * @Last Modified By :
 * @Last Modified On : October 31, 2025
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | October 31, 2025 |   | Initial Version
 **/
@isTest
public with sharing class NGMCP_HttpAddressMockTestCallout implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        String responseBody = '{' +
            '"ngme_c_st":"MONTROSE",' +
            '"ngme_c_prncpstreet":"Avenue road",' +
            '"ngme_c_depndlocality":"INVERBERVIE",' +
            '"ngme_c_spc":"DD10 0RR",' +
            '"siteid":"SCO",' +
            '"location":"1000023705",' +
            '"ngme_c_bldngname":"23",' +
            '"asset":[{' +
            '"serialnum":"00600790",' +
            '"assetnum":"13517737"' +
            '}]' +
            '}';
        res.setBody(responseBody);
        return res;
    }
}