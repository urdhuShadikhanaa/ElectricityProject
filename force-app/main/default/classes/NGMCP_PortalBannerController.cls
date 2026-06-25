public with sharing class NGMCP_PortalBannerController {
    @AuraEnabled(cacheable=true)
    public static List<NGMCP_Portal_Announcement_Config__mdt> getActiveNGMCPAnnouncements() {
        //if (!Schema.sObjectType.NGMCP_Portal_Announcement_Config__mdt.isAccessible()) {
         //   throw new AuraHandledException('You do not have access to view announcements.');
       // }
        // Date today = Date.today();

        // Query all metadata records
        List<NGMCP_Portal_Announcement_Config__mdt> activeBanners = [
           SELECT DeveloperName, NGMCP_Header__c, NGMCP_BannerMessage__c, NGMCP_Severity__c,
                  NGMCP_StartDate__c, NGMCP_EndDate__c, NGMCP_IsActive__c
           FROM NGMCP_Portal_Announcement_Config__mdt
           WHERE NGMCP_IsActive__c = TRUE
           AND (NGMCP_StartDate__c <= TODAY 
           AND NGMCP_EndDate__c >=TODAY ) WITH USER_MODE
       ];
        // Always return a valid list (never null)
        return activeBanners != null ? activeBanners : new List<NGMCP_Portal_Announcement_Config__mdt>();
    }
}