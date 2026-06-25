global with sharing class NGMCP_AccessCodeSchedular implements Schedulable{
    /*
    String cron1 = '0 0 * * * ?';
        System.schedule('Generate Mulesoft Token - Every 0th min', cron1, new NGMCP_AccessCodeSchedular());
        String cron2 = '0 10 * * * ?';
        System.schedule('Generate Mulesoft Token - Every 10th min', cron2, new NGMCP_AccessCodeSchedular());
        String cron3 = '0 20 * * * ?';
        System.schedule('Generate Mulesoft Token - Every 20th min', cron3, new NGMCP_AccessCodeSchedular());
        String cron4 = '0 30 * * * ?';
        System.schedule('Generate Mulesoft Token - Every 30th min', cron4, new NGMCP_AccessCodeSchedular());
		String cron5 = '0 40 * * * ?';
        System.schedule('Generate Mulesoft Token - Every 40th min', cron5, new NGMCP_AccessCodeSchedular());
        String cron6 = '0 50 * * * ?';
        System.schedule('Generate Mulesoft Token - Every 50th min', cron6, new NGMCP_AccessCodeSchedular());
    */
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new NGMCP_AccessCodeQueueable());
    }

}