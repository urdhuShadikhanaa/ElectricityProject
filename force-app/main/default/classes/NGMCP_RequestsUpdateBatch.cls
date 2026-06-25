public with sharing class NGMCP_RequestsUpdateBatch implements 
Database.Batchable<NGMCP_RequestClass.MemberClass>, Database.Stateful{
    private final List<NGMCP_RequestClass.MemberClass> data;
    
    public NGMCP_RequestsUpdateBatch(List<NGMCP_RequestClass.MemberClass> data) {
        this.data = (data == null) ? new List<NGMCP_RequestClass.MemberClass>() : data;
    }
    
    public Iterable<NGMCP_RequestClass.MemberClass> start(Database.BatchableContext bc) {
        return data;
    }
    
    public void execute(Database.BatchableContext bc, List<NGMCP_RequestClass.MemberClass> scope) {
        try{
            List<NGMCP_Request__c> requestList = new List<NGMCP_Request__c>();
            List<NGMCP_Request__c> requestListToUpdate = new List<NGMCP_Request__c>();
            
            Set<String> ticketuids = new Set<String>();
            Map<String,NGMCP_RequestClass.MemberClass> memberMap = new Map<String,NGMCP_RequestClass.MemberClass>();
            
            for (NGMCP_RequestClass.MemberClass rcm1 : scope) {
                
                ticketuids.add(rcm1.ticketuid);
                memberMap.put(rcm1.ticketuid,rcm1);
            }
            
            if(ticketuids != null && !ticketuids.isEmpty()){
                requestList = [SELECT Id,NGMCP_Ticketuid__c,NGMCP_Status__c,
                               NGMCP_Enquiry_Resubmitted__c,NGMCP_Is_the_enquiry_justified__c,NGMCP_Is_the_enquiry_justifi__c,
                               NGMCP_Enquiry_start_date__c,NGMCP_Enquiry_target_end_date__c,
                               NGMCP_Enquiry_resolution__c,NGMCP_ADI_question_from_business_user__c,
                               NGMCP_ADI_response_from_cutomer_portal__c,NGMCP_ADI_expries_on__c,NGMCP_Resolution_Date__c
                               FROM NGMCP_Request__c
                               WHERE NGMCP_Ticketuid__c IN :ticketuids
                               with user_mode];
            }
            
            if(requestList != null && !requestList.isEmpty()){
                
                for(NGMCP_Request__c r : requestList){
                    if(memberMap.containsKey(r.NGMCP_Ticketuid__c)){
                        NGMCP_RequestClass.MemberClass rcm = memberMap.get(r.NGMCP_Ticketuid__c);
                        
                        NGMCP_Request__c row = new NGMCP_Request__c();
                        row.Id = r.Id;
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Ticketuid__c.isUpdateable()){
                            row.NGMCP_Ticketuid__c = rcm.ticketuid;
                        }
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                            row.NGMCP_Status__c = rcm.status_description == 'Approve the SR' ? 'SR Approved' : rcm.status_description;
                        }
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Is_the_enquiry_justified__c.isUpdateable()){
                            row.NGMCP_Is_the_enquiry_justified__c = (rcm.status_description == 'Resolved' || rcm.status_description == 'RESOLVED') && (rcm.commoditygroup == 'QRT' || rcm.commoditygroup == 'QRD') ? rcm.ngme_justify : r.NGMCP_Status__c == 'Resolved' && rcm.status_description == 'In Progress' ? false : r.NGMCP_Is_the_enquiry_justified__c;
                        }
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Is_the_enquiry_justifi__c.isUpdateable()){
                            row.NGMCP_Is_the_enquiry_justifi__c = (rcm.status_description == 'Resolved' || rcm.status_description == 'RESOLVED') && (rcm.commoditygroup == 'QRT' || rcm.commoditygroup == 'QRD') && rcm.ngme_justify != null && rcm.ngme_justify == true ? 'Yes' :(rcm.status_description == 'Resolved' || rcm.status_description == 'RESOLVED') && (rcm.commoditygroup == 'QRT' || rcm.commoditygroup == 'QRD') && rcm.ngme_justify != null && rcm.ngme_justify == false ? 'No' : r.NGMCP_Is_the_enquiry_justifi__c == null ? '' : r.NGMCP_Status__c == 'Resolved' && rcm.status_description == 'In Progress'? '': r.NGMCP_Is_the_enquiry_justifi__c;
                        }
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_ADI_expries_on__c.isUpdateable()){
                            row.NGMCP_ADI_expries_on__c = (rcm.status_description == 'Resolved' || rcm.status_description == 'RESOLVED') ? '' : r.NGMCP_ADI_expries_on__c;
                        } 
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_ADI_question_from_business_user__c.isUpdateable()){
                            row.NGMCP_ADI_question_from_business_user__c = (rcm.status_description == 'Resolved' || rcm.status_description == 'RESOLVED') ? '' : r.NGMCP_ADI_question_from_business_user__c;
                        } 
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Enquiry_Resubmitted__c.isUpdateable()){
                            row.NGMCP_Enquiry_Resubmitted__c = rcm.ngme_resub;
                        }
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Enquiry_start_date__c.isUpdateable()){
                            row.NGMCP_Enquiry_start_date__c = NGMCP_GetRequestClass.changeDateFormat(rcm.actualstart, false);
                        }
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Enquiry_target_end_date__c.isUpdateable()){
                            row.NGMCP_Enquiry_target_end_date__c = NGMCP_GetRequestClass.changeDateFormat(rcm.targetfinish, false);
                        }
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Enquiry_resolution__c.isUpdateable()){
                            row.NGMCP_Enquiry_resolution__c = (rcm.status_description == 'Resolved' || rcm.status_description == 'RESOLVED') && (rcm.commoditygroup == 'QRT' || rcm.commoditygroup == 'QRD') && String.isNotBlank(rcm.ngme_resolutionletter) ? rcm.ngme_resolutionletter : r.NGMCP_Status__c == 'Resolved' && rcm.status_description == 'In Progress'? '' : r.NGMCP_Enquiry_resolution__c;
                        }
                        if (Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Resolution_Date__c.isUpdateable()) {
                            row.NGMCP_Resolution_Date__c =
                                ((rcm.status_description == 'Resolved' || rcm.status_description == 'RESOLVED') &&
                                 (rcm.commoditygroup == 'QRT' || rcm.commoditygroup == 'QRD'))
                                ? NGMCP_EnquiriesHandler.formatToDDMMYYYY(String.valueOf(System.today()))
                                : (r.NGMCP_Status__c == 'Resolved' && rcm.status_description == 'In Progress')
                            ? null
                                : NGMCP_EnquiriesHandler.formatToDDMMYYYY(r.NGMCP_Resolution_Date__c);
                        }
                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                            row.NGMCP_TGEN_task_description__c = rcm.status_description == 'ACKNOWLEDGED' ? 'This Enquiry will be reviewed and NGM will contact the End Customer to agree a visit' : rcm.status_description == 'Resolved' ? 'Resolved - Resolution letter' : '';
                        }
                        
                        
                        if(rcm.worklog != null && !rcm.worklog.isEmpty() && (rcm.status_description != 'Resolved' && rcm.status_description != 'Closed' && rcm.status_description != 'Cancelled')){
                            
                            List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
                            for(NGMCP_RequestClass.WorkLogClass wl : rcm.worklog ){
                                
                                if(wl.logtype == 'QUESTION' || wl.logtype == 'ANSWER' || wl.logtype == 'REMINDER'){
                                    wlList.add(wl);
                                }
                            }
                            
                            if(wlList != null && !wlList.isEmpty()){
                                
                                if(wlList.size() == 1 && wlList[0].logtype == 'QUESTION' ){
                                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_ADI_question_from_business_user__c.isUpdateable()){
                                        row.NGMCP_ADI_question_from_business_user__c = NGMCP_GetRequestClass.changeDateFormat(wlList[0].ngme_adi_expdate, true) == '' ? '' : wlList[0].description_longdescription;
                                    }
                                    
                                    //row.NGMCP_ADI_response_from_cutomer_portal__c = wlList[0].description_longdescription;
                                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                        row.NGMCP_TGEN_task_description__c = NGMCP_GetRequestClass.changeDateFormat(wlList[0].ngme_adi_expdate, true) == '' ? '' : 'Additional Information Requested';
                                    }
                                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_ADI_expries_on__c.isUpdateable()){
                                        row.NGMCP_ADI_expries_on__c = NGMCP_GetRequestClass.changeDateFormat(wlList[0].ngme_adi_expdate, true);
                                    }
                                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                        row.NGMCP_Status__c = NGMCP_GetRequestClass.changeDateFormat(wlList[0].ngme_adi_expdate, true) == '' ? rcm.status_description : 'Additional Information Requested';
                                    }
                                    
                                    
                                }
                                else if(wlList.size() == 1 && wlList[0].logtype == 'REMINDER' ){
                                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                        row.NGMCP_TGEN_task_description__c = NGMCP_GetRequestClass.changeDateFormat(wlList[0].ngme_adi_expdate, true) == '' ? '' : 'Reminder for Additional information';
                                    }
                                    
                                    //row.NGMCP_ADI_response_from_cutomer_portal__c = wlList[0].description_longdescription;
                                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_ADI_expries_on__c.isUpdateable()){
                                        row.NGMCP_ADI_expries_on__c = NGMCP_GetRequestClass.changeDateFormat(wlList[0].ngme_adi_expdate, true);
                                    }
                                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                        row.NGMCP_Status__c = NGMCP_GetRequestClass.changeDateFormat(wlList[0].ngme_adi_expdate, true) == '' ? rcm.status_description : 'Reminder for Additional Information';
                                    }
                                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Reminder_For_ADI__c.isUpdateable()){
                                        row.NGMCP_Reminder_For_ADI__c = wlList[0].description_longdescription;
                                    }
                                    
                                    
                                }else{
                                    NGMCP_RequestClass.WorkLogClass latest = wlList[0];
                                    for(NGMCP_RequestClass.WorkLogClass wl : wlList){
                                        if(NGMCP_GetRequestClass.changeDateTimeFormat(wl.createdate) > NGMCP_GetRequestClass.changeDateTimeFormat(latest.createdate)){
                                            latest = wl;
                                        }
                                    }
                                    if(latest.logtype == 'QUESTION'){
                                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_ADI_question_from_business_user__c.isUpdateable()){
                                            row.NGMCP_ADI_question_from_business_user__c = NGMCP_GetRequestClass.changeDateFormat(latest.ngme_adi_expdate, true) == '' ? '' : latest.description_longdescription;
                                        }
                                        
                                        //row.NGMCP_ADI_response_from_cutomer_portal__c = latest.description_longdescription;
                                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                            row.NGMCP_TGEN_task_description__c = NGMCP_GetRequestClass.changeDateFormat(latest.ngme_adi_expdate, true) == '' ? '' : 'Additional Information Requested';
                                        }
                                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_ADI_expries_on__c.isUpdateable()){
                                            row.NGMCP_ADI_expries_on__c = NGMCP_GetRequestClass.changeDateFormat(latest.ngme_adi_expdate,true);
                                        }
                                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                            row.NGMCP_Status__c = NGMCP_GetRequestClass.changeDateFormat(latest.ngme_adi_expdate, true) == '' ? rcm.status_description : 'Additional Information Requested';
                                        }
                                        
                                        
                                    }
                                    if(latest.logtype == 'REMINDER'){
                                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                            row.NGMCP_TGEN_task_description__c = NGMCP_GetRequestClass.changeDateFormat(latest.ngme_adi_expdate, true) == '' ? '' : 'Reminder for Additional information';
                                        }
                                        
                                        //row.NGMCP_ADI_response_from_cutomer_portal__c = latest.description_longdescription;
                                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_ADI_expries_on__c.isUpdateable()){
                                            row.NGMCP_ADI_expries_on__c = NGMCP_GetRequestClass.changeDateFormat(latest.ngme_adi_expdate,true);
                                        }
                                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                            row.NGMCP_Status__c = NGMCP_GetRequestClass.changeDateFormat(latest.ngme_adi_expdate, true) == '' ? rcm.status_description : 'Reminder for Additional Information';
                                        }
                                        if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Reminder_For_ADI__c.isUpdateable()){
                                            row.NGMCP_Reminder_For_ADI__c = latest.description_longdescription;
                                        }
                                        
                                        
                                    }
                                }
                            }
                        }
                        
                        
                        if(rcm.relatedrecord != null && !rcm.relatedrecord.isEmpty() && (rcm.status_description != 'Resolved' && rcm.status_description != 'Closed' && rcm.status_description != 'Cancelled')){
                            NGMCP_RequestClass.RelatedRecordClass rrc = rcm.relatedrecord[0];
                            
                            if(rrc.workorder != null && !rrc.workorder.isEmpty()){
                                
                                if(rrc.workorder.size() == 1){
                                    row.NGMCP_OFMAT_Result__c = rrc.workorder[0].ngme_ofmat_result_description;
                                    String quotationMessage = '';
                                    if(rrc.workorder[0].status == 'WCUSTQAPPR'){
                                        quotationMessage = String.isNotBlank(rrc.workorder[0].status_description) ? rrc.workorder[0].status_description : 'Waiting for Customer\'s Quote Approval';
                                    }
                                    if(rrc.workorder[0].status == 'CUSTQAPPR'){
                                        quotationMessage = String.isNotBlank(rrc.workorder[0].status_description) ? rrc.workorder[0].status_description : 'Customer approved quotation';
                                    }
                                    if(rrc.workorder[0].status == 'CUSTQREJ'){
                                        quotationMessage = String.isNotBlank(rrc.workorder[0].status_description) ? rrc.workorder[0].status_description : 'Customer Rejected quotation';
                                    }
                                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Quotation_Status__c.isUpdateable()){
                                        row.NGMCP_Quotation_Status__c = quotationMessage;
                                    }
                                    
                                    
                                    if(rrc.workorder[0].woactivity != null && !rrc.workorder[0].woactivity.isEmpty() && rcm.commoditygroup == 'QRT'){
                                        if(rrc.workorder[0].woactivity.size() == 1){
                                            if((rrc.workorder[0].woactivity[0].ngme_task_code == 'AMD' ||
                                                rrc.workorder[0].woactivity[0].ngme_task_code == 'TGEN' ||
                                                rrc.workorder[0].woactivity[0].ngme_task_code == 'OIX' ||
                                                rrc.workorder[0].woactivity[0].ngme_task_code == 'COM') 
                                               && rrc.workorder[0].woactivity[0].status != 'COMP'
                                              ){
                                                  if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                      row.NGMCP_TGEN_task_description__c = rrc.workorder[0].woactivity[0].description;
                                                  }
                                                  if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                      row.NGMCP_Status__c = rrc.workorder[0].woactivity[0].status;
                                                  }
                                                  
                                                  
                                                  if(rrc.workorder[0].woactivity[0].ngme_task_code == 'AMD'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'Amendment made';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'Amendment made';
                                                      }
                                                      
                                                      
                                                  }
                                                  if(rrc.workorder[0].woactivity[0].ngme_task_code == 'TGEN'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'Meter Order in Process';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'Meter replacement has been processed';
                                                      }
                                                      
                                                      
                                                      
                                                  }
                                                  if(rrc.workorder[0].woactivity[0].ngme_task_code == 'OIX'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'In-Progress with Service Partner';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'In-Progress with Service Partner';
                                                      }
                                                      
                                                      
                                                      
                                                  }
                                                  if(rrc.workorder[0].woactivity[0].ngme_task_code == 'COM'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'Site Visit to be agreed';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'Service Partner and End Customer to agree on next steps or agree a site visit';
                                                      }
                                                      
                                                      
                                                      
                                                  }
                                              }
                                            else if((rrc.workorder[0].woactivity[0].ngme_task_code == 'SV' ||
                                                     rrc.workorder[0].woactivity[0].ngme_task_code == 'ATP' ||
                                                     rrc.workorder[0].woactivity[0].ngme_task_code == 'EUD')
                                                    && rrc.workorder[0].woactivity[0].status != 'COMP'
                                                   ){
                                                       if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                           row.NGMCP_Status__c = rrc.workorder[0].woactivity[0].ngme_task_code == 'SV' ? 'Site Visit Planned' : 'Appointment booked';
                                                       }
                                                       if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){ 
                                                           if(rrc.workorder[0].woactivity[0].ngme_task_code == 'SV'){
                                                               row.NGMCP_TGEN_task_description__c = 'Site visit on or before ' + NGMCP_DateUtils.firstFutureDdMmYyyyFromDescription(rrc.workorder[0].woactivity[0].description, Date.today());
                                                           }
                                                           else{
                                                               row.NGMCP_TGEN_task_description__c = NGMCP_DateUtils.expandFutureDdMmToDdMmYyyy(rrc.workorder[0].woactivity[0].description, Date.today());
                                                           }
                                                       }
                                                   }
                                            else{
                                                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                    row.NGMCP_TGEN_task_description__c = '';
                                                }
                                            }
                                            
                                        }
                                        else{
                                            NGMCP_RequestClass.WOActivityClass latestWOA = rrc.workorder[0].woactivity[0];
                                            for(NGMCP_RequestClass.WOActivityClass woa : rrc.workorder[0].woactivity){
                                                
                                                if(latestWOA.taskid != null && woa.taskid != null && woa.taskid > latestWOA.taskid){
                                                    latestWOA = woa;
                                                }
                                            }
                                            if((latestWOA.ngme_task_code == 'AMD' ||
                                                latestWOA.ngme_task_code == 'TGEN' ||
                                                latestWOA.ngme_task_code == 'OIX' ||
                                                latestWOA.ngme_task_code == 'COM') 
                                               && latestWOA.status != 'COMP'
                                              ){
                                                  if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                      row.NGMCP_TGEN_task_description__c = latestWOA.description;
                                                  }
                                                  if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                      row.NGMCP_Status__c = latestWOA.status;
                                                  }
                                                  if(latestWOA.ngme_task_code == 'AMD'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'Amendment made';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'Amendment made';
                                                      }
                                                  }
                                                  if(latestWOA.ngme_task_code == 'TGEN'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'Meter Order in Process';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'Meter replacement has been processed';
                                                      }
                                                  }
                                                  if(latestWOA.ngme_task_code == 'OIX'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'In-Progress with Service Partner';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'In-Progress with Service Partner';
                                                      }
                                                  }
                                                  if(latestWOA.ngme_task_code == 'COM'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'Site Visit to be agreed';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'Service Partner and End Customer to agree on next steps or agree a site visit';
                                                      }
                                                  }
                                              }
                                            else if((latestWOA.ngme_task_code == 'SV' ||
                                                     latestWOA.ngme_task_code == 'ATP' ||
                                                     latestWOA.ngme_task_code == 'EUD')
                                                    && latestWOA.status != 'COMP'
                                                   ){
                                                       if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                           row.NGMCP_Status__c = latestWOA.ngme_task_code == 'SV' ? 'Site Visit Planned' : 'Appointment booked';
                                                       }
                                                       if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                           if(latestWOA.ngme_task_code == 'SV'){
                                                               row.NGMCP_TGEN_task_description__c = 'Site visit on or before ' + NGMCP_DateUtils.firstFutureDdMmYyyyFromDescription(latestWOA.description, Date.today());
                                                           }
                                                           else{
                                                               row.NGMCP_TGEN_task_description__c = NGMCP_DateUtils.expandFutureDdMmToDdMmYyyy(latestWOA.description, Date.today());
                                                           }                                                          
                                                       }
                                                       
                                                   }
                                            else{
                                                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                    row.NGMCP_TGEN_task_description__c = '';
                                                }
                                            }    
                                        }
                                    }
                                }
                                else{
                                    NGMCP_RequestClass.WorkOrderClass earliest = rrc.workorder[0];
                                    for(NGMCP_RequestClass.WorkOrderClass woc : rrc.workorder){
                                        if(woc.wonum < earliest.wonum){
                                            earliest = woc;
                                        }
                                    }
                                    row.NGMCP_OFMAT_Result__c = earliest.ngme_ofmat_result_description;
                                    String quotationMessage = '';
                                    if(earliest.status == 'WCUSTQAPPR'){
                                        quotationMessage = String.isNotBlank(earliest.status_description) ? earliest.status_description : 'Waiting for Customer\'s Quote Approval';
                                    }
                                    if(earliest.status == 'CUSTQAPPR'){
                                        quotationMessage = String.isNotBlank(earliest.status_description) ? earliest.status_description : 'Customer approved quotation';
                                    }
                                    if(earliest.status == 'CUSTQREJ'){
                                        quotationMessage = String.isNotBlank(earliest.status_description) ? earliest.status_description : 'Customer Rejected quotation';
                                    }
                                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Quotation_Status__c.isUpdateable()){
                                        row.NGMCP_Quotation_Status__c = quotationMessage;
                                    }
                                    
                                    
                                    if(earliest.woactivity != null && !earliest.woactivity.isEmpty() && rcm.commoditygroup == 'QRT'){
                                        
                                        if(earliest.woactivity.size() == 1){
                                            if((earliest.woactivity[0].ngme_task_code == 'AMD' ||
                                                earliest.woactivity[0].ngme_task_code == 'TGEN' ||
                                                earliest.woactivity[0].ngme_task_code == 'OIX' ||
                                                earliest.woactivity[0].ngme_task_code == 'COM') 
                                               && earliest.woactivity[0].status != 'COMP'
                                              ){
                                                  if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                      row.NGMCP_TGEN_task_description__c = earliest.woactivity[0].description;
                                                  }
                                                  if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                      row.NGMCP_Status__c = earliest.woactivity[0].status;
                                                  }
                                                  
                                                  
                                                  if(earliest.woactivity[0].ngme_task_code == 'AMD'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'Amendment made';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'Amendment made';
                                                      }
                                                  }
                                                  if(earliest.woactivity[0].ngme_task_code == 'TGEN'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'Meter Order in Process';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'Meter replacement has been processed';
                                                      }
                                                      
                                                      
                                                  }
                                                  if(earliest.woactivity[0].ngme_task_code == 'OIX'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'In-Progress with Service Partner';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'In-Progress with Service Partner';
                                                      }
                                                  }
                                                  if(earliest.woactivity[0].ngme_task_code == 'COM'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'Site Visit to be agreed';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'Service Partner and End Customer to agree on next steps or agree a site visit';
                                                      }
                                                  }
                                              }
                                            else if((earliest.woactivity[0].ngme_task_code == 'SV' ||
                                                     earliest.woactivity[0].ngme_task_code == 'ATP' ||
                                                     earliest.woactivity[0].ngme_task_code == 'EUD')
                                                    && earliest.woactivity[0].status != 'COMP'
                                                   ){
                                                       if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                           row.NGMCP_Status__c = earliest.woactivity[0].ngme_task_code == 'SV' ? 'Site Visit Planned' : 'Appointment booked';
                                                       }
                                                       if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                           if(earliest.woactivity[0].ngme_task_code == 'SV'){
                                                               row.NGMCP_TGEN_task_description__c = 'Site visit on or before ' + NGMCP_DateUtils.firstFutureDdMmYyyyFromDescription(earliest.woactivity[0].description, Date.today());
                                                           }
                                                           else{
                                                               row.NGMCP_TGEN_task_description__c = NGMCP_DateUtils.expandFutureDdMmToDdMmYyyy(earliest.woactivity[0].description, Date.today());
                                                           }
                                                       }
                                                       
                                                   }
                                            else{
                                                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                    row.NGMCP_TGEN_task_description__c = '';
                                                }
                                            }
                                        }
                                        else{
                                            NGMCP_RequestClass.WOActivityClass latestWOA = earliest.woactivity[0];
                                            for(NGMCP_RequestClass.WOActivityClass woa : earliest.woactivity){
                                                
                                                if(latestWOA.taskid != null && woa.taskid != null && woa.taskid > latestWOA.taskid){
                                                    latestWOA = woa;
                                                }
                                            }
                                            if((latestWOA.ngme_task_code == 'AMD' ||
                                                latestWOA.ngme_task_code == 'TGEN' ||
                                                latestWOA.ngme_task_code == 'OIX' ||
                                                latestWOA.ngme_task_code == 'COM') 
                                               && latestWOA.status != 'COMP'
                                              ){
                                                  if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                      row.NGMCP_Status__c = latestWOA.status;
                                                  }
                                                  if(latestWOA.ngme_task_code == 'AMD'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'Amendment made';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'Amendment made';
                                                      }
                                                  }
                                                  if(latestWOA.ngme_task_code == 'TGEN'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'Meter Order in Process';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'Meter replacement has been processed';
                                                      }
                                                  }
                                                  if(latestWOA.ngme_task_code == 'OIX'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'In-Progress with Service Partner';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'In-Progress with Service Partner';
                                                      }
                                                  }
                                                  if(latestWOA.ngme_task_code == 'COM'){
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                          row.NGMCP_Status__c = 'Site Visit to be agreed';
                                                      }
                                                      if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                          row.NGMCP_TGEN_task_description__c = 'Service Partner and End Customer to agree on next steps or agree a site visit';
                                                      }
                                                  }
                                              }
                                            else if((latestWOA.ngme_task_code == 'SV' ||
                                                     latestWOA.ngme_task_code == 'ATP' ||
                                                     latestWOA.ngme_task_code == 'EUD')
                                                    && latestWOA.status != 'COMP'
                                                   ){
                                                       if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isUpdateable()){
                                                           row.NGMCP_Status__c = latestWOA.ngme_task_code == 'SV' ? 'Site Visit Planned' : 'Appointment booked';
                                                       }
                                                       if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                           if(latestWOA.ngme_task_code == 'SV'){
                                                               row.NGMCP_TGEN_task_description__c = 'Site visit on or before ' + NGMCP_DateUtils.firstFutureDdMmYyyyFromDescription(latestWOA.description, Date.today());
                                                           }
                                                           else{
                                                               row.NGMCP_TGEN_task_description__c = NGMCP_DateUtils.expandFutureDdMmToDdMmYyyy(latestWOA.description, Date.today());
                                                           }
                                                       }
                                                   }
                                            else{
                                                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_TGEN_task_description__c.isUpdateable()){
                                                    row.NGMCP_TGEN_task_description__c = '';
                                                }
                                            }   
                                        }
                                    }
                                }
                            }
                        }
                        
                        requestListToUpdate.add(row);
                    }
                }
                if(Schema.sObjectType.NGMCP_Request__c.isUpdateable()){
                    update requestListToUpdate;
                }
            }
            
        }catch(Exception e){
            System.debug('Error: '+e + ' line: '+e.getLineNumber());
            throw e;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
    
}