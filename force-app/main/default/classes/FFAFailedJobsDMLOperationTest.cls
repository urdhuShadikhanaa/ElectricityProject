@isTest
public class FFAFailedJobsDMLOperationTest {
    
    @isTest static void doTestMethod(){
        list<WorkOrder> replanList = new list<WorkOrder>();
        list<WorkOrder> unpolicyList = new list<WorkOrder>();
        list<WorkOrder> SAPReplanUncheck = new list<WorkOrder>();
        list<WorkOrder> FailedList = new list<WorkOrder>();
        list<FFA_Interface_Runs__c> InterfacerunList = new list<FFA_Interface_Runs__c>();
        list<FFA_Interface_Runs__c> oldInterfacerunList = new list<FFA_Interface_Runs__c>();
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
                                     FFA_ServiceNotificationNumber__c='43621',Completion_Date__c=str,
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC');
        insert wo;
        replanList.add(wo);
        WorkOrder wo1 = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
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
                                     FFA_ServiceNotificationNumber__c='43421',Completion_Date__c=str,
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC');
        insert wo1;replanList.add(wo1);
        WorkOrder wo2 = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
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
                                     FFA_ServiceNotificationNumber__c='43221',Completion_Date__c=str,
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC');
        insert wo2;unpolicyList.add(wo2);
        WorkOrder wo3 = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
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
                                     FFA_ServiceNotificationNumber__c='43121',Completion_Date__c=str,
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC');
        insert wo3;
        FailedList.add(wo3);
        WorkOrder wo4 = new WorkOrder(Site__c=site.Id,FFA_PurgingCompleted__c='L',WorkTypeId=WType.Id, Service_Provider__c=acc.Id,
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
                                     FFA_ServiceNotificationNumber__c='43121',Completion_Date__c=str,
                                     FFA_OperationNumber__c='0010',
                                     Status='New',
                                     FFA_JobCode__c='JC');
        insert wo4;
        SAPReplanUncheck.add(wo4);
        FFA_Interface_Runs__c oldintLogs = new FFA_Interface_Runs__c(Interface_Name__c='/FFACompleteInterface',Transaction_Status__c='404',Work_Order__c='000000',FFA_Re_Triggered__c=false,
                                                                  Transaction_Message__c='');
        insert oldintLogs;
        FFA_Interface_Runs__c intLogs = new FFA_Interface_Runs__c(Interface_Name__c='/FFACompleteInterface',Transaction_Status__c='404',Work_Order__c='000000',FFA_Re_Triggered__c=false,
                                                                  Transaction_Message__c='');
                                                                  //insert intLogs;
        
        oldInterfacerunList.add(oldintLogs);
        InterfacerunList.add(intLogs);
        
        FFAFailedJobsDMLOperation.doDmlOperation(replanList,oldInterfacerunList,InterfacerunList);
        
    }

}