public with sharing class NGMCP_AMRBulkController {
    
    public static Map<String, String> actionModeMap = new Map<String, String>{
        'AMR-STRT' => 'Customer,Trans Ref,Contract Ref,Job Type,MPRN,Service Level,Site Contact,Contact Mechanism Value,Access Instructions,MAM ID,Building Number,Building Name,Street,Dependent Locality,Post Town,Post Code,Meter Manufacturer,Meter Model,Meter YOM,Meter Serial Number,Meter Dials,Meter Unit Of Measure,Converter Fitted Indicator',
        'AMR-RMVE' => 'Customer,Trans Ref,Contract Ref,Job Type,MPRN,Service Level,Site Contact,Contact Mechanism Value,Access Instructions,MAM ID,Building Number,Building Name,Street,Dependent Locality,Post Town,Post Code,Meter Manufacturer,Meter Model,Meter YOM,Meter Serial Number,Meter Dials,Meter Unit Of Measure,Converter Fitted Indicator,AMR Serial Number',
        'AMR-STOP' => 'Customer,Trans Ref,Contract Ref,Job Type,MPRN,Service Level,Site Contact,Contact Mechanism Value,Access Instructions,MAM ID,Building Number,Building Name,Street,Dependent Locality,Post Town,Post Code,Meter Manufacturer,Meter Model,Meter YOM,Meter Serial Number,Meter Dials,Meter Unit Of Measure,Converter Fitted Indicator,AMR Serial Number',
        'AMR-SVST' => 'Customer,Trans Ref,Contract Ref,Job Type,MPRN,Service Level,Site Contact,Contact Mechanism Value,Access Instructions,MAM ID,Building Number,Building Name,Street,Dependent Locality,Post Town,Post Code,Meter Manufacturer,Meter Model,Meter YOM,Meter Serial Number,Meter Dials,Meter Unit Of Measure,Converter Fitted Indicator,AMR Serial Number',
        'Deappointment-COS' => 'MPRN,Supplier short code,Request Type,Appointment Type,Effective Date,New Supplier Short Code,Market sector code',
        'Deappointment-CA' => 'MPRN,Supplier short code,Request Type,Appointment Type,Effective Date,New MAM Code,Market sector code',
        'Deappointment-DE' => 'MPRN,Supplier short code,Request Type,Appointment Type,Effective Date',
        'Deappointment-DEMO' => 'MPRN,Supplier short code,Request Type,Appointment Type,Effective Date',
        'Deappointment-COT' => 'MPRN,Supplier short code,Request Type,Appointment Type,Effective Date',
        'Deappointment-CM' => 'MPRN,Supplier short code,Request Type,Appointment Type,Effective Date',
        'Deappointment-DPL' => 'MPRN,Supplier short code,Request Type,Appointment Type,Effective Date',
        'Deappointment-EOT' => 'MPRN,Supplier short code,Request Type,Appointment Type,Effective Date',
        'Appointment-COS' => 'MPRN,Supplier short code,Request Type,Appointment Type,Effective Date',
        'Appointment-FIX' => 'MPRN,Supplier short code,Request Type,Appointment Type,Effective Date,Building Number,Building Name,Dependant Locality,Street,Postal Town,Postal Code',
        'Appointment-CA' => 'MPRN,Supplier short code,Request Type,Appointment Type,Effective Date,Building Number,Building Name,Dependant Locality,Street,Postal Town,Postal Code',
        'Appointment-NEWCN' => 'MPRN,Supplier short code,Request Type,Appointment Type,Effective Date,Building Number,Building Name,Dependant Locality,Street,Postal Town,Postal Code',
        'Appointment-FNDAS' => 'MPRN,Supplier short code,Request Type,Appointment Type,Effective Date,Building Number,Building Name,Dependant Locality,Street,Postal Town,Postal Code,Manufacturer,Meter Model,Year of manufacture,Manufacturer serial number,Payment Type,Meter type,Location code,No. of digit,Multiplication factor'
    };

    @AuraEnabled
    public static Id startBulkProcess(String payloadJson, String action, String mode, Id user) {
        System.debug('payloadJson: ' + payloadJson);
        if (String.isBlank(payloadJson)) {
            throw new AuraHandledException('No records provided.');
        }
        
        List<Object> raw = (List<Object>) JSON.deserializeUntyped(payloadJson);
        List<Map<String, Object>> rows = new List<Map<String, Object>>();
        for (Object o : raw) rows.add((Map<String, Object>)o);
        System.debug('rows: ' + rows);
        System.debug('action: ' + action);
        System.debug('mode: ' + mode);
        System.debug('user: ' + user);
        String[] inputFields;
        if(actionModeMap.containsKey(action + '-' + mode)){
            inputFields = actionModeMap.get(action + '-' + mode).split(',');
        }
        System.debug('inputFields: ' + inputFields);
        List<NGMCP_Bulk_Request__c> brList = new List<NGMCP_Bulk_Request__c>();
        Integer counter = 2;
        for (Map<String, Object> r : rows) {
            System.debug('r: ' + r);
            NGMCP_Bulk_Request__c rec = new NGMCP_Bulk_Request__c();
            rec.NGMCP_Input_CSV_Row_Number__c = counter;
            String missingField = '';
            for(String field : inputFields){
                if(r.get(field) == null || r.get(field) == '') {
                    missingField = missingField == '' ? field + ',' : missingField + field + ',';
                    
                }
            }
            missingField = missingField == '' ? '' : missingField.removeEnd(',');
            System.debug('missingField: ' + missingField);
            if(missingField == '' && action == 'AMR'){
                System.debug('Inside AMR if');
                rec.NGMCP_Callout_Type__c = action;
                rec.NGMCP_Callout_Sub_Type__c = mode;
                rec.NGMCP_Status__c = 'Pending';
                rec.NGMCP_Customer__c = (String)r.get('Customer');
                rec.NGMCP_Trans_Ref__c = (String)r.get('Trans Ref');
                rec.NGMCP_Contract_Ref__c = (String)r.get('Contract Ref');
                rec.NGMCP_Job_Type__c = (String)r.get('Job Type') == 'STRT' || (String)r.get('Job Type') == 'SVST' || 
                    (String)r.get('Job Type') == 'STOP' || (String)r.get('Job Type') == 'RMVE' ? (String)r.get('Job Type') : '' ;
                rec.NGMCP_MPRN__c = (String)r.get('MPRN');
                rec.NGMCP_Service_Level__c = (String)r.get('Service Level');
                //rec.NGMCP_Alarm_Req__c = (String)r.get('Alarm Req');
                //rec.NGMCP_High__c = (String)r.get('High');
                //rec.NGMCP_Low__c = (String)r.get('Low');
                //rec.NGMCP_Period__c = (String)r.get('Period');
                //rec.NGMCP_Alarm_Notification__c = (String)r.get('Alarm Notification');
                //rec.NGMCP_Upfront_Payment__c = (String)r.get('Upfront Payment');
                //rec.NGMCP_AQ_KWH__c = (String)r.get('AQ (KWH)');
                //rec.NGMCP_Site_Name__c = (String)r.get('Site Name');
                rec.NGMCP_Site_Contact__c = (String)r.get('Site Contact');
                rec.NGMCP_Contact_Mechanism_Value__c = (String)r.get('Contact Mechanism Value');
                //rec.NGMCP_DM_logger_ind__c = (String)r.get('DM logger ind');
                //rec.NGMCP_Prime_or_Sub__c = (String)r.get('Prime or Sub');
                rec.NGMCP_Access_Instructions__c = (String)r.get('Access Instructions');
                //rec.NGMCP_Effective_date__c = (String)r.get('Effective date');
                rec.NGMCP_Effective_date__c = String.valueOf(Date.today());
                //rec.NGMCP_Opening_read_required__c = (String)r.get('Opening read required');
                rec.NGMCP_MAM_ID__c = (String)r.get('MAM ID');
                rec.NGMCP_Building_Number__c = (String)r.get('Building Number');
                rec.NGMCP_Building_Name__c = (String)r.get('Building Name');
                rec.NGMCP_Street__c = (String)r.get('Street');
                rec.NGMCP_Dependent_Locality__c = (String)r.get('Dependent Locality');
                rec.NGMCP_Post_Town__c = (String)r.get('Post Town');
                rec.NGMCP_Post_Code__c = (String)r.get('Post Code');
                
                List<String> parts = new List<String>();
                for (String s : new String[]{ (String)r.get('Building Number'), (String)r.get('Building Name'), (String)r.get('Street'), (String)r.get('Dependent Locality'), (String)r.get('Post Town'), (String)r.get('Post Code') }) {
                    if (!String.isBlank(s)) {
                        parts.add(s.trim());
                    }
                }
                String result = String.join(parts, ',');

                rec.NGMCP_Address__c = result;
                //rec.NGMCP_Correction_Factor__c = (String)r.get('Correction Factor');
                rec.NGMCP_Meter_Manufacturer__c = (String)r.get('Meter Manufacturer');
                rec.NGMCP_Meter_Model__c = (String)r.get('Meter Model');
                rec.NGMCP_Meter_YOM__c = (String)r.get('Meter YOM');
                rec.NGMCP_Meter_Serial_Number__c = (String)r.get('Meter Serial Number');
                rec.NGMCP_Meter_Dials__c = (String)r.get('Meter Dials');
                rec.NGMCP_Meter_Unit_Of_Measure__c = (String)r.get('Meter Unit Of Measure');
                //rec.NGMCP_Meter_reading_Factor__c = (String)r.get('Meter reading Factor');
                rec.NGMCP_Converter_Fitted_Indicator__c = (String)r.get('Converter Fitted Indicator');
                //rec.NGMCP_Converter_Serial_Number__c = (String)r.get('Converter Serial Number');
                //rec.NGMCP_Converter_Dials__c = (String)r.get('Converter  Dials');
                //rec.NGMCP_Converter_Reading_Factor__c = (String)r.get('Converter Reading Factor');
                //rec.NGMCP_Site_Contact_Email__c = (String)r.get('Site Contact Email');
                rec.NGMCP_AMR_Serial_Number__c = mode == 'STRT' ? '' : (String)r.get('AMR Serial Number');
                rec.NGMCP_Response__c = (String)r.get('Job Type') == 'STRT' || (String)r.get('Job Type') == 'SVST' || 
                    (String)r.get('Job Type') == 'STOP' || (String)r.get('Job Type') == 'RMVE' ? '' :
                'Please enter correct job type';
            }
            else if(missingField == '' && (action == 'Deappointment' || action == 'Appointment')){
                System.debug('Inside Appnt/Deapp else if');
                rec.NGMCP_Callout_Type__c = action;
                rec.NGMCP_Callout_Sub_Type__c = mode;
                rec.NGMCP_Status__c = 'Pending';
                rec.NGMCP_MPRN__c = (String)r.get('MPRN');
                rec.NGMCP_Customer__c = (String)r.get('Supplier short code');
                rec.NGMCP_Request_Type__c = (String)r.get('Request Type');
                rec.NGMCP_Appointment_Type__c = (String)r.get('Appointment Type');
                rec.NGMCP_Effective_date__c = toYYYYMMDD((String)r.get('Effective Date'));
                rec.NGMCP_New_Supplier_Short_Code__c = (String)r.get('New Supplier Short Code');
                rec.NGMCP_Market_Sector_Code__c = (String)r.get('Market sector code');
                rec.NGMCP_Contract_Ref__c = NGMCP_AppointmentDeappointmentHandler.getSupplierInfo((String) r.get('Supplier short code')) != null ? NGMCP_AppointmentDeappointmentHandler.getSupplierInfo((String) r.get('Supplier short code')).NGMCP_Rental_Contract__c : '';
                if(rec.NGMCP_Contract_Ref__c == '' || rec.NGMCP_Contract_Ref__c == null){
                    rec.NGMCP_Response__c = 'Contract Reference is not available for this Supplier short code';
                }
                rec.NGMCP_New_MAM_Code__c = (String)r.get('New MAM Code');
                rec.NGMCP_Building_Number__c = (String)r.get('Building Number');
                rec.NGMCP_Building_Name__c = (String)r.get('Building Name');
                rec.NGMCP_Street__c = (String)r.get('Street');
                rec.NGMCP_Dependent_Locality__c = (String)r.get('Dependant Locality');
                rec.NGMCP_Post_Town__c = (String)r.get('Postal Town');
                rec.NGMCP_Post_Code__c = (String)r.get('Postal Code');
                rec.NGMCP_Meter_Manufacturer__c = (String)r.get('Manufacturer');
                rec.NGMCP_Meter_Model__c = (String)r.get('Meter Model');
                rec.NGMCP_Meter_YOM__c = (String)r.get('Year of manufacture');
                rec.NGMCP_Meter_Serial_Number__c = (String)r.get('Manufacturer serial number');
                rec.NGMCP_Payment_Type__c = (String)r.get('Payment Type');
                rec.NGMCP_Meter_type__c = (String)r.get('Meter type');
                rec.NGMCP_Location_code__c = (String)r.get('Location code');
                rec.NGMCP_No_of_digit__c = (String)r.get('No. of digit');
                rec.NGMCP_Multiplication_factor__c = (String)r.get('Multiplication factor');
				rec.NGMCP_Meter_Unit_Of_Measure__c = (String)r.get('Unit of measure');
            }
            else{
                System.debug('Inside else');
                rec.NGMCP_Response__c = 'Contains following missing fields: ' + missingField;
            }
            System.debug('rec: ' + rec);
            brList.add(rec);
            counter = counter + 1;
        }
        System.debug('brList: ' + brList);
        //return user;
        
        // Kick off Batch #1 (for bulk insert + chaining)
        NGMCP_BulkRequestBatch b1 = new NGMCP_BulkRequestBatch(brList, action, mode, user);
        // scope 200 is fine for DML; adjust if you have many before triggers
        return Database.executeBatch(b1, 90); 
        
    }
	
    public static String buildCsv(List<Id> brIds) {

        List<List<String>> matrix = new List<List<String>>();
       
       
       	matrix.add(new List<String>{'Row Number','MPRN','Success or Failure','NGM Reference Number'});
        List<NGMCP_Bulk_Request__c> rows = [Select Id, Name, NGMCP_Response__c,NGMCP_Input_CSV_Row_Number__c,NGMCP_MPRN__c,NGMCP_Service_Request_Number__c FROM NGMCP_Bulk_Request__c WHERE Id in: brIds];
        
        for (NGMCP_Bulk_Request__c r : rows) {
            matrix.add(new List<String>{
                
                r.NGMCP_Input_CSV_Row_Number__c.toString(),
                r.NGMCP_MPRN__c,
                r.NGMCP_Response__c,
                r.NGMCP_Service_Request_Number__c
            });
        }
        System.debug('matrix: '+ matrix);
        return toCsv(matrix);
    }

    private static String toCsv(List<List<String>> rows) {
        List<String> lines = new List<String>();
        for (List<String> r : rows) lines.add( rowToCsv(r) );
        System.debug('toCsv: '+ String.join(lines, '\n'));
        return String.join(lines, '\n');
    }

    private static String rowToCsv(List<String> cols) {
        List<String> out = new List<String>();
        for (String c : cols) out.add(escapeCsv(c));
        return String.join(out, ',');
    }

    private static String escapeCsv(String s) {
        if (s == null) return '';
        Boolean mustQuote = s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r');
        String v = s.replace('"', '""');
        return mustQuote ? '"' + v + '"' : v;
    }
	
    public static String toYYYYMMDD(String inputDate) {
        if (String.isBlank(inputDate)) {
            return null;
        }

        inputDate = inputDate.trim();
        Date d;

        try {
            // yyyy-MM-dd
            if (Pattern.matches('\\d{4}-\\d{2}-\\d{2}', inputDate)) {
                d = Date.valueOf(inputDate);
            }
            // dd/MM/yyyy or dd-MM-yyyy
            else if (Pattern.matches('\\d{2}[/-]\\d{2}[/-]\\d{4}', inputDate)) {
                List<String> parts = inputDate.split('[/-]');
                d = Date.newInstance(
                    Integer.valueOf(parts[2]), // year
                    Integer.valueOf(parts[1]), // month
                    Integer.valueOf(parts[0])  // day
                );
            }
            else {
                return null;
            }

            DateTime dt = DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0));
            return dt.format('yyyyMMdd');
        }
        catch (Exception e) {
            return null;
        }
    }
    
    @AuraEnabled
    public static Id uploadFile(String fileName, String base64Data, String shortCode, String action) {

        NGMCP_Request__c record = new NGMCP_Request__c();
        record.NGMCP_Job_Type__c = 'Other Visits';
        record.NGMCP_Job_SubType__c = action;
        record.NGMCP_Supplier_Id__c = shortCode;
        
        Id cwrRTId = Schema.SObjectType.NGMCP_Request__c.getRecordTypeInfosByName().get('Customer Work Request').getRecordTypeId();
        record.RecordTypeId = cwrRTId;
        record.NGMCP_Status__c = 'Submitted';
        insert record;

        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.FirstPublishLocationId = record.Id;
        insert cv;
        return record.Id;
    }



}