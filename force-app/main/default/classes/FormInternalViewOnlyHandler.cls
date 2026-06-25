public class FormInternalViewOnlyHandler {

    public static void process(Set<Id> changedFormIds) {
        Integer count = [
            SELECT count()
            FROM axsy_forms__Form_Response__c
            WHERE axsy_forms__Form__c IN :changedFormIds
                AND axsy_forms__Status__c = 'Completed - Synced'
                AND Original_Form_Response__c = null
            LIMIT 1
        ];

        if (count == 0) {
            return;
        }

        FormInternalViewOnlyBatch.enqueue(changedFormIds);
    }
}