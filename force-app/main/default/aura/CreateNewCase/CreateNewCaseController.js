({
    init : function (component) {
        
        var flow = component.find("flowData1a");
      
        flow.startFlow("Create_New_Case");
    },
   removeCSS: function(cmp, event) {
        var cmpTarget = cmp.find('MainDiv');
        $A.util.removeClass(cmpTarget, 'slds-modal__container');
    }    

})