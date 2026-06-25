global class agentsummary implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope){        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult(); 
          Messaging.InboundEmail.TextAttachment[] tAttachments = email.textAttachments;
        Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments; 
        String csvbody='';
        String[] csvFileLines = new List<String>();
        List<VCC_Reporting_Object__c> vcclist2= New List<VCC_Reporting_Object__c>();        
        system.debug('bAttachments'+ bAttachments);
        if(bAttachments !=null){
            for(Messaging.InboundEmail.BinaryAttachment btt :bAttachments){
                if(btt.filename.endsWith('.csv')){
                    csvbody = btt.body.toString();  
                    system.debug('csvbody'+ csvbody);                  
                                      
                    csvFileLines = csvbody.split('\n');
                    system.debug('csvFileLines'+ csvFileLines);                    
                    for(Integer i=1; i < csvFileLines.size(); i++){                        
                        String[] csvRecordData = csvFileLines[i].split(',');
                        VCC_Reporting_Object__c vccObj2 = new VCC_Reporting_Object__c() ;
                        system.debug('vccObj2'+ vccObj2);   
                        vccObj2.Agent_Id__c = csvRecordData[0] ;
                         vccObj2.Agent_Name1__c = csvRecordData[1];
                        vccObj2.Name = csvRecordData[1];
                        vccObj2.Inbound_Contacts__c = csvRecordData[3];  
                        vccObj2.Outbound_contacts__c = csvRecordData[4];  
                          vccObj2.Unavailable_Time__c = csvRecordData[9]; 
                        vccObj2.Available_Time__c = csvRecordData[10]; 
                        vccObj2.Refused__c = csvRecordData[12]; 
                      
                       // vccObj.body = Blob.valueOf(tAttachment.Body);                 
                        vcclist2.add(vccObj2);                        
                    }     
                }
            }           
            if(vcclist2.size()>0)                
                insert vcclist2;
            system.debug('vcclist2'+ vcclist2);
        }        
        result.success = true;
        return result;        
                                      }     

}