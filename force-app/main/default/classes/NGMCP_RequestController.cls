public with sharing class NGMCP_RequestController {
   @AuraEnabled
   public static void updateStatusAndCallAPI(Id recordId, String comments, String actionType) {
       NGMCP_Request__c req = [SELECT Id, NGMCP_ADI_Status__c FROM NGMCP_Request__c WHERE Id = :recordId with user_mode];
       String newStatus = req.NGMCP_ADI_Status__c;
       if(actionType == 'ADI'){
           newStatus = 'Additional Information Provided';
           callMaximoADIAPI(comments, recordId, 'TICKET_ADI');
       }
       else if(actionType == 'REOPEN'){
           newStatus = 'Inprogress';
           callMaximoReopenAPI(comments, recordId, 'TICKET_REOPEN');
       }
       if(Schema.sObjectType.NGMCP_Request__c.fields.Status__c.isUpdateable()){
       	   req.Status__c = newStatus; 
       }
       
       //req.Additional_Comments__c = comments;
       if(Schema.sObjectType.NGMCP_Request__c.isUpdateable()){
       	  update req;         	
       }
       
   }
   
   @AuraEnabled
   public static Object callMaximoADIAPI(String requestBody, Id requestId, String ticketuid) {
       // Construct the endpoint URL
       String endpoint = 'callout:NGMCP_Maximo_Named_Credential/NGME_CNRPN_ADI_RSMT/' + ticketuid +'?relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1&ignorers=1';
       // Create HTTP request
       Http http = new Http();
       HttpRequest request = new HttpRequest();
       request.setEndpoint(endpoint);
       request.setMethod('POST');
       request.setHeader('properties', 'ticketid, description');
       request.setHeader('Content-Type', 'application/json');
       request.setHeader('x-method-override', 'PATCH');
       request.setHeader('patchtype', 'MERGE');
       request.setBody(requestBody);
       request.setTimeout(120000);
       
       // Execute callout
       HttpResponse response = http.send(request);
       
       // Handle response
       if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
           // Success case
           String responseBody = response.getBody();
           
           // Update the request record
           NGMCP_Request__c req = [SELECT Id FROM NGMCP_Request__c WHERE Id = :requestId with user_mode];
           Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
           Map<String, Object> worklog = (Map<String, Object>) parsedJson.get('worklog');
           String description = (String) worklog.get('description_longdescription');
           if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_ADI_response_from_cutomer_portal__c.isUpdateable()){
       	   req.NGMCP_ADI_response_from_cutomer_portal__c = description;
       		}
           
           if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
       	   req.NGMCP_Status__c = 'Additional Information Provided';
       		}	
           if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
       	   req.NGMCP_TGEN_task_description__c = 'Additional Information Provided';
       		}
           
           if(Schema.sObjectType.NGMCP_Request__c.isUpdateable()){
       	  		update req;         	
       		}
           
           return responseBody;
       } else {
           // Error case
           throw new AuraHandledException('Maximo API call failed with status: ' + response.getBody());
       }
   }
   
  
   @AuraEnabled
   public static Object callMaximoReopenAPI(String requestBody, Id requestId, String ticketuid) {
       // Construct the endpoint URL
       String endpoint = 'callout:NGMCP_Maximo_Named_Credential/NGME_CNRPN_ADI_RSMT/' + ticketuid + '?relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1&ignorers=1'; 
       
       // Create HTTP request
       Http http = new Http();
       HttpRequest request = new HttpRequest();
       request.setEndpoint(endpoint);
       request.setMethod('POST');
       request.setHeader('properties', 'ticketid,description,ticketuid');
       request.setHeader('Content-Type', 'application/json');
       request.setHeader('x-method-override', 'PATCH');
       request.setHeader('patchtype', 'MERGE');
       request.setBody(requestBody);
       request.setTimeout(120000);
       
       // Execute callout
       HttpResponse response = http.send(request);
       System.debug('response: '+response);
       System.debug('response body: '+response.getBody());
       // Handle response
       if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
           // Success case
           String responseBody = response.getBody();
           
           // Update the request record
           NGMCP_Request__c req = [SELECT Id FROM NGMCP_Request__c WHERE Id = :requestId with user_mode];
           if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
       	   	req.NGMCP_Status__c = 'In Progress';
       		}
           if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Enquiry_Resubmitted__c.isUpdateable()){
       	   	req.NGMCP_Enquiry_Resubmitted__c = true;
       		}
           
           Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
           if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Resubmit_Reason__c.isUpdateable()){
       	   	req.NGMCP_Resubmit_Reason__c = (String) parsedJson.get('reason');
       		}
           if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Is_the_enquiry_justified__c.isUpdateable()){
       	   	req.NGMCP_Is_the_enquiry_justified__c = false;
       		}
           if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Is_the_enquiry_justifi__c.isUpdateable()){
       	   	req.NGMCP_Is_the_enquiry_justifi__c = '';
       		}
           if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Resolution_Date__c.isUpdateable()){
       	   	req.NGMCP_Resolution_Date__c = null;
       		}
           if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Enquiry_resolution__c.isUpdateable()){
       	   	req.NGMCP_Enquiry_resolution__c = '';
       		}
           if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
       	   	req.NGMCP_TGEN_task_description__c = '';
       		}
           
           if(Schema.sObjectType.NGMCP_Request__c.isUpdateable()){
       	  		update req;         	
       		}
           
           return responseBody;
       } else {
           // Error case
           throw new AuraHandledException('Maximo API call failed with status: ' + response.getBody());
       }
   }
     @AuraEnabled
   public static Object callMaximoSupportInfoAPI(String requestBody, Id requestId, String ticketuid){
       String relativePath;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        if (!String.isEmpty(requestBody)) {
            relativePath = '/NGME_CNRPN_ADI_RSMT/' + ticketuid + '?relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1&ignorers=1';
        }
        request.setEndpoint('callout:NGMCP_Maximo_Named_Credential' + relativePath);
        request.setMethod('POST');
        request.setHeader('properties', 'ticketid, description, ticketuid');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-method-override', 'PATCH');
        request.setHeader('patchtype', 'MERGE');
        request.setBody(requestBody);
        request.setTimeout(120000);
        
        // Start time
        Long startTime = System.currentTimeMillis();
        
        HttpResponse response = http.send(request);
        System.debug('response: '+response);
       	System.debug('response.getBody(): '+response.getBody());
        Long endTime = System.currentTimeMillis();
        Long duration = endTime - startTime;
        // 200/201 treated as success for create
        if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            //Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<NGMCP_Request__c> updateRequest =[
                SELECT Id,Name,NGMCP_MPRN__c, NGMCP_SInfo_response_from_cutomer_portal__c               
                FROM NGMCP_Request__c
                WHERE Id = :requestId 
                with user_mode
                LIMIT 1
            ];  
            // Update request tracking record if it is completed
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            if (!updateRequest.isEmpty() && !payload.isEmpty()) {
                Map<String, Object> log = (Map<String, Object>) payload.get('worklog');
                if(!log.isEmpty()){
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_SInfo_response_from_cutomer_portal__c.isUpdateable()){
                    	updateRequest[0].NGMCP_SInfo_response_from_cutomer_portal__c = (String) log.get('description_longdescription');
                    }
                    if(Schema.sObjectType.NGMCP_Request__c.isUpdateable()){
                    	update updateRequest;
                    }
                }
                       
				sendSupportInfoEmail(
    				updateRequest[0].Id,
    				updateRequest[0].Name,
    				updateRequest[0].NGMCP_MPRN__c,
    				updateRequest[0].NGMCP_SInfo_response_from_cutomer_portal__c
					);

            }
            return response.getBody();
        } else {
            // Surface a user-friendly exception to Lightning consumers
            throw new AuraHandledException('Failed to update SUP: ' + response.getBody());
        }    
    }
   
   // -------------------------------
// CMDT-driven email routing 
// -------------------------------
@AuraEnabled
public static void sendSupportInfoEmail(
    Id requestId,
    String reqName,
    String mprn,
    String supportInfoText
) {
	
 if (String.isBlank(supportInfoText)) {
        throw new AuraHandledException('Supporting information cannot be empty.');
    }

  // Backfill reqName/mprn if missing
    if (String.isBlank(reqName) || String.isBlank(mprn)) {
        NGMCP_Request__c req = [
            SELECT Id, Name, NGMCP_MPRN__c
            FROM NGMCP_Request__c
            WHERE Id = :requestId
            with user_mode
            LIMIT 1
        ];
        if (String.isBlank(reqName)) reqName = req.Name;
        if (String.isBlank(mprn))   mprn   = req.NGMCP_MPRN__c;
    }

    RoutingResult route = resolveRecipientsForRequestCMDT(requestId);
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
    if (!route.toList.isEmpty()) {

        mail.setToAddresses(route.toList);
    }

    OrgWideEmailAddress owea = tryGetOWEAByAddress(System.Label.Box_Email);
    if (owea != null) {
        mail.setOrgWideEmailAddressId(owea.Id);
    }

    mail.setSubject('Supporting Information Submitted');

    String body =
        'Supporting information has been provided for the below request\n\n' +
        'Request Ref: ' + (reqName == null ? '' : reqName) + '\n' +
        'MPRN: ' + (mprn == null ? '' : mprn) + '\n\n' +
        'Information text: ' + (supportInfoText == null ? '' : supportInfoText) + '\n\n' +
        'Email of user submitting information: ' + UserInfo.getUserEmail() + '\n' +
        'Date and time: ' + System.now().format();

    mail.setPlainTextBody(body);

    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
}

// -------------------------------
// Routing helpers
// -------------------------------
private class RoutingResult {
    List<String> toList = new List<String>();
    String matchedKey;
    String matchedRow;
}


private static final String CWR_NON_STD_FIELD = 'NGMCP_Is_Non_Standard__c'; // Boolean, determines Standard vs Non-Standard for CWR
private static final String UWR_SEGMENT_FIELD = 'NGMCP_Segment__c';         // Text/Picklist: 'Residential' or 'Commercial'
private static final String REQUEST_OBJECT = 'NGMCP_Request__c';

private static RoutingResult resolveRecipientsForRequestCMDT(Id requestId) {
    RoutingResult ret = new RoutingResult();

    Map<String, Schema.SObjectField> fmap =
        Schema.getGlobalDescribe().get(REQUEST_OBJECT).getDescribe().fields.getMap();

    List<String> selectFields = new List<String>{
        'Id',
        'Name',
        'NGMCP_MPRN__c',
        'RecordType.DeveloperName'
    };
    Boolean hasCwrNonStd = fmap.containsKey(CWR_NON_STD_FIELD);
    Boolean hasUwrSegment = fmap.containsKey(UWR_SEGMENT_FIELD);
    if (hasCwrNonStd) selectFields.add(CWR_NON_STD_FIELD);
    if (hasUwrSegment) selectFields.add(UWR_SEGMENT_FIELD);

    String soql = 'SELECT ' + String.join(selectFields, ',') +
                  ' FROM ' + REQUEST_OBJECT +
                  ' WHERE Id = :requestId LIMIT 1';

SObject rso = Database.query(soql);

SObject rtSo = rso.getSObject('RecordType');
String process = (rtSo != null) ? (String) rtSo.get('DeveloperName') : null;

if (String.isBlank(process)) {
    Id rtId = (Id) rso.get('RecordTypeId');
    if (rtId != null) {
        Schema.SObjectType sType = Schema.getGlobalDescribe().get(REQUEST_OBJECT);
        Schema.DescribeSObjectResult d = sType.getDescribe();
        Map<Id, Schema.RecordTypeInfo> byId = d.getRecordTypeInfosById();
        Schema.RecordTypeInfo rti = byId.get(rtId);
        if (rti != null) {
            process = rti.getDeveloperName();
        }
    }
}

String routingKey = computeRoutingKey(process, rso, hasCwrNonStd, hasUwrSegment);
    List<NGMCP_Email_Routing__mdt> rows = [
        SELECT DeveloperName, Object_API_Name__c, Routing_Key__c, To_Addresses__c, Active__c
        FROM NGMCP_Email_Routing__mdt
        WHERE Active__c = TRUE
          AND Routing_Key__c = :routingKey
        with user_mode
    ];

    NGMCP_Email_Routing__mdt best = null;
    for (NGMCP_Email_Routing__mdt row : rows) {
        if (row.Object_API_Name__c != null && row.Object_API_Name__c.trim().length() > 0) {
            if (row.Object_API_Name__c == REQUEST_OBJECT) {
                best = row; // exact object match wins immediately
                break;
            }
        } else {
            
            if (best == null) best = row;
        }
    }

    if (best != null && !String.isBlank(best.To_Addresses__c)) {
        ret.toList = parseEmails(best.To_Addresses__c);
        ret.matchedKey = best.Routing_Key__c;
        ret.matchedRow = best.DeveloperName;
    } else {
        // Safe fallback → Technical Queries
        ret.toList = parseEmails(System.Label.NGMCP_Provide_Supporting_Info_Email_Ids);
        ret.matchedKey = routingKey + ' (FALLBACK)';
        ret.matchedRow = 'FALLBACK_TQ';
    }

    return ret;
}

/**
 * Compute Routing_Key__c from request attributes:
 *   - CWR → CWR_Standard or CWR_Non_Standard (uses Boolean field if present; default Standard)
 *   - UWR → UWR_Residential or UWR_Commercial (uses Segment field if present; default Residential)
 *   - DQ/TQ/AMR → the same as record type
 */
private static String computeRoutingKey(String process, SObject rso, Boolean hasCwrNonStd, Boolean hasUwrSegment) {
    if (String.isBlank(process)) return 'TQ'; // safest sink

    if (process == 'CWR') {
        Boolean nonStd = false;
        if (hasCwrNonStd) {
            Object v = rso.get(CWR_NON_STD_FIELD);
            if (v != null && v instanceof Boolean) nonStd = (Boolean)v;
        }
        return nonStd ? 'CWR_Non_Standard' : 'CWR_Standard';
    }

    if (process == 'UWR') {
        String seg = null;
        if (hasUwrSegment) {
            Object v = rso.get(UWR_SEGMENT_FIELD);
            if (v != null) seg = String.valueOf(v);
        }
        // Normalize to 'Residential' / 'Commercial'
        if (!String.isBlank(seg) && seg.toLowerCase().startsWith('com')) {
            return 'UWR_Commercial';
        }
        return 'UWR_Residential'; // default
    }

    if (process == 'DQ' || process == 'TQ' || process == 'AMR') {
        return process;
    }

 
    return 'TQ';
}

/** Robust parsing for ';' / ',' / '&' separated emails */
private static List<String> parseEmails(String emailsRaw) {
    List<String> out = new List<String>();
    if (String.isBlank(emailsRaw)) return out;
    String norm = emailsRaw.replace('&', ',').replace(';', ',');
    for (String token : norm.split(',')) {
        String e = token != null ? token.trim() : null;
        if (!String.isBlank(e)) out.add(e);
    }
    return out;
}

private static OrgWideEmailAddress tryGetOWEAByAddress(String email) {
    if (String.isBlank(email)) return null;
    try {
        return [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE Address = :email
            with user_mode
            LIMIT 1
        ];
    } catch (Exception e) {
        return null;
    }
}
}