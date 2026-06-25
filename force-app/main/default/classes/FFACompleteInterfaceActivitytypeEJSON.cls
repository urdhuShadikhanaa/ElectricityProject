Public class FFACompleteInterfaceActivitytypeEJSON{

    public static string returnValvesJSON(string AssetID){
            string JSON;
            CompleteInterfaceMappping__mdt[] configObjTypes = [Select MasterLabel,FFAFieldName__c,AssetCondition__c,SAPFieldName__c,RecordType__c from CompleteInterfaceMappping__mdt WHERE RecordType__c='Valve'];
            FFA_NGV_Asset__c AssetMAP = [SELECT id,FFA_Serial_Number__c,FFA_Asset_Type__c,FFA_Connection_size__c,FFA_Asset_Status__c,FFA_Manufacturer__c,
                                     FFA_Model__c,FFA_ThirdPartyMeter__c,FFA_Year_of_Manufacturer__c,FFA_Location_Notes_Fix__c,FFA_Installed_On_Stream__c,FFA_Meter_Type__c,FFA_Payment_Method__c,
                                     FFA_Meter_Link_Status__c,FFA_Meter_Mechanism__c,FFA_Meter_Mechanism_Fix__c,FFA_Installed_On_Stream_Fix__c,FFA_Readable_Dials__c,FFA_Metric_or_Imperial_Indicator__c,FFA_Qmax__c,FFA_Pressure_Read__c,
                                     FFA_Date_Installed__c,FFA_Activity_Type__c,FFA_Primary_Function__c,FFA_Physical_Size__c,FFA_Meter_Read__c,FFA_Connection_type__c,
                                     FFA_Location_Notes__c,FFA_Location__c,Serial_Number_Fix__c,FFA_Connection_size_Fix__c,FFA_Connection_Type_Fix__c,FFA_Converted_Read_Fix__c,
                                     FFA_Date_Installed_Fix__c,FFA_Location_Fix__c,FFA_Manufacturer_Fix__c,FFA_Material_Type_Fix__c,    
                                     FFAMeterLinkStatusFix__c,FFA_Material_Type__c,FFA_Meter_Read_Fix__c,FFA_Meter_Type_Fix__c,FFA_Metric_Imperial_Indicator_Fix__c,
                                     FFA_Model_Fix__c,FFA_Physical_Size_Fix__c,FFA_Pressure_Read_Fix__c,FFA_Primary_Function_Fix__c,FFA_Qmax_Fix__c,
                                     FFA_Readable_Dials_Fix__c,FFA_Unconverted_Read_Fix__c,FFA_Year_of_Manufacturer_Fix__c,FFA_UnConvertedReadingFound__c,FFA_ConvertedReadFound__c,FFA_Unconverted_readings_as_left_Fix__c,FFA_Converted_Reading_As_Left_Fix__c,
                                     FFA_Gauge_Pressure_Fix__c,FFA_Atmospheric_pressure_mBar_Fix__c,FFA_Absolute_Pres_Convertor_Reading_Fix__c,FFA_Temperature_Convertor_Reading_Fix__c,FFA_Atmospheric_Pressure__c,FFA_Conversion_Factor_Fix__c,
                                     FFA_Converter_status_code__c,FFA_Asset_Status_Fix__c,FFA_NoOfDials__c,FFA_UnconvertedLeft__c,FFA_ConvertedLeft__c,FFA_GaugePressure__c,FFA_TI_Absolute_Pressure__c,FFA_TI_Temperature_Reading__c,FFA_Conversion_Factor__c,
                                     FFA_Other_Manufacturer_fix__c,FFA_Other_Manufacturer__c,FFA_Other_Model__c,FFA_Other_Model_fix__c,
                                     FFA_Converter_Status_Code_Fix__c from FFA_NGV_Asset__c WHERE ID=:AssetID limit 1];
                                        
            Map<String, Object> fieldsAPINameToValue = AssetMAP.getPopulatedFieldsAsMap();
            String currentJSON;
            String fixJSON;
            //system.debug('fieldsAPINameToValue--->'+fieldsAPINameToValue.get('FFA_Other_Manufacturer__c')+AssetMAP.FFA_Other_Manufacturer__c);
            
            for(CompleteInterfaceMappping__mdt cust:configObjTypes){
                if(cust.AssetCondition__c=='Current'){
                      if(cust.FFAFieldName__c=='FFA_Other_Manufacturer__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer__c')!=null){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          currentJSON=innerJSON;
                          
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Manufacturer__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer__c')==null ){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Manufacturer__c+'",';
                          currentJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model__c' && fieldsAPINameToValue.get('FFA_Other_Model__c')!=null ){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          currentJSON=innerJSON;
                         
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model__c' && (fieldsAPINameToValue.get('FFA_Other_Model__c')==null || AssetMAP.FFA_Other_Model__c=='')){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Model__c+'",';
                          currentJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed__c' && fieldsAPINameToValue.get('FFA_Date_Installed__c')!=null ){
                          string dateInstalled=FFA_WorkOrderCompleteInterface.convertDateFormattoSAP(AssetMAP.FFA_Date_Installed__c);
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+dateInstalled+'",';
                          currentJSON=innerJSON;
                          
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed__c' && fieldsAPINameToValue.get('FFA_Date_Installed__c')==null ){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"",';
                          currentJSON=innerJSON;
                      }
                      else{
                      string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                      currentJSON=innerJSON;
                      }
                }
                
                        
                    
                
                if(cust.AssetCondition__c=='Fix'){
                   if(cust.FFAFieldName__c=='FFA_Other_Manufacturer_fix__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer_fix__c')!=null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          fixJSON=innerJSON;
                          
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Manufacturer_fix__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer_fix__c')==null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Manufacturer_Fix__c+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model_fix__c' && fieldsAPINameToValue.get('FFA_Other_Model_fix__c')!=null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model_fix__c' && fieldsAPINameToValue.get('FFA_Other_Model_fix__c')==null){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Model_Fix__c+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed_Fix__c' && fieldsAPINameToValue.get('FFA_Date_Installed_Fix__c')!=null ){
                          string dateInstalled=FFA_WorkOrderCompleteInterface.convertDateFormattoSAP(AssetMAP.FFA_Date_Installed_Fix__c);
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+dateInstalled+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed_Fix__c' && fieldsAPINameToValue.get('FFA_Date_Installed_Fix__c')==null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"",';
                          fixJSON=innerJSON;
                      }
                      else{
                       string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                       fixJSON=innerJSON;
                   }
                }
            }   
             
            currentJSON = currentJSON.replace('"null"', '""');
            currentJSON = currentJSON.replace('null', '');
            currentJSON = currentJSON.substring(0,currentJSON.length()-1);
            fixJSON = fixJSON.replace('"null"', '""');
            fixJSON = fixJSON.replace('null', '');
            fixJSON = fixJSON.substring(0,fixJSON.length()-1);
            system.debug('currentJSON--'+currentJSON);
            system.debug('fixJSON--'+fixJSON);
            JSON='"Current":{'+currentJSON+'},'+'"Fix":{'+fixJSON+'}';
            return JSON;
        }
        public static string returnSlamShutJSON(string AssetID){
            string JSON;
            CompleteInterfaceMappping__mdt[] configObjTypes = [Select MasterLabel,FFAFieldName__c,AssetCondition__c,SAPFieldName__c,RecordType__c from CompleteInterfaceMappping__mdt WHERE RecordType__c='SlamShut'];
            FFA_NGV_Asset__c AssetMAP = [SELECT id,FFA_Serial_Number__c,FFA_Asset_Type__c,FFA_Connection_size__c,FFA_Asset_Status__c,FFA_Manufacturer__c,
                                     FFA_Model__c,FFA_ThirdPartyMeter__c,FFA_Year_of_Manufacturer__c,FFA_Location_Notes_Fix__c,FFA_Installed_On_Stream__c,FFA_Meter_Type__c,FFA_Payment_Method__c,
                                     FFA_Meter_Link_Status__c,FFA_Meter_Mechanism__c,FFA_Meter_Mechanism_Fix__c,FFA_Installed_On_Stream_Fix__c,FFA_Readable_Dials__c,FFA_Metric_or_Imperial_Indicator__c,FFA_Qmax__c,FFA_Pressure_Read__c,
                                     FFA_Date_Installed__c,FFA_Activity_Type__c,FFA_Primary_Function__c,FFA_Physical_Size__c,FFA_Meter_Read__c,FFA_Connection_type__c,
                                     FFA_Location_Notes__c,FFA_Location__c,Serial_Number_Fix__c,FFA_Connection_size_Fix__c,FFA_Connection_Type_Fix__c,FFA_Converted_Read_Fix__c,
                                     FFA_Date_Installed_Fix__c,FFA_Location_Fix__c,FFA_Manufacturer_Fix__c,FFA_Material_Type_Fix__c,    
                                     FFAMeterLinkStatusFix__c,FFA_Material_Type__c,FFA_Meter_Read_Fix__c,FFA_Meter_Type_Fix__c,FFA_Metric_Imperial_Indicator_Fix__c,
                                     FFA_Model_Fix__c,FFA_Physical_Size_Fix__c,FFA_Pressure_Read_Fix__c,FFA_Primary_Function_Fix__c,FFA_Qmax_Fix__c,
                                     FFA_Readable_Dials_Fix__c,FFA_Unconverted_Read_Fix__c,FFA_Year_of_Manufacturer_Fix__c,FFA_UnConvertedReadingFound__c,FFA_ConvertedReadFound__c,FFA_Unconverted_readings_as_left_Fix__c,FFA_Converted_Reading_As_Left_Fix__c,
                                     FFA_Gauge_Pressure_Fix__c,FFA_Atmospheric_pressure_mBar_Fix__c,FFA_Absolute_Pres_Convertor_Reading_Fix__c,FFA_Temperature_Convertor_Reading_Fix__c,FFA_Atmospheric_Pressure__c,FFA_Conversion_Factor_Fix__c,
                                     FFA_Converter_status_code__c,FFA_Asset_Status_Fix__c,FFA_NoOfDials__c,FFA_UnconvertedLeft__c,FFA_ConvertedLeft__c,FFA_GaugePressure__c,FFA_TI_Absolute_Pressure__c,FFA_TI_Temperature_Reading__c,FFA_Conversion_Factor__c,
                                     FFA_Other_Manufacturer_fix__c,FFA_Other_Manufacturer__c,FFA_Other_Model__c,FFA_Other_Model_fix__c,
                                     FFA_Converter_Status_Code_Fix__c from FFA_NGV_Asset__c WHERE ID=:AssetID limit 1];
            
            Map<String, Object> fieldsAPINameToValue = AssetMAP.getPopulatedFieldsAsMap();
            String currentJSON;
            String fixJSON;
            for(CompleteInterfaceMappping__mdt cust:configObjTypes){
                if(cust.AssetCondition__c=='Current'){
                if(cust.FFAFieldName__c=='FFA_Other_Manufacturer__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer__c')!=null){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          currentJSON=innerJSON;
                          
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Manufacturer__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer__c')==null ){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Manufacturer__c+'",';
                          currentJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model__c' && fieldsAPINameToValue.get('FFA_Other_Model__c')!=null ){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          currentJSON=innerJSON;
                         
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model__c' && (fieldsAPINameToValue.get('FFA_Other_Model__c')==null || AssetMAP.FFA_Other_Model__c=='')){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Model__c+'",';
                          currentJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed__c' && fieldsAPINameToValue.get('FFA_Date_Installed__c')!=null ){
                          string dateInstalled=FFA_WorkOrderCompleteInterface.convertDateFormattoSAP(AssetMAP.FFA_Date_Installed__c);
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+dateInstalled+'",';
                          currentJSON=innerJSON;
                          
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed__c' && fieldsAPINameToValue.get('FFA_Date_Installed__c')==null ){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"",';
                          currentJSON=innerJSON;
                      }
                      else{
                      string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                      currentJSON=innerJSON;
                      }
                }
                
                        
                    
                
                if(cust.AssetCondition__c=='Fix'){
                   if(cust.FFAFieldName__c=='FFA_Other_Manufacturer_fix__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer_fix__c')!=null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          fixJSON=innerJSON;
                          
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Manufacturer_fix__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer_fix__c')==null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Manufacturer_Fix__c+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model_fix__c' && fieldsAPINameToValue.get('FFA_Other_Model_fix__c')!=null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model_fix__c' && fieldsAPINameToValue.get('FFA_Other_Model_fix__c')==null){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Model_Fix__c+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed_Fix__c' && fieldsAPINameToValue.get('FFA_Date_Installed_Fix__c')!=null ){
                          string dateInstalled=FFA_WorkOrderCompleteInterface.convertDateFormattoSAP(AssetMAP.FFA_Date_Installed_Fix__c);
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+dateInstalled+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed_Fix__c' && fieldsAPINameToValue.get('FFA_Date_Installed_Fix__c')==null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"",';
                          fixJSON=innerJSON;
                      }
                      else{
                       string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                       fixJSON=innerJSON;
                   }
                }
            }   
             
            currentJSON = currentJSON.replace('"null"', '""');
            currentJSON = currentJSON.replace('null', '');
            currentJSON = currentJSON.substring(0,currentJSON.length()-1);
            fixJSON = fixJSON.replace('"null"', '""');
            fixJSON = fixJSON.replace('null', '');
            fixJSON = fixJSON.substring(0,fixJSON.length()-1);
            system.debug('currentJSON--'+currentJSON);
            system.debug('fixJSON--'+fixJSON);
            JSON='"Current":{'+currentJSON+'},'+'"Fix":{'+fixJSON+'}';
            return JSON;
         } 
         
         //Boiler
         public static string returnBoilersJSON(string AssetID){
            string JSON;
            CompleteInterfaceMappping__mdt[] configObjTypes = [Select MasterLabel,FFAFieldName__c,AssetCondition__c,SAPFieldName__c,RecordType__c from CompleteInterfaceMappping__mdt WHERE RecordType__c='Boiler'];
            FFA_NGV_Asset__c AssetMAP = [SELECT id,FFA_Serial_Number__c,FFA_Asset_Type__c,FFA_Connection_size__c,FFA_Asset_Status__c,FFA_Manufacturer__c,
                                     FFA_Model__c,FFA_ThirdPartyMeter__c,FFA_Year_of_Manufacturer__c,FFA_Location_Notes_Fix__c,FFA_Installed_On_Stream__c,FFA_Meter_Type__c,FFA_Payment_Method__c,
                                     FFA_Meter_Link_Status__c,FFA_Meter_Mechanism__c,FFA_Meter_Mechanism_Fix__c,FFA_Installed_On_Stream_Fix__c,FFA_Readable_Dials__c,FFA_Metric_or_Imperial_Indicator__c,FFA_Qmax__c,FFA_Pressure_Read__c,
                                     FFA_Date_Installed__c,FFA_Activity_Type__c,FFA_Primary_Function__c,FFA_Physical_Size__c,FFA_Meter_Read__c,FFA_Connection_type__c,
                                     FFA_Location_Notes__c,FFA_Location__c,Serial_Number_Fix__c,FFA_Connection_size_Fix__c,FFA_Connection_Type_Fix__c,FFA_Converted_Read_Fix__c,
                                     FFA_Date_Installed_Fix__c,FFA_Location_Fix__c,FFA_Manufacturer_Fix__c,FFA_Material_Type_Fix__c,    
                                     FFAMeterLinkStatusFix__c,FFA_Material_Type__c,FFA_Meter_Read_Fix__c,FFA_Meter_Type_Fix__c,FFA_Metric_Imperial_Indicator_Fix__c,
                                     FFA_Model_Fix__c,FFA_Physical_Size_Fix__c,FFA_Pressure_Read_Fix__c,FFA_Primary_Function_Fix__c,FFA_Qmax_Fix__c,
                                     FFA_Readable_Dials_Fix__c,FFA_Unconverted_Read_Fix__c,FFA_Year_of_Manufacturer_Fix__c,FFA_UnConvertedReadingFound__c,FFA_ConvertedReadFound__c,FFA_Unconverted_readings_as_left_Fix__c,FFA_Converted_Reading_As_Left_Fix__c,
                                     FFA_Gauge_Pressure_Fix__c,FFA_Atmospheric_pressure_mBar_Fix__c,FFA_Absolute_Pres_Convertor_Reading_Fix__c,FFA_Temperature_Convertor_Reading_Fix__c,FFA_Atmospheric_Pressure__c,FFA_Conversion_Factor_Fix__c,
                                     FFA_Converter_status_code__c,FFA_Asset_Status_Fix__c,FFA_NoOfDials__c,FFA_UnconvertedLeft__c,FFA_ConvertedLeft__c,FFA_GaugePressure__c,FFA_TI_Absolute_Pressure__c,FFA_TI_Temperature_Reading__c,FFA_Conversion_Factor__c,
                                     FFA_Other_Manufacturer_fix__c,FFA_Other_Manufacturer__c,FFA_Other_Model__c,FFA_Other_Model_fix__c,
                                     FFA_Converter_Status_Code_Fix__c from FFA_NGV_Asset__c WHERE ID=:AssetID limit 1];
            
            Map<String, Object> fieldsAPINameToValue = AssetMAP.getPopulatedFieldsAsMap();
            String currentJSON;
            String fixJSON;
            for(CompleteInterfaceMappping__mdt cust:configObjTypes){
                if(cust.AssetCondition__c=='Current'){
                     if(cust.FFAFieldName__c=='FFA_Other_Manufacturer__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer__c')!=null){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          currentJSON=innerJSON;
                          
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Manufacturer__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer__c')==null ){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Manufacturer__c+'",';
                          currentJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model__c' && fieldsAPINameToValue.get('FFA_Other_Model__c')!=null ){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          currentJSON=innerJSON;
                         
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model__c' && (fieldsAPINameToValue.get('FFA_Other_Model__c')==null || AssetMAP.FFA_Other_Model__c=='')){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Model__c+'",';
                          currentJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed__c' && fieldsAPINameToValue.get('FFA_Date_Installed__c')!=null ){
                          string dateInstalled=FFA_WorkOrderCompleteInterface.convertDateFormattoSAP(AssetMAP.FFA_Date_Installed__c);
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+dateInstalled+'",';
                          currentJSON=innerJSON;
                          
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed__c' && fieldsAPINameToValue.get('FFA_Date_Installed__c')==null ){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"",';
                          currentJSON=innerJSON;
                      }
                      else{
                      string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                      currentJSON=innerJSON;
                      }
                }
                
                        
                    
                
                if(cust.AssetCondition__c=='Fix'){
                   if(cust.FFAFieldName__c=='FFA_Other_Manufacturer_fix__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer_fix__c')!=null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          fixJSON=innerJSON;
                          
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Manufacturer_fix__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer_fix__c')==null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Manufacturer_Fix__c+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model_fix__c' && fieldsAPINameToValue.get('FFA_Other_Model_fix__c')!=null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model_fix__c' && fieldsAPINameToValue.get('FFA_Other_Model_fix__c')==null){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Model_Fix__c+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed_Fix__c' && fieldsAPINameToValue.get('FFA_Date_Installed_Fix__c')!=null ){
                          string dateInstalled=FFA_WorkOrderCompleteInterface.convertDateFormattoSAP(AssetMAP.FFA_Date_Installed_Fix__c);
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+dateInstalled+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed_Fix__c' && fieldsAPINameToValue.get('FFA_Date_Installed_Fix__c')==null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"",';
                          fixJSON=innerJSON;
                      }
                      else{
                       string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                       fixJSON=innerJSON;
                   }
                }
            }   
             
            currentJSON = currentJSON.replace('"null"', '""');
            currentJSON = currentJSON.replace('null', '');
            currentJSON = currentJSON.substring(0,currentJSON.length()-1);
            fixJSON = fixJSON.replace('"null"', '""');
            fixJSON = fixJSON.replace('null', '');
            fixJSON = fixJSON.substring(0,fixJSON.length()-1);
            system.debug('currentJSON--'+currentJSON);
            system.debug('fixJSON--'+fixJSON);
            JSON='"Current":{'+currentJSON+'},'+'"Fix":{'+fixJSON+'}';
            return JSON;
         } 
         
          public static string returnFiltersJSON(string AssetID){
            string JSON;
            CompleteInterfaceMappping__mdt[] configObjTypes = [Select MasterLabel,FFAFieldName__c,AssetCondition__c,SAPFieldName__c,RecordType__c from CompleteInterfaceMappping__mdt WHERE RecordType__c='Filter'];
            FFA_NGV_Asset__c AssetMAP = [SELECT id,FFA_Serial_Number__c,FFA_Asset_Type__c,FFA_Connection_size__c,FFA_Asset_Status__c,FFA_Manufacturer__c,
                                     FFA_Model__c,FFA_ThirdPartyMeter__c,FFA_Year_of_Manufacturer__c,FFA_Location_Notes_Fix__c,FFA_Installed_On_Stream__c,FFA_Meter_Type__c,FFA_Payment_Method__c,
                                     FFA_Meter_Link_Status__c,FFA_Meter_Mechanism__c,FFA_Meter_Mechanism_Fix__c,FFA_Installed_On_Stream_Fix__c,FFA_Readable_Dials__c,FFA_Metric_or_Imperial_Indicator__c,FFA_Qmax__c,FFA_Pressure_Read__c,
                                     FFA_Date_Installed__c,FFA_Activity_Type__c,FFA_Primary_Function__c,FFA_Physical_Size__c,FFA_Meter_Read__c,FFA_Connection_type__c,
                                     FFA_Location_Notes__c,FFA_Location__c,Serial_Number_Fix__c,FFA_Connection_size_Fix__c,FFA_Connection_Type_Fix__c,FFA_Converted_Read_Fix__c,
                                     FFA_Date_Installed_Fix__c,FFA_Location_Fix__c,FFA_Manufacturer_Fix__c,FFA_Material_Type_Fix__c,    
                                     FFAMeterLinkStatusFix__c,FFA_Material_Type__c,FFA_Meter_Read_Fix__c,FFA_Meter_Type_Fix__c,FFA_Metric_Imperial_Indicator_Fix__c,
                                     FFA_Model_Fix__c,FFA_Physical_Size_Fix__c,FFA_Pressure_Read_Fix__c,FFA_Primary_Function_Fix__c,FFA_Qmax_Fix__c,
                                     FFA_Readable_Dials_Fix__c,FFA_Unconverted_Read_Fix__c,FFA_Year_of_Manufacturer_Fix__c,FFA_UnConvertedReadingFound__c,FFA_ConvertedReadFound__c,FFA_Unconverted_readings_as_left_Fix__c,FFA_Converted_Reading_As_Left_Fix__c,
                                     FFA_Gauge_Pressure_Fix__c,FFA_Atmospheric_pressure_mBar_Fix__c,FFA_Absolute_Pres_Convertor_Reading_Fix__c,FFA_Temperature_Convertor_Reading_Fix__c,FFA_Atmospheric_Pressure__c,FFA_Conversion_Factor_Fix__c,
                                     FFA_Converter_status_code__c,FFA_Asset_Status_Fix__c,FFA_NoOfDials__c,FFA_UnconvertedLeft__c,FFA_ConvertedLeft__c,FFA_GaugePressure__c,FFA_TI_Absolute_Pressure__c,FFA_TI_Temperature_Reading__c,FFA_Conversion_Factor__c,
                                     FFA_Other_Manufacturer_fix__c,FFA_Other_Manufacturer__c,FFA_Other_Model__c,FFA_Other_Model_fix__c,
                                     FFA_Converter_Status_Code_Fix__c from FFA_NGV_Asset__c WHERE ID=:AssetID limit 1];
            
            Map<String, Object> fieldsAPINameToValue = AssetMAP.getPopulatedFieldsAsMap();
            String currentJSON;
            String fixJSON;
            for(CompleteInterfaceMappping__mdt cust:configObjTypes){
                if(cust.AssetCondition__c=='Current'){
                     if(cust.FFAFieldName__c=='FFA_Other_Manufacturer__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer__c')!=null){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          currentJSON=innerJSON;
                          
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Manufacturer__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer__c')==null ){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Manufacturer__c+'",';
                          currentJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model__c' && fieldsAPINameToValue.get('FFA_Other_Model__c')!=null ){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          currentJSON=innerJSON;
                         
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model__c' && (fieldsAPINameToValue.get('FFA_Other_Model__c')==null || AssetMAP.FFA_Other_Model__c=='')){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Model__c+'",';
                          currentJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed__c' && fieldsAPINameToValue.get('FFA_Date_Installed__c')!=null ){
                          string dateInstalled=FFA_WorkOrderCompleteInterface.convertDateFormattoSAP(AssetMAP.FFA_Date_Installed__c);
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+dateInstalled+'",';
                          currentJSON=innerJSON;
                          
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed__c' && fieldsAPINameToValue.get('FFA_Date_Installed__c')==null ){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"",';
                          currentJSON=innerJSON;
                      }
                      else{
                      string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                      currentJSON=innerJSON;
                      }
                }
                
                        
                    
                
                if(cust.AssetCondition__c=='Fix'){
                   if(cust.FFAFieldName__c=='FFA_Other_Manufacturer_fix__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer_fix__c')!=null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          fixJSON=innerJSON;
                          
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Manufacturer_fix__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer_fix__c')==null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Manufacturer_Fix__c+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model_fix__c' && fieldsAPINameToValue.get('FFA_Other_Model_fix__c')!=null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model_fix__c' && fieldsAPINameToValue.get('FFA_Other_Model_fix__c')==null){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Model_Fix__c+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed_Fix__c' && fieldsAPINameToValue.get('FFA_Date_Installed_Fix__c')!=null ){
                          string dateInstalled=FFA_WorkOrderCompleteInterface.convertDateFormattoSAP(AssetMAP.FFA_Date_Installed_Fix__c);
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+dateInstalled+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed_Fix__c' && fieldsAPINameToValue.get('FFA_Date_Installed_Fix__c')==null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"",';
                          fixJSON=innerJSON;
                      }
                      else{
                       string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                       fixJSON=innerJSON;
                   }
                }
            }   
             
            currentJSON = currentJSON.replace('"null"', '""');
            currentJSON = currentJSON.replace('null', '');
            currentJSON = currentJSON.substring(0,currentJSON.length()-1);
            fixJSON = fixJSON.replace('"null"', '""');
            fixJSON = fixJSON.replace('null', '');
            fixJSON = fixJSON.substring(0,fixJSON.length()-1);
            system.debug('currentJSON--'+currentJSON);
            system.debug('fixJSON--'+fixJSON);
            JSON='"Current":{'+currentJSON+'},'+'"Fix":{'+fixJSON+'}';
            return JSON;
         } 
         
         
         public static string returncreepReliefJSON(string AssetID){
            string JSON;
            CompleteInterfaceMappping__mdt[] configObjTypes = [Select MasterLabel,FFAFieldName__c,AssetCondition__c,SAPFieldName__c,RecordType__c from CompleteInterfaceMappping__mdt WHERE RecordType__c='CreepRelief'];
            FFA_NGV_Asset__c AssetMAP = [SELECT id,FFA_Serial_Number__c,FFA_Asset_Type__c,FFA_Connection_size__c,FFA_Asset_Status__c,FFA_Manufacturer__c,
                                     FFA_Model__c,FFA_ThirdPartyMeter__c,FFA_Year_of_Manufacturer__c,FFA_Location_Notes_Fix__c,FFA_Installed_On_Stream__c,FFA_Meter_Type__c,FFA_Payment_Method__c,
                                     FFA_Meter_Link_Status__c,FFA_Meter_Mechanism__c,FFA_Meter_Mechanism_Fix__c,FFA_Installed_On_Stream_Fix__c,FFA_Readable_Dials__c,FFA_Metric_or_Imperial_Indicator__c,FFA_Qmax__c,FFA_Pressure_Read__c,
                                     FFA_Date_Installed__c,FFA_Activity_Type__c,FFA_Primary_Function__c,FFA_Physical_Size__c,FFA_Meter_Read__c,FFA_Connection_type__c,
                                     FFA_Location_Notes__c,FFA_Location__c,Serial_Number_Fix__c,FFA_Connection_size_Fix__c,FFA_Connection_Type_Fix__c,FFA_Converted_Read_Fix__c,
                                     FFA_Date_Installed_Fix__c,FFA_Location_Fix__c,FFA_Manufacturer_Fix__c,FFA_Material_Type_Fix__c,    
                                     FFAMeterLinkStatusFix__c,FFA_Material_Type__c,FFA_Meter_Read_Fix__c,FFA_Meter_Type_Fix__c,FFA_Metric_Imperial_Indicator_Fix__c,
                                     FFA_Model_Fix__c,FFA_Physical_Size_Fix__c,FFA_Pressure_Read_Fix__c,FFA_Primary_Function_Fix__c,FFA_Qmax_Fix__c,
                                     FFA_Readable_Dials_Fix__c,FFA_Unconverted_Read_Fix__c,FFA_Year_of_Manufacturer_Fix__c,FFA_UnConvertedReadingFound__c,FFA_ConvertedReadFound__c,FFA_Unconverted_readings_as_left_Fix__c,FFA_Converted_Reading_As_Left_Fix__c,
                                     FFA_Gauge_Pressure_Fix__c,FFA_Atmospheric_pressure_mBar_Fix__c,FFA_Absolute_Pres_Convertor_Reading_Fix__c,FFA_Temperature_Convertor_Reading_Fix__c,FFA_Atmospheric_Pressure__c,FFA_Conversion_Factor_Fix__c,
                                     FFA_Converter_status_code__c,FFA_Asset_Status_Fix__c,FFA_NoOfDials__c,FFA_UnconvertedLeft__c,FFA_ConvertedLeft__c,FFA_GaugePressure__c,FFA_TI_Absolute_Pressure__c,FFA_TI_Temperature_Reading__c,FFA_Conversion_Factor__c,
                                     FFA_Other_Manufacturer_fix__c,FFA_Other_Manufacturer__c,FFA_Other_Model__c,FFA_Other_Model_fix__c,
                                     FFA_Converter_Status_Code_Fix__c from FFA_NGV_Asset__c WHERE ID=:AssetID limit 1];
            
            Map<String, Object> fieldsAPINameToValue = AssetMAP.getPopulatedFieldsAsMap();
            String currentJSON;
            String fixJSON;
            for(CompleteInterfaceMappping__mdt cust:configObjTypes){
                if(cust.AssetCondition__c=='Current'){
                     if(cust.FFAFieldName__c=='FFA_Other_Manufacturer__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer__c')!=null){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          currentJSON=innerJSON;
                          
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Manufacturer__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer__c')==null ){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Manufacturer__c+'",';
                          currentJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model__c' && fieldsAPINameToValue.get('FFA_Other_Model__c')!=null ){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          currentJSON=innerJSON;
                         
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model__c' && (fieldsAPINameToValue.get('FFA_Other_Model__c')==null || AssetMAP.FFA_Other_Model__c=='')){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Model__c+'",';
                          currentJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed__c' && fieldsAPINameToValue.get('FFA_Date_Installed__c')!=null ){
                          string dateInstalled=FFA_WorkOrderCompleteInterface.convertDateFormattoSAP(AssetMAP.FFA_Date_Installed__c);
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+dateInstalled+'",';
                          currentJSON=innerJSON;
                          
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed__c' && fieldsAPINameToValue.get('FFA_Date_Installed__c')==null ){
                          string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"",';
                          currentJSON=innerJSON;
                      }
                      else{
                      string innerJSON = +currentJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                      currentJSON=innerJSON;
                      }
                }
                
                        
                    
                
                if(cust.AssetCondition__c=='Fix'){
                   if(cust.FFAFieldName__c=='FFA_Other_Manufacturer_fix__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer_fix__c')!=null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          fixJSON=innerJSON;
                          
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Manufacturer_fix__c' && fieldsAPINameToValue.get('FFA_Other_Manufacturer_fix__c')==null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Manufacturer_Fix__c+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model_fix__c' && fieldsAPINameToValue.get('FFA_Other_Model_fix__c')!=null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Other_Model_fix__c' && fieldsAPINameToValue.get('FFA_Other_Model_fix__c')==null){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+AssetMAP.FFA_Model_Fix__c+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed_Fix__c' && fieldsAPINameToValue.get('FFA_Date_Installed_Fix__c')!=null ){
                          string dateInstalled=FFA_WorkOrderCompleteInterface.convertDateFormattoSAP(AssetMAP.FFA_Date_Installed_Fix__c);
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+dateInstalled+'",';
                          fixJSON=innerJSON;
                      }
                      else if(cust.FFAFieldName__c=='FFA_Date_Installed_Fix__c' && fieldsAPINameToValue.get('FFA_Date_Installed_Fix__c')==null ){
                          string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"",';
                          fixJSON=innerJSON;
                      }
                      else{
                       string innerJSON = +fixJSON+'"'+cust.SAPFieldName__c+'":'+'"'+fieldsAPINameToValue.get(cust.FFAFieldName__c)+'",';
                       fixJSON=innerJSON;
                   }
                }
            }   
             
            currentJSON = currentJSON.replace('"null"', '""');
            currentJSON = currentJSON.replace('null', '');
            currentJSON = currentJSON.substring(0,currentJSON.length()-1);
            fixJSON = fixJSON.replace('"null"', '""');
            fixJSON = fixJSON.replace('null', '');
            fixJSON = fixJSON.substring(0,fixJSON.length()-1);
            system.debug('currentJSON--'+currentJSON);
            system.debug('fixJSON--'+fixJSON);
            JSON='"Current":{'+currentJSON+'},'+'"Fix":{'+fixJSON+'}';
            system.debug('Json--'+JSON);
            return JSON;
         } 
    
}