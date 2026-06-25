public with sharing class ngCaseAppointmentsController {
   @AuraEnabled(cacheable=true)
    public static List<Case> getLatestCases() {
        // Query the 5 most recent cases created by current user
        return [
            SELECT Id, Subject, Status/*,NG_Appointment_Date__c, 
                   NG_Appointment_Start_Time__c, NG_Appointment_End_Time__c*/
            FROM Case
            /*WHERE CreatedById = :UserInfo.getUserId()
            ORDER BY CreatedDate DESC*/
            LIMIT 5
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static User getCurrentUser() {
        return [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
    }
    
    @AuraEnabled(cacheable=true)
    public static FFA_NGV_Asset__c fetchAssetDetails(String mprnName) {
        List<MPRN_Summary__c> mprnList = [
            SELECT Id, Name, NGV_Asset__r.Id
            FROM MPRN_Summary__c
            WHERE Name = :mprnName
            LIMIT 1
        ];

        if (!mprnList.isEmpty()) {
            Id assetId = mprnList[0].NGV_Asset__r.Id;

            FFA_NGV_Asset__c asset = [
                SELECT Id, Name, FFA_Meter_Type__c, FFA_Asset_Type__c,
                       FFA_Location_Notes__c, FFA_Year_of_Manufacturer_Fix__c, FFA_Asset_Status__c,FFA_Model_Fix__c
                FROM FFA_NGV_Asset__c
                WHERE Id = :assetId
                LIMIT 1
            ];

            return asset;
        }
        return null;
    }

    @AuraEnabled(cacheable=false)
    public static FFA_NGV_Asset__c fetchAssetById(Id assetId) {
        System.debug('assetId >>'+assetId);
        return [
            SELECT Id, Name, FFA_Meter_Type__c, FFA_Asset_Type__c,
                   FFA_Location_Notes__c, FFA_Year_of_Manufacturer_Fix__c, FFA_Asset_Status__c, FFA_Model_Fix__c
            FROM FFA_NGV_Asset__c
            WHERE Id = :assetId
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Case> getUpcomingCases() {
        // Query the next 5 cases with Appointment Date in the future
        Date today = Date.today();
        return null /*[
            SELECT Id, CaseNumber, Subject, Status,CRM_De_appointment_effective_date__c, NG_Appointment_Date__c, 
                   NG_Appointment_Start_Time__c, NG_Appointment_End_Time__c,CRM_House_Name_Number_Site_Name__c
            FROM Case  WHERE CRM_House_Name_Number_Site_Name__c != '' LIMIT 5
            /*WHERE CreatedById = :UserInfo.getUserId()
              AND CRM_De_appointment_effective_date__c > :today
            ORDER BY CRM_De_appointment_effective_date__c ASC
       
        ]*/;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<WorkOrder> getTodaysAppointments() {
        return [SELECT Id, WorkOrderNumber, Subject, Status,ScheduledStart__c, ScheduledEnd__c, OwnerId FROM WorkOrder LIMIT 5];
        
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getScheduleAppointmentStats() {
        Map<String, Integer> stats = new Map<String, Integer>();
        
        // Fetch only the latest 50 case records
        List<Case> caseList = [
            SELECT Id, Status
            FROM Case
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];
        
        Integer totalCases = caseList.size();
        Integer scheduledCases = 0;
        Integer openCases = 0;
        Integer closedCases = 0;
        
        for (Case c : caseList) {
            if (c.Status == 'In Progress') {
                scheduledCases++;
            }
            if (c.Status == 'New') {
                openCases++;
            }
            if (c.Status == 'Closed') {
                closedCases++;
            }
        }
        
        stats.put('total', totalCases);
        stats.put('scheduled', scheduledCases);
        stats.put('openQueries', openCases);
        stats.put('closedQueries', closedCases);
        
        return stats;
    }
    

    
   /*     @AuraEnabled(cacheable=true)
    public static List<WorkOrder> fetchAMRByAssetId(Id assetId) {
        if (String.isBlank(assetId)) return new List<WorkOrder>();
        return [SELECT Id, WorkOrderNumber, Subject, Status, Priority, CreatedDate
                FROM WorkOrder
                WHERE AssetId = :assetId
                ORDER BY CreatedDate DESC
                LIMIT 50];
    }
*/

   /* @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> fetchAssetAttachments(Id assetId) {
        if (String.isBlank(assetId)) return new List<ContentDocumentLink>();
        return [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :assetId];
    }*/

    @AuraEnabled(cacheable=true)
    public static List<WorkOrder> getWorkOrdersByAssetId(Id assetId) {
        if (String.isBlank(assetId)) return new List<WorkOrder>();
        return [SELECT Id, WorkOrderNumber, Subject, Status, Priority, CreatedDate,FFA_UnplannedPolicyStartDate__c,
                FFA_UnplannedPolicyEndDate__c,FFA_CompletionDateAndTime__c
                FROM WorkOrder
                ORDER BY CreatedDate DESC
                LIMIT 5];
    }

  /*  @AuraEnabled(cacheable=true)
    public static List<WorkOrder> getRegulatorsByAssetId(Id assetId) {
      if (String.isBlank(assetId)) return new List<WorkOrder>();
        return [SELECT Id, WorkOrderNumber, Subject, Status, Priority, CreatedDate
                FROM WorkOrder
                WHERE AssetId = :assetId
                ORDER BY CreatedDate DESC
                LIMIT 50];
    }  */

     @AuraEnabled(cacheable=true)
    public static List<Case> getQueryLogsByAssetId(Id mprnSummaryId) {
        return null /*[
            SELECT Id, CaseNumber, Subject, Description, Status, Priority, CreatedDate, NG_Appointment_Date__c,
            NG_Appointment_End_Time__c,NG_Appointment_Start_Time__c
            FROM Case LIMIT 1 ]*/;
    }
    
     @AuraEnabled(cacheable=true)
    public static List<String> fetchAMRByAssetId(Id assetId) {
        return null/*[
            SELECT Id, Name,Timestamp__c, AMR_Serial_no__c,AMR_Model__c,AMR_Manufacturer__c
            FROM AMR__c
            WHERE NGV_Asset__c = :assetId
            ORDER BY Timestamp__c DESC LIMIT 5
        ]*/;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getRegulatorsByAssetId(Id assetId) {
        return null;/* [
            SELECT Id, Name, Manufacturer__c, Manufacturer_Serial_Number__c, Model_Number__c, Stream_Number__c
            FROM Regulator__c
            WHERE NGV_Asset__c = :assetId LIMIT 5
        ];*/
    }

     @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> fetchAssetAttachments(Id assetId) {
        return [
            SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title, ContentDocument.FileType, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :assetId
        ];
    }
    
     @AuraEnabled(cacheable=true)
    public static List<String> fetchAssetHistoryByAssetId(Id assetId) {
        return  null ;/*[
            SELECT Id, Device_Category__c, Installation_date__c, Meter_Manufacturer__c, Meter_Model__c, 
            Meter_Serial_Number__c, Meter_Status__c, Removal_date__c, NGV_Asset__c FROM Meter_History__c
            WHERE NGV_Asset__c = :assetId
        ];*/
    }
    
    
}