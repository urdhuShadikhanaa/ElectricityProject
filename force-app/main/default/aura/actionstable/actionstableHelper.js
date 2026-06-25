({
    fetchData: function (component,event,helper) {
        var action = component.get("c.getActions");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();

                for ( var i = 0; i < data.length; i++ ) {
                    

                    if ( data[i].indicator__c=="Green" ) {
                        
                        data[i].colortext='slds-text-color_success';
                    }   
                    else if( data[i].indicator__c=="Red") {
                
                        data[i].colortext='slds-text-color_error';
                    } 
                        else {
                           
                            data[i].colortext='slds-text-color_weak'; 
                        }
                } 
                                data.forEach(function(data){
data.linkName = '/'+ data.Id;
});
                
                component.set('v.data',data);
              
            }
        });
        $A.enqueueAction(action);
    },
    showSuccessToast: function(component,event,helper,type,message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": type,
            "message": message
        });
        toastEvent.fire();
    },
        showerrorToast: function(component,event,helper,type,message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Oops!",
            "type": type,
            "message": message
        });
        toastEvent.fire();
    }
})