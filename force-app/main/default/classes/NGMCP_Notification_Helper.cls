public class NGMCP_Notification_Helper {

    // Build Event
    public static NGMCP_Notification_Event__e buildEvent(
        String message,
        Id serviceAppointmentId,
        Id userId
    ) {
        return new NGMCP_Notification_Event__e(
            NGMCP_Message__c = message,
            NGMCP_Service_Appointment_Id__c = serviceAppointmentId,
            NGMCP_User_Id__c = userId
        );
    }
}