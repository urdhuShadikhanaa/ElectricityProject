/* ***************************************************************************************
   ***************************************************************************************
 
 * Name       : FFA_WorkOrderCompleteInterface 
 * 
 * CreatedBy  : Venkat
 * Task       :T-811721
 * Description:When Workorder Status Set to Complete,Further work required ,terminated
                or cancelled Workorder Will be Pushed to SAP with All Assets
                with Status as current or FIX in JSON
 * UPDATES    : 1.S-649680 :ADDED REJECT CONDITION AS PER S-649680 :DOMESTIC ENHANCEMET 
                2.S-649680 :ADDED SP REPLAN CONDITION AS PER S-649680 :DOMESTIC ENHANCEMET
                3.S-658453 :VENKAT[11June2020]: MPRM FC & VI Warning Notice Issued Information needs to be passed back to SAP          
   ***************************************************************************************
   *****************************************************************************************               
 */
public class FFA_WorkOrderCompleteInterface {
    //*From Trigger on Workorder 'CompletedWorkorders' Function Will be called with respective workorder IDS
    //*Based on Workorder ID,Workorder and its assets with all details will be fetched.After processing logic
    //*it will hit SAP via OAG with JSON
   @Future(callout=true)
    public static void completedWorkorders(String toDeserialize){
        system.debug(toDeserialize);
        Set<id> serializeWorkorderIDS= new Set<id>();
        List<WorkOrder> replanUncheck=new List<WorkOrder>();
        List<WorkOrder> policyUncheck=new List<WorkOrder>();
        List<WorkOrder> SAPReplanUncheck=new List<WorkOrder>();
        if(toDeserialize!=null)
        serializeWorkorderIDS=(Set<Id>)System.JSON.deserialize(toDeserialize, Set<ID>.class);
        system.debug(serializeWorkorderIDS);
        String WONUMBER;
        String failedPayload;
        //**WRAPPER INSTANCES FOR TO HOLD DATA OF WORKORDES
        //   SITES,NGV ASSETS ,ADDITIONAL COSTS **//
        try{
        //GETTING ALL HARDCODE CONSTANTS FROM METADATA
        
        FFA_WorkOrderCompleteInterfaceWrapper FFA_WCIW = new FFA_WorkOrderCompleteInterfaceWrapper();
        FFA_WorkOrderCompleteInterfaceWrapper.Header headers = new FFA_WorkOrderCompleteInterfaceWrapper.Header(); 
        FFA_WorkOrderCompleteInterfaceWrapper.Job workOrders = new FFA_WorkOrderCompleteInterfaceWrapper.Job(); 
        FFA_WorkOrderCompleteInterfaceWrapper.Site Sites = new FFA_WorkOrderCompleteInterfaceWrapper.Site();
        FFA_WorkOrderCompleteInterfaceWrapper.Meter Meters = new FFA_WorkOrderCompleteInterfaceWrapper.Meter();
        //FFA_WorkOrderCompleteInterfaceWrapper.Regulator Regulators = new FFA_WorkOrderCompleteInterfaceWrapper.Regulator();
        FFA_WorkOrderCompleteInterfaceWrapper.Convertor Convertors = new FFA_WorkOrderCompleteInterfaceWrapper.Convertor();
        FFA_WorkOrderCompleteInterfaceWrapper.FlowComputer FlowComputers = new FFA_WorkOrderCompleteInterfaceWrapper.FlowComputer();
        FFA_WorkOrderCompleteInterfaceWrapper.SlamShut SlamShuts = new FFA_WorkOrderCompleteInterfaceWrapper.SlamShut();
        FFA_WorkOrderCompleteInterfaceWrapper.CreepRelief CreepReliefs = new FFA_WorkOrderCompleteInterfaceWrapper.CreepRelief();
        FFA_WorkOrderCompleteInterfaceWrapper.Boiler Boilers = new FFA_WorkOrderCompleteInterfaceWrapper.Boiler();
        FFA_WorkOrderCompleteInterfaceWrapper.WaterBathHeaters WaterBathHeater = new FFA_WorkOrderCompleteInterfaceWrapper.WaterBathHeaters();
        FFA_WorkOrderCompleteInterfaceWrapper.ShellandTube ShellandTubes = new FFA_WorkOrderCompleteInterfaceWrapper.ShellandTube();
        FFA_WorkOrderCompleteInterfaceWrapper.Chromatograph Chromatographs = new FFA_WorkOrderCompleteInterfaceWrapper.Chromatograph();
        FFA_WorkOrderCompleteInterfaceWrapper.Densitometer Densitometers = new FFA_WorkOrderCompleteInterfaceWrapper.Densitometer();
        FFA_WorkOrderCompleteInterfaceWrapper.Valves Valve = new FFA_WorkOrderCompleteInterfaceWrapper.Valves();
        FFA_WorkOrderCompleteInterfaceWrapper.Pipework Pipeworks = new FFA_WorkOrderCompleteInterfaceWrapper.Pipework();
        FFA_WorkOrderCompleteInterfaceWrapper.CathodicProtection CathodicProtections = new FFA_WorkOrderCompleteInterfaceWrapper.CathodicProtection();
        FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryControl AuxillaryControls = new FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryControl();
        FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryRelief AuxillaryReliefs = new FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryRelief();
        FFA_WorkOrderCompleteInterfaceWrapper.Filters Filter = new FFA_WorkOrderCompleteInterfaceWrapper.Filters();
        String WorkOrderID;
        
        Boolean IsfilterActivityE=False;
        Boolean isValveActivityE=False;
        Boolean isRegulatorActivityE=False;
        Boolean isSlamshutActivityE=False;
        Boolean isCreepReliefActivityE=False;
        Boolean isBoilerActivityE=False;
        String ValvesStructeredJson;
        String slamshutStructeredJson;
        String biolerStructeredJson;
        String filterStructeredJson;
        String creepReliefStructeredJson;
        
        list<WorkOrder> SenderId=[select id,FFA_Sender_ID__c from WorkOrder
                                Where id=: SerializeWorkorderIDS limit 1];
         List<WorkOrder> WorkOrderFetchedList = new List<WorkOrder>();
            set<string> assetSet=new set<string>();
            set<id> assetId=new set<id>();
        //**   QUERY WILL GET ALL ASSETS OF WORKORDER 
        //    QUERY WILL GET ALL SITE,ADDITIONAL COSTS **//
        for(WorkOrder sender:SenderId)
        {
            if(sender.FFA_Sender_ID__c=='PHOENIX')
            {
                WorkOrderFetchedList=[Select id,WorkOrderNumber,FFA_PurgingCompleted__c,FFA_PartialCompletion__c,FFA_ServiceProviderWorkReferenceNumber__c,PolicyReplanJob__c,
                                FFA_EngineerContactNumber__c,AnySiteHusbandary__c,FFA_ContractorID__c,FFA_Sender_ID__c,FFA_EngineerResourceID__c,FFA_NewAppointmentTimeSlot__c,
                                FFA_NewAppointmentDate__c,FFA_JobReplanReasonText__c,FFA_JobReplanReasonCode__c,FFA_CompletedTerminatedCancelledText__c,FFA_JobCode__c,Further_Work_Required__c,
                                FFA_RejectReasonCode__c,FFA_RejectReasonText__c,FFA_StatusReasonCode__c,FFA_TerminatedCancelledReasonCode__c,Completion_Date__c,FFA_ServiceProvider__c,FFA_SP_Mobile_Replan_Days__c,
                                FFA_ArrivalTime__c,FFA_ArrivalDate__c,FFA_MeterPointReferenceNumber__c,FFA_ShipperID__c,FFA_SiteID__c,FFA_Final_Job_Report__c ,FFA_JOC3__c,FFA_JOC2__c,FFA_JOC1__c,SAP_Replan__c,FFA_Replan_Date_Time__c,
                                FFA_ServiceNotificationNumber__c,FFA_OperationNumber__c,Discount,Status,/*FFA_SPReplan__c,*/FFA_Service_Provider_Replan__c,FFA_RequestedAppointmentDate__c,FFA_RequestedAppointmentTimeslot__c,
                                (Select id,FFA_Serial_Number__c,FFA_Asset_Type__c,FFA_Connection_size__c,FFA_Asset_Status__c,FFA_Manufacturer__c,
                                 FFA_Model__c,FFA_ThirdPartyMeter__c,FFA_Year_of_Manufacturer__c,FFA_Location_Notes_Fix__c,FFA_Installed_On_Stream__c,FFA_Meter_Type__c,FFA_Payment_Method__c,
                                 FFA_Meter_Link_Status__c,FFA_Meter_Mechanism__c,FFA_Meter_Mechanism_Fix__c,FFA_Installed_On_Stream_Fix__c,FFA_Readable_Dials__c,FFA_Metric_or_Imperial_Indicator__c,FFA_Qmax__c,FFA_Pressure_Read__c,
                                 FFA_Date_Installed__c,FFA_Activity_Type__c,FFA_Primary_Function__c,FFA_Physical_Size__c,FFA_Meter_Read__c,FFA_Connection_type__c,FFA_Meter_Reading_Date__c,FFA_Meter_Reading_Date_Fix__c,
                                 FFA_Unrecorded_Meter_Manufacturer__c,FFA_Unrecorded_Meter_Model__c,FFA_Single_Twin__c,FFA_Single_Twin_fix__c,
                                 FFA_Location_Notes__c,FFA_Location__c,Serial_Number_Fix__c,FFA_Connection_size_Fix__c,FFA_Connection_Type_Fix__c,FFA_Converted_Read_Fix__c,
                                 FFA_Date_Installed_Fix__c,FFA_Location_Fix__c,FFA_Manufacturer_Fix__c,FFA_Material_Type_Fix__c,FFA_IsRegulatorOnSite__c,FFA_IsMeterOnSite__c,    
                                 FFAMeterLinkStatusFix__c,FFA_Material_Type__c,FFA_Meter_Read_Fix__c,FFA_Meter_Type_Fix__c,FFA_Metric_Imperial_Indicator_Fix__c,
                                 FFA_Model_Fix__c,FFA_Physical_Size_Fix__c,FFA_Pressure_Read_Fix__c,FFA_Primary_Function_Fix__c,FFA_Qmax_Fix__c,
                                 FFA_Readable_Dials_Fix__c,FFA_Unconverted_Read_Fix__c,FFA_Year_of_Manufacturer_Fix__c,FFA_UnConvertedReadingFound__c,FFA_ConvertedReadFound__c,FFA_Unconverted_readings_as_left_Fix__c,FFA_Converted_Reading_As_Left_Fix__c,
                                 FFA_Gauge_Pressure_Fix__c,FFA_Atmospheric_pressure_mBar_Fix__c,FFA_Absolute_Pres_Convertor_Reading_Fix__c,FFA_Temperature_Convertor_Reading_Fix__c,FFA_Atmospheric_Pressure__c,FFA_Conversion_Factor_Fix__c,
                                 FFA_Converter_status_code__c,FFA_Asset_Status_Fix__c,FFA_NoOfDials__c,FFA_UnconvertedLeft__c,FFA_ConvertedLeft__c,FFA_GaugePressure__c,FFA_TI_Absolute_Pressure__c,FFA_TI_Temperature_Reading__c,FFA_Conversion_Factor__c,
                                 FFA_Other_Manufacturer_fix__c,FFA_Other_Manufacturer__c,FFA_Other_Model__c,FFA_Other_Model_fix__c,FFA_Regulator_Removed__c,FFA_Batch_Number_Fix__c,
                                 FFA_Converter_Status_Code_Fix__c,FFA_Regulator_required_to_be_replaced__c,FFA_Regulator_replace_reason__c,
                                 FFA_Current_Reg_Serial_Number_Selection__c,FFA_Cur_Reg_Batch_Selection__c,FFA_Regulator_Batch_Number__c from FFA_Assets__r),
                                 (SELECT Id,FFA_MaterialCostType__c,FAA_LabourCostType__c,FAA_AddCostType__c,FFA_MaterialQuantity__c,FAA_LabourHours__c from FFA_AddCosts__r),
                                 (SELECT ID,FFA_AnySiteHusbandary__c,FFA_Object_Type__c,FFA_Safety_Check_Reason_Code__c,FFA_Safety_Check_Reason_Text__c,FFA_Safety_Check_Complete__c from Job_Informations__r),
                                 Site__r.Name,Site__r.FFA_Title__c,Site__r.FFA_Initials__c,Site__r.Site_Name__c,Site__r.FFA_Surname__c,Site__r.FFA_ContactTelephoneNumber__c,
                                Site__r.FFA_BuildingName__c,Site__r.FFA_SubBuildingName__c,Site__r.FFA_BuildingNumber__c,Site__r.FFA_DependentStreet__c,Site__r.FFA_PrincipalStreet__c,
                                Site__r.FFA_DependentLocality__c,Site__r.FFA_DoubleDependantLocality__c,Site__r.FFA_PostTown__c,Site__r.FFA_County__c,Site__r.FFA_PostcodeOutcode__c,
                                Site__r.FFA_PostcodeIncode__c,Site__r.FFA_GPSEasting__c,Site__r.FFA_GPSNorthing__c,Site__r.FFA_AccessInstructions__c,Site__r.FFA_AccessRestrictions__c,
                                Site__r.FFA_PressureTier__c,Site__r.FFA_DoesTheSiteContainAsbestos__c
                                from WorkOrder
                                Where id=: SerializeWorkorderIDS limit 1];
                                system.debug('WorkOrderFetchedListPhoenix->'+WorkOrderFetchedList);
            }
            else
            {
                list<workorder> WorkOrderFetchedListForAsset=[Select id,WorkOrderNumber,FFA_PurgingCompleted__c,FFA_PartialCompletion__c,FFA_ServiceProviderWorkReferenceNumber__c,PolicyReplanJob__c,
                                FFA_EngineerContactNumber__c,AnySiteHusbandary__c,FFA_ContractorID__c,FFA_Sender_ID__c,FFA_EngineerResourceID__c,FFA_NewAppointmentTimeSlot__c,
                                FFA_NewAppointmentDate__c,FFA_JobReplanReasonText__c,FFA_JobReplanReasonCode__c,FFA_CompletedTerminatedCancelledText__c,FFA_JobCode__c,Further_Work_Required__c,
                                FFA_RejectReasonCode__c,FFA_RejectReasonText__c,FFA_StatusReasonCode__c,FFA_TerminatedCancelledReasonCode__c,Completion_Date__c,FFA_ServiceProvider__c,FFA_SP_Mobile_Replan_Days__c,
                                FFA_ArrivalTime__c,FFA_ArrivalDate__c,FFA_MeterPointReferenceNumber__c,FFA_ShipperID__c,FFA_SiteID__c,FFA_Final_Job_Report__c ,FFA_JOC3__c,FFA_JOC2__c,FFA_JOC1__c,SAP_Replan__c,FFA_Replan_Date_Time__c,
                                FFA_ServiceNotificationNumber__c,FFA_OperationNumber__c,Discount,Status,/*FFA_SPReplan__c,*/FFA_Service_Provider_Replan__c,FFA_RequestedAppointmentDate__c,FFA_RequestedAppointmentTimeslot__c,
                                (Select id,FFA_Serial_Number__c,FFA_Asset_Type__c,FFA_Connection_size__c,FFA_Asset_Status__c,FFA_Manufacturer__c,
                                 FFA_Model__c,FFA_ThirdPartyMeter__c,FFA_Year_of_Manufacturer__c,FFA_Location_Notes_Fix__c,FFA_Installed_On_Stream__c,FFA_Meter_Type__c,FFA_Payment_Method__c,
                                 FFA_Meter_Link_Status__c,FFA_Meter_Mechanism__c,FFA_Meter_Mechanism_Fix__c,FFA_Installed_On_Stream_Fix__c,FFA_Readable_Dials__c,FFA_Metric_or_Imperial_Indicator__c,FFA_Qmax__c,FFA_Pressure_Read__c,
                                 FFA_Date_Installed__c,FFA_Activity_Type__c,FFA_Primary_Function__c,FFA_Physical_Size__c,FFA_Meter_Read__c,FFA_Connection_type__c,FFA_Meter_Reading_Date__c,FFA_Meter_Reading_Date_Fix__c,
                                 FFA_Unrecorded_Meter_Manufacturer__c,FFA_Unrecorded_Meter_Model__c,FFA_Single_Twin__c,FFA_Single_Twin_fix__c,
                                 FFA_Location_Notes__c,FFA_Location__c,Serial_Number_Fix__c,FFA_Connection_size_Fix__c,FFA_Connection_Type_Fix__c,FFA_Converted_Read_Fix__c,
                                 FFA_Date_Installed_Fix__c,FFA_Location_Fix__c,FFA_Manufacturer_Fix__c,FFA_Material_Type_Fix__c,FFA_IsRegulatorOnSite__c,FFA_IsMeterOnSite__c,    
                                 FFAMeterLinkStatusFix__c,FFA_Material_Type__c,FFA_Meter_Read_Fix__c,FFA_Meter_Type_Fix__c,FFA_Metric_Imperial_Indicator_Fix__c,
                                 FFA_Model_Fix__c,FFA_Physical_Size_Fix__c,FFA_Pressure_Read_Fix__c,FFA_Primary_Function_Fix__c,FFA_Qmax_Fix__c,
                                 FFA_Readable_Dials_Fix__c,FFA_Unconverted_Read_Fix__c,FFA_Year_of_Manufacturer_Fix__c,FFA_UnConvertedReadingFound__c,FFA_ConvertedReadFound__c,FFA_Unconverted_readings_as_left_Fix__c,FFA_Converted_Reading_As_Left_Fix__c,
                                 FFA_Gauge_Pressure_Fix__c,FFA_Atmospheric_pressure_mBar_Fix__c,FFA_Absolute_Pres_Convertor_Reading_Fix__c,FFA_Temperature_Convertor_Reading_Fix__c,FFA_Atmospheric_Pressure__c,FFA_Conversion_Factor_Fix__c,
                                 FFA_Converter_status_code__c,FFA_Asset_Status_Fix__c,FFA_NoOfDials__c,FFA_UnconvertedLeft__c,FFA_ConvertedLeft__c,FFA_GaugePressure__c,FFA_TI_Absolute_Pressure__c,FFA_TI_Temperature_Reading__c,FFA_Conversion_Factor__c,
                                 FFA_Other_Manufacturer_fix__c,FFA_Other_Manufacturer__c,FFA_Other_Model__c,FFA_Other_Model_fix__c,FFA_Regulator_Removed__c,FFA_Batch_Number_Fix__c,
                                 FFA_Converter_Status_Code_Fix__c,FFA_Regulator_required_to_be_replaced__c,FFA_Regulator_replace_reason__c,
                                 FFA_Current_Reg_Serial_Number_Selection__c,FFA_Cur_Reg_Batch_Selection__c,FFA_Regulator_Batch_Number__c from FFA_Assets__r ORDER BY createddate DESC),
                                 (SELECT Id,FFA_MaterialCostType__c,FAA_LabourCostType__c,FAA_AddCostType__c,FFA_MaterialQuantity__c,FAA_LabourHours__c from FFA_AddCosts__r),
                                 (SELECT ID,FFA_AnySiteHusbandary__c,FFA_Object_Type__c,FFA_Safety_Check_Reason_Code__c,FFA_Safety_Check_Reason_Text__c,FFA_Safety_Check_Complete__c from Job_Informations__r),
                                 Site__r.Name,Site__r.FFA_Title__c,Site__r.FFA_Initials__c,Site__r.Site_Name__c,Site__r.FFA_Surname__c,Site__r.FFA_ContactTelephoneNumber__c,
                                Site__r.FFA_BuildingName__c,Site__r.FFA_SubBuildingName__c,Site__r.FFA_BuildingNumber__c,Site__r.FFA_DependentStreet__c,Site__r.FFA_PrincipalStreet__c,
                                Site__r.FFA_DependentLocality__c,Site__r.FFA_DoubleDependantLocality__c,Site__r.FFA_PostTown__c,Site__r.FFA_County__c,Site__r.FFA_PostcodeOutcode__c,
                                Site__r.FFA_PostcodeIncode__c,Site__r.FFA_GPSEasting__c,Site__r.FFA_GPSNorthing__c,Site__r.FFA_AccessInstructions__c,Site__r.FFA_AccessRestrictions__c,
                                Site__r.FFA_PressureTier__c,Site__r.FFA_DoesTheSiteContainAsbestos__c
                                from WorkOrder
                                Where id=: SerializeWorkorderIDS limit 1];
                                system.debug('WorkOrderFetchedListForAsset->'+WorkOrderFetchedListForAsset);
                                
                                  for(WorkOrder WorkorderList : WorkOrderFetchedListForAsset)
                                    {
                                        for(FFA_NGV_Asset__c AssetList : WorkorderList.FFA_Assets__r)
                                        {
                                            //if(!AssetList.FFA_Asset_Type__c.containsAll(assetSet))
                                            if(!assetSet.contains(AssetList.FFA_Asset_Type__c))
                                            {
                                                assetSet.add(AssetList.FFA_Asset_Type__c);
                                                assetId.add(AssetList.Id);
                                            }
                                            
                                        }
                                    }
                                system.debug('assetSet'+assetSet);
                                system.debug('assetId'+assetId);
                                WorkOrderFetchedList=[Select id,WorkOrderNumber,FFA_PurgingCompleted__c,FFA_PartialCompletion__c,FFA_ServiceProviderWorkReferenceNumber__c,PolicyReplanJob__c,
                                FFA_EngineerContactNumber__c,AnySiteHusbandary__c,FFA_ContractorID__c,FFA_Sender_ID__c,FFA_EngineerResourceID__c,FFA_NewAppointmentTimeSlot__c,
                                FFA_NewAppointmentDate__c,FFA_JobReplanReasonText__c,FFA_JobReplanReasonCode__c,FFA_CompletedTerminatedCancelledText__c,FFA_JobCode__c,Further_Work_Required__c,
                                FFA_RejectReasonCode__c,FFA_RejectReasonText__c,FFA_StatusReasonCode__c,FFA_TerminatedCancelledReasonCode__c,Completion_Date__c,FFA_ServiceProvider__c,FFA_SP_Mobile_Replan_Days__c,
                                FFA_ArrivalTime__c,FFA_ArrivalDate__c,FFA_MeterPointReferenceNumber__c,FFA_ShipperID__c,FFA_SiteID__c,FFA_Final_Job_Report__c ,FFA_JOC3__c,FFA_JOC2__c,FFA_JOC1__c,SAP_Replan__c,FFA_Replan_Date_Time__c,
                                FFA_ServiceNotificationNumber__c,FFA_OperationNumber__c,Discount,Status,/*FFA_SPReplan__c,*/FFA_Service_Provider_Replan__c,FFA_RequestedAppointmentDate__c,FFA_RequestedAppointmentTimeslot__c,
                                (Select id,FFA_Serial_Number__c,FFA_Asset_Type__c,FFA_Connection_size__c,FFA_Asset_Status__c,FFA_Manufacturer__c,
                                 FFA_Model__c,FFA_ThirdPartyMeter__c,FFA_Year_of_Manufacturer__c,FFA_Location_Notes_Fix__c,FFA_Installed_On_Stream__c,FFA_Meter_Type__c,FFA_Payment_Method__c,
                                 FFA_Meter_Link_Status__c,FFA_Meter_Mechanism__c,FFA_Meter_Mechanism_Fix__c,FFA_Installed_On_Stream_Fix__c,FFA_Readable_Dials__c,FFA_Metric_or_Imperial_Indicator__c,FFA_Qmax__c,FFA_Pressure_Read__c,
                                 FFA_Date_Installed__c,FFA_Activity_Type__c,FFA_Primary_Function__c,FFA_Physical_Size__c,FFA_Meter_Read__c,FFA_Connection_type__c,FFA_Meter_Reading_Date__c,FFA_Meter_Reading_Date_Fix__c,
                                 FFA_Unrecorded_Meter_Manufacturer__c,FFA_Unrecorded_Meter_Model__c,FFA_Single_Twin__c,FFA_Single_Twin_fix__c,
                                 FFA_Location_Notes__c,FFA_Location__c,Serial_Number_Fix__c,FFA_Connection_size_Fix__c,FFA_Connection_Type_Fix__c,FFA_Converted_Read_Fix__c,
                                 FFA_Date_Installed_Fix__c,FFA_Location_Fix__c,FFA_Manufacturer_Fix__c,FFA_Material_Type_Fix__c,FFA_IsRegulatorOnSite__c,FFA_IsMeterOnSite__c,    
                                 FFAMeterLinkStatusFix__c,FFA_Material_Type__c,FFA_Meter_Read_Fix__c,FFA_Meter_Type_Fix__c,FFA_Metric_Imperial_Indicator_Fix__c,
                                 FFA_Model_Fix__c,FFA_Physical_Size_Fix__c,FFA_Pressure_Read_Fix__c,FFA_Primary_Function_Fix__c,FFA_Qmax_Fix__c,
                                 FFA_Readable_Dials_Fix__c,FFA_Unconverted_Read_Fix__c,FFA_Year_of_Manufacturer_Fix__c,FFA_UnConvertedReadingFound__c,FFA_ConvertedReadFound__c,FFA_Unconverted_readings_as_left_Fix__c,FFA_Converted_Reading_As_Left_Fix__c,
                                 FFA_Gauge_Pressure_Fix__c,FFA_Atmospheric_pressure_mBar_Fix__c,FFA_Absolute_Pres_Convertor_Reading_Fix__c,FFA_Temperature_Convertor_Reading_Fix__c,FFA_Atmospheric_Pressure__c,FFA_Conversion_Factor_Fix__c,
                                 FFA_Converter_status_code__c,FFA_Asset_Status_Fix__c,FFA_NoOfDials__c,FFA_UnconvertedLeft__c,FFA_ConvertedLeft__c,FFA_GaugePressure__c,FFA_TI_Absolute_Pressure__c,FFA_TI_Temperature_Reading__c,FFA_Conversion_Factor__c,
                                 FFA_Other_Manufacturer_fix__c,FFA_Other_Manufacturer__c,FFA_Other_Model__c,FFA_Other_Model_fix__c,FFA_Regulator_Removed__c,FFA_Batch_Number_Fix__c,
                                 FFA_Converter_Status_Code_Fix__c,FFA_Regulator_required_to_be_replaced__c,FFA_Regulator_replace_reason__c,
                                 FFA_Current_Reg_Serial_Number_Selection__c,FFA_Cur_Reg_Batch_Selection__c,FFA_Regulator_Batch_Number__c from FFA_Assets__r where id=:assetId),
                                 (SELECT Id,FFA_MaterialCostType__c,FAA_LabourCostType__c,FAA_AddCostType__c,FFA_MaterialQuantity__c,FAA_LabourHours__c from FFA_AddCosts__r),
                                 (SELECT ID,FFA_AnySiteHusbandary__c,FFA_Object_Type__c,FFA_Safety_Check_Reason_Code__c,FFA_Safety_Check_Reason_Text__c,FFA_Safety_Check_Complete__c from Job_Informations__r),
                                 Site__r.Name,Site__r.FFA_Title__c,Site__r.FFA_Initials__c,Site__r.Site_Name__c,Site__r.FFA_Surname__c,Site__r.FFA_ContactTelephoneNumber__c,
                                Site__r.FFA_BuildingName__c,Site__r.FFA_SubBuildingName__c,Site__r.FFA_BuildingNumber__c,Site__r.FFA_DependentStreet__c,Site__r.FFA_PrincipalStreet__c,
                                Site__r.FFA_DependentLocality__c,Site__r.FFA_DoubleDependantLocality__c,Site__r.FFA_PostTown__c,Site__r.FFA_County__c,Site__r.FFA_PostcodeOutcode__c,
                                Site__r.FFA_PostcodeIncode__c,Site__r.FFA_GPSEasting__c,Site__r.FFA_GPSNorthing__c,Site__r.FFA_AccessInstructions__c,Site__r.FFA_AccessRestrictions__c,
                                Site__r.FFA_PressureTier__c,Site__r.FFA_DoesTheSiteContainAsbestos__c
                                from WorkOrder
                                Where id=: SerializeWorkorderIDS limit 1];
                                //system.debug('WorkOrderFetchedListRainbow->'+ WorkOrderFetchedList.FFA_Assets__r);
              
                    
               }
        }
        
        List<WorkOrder> ActivityTypeCheck=[Select id,WorkOrderNumber,
                                          (Select id,FFA_Asset_Type__c,FFA_Activity_Type__c from FFA_Assets__r WHERE FFA_Asset_Type__c in('Valve','Slamshut','Regulator','Creep Relief','Boiler','Filter'))
                                          from WorkOrder Where id=:SerializeWorkorderIDS limit 1];
        if(!ActivityTypeCheck.isEmpty()){                                  
            for(WorkOrder AssetActivityCheck:ActivityTypeCheck){
                 WONUMBER=AssetActivityCheck.WorkOrderNumber;
                  If(!AssetActivityCheck.FFA_Assets__r.isEmpty()){
                      for(FFA_NGV_Asset__c Activity : AssetActivityCheck.FFA_Assets__r){
                           if(Activity.FFA_Asset_Type__c==FFA_Constants.FFA_VALVES && Activity.FFA_Activity_Type__c==FFA_Constants.ActivityTypeE ){
                               isValveActivityE=True;
                           }
                           if(Activity.FFA_Asset_Type__c==FFA_Constants.FFA_SLAMSHUT && Activity.FFA_Activity_Type__c==FFA_Constants.ActivityTypeE){
                               isSlamshutActivityE=True;
                           }
                           if(Activity.FFA_Asset_Type__c==FFA_Constants.FFA_REGULATOR && Activity.FFA_Activity_Type__c==FFA_Constants.ActivityTypeE ){
                               isRegulatorActivityE=True;
                           } 
                           if(Activity.FFA_Asset_Type__c==FFA_Constants.FFA_FILTER && Activity.FFA_Activity_Type__c==FFA_Constants.ActivityTypeE ){
                               IsfilterActivityE=True;
                           }
                           if(Activity.FFA_Asset_Type__c==FFA_Constants.FFA_BOILER && Activity.FFA_Activity_Type__c==FFA_Constants.ActivityTypeE ){
                               isBoilerActivityE=True;
                           }
                           if(Activity.FFA_Asset_Type__c==FFA_Constants.FFA_CREEPRELIEF && Activity.FFA_Activity_Type__c==FFA_Constants.ActivityTypeE ){
                               isCreepReliefActivityE=True;
                           }     
                      }
                  }   
            } 
        }                                     
                                          
        
        FFA_WorkOrderCompleteInterfaceWrapper.WrapperBody jsonWrapper = new FFA_WorkOrderCompleteInterfaceWrapper.WrapperBody();
        //**FINAL WRAPPER WHICH HOLDS THE DATA
        FFA_WorkOrderCompleteInterfaceWrapper.body Jobs_toSend = new FFA_WorkOrderCompleteInterfaceWrapper.body();
        FFA_WorkOrderCompleteInterfaceWrapper.Completion completiondetails = new FFA_WorkOrderCompleteInterfaceWrapper.Completion();
        list<FFA_WorkOrderCompleteInterfaceWrapper.Payment> PaymentList = new list<FFA_WorkOrderCompleteInterfaceWrapper.Payment>();
        FFA_WorkOrderCompleteInterfaceWrapper.Details SiteDetails = new FFA_WorkOrderCompleteInterfaceWrapper.Details();
        FFA_WorkOrderCompleteInterfaceWrapper.MPRM MPRMSJOBs = new FFA_WorkOrderCompleteInterfaceWrapper.MPRM();
        
        //**  CREATING INSTANCES FOR CURRENT AND FIX FOR ALL ASSETS
        //    TO HOLD THE DATA                                  //
        list<FFA_WorkOrderCompleteInterfaceWrapper.ConvertorCurrent> ConvertorCurrentList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.ConvertorCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.ConvertorFix> ConvertorFixList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.ConvertorFix>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.ConvertorReadingsAndData> ConvertorReadingsAndDataList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.ConvertorReadingsAndData>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.ConvertorFixReadingsAndData> ConvertorFixReadingsAndDataList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.ConvertorFixReadingsAndData>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.MeterCurrent> MeterCurrentList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.MeterCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.MeterFix> MeterFixList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.MeterFix>();
        //list<FFA_WorkOrderCompleteInterfaceWrapper.RegulatorCurrent> RegulatorCurrentList = new list<FFA_WorkOrderCompleteInterfaceWrapper.RegulatorCurrent>();
        //list<FFA_WorkOrderCompleteInterfaceWrapper.RegulatorFix> RegulatorFixList = new list<FFA_WorkOrderCompleteInterfaceWrapper.RegulatorFix>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.FlowComputerCurrent> FlowComputerCurrentList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.FlowComputerCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.FlowComputerFix> FlowComputerFixList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.FlowComputerFix>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.SlamShutCurrent> SlamShutCurrentList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.SlamShutCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.SlamShutFix> SlamShutFixList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.SlamShutFix>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.CreepReliefCurrent> CreepReliefCurrentList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.CreepReliefCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.CreepReliefFix> CreepReliefFixList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.CreepReliefFix>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.BoilerCurrent> BoilerCurrentList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.BoilerCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.BoilerFix> BoilerFixList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.BoilerFix>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.WaterBathHeatersCurrent> WaterBathHeaterCurrentList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.WaterBathHeatersCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.WaterBathHeatersFix> WaterBathHeaterFixList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.WaterBathHeatersFix>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.ShellandTubeCurrent> ShellAndtubeCurrentList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.ShellandTubeCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.ShellandTubeFix> ShellAndTubeFixList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.ShellandTubeFix>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.ChromatographCurrent> ChromatographCurrentList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.ChromatographCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.ChromatographFix> ChromatographFixList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.ChromatographFix>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.DensitometerCurrent> DensitometerCurrentList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.DensitometerCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.DensitometerFix> DensitometerFixList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.DensitometerFix>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.ValvesCurrent> CurrentValvesList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.ValvesCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.ValvesFix> FixValvesList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.ValvesFix>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.PipeworkCurrent> PipeWorkCurrentList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.PipeworkCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.PipeworkFix> PipeWorkFixList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.PipeworkFix>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.CathodicProtectionCurrent> CathodicProtectionCurrentList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.CathodicProtectionCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.CathodicProtectionFix> CathodicProtectionFixList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.CathodicProtectionFix>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryControlCurrent> AuxillaryControlCurrentList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryControlCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryControlFix> AuxillaryControlFixList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryControlFix>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryReliefCurrent> AuxillaryReliefCurrentList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryReliefCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryReliefFix> AuxillaryReliefFixList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryReliefFix>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.FiltersCurrent> FiltersCurrentList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.FiltersCurrent>();
        list<FFA_WorkOrderCompleteInterfaceWrapper.FiltersFix> FiltersFixList = new  list<FFA_WorkOrderCompleteInterfaceWrapper.FiltersFix>();
        
        // **FOR REQGULATOR SAP REQUIRED CURRENT AND FIX DETAILS IN 
        // A SPECIFIC ORDER TO IDETENTIFY CURRENT AND FIX IN SAP DATABASE,SO CUSTOMIZED
        // THE LOGIC WITH DUPLICATE NODES **//   
        //REGULATOR WRAPPERS AND LISTS                               
        //FA_WorkOrderCompleteInterfaceWrapper.RegulatorCurrent RegulatorCurrent = new FFA_WorkOrderCompleteInterfaceWrapper.RegulatorCurrent();
        //FFA_WorkOrderCompleteInterfaceWrapper.RegulatorFix RegulatorFix = new FFA_WorkOrderCompleteInterfaceWrapper.RegulatorFix();
        
        list<String> RegulatorValueJsonList = new list<String>();
            string RegulatorMainJson;
            string RegulatorInnerJson;
            string RegulatorInnerfinalJson;
            boolean isRegulatorCheck = false;
            dateTime FFACompletionDate;
        Set<id> MPRMids=new Set<id>();
        Set<id> RegMPRM=new Set<id>();    
        //HOLDING DATA USING WRAPPERS FROM QUERIED BY SOQL    
         for(WorkOrder Wraplist: WorkOrderFetchedList){
           
            if(Wraplist!=null){
            //** WRAPPER HEADER  **//
                if(Wraplist.status==FFA_Constants.FFAWorkOrderStatusComplete){
                    headers.TransactionType = FFA_Constants.FFATRANSACTIONN64;
                    headers.InterfaceName = FFA_Constants.FFASFCOMPLETION;
                }
                if(Wraplist.Status==FFA_Constants.FFAWorkOrderStatusCancelled){
                    headers.TransactionType = FFA_Constants.FFATRANSACTIONN66;
                    headers.InterfaceName = FFA_Constants.FFASFCANCEL;
                }
                if(Wraplist.Status==FFA_Constants.FFAWorkOrderStatusTerminated){
                    headers.TransactionType = FFA_Constants.FFATRANSACTIONN65;
                    headers.InterfaceName = FFA_Constants.FFASFTERMINATE;
                }
                if(Wraplist.status==FFA_Constants.FFAWorkOrderStatusFWR || Wraplist.FFA_Service_Provider_Replan__c==FFA_Constants.Yes ||Wraplist.SAP_Replan__c=='Yes'){
                    headers.TransactionType = FFA_Constants.FFATRANSACTIONN67;
                    headers.InterfaceName = FFA_Constants.FFASFREPLAN;
                }
                if(Wraplist.status==FFA_Constants.FFAWorkOrderStatusRejected){
                    headers.TransactionType = FFA_Constants.FFATRANSACTIONN68;
                    headers.InterfaceName = FFA_Constants.FFASFREJECT;
                }
                if(Wraplist.PolicyReplanJob__c==true){
                    policyUncheck.add(Wraplist);
                    headers.TransactionType = FFA_Constants.FFATRANSACTIONN75;
                    headers.InterfaceName = FFA_Constants.FFASFPOLICYJOB;
                }
                IF(Wraplist.SAP_Replan__c=='Yes'){
                SAPReplanUncheck.add(Wraplist);
                }
                headers.SenderID = 'FFA'; 
                headers.ReceiverID = Wraplist.FFA_Sender_ID__c!=null ? Wraplist.FFA_Sender_ID__c:'';
                IF(Wraplist.FFA_Sender_ID__c==FFA_Constants.FFARAINBOW){
                    headers.FileType = FFA_Constants.FFAFileType;
                }
                else{
                headers.FileType =FFA_Constants.FFASFCOMPLETION;
                }
                
                headers.CreationDate = '';//string.valueof(system.today())
                headers.CreationTime = ''; 
                if(Wraplist.Completion_Date__c!=null){
                    //added changes by Prachi
                    if(Wraplist.status== FFA_Constants.FFAWorkOrderStatusTerminated)
                         {
                      FFACompletionDate= DateTime.ValueofGmt(Wraplist.Completion_Date__c.replace('T', ' '));
                         system.debug('FFACompletionDate terminated'+ FFACompletionDate);
                         }
                    
            FFACompletionDate= DateTime.Valueof(Wraplist.Completion_Date__c.replace('T',' ').replace('z',' '));
                         system.debug('FFACompletionDate others'+ FFACompletionDate);

                }
                
                //** IT WILL INVOKE 'FFA_WorkOrderCompleteInterfaceWrapper.Completion' WRAPPER AND IT WILL SEND DATA TO 
                //*   COMPLETION NODE of JOB     //
                completiondetails.ServiceNotificationNumber = Wraplist.FFA_ServiceNotificationNumber__c!=null ? Wraplist.FFA_ServiceNotificationNumber__c:'';
                completiondetails.OperationNumber =Wraplist.FFA_OperationNumber__c!=null ? Wraplist.FFA_OperationNumber__c:'';
                completiondetails.SiteID  =Wraplist.FFA_SiteID__c!=null ? Wraplist.FFA_SiteID__c:'';
                completiondetails.ShipperID   =Wraplist.FFA_ShipperID__c!=null ? Wraplist.FFA_ShipperID__c:'';
                completiondetails.MeterPointReferenceNumber=  Wraplist.FFA_MeterPointReferenceNumber__c!=null ? Wraplist.FFA_MeterPointReferenceNumber__c:'';
                completiondetails.ServiceProviderId=Wraplist.FFA_ServiceProvider__c!=null ? Wraplist.FFA_ServiceProvider__c :'';
                if(Wraplist.FFA_ArrivalDate__c!=null){
                    completiondetails.ArrivalDate=  convertDateFormattoSAP(Wraplist.FFA_ArrivalDate__c.date());
                }
                if(Wraplist.FFA_ArrivalDate__c!=null){
                    string ArrTime=Wraplist.FFA_ArrivalDate__c.format('HH:mm:ss');
                if(string.isNotBlank(ArrTime))
                    ArrTime=ArrTime.replaceAll(':','');
                    completiondetails.ArrivalTime =ArrTime;
                }
                if(Wraplist.Completion_Date__c!=null){
                    completiondetails.CompletionDate=convertDateFormattoSAP(FFACompletionDate.date());
                }
                if(Wraplist.Completion_Date__c!=null){
                    string CompTime=FFACompletionDate.format('HH:mm:ss');
                    if(string.isNotBlank(CompTime))
                    CompTime=CompTime.replaceAll(':','');
                    completiondetails.CompletionTime=CompTime;
                }
                completiondetails.TerminatedCancelledReasonCode   =Wraplist.FFA_TerminatedCancelledReasonCode__c!=null ? Wraplist.FFA_TerminatedCancelledReasonCode__c:'';
                completiondetails.CompletedTerminatedCancelledText=   Wraplist.FFA_CompletedTerminatedCancelledText__c!=null ? Wraplist.FFA_CompletedTerminatedCancelledText__c:'';
                completiondetails.JobReplanReasonCode =Wraplist.FFA_JobReplanReasonCode__c!=null ? Wraplist.FFA_JobReplanReasonCode__c:'';
                completiondetails.JobReplanReasonText =Wraplist.FFA_JobReplanReasonText__c!=null ? Wraplist.FFA_JobReplanReasonText__c :'';
                completiondetails.JobCode=Wraplist.FFA_JobCode__c!=null ? Wraplist.FFA_JobCode__c:'';
                completiondetails.StatusReasonCode= Wraplist.FFA_StatusReasonCode__c!=null ? Wraplist.FFA_StatusReasonCode__c :''; 
                completiondetails.NewAppointmentDate= string.valueof(Wraplist.FFA_NewAppointmentDate__c)!=null ? string.valueof(Wraplist.FFA_NewAppointmentDate__c):'';
                completiondetails.NewAppointmentTimeSlot  =Wraplist.FFA_NewAppointmentTimeSlot__c!=null ? Wraplist.FFA_NewAppointmentTimeSlot__c:'';
                completiondetails.ContractorID    =Wraplist.FFA_ContractorID__c!=null ? Wraplist.FFA_ContractorID__c:'';
                completiondetails.EngineerResourceID  =Wraplist.FFA_EngineerResourceID__c!=null ? Wraplist.FFA_EngineerResourceID__c :'';
                completiondetails.EngineerContactNumber   =Wraplist.FFA_EngineerContactNumber__c!=null ? Wraplist.FFA_EngineerContactNumber__c :'';
                if(Wraplist.FFA_Sender_ID__c==FFA_Constants.FFARAINBOW){
                     completiondetails.ServiceProviderWorkReferenceNumber  =string.valueOf(Wraplist.FFA_ServiceProviderWorkReferenceNumber__c)!=null ? string.valueOf(Wraplist.FFA_ServiceProviderWorkReferenceNumber__c) :'';
                }
                else{
                    completiondetails.ServiceProviderWorkReferenceNumber  =Wraplist.Workordernumber;
                }
                
                completiondetails.PartialCompletion=  Wraplist.FFA_PartialCompletion__c!=null ? Wraplist.FFA_PartialCompletion__c:'';
                completiondetails.PurgingCompleted    ='N';
                
                //**BY DEFAULT 'SiteHusbandryChecksFailed' TO BE AS 'N',IF IT FIND ANY 'YES',THEN IT WILL CONSIDERED AS 'Y'.
                //  IN SAP ITS A REQUIRED FIELD TO GENERATE IDOC ,EITHER WE NEED TO SEND 'N' OT 'Y'                    **//
                if(Wraplist.AnySiteHusbandary__c=='Yes'){
                      completiondetails.SiteHusbandryChecksFailed = 'Y';
                }else{
                     completiondetails.SiteHusbandryChecksFailed = 'N';
                }
                //REQUIRED FIELDS IN SAP,IF METER,CONVERTOR OR REGULATOR HAVE WORKORDER
                //NEEDS SEND INDICATOR TO SAP,BY DEAFULT N AND IT WILL BE OVERIDE TO 'Y' 
                //IF WORKORDER CONTAINS ANY OF ABOVE
                completiondetails.MeterDetailsAttached = 'N';
                completiondetails.ConvertorDetailsAttached = 'N';
                completiondetails.RegulatorDetailsAttached = 'N';
                
                if(Wraplist.status==FFA_Constants.FFAWorkOrderStatusComplete){
                completiondetails.StatusReasonCode= Wraplist.FFA_StatusReasonCode__c!=null ? Wraplist.FFA_StatusReasonCode__c:'';
                completiondetails.FinalJobReport= Wraplist.FFA_Final_Job_Report__c !=null ? Wraplist.FFA_Final_Job_Report__c :'';
                completiondetails.JobOutcome1=Wraplist.FFA_JOC1__c !=null ? Wraplist.FFA_JOC1__c :'';
                completiondetails.JobOutcome2=Wraplist.FFA_JOC2__c !=null ? Wraplist.FFA_JOC2__c :'';
                completiondetails.JobOutcome3=Wraplist.FFA_JOC3__c !=null ? Wraplist.FFA_JOC3__c :'';
                }
                if(Wraplist.Status=='Cancelled'){
                    completiondetails.JobReasonCode ='CM';
                    completiondetails.CompletedTerminatedCancelText ='CANCELLED BY MAM';
                    completiondetails.TerminatedCancelReasonCode   = 'OTHER';
                    completiondetails.TerminatedCancelledReasonCode='OTHER';
                    IF(Wraplist.FFA_TerminatedCancelledReasonCode__c==null && Wraplist.FFA_Sender_ID__c=='RAIBOW'){
                        completiondetails.TerminatedCancelReasonCode = 'CM';
                    }
                  
                }
                if(Wraplist.Status=='Terminated'){
                    completiondetails.JobReasonCode =  Wraplist.FFA_TerminatedCancelledReasonCode__c!=null ? Wraplist.FFA_TerminatedCancelledReasonCode__c :'';
                    completiondetails.TerminatedCancelReasonCode = 'OTHER';
                    completiondetails.TerminatedCancelledReasonCode='OTHER';
                    completiondetails.CompletedTerminatedCancelText =Wraplist.FFA_CompletedTerminatedCancelledText__c!=null ? Wraplist.FFA_CompletedTerminatedCancelledText__c :'';
                    completiondetails.FinalJobReport= Wraplist.FFA_Final_Job_Report__c !=null ? Wraplist.FFA_Final_Job_Report__c :'';
                }
                if(Wraplist.status=='Further Work Required'){
                
                    //completiondetails.ReplanTerminationReason = 'OTHER';
                    completiondetails.JobReplanReasonCode =Wraplist.FFA_StatusReasonCode__c!=null ? Wraplist.FFA_StatusReasonCode__c:'';
                    completiondetails.JobReplanReasonText =Wraplist.FFA_JobReplanReasonText__c!=null ? Wraplist.FFA_JobReplanReasonText__c:'';
                }
                //ADDED REJECT CONDITION AS PER S-649680 :DOMESTIC ENHANCEMET
                if(Wraplist.Status=='Rejected'){
                    completiondetails.RejectReasonCode = Wraplist.FFA_RejectReasonCode__c!=null ? Wraplist.FFA_RejectReasonCode__c :'';
                    completiondetails.RejectReasonText = Wraplist.FFA_RejectReasonText__c!=null ? Wraplist.FFA_RejectReasonText__c :'';
                    
                }
                system.debug('Wraplist.FFA_Service_Provider_Replan__c----'+Wraplist.FFA_Service_Provider_Replan__c+Wraplist.FFA_JobReplanReasonCode__c);
                if(Wraplist.FFA_Service_Provider_Replan__c=='Yes' || Wraplist.SAP_Replan__c=='Yes'){
                system.debug('Replan in----');
                    replanUncheck.add(Wraplist);
                    IF(Wraplist.FFA_JobReplanReasonCode__c==null && Wraplist.FFA_Sender_ID__c=='RAINBOW'){
                        completiondetails.JobReplanReasonCode = 'RM';
                        
                    }
                    else{
                        completiondetails.JobReplanReasonCode = Wraplist.FFA_JobReplanReasonCode__c!=null ? Wraplist.FFA_JobReplanReasonCode__c :'';
                    }
                    completiondetails.JobReplanReasonText = Wraplist.FFA_JobReplanReasonText__c!=null ? Wraplist.FFA_JobReplanReasonText__c :'';
                }
                if(Wraplist.status=='Further Work Required' || Wraplist.FFA_Service_Provider_Replan__c=='Yes' || Wraplist.PolicyReplanJob__c==True || Wraplist.SAP_Replan__c=='Yes'){
                    //Prod BUG ,As Discussced With MAHESH,NewAppointmentDate and NewAppointmentTimeSlot will be sent for RAINBOW SYSTEMS
                    IF(Wraplist.FFA_Sender_ID__c==FFA_Constants.FFARAINBOW){
                        completiondetails.NewAppointmentDate= string.valueof(Wraplist.FFA_RequestedAppointmentDate__c)!=null ? string.valueof(Wraplist.FFA_RequestedAppointmentDate__c):'';
                        completiondetails.NewAppointmentTimeSlot  =Wraplist.FFA_RequestedAppointmentTimeslot__c!=null ? Wraplist.FFA_RequestedAppointmentTimeslot__c:'';
                        IF(Wraplist.FFA_Replan_Date_Time__c!=null){
                            completiondetails.ReplanRecordedDate=convertDateFormattoSAP(Wraplist.FFA_Replan_Date_Time__c.date());
                            string repTime=Wraplist.FFA_Replan_Date_Time__c.format('HH:mm:ss');
                            if(string.isNotBlank(repTime))
                            repTime=repTime.replaceAll(':','');
                            completiondetails.ReplanRecordedTime=repTime;
                        }
                        
                    }
                    else{
                        completiondetails.NewAppointmentDate= '';
                        completiondetails.NewAppointmentTimeSlot  ='';
                     
                    }
                    completiondetails.ReplanTerminationReason = 'OTHER';
                }
                for(Job_Information__c jobInfo: Wraplist.Job_Informations__r){
                    if(jobInfo.FFA_Object_Type__c=='Safety Checks'){
                        if(jobInfo.FFA_Safety_Check_Complete__c=='Yes'){
                            completiondetails.SafetyCheck='Y';
                        }
                        if(jobInfo.FFA_Safety_Check_Complete__c=='No'){
                            completiondetails.SafetyCheck='N';
                        }
                        if(jobInfo.FFA_Safety_Check_Reason_Code__c!=null ){
                            if(jobInfo.FFA_Safety_Check_Reason_Code__c.contains('01')){
                                completiondetails.SafetyCheckReasonCode='01';
                            }
                            if(jobInfo.FFA_Safety_Check_Reason_Code__c.contains('02')){
                                completiondetails.SafetyCheckReasonCode='02';
                            }
                            if(jobInfo.FFA_Safety_Check_Reason_Code__c.contains('49')){
                                 completiondetails.SafetyCheckReasonCode='49';
                            }
                        }
                        completiondetails.SafetyCheckReasonText=jobInfo.FFA_Safety_Check_Reason_Text__c;
                    }
                    MPRMids.add(jobInfo.ID);
                }
                //FFA_WorkOrderCompleteInterfaceWrapper.MPRM MPRMSJOBs = new FFA_WorkOrderCompleteInterfaceWrapper.MPRM();
                
                WorkOrderID=Wraplist.Workordernumber+'-'+System.today();
                //* IT WILL INVOKE 'FFA_WorkOrderCompleteInterfaceWrapper.Payment pay' WRAPPER and Send the data to Payment Child Node
                //* of Job Node
                if(Wraplist.FFA_AddCosts__r!=null || Wraplist.status!='Rejected' && Wraplist.PolicyReplanJob__c==False){
                for(FFA_AddCost__c Additionalcosts : Wraplist.FFA_AddCosts__r){
                    if(Wraplist.status=='Completed'){
                        FFA_WorkOrderCompleteInterfaceWrapper.Payment pay = new FFA_WorkOrderCompleteInterfaceWrapper.Payment();
                        pay.PlannedService = '';//FAA_AddCostType__c
                        //pay.UnplannedServices = Additionalcosts.FAA_LabourCostType__c;
                        pay.UnplannedServices = string.valueof(Additionalcosts.FAA_LabourCostType__c)!=null ? string.valueof(Additionalcosts.FAA_LabourCostType__c):'';
                        if(Additionalcosts.FAA_LabourCostType__c==null){
                         pay.UnplannedServices=string.valueof(Additionalcosts.FFA_MaterialCostType__c)!=null ?string.valueof(Additionalcosts.FFA_MaterialCostType__c):'';
                        }
                        pay.UnitOfMeasurement = 'JOB';
                        pay.Quantity = string.valueof(Additionalcosts.FFA_MaterialQuantity__c)!=null ? string.valueof(Additionalcosts.FFA_MaterialQuantity__c):'';
                        if(Additionalcosts.FFA_MaterialQuantity__c==null){
                         pay.Quantity=string.valueof(Additionalcosts.FAA_LabourHours__c)!=null ? string.valueof(Additionalcosts.FAA_LabourHours__c):'';
                        }
                        pay.Rate = '';
                        pay.UnplannedMaterialLabour = Additionalcosts.FAA_AddCostType__c!=null ? Additionalcosts.FAA_AddCostType__c:'';
                        PaymentList.add(pay);
                     }
                  }
                }
                //** SITE DETAILS WILL CAPTURE AND SEND TO WRAPPER **//
                IF(Wraplist.PolicyReplanJob__c==False){
                SiteDetails.Title   =   Wraplist.Site__r.FFA_Title__c!=null ? Wraplist.Site__r.FFA_Title__c:'';
                SiteDetails.Initials    = Wraplist.Site__r.FFA_Initials__c!=null ? Wraplist.Site__r.FFA_Initials__c:'';
                SiteDetails.Surname=     Wraplist.Site__r.FFA_Surname__c!=null ? Wraplist.Site__r.FFA_Surname__c:'';
                SiteDetails.ContactTelephoneNumber=  Wraplist.Site__r.FFA_ContactTelephoneNumber__c!=null ? Wraplist.Site__r.FFA_ContactTelephoneNumber__c:'';
                SiteDetails.SiteName    =    Wraplist.Site__r.Site_Name__c!=null ? Wraplist.Site__r.Site_Name__c:'';
                SiteDetails.BuildingName    =Wraplist.Site__r.FFA_BuildingName__c!=null ? Wraplist.Site__r.FFA_BuildingName__c:'';
                SiteDetails.SubBuildingName=    Wraplist.Site__r.FFA_SubBuildingName__c!=null ? Wraplist.Site__r.FFA_SubBuildingName__c:'';
                SiteDetails.BuildingNumber  =Wraplist.Site__r.FFA_BuildingNumber__c!=null ? Wraplist.Site__r.FFA_BuildingNumber__c:'';
                SiteDetails.DependentStreet=    Wraplist.Site__r.FFA_DependentStreet__c!=null ? Wraplist.Site__r.FFA_DependentStreet__c:'';
                SiteDetails.PrincipalStreet =Wraplist.Site__r.FFA_PrincipalStreet__c!=null ? Wraplist.Site__r.FFA_PrincipalStreet__c:'';
                SiteDetails.DependentLocality   =Wraplist.Site__r.FFA_DependentLocality__c!=null ? Wraplist.Site__r.FFA_DependentLocality__c:'';
                SiteDetails.DoubleDependantLocality=    Wraplist.Site__r.FFA_DoubleDependantLocality__c!=null ? Wraplist.Site__r.FFA_DoubleDependantLocality__c:'';
                SiteDetails.PostTown=   Wraplist.Site__r.FFA_PostTown__c!=null ? Wraplist.Site__r.FFA_PostTown__c:'';
                SiteDetails.County  =Wraplist.Site__r.FFA_County__c!=null ? Wraplist.Site__r.FFA_County__c:'';
                SiteDetails.PostcodeOutcode=    Wraplist.Site__r.FFA_PostcodeOutcode__c!=null ? Wraplist.Site__r.FFA_PostcodeOutcode__c:'';
                SiteDetails.PostcodeIncode= Wraplist.Site__r.FFA_PostcodeIncode__c!=null ? Wraplist.Site__r.FFA_PostcodeIncode__c:'';
                SiteDetails.GPSEasting  =Wraplist.Site__r.FFA_GPSEasting__c!=null ? Wraplist.Site__r.FFA_GPSEasting__c:'';
                SiteDetails.GPSNorthing=    Wraplist.Site__r.FFA_GPSNorthing__c!=null ? Wraplist.Site__r.FFA_GPSNorthing__c:'';
                SiteDetails.AccessInstructions  =Wraplist.Site__r.FFA_AccessInstructions__c!=null ? Wraplist.Site__r.FFA_AccessInstructions__c:'';
                SiteDetails.AccessRestriction=  Wraplist.Site__r.FFA_AccessRestrictions__c!=null ? Wraplist.Site__r.FFA_AccessRestrictions__c:'';
                SiteDetails.PressureTier    =Wraplist.Site__r.FFA_PressureTier__c!=null ? Wraplist.Site__r.FFA_PressureTier__c:'';
                //SiteDetails.DoesTheSiteContainAsbestos    =Wraplist.Site__r.FFA_DoesTheSiteContainAsbestos__c;
                //*All Assets will be captured and hold it on Corresponding Asset Wrapper
                }
                if(Wraplist.FFA_Assets__r!=null && Wraplist.PolicyReplanJob__c==False){
                    for(FFA_NGV_Asset__c NGR : Wraplist.FFA_Assets__r){
                    //*If Asset Type is Meter
                    if(NGR.FFA_Asset_Type__c ==FFA_Constants.FFA_METER){ 
                        //METER CURRENT DETAILS
                        FFA_WorkOrderCompleteInterfaceWrapper.MeterCurrent CurrentMeter = new  FFA_WorkOrderCompleteInterfaceWrapper.MeterCurrent();
                        CurrentMeter.MeterActivityType = NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:''; 
                         IF(NGR.FFA_IsMeterOnSite__c!='No'){     
                        CurrentMeter.MeterSerialNumber=NGR.FFA_Serial_Number__c!=null ? NGR.FFA_Serial_Number__c:'';
                        if(NGR.FFA_Unrecorded_Meter_Manufacturer__c !=null){
                            CurrentMeter.MeterManufacturer=NGR.FFA_Unrecorded_Meter_Manufacturer__c !=null ? NGR.FFA_Unrecorded_Meter_Manufacturer__c :'';
                        }
                        else if(NGR.FFA_Other_Manufacturer__c !=null){
                            CurrentMeter.MeterManufacturer=NGR.FFA_Other_Manufacturer__c!=null ? NGR.FFA_Other_Manufacturer__c:'';
                        }
                        else{
                            CurrentMeter.MeterManufacturer=NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';
                        }
                        //CurrentMeter.MeterModel=NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                        if(NGR.FFA_Unrecorded_Meter_Model__c!=null){
                          CurrentMeter.MeterModel=NGR.FFA_Unrecorded_Meter_Model__c!=null ? NGR.FFA_Unrecorded_Meter_Model__c:'';  
                        }
                        else if(NGR.FFA_Other_Model__c!=null){
                            CurrentMeter.MeterModel=NGR.FFA_Other_Model__c!=null ? NGR.FFA_Other_Model__c:'';  
                        }
                        else{
                          CurrentMeter.MeterModel=NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';  
                        }
                        CurrentMeter.MeterYearOfManufacture=NGR.FFA_Year_of_Manufacturer__c!=null ? NGR.FFA_Year_of_Manufacturer__c:'';
                        CurrentMeter.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                        CurrentMeter.MeterStatusCode=NGR.FFA_Asset_Status__c!=null ? NGR.FFA_Asset_Status__c:'';
                        CurrentMeter.MeterType=NGR.FFA_Meter_Type__c!=null ? NGR.FFA_Meter_Type__c:'';
                        CurrentMeter.MeterMechanism=NGR.FFA_Meter_Mechanism__c!=null ? NGR.FFA_Meter_Mechanism__c:'';
                        CurrentMeter.MeterNumberOfDials=string.valueOf(NGR.FFA_Readable_Dials__c)!=null ? string.valueOf(NGR.FFA_Readable_Dials__c):'';
                        CurrentMeter.MeterImperialFlag=NGR.FFA_Metric_or_Imperial_Indicator__c!=null ? NGR.FFA_Metric_or_Imperial_Indicator__c:'';
                        if(string.isNotBlank(NGR.FFA_Location__c)){
                            CurrentMeter.MeterLocationCode=getLocationCode(NGR.FFA_Location__c);
                        }
                        CurrentMeter.MeterLocationNotes=NGR.FFA_Location_Notes__c!=null ? NGR.FFA_Location_Notes__c:'';
                        CurrentMeter.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed__c);
                        CurrentMeter.MeterRead=NGR.FFA_Meter_Read__c!=null ? NGR.FFA_Meter_Read__c:'';
                        CurrentMeter.PrimaryFunction=NGR.FFA_Primary_Function__c!=null ? NGR.FFA_Primary_Function__c:'';
                        CurrentMeter.PhysicalSize=NGR.FFA_Physical_Size__c!=null ? NGR.FFA_Physical_Size__c:'';
                        CurrentMeter.MaterialType=NGR.FFA_Material_Type__c!=null ? NGR.FFA_Material_Type__c:'';
                        CurrentMeter.MeterLinkCode=NGR.FFA_Meter_Link_Status__c!=null ? NGR.FFA_Meter_Link_Status__c:'';
                        CurrentMeter.PressureRead=NGR.FFA_Pressure_Read__c!=null ? NGR.FFA_Pressure_Read__c:'';
                        CurrentMeter.ConnectionType=NGR.FFA_Connection_type__c!=null ? NGR.FFA_Connection_type__c:'';
                        CurrentMeter.Qmax=string.valueOf(NGR.FFA_Qmax__c)!=null ? string.valueOf(NGR.FFA_Qmax__c):'';
                        completiondetails.MeterDetailsAttached = 'Y';
                        //CurrentMeter.MeterByPassPresent=NGR. //Need Mapping :
                        if(NGR.FFA_ThirdPartyMeter__c!='' ||NGR.FFA_ThirdPartyMeter__c!=null){
                          if(NGR.FFA_ThirdPartyMeter__c=='Yes'){
                             CurrentMeter.ThirdPartyMeter='Y'; 
                             }
                             if(NGR.FFA_ThirdPartyMeter__c=='No'){
                             CurrentMeter.ThirdPartyMeter='N'; 
                             }
                        } 
                        if(Wraplist.Completion_Date__c!=null ){
                        CurrentMeter.MeterReadDate=convertDateFormattoSAP(FFACompletionDate.date());
                        }
                        if(Wraplist.FFA_Sender_ID__c=='RAINBOW' && NGR.FFA_Meter_Reading_Date__c!=null ){
                        CurrentMeter.MeterReadDate=convertDateFormattoSAP(NGR.FFA_Meter_Reading_Date__c);
                        }
                        CurrentMeter.ConnectionSize=NGR.FFA_Connection_size__c!=null ? NGR.FFA_Connection_size__c:''; 
                        MeterCurrentList.add(CurrentMeter);
                        }
                        //METER FIX DETAILS
                        if(NGR.Serial_Number_Fix__c != null || NGR.FFA_Manufacturer_Fix__c!=null || NGR.FFA_Model_Fix__c!=null || NGR.FFA_Year_of_Manufacturer_Fix__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.MeterFix FixMeter = new  FFA_WorkOrderCompleteInterfaceWrapper.MeterFix();
                            FixMeter.NewMeterSerialNumber= NGR.Serial_Number_Fix__c!=null ? NGR.Serial_Number_Fix__c:'';
                            //FixMeter.NewMeterManufacturer= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            //FixMeter.NewMeterModel=NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            if(NGR.FFA_Other_Manufacturer_fix__c!=null){
                                FixMeter.NewMeterManufacturer=NGR.FFA_Other_Manufacturer_fix__c!=null ? NGR.FFA_Other_Manufacturer_fix__c:'';
                            }else{
                                FixMeter.NewMeterManufacturer= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            }
                            if(NGR.FFA_Other_Model_fix__c!=null){
                                FixMeter.NewMeterModel=NGR.FFA_Other_Model_fix__c!=null ? NGR.FFA_Other_Model_fix__c:'';
                            }else{
                                FixMeter.NewMeterModel= NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            }
                            FixMeter.NewMeterYearOfManufacture=NGR.FFA_Year_of_Manufacturer_Fix__c!=null ? NGR.FFA_Year_of_Manufacturer_Fix__c:'';
                            FixMeter.NewMeterStatusCode=NGR.FFA_Asset_Status_Fix__c!=null ? NGR.FFA_Asset_Status_Fix__c:'';
                            FixMeter.NewMeterType=NGR.FFA_Meter_Type_Fix__c!=null ? NGR.FFA_Meter_Type_Fix__c:'';
                            FixMeter.NewMeterNumberOfDials=string.valueof(NGR.FFA_Readable_Dials_Fix__c)!=null ? string.valueof(NGR.FFA_Readable_Dials_Fix__c):'';
                            FixMeter.NewMeterLocationCode=NGR.FFA_Location_Fix__c!=null ? NGR.FFA_Location_Fix__c:'';
                            FixMeter.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                            FixMeter.PrimaryFunction=NGR.FFA_Primary_Function_Fix__c!=null ? NGR.FFA_Primary_Function_Fix__c:'';
                            FixMeter.PhysicalSize=NGR.FFA_Physical_Size_Fix__c!=null ? NGR.FFA_Physical_Size_Fix__c:'';
                            FixMeter.MaterialType=NGR.FFA_Material_Type_Fix__c!=null ? NGR.FFA_Material_Type_Fix__c:'';
                            FixMeter.PressureRead=NGR.FFA_Pressure_Read_Fix__c!=null ? NGR.FFA_Pressure_Read_Fix__c:'';
                            FixMeter.ConnectionSize=NGR.FFA_Connection_size_Fix__c!=null ? NGR.FFA_Connection_size_Fix__c:'';
                            FixMeter.ConnectionType=NGR.FFA_Connection_Type_Fix__c!=null ? NGR.FFA_Connection_Type_Fix__c:'';
                            FixMeter.Qmax=string.valueof(NGR.FFA_Qmax_Fix__c)!=null ? string.valueof(NGR.FFA_Qmax_Fix__c):'';
                            FixMeter.MeterLinkCode=NGR.FFAMeterLinkStatusFix__c!=null ? NGR.FFAMeterLinkStatusFix__c:'';
                            FixMeter.NewMeterLocationNotes=NGR.FFA_Location_Notes_Fix__c!=null ? NGR.FFA_Location_Notes_Fix__c:'';
                            FixMeter.NewMeterMechanism=NGR.FFA_Meter_Mechanism_Fix__c!=null ? NGR.FFA_Meter_Mechanism_Fix__c:'';
                            //Changed as per discussion  with MAhesh on 26 NOV
                            if((NGR.FFA_Activity_Type__c=='E' || NGR.FFA_Activity_Type__c=='F') && NGR.FFA_Installed_On_Stream_Fix__c==null){
                                FixMeter.NewMeterInstalledOnStream='1';
                                system.debug('---Enter'+NGR.FFA_Installed_On_Stream_Fix__c+':'+FixMeter.NewMeterInstalledOnStream);
                            }
                            else{
                            FixMeter.NewMeterInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c!=null ? NGR.FFA_Installed_On_Stream_Fix__c:'';
                            }
                            FixMeter.NewMeterActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            FixMeter.NewMeterImperialFlag=NGR.FFA_Metric_Imperial_Indicator_Fix__c!=null ? NGR.FFA_Metric_Imperial_Indicator_Fix__c:''; 
                            FixMeter.OpeningRead=NGR.FFA_Meter_Read_Fix__c!=null ? NGR.FFA_Meter_Read_Fix__c:'';
                            if(Wraplist.Completion_Date__c!=null){
                                FixMeter.OpeningReadDate=convertDateFormattoSAP(FFACompletionDate.date());
                            }
                            if(Wraplist.FFA_Sender_ID__c=='RAINBOW' && NGR.FFA_Meter_Reading_Date_Fix__c!=null){
                                FixMeter.OpeningReadDate=convertDateFormattoSAP(NGR.FFA_Meter_Reading_Date_Fix__c);
                            }
                            MeterFixList.add(FixMeter);
                        }
                    }
                   
                    // Convertor Current/Fix
                    if(NGR.FFA_Asset_Type__c ==FFA_Constants.FFA_CONVERTOR){
                        system.debug('conve'+NGR.FFA_Asset_Type__c);
                        FFA_WorkOrderCompleteInterfaceWrapper.ConvertorCurrent CurrentConvertor = new  FFA_WorkOrderCompleteInterfaceWrapper.ConvertorCurrent();
                        CurrentConvertor.ConvertorActivityType =NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                        CurrentConvertor.ConvertorSerialNumber = NGR.FFA_Serial_Number__c!=null ? NGR.FFA_Serial_Number__c:'';
                        //CurrentConvertor.ConvertorManufacturer = NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';
                        if(NGR.FFA_Other_Manufacturer__c!=null){
                           CurrentConvertor.ConvertorManufacturer = NGR.FFA_Other_Manufacturer__c!=null ? NGR.FFA_Other_Manufacturer__c:''; 
                        }
                        else{
                           CurrentConvertor.ConvertorManufacturer = NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:''; 
                        }
                        //CurrentConvertor.ConvertorModel = NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                        if(NGR.FFA_Other_Model__c!=null){
                         CurrentConvertor.ConvertorModel = NGR.FFA_Other_Model__c!=null ? NGR.FFA_Other_Model__c:'';   
                        }
                        else{
                          CurrentConvertor.ConvertorModel = NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';  
                        }
                        CurrentConvertor.ConvertorYearOfManufacture = NGR.FFA_Year_of_Manufacturer__c!=null ? NGR.FFA_Year_of_Manufacturer__c:'';
                        CurrentConvertor.ConvertorStatusCode = NGR.FFA_Asset_Status__c!=null ? NGR.FFA_Asset_Status__c:'';//updated as per discussion with Venkat on 29/10/2019 - by Ankit
                        if(string.isNotBlank(NGR.FFA_Location__c)){
                            CurrentConvertor.ConvertorLocationCode =getLocationCode(NGR.FFA_Location__c);
                        }    
                        CurrentConvertor.ConvertorLocationNotes =  NGR.FFA_Location_Notes__c!=null ? NGR.FFA_Location_Notes__c:'';
                        CurrentConvertor.ConvertorNumberOfDials =string.valueof(NGR.FFA_Readable_Dials__c)!=null ? string.valueof(NGR.FFA_Readable_Dials__c):'';
                        CurrentConvertor.ConvertorImperialIndicator =string.valueof(NGR.FFA_Metric_or_Imperial_Indicator__c)!=null ? string.valueof(NGR.FFA_Metric_or_Imperial_Indicator__c):'';
                        CurrentConvertor.DateInstalled =convertDateFormattoSAP(NGR.FFA_Date_Installed__c);
                        CurrentConvertor.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                        completiondetails.ConvertorDetailsAttached = 'Y';
                        ConvertorCurrentList.add(CurrentConvertor);
                        FFA_WorkOrderCompleteInterfaceWrapper.ConvertorReadingsAndData ReadingsAndDataConvertor = new  FFA_WorkOrderCompleteInterfaceWrapper.ConvertorReadingsAndData();
                        ReadingsAndDataConvertor.UnconvertedReadingAsFound = NGR.FFA_UnConvertedReadingFound__c!=null ? NGR.FFA_UnConvertedReadingFound__c:'';
                        ReadingsAndDataConvertor.ConvertedReadingAsFound = NGR.FFA_ConvertedReadFound__c!=null ? NGR.FFA_ConvertedReadFound__c:'';               
                        ReadingsAndDataConvertor.UnconvertedReadingAsLeft = NGR.FFA_UnconvertedLeft__c!=null ? NGR.FFA_UnconvertedLeft__c:'';            
                        ReadingsAndDataConvertor.ConvertedReadingAsLeft = NGR.FFA_ConvertedLeft__c!=null ? NGR.FFA_ConvertedLeft__c:'';              
                        ReadingsAndDataConvertor.GaugePressureConverterReading = NGR.FFA_GaugePressure__c!=null ? NGR.FFA_GaugePressure__c:'';     
                        ReadingsAndDataConvertor.AbsolutePressureConvertorReading = NGR.FFA_Pressure_Read__c!=null ? NGR.FFA_Pressure_Read__c:'';   
                        ReadingsAndDataConvertor.AtmosphericPressure = NGR.FFA_Atmospheric_Pressure__c!=null ? NGR.FFA_Atmospheric_Pressure__c:'';           
                        ReadingsAndDataConvertor.TemperatureConvertorReading = NGR.FFA_TI_Temperature_Reading__c!=null ? NGR.FFA_TI_Temperature_Reading__c:'';     
                        ReadingsAndDataConvertor.ConversionFactor = NGR.FFA_Conversion_Factor__c!=null ? NGR.FFA_Conversion_Factor__c:'';
                        ConvertorReadingsAndDataList.add(ReadingsAndDataConvertor);
                        if(NGR.Serial_Number_Fix__c != null || NGR.FFA_Manufacturer_Fix__c!=null || NGR.FFA_Model_Fix__c!=null || NGR.FFA_Year_of_Manufacturer_Fix__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.ConvertorFix FixConvertor = new  FFA_WorkOrderCompleteInterfaceWrapper.ConvertorFix();
                            FixConvertor.ConvertorSerialNumber= NGR.Serial_Number_Fix__c!=null ? NGR.Serial_Number_Fix__c:'';
                           // FixConvertor.ConvertorManufacturer=NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                           // FixConvertor.ConvertorModel=NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                           if(NGR.FFA_Other_Manufacturer_fix__c!=null){
                                FixConvertor.ConvertorManufacturer=NGR.FFA_Other_Manufacturer_fix__c!=null ? NGR.FFA_Other_Manufacturer_fix__c:'';
                            }else{
                                FixConvertor.ConvertorManufacturer= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            }
                            if(NGR.FFA_Other_Model_fix__c!=null){
                                FixConvertor.ConvertorModel=NGR.FFA_Other_Model_fix__c!=null ? NGR.FFA_Other_Model_fix__c:'';
                            }else{
                                FixConvertor.ConvertorModel= NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            }
                            FixConvertor.ConvertorYearOfManufacture=NGR.FFA_Year_of_Manufacturer_Fix__c!=null ? NGR.FFA_Year_of_Manufacturer_Fix__c:'';
                            FixConvertor.ConvertorStatusCode=NGR.FFA_Asset_Status_Fix__c!=null ? NGR.FFA_Asset_Status_Fix__c:'';//updated as per discussion with Venkat on 29/10/2019 - by Ankit
                            FixConvertor.ConvertorLocationCode=NGR.FFA_Location_Fix__c!=null ? NGR.FFA_Location_Fix__c:'';
                            FixConvertor.ConvertorLocationNotes=NGR.FFA_Location_Notes_Fix__c!=null ? NGR.FFA_Location_Notes_Fix__c:'';
                            FixConvertor.ConvertorNumberOfDials=string.valueof(NGR.FFA_Readable_Dials_Fix__c)!=null ? string.valueof(NGR.FFA_Readable_Dials_Fix__c):'';
                            FixConvertor.ConvertorImperialIndicator= NGR.FFA_Metric_Imperial_Indicator_Fix__c!=null ? NGR.FFA_Metric_Imperial_Indicator_Fix__c:'';
                            FixConvertor.DateInstalled =convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                            FixConvertor.NewConvertorActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:''; 
                            ConvertorFixList.add(FixConvertor);
                            FFA_WorkOrderCompleteInterfaceWrapper.ConvertorFixReadingsAndData FixConvertorReadingsAndData = new  FFA_WorkOrderCompleteInterfaceWrapper.ConvertorFixReadingsAndData();
                            if((NGR.FFA_Activity_Type__c=='E' || NGR.FFA_Activity_Type__c=='F') && NGR.FFA_Installed_On_Stream_Fix__c==null){
                                FixConvertorReadingsAndData.NewInstalledOnStream='1';
                                
                            }
                            else{
                            FixConvertorReadingsAndData.NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c!=null ? NGR.FFA_Installed_On_Stream_Fix__c:'';
                            }
                            //
                            FixConvertorReadingsAndData.GaugePressureConverterReading = NGR.FFA_Gauge_Pressure_Fix__c!=null ? NGR.FFA_Gauge_Pressure_Fix__c:'';     
                            FixConvertorReadingsAndData.AbsolutePressureConvertorReading = NGR.FFA_Absolute_Pres_Convertor_Reading_Fix__c!=null ? NGR.FFA_Absolute_Pres_Convertor_Reading_Fix__c:'';   
                            FixConvertorReadingsAndData.TemperatureConvertorReading = NGR.FFA_Temperature_Convertor_Reading_Fix__c!=null ? NGR.FFA_Temperature_Convertor_Reading_Fix__c:'';  
                            FixConvertorReadingsAndData.AtmosphericPressure = NGR.FFA_Atmospheric_pressure_mBar_Fix__c!=null ? NGR.FFA_Atmospheric_pressure_mBar_Fix__c:'';       
                            FixConvertorReadingsAndData.ConversionFactor = NGR.FFA_Conversion_Factor_Fix__c!=null ? NGR.FFA_Conversion_Factor_Fix__c:'';
                            FixConvertorReadingsAndData.OpeningUnconvertedReading = NGR.FFA_Unconverted_readings_as_left_Fix__c!=null ? NGR.FFA_Unconverted_readings_as_left_Fix__c:'';
                            FixConvertorReadingsAndData.OpeningConvertedReading = NGR.FFA_Converted_Reading_As_Left_Fix__c!=null ? NGR.FFA_Converted_Reading_As_Left_Fix__c:'';
                            //FixConvertorReadingsAndData.UnconvertedReadingAsFound=NGR.FFA_Converted_Reading_As_Left_Fix__c;
                            //FixConvertorReadingsAndData.ConvertedReadingAsFound  = NGR.FFA_ConvertedReadFound__c;
                            
                            
                            ConvertorFixReadingsAndDataList.add(FixConvertorReadingsAndData);
                        }
                    }
                    
                    //Flow Computer Current/Fix
                    if(NGR.FFA_Asset_Type__c == FFA_Constants.FFA_FLOWCOMPUTER){//
                        FFA_WorkOrderCompleteInterfaceWrapper.FlowComputerCurrent CurrentFlowComputer = new  FFA_WorkOrderCompleteInterfaceWrapper.FlowComputerCurrent();
                        CurrentFlowComputer.FlowComputerActivityType = NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                        CurrentFlowComputer.FlowComputerSerialNumber = NGR.FFA_Serial_Number__c!=null ? NGR.FFA_Serial_Number__c:'';
                        //CurrentFlowComputer.FlowComputerManufacturer = NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';
                        if(NGR.FFA_Other_Manufacturer__c!=null){
                            CurrentFlowComputer.FlowComputerManufacturer = NGR.FFA_Other_Manufacturer__c!=null ? NGR.FFA_Other_Manufacturer__c:'';
                        }
                        else{
                             CurrentFlowComputer.FlowComputerManufacturer = NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';   
                        }
                        //CurrentFlowComputer.FlowComputerModel = NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                        if(NGR.FFA_Other_Model__c!=null){
                           CurrentFlowComputer.FlowComputerModel = NGR.FFA_Other_Model__c!=null ? NGR.FFA_Other_Model__c:''; 
                        }
                        else{
                           CurrentFlowComputer.FlowComputerModel = NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:''; 
                        }
                        CurrentFlowComputer.FlowComputerYearOfManufacture = NGR.FFA_Year_of_Manufacturer__c!=null ? NGR.FFA_Year_of_Manufacturer__c:'';
                        CurrentFlowComputer.DateInstalled = convertDateFormattoSAP(NGR.FFA_Date_Installed__c);
                        if(string.isNotBlank(NGR.FFA_Location__c)){
                            CurrentFlowComputer.FlowComputerLocationCode =getLocationCode(NGR.FFA_Location__c);
                        } 
                        
                        CurrentFlowComputer.FlowComputerrImperialIndicator = string.valueOf(NGR.FFA_Metric_or_Imperial_Indicator__c)!=null ? string.valueOf(NGR.FFA_Metric_or_Imperial_Indicator__c):'';
                        CurrentFlowComputer.UnconvertedReadingAsFound = NGR.FFA_UnConvertedReadingFound__c!=null ? NGR.FFA_UnConvertedReadingFound__c:''; //FFA_UnConvertedReadingFound__c
                        CurrentFlowComputer.ConvertedReadingAsFound =NGR.FFA_ConvertedReadFound__c!=null ? NGR.FFA_ConvertedReadFound__c:'';//FFA_ConvertedReadFound__c
                        CurrentFlowComputer.FlowComputerNumberOfDials = string.valueOf(NGR.FFA_Readable_Dials__c)!=null ? string.valueOf(NGR.FFA_Readable_Dials__c):'';
                        CurrentFlowComputer.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                        FlowComputerCurrentList.add(CurrentFlowComputer);
                        if(NGR.Serial_Number_Fix__c != null || NGR.FFA_Manufacturer_Fix__c!=null || NGR.FFA_Model_Fix__c!=null || NGR.FFA_Year_of_Manufacturer_Fix__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.FlowComputerFix FixFlowComputer = new  FFA_WorkOrderCompleteInterfaceWrapper.FlowComputerFix();
                            FixFlowComputer.FlowComputerSerialNumber= NGR.Serial_Number_Fix__c!=null ? NGR.Serial_Number_Fix__c:'';
                            //FixFlowComputer.FlowComputerManufacturer=NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            //FixFlowComputer.FlowComputerModel=NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            if(NGR.FFA_Other_Manufacturer_fix__c!=null){
                                FixFlowComputer.FlowComputerManufacturer=NGR.FFA_Other_Manufacturer_fix__c!=null ? NGR.FFA_Other_Manufacturer_fix__c:'';
                            }else{
                                FixFlowComputer.FlowComputerManufacturer= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            }
                            if(NGR.FFA_Other_Model_fix__c!=null){
                                FixFlowComputer.FlowComputerModel=NGR.FFA_Other_Model_fix__c!=null ? NGR.FFA_Other_Model_fix__c:'';
                            }else{
                                FixFlowComputer.FlowComputerModel= NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            }
                            FixFlowComputer.FlowComputerYearOfManufacture=NGR.FFA_Year_of_Manufacturer_Fix__c!=null ? NGR.FFA_Year_of_Manufacturer_Fix__c:'';
                            FixFlowComputer.DateInstalled =convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                            FixFlowComputer.FlowComputerLocationCode=NGR.FFA_Location_Fix__c!=null ? NGR.FFA_Location_Fix__c:'';
                            FixFlowComputer.FlowComputerrImperialIndicator= NGR.FFA_Metric_Imperial_Indicator_Fix__c!=null ? NGR.FFA_Metric_Imperial_Indicator_Fix__c:'';
                            FixFlowComputer.NewUnconvertedReadingAsFound=NGR.FFA_Unconverted_Read_Fix__c!=null ? NGR.FFA_Unconverted_Read_Fix__c:'';
                            FixFlowComputer.NewConvertedReadingAsFound=NGR.FFA_Converted_Read_Fix__c!=null ? NGR.FFA_Converted_Read_Fix__c:'';
                            FixFlowComputer.FlowComputerNumberOfDials=string.valueof(NGR.FFA_Readable_Dials_Fix__c)!=null ? string.valueof(NGR.FFA_Readable_Dials_Fix__c):'';
                            FixFlowComputer.NewFlowComputerActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:''; 
                            FixFlowComputer.NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c!=null ? NGR.FFA_Installed_On_Stream_Fix__c:'';
                            FlowComputerFixList.add(FixFlowComputer);
                        }
                    }
                    
                    //Slamshut Current/fix
                    if(NGR.FFA_Asset_Type__c == FFA_Constants.FFA_SLAMSHUT && isSlamshutActivityE!=True ){ 
                    //FFA_SLAMSHUT CURRENT DETAILS
                        FFA_WorkOrderCompleteInterfaceWrapper.SlamShutCurrent CurrentSlamShut = new  FFA_WorkOrderCompleteInterfaceWrapper.SlamShutCurrent();
                            CurrentSlamShut.SlamShutActivityType =NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            CurrentSlamShut.SlamShutSerialNumber = NGR.FFA_Serial_Number__c!=null ? NGR.FFA_Serial_Number__c:'';
                            //CurrentSlamShut.SlamShutManufacturer = NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';
                            if(NGR.FFA_Other_Manufacturer__c!=null){
                                CurrentSlamShut.SlamShutManufacturer = NGR.FFA_Other_Manufacturer__c!=null ? NGR.FFA_Other_Manufacturer__c:'';
                            }
                            else{
                              CurrentSlamShut.SlamShutManufacturer = NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';  
                            }
                            //CurrentSlamShut.SlamShutModel = NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                            if(NGR.FFA_Other_Model__c!=null){
                                CurrentSlamShut.SlamShutModel = NGR.FFA_Other_Model__c!=null ? NGR.FFA_Other_Model__c:'';
                            }
                            else{
                             CurrentSlamShut.SlamShutModel = NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';   
                            }
                            CurrentSlamShut.SlamShutYearOfManufacture= NGR.FFA_Year_of_Manufacturer__c!=null ? NGR.FFA_Year_of_Manufacturer__c:'';
                            CurrentSlamShut.DateInstalled= convertDateFormattoSAP(NGR.FFA_Date_Installed__c);
                            CurrentSlamShut.PrimaryFunction=NGR.FFA_Primary_Function__c!=null ? NGR.FFA_Primary_Function__c:'';
                            CurrentSlamShut.PhysicalSize=NGR.FFA_Physical_Size__c!=null ? NGR.FFA_Physical_Size__c:'';
                            CurrentSlamShut.PressureRead=NGR.FFA_Pressure_Read__c!=null ? NGR.FFA_Pressure_Read__c:'';
                            CurrentSlamShut.ConnectionSize=NGR.FFA_Connection_size__c!=null ? NGR.FFA_Connection_size__c:'';
                            CurrentSlamShut.ConnectionType=NGR.FFA_Connection_type__c!=null ? NGR.FFA_Connection_type__c:'';
                            CurrentSlamShut.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                            SlamShutCurrentList.add(CurrentSlamShut);
                            
                        //FFA_SLAMSHUT FIX DETAILS
                        if(NGR.Serial_Number_Fix__c != null || NGR.FFA_Manufacturer_Fix__c!=null || NGR.FFA_Model_Fix__c!=null || NGR.FFA_Year_of_Manufacturer_Fix__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.SlamShutFix FixSlamShut = new  FFA_WorkOrderCompleteInterfaceWrapper.SlamShutFix();
                            FixSlamShut.SlamShutSerialNumber= NGR.Serial_Number_Fix__c!=null ? NGR.Serial_Number_Fix__c:'';
                            //FixSlamShut.SlamShutManufacturer=NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            //FixSlamShut.SlamShutModel=NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            if(NGR.FFA_Other_Manufacturer_fix__c!=null){
                                FixSlamShut.SlamShutManufacturer=NGR.FFA_Other_Manufacturer_fix__c!=null ? NGR.FFA_Other_Manufacturer_fix__c:'';
                            }else{
                                FixSlamShut.SlamShutManufacturer= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            }
                            if(NGR.FFA_Other_Model_fix__c!=null){
                                FixSlamShut.SlamShutModel=NGR.FFA_Other_Model_fix__c!=null ? NGR.FFA_Other_Model_fix__c:'';
                            }else{
                                FixSlamShut.SlamShutModel= NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            }
                            FixSlamShut.SlamShutYearOfManufacture=NGR.FFA_Year_of_Manufacturer_Fix__c!=null ? NGR.FFA_Year_of_Manufacturer_Fix__c:'';
                            FixSlamShut.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                            FixSlamShut.PrimaryFunction=NGR.FFA_Primary_Function_Fix__c!=null ? NGR.FFA_Primary_Function_Fix__c:'';
                            FixSlamShut.PhysicalSize=NGR.FFA_Physical_Size_Fix__c!=null ? NGR.FFA_Physical_Size_Fix__c:'';
                            FixSlamShut.PressureRead=NGR.FFA_Pressure_Read_Fix__c!=null ? NGR.FFA_Pressure_Read_Fix__c:'';
                            FixSlamShut.ConnectionSize=NGR.FFA_Connection_size_Fix__c!=null ? NGR.FFA_Connection_size_Fix__c:'';
                            FixSlamShut.ConnectionType=NGR.FFA_Connection_Type_Fix__c!=null ? NGR.FFA_Connection_Type_Fix__c:'';
                            FixSlamShut.NewSlamShutActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            FixSlamShut.NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c!=null ? NGR.FFA_Installed_On_Stream_Fix__c:'';
                            SlamShutFixList.add(FixSlamShut);
                        }
                    }
                    else{
                         if(slamshutStructeredJson!=null && NGR.FFA_Asset_Type__c == FFA_Constants.FFA_SLAMSHUT){
                              slamshutStructeredJson=slamshutStructeredJson+FFACompleteInterfaceActivitytypeEJSON.returnSlamShutJSON(NGR.id);
                              slamshutStructeredJson=slamshutStructeredJson+',';
                         }else{
                              if(NGR.FFA_Asset_Type__c == FFA_Constants.FFA_SLAMSHUT){
                              slamshutStructeredJson=FFACompleteInterfaceActivitytypeEJSON.returnSlamShutJSON(NGR.id);
                              slamshutStructeredJson=slamshutStructeredJson+',';
                              }
                         }
                         
                         
                    }
                    
                    //CreepRelief Current/Fix
                    if(NGR.FFA_Asset_Type__c ==FFA_Constants.FFA_CREEPRELIEF && isCreepReliefActivityE==False){
                        FFA_WorkOrderCompleteInterfaceWrapper.CreepReliefCurrent CurrentCreepRelief = new  FFA_WorkOrderCompleteInterfaceWrapper.CreepReliefCurrent();
                            CurrentCreepRelief.CreepReliefActivityType =NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            CurrentCreepRelief.CreepReliefSerialNumber =NGR.FFA_Serial_Number__c!=null ? NGR.FFA_Serial_Number__c:'';
                            //CurrentCreepRelief.CreepReliefManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';
                            if(NGR.FFA_Other_Manufacturer__c!=null){
                                CurrentCreepRelief.CreepReliefManufacturer= NGR.FFA_Other_Manufacturer__c!=null ? NGR.FFA_Other_Manufacturer__c:'';
                            }
                            else{
                               CurrentCreepRelief.CreepReliefManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:''; 
                            }
                            //CurrentCreepRelief.CreepReliefModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                            if(NGR.FFA_Other_Model__c!=null){
                                CurrentCreepRelief.CreepReliefModel= NGR.FFA_Other_Model__c!=null ? NGR.FFA_Other_Model__c:'';
                            }
                            else{
                              CurrentCreepRelief.CreepReliefModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';  
                            }
                            CurrentCreepRelief.CreepReliefYearOfManufacture= NGR.FFA_Year_of_Manufacturer__c!=null ? NGR.FFA_Year_of_Manufacturer__c:'';
                            CurrentCreepRelief.DateInstalled= convertDateFormattoSAP(NGR.FFA_Date_Installed__c);
                            CurrentCreepRelief.PrimaryFunction=NGR.FFA_Primary_Function__c!=null ? NGR.FFA_Primary_Function__c:'';
                            CurrentCreepRelief.PhysicalSize=NGR.FFA_Physical_Size__c!=null ? NGR.FFA_Physical_Size__c:'';
                            CurrentCreepRelief.PressureRead=NGR.FFA_Pressure_Read__c!=null ? NGR.FFA_Pressure_Read__c:'';
                            CurrentCreepRelief.ConnectionSize=NGR.FFA_Connection_size__c!=null ? NGR.FFA_Connection_size__c:'';
                            CurrentCreepRelief.ConnectionType=NGR.FFA_Connection_type__c!=null ? NGR.FFA_Connection_type__c:'';
                            CurrentCreepRelief.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                            CreepReliefCurrentList.add(CurrentCreepRelief);
                        if(NGR.Serial_Number_Fix__c != null || NGR.FFA_Manufacturer_Fix__c!=null || NGR.FFA_Model_Fix__c!=null || NGR.FFA_Year_of_Manufacturer_Fix__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.CreepReliefFix FixCreepRelief = new  FFA_WorkOrderCompleteInterfaceWrapper.CreepReliefFix();
                            FixCreepRelief.CreepReliefSerialNumber= NGR.Serial_Number_Fix__c!=null ? NGR.Serial_Number_Fix__c:'';
                            //FixCreepRelief.CreepReliefManufacturer=NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            //FixCreepRelief.CreepReliefModel=NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            if(NGR.FFA_Other_Manufacturer_fix__c!=null){
                                FixCreepRelief.CreepReliefManufacturer=NGR.FFA_Other_Manufacturer_fix__c!=null ? NGR.FFA_Other_Manufacturer_fix__c:'';
                            }else{
                                FixCreepRelief.CreepReliefManufacturer= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            }
                            if(NGR.FFA_Other_Model_fix__c!=null){
                                FixCreepRelief.CreepReliefModel=NGR.FFA_Other_Model_fix__c!=null ? NGR.FFA_Other_Model_fix__c:'';
                            }else{
                                FixCreepRelief.CreepReliefModel= NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            }
                            FixCreepRelief.CreepReliefYearOfManufacture=NGR.FFA_Year_of_Manufacturer_Fix__c!=null ? NGR.FFA_Year_of_Manufacturer_Fix__c:'';
                            FixCreepRelief.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                            FixCreepRelief.PrimaryFunction=NGR.FFA_Primary_Function_Fix__c!=null ? NGR.FFA_Primary_Function_Fix__c:'';
                            FixCreepRelief.PhysicalSize=NGR.FFA_Physical_Size_Fix__c!=null ? NGR.FFA_Physical_Size_Fix__c:'';
                            FixCreepRelief.PressureRead=NGR.FFA_Pressure_Read_Fix__c!=null ? NGR.FFA_Pressure_Read_Fix__c:'';
                            FixCreepRelief.ConnectionSize=NGR.FFA_Connection_size_Fix__c!=null ? NGR.FFA_Connection_size_Fix__c:'';
                            FixCreepRelief.ConnectionType=NGR.FFA_Connection_Type_Fix__c!=null ? NGR.FFA_Connection_Type_Fix__c:'';
                            FixCreepRelief.NewCreepReliefActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:''; 
                            FixCreepRelief.NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c!=null ? NGR.FFA_Installed_On_Stream_Fix__c:'';
                            CreepReliefFixList.add(FixCreepRelief);
                        }
                    }
                    else{
                        if(NGR.FFA_Asset_Type__c ==FFA_Constants.FFA_CREEPRELIEF && isCreepReliefActivityE==True ){
                            creepReliefStructeredJson=creepReliefStructeredJson+FFACompleteInterfaceActivitytypeEJSON.returncreepReliefJSON(NGR.id);
                              creepReliefStructeredJson=creepReliefStructeredJson+',';
                         }else{
                              if(NGR.FFA_Asset_Type__c == FFA_Constants.FFA_CREEPRELIEF && isCreepReliefActivityE==True){
                              creepReliefStructeredJson=FFACompleteInterfaceActivitytypeEJSON.returncreepReliefJSON(NGR.id);
                              creepReliefStructeredJson=creepReliefStructeredJson+',';
                              }
                         }
                         
                         
                    }
                    
                    //Boiler Current/fix
                    if(NGR.FFA_Asset_Type__c == FFA_Constants.FFA_BOILER && isBoilerActivityE==False ){//FFA_Constants.FFA_BOILER_RECORD_TYPE
                        FFA_WorkOrderCompleteInterfaceWrapper.BoilerCurrent CurrentBoiler = new  FFA_WorkOrderCompleteInterfaceWrapper.BoilerCurrent();
                            CurrentBoiler.BoilerActivityType = NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            CurrentBoiler.BoilerSerialNumber = NGR.FFA_Serial_Number__c!=null ? NGR.FFA_Serial_Number__c:'';
                            //CurrentBoiler.BoilerManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';
                            if(NGR.FFA_Other_Manufacturer__c!=null){
                                CurrentBoiler.BoilerManufacturer= NGR.FFA_Other_Manufacturer__c!=null ? NGR.FFA_Other_Manufacturer__c:'';
                            }
                            else{
                              CurrentBoiler.BoilerManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';  
                            }
                            //CurrentBoiler.BoilerModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                            if(NGR.FFA_Other_Model__c!=null){
                            CurrentBoiler.BoilerModel= NGR.FFA_Other_Model__c!=null ? NGR.FFA_Other_Model__c:'';
                            }
                            else{
                              CurrentBoiler.BoilerModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';  
                            }
                            CurrentBoiler.BoilerYearOfManufacture= NGR.FFA_Year_of_Manufacturer__c!=null ? NGR.FFA_Year_of_Manufacturer__c:'';
                            CurrentBoiler.DateInstalled= convertDateFormattoSAP(NGR.FFA_Date_Installed__c);
                            CurrentBoiler.PrimaryFunction=NGR.FFA_Primary_Function__c!=null ? NGR.FFA_Primary_Function__c:'';
                            CurrentBoiler.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                            BoilerCurrentList.add(CurrentBoiler);
                        if(NGR.Serial_Number_Fix__c != null || NGR.FFA_Manufacturer_Fix__c!=null || NGR.FFA_Model_Fix__c!=null || NGR.FFA_Year_of_Manufacturer_Fix__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.BoilerFix FixBoiler = new  FFA_WorkOrderCompleteInterfaceWrapper.BoilerFix();
                            FixBoiler.BoilerSerialNumber= NGR.Serial_Number_Fix__c!=null ? NGR.Serial_Number_Fix__c:'';
                            //FixBoiler.BoilerManufacturer=NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            //FixBoiler.BoilerModel=NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            if(NGR.FFA_Other_Manufacturer_fix__c!=null){
                                FixBoiler.BoilerManufacturer=NGR.FFA_Other_Manufacturer_fix__c!=null ? NGR.FFA_Other_Manufacturer_fix__c:'';
                            }else{
                                FixBoiler.BoilerManufacturer= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            }
                            if(NGR.FFA_Other_Model_fix__c!=null){
                                FixBoiler.BoilerModel=NGR.FFA_Other_Model_fix__c!=null ? NGR.FFA_Other_Model_fix__c:'';
                            }else{
                                FixBoiler.BoilerModel= NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            }
                            FixBoiler.BoilerYearOfManufacture=NGR.FFA_Year_of_Manufacturer_Fix__c!=null ? NGR.FFA_Year_of_Manufacturer_Fix__c:'';
                            FixBoiler.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                            FixBoiler.PrimaryFunction=NGR.FFA_Primary_Function_Fix__c!=null ? NGR.FFA_Primary_Function_Fix__c:'';
                            FixBoiler.NewBoilerActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:''; 
                            FixBoiler.NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c!=null ? NGR.FFA_Installed_On_Stream_Fix__c:'';
                            BoilerFixList.add(FixBoiler);
                        }
                    }
                    else{
                         if(biolerStructeredJson!=null && NGR.FFA_Asset_Type__c == FFA_Constants.FFA_BOILER){
                              biolerStructeredJson=biolerStructeredJson+FFACompleteInterfaceActivitytypeEJSON.returnBoilersJSON(NGR.id);
                              biolerStructeredJson=biolerStructeredJson+',';
                         }else{
                              if(NGR.FFA_Asset_Type__c == FFA_Constants.FFA_BOILER){
                              biolerStructeredJson=FFACompleteInterfaceActivitytypeEJSON.returnBoilersJSON(NGR.id);
                              biolerStructeredJson=biolerStructeredJson+',';
                              }
                         }
                         
                         
                    }
                     
                    
                    // WaterBathAndHeaters Current/Fix
                    if(NGR.FFA_Asset_Type__c == FFA_Constants.FFA_WATERBATHHEATER){ //FFA_Constants.FFA_WATERBATHHEATER_RECORD_TYPE
                        FFA_WorkOrderCompleteInterfaceWrapper.WaterBathHeatersCurrent CurrentWaterBathHeater = new  FFA_WorkOrderCompleteInterfaceWrapper.WaterBathHeatersCurrent();
                            CurrentWaterBathHeater.WaterBathHeatersActivityType = NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            CurrentWaterBathHeater.WaterBathHeatersSerialNumber = NGR.FFA_Serial_Number__c!=null ? NGR.FFA_Serial_Number__c:'';
                            //CurrentWaterBathHeater.WaterBathHeatersManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';
                                if(NGR.FFA_Other_Manufacturer__c!=null){
                                    CurrentWaterBathHeater.WaterBathHeatersManufacturer= NGR.FFA_Other_Manufacturer__c!=null ? NGR.FFA_Other_Manufacturer__c:'';
                                }
                                else{
                                  CurrentWaterBathHeater.WaterBathHeatersManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';  
                                }
                            //CurrentWaterBathHeater.WaterBathHeatersModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                            if(NGR.FFA_Other_Model__c!=null){
                                CurrentWaterBathHeater.WaterBathHeatersModel= NGR.FFA_Other_Model__c!=null ? NGR.FFA_Other_Model__c:'';
                            }
                            else{
                               CurrentWaterBathHeater.WaterBathHeatersModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:''; 
                            }
                            CurrentWaterBathHeater.WaterBathHeatersYearOfManufacture= NGR.FFA_Year_of_Manufacturer__c!=null ? NGR.FFA_Year_of_Manufacturer__c:'';
                            CurrentWaterBathHeater.DateInstalled= convertDateFormattoSAP(NGR.FFA_Date_Installed__c);
                            CurrentWaterBathHeater.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                            WaterBathHeaterCurrentList.add(CurrentWaterBathHeater);
                        if(NGR.Serial_Number_Fix__c != null || NGR.FFA_Manufacturer_Fix__c!=null || NGR.FFA_Model_Fix__c!=null || NGR.FFA_Year_of_Manufacturer_Fix__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.WaterBathHeatersFix FixWaterBathHeater = new  FFA_WorkOrderCompleteInterfaceWrapper.WaterBathHeatersFix();
                            FixWaterBathHeater.WaterBathHeatersSerialNumber= NGR.Serial_Number_Fix__c!=null ? NGR.Serial_Number_Fix__c:'';
                            //FixWaterBathHeater.WaterBathHeatersManufacturer=NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            //FixWaterBathHeater.WaterBathHeatersModel=NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            if(NGR.FFA_Other_Manufacturer_fix__c!=null){
                                FixWaterBathHeater.WaterBathHeatersManufacturer=NGR.FFA_Other_Manufacturer_fix__c!=null ? NGR.FFA_Other_Manufacturer_fix__c:'';
                            }else{
                                FixWaterBathHeater.WaterBathHeatersManufacturer= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            }
                            if(NGR.FFA_Other_Model_fix__c!=null){
                                FixWaterBathHeater.WaterBathHeatersModel=NGR.FFA_Other_Model_fix__c!=null ? NGR.FFA_Other_Model_fix__c:'';
                            }else{
                                FixWaterBathHeater.WaterBathHeatersModel= NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            }
                            FixWaterBathHeater.WaterBathHeatersYearOfManufacture=NGR.FFA_Year_of_Manufacturer_Fix__c!=null ? NGR.FFA_Year_of_Manufacturer_Fix__c:'';
                            FixWaterBathHeater.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                            FixWaterBathHeater.NewWaterBathHeatersActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            FixWaterBathHeater.NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c!=null ? NGR.FFA_Installed_On_Stream_Fix__c:''; 
                            WaterBathHeaterFixList.add(FixWaterBathHeater);
                        }
                    }
                    
                    // ShellAndTube Current/Fix
                    if(NGR.FFA_Asset_Type__c == FFA_Constants.FFA_SHELLANDTUBE){//FFA_Constants.FFA_SHELLANDTUBE_RECORD_TYPE/
                        FFA_WorkOrderCompleteInterfaceWrapper.ShellandTubeCurrent CurrentShellAndTube = new  FFA_WorkOrderCompleteInterfaceWrapper.ShellandTubeCurrent();
                            CurrentShellAndTube.ShellAndTubeActivityType =NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            CurrentShellAndTube.ShellAndTubeSerialNumber = NGR.FFA_Serial_Number__c!=null ? NGR.FFA_Serial_Number__c:'';
                            //CurrentShellAndTube.ShellAndTubeManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';
                            if(NGR.FFA_Other_Manufacturer__c!=null){
                                CurrentShellAndTube.ShellAndTubeManufacturer= NGR.FFA_Other_Manufacturer__c!=null ? NGR.FFA_Other_Manufacturer__c:'';
                            }
                            else{
                               CurrentShellAndTube.ShellAndTubeManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:''; 
                            }
                            //CurrentShellAndTube.ShellAndTubeModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                            if(NGR.FFA_Other_Model__c!=null){
                                CurrentShellAndTube.ShellAndTubeModel= NGR.FFA_Other_Model__c!=null ? NGR.FFA_Other_Model__c:'';
                            }
                            else{
                                CurrentShellAndTube.ShellAndTubeModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                            }
                            CurrentShellAndTube.ShellAndTubeYearOfManufacture= NGR.FFA_Year_of_Manufacturer__c!=null ? NGR.FFA_Year_of_Manufacturer__c:'';
                            CurrentShellAndTube.DateInstalled= convertDateFormattoSAP(NGR.FFA_Date_Installed__c);
                            CurrentShellAndTube.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                            ShellAndtubeCurrentList.add(CurrentShellAndTube);
                        if(NGR.Serial_Number_Fix__c != null || NGR.FFA_Manufacturer_Fix__c!=null || NGR.FFA_Model_Fix__c!=null || NGR.FFA_Year_of_Manufacturer_Fix__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.ShellandTubeFix FixShellAndTube = new  FFA_WorkOrderCompleteInterfaceWrapper.ShellandTubeFix();
                            FixShellAndTube.ShellandTubeSerialNumber= NGR.Serial_Number_Fix__c!=null ? NGR.Serial_Number_Fix__c:'';
                            //FixShellAndTube.ShellandTubeManufacturer=NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            //FixShellAndTube.ShellandTubeModel=NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            if(NGR.FFA_Other_Manufacturer_fix__c!=null){
                                FixShellAndTube.ShellandTubeYearOfManufacture=NGR.FFA_Other_Manufacturer_fix__c!=null ? NGR.FFA_Other_Manufacturer_fix__c:'';
                            }else{
                                FixShellAndTube.ShellandTubeYearOfManufacture= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            }
                            if(NGR.FFA_Other_Model_fix__c!=null){
                                FixShellAndTube.ShellandTubeModel=NGR.FFA_Other_Model_fix__c!=null ? NGR.FFA_Other_Model_fix__c:'';
                            }else{
                                FixShellAndTube.ShellandTubeModel= NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            }
                            FixShellAndTube.ShellandTubeYearOfManufacture=NGR.FFA_Year_of_Manufacturer_Fix__c!=null ? NGR.FFA_Year_of_Manufacturer_Fix__c:'';
                            FixShellAndTube.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                            FixShellAndTube.NewShellandTubeActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:''; 
                            FixShellAndTube.NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c!=null ? NGR.FFA_Installed_On_Stream_Fix__c:'';
                            ShellAndTubeFixList.add(FixShellAndTube);
                        }
                    }
                    
                    // Chromatograph Current/Fix
                    if(NGR.FFA_Asset_Type__c == FFA_Constants.FFA_CHROMATOGRAPH){
                        FFA_WorkOrderCompleteInterfaceWrapper.ChromatographCurrent CurrentChromatograph = new  FFA_WorkOrderCompleteInterfaceWrapper.ChromatographCurrent();
                            CurrentChromatograph.ChromatographActivityType =NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            CurrentChromatograph.ChromatographSerialNumber = NGR.FFA_Serial_Number__c!=null ? NGR.FFA_Serial_Number__c:'';
                            //CurrentChromatograph.ChromatographManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';
                            if(NGR.FFA_Other_Manufacturer__c!=null){
                                CurrentChromatograph.ChromatographManufacturer= NGR.FFA_Other_Manufacturer__c!=null ? NGR.FFA_Other_Manufacturer__c:'';
                            }
                            else{
                                CurrentChromatograph.ChromatographManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';  
                            }
                            
                            //CurrentChromatograph.ChromatographModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                            if(NGR.FFA_Other_Model__c!=null){
                                CurrentChromatograph.ChromatographModel= NGR.FFA_Other_Model__c!=null ? NGR.FFA_Other_Model__c:'';
                            }
                            else{
                               CurrentChromatograph.ChromatographModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:''; 
                            }
                            CurrentChromatograph.ChromatographYearOfManufacture= NGR.FFA_Year_of_Manufacturer__c!=null ? NGR.FFA_Year_of_Manufacturer__c:'';
                            CurrentChromatograph.DateInstalled= convertDateFormattoSAP(NGR.FFA_Date_Installed__c);
                            CurrentChromatograph.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                            ChromatographCurrentList.add(CurrentChromatograph);
                        if(NGR.Serial_Number_Fix__c != null || NGR.FFA_Manufacturer_Fix__c!=null || NGR.FFA_Model_Fix__c!=null || NGR.FFA_Year_of_Manufacturer_Fix__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.ChromatographFix FixChromatograph = new  FFA_WorkOrderCompleteInterfaceWrapper.ChromatographFix();
                            FixChromatograph.ChromatographSerialNumber= NGR.Serial_Number_Fix__c!=null ? NGR.Serial_Number_Fix__c:'';
                            //FixChromatograph.ChromatographManufacturer=NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            //FixChromatograph.ChromatographModel=NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            if(NGR.FFA_Other_Manufacturer_fix__c!=null){
                                FixChromatograph.ChromatographManufacturer=NGR.FFA_Other_Manufacturer_fix__c!=null ? NGR.FFA_Other_Manufacturer_fix__c:'';
                            }else{
                                FixChromatograph.ChromatographManufacturer= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            }
                            if(NGR.FFA_Other_Model_fix__c!=null){
                                FixChromatograph.ChromatographModel=NGR.FFA_Other_Model_fix__c!=null ? NGR.FFA_Other_Model_fix__c:'';
                            }else{
                                FixChromatograph.ChromatographModel= NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            }
                            FixChromatograph.ChromatographYearOfManufacture=NGR.FFA_Year_of_Manufacturer_Fix__c!=null ? NGR.FFA_Year_of_Manufacturer_Fix__c:'';
                            FixChromatograph.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                            FixChromatograph.NewChromatographActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:''; 
                            FixChromatograph.NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c!=null ? NGR.FFA_Installed_On_Stream_Fix__c:'';
                            ChromatographFixList.add(FixChromatograph);
                        }
                    }
                    
                    //Densitometer Current/Fix
                    if(NGR.FFA_Asset_Type__c == FFA_Constants.FFA_DENSITOMETER){
                        FFA_WorkOrderCompleteInterfaceWrapper.DensitometerCurrent CurrentDensitometer = new  FFA_WorkOrderCompleteInterfaceWrapper.DensitometerCurrent();
                            CurrentDensitometer.DensitometerActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            CurrentDensitometer.DensitometerSerialNumber  = NGR.FFA_Serial_Number__c!=null ? NGR.FFA_Serial_Number__c:'';
                            //CurrentDensitometer.DensitometerManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';
                            if(NGR.FFA_Other_Manufacturer__c!=null){
                                CurrentDensitometer.DensitometerManufacturer= NGR.FFA_Other_Manufacturer__c!=null ? NGR.FFA_Other_Manufacturer__c:'';
                            }
                            else{
                                CurrentDensitometer.DensitometerManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';  
                            }
                            
                            //CurrentDensitometer.DensitometerModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                            if(NGR.FFA_Other_Model__c!=null){
                                CurrentDensitometer.DensitometerModel= NGR.FFA_Other_Model__c!=null ? NGR.FFA_Other_Model__c:'';
                            }
                            else{
                                CurrentDensitometer.DensitometerModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';   
                            }
                            CurrentDensitometer.DensitometerYearOfManufacture= NGR.FFA_Year_of_Manufacturer__c!=null ? NGR.FFA_Year_of_Manufacturer__c:'';
                            CurrentDensitometer.DateInstalled= convertDateFormattoSAP(NGR.FFA_Date_Installed__c);
                            CurrentDensitometer.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                            DensitometerCurrentList.add(CurrentDensitometer);
                        if(NGR.Serial_Number_Fix__c != null || NGR.FFA_Manufacturer_Fix__c!=null || NGR.FFA_Model_Fix__c!=null || NGR.FFA_Year_of_Manufacturer_Fix__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.DensitometerFix FixDensitometer = new  FFA_WorkOrderCompleteInterfaceWrapper.DensitometerFix();
                            FixDensitometer.DensitometerSerialNumber= NGR.Serial_Number_Fix__c!=null ? NGR.Serial_Number_Fix__c:'';
                            //FixDensitometer.DensitometerManufacturer=NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            //FixDensitometer.DensitometerModel=NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            if(NGR.FFA_Other_Manufacturer_fix__c!=null){
                                FixDensitometer.DensitometerManufacturer=NGR.FFA_Other_Manufacturer_fix__c!=null ? NGR.FFA_Other_Manufacturer_fix__c:'';
                            }else{
                                FixDensitometer.DensitometerManufacturer= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            }
                            if(NGR.FFA_Other_Model_fix__c!=null){
                                FixDensitometer.DensitometerModel=NGR.FFA_Other_Model_fix__c!=null ? NGR.FFA_Other_Model_fix__c:'';
                            }else{
                                FixDensitometer.DensitometerModel= NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            }
                            FixDensitometer.DensitometerYearOfManufacture=NGR.FFA_Year_of_Manufacturer_Fix__c!=null ? NGR.FFA_Year_of_Manufacturer_Fix__c:'';
                            FixDensitometer.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                            FixDensitometer.NewDensitometerActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:''; 
                            FixDensitometer.NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c!=null ? NGR.FFA_Installed_On_Stream_Fix__c:'';
                            DensitometerFixList.add(FixDensitometer);
                        }
                    }
                    
                    //Valves Current/Fix
                    if(NGR.FFA_Asset_Type__c == FFA_Constants.FFA_VALVES && isValveActivityE!=True){
                        FFA_WorkOrderCompleteInterfaceWrapper.ValvesCurrent CurrentValves = new  FFA_WorkOrderCompleteInterfaceWrapper.ValvesCurrent();
                            CurrentValves.ValvesActivityType =NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            CurrentValves.ValvesSerialNumber = NGR.FFA_Serial_Number__c!=null ? NGR.FFA_Serial_Number__c:'';
                            //CurrentValves.ValvesManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';
                            if(NGR.FFA_Other_Manufacturer__c!=null){
                                CurrentValves.ValvesManufacturer= NGR.FFA_Other_Manufacturer__c!=null ? NGR.FFA_Other_Manufacturer__c:'';
                            }
                            else{
                                CurrentValves.ValvesManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';  
                            }
                            //CurrentValves.ValvesModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                            if(NGR.FFA_Other_Model__c!=null){
                                CurrentValves.ValvesModel= NGR.FFA_Other_Model__c!=null ? NGR.FFA_Other_Model__c:'';
                            }
                            else{
                                 CurrentValves.ValvesModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';   
                            }
                            CurrentValves.ValvesYearOfManufacture= NGR.FFA_Year_of_Manufacturer__c!=null ? NGR.FFA_Year_of_Manufacturer__c:'';
                            CurrentValves.DateInstalled= convertDateFormattoSAP(NGR.FFA_Date_Installed__c);
                            CurrentValves.PrimaryFunction=NGR.FFA_Primary_Function__c!=null ? NGR.FFA_Primary_Function__c:'';
                            CurrentValves.PhysicalSize=NGR.FFA_Physical_Size__c!=null ? NGR.FFA_Physical_Size__c:'';
                            CurrentValves.ConnectionSize=NGR.FFA_Connection_size__c!=null ? NGR.FFA_Connection_size__c:'';
                            CurrentValves.ConnectionType=NGR.FFA_Connection_type__c!=null ? NGR.FFA_Connection_type__c:'';
                            CurrentValves.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                            CurrentValvesList.add(CurrentValves);
                        if(NGR.Serial_Number_Fix__c != null || NGR.FFA_Manufacturer_Fix__c!=null || NGR.FFA_Model_Fix__c!=null || NGR.FFA_Year_of_Manufacturer_Fix__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.ValvesFix FixValves = new  FFA_WorkOrderCompleteInterfaceWrapper.ValvesFix();
                            FixValves.ValvesSerialNumber= NGR.Serial_Number_Fix__c!=null ? NGR.Serial_Number_Fix__c:'';
                            //FixValves.ValvesManufacturer=NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            //FixValves.ValvesModel=NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            if(NGR.FFA_Other_Manufacturer_fix__c!=null){
                                FixValves.ValvesManufacturer=NGR.FFA_Other_Manufacturer_fix__c!=null ? NGR.FFA_Other_Manufacturer_fix__c:'';
                            }else{
                                FixValves.ValvesManufacturer= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            }
                            if(NGR.FFA_Other_Model_fix__c!=null){
                                FixValves.ValvesModel=NGR.FFA_Other_Model_fix__c!=null ? NGR.FFA_Other_Model_fix__c:'';
                            }else{
                                FixValves.ValvesModel= NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            }
                            FixValves.ValvesYearOfManufacture=NGR.FFA_Year_of_Manufacturer_Fix__c!=null ? NGR.FFA_Year_of_Manufacturer_Fix__c:'';
                            FixValves.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                            FixValves.PrimaryFunction=NGR.FFA_Primary_Function_Fix__c!=null ? NGR.FFA_Primary_Function_Fix__c:'';
                            FixValves.PhysicalSize=NGR.FFA_Physical_Size_Fix__c!=null ? NGR.FFA_Physical_Size_Fix__c:'';
                            FixValves.ConnectionSize=NGR.FFA_Connection_size_Fix__c!=null ? NGR.FFA_Connection_size_Fix__c:'';
                            FixValves.ConnectionType=NGR.FFA_Connection_Type_Fix__c!=null ? NGR.FFA_Connection_Type_Fix__c:'';
                            FixValves.NewValvesActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:''; 
                            FixValves.NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c!=null ? NGR.FFA_Installed_On_Stream_Fix__c:'';
                            FixValvesList.add(FixValves);
                        }
                    }
                    else{
                         if(ValvesStructeredJson!=null && NGR.FFA_Asset_Type__c == FFA_Constants.FFA_VALVES){
                              ValvesStructeredJson=ValvesStructeredJson+FFACompleteInterfaceActivitytypeEJSON.returnValvesJSON(NGR.id);
                              ValvesStructeredJson=ValvesStructeredJson+',';
                         }else{
                              if(NGR.FFA_Asset_Type__c == FFA_Constants.FFA_VALVES){
                              ValvesStructeredJson=FFACompleteInterfaceActivitytypeEJSON.returnValvesJSON(NGR.id);
                              ValvesStructeredJson=ValvesStructeredJson+',';
                              }
                         }
                         
                         
                    }
                    
                    //PipeWork Current/Fix
                    if(NGR.FFA_Asset_Type__c == FFA_Constants.FFA_PIPEWORK){
                        FFA_WorkOrderCompleteInterfaceWrapper.PipeworkCurrent CurrentPipework = new  FFA_WorkOrderCompleteInterfaceWrapper.PipeworkCurrent();
                            CurrentPipework.PipeworkActivityType =NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            CurrentPipework.PipeworkLocationCode =NGR.FFA_Location__c!=null ? NGR.FFA_Location__c:'';
                            CurrentPipework.PhysicalSize=NGR.FFA_Physical_Size__c!=null ? NGR.FFA_Physical_Size__c:'';
                            CurrentPipework.MaterialType =NGR.FFA_Material_Type__c!=null ? NGR.FFA_Material_Type__c:'';
                            CurrentPipework.ConnectionSize=NGR.FFA_Connection_size__c!=null ? NGR.FFA_Connection_size__c:'';
                            CurrentPipework.ConnectionType=NGR.FFA_Connection_type__c!=null ? NGR.FFA_Connection_type__c:'';
                            CurrentPipework.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                            PipeWorkCurrentList.add(CurrentPipework);
                        if(NGR.FFA_Location_Fix__c != null || NGR.FFA_Physical_Size_Fix__c!=null || NGR.FFA_Material_Type_Fix__c!=null || NGR.FFA_Connection_size_Fix__c!=null
                          || NGR.FFA_Connection_Type_Fix__c!=null || NGR.FFA_Activity_Type__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.PipeworkFix FixPipework = new  FFA_WorkOrderCompleteInterfaceWrapper.PipeworkFix();
                            FixPipework.PipeworkLocationCode=NGR.FFA_Location_Fix__c!=null ? NGR.FFA_Location_Fix__c:'';
                            FixPipework.PhysicalSize=NGR.FFA_Physical_Size_Fix__c!=null ? NGR.FFA_Physical_Size_Fix__c:'';
                            FixPipework.MaterialType=NGR.FFA_Material_Type_Fix__c!=null ? NGR.FFA_Material_Type_Fix__c:'';
                            FixPipework.ConnectionSize=NGR.FFA_Connection_size_Fix__c!=null ? NGR.FFA_Connection_size_Fix__c:'';
                            FixPipework.ConnectionType=NGR.FFA_Connection_Type_Fix__c!=null ? NGR.FFA_Connection_Type_Fix__c:'';
                            FixPipework.NewPipeworkActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:''; 
                            //FixPipework.NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c;
                            PipeWorkFixList.add(FixPipework);
                        }
                    }
                    
                    //CathodicProtection Current/Fix
                    if(NGR.FFA_Asset_Type__c == FFA_Constants.FFA_CATHODICPROTECTION){
                        FFA_WorkOrderCompleteInterfaceWrapper.CathodicProtectionCurrent CurrentCathodicProtection = new  FFA_WorkOrderCompleteInterfaceWrapper.CathodicProtectionCurrent();
                            CurrentCathodicProtection.CathodicProtectionActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                           // CurrentCathodicProtection.CathodicProtectionManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';
                            if(NGR.FFA_Other_Manufacturer__c!=null){
                                CurrentCathodicProtection.CathodicProtectionManufacturer= NGR.FFA_Other_Manufacturer__c!=null ? NGR.FFA_Other_Manufacturer__c:'';
                            }
                            else{
                               CurrentCathodicProtection.CathodicProtectionManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:''; 
                            }
                            //CurrentCathodicProtection.CathodicProtectionModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                            if(NGR.FFA_Other_Model__c!=null){
                                CurrentCathodicProtection.CathodicProtectionModel= NGR.FFA_Other_Model__c!=null ? NGR.FFA_Other_Model__c:'';
                            }
                            else{
                               CurrentCathodicProtection.CathodicProtectionModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';  
                            }
                            CurrentCathodicProtection.DateInstalled= convertDateFormattoSAP(NGR.FFA_Date_Installed__c);
                            CurrentCathodicProtection.MaterialType = NGR.FFA_Material_Type__c!=null ? NGR.FFA_Material_Type__c:'';
                            CurrentCathodicProtection.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                            CathodicProtectionCurrentList.add(CurrentCathodicProtection);
                        if(NGR.FFA_Manufacturer_Fix__c!=null || NGR.FFA_Model_Fix__c!=null || NGR.FFA_Material_Type_Fix__c!=null || NGR.FFA_Installed_On_Stream_Fix__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.CathodicProtectionFix FixCathodicProtection = new  FFA_WorkOrderCompleteInterfaceWrapper.CathodicProtectionFix();
                            //FixCathodicProtection.CathodicProtectionManufacturer=NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            //FixCathodicProtection.CathodicProtectionModel=NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            if(NGR.FFA_Other_Manufacturer_fix__c!=null){
                                FixCathodicProtection.CathodicProtectionManufacturer=NGR.FFA_Other_Manufacturer_fix__c!=null ? NGR.FFA_Other_Manufacturer_fix__c:'';
                            }else{
                                FixCathodicProtection.CathodicProtectionManufacturer= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            }
                            if(NGR.FFA_Other_Model_fix__c!=null){
                                FixCathodicProtection.CathodicProtectionModel=NGR.FFA_Other_Model_fix__c!=null ? NGR.FFA_Other_Model_fix__c:'';
                            }else{
                                FixCathodicProtection.CathodicProtectionModel= NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            }
                            FixCathodicProtection.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                            FixCathodicProtection.MaterialType=NGR.FFA_Material_Type_Fix__c!=null ? NGR.FFA_Material_Type_Fix__c:'';
                            FixCathodicProtection.NewCathodicProtectionActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            FixCathodicProtection.NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c!=null ? NGR.FFA_Installed_On_Stream_Fix__c:'';
                            CathodicProtectionFixList.add(FixCathodicProtection);
                        }
                    }
                    
                    //AuxillaryControl Current/Fix
                    if(NGR.FFA_Asset_Type__c ==FFA_Constants.FFA_AUXCONTROL){//
                        FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryControlCurrent CurrentAuxillaryControl = new  FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryControlCurrent();
                            CurrentAuxillaryControl.AuxillaryControlActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            CurrentAuxillaryControl.AuxillaryControlSerialNumber  = NGR.FFA_Serial_Number__c!=null ? NGR.FFA_Serial_Number__c:'';
                            //CurrentAuxillaryControl.AuxillaryControlManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';
                            if(NGR.FFA_Other_Manufacturer__c!=null){
                                CurrentAuxillaryControl.AuxillaryControlManufacturer= NGR.FFA_Other_Manufacturer__c!=null ? NGR.FFA_Other_Manufacturer__c:'';
                            }
                            else{
                                CurrentAuxillaryControl.AuxillaryControlManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';   
                            }
                            //CurrentAuxillaryControl.AuxillaryControlModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                            if(NGR.FFA_Other_Model__c!=null){
                                CurrentAuxillaryControl.AuxillaryControlModel= NGR.FFA_Other_Model__c!=null ? NGR.FFA_Other_Model__c:'';
                            }
                            else{
                                CurrentAuxillaryControl.AuxillaryControlModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';  
                            }
                            CurrentAuxillaryControl.AuxillaryControlYearOfManufacture= NGR.FFA_Year_of_Manufacturer__c!=null ? NGR.FFA_Year_of_Manufacturer__c:'';
                            CurrentAuxillaryControl.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed__c);
                            CurrentAuxillaryControl.PrimaryFunction=NGR.FFA_Physical_Size__c!=null ? NGR.FFA_Physical_Size__c:'';
                            CurrentAuxillaryControl.ConnectionSize=NGR.FFA_Connection_size__c!=null ? NGR.FFA_Connection_size__c:'';
                            CurrentAuxillaryControl.ConnectionType=NGR.FFA_Connection_type__c!=null ? NGR.FFA_Connection_type__c:'';
                            CurrentAuxillaryControl.PressureRead=NGR.FFA_Pressure_Read__c!=null ? NGR.FFA_Pressure_Read__c:'';
                            CurrentAuxillaryControl.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                            AuxillaryControlCurrentList.add(CurrentAuxillaryControl);
                        //
                        if(NGR.Serial_Number_Fix__c != null || NGR.FFA_Manufacturer_Fix__c!=null || NGR.FFA_Model_Fix__c!=null || NGR.FFA_Year_of_Manufacturer_Fix__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryControlFix FixAuxillaryControl = new  FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryControlFix();
                            FixAuxillaryControl.AuxillaryControlSerialNumber= NGR.Serial_Number_Fix__c!=null ? NGR.Serial_Number_Fix__c:'';
                            //FixAuxillaryControl.AuxillaryControlManufacturer=NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            //FixAuxillaryControl.AuxillaryControlModel=NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            if(NGR.FFA_Other_Manufacturer_fix__c!=null){
                                FixAuxillaryControl.AuxillaryControlManufacturer=NGR.FFA_Other_Manufacturer_fix__c!=null ? NGR.FFA_Other_Manufacturer_fix__c:'';
                            }else{
                                FixAuxillaryControl.AuxillaryControlManufacturer= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            }
                            if(NGR.FFA_Other_Model_fix__c!=null){
                                FixAuxillaryControl.AuxillaryControlModel=NGR.FFA_Other_Model_fix__c!=null ? NGR.FFA_Other_Model_fix__c:'';
                            }else{
                                FixAuxillaryControl.AuxillaryControlModel= NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            }
                            FixAuxillaryControl.AuxillaryControlYearOfManufacture=NGR.FFA_Year_of_Manufacturer_Fix__c!=null ? NGR.FFA_Year_of_Manufacturer_Fix__c:'';
                            FixAuxillaryControl.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                            FixAuxillaryControl.PrimaryFunction=NGR.FFA_Primary_Function_Fix__c!=null ? NGR.FFA_Primary_Function_Fix__c:'';
                            FixAuxillaryControl.ConnectionSize=NGR.FFA_Connection_size_Fix__c!=null ? NGR.FFA_Connection_size_Fix__c:'';
                            FixAuxillaryControl.ConnectionType=NGR.FFA_Connection_Type_Fix__c!=null ? NGR.FFA_Connection_Type_Fix__c:'';
                            FixAuxillaryControl.PressureRead=NGR.FFA_Pressure_Read_Fix__c!=null ? NGR.FFA_Pressure_Read_Fix__c:'';
                            FixAuxillaryControl.NewAuxillaryControlActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            FixAuxillaryControl.NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c!=null ? NGR.FFA_Installed_On_Stream_Fix__c:''; 
                            AuxillaryControlFixList.add(FixAuxillaryControl);
                        }
                    }
                    
                    //AuxillaryRelief Current/Fix
                    if(NGR.FFA_Asset_Type__c ==FFA_Constants.FFA_AUXRELIEF){//FFA_Constants.FFA_AUXRELIEF_RECORD_TYPE
                        FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryReliefCurrent CurrentAuxillaryRelief = new  FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryReliefCurrent();
                            CurrentAuxillaryRelief.AuxillaryReliefActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            CurrentAuxillaryRelief.AuxillaryReliefSerialNumber = NGR.FFA_Serial_Number__c!=null ? NGR.FFA_Serial_Number__c:'';
                            //CurrentAuxillaryRelief.AuxillaryReliefManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';
                            if(NGR.FFA_Other_Manufacturer__c!=null){
                                CurrentAuxillaryRelief.AuxillaryReliefManufacturer= NGR.FFA_Other_Manufacturer__c!=null ? NGR.FFA_Other_Manufacturer__c:'';
                            }
                            else{
                               CurrentAuxillaryRelief.AuxillaryReliefManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';  
                            }
                            //CurrentAuxillaryRelief.AuxillaryReliefModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                            if(NGR.FFA_Other_Model__c!=null){
                                CurrentAuxillaryRelief.AuxillaryReliefModel= NGR.FFA_Other_Model__c!=null ? NGR.FFA_Other_Model__c:'';
                            }
                            else{
                              CurrentAuxillaryRelief.AuxillaryReliefModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';  
                            }
                            CurrentAuxillaryRelief.AuxillaryReliefYearOfManufacture= NGR.FFA_Year_of_Manufacturer__c!=null ? NGR.FFA_Year_of_Manufacturer__c:'';
                            CurrentAuxillaryRelief.DateInstalled= convertDateFormattoSAP(NGR.FFA_Date_Installed__c);
                            CurrentAuxillaryRelief.PrimaryFunction=NGR.FFA_Primary_Function__c!=null ? NGR.FFA_Primary_Function__c:'';
                            CurrentAuxillaryRelief.ConnectionSize=string.valueOf(NGR.FFA_Connection_size__c)!=null ? string.valueOf(NGR.FFA_Connection_size__c):'';
                            CurrentAuxillaryRelief.ConnectionType=NGR.FFA_Connection_type__c!=null ? NGR.FFA_Connection_type__c:'';
                            CurrentAuxillaryRelief.PressureRead=NGR.FFA_Pressure_Read__c!=null ? NGR.FFA_Pressure_Read__c:'';
                            CurrentAuxillaryRelief.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                            AuxillaryReliefCurrentList.add(CurrentAuxillaryRelief);
                        if(NGR.Serial_Number_Fix__c != null || NGR.FFA_Manufacturer_Fix__c!=null || NGR.FFA_Model_Fix__c!=null || NGR.FFA_Year_of_Manufacturer_Fix__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryReliefFix FixAuxillaryRelief = new  FFA_WorkOrderCompleteInterfaceWrapper.AuxillaryReliefFix();
                            FixAuxillaryRelief.AuxillaryReliefSerialNumber= NGR.Serial_Number_Fix__c!=null ? NGR.Serial_Number_Fix__c:'';
                            //FixAuxillaryRelief.AuxillaryReliefManufacturer=NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            //FixAuxillaryRelief.AuxillaryReliefModel=NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            if(NGR.FFA_Other_Manufacturer_fix__c!=null){
                                FixAuxillaryRelief.AuxillaryReliefManufacturer=NGR.FFA_Other_Manufacturer_fix__c!=null ? NGR.FFA_Other_Manufacturer_fix__c:'';
                            }else{
                                FixAuxillaryRelief.AuxillaryReliefManufacturer= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            }
                            if(NGR.FFA_Other_Model_fix__c!=null){
                                FixAuxillaryRelief.AuxillaryReliefModel=NGR.FFA_Other_Model_fix__c!=null ? NGR.FFA_Other_Model_fix__c:'';
                            }else{
                                FixAuxillaryRelief.AuxillaryReliefModel= NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            }
                            FixAuxillaryRelief.AuxillaryReliefYearOfManufacture=NGR.FFA_Year_of_Manufacturer_Fix__c!=null ? NGR.FFA_Year_of_Manufacturer_Fix__c:'';
                            FixAuxillaryRelief.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                            FixAuxillaryRelief.PrimaryFunction=NGR.FFA_Primary_Function_Fix__c!=null ? NGR.FFA_Primary_Function_Fix__c:'';
                            FixAuxillaryRelief.ConnectionSize=NGR.FFA_Connection_size_Fix__c!=null ? NGR.FFA_Connection_size_Fix__c:'';
                            FixAuxillaryRelief.ConnectionType=NGR.FFA_Connection_Type_Fix__c!=null ? NGR.FFA_Connection_Type_Fix__c:'';
                            FixAuxillaryRelief.PressureRead=NGR.FFA_Pressure_Read_Fix__c!=null ? NGR.FFA_Pressure_Read_Fix__c:'';
                            FixAuxillaryRelief.NewAuxillaryReliefActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:''; 
                            FixAuxillaryRelief.NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c!=null ? NGR.FFA_Installed_On_Stream_Fix__c:'';
                            AuxillaryReliefFixList.add(FixAuxillaryRelief);
                        }
                    }
                    
                    //Filters Current/Fix
                    if(NGR.FFA_Asset_Type__c ==FFA_Constants.FFA_FILTER && IsfilterActivityE==False){
                        FFA_WorkOrderCompleteInterfaceWrapper.FiltersCurrent CurrentFilters = new  FFA_WorkOrderCompleteInterfaceWrapper.FiltersCurrent();
                            CurrentFilters.FiltersActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:'';
                            CurrentFilters.FiltersSerialNumber = NGR.FFA_Serial_Number__c!=null ? NGR.FFA_Serial_Number__c:''; 
                            if(NGR.FFA_Other_Manufacturer__c!=null){
                                CurrentFilters.FiltersManufacturer= NGR.FFA_Other_Manufacturer__c!=null ? NGR.FFA_Other_Manufacturer__c:'';
                            }
                            else{
                              CurrentFilters.FiltersManufacturer= NGR.FFA_Manufacturer__c!=null ? NGR.FFA_Manufacturer__c:'';  
                            }
                            
                            if(NGR.FFA_Other_Model__c!=null){
                                CurrentFilters.FiltersModel= NGR.FFA_Other_Model__c!=null ? NGR.FFA_Other_Model__c:'';
                            }
                            else{ 
                                CurrentFilters.FiltersModel= NGR.FFA_Model__c!=null ? NGR.FFA_Model__c:'';
                            }
                            CurrentFilters.FilterYearOfManufacture= NGR.FFA_Year_of_Manufacturer__c!=null ? NGR.FFA_Year_of_Manufacturer__c:'';
                            CurrentFilters.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed__c);// string.valueOf(NGR.FFA_Date_Installed__c);
                            CurrentFilters.PrimaryFunction=NGR.FFA_Primary_Function__c!=null ? NGR.FFA_Primary_Function__c:'';
                            CurrentFilters.Physicalsize=NGR.FFA_Physical_Size__c!=null ? NGR.FFA_Physical_Size__c:'';
                            CurrentFilters.ConnectionSize=NGR.FFA_Connection_size__c!=null ? NGR.FFA_Connection_size__c:'';//Problem with SAP PI
                            CurrentFilters.ConnectionType=NGR.FFA_Connection_type__c!=null ? NGR.FFA_Connection_type__c:'';
                            CurrentFilters.PressureRead=NGR.FFA_Pressure_Read__c!=null ? NGR.FFA_Pressure_Read__c:'';
                            CurrentFilters.InstalledOnStream=NGR.FFA_Installed_On_Stream__c!=null ? NGR.FFA_Installed_On_Stream__c:'';
                            FiltersCurrentList.add(CurrentFilters);
                        if(NGR.Serial_Number_Fix__c != null || NGR.FFA_Manufacturer_Fix__c!=null || NGR.FFA_Model_Fix__c!=null || NGR.FFA_Year_of_Manufacturer_Fix__c!=null){
                            FFA_WorkOrderCompleteInterfaceWrapper.FiltersFix FixFilters = new  FFA_WorkOrderCompleteInterfaceWrapper.FiltersFix();
                            FixFilters.FiltersSerialNumber= NGR.Serial_Number_Fix__c!=null ? NGR.Serial_Number_Fix__c:'';
                            if(NGR.FFA_Other_Manufacturer_fix__c!=null){
                                FixFilters.FiltersManufacturer=NGR.FFA_Other_Manufacturer_fix__c!=null ? NGR.FFA_Other_Manufacturer_fix__c:'';
                            }else{
                                FixFilters.FiltersManufacturer= NGR.FFA_Manufacturer_Fix__c!=null ? NGR.FFA_Manufacturer_Fix__c:'';
                            }
                            if(NGR.FFA_Other_Model_fix__c!=null){
                                FixFilters.FiltersModel=NGR.FFA_Other_Model_fix__c!=null ? NGR.FFA_Other_Model_fix__c:'';
                            }else{
                                FixFilters.FiltersModel= NGR.FFA_Model_Fix__c!=null ? NGR.FFA_Model_Fix__c:'';
                            }
                            FixFilters.FilterYearOfManufacture=NGR.FFA_Year_of_Manufacturer_Fix__c!=null ? NGR.FFA_Year_of_Manufacturer_Fix__c:'';
                            FixFilters.DateInstalled=convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                            FixFilters.PrimaryFunction=NGR.FFA_Primary_Function_Fix__c!=null ? NGR.FFA_Primary_Function_Fix__c:'';
                            FixFilters.PhysicalSize=NGR.FFA_Physical_Size_Fix__c!=null ? NGR.FFA_Physical_Size_Fix__c:'';
                            FixFilters.ConnectionSize=NGR.FFA_Connection_size_Fix__c!=null ? NGR.FFA_Connection_size_Fix__c:'';
                            FixFilters.ConnectionType=NGR.FFA_Connection_Type_Fix__c!=null ? NGR.FFA_Connection_Type_Fix__c:'';
                            FixFilters.PressureRead=NGR.FFA_Pressure_Read_Fix__c!=null ? NGR.FFA_Pressure_Read_Fix__c:'';
                            FixFilters.NewFiltersActivityType=NGR.FFA_Activity_Type__c!=null ? NGR.FFA_Activity_Type__c:''; 
                            FixFilters.NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c!=null ? NGR.FFA_Installed_On_Stream_Fix__c:'';
                            FiltersFixList.add(FixFilters);
                        }
                    }
                    else{
                         if(filterStructeredJson!=null && NGR.FFA_Asset_Type__c ==FFA_Constants.FFA_FILTER && IsfilterActivityE==True){
                              filterStructeredJson=filterStructeredJson+FFACompleteInterfaceActivitytypeEJSON.returnFiltersJSON(NGR.id);
                              filterStructeredJson=filterStructeredJson+',';
                         }else{
                              if(NGR.FFA_Asset_Type__c == FFA_Constants.FFA_FILTER && IsfilterActivityE==True ){
                              filterStructeredJson=FFACompleteInterfaceActivitytypeEJSON.returnFiltersJSON(NGR.id);
                              filterStructeredJson=filterStructeredJson+',';
                              }
                         }
                         
                         
                    }
                    
                    if(NGR.FFA_Asset_Type__c ==FFA_Constants.FFA_REGULATOR){
                        //MPRM DATA for DOMESTIC
                        IF(Wraplist.FFA_Sender_ID__c=='RAINBOW'){
                           
                           RegMPRM.add(NGR.id);
                        }
                        
                        completiondetails.RegulatorDetailsAttached = 'Y';
                        //Current
                        string RegulatorManufacturer ;
                        string RegulatorModel ;
                        string RegulatorActivityType = NGR.FFA_Activity_Type__c!=null ? '"'+NGR.FFA_Activity_Type__c+'"' : null;
                        string RegulatorSerialNumber = NGR.FFA_Serial_Number__c!=null ? '"'+NGR.FFA_Serial_Number__c+'"' : null;
                        IF(wraplist.FFA_Sender_ID__c=='RAINBOW'){
                            IF(NGR.FFA_Current_Reg_Serial_Number_Selection__c=='Yes'){
                                RegulatorSerialNumber = NGR.FFA_Serial_Number__c!=null ? '"'+NGR.FFA_Serial_Number__c+'"' : null;
                                system.debug('--Reg1');
                            }
                            else if(NGR.FFA_Cur_Reg_Batch_Selection__c=='Yes'){
                                RegulatorSerialNumber = NGR.FFA_Regulator_Batch_Number__c!=null ? '"'+NGR.FFA_Regulator_Batch_Number__c+'"' : null;
                                system.debug('--Reg2');
                            }
                            else {
                                RegulatorSerialNumber = NGR.FFA_Serial_Number__c!=null ? '"'+NGR.FFA_Serial_Number__c+'"' : null;
                                system.debug('--Reg3');
                            }
                        }
                        RegulatorManufacturer = NGR.FFA_Other_Manufacturer__c!=null ? '"'+NGR.FFA_Other_Manufacturer__c+'"' : null;
                        if(RegulatorManufacturer=='' || RegulatorManufacturer ==null){
                            RegulatorManufacturer = NGR.FFA_Manufacturer__c!=null ? '"'+NGR.FFA_Manufacturer__c+'"' : null;
                        }
                        
                        RegulatorModel = NGR.FFA_Other_Model__c!=null ? '"'+NGR.FFA_Other_Model__c+'"' : null;
                        if(RegulatorModel =='' || RegulatorModel ==null){
                            RegulatorModel = NGR.FFA_Model__c!=null ? '"'+NGR.FFA_Model__c+'"' : null;
                        }
                        String RegPressureTier=SiteDetails.PressureTier!=null ? '"'+SiteDetails.PressureTier+'"' : null;
                        string RegulatorYearOfManufacture = NGR.FFA_Year_of_Manufacturer__c!=null ? '"'+NGR.FFA_Year_of_Manufacturer__c+'"' : null;
                        string InstalledOnStream = NGR.FFA_Installed_On_Stream__c!=null ? '"'+NGR.FFA_Installed_On_Stream__c+'"' : null;
                        //Need Mapping
                        string RegulatorSetPoint ;//= NGR.FFA_Installed_On_Stream__c!=null ? '"'+NGR.FFA_Installed_On_Stream__c+'"' : null;
                        string DateInstalledConvert = convertDateFormattoSAP(NGR.FFA_Date_Installed__c);
                        string DateInstalled;
                        if(string.isNotBlank(DateInstalledConvert)){
                            DateInstalled = DateInstalledConvert;
                        }else{
                            DateInstalled = DateInstalledConvert!=null ? '"'+DateInstalledConvert+'"' : null;
                        }
                        string PrimaryFunction = NGR.FFA_Primary_Function__c!=null ? '"'+NGR.FFA_Primary_Function__c+'"' : null;
                        string PhysicalSize = NGR.FFA_Physical_Size__c!=null ? '"'+NGR.FFA_Physical_Size__c+'"' : null;
                        string PressureRead = NGR.FFA_Pressure_Read__c!=null ? '"'+NGR.FFA_Pressure_Read__c+'"' : null;
                        string ConnectionSize = NGR.FFA_Connection_size__c!=null ? '"'+NGR.FFA_Connection_size__c+'"' : null;
                        string ConnectionType = NGR.FFA_Connection_type__c!=null ? '"'+NGR.FFA_Connection_type__c+'"' : null;
                        //Fix
                        string NewRegulatorSerialNumber = NGR.Serial_Number_Fix__c!=null ? '"'+NGR.Serial_Number_Fix__c+'"' : null;
                        IF(NewRegulatorSerialNumber==null){
                        NewRegulatorSerialNumber=NGR.FFA_Batch_Number_Fix__c!=null ? '"'+NGR.FFA_Batch_Number_Fix__c+'"' : null;
                        }
                        string NewRegulatorManufacturer ;
                        NewRegulatorManufacturer = NGR.FFA_Other_Manufacturer_fix__c!=null ? '"'+NGR.FFA_Other_Manufacturer_fix__c+'"' : null;
                        if(NewRegulatorManufacturer =='' || NewRegulatorManufacturer ==null){
                        NewRegulatorManufacturer = NGR.FFA_Manufacturer_Fix__c!=null ? '"'+NGR.FFA_Manufacturer_Fix__c+'"' : null;
                        }
                        
                        string NewRegulatorModel ;
                        NewRegulatorModel = NGR.FFA_Other_Model_fix__c!=null ? '"'+NGR.FFA_Other_Model_fix__c+'"' : null;
                        if(NewRegulatorModel =='' || NewRegulatorModel ==null){
                        NewRegulatorModel = NGR.FFA_Model_Fix__c!=null ? '"'+NGR.FFA_Model_Fix__c+'"' : null;
                        }
                        
                        //string NewRegulatorModel = NGR.FFA_Model_Fix__c!=null ? '"'+NGR.FFA_Model_Fix__c+'"' : null;
                        string NewRegulatorYearOfManufacture = NGR.FFA_Year_of_Manufacturer_Fix__c!=null ? '"'+NGR.FFA_Year_of_Manufacturer_Fix__c+'"' : null;
                        string NewInstalledOnStream ;
                        //Need Mapping
                        string NewRegulatorSetPoint ;//= NGR.FFA_Installed_On_Stream_Fix__c!=null ? '"'+NGR.FFA_Installed_On_Stream_Fix__c+'"' : null;
                        string DateInstalledConvertFix = convertDateFormattoSAP(NGR.FFA_Date_Installed_Fix__c);
                        string DateInstalledFix;
                        if(string.isNotBlank(DateInstalledConvertFix)){
                            DateInstalledFix = DateInstalledConvertFix;
                        }else{
                            DateInstalledFix = DateInstalledConvertFix!=null ? '"'+DateInstalledConvertFix+'"' : null;
                        }
                        string PrimaryFunctionFix = NGR.FFA_Primary_Function_Fix__c!=null ? '"'+NGR.FFA_Primary_Function_Fix__c+'"' : null;
                        string PhysicalSizeFix = NGR.FFA_Physical_Size_Fix__c!=null ? '"'+NGR.FFA_Physical_Size_Fix__c+'"' : null;
                        string PressureReadFix = NGR.FFA_Pressure_Read_Fix__c!=null ? '"'+NGR.FFA_Pressure_Read_Fix__c+'"' : null;
                        string ConnectionSizeFix =NGR.FFA_Connection_size_Fix__c!=null ? '"'+NGR.FFA_Connection_size_Fix__c+'"' : null;
                        string ConnectionTypeFix = NGR.FFA_Connection_Type_Fix__c!=null ? '"'+NGR.FFA_Connection_Type_Fix__c+'"' : null;
                        //Need Mapping
                        string NewRegulatorActivityType =NGR.FFA_Activity_Type__c!=null ? '"'+NGR.FFA_Activity_Type__c+'"' : null;
                        if((NGR.FFA_Activity_Type__c=='E' || NGR.FFA_Activity_Type__c=='F') && (NewInstalledOnStream ==null || NewInstalledOnStream=='' )){
                         NewInstalledOnStream='1';
                         
                        }else{
                        NewInstalledOnStream=NGR.FFA_Installed_On_Stream_Fix__c;
                        }
                        IF(NGR.FFA_IsRegulatorOnSite__c=='No'){
                        system.debug('Onsite---'+NGR.FFA_IsRegulatorOnSite__c);
                            RegulatorActivityType=null;
                            RegulatorSerialNumber=null;
                            RegulatorManufacturer=null;
                            RegulatorModel=null;
                            RegulatorYearOfManufacture=null;
                            InstalledOnStream=null;
                            DateInstalled=null;
                            PrimaryFunction=null;
                            PhysicalSize=null;
                            RegPressureTier=null;
                            PressureRead=null;
                            ConnectionSize=null;
                            RegulatorSetPoint=null;
                            ConnectionType=null;
                        }
                        
                        RegulatorInnerJson = RegulatorInnerJson+'"Current":{'+
                            ' "RegulatorActivityType":'+RegulatorActivityType+','+
                            ' "RegulatorSerialNumber":'+RegulatorSerialNumber+','+
                            ' "RegulatorManufacturer":'+RegulatorManufacturer+','+
                            ' "RegulatorModel":'+RegulatorModel+','+
                            ' "RegulatorYearOfManufacture":'+RegulatorYearOfManufacture+','+
                            ' "InstalledOnStream":'+InstalledOnStream+','+
                            ' "DateInstalled":'+DateInstalled+','+
                            ' "PrimaryFunction":'+PrimaryFunction+','+
                            ' "PhysicalSize":'+PhysicalSize+','+ 
                            ' "PressureTier":'+RegPressureTier+','+
                            ' "PressureRead":'+PressureRead+','+
                            ' "ConnectionSize":'+ConnectionSize+','+
                            ' "RegulatorSetPoint":'+RegulatorSetPoint+','+
                            ' "ConnectionType":'+ConnectionType+''+
                            ' },'+
                            '"Fix":{'+
                            ' "NewRegulatorSerialNumber":'+NewRegulatorSerialNumber+','+
                            ' "NewRegulatorActivityType":'+NewRegulatorActivityType+','+
                            ' "NewRegulatorManufacturer":'+NewRegulatorManufacturer+','+
                            ' "NewRegulatorModel":'+NewRegulatorModel+','+
                            ' "NewRegulatorYearOfManufacture":'+NewRegulatorYearOfManufacture+','+
                            ' "NewInstalledOnStream": '+NewInstalledOnStream+','+
                            ' "DateInstalled":'+DateInstalledFix+','+
                            ' "PrimaryFunction":'+PrimaryFunctionFix+','+
                            ' "PhysicalSize":'+PhysicalSizeFix+','+
                            ' "PressureRead":'+PressureReadFix+','+
                            ' "ConnectionSize":'+ConnectionSizeFix+','+
                            ' "NewRegulatorSetPoint":'+RegulatorSetPoint+','+
                            ' "ConnectionType":'+ConnectionTypeFix+''+
                            '},'; 
                        
                       
                        isRegulatorCheck = true;
                    }
                }
              }
            }
            //MPRM JOB Data 
            if(!MPRMids.isEmpty()){
            MPRMSJOBs=MPRMdata(MPRMids,RegMPRM);
            
            }
        }
       
      if(isValveActivityE==True){
           ValvesStructeredJson = ValvesStructeredJson.substring(0,ValvesStructeredJson.length()-1);
           ValvesStructeredJson='"Valves":{'+ValvesStructeredJson+'},';
           system.debug('Valves SAPJSON--->'+slamshutStructeredJson);
       }
       if(isSlamshutActivityE==True){
           slamshutStructeredJson=slamshutStructeredJson.substring(0,slamshutStructeredJson.length()-1);
           slamshutStructeredJson='"Slamshut":{'+slamshutStructeredJson+'},';
           system.debug('SlamShut SAPJSON--->'+slamshutStructeredJson);
       }
       if(isBoilerActivityE==True && biolerStructeredJson!=null){
           biolerStructeredJson=biolerStructeredJson.substring(0,biolerStructeredJson.length()-1);
           biolerStructeredJson='"Boiler":{'+biolerStructeredJson+'},';
           system.debug('SlamShut SAPJSON--->'+biolerStructeredJson);
           }
       if(IsfilterActivityE==True && filterStructeredJson!=null){
           filterStructeredJson=filterStructeredJson.substring(0,filterStructeredJson.length()-1);
           filterStructeredJson='"Filters":{'+filterStructeredJson+'},';
           system.debug('Filter SAPJSON--->'+filterStructeredJson);
       }
       system.debug('--creepJson'+creepReliefStructeredJson);
       if(IscreepReliefActivityE==True && creepReliefStructeredJson!=null){
           creepReliefStructeredJson = creepReliefStructeredJson.replace('null"Current":', '"Current":');
           creepReliefStructeredJson=creepReliefStructeredJson.substring(0,creepReliefStructeredJson.length()-1);
           creepReliefStructeredJson='"CreepRelief":{'+creepReliefStructeredJson+'},';
           system.debug('creepRelief SAPJSON--->'+creepReliefStructeredJson);
       }
 
       
       if(RegulatorInnerJson!=null){
            string str1 = RegulatorInnerJson.removeStartIgnoreCase('null');
            string str = str1.substring(0,str1.length()-1);
            RegulatorInnerfinalJson = str;
            system.debug('Regulator Json after remove null====>>>'+RegulatorInnerfinalJson);
            RegulatorMainJson = '"Regulator":{'+RegulatorInnerfinalJson+'},';
        }
        //*Individul Node which contains Data will be Sending to Main Wrappers
        //* and after it will be send to Main Node
        workOrders.Completion = completiondetails;
        workOrders.Payment = PaymentList;
        if(headers.ReceiverID=='RAINBOW'){
           workOrders.MPRM=MPRMSJOBs;
        }
        Sites.Details = SiteDetails;
        
        //* All Current Nodes of Assets
        Meters.Current = MeterCurrentList;
        convertors.Current = ConvertorCurrentList;
        convertors.ReadingsAndData = ConvertorReadingsAndDataList;
        FlowComputers.current = FlowComputerCurrentList;
        SlamShuts.Current = SlamShutCurrentList;
        CreepReliefs.Current = CreepReliefCurrentList;
        Boilers.Current = BoilerCurrentList;
        WaterBathHeater.Current = WaterBathHeaterCurrentList;
        ShellandTubes.Current = ShellAndtubeCurrentList;
        Chromatographs.Current = ChromatographCurrentList;
        Densitometers.Current = DensitometerCurrentList;
        Valve.Current = CurrentValvesList;
        Pipeworks.Current = PipeWorkCurrentList;
        CathodicProtections.Current = CathodicProtectionCurrentList;
        AuxillaryControls.Current = AuxillaryControlCurrentList;
        AuxillaryReliefs.Current = AuxillaryReliefCurrentList;
        Filter.Current = FiltersCurrentList;
        
        //* All Fix Nodes of Assets
        Meters.Fix = MeterFixList;
        convertors.Fix = ConvertorFixList;
        convertors.FixReadingsAndData = ConvertorFixReadingsAndDataList;
        FlowComputers.Fix = FlowComputerFixList;
        SlamShuts.Fix = SlamShutFixList;
        CreepReliefs.Fix = CreepReliefFixList;
        Boilers.Fix = BoilerFixList;
        WaterBathHeater.Fix = WaterBathHeaterFixList;
        ShellandTubes.Fix = ShellAndTubeFixList;
        Chromatographs.Fix = ChromatographFixList;
        Densitometers.Fix = DensitometerFixList;
        Valve.Fix = FixValvesList;
        Pipeworks.Fix = PipeWorkFixList;
        CathodicProtections.Fix = CathodicProtectionFixList;
        AuxillaryControls.Fix = AuxillaryControlFixList;
        AuxillaryReliefs.Fix = AuxillaryReliefFixList;
        Filter.Fix = FiltersFixList;
        
        Jobs_toSend.Job = workOrders;
        Jobs_toSend.Site = Sites;
        Jobs_toSend.Meter = Meters;
        Jobs_toSend.Convertor=Convertors;
        Jobs_toSend.FlowComputer=FlowComputers;
        if(isslamshutActivityE==False){
            Jobs_toSend.SlamShut = SlamShuts;
        }
        if(iscreepReliefActivityE==False){
            Jobs_toSend.CreepRelief = CreepReliefs;
        }
        if(isBoilerActivityE==False){
                Jobs_toSend.Boiler = Boilers;
        }
        
        Jobs_toSend.WaterBathHeaters = WaterBathHeater;
        Jobs_toSend.ShellandTube = ShellandTubes;
        Jobs_toSend.Chromatograph = Chromatographs;
        Jobs_toSend.Densitometer = Densitometers;
            if(isValveActivityE==False){
                Jobs_toSend.Valves = Valve;
            }
        Jobs_toSend.Pipework = Pipeworks;
        Jobs_toSend.CathodicProtection = CathodicProtections;
        Jobs_toSend.AuxillaryControl = AuxillaryControls;
        Jobs_toSend.AuxillaryRelief = AuxillaryReliefs;
        if(isFilterActivityE==False){
             Jobs_toSend.Filters = Filter;
        }
        
        jsonWrapper.body = Jobs_toSend;
        jsonWrapper.header = headers;
        // JSON.serialize(jsonWrapper);
        string JSONPayload;
        if(isValveActivityE == true || isSlamshutActivityE==true || isFilterActivityE==true || iscreepReliefActivityE==true || isBoilerActivityE==true || RegulatorMainJson!=null ){
            string BeforeJsonEdit = JSON.serialize(jsonWrapper);
            if(ValvesStructeredJson==null){
                ValvesStructeredJson='';
            }
            if(slamshutStructeredJson==null){
                slamshutStructeredJson='';
            }
            if(biolerStructeredJson==null){
                biolerStructeredJson='';
            }
            if(filterStructeredJson==null){
                filterStructeredJson='';
            }
            if(creepReliefStructeredJson==null){
                creepReliefStructeredJson='';
            }
            
            string AfterJsonEdit = BeforeJsonEdit.substring(0, BeforeJsonEdit.indexOf('"WaterBathHeaters":{'))+ ValvesStructeredJson + slamshutStructeredJson + biolerStructeredJson+ filterStructeredJson+creepReliefStructeredJson+RegulatorMainJson+
                                   BeforeJsonEdit.substring(BeforeJsonEdit.indexOf('"WaterBathHeaters":{'), BeforeJsonEdit.length());
            JSONPayload = AfterJsonEdit;
            system.debug('---Json with valves---->>>>'+JSONPayload);
        }
        
        else{
            JSONPayload = JSON.serialize(jsonWrapper);
            
        }
        //Blob headerValue = Blob.valueOf(label.FFA_Integration_UserName + ':' + label.FFA_Integration_Password);
        //String authorizationHeader = 'Basic '+EncodingUtil.base64Encode(headerValue);
        failedPayload=JSONPayload;
        Httprequest request = new HttpRequest();
        Http http = new Http();
        request.setMethod('POST');
        request.setEndpoint('callout:NG_WorkOrder_Completion_From_Salesforce_NC');
        request.setTimeout(120000);
        request.setBody(JSONPayload);
        system.debug('PayloadSenttoSAP-->'+JSONPayload);          
        HttpResponse response = http.send(request);  
        System.debug('responseBody: ---->'+response.getBody());
        System.debug('Respcode       --->'+response.getStatusCode());
        FFA_Interface_Runs__c InterfaceLogs = new FFA_Interface_Runs__c(Interface_Name__c='/FFACompleteInterface',Transaction_Message__c=JSONPayload, Transaction_Status__c = string.valueOf(response.getStatusCode()),Work_Order__c=WONUMBER);
        insert InterfaceLogs;
        
        system.debug('Interfaceid'+InterfaceLogs.id);
        List<QueueSobject> lstQueues = [SELECT Id,queue.Name, QueueId FROM QueueSobject WHERE SobjectType = 'Case'and queue.Name='API error Queue'];
            If(InterfaceLogs!=null && InterfaceLogs.Transaction_Status__c!=null ){
                If(InterfaceLogs.Transaction_Status__c!=null && !(InterfaceLogs.Transaction_Status__c.contains('200') ||
                                                                  InterfaceLogs.Transaction_Status__c.contains('202') ||
                                                                 InterfaceLogs.Transaction_Status__c.contains('503')  || 
                                                                 InterfaceLogs.Transaction_Status__c.contains('504')  ||
                                                                 InterfaceLogs.Transaction_Status__c.contains('500') ||
                                                                 InterfaceLogs.Transaction_Status__c.contains('501')) ||
                                                                 InterfaceLogs.Transaction_Status__c.contains('502')){
                    Case ApexCases=new Case(Status='New',
                                            Origin='API',
                                            Description=InterfaceLogs.Transaction_Status__c+'Error',
                                            OwnerId=lstQueues[0].queueId,
                                            Subject='Complete API Failed Work order : '+WONUMBER,
                                            Priority='High',
                                            Interface_Log__c=InterfaceLogs.id);
                    Insert ApexCases;
                    
                }
          }
          //REPLAN WILL HAPPEN MULTIPLE TIMES FOR SAME JOB BY SP'S ,SO REQUIRED TO UNCHECK 
            IF(replanUncheck!=null){
                FOR(WorkOrder repaln:replanUncheck){
                    repaln.FFA_Service_Provider_Replan__c='No';
                }
            }
            IF(policyUncheck!=null){
                FOR(Workorder WOUncheck:policyUncheck){
                    WOUncheck.PolicyReplanJob__c=False;
                 }
            }
            IF(SAPReplanUncheck!=null){
                FOR(Workorder SAPreplancheck:SAPReplanUncheck){
                    SAPreplancheck.SAP_Replan__c='No';
                 }
            }
            
            IF(!replanUncheck.isEmpty()){update replanUncheck;}
            IF(!policyUncheck.isEmpty()){update policyUncheck;}
            IF(!SAPReplanUncheck.isEmpty()){update SAPReplanUncheck;}
        
        }catch(Exception e){
            Boolean TimeOutException;
            FFA_Interface_Runs__c InterfaceLogs = new FFA_Interface_Runs__c(Interface_Name__c='/FFACompleteInterface',
                                                                            Transaction_Message__c=failedPayload!=null ? failedPayload :'' ,
                                                                            Interface_Exception__c=e.getMessage()+'Exception at Line'+e.getLineNumber(), 
                                                                            Transaction_Status__c ='400',
                                                                            Work_Order__c=WONUMBER);
            
            IF(InterfaceLogs.Interface_Exception__c.contains('Read timed')){
                 InterfaceLogs.Transaction_Status__c='503';
                 TimeOutException=True;
                 
            }
            
            insert InterfaceLogs;
            system.debug('Exception In CompleteInterface at Line No----:'+e.getLineNumber()+'with Error Message:'+e.getMessage());
            List<QueueSobject> lstQueues = [SELECT Id,queue.Name, QueueId FROM QueueSobject WHERE SobjectType = 'Case'and queue.Name='API error Queue'];
            If(TimeOutException==False && InterfaceLogs!=null){
                Case ApexCases=new Case(Status='New',
                                        Origin='API',
                                        Description=e.getMessage()+'Exception at Line'+e.getLineNumber()+'Please contact system Admin',
                                        OwnerId=lstQueues[0].queueId,
                                        Subject='Complete API Failed Work order : '+WONUMBER,
                                        Priority='High',
                                        Interface_Log__c=InterfaceLogs.id);
                Insert ApexCases;
            }
            
        }
        
   
        
        
    }
    //MPRM DATA creation
    public static FFA_WorkOrderCompleteInterfaceWrapper.MPRM MPRMdata(Set<ID> MPRMdata,Set<Id> RegMPRM){
    FFA_WorkOrderCompleteInterfaceWrapper.MPRM MPRMJobdata = new FFA_WorkOrderCompleteInterfaceWrapper.MPRM(); 
        List<Job_Information__c> jobInfoList=[SELECT Id,FFA_Current_Reg_Relief_Valve_Setting_1__c,FFA_Current_Reg_Relief_Valve_Setting_2__c,FFA_Current_Reg_Relief_Valve_Setting_3__c,
                                                FFA_Current_Reg_Slam_Check_Test_1__c,FFA_Current_Reg_Slam_Check_Test_2__c,FFA_Current_Reg_Slam_Check_Test_3__c,
                                                FFA_New_Reg_Relief_Valve_Setting_Test_1__c,FFA_New_Reg_Relief_Valve_Setting_Test_2__c,FFA_New_Reg_Relief_Valve_Setting_Test_3__c,
                                                FFA_New_Reg_Slam_Check_Test_1__c,FFA_New_Reg_Slam_Check_Test_2__c,FFA_New_Reg_Slam_Check_Test_3__c,
                                                FFA_Working_Pressure_Reading_mbar__c,FFA_Standing_Pressure_Reading_mbar__c,FFA_Other_remedial_work_comments__c,
                                                FFA_Required_to_leave_any_Warning_Notice__c,FFA_WarningNoticeComment__c,
                                                FFA_Remedial_work_not_completed_notes__c,FFA_Remedial_not_completed_reason__c,FFA_Action_1__c,FFA_Action_1_been_rectified__c,FFA_Action_1_not_rectified_reason__c,FFA_Corrective_Action_1_Description__c,
                                                FFA_Action_2__c,FFA_Action_2_been_rectified__c,FFA_Action_2_not_rectified_reason__c,FFA_Corrective_Action_2_Description__c,
                                                FFA_Action_3__c,FFA_Action_3_been_rectified__c,FFA_Action_3_not_rectified_reason__c,FFA_Corrective_Action_3_Description__c,
                                                FFA_Action_4__c,FFA_Action_4_been_rectified__c,FFA_Action_4_not_rectified_reason__c,FFA_Corrective_Action_4_Description__c
                                                FROM Job_Information__c WHERE id=:MPRMdata];
         List<FFA_NGV_Asset__c> Assets=[Select ID ,FFA_Current_Working_Pressure_Reading__c,FFA_New_Working_Pressure_Reading__c,FFA_Regulator_Removed__c,FFA_Regulator_replace_reason__c,FFA_Single_Twin_fix__c,FFA_Single_Twin__c,FFA_Pressure_Read_Fix__c from FFA_NGV_Asset__c WHERE id=:RegMPRM limit 1];  
         String RegulatorCurrentWorkingPressureRead;
         For(FFA_NGV_Asset__c NGR:Assets){
               MPRMJobdata.MPRMRegRepl=NGR.FFA_Regulator_Removed__c !=null ? NGR.FFA_Regulator_Removed__c :'';
               MPRMJobdata.MPRMRegReplReason=NGR.FFA_Regulator_replace_reason__c!=null?NGR.FFA_Regulator_replace_reason__c:'';
               MPRMJobdata.MPRMAssRegOnsite=NGR.FFA_Single_Twin_fix__c !=null ? NGR.FFA_Single_Twin_fix__c :'';
               MPRMJobdata.MPRMVisRegOnsite=NGR.FFA_Single_Twin__c !=null ? NGR.FFA_Single_Twin__c :'';
               MPRMJobdata.MPRMNewRegWpr=string.valueof(NGR.FFA_New_Working_Pressure_Reading__c) !=null ? string.valueof(NGR.FFA_New_Working_Pressure_Reading__c) :'';
               RegulatorCurrentWorkingPressureRead=string.valueof(NGR.FFA_Current_Working_Pressure_Reading__c) !=null ? string.valueof(NGR.FFA_Current_Working_Pressure_Reading__c) :'';
         }
         
            if(!jobInfoList.isEmpty()){
                for(Job_Information__c jobInfo:jobInfoList){
                    if(jobInfo.FFA_Current_Reg_Relief_Valve_Setting_1__c!=null){
                         MPRMJobdata.MPRMCurRegRV1=string.valueof(jobInfo.FFA_Current_Reg_Relief_Valve_Setting_1__c);
                    }
                    if(jobInfo.FFA_Current_Reg_Relief_Valve_Setting_2__c!=null){
                         MPRMJobdata.MPRMCurRegRV2=string.valueof(jobInfo.FFA_Current_Reg_Relief_Valve_Setting_2__c);
                    }
                    if(jobInfo.FFA_Current_Reg_Relief_Valve_Setting_3__c!=null){
                         MPRMJobdata.MPRMCurRegRV3=string.valueof(jobInfo.FFA_Current_Reg_Relief_Valve_Setting_3__c);
                    }
                    if(jobInfo.FFA_Current_Reg_Slam_Check_Test_1__c!=null){
                         MPRMJobdata.MPRMCurRegSC1=string.valueof(jobInfo.FFA_Current_Reg_Slam_Check_Test_1__c);
                    }
                    if(jobInfo.FFA_Current_Reg_Slam_Check_Test_2__c!=null){
                         MPRMJobdata.MPRMCurRegSC2=string.valueof(jobInfo.FFA_Current_Reg_Slam_Check_Test_2__c);
                    }
                    if(jobInfo.FFA_Current_Reg_Slam_Check_Test_3__c!=null){
                         MPRMJobdata.MPRMCurRegSC3=string.valueof(jobInfo.FFA_Current_Reg_Slam_Check_Test_3__c);
                    }
                    if(jobInfo.FFA_New_Reg_Relief_Valve_Setting_Test_1__c!=null){
                         MPRMJobdata.MPRMNewRegRV1=string.valueof(jobInfo.FFA_New_Reg_Relief_Valve_Setting_Test_1__c);
                    }
                    if(jobInfo.FFA_New_Reg_Relief_Valve_Setting_Test_2__c!=null){
                         MPRMJobdata.MPRMNewRegRV2=string.valueof(jobInfo.FFA_New_Reg_Relief_Valve_Setting_Test_2__c);
                    }
                    if(jobInfo.FFA_New_Reg_Relief_Valve_Setting_Test_3__c!=null){
                         MPRMJobdata.MPRMNewRegRV3=string.valueof(jobInfo.FFA_New_Reg_Relief_Valve_Setting_Test_3__c);
                    }
                    if(jobInfo.FFA_New_Reg_Slam_Check_Test_1__c!=null){
                         MPRMJobdata.MPRMNewRegSC1=string.valueof(jobInfo.FFA_New_Reg_Slam_Check_Test_1__c);
                    }
                    if(jobInfo.FFA_New_Reg_Slam_Check_Test_2__c!=null){
                         MPRMJobdata.MPRMNewRegSC2=string.valueof(jobInfo.FFA_New_Reg_Slam_Check_Test_2__c);
                    }
                    if(jobInfo.FFA_New_Reg_Slam_Check_Test_3__c!=null){
                         MPRMJobdata.MPRMNewRegSC3=string.valueof(jobInfo.FFA_New_Reg_Slam_Check_Test_3__c);
                    }
                    if(jobInfo.FFA_Working_Pressure_Reading_mbar__c!=null){
                         MPRMJobdata.MPRMVisWorPres=string.valueof(jobInfo.FFA_Working_Pressure_Reading_mbar__c);
                    }
                    if(jobInfo.FFA_Standing_Pressure_Reading_mbar__c!=null){
                         MPRMJobdata.MPRMVisStaPres=string.valueof(jobInfo.FFA_Standing_Pressure_Reading_mbar__c);
                    }
                    if(jobInfo.FFA_Remedial_not_completed_reason__c!=null){
                         MPRMJobdata.MPRMInsRemRes=string.valueof(jobInfo.FFA_Remedial_not_completed_reason__c);
                    }
                    if(jobInfo.FFA_Remedial_work_not_completed_notes__c!=null){
                        MPRMJobdata.MPRMInsRemNot=string.valueof(jobInfo.FFA_Remedial_work_not_completed_notes__c);
                    }
                    if(jobInfo.FFA_Other_remedial_work_comments__c!=null){
                         MPRMJobdata.MPRMInsRemCom=string.valueof(jobInfo.FFA_Other_remedial_work_comments__c);
                    }
                    /*S-658453 START */
                    if(jobInfo.FFA_Required_to_leave_any_Warning_Notice__c=='Yes'){
                         MPRMJobdata.MPRMVisWarNot=jobInfo.FFA_Required_to_leave_any_Warning_Notice__c;
                         MPRMJobdata.MPRMVisWarNotRes=jobInfo.FFA_WarningNoticeComment__c!=null ? jobInfo.FFA_WarningNoticeComment__c :'';
                    }
                    /*S-658453 END */
                    if(jobInfo.FFA_Action_1__c!=null && jobInfo.FFA_Action_1__c=='Excessive Meter Corrosion'){
                        MPRMJobdata.MPRMVisInsEMC=jobInfo.FFA_Action_1__c;
                        MPRMJobdata.MPRMVisInsEMCCA=jobInfo.FFA_Corrective_Action_1_Description__c;
                        MPRMJobdata.MPRMVisInsEMCNR=jobInfo.FFA_Action_1_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_1__c!=null && jobInfo.FFA_Action_1__c=='Up to 1mtr Vent Pipe copper extended'){
                        MPRMJobdata.MPRMVisInsVP1=jobInfo.FFA_Action_1__c;
                        MPRMJobdata.MPRMVisInsVP1CA=jobInfo.FFA_Corrective_Action_1_Description__c;
                        MPRMJobdata.MPRMVisInsVP1NR=jobInfo.FFA_Action_1_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_1__c!=null && jobInfo.FFA_Action_1__c=='Up to 2mtr Vent Pipe copper extended'){
                        MPRMJobdata.MPRMVisInsVP2=jobInfo.FFA_Action_1__c;
                        MPRMJobdata.MPRMVisInsVP2CA=jobInfo.FFA_Corrective_Action_1_Description__c;
                        MPRMJobdata.MPRMVisInsVP2NR=jobInfo.FFA_Action_1_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_1__c!=null && jobInfo.FFA_Action_1__c=='Vent Pipe extended copper up to 1mtr'){
                        MPRMJobdata.MPRMVisInsVP1=jobInfo.FFA_Action_1__c;
                        MPRMJobdata.MPRMVisInsVP1CA=jobInfo.FFA_Corrective_Action_1_Description__c;
                        MPRMJobdata.MPRMVisInsVP1NR=jobInfo.FFA_Action_1_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_1__c!=null && jobInfo.FFA_Action_1__c=='Vent Pipe extended copper up to 2mtr'){
                        MPRMJobdata.MPRMVisInsVP2=jobInfo.FFA_Action_1__c;
                        MPRMJobdata.MPRMVisInsVP2CA=jobInfo.FFA_Corrective_Action_1_Description__c;
                        MPRMJobdata.MPRMVisInsVP2NR=jobInfo.FFA_Action_1_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_1__c!=null && jobInfo.FFA_Action_1__c=='Vent Pipe extended Plastic'){
                        MPRMJobdata.MPRMVisInsVPP=jobInfo.FFA_Action_1__c;
                        MPRMJobdata.MPRMVisInsVPPCA=jobInfo.FFA_Corrective_Action_1_Description__c;
                        MPRMJobdata.MPRMVisInsVPPNR=jobInfo.FFA_Action_1_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_1__c!=null && jobInfo.FFA_Action_1__c=='Electrical Apparatus'){
                        MPRMJobdata.MPRMVisInsEA=jobInfo.FFA_Action_1__c;
                        MPRMJobdata.MPRMVisInsEACA=jobInfo.FFA_Corrective_Action_1_Description__c;
                        MPRMJobdata.MPRMVisInsEANR=jobInfo.FFA_Action_1_not_rectified_reason__c;

                    }
                    
                    if(jobInfo.FFA_Action_1__c!=null && (jobInfo.FFA_Action_1__c=='Other' || jobInfo.FFA_Action_1__c=='Regulator Exchange Required')){
                        MPRMJobdata.MPRMVisInsOT=jobInfo.FFA_Action_1__c;
                        MPRMJobdata.MPRMVisInsOTCA=jobInfo.FFA_Corrective_Action_1_Description__c;
                        MPRMJobdata.MPRMVisInsOTNR=jobInfo.FFA_Action_1_not_rectified_reason__c;

                    }
                    //Action 2
                    
                    if(jobInfo.FFA_Action_2__c!=null && jobInfo.FFA_Action_2__c=='Excessive Meter Corrosion'){
                        MPRMJobdata.MPRMVisInsEMC=jobInfo.FFA_Action_2__c;
                        MPRMJobdata.MPRMVisInsEMCCA=jobInfo.FFA_Corrective_Action_2_Description__c;
                        MPRMJobdata.MPRMVisInsEMCNR=jobInfo.FFA_Action_2_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_2__c!=null && jobInfo.FFA_Action_2__c=='Up to 1mtr Vent Pipe copper extended'){
                        MPRMJobdata.MPRMVisInsVP1=jobInfo.FFA_Action_2__c;
                        MPRMJobdata.MPRMVisInsVP1CA=jobInfo.FFA_Corrective_Action_2_Description__c;
                        MPRMJobdata.MPRMVisInsVP1NR=jobInfo.FFA_Action_2_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_2__c!=null && jobInfo.FFA_Action_2__c=='Up to 2mtr Vent Pipe copper extended'){
                        MPRMJobdata.MPRMVisInsVP2=jobInfo.FFA_Action_2__c;
                        MPRMJobdata.MPRMVisInsVP2CA=jobInfo.FFA_Corrective_Action_2_Description__c;
                        MPRMJobdata.MPRMVisInsVP2NR=jobInfo.FFA_Action_2_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_2__c!=null && jobInfo.FFA_Action_2__c=='Vent Pipe extended copper up to 1mtr'){
                        MPRMJobdata.MPRMVisInsVP1=jobInfo.FFA_Action_2__c;
                        MPRMJobdata.MPRMVisInsVP1CA=jobInfo.FFA_Corrective_Action_2_Description__c;
                        MPRMJobdata.MPRMVisInsVP1NR=jobInfo.FFA_Action_2_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_2__c!=null && jobInfo.FFA_Action_2__c=='Vent Pipe extended copper up to 2mtr'){
                        MPRMJobdata.MPRMVisInsVP2=jobInfo.FFA_Action_2__c;
                        MPRMJobdata.MPRMVisInsVP2CA=jobInfo.FFA_Corrective_Action_2_Description__c;
                        MPRMJobdata.MPRMVisInsVP2NR=jobInfo.FFA_Action_2_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_2__c!=null && jobInfo.FFA_Action_2__c=='Vent Pipe extended Plastic'){
                        MPRMJobdata.MPRMVisInsVPP=jobInfo.FFA_Action_2__c;
                        MPRMJobdata.MPRMVisInsVPPCA=jobInfo.FFA_Corrective_Action_2_Description__c;
                        MPRMJobdata.MPRMVisInsVPPNR=jobInfo.FFA_Action_2_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_2__c!=null && jobInfo.FFA_Action_2__c=='Electrical Apparatus'){
                        MPRMJobdata.MPRMVisInsEA=jobInfo.FFA_Action_2__c;
                        MPRMJobdata.MPRMVisInsEACA=jobInfo.FFA_Corrective_Action_2_Description__c;
                        MPRMJobdata.MPRMVisInsEANR=jobInfo.FFA_Action_2_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_2__c!=null && (jobInfo.FFA_Action_2__c=='Other' || jobInfo.FFA_Action_2__c=='Regulator Exchange Required')){
                        MPRMJobdata.MPRMVisInsOT=jobInfo.FFA_Action_2__c;
                        MPRMJobdata.MPRMVisInsOTCA=jobInfo.FFA_Corrective_Action_2_Description__c;
                        MPRMJobdata.MPRMVisInsOTNR=jobInfo.FFA_Action_2_not_rectified_reason__c;

                    }
                    
                    //Action 3
                    if(jobInfo.FFA_Action_3__c!=null && jobInfo.FFA_Action_3__c=='Excessive Meter Corrosion'){
                        MPRMJobdata.MPRMVisInsEMC=jobInfo.FFA_Action_3__c;
                        MPRMJobdata.MPRMVisInsEMCCA=jobInfo.FFA_Corrective_Action_3_Description__c;
                        MPRMJobdata.MPRMVisInsEMCNR=jobInfo.FFA_Action_3_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_3__c!=null && jobInfo.FFA_Action_3__c=='Up to 1mtr Vent Pipe copper extended'){
                        MPRMJobdata.MPRMVisInsVP1=jobInfo.FFA_Action_3__c;
                        MPRMJobdata.MPRMVisInsVP1CA=jobInfo.FFA_Corrective_Action_3_Description__c;
                        MPRMJobdata.MPRMVisInsVP1NR=jobInfo.FFA_Action_3_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_3__c!=null && jobInfo.FFA_Action_3__c=='Up to 2mtr Vent Pipe copper extended'){
                        MPRMJobdata.MPRMVisInsVP2=jobInfo.FFA_Action_3__c;
                        MPRMJobdata.MPRMVisInsVP2CA=jobInfo.FFA_Corrective_Action_3_Description__c;
                        MPRMJobdata.MPRMVisInsVP2NR=jobInfo.FFA_Action_3_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_3__c!=null && jobInfo.FFA_Action_3__c=='Vent Pipe extended copper up to 1mtr'){
                        MPRMJobdata.MPRMVisInsVP1=jobInfo.FFA_Action_3__c;
                        MPRMJobdata.MPRMVisInsVP1CA=jobInfo.FFA_Corrective_Action_3_Description__c;
                        MPRMJobdata.MPRMVisInsVP1NR=jobInfo.FFA_Action_3_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_3__c!=null && jobInfo.FFA_Action_3__c=='Vent Pipe extended copper up to 2mtr'){
                        MPRMJobdata.MPRMVisInsVP2=jobInfo.FFA_Action_3__c;
                        MPRMJobdata.MPRMVisInsVP2CA=jobInfo.FFA_Corrective_Action_3_Description__c;
                        MPRMJobdata.MPRMVisInsVP2NR=jobInfo.FFA_Action_3_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_3__c!=null && jobInfo.FFA_Action_3__c=='Vent Pipe extended Plastic'){
                        MPRMJobdata.MPRMVisInsVPP=jobInfo.FFA_Action_3__c;
                        MPRMJobdata.MPRMVisInsVPPCA=jobInfo.FFA_Corrective_Action_3_Description__c;
                        MPRMJobdata.MPRMVisInsVPPNR=jobInfo.FFA_Action_3_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_3__c!=null && jobInfo.FFA_Action_3__c=='Electrical Apparatus'){
                        MPRMJobdata.MPRMVisInsEA=jobInfo.FFA_Action_3__c;
                        MPRMJobdata.MPRMVisInsEACA=jobInfo.FFA_Corrective_Action_3_Description__c;
                        MPRMJobdata.MPRMVisInsEANR=jobInfo.FFA_Action_3_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_3__c!=null && (jobInfo.FFA_Action_3__c=='Other' || jobInfo.FFA_Action_3__c=='Regulator Exchange Required')){
                        MPRMJobdata.MPRMVisInsOT=jobInfo.FFA_Action_3__c;
                        MPRMJobdata.MPRMVisInsOTCA=jobInfo.FFA_Corrective_Action_3_Description__c;
                        MPRMJobdata.MPRMVisInsOTNR=jobInfo.FFA_Action_3_not_rectified_reason__c;

                    }
                    //Action 4
                    if(jobInfo.FFA_Action_4__c!=null && jobInfo.FFA_Action_4__c=='Excessive Meter Corrosion'){
                        MPRMJobdata.MPRMVisInsEMC=jobInfo.FFA_Action_4__c;
                        MPRMJobdata.MPRMVisInsEMCCA=jobInfo.FFA_Corrective_Action_4_Description__c;
                        MPRMJobdata.MPRMVisInsEMCNR=jobInfo.FFA_Action_4_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_4__c!=null && jobInfo.FFA_Action_4__c=='Up to 1mtr Vent Pipe copper extended'){
                        MPRMJobdata.MPRMVisInsVP1=jobInfo.FFA_Action_4__c;
                        MPRMJobdata.MPRMVisInsVP1CA=jobInfo.FFA_Corrective_Action_4_Description__c;
                        MPRMJobdata.MPRMVisInsVP1NR=jobInfo.FFA_Action_4_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_4__c!=null && jobInfo.FFA_Action_4__c=='Up to 2mtr Vent Pipe copper extended'){
                        MPRMJobdata.MPRMVisInsVP2=jobInfo.FFA_Action_4__c;
                        MPRMJobdata.MPRMVisInsVP2CA=jobInfo.FFA_Corrective_Action_4_Description__c;
                        MPRMJobdata.MPRMVisInsVP2NR=jobInfo.FFA_Action_4_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_4__c!=null && jobInfo.FFA_Action_4__c=='Vent Pipe extended copper up to 1mtr'){
                        MPRMJobdata.MPRMVisInsVP1=jobInfo.FFA_Action_4__c;
                        MPRMJobdata.MPRMVisInsVP1CA=jobInfo.FFA_Corrective_Action_4_Description__c;
                        MPRMJobdata.MPRMVisInsVP1NR=jobInfo.FFA_Action_4_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_4__c!=null && jobInfo.FFA_Action_4__c=='Vent Pipe extended copper up to 2mtr'){
                        MPRMJobdata.MPRMVisInsVP2=jobInfo.FFA_Action_4__c;
                        MPRMJobdata.MPRMVisInsVP2CA=jobInfo.FFA_Corrective_Action_4_Description__c;
                        MPRMJobdata.MPRMVisInsVP2NR=jobInfo.FFA_Action_4_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_4__c!=null && jobInfo.FFA_Action_4__c=='Vent Pipe extended Plastic'){
                        MPRMJobdata.MPRMVisInsVPP=jobInfo.FFA_Action_4__c;
                        MPRMJobdata.MPRMVisInsVPPCA=jobInfo.FFA_Corrective_Action_4_Description__c;
                        MPRMJobdata.MPRMVisInsVPPNR=jobInfo.FFA_Action_4_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_4__c!=null && jobInfo.FFA_Action_4__c=='Electrical Apparatus'){
                        MPRMJobdata.MPRMVisInsEA=jobInfo.FFA_Action_4__c;
                        MPRMJobdata.MPRMVisInsEACA=jobInfo.FFA_Corrective_Action_4_Description__c;
                        MPRMJobdata.MPRMVisInsEANR=jobInfo.FFA_Action_4_not_rectified_reason__c;

                    }
                    if(jobInfo.FFA_Action_4__c!=null && (jobInfo.FFA_Action_4__c=='Other' || jobInfo.FFA_Action_4__c=='Regulator Exchange Required')){
                        MPRMJobdata.MPRMVisInsOT=jobInfo.FFA_Action_4__c;
                        MPRMJobdata.MPRMVisInsOTCA=jobInfo.FFA_Corrective_Action_4_Description__c;
                        MPRMJobdata.MPRMVisInsOTNR=jobInfo.FFA_Action_4_not_rectified_reason__c;

                    }
                }
            }
            IF(MPRMJobdata.MPRMVisWorPres==null){
            MPRMJobdata.MPRMVisWorPres=RegulatorCurrentWorkingPressureRead;
            } 
        return MPRMJobdata;
    }
    public static string convertDateFormattoSAP(date SFdate){
        String Convereteddate;
        if(SFdate!=null){
            Convereteddate=string.valueof(SFdate);
            Convereteddate=Convereteddate.substring(0,10);
            Convereteddate=Convereteddate.replaceAll('-','');
        }
        return Convereteddate;
    }
    
    public static string getLocationCode(string LocationCode){
        string LocationCodeValue;
        if(string.isNotBlank(LocationCode)){
            LocationCodeValue = LocationCode.substring(0,2);
        }
        return LocationCodeValue;
    }
    
   
   
}