({

    showToast : function(title, message, success) {
        let toastParams = {
            title: title,
            message: message, 
            type: success
        };
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    }
})