({
    doInit: function (component, event, helper) {
        component.set('v.columns', [
 {label: 'From', fieldName: 'linkName', type: 'url', 
            typeAttributes: {label: { fieldName: 'From__c' }, target: '_blank'}}, 
 {label: 'To', fieldName: 'To__c', type: 'int', wrapText: true ,editable: false, cellAttributes:{ 
     class: { fieldName: 'colortext' }}},
             {label: 'Tech Enginner Support', fieldName: 'Tech_Support__c', type: 'text', wrapText: true ,editable: false, cellAttributes:{ 
  class: { fieldName: 'colortext' }}}

            
        ]);
        helper.fetchData(component,event, helper);
        
    },

     createRecord : function (component, event, helper) {
         var TechEngineerSupport={Name: 'New Update','support__c': 'yes'};
    var createengineerEvent = $A.get("e.force:createRecord");
 if ( createengineerEvent ) {
        createengineerEvent.setParams({
            "entityApiName": "Tech_Engineer_Support__c",
"defaultFieldValues": TechEngineerSupport
                     
          });
createengineerEvent.fire();
        }
     }
})