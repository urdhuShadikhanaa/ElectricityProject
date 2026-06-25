public  class FFA_CreateInterfaceModel {

    public class wrapperClass
    {
        public FFA_NGV_Asset__c newAssetRecord;
        public WorkOrder newJobRecord;
        public FFA_Site__c newSiteRecord; 
        
        public Map<String,Object> jobMapObject;
        public Map<String,Object> siteMapObject;
        public Map<String,Object> meterMapObject;
        public Map<String,Object> convertorMapObject;
        public Map<String,Object> regulatorMapObject;
        public Map<String,Object> slamShutMapObject;
        public Map<String,Object> valveMapObject;
        public Map<String,Object> filterMapObject;
        public Map<String,Object> flowComputerMapObject;
        public Map<String,Object> creepReliefMapObject;
        public Map<String,Object> boilerMapObject;
        public Map<String,Object> chromatographMapObject;
        public Map<String,Object> densitometerMapObject;
        public Map<String,Object> pipeworkMapObject;
        public Map<String,Object> cathodicProtectionMapObject;
        public Map<String,Object> auxillaryControlMapObject;
        public Map<String,Object> auxillaryReliefMapObject;
        public Map<String,Object> waterBathHeaterMapObject;
        public Map<String,Object> shellandTubeMapObject;
        public Map<String,Object> HeaderMapObject;
        
        public Job jobObject;
        public FFA_Site siteObject;
        public Meter meterObject;
        public Convertor convertorObject;
        public Regulator reguatorObject;
        public Valves valveObject;
        public SlamShut slamShutObject;
        public FlowComputer flowComputerbject;
        public CreepRelief creepReliefObject;
        public Boiler boilerObject;
        public Chromatograph chromatographObject;
        public Densitometer densitometerObject;
        public Pipework pipeworkObject;
        public CathodicProtection cathodicProtectionObject;
        public AuxillaryControl auxillaryControlObject;
        public AuxillaryRelief auxillaryReliefObject;
        public WaterBathHeaters waterBathHeaterObject;
        public ShellandTube shellandTubeObject;
        public Header HeaderObject;
        
        public wrapperClass(){}
  
   }
    /*HTTP Response Wrapper Class*/
    public class SystemResponseWrapper
    {
        public string TransactionMessage;
        public string TransactionStatus;
        public string ServiceNotificationNumber;
        public string OperationNumber;
        public string WorkOrderNumber;
        public string HTTP_Status_Code;
        
        public SystemResponseWrapper(){}
    }
    /*Header Wrapper class */
    public class Header{
        public string TransactionType ;
        public string SenderID ;
        public string ReceiverID ;
        public string InterfaceName ;
        public string FileType;
        public string CreationDate;
        public string CreationTime ;
        public String GenerationNumber;
        
        public Header(){}
    }
    
    public FFA_CreateInterfaceModel(){
        
    }
}