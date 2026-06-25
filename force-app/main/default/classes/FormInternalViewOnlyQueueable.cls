/**
 * Queueable fallback for FormInternalViewOnlyBatch. Used when the Apex flex
 * queue is full and Database.executeBatch() throws AsyncException, so the
 * triggering DML is not rolled back.
 *
 * Retries the batch enqueue rather than processing directly, because the
 * re-sanitisation path can involve thousands of responses that require
 * QueryLocator-based chunking.
 */
public without sharing class FormInternalViewOnlyQueueable implements Queueable {

    private Set<Id> formIds;

    public FormInternalViewOnlyQueueable(Set<Id> formIds) {
        this.formIds = formIds;
    }

    public void execute(QueueableContext ctx) {
        try {
            FormInternalViewOnlyBatch.enqueueBatch(formIds);
        } catch (System.AsyncException e) {
            System.debug(LoggingLevel.ERROR,
                'FormInternalViewOnlyQueueable: Batch retry failed for forms: ' + formIds);
        }
    }
}