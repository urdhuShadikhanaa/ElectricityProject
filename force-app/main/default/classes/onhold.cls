global class onhold implements Messaging.InboundEmailHandler{
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
                        vccObj2.Agent_Id__c = csvRecordData[10] ;
                        vccObj2.Name = csvRecordData[10];
                        vccObj2.Date__c = csvRecordData[16];  
                        vccObj2.hold_time__c = csvRecordData[28]; 
                 
                         
                      
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