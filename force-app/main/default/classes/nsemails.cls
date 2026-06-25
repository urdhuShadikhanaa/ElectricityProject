global class nsemails implements Messaging.InboundEmailHandler{
 global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope){        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult(); 
          Messaging.InboundEmail.TextAttachment[] tAttachments = email.textAttachments;
        Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments; 
        String csvbody='';
        String[] csvFileLines = new List<String>();
        List<Case> nscase= New List<Case>();        
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
                        Case case2 = new Case() ;
                        system.debug('case2'+ case2);   
                        
                        case2.Origin = csvRecordData[0];
                        case2.Status = csvRecordData[1];  
                        case2.Priority = csvRecordData[2];
                         case2.text_email__c = csvRecordData[3];
                        case2.Subject = csvRecordData[4];
                       
                       
                    
                    
                 
                         
                      
                                   
                        nscase.add(case2);                        
                    }     
                }
            }           
            if(nscase.size()>0)                
                insert nscase;
            system.debug('nscase'+ nscase);
        }        
        result.success = true;
        return result;        
                                      }     

}