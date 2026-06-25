Public class FFAServiceAppointmentSlotsHandler{

   public static void changeServiceApptTime(Set<ID> ServiceAppointmentIDS){
       try{
           Set<ID>requiredWO=new Set<ID>();
           List<ServiceAppointment> FFASlotTimingUpdate=new List<ServiceAppointment>() ;
           List<FFAServiceAppointmentSlots__mdt> serviceAppointmentSlotsMDT=[SELECT ID,SenderID__c,Slot__c,StartTime__c,EndTime__c,Hours__c,Notification_Type__c
                                                                  FROM FFAServiceAppointmentSlots__mdt];
           List<ServiceAppointment> reqServiceAppointmets=[SELECT ID,Status,ParentRecordId,SchedStartTime,SchedEndTime,FFA_Work_Order__r.FFA_RequestedAppointmentTimeslot__c,
                                                       FFA_Work_Order__r.Notification_Type__c,FFA_Work_Order__r.FFA_Sender_ID__c FROM SERVICEAPPOINTMENT WHERE ID=:ServiceAppointmentIDS];
       
           FOR(ServiceAppointment relatedSAWorkorders:reqServiceAppointmets){
               IF(relatedSAWorkorders.ParentRecordId!=null){
                   requiredWO.add(relatedSAWorkorders.ParentRecordId);
               }
          }
          Map<ID,Workorder> workorderSlots=new Map<ID,Workorder>();
          List<Workorder>workorderSlotsList=[SELECT id,Notification_Type__c,FFA_RequestCreatedTime__c,FFA_RequestedAppointmentTimeslot__c,FFA_Sender_ID__c,FFA_RequestedAppointmentEndDate__c,FFA_RequestedAppointmentDate__c,NGMCP_Scheduled_Start__c,NGMCP_Scheduled_End__c FROM Workorder WHERE ID=:requiredWO];
          FOR(Workorder WO:workorderSlotsList){
          workorderSlots.put(WO.id,WO);
          } 
          
          
          IF(!reqServiceAppointmets.isEmpty() ){
              
              FOR(ServiceAppointment reqSA:reqServiceAppointmets){
                
                  FOR(FFAServiceAppointmentSlots__mdt SASlots:serviceAppointmentSlotsMDT){
                  //CHECKING SYSTEMS
                  IF(SASlots.SenderID__c.toUpperCase()==workorderSlots.get(reqSA.ParentRecordId).FFA_Sender_ID__c.toUpperCase()){
                      //IF PHENIX NOTIFICATION EMPTY FOR RAINBOW ITS HAVE VALUE ALWAYS
                      
                          IF(SASlots.Slot__c==workorderSlots.get(reqSA.ParentRecordId).FFA_RequestedAppointmentTimeslot__c
                             &&SASlots.Notification_Type__c==workorderSlots.get(reqSA.ParentRecordId).Notification_Type__c
                             && (workorderSlots.get(reqSA.ParentRecordId).FFA_RequestedAppointmentEndDate__c == null 
                             || workorderSlots.get(reqSA.ParentRecordId).FFA_RequestedAppointmentEndDate__c ==
                             workorderSlots.get(reqSA.ParentRecordId).FFA_RequestedAppointmentDate__c)
                             && SASlots.Notification_Type__c!=null && SASlots.StartTime__c!=null && SASlots.EndTime__c!=null && reqSA.SchedStartTime!=null && reqSA.SchedEndTime!=null ){
                                
                                        String[] FFASlotTimesStart    = SASlots.StartTime__c.split(':');
                                        String[] FFASlotTimesEnd    = SASlots.EndTime__c.split(':');
                                        String SchStartDateHours=FFASlotTimesStart[0];
                                        String SchStartDateMins=FFASlotTimesStart[1];
                                        String SchEndDateHours=FFASlotTimesEnd[0];
                                        String SchEndDateMins=FFASlotTimesEnd[1];
                                        reqSA.SchedStartTime = Datetime.newInstance(Integer.valueof(reqSA.SchedStartTime.year()), Integer.valueof(reqSA.SchedStartTime.month()), Integer.valueof(reqSA.SchedStartTime.day()), Integer.valueof(SchStartDateHours), Integer.valueof(SchStartDateMins), 00);
                                        reqSA.SchedEndTime   = Datetime.newInstance(Integer.valueof(reqSA.SchedEndTime.year()), Integer.valueof(reqSA.SchedEndTime.month()), Integer.valueof(reqSA.SchedEndTime.day()), Integer.valueof(SchEndDateHours), Integer.valueof(SchEndDateMins), 00);
                                           
                          }
                          //FOR RAINBOW NOTIFICATION CASE
                          IF(SASlots.Slot__c==workorderSlots.get(reqSA.ParentRecordId).FFA_RequestedAppointmentTimeslot__c
                             &&SASlots.Notification_Type__c==workorderSlots.get(reqSA.ParentRecordId).Notification_Type__c
                             && (workorderSlots.get(reqSA.ParentRecordId).FFA_RequestedAppointmentEndDate__c == null 
                             || workorderSlots.get(reqSA.ParentRecordId).FFA_RequestedAppointmentEndDate__c ==
                             workorderSlots.get(reqSA.ParentRecordId).FFA_RequestedAppointmentDate__c)
                             && SASlots.Notification_Type__c!=null && SASlots.StartTime__c!=null && SASlots.EndTime__c!=null && reqSA.SchedStartTime!=null && reqSA.SchedEndTime!=null){
                                
                                        
                                        Date SchEnddate=date.valueof(reqSA.SchedEndTime);
                                        
                                        String[] FFASlotTimesStart    = SASlots.StartTime__c.split(':');
                                        String[] FFASlotTimesEnd    = SASlots.EndTime__c.split(':');
                                        String SchStartDateHours=FFASlotTimesStart[0];
                                        String SchStartDateMins=FFASlotTimesStart[1];
                                        String SchEndDateHours=FFASlotTimesEnd[0];
                                        String SchEndDateMins=FFASlotTimesEnd[1];
                                        
                                        reqSA.SchedStartTime = Datetime.newInstance(Integer.valueof(reqSA.SchedStartTime.year()), Integer.valueof(reqSA.SchedStartTime.month()), Integer.valueof(reqSA.SchedStartTime.day()), Integer.valueof(SchStartDateHours), Integer.valueof(SchStartDateMins), 00);
                                        reqSA.SchedEndTime   = Datetime.newInstance(Integer.valueof(SchEnddate.year()), Integer.valueof(SchEnddate.month()), Integer.valueof(SchEnddate.day()), Integer.valueof(SchEndDateHours), Integer.valueof(SchEndDateMins), 00);
                                 
                           }
                           IF(SASlots.Hours__c!= null && workorderSlots.get(reqSA.ParentRecordId).FFA_RequestedAppointmentTimeslot__c==null 
                              && SASlots.Notification_Type__c==workorderSlots.get(reqSA.ParentRecordId).Notification_Type__c 
                              && (SASlots.Notification_Type__c == 'Y3' || SASlots.Notification_Type__c == 'Z4')
                              &&  reqSA.SchedStartTime!=null && reqSA.SchedEndTime!=null
                             && (workorderSlots.get(reqSA.ParentRecordId).FFA_RequestedAppointmentEndDate__c == null 
                             || workorderSlots.get(reqSA.ParentRecordId).FFA_RequestedAppointmentEndDate__c ==
                             workorderSlots.get(reqSA.ParentRecordId).FFA_RequestedAppointmentDate__c)){
                                       IF(workorderSlots.get(reqSA.ParentRecordId).FFA_RequestCreatedTime__c!=null){
                                        
                                           String[] FFAHour=workorderSlots.get(reqSA.ParentRecordId).FFA_RequestCreatedTime__c.split(':');
                                           Integer FinalHours=Integer.valueof(FFAHour[0])+Integer.valueof(SASlots.Hours__c);
                                           reqSA.SchedStartTime = Datetime.newInstance(Integer.valueof(reqSA.SchedStartTime.year()), Integer.valueof(reqSA.SchedStartTime.month()), Integer.valueof(reqSA.SchedStartTime.day()), Integer.valueof(FFAHour[0]), Integer.valueof(FFAHour[1]), 00);
                                            reqSA.SchedEndTime   = Datetime.newInstance(Integer.valueof(reqSA.SchedStartTime.year()), Integer.valueof(reqSA.SchedStartTime.month()), Integer.valueof(reqSA.SchedStartTime.day()), Integer.valueof(FinalHours), Integer.valueof(FFAHour[1]), 00);
                                           
                                       }else{
                                        
                                       reqSA.SchedEndTime   = Datetime.newInstance(Integer.valueof(reqSA.SchedStartTime.year()), Integer.valueof(reqSA.SchedStartTime.month()), Integer.valueof(reqSA.SchedStartTime.day()), Integer.valueof(reqSA.SchedStartTime.Hour()+3), Integer.valueof(reqSA.SchedStartTime.Minute()), 00);
                                           
                                       }        
                           } 
                      }
                  }
                   FFASlotTimingUpdate.add(reqSA);
              }
          }
          IF(!FFASlotTimingUpdate.isEmpty()){
               Update FFASlotTimingUpdate;
          }
          
           
       }
       catch(Exception e){
      
       }                                           
   }
 }