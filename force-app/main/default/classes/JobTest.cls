/**
 * @description Test class for the Job class
 * @author Salesforce Developer
 * @since 2026-04-03
 */
@isTest
private class JobTest {
    
    /**
     * @description Tests the default constructor of the Job class
     */
    @isTest
    static void testJobDefaultConstructor() {
        // Instantiate a new Job object
        Job job = new Job();
        
        // Verify the object was created successfully
        System.assertNotEquals(null, job, 'Job object should not be null');
    }
    
    /**
     * @description Tests instantiation of Job class with all fields populated
     */
    @isTest
    static void testJobInstantiationWithValues() {
        // Create a new Job object with sample data
        Job job = new Job();
        job.ServiceProvider = 'Test Provider';
        job.SiteID = 'SITE001';
        job.MeterPointReferenceNumber = 'MPR001';
        job.RequestedAppointmentTimeslot = 'Morning';
        job.ShipperID = 'SHIP001';
        job.ShipperName = 'Test Shipper';
        job.MeterProvider = 'Meter Provider Inc';
        job.ServiceNotificationNumber = 'SN001';
        job.OperationNumber = 'OP001';
        job.JobCode = 'JOB001';
        job.JobDescription = 'Test Job Description';
        job.RequestCreatedDate = '2026-04-01';
        job.RequestCreatedTime = '09:00';
        job.RequestedAppointmentDate = '2026-04-05';
        job.RequestedAppointmentEndDate = '2026-04-05';
        job.UnplannedPolicyStartDate = '2026-04-01';
        job.UnplannedPolicyEndDate = '2026-04-30';
        job.JobNotes = 'Test notes for job';
        job.NewManufacturerName = 'Test Manufacturer';
        job.NewModelName = 'Test Model';
        job.NewMeterManufacturedYear = '2020';
        job.NewMeterMechanism = 'Mechanism Type';
        job.NewMeterPaymentType = 'Credit Card';
        job.NewNumberOfDials = '5';
        job.NewImperialMeInd = 'Y';
        job.NewMeasuringCap = '1000';
        job.NatureOfJob = 'Routine Maintenance';
        job.NotificationType = 'Email';
        
        // Verify all fields are set correctly
        System.assertEquals('Test Provider', job.ServiceProvider, 'ServiceProvider should match');
        System.assertEquals('SITE001', job.SiteID, 'SiteID should match');
        System.assertEquals('MPR001', job.MeterPointReferenceNumber, 'MeterPointReferenceNumber should match');
        System.assertEquals('Morning', job.RequestedAppointmentTimeslot, 'RequestedAppointmentTimeslot should match');
        System.assertEquals('SHIP001', job.ShipperID, 'ShipperID should match');
        System.assertEquals('Test Shipper', job.ShipperName, 'ShipperName should match');
        System.assertEquals('Meter Provider Inc', job.MeterProvider, 'MeterProvider should match');
        System.assertEquals('SN001', job.ServiceNotificationNumber, 'ServiceNotificationNumber should match');
        System.assertEquals('OP001', job.OperationNumber, 'OperationNumber should match');
        System.assertEquals('JOB001', job.JobCode, 'JobCode should match');
        System.assertEquals('Test Job Description', job.JobDescription, 'JobDescription should match');
        System.assertEquals('2026-04-01', job.RequestCreatedDate, 'RequestCreatedDate should match');
        System.assertEquals('09:00', job.RequestCreatedTime, 'RequestCreatedTime should match');
        System.assertEquals('2026-04-05', job.RequestedAppointmentDate, 'RequestedAppointmentDate should match');
        System.assertEquals('2026-04-05', job.RequestedAppointmentEndDate, 'RequestedAppointmentEndDate should match');
        System.assertEquals('2026-04-01', job.UnplannedPolicyStartDate, 'UnplannedPolicyStartDate should match');
        System.assertEquals('2026-04-30', job.UnplannedPolicyEndDate, 'UnplannedPolicyEndDate should match');
        System.assertEquals('Test notes for job', job.JobNotes, 'JobNotes should match');
        System.assertEquals('Test Manufacturer', job.NewManufacturerName, 'NewManufacturerName should match');
        System.assertEquals('Test Model', job.NewModelName, 'NewModelName should match');
        System.assertEquals('2020', job.NewMeterManufacturedYear, 'NewMeterManufacturedYear should match');
        System.assertEquals('Mechanism Type', job.NewMeterMechanism, 'NewMeterMechanism should match');
        System.assertEquals('Credit Card', job.NewMeterPaymentType, 'NewMeterPaymentType should match');
        System.assertEquals('5', job.NewNumberOfDials, 'NewNumberOfDials should match');
        System.assertEquals('Y', job.NewImperialMeInd, 'NewImperialMeInd should match');
        System.assertEquals('1000', job.NewMeasuringCap, 'NewMeasuringCap should match');
        System.assertEquals('Routine Maintenance', job.NatureOfJob, 'NatureOfJob should match');
        System.assertEquals('Email', job.NotificationType, 'NotificationType should match');
    }
    
    /**
     * @description Tests that Job class can be instantiated and fields can be accessed
     */
    @isTest
    static void testJobFieldAccess() {
        // Create a new Job object
        Job job = new Job();
        
        // Test setting and getting a few fields
        job.ServiceProvider = 'Test Provider';
        job.MeterPointReferenceNumber = 'MPR001';
        
        // Verify the values
        System.assertEquals('Test Provider', job.ServiceProvider, 'ServiceProvider should be set correctly');
        System.assertEquals('MPR001', job.MeterPointReferenceNumber, 'MeterPointReferenceNumber should be set correctly');
    }
    
    /**
     * @description Tests that Job class handles null values properly
     */
    @isTest
    static void testJobNullValues() {
        // Create a new Job object
        Job job = new Job();
        
        // Test with null values
        job.ServiceProvider = null;
        job.MeterPointReferenceNumber = null;
        
        // Verify the null values
        System.assertEquals(null, job.ServiceProvider, 'ServiceProvider should be null');
        System.assertEquals(null, job.MeterPointReferenceNumber, 'MeterPointReferenceNumber should be null');
    }
    
    /**
     * @description Tests that Job class handles empty string values properly
     */
    @isTest
    static void testJobEmptyStringValues() {
        // Create a new Job object
        Job job = new Job();
        
        // Test with empty string values
        job.ServiceProvider = '';
        job.MeterPointReferenceNumber = '';
        
        // Verify the empty string values
        System.assertEquals('', job.ServiceProvider, 'ServiceProvider should be empty string');
        System.assertEquals('', job.MeterPointReferenceNumber, 'MeterPointReferenceNumber should be empty string');
    }
}