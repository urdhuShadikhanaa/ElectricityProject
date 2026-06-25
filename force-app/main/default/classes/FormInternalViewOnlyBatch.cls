/**
 * Batch job that re-sanitises all completed-synced original responses for the
 * given Form IDs. Uses Database.QueryLocator to avoid the 50,000 SOQL row
 * limit that a synchronous query would hit on forms with many responses.
 */
public without sharing class FormInternalViewOnlyBatch implements Database.Batchable<SObject> {

    private static final Integer SCOPE_SIZE = 10;

    private Set<Id> formIds;

    public FormInternalViewOnlyBatch(Set<Id> formIds) {
        this.formIds = formIds;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id
            FROM axsy_forms__Form_Response__c
            WHERE axsy_forms__Form__c IN :formIds
                AND axsy_forms__Status__c = 'Completed - Synced'
                AND Original_Form_Response__c = null
        ]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        Set<Id> responseIds = new Set<Id>();
        for (SObject s : scope) {
            responseIds.add(s.Id);
        }
        FormResponseSanitiserHandler.process(responseIds);
    }

    public void finish(Database.BatchableContext bc) {}

    public static void enqueue(Set<Id> formIds) {
        try {
            enqueueBatch(formIds);
        } catch (System.AsyncException e) {
            System.enqueueJob(new FormInternalViewOnlyQueueable(formIds));
        }
    }

    public static void enqueueBatch(Set<Id> formIds) {
        Database.executeBatch(
            new FormInternalViewOnlyBatch(formIds),
            SCOPE_SIZE
        );
    }
}