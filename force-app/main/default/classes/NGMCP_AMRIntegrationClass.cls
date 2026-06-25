public with sharing class NGMCP_AMRIntegrationClass {
    
    @AuraEnabled
    /**
     * Submit an AMR (Service Request create) to Mulesoft.
     * Writes back the SR ticket id and full response to NGMCP_Request__c for auditability.
     *
     * Performance:
     * - Captures duration for troubleshooting downstream latency.
     *
     * @param requestBody JSON body defining the SR payload.
     * @param requestId   NGMCP_Request__c Id to store status/response.
     * @return Raw response body string on success.
     * @throws AuraHandledException on non-2xx responses.
     */
        
    public static Object  submitAMR(String requestBody, Id requestId) {
        NGMCP_Mulesoft_Access_Code__c MAC = NGMCP_MulesoftIntegrationController.getMAC();
        
        String relativePath;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        if (!String.isEmpty(requestBody)) {
            relativePath = '/v1/workRequest/createOnlineWorkRequest';
            
        }
        request.setEndpoint('callout:NGMCP_Mulesoft_Named_Credential' + relativePath);
        request.setMethod('POST');
        
        
        request.setHeader('client_id', System.Label.NGMCP_Mulesoft_Username);
        request.setHeader('client_secret', System.Label.NGMCP_Mulesoft_Password);

        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        
        request.setHeader('Authorization', MAC.NGMCP_Token_Type__c + ' ' + MAC.NGMCP_Access_Code__c);
        request.setBody(requestBody);
        request.setTimeout(120000);
        
        // Start time
        Long startTime = System.currentTimeMillis();
        
        HttpResponse response = http.send(request);
        
        Long endTime = System.currentTimeMillis();
        Long duration = endTime - startTime;
        
        // 200/201 treated as success for create
        if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            
            Map<String, Object> obj = (Map<String, Object>) result.get('obj');
            
            List<NGMCP_Request__c> updateRequest =[
                SELECT Id, NGMCP_Callout_Status__c, NGMCP_Callout_Response__c, NGMCP_SR_Ticket__c, 
                NGMCP_Status__c, NGMCP_Job_Type__c
                FROM NGMCP_Request__c
                WHERE Id = :requestId 
                //AND NGMCP_Callout_Status__c = 'In Progress'
                with user_mode
                LIMIT 1
            ];
            // Update request tracking record if still in-progress
            if (!updateRequest.isEmpty()) {
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Callout_Status__c.isUpdateable()){
        			updateRequest[0].NGMCP_Callout_Status__c = 'Completed';
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Callout_Response__c.isUpdateable()){
        			updateRequest[0].NGMCP_Callout_Response__c = response.getBody();
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_SR_Ticket__c.isUpdateable()){
        			updateRequest[0].NGMCP_SR_Ticket__c = obj != null ? obj.get('p_WorkRequestID').toString() : '';
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
        			updateRequest[0].NGMCP_Status__c = 'Submitted';
        		}
                
                
                //updateRequest[0].NGMCP_Job_Type__c = String.valueOF(obj.get('p_JobType'));
                if(Schema.sObjectType.NGMCP_Request__c.isUpdateable()){
                	update updateRequest;
                }
            }
            return response.getBody();
        } else {
            
            // Surface a user-friendly exception to Lightning consumers
            throw new AuraHandledException('Failed to create enquiry. Status: ' + response.getBody());
        }
        
    }

    // new method for assetdetails MPRN
@AuraEnabled

     public static Object getAMRAssetDetails(String Mprn) {
    NGMCP_Mulesoft_Access_Code__c MAC =
        NGMCP_MulesoftIntegrationController.getMAC();

    Http http = new Http();
    HttpRequest request = new HttpRequest();

    
    String relativePath =
        '/v1/getAssetDetails?p_MPRN=' +
        EncodingUtil.urlEncode(Mprn, 'UTF-8');

    request.setEndpoint(
        'callout:NGMCP_Mulesoft_Named_Credential' + relativePath
    );

   
    request.setMethod('POST');

    
    request.setHeader('client_id', System.Label.NGMCP_Mulesoft_Username);
    request.setHeader('client_secret', System.Label.NGMCP_Mulesoft_Password);
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('Accept', 'application/json');
    request.setHeader(
        'Authorization',
        MAC.NGMCP_Token_Type__c + ' ' + MAC.NGMCP_Access_Code__c
    );

    
    request.setBody('{}');

    request.setTimeout(120000);

    HttpResponse response = http.send(request);
	System.debug('response: '+response);
    System.debug('response body: '+response.getBody());     
    

    if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
        return response.getBody();
    }

    throw new AuraHandledException(
        'AMR Asset API Failed. Status: ' +
        response.getStatusCode() +
        ' Body: ' +
        response.getBody()
    );
}

    /**
     * @method createAMR
     * @description Creates a new Data Query record in Salesforce.
     * @param requestBody - JSON string containing data query details.
     * @return Id - The Id of the newly created NGMCP_Request__c record.
     */

         @AuraEnabled
        public static Id  createAMR(String requestBody, String isPulsing, String gpsId, NGMCP_Request__c amrRequest) {
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            List<NGMCP_Request__c> requestObjList = new List<NGMCP_Request__c>();
            String result;
            Id recordTypeId = Schema.SObjectType.NGMCP_Request__C.RecordTypeInfosByName.get('AMR').RecordTypeId;
            if (!payload.isEmpty()) {                
                NGMCP_Request__c requestObj = new NGMCP_Request__c();
                if(Schema.sObjectType.NGMCP_Request__c.fields.RecordTypeId.isCreateable()){
        			requestObj.RecordTypeId = recordTypeId;
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Contract_Reference__c.isCreateable()){
        			requestObj.NGMCP_Contract_Reference__c = (String) payload.get('p_ContractRef');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Supplier_Id__c.isCreateable()){
        			requestObj.NGMCP_Supplier_Id__c = (String) payload.get('p_CustomerCode');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Transaction_Reference__c.isCreateable()){
        			requestObj.NGMCP_Transaction_Reference__c = (String) payload.get('p_TransactionRef');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Job_Type__c.isCreateable()){
        			requestObj.NGMCP_Job_Type__c = (String) payload.get('p_JobType');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_MPRN__c.isCreateable()){
        			requestObj.NGMCP_MPRN__c = (String) payload.get('p_MPRN');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Service_Level__c.isCreateable()){
        			requestObj.NGMCP_Service_Level__c = (String) payload.get('p_ServiceLevel');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Annual_Consumption__c.isCreateable()){
        			requestObj.NGMCP_Annual_Consumption__c = (String) payload.get('p_AnnualQuantity');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Target_Start__c.isCreateable()){
        			requestObj.NGMCP_Target_Start__c = (String) payload.get('p_EffectiveDate');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Reason__c.isCreateable()){
        			requestObj.NGMCP_Reason__c = (String) payload.get('p_CreateReason');
        		}
				if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Affectedphone__c.isCreateable()){
        			requestObj.NGMCP_Affectedphone__c = (String) payload.get('p_SiteContact');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Affected_Person__c.isCreateable()){
        			requestObj.NGMCP_Affected_Person__c = (String) payload.get('p_SiteName');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Affectedphone__c.isCreateable()){
        			requestObj.NGMCP_Affectedphone__c = (String) payload.get('p_contactNo');
        		}
				if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Description_Long_Description__c.isCreateable()){
        			requestObj.NGMCP_Description_Long_Description__c = (String) payload.get('p_Comments');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Ngme_ConseMail__c.isCreateable()){
        			requestObj.NGMCP_Ngme_ConseMail__c = (String) payload.get('p_Email');
        		}
				if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_MAM_Id__c.isCreateable()){
        			requestObj.NGMCP_MAM_Id__c = (String) payload.get('p_MAMId');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Address__c.isCreateable()){
        			requestObj.NGMCP_Address__c = (String) payload.get('p_Address');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Postal_Town__c.isCreateable()){
        			requestObj.NGMCP_Postal_Town__c = (String) payload.get('p_Posttown');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Postal_Code__c.isCreateable()){
        			requestObj.NGMCP_Postal_Code__c = (String) payload.get('p_PostCode');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Correction_Conversion_Factor__c.isCreateable()){
        			requestObj.NGMCP_Correction_Conversion_Factor__c = payload.get('p_CorrectionFactor').toString();
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Manufacturer__c.isCreateable()){
        			requestObj.NGMCP_Manufacturer__c = (String) payload.get('p_MeterManufacturer');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Current_Meter_Model__c.isCreateable()){
        			requestObj.NGMCP_Current_Meter_Model__c = (String) payload.get('p_MeterModel');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Year_of_Manufacture__c.isCreateable()){
        			requestObj.NGMCP_Year_of_Manufacture__c = (String) payload.get('p_MeterYOM');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Current_Meter_Serialnumber__c.isCreateable()){
        			requestObj.NGMCP_Current_Meter_Serialnumber__c = (String) payload.get('p_MeterSerialNumber');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_No_of_Dials__c.isCreateable()){
        			requestObj.NGMCP_No_of_Dials__c =  payload.get('p_MeterDials').toString();
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Meter_Units_of_Measure__c.isCreateable()){
        			requestObj.NGMCP_Meter_Units_of_Measure__c = (String) payload.get('p_MeterUnitofMeasure');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Meter_Reading_Factor__c.isCreateable()){
        			requestObj.NGMCP_Meter_Reading_Factor__c =  payload.get('p_MeterReadingFactor').toString();
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Converter_Fitted_Indicator__c.isCreateable()){
        			requestObj.NGMCP_Converter_Fitted_Indicator__c = (String) payload.get('p_ConverterFittedIndicator');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Converter_Serial_Number__c.isCreateable()){
        			requestObj.NGMCP_Converter_Serial_Number__c = (String) payload.get('p_ConverterSerialNumber');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Converter_Dials__c.isCreateable()){
        			requestObj.NGMCP_Converter_Dials__c =  payload.get('p_ConverterDials').toString();
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Converter_Reading_Factor__c.isCreateable()){
        			requestObj.NGMCP_Converter_Reading_Factor__c =  payload.get('p_ConverterReadingFactor').toString();
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Callout_Status__c.isCreateable()){
        			requestObj.NGMCP_Callout_Status__c = 'In Progress';
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_API_Callout__c.isCreateable()){
        			requestObj.NGMCP_API_Callout__c = 'Create AMR callout';
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isCreateable()){
        			requestObj.NGMCP_Status__c = ((String) payload.get('p_JobType') == 'STRT' && isPulsing == 'NO') || (String) payload.get('p_JobType') == 'RMVE' ? 'On Hold' : '';
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Related_GPS_Job_Number__c.isCreateable()){
        			requestObj.NGMCP_Related_GPS_Job_Number__c = gpsId;
        		}
                
                if(amrRequest != null){
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Building_Name__c.isCreateable()){
        				requestObj.NGMCP_Building_Name__c = amrRequest.NGMCP_Building_Name__c;
        			}
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Market_Sector_Code__c.isCreateable()){
        				requestObj.NGMCP_Market_Sector_Code__c = amrRequest.NGMCP_Market_Sector_Code__c;
        			}
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Street__c.isCreateable()){
        				requestObj.NGMCP_Street__c = amrRequest.NGMCP_Street__c;
        			}
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Affected_Person_Title__c.isCreateable()){
        				requestObj.NGMCP_Affected_Person_Title__c = amrRequest.NGMCP_Affected_Person_Title__c;
        			}
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Dependent_Locality__c.isCreateable()){
        				requestObj.NGMCP_Dependent_Locality__c = amrRequest.NGMCP_Dependent_Locality__c;
        			}
                    
                }
                
                requestObjList.add(requestObj);
            }
            if (!requestObjList.isEmpty() && Schema.sObjectType.NGMCP_Request__c.isCreateable()) {
                insert requestObjList;
            }
            return requestObjList[0].Id;
        }


    @AuraEnabled
public static String cancelAMRRequest(Id requestId) {

    NGMCP_Mulesoft_Access_Code__c MAC =
        NGMCP_MulesoftIntegrationController.getMAC();

    // Get Salesforce record
    NGMCP_Request__c req = [
        SELECT Id,
               NGMCP_SR_Ticket__c,
               NGMCP_Status__c
        FROM NGMCP_Request__c
        WHERE Id = :requestId
        with user_mode
        LIMIT 1
    ];

    if (String.isBlank(req.NGMCP_SR_Ticket__c)) {
        throw new AuraHandledException('WorkRequestID not available');
    }

    String relativePath =
        '/v1/workRequest/cancelWorkRequest'
        + '?workRequestID=' + req.NGMCP_SR_Ticket__c;

    HttpRequest request = new HttpRequest();
    request.setEndpoint('callout:NGMCP_Mulesoft_Named_Credential' + relativePath);
    request.setMethod('POST');

    request.setHeader('client_id', System.Label.NGMCP_Mulesoft_Username);
    request.setHeader('client_secret', System.Label.NGMCP_Mulesoft_Password);
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('Accept', 'application/json');
    request.setHeader('Authorization',
        MAC.NGMCP_Token_Type__c + ' ' + MAC.NGMCP_Access_Code__c
    );

    request.setBody('{}');
    request.setTimeout(120000);

    Http http = new Http();
    HttpResponse response = http.send(request);

    

    if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
		if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
        	req.NGMCP_Status__c = 'Cancelled';
        }
        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Callout_Response__c.isUpdateable()){
        	req.NGMCP_Callout_Response__c = response.getBody();
        }
        if(Schema.sObjectType.NGMCP_Request__c.isUpdateable()){
        	update req;
        }
        return response.getBody();
    }
    else {
        throw new AuraHandledException(
            'Cancellation failed: ' + response.getBody()
        );
    }
}
	
    public static Id createTQ(NGMCP_Request__c tq){
        insert tq;
        return tq.Id;
    } 

    public class PayloadWrapper{
        public String p_ContractRef;
        public String p_CustomerCode;
        public String p_TransactionRef;
        public String p_JobType;
        public String p_MPRN;
        public String p_ServiceLevel;
        public Integer p_AlarmReq;
        public String p_UpfrontReq;
        public String p_AnnualQuantity;
        public String p_EffectiveDate;
        public String p_CreateReason;
        public String p_AlarmHigh;
        public String p_AlarmLow;
        public String p_AlarmPeriod;
        public String p_AlarmNotification;
        public String p_SiteContact;
        public String p_SiteName;
        public String p_contactNo;
        public Integer p_DMLogger;
        public String p_OpenRead;
        public String p_Prime;
        public String p_Comments;
        public String p_Email;
        public String p_Retval;
        public String p_MAMId;
        public String p_Address;
        public String p_Posttown;
        public String p_PostCode;
        public Integer p_CorrectionFactor;
        public String p_MeterManufacturer;
        public String p_MeterModel;
        public String p_MeterYOM;
        public String p_MeterSerialNumber;
        public Integer p_MeterDials;
        public String p_MeterUnitofMeasure;
        public Integer p_MeterReadingFactor;
        public String p_ConverterFittedIndicator;
        public String p_ConverterSerialNumber;
        public Integer p_ConverterDials;
        public Integer p_ConverterReadingFactor;
        public Boolean p_SVSTResponseSent;
        public String p_ReadFrequency;
        public String p_RequestNGMReference;
        public String p_AMRSerialNumber;
        public String p_YearofManufacture;
        public String p_ServiceProvider;
    }  
    
    public class TQPayloadWrapper{
        public String ngme_consname;
        public String reason;
        public String loccode;
        public String bldgname;
        public String sectorcode;
        public String street;
        public String supplier;
        public String notif_type;
        public String ngme_riskassess;
        public String posttown;
        public String ngme_constitle;
        public String description_longdescription;
        public String ngme_engvisit;
        public String targetstart;
        public String postcode;
        public String ngme_time;
        public String ngme_consphone;
        public String ngme_consemail;
        public String deplocal;
        public String ngme_threshold;
        public String location;
        public String reportedemail;
        public String category;
        public String subcategory;
    }
	
    public class AppntDeappPayloadWrapper{
       	public String ngme_file_type;
       	public String ngme_creation_date;
        public String ngme_originator_id;
       	public String ngme_recipient_role;
        public String ngme_status;
       	public Long ngme_transaction_count;
        public String ngme_integration_type;
       	public String ngme_creation_time;
       	public String ngme_reqrecdate;
       	public Long ngme_record_count;
        public String ngme_record_identifier;
       	public String ngme_recipient_id;
        public TransClass ngme_trans;
        public String ngme_originator_role;
       	public String ngme_file_identifier;
        public String ngme_source_system;
       	public String ngme_file_usage_code; 
    }
    
    public class TransClass{
        public String ngme_reason_code;
       	public String ngme_reference;
        public String ngme_type_code;
       	public String ngme_sector_code;
        public String ngme_record_identifier;
        public String ngme_contract_ref;
        public MTPNTClass ngme_mtpnt;
        public String ngme_to_date;
        public String ngme_from_date;
    }
    
    public class MTPNTClass{
       public String ngme_record_identifier; 
       public MKPRTClass ngme_mkprt;
       public String ngme_link_code;
       public String ngme_referencenum;
       public ADDRSClass ngme_addrs;
       public AssetClass ngme_asset;
    }
    
    public class MKPRTClass{
       public String ngme_record_identifier;
       public String ngme_role_code;
       public String ngme_abbrv_name;
    }
    
    public class ADDRSClass{
        public String ngme_type_code;
       	public String ngme_record_identifier;
        public String ngme_sub_building_no;
       	public String ngme_building_no; 
        public String ngme_dependent_through;
       	public String ngme_throughfare;
        public String ngme_double_locality;
       	public String ngme_dependent_locality; 
        public String ngme_post_town;
       	public String ngme_county;
        public String ngme_post_code; 
    }
    
    public class AssetClass{
        public String ngme_record_identifier; 
        public String ngme_pay_method_code;
       	public String ngme_trans_type_code;
        public String ngme_class_code;
       	public String ngme_model_code; 
        public String ngme_manufacture_code;
       	public String ngme_manufacture_year;
        public String ngme_serial_no; 
        public String ngme_location_code; 
        public String ngme_location_notes;
       	public String ngme_status_code;
        public MeterClass ngme_meter;
        public REGSTClass ngme_regst;						
    }
    
    public class MeterClass{
       	public String ngme_record_identifier; 
        public String ngme_type_code; 
        public String ngme_mechanism_code;
       	public Integer ngme_measure_capacity; 
        public String ngme_status_code; 
    }
    
    public class REGSTClass{
       	public String ngme_record_identifier; 
        public String ngme_type_code; 
        public Integer ngme_no_of_digit;
       	public String ngme_measure_unit; 
        public Integer ngme_multiplication_factor; 
    }

}