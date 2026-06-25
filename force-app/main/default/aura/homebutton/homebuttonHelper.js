({
   
    navigate : function(component) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": '/lightning/o/Knowledge__kav/list?filterName=Recent'
        });
        urlEvent.fire();
    }
})