/* ***************************************************************************************
   ***************************************************************************************
 * Name       : FFA_WorkOrderCompleteInterfaceWrapper
 * CreatedBy  : Venkat
 * Task       :T-811721
 * Description:Supproting class for Complete Interface
   UPDATES : 
   1.S-660046[VENKAT] 12-06-2020:Added REPLAN DATE and TIME 
   ***************************************************************************************
   *****************************************************************************************               
 */

public Class FFA_WorkOrderCompleteInterfaceWrapper{
    
    // Wrapper Classess
    //Start From here
    public class WrapperBody{
        public Header Header { get; set; }
        public Body Body { get; set; }
        
    }
    
    public class Body{
        public Job Job { get; set; }
        public Site Site { get; set; }
        public Meter Meter { get; set; }
        public Convertor Convertor { get; set; }
        //public Regulator Regulator { get; set; }
        public FlowComputer FlowComputer { get; set; }
        public Slamshut Slamshut { get; set; }
        public CreepRelief CreepRelief { get; set; }
        public Boiler Boiler { get; set; }
        public WaterBathHeaters WaterBathHeaters { get; set; }
        public ShellandTube ShellandTube { get; set; }
        public Chromatograph Chromatograph { get; set; }
        public Densitometer Densitometer { get; set; }
        public Valves Valves { get; set; }
        public Pipework Pipework { get; set; }
        public CathodicProtection CathodicProtection { get; set; }
        public AuxillaryControl AuxillaryControl { get; set; }
        public AuxillaryRelief AuxillaryRelief { get; set; }
        public Filters Filters { get; set; }
    }
    
    public class Header{
        public string TransactionType { get; set;} 
        public string SenderID { get; set; }
        public string ReceiverID { get; set; }
        public string InterfaceName { get; set; }
        public string FileType { get; set; }
        public string CreationDate { get; set; }
        public string CreationTime { get; set; }
    }
    
    public class Job{
        public Completion Completion { get; set; }
        public MPRM MPRM { get; set; }
        // public CompletionAdditional CompletionAdditional { get; set; }
        public list<Payment> Payment { get; set; }
    }
    
    public class Site{
        public Details Details { get; set; }
    }
    
    public class Meter{
        public list<MeterCurrent> Current { get; set; }
        public list<MeterFix> Fix { get; set; }
    }
    
    /*public class Regulator{
        public RegulatorCurrent Current {get;set;}
        public RegulatorFix Fix {get;set;}
    }*/
    public class Convertor{
        public list<ConvertorCurrent> Current;
        public list<ConvertorFix> Fix;
        public list<ConvertorReadingsAndData> ReadingsAndData;
        public list<convertorFixReadingsAndData> FixReadingsAndData;
    }
    
    public class FlowComputer{
        public list<FlowComputerCurrent> Current;
        public list<FlowComputerFix> Fix;
    }
    
    public class SlamShut{
        public list<SlamShutCurrent> Current;
        public list<SlamShutFix> Fix;
    }
    
    public class CreepRelief{
        public list<CreepReliefCurrent> Current;
        public list<CreepReliefFix> Fix;
    }
    
    public class Boiler{
        public list<BoilerCurrent> Current;
        public list<BoilerFix> Fix;
    }
    
    public class WaterBathHeaters{
        public list<WaterBathHeatersCurrent> Current;
        public list<WaterBathHeatersFix> Fix;
    }
    
    public class ShellandTube{
        public list<ShellandTubeCurrent> Current;
        public list<ShellandTubeFix> Fix;
    }
    
    public class Chromatograph{
        public list<ChromatographCurrent> Current;
        public list<ChromatographFix> Fix;
    }
    
    public class Densitometer{
        public list<DensitometerCurrent> Current;
        public list<DensitometerFix> Fix;
    }
    
    public class Valves{
        public list<ValvesCurrent> Current;
        public list<ValvesFix> Fix;
    }
    
    public class Pipework{
        public list<PipeworkCurrent> Current;
        public list<PipeworkFix> Fix;
    }
    
    public class CathodicProtection{
        public list<CathodicProtectionCurrent> Current;
        public list<CathodicProtectionFix> Fix;
    }
    
    public class AuxillaryControl{
        public list<AuxillaryControlCurrent> Current;
        public list<AuxillaryControlFix> Fix;
    }
    
    public class AuxillaryRelief{
        public list<AuxillaryReliefCurrent> Current;
        public list<AuxillaryReliefFix> Fix;
    }
    
    public class Filters{
        public list<FiltersCurrent> Current;
        public list<FiltersFix> Fix;
    }
    
    public class Details{
        public String Title { get; set; }
        public String Initials { get; set; }
        public String Surname { get; set; }
        public String ContactTelephoneNumber { get; set; }
        public String SiteName { get; set; }
        public String BuildingName { get; set; }
        public String SubBuildingName { get; set; }
        public String BuildingNumber { get; set; }
        public String DependentStreet { get; set; }
        public String PrincipalStreet { get; set; }
        public String DependentLocality { get; set; }
        public String DoubleDependantLocality { get; set; }
        public String PostTown { get; set; }
        public String County { get; set; }
        public String PostcodeOutcode { get; set; }
        public String PostcodeIncode { get; set; }
        public String GPSEasting { get; set; }
        public String GPSNorthing { get; set; }
        public String AccessInstructions { get; set; }
        public String AccessRestriction { get; set; }
        public String PressureTier { get; set; }
        public String DoesTheSiteContainAsbestos { get; set; }
        public String AsbestosDetails { get; set; }
        public String Bypass { get; set; }
        public String InletPressure { get; set; }
        public String OutletPressure { get; set; }
        public String ConversionFactor { get; set; }
        public String LocationofMpoint { get; set; }
        public String ECVLocationToNetwork { get; set; }
    }
    
    public class Completion{
        public String ServiceNotificationNumber { get; set; }
        public String OperationNumber { get; set; }
        public String SiteID { get; set; }
        public String ShipperID { get; set; }
        public String MeterPointReferenceNumber { get; set; }
        public String ArrivalDate { get; set; }
        public String ArrivalTime { get; set; }
        public String CompletionDate { get; set; }
        public String CompletionTime { get; set; }
        public String StatusReasonCode { get; set; }
        public String JobReasonCode { get; set; }
        public String ReplanTerminationReason { get; set; }
        public String TerminatedCancelledReasonCode { get; set; }
        public String CompletedTerminatedCancelledText { get; set; }
        public String JobReplanReasonCode { get; set; }
        public String JobReplanReasonText { get; set; }
        public String NewAppointmentDate { get; set; }
        //S-660046 START
        public String ReplanRecordedDate { get; set; }
        public String ReplanRecordedTime { get; set; }
        //S-660046 END
        public String NewAppointmentTimeSlot { get; set; }
        public String ContractorID { get; set; }
        public String EngineerResourceID { get; set; }
        public String EngineerContactNumber { get; set; }
        public String ServiceProviderWorkReferenceNumber { get; set; }
        public String PartialCompletion { get; set; }
        public String MeterDetailsAttached { get; set; }
        public String ConvertorDetailsAttached { get; set; }
        public String JobCode { get; set; }
        public String SiteHusbandryChecksFailed { get; set; }
        public String ActionCode { get; set; }
        public String FaultyAsset { get; set; }
        public String RegulatorDetailsAttached { get; set; }
        public String PurgingCompleted { get; set; }
        public String TerminatedCancelReasonCode { get; set; }
        public String CompletedTerminatedCancelText { get; set; }
        public String ReplanTerminationCode { get; set; }
        public String RejectReasonCode { get; set; }
        public String RejectReasonText { get; set; }
        public String SafetyCheck { get; set; }
        public String SafetyCheckReasonCode { get; set; }
        public String SafetyCheckReasonText { get; set; }
        public String ServiceProviderID { get; set; }
        public String ReportIndicator { get; set; }
        public String FinalJobReport { get; set; }
        public String JobOutcome1 { get; set; }
        public String JobOutcome2 { get; set; }
        public String JobOutcome3 { get; set; }

        
    }
    
    public class MPRM{
        public String MPRMRegRepl { get; set; }
        public String MPRMRegReplReason { get; set; }
        public String MPRMCurRegRV1 { get; set; }
        public string MPRMCurRegRV2 { get; set; }
        public string MPRMCurRegRV3 { get; set; }
        public string MPRMCurRegSC1 { get; set; }
        public string MPRMCurRegSC2 { get; set; }
        public string MPRMCurRegSC3 { get; set; }
        public string MPRMNewRegRV1 { get; set; }
        public string MPRMNewRegRV2 { get; set; }
        public string MPRMNewRegRV3 { get; set; }
        public string MPRMNewRegSC1 { get; set; }
        public string MPRMNewRegSC2 { get; set; }
        public string MPRMNewRegSC3 { get; set; }
        public string MPRMVisRegOnsite { get; set; }
        public string MPRMVisWorPres { get; set; }
        public string MPRMVisStaPres { get; set; }
        public string MPRMVisInsEMC { get; set; }
        public string MPRMVisInsEMCCA { get; set; }
        public string MPRMVisInsEMCNR { get; set; }
        public string MPRMVisInsVP1 { get; set; }
        public string MPRMVisInsVP1CA { get; set; }
        public string MPRMVisInsVP1NR { get; set; }
        public string MPRMVisInsVP2 { get; set; }
        public string MPRMVisInsVP2CA { get; set; }
        public string MPRMVisInsVP2NR { get; set; }
        public string MPRMVisInsVPP { get; set; }
        public string MPRMVisInsVPPCA { get; set; }
        public string MPRMVisInsVPPNR { get; set; }
        public string MPRMVisInsEA { get; set; }
        public string MPRMVisInsEACA { get; set; }
        public string MPRMVisInsEANR { get; set; }
        public string MPRMInsRemRes { get; set; }
        public string MPRMInsRemCom { get; set; }
        public string MPRMInsRemNot { get; set; }
        public string MPRMVisInsOT  { get; set; }
        public string MPRMVisInsOTCA  { get; set; }
        public string MPRMVisInsOTNR  { get; set; }
        public string MPRMAssRegOnsite  { get; set; }
        public string MPRMNewRegWpr  { get; set; }
        public string MPRMVisWarNot { get; set; }
        public string MPRMVisWarNotRes { get; set; }
        

    }
    
    public class Payment{
        public String PlannedService { get; set; }
        public String UnplannedServices { get; set; }
        public String UnitOfMeasurement { get; set; }
        public String Quantity { get; set; }
        public String Rate { get; set; }
        public String UnplannedMaterialLabour { get; set; }
    }
    
    public class MeterCurrent{
        public String MeterActivityType { get; set; }
        public String MeterSerialNumber { get; set; }
        public String MeterManufacturer { get; set; }
        public String MeterModel { get; set; }
        public String MeterYearOfManufacture { get; set; }
        public String InstalledOnStream { get; set; }
        public String MeterStatusCode { get; set; }
        public String MeterType { get; set; }
        public String MeterMechanism { get; set; }
        public String MeterNumberOfDials { get; set; }
        public String MeterImperialFlag { get; set; }
        public String MeterLocationCode { get; set; }
        public String MeterLocationNotes { get; set; }
        public String ThirdPartyMeter { get; set; }
        public String MeterRead { get; set; }
        public String MeterReadDate { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String PhysicalSize { get; set; }
        public String MaterialType { get; set; }
        public String MeterLinkCode { get; set; }
        public String PressureRead { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
        public String Qmax { get; set; }
    }
    
    public class MeterFix{
        public String NewMeterSerialNumber { get; set; }
        public String NewMeterManufacturer { get; set; }
        public String NewMeterModel { get; set; }
        public String NewMeterYearOfManufacture { get; set; }
        public String NewMeterInstalledOnStream { get; set; }
        public String NewMeterStatusCode { get; set; }
        public String NewMeterType { get; set; }
        public String NewMeterMechanism { get; set; }
        public String NewMeterNumberOfDials { get; set; }
        public String NewMeterLocationCode { get; set; }
        public String NewMeterLocationNotes { get; set; }
        public String OpeningRead { get; set; }
        public String OpeningReadDate { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String PhysicalSize { get; set; }
        public String MaterialType { get; set; }
        public String FlowComputerrImperialIndicator { get; set; }
        public String NewMeterImperialIndicator { get; set; }
        public String NewMeterImperialFlag { get; set; }
        public String MeterLinkCode { get; set; }
        public String PressureRead { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
        public String Qmax { get; set; }
        public String NewMeterActivityType { get; set; }
    }
    
    /*public class RegulatorCurrent{
        public string RegulatorActivityType {get;set;}
        public string RegulatorFunction{get;set;}
        public string RegulatorSerialNumber{get;set;}
        public string RegulatorManufacturer{get;set;}
        public string RegulatorModel{get;set;}
        public string RegulatorYearOfManufacture{get;set;}
        public string InstalledOnStream{get;set;}
        public string RegulatorSetPoint{get;set;}
        public string DateInstalled{get;set;}
        public string PrimaryFunction{get;set;}
        public string PhysicalSize{get;set;}
        public string PressureRead{get;set;}
        public string ConnectionSize{get;set;}
        public string ConnectionType{get;set;}
    }
    public class RegulatorFix{
        public string NewRegulatorFunction{get;set;}
        public string NewRegulatorSerialNumber{get;set;}
        public string NewRegulatorManufacturer{get;set;}
        public string NewRegulatorModel{get;set;}
        public string NewRegulatorYearOfManufacture{get;set;}
        public string NewInstalledOnStream{get;set;}
        public string NewRegulatorSetPoint{get;set;}
        public string DateInstalled{get;set;}
        public string PrimaryFunction{get;set;}
        public string PhysicalSize{get;set;}
        public string PressureRead{get;set;}
        public string ConnectionSize{get;set;}
        public string ConnectionType{get;set;}
        public string NewRegulatorActivityType{get;set;}
    }*/
    
    public class ConvertorCurrent{
        public String ConvertorActivityType { get; set; }
        public String ConvertorSerialNumber { get; set; }
        public String ConvertorManufacturer { get; set; }
        public String ConvertorModel { get; set; }
        public String ConvertorYearOfManufacture { get; set; }
        public string InstalledOnStream { get; set; }
        public String ConvertorStatusCode { get; set; }
        public String ConvertorLocationCode { get; set; }
        public String ConvertorLocationNotes { get; set; }
        public String ConvertorNumberOfDials { get; set; }
        public String ConvertorNumberOfUnits { get; set; }
        public String ConvertorImperialIndicator { get; set; }
        public String DateInstalled { get; set; }
        }
    
    public class ConvertorFix{
        public String ConvertorSerialNumber { get; set; } // old SAP Vairable 
        public String ConvertorManufacturer { get; set; } // old SAP Vairable 
        public String ConvertorModel { get; set; } // old SAP Vairable 
        public String ConvertorYearOfManufacture { get; set; } // old SAP Vairable 
        public String ConvertorStatusCode { get; set; } // old SAP Vairable 
        public String ConvertorLocationCode { get; set; } // old SAP Vairable 
        public String ConvertorLocationNotes { get; set; } // old SAP Vairable 
        public String ConvertorNumberOfDials { get; set; } // old SAP Vairable 
        public String ConvertorImperialIndicator { get; set; } // old SAP Vairable 
        public String DateInstalled { get; set; }
        public string NewConvertorActivityType { get; set; }
        
    }
    
    public class ConvertorReadingsAndData{
        public string UnconvertedReadingAsLeft   { get; set; }
        public string UnconvertedReadingAsFound  { get; set; }
        public string TemperatureConvertorReading    { get; set; }
        public string GaugePressureConverterReading  { get; set; }
        public string ConvertedReadingAsLeft     { get; set; }
        public string ConvertedReadingAsFound    { get; set; }
        public string ConversionFactor   { get; set; }
        public string AtmosphericPressure    { get; set; }
        public string AbsolutePressureConvertorReading   { get; set; }
    }
    
    public class ConvertorFixReadingsAndData{
        public string TemperatureConvertorReading  { get; set; }
        public string NewInstalledOnStream   { get; set; }
        public string GaugePressureConverterReading  { get; set; }
        public string ConversionFactor   { get; set; }
        public string AtmosphericPressure    { get; set; }
        public string AbsolutePressureConvertorReading   { get; set; }
        public string UnconvertedReadingAsFound{ get; set; }
        public string OpeningUnconvertedReading { get; set; }
        public string OpeningConvertedReading { get; set; }
        public string ConvertedReadingAsFound { get; set; }
    }
    
    public class FlowComputerCurrent{
        public String FlowComputerActivityType { get; set; }
        public String FlowComputerSerialNumber { get; set; }
        public String FlowComputerManufacturer { get; set; }
        public String FlowComputerModel { get; set; }
        public String FlowComputerYearOfManufacture { get; set; }
        public String InstalledOnStream { get; set; }
        public String DateInstalled { get; set; }
        public String FlowComputerLocationCode { get; set; }
        public String FlowComputerrImperialIndicator { get; set; }
        public String UnconvertedReadingAsFound { get; set; }
        public String ConvertedReadingAsFound { get; set; }
        public String UnconvertedReadingAsLeft { get; set; }
        public String ConvertedReadingAsLeft { get; set; }
        public String FlowComputerNumberOfDials { get; set; }
    }
    
    public class FlowComputerFix{
        public String FlowComputerSerialNumber { get; set; }
        public String FlowComputerManufacturer { get; set; }
        public String FlowComputerModel { get; set; }
        public String FlowComputerYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String FlowComputerLocationCode { get; set; }
        public String FlowComputerrImperialIndicator { get; set; }
        public String NewUnconvertedReadingAsFound { get; set; }
        public String NewConvertedReadingAsFound { get; set; }
        public String FlowComputerNumberOfDials { get; set; }
        public String NewInstalledOnStream { get; set; }
        public String NewFlowComputerActivityType { get; set; }
    }
    
    public class SlamShutCurrent{
        public String InstalledOnStream { get; set; }
        public String SlamShutActivityType { get; set; }
        public String SlamShutSerialNumber { get; set; }
        public String SlamShutManufacturer { get; set; }
        public String SlamShutModel { get; set; }
        public String SlamShutYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String PhysicalSize { get; set; }
        public String PressureRead { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
    }
    
    public class SlamShutFix{
        public String SlamShutSerialNumber { get; set; }
        public String SlamShutManufacturer { get; set; }
        public String SlamShutModel { get; set; }
        public String SlamShutYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String PhysicalSize { get; set; }
        public String PressureRead { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
        public String NewInstalledOnStream { get; set; }
        public String NewSlamShutActivityType { get; set; }
    }
    
    Public class CreepReliefCurrent{
        public String InstalledOnStream { get; set; }
        public String CreepReliefActivityType { get; set; }
        public String CreepReliefSerialNumber { get; set; }
        public String CreepReliefManufacturer { get; set; }
        public String CreepReliefModel { get; set; }
        public String CreepReliefYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String PhysicalSize { get; set; }
        public String PressureRead { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
        
    }
    
    public class CreepReliefFix{
        public String NewInstalledOnStream { get; set; }
        public String CreepReliefSerialNumber { get; set; }
        public String CreepReliefManufacturer { get; set; }
        public String CreepReliefModel { get; set; }
        public String CreepReliefYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String PhysicalSize { get; set; }
        public String PressureRead { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
        public String NewCreepReliefActivityType { get; set; }
    }
    
    public class BoilerCurrent{
        public String BoilerActivityType { get; set; }
        public String BoilerSerialNumber { get; set; }
        public String BoilerManufacturer { get; set; }
        public String BoilerModel { get; set; }
        public String BoilerYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String InstalledOnStream { get; set; }
    }
    
    public class BoilerFix{
        public String NewInstalledOnStream { get; set; }
        public String BoilerSerialNumber { get; set; }
        public String BoilerManufacturer { get; set; }
        public String BoilerModel { get; set; }
        public String BoilerYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String NewBoilerActivityType { get; set; }
    }
    
    public class WaterBathHeatersCurrent{
        public String InstalledOnStream { get; set; }
        public String WaterBathHeatersActivityType { get; set; }
        public String WaterBathHeatersSerialNumber { get; set; }
        public String WaterBathHeatersManufacturer { get; set; }
        public String WaterBathHeatersModel { get; set; }
        public String WaterBathHeatersYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
    }
    
    public class WaterBathHeatersFix{
        public String NewInstalledOnStream { get; set; }
        public String WaterBathHeatersSerialNumber { get; set; }
        public String WaterBathHeatersManufacturer { get; set; }
        public String WaterBathHeatersModel { get; set; }
        public String WaterBathHeatersYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String NewWaterBathHeatersActivityType { get; set; }
    }
    
    public class ShellandTubeCurrent{
        public String InstalledOnStream { get; set; }
        public String ShellandTubeActivityType { get; set; }
        public String ShellandTubeSerialNumber { get; set; }
        public String ShellandTubeManufacturer { get; set; }
        public String ShellandTubeModel { get; set; }
        public String ShellandTubeYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
    }
    
    public class ShellandTubeFix{
        public String ShellandTubeSerialNumber { get; set; }
        public String ShellandTubeManufacturer { get; set; }
        public String ShellandTubeModel { get; set; }
        public String ShellandTubeYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String NewInstalledOnStream { get; set; }
        public String NewShellandTubeActivityType { get; set; }
    }
    
    public class ChromatographCurrent{
        public String ChromatographActivityType { get; set; }
        public String ChromatographSerialNumber { get; set; }
        public String ChromatographManufacturer { get; set; }
        public String ChromatographModel { get; set; }
        public String ChromatographYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String InstalledOnStream { get; set; }
    }
    
    public class ChromatographFix{
        public String ChromatographSerialNumber { get; set; }
        public String ChromatographManufacturer { get; set; }
        public String ChromatographModel { get; set; }
        public String ChromatographYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String NewInstalledOnStream { get; set; }
        public String NewChromatographActivityType { get; set; }
    }
    
    public class DensitometerCurrent{
        public String DensitometerActivityType { get; set; }
        public String DensitometerSerialNumber { get; set; }
        public String DensitometerManufacturer { get; set; }
        public String DensitometerModel { get; set; }
        public String DensitometerYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String InstalledOnStream { get; set; }
        
    }
    
    public class DensitometerFix{
        public String DensitometerSerialNumber { get; set; }
        public String DensitometerManufacturer { get; set; }
        public String DensitometerModel { get; set; }
        public String DensitometerYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String NewInstalledOnStream { get; set; }
        public String NewDensitometerActivityType { get; set; }
    }
    
    public class ValvesCurrent{
        public String ValvesActivityType { get; set; }
        public String ValvesSerialNumber { get; set; }
        public String ValvesManufacturer { get; set; }
        public String ValvesModel { get; set; }
        public String ValvesYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String PhysicalSize { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
        public String InstalledOnStream { get; set; }
    }
    
    public class ValvesFix{
        public String ValvesSerialNumber { get; set; }
        public String ValvesManufacturer { get; set; }
        public String ValvesModel { get; set; }
        public String ValvesYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String PhysicalSize { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
        public String NewInstalledOnStream { get; set; }
        public String NewValvesActivityType { get; set; }
    }
    
    public class PipeworkCurrent{
        public String PipeworkActivityType { get; set; }
        public String PipeworkLocationCode { get; set; }
        public String PhysicalSize { get; set; }
        public String MaterialType { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
        public String InstalledOnStream { get; set; }
    }
    
    public class PipeworkFix{
        public String PipeworkLocationCode { get; set; }
        public String PhysicalSize { get; set; }
        public String MaterialType { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
        public String InstalledOnStream { get; set; }
        public String NewPipeworkActivityType { get; set; }
    }
    
    public class CathodicProtectionCurrent{
        public String CathodicProtectionActivityType { get; set; }
        public String CathodicProtectionManufacturer { get; set; }
        public String CathodicProtectionModel { get; set; }
        public String DateInstalled { get; set; }
        public String MaterialType { get; set; }
        public String InstalledOnStream { get; set; }
    }
    
    public class CathodicProtectionFix{
        public String CathodicProtectionManufacturer { get; set; }
        public String CathodicProtectionModel { get; set; }
        public String DateInstalled { get; set; }
        public String MaterialType { get; set; }
        public String NewInstalledOnStream { get; set; }
        public String NewCathodicProtectionActivityType { get; set; }
    }
    
    public class AuxillaryControlCurrent{
        public String AuxillaryControlActivityType { get; set; }
        public String AuxillaryControlSerialNumber { get; set; }
        public String AuxillaryControlManufacturer { get; set; }
        public String AuxillaryControlModel { get; set; }
        public String AuxillaryControlYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
        public String InstalledOnStream { get; set; }
        public String PressureRead { get; set; }
    }
    
    public class AuxillaryControlFix{
        public String AuxillaryControlSerialNumber { get; set; }
        public String AuxillaryControlManufacturer { get; set; }
        public String AuxillaryControlModel { get; set; }
        public String AuxillaryControlYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
        public String NewInstalledOnStream { get; set; }
        public String NewAuxillaryControlActivityType { get; set; }
        public String PressureRead { get; set; }
    }
    
    public class AuxillaryReliefCurrent{
        public String AuxillaryReliefActivityType { get; set; }
        public String AuxillaryReliefSerialNumber { get; set; }
        public String AuxillaryReliefManufacturer { get; set; }
        public String AuxillaryReliefModel { get; set; }
        public String AuxillaryReliefYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
        public String InstalledOnStream { get; set; }
        public String PressureRead { get; set; }
    }
    
    public class AuxillaryReliefFix{
        public String AuxillaryReliefSerialNumber { get; set; }
        public String AuxillaryReliefManufacturer { get; set; }
        public String AuxillaryReliefModel { get; set; }
        public String AuxillaryReliefYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
        public String NewInstalledOnStream { get; set; }
        public String NewAuxillaryReliefActivityType { get; set; }
        public String PressureRead { get; set; }
    }
    
    public class FiltersCurrent{
        public String FiltersActivityType { get; set; }
        public String FiltersSerialNumber { get; set; }
        public String FiltersManufacturer { get; set; }
        public String FiltersModel { get; set; }
        public String FilterYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String PhysicalSize { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
        public String InstalledOnStream { get; set; }
        public String PressureRead { get; set; }
    }
    
    public class FiltersFix{
        public String FiltersSerialNumber { get; set; }
        public String FiltersManufacturer { get; set; }
        public String FiltersModel { get; set; }
        public String FilterYearOfManufacture { get; set; }
        public String DateInstalled { get; set; }
        public String PrimaryFunction { get; set; }
        public String PhysicalSize { get; set; }
        public String ConnectionSize { get; set; }
        public String ConnectionType { get; set; }
        public String NewInstalledOnStream { get; set; }
        public String NewFiltersActivityType { get; set; }
        public String PressureRead { get; set; }
    }
}