/**
 * Queueable fallback for FormResponseSanitiserBatch. Used when the Apex flex
 * queue is full and Database.executeBatch() throws AsyncException, so the
 * triggering DML is not rolled back.
 */
public without sharing class FormResponseSanitiserQueueable implements Queueable {

    private Set<Id> responseIds;

    public FormResponseSanitiserQueueable(Set<Id> responseIds) {
        this.responseIds = responseIds;
    }

    public void execute(QueueableContext ctx) {
        FormResponseSanitiserHandler.process(responseIds);
    }
}