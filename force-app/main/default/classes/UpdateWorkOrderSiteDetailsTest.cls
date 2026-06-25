/*This class is used in FFA*/
@isTest
public class UpdateWorkOrderSiteDetailsTest{
    @isTest static void completeInterfaceMethod1(){ 
        List<Workorder> woList=new List<Workorder>();
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
        
        Workorder wo2 = new Workorder(Status = 'New',FFA_ServiceNotificationNumber__c='629',FFA_Sender_ID__c='PHOENIX',DSEAR_Status__c='s',FFA_MeterPointReferenceNumber__c ='12345678',
                                      FFA_OperationNumber__c= '0010',WorkTypeId=WType.id, Service_Provider__c=acc.Id,
                                      Site__c = site.id,FFA_RequestedAppointmentTimeslot__c='AT',FFA_RequestedAppointmentDate__c=System.Datetime.Now());
        system.debug(''+wo2.FFA_RequestedAppointmentDate__c);
        insert wo2;
        
        DSEAR__c dsearRecord = new DSEAR__c();
        dsearRecord.Work_Order__c = wo2.Id;
        insert dsearRecord;
        
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
                                     DSEAR_Lookup__c = dsearRecord.Id,
                                     FFA_JobCode__c='JC');
        insert wo;
        woList.add(wo);
        UpdateWorkOrderSiteDetails.UpdateWorkOrderSite(woList);
        
    }
}