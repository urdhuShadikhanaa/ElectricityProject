global class FFAScehduleFailedJobsReTrigger implements Schedulable {

   global void execute(SchedulableContext ctx) {
      FFAFailedJobsBatch scheduleFailedJobs = new FFAFailedJobsBatch();
        database.executeBatch(scheduleFailedJobs);
   }   
}