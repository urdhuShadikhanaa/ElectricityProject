@isTest
public class FFAAssetActivityFromWOrkorderHandlerTest {
    @isTest static void TestMethod1(){
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        Set<Id> WorkOrderIdsSet = new Set<Id>();
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
                                     FFA_Sender_ID__c='PHONEIX',
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
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='543215',FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',FFA_Other_Manufacturer__c='Unknown',FFA_Other_Manufacturer_fix__c='Manu Other',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',FFA_Other_Model__c='Unknown',FFA_Other_Model_fix__c='Other Model',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019',Work_Order__c=wo.Id);
        insert MeterAssetsNew;
        MeterAssetsNew.FFA_Serial_Number__c='34567';
        update MeterAssetsNew;
        FFA_NGV_Asset__c MeterAssetsNew1 = new FFA_NGV_Asset__c(FFA_Serial_Number__c='5432135',FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c=null, FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',FFA_Other_Manufacturer__c='Unknown',FFA_Other_Manufacturer_fix__c='Manu Other',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',FFA_Other_Model__c='Unknown',FFA_Other_Model_fix__c='Other Model',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019',Work_Order__c=wo.Id);
        insert MeterAssetsNew1;
        FFA_NGV_Asset__c MeterAssetsNew2 = new FFA_NGV_Asset__c(FFA_Serial_Number__c='5432135',FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c=null, FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c=null, FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',FFA_Other_Manufacturer__c='Unknown',FFA_Other_Manufacturer_fix__c='Manu Other',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',FFA_Other_Model__c='Unknown',FFA_Other_Model_fix__c='Other Model',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019',Work_Order__c=wo.Id);
        insert MeterAssetsNew2;
        FFA_NGV_Asset__c MeterAssetsNew3 = new FFA_NGV_Asset__c(FFA_Serial_Number__c='5432135',FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c=null, FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c=null, FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',FFA_Other_Manufacturer__c='Unknown',FFA_Other_Manufacturer_fix__c='Manu Other',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',FFA_Other_Model__c='Unknown',FFA_Other_Model_fix__c='Other Model',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c=null,Work_Order__c=wo.Id);
        insert MeterAssetsNew3;
        FFA_NGV_Asset__c MeterAssetsNew4 = new FFA_NGV_Asset__c(FFA_Serial_Number__c='5432135',FFA_Asset_Type__c='Slamshut',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',FFA_IsMeterOnSite__c='No',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,FFA_IsRegulatorOnSite__c='No',
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c=null, FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c=null, FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',FFA_Other_Manufacturer__c='Unknown',FFA_Other_Manufacturer_fix__c='Manu Other',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c=null,FFA_Physical_Size_Fix__c='PY',FFA_Other_Model__c='Unknown',FFA_Other_Model_fix__c='Other Model',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c=null,Work_Order__c=wo.Id);
        insert MeterAssetsNew4;
        FFA_NGV_Asset__c MeterAssetsNew5 = new FFA_NGV_Asset__c(FFA_Serial_Number__c='5432135',FFA_Asset_Type__c='Regulator',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c=null, FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c=null, FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',FFA_Other_Manufacturer__c='Unknown',FFA_Other_Manufacturer_fix__c='Manu Other',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c=null,FFA_Physical_Size_Fix__c='PY',FFA_Other_Model__c='Unknown',FFA_Other_Model_fix__c=null,
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c=null,Work_Order__c=wo.Id);
        insert MeterAssetsNew5;
        
        wo.Form_Response_Completed__c = true;
        update wo;
        
        Test.startTest();
        WorkOrderIdsSet.add(wo.Id);
        FFAAssetActivityFromWOrkorderHandler.astActivitiesbeforeFormResponse(WorkOrderIdsSet);
        Test.stopTest();
    }
    
    @isTest static void TestMethod2(){
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        Set<Id> WorkOrderIdsSet = new Set<Id>();
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
                                     FFA_Sender_ID__c='PHONEIX',
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
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c=null,Serial_Number_Fix__c='5432135',FFA_Manufacturer__c=null,FFA_Manufacturer_Fix__c='null',
                                                                FFA_Model__c=null,FFA_Model_Fix__c='null',FFA_Other_Model__c=null,FFA_Other_Model_fix__c='Other Model',FFA_Activity_Type__c='R',
                                                                FFA_Other_Manufacturer__c=null,FFA_Other_Manufacturer_fix__c='Manu Other',FFA_IsMeterOnSite__c=null,FFA_IsRegulatorOnSite__c=null,
                                                                FFA_Year_of_Manufacturer_Fix__c='2019',FFA_Year_of_Manufacturer__c=null,Work_Order__c=wo.Id,FFA_Asset_Type__c='Meter');
        insert MeterAssetsNew;
        FFA_NGV_Asset__c MeterAssetsNew1 = new FFA_NGV_Asset__c(FFA_Activity_Type__c='R',
                                                                FFA_Other_Asset_Activity__c='Remove Asset',
                                                                FFA_IsMeterOnSite__c=null,FFA_IsRegulatorOnSite__c=null,
                                                                Work_Order__c=wo.Id,FFA_Asset_Type__c='Meter');
        insert MeterAssetsNew1;
        
        Test.startTest();
        WorkOrderIdsSet.add(wo.Id);
        FFAAssetActivityFromWOrkorderHandler.astActivitiesbeforeFormResponse(WorkOrderIdsSet);
        Test.stopTest();
    }
    
    @isTest(Seealldata=True) static void TestMethod3(){
        
        Set<Id> WorkOrderIdsSet = new Set<Id>();
        /*FFA_Site__c site = new FFA_Site__c(Name='demo site',
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
                                     FFA_Sender_ID__c='PHONEIX',
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
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='5432135',Work_Order__c=wo.Id);
        insert MeterAssetsNew;
        
        
        MeterAssetsNew.FFA_Serial_Number__c='6543222222';
        
        update MeterAssetsNew;
        */
        List<FFA_NGV_Asset__c> Ast=[Select id,Work_Order__c,FFA_Activity_Type__c From FFA_NGV_Asset__c WHERE FFA_Activity_Type__c='A' limit 20];
        For(FFA_NGV_Asset__c Asst: Ast){
            if(Asst.Work_Order__c!=null){
           WorkOrderIdsSet.add(Asst.Work_Order__c);
           }
        }
        Test.startTest();
        //WorkOrderIdsSet.add(wo.Id);
        FFAAssetActivityFromWOrkorderHandler.astActivitiesbeforeFormResponse(WorkOrderIdsSet);
        Test.stopTest();
    }
    @isTest static void TestMethod4(){
        
    }

}