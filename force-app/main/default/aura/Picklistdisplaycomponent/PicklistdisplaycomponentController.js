({
    doinit : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Class', fieldName: 'Class__c', type: 'text', cellAttributes: {alignment: 'left'}},
            {label: 'Size', fieldName: 'Size__c', type: 'text'},
            {label: 'Flange (Diameter)', fieldName: 'Flange_Diameter__c', type: 'text'},
            {label: 'PCD', fieldName: 'PCD__c', type: 'text'},
             {label: 'Number of Bolts', fieldName: 'Number_of_Bolts__c', type: 'text'},
            {label: 'Bolt Size', fieldName: 'Bolt_Size__c', type: 'text'},
            {label: 'Thickness (Cast Iron)', fieldName: 'Thickness_Cast_Iron__c', type: 'text'},
             {label: 'Thickness (Copper Alloy)', fieldName: 'Thickness_Copper_Alloy__c', type: 'text'},
            {label: 'Thickness (Steel)', fieldName: 'Thickness_Steel__c', type: 'text'}
        ]);
        
        helper.allflangesizes(component);
        helper.flangesizeName(component);
    },
    
    onControllerFieldChange : function(component, event, helper){
        var pickselected = component.find("PicklistId").get("v.value");
        console.log('pickselected--->>> ' + pickselected);
        var action = component.get("c.getflanges");
        action.setParams({cClass : pickselected});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log('allValues--->>> ' + JSON.stringify(allValues));
                component.set("v.mydata", allValues);
            }
        });
        $A.enqueueAction(action);
    }
})