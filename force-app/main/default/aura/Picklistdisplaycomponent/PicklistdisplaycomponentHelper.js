({
    allflangesizes : function(component) {
        var action = component.get("c.getAllflanges");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log('allValues -- >> ' + allValues);
                component.set("v.mydata", allValues);
            }
        });
        $A.enqueueAction(action);
    },
    
	flangesizeName : function(component) {
		var action = component.get("c.getFlangeName");
        var percent = component.find("PicklistId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log('allValues -- >> ' + allValues);
                component.set("v.pickName", allValues);
            }
        });
        $A.enqueueAction(action);
	}
})