({
    handleSelect : function (component, event, helper) {
        var stepName = event.getParam("detail").value;
        component.set("v.PicklistField.Part_Low_Risk__c", stepName);
        
        component.find("record").saveRecord($A.getCallback(function(response) {
            if (response.state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            }
        }));
    }
    
})