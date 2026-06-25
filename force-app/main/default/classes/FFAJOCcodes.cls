public class FFAJOCcodes{

    public void JOCcodesToPoppulates(Set<ID> WorkOrderIds){
        list<Workorder> FFAWorkordersToUpdate=new list<Workorder>();
        Map<string,Job_Code__mdt> JobcodesMap=new Map<string,Job_Code__mdt>();
        List<string> JobCombination=new List<string>();
        list<Workorder> JOCWorkorders=[SELECT ID,FFA_Code_Combination__c,FFA_JOC_3_Code_Combination__c,FFA_JOC1__c,FFA_JOC2__c,FFA_JOC3__c from Workorder WHERE ID IN:WorkOrderIds ];
        
        Job_Code__mdt[] JOBcodemdt = [Select MasterLabel,CodeCombination__c,JOC1__c,JOC2__c,JOC3__c from Job_Code__mdt ];
            for(Job_Code__mdt JOCcodes:JOBcodemdt){
                JobcodesMap.put(JOCcodes.CodeCombination__c.touppercase(),JOCcodes);
            }
        if(JobcodesMap!=null && !JOCWorkorders.isEmpty()){
            for(Workorder JOCcodes: JOCWorkorders){
                //For JObcode 1 && 2
                if(JOCcodes.FFA_Code_Combination__c!=null && JobcodesMap.containsKey(JOCcodes.FFA_Code_Combination__c.touppercase()) ){
                    JOCcodes.FFA_JOC1__c=JobcodesMap.get(JOCcodes.FFA_Code_Combination__c.touppercase()).JOC1__c!=null ? JobcodesMap.get(JOCcodes.FFA_Code_Combination__c.touppercase()).JOC1__c : ''; 
                    JOCcodes.FFA_JOC2__c=JobcodesMap.get(JOCcodes.FFA_Code_Combination__c.touppercase()).JOC2__c!=null ? JobcodesMap.get(JOCcodes.FFA_Code_Combination__c.touppercase()).JOC2__c : '';
                   
                    
                }
                else{
                JOCcodes.FFA_JOC1__c=''; 
                    JOCcodes.FFA_JOC2__c='';
                }
                if(JOCcodes.FFA_JOC_3_Code_Combination__c!=null && JobcodesMap.containsKey(JOCcodes.FFA_JOC_3_Code_Combination__c.touppercase()) ){
                    JOCcodes.FFA_JOC3__c=JobcodesMap.get(JOCcodes.FFA_JOC_3_Code_Combination__c.touppercase()).JOC3__c!=null ? JobcodesMap.get(JOCcodes.FFA_JOC_3_Code_Combination__c.touppercase()).JOC3__c : ''; 
                    
                }
                else{
                    JOCcodes.FFA_JOC3__c='';
                }
                 FFAWorkordersToUpdate.add(JOCcodes);
                
            }
         } 
         if(!FFAWorkordersToUpdate.isEmpty()){
             Update FFAWorkordersToUpdate;
         }   
    }
      
}