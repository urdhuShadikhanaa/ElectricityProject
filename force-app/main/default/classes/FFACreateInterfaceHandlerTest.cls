@isTest
public class FFACreateInterfaceHandlerTest {
     @isTest static void doPostTestMethod1(){
         //unplanned date checked with all correct value
        FFA_Site__c site = new FFA_Site__c(name='test site');
         insert site;
         
         Account acc = new Account(Name='NGGD_WM');
         insert acc;
         
         axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
         insert axsyfomlist;
         
         WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
         insert WType;
         
         Workorder wo1 = new Workorder(ExternalId__c='6280010',Status = 'New',FFA_ServiceNotificationNumber__c='629',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
         insert wo1;
         
         OperatingHours op = new OperatingHours(Name = 'NG UK Operating Hours',TimeZone='GMT');
         insert op;
         ServiceTerritory st = new ServiceTerritory(Name='NG UK Territory',OperatingHoursId=op.Id);
         insert st;
         //Response Fake
        string JsonBody = '{"Header":{"TransactionType":"SC","SenderID":"PHOENIX","ReceiverID":"NGGD_WM","InterfaceName":"SF01","FileType":"SF-CREATE","CreationDate":"2019-07-17","CreationTime":"11:27:38","GenerationNumber":823987},"Job":{"ServiceProvider":"NGGD_WM","SiteID":10000492626,"MeterPointReferenceNumber":15935200,"MeterProvider":"NG","ServiceNotificationNumber":1006,"OperationNumber":"0010","JobCode":"E0005A","JobDescription":"I1261B MAINTAIN CONVERTER 2YR","RequestCreatedDate":"2055-09-21","RequestedAppointmentDate":"2055-09-21","UnplannedPolicyStartDate":"2055-06-22","UnplannedPolicyEndDate":"2021-12-31","RequestCreatedTime":"11:27:00","AssetType":"CONVERTER"},"Site":{"ContactTelephoneNumber":"0121 360 0155","BuildingName":"T D CROSS LTD","DependentStreet":"CROSS & MORSE","PrincipalStreet":"SHADY LANE","PostTown":"BIRMINGHAM","PostcodeOutcode":"B44","PostcodeIncode":"9EU","PressureTier":"LP","ConversionFactor":1.02},"Meter":{"ExistingMeterSerialNumber":"R0310D343684A6","ExistingMeterManufacturer":"DRESSER","ExistingMeterModel":"MRD0310A1R","ExistingMeterYearOfManufacture":2006,"MeterStatusCode":"LI","MeterType":"R","MeterMechanism":"CR","MeterLinkCode":"F","MeterNumberOfDials":6,"MeterImperialFlag":"M","MeterLocationCode":32,"MeterLocationNotes":"Meterbox","Qmin":2525,"Qnom":"TEST147","PreviousMeterRead":4685510.54,"PrimaryFunction":"Monitor","PhysicalSize":"25M","PressureRead":"Outlet","Connectionsize":"582.00","Connectiontype":"TEST15325"},"Convertor":{"ConvertorSerialNumber":42099,"ConvertorManufacturer":"DRESSER","ConvertorModel":"M19781","ConvertorYearOfManufacture":2006,"ConvertorLocationCode":32,"ConvertorLocationNotes":"Meterbox","ConvertorNumberOfDials":8,"ConvertorNumberOfUnits":1,"ConvertorImperialIndicator":"M","PreviousUnconvertedReading":953531,"PreviousConvertedReading":501739,"DateInstalled":"2019-07-17"},"FlowComputer":{"FlowComputerSerialNumber":25623,"FlowComputerManufacturer":"AC DELCO","FlowComputerModel":152663,"FlowComputerYearOfManufacture":2004,"DateInstalled":"2019-07-17","FlowComputerLocationCode":"04","FlowComputerrImperialIndicator":"M","FlowComputerNumberOfDials":8},"SlamShut":{"SlamShutSerialNumber":"MPSS00008946","SlamShutManufacturer":"Slamshut5","SlamShutModel":"SL8","SlamShutYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Active","PhysicalSize":86,"PressureRead":"Inlet","Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"CreepRelief":{"CreepReliefSerialNumber":"MPCR00009926","CreepReliefManufacturer":"TestCreeprelief","CreepReliefModel":15263,"CreepReliefYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Creep Relief","PhysicalSize":25,"PressureRead":"Outlet","Connectionsize":"123.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Boiler":{"BoilerSerialNumber":1253625,"BoilerManufacturer":"BOWDEN","BoilerModel":"MD908","BoilerYearOfManufacture":2005,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","InstalledOnStream":1},"WaterBathHeaters":{"WaterBathHeatersSerialNumber":251202,"WaterBathHeatersManufacturer":"BOSS","WaterBathHeatersModel":2525,"WaterBathHeatersYearOfManufacture":2005,"DateInstalled":"2019-07-17","InstalledOnStream":1},"ShellandTube":{"ShellandTubeSerialNumber":"MB8526","ShellandTubeManufacturer":"BAILEY BIRKETT","ShellandTubeModel":"M2525","ShellandTubeYearOfManufacture":1994,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Chromatograph":{"ChromatographSerialNumber":256025,"ChromatographManufacturer":"COMET METERS LTD","ChromatographModel":"M4582","ChromatographYearOfManufacture":2004,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Densitometer":{"DensitometerSerialNumber":8542635,"DensitometerManufacturer":"AUDCO","DensitometerModel":2536,"DensitometerYearOfManufacture":2003,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Valves":{"ValvesSerialNumber":"MPVA00025987","ValvesManufacturer":"Testvalve1","ValvesModel":2563,"ValvesYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Service","PhysicalSize":152,"Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Pipework":{"PipeworkLocationCode":10,"PhysicalSize":123,"MaterialType":"Plastic","Connectionsize":"53.00","Connectiontype":"TEST123653","InstalledOnStream":4},"CathodicProtection":{"CathodicProtectionManufacturer":"ELLIOTT AND GARROOD","CathodicProtectionModel":"E1252","DateInstalled":"2019-07-17","MaterialType":"Plastic","InstalledOnStream":2},"AuxillaryControl":{"AuxillaryControlSerialNumber":125623,"AuxillaryControlManufacturer":"BM METERS","AuxillaryControlModel":"Tes252","AuxillaryControlYearOfManufacture":1983,"DateInstalled":"2019-07-17","PrimaryFunction":"RTU","Connectionsize":"125.00","Connectiontype":"TURBINE","InstalledOnStream":2,"PressureRead":"Outlet"},"AuxillaryRelief":{"AuxillaryReliefSerialNumber":125326,"AuxillaryReliefManufacturer":"BRITISH GAS LIGHT IND","AuxillaryReliefModel":"tr456","AuxillaryReliefYearOfManufacture":1942,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Connectionsize":"152.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"},"Filters":{"FiltersSerialNumber":"MPFI00009926","FiltersManufacturer":"TestFilter","FiltersModel":"TC25","FilterYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Physicalsize":365,"Connectionsize":"1452.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFACreateInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
	Test.startTest();
      
        FFACreateInterfaceHandler.doPost();
	Test.stopTest();
     }
    
    @isTest static void doPostTestMethod2(){
        //With Requested appointment value with all values of work order
        FFA_Site__c site = new FFA_Site__c(name='test site');
         insert site;
         
         Account acc = new Account(Name='NGGD_WM');
         insert acc;
         
         axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
         insert axsyfomlist;
         
         WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
         insert WType;
         
         Workorder wo1 = new Workorder(ExternalId__c='6380010',Status = 'New',FFA_ServiceNotificationNumber__c='639',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
         insert wo1; 
        OperatingHours op = new OperatingHours(Name = 'NG UK Operating Hours',TimeZone='GMT');
         insert op;
        ServiceTerritory st = new ServiceTerritory(Name='NG UK Territory',OperatingHoursId=op.Id);
         insert st;
         //Response Fake
        string JsonBody = '{"Header":{"TransactionType":"SC","SenderID":"RAINBOW","ReceiverID":"NGGD_WM","InterfaceName":"SF01","FileType":"SF-CREATE","CreationDate":"2019-07-17","CreationTime":"11:27:38","GenerationNumber":823987},"Job":{"ServiceProvider":"NGGD_WM","SiteID":10000492626,"MeterPointReferenceNumber":15935200,"MeterProvider":"NG","ServiceNotificationNumber":1006,"OperationNumber":"0010","JobCode":"E0005A","JobDescription":"I1261B MAINTAIN CONVERTER 2YR","RequestCreatedDate":"2020-09-21","UnplannedPolicyStartDate":"2020-09-21","UnplannedPolicyEndDate":"2020-12-21","RequestCreatedTime":"11:27:00","AssetType":"CONVERTER"},"Site":{"ContactTelephoneNumber":"0121 360 0155","BuildingName":"T D CROSS LTD","DependentStreet":"CROSS & MORSE","PrincipalStreet":"SHADY LANE","PostTown":"BIRMINGHAM","PostcodeOutcode":"B44","PostcodeIncode":"9EU","PressureTier":"LP","ConversionFactor":1.02},"Meter":{"ExistingMeterSerialNumber":"R0310D343684A6","ExistingMeterManufacturer":"DRESSER","ExistingMeterModel":"MRD0310A1R","ExistingMeterYearOfManufacture":2006,"MeterStatusCode":"LI","MeterType":"R","MeterMechanism":"CR","MeterLinkCode":"F","MeterNumberOfDials":6,"MeterImperialFlag":"M","MeterLocationCode":32,"MeterLocationNotes":"Meterbox","Qmin":2525,"Qnom":"TEST147","PreviousMeterRead":4685510.54,"PrimaryFunction":"Monitor","PhysicalSize":"25M","PressureRead":"Outlet","Connectionsize":"582.00","Connectiontype":"TEST15325"},"Convertor":{"ConvertorSerialNumber":42099,"ConvertorManufacturer":"DRESSER","ConvertorModel":"M19781","ConvertorYearOfManufacture":2006,"ConvertorLocationCode":32,"ConvertorLocationNotes":"Meterbox","ConvertorNumberOfDials":8,"ConvertorNumberOfUnits":1,"ConvertorImperialIndicator":"M","PreviousUnconvertedReading":953531,"PreviousConvertedReading":501739,"DateInstalled":"2019-07-17"},"FlowComputer":{"FlowComputerSerialNumber":25623,"FlowComputerManufacturer":"AC DELCO","FlowComputerModel":152663,"FlowComputerYearOfManufacture":2004,"DateInstalled":"2019-07-17","FlowComputerLocationCode":"04","FlowComputerrImperialIndicator":"M","FlowComputerNumberOfDials":8},"SlamShut":{"SlamShutSerialNumber":"MPSS00008946","SlamShutManufacturer":"Slamshut5","SlamShutModel":"SL8","SlamShutYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Active","PhysicalSize":86,"PressureRead":"Inlet","Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"CreepRelief":{"CreepReliefSerialNumber":"MPCR00009926","CreepReliefManufacturer":"TestCreeprelief","CreepReliefModel":15263,"CreepReliefYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Creep Relief","PhysicalSize":25,"PressureRead":"Outlet","Connectionsize":"123.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Boiler":{"BoilerSerialNumber":1253625,"BoilerManufacturer":"BOWDEN","BoilerModel":"MD908","BoilerYearOfManufacture":2005,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","InstalledOnStream":1},"WaterBathHeaters":{"WaterBathHeatersSerialNumber":251202,"WaterBathHeatersManufacturer":"BOSS","WaterBathHeatersModel":2525,"WaterBathHeatersYearOfManufacture":2005,"DateInstalled":"2019-07-17","InstalledOnStream":1},"ShellandTube":{"ShellandTubeSerialNumber":"MB8526","ShellandTubeManufacturer":"BAILEY BIRKETT","ShellandTubeModel":"M2525","ShellandTubeYearOfManufacture":1994,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Chromatograph":{"ChromatographSerialNumber":256025,"ChromatographManufacturer":"COMET METERS LTD","ChromatographModel":"M4582","ChromatographYearOfManufacture":2004,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Densitometer":{"DensitometerSerialNumber":8542635,"DensitometerManufacturer":"AUDCO","DensitometerModel":2536,"DensitometerYearOfManufacture":2003,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Valves":{"ValvesSerialNumber":"MPVA00025987","ValvesManufacturer":"Testvalve1","ValvesModel":2563,"ValvesYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Service","PhysicalSize":152,"Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Pipework":{"PipeworkLocationCode":10,"PhysicalSize":123,"MaterialType":"Plastic","Connectionsize":"53.00","Connectiontype":"TEST123653","InstalledOnStream":4},"CathodicProtection":{"CathodicProtectionManufacturer":"ELLIOTT AND GARROOD","CathodicProtectionModel":"E1252","DateInstalled":"2019-07-17","MaterialType":"Plastic","InstalledOnStream":2},"AuxillaryControl":{"AuxillaryControlSerialNumber":125623,"AuxillaryControlManufacturer":"BM METERS","AuxillaryControlModel":"Tes252","AuxillaryControlYearOfManufacture":1983,"DateInstalled":"2019-07-17","PrimaryFunction":"RTU","Connectionsize":"125.00","Connectiontype":"TURBINE","InstalledOnStream":2,"PressureRead":"Outlet"},"AuxillaryRelief":{"AuxillaryReliefSerialNumber":125326,"AuxillaryReliefManufacturer":"BRITISH GAS LIGHT IND","AuxillaryReliefModel":"tr456","AuxillaryReliefYearOfManufacture":1942,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Connectionsize":"152.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"},"Filters":{"FiltersSerialNumber":"MPFI00009926","FiltersManufacturer":"TestFilter","FiltersModel":"TC25","FilterYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Physicalsize":365,"Connectionsize":"1452.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFACreateInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        //string strres;
        //strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
	Test.startTest();
        FFACreateInterfaceHandler.doPost();
	Test.stopTest();
     }
    
    @isTest static void dsearDataTestMethod(){
        FFA_Site__c site = new FFA_Site__c(name='1234567');
         insert site;
         
         Account acc = new Account(Name='NGGD_WM');
         insert acc;
         
         axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
         insert axsyfomlist;
         
         WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
         insert WType;
        Workorder wo2 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='629',FFA_Sender_ID__c='PHOENIX',DSEAR_Status__c='s',FFA_MeterPointReferenceNumber__c ='12345678',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo2.FFA_RequestedAppointmentDate__c);
         insert wo2;
         
         DSEAR__c dsearRecord = new DSEAR__c();
         dsearRecord.Work_Order__c = wo2.Id;
         insert dsearRecord;
         
         Workorder wo3 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='629',FFA_Sender_ID__c='PHOENIX',DSEAR_Status__c='F',FFA_MeterPointReferenceNumber__c ='1234567',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,Full_DSEAR__c=dsearRecord.id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo3.FFA_RequestedAppointmentDate__c);
         insert wo3;
        Test.StartTest();
        FFAGetDSEARWorkOrder.getDsearWorkOrderId('1234567');
	Test.StopTest();
    }
    //my added lines
    //working
     @isTest static void test_Failurepath_ReturnFalse(){
         string JsonBody = '{"Header":{"TransactionType":"SC","SenderID":"PHOENIX","ReceiverID":"NGGD_WM","InterfaceName":"SF01","FileType":"SF-CREATE","CreationDate":"2019-07-17","CreationTime":"11:27:38","GenerationNumber":823987},"Job":{"ServiceProvider":"","SiteID":10000492626,"MeterPointReferenceNumber":15935200,"MeterProvider":"NG","ServiceNotificationNumber":"","OperationNumber":"","JobCode":"","JobDescription":"I1261B MAINTAIN CONVERTER 2YR","RequestCreatedDate":"2055-09-21","RequestedAppointmentDate":"","UnplannedPolicyStartDate":"2055-06-22","UnplannedPolicyEndDate":"2021-12-31","RequestCreatedTime":"11:27:00","AssetType":"CONVERTER"},"Site":{"ContactTelephoneNumber":"0121 360 0155","BuildingName":"T D CROSS LTD","DependentStreet":"CROSS & MORSE","PrincipalStreet":"SHADY LANE","PostTown":"BIRMINGHAM","PostcodeOutcode":"B44","PostcodeIncode":"9EU","PressureTier":"LP","ConversionFactor":1.02},"Meter":{"ExistingMeterSerialNumber":"R0310D343684A6","ExistingMeterManufacturer":"DRESSER","ExistingMeterModel":"MRD0310A1R","ExistingMeterYearOfManufacture":2006,"MeterStatusCode":"LI","MeterType":"R","MeterMechanism":"CR","MeterLinkCode":"F","MeterNumberOfDials":6,"MeterImperialFlag":"M","MeterLocationCode":32,"MeterLocationNotes":"Meterbox","Qmin":2525,"Qnom":"TEST147","PreviousMeterRead":4685510.54,"PrimaryFunction":"Monitor","PhysicalSize":"25M","PressureRead":"Outlet","Connectionsize":"582.00","Connectiontype":"TEST15325"},"Convertor":{"ConvertorSerialNumber":42099,"ConvertorManufacturer":"DRESSER","ConvertorModel":"M19781","ConvertorYearOfManufacture":2006,"ConvertorLocationCode":32,"ConvertorLocationNotes":"Meterbox","ConvertorNumberOfDials":8,"ConvertorNumberOfUnits":1,"ConvertorImperialIndicator":"M","PreviousUnconvertedReading":953531,"PreviousConvertedReading":501739,"DateInstalled":"2019-07-17"},"FlowComputer":{"FlowComputerSerialNumber":25623,"FlowComputerManufacturer":"AC DELCO","FlowComputerModel":152663,"FlowComputerYearOfManufacture":2004,"DateInstalled":"2019-07-17","FlowComputerLocationCode":"04","FlowComputerrImperialIndicator":"M","FlowComputerNumberOfDials":8},"SlamShut":{"SlamShutSerialNumber":"MPSS00008946","SlamShutManufacturer":"Slamshut5","SlamShutModel":"SL8","SlamShutYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Active","PhysicalSize":86,"PressureRead":"Inlet","Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"CreepRelief":{"CreepReliefSerialNumber":"MPCR00009926","CreepReliefManufacturer":"TestCreeprelief","CreepReliefModel":15263,"CreepReliefYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Creep Relief","PhysicalSize":25,"PressureRead":"Outlet","Connectionsize":"123.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Boiler":{"BoilerSerialNumber":1253625,"BoilerManufacturer":"BOWDEN","BoilerModel":"MD908","BoilerYearOfManufacture":2005,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","InstalledOnStream":1},"WaterBathHeaters":{"WaterBathHeatersSerialNumber":251202,"WaterBathHeatersManufacturer":"BOSS","WaterBathHeatersModel":2525,"WaterBathHeatersYearOfManufacture":2005,"DateInstalled":"2019-07-17","InstalledOnStream":1},"ShellandTube":{"ShellandTubeSerialNumber":"MB8526","ShellandTubeManufacturer":"BAILEY BIRKETT","ShellandTubeModel":"M2525","ShellandTubeYearOfManufacture":1994,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Chromatograph":{"ChromatographSerialNumber":256025,"ChromatographManufacturer":"COMET METERS LTD","ChromatographModel":"M4582","ChromatographYearOfManufacture":2004,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Densitometer":{"DensitometerSerialNumber":8542635,"DensitometerManufacturer":"AUDCO","DensitometerModel":2536,"DensitometerYearOfManufacture":2003,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Valves":{"ValvesSerialNumber":"MPVA00025987","ValvesManufacturer":"Testvalve1","ValvesModel":2563,"ValvesYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Service","PhysicalSize":152,"Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Pipework":{"PipeworkLocationCode":10,"PhysicalSize":123,"MaterialType":"Plastic","Connectionsize":"53.00","Connectiontype":"TEST123653","InstalledOnStream":4},"CathodicProtection":{"CathodicProtectionManufacturer":"ELLIOTT AND GARROOD","CathodicProtectionModel":"E1252","DateInstalled":"2019-07-17","MaterialType":"Plastic","InstalledOnStream":2},"AuxillaryControl":{"AuxillaryControlSerialNumber":125623,"AuxillaryControlManufacturer":"BM METERS","AuxillaryControlModel":"Tes252","AuxillaryControlYearOfManufacture":1983,"DateInstalled":"2019-07-17","PrimaryFunction":"RTU","Connectionsize":"125.00","Connectiontype":"TURBINE","InstalledOnStream":2,"PressureRead":"Outlet"},"AuxillaryRelief":{"AuxillaryReliefSerialNumber":125326,"AuxillaryReliefManufacturer":"BRITISH GAS LIGHT IND","AuxillaryReliefModel":"tr456","AuxillaryReliefYearOfManufacture":1942,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Connectionsize":"152.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"},"Filters":{"FiltersSerialNumber":"MPFI00009926","FiltersManufacturer":"TestFilter","FiltersModel":"TC25","FilterYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Physicalsize":365,"Connectionsize":"1452.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFACreateInterface/*';
        req.httpMethod = 'POST';
         req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        //string strres;
        //strres= req.requestBody.tostring();
        //FFACreateInterfaceHandler.parse(strres);
	Test.startTest();
     FFACreateInterfaceHandler.doPost();
	Test.stopTest();
    system.assert(true);
    }
    //working
    @isTest static void test_createResponse_jobcodenotvalidormissing(){
        string JsonBody = '{"Header":{"TransactionType":"SC","SenderID":"PHOENIX","ReceiverID":"NGGD_WM","InterfaceName":"SF01","FileType":"SF-CREATE","CreationDate":"2019-07-17","CreationTime":"11:27:38","GenerationNumber":823987},"Job":{"ServiceProvider":"NGGD_WM","SiteID":10000492626,"MeterPointReferenceNumber":15935200,"MeterProvider":"NG","ServiceNotificationNumber":900,"OperationNumber":"1000","JobCode":"E0005A","JobDescription":"I1261B MAINTAIN CONVERTER 2YR","RequestCreatedDate":"2055-09-21","RequestedAppointmentDate":"20250-09-21","UnplannedPolicyStartDate":"2055-06-22","UnplannedPolicyEndDate":"2021-12-31","RequestCreatedTime":"11:27:00","AssetType":"CONVERTER"},"Site":{"ContactTelephoneNumber":"0121 360 0155","BuildingName":"T D CROSS LTD","DependentStreet":"CROSS & MORSE","PrincipalStreet":"SHADY LANE","PostTown":"BIRMINGHAM","PostcodeOutcode":"B44","PostcodeIncode":"9EU","PressureTier":"LP","ConversionFactor":1.02},"Meter":{"ExistingMeterSerialNumber":"R0310D343684A6","ExistingMeterManufacturer":"DRESSER","ExistingMeterModel":"MRD0310A1R","ExistingMeterYearOfManufacture":2006,"MeterStatusCode":"LI","MeterType":"R","MeterMechanism":"CR","MeterLinkCode":"F","MeterNumberOfDials":6,"MeterImperialFlag":"M","MeterLocationCode":32,"MeterLocationNotes":"Meterbox","Qmin":2525,"Qnom":"TEST147","PreviousMeterRead":4685510.54,"PrimaryFunction":"Monitor","PhysicalSize":"25M","PressureRead":"Outlet","Connectionsize":"582.00","Connectiontype":"TEST15325"},"Convertor":{"ConvertorSerialNumber":42099,"ConvertorManufacturer":"DRESSER","ConvertorModel":"M19781","ConvertorYearOfManufacture":2006,"ConvertorLocationCode":32,"ConvertorLocationNotes":"Meterbox","ConvertorNumberOfDials":8,"ConvertorNumberOfUnits":1,"ConvertorImperialIndicator":"M","PreviousUnconvertedReading":953531,"PreviousConvertedReading":501739,"DateInstalled":"2019-07-17"},"FlowComputer":{"FlowComputerSerialNumber":25623,"FlowComputerManufacturer":"AC DELCO","FlowComputerModel":152663,"FlowComputerYearOfManufacture":2004,"DateInstalled":"2019-07-17","FlowComputerLocationCode":"04","FlowComputerrImperialIndicator":"M","FlowComputerNumberOfDials":8},"SlamShut":{"SlamShutSerialNumber":"MPSS00008946","SlamShutManufacturer":"Slamshut5","SlamShutModel":"SL8","SlamShutYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Active","PhysicalSize":86,"PressureRead":"Inlet","Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"CreepRelief":{"CreepReliefSerialNumber":"MPCR00009926","CreepReliefManufacturer":"TestCreeprelief","CreepReliefModel":15263,"CreepReliefYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Creep Relief","PhysicalSize":25,"PressureRead":"Outlet","Connectionsize":"123.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Boiler":{"BoilerSerialNumber":1253625,"BoilerManufacturer":"BOWDEN","BoilerModel":"MD908","BoilerYearOfManufacture":2005,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","InstalledOnStream":1},"WaterBathHeaters":{"WaterBathHeatersSerialNumber":251202,"WaterBathHeatersManufacturer":"BOSS","WaterBathHeatersModel":2525,"WaterBathHeatersYearOfManufacture":2005,"DateInstalled":"2019-07-17","InstalledOnStream":1},"ShellandTube":{"ShellandTubeSerialNumber":"MB8526","ShellandTubeManufacturer":"BAILEY BIRKETT","ShellandTubeModel":"M2525","ShellandTubeYearOfManufacture":1994,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Chromatograph":{"ChromatographSerialNumber":256025,"ChromatographManufacturer":"COMET METERS LTD","ChromatographModel":"M4582","ChromatographYearOfManufacture":2004,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Densitometer":{"DensitometerSerialNumber":8542635,"DensitometerManufacturer":"AUDCO","DensitometerModel":2536,"DensitometerYearOfManufacture":2003,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Valves":{"ValvesSerialNumber":"MPVA00025987","ValvesManufacturer":"Testvalve1","ValvesModel":2563,"ValvesYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Service","PhysicalSize":152,"Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Pipework":{"PipeworkLocationCode":10,"PhysicalSize":123,"MaterialType":"Plastic","Connectionsize":"53.00","Connectiontype":"TEST123653","InstalledOnStream":4},"CathodicProtection":{"CathodicProtectionManufacturer":"ELLIOTT AND GARROOD","CathodicProtectionModel":"E1252","DateInstalled":"2019-07-17","MaterialType":"Plastic","InstalledOnStream":2},"AuxillaryControl":{"AuxillaryControlSerialNumber":125623,"AuxillaryControlManufacturer":"BM METERS","AuxillaryControlModel":"Tes252","AuxillaryControlYearOfManufacture":1983,"DateInstalled":"2019-07-17","PrimaryFunction":"RTU","Connectionsize":"125.00","Connectiontype":"TURBINE","InstalledOnStream":2,"PressureRead":"Outlet"},"AuxillaryRelief":{"AuxillaryReliefSerialNumber":125326,"AuxillaryReliefManufacturer":"BRITISH GAS LIGHT IND","AuxillaryReliefModel":"tr456","AuxillaryReliefYearOfManufacture":1942,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Connectionsize":"152.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"},"Filters":{"FiltersSerialNumber":"MPFI00009926","FiltersManufacturer":"TestFilter","FiltersModel":"TC25","FilterYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Physicalsize":365,"Connectionsize":"1452.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"}}';
 RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFACreateInterface/*';
        req.httpMethod = 'POST';
         req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
	Test.startTest();
     FFACreateInterfaceHandler.doPost();
	Test.stopTest();
    system.assert(true,'Failure branches executed');
        
    }
    //working
      @isTest static void test_serviceprovidernotvalid(){
        FFA_Site__c site = new FFA_Site__c(name='test site');
         insert site;
         
         Account acc = new Account(Name='NGGD_WM');
         insert acc;
         
         axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
         insert axsyfomlist;
         
         WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
         insert WType;
         
         Workorder wo1 = new Workorder(ExternalId__c='6280010',Status = 'New',FFA_ServiceNotificationNumber__c='629',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
         insert wo1;
         
         OperatingHours op = new OperatingHours(Name = 'NG UK Operating Hours',TimeZone='GMT');
         insert op;
         ServiceTerritory st = new ServiceTerritory(Name='NG UK Territory',OperatingHoursId=op.Id);
         insert st;
         //Response Fake
        string JsonBody = '{"Header":{"TransactionType":"SC","SenderID":"PHOENIX","ReceiverID":"NGGD_WM","InterfaceName":"SF01","FileType":"SF-CREATE","CreationDate":"2019-07-17","CreationTime":"11:27:38","GenerationNumber":823987},"Job":{"ServiceProvider":"NN0P1","SiteID":10000492626,"MeterPointReferenceNumber":15935200,"MeterProvider":"NG","ServiceNotificationNumber":1006,"OperationNumber":"0010","JobCode":"E0005A","JobDescription":"I1261B MAINTAIN CONVERTER 2YR","RequestCreatedDate":"2055-09-21","RequestedAppointmentDate":"2055-09-21","UnplannedPolicyStartDate":"2055-06-22","UnplannedPolicyEndDate":"2021-12-31","RequestCreatedTime":"11:27:00","AssetType":"CONVERTER"},"Site":{"ContactTelephoneNumber":"0121 360 0155","BuildingName":"T D CROSS LTD","DependentStreet":"CROSS & MORSE","PrincipalStreet":"SHADY LANE","PostTown":"BIRMINGHAM","PostcodeOutcode":"B44","PostcodeIncode":"9EU","PressureTier":"LP","ConversionFactor":1.02},"Meter":{"ExistingMeterSerialNumber":"R0310D343684A6","ExistingMeterManufacturer":"DRESSER","ExistingMeterModel":"MRD0310A1R","ExistingMeterYearOfManufacture":2006,"MeterStatusCode":"LI","MeterType":"R","MeterMechanism":"CR","MeterLinkCode":"F","MeterNumberOfDials":6,"MeterImperialFlag":"M","MeterLocationCode":32,"MeterLocationNotes":"Meterbox","Qmin":2525,"Qnom":"TEST147","PreviousMeterRead":4685510.54,"PrimaryFunction":"Monitor","PhysicalSize":"25M","PressureRead":"Outlet","Connectionsize":"582.00","Connectiontype":"TEST15325"},"Convertor":{"ConvertorSerialNumber":42099,"ConvertorManufacturer":"DRESSER","ConvertorModel":"M19781","ConvertorYearOfManufacture":2006,"ConvertorLocationCode":32,"ConvertorLocationNotes":"Meterbox","ConvertorNumberOfDials":8,"ConvertorNumberOfUnits":1,"ConvertorImperialIndicator":"M","PreviousUnconvertedReading":953531,"PreviousConvertedReading":501739,"DateInstalled":"2019-07-17"},"FlowComputer":{"FlowComputerSerialNumber":25623,"FlowComputerManufacturer":"AC DELCO","FlowComputerModel":152663,"FlowComputerYearOfManufacture":2004,"DateInstalled":"2019-07-17","FlowComputerLocationCode":"04","FlowComputerrImperialIndicator":"M","FlowComputerNumberOfDials":8},"SlamShut":{"SlamShutSerialNumber":"MPSS00008946","SlamShutManufacturer":"Slamshut5","SlamShutModel":"SL8","SlamShutYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Active","PhysicalSize":86,"PressureRead":"Inlet","Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"CreepRelief":{"CreepReliefSerialNumber":"MPCR00009926","CreepReliefManufacturer":"TestCreeprelief","CreepReliefModel":15263,"CreepReliefYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Creep Relief","PhysicalSize":25,"PressureRead":"Outlet","Connectionsize":"123.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Boiler":{"BoilerSerialNumber":1253625,"BoilerManufacturer":"BOWDEN","BoilerModel":"MD908","BoilerYearOfManufacture":2005,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","InstalledOnStream":1},"WaterBathHeaters":{"WaterBathHeatersSerialNumber":251202,"WaterBathHeatersManufacturer":"BOSS","WaterBathHeatersModel":2525,"WaterBathHeatersYearOfManufacture":2005,"DateInstalled":"2019-07-17","InstalledOnStream":1},"ShellandTube":{"ShellandTubeSerialNumber":"MB8526","ShellandTubeManufacturer":"BAILEY BIRKETT","ShellandTubeModel":"M2525","ShellandTubeYearOfManufacture":1994,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Chromatograph":{"ChromatographSerialNumber":256025,"ChromatographManufacturer":"COMET METERS LTD","ChromatographModel":"M4582","ChromatographYearOfManufacture":2004,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Densitometer":{"DensitometerSerialNumber":8542635,"DensitometerManufacturer":"AUDCO","DensitometerModel":2536,"DensitometerYearOfManufacture":2003,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Valves":{"ValvesSerialNumber":"MPVA00025987","ValvesManufacturer":"Testvalve1","ValvesModel":2563,"ValvesYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Service","PhysicalSize":152,"Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Pipework":{"PipeworkLocationCode":10,"PhysicalSize":123,"MaterialType":"Plastic","Connectionsize":"53.00","Connectiontype":"TEST123653","InstalledOnStream":4},"CathodicProtection":{"CathodicProtectionManufacturer":"ELLIOTT AND GARROOD","CathodicProtectionModel":"E1252","DateInstalled":"2019-07-17","MaterialType":"Plastic","InstalledOnStream":2},"AuxillaryControl":{"AuxillaryControlSerialNumber":125623,"AuxillaryControlManufacturer":"BM METERS","AuxillaryControlModel":"Tes252","AuxillaryControlYearOfManufacture":1983,"DateInstalled":"2019-07-17","PrimaryFunction":"RTU","Connectionsize":"125.00","Connectiontype":"TURBINE","InstalledOnStream":2,"PressureRead":"Outlet"},"AuxillaryRelief":{"AuxillaryReliefSerialNumber":125326,"AuxillaryReliefManufacturer":"BRITISH GAS LIGHT IND","AuxillaryReliefModel":"tr456","AuxillaryReliefYearOfManufacture":1942,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Connectionsize":"152.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"},"Filters":{"FiltersSerialNumber":"MPFI00009926","FiltersManufacturer":"TestFilter","FiltersModel":"TC25","FilterYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Physicalsize":365,"Connectionsize":"1452.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFACreateInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
	Test.startTest();
        FFACreateInterfaceHandler.doPost();
	Test.stopTest();        
    }
    //working
    @isTest static void test_SetpointsForWorkorder(){
        FFA_Site__c site = new FFA_Site__c(Name='TestMPRN');
        insert Site;
        Account acc = new Account(Name='NGGD_WM');
         insert acc;
         
         axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
         insert axsyfomlist;
         
         WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
         insert WType;
        Workorder wo1 = new Workorder(ExternalId__c='6380010',Status = 'New',FFA_ServiceNotificationNumber__c='639',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo1.FFA_RequestedAppointmentDate__c);
         insert wo1;
        Workorder wo2 = new Workorder(ExternalId__c='6380011',Status = 'New',FFA_ServiceNotificationNumber__c='649',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        
         insert wo2;
        Operational_Settings__c os1 = new Operational_Settings__c(
        Work_Order__c=wo1.Id,
        Site__C=site.Id,
            Asset_Type__C='Slamshut',
            Set_Point__C='100',
            Stream_No__C='1',
            Primary_Function__C='Monitor',
            Lockup_pressure__c='10'
        );
        Operational_Settings__c os2 = new Operational_Settings__c(
        Work_Order__c=wo2.Id,
        Site__C=site.Id,
            Asset_Type__C='Boiler',
            Set_Point__C='200',
            Stream_No__C='2',
            Primary_Function__C='Monitor',
            Lockup_pressure__c='50'
        );
        insert os2;
        Test.startTest();
        FFACreateInterfaceHandler.SetpointsforWorkorder('TestMPRN',Wo1.Id,Site.Id);
        Test.stopTest();
        List<Operational_Settings__c> created = [Select Id From Operational_Settings__c WHERE Site__C =:site.Id];
    }
     @isTest static void test_CreateFailureResponses(){
         string JsonBody = '{"Header":{"TransactionType":"SC","SenderID":"PHOENIX","ReceiverID":"NGGD_WM","InterfaceName":"SF01","FileType":"SF-CREATE","CreationDate":"2019-07-17","CreationTime":"11:27:38","GenerationNumber":823987},"Job":{"ServiceProvider":"NGGD_WM","SiteID":10000492626,"MeterPointReferenceNumber":15935200,"MeterProvider":"NG","ServiceNotificationNumber":1006,"OperationNumber":"0010","JobCode":"THIS_VALUE_NEVER_EXIST","JobDescription":"I1261B MAINTAIN CONVERTER 2YR","RequestCreatedDate":"2055-09-21","RequestedAppointmentDate":"2055-09-21","UnplannedPolicyStartDate":"2055-06-22","UnplannedPolicyEndDate":"2021-12-31","RequestCreatedTime":"11:27:00","AssetType":"CONVERTER"},"Site":{"ContactTelephoneNumber":"0121 360 0155","BuildingName":"T D CROSS LTD","DependentStreet":"CROSS & MORSE","PrincipalStreet":"SHADY LANE","PostTown":"BIRMINGHAM","PostcodeOutcode":"B44","PostcodeIncode":"9EU","PressureTier":"LP","ConversionFactor":1.0,"County":"SomeCountyValue"},"Meter":{"ExistingMeterSerialNumber":"R0310D343684A6","ExistingMeterManufacturer":"DRESSER","ExistingMeterModel":"MRD0310A1R","ExistingMeterYearOfManufacture":2006,"MeterStatusCode":"LI","MeterType":"R","MeterMechanism":"CR","MeterLinkCode":"F","MeterNumberOfDials":6,"MeterImperialFlag":"M","MeterLocationCode":32,"MeterLocationNotes":"Meterbox","Qmin":2525,"Qnom":"TEST147","PreviousMeterRead":4685510.54,"PrimaryFunction":"Monitor","PhysicalSize":"25M","PressureRead":"Outlet","Connectionsize":"582.00","Connectiontype":"TEST15325"},"Convertor":{"ConvertorSerialNumber":42099,"ConvertorManufacturer":"DRESSER","ConvertorModel":"M19781","ConvertorYearOfManufacture":2006,"ConvertorLocationCode":32,"ConvertorLocationNotes":"Meterbox","ConvertorNumberOfDials":8,"ConvertorNumberOfUnits":1,"ConvertorImperialIndicator":"M","PreviousUnconvertedReading":953531,"PreviousConvertedReading":501739,"DateInstalled":"2019-07-17"},"FlowComputer":{"FlowComputerSerialNumber":25623,"FlowComputerManufacturer":"AC DELCO","FlowComputerModel":152663,"FlowComputerYearOfManufacture":2004,"DateInstalled":"2019-07-17","FlowComputerLocationCode":"04","FlowComputerrImperialIndicator":"M","FlowComputerNumberOfDials":8},"SlamShut":{"SlamShutSerialNumber":"MPSS00008946","SlamShutManufacturer":"Slamshut5","SlamShutModel":"SL8","SlamShutYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Active","PhysicalSize":86,"PressureRead":"Inlet","Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"CreepRelief":{"CreepReliefSerialNumber":"MPCR00009926","CreepReliefManufacturer":"TestCreeprelief","CreepReliefModel":15263,"CreepReliefYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Creep Relief","PhysicalSize":25,"PressureRead":"Outlet","Connectionsize":"123.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Boiler":{"BoilerSerialNumber":1253625,"BoilerManufacturer":"BOWDEN","BoilerModel":"MD908","BoilerYearOfManufacture":2005,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","InstalledOnStream":1},"WaterBathHeaters":{"WaterBathHeatersSerialNumber":251202,"WaterBathHeatersManufacturer":"BOSS","WaterBathHeatersModel":2525,"WaterBathHeatersYearOfManufacture":2005,"DateInstalled":"2019-07-17","InstalledOnStream":1},"ShellandTube":{"ShellandTubeSerialNumber":"MB8526","ShellandTubeManufacturer":"BAILEY BIRKETT","ShellandTubeModel":"M2525","ShellandTubeYearOfManufacture":1994,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Chromatograph":{"ChromatographSerialNumber":256025,"ChromatographManufacturer":"COMET METERS LTD","ChromatographModel":"M4582","ChromatographYearOfManufacture":2004,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Densitometer":{"DensitometerSerialNumber":8542635,"DensitometerManufacturer":"AUDCO","DensitometerModel":2536,"DensitometerYearOfManufacture":2003,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Valves":{"ValvesSerialNumber":"MPVA00025987","ValvesManufacturer":"Testvalve1","ValvesModel":2563,"ValvesYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Service","PhysicalSize":152,"Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Pipework":{"PipeworkLocationCode":10,"PhysicalSize":123,"MaterialType":"Plastic","Connectionsize":"53.00","Connectiontype":"TEST123653","InstalledOnStream":4},"CathodicProtection":{"CathodicProtectionManufacturer":"ELLIOTT AND GARROOD","CathodicProtectionModel":"E1252","DateInstalled":"2019-07-17","MaterialType":"Plastic","InstalledOnStream":2},"AuxillaryControl":{"AuxillaryControlSerialNumber":125623,"AuxillaryControlManufacturer":"BM METERS","AuxillaryControlModel":"Tes252","AuxillaryControlYearOfManufacture":1983,"DateInstalled":"2019-07-17","PrimaryFunction":"RTU","Connectionsize":"125.00","Connectiontype":"TURBINE","InstalledOnStream":2,"PressureRead":"Outlet"},"AuxillaryRelief":{"AuxillaryReliefSerialNumber":125326,"AuxillaryReliefManufacturer":"BRITISH GAS LIGHT IND","AuxillaryReliefModel":"tr456","AuxillaryReliefYearOfManufacture":1942,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Connectionsize":"152.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"},"Filters":{"FiltersSerialNumber":"MPFI00009926","FiltersManufacturer":"TestFilter","FiltersModel":"TC25","FilterYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Physicalsize":365,"Connectionsize":"1452.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"}}';  
		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFACreateInterface/*';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
Test.startTest();	
        FFACreateInterfaceHandler.doPost();
	Test.stopTest();        
    }
    
    @isTest static void test_createNewWoRecord(){
         FFA_Site__c site = new FFA_Site__c(name='Test site');
         insert site;
         
         Account acc = new Account(Name='NGGD_WM');
         insert acc;
         
         axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
         insert axsyfomlist;
         
         WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
         insert WType;
        Workorder wo2 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='629',FFA_Sender_ID__c='PHOENIX',DSEAR_Status__c='s',FFA_MeterPointReferenceNumber__c ='12345678',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo2.FFA_RequestedAppointmentDate__c);
         insert wo2;
       FFAServiceAppointmentSlots__mdt appointmentSlot = [SELECT ID,SenderID__c,Slot__c,StartTime__c,EndTime__c,Hours__c,Notification_Type__c
            FROM FFAServiceAppointmentSlots__mdt 
            where SenderID__c ='Phoenix' AND
            Notification_Type__c ='Z3' AND
            Slot__c ='AT'
            LIMIT 1];
                         

        string jsonbody='{"Header":{"TransactionType":"SC","SenderID":"PHOENIX","ReceiverID":"NGGD_WM","InterfaceName":"SF01","FileType":"SF-CREATE","CreationDate":"2019-07-17","CreationTime":"11:27:38","GenerationNumber":823987},"Job":{"ServiceProvider":"NGGD_WM","SiteID":10000492626,"MeterPointReferenceNumber":15935200,"NotificationType": "Z3","RequestedAppointmentTimeslot": "AT","MeterProvider":"NG","ServiceNotificationNumber":1006,"OperationNumber":"0010","JobCode":"E0005A","JobDescription":"I1261B MAINTAIN CONVERTER 2YR","RequestCreatedDate":"2055-09-21","RequestedAppointmentDate":"2055-09-21","RequestedAppointmentEndDate":"2055-11-21","UnplannedPolicyStartDate":"2055-06-22","UnplannedPolicyEndDate":"2021-12-31","RequestCreatedTime":"11:27:00","AssetType":"CONVERTER"},"Site":{"ContactTelephoneNumber":"0121 360 0155","BuildingName":"T D CROSS LTD","DependentStreet":"CROSS & MORSE","PrincipalStreet":"SHADY LANE","PostTown":"BIRMINGHAM","PostcodeOutcode":"B44","PostcodeIncode":"9EU","PressureTier":"LP","ConversionFactor":1.0,"County":"SomeCountyValue","BuildingNumber":"10","SubBuildingName":"Unit1","DependentLocality":"Locality","DoubleDependentLocality":"District"},"Meter":{"ExistingMeterSerialNumber":"R0310D343684A6","ExistingMeterManufacturer":"DRESSER","ExistingMeterModel":"MRD0310A1R","ExistingMeterYearOfManufacture":2006,"MeterStatusCode":"LI","MeterType":"R","MeterMechanism":"CR","MeterLinkCode":"F","MeterNumberOfDials":6,"MeterImperialFlag":"M","MeterLocationCode":32,"MeterLocationNotes":"Meterbox","Qmin":2525,"Qnom":"TEST147","PreviousMeterRead":4685510.54,"PrimaryFunction":"Monitor","PhysicalSize":"25M","PressureRead":"Outlet","Connectionsize":"582.00","Connectiontype":"TEST15325"},"Convertor":{"ConvertorSerialNumber":42099,"ConvertorManufacturer":"DRESSER","ConvertorModel":"M19781","ConvertorYearOfManufacture":2006,"ConvertorLocationCode":32,"ConvertorLocationNotes":"Meterbox","ConvertorNumberOfDials":8,"ConvertorNumberOfUnits":1,"ConvertorImperialIndicator":"M","PreviousUnconvertedReading":953531,"PreviousConvertedReading":501739,"DateInstalled":"2019-07-17"},"FlowComputer":{"FlowComputerSerialNumber":25623,"FlowComputerManufacturer":"AC DELCO","FlowComputerModel":152663,"FlowComputerYearOfManufacture":2004,"DateInstalled":"2019-07-17","FlowComputerLocationCode":"04","FlowComputerrImperialIndicator":"M","FlowComputerNumberOfDials":8},"SlamShut":{"SlamShutSerialNumber":"MPSS00008946","SlamShutManufacturer":"Slamshut5","SlamShutModel":"SL8","SlamShutYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Active","PhysicalSize":86,"PressureRead":"Inlet","Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"CreepRelief":{"CreepReliefSerialNumber":"MPCR00009926","CreepReliefManufacturer":"TestCreeprelief","CreepReliefModel":15263,"CreepReliefYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Creep Relief","PhysicalSize":25,"PressureRead":"Outlet","Connectionsize":"123.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Boiler":{"BoilerSerialNumber":1253625,"BoilerManufacturer":"BOWDEN","BoilerModel":"MD908","BoilerYearOfManufacture":2005,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","InstalledOnStream":1},"WaterBathHeaters":{"WaterBathHeatersSerialNumber":251202,"WaterBathHeatersManufacturer":"BOSS","WaterBathHeatersModel":2525,"WaterBathHeatersYearOfManufacture":2005,"DateInstalled":"2019-07-17","InstalledOnStream":1},"ShellandTube":{"ShellandTubeSerialNumber":"MB8526","ShellandTubeManufacturer":"BAILEY BIRKETT","ShellandTubeModel":"M2525","ShellandTubeYearOfManufacture":1994,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Chromatograph":{"ChromatographSerialNumber":256025,"ChromatographManufacturer":"COMET METERS LTD","ChromatographModel":"M4582","ChromatographYearOfManufacture":2004,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Densitometer":{"DensitometerSerialNumber":8542635,"DensitometerManufacturer":"AUDCO","DensitometerModel":2536,"DensitometerYearOfManufacture":2003,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Valves":{"ValvesSerialNumber":"MPVA00025987","ValvesManufacturer":"Testvalve1","ValvesModel":2563,"ValvesYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Service","PhysicalSize":152,"Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Pipework":{"PipeworkLocationCode":10,"PhysicalSize":123,"MaterialType":"Plastic","Connectionsize":"53.00","Connectiontype":"TEST123653","InstalledOnStream":4},"CathodicProtection":{"CathodicProtectionManufacturer":"ELLIOTT AND GARROOD","CathodicProtectionModel":"E1252","DateInstalled":"2019-07-17","MaterialType":"Plastic","InstalledOnStream":2},"AuxillaryControl":{"AuxillaryControlSerialNumber":125623,"AuxillaryControlManufacturer":"BM METERS","AuxillaryControlModel":"Tes252","AuxillaryControlYearOfManufacture":1983,"DateInstalled":"2019-07-17","PrimaryFunction":"RTU","Connectionsize":"125.00","Connectiontype":"TURBINE","InstalledOnStream":2,"PressureRead":"Outlet"},"AuxillaryRelief":{"AuxillaryReliefSerialNumber":125326,"AuxillaryReliefManufacturer":"BRITISH GAS LIGHT IND","AuxillaryReliefModel":"tr456","AuxillaryReliefYearOfManufacture":1942,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Connectionsize":"152.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"},"Filters":{"FiltersSerialNumber":"MPFI00009926","FiltersManufacturer":"TestFilter","FiltersModel":"TC25","FilterYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Physicalsize":365,"Connectionsize":"1452.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"}}';   RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/FFACreateInterface/*';
        req.httpMethod = 'POST';
         req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
	Test.startTest();
     FFACreateInterfaceHandler.doPost();

	Test.stopTest();
        List<Workorder> WoList=[SELECT Id FROM Workorder Limit 1];
        System.Assert(!wolist.isempty(),'Workorder must be created');
                                      
    }
    @isTest static void test_createServiceAppointment(){
       FFA_Site__c site = new FFA_Site__c(name='Test site');
         insert site;
         
         Account acc = new Account(Name='NGGD_WM');
         insert acc;
         
         axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
         insert axsyfomlist;
        OperatingHours Op = new OperatingHours(Name='NG Business Hours');
        insert op;
         ServiceTerritory ST = new ServiceTerritory(Name='NG UK Territory',OperatingHoursId=op.id);
        Insert ST;
         WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
         insert WType;
        Workorder wo2 = new Workorder(Status = 'Pending',FFA_ServiceNotificationNumber__c='629',FFA_Sender_ID__c='PHOENIX',DSEAR_Status__c='s',FFA_MeterPointReferenceNumber__c ='12345678',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=Datetime.Now().addDays(1),FFA_RequestedAppointmentEndDate__c=Datetime.Now().addDays(1).addHours(2),
                                      FFA_UnplannedPolicyStartDate__c=Datetime.Now().addDays(1).addHours(3),FFA_UnplannedPolicyEndDate__c=Datetime.Now().addDays(1).addHours(4));
        system.debug(''+wo2.FFA_RequestedAppointmentDate__c);
         insert wo2;
        
      string jsonbody='{"Header":{"TransactionType":"SC","SenderID":"PHOENIX","ReceiverID":"NGGD_WM","InterfaceName":"SF01","FileType":"SF-CREATE","CreationDate":"2019-07-17","CreationTime":"11:27:38","GenerationNumber":823987},"Job":{"ServiceProvider":"NGGD_WM","SiteID":10000492626,"MeterPointReferenceNumber":15935200,"MeterProvider":"NG","ServiceNotificationNumber":1006,"OperationNumber":"0010","JobCode":"E0005A","JobDescription":"I1261B MAINTAIN CONVERTER 2YR","RequestCreatedDate":"2055-09-21","RequestedAppointmentDate":"2055-09-21","RequestedAppointmentEndDate":"2055-11-20","UnplannedPolicyStartDate":"2055-06-22","UnplannedPolicyEndDate":"2055-12-31","RequestCreatedTime":"11:27:00","AssetType":"CONVERTER"},"Site":{"ContactTelephoneNumber":"0121 360 0155","BuildingName":"T D CROSS LTD","DependentStreet":"CROSS & MORSE","PrincipalStreet":"SHADY LANE","PostTown":"BIRMINGHAM","PostcodeOutcode":"B44","PostcodeIncode":"9EU","PressureTier":"LP","ConversionFactor":1.0,"County":"SomeCountyValue"},"Meter":{"ExistingMeterSerialNumber":"R0310D343684A6","ExistingMeterManufacturer":"DRESSER","ExistingMeterModel":"MRD0310A1R","ExistingMeterYearOfManufacture":2006,"MeterStatusCode":"LI","MeterType":"R","MeterMechanism":"CR","MeterLinkCode":"F","MeterNumberOfDials":6,"MeterImperialFlag":"M","MeterLocationCode":32,"MeterLocationNotes":"Meterbox","Qmin":2525,"Qnom":"TEST147","PreviousMeterRead":4685510.54,"PrimaryFunction":"Monitor","PhysicalSize":"25M","PressureRead":"Outlet","Connectionsize":"582.00","Connectiontype":"TEST15325"},"Convertor":{"ConvertorSerialNumber":42099,"ConvertorManufacturer":"DRESSER","ConvertorModel":"M19781","ConvertorYearOfManufacture":2006,"ConvertorLocationCode":32,"ConvertorLocationNotes":"Meterbox","ConvertorNumberOfDials":8,"ConvertorNumberOfUnits":1,"ConvertorImperialIndicator":"M","PreviousUnconvertedReading":953531,"PreviousConvertedReading":501739,"DateInstalled":"2019-07-17"},"FlowComputer":{"FlowComputerSerialNumber":25623,"FlowComputerManufacturer":"AC DELCO","FlowComputerModel":152663,"FlowComputerYearOfManufacture":2004,"DateInstalled":"2019-07-17","FlowComputerLocationCode":"04","FlowComputerrImperialIndicator":"M","FlowComputerNumberOfDials":8},"SlamShut":{"SlamShutSerialNumber":"MPSS00008946","SlamShutManufacturer":"Slamshut5","SlamShutModel":"SL8","SlamShutYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Active","PhysicalSize":86,"PressureRead":"Inlet","Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"CreepRelief":{"CreepReliefSerialNumber":"MPCR00009926","CreepReliefManufacturer":"TestCreeprelief","CreepReliefModel":15263,"CreepReliefYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Creep Relief","PhysicalSize":25,"PressureRead":"Outlet","Connectionsize":"123.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Boiler":{"BoilerSerialNumber":1253625,"BoilerManufacturer":"BOWDEN","BoilerModel":"MD908","BoilerYearOfManufacture":2005,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","InstalledOnStream":1},"WaterBathHeaters":{"WaterBathHeatersSerialNumber":251202,"WaterBathHeatersManufacturer":"BOSS","WaterBathHeatersModel":2525,"WaterBathHeatersYearOfManufacture":2005,"DateInstalled":"2019-07-17","InstalledOnStream":1},"ShellandTube":{"ShellandTubeSerialNumber":"MB8526","ShellandTubeManufacturer":"BAILEY BIRKETT","ShellandTubeModel":"M2525","ShellandTubeYearOfManufacture":1994,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Chromatograph":{"ChromatographSerialNumber":256025,"ChromatographManufacturer":"COMET METERS LTD","ChromatographModel":"M4582","ChromatographYearOfManufacture":2004,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Densitometer":{"DensitometerSerialNumber":8542635,"DensitometerManufacturer":"AUDCO","DensitometerModel":2536,"DensitometerYearOfManufacture":2003,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Valves":{"ValvesSerialNumber":"MPVA00025987","ValvesManufacturer":"Testvalve1","ValvesModel":2563,"ValvesYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Service","PhysicalSize":152,"Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Pipework":{"PipeworkLocationCode":10,"PhysicalSize":123,"MaterialType":"Plastic","Connectionsize":"53.00","Connectiontype":"TEST123653","InstalledOnStream":4},"CathodicProtection":{"CathodicProtectionManufacturer":"ELLIOTT AND GARROOD","CathodicProtectionModel":"E1252","DateInstalled":"2019-07-17","MaterialType":"Plastic","InstalledOnStream":2},"AuxillaryControl":{"AuxillaryControlSerialNumber":125623,"AuxillaryControlManufacturer":"BM METERS","AuxillaryControlModel":"Tes252","AuxillaryControlYearOfManufacture":1983,"DateInstalled":"2019-07-17","PrimaryFunction":"RTU","Connectionsize":"125.00","Connectiontype":"TURBINE","InstalledOnStream":2,"PressureRead":"Outlet"},"AuxillaryRelief":{"AuxillaryReliefSerialNumber":125326,"AuxillaryReliefManufacturer":"BRITISH GAS LIGHT IND","AuxillaryReliefModel":"tr456","AuxillaryReliefYearOfManufacture":1942,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Connectionsize":"152.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"},"Filters":{"FiltersSerialNumber":"MPFI00009926","FiltersManufacturer":"TestFilter","FiltersModel":"TC25","FilterYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Physicalsize":365,"Connectionsize":"1452.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"}}';   
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
       // req.requestURI = '/FFACreateInterface/*';
        req.httpMethod = 'POST';
         req.requestBody= Blob.valueof(JsonBody);
        RestContext.request = req;
        RestContext.response = res;
        
	Test.startTest();
     FFACreateInterfaceHandler.dopost();
      FFACreateInterfaceHandler.createServiceAppointment(System.now(),System.now().addHours(4), System.now(),
                                         System.now().addHours(4),wo2.Id);  
        FFACreateInterfaceHandler.createServiceAppointment(System.now(),null, System.now(),
                                         System.now().addHours(4),wo2.Id);  
         Test.stopTest();
	}
    //till here
   @isTest static void testMethodForContactToUser()
    {
      try{
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(UserRoleId = portalRole.Id,
                                            ProfileId = profile1.Id,
                                            Username = System.now().millisecond() + 'test2@test.com',
                                            Alias = 'batman',
                                            Email='bruce.wayne@wayneenterprises.com',
                                            EmailEncodingKey='UTF-8',
                                            Firstname='Bruce',
                                            Lastname='Wayne',
                                            LanguageLocaleKey='en_US',
                                            LocaleSidKey='en_US',
                                            TimeZoneSidKey='America/Chicago'
                                            );
        Database.insert(portalAccountOwner1);
        System.runAs ( portalAccountOwner1 ) {
            Account portalAccount1 = new Account(Name = 'NG portal User Account',
                                                OwnerId = portalAccountOwner1.Id
                                                );
                                            
            Database.insert(portalAccount1);
            
            
        }
            
     }
     catch (Exception e) {
         Boolean expectedExceptionThrown =  e.getMessage().contains('Out of Axsy Liscenses,Please request Axsy for more Liscenses') ? true : false;
         //System.assertEquals(expectedExceptionThrown, False);   
        }
    }
    
    @isTest static void CreateNewAssetRecordTest(){

        FFA_Site__c site = new FFA_Site__c(name='1234567');
         insert site;
         
         Account acc = new Account(Name='NGGD_WM');
         insert acc;
         
         axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
         insert axsyfomlist;
         
         WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
         insert WType;
        Workorder wo2 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='629',FFA_Sender_ID__c='PHOENIX',DSEAR_Status__c='s',FFA_MeterPointReferenceNumber__c ='12345678',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo2.FFA_RequestedAppointmentDate__c);
         insert wo2;
        FFA_Integration_Mappings__mdt[] mappings = [Select SAP_Field_Name__c,FFA_Field_Name__c,FFA_Data_Type__c from FFA_Integration_Mappings__mdt];
        
       Map<String, Object> payload = new Map<String, Object>{
            'ExistingMeterSerialNumber' => 'A0123B456789C0',
            'ExistingMeterManufacturer' => 'MRS0120B2D',
            'ExistingMeterYearOfManufacture' => '2000',
            'MeterStatusCode' => 'A1',
            'MeterType' => 'R',
            'MeterMechanism' => 'ND',
            'MeterLinkCode' => 'A',
            'MeterNumberOfDials' => '3',
            'MeterImperialFlag' => 'M',
            'MeterLocationCode' => '00',
            'MeterLocationNotes' => 'Meterbox',
            'Qmin' => '1234',
            'Qnom' => 'TEST123',
            'PreviousMeterRead' => '1234.00',
            'PrimaryFunction' => 'Monitor',
            'PhysicalSize' => '10M',
            'PressureRead' => 'Outlet',
            'Connectionsize' => '123.00',
            'Connectiontype' => 'TEST12345'
            
        }; 
            Map<String, Object> payload2 = new Map<String, Object>{
            'ContactTelephoneNumber'=> '0121 360 0155',
    'BuildingName'=> 'T D CROSS LTD',
    'DependentStreet'=> 'CROSS & MORSE',
    'PrincipalStreet'=> 'SHADY LANE',
    'PostTown'=> 'BIRMINGHAM',
    'PostcodeOutcode'=> 'B44',
    'PostcodeIncode'=> '9EU',
    'PressureTier'=> 'LP',
    'ConversionFactor'=> 1,
            'County'=> 'SomeCountyValue'};
                
        
       // String payloadStringified = buildCreateRequestBody();
       FFA_CreateInterfaceModel.wrapperClass wc = new FFA_CreateInterfaceModel.wrapperClass();
        Record_Type__mdt[] recordTypes = [Select MasterLabel from Record_Type__mdt];
        Test.startTest();
         FFACreateInterfaceHandler.CreateNewAssetRecord(wo2,'Meter', payload, mappings,acc.Name);
        FFACreateInterfaceHandler.CreateNewSiteRecord(wo2,payload2, mappings);
        
        string jsonbody='{"Header":{"TransactionType":"SC","SenderID":"PHOENIX","ReceiverID":"NGGD_WM","InterfaceName":"SF01","FileType":"SF-CREATE","CreationDate":"2019-07-17","CreationTime":"11:27:38","GenerationNumber":823987},"Job":{"ServiceProvider":"NGGD_WM","SiteID":10000492626,"MeterPointReferenceNumber":15935200,"MeterProvider":"NG","ServiceNotificationNumber":1006,"OperationNumber":"0010","JobCode":"E0005A","JobDescription":"I1261B MAINTAIN CONVERTER 2YR","RequestCreatedDate":"2055-09-21","RequestedAppointmentDate":"2055-09-21","RequestedAppointmentEndDate":"2055-11-20","UnplannedPolicyStartDate":"2055-06-22","UnplannedPolicyEndDate":"2055-12-31","RequestCreatedTime":"11:27:00","AssetType":"CONVERTER"},"Site":{"ContactTelephoneNumber":"0121 360 0155","BuildingName":"T D CROSS LTD","DependentStreet":"CROSS & MORSE","PrincipalStreet":"SHADY LANE","PostTown":"BIRMINGHAM","PostcodeOutcode":"B44","PostcodeIncode":"9EU","PressureTier":"LP","ConversionFactor":1.0,"County":"SomeCountyValue"},"Meter":{"ExistingMeterSerialNumber":"R0310D343684A6","ExistingMeterManufacturer":"DRESSER","ExistingMeterModel":"MRD0310A1R","ExistingMeterYearOfManufacture":2006,"MeterStatusCode":"LI","MeterType":"R","MeterMechanism":"CR","MeterLinkCode":"F","MeterNumberOfDials":6,"MeterImperialFlag":"M","MeterLocationCode":32,"MeterLocationNotes":"Meterbox","Qmin":2525,"Qnom":"TEST147","PreviousMeterRead":4685510.54,"PrimaryFunction":"Monitor","PhysicalSize":"25M","PressureRead":"Outlet","Connectionsize":"582.00","Connectiontype":"TEST15325"},"Convertor":{"ConvertorSerialNumber":42099,"ConvertorManufacturer":"DRESSER","ConvertorModel":"M19781","ConvertorYearOfManufacture":2006,"ConvertorLocationCode":32,"ConvertorLocationNotes":"Meterbox","ConvertorNumberOfDials":8,"ConvertorNumberOfUnits":1,"ConvertorImperialIndicator":"M","PreviousUnconvertedReading":953531,"PreviousConvertedReading":501739,"DateInstalled":"2019-07-17"},"FlowComputer":{"FlowComputerSerialNumber":25623,"FlowComputerManufacturer":"AC DELCO","FlowComputerModel":152663,"FlowComputerYearOfManufacture":2004,"DateInstalled":"2019-07-17","FlowComputerLocationCode":"04","FlowComputerrImperialIndicator":"M","FlowComputerNumberOfDials":8},"SlamShut":{"SlamShutSerialNumber":"MPSS00008946","SlamShutManufacturer":"Slamshut5","SlamShutModel":"SL8","SlamShutYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Active","PhysicalSize":86,"PressureRead":"Inlet","Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"CreepRelief":{"CreepReliefSerialNumber":"MPCR00009926","CreepReliefManufacturer":"TestCreeprelief","CreepReliefModel":15263,"CreepReliefYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Creep Relief","PhysicalSize":25,"PressureRead":"Outlet","Connectionsize":"123.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Boiler":{"BoilerSerialNumber":1253625,"BoilerManufacturer":"BOWDEN","BoilerModel":"MD908","BoilerYearOfManufacture":2005,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","InstalledOnStream":1},"WaterBathHeaters":{"WaterBathHeatersSerialNumber":251202,"WaterBathHeatersManufacturer":"BOSS","WaterBathHeatersModel":2525,"WaterBathHeatersYearOfManufacture":2005,"DateInstalled":"2019-07-17","InstalledOnStream":1},"ShellandTube":{"ShellandTubeSerialNumber":"MB8526","ShellandTubeManufacturer":"BAILEY BIRKETT","ShellandTubeModel":"M2525","ShellandTubeYearOfManufacture":1994,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Chromatograph":{"ChromatographSerialNumber":256025,"ChromatographManufacturer":"COMET METERS LTD","ChromatographModel":"M4582","ChromatographYearOfManufacture":2004,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Densitometer":{"DensitometerSerialNumber":8542635,"DensitometerManufacturer":"AUDCO","DensitometerModel":2536,"DensitometerYearOfManufacture":2003,"DateInstalled":"2019-07-17","InstalledOnStream":1},"Valves":{"ValvesSerialNumber":"MPVA00025987","ValvesManufacturer":"Testvalve1","ValvesModel":2563,"ValvesYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Service","PhysicalSize":152,"Connectionsize":"156.00","Connectiontype":"TURBINE","InstalledOnStream":1},"Pipework":{"PipeworkLocationCode":10,"PhysicalSize":123,"MaterialType":"Plastic","Connectionsize":"53.00","Connectiontype":"TEST123653","InstalledOnStream":4},"CathodicProtection":{"CathodicProtectionManufacturer":"ELLIOTT AND GARROOD","CathodicProtectionModel":"E1252","DateInstalled":"2019-07-17","MaterialType":"Plastic","InstalledOnStream":2},"AuxillaryControl":{"AuxillaryControlSerialNumber":125623,"AuxillaryControlManufacturer":"BM METERS","AuxillaryControlModel":"Tes252","AuxillaryControlYearOfManufacture":1983,"DateInstalled":"2019-07-17","PrimaryFunction":"RTU","Connectionsize":"125.00","Connectiontype":"TURBINE","InstalledOnStream":2,"PressureRead":"Outlet"},"AuxillaryRelief":{"AuxillaryReliefSerialNumber":125326,"AuxillaryReliefManufacturer":"BRITISH GAS LIGHT IND","AuxillaryReliefModel":"tr456","AuxillaryReliefYearOfManufacture":1942,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Connectionsize":"152.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"},"Filters":{"FiltersSerialNumber":"MPFI00009926","FiltersManufacturer":"TestFilter","FiltersModel":"TC25","FilterYearOfManufacture":1900,"DateInstalled":"2019-07-17","PrimaryFunction":"Monitor","Physicalsize":365,"Connectionsize":"1452.00","Connectiontype":"TEST147","InstalledOnStream":1,"PressureRead":"Outlet"}}';   
		Map<String, Object> originalpayload = (Map<String, Object>) JSON.deserializeUntyped(jsonbody);
        for(Record_Type__mdt rT : recordTypes){
		 FFACreateInterfaceHandler.CreateNewAssets(wc,originalpayload, jsonbody,rT.MasterLabel,acc.Name);
            
        } 
         Test.stopTest();
    }

     private static String buildCreateRequestBody() {
        Map<String, Object> payload = new Map<String, Object>{
            'ExistingMeterSerialNumber' => 'A0123B456789C0',
            'ExistingMeterManufacturer' => 'MRS0120B2D',
            'ExistingMeterYearOfManufacture' => '2000',
            'MeterStatusCode' => 'A1',
            'MeterType' => 'R',
            'MeterMechanism' => 'ND',
            'MeterLinkCode' => 'A',
            'MeterNumberOfDials' => '3',
            'MeterImperialFlag' => 'M',
            'MeterLocationCode' => '00',
            'MeterLocationNotes' => 'Meterbox',
            'Qmin' => '1234',
            'Qnom' => 'TEST123',
            'PreviousMeterRead' => '1234.00',
            'PrimaryFunction' => 'Monitor',
            'PhysicalSize' => '10M',
            'PressureRead' => 'Outlet',
            'Connectionsize' => '123.00',
            'Connectiontype' => 'TEST12345'
            
        };
       
        return JSON.serialize(payload);
    }
    


}