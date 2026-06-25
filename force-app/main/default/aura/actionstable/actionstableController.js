({
    doInit: function (component, event, helper) {
        component.set('v.columns', [
 {label: 'Action Date', fieldName: 'linkName', type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}}, 

             {label: 'Full Action', fieldName: 'Action__c', type: 'text', wrapText: true ,editable: true},
            {label: 'Action / Decision Log', fieldName: 'TYpe__c', type: 'text', wrapText: true ,editable: false},
            {label: '% Complete', fieldName: 'Complete__c', type: 'formattednumber' ,
            editable: true,
             cellAttributes:{ 
                 class: { fieldName: 'colortext' }}
        },
            {label: 'Assigned To:', fieldName: 'Assignee__c',type: 'lookup',editable: true,
            cellAttributes:{ 
                 class: { fieldName: 'colortext' }}},
            {label: 'Due Date', fieldName: 'Due_Date__c', type: 'date-local' ,sortable: 'true',editable: true,
            cellAttributes:{ 
                 class: { fieldName: 'colortext' }}}
        ]);
        helper.fetchData(component,event, helper);
        
    },
    handleSave: function (component, event, helper) {
        var draftValues = event.getParam('draftValues');
        var action = component.get("c.updateActions");
        action.setParams({"accList" : draftValues});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue(); 
             
                if(data === true){
                    helper.showSuccessToast(component,event, helper, 'success','action updated successfully');
                    $A.get('e.force:refreshView').fire();
                }else{
                    helper.showerrorToast(component,event, helper, 'error','please try again')
                }
            }
        });
        $A.enqueueAction(action);
    },
})