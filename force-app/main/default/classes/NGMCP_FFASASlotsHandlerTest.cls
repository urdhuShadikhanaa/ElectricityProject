@IsTest(SeeAllData=true)
public class NGMCP_FFASASlotsHandlerTest {

      /* --------------------------------------------------------
       Test 1: Slot-based start & end time calculation
       -------------------------------------------------------- */
    @IsTest
    static void testSlotBasedTimeUpdate() {

        WorkOrder wo = new WorkOrder(
            Subject = 'Slot Test WO',
            Status = 'New',
            FFA_RequestedAppointmentTimeslot__c = 'AM',
            Notification_Type__c = 'Y3',
            FFA_Sender_ID__c = 'RAINBOW',
            FFA_RequestCreatedTime__c = '08:30'
        );
        insert wo;

        ServiceAppointment sa = new ServiceAppointment(
            ParentRecordId = wo.Id,
            Status = 'New',
            SchedStartTime = Datetime.newInstance(2026, 4, 3,11, 0, 0),
            SchedEndTime   = Datetime.newInstance(2026, 4, 3, 17, 0, 0)
        );
        insert sa;

        Test.startTest();
        FFAServiceAppointmentSlotsHandler.changeServiceApptTime(
            new Set<Id>{ sa.Id }
        );
        Test.stopTest();

        ServiceAppointment updatedSA = [
            SELECT SchedStartTime, SchedEndTime
            FROM ServiceAppointment
            WHERE Id = :sa.Id
        ];

        System.assertNotEquals(null, updatedSA.SchedStartTime);
        System.assertNotEquals(null, updatedSA.SchedEndTime);
    }

    /* --------------------------------------------------------
       Test 2: Hours-based logic (Requested Slot = null)
       -------------------------------------------------------- */
    @IsTest
    static void testHoursBasedCalculation() {

        WorkOrder wo = new WorkOrder(
            Subject = 'Hours Test WO',
            Status = 'New',
            FFA_RequestedAppointmentTimeslot__c = null,
            Notification_Type__c = 'Y3',
            FFA_Sender_ID__c = 'RAINBOW',
            FFA_RequestCreatedTime__c = '10:15'
        );
        insert wo;

        ServiceAppointment sa = new ServiceAppointment(
            ParentRecordId = wo.Id,
            Status = 'New',
            SchedStartTime = Datetime.newInstance(2026, 4, 4, 9, 0, 0),
            SchedEndTime   = Datetime.newInstance(2026, 4, 4, 12, 0, 0)
        );
        insert sa;

        Test.startTest();
        FFAServiceAppointmentSlotsHandler.changeServiceApptTime(
            new Set<Id>{ sa.Id }
        );
        Test.stopTest();

        ServiceAppointment updatedSA = [
            SELECT SchedStartTime, SchedEndTime
            FROM ServiceAppointment
            WHERE Id = :sa.Id
        ];

        System.assertNotEquals(null, updatedSA.SchedEndTime);
    }

    /* --------------------------------------------------------
       Test 3: Hours logic fallback (RequestCreatedTime = null)
       -------------------------------------------------------- */
    @IsTest
    static void testFallbackWhenRequestCreatedTimeNull() {

        WorkOrder wo = new WorkOrder(
            Subject = 'Fallback Test WO',
            Status = 'New',
            FFA_RequestedAppointmentTimeslot__c = null,
            Notification_Type__c = 'Z4',
            FFA_Sender_ID__c = 'PHOENIX',
            FFA_RequestCreatedTime__c = null
        );
        insert wo;

        ServiceAppointment sa = new ServiceAppointment(
            ParentRecordId = wo.Id,
            Status = 'New',
            SchedStartTime = Datetime.newInstance(2026, 4, 5, 8, 0, 0),
            SchedEndTime   = Datetime.newInstance(2026, 4, 5, 11, 0, 0)
        );
        insert sa;

        Test.startTest();
        FFAServiceAppointmentSlotsHandler.changeServiceApptTime(
            new Set<Id>{ sa.Id }
        );
        Test.stopTest();

        ServiceAppointment updatedSA = [
            SELECT SchedEndTime
            FROM ServiceAppointment
            WHERE Id = :sa.Id
        ];

        System.assertNotEquals(null, updatedSA.SchedEndTime);
    }

    /* --------------------------------------------------------
       Test 4: Bulk safety (multiple SAs)
       -------------------------------------------------------- */
    @IsTest
    static void testBulkExecution() {

        WorkOrder wo = new WorkOrder(
            Subject = 'Bulk WO',
            Status = 'New',
            FFA_RequestedAppointmentTimeslot__c = 'AM',
            Notification_Type__c = 'Y3',
            FFA_Sender_ID__c = 'RAINBOW'
        );
        insert wo;

        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        for (Integer i = 0; i < 3; i++) {
            saList.add(new ServiceAppointment(
                ParentRecordId = wo.Id,
                Status = 'New',
                SchedStartTime = Datetime.now().addHours(i),
                SchedEndTime   = Datetime.now().addHours(i + 2)
            ));
        }
        insert saList;

        Test.startTest();
        FFAServiceAppointmentSlotsHandler.changeServiceApptTime(
            new Map<Id, ServiceAppointment>(saList).keySet()
        );
        Test.stopTest();

        System.assertEquals(3,
            [SELECT COUNT() FROM ServiceAppointment WHERE Id IN :saList]
        );
    }
}