public with sharing class NGMCP_AppntDeappQueueable implements Queueable {
    
    private List<Id> brIds;
    private Integer index;
    private String action;
    private String mode;
    private Id userId;

    public NGMCP_AppntDeappQueueable(
        List<Id> brIds,
        Integer index,
        String action,
        String mode,
        Id userId
    ) {
        this.brIds = brIds;
        this.index = index;
        this.action = action;
        this.mode = mode;
        this.userId = userId;
    }

    public void execute(QueueableContext qc) {
        if (index >= brIds.size()) {
            return;
        }

        NGMCP_Bulk_Request__c req;
        Id requestId;
        String payload;

        try {
            // Lock the row so only one queueable chain can process it
            req = [
                SELECT Id, Name, NGMCP_Callout_Type__c, NGMCP_Callout_Sub_Type__c, NGMCP_Status__c,
                       NGMCP_Customer__c, NGMCP_Trans_Ref__c, NGMCP_Response__c, NGMCP_Request_Id__c,
                       NGMCP_Site_Contact_Email__c, NGMCP_Contract_Ref__c, NGMCP_Job_Type__c,
                       NGMCP_MPRN__c, NGMCP_Service_Level__c, NGMCP_Alarm_Req__c, NGMCP_High__c,
                       NGMCP_Low__c, NGMCP_Period__c, NGMCP_Alarm_Notification__c,
                       NGMCP_Upfront_Payment__c, NGMCP_AQ_KWH__c, NGMCP_Site_Name__c,
                       NGMCP_Site_Contact__c, NGMCP_Contact_Mechanism_Value__c,
                       NGMCP_DM_logger_ind__c, NGMCP_Prime_or_Sub__c, NGMCP_Access_Instructions__c,
                       NGMCP_Effective_date__c, NGMCP_Opening_read_required__c, NGMCP_MAM_ID__c,
                       NGMCP_Address__c, NGMCP_Post_Town__c, NGMCP_Post_Code__c,
                       NGMCP_Correction_Factor__c, NGMCP_Meter_Manufacturer__c,
                       NGMCP_Meter_Model__c, NGMCP_Meter_YOM__c, NGMCP_Meter_Serial_Number__c,
                       NGMCP_Meter_Dials__c, NGMCP_Meter_Unit_Of_Measure__c,
                       NGMCP_Meter_reading_Factor__c, NGMCP_Converter_Fitted_Indicator__c,
                       NGMCP_Converter_Serial_Number__c, NGMCP_Converter_Dials__c,
                       NGMCP_Converter_Reading_Factor__c, NGMCP_Building_Number__c,
                       NGMCP_Building_Name__c, NGMCP_Street__c, NGMCP_Dependent_Locality__c,
                       NGMCP_AMR_Serial_Number__c, NGMCP_Request_Type__c, NGMCP_Appointment_Type__c,
                       NGMCP_New_Supplier_Short_Code__c, NGMCP_Market_Sector_Code__c,
                       NGMCP_New_MAM_Code__c, NGMCP_Payment_Type__c, NGMCP_Meter_type__c,
                       NGMCP_Location_code__c, NGMCP_No_of_digit__c, NGMCP_Multiplication_factor__c
                FROM NGMCP_Bulk_Request__c
                WHERE Id = :brIds[index]
                FOR UPDATE
            ];

            System.debug('Locked bulk request: ' + req);

            // If another chain has already processed / is processing this row, do nothing.
            if (isTerminalStatus(req.NGMCP_Status__c)) {
                System.debug('Skipping row because it is already terminal: ' + req.NGMCP_Status__c);
                return;
            }

            if (req.NGMCP_Request_Id__c != null || req.NGMCP_Status__c == 'In Progress') {
                System.debug('Skipping row because request already created or processing already started.');
                return;
            }

            // Build payload only after lock + idempotency guard
            NGMCP_AMRIntegrationClass.AppntDeappPayloadWrapper pw = new NGMCP_AMRIntegrationClass.AppntDeappPayloadWrapper();

            pw.ngme_trans = new NGMCP_AMRIntegrationClass.TransClass();
            pw.ngme_trans.ngme_mtpnt = new NGMCP_AMRIntegrationClass.MTPNTClass();
            pw.ngme_trans.ngme_mtpnt.ngme_mkprt = new NGMCP_AMRIntegrationClass.MKPRTClass();

            pw.ngme_file_type = 'ONAGE';
            pw.ngme_creation_date = Date.today().year() +
                String.valueOf(Date.today().month()).leftPad(2, '0') +
                String.valueOf(Date.today().day()).leftPad(2, '0');
            pw.ngme_originator_id = req.NGMCP_Customer__c;
            pw.ngme_recipient_role = 'MAM';
            pw.ngme_status = 'NEW';
            pw.ngme_transaction_count = 1;
            pw.ngme_integration_type = 'INBOUND';
            pw.ngme_creation_time = DateTime.now().format('HHmmss');
            pw.ngme_reqrecdate = Date.today().year() + '-' +
                String.valueOf(Date.today().month()).leftPad(2, '0') + '-' +
                String.valueOf(Date.today().day()).leftPad(2, '0');
            pw.ngme_record_count = 3;
            pw.ngme_record_identifier = 'HEADR';
            pw.ngme_recipient_id = 'GTM';
            pw.ngme_trans.ngme_reason_code = req.NGMCP_Appointment_Type__c;

            pw.ngme_trans.ngme_reference = req.NGMCP_MPRN__c;
            pw.ngme_trans.ngme_type_code = action == 'Appointment' ? 'APPNT' : 'DEAPP';
            pw.ngme_trans.ngme_sector_code =
                String.isBlank(req.NGMCP_Market_Sector_Code__c) ? 'I' : req.NGMCP_Market_Sector_Code__c;
            pw.ngme_trans.ngme_record_identifier = 'TRANS';
            pw.ngme_trans.ngme_contract_ref = req.NGMCP_Contract_Ref__c;
            pw.ngme_trans.ngme_mtpnt.ngme_record_identifier = 'MTPNT';
            pw.ngme_trans.ngme_mtpnt.ngme_mkprt.ngme_record_identifier = 'MKPRT';

            if (action == 'Appointment') {
                pw.ngme_trans.ngme_mtpnt.ngme_mkprt.ngme_role_code = 'MAM';
                pw.ngme_trans.ngme_mtpnt.ngme_mkprt.ngme_abbrv_name = 'GTM';
            } else {
                pw.ngme_trans.ngme_mtpnt.ngme_mkprt.ngme_role_code =
                    mode == 'COS' ? 'SUP' : mode == 'CA' ? 'MAM' : 'MAM';
                pw.ngme_trans.ngme_mtpnt.ngme_mkprt.ngme_abbrv_name =
                    mode == 'COS' ? req.NGMCP_New_Supplier_Short_Code__c :
                    mode == 'CA' ? req.NGMCP_New_MAM_Code__c : 'GTM';
            }

            pw.ngme_trans.ngme_mtpnt.ngme_link_code = 'F';
            pw.ngme_trans.ngme_mtpnt.ngme_referencenum = req.NGMCP_MPRN__c;
            pw.ngme_originator_role = 'SUP';
            pw.ngme_file_identifier = 'AP' + Math.abs(Math.round(Math.random() * 100000000));
            pw.ngme_recipient_id = 'GTM';
            pw.ngme_source_system = 'PORTAL';
            pw.ngme_file_usage_code = 'PRDCT';

            if (action == 'Appointment') {
                pw.ngme_trans.ngme_from_date = req.NGMCP_Effective_date__c;
            } else {
                pw.ngme_trans.ngme_to_date = req.NGMCP_Effective_date__c;
            }

            if (action == 'Appointment' && (mode == 'FIX' || mode == 'FNDAS')) {
                pw.ngme_trans.ngme_mtpnt.ngme_addrs = new NGMCP_AMRIntegrationClass.ADDRSClass();
                pw.ngme_trans.ngme_mtpnt.ngme_addrs.ngme_type_code = 'MTRPT';
                pw.ngme_trans.ngme_mtpnt.ngme_addrs.ngme_record_identifier = 'ADDRS';
                pw.ngme_trans.ngme_mtpnt.ngme_addrs.ngme_sub_building_no = '';
                pw.ngme_trans.ngme_mtpnt.ngme_addrs.ngme_building_no = req.NGMCP_Building_Number__c;
                pw.ngme_trans.ngme_mtpnt.ngme_addrs.ngme_dependent_through = '';
                pw.ngme_trans.ngme_mtpnt.ngme_addrs.ngme_throughfare = req.NGMCP_Street__c;
                pw.ngme_trans.ngme_mtpnt.ngme_addrs.ngme_double_locality = '';
                pw.ngme_trans.ngme_mtpnt.ngme_addrs.ngme_dependent_locality = req.NGMCP_Dependent_Locality__c;
                pw.ngme_trans.ngme_mtpnt.ngme_addrs.ngme_post_town = req.NGMCP_Post_Town__c;
                pw.ngme_trans.ngme_mtpnt.ngme_addrs.ngme_county = '';
                pw.ngme_trans.ngme_mtpnt.ngme_addrs.ngme_post_code = req.NGMCP_Post_Code__c;
            }

            if (mode == 'FNDAS') {
                pw.ngme_trans.ngme_mtpnt.ngme_asset = new NGMCP_AMRIntegrationClass.AssetClass();
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_meter = new NGMCP_AMRIntegrationClass.MeterClass();
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_regst = new NGMCP_AMRIntegrationClass.REGSTClass();
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_record_identifier = 'ASSET';
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_pay_method_code =
                    req.NGMCP_Payment_Type__c == 'Credit' ? 'CR' : 'PP';
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_trans_type_code = 'APPNT';
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_class_code = 'METER';
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_model_code = req.NGMCP_Meter_Model__c;
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_manufacture_code = 'ACT';
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_manufacture_year = req.NGMCP_Meter_YOM__c;
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_serial_no = req.NGMCP_Meter_Serial_Number__c;
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_location_code = req.NGMCP_Location_code__c;
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_location_notes = '';
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_status_code = 'LI';

                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_meter.ngme_record_identifier = 'METER';
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_meter.ngme_type_code =
                    req.NGMCP_Meter_type__c != null && req.NGMCP_Meter_type__c.toLowerCase() == 'diaphragm' ? 'D' :
                    req.NGMCP_Meter_type__c != null && req.NGMCP_Meter_type__c.toLowerCase() == 'rotary displacement' ? 'R' :
                    req.NGMCP_Meter_type__c != null && req.NGMCP_Meter_type__c.toLowerCase() == 'diaphragm - synthetic' ? 'S' :
                    req.NGMCP_Meter_type__c != null && req.NGMCP_Meter_type__c.toLowerCase() == 'turbine' ? 'T' :
                    req.NGMCP_Meter_type__c != null && req.NGMCP_Meter_type__c.toLowerCase() == 'ultrasonic' ? 'U' :
                    req.NGMCP_Meter_type__c != null && req.NGMCP_Meter_type__c.toLowerCase() == 'other' ? 'Z' : 'Z';

                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_meter.ngme_mechanism_code =
                    req.NGMCP_Payment_Type__c == 'Credit' ? 'CR' : 'PP';
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_meter.ngme_measure_capacity = 0;
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_meter.ngme_status_code = '';

                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_regst.ngme_record_identifier = 'REGST';
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_regst.ngme_type_code = 'METER';
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_regst.ngme_no_of_digit = req.NGMCP_No_of_digit__c != null ?
                    Integer.valueOf(req.NGMCP_No_of_digit__c) : 0;
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_regst.ngme_measure_unit = '';
                pw.ngme_trans.ngme_mtpnt.ngme_asset.ngme_regst.ngme_multiplication_factor = req.NGMCP_Multiplication_factor__c != null ?
                    Integer.valueOf(req.NGMCP_Multiplication_factor__c) : 0;
            }

            payload = JSON.serialize(pw);

            // Create request exactly once
            requestId = NGMCP_AppointmentDeappointmentHandler.createAppntDeappntRecord(payload);

            update new NGMCP_Bulk_Request__c(
                Id = req.Id,
                NGMCP_Status__c = 'In Progress',
                NGMCP_Request_Id__c = requestId
            );

            System.enqueueJob(
                new NGMCP_AppntDeappCalloutQueueable(
                    brIds,
                    index,
                    requestId,
                    payload,
                    action,
                    mode,
                    userId
                )
            );

        } catch (Exception e) {
            System.debug('Queueable creation error: ' + e.getMessage() + ' @line ' + e.getLineNumber());

            if (req != null) {
                update new NGMCP_Bulk_Request__c(
                    Id = req.Id,
                    NGMCP_Status__c = 'Creation Failed',
                    NGMCP_Response__c = e.getMessage()
                );
            }

            // move to next only for true failure, not duplicate processing skip
            System.enqueueJob(
                new NGMCP_AppntDeappQueueable(
                    brIds,
                    index + 1,
                    action,
                    mode,
                    userId
                )
            );
        }
    }

    private static Boolean isTerminalStatus(String status) {
        return status == 'Completed' ||
               status == 'Failed' ||
               status == 'Creation Failed';
    }
}