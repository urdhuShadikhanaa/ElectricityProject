public without sharing class FormResponseSanitiserBatch implements Database.Batchable<Id> {

    private static final Integer SCOPE_SIZE = 10;

    private List<Id> responseIds;

    public FormResponseSanitiserBatch(Set<Id> responseIds) {
        this.responseIds = new List<Id>(responseIds);
    }

    public Iterable<Id> start(Database.BatchableContext bc) {
        return responseIds;
    }

    public void execute(Database.BatchableContext bc, List<Id> scope) {
        FormResponseSanitiserHandler.process(new Set<Id>(scope));
    }

    public void finish(Database.BatchableContext bc) {}

    public static void enqueue(Set<Id> responseIds) {
        try {
            Database.executeBatch(
                new FormResponseSanitiserBatch(responseIds),
                SCOPE_SIZE
            );
        } catch (System.AsyncException e) {
            System.enqueueJob(new FormResponseSanitiserQueueable(responseIds));
        }
    }
}