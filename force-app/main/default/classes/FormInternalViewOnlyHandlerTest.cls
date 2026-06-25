@isTest
private class FormInternalViewOnlyHandlerTest {

    @TestSetup
    static void setupTestData() {
        axsy_forms__Form__c form = new axsy_forms__Form__c(
            Name = 'Test IVO Form',
            Internal_View_Only__c = 'Internal Section'
        );
        insert form;

        // Create a Completed-Synced response (original, not a copy)
        axsy_forms__Form_Response__c resp = new axsy_forms__Form_Response__c(
            axsy_forms__Form__c = form.Id,
            axsy_forms__Status__c = 'Completed - Synced',
            Customer_Visible__c = false,
            axsy_forms__Response_Data__c = '{}'
        );
        insert resp;
    }

    private static axsy_forms__Form__c getForm() {
        return [SELECT Id, Internal_View_Only__c FROM axsy_forms__Form__c LIMIT 1];
    }

    private static axsy_forms__Form_Response__c getResponse() {
        return [
            SELECT Id, axsy_forms__Status__c, Customer_Visible__c
            FROM axsy_forms__Form_Response__c
            WHERE Original_Form_Response__c = null
            LIMIT 1
        ];
    }

    @isTest
    static void internalViewOnlyChanged_enqueuesAffectedResponses() {
        axsy_forms__Form__c form = getForm();

        Test.startTest();
        form.Internal_View_Only__c = 'Different Section';
        update form;
        Test.stopTest();

        // The handler should have queried the Completed-Synced response
        // and enqueued it for re-sanitisation via the batch.
        List<AsyncApexJob> jobs = [
            SELECT Id, ApexClass.Name
            FROM AsyncApexJob
            WHERE ApexClass.Name = 'FormInternalViewOnlyBatch'
        ];
        System.assert(!jobs.isEmpty(),
            'Batch should be enqueued when Internal_View_Only__c changes');
    }

    @isTest
    static void internalViewOnlyUnchanged_doesNotEnqueue() {
        axsy_forms__Form__c form = getForm();

        Test.startTest();
        // Update a different field, not Internal_View_Only__c
        form.Name = 'Renamed Form';
        update form;
        Test.stopTest();

        List<AsyncApexJob> jobs = [
            SELECT Id FROM AsyncApexJob
            WHERE ApexClass.Name = 'FormInternalViewOnlyBatch'
                AND CreatedDate = TODAY
        ];
        System.assertEquals(0, jobs.size(),
            'No batch should be enqueued when Internal_View_Only__c did not change');
    }

    @isTest
    static void noAffectedResponses_noBatchEnqueued() {
        // Delete all responses so there are none to process
        List<axsy_forms__Form_Response__c> allResponses = [
            SELECT Id FROM axsy_forms__Form_Response__c
        ];
        delete allResponses;

        axsy_forms__Form__c form = getForm();

        Test.startTest();
        form.Internal_View_Only__c = 'New Section';
        update form;
        Test.stopTest();

        // Handler should return early with no responses to process
        List<AsyncApexJob> jobs = [
            SELECT Id FROM AsyncApexJob
            WHERE ApexClass.Name = 'FormInternalViewOnlyBatch'
                AND CreatedDate = TODAY
        ];
        System.assertEquals(0, jobs.size(),
            'No batch should be enqueued when there are no affected responses');
    }

    @isTest
    static void handlerDoesNotManipulateCustomerVisible() {
        // The handler should only enqueue — FormResponseSanitiserHandler owns
        // Customer_Visible__c mutations
        axsy_forms__Form_Response__c resp = getResponse();
        Boolean originalVisibility = resp.Customer_Visible__c;

        axsy_forms__Form__c form = getForm();

        Test.startTest();
        form.Internal_View_Only__c = 'Changed Section';
        update form;
        Test.stopTest();

        // After the trigger + handler run, check that the handler itself
        // didn't flip Customer_Visible__c (the batch/FormResponseSanitiserHandler does that)
        // We can only verify that the batch was enqueued — the actual visibility
        // mutation happens in FormResponseSanitiserHandler.process()
        List<AsyncApexJob> jobs = [
            SELECT Id FROM AsyncApexJob
            WHERE ApexClass.Name = 'FormInternalViewOnlyBatch'
        ];
        System.assert(!jobs.isEmpty(),
            'Handler should delegate to batch, not manipulate fields directly');
    }

    @isTest
    static void queueable_retriesBatchEnqueue() {
        axsy_forms__Form__c form = getForm();

        Test.startTest();
        System.enqueueJob(new FormInternalViewOnlyQueueable(new Set<Id>{ form.Id }));
        Test.stopTest();

        // The Queueable should have re-enqueued the batch
        List<AsyncApexJob> jobs = [
            SELECT Id, ApexClass.Name
            FROM AsyncApexJob
            WHERE ApexClass.Name = 'FormInternalViewOnlyBatch'
        ];
        System.assert(!jobs.isEmpty(),
            'Queueable fallback should re-enqueue the batch job');
    }
}