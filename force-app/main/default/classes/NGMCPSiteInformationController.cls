public with sharing class NGMCPSiteInformationController {
    // Wrapper class
    public class WOWrapper {
        @AuraEnabled public Id workOrderId;
        @AuraEnabled public Id siteId;
        @AuraEnabled public String title;
        @AuraEnabled public String name;
        @AuraEnabled public String phone;
        @AuraEnabled public String access;
        @AuraEnabled public String flag;
    }
    //  Fetch WorkOrder + Site fields
    @AuraEnabled(cacheable=true)
    public static WOWrapper getWorkOrderDetails(Id recordId) {
        try{
        WorkOrder wo = [
            SELECT Id,
            NGMCP_Site_contact_details__c,
            Site__c
            FROM WorkOrder
            WHERE Id = :recordId 
            LIMIT 1
        ];
        if (wo.Site__c == null) {
            throw new AuraHandledException('This Work Order has no linked Site.');
        }
        // Query the Site object (FFA_Site__c)
        FFA_Site__c siteRec = [
            SELECT Id,
            Name,
            FFA_Title__c,
            FFA_ContactTelephoneNumber__c,
            FFA_AccessInstructions__c
            FROM FFA_Site__c
            WHERE Id = :wo.Site__c
            LIMIT 1
        ];
        WOWrapper wrap = new WOWrapper();
        wrap.workOrderId = wo.Id;
        wrap.siteId = siteRec.Id;
        wrap.name = siteRec.Name;
        wrap.title = siteRec.FFA_Title__c;
        wrap.phone = siteRec.FFA_ContactTelephoneNumber__c;
        wrap.access = siteRec.FFA_AccessInstructions__c;
        wrap.flag = wo.NGMCP_Site_contact_details__c;
        return wrap;
        }
        catch(Exception e){
            System.debug('Error: '+e.getMessage() + ' @line: '+ e.getLineNumber());
            throw new AuraHandledException('Error: '+e.getMessage() + ' @line: '+ e.getLineNumber());
        }
    }
    @AuraEnabled
    public static string updateSiteDetails(FFA_Site__c input, Id workOrderId){
        // if (String.isBlank(input)) {
        //     throw new AuraHandledException('Invalid update request: empty payload.');
        // }
        
        try {
        //     // Parse dynamic JSON to a map
        //     Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(input);
            
        //     // Extract values from map
        //     String workOrderIdStr = '0WOdu000002hfYDGAY';
        //     String siteIdStr      = (String) data.get('siteId');
        //     String title          = (String) data.get('title');
        //     String name           = (String) data.get('name');
        //     String phone          = (String) data.get('phone');
        //     String access         = (String) data.get('access');
            
        //     // Basic validation
        //     if (String.isBlank(workOrderIdStr) || String.isBlank(siteIdStr)) {
        //         throw new AuraHandledException('Invalid update request: workOrderId or siteId missing.');
        //     }
            
        //     WorkOrder woUpdate = new WorkOrder(
        //         Id = (Id) workOrderIdStr,
        //     NGMCP_Site_contact_details__c = 'No' 
        //         );
        if (Schema.sObjectType.FFA_Site__c.isUpdateable()) {
            update input;
        }
            WorkOrder wo = [Select id, NGMCP_Site_contact_details__c 
                            From WorkOrder 
                           Where id =: workOrderId WITH USER_MODE];
            if(wo != null){
                if (Schema.sObjectType.WorkOrder.isUpdateable()) {
                    wo.NGMCP_Site_contact_details__c = 'No';
                    update wo;
                }
            }
            return 'SUCCESS';
        } catch (DmlException dmle) {
            throw new AuraHandledException('Update failed: ' + dmle.getMessage());
        } catch (Exception ex) {
            throw new AuraHandledException('Unexpected error: ' + ex.getMessage());
        }
    }
}