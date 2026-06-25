public with sharing class FFA_Constants {

   public static final String FFA_JOB_RECORD_TYPE = 'Job';
   public static final String FFA_SITE_RECORD_TYPE = 'Site';
   public static final String FFA_METER_RECORD_TYPE = 'Meter';
   public static final String FFA_CONVERTOR_RECORD_TYPE = 'Convertor';
   public static final String FFA_REGULATOR_RECORD_TYPE = 'Regulator';
   public static final String FFA_FILTER_RECORD_TYPE = 'Filters';
   public static final String FFA_SLAMSHUT_RECORD_TYPE = 'SlamShut';
   public static final String FFA_VALVES_RECORD_TYPE = 'Valves';
   public static final String FFA_AUXRELIEF_RECORD_TYPE = 'AuxillaryRelief';
   public static final String FFA_CREEPRELIEF_RECORD_TYPE = 'CreepRelief';
   public static final String FFA_AUXCONTROL_RECORD_TYPE = 'AuxillaryControl';
   public static final String FFA_BOILER_RECORD_TYPE = 'Boiler';
   public static final String FFA_WATERBATHHEATER_RECORD_TYPE = 'WaterBathHeaters';
   public static final String FFA_SHELLANDTUBE_RECORD_TYPE = 'ShellandTube';
   public static final String FFA_FLOWCOMPUTER_RECORD_TYPE = 'FlowComputer';
   public static final String FFA_CHROMATOGRAPH_RECORD_TYPE = 'Chromatograph';
   public static final String FFA_DENSITOMETER_RECORD_TYPE = 'Densitometer';
   public static final String FFA_PIPEWORK_RECORD_TYPE = 'Pipework';
   public static final String FFA_CATHODICPROTECTION_RECORD_TYPE = 'CathodicProtection';

   public static final String SERVICE_NOTIFICATION = 'ServiceNotificationNumber';
   public static final String OPERATION_NO = 'OperationNumber';
   

   //JSON Data types 
   public static final String STRING_DATA_TYPE='String';
   public static final String TEXT_DATA_TYPE='Text';
   public static final String NUMBER_DATA_TYPE='Integer';
   public static final String DECIMAL_DATA_TYPE='Decimal';
   public static final String DATE_DATA_TYPE='Date';
   public static final String DATETIME_DATA_TYPE='DateTime'; 
   
   //Error Codes
   public static final String FFA_INTEGRATION_CONFIG_MISSING ='FFA Integration Configuration Missing';
   public static final String MANDATORY_DATA_MISSING='Mandatory data or fields missing';
   public static final String DUPLICATE_WORKORDER= 'Duplicate workorder';
   public static final string JOBCODE_NOTVALID_OR_MISSING = 'Job Code is not Valid';
   public static final string SERVICE_PROVIDER_NOTVALID = 'Service Provider is not valid';
   public static final string REQAPPOINTMENTDATE_NOTVALID = 'Date is not valid. It should be greater than Today or Equal to it.';
   public static final string UNPLANNEDSTARTDATE_NOTVALID = 'Unplannned policy start date either would be greater than today or equal to it.';
   public static final string UNPLANNEDENDDATE_NOTVALID = 'Unplanned policy end date should be greater tha Unplanned Policy Start Date or equal to it.';
   public static final string UPDATE_WORKORDER_MESSAGE = 'Work Order updated Successfully';
   public static final string UPDATE_ERROR_BY_STATUS ='Update cannot be processed due to work order status';
   public static final string UPDATE_WO_NOT_FOUND = 'Work Order does not exist or invalid.';
   public static final string UPDATE_ASSET_NOT_FOUND = 'Update received on the Asset which does not exist in Salesforce';
   public static final string UPDATE_REPLAN_SUCCESS_MESSAGE ='Replan Job updated Successfully';
   public static final string UPDATE_AMEND_SUCCESS_MESSAGE =  'Amend Job updated Successfully';
   public static final string UPDATE_WO_FAILED_OPERATION = 'Work order update operation failed.';
   public static final string UPDATE_WO_SA_NOTVALID_STATUS = 'Service appointment status is not valid.';
   public static final string UPDATE_WO_SA_NOT_FOUND = 'No service appointment found.';
   public static final string REPLAN_SLOTS_EXPIRED = 'Timeslot selected is not permitted, please select valid future timeslot'; 
  
   public static Id WorkOrderIdsForAsset {get; set;}
    
    
    //FFA UPDATE INTERFACE CONSTANTS
    
    public static final string FFA_TRANSACTIONTYPE_CANCEL='ST';
    public static final string FFA_TRANSACTIONTYPE_REPLAN='SR';
    public static final string FFA_TRANSACTIONTYPE_AMEND='SA';
    
     //WorkOrder Feed Default Statuses
    public static final string WORKORDER_STATUS_CANCEL='Cancelled';
    public static final string WORKORDER_STATUS_REPLAN='Replan';
    public static final string WORKORDER_STATUS_ASSIGN='Assigned';
    public static final string WORKORDER_STATUS_SCHEDULE='Scheduled';
    public static final string WORKORDER_STATUS_COMPLETED='Completed';
    public static final string WORKORDER_SYNC_STATUS_PENDING = 'Pending';
    public static final string WORKORDER_STATUS_INPROGRESS='In Progress';
    public static final String DOMSTATUSReject = 'Rejected';
    public static final String UNASSIGNED_STATUS='New';
    public static final String REPLAN_REQUIRED_STATUS='Replan_Required';
    public static final String SP_UNSCHEDULED_STATUS='Unassigned';
    
    //UPDATE INTERFACE STATUS CODES
    public static final string SUCESS_CODE='201';
    public static final string FAILURE_CODE='400';
    public static final string SUCCESS_STATUS = 'Success';
    public static final string FAILURE_STATUS = 'Failure';
    
    
    //Complete Interface Constants
   public static final String FFA_SITE = 'Site';
   public static final String FFA_METER = 'Meter';
   public static final String FFA_CONVERTOR = 'Converter';
   public static final String FFA_REGULATOR = 'Regulator';
   public static final String FFA_FILTER = 'Filter';
   public static final String FFA_SLAMSHUT = 'Slamshut';
   public static final String FFA_VALVES = 'Valve';
   public static final String FFA_AUXRELIEF= 'Auxillary Relief';
   public static final String FFA_CREEPRELIEF = 'Creep Relief';
   public static final String FFA_AUXCONTROL= 'Auxillary Control';
   public static final String FFA_BOILER = 'Boiler';
   public static final String FFA_WATERBATHHEATER = 'Water Bath Heater';
   public static final String FFA_SHELLANDTUBE = 'Shell & Tube';
   public static final String FFA_FLOWCOMPUTER = 'Flow Computer';
   public static final String FFA_CHROMATOGRAPH= 'Chromatograph';
   public static final String FFA_DENSITOMETER = 'Densitometer';
   public static final String FFA_PIPEWORK = 'Pipework';
   public static final String FFA_CATHODICPROTECTION = 'Cathodic Protection';
   public static final String ActivityTypeE = 'E';
   public static final String FFAWorkOrderStatusComplete = 'Completed';
   public static final String FFAWorkOrderStatusCancelled = 'Cancelled';
   public static final String FFAWorkOrderStatusTerminated = 'Terminated';
   public static final String FFAWorkOrderStatusFWR = 'Further Work Required';
   public static final String FFAWorkOrderStatusRejected = 'Rejected';
   public static final String FFASFCOMPLETION = 'SF-COMPLETION';
   public static final String FFASFCANCEL = 'SF-CANCEL';
   public static final String FFASFTERMINATE = 'SF-TERMINATE';
   public static final String FFASFREPLAN = 'SF-REPLAN';
   public static final String FFASFREJECT = 'SF-REJECT';
   public static final String FFASFPOLICYJOB = 'SF-POLSCH';
   public static final String FFATRANSACTIONN64 = 'N64';
   public static final String FFATRANSACTIONN65 = 'N65';
   public static final String FFATRANSACTIONN66 = 'N66';
   public static final String FFATRANSACTIONN67 = 'N67';
   public static final String FFATRANSACTIONN68 = 'N68';
   public static final String FFATRANSACTIONN75 = 'N75';
   public static final String Yes = 'Yes';
   public static final String FFARAINBOW = 'RAINBOW';
   public static final String FFAPHOENIX = 'PHOENIX';
   public static final String FFAFileType = 'SFCOM';
   
   
}