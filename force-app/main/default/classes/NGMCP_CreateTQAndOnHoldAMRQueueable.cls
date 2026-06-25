public with sharing class NGMCP_CreateTQAndOnHoldAMRQueueable implements Queueable, Database.AllowsCallouts{
     @TestVisible private static Boolean doChainJob = true;
	public class JobItem {
        public NGMCP_Request__c tq;
        public NGMCP_Request__c onHoldAMR;
        public String payload;
        
        public JobItem(NGMCP_Request__c tq, NGMCP_Request__c onHoldAMR, String payload) {
            this.tq = tq;
            this.onHoldAMR = onHoldAMR;
            this.payload = payload;
        }
    }
    
    public final List<JobItem> items;
    
    public NGMCP_CreateTQAndOnHoldAMRQueueable(List<JobItem> items) {
        this.items = items;
    }
    
    public void execute(QueueableContext qc){
        System.debug('items: '+items);
        List<NGMCP_OnHoldAMRQueueable.JobItem> onHolditems = new List<NGMCP_OnHoldAMRQueueable.JobItem>();
        for(JobItem ji : items){
            Id createdTQId = null;
            try{
               createdTQId = NGMCP_AMRIntegrationClass.createTQ(ji.tq);
               onHolditems.add(new NGMCP_OnHoldAMRQueueable.JobItem(createdTQId, ji.payload, ji.onHoldAMR));
            }
            catch(Exception tqCreateException){
                System.debug('NGMCP_CreateTQAndOnHoldAMRQueueable createTQ error: '+ tqCreateException.getMessage() + ' at line: ' + tqCreateException.getLineNumber());
            }
        }
        if(doChainJob){
        	System.enqueueJob(new NGMCP_OnHoldAMRQueueable(onHolditems));
        }
    }
}