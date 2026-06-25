/**
 * @File Name : NGMCP_HttpSubmitworkRequestCallout
 * @Description :
 * @Author :P Shabbir Ali Khan
 * @Last Modified By :
 * @Last Modified On : October 1331, 2025
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | October 31, 2025 |   | Initial Version
 **/
@isTest
public with sharing class NGMCP_HttpSubmitworkRequestCallout implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        String jsonBody = '{' +
            
        '"reportedpriority":"1",' +
            '"job_type":"OTVST",' +
            '"affectedphone":"01234567890",' +
            '"description_longdescription":"Test-Retrospective YES",' +
            '"job_subtype":"FAULT",' +
            '"targetstart":"2025-10-04",' +
            '"ngme_time":"05:42",' +
            '"source":"PORTAL",' +
            '"job_sub_subtype":"EXCFT40",' +
            '"ngme_liferay_slot":"AT",' +
            '"ngme_industry":"D",' +
            '"assetnum":"2360",' +
            '"suppliercode":"LEP",' +
            '"location":"1000023705",' +
            '"affectedperson":"Tina"' +
            '}';
        
        res.setBody(jsonBody);
        return res;
    }
}