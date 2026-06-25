@isTest
public class FFAAssetActivityHandlerTest {
    @isTest static void TestMethod1(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='543215',FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert MeterAssetsNew;
        NAssets.add(MeterAssetsNew);
        FFA_NGV_Asset__c MeterAssets = new FFA_NGV_Asset__c(FFA_Serial_Number__c='54321',FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert MeterAssets;
        Test.startTest();
        oldMap.put(MeterAssets.id,MeterAssets);
        Boolean updateEvent=True;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,null,true);
        //FFAAssetActivityHandler.doProcessActivityTypes(null,null,null);
        Test.stopTest();
    }
    @isTest static void TestMethod2(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert MeterAssetsNew;
        NAssets.add(MeterAssetsNew);
        FFA_NGV_Asset__c MeterAssets = new FFA_NGV_Asset__c(FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert MeterAssets;
        Test.startTest();
        oldMap.put(MeterAssets.id,MeterAssets);
        Boolean updateEvent=True;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,null,true);
        //FFAAssetActivityHandler.doProcessActivityTypes(null,null,null);
        Test.stopTest();
    }
    @isTest static void TestMethod3(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L',  FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019',Converter_Removed__c='True');
        insert MeterAssetsNew;
        NAssets.add(MeterAssetsNew);
        FFA_NGV_Asset__c MeterAssets = new FFA_NGV_Asset__c(FFA_Asset_Type__c='Meter',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L', Serial_Number_Fix__c='90890', FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert MeterAssets;
        Test.startTest();
        oldMap.put(MeterAssets.id,MeterAssets);
        Boolean updateEvent=True;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,oldMap,updateEvent);
        //FFAAssetActivityHandler.doProcessActivityTypes(null,null,null);
        Test.stopTest();
    }
    @isTest static void TestMethod4(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L',Serial_Number_Fix__c='',  FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019',Converter_Removed__c='True');
        insert MeterAssetsNew;
        
        NAssets.add(MeterAssetsNew);
         Test.startTest();
        Boolean updateEvent=True;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,null,updateEvent);
        //FFAAssetActivityHandler.doProcessActivityTypes(null,null,null);
        Test.stopTest();
    }

    @isTest static void TestMethod5(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='unknown',FFA_Model__c='unknown',
                                                       FFA_Year_of_Manufacturer__c='2019', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L',Serial_Number_Fix__c='',FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert MeterAssetsNew;
        MeterAssetsNew.FFA_Physical_Size__c='2';
        update MeterAssetsNew;
        NAssets.add(MeterAssetsNew);
       
        Test.startTest();
        oldMap.put(MeterAssetsNew.id,MeterAssetsNew);
        Boolean updateEvent=true;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,oldMap,true);
        Test.stopTest();
    }
    
    @isTest static void TestMethod6(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='',FFA_Model__c='',
                                                       FFA_Year_of_Manufacturer__c='', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L',Serial_Number_Fix__c='',FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019');
        insert MeterAssetsNew;
        MeterAssetsNew.FFA_Physical_Size__c='2';
        update MeterAssetsNew;
        NAssets.add(MeterAssetsNew);
       
        Test.startTest();
        oldMap.put(MeterAssetsNew.id,MeterAssetsNew);
        Boolean updateEvent=true;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,oldMap,true);
        Test.stopTest();
    }
    
    @isTest static void TestMethod7(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='',FFA_Model__c='',
                                                       FFA_Year_of_Manufacturer__c='', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L',Serial_Number_Fix__c='',FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='');
        insert MeterAssetsNew;
        
        list<FFA_NGV_Asset__c> updateAssetList = [select id , FFA_Physical_Size__c from FFA_NGV_Asset__c where id =: MeterAssetsNew.id];        
        updateAssetList[0].FFA_Physical_Size__c='2';
        update updateAssetList;
        //NAssets.add(MeterAssetsNew);
       
        Test.startTest();
        oldMap.put(MeterAssetsNew.id,MeterAssetsNew);
        Boolean updateEvent=true;
        FFAAssetActivityHandler.doProcessActivityTypes(updateAssetList,oldMap,true);
        Test.stopTest();
    }
    @isTest static void TestMethod8(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='',FFA_Connection_size__c='233',FFA_Asset_Status__c='Fix',FFA_Manufacturer__c='',FFA_Model__c='',
                                                       FFA_Year_of_Manufacturer__c='', FFA_Location_Notes_Fix__c='G',FFA_Installed_On_Stream__c='I',FFA_Meter_Type__c='L',FFA_Payment_Method__c='P',FFA_Meter_Link_Status__c='Prime',
                                                       FFA_Meter_Mechanism__c='M',FFA_Meter_Mechanism_Fix__c='F',FFA_Installed_On_Stream_Fix__c='F', FFA_Readable_Dials__c=12,FFA_Metric_or_Imperial_Indicator__c='I',FFA_Qmax__c=12,
                                                       FFA_Pressure_Read__c='P',FFA_Date_Installed__c=System.Date.today(), FFA_Activity_Type__c='R',FFA_Primary_Function__c='F',FFA_Physical_Size__c='S', FFA_Meter_Read__c='C',FFA_Connection_type__c='CT',
                                                       FFA_Location_Notes__c='LN', FFA_Location__c='L',Serial_Number_Fix__c='',FFA_Connection_size_Fix__c='CF',FFA_Connection_Type_Fix__c='CTF',FFA_Converted_Read_Fix__c='CRF', FFA_Date_Installed_Fix__c=System.Date.today(),
                                                       FFA_UnConvertedReadingFound__c='URF',FFA_ConvertedReadFound__c='C', FFA_Location_Fix__c='LF',FFA_Manufacturer_Fix__c='MF', FFA_Material_Type_Fix__c='MTF',  FFAMeterLinkStatusFix__c='Prime',
                                                       FFA_Material_Type__c='MT',FFA_Meter_Read_Fix__c='MRF',FFA_Meter_Type_Fix__c='MTF', FFA_Metric_Imperial_Indicator_Fix__c='MIF', FFA_Model_Fix__c='Model',FFA_Physical_Size_Fix__c='PY',
                                                       FFA_Pressure_Read_Fix__c='PR',FFA_Primary_Function_Fix__c='PF', FFA_Qmax_Fix__c=21, FFA_Readable_Dials_Fix__c=31, FFA_Unconverted_Read_Fix__c='URF', FFA_Year_of_Manufacturer_Fix__c='2019',FFA_Meter_Removed__c='Removed');
        insert MeterAssetsNew;
        MeterAssetsNew.FFA_Physical_Size__c='2';
        update MeterAssetsNew;
        NAssets.add(MeterAssetsNew);
       
        Test.startTest();
        oldMap.put(MeterAssetsNew.id,MeterAssetsNew);
        Boolean updateEvent=true;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,oldMap,true);
        Test.stopTest();
    }
    @isTest static void TestMethod9(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='',Serial_Number_Fix__c='AFIXED',FFA_Manufacturer__c='',FFA_Model__c='',FFA_Year_of_Manufacturer__c='',FFA_Asset_Type__c='Converter');
        insert MeterAssetsNew;
        
        NAssets.add(MeterAssetsNew);
       
        Test.startTest();
        oldMap.put(MeterAssetsNew.id,MeterAssetsNew);
        Boolean updateEvent=true;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,oldMap,false);
        Test.stopTest();
    }
    @isTest static void TestMethod10(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='Test',FFA_Model_Fix__c='Other',FFA_Asset_Type__c='Meter',FFA_IsMeterOnSite__c='No');
        insert MeterAssetsNew;
        MeterAssetsNew.FFA_Serial_Number__c='EXCHANGED';
        update MeterAssetsNew;
        NAssets.add(MeterAssetsNew);
       
        Test.startTest();
        oldMap.put(MeterAssetsNew.id,MeterAssetsNew);
        Boolean updateEvent=true;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,oldMap,true);
        Test.stopTest();
    }
    
    @isTest static void TestMethod11(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='Test',Serial_Number_Fix__c='Other',FFA_Asset_Type__c='Meter',FFA_IsMeterOnSite__c='No');
        insert MeterAssetsNew;
        MeterAssetsNew.FFA_Serial_Number__c='EXCHANGED';
        update MeterAssetsNew;
        NAssets.add(MeterAssetsNew);
       
        Test.startTest();
        oldMap.put(MeterAssetsNew.id,MeterAssetsNew);
        Boolean updateEvent=true;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,oldMap,true);
        Test.stopTest();
    }

@isTest static void TestMethod12(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='Test',FFA_Year_of_Manufacturer_Fix__c='Other',FFA_Asset_Type__c='Meter',FFA_IsMeterOnSite__c='No');
        insert MeterAssetsNew;
        MeterAssetsNew.FFA_Serial_Number__c='EXCHANGED';
        update MeterAssetsNew;
        NAssets.add(MeterAssetsNew);
       
        Test.startTest();
        oldMap.put(MeterAssetsNew.id,MeterAssetsNew);
        Boolean updateEvent=true;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,oldMap,true);
        Test.stopTest();
    }

@isTest static void TestMethod13(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='Test',FFA_Manufacturer_Fix__c='Other',FFA_Asset_Type__c='Meter',FFA_IsMeterOnSite__c='No');
        insert MeterAssetsNew;
        MeterAssetsNew.FFA_Serial_Number__c='EXCHANGED';
        update MeterAssetsNew;
        NAssets.add(MeterAssetsNew);
       
        Test.startTest();
        oldMap.put(MeterAssetsNew.id,MeterAssetsNew);
        Boolean updateEvent=true;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,oldMap,true);
        Test.stopTest();
    }

@isTest static void TestMethod14(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='Test',FFA_Asset_Status_Fix__c='Other',FFA_Asset_Type__c='Meter',FFA_IsMeterOnSite__c='No');
        insert MeterAssetsNew;
        MeterAssetsNew.FFA_Serial_Number__c='EXCHANGED';
        update MeterAssetsNew;
        NAssets.add(MeterAssetsNew);
       
        Test.startTest();
        oldMap.put(MeterAssetsNew.id,MeterAssetsNew);
        Boolean updateEvent=true;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,oldMap,true);
        Test.stopTest();
    }

@isTest static void TestMethod15(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='Test',FFA_Other_Manufacturer_Fix__c='Other',FFA_Asset_Type__c='Meter',FFA_IsMeterOnSite__c='No');
        insert MeterAssetsNew;
        MeterAssetsNew.FFA_Serial_Number__c='EXCHANGED';
        update MeterAssetsNew;
        NAssets.add(MeterAssetsNew);
       
        Test.startTest();
        oldMap.put(MeterAssetsNew.id,MeterAssetsNew);
        Boolean updateEvent=true;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,oldMap,true);
        Test.stopTest();
    }

@isTest static void TestMethod16(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Serial_Number__c='Test',FFA_Other_Model_Fix__c='Other',FFA_Asset_Type__c='Meter',FFA_IsMeterOnSite__c='No');
        insert MeterAssetsNew;
        MeterAssetsNew.FFA_Serial_Number__c='EXCHANGED';
        update MeterAssetsNew;
        NAssets.add(MeterAssetsNew);
       
        Test.startTest();
        oldMap.put(MeterAssetsNew.id,MeterAssetsNew);
        Boolean updateEvent=true;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,oldMap,true);
        Test.stopTest();
    }
    
    
    
    @isTest static void TestMethod18(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Meter_Removed__c='Other');
        insert MeterAssetsNew;
        
        NAssets.add(MeterAssetsNew);
         Test.startTest();
        Boolean updateEvent=True;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,null,updateEvent);
        //FFAAssetActivityHandler.doProcessActivityTypes(null,null,null);
        Test.stopTest();
    }
    
    @isTest static void TestMethod19(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Other_Manufacturer__c='Other');
        insert MeterAssetsNew;
        MeterAssetsNew.FFA_Physical_Size__c='2';
        update MeterAssetsNew;
        NAssets.add(MeterAssetsNew);
       
        Test.startTest();
        oldMap.put(MeterAssetsNew.id,MeterAssetsNew);
        Boolean updateEvent=true;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,oldMap,true);
        Test.stopTest();
    }
    
    @isTest static void TestMethod20(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c(FFA_Other_Model__c='Other');
        insert MeterAssetsNew;
        MeterAssetsNew.FFA_Physical_Size__c='2';
        update MeterAssetsNew;
        NAssets.add(MeterAssetsNew);
       
        Test.startTest();
        oldMap.put(MeterAssetsNew.id,MeterAssetsNew);
        Boolean updateEvent=true;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,oldMap,true);
        Test.stopTest();
    }
    
    @isTest static void TestMethod21(){
        Map<id,FFA_NGV_Asset__c> newMap = new Map<id,FFA_NGV_Asset__c>();
        Map<id,FFA_NGV_Asset__c> oldMap = new Map<id,FFA_NGV_Asset__c>();
        list<FFA_NGV_Asset__c>NAssets=new list<FFA_NGV_Asset__c>();
        FFA_NGV_Asset__c MeterAssetsNew = new FFA_NGV_Asset__c();
        insert MeterAssetsNew;
        
       
        Test.startTest();
        oldMap.put(MeterAssetsNew.id,MeterAssetsNew);
        Boolean updateEvent=true;
        FFAAssetActivityHandler.doProcessActivityTypes(NAssets,oldMap,true);
        Test.stopTest();
    }
    
    @isTest(SeeAllData = true) static void TestMethod22(){
        
        list<FFA_NGV_Asset__c> queryAsset = [select Id , Work_Order__c, FFA_Serial_Number__c from  FFA_NGV_Asset__c where Work_Order__c != null limit 1];
        if(queryAsset.size() > 0){
            queryAsset[0].FFA_Serial_Number__c = 'xyz';
            update queryAsset;
        }
    }
}