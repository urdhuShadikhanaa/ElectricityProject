( {
	submitrobotInfo : function(component, event, helper) {
        
        var isValidate = true;        
        var firstName = component.find('fName');        
        var firstNameVal = component.find('fName').get('v.value');        
        if($A.util.isUndefinedOrNull(firstNameVal) || $A.util.isUndefined(firstNameVal) || $A.util.isEmpty(firstNameVal)){
            firstName.set('v.errors',[{message:'Performance Month is Required'}]);
            isValidate = false;
        }else{
            firstName.set('v.errors',null);
        }        
        
        if(isValidate){
             var action = component.get('c.getRobot');
             var postData =  component.get('v.robotInfoAc');                
             action.setParams({'insertRobot': postData});
            
            action.setCallback(this, function(response) {            
            var state = response.getState();  
            if (state === 'SUCCESS') {                
                var stringItems = response.getReturnValue();
                component.set('v.robotItrt',stringItems);
                component.set('v.robotInfoAc', null);       
                
                //Show the success toast message
                var toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({
                    'title':'Success',
                    'type':'success',
                    'message':'Robot Entry submitted successfully.',                        
                });
                toastEvent.fire();   
                // Close the action panel
        var dismissActionPanel = $A.get('e.force:closeQuickAction');
        dismissActionPanel.fire();
            
            }
                
        }); 
        
        $A.enqueueAction(action);
            
        }
        
  

},

        })