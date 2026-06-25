@isTest
public class FFAReplanServiceAppointmentTest {
    
    @isTest static void doTestMethod(){
        
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
                                     FFA_ContractorID__c='Q',FFA_UnplannedPolicyStartDate__c=System.Datetime.now(),
                                     FFA_Sender_ID__c='PHONEIX',FFA_UnplannedPolicyEndDate__c=System.Datetime.now(),
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',FFA_Replan_Days__c=10,
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
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=System.Datetime.now(),SchedEndTime=System.Datetime.now());
        insert sa;
        
        wo.FFA_Service_Provider_Replan__c = 'Yes';
        wo.FFA_Replan_Days__c = 1;
        update wo;        
        WorkOrder WOQuery = [select Id, WorkOrderNumber from WorkOrder where Id=:wo.Id];
        Set<Id> WOIds = new set<Id>();
        WOIds.add(WOQuery.Id);
        FFAReplanServiceAppointment ffaReplan = new FFAReplanServiceAppointment();
        ffaReplan.setServiceAppointmentDates(WOIds);
    }
    @isTest static void doTestMethod1(){
        
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
                                     FFA_ContractorID__c='Q',FFA_UnplannedPolicyStartDate__c=datetime.valueOf('2050-07-01 00:00:00.0000z'),
                                     FFA_Sender_ID__c='PHONEIX',FFA_UnplannedPolicyEndDate__c=datetime.valueOf('2050-12-31 00:00:00.0000z'),
                                     FFA_EngineerResourceID__c='E',
                                     FFA_NewAppointmentTimeSlot__c='AM',FFA_Replan_Days__c=3,
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
        ServiceAppointment sa = new ServiceAppointment(Status = 'None', Duration=120,DurationType='Hours',ParentRecordId=wo.Id,EarliestStartTime=System.Datetime.now(),DueDate=System.Datetime.now().addHours(23),SchedStartTime=datetime.valueOf('2050-08-01 00:00:00.0000z'),SchedEndTime=datetime.valueOf('2050-12-01 00:00:00.0000z'));
        insert sa;
        
        WorkOrder WOQuery = [select Id, WorkOrderNumber from WorkOrder where Id=:wo.Id];
        Set<Id> WOIds = new set<Id>();
        WOIds.add(WOQuery.Id);
        FFAReplanServiceAppointment ffaReplan = new FFAReplanServiceAppointment();
        ffaReplan.setServiceAppointmentDates(WOIds);
    }
    @isTest static void BusinessDaysAddTestMethod(){
    Integer I=10;
    FFAWorkingDaysCalculator.getBusinessTargetDate(I);
    }
    @isTest static void BusinessDaysAddTestMethod1(){
    Integer I=3;
    FFAWorkingDaysCalculator.getBusinessTargetDate(I);
    }

}