public with sharing class NGMCP_AMRBulkCreationBatch implements Database.Batchable<SObject>, 
Database.Stateful, Database.AllowsCallouts {

    // Inputs
    private List<Id> primaryIds;
    private Id user;
    private String mode;
    private String action;
	
    List<Id> brIds = new List<Id>();
    List<NGMCP_AMRQueueable.JobItem> items = new List<NGMCP_AMRQueueable.JobItem>();
    public NGMCP_AMRBulkCreationBatch(List<Id> primaryIds, String action, String mode, Id user) {
        this.primaryIds = primaryIds;
        this.user = user;
        this.action = action;
        this.mode = mode;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, NGMCP_Callout_Type__c, NGMCP_Callout_Sub_Type__c, NGMCP_Status__c,
            NGMCP_Customer__c, NGMCP_Trans_Ref__c, NGMCP_Response__c, NGMCP_Request_Id__c, NGMCP_Site_Contact_Email__c,
            NGMCP_Contract_Ref__c, NGMCP_Job_Type__c, NGMCP_MPRN__c, NGMCP_Service_Level__c, NGMCP_Alarm_Req__c,
            NGMCP_High__c, NGMCP_Low__c, NGMCP_Period__c, NGMCP_Alarm_Notification__c, NGMCP_Upfront_Payment__c,
            NGMCP_AQ_KWH__c, NGMCP_Site_Name__c, NGMCP_Site_Contact__c, NGMCP_Contact_Mechanism_Value__c,
            NGMCP_DM_logger_ind__c, NGMCP_Prime_or_Sub__c, NGMCP_Access_Instructions__c,
            NGMCP_Effective_date__c, NGMCP_Opening_read_required__c, NGMCP_MAM_ID__c, NGMCP_Address__c,
            NGMCP_Post_Town__c, NGMCP_Post_Code__c, NGMCP_Correction_Factor__c, NGMCP_Meter_Manufacturer__c,
            NGMCP_Meter_Model__c, NGMCP_Meter_YOM__c, NGMCP_Meter_Serial_Number__c, NGMCP_Meter_Dials__c,
            NGMCP_Meter_Unit_Of_Measure__c, NGMCP_Meter_reading_Factor__c,NGMCP_Converter_Fitted_Indicator__c,
            NGMCP_Converter_Serial_Number__c, NGMCP_Converter_Dials__c,NGMCP_Converter_Reading_Factor__c,
            NGMCP_Building_Number__c,NGMCP_Building_Name__c,NGMCP_Street__c,NGMCP_Dependent_Locality__c,
            NGMCP_AMR_Serial_Number__c
            FROM NGMCP_Bulk_Request__c
            WHERE Id IN :primaryIds
            with user_mode
            ORDER BY CreatedDate ASC 
            
        ]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<NGMCP_Bulk_Request__c> primaries = (List<NGMCP_Bulk_Request__c>)scope;

       	List<NGMCP_Bulk_Request__c> toUpdatePrimary = new List<NGMCP_Bulk_Request__c>();
        List<NGMCP_Request__c> secondariesToInsert = new List<NGMCP_Request__c>();
        Map<Id, NGMCP_Request__c> secondaryByPrimary = new Map<Id, NGMCP_Request__c>();
		User u = [Select id, email from user where id =: user];
        System.debug('user: '+ u);
        for (NGMCP_Bulk_Request__c req : primaries) {
            String bulkResponse = null;
            String finalStatus = null;
            Id createdRequestId = null;
            System.debug('req.NGMCP_Response__c: '+ req.NGMCP_Response__c);
            if(req.NGMCP_Response__c == '' || req.NGMCP_Response__c == null){
                NGMCP_AMRIntegrationClass.PayloadWrapper pw = new NGMCP_AMRIntegrationClass.PayloadWrapper();
               
                pw.p_Address = req.NGMCP_Address__c;
                pw.p_AlarmHigh = '';
                pw.p_AlarmLow = '';
                pw.p_AlarmNotification = '';
                pw.p_AlarmPeriod = '';
                pw.p_AlarmReq = 0;
                pw.p_AnnualQuantity = '1';
                pw.p_Comments = req.NGMCP_Access_Instructions__c;
                pw.p_contactNo = req.NGMCP_Contact_Mechanism_Value__c;
                pw.p_ContractRef = req.NGMCP_Contract_Ref__c;
                
                pw.p_ConverterFittedIndicator = req.NGMCP_Converter_Fitted_Indicator__c;
                
                pw.p_ConverterSerialNumber = '0';
                
                pw.p_CustomerCode = req.NGMCP_Customer__c;
                
                pw.p_EffectiveDate = req.NGMCP_Effective_date__c;
                
                pw.p_JobType = req.NGMCP_Job_Type__c == 'RMVE' ? 'STOP' : req.NGMCP_Job_Type__c;
                pw.p_MAMId = req.NGMCP_MAM_Id__c;
                pw.p_MeterDials = Integer.valueOf(req.NGMCP_Meter_Dials__c);
                pw.p_MeterManufacturer = req.NGMCP_Meter_Manufacturer__c;
                pw.p_MeterModel = req.NGMCP_Meter_Model__c;
                
                pw.p_MeterSerialNumber = req.NGMCP_Meter_Serial_Number__c;
                pw.p_MeterUnitofMeasure = req.NGMCP_Meter_Unit_Of_Measure__c;
                pw.p_MeterYOM = req.NGMCP_Meter_YOM__c;
                pw.p_MPRN = req.NGMCP_MPRN__c;
                
                pw.p_PostCode = req.NGMCP_Post_Code__c;
                pw.p_Posttown = req.NGMCP_Post_Town__c;
                
                pw.p_ServiceLevel = req.NGMCP_Service_Level__c;
                pw.p_SiteContact = req.NGMCP_Site_Contact__c;
                pw.p_SiteName = req.NGMCP_Building_Name__c;
                pw.p_TransactionRef = req.NGMCP_Trans_Ref__c;
                
                pw.p_Email = u.Email;
                pw.p_CreateReason = 'Request submitted from Portal';
                //default values
                pw.p_CorrectionFactor = 0;
                pw.p_MeterReadingFactor = 0;
                pw.p_ConverterDials = 0;
                pw.p_ConverterReadingFactor = 0;
                
                 
                String payload = JSON.serialize(pw);
                System.debug('Payload: '+payload);
                System.debug('req.NGMCP_Meter_Manufacturer__c: '+req.NGMCP_Meter_Manufacturer__c);
                System.debug('req.NGMCP_Meter_Model__c: '+req.NGMCP_Meter_Model__c);
                System.debug('req.NGMCP_Meter_YOM__c: '+req.NGMCP_Meter_YOM__c);
                System.debug('req.NGMCP_Meter_YOM__c int: '+Integer.valueOf(req.NGMCP_Meter_YOM__c));
                String pulsing = NGMCP_AmrPulsingService.getPulsing(req.NGMCP_Meter_Manufacturer__c, req.NGMCP_Meter_Model__c,Integer.valueOf(req.NGMCP_Meter_YOM__c));
                System.debug('pulsing before: '+pulsing);
                if(pulsing == '' || pulsing == null){
                    pulsing = 'YES';
                }
                System.debug('pulsing after: '+pulsing);
                try {
                    if((pulsing == 'YES' && mode == 'STRT') || mode == 'SVST' || mode == 'STOP' || mode == 'RMVE'){
                    	createdRequestId = NGMCP_AMRIntegrationClass.createAMR(payload, 'YES', '', null);
                        System.debug('createdRequestId: '+createdRequestId);
                    	finalStatus = 'In Progress';
                    	items.add(new NGMCP_AMRQueueable.JobItem(req, createdRequestId, payload, user,pulsing, ''));
                    }
                    else if (pulsing == 'NO' && mode == 'STRT'){
                        NGMCP_AMRIntegrationClass.TQPayloadWrapper tqpw = new NGMCP_AMRIntegrationClass.TQPayloadWrapper();
                        tqpw.ngme_consname = req.NGMCP_Site_Contact__c;
                        tqpw.reason = 'MUOP';
                        tqpw.loccode = '';
                        tqpw.bldgname = req.NGMCP_Site_Name__c;
                        tqpw.sectorcode = 'I';//req.NGMCP_Market_Sector_Code__c;
                        tqpw.street = 'Street';//req.NGMCP_Street__c;
                        tqpw.supplier = req.NGMCP_Customer__c;
                        tqpw.notif_type = 'TQ';
                        tqpw.ngme_riskassess = 'N';
                        tqpw.posttown = req.NGMCP_Post_Town__c;
                        tqpw.ngme_constitle = '';//req.NGMCP_Affected_Person_Title__c;
                        tqpw.description_longdescription = 'TQ auto created due to existing meter being identified as Non-Pulsing (following AMR Install request). Please review and raise the required GPS exchange job.';
                        tqpw.ngme_engvisit = 'N';
                        tqpw.targetstart = '';
                        tqpw.postcode = req.NGMCP_Post_Code__c;
                        tqpw.ngme_time = '';
                        tqpw.ngme_consphone = '1234';//req.NGMCP_Affectedphone__c;
                        tqpw.deplocal = 'Test';//req.NGMCP_Dependent_Locality__c;
                        tqpw.ngme_threshold = 'N';
                        tqpw.location = req.NGMCP_MPRN__c;
                        tqpw.ngme_consemail = req.NGMCP_Site_Contact_Email__c;
                        tqpw.reportedemail = UserInfo.getUserEmail();
                        tqpw.category = 'TQUERY';
                        tqpw.subcategory = 'MET';
                        System.debug('tqpw: '+tqpw);
                        String tqPayload = JSON.serialize(tqpw);
                        System.debug('tqPayload: '+tqPayload);       
                        createdRequestId = NGMCP_EnquiriesHandler.createDataQueryRecord(tqPayload, null, '');
						System.debug('createdRequestId: '+createdRequestId);
                    	finalStatus = 'In Progress';
                    	items.add(new NGMCP_AMRQueueable.JobItem(req, createdRequestId, payload, user, pulsing, tqPayload));
                    }
                } catch (Exception exCreate) {
                    bulkResponse = 'createAMR error: ' + exCreate.getMessage() + ' at line: ' + exCreate.getLineNumber();
                    System.debug('bulkResponse: '+bulkResponse);
                    finalStatus = 'Creation Failed';
                    items.add(new NGMCP_AMRQueueable.JobItem(req, null, payload, user, '', ''));
                }
                NGMCP_Bulk_Request__c upd = new NGMCP_Bulk_Request__c();
                if(Schema.sObjectType.NGMCP_Bulk_Request__c.fields.Id.isUpdateable()){
        			upd.Id = req.Id;
        		}
                if(Schema.sObjectType.NGMCP_Bulk_Request__c.fields.NGMCP_Status__c.isUpdateable()){
        			upd.NGMCP_Status__c = (finalStatus == null ? 'Pending' : finalStatus);
        		}
                if(Schema.sObjectType.NGMCP_Bulk_Request__c.fields.NGMCP_Request_Id__c.isUpdateable()){
        			upd.NGMCP_Request_Id__c = createdRequestId == null ? '' : createdRequestId;
        		}
                if(Schema.sObjectType.NGMCP_Bulk_Request__c.fields.NGMCP_Response__c.isUpdateable()){
        			upd.NGMCP_Response__c = req.NGMCP_Response__c != '' && req.NGMCP_Response__c == null ? upd.NGMCP_Response__c : bulkResponse;
        		}
                
                brIds.add(upd.Id);
               System.debug('upd: '+ upd);
                toUpdatePrimary.add(upd); 
            }
            else{
               items.add(new NGMCP_AMRQueueable.JobItem(req, null, '', user, '', ''));
            }
            /*
			if (createdRequestId != null) {
                try {
                    Object res = NGMCP_AMRIntegrationClass.submitAMR(payload, createdRequestId);
                    bulkResponse = res.toString();
                    finalStatus = 'Completed';
                } catch (Exception exSubmit) {
                    bulkResponse = 'submitAMR error: ' + exSubmit.getMessage() + ' at line: ' + exSubmit.getLineNumber();
                    finalStatus = 'Submission Failed';
                }
            }*/

        }
		System.debug('toUpdatePrimary: '+ toUpdatePrimary);
        if (!toUpdatePrimary.isEmpty() && Schema.sObjectType.NGMCP_Bulk_Request__c.isUpdateable()) {
            Database.update(toUpdatePrimary, /* allOrNone */ false);
        }
        System.debug('items: '+ items);
		if (!items.isEmpty()) {
          
			System.enqueueJob(new NGMCP_AMRQueueable(items,primaryIds, action, mode));
        }
		
    }

    public void finish(Database.BatchableContext bc) {
       

    }
}