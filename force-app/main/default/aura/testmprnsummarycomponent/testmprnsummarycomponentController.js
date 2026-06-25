({
    Search: function(component, event, helper) {
       component.set('v.searchResult', [{
                label: 'Work Order',
                fieldName: 'Work_Order__c',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'Work_Order__c'
                    },
                    target: '_blank'
                
                }
           
            
       }
                                      ]);
         var searchField = component.find('searchField');                                 
        var isValueMissing = searchField.get('v.validity').valueMissing;
        // if value is missing show error message and focus on field
        if(isValueMissing) {
            searchField.showHelpMessageIfInvalid();
            searchField.focus();
        }else{
          // else call helper function 
            helper.SearchHelper(component, event);
        }
                                       },
})