public with sharing class NGMCP_RequestTriggerHandler {
	
    //To submit On-Hold AMRs whenever it's related TQ/Stop AMR is Completed
    public static void submitOnHoldAMRs(List<NGMCP_Request__c> tqList, Map<Id,NGMCP_Request__c> tqMap){
        Set<String> srNumSet = new Set<String>();
        Map<String,String> srNumRecordTypeMap = new Map<String,String>();
        List<NGMCP_Request__c> amrList = new List<NGMCP_Request__c>();
        List<NGMCP_Request__c> enquiryList = new List<NGMCP_Request__c>();
        List<NGMCP_AMRNonPulsingSubmitQueueable.JobItem> jiList = new List<NGMCP_AMRNonPulsingSubmitQueueable.JobItem>();
        
		Id tqRTId = Schema.SObjectType.NGMCP_Request__c.getRecordTypeInfosByName().get('Enquiry').getRecordTypeId();
        Id amrRTId = Schema.SObjectType.NGMCP_Request__c.getRecordTypeInfosByName().get('AMR').getRecordTypeId();
        for(NGMCP_Request__c req : tqList){
            if(((req.recordTypeId == tqRTId && req.NGMCP_Enquiry_Type__c == 'Technical Query'  
              && (req.NGMCP_Status__c == 'Completed' || req.NGMCP_Status__c == 'Resolved')) ||
               (req.recordTypeId == amrRTId && req.NGMCP_Job_Type__c == 'STOP' &&
               req.NGMCP_Status__c == 'Completed')) 
               && req.NGMCP_SR_Ticket__c != null && req.NGMCP_SR_Ticket__c != ''
              && req.NGMCP_Status__c != tqMap.get(req.Id).NGMCP_Status__c){
                   srNumSet.add(req.NGMCP_SR_Ticket__c);
                   srNumRecordTypeMap.put(req.NGMCP_SR_Ticket__c, req.recordTypeId);
               }
        }
        
        if(srNumSet != null && !srNumSet.isEmpty()){
           amrList = [Select id, name, NGMCP_Related_GPS_Job_Number__c, NGMCP_Contract_Reference__c, NGMCP_Supplier_Id__c,
                     NGMCP_Transaction_Reference__c,NGMCP_Job_Type__c,NGMCP_MPRN__c,NGMCP_Service_Level__c,
                     NGMCP_Annual_Consumption__c,NGMCP_Target_Start__c,NGMCP_Reason__c,NGMCP_Affectedphone__c,
                     NGMCP_Affected_Person__c,NGMCP_Description_Long_Description__c,NGMCP_Ngme_ConseMail__c,
                     NGMCP_MAM_Id__c,NGMCP_Address__c,NGMCP_Postal_Town__c,NGMCP_Postal_Code__c,
                     NGMCP_Correction_Conversion_Factor__c,NGMCP_Manufacturer__c,NGMCP_Current_Meter_Model__c,
                     NGMCP_Year_of_Manufacture__c,NGMCP_Current_Meter_Serialnumber__c,NGMCP_No_of_Dials__c,
                     NGMCP_Meter_Units_of_Measure__c,NGMCP_Meter_Reading_Factor__c,NGMCP_Converter_Fitted_Indicator__c,
                     NGMCP_Converter_Serial_Number__c,NGMCP_Converter_Dials__c,NGMCP_Converter_Reading_Factor__c,
                     NGMCP_Building_Name__c, NGMCP_Market_Sector_Code__c, NGMCP_Street__c,
                     NGMCP_Affected_Person_Title__c,NGMCP_Dependent_Locality__c, recordTypeId
                     FROM NGMCP_Request__c WHERE RecordType.Name = 'AMR' AND
                     NGMCP_Related_GPS_Job_Number__c IN: srNumSet with user_mode];
        }
        if(amrList != null && !amrList.isEmpty()){
            for(NGMCP_Request__c req : amrList){
                NGMCP_AMRIntegrationClass.PayloadWrapper pw = new NGMCP_AMRIntegrationClass.PayloadWrapper();
                pw.p_Address = req.NGMCP_Address__c;
                pw.p_AlarmHigh = '';
                pw.p_AlarmLow = '';
                pw.p_AlarmNotification = '';
                pw.p_AlarmPeriod = '';
                pw.p_AlarmReq = 0;
                pw.p_AnnualQuantity = req.NGMCP_Annual_Consumption__c;
                pw.p_Comments = req.NGMCP_Description_Long_Description__c;
                pw.p_contactNo = req.NGMCP_Affectedphone__c;
                pw.p_ContractRef = req.NGMCP_Contract_Reference__c;
                pw.p_ConverterDials = srNumRecordTypeMap.get(req.NGMCP_Related_GPS_Job_Number__c) == amrRTId ? Integer.valueOf(req.NGMCP_Converter_Dials__c) : 0;
                pw.p_ConverterFittedIndicator = srNumRecordTypeMap.get(req.NGMCP_Related_GPS_Job_Number__c) == amrRTId ? req.NGMCP_Converter_Fitted_Indicator__c : '';
                pw.p_ConverterReadingFactor = srNumRecordTypeMap.get(req.NGMCP_Related_GPS_Job_Number__c) == amrRTId ? Integer.valueOf(req.NGMCP_Converter_Reading_Factor__c) : 0;
                pw.p_ConverterSerialNumber = srNumRecordTypeMap.get(req.NGMCP_Related_GPS_Job_Number__c) == amrRTId ? req.NGMCP_Converter_Serial_Number__c : '';
                pw.p_CorrectionFactor = Integer.valueOf(req.NGMCP_Correction_Conversion_Factor__c);
                //pw.p_CreateReason = req.NGMCP_Reason__c;
                pw.p_CustomerCode = req.NGMCP_Supplier_Id__c;
                pw.p_DMLogger = 0;
                pw.p_EffectiveDate = req.NGMCP_Target_Start__c.split('/')[2] + '-' + req.NGMCP_Target_Start__c.split('/')[1] + '-'+ req.NGMCP_Target_Start__c.split('/')[0];
                //pw.p_Email = req.NGMCP_Ngme_ConseMail__c;
                pw.p_JobType = req.NGMCP_Job_Type__c;
                pw.p_MAMId = req.NGMCP_MAM_Id__c;
                
                pw.p_MeterDials = srNumRecordTypeMap.get(req.NGMCP_Related_GPS_Job_Number__c) == amrRTId ? Integer.valueOf(req.NGMCP_No_of_Dials__c) : 0;
                pw.p_MeterManufacturer = srNumRecordTypeMap.get(req.NGMCP_Related_GPS_Job_Number__c) == amrRTId ? req.NGMCP_Manufacturer__c : '';
                pw.p_MeterModel = srNumRecordTypeMap.get(req.NGMCP_Related_GPS_Job_Number__c) == amrRTId ? req.NGMCP_Current_Meter_Model__c : '';
                pw.p_MeterReadingFactor = srNumRecordTypeMap.get(req.NGMCP_Related_GPS_Job_Number__c) == amrRTId ? Integer.valueOf(req.NGMCP_Meter_Reading_Factor__c) : 0;
                pw.p_MeterSerialNumber = srNumRecordTypeMap.get(req.NGMCP_Related_GPS_Job_Number__c) == amrRTId ? req.NGMCP_Current_Meter_Serialnumber__c : '';
                pw.p_MeterUnitofMeasure = srNumRecordTypeMap.get(req.NGMCP_Related_GPS_Job_Number__c) == amrRTId ? req.NGMCP_Meter_Units_of_Measure__c : '';
                pw.p_MeterYOM = srNumRecordTypeMap.get(req.NGMCP_Related_GPS_Job_Number__c) == amrRTId ? req.NGMCP_Year_of_Manufacture__c : '';
                pw.p_MPRN = req.NGMCP_MPRN__c;
                pw.p_OpenRead = '';
                pw.p_PostCode = req.NGMCP_Postal_Code__c;
                pw.p_Posttown = req.NGMCP_Postal_Town__c;
                pw.p_Prime = '';
                pw.p_Retval = '';
                pw.p_ServiceLevel = req.NGMCP_Service_Level__c;
                pw.p_SiteContact = req.NGMCP_Affectedphone__c;
                
                pw.p_SiteName = srNumRecordTypeMap.get(req.NGMCP_Related_GPS_Job_Number__c) == amrRTId ? req.NGMCP_Affected_Person__c : req.NGMCP_Building_Name__c != null && req.NGMCP_Building_Name__c != '' ? req.NGMCP_Building_Name__c : '.';
                
                pw.p_TransactionRef = req.NGMCP_Transaction_Reference__c;
                pw.p_UpfrontReq = '';
                pw.p_Email = req.NGMCP_Ngme_ConseMail__c;
                pw.p_CreateReason = 'Test Reason';
                pw.p_SVSTResponseSent = false;
                pw.p_ReadFrequency = '';
                pw.p_RequestNGMReference = '';
                pw.p_AMRSerialNumber = 'AC0003999610TA';
                pw.p_YearofManufacture = '2020';
                pw.p_ServiceProvider = 'TEC';
                String payload = JSON.serialize(pw);
                System.debug('payload: '+payload);
                jiList.add(new NGMCP_AMRNonPulsingSubmitQueueable.JobItem(req.Id, payload));
            }
        }
        if (jiList != null && !jiList.isEmpty()) {
            Integer chunkSize = 90; // safe below 100 callouts/job
            List<NGMCP_AMRNonPulsingSubmitQueueable.JobItem> chunk = new List<NGMCP_AMRNonPulsingSubmitQueueable.JobItem>();
            for (Integer startjob = 0; startjob < jiList.size(); startjob += chunkSize) {
                Integer endjob = Math.min(startjob + chunkSize, jiList.size());
            
                
                for (Integer k = startjob; k < endjob; k++) {
                    chunk.add(jiList[k]);
                }
                System.enqueueJob(new NGMCP_AMRNonPulsingSubmitQueueable(chunk));
            }
			
        }
    }
    
    //To update NGMCP_Status_Completed_Date__c on TQ whenever it is Completed/Resolved
    public static void updateTQ(List<NGMCP_Request__c> tqList, Map<Id,NGMCP_Request__c> tqMap){
        Id cwrRTId = Schema.SObjectType.NGMCP_Request__c.getRecordTypeInfosByName().get('Enquiry').getRecordTypeId();

    	for(NGMCP_Request__c req : tqList){
            if(req.recordTypeId == cwrRTId &&
               (req.NGMCP_Status__c == 'Completed' || req.NGMCP_Status__c == 'Resolved')
               && req.NGMCP_Status__c != tqMap.get(req.Id).NGMCP_Status__c){
                   req.NGMCP_Status_Completed_Date__c = Date.today();
               } 
        }
    }
    
    //To create TQ and On-Hold Install(STRT) AMR whenever it's corresponding Install AMR is Aborted
    public static void createTQAndOnHoldAMR(List<NGMCP_Request__c> amrList, Map<Id,NGMCP_Request__c> amrMap){
        
        Set<Id> abortedAMRIds = new Set<Id>();
        Id amrRTId = Schema.SObjectType.NGMCP_Request__c.getRecordTypeInfosByName().get('AMR').getRecordTypeId();
        Id tqRTId = Schema.SObjectType.NGMCP_Request__C.RecordTypeInfosByName.get('Enquiry').RecordTypeId;
        List<NGMCP_Request__c> abortedAmrList = new List<NGMCP_Request__c>();
        List<NGMCP_Request__c> reqToCreateList = new List<NGMCP_Request__c>();
        Map<String,NGMCP_Request__c> abortedAMRID_TQ_Map = new Map<String,NGMCP_Request__c>();
        List<NGMCP_Request__c> onHoldAmrList = new List<NGMCP_Request__c>();
        List<NGMCP_CreateTQAndOnHoldAMRQueueable.JobItem> jiList = new List<NGMCP_CreateTQAndOnHoldAMRQueueable.JobItem>();
        
        for(NGMCP_Request__c amr : amrList){
			if(amr.recordTypeId == amrRTId &&
               amr.NGMCP_Status__c == 'Aborted' &&
               amr.NGMCP_Job_Type__c == 'STRT' &&
               amr.NGMCP_Status__c != amrMap.get(amr.Id).NGMCP_Status__c &&
               (amr.NGMCP_AMR_Status_Reason_Code__c == 'No LF Output' ||
                amr.NGMCP_AMR_Status_Reason_Code__c == 'LF Not working')){
				  abortedAMRIds.add(amr.Id);                  
           	}       
        }
        if(abortedAMRIds != null){
            abortedAmrList = [Select id, name, NGMCP_Related_GPS_Job_Number__c, NGMCP_Contract_Reference__c, NGMCP_Supplier_Id__c,
                     NGMCP_Transaction_Reference__c,NGMCP_Job_Type__c,NGMCP_MPRN__c,NGMCP_Service_Level__c,
                     NGMCP_Annual_Consumption__c,NGMCP_Target_Start__c,NGMCP_Reason__c,NGMCP_Affectedphone__c,
                     NGMCP_Affected_Person__c,NGMCP_Description_Long_Description__c,NGMCP_Ngme_ConseMail__c,
                     NGMCP_MAM_Id__c,NGMCP_Address__c,NGMCP_Postal_Town__c,NGMCP_Postal_Code__c,
                     NGMCP_Correction_Conversion_Factor__c,NGMCP_Manufacturer__c,NGMCP_Current_Meter_Model__c,
                     NGMCP_Year_of_Manufacture__c,NGMCP_Current_Meter_Serialnumber__c,NGMCP_No_of_Dials__c,
                     NGMCP_Meter_Units_of_Measure__c,NGMCP_Meter_Reading_Factor__c,NGMCP_Converter_Fitted_Indicator__c,
                     NGMCP_Converter_Serial_Number__c,NGMCP_Converter_Dials__c,NGMCP_Converter_Reading_Factor__c,
                     NGMCP_Building_Name__c,NGMCP_Market_Sector_Code__c,NGMCP_Street__c,NGMCP_Affected_Person_Title__c,
                     NGMCP_Dependent_Locality__c, RecordTypeId
                     FROM NGMCP_Request__c WHERE Id IN: abortedAMRIds with user_mode];
        }
        if(abortedAmrList != null && !amrList.isEmpty()){
            for(NGMCP_Request__c abortedAMR : abortedAmrList){
                NGMCP_Request__c tq = new NGMCP_Request__c();
                tq.NGMCP_Aborted_AMR_Id__c = abortedAMR.Name;
                tq.RecordTypeId = tqRTId;
                tq.NGMCP_Affected_Person__c = abortedAMR.NGMCP_Affected_Person__c;
                tq.NGMCP_Enquiry_Category__c = 'MUOP';
                tq.NGMCP_LocationsId__c = '';
                tq.NGMCP_Building_Name__c = abortedAMR.NGMCP_Building_Name__c;
                tq.NGMCP_Market_Sector_Code__c = abortedAMR.NGMCP_Market_Sector_Code__c;
                tq.NGMCP_Street__c = abortedAMR.NGMCP_Street__c;
                tq.NGMCP_Supplier_Id__c = abortedAMR.NGMCP_Supplier_Id__c;
                tq.NGMCP_Notification_Type__c = 'TQ';
                tq.NGMCP_Risk_Assessment__c = 'N';
                tq.NGMCP_Postal_Town__c = abortedAMR.NGMCP_Postal_Town__c;
                tq.NGMCP_Affected_Person_Title__c = abortedAMR.NGMCP_Affected_Person_Title__c;
                tq.NGMCP_Enquiry_Description__c = 'TQ auto created due to existing meter being identified as Non-Pulsing (following AMR Install request). Please review and raise the required GPS exchange job.';
                tq.NGMCP_Engineer_Visit__c = 'N';
                tq.NGMCP_Target_Start__c = '';
                tq.NGMCP_Postal_Code__c = abortedAMR.NGMCP_Postal_Code__c;
                tq.NGMCP_Time__c = '';
                tq.NGMCP_Affectedphone__c = abortedAMR.NGMCP_Affectedphone__c;
                tq.NGMCP_Ngme_ConseMail__c = abortedAMR.NGMCP_Ngme_ConseMail__c;
                tq.NGMCP_Dependent_Locality__c = abortedAMR.NGMCP_Dependent_Locality__c;
                tq.NGMCP_Above_Threshold__c = 'N';
                tq.NGMCP_MPRN__c = abortedAMR.NGMCP_MPRN__c;
                tq.NGMCP_Reported_Email__c = UserInfo.getUserEmail();
                tq.NGMCP_Enquiry_Type__c = 'Technical Query';
                tq.NGMCP_Enquiry_Reason_Code__c = 'MET';
                tq.NGMCP_Callout_Status__c = 'In Progress';
                tq.NGMCP_API_Callout__c = 'Create Enquiry callout';
                //tq.NGMCP_Target_Finish_Date__c = (String) payload.get('category') == 'TQUERY' ? NGMCP_EnquiriesHandler.addWorkingDays(date.today(), 20, NGMCP_HolidaysService.getHolidaysBetween()) : '';
                reqToCreateList.add(tq);
                
                NGMCP_Request__c onHoldAMR = new NGMCP_Request__c();
                onHoldAMR.NGMCP_Aborted_AMR_Id__c = abortedAMR.Name;
                onHoldAMR.RecordTypeId = abortedAMR.RecordTypeId;
                onHoldAMR.NGMCP_Contract_Reference__c = abortedAMR.NGMCP_Contract_Reference__c;
                onHoldAMR.NGMCP_Supplier_Id__c = abortedAMR.NGMCP_Supplier_Id__c;
                onHoldAMR.NGMCP_Transaction_Reference__c = abortedAMR.NGMCP_Transaction_Reference__c;
                onHoldAMR.NGMCP_Job_Type__c = abortedAMR.NGMCP_Job_Type__c;
                onHoldAMR.NGMCP_MPRN__c = abortedAMR.NGMCP_MPRN__c;
                onHoldAMR.NGMCP_Service_Level__c = abortedAMR.NGMCP_Service_Level__c;
                onHoldAMR.NGMCP_Annual_Consumption__c = abortedAMR.NGMCP_Annual_Consumption__c;
                onHoldAMR.NGMCP_Target_Start__c = abortedAMR.NGMCP_Target_Start__c;
                onHoldAMR.NGMCP_Reason__c = abortedAMR.NGMCP_Reason__c;
                onHoldAMR.NGMCP_Affectedphone__c = abortedAMR.NGMCP_Affectedphone__c;
                onHoldAMR.NGMCP_Affected_Person__c = abortedAMR.NGMCP_Affected_Person__c;
                onHoldAMR.NGMCP_Description_Long_Description__c = abortedAMR.NGMCP_Description_Long_Description__c;
                onHoldAMR.NGMCP_Ngme_ConseMail__c = abortedAMR.NGMCP_Ngme_ConseMail__c;
                onHoldAMR.NGMCP_MAM_Id__c = abortedAMR.NGMCP_MAM_Id__c;
                onHoldAMR.NGMCP_Address__c = abortedAMR.NGMCP_Address__c;
                onHoldAMR.NGMCP_Postal_Town__c = abortedAMR.NGMCP_Postal_Town__c;
                onHoldAMR.NGMCP_Postal_Code__c = abortedAMR.NGMCP_Postal_Code__c;
                onHoldAMR.NGMCP_Correction_Conversion_Factor__c = abortedAMR.NGMCP_Correction_Conversion_Factor__c;
                onHoldAMR.NGMCP_Manufacturer__c = abortedAMR.NGMCP_Manufacturer__c;
                onHoldAMR.NGMCP_Current_Meter_Model__c = abortedAMR.NGMCP_Current_Meter_Model__c;
                onHoldAMR.NGMCP_Year_of_Manufacture__c = abortedAMR.NGMCP_Year_of_Manufacture__c;
                onHoldAMR.NGMCP_Current_Meter_Serialnumber__c = abortedAMR.NGMCP_Current_Meter_Serialnumber__c;
                onHoldAMR.NGMCP_No_of_Dials__c = abortedAMR.NGMCP_No_of_Dials__c;
                onHoldAMR.NGMCP_Meter_Units_of_Measure__c = abortedAMR.NGMCP_Meter_Units_of_Measure__c;
                onHoldAMR.NGMCP_Meter_Reading_Factor__c = abortedAMR.NGMCP_Meter_Reading_Factor__c;
                onHoldAMR.NGMCP_Converter_Fitted_Indicator__c = abortedAMR.NGMCP_Converter_Fitted_Indicator__c;
                onHoldAMR.NGMCP_Converter_Serial_Number__c = abortedAMR.NGMCP_Converter_Serial_Number__c;
                onHoldAMR.NGMCP_Converter_Dials__c = abortedAMR.NGMCP_Converter_Dials__c;
                onHoldAMR.NGMCP_Converter_Reading_Factor__c = abortedAMR.NGMCP_Converter_Reading_Factor__c;
                onHoldAMR.NGMCP_Callout_Status__c = 'In Progress';
                onHoldAMR.NGMCP_API_Callout__c = 'Create AMR callout';
                onHoldAMR.NGMCP_Status__c = 'On Hold';
                onHoldAMR.NGMCP_Building_Name__c = abortedAMR.NGMCP_Building_Name__c;
                onHoldAMR.NGMCP_Market_Sector_Code__c = abortedAMR.NGMCP_Market_Sector_Code__c;
                onHoldAMR.NGMCP_Street__c = abortedAMR.NGMCP_Street__c;
                onHoldAMR.NGMCP_Affected_Person_Title__c = abortedAMR.NGMCP_Affected_Person_Title__c;
               	onHoldAMR.NGMCP_Dependent_Locality__c = abortedAMR.NGMCP_Dependent_Locality__c;
                onHoldAmrList.add(onHoldAMR);
                
				NGMCP_AMRIntegrationClass.TQPayloadWrapper tqpw = new NGMCP_AMRIntegrationClass.TQPayloadWrapper(); 
                tqpw.ngme_consname = abortedAMR.NGMCP_Affected_Person__c;
                tqpw.reason = 'MUOP';
                tqpw.loccode = '';
                tqpw.bldgname = abortedAMR.NGMCP_Building_Name__c;
                tqpw.sectorcode = abortedAMR.NGMCP_Market_Sector_Code__c;
                tqpw.street = abortedAMR.NGMCP_Street__c;
                tqpw.supplier = abortedAMR.NGMCP_Supplier_Id__c;
                tqpw.notif_type = 'TQ';
                tqpw.ngme_riskassess = 'N';
                tqpw.posttown = abortedAMR.NGMCP_Postal_Town__c;
                tqpw.ngme_constitle = abortedAMR.NGMCP_Affected_Person_Title__c;
                tqpw.description_longdescription = 'TQ auto created due to existing meter being identified as Non-Pulsing (following AMR Install request). Please review and raise the required GPS exchange job.';
                tqpw.ngme_engvisit = 'N';
                tqpw.targetstart = '';
                tqpw.postcode = abortedAMR.NGMCP_Postal_Code__c;
                tqpw.ngme_time = '';
                tqpw.ngme_consphone = abortedAMR.NGMCP_Affectedphone__c;
                tqpw.deplocal = abortedAMR.NGMCP_Dependent_Locality__c;
                tqpw.ngme_threshold = 'N';
                tqpw.location = abortedAMR.NGMCP_MPRN__c;
                tqpw.ngme_consemail = abortedAMR.NGMCP_Ngme_ConseMail__c;
                tqpw.reportedemail = UserInfo.getUserEmail();
                tqpw.category = 'TQUERY';
                tqpw.subcategory = 'MET';
                String payload = JSON.serialize(tqpw);
                
                jiList.add(new NGMCP_CreateTQAndOnHoldAMRQueueable.JobItem(tq, onHoldAMR, payload));
            }
        }
        if (jiList != null && !jiList.isEmpty()) {
            Integer chunkSize = 90; // safe below 100 callouts/job
            List<NGMCP_CreateTQAndOnHoldAMRQueueable.JobItem> chunk = new List<NGMCP_CreateTQAndOnHoldAMRQueueable.JobItem>();
            for (Integer startjob = 0; startjob < jiList.size(); startjob += chunkSize) {
                Integer endjob = Math.min(startjob + chunkSize, jiList.size());
            
                
                for (Integer k = startjob; k < endjob; k++) {
                    chunk.add(jiList[k]);
                }
                System.enqueueJob(new NGMCP_CreateTQAndOnHoldAMRQueueable(chunk));
            }
			
        }
    }
    
    //To update an On-Hold Remove AMR to Cancelled whenever it's related Stop AMR is Aborted/Cancelled/Rejected
    public static void updateOnHoldRemoveAMRs(List<NGMCP_Request__c> amrList, Map<Id,NGMCP_Request__c> amrMap){
        
        Set<String> srNumSet = new Set<String>();
        Id amrRTId = Schema.SObjectType.NGMCP_Request__c.getRecordTypeInfosByName().get('AMR').getRecordTypeId();
        List<NGMCP_Request__c> onHoldRemoveAMRList = new List<NGMCP_Request__c>(); 
        
        for(NGMCP_Request__c amrStop : amrList){
            if(amrStop.RecordTypeId == amrRTId && amrStop.NGMCP_Job_Type__c == 'STOP' &&
              (amrStop.NGMCP_Status__c == 'Aborted' || amrStop.NGMCP_Status__c == 'Cancelled' ||
              amrStop.NGMCP_Status__c == 'Rejected') && 
              amrStop.NGMCP_SR_Ticket__c != null && amrStop.NGMCP_SR_Ticket__c != '' &&
               amrStop.NGMCP_Status__c != amrMap.get(amrStop.Id).NGMCP_Status__c){
                   srNumSet.add(amrStop.NGMCP_SR_Ticket__c);
               }
        }
        if(srNumSet != null){
           onHoldRemoveAMRList = [Select Id, Name, NGMCP_Related_GPS_Job_Number__c, NGMCP_Status__c 
                                 FROM NGMCP_Request__c 
                                 WHERE NGMCP_Related_GPS_Job_Number__c in: srNumSet with user_mode] ;
        }
        if(onHoldRemoveAMRList != null){
            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                for(NGMCP_Request__c removeAMR : onHoldRemoveAMRList){
                    removeAMR.NGMCP_Status__c = 'Cancelled';
                }
            }
            if(Schema.sObjectType.NGMCP_Request__c.isUpdateable()){
            	update onHoldRemoveAMRList;
            }
        }
    }

}