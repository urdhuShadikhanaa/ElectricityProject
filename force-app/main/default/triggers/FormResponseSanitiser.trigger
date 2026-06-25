trigger FormResponseSanitiser on axsy_forms__Form_Response__c (after insert, after update, before delete) {

    // --- Before delete: clean up customer copies to prevent orphans ---
    if (Trigger.isDelete) {
        Set<Id> deletedOriginalIds = new Set<Id>();
        Set<Id> allDeletingIds = Trigger.oldMap.keySet();
        for (axsy_forms__Form_Response__c resp : Trigger.old) {
            // Only originals (not copies) can have customer copies
            if (resp.Original_Form_Response__c == null) {
                deletedOriginalIds.add(resp.Id);
            }
        }
        if (!deletedOriginalIds.isEmpty()) {
            // Exclude copies already in this delete batch to avoid recursive trigger
            List<axsy_forms__Form_Response__c> orphanedCopies = [
                SELECT Id
                FROM axsy_forms__Form_Response__c
                WHERE Original_Form_Response__c IN :deletedOriginalIds
                    AND Id NOT IN :allDeletingIds
            ];
            if (!orphanedCopies.isEmpty()) {
                delete orphanedCopies;
            }
        }
        return;
    }

    // --- After insert / after update: enqueue sanitisation ---
    Set<Id> eligibleIds = new Set<Id>();

    for (axsy_forms__Form_Response__c resp : Trigger.new) {
        if (resp.axsy_forms__Status__c != 'Completed - Synced'
            || resp.Customer_Visible__c != false
            || resp.Original_Form_Response__c != null) {
            continue;
        }
        // Only fire when Status__c *transitions* to 'Completed - Synced'.
        // On insert, there is no old value so always eligible.
        // On update, skip if status was already 'Completed - Synced' (e.g. only
        // Customer_Visible__c changed). This transition check also prevents
        // recursion when FormResponseSanitiserHandler sets Customer_Visible__c
        // = false on originals in the strip path — that DML re-fires this trigger
        // but Status__c is unchanged, so the record is filtered out here.
        if (Trigger.isInsert
            || Trigger.oldMap.get(resp.Id).axsy_forms__Status__c != 'Completed - Synced') {
            eligibleIds.add(resp.Id);
        }
    }

    if (eligibleIds.isEmpty()) {
        return;
    }

    // --- Early exit: handle no-strip forms directly in the trigger ---
    // Forms without Internal_View_Only__c don't need sanitisation — just mark the
    // original as customer-visible. This avoids consuming a batch queue slot for
    // every form completion on forms that don't use the feature.
    Set<Id> formIds = new Set<Id>();
    for (axsy_forms__Form_Response__c resp : Trigger.new) {
        if (eligibleIds.contains(resp.Id)) {
            formIds.add(resp.axsy_forms__Form__c);
        }
    }

    Set<Id> formsNeedingSanitisation = new Set<Id>();
    for (axsy_forms__Form__c f : [
        SELECT Id, Internal_View_Only__c FROM axsy_forms__Form__c WHERE Id IN :formIds
    ]) {
        if (String.isNotBlank(f.Internal_View_Only__c)) {
            formsNeedingSanitisation.add(f.Id);
        }
    }

    List<axsy_forms__Form_Response__c> noStripUpdates = new List<axsy_forms__Form_Response__c>();
    Set<Id> stripIds = new Set<Id>();

    for (Id respId : eligibleIds) {
        axsy_forms__Form_Response__c resp = Trigger.newMap.get(respId);
        if (formsNeedingSanitisation.contains(resp.axsy_forms__Form__c)) {
            stripIds.add(respId);
        } else {
            noStripUpdates.add(new axsy_forms__Form_Response__c(
                Id = respId, Customer_Visible__c = true
            ));
        }
    }

    // No-strip path: mark originals customer-visible and clean up stale copies.
    // The Customer_Visible__c = true update re-fires this trigger, but line 33
    // (Customer_Visible__c != false) filters it out since it's now true.
    if (!noStripUpdates.isEmpty()) {
        update noStripUpdates;

        Set<Id> noStripIds = new Set<Id>();
        for (axsy_forms__Form_Response__c r : noStripUpdates) {
            noStripIds.add(r.Id);
        }
        List<axsy_forms__Form_Response__c> staleCopies = [
            SELECT Id FROM axsy_forms__Form_Response__c
            WHERE Original_Form_Response__c IN :noStripIds
        ];
        if (!staleCopies.isEmpty()) {
            delete staleCopies;
        }
    }

    // Strip path: enqueue batch for forms that need sanitisation
    if (!stripIds.isEmpty()) {
        FormResponseSanitiserBatch.enqueue(stripIds);
    }
}