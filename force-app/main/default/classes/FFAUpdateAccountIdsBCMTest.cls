@isTest
Public Class FFAUpdateAccountIdsBCMTest{
     @isTest static void UpdateAccountIdsBCMTestMethod1(){
         List<Domestic_BCM_Jobs__c> domBCMJobsLst=new List<Domestic_BCM_Jobs__c>();
         Domestic_BCM_Jobs__c DomBCMJobs=new Domestic_BCM_Jobs__c(receiverid__c='BCMAcc',SenderID__c='RAINBOW',Name='BCMAcc',APPOINTMENT_TIME__c='AM',APPOINTMENT_DATE__c=system.date.today(),Job_Id__c='xyzabcdef',NOTIFICATION_TYPE__c='NOTIFICATION', NatureOfJob__c='NatureOfJob'
                                                                 ,TRANSACTION_TYPE__c='SC',JOB_TYPE__c='Work', MPRN__c='1234', POSTCODE_INCODE__c='1234', POSTCODE_OUTCODE__c='1234', POST_TOWN__c='Test', PRINCIPAL_STREET__c='Test', RECEIPT_DATE__c=system.today(), RECEIPT_TIME__c='8:20', SUPPLIER_ID__c='NGVSP', SUPPLIER__c='Test');
         domBCMJobsLst.add(DomBCMJobs);
         insert domBCMJobsLst;
         
         Account acctoIns = new Account(Name='BCMAcc');
         insert acctoIns;
         UpdateAccountIdsBCM.UpdateAccountIds(null);
         
     }
     @isTest static void UpdateWorkTypeIdsTestMethod1(){
         List<Domestic_BCM_Jobs__c> domBCMJobsLst=new List<Domestic_BCM_Jobs__c>();
         Domestic_BCM_Jobs__c DomBCMJobs=new Domestic_BCM_Jobs__c(receiverid__c='BCMAcc',SenderID__c='RAINBOW',Name='BCMAcc',APPOINTMENT_TIME__c='AM',APPOINTMENT_DATE__c=system.date.today(),Job_Id__c='xyeflkjs',NOTIFICATION_TYPE__c='NOTIFICATION', NatureOfJob__c='NatureOfJob'
                                                                 ,TRANSACTION_TYPE__c='SC',Job_Type__c='E0005A', MPRN__c='1234', POSTCODE_INCODE__c='1234', POSTCODE_OUTCODE__c='1234', POST_TOWN__c='Test', PRINCIPAL_STREET__c='Test', RECEIPT_DATE__c=system.today(), RECEIPT_TIME__c='8:20', SUPPLIER_ID__c='NGVSP', SUPPLIER__c='Test');
         domBCMJobsLst.add(DomBCMJobs);
         insert domBCMJobsLst;
         
         axsy_forms__Form__c axsyfomlist = new axsy_forms__Form__c(Name = 'Test Demo Form');
         insert axsyfomlist;
         
         WorkType WType=new WorkType(name='E0005A',EstimatedDuration=20,DurationType='Hours', Axsy_Form__c=axsyfomlist.Id);
         insert WType;
         UpdateWorkTypeIdsBCM.UpdateWorkTypeIds(null);
         
     }
}