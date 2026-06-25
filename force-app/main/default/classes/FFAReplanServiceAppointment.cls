public class FFAReplanServiceAppointment {
    
   public void setServiceAppointmentDates(set<ID> WorkOrderIds){
        set<Id> serviceAppointmentIds = new set<Id>();
        list<WorkOrder> FFAWorkORders = [select Id , FFA_Replan_Days__c,
                                         (SELECT Id, AppointmentNumber, Status,EarliestStartTime,SchedStartTime,SchedEndTime,DueDate 
                                              FROM SERVICEAPPOINTMENTS where status = 'None' order by createdDate desc limit 1)
                                         from workorder where Id =: WorkOrderIds ];
       
       list<ServiceAppointment> activeServiceAppointmentToUpdate = new list<ServiceAppointment>();
       list<WorkOrder> activeWorkOrderToUpdate = new list<WorkOrder>();
        
       if(FFAWorkORders!=null){
           for(WorkOrder wo : FFAWorkORders){
               system.debug(wo.FFA_Replan_Days__c);
               Date WorkorderBusinessTargetDays = FFAWorkingDaysCalculator.getBusinessTargetDate(integer.valueOf(wo.FFA_Replan_Days__c));
               system.debug(WorkorderBusinessTargetDays);
               Time myReqTime = Time.newInstance(8, 0, 0, 0);
               DateTime ReqAppDate = DateTime.newInstance(WorkorderBusinessTargetDays, myReqTime);
               wo.FFA_RequestedAppointmentDate__c = ReqAppDate;
               activeWorkOrderToUpdate.add(wo);
               system.debug(activeWorkOrderToUpdate.size());
               if(wo.FFA_Replan_Days__c!=null){
                   list<ServiceAppointment> activeServiceAppointment = wo.ServiceAppointments;
                   for(ServiceAppointment sa : activeServiceAppointment){
                       Date serviceApptsBusinessTargetDays = FFAWorkingDaysCalculator.getBusinessTargetDate(integer.valueOf(wo.FFA_Replan_Days__c));
                       Time myStartTime = Time.newInstance(8, 0, 0, 0);
                       Time myEndTime = Time.newInstance(20, 0, 0, 0);
                       DateTime startDate = DateTime.newInstance(serviceApptsBusinessTargetDays, myStartTime);
                       DateTime EndDate = DateTime.newInstance(serviceApptsBusinessTargetDays, myEndTime);
                       sa.SchedStartTime=startDate;
                       sa.SchedEndTime=EndDate;
                       activeServiceAppointmentToUpdate.add(sa);
                       system.debug(activeServiceAppointmentToUpdate.size());
                   }
               }
               // Added by Ankit 08-07-2020,
               wo.FFA_SP_Mobile_Replan_Days__c = wo.FFA_Replan_Days__c;
               wo.FFA_Replan_Days__c = null;
           }
           
           if(!activeServiceAppointmentToUpdate.isEmpty() && !activeWorkOrderToUpdate.isEmpty()){
               update activeWorkOrderToUpdate;
               update activeServiceAppointmentToUpdate;
           }
       }
        
    }

}