public with sharing class NGMCP_EnquiriesHandler {
    //Reason code = MUOP, sub category = MET 
	public static Map<String, String> categoryCodeMap = new Map<String, String>{
        'MUOP' => 'Meter under/over pulsing',
        'BSM' => 'Blank screen on an E6 meter',
        'COQ' => 'Converter Enquiry',
        'CROS' => 'Converter reads out of sync',
        'CFU' => 'Correction Factor Challenge',
        'CRM' => 'Corroded/Rusty Meter',
        'FMB' => 'Faulty meter bracket',
        'DUM2' => 'Incorrect asset details',
        'LBC' => 'Low battery converter',
        'MNR' => 'Meter not registering / Static reads on meter',
        'DUM5' => 'Meter Status Enquiry',
        'DUM1' => 'Missing exchange',
        'MRV' => 'Missing removal',
        'DUM4' => 'Other',
        'CXPC' => 'The converter is not pulsing correctly',
        'WOMS' => 'Water/condensation in the meter screen'
    };
    
    public static Map<String, String> reasonCodeMap = new Map<String, String>{
        'MET' => 'Meter',
        'CAA' => 'Address Amendment Enquiry',
        'ADHOC' => 'Adhoc',
        'ADQ' => 'Asset Data Enquiry',
        'CON' => 'Converter',
        'CRO' => 'Crossed Meter Enquiry',
        'FOU' => 'Found Meter Enquiry',
        'REP' => 'Replicate MPRN Enquiry'
    };

    @AuraEnabled
    /**
     * Submit a Data Query (Service Request create) to Maximo.
     * Writes back the SR ticket id and full response to NGMCP_Request__c for auditability.
     *
     * Performance:
     * - Captures duration for troubleshooting downstream latency.
     *
     * @param requestBody JSON body defining the SR payload.
     * @param requestId   NGMCP_Request__c Id to store status/response/ticket id.
     * @return Raw response body string on success.
     * @throws AuraHandledException on non-2xx responses.
     */
        
    public static Object  submitDataQuery(String requestBody, Id requestId) {
        String relativePath;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        if (!String.isEmpty(requestBody)) {
            relativePath = '/NGME_LR_CREATE_ENQ?relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1';
        }
        request.setEndpoint('callout:NGMCP_Maximo_Named_Credential' + relativePath);
        request.setMethod('POST');
        request.setHeader('properties', 'ticketid,ticketuid,targetstart,targetfinish');
        //request.setHeader('properties', 'ticketuid');
        request.setHeader('Content-Type', 'application/json');
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
            List<NGMCP_Request__c> updateRequest =[
                SELECT Id, NGMCP_Callout_Status__c, NGMCP_Callout_Response__c, NGMCP_SR_Ticket__c, NGMCP_Status__c
                FROM NGMCP_Request__c
                WHERE Id = :requestId
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
        			updateRequest[0].NGMCP_SR_Ticket__c = String.valueOf(result.get('ticketid'));
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Ticketuid__c.isUpdateable()){
        			updateRequest[0].NGMCP_Ticketuid__c = String.valueOf(result.get('ticketuid'));
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
        			updateRequest[0].NGMCP_Status__c = 'Submitted';
        		}
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

    /**
     * @method createDataQueryRecord
     * @description Creates a new Data Query record in Salesforce.
     * @param requestBody - JSON string containing data query details.
     * @return Id - The Id of the newly created NGMCP_Request__c record.
     */

         @AuraEnabled
        public static Id  createDataQueryRecord(String requestBody,NGMCP_Request__c meterDetails, String reportedEmail) {
            try{
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            List<NGMCP_Request__c> requestObjList = new List<NGMCP_Request__c>();
            String result;
            
            Id recordTypeId = Schema.SObjectType.NGMCP_Request__C.RecordTypeInfosByName.get('Enquiry').RecordTypeId;
            if (!payload.isEmpty()) {                
                NGMCP_Request__c requestObj = new NGMCP_Request__c();
                if(Schema.sObjectType.NGMCP_Request__c.fields.RecordTypeId.isCreateable()){
        			requestObj.RecordTypeId = recordTypeId;
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Affected_Person__c.isCreateable()){
        			requestObj.NGMCP_Affected_Person__c = (String) payload.get('ngme_consname');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Enquiry_Category__c.isCreateable()){
        			requestObj.NGMCP_Enquiry_Category__c = (String) payload.get('reason'); //categoryCodeMap.containsKey((String) payload.get('reason')) ? categoryCodeMap.get((String) payload.get('reason')) : '';
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_LocationsId__c.isCreateable()){
        			requestObj.NGMCP_LocationsId__c = (String) payload.get('loccode');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Building_Name__c.isCreateable()){
        			requestObj.NGMCP_Building_Name__c = (String) payload.get('bldgname');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Market_Sector_Code__c.isCreateable()){
        			requestObj.NGMCP_Market_Sector_Code__c = (String) payload.get('sectorcode');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Street__c.isCreateable()){
        			requestObj.NGMCP_Street__c = (String) payload.get('street');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Supplier_Id__c.isCreateable()){
        			requestObj.NGMCP_Supplier_Id__c = (String) payload.get('supplier');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Notification_Type__c.isCreateable()){
        			requestObj.NGMCP_Notification_Type__c = (String) payload.get('notif_type');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Risk_Assessment__c.isCreateable()){
        			requestObj.NGMCP_Risk_Assessment__c = (String) payload.get('ngme_riskassess');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Postal_Town__c.isCreateable()){
        			requestObj.NGMCP_Postal_Town__c = (String) payload.get('posttown');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Affected_Person_Title__c.isCreateable()){
        			requestObj.NGMCP_Affected_Person_Title__c = (String) payload.get('ngme_constitle');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Enquiry_Description__c.isCreateable()){
        			requestObj.NGMCP_Enquiry_Description__c = (String) payload.get('description_longdescription');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Engineer_Visit__c.isCreateable()){
        			requestObj.NGMCP_Engineer_Visit__c = (String) payload.get('ngme_engvisit');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Target_Start__c.isCreateable()){
                    
        			requestObj.NGMCP_Target_Start__c =(String) payload.get('targetstart'); //formatToDDMMYYYY((String) payload.get('targetstart'));
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Postal_Code__c.isCreateable()){
        			requestObj.NGMCP_Postal_Code__c = (String) payload.get('postcode');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Time__c.isCreateable()){
        			requestObj.NGMCP_Time__c = (String) payload.get('ngme_time');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Affectedphone__c.isCreateable()){
        			requestObj.NGMCP_Affectedphone__c = (String) payload.get('ngme_consphone');//affectedphone
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Dependent_Locality__c.isCreateable()){
        			requestObj.NGMCP_Dependent_Locality__c = (String) payload.get('deplocal');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Above_Threshold__c.isCreateable()){
        			requestObj.NGMCP_Above_Threshold__c = (String) payload.get('ngme_threshold');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_MPRN__c.isCreateable()){
        			requestObj.NGMCP_MPRN__c = (String) payload.get('location');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Ngme_ConseMail__c.isCreateable()){
        			requestObj.NGMCP_Ngme_ConseMail__c = (String) payload.get('ngme_consemail');//reportedemail
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Reported_Email__c.isCreateable()){
        			requestObj.NGMCP_Reported_Email__c = reportedEmail;
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Enquiry_Type__c.isCreateable()){
        			requestObj.NGMCP_Enquiry_Type__c = (String) payload.get('category') == 'TQUERY' ? 'Technical Query' : 'Data Query';
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Enquiry_Reason_Code__c.isCreateable()){
        			requestObj.NGMCP_Enquiry_Reason_Code__c = (String) payload.get('subcategory');//reasonCodeMap.containsKey((String) payload.get('subcategory')) ? reasonCodeMap.get((String) payload.get('subcategory')) : '';
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Callout_Status__c.isCreateable()){
        			requestObj.NGMCP_Callout_Status__c = 'In Progress';
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_API_Callout__c.isCreateable()){
        			requestObj.NGMCP_API_Callout__c = 'Create Enquiry callout';
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Target_Finish_Date__c.isCreateable()){
        			requestObj.NGMCP_Target_Finish_Date__c = (String) payload.get('category') == 'TQUERY' ? addWorkingDays(date.today(), 20, NGMCP_HolidaysService.getHolidaysBetween()) : '';
        		}
                
            
                NGMCP_Enquiry_Code__mdt ec = [Select Id,NGMCP_Enquiry_Sub_Category_Code__c,NGMCP_Enquiry_Sub_Category__c, 
                                              NGMCP_Enquiry_Reason__c, NGMCP_Enquiry_Reason_Code__c
                                                 FROM NGMCP_Enquiry_Code__mdt
                                             WHERE NGMCP_Enquiry_Sub_Category_Code__c =: (String) payload.get('subcategory') AND
                                             NGMCP_Enquiry_Reason_Code__c =: (String) payload.get('reason')
                                             with user_mode
                                             LIMIT 1];
                if(ec != null){
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Enquiry_Category_Description__c.isCreateable()){
        				requestObj.NGMCP_Enquiry_Category_Description__c = ec.NGMCP_Enquiry_Reason__c;
        			}
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Enquiry_Reason_Description__c.isCreateable()){
        				requestObj.NGMCP_Enquiry_Reason_Description__c = ec.NGMCP_Enquiry_Sub_Category__c;
        			}
                    
                }
                if(meterDetails!=null){
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Model__c.isCreateable()){
        				requestObj.NGMCP_Model__c = meterDetails.NGMCP_Model__c;
        			}
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Manufacturer_Serial_No__c.isCreateable()){
        				requestObj.NGMCP_Manufacturer_Serial_No__c = meterDetails.NGMCP_Manufacturer_Serial_No__c;
        			}
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Meter_Type__c.isCreateable()){
        				requestObj.NGMCP_Meter_Type__c = meterDetails.NGMCP_Meter_Type__c;
        			}
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Payment_Mechanism__c.isCreateable()){
        				requestObj.NGMCP_Payment_Mechanism__c = meterDetails.NGMCP_Payment_Mechanism__c;
        			}
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Year_of_Manufacture__c.isCreateable()){
        				requestObj.NGMCP_Year_of_Manufacture__c = meterDetails.NGMCP_Year_of_Manufacture__c;
        			}
                    
                }
                requestObjList.add(requestObj);
            }
            if (!requestObjList.isEmpty() && Schema.sObjectType.NGMCP_Request__c.isCreateable()) {
                insert requestObjList;
            }
            return requestObjList[0].Id;
            }
            catch(Exception e){
                System.debug('Error at create query: '+e);
                throw new AuraHandledException('Error at create query: '+e);
            }
        }

        /**
     * @method getAllEnquiryCodes
     * @description Fetch all the records from NGMCP_Enquiry_Code__mdt
     * @return List<NGMCP_Enquiry_Code__mdt> - List of all NGMCP_Enquiry_Code__mdt records
     */
    
    @AuraEnabled
    public static List<NGMCP_Enquiry_Code__mdt> getAllEnquiryCodes() {
        return [SELECT DeveloperName, MasterLabel, NGMCP_Enquiry_Category__c,
        NGMCP_Enquiry_Category_Code__c, NGMCP_Enquiry_Reason__c, NGMCP_Description__c,
        NGMCP_Enquiry_Reason_Code__c, NGMCP_Enquiry_Sub_Category__c,
        NGMCP_Enquiry_Sub_Category_Code__c, NGMCP_Notification_Type__c
        FROM NGMCP_Enquiry_Code__mdt with user_mode];
    }

	public static String addWorkingDays(Date startDate, Integer workingDays, List<Date> holidays) {
        if (startDate == null) {
            throw new IllegalArgumentException('startDate is required');
        }
        if (workingDays == null || workingDays < 0) {
            throw new IllegalArgumentException('workingDays must be >= 0');
        }

        // Defensive copy
        List<Date> hol = (holidays == null) ? new List<Date>() : holidays.clone();

        Date cursor = startDate;
        Integer added = 0;
        while (added < workingDays) {
            cursor = cursor.addDays(1);
            if (isBusinessDay(cursor, hol)) {
                added++;
            }
        }
        String[] cursorList = cursor.toString().split(' ');
        return cursorList[0];
    }

    public static Boolean isBusinessDay(Date d, List<Date> holidays) {
        Integer dow = dayOfWeekSunday1(d);   // 1=Sun ... 7=Sat
        Boolean isWeekend = (dow == 1 || dow == 7);
        Boolean isHoliday = (holidays != null && holidays.contains(d));
        return !isWeekend && !isHoliday;
    }

    // Integer-only Zeller helper
    private static Integer dayOfWeekSunday1(Date d) {
        Integer y = d.year();
        Integer m = d.month();
        Integer q = d.day();

        if (m <= 2) { m += 12; y -= 1; }

        Integer K = Math.mod(y, 100);
        Integer J = (Integer)Math.floor(y / 100);

        Integer term1 = (13 * (m + 1)) / 5;
        Integer term2 = K / 4;
        Integer term3 = J / 4;

        Integer h = Math.mod((q + term1 + K + term2 + term3 + (5 * J)), 7); // 0=Sat, 1=Sun, 2=Mon, ..., 6=Fri
        return (h == 0) ? 7 : h; // 1..7, with 1=Sun, 7=Sat
    }
    

public static String formatToDDMMYYYY(String isoDate) {
        if (String.isBlank(isoDate)) return '';
        try {
            Date d = Date.valueOf(isoDate);
            
            // Manual formatting to avoid locale issues
            return String.valueOf(d.day()).leftPad(2, '0') + '/' +
            String.valueOf(d.month()).leftPad(2, '0') + '/' +
            String.valueOf(d.year());

            // Or use DateTime if you prefer pattern formatting:
            // DateTime dt = DateTime.newInstance(d, Time.newInstance(0,0,0,0));
            // return dt.format('dd/MM/yyyy');
        } catch (Exception e) {
            return '';
        }
    }


}