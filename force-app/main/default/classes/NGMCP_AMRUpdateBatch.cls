public with sharing class NGMCP_AMRUpdateBatch implements 
    Database.Batchable<NGMCP_AMRClass.ObjListClass>, Database.Stateful{
	
    private final List<NGMCP_AMRClass.ObjListClass> data;

    public NGMCP_AMRUpdateBatch(List<NGMCP_AMRClass.ObjListClass> data) {
    	this.data = (data == null) ? new List<NGMCP_AMRClass.ObjListClass>() : data;
    }

    public Iterable<NGMCP_AMRClass.ObjListClass> start(Database.BatchableContext bc) {
    	return data;
    }
    
    private static Map<String, String> JobOutComeStatusCodeMap = new Map<String, String>{
        'ABORT' => 'Aborted',
        'CANS' => 'Cancelled',
        'COMLT' => 'Completed',
        'Regen' => 'Regenerated',
        'REJCT' => 'Rejected'   
    };
    
    private static Map<String, String> TransactionStatusCodeMap = new Map<String, String>{
        'NOSPC' => '',
        'RA000' => 'Refused Access',
        'NOLFO' => 'No LF Output',
        'MPU03' => '',
        'ADMIN' => '',
        'NOACC' => 'No Access',
        'LFNOW' => 'LF Not working',
        'VACNT' => 'Vacant premises',
        'REACC' => 'Refused access',
        'NOSIG' => 'No signal',
        'FLTIN' => 'Faulty Index',
        '3RDPA' => '',
        'DEMOL' => 'Premises due for demolition',
        'UPREM' => 'Unable to locate premises',
        'DISCN' => 'Meter not connected',
        'OT000' => 'Other',
        'MPU02' => '',
        'HEASA' => 'Health and Safety issues - Comments mandatory to inform  of reason',
        'OTHER' => 'Other – Comments mandatory to inform of reason',
        'NLMTR' => 'No live meter',
        'UNLOC' => '',
        'DL000' => 'Demolition',
        'RA000' => 'Refused Access',
        'IC000' => 'Invalid Contact Details',
        'IM000' => 'Invalid Meter Point',
        'NA000' => 'Not appointed supplier'
    };

    
    public void execute(Database.BatchableContext bc, List<NGMCP_AMRClass.ObjListClass> scope) {
		try{
           List<NGMCP_Request__c> requestList = new List<NGMCP_Request__c>();
           List<NGMCP_Request__c> requestListToUpdate = new List<NGMCP_Request__c>();
           
           Set<String> srNums = new Set<String>();
           Map<String,NGMCP_AMRClass.ObjListClass> objMap = new Map<String,NGMCP_AMRClass.ObjListClass>();
           
           	for(NGMCP_AMRClass.ObjListClass obj : scope){
               	if(obj.parentWorkRequestID != null){
            		srNums.add(String.valueOf(obj.parentWorkRequestID));
                    objMap.put(String.valueOf(obj.parentWorkRequestID), obj);
            	}  
                	if(obj.workRequestId != null){
            		srNums.add(String.valueOf(obj.workRequestId));
                    objMap.put(String.valueOf(obj.workRequestId), obj);
            	}    
           	}
            
            if(srNums != null){
                requestList = [Select Id, Name, NGMCP_SR_Ticket__c, NGMCP_Status__c, NGMCP_AMR_Status_Date__c,
                              NGMCP_AMR_Status_Reason_Code__c,
                              NGMCP_Target_Start__c, NGMCP_Meter_Reading_As_Found__c, 
                              NGMCP_Converted_Reading_As_Found__c, NGMCP_Unconverted_Reading_As_Found__c, 
                              NGMCP_AMR_Meter_Reading_As_Found__c, NGMCP_AMR_Converter_Reading_As_Found__c, 
                              NGMCP_Meter_Reading_As_Left__c, NGMCP_Converted_Reading_As_Left__c, 
                              NGMCP_Unconverted_Reading_As_Left__c, NGMCP_AMR_Meter_Reading_As_Left__c, 
                              NGMCP_AMR_Converter_Reading_As_Left__c
                              FROM NGMCP_Request__c
                              WHERE NGMCP_SR_Ticket__c in: srNums
                              with user_mode];
            }
            
            if(requestList != null && !requestList.isEmpty() && objMap != null){
                for(NGMCP_Request__c req : requestList){
                    if(objMap.containsKey(req.NGMCP_SR_Ticket__c)){
                       
                       NGMCP_Request__c reqToUpdate = new NGMCP_Request__c();
                        //if(Schema.sObjectType.NGMCP_Request__c.fields.Id.isUpdateable()){
        					reqToUpdate.Id = req.Id;
        				//}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
        					reqToUpdate.NGMCP_Status__c = objMap.get(req.NGMCP_SR_Ticket__c).jobOutComeStatusCode != null && 
                            objMap.get(req.NGMCP_SR_Ticket__c).jobOutComeStatusCode != ''  && 
                            JobOutComeStatusCodeMap.containsKey(objMap.get(req.NGMCP_SR_Ticket__c).jobOutComeStatusCode) ? 
                            JobOutComeStatusCodeMap.get(objMap.get(req.NGMCP_SR_Ticket__c).jobOutComeStatusCode) : 
                        objMap.get(req.NGMCP_SR_Ticket__c).PlannedStatus != null && 
                            objMap.get(req.NGMCP_SR_Ticket__c).PlannedStatus != '' ? 
                            objMap.get(req.NGMCP_SR_Ticket__c).PlannedStatus :  req.NGMCP_Status__c;
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_AMR_Status_Date__c.isUpdateable()){
        					reqToUpdate.NGMCP_AMR_Status_Date__c = NGMCP_AMRUpdateClass.toDdMmYyyy(String.valueOf(objMap.get(req.NGMCP_SR_Ticket__c).jobOutComeDate));
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_AMR_Status_Reason_Code__c.isUpdateable()){
        					reqToUpdate.NGMCP_AMR_Status_Reason_Code__c = TransactionStatusCodeMap.containsKey(objMap.get(req.NGMCP_SR_Ticket__c).transactionStatusCode) ? TransactionStatusCodeMap.get(objMap.get(req.NGMCP_SR_Ticket__c).transactionStatusCode) : '';
        				}
                        
                        //reqToUpdate.NGMCP_Target_Start__c = objMap.get(req.NGMCP_SR_Ticket__c).jobPlannedDate != null ? NGMCP_AMRUpdateClass.toDdMmYyyy(String.valueOf(objMap.get(req.NGMCP_SR_Ticket__c).jobPlannedDate)) : req.NGMCP_Target_Start__c;
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Target_Start__c.isUpdateable()){
        					reqToUpdate.NGMCP_Target_Start__c = objMap.get(req.NGMCP_SR_Ticket__c).jobPlannedDate != null ? objMap.get(req.NGMCP_SR_Ticket__c).jobPlannedDate.toString() : req.NGMCP_Target_Start__c;
        				}
                        
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Meter_Reading_As_Found__c.isUpdateable()){
        					reqToUpdate.NGMCP_Meter_Reading_As_Found__c = objMap.get(req.NGMCP_SR_Ticket__c).meterReading;
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Converted_Reading_As_Found__c.isUpdateable()){
        					reqToUpdate.NGMCP_Converted_Reading_As_Found__c = objMap.get(req.NGMCP_SR_Ticket__c).converterReading;
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Unconverted_Reading_As_Found__c.isUpdateable()){
        					reqToUpdate.NGMCP_Unconverted_Reading_As_Found__c = objMap.get(req.NGMCP_SR_Ticket__c).unCorrectedReading;
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_AMR_Meter_Reading_As_Found__c.isUpdateable()){
        					reqToUpdate.NGMCP_AMR_Meter_Reading_As_Found__c = objMap.get(req.NGMCP_SR_Ticket__c).amrMeterReading;
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_AMR_Converter_Reading_As_Found__c.isUpdateable()){
        					reqToUpdate.NGMCP_AMR_Converter_Reading_As_Found__c = objMap.get(req.NGMCP_SR_Ticket__c).amrConverterReading;
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Meter_Reading_As_Left__c.isUpdateable()){
        					reqToUpdate.NGMCP_Meter_Reading_As_Left__c = objMap.get(req.NGMCP_SR_Ticket__c).departMeterReading;
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Converted_Reading_As_Left__c.isUpdateable()){
        					reqToUpdate.NGMCP_Converted_Reading_As_Left__c = objMap.get(req.NGMCP_SR_Ticket__c).departConverterReading;
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Unconverted_Reading_As_Left__c.isUpdateable()){
        					reqToUpdate.NGMCP_Unconverted_Reading_As_Left__c = objMap.get(req.NGMCP_SR_Ticket__c).departUnCorrectedRead;
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_AMR_Meter_Reading_As_Left__c.isUpdateable()){
        					reqToUpdate.NGMCP_AMR_Meter_Reading_As_Left__c = objMap.get(req.NGMCP_SR_Ticket__c).departAMRMeterRead;
        				}
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_AMR_Converter_Reading_As_Left__c.isUpdateable()){
        					reqToUpdate.NGMCP_AMR_Converter_Reading_As_Left__c = objMap.get(req.NGMCP_SR_Ticket__c).departAMRConvertedRead;
        				}
                        
                        if(objMap.get(req.NGMCP_SR_Ticket__c).amrJobTypeCode == null || objMap.get(req.NGMCP_SR_Ticket__c).amrJobTypeCode == ''){
                            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                            	reqToUpdate.NGMCP_Status__c = objMap.get(req.NGMCP_SR_Ticket__c).wrStatusCode != null && 
                                objMap.get(req.NGMCP_SR_Ticket__c).wrStatusCode != ''  && (
                                objMap.get(req.NGMCP_SR_Ticket__c).jobTypeCode == 'DEAP' ||
                                objMap.get(req.NGMCP_SR_Ticket__c).jobTypeCode == 'STOP') &&
                                JobOutComeStatusCodeMap.containsKey(objMap.get(req.NGMCP_SR_Ticket__c).wrStatusCode) ? 
                                JobOutComeStatusCodeMap.get(objMap.get(req.NGMCP_SR_Ticket__c).wrStatusCode) : req.NGMCP_Status__c;
                            }
                        }
                       	  
                        requestListToUpdate.add(reqToUpdate);
                    }
                }
            }
            
            if(requestListToUpdate != null && Schema.sObjectType.NGMCP_Request__c.isUpdateable()){
                update requestListToUpdate;
            }
		}catch(Exception e){
			throw e;
    	}
	}

	public void finish(Database.BatchableContext bc) {
        
	}
}