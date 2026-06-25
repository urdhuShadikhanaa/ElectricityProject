public with sharing class NGMCP_GetRequestClass {

    public static List<NGMCP_RequestClass.MemberClass> fetchRequestRecords() {
        String relativePath = '/NGME_LR_MX_SCH?oslc.select=*&relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1&savedQuery=SCHEDULERSRWRQUERY&ignorers=1';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:NGMCP_Maximo_Named_Credential' + relativePath);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        HttpResponse response;
        List<NGMCP_RequestClass.MemberClass> records;
        /*HttpResponse response = http.send(request);
        Integer statusCode = response.getStatusCode();
        System.debug('Status Code: ' + statusCode);
        List<RecordToUpdate> records
        if (statusCode == 200) {
            System.debug(response.getBody());
            System.debug('Response Body'+NGMCP_GetAssetDetailsClass.parse(response.getBody()));
            return NGMCP_GetAssetDetailsClass.parse(response.getBody());
        } else {
            throw new AuraHandledException('Failed postcallout: ' + response.getStatus());
        }*/
        try {
            response = http.send(request);
            Integer statusCode = response.getStatusCode();
            System.debug('Status Code: ' + statusCode);
            System.debug('response: ' + response);
            System.debug('response.getBody(): ' + response.getBody());
            if(statusCode == 200){
                //records = (List<NGMCP_RequestClass.MemberClass>) JSON.deserialize(response.getBody(), List<NGMCP_RequestClass.MemberClass>.class);
                System.debug('response.getBody(): '+response.getBody());
                System.debug('return values: '+NGMCP_RequestClass.parse(response.getBody()));
                //return NGMCP_RequestClass.parse(response.getBody());
                NGMCP_RequestClass req = NGMCP_RequestClass.parse(response.getBody());
                System.debug('req:'+req);
                System.debug('req.member:'+req.member);
                System.debug('req.member size:'+req.member.size());
                if(!req.member.isEmpty()){
                    records = req.member;
                }
                System.debug('records:'+records);
                
            }
        } catch (Exception e) {
            System.debug('Error @39:' + e.getMessage() + ' @line:' + e.getLineNumber() + ' @class:' + e.getTypeName() + ' @method:' + e.getStackTraceString());
            System.debug('Error @40:' + response.getStatusCode());
            System.debug('Error @41:' + response.getBody());
            throw new CalloutException('Get request callout failed: ' + e.getMessage());
        }

        return (records == null) ? new List<NGMCP_RequestClass.MemberClass>() : records;
    }
/*
    // Utility: Parse ISO-8601 "2025-12-06T07:30:00Z" to DateTime
    public static DateTime parseIso8601(String iso) {
        if (iso == null) return null;
        String cleaned = iso.replace('T', ' ').replace('Z', '');
        try {
            return DateTime.valueOf(cleaned);
        } catch (Exception e) {
            return null;
        }
    }
*/

    public static String changeDateFormat(String dateStr, Boolean isADIDate){
        System.debug('dateStr: '+dateStr);
        String formatted = '';
        if(dateStr == null || dateStr == ''){
            return '';
        }else{
        //
        // Step 1: Normalize
        String cleaned = dateStr.replace('T', ' ');
        Integer tzPos = Math.max(cleaned.lastIndexOf('+'), cleaned.lastIndexOf('-'));
        if (tzPos > 10) {
            cleaned = cleaned.substring(0, tzPos); // strip timezone offset
        }

        //// Step 2: Convert to DateTime
        DateTime dt = DateTime.valueOf(cleaned);

        // Step 3: Extract Date
        Date d = dt.date();
        System.debug('d: '+d);
        formatted = d.format();
        System.debug('Formatted Date before: ' + formatted);
        System.debug('Date.today(): ' + Date.today());
        System.debug('isADIDate: ' + isADIDate);
        System.debug('d > Date.today(): ' + (d > Date.today()));
        if(d > Date.today() && isADIDate == true){
        // Step 4: Format as yyyy-MM-dd
        formatted = d.format();// Default is yyyy-MM-dd
        }
        else if(d < Date.today() && isADIDate == true){
            formatted = '';
        }
        else{
           formatted = d.format(); 
        }
        System.debug('Formatted Date: ' + formatted);
        //System.debug('Formatted Date: ' + Date.valueOf(formatted));
        return formatted;
        }
    }

    public static DateTime changeDateTimeFormat(String dateStr){
        System.debug('dateStr: '+dateStr);
        DateTime dt = DateTime.now();
        if(dateStr == null || dateStr == ''){
            return null;
        }
        else{
        // Step 1: Normalize
        String cleaned = dateStr.replace('T', ' ');
        Integer tzPos = Math.max(cleaned.lastIndexOf('+'), cleaned.lastIndexOf('-'));
        if (tzPos > 10) {
            cleaned = cleaned.substring(0, tzPos); // strip timezone offset
        }

        //// Step 2: Convert to DateTime
        dt = DateTime.valueOf(cleaned);

    
        System.debug('dt: ' + dt);
       
        return dt;
        }   
    }
    public class CalloutException extends Exception {}


}