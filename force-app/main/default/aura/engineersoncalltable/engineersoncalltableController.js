({
    doInit: function (component, event, helper) {
        component.set('v.columns', [
 {label: 'Date', fieldName: 'linkName', type: 'url', 
            typeAttributes: {label: { fieldName: 'From__c' }, target: '_blank'}}, 

             {label: 'Standby Engineer', fieldName: 'Engineer_on_Call__c', type: 'text', wrapText: true ,editable: false, cellAttributes:{ 
                 class: { fieldName: 'colortext' }}}

            
        ]);
        helper.fetchData(component,event, helper);
        
    },

     createRecord : function (component, event, helper) {
    var createengineerEvent = $A.get("e.force:createRecord");
 
        createengineerEvent.setParams({
            "entityApiName": "Tech_Engineer_Support__c",
"defaultFieldValues": {
                    'Name' : 'New Update', 
    'support__c' :'no',
  
        }  });
createengineerEvent.fire();
        }
})