global with sharing class NGMCP_RequestUpdateScheduler implements Schedulable{
    /*String cron = '0 0 * * * ?';
        System.schedule('Request Update - Every 15 mins1', cron, new NGMCP_RequestUpdateScheduler());
        String cron1 = '0 15 * * * ?';
        System.schedule('Request Update - Every 15 mins1', cron1, new NGMCP_RequestUpdateScheduler());
        String cron2 = '0 30 * * * ?';
        System.schedule('Request Update - Every 15 mins1', cron2, new NGMCP_RequestUpdateScheduler());
        String cron3 = '0 45 * * * ?';
        System.schedule('Request Update - Every 15 mins1', cron3, new NGMCP_RequestUpdateScheduler());
    */
    
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new NGMCP_FetchRequestsFromMaximoQueuable());
    }
    
    /*

// Optional: unschedule existing job(s) by name
public static void unscheduleAll() {
for (CronTrigger ct : [SELECT Id, State, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Request Update - Every 15 mins']) {
System.abortJob(ct.Id);
}
}

*/
    
    
}