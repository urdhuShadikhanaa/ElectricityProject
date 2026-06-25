/////////////////////////////////////////////////
/*          SAP-FFA COMPLETE INTERFACE TEST      */
/*          Author: Ankit Tomar                */ 
/*          Company: Wipro Technologies        */
/*          Created Date: 20/08/2019           */
/////////////////////////////////////////////////
@isTest(SeeAllData=true)
public class FFA_WorkOrderCompleteInterfaceTest { 
    
    @isTest static void completeInterfaceMethod(){ 
        
        
        FFA_WorkOrderCompleteInterfaceWrapper.Header headers = new FFA_WorkOrderCompleteInterfaceWrapper.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        string str = string.valueOf(system.datetime.now());
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='PHOENIX',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                    // Completion_Date__c=string.valueOf(system.date.today()),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',Completion_Date__c=str,
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC');
        insert wo;
        FFA_AddCost__c FFAAdditionalCosts=new FFA_AddCost__c(FAA_LabourCostType__c='Labour',FFA_MaterialQuantity__c=10,Work_Order__c=wo.id);
        insert FFAAdditionalCosts;

        
        FFA_NGV_Asset__c MeterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert MeterAssets;
        
        FFA_NGV_Asset__c ConverterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Converter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ConverterAssets;
        
        FFA_NGV_Asset__c RegulatorAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Regulator',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert RegulatorAssets; 
        
        FFA_NGV_Asset__c FlowComputerAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Flow Computer',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert FlowComputerAssets;
        
        FFA_NGV_Asset__c SlamshutAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Slamshut',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='E',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Manufacturer__c='g',FFA_Other_Model__c='g',
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert SlamshutAssets;
        
        FFA_NGV_Asset__c CreepReliefAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Creep Relief',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert CreepReliefAssets;
        
        FFA_NGV_Asset__c BoilerAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Boiler',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert BoilerAssets;
        
        FFA_NGV_Asset__c WaterBathHeaterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Water Bath Heater',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert WaterBathHeaterAssets;
        
        FFA_NGV_Asset__c ShellAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Shell & Tube',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ShellAssets;
        
        FFA_NGV_Asset__c ChromatographAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Chromatograph',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ChromatographAssets;
        
        FFA_NGV_Asset__c DensitometerAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Densitometer',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert DensitometerAssets;
        
        FFA_NGV_Asset__c ValveAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Valve',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ValveAssets;
        
        FFA_NGV_Asset__c PipeworkAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Pipework',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert PipeworkAssets;
        
        FFA_NGV_Asset__c CPAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Cathodic Protection',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert CPAssets;
        
        FFA_NGV_Asset__c AuxAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Auxillary Control',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert AuxAssets;
        
        FFA_NGV_Asset__c AuxRefAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Auxillary Relief',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert AuxRefAssets;
        
        FFA_NGV_Asset__c FilterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Filter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert FilterAssets;
        
        wo.Status = 'Completed';
        wo.Further_Work_Required__c='No';
        update wo;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(wo.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        
        
        string JsonBody = WorkOrderId;
        
      /*  RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = label.FFA_IntegrationEndPointURL;
        req.httpMethod = 'PUT';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        
        string strres;
        strres= req.requestBody.tostring();*/
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        FFA_WorkOrderCompleteInterface.CompletedWorkorders(WorkOrderId);
        Test.StopTest();
       
        
    }
    
    @isTest static void completeInterfaceMethod11(){ 
        
        
        FFA_WorkOrderCompleteInterfaceWrapper.Header headers = new FFA_WorkOrderCompleteInterfaceWrapper.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        string str = string.valueOf(system.datetime.now());
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='PHOENIX',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                     //added by prachi
                                    // Completion_Date__c=string.valueOf(system.date.today()),
                                    //Completion_Date__c=DateTime.ValueofGmt(Wraplist.Completion_Date__c.replace('T', ' '));string.valueOf(system.date.today()),

                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',Completion_Date__c=str,
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC');
        insert wo;
        FFA_AddCost__c FFAAdditionalCosts=new FFA_AddCost__c(FAA_LabourCostType__c='Labour',FFA_MaterialQuantity__c=10,Work_Order__c=wo.id);
        insert FFAAdditionalCosts;

        
        
        
        FFA_NGV_Asset__c SlamshutAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Slamshut',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='E',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',FFA_Other_Manufacturer_fix__c='k',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert SlamshutAssets;
        FFA_NGV_Asset__c BoilerAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Boiler',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',FFA_Other_Model_fix__c='l',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Model__c='k',
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert BoilerAssets;
        FFA_NGV_Asset__c FilterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Filter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',FFA_Other_Model_fix__c='l',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Model__c='k',
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert FilterAssets;
        FFA_NGV_Asset__c CreepReliefAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Creep Relief',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',FFA_Other_Model_fix__c='l',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Model__c='k',
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert CreepReliefAssets;
        
        
        
        wo.Status = 'Completed';
        wo.Further_Work_Required__c='No';
        update wo;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(wo.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        
        
        string JsonBody = WorkOrderId;
        
      /*  RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = label.FFA_IntegrationEndPointURL;
        req.httpMethod = 'PUT';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        
        string strres;
        strres= req.requestBody.tostring();*/
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        FFA_WorkOrderCompleteInterface.CompletedWorkorders(WorkOrderId);
        Test.StopTest();
       
        
    }
    @isTest static void completeInterfaceMethod12(){ 
        
        
        FFA_WorkOrderCompleteInterfaceWrapper.Header headers = new FFA_WorkOrderCompleteInterfaceWrapper.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        string str = string.valueOf(system.datetime.now());
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='PHOENIX',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                    // Completion_Date__c=string.valueOf(system.date.today()),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',Completion_Date__c=str,
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC');
        insert wo;
        FFA_AddCost__c FFAAdditionalCosts=new FFA_AddCost__c(FAA_LabourCostType__c='Labour',FFA_MaterialQuantity__c=10,Work_Order__c=wo.id);
        insert FFAAdditionalCosts;

        
        
        
        FFA_NGV_Asset__c ValveAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Valve',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Manufacturer__c='g',
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ValveAssets;
        FFA_NGV_Asset__c SlamshutAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Slamshut',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Model_fix__c='j',
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert SlamshutAssets;
        FFA_NGV_Asset__c BoilerAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Boiler',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',FFA_Other_Manufacturer_fix__c='l',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Manufacturer__c='k',
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert BoilerAssets;
        FFA_NGV_Asset__c FilterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Filter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',FFA_Other_Manufacturer_fix__c='l',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Manufacturer__c='k',
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert FilterAssets;
        FFA_NGV_Asset__c CreepReliefAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Creep Relief',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',FFA_Other_Manufacturer_fix__c='l',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Manufacturer__c='k',
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert CreepReliefAssets;
        
        
        
        wo.Status = 'Completed';
        wo.Further_Work_Required__c='No';
        update wo;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(wo.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        
        
        string JsonBody = WorkOrderId;
        
      /*  RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = label.FFA_IntegrationEndPointURL;
        req.httpMethod = 'PUT';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        
        string strres;
        strres= req.requestBody.tostring();*/
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        FFA_WorkOrderCompleteInterface.CompletedWorkorders(WorkOrderId);
        Test.StopTest();
       
        
    }
    @isTest static void completeInterfaceMethod13(){ 
        
        
        FFA_WorkOrderCompleteInterfaceWrapper.Header headers = new FFA_WorkOrderCompleteInterfaceWrapper.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        string str = string.valueOf(system.datetime.now());
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='PHOENIX',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                    // Completion_Date__c=string.valueOf(system.date.today()),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',Completion_Date__c=str,
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC');
        insert wo;
        FFA_AddCost__c FFAAdditionalCosts=new FFA_AddCost__c(FAA_LabourCostType__c='Labour',FFA_MaterialQuantity__c=10,Work_Order__c=wo.id);
        insert FFAAdditionalCosts;

        
        
        
        FFA_NGV_Asset__c ValveAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Valve',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',FFA_Other_Model__c='g',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Manufacturer__c='g',
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ValveAssets;
        
        
        
        wo.Status = 'Completed';
        wo.Further_Work_Required__c='No';
        update wo;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(wo.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        
        
        string JsonBody = WorkOrderId;
        
      /*  RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = label.FFA_IntegrationEndPointURL;
        req.httpMethod = 'PUT';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        
        string strres;
        strres= req.requestBody.tostring();*/
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        FFA_WorkOrderCompleteInterface.CompletedWorkorders(WorkOrderId);
        Test.StopTest();
       
        
    }
    @isTest static void completeInterfaceMethod14(){ 
        
        
        FFA_WorkOrderCompleteInterfaceWrapper.Header headers = new FFA_WorkOrderCompleteInterfaceWrapper.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        string str = string.valueOf(system.datetime.now());
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='PHOENIX',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                    // Completion_Date__c=string.valueOf(system.date.today()),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',Completion_Date__c=str,
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC');
        insert wo;
        FFA_AddCost__c FFAAdditionalCosts=new FFA_AddCost__c(FAA_LabourCostType__c='Labour',FFA_MaterialQuantity__c=10,Work_Order__c=wo.id);
        insert FFAAdditionalCosts;

        
        
        
        FFA_NGV_Asset__c ValveAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Valve',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Manufacturer__c='g',
                                                       FFA_Pressure_Read__c='P',FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',FFA_Other_Model_fix__c='j',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ValveAssets;
        
        
        
        wo.Status = 'Completed';
        wo.Further_Work_Required__c='No';
        update wo;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(wo.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        
        
        string JsonBody = WorkOrderId;
        
      /*  RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = label.FFA_IntegrationEndPointURL;
        req.httpMethod = 'PUT';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        
        string strres;
        strres= req.requestBody.tostring();*/
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        FFA_WorkOrderCompleteInterface.CompletedWorkorders(WorkOrderId);
        Test.StopTest();
       
        
    }
    @isTest static void completeInterfaceMethod15(){ 
        
        
        FFA_WorkOrderCompleteInterfaceWrapper.Header headers = new FFA_WorkOrderCompleteInterfaceWrapper.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        string str = string.valueOf(system.datetime.now());
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='PHOENIX',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                    // Completion_Date__c=string.valueOf(system.date.today()),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',Completion_Date__c=str,
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC');
        insert wo;
        FFA_AddCost__c FFAAdditionalCosts=new FFA_AddCost__c(FAA_LabourCostType__c='Labour',FFA_MaterialQuantity__c=10,Work_Order__c=wo.id);
        insert FFAAdditionalCosts;

        
        
        
        FFA_NGV_Asset__c ValveAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Valve',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Manufacturer__c='g',
                                                       FFA_Pressure_Read__c='P',FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',FFA_Other_Model__c='k',FFA_Other_Manufacturer_fix__c='h',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ValveAssets;
        
        
        
        wo.Status = 'Completed';
        wo.Further_Work_Required__c='No';
        update wo;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(wo.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        
        
        string JsonBody = WorkOrderId;
        
      /*  RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = label.FFA_IntegrationEndPointURL;
        req.httpMethod = 'PUT';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        
        string strres;
        strres= req.requestBody.tostring();*/
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        FFA_WorkOrderCompleteInterface.CompletedWorkorders(WorkOrderId);
        Test.StopTest();
       
        
    }    
    @isTest static void completeInterfaceMethod1(){ 
        
        
        FFA_WorkOrderCompleteInterfaceWrapper.Header headers = new FFA_WorkOrderCompleteInterfaceWrapper.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        string str = string.valueOf(system.datetime.now());
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='RAINBOW',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(), 
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='CR',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                    // Completion_Date__c=string.valueOf(system.date.today()),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',
                                     FFA_OperationNumber__c='0010',Completion_Date__c=str,FFA_Service_Provider_Replan__c='Yes',
                                     Status='New',
                                     FFA_JobCode__c='JC');
        insert wo;
        FFA_AddCost__c FFAAdditionalCosts=new FFA_AddCost__c(FAA_LabourCostType__c='Labour',FFA_MaterialQuantity__c=10,Work_Order__c=wo.id,FFA_MaterialCostType__c='Equipment');
        insert FFAAdditionalCosts;
        FFA_AddCost__c FFAAdditionalCosts1=new FFA_AddCost__c(FAA_LabourHours__c=2,Work_Order__c=wo.id,FFA_MaterialCostType__c='Equipment');
        insert FFAAdditionalCosts1;
        Job_Information__c jobInfo = new Job_Information__c(FFA_Current_Reg_Relief_Valve_Setting_1__c=1,FFA_Current_Reg_Relief_Valve_Setting_2__c=1,FFA_Current_Reg_Relief_Valve_Setting_3__c=1,FFA_Current_Reg_Slam_Check_Test_1__c=1,FFA_Current_Reg_Slam_Check_Test_2__c=1,FFA_Current_Reg_Slam_Check_Test_3__c=1,Work_Order__c=wo.Id,FFA_Object_Type__c='Safety Checks',FFA_Safety_Check_Complete__c='Yes',FFA_Safety_Check_Reason_Code__c='01',
                                                           FFA_New_Reg_Relief_Valve_Setting_Test_1__c=1,FFA_New_Reg_Relief_Valve_Setting_Test_2__c=1,FFA_New_Reg_Relief_Valve_Setting_Test_3__c=1,FFA_New_Reg_Slam_Check_Test_1__c=1,FFA_New_Reg_Slam_Check_Test_2__c=1,FFA_New_Reg_Slam_Check_Test_3__c=1,FFA_Working_Pressure_Reading_mbar__c=1,FFA_Standing_Pressure_Reading_mbar__c=1,FFA_Remedial_not_completed_reason__c='Follow up',
                                                            FFA_Remedial_work_not_completed_notes__c='r',FFA_Other_remedial_work_comments__c='l',FFA_Action_1__c='Excessive Meter Corrosion',FFA_Action_2__c='Excessive Meter Corrosion',FFA_Action_3__c='Excessive Meter Corrosion',FFA_Action_4__c='Excessive Meter Corrosion');
        insert jobInfo;
        Job_Information__c jobInfo1 = new Job_Information__c(Work_Order__c=wo.Id,FFA_Object_Type__c='Safety Checks',FFA_Safety_Check_Complete__c='Yes',FFA_Safety_Check_Reason_Code__c='02',FFA_Action_1__c='Up to 1mtr Vent Pipe copper extended',FFA_Action_2__c='Up to 1mtr Vent Pipe copper extended',FFA_Action_3__c='Up to 1mtr Vent Pipe copper extended',FFA_Action_4__c='Up to 1mtr Vent Pipe copper extended');
        insert jobInfo1;
        Job_Information__c jobInfo2 = new Job_Information__c(Work_Order__c=wo.Id,FFA_Object_Type__c='Safety Checks',FFA_Safety_Check_Complete__c='No',FFA_Safety_Check_Reason_Code__c='49',FFA_Action_1__c='Up to 2mtr Vent Pipe copper extended    ',FFA_Action_2__c='Up to 2mtr Vent Pipe copper extended ',FFA_Action_3__c='Up to 2mtr Vent Pipe copper extended ',FFA_Action_4__c='Up to 2mtr Vent Pipe copper extended ');
        insert jobInfo2;
        Job_Information__c jobInfo3 = new Job_Information__c(Work_Order__c=wo.Id,FFA_Object_Type__c='Safety Checks',FFA_Safety_Check_Complete__c='No',FFA_Safety_Check_Reason_Code__c='49',FFA_Action_1__c='Vent Pipe extended Plastic',FFA_Action_3__c='Vent Pipe extended Plastic',FFA_Action_4__c='Vent Pipe extended Plastic',FFA_Action_2__c='Vent Pipe extended Plastic');
        insert jobInfo3;
        Job_Information__c jobInfo4 = new Job_Information__c(Work_Order__c=wo.Id,FFA_Object_Type__c='Safety Checks',FFA_Safety_Check_Complete__c='No',FFA_Safety_Check_Reason_Code__c='49',FFA_Action_1__c='Electrical Apparatus',FFA_Action_3__c='Electrical Apparatus',FFA_Action_4__c='Electrical Apparatus',FFA_Action_2__c='Electrical Apparatus');
        insert jobInfo4;
        Job_Information__c jobInfo5 = new Job_Information__c(Work_Order__c=wo.Id,FFA_Object_Type__c='Safety Checks',FFA_Safety_Check_Complete__c='No',FFA_Safety_Check_Reason_Code__c='49',FFA_Action_1__c='Other',FFA_Action_3__c='Other',FFA_Action_4__c='Other',FFA_Action_2__c='Other');
        insert jobInfo5;
        
        FFA_NGV_Asset__c MeterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',FFA_Meter_Reading_Date_Fix__c=System.date.today(),
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Meter_Reading_Date__c=System.date.today(),
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',FFA_Unrecorded_Meter_Model__c='V',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',FFA_ThirdPartyMeter__c='Yes',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019',FFA_Unrecorded_Meter_Manufacturer__c='S');
        insert MeterAssets;
        FFA_NGV_Asset__c MeterAssets1 = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',FFA_Other_Model_fix__c='y',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Manufacturer__c='V',
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',FFA_Other_Model__c='F',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',FFA_ThirdPartyMeter__c='No',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert MeterAssets1;
        FFA_NGV_Asset__c MeterAssets2 = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',FFA_Other_Manufacturer_fix__c='G',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert MeterAssets2;
        FFA_NGV_Asset__c ConverterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Converter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ConverterAssets;
        FFA_NGV_Asset__c ConverterAssets1 = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Converter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',FFA_Other_Manufacturer__c='R',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Model__c='T',
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',FFA_Other_Model_fix__c='j',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',FFA_Other_Manufacturer_fix__c='F',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ConverterAssets1;
        FFA_NGV_Asset__c RegulatorAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Regulator',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert RegulatorAssets; 
        
        FFA_NGV_Asset__c FlowComputerAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Flow Computer',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert FlowComputerAssets;
        FFA_NGV_Asset__c FlowComputerAssets1 = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Flow Computer',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',FFA_Other_Model__c='l',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Manufacturer__c='j',
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',FFA_Other_Model_fix__c='j',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',FFA_Other_Manufacturer_fix__c='k',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert FlowComputerAssets1;
        FFA_NGV_Asset__c SlamshutAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Slamshut',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_Other_Model_fix__c='j',
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='F',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert SlamshutAssets;
        
        FFA_NGV_Asset__c CreepReliefAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Creep Relief',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert CreepReliefAssets;
        
        FFA_NGV_Asset__c BoilerAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Boiler',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert BoilerAssets;
        
        FFA_NGV_Asset__c WaterBathHeaterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Water Bath Heater',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert WaterBathHeaterAssets;
        
        FFA_NGV_Asset__c ShellAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Shell & Tube',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ShellAssets;
        
        FFA_NGV_Asset__c ChromatographAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Chromatograph',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ChromatographAssets;
        
        FFA_NGV_Asset__c DensitometerAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Densitometer',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert DensitometerAssets;
        
        FFA_NGV_Asset__c ValveAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Valve',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ValveAssets;
        
        FFA_NGV_Asset__c PipeworkAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Pipework',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert PipeworkAssets;
        
        FFA_NGV_Asset__c CPAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Cathodic Protection',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert CPAssets;
        
        FFA_NGV_Asset__c AuxAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Auxillary Control',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert AuxAssets;
        
        FFA_NGV_Asset__c AuxRefAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Auxillary Relief',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert AuxRefAssets;
        
        FFA_NGV_Asset__c FilterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Filter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='E',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert FilterAssets;
        
        wo.Status = 'Completed';
        wo.Further_Work_Required__c='No';
        update wo;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(wo.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        
        
        string JsonBody = WorkOrderId;
        
      /*  RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = label.FFA_IntegrationEndPointURL;
        req.httpMethod = 'PUT';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        
        string strres;
        strres= req.requestBody.tostring();*/
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        FFA_WorkOrderCompleteInterface.CompletedWorkorders(WorkOrderId);
        Test.StopTest();
       
        
    }
    
    @isTest static void statusServiceEngneerUpdateInterfaceMethod(){
        workOrderServiceEngineerstatusUpdate.Header Headers=new workOrderServiceEngineerstatusUpdate.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        //WorkOrder
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='S',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     Further_Work_Required__c='No',
                                     FFA_JobCode__c='JC',FFA_RequestedAppointmentDate__c=system.now());
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'Arrived',Onsite__c=system.now(), Duration=120,DurationType='Hours',ParentRecordId=wo.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(sa.Id);
        string enStatus = sa.Status;
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        workOrderServiceEngineerstatusUpdate.CompletedWorkorders(WorkOrderId,enStatus);
        Test.StopTest();
        
     }
    
    @isTest static void statusServiceEngneerUpdateEnrouteMethod(){
        workOrderServiceEngineerstatusUpdate.Header Headers=new workOrderServiceEngineerstatusUpdate.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        //WorkOrder
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='S',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     Further_Work_Required__c='No',
                                     FFA_JobCode__c='JC',FFA_RequestedAppointmentDate__c=system.now());
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'Enroute',Enroute__c=system.now(),Onsite__c=system.now(), Duration=120,DurationType='Hours',ParentRecordId=wo.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(sa.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        string enStatus = sa.Status;
        workOrderServiceEngineerstatusUpdate.CompletedWorkorders(WorkOrderId,enStatus);
        Test.StopTest();
        
     }
    
    @isTest static void statusServiceEngneerUpdateExceptionMethod(){
        workOrderServiceEngineerstatusUpdate.Header Headers=new workOrderServiceEngineerstatusUpdate.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        //WorkOrder
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='S',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC',FFA_RequestedAppointmentDate__c=system.now());
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'Enroute',Enroute__c=system.now(),Onsite__c=system.now(), Duration=120,DurationType='Hours',ParentRecordId=wo.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(sa.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        Test.setMock(HttpCalloutMock.class, new RestMockfail());
        Test.startTest();
        string enStatus = sa.Status;
        workOrderServiceEngineerstatusUpdate.CompletedWorkorders(WorkOrderId,enStatus);
        Test.StopTest();
        
     }
     
     @isTest static void statusServiceEngneerUpdateExceptionMethodT2(){
        workOrderServiceEngineerstatusUpdate.Header Headers=new workOrderServiceEngineerstatusUpdate.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        //WorkOrder
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='S',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC',FFA_RequestedAppointmentDate__c=system.now());
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'Started Work',Enroute__c=system.now(),Onsite__c=system.now(), Duration=120,DurationType='Hours',ParentRecordId=wo.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),FFA_Long_Job_Date_Time__c=System.Datetime.now());
        insert sa;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(sa.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        Test.setMock(HttpCalloutMock.class, new RestMockfail());
        Test.startTest();
        string enStatus = 'LongJob';
        workOrderServiceEngineerstatusUpdate.CompletedWorkorders(WorkOrderId,enStatus);
        Test.StopTest();
        
     }
     
     @isTest static void statusServiceEngneerUpdateExceptionMethodT1(){
        workOrderServiceEngineerstatusUpdate.Header Headers=new workOrderServiceEngineerstatusUpdate.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        //WorkOrder
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='S',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC',FFA_RequestedAppointmentDate__c=system.now());
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'Started Work',Enroute__c=system.now(),Onsite__c=system.now(), Duration=120,DurationType='Hours',ParentRecordId=wo.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(sa.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        Test.setMock(HttpCalloutMock.class, new RestMockfail());
        Test.startTest();
        string enStatus = 'ReturnJob';
        workOrderServiceEngineerstatusUpdate.CompletedWorkorders(WorkOrderId,enStatus);
        Test.StopTest();
        
     }
    
    @isTest static void completeInterfaceMethod3(){ 
        
        
        FFA_WorkOrderCompleteInterfaceWrapper.Header headers = new FFA_WorkOrderCompleteInterfaceWrapper.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='S',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     Further_Work_Required__c='No',
                                     FFA_JobCode__c='JC');
        insert wo;
        
        FFA_NGV_Asset__c MeterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert MeterAssets;
        
        FFA_NGV_Asset__c ConverterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Converter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ConverterAssets;
        
        FFA_NGV_Asset__c RegulatorAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Regulator',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert RegulatorAssets; 
        
        FFA_NGV_Asset__c FlowComputerAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Flow Computer',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert FlowComputerAssets;
        
        FFA_NGV_Asset__c SlamshutAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Slamshut',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert SlamshutAssets;
        
        FFA_NGV_Asset__c CreepReliefAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Creep Relief',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert CreepReliefAssets;
        
        FFA_NGV_Asset__c BoilerAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Boiler',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert BoilerAssets;
        
        FFA_NGV_Asset__c WaterBathHeaterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Water Bath Heater',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert WaterBathHeaterAssets;
        
        FFA_NGV_Asset__c ShellAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Shell & Tube',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ShellAssets;
        
        FFA_NGV_Asset__c ChromatographAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Chromatograph',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ChromatographAssets;
        
        FFA_NGV_Asset__c DensitometerAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Densitometer',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert DensitometerAssets;
        
        FFA_NGV_Asset__c ValveAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Valve',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert ValveAssets;
        
        FFA_NGV_Asset__c PipeworkAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Pipework',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert PipeworkAssets;
        
        FFA_NGV_Asset__c CPAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Cathodic Protection',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert CPAssets;
        
        FFA_NGV_Asset__c AuxAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Auxillary Control',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert AuxAssets;
        
        FFA_NGV_Asset__c AuxRefAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Auxillary Relief',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert AuxRefAssets;
        
        FFA_NGV_Asset__c FilterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Filter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert FilterAssets;
        
        wo.Status = 'Completed';
        update wo;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(wo.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        
        
        string JsonBody = WorkOrderId;
        
      /*  RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = label.FFA_IntegrationEndPointURL;
        req.httpMethod = 'PUT';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        
        string strres;
        strres= req.requestBody.tostring();*/
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        FFA_WorkOrderCompleteInterface.CompletedWorkorders(WorkOrderId);
        Test.StopTest();
       
        
    }
    
    @isTest static void statusServiceEngneerUpdateExceptionMethod1(){
        workOrderServiceEngineerstatusUpdate.Header Headers=new workOrderServiceEngineerstatusUpdate.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        //WorkOrder
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='S',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC',FFA_RequestedAppointmentDate__c=system.now());
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(Status = 'Enroute',Enroute__c=system.now(),Onsite__c=system.now(), Duration=120,DurationType='Hours',ParentRecordId=wo.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(sa.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        string enStatus = sa.Status;
        workOrderServiceEngineerstatusUpdate.CompletedWorkorders(WorkOrderId,enStatus);
        Test.StopTest();
        
     }
    
    @isTest static void cancelledInterfaceMethod(){ 
      FFA_WorkOrderCompleteInterfaceWrapper.Header headers = new FFA_WorkOrderCompleteInterfaceWrapper.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='S',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC');
        insert wo;
        
        FFA_NGV_Asset__c MeterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert MeterAssets;
        
        
         
        
        
        wo.Status = 'Cancelled';
        update wo;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(wo.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        
        
        string JsonBody = WorkOrderId;
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        FFA_WorkOrderCompleteInterface.CompletedWorkorders(WorkOrderId);
        Test.StopTest();
    }
    
    @isTest static void terminatedInterfaceMethod(){ 
      FFA_WorkOrderCompleteInterfaceWrapper.Header headers = new FFA_WorkOrderCompleteInterfaceWrapper.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='S',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC');
        insert wo;
        
        FFA_NGV_Asset__c MeterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert MeterAssets;
        
        
         
        
        
        wo.Status = 'Terminated';
        update wo;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(wo.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        
        
        string JsonBody = WorkOrderId;
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        FFA_WorkOrderCompleteInterface.CompletedWorkorders(WorkOrderId);
        Test.StopTest();
    }
    
    @isTest static void FWRInterfaceMethod(){ 
      FFA_WorkOrderCompleteInterfaceWrapper.Header headers = new FFA_WorkOrderCompleteInterfaceWrapper.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='S',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     Further_Work_Required__c='Yes',
                                     FFA_JobCode__c='JC');
        insert wo;
        
        FFA_NGV_Asset__c MeterAssets = new FFA_NGV_Asset__c(Work_Order__c=wo.Id,FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='02', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert MeterAssets;
        
        
         
        
        
        wo.Status = 'Further Work Required';
        update wo;
        ServiceAppointment sa1 = new ServiceAppointment(Status = 'Arrived', Duration=120,DurationType='Hours',ParentRecordId=wo.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2020-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2020-12-01 00:00:00.0000z'));
        insert sa1;
        sa1.Status='Enroute';
        update sa1;
        FFA_AddCost__c FFAAdditionalCosts=new FFA_AddCost__c(FAA_LabourCostType__c='Labour',FFA_MaterialQuantity__c=10,Work_Order__c=wo.id);
        insert FFAAdditionalCosts;
        
        Set<id> SerializeWorkorderIDS= new  Set<Id>();
        SerializeWorkorderIDS.add(wo.Id);
        string WorkOrderId = JSON.serialize(SerializeWorkorderIDS);
        
        
        string JsonBody = WorkOrderId;
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        FFA_WorkOrderCompleteInterface.CompletedWorkorders(WorkOrderId);
        Test.StopTest();
    }
    
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    private class RestMockfail implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(400);
            return res;
        }
    }
    @isTest static void ServiceApptSlotsTestMethod1(){
        workOrderServiceEngineerstatusUpdate.Header Headers=new workOrderServiceEngineerstatusUpdate.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        //WorkOrder
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='RAINBOW',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',
                                     FFA_OperationNumber__c='0010',
                                     Notification_Type__c='Y0',
                                     FFA_RequestedAppointmentTimeslot__c='S1',
                                     Status='New',
                                     FFA_JobCode__c='JC',FFA_RequestedAppointmentDate__c=system.now());
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(SchedStartTime=system.now(),SchedEndTime=system.now(),Status = 'Enroute',Enroute__c=system.now(),Onsite__c=system.now(), Duration=120,DurationType='Hours',ParentRecordId=wo.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        set<id> sets=new set<id>();
        sets.add(sa.id);
        FFAServiceAppointmentSlotsHandler.changeServiceApptTime(sets);
    }
    
    @isTest static void ServiceApptSlotsTestMethod2(){
        workOrderServiceEngineerstatusUpdate.Header Headers=new workOrderServiceEngineerstatusUpdate.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        //WorkOrder
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='PHOENIX',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',
                                     FFA_OperationNumber__c='0010',
                                     FFA_RequestedAppointmentTimeslot__c='S1',
                                     Status='New',
                                     FFA_JobCode__c='JC',FFA_RequestedAppointmentDate__c=system.now());
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(SchedStartTime=system.now(),SchedEndTime=system.now(),Status = 'Enroute',Enroute__c=system.now(),Onsite__c=system.now(), Duration=120,DurationType='Hours',ParentRecordId=wo.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        set<id> sets=new set<id>();
        sets.add(sa.id);
        FFAServiceAppointmentSlotsHandler.changeServiceApptTime(sets);
    }
    @isTest static void ServiceApptSlotsTestMethod3(){
        workOrderServiceEngineerstatusUpdate.Header Headers=new workOrderServiceEngineerstatusUpdate.Header();
        headers.TransactionType = 'N64';
        headers.SenderID ='';
        headers.ReceiverID ='';
        headers.InterfaceName ='SF-COMPLETION';
        headers.FileType ='';
        headers.CreationDate ='';
        headers.CreationTime ='';
        //WorkOrder
        FFA_Site__c site = new FFA_Site__c(Name='demo site',
                                           FFA_Title__c='Mr',
                                           FFA_Initials__c='I',
                                           FFA_Surname__c='S',
                                           FFA_ContactTelephoneNumber__c='D',
                                           FFA_BuildingName__c='building',
                                           FFA_SubBuildingName__c='Sub Building',
                                           FFA_BuildingNumber__c='121',
                                           FFA_DependentStreet__c='23',
                                           FFA_PrincipalStreet__c='23',
                                           FFA_DependentLocality__c='D',
                                           FFA_DoubleDependantLocality__c='D',
                                           FFA_PostTown__c='G',
                                           FFA_County__c='I',
                                           FFA_PostcodeOutcode__c='3455',
                                           FFA_PostcodeIncode__c='09877',
                                           FFA_GPSEasting__c='GPS',
                                           FFA_GPSNorthing__c='N',
                                           FFA_AccessInstructions__c='A',
                                           FFA_AccessRestrictions__c='A',
                                           FFA_PressureTier__c='P',
                                           FFA_DoesTheSiteContainAsbestos__c=true);
        insert site;
        
        Account acc = new Account(Name='NG__ACC__1');
        insert acc;
        
        axsy_forms__Form__c axsyfom = new axsy_forms__Form__c(Name='test form');
         insert axsyfom;
         
         WorkType WType=new WorkType(name='I1261B',EstimatedDuration=20,DurationType='Hours',Axsy_Form__c=axsyfom.Id);
         insert WType;
        
        WorkOrder wo = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
                                     FFA_PartialCompletion__c='l',
                                     FFA_ServiceProviderWorkReferenceNumber__c=1234.00,
                                     FFA_EngineerContactNumber__c='q',
                                     FFA_ContractorID__c='Q',
                                     FFA_Sender_ID__c='RAINBOW',
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',
                                     FFA_NewAppointmentDate__c=system.datetime.now(),
                                     FFA_JobReplanReasonText__c='R',
                                     FFA_JobReplanReasonCode__c='J',
                                     FFA_CompletedTerminatedCancelledText__c='T',
                                     FFA_StatusReasonCode__c='S',
                                     FFA_TerminatedCancelledReasonCode__c='TC',
                                     FFA_CompletionDateAndTime__c=system.datetime.now(),
                                     FFA_ArrivalTime__c=system.datetime.now(),
                                     FFA_ArrivalDate__c=system.datetime.now(),
                                     FFA_MeterPointReferenceNumber__c='MPRN',
                                     FFA_ShipperID__c='SP',
                                     FFA_SiteID__c='SI',
                                     FFA_ServiceNotificationNumber__c='4321',
                                     FFA_OperationNumber__c='0010',
                                     Notification_Type__c='Y3',
                                     FFA_RequestCreatedTime__c='10:28:10',
                                     Status='New',
                                     FFA_JobCode__c='JC',FFA_RequestedAppointmentDate__c=system.now());
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment(SchedStartTime=system.now(),SchedEndTime=system.now(),Status = 'Enroute',Enroute__c=system.now(),Onsite__c=system.now(), Duration=120,DurationType='Hours',ParentRecordId=wo.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23));
        insert sa;
        set<id> sets=new set<id>();
        sets.add(sa.id);
        FFAServiceAppointmentSlotsHandler.changeServiceApptTime(sets);
    }
}