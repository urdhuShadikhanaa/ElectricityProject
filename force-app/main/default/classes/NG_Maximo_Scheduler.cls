global class NG_Maximo_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        MaximoAPIHandler.fetchUpdatesFromMaximo();
    }
}