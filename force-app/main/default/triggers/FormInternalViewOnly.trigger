trigger FormInternalViewOnly on axsy_forms__Form__c (after update) {
    Set<Id> changedFormIds = new Set<Id>();
    for (axsy_forms__Form__c form : Trigger.new) {
        axsy_forms__Form__c oldForm = Trigger.oldMap.get(form.Id);
        if (form.Internal_View_Only__c != oldForm.Internal_View_Only__c) {
            changedFormIds.add(form.Id);
        }
    }

    if (!changedFormIds.isEmpty()) {
        FormInternalViewOnlyHandler.process(changedFormIds);
    }
}