public with sharing class NGMCP_AMRClass {
	public String status;
    public String message;
    public List<ObjListClass> objList;
    
    public class ObjListClass{
        public Long amrWorkRequestId;
        public String ngmReference;
        public Long mprn;
        public String amrJobTypeCode;
    	public String meterReading;
        public Long readingFactor;
        public Long workRequestId;
        
        public Double pulseSignificance;
        public String converterReading;
    	public String unCorrectedReading;
        public String amrMeterReading;
    	public String amrConverterReading;
        public String readFlagCode;
    	public String resynchReasonCode;
        public String departMeterReading;
    	public String departConverterReading;
        public String departUnCorrectedRead;
    	public String departAMRMeterRead;
        public String departAMRConvertedRead;
    	public String jobOutComeStatusCode;
        public DateTime jobOutComeDate;
        public String meterInspection;
        public String batteryChange;
    	public String masterAssetDataChange;
        public String transactionStatusCode;
    	public String comments;
        public Long parentWorkRequestID;
        public String approvedBy;
        public DateTime jobPlannedDate;
        public String lastModifiedDate;
    	public String lastModifiedUser;
        public DateTime requestGeneratedDate;
        public String primaryErrorCode;
        public String secondaryErrorCode;
    	public String wrStatusCode;
        public String fileName;
        public Boolean svstResponseSent;
        public String readFrequency;
        public String requestNGMReference;
    	public String wipStatusCode;
        public String assignedTo;
    	public String wipActionComment;
        public DateTime wipStatusDate;
        public String wipType;
    	public String meterSerialNumber;
        public String converterSerialNumber;
    	public String meterManufacturer;
        public String meterModel;
        public Long meterDials;
        public Long converterDials;
        public String amrSerialNumber;
        public String imperialMetricIndicator;
    	public String yearofManufacture;
        public String wipActionSPReference;
    	public String supplierTransactionStatus;
        public String supplierComments;
        public Long driftPercentage;
        public Boolean billSiteVisit;
        public DateTime responseReceivedDate;
        public String amrModelCode;
        public String amrYearofManufacturer;
    	public String ocrSerialNumber;
        public String gps;
        public Long conDriftPercentage;
        public String responseFileName;
        public String plannedStatus;
    	public String raisedBy;
        public String expectedDataFromCustomer;
    	public String serviceProvider;
        public Boolean microbusiness;
        public String jobPlannedSlot;
    	public String jobOutcomeTime;
        public String jobTypeCode;
    }
    
    public static NGMCP_AMRClass parse(String json){
        try{
        System.debug('return from amr class****'+ (NGMCP_AMRClass) System.JSON.deserialize(json, NGMCP_AMRClass.class));
        return (NGMCP_AMRClass) System.JSON.deserialize(json, NGMCP_AMRClass.class);
        }
        catch(Exception e){
            System.debug('Error in parsing request class: '+e.getMessage() + ' @line:' + e.getLineNumber());
            return null;
        }
    }
    
}