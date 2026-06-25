@isTest
public class NGMCP_Notification_HelperTest {
    
    @isTest
    static void testBuildEvent() {
        // Given
        String testMessage = 'Test notification message';
        Id testServiceAppointmentId = '0SA000000000001';
        Id testUserId = '005000000000001';
        
        // When
        NGMCP_Notification_Event__e event = NGMCP_Notification_Helper.buildEvent(
            testMessage,
            testServiceAppointmentId,
            testUserId
        );
        
        // Then
        System.assertNotEquals(null, event, 'Event should not be null');
        System.assertEquals(testMessage, event.NGMCP_Message__c, 'Message should match');
        System.assertEquals(testServiceAppointmentId, event.NGMCP_Service_Appointment_Id__c, 'Service Appointment ID should match');
        System.assertEquals(testUserId, event.NGMCP_User_Id__c, 'User ID should match');
    }
    
    @isTest
    static void testBuildEventWithNullValues() {
        // Given
        String testMessage = null;
        Id testServiceAppointmentId = null;
        Id testUserId = null;
        
        // When
        NGMCP_Notification_Event__e event = NGMCP_Notification_Helper.buildEvent(
            testMessage,
            testServiceAppointmentId,
            testUserId
        );
        
        // Then
        System.assertNotEquals(null, event, 'Event should not be null');
        System.assertEquals(testMessage, event.NGMCP_Message__c, 'Message should be null');
        System.assertEquals(testServiceAppointmentId, event.NGMCP_Service_Appointment_Id__c, 'Service Appointment ID should be null');
        System.assertEquals(testUserId, event.NGMCP_User_Id__c, 'User ID should be null');
    }
    
}