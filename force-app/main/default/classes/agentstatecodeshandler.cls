global class agentstatecodeshandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope){        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult(); 
          Messaging.InboundEmail.TextAttachment[] tAttachments = email.textAttachments;
        Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments; 
        String csvbody='';
        String[] csvFileLines = new List<String>();
        List<VCC_Reporting_Object__c> vcclist1= New List<VCC_Reporting_Object__c>();        
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
                        VCC_Reporting_Object__c vccObj1 = new VCC_Reporting_Object__c() ;
                        system.debug('vccObj1'+ vccObj1);   
                        vccObj1.Agent_Id__c = csvRecordData[0] ;
                         vccObj1.Date__c = csvRecordData[1];
                        vccObj1.name = csvRecordData[0];
                        vccObj1.Agent_state_code__c = csvRecordData[2];  
                        vccObj1.Duration__c = csvRecordData[3];  
                        
                      
                       // vccObj.body = Blob.valueOf(tAttachment.Body);                 
                        vcclist1.add(vccObj1);                        
                    }     
                }
            }           
            if(vcclist1.size()>0)                
                insert vcclist1;
            system.debug('vcclist1'+ vcclist1);
        }        
        result.success = true;
        return result;        
                                      }     
}