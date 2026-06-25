global class FFAScehduleFFADeleteInterfaceLogsTrigger implements Schedulable  {
    
    global void execute(SchedulableContext ctx) {
      FFADeleteIntefaceOldData scheduleDeleteInterfaceLogs = new FFADeleteIntefaceOldData();
        database.executeBatch(scheduleDeleteInterfaceLogs);
   }

}