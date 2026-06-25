public with sharing class NGMCP_RequestSearchController {
    public NGMCP_RequestSearchController() {
        
    }
    @AuraEnabled(cacheable=true)
    public static List<RequestRowDTO> search(
        String mprn,
    String sr,
    String createdFrom, // <-- String
    String createdTo,   // <-- String
    String shortCode
    ) {
        // Parse incoming strings (format 'YYYY-MM-DD') to Date
        Date createdFromDate = parseDateSafe(createdFrom);
        Date createdToDate   = parseDateSafe(createdTo);
        
        // ---------- Build dynamic WHERE clause safely using bind variables ----------
        List<String> whereClauses = new List<String>();
        
        String mprnLike;
        String srLike;
        String woLike;
        DateTime createdFromStart;
        DateTime createdToEnd;
        String shortCodeVal;
        
        if (String.isNotBlank(mprn)) {
            mprnLike = '%' + mprn.trim() + '%';
            whereClauses.add('NGMCP_MPRN__c LIKE :mprnLike');
        }
        if (String.isNotBlank(sr)) {
            srLike = '%' + sr.trim() + '%';
            whereClauses.add('NGMCP_SR_Ticket__c  LIKE :srLike');
        }
        if (createdFromDate != null) {
            createdFromStart = DateTime.newInstance(createdFromDate, Time.newInstance(0, 0, 0, 0));
            whereClauses.add('CreatedDate >= :createdFromStart');
        }
        if (createdToDate != null) {
            createdToEnd = DateTime.newInstance(createdToDate, Time.newInstance(23, 59, 59, 999));
            whereClauses.add('CreatedDate <= :createdToEnd');
        }
        List<String> shortCodeList = new List<String>();
        if (!String.isBlank(shortCode)) {
            String sc = shortCode.trim();
            if (sc.contains(',')) {
                for (String token : sc.split('\\s*,\\s*')) {
                    if (!String.isBlank(token)) shortCodeList.add(token.trim());
                }
            } else {
                shortCodeList.add(sc);
            }
        }
        if (!shortCodeList.isEmpty()) {
            whereClauses.add('NGMCP_Supplier_Id__c IN :shortCodeList');
        }
        
        // Optional: guard invalid ranges (avoid returning empty silently)
        if (createdFromDate != null && createdToDate != null && createdFromDate > createdToDate) {
            // Swap or throw; here we swap for resilience
            Date tmp = createdFromDate;
            createdFromDate = createdToDate;
            createdToDate = tmp;
            createdFromStart = DateTime.newInstance(createdFromDate, Time.newInstance(0, 0, 0, 0));
            createdToEnd = DateTime.newInstance(createdToDate, Time.newInstance(23, 59, 59, 999));
        }
        
        String whereSoql = (whereClauses.isEmpty()) ? '' : (' WHERE ' + String.join(whereClauses, ' AND '));
        
        String baseSoql =
            'SELECT ' +
            '  Id, Name,NGMCP_SR_Ticket__c, CreatedDate, ' +
            '  NGMCP_MPRN__c, ' +
            '  RecordTypeId, RecordType.Name, ' +
            '  NGMCP_Job_Type__c, NGMCP_Job_SubType__c, '+
            '  NGMCP_API_Callout__c, ' +
            '  NGMCP_Status__c , NGMCP_Supplier_Id__c ' +
            'FROM NGMCP_Request__c' + whereSoql +
            ' ORDER BY CreatedDate DESC ' +
            ' LIMIT 50000';
        
        List<NGMCP_Request__c> listRecords = Database.query(baseSoql);
        List<RequestRowDTO> out = new List<RequestRowDTO>();
        for (NGMCP_Request__c r : listRecords) {
            RequestRowDTO dto = new RequestRowDTO();
            dto.id = r.Id;
            dto.name = r.Name;
            dto.nameUrl = '/lightning/r/NGMCP_Request__c/' + r.Id + '/view';
            dto.recordType = (r.RecordType != null) ? r.RecordType.Name : null;
            dto.recordTypeUrl = (r.RecordTypeId != null)
                ? ('/lightning/r/RecordType/' + r.RecordTypeId + '/view')
                : null;
            dto.mprn = r.NGMCP_MPRN__c;
            dto.jobcode = r.NGMCP_Job_Type__c;
            dto.jobSubCode = r.NGMCP_Job_SubType__c;
            dto.status = r.NGMCP_Status__c ;
            dto.shortCode = r.NGMCP_Supplier_Id__c;
            dto.srNumber = r.NGMCP_SR_Ticket__c;
            dto.createdDate = (r.CreatedDate != null)
                ? Date.newInstance(r.CreatedDate.year(), r.CreatedDate.month(), r.CreatedDate.day())
                : null;
            // dto.shortCode = r.NGMCP_API_Callout__c;
            out.add(dto);
        }
        
        return out;
    }
    
    // Parse 'YYYY-MM-DD' -> Date; returns null for blank/invalid
    private static Date parseDateSafe(String ymd) {
        if (String.isBlank(ymd)) return null;
        try {
            return Date.valueOf(ymd);
        } catch (Exception e) {
            return null;
        }
    }
    
    private static String deriveJobCode(NGMCP_Request__c r) {
        List<String> parts = new List<String>();
        if (String.isNotBlank(r.NGMCP_Job_Type__c)) parts.add(r.NGMCP_Job_Type__c.trim());
        if (String.isNotBlank(r.NGMCP_Job_SubType__c)) parts.add(r.NGMCP_Job_SubType__c.trim());
        return parts.isEmpty() ? null : String.join(parts, ' / ');
    }
    
    public class RequestRowDTO {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String nameUrl;
        @AuraEnabled public String recordType;
        @AuraEnabled public String recordTypeUrl;
        @AuraEnabled public String mprn;
        @AuraEnabled public String jobCode;
        @AuraEnabled public String jobSubCode;
        @AuraEnabled public String srNumber;
        @AuraEnabled public String status;
        @AuraEnabled public Date createdDate;
        @AuraEnabled public String shortCode;
    }
    
    @AuraEnabled(cacheable=true)
    public static Id getWorkOrderId(String workOrderNumber) {
        // Validate input
        if (String.isBlank(workOrderNumber)) {
            throw new AuraHandledException('Work Order Number cannot be blank.');
        }
        
        // Decide which field to use based on length
        String fieldName;
        if (workOrderNumber.length() == 8 && workOrderNumber.startsWith('0')) {
            fieldName = 'WorkOrderNumber';
        } else {
            fieldName = 'FFA_MeterPointReferenceNumber__c';
        }
        
        // Build dynamic SOQL
        String query = 'SELECT Id FROM WorkOrder WHERE ' + fieldName + ' = :workOrderNumber LIMIT 1';
        
        // Execute query
        List<SObject> results = Database.query(query);
        
        return results.isEmpty() ? null : (Id)results[0].get('Id');
    }

    
    @AuraEnabled 
public static List<ContentVersion> getParentAccountFiles(Id workOrderId) {
    List<ContentVersion> results = new List<ContentVersion>();

    // Defensive null guard
    if (workOrderId == null) {
        return results; // empty
    }

    // 1) Resolve parent account
    Id parentAccountId;
    try {
        WorkOrder wo = [
            SELECT Service_Provider__r.ParentId
            FROM WorkOrder
            WHERE Id = :workOrderId WITH USER_MODE
            LIMIT 1
        ];
        parentAccountId = (wo.Service_Provider__r != null) ? wo.Service_Provider__r.ParentId : null;
    } catch (Exception e) {
        return results; // empty on no access / not found
    }

    if (parentAccountId == null) {
        return results; // empty
    }

    // 2) Collect content document IDs linked to Parent Account via CDL
    Set<Id> contentDocIds = new Set<Id>();
    for (ContentDocumentLink cdl : [
        SELECT ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :parentAccountId WITH USER_MODE
    ]) {
        contentDocIds.add(cdl.ContentDocumentId);
    }

    if (contentDocIds.isEmpty()) {
        return results; // empty
    }

    // 3) Query latest ContentVersions
    results = [
        SELECT Id,
               Title,
               FileExtension,
               ContentDocumentId,
               IsLatest,
               ContentDocument.LatestPublishedVersionId
        FROM ContentVersion
        WHERE ContentDocumentId IN :contentDocIds
          AND IsLatest = true WITH USER_MODE
        ORDER BY Title ASC
        LIMIT 500
    ];

    return results;
}

    @TestVisible
    private static Set<Id> collectParentAccountContentDocIds(Id parentAccountId) {
        Set<Id> contentDocIds = new Set<Id>();
        for (ContentDocumentLink cdl : [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :parentAccountId WITH USER_MODE
        ]) {
            contentDocIds.add(cdl.ContentDocumentId);
        }
        return contentDocIds;
    }


    @AuraEnabled(cacheable=true)
    public static List<WorkOrderRowDTO> workOrdersearch(
        String mprn,
    String wo,
    String createdFrom, // 'YYYY-MM-DD'
    String createdTo,   // 'YYYY-MM-DD'
    String shortCode
    ) {
        // Parse incoming strings ('YYYY-MM-DD') to Date
        Date createdFromDate = parseDateSafe(createdFrom);
        Date createdToDate   = parseDateSafe(createdTo);
        
        // ---------- Build dynamic WHERE clause safely using bind variables ----------
        List<String> whereClauses = new List<String>();
        
        // Bind variables
        String mprnLike;
        String woLike;
        DateTime createdFromStart;
        DateTime createdToEnd;
        String shortCodeVal;
        
        if (String.isNotBlank(mprn)) {
            mprnLike = '%' + mprn.trim() + '%';
            whereClauses.add('FFA_MeterPointReferenceNumber__c LIKE :mprnLike');
        }
        if (String.isNotBlank(wo)) {
            // Reuse "sr" param to search WorkOrderNumber
            woLike = '%' + wo.trim() + '%';
            whereClauses.add('WorkOrderNumber LIKE :woLike');
        }
        if (createdFromDate != null) {
            createdFromStart = DateTime.newInstance(createdFromDate, Time.newInstance(0, 0, 0, 0));
            whereClauses.add('CreatedDate >= :createdFromStart');
        }
        if (createdToDate != null) {
            createdToEnd = DateTime.newInstance(createdToDate, Time.newInstance(23, 59, 59, 999));
            whereClauses.add('CreatedDate <= :createdToEnd');
        }
        List<String> shortCodeList = new List<String>();
        if (!String.isBlank(shortCode)) {
            String sc = shortCode.trim();
            if (sc.contains(',')) {
                for (String token : sc.split('\\s*,\\s*')) {
                    if (!String.isBlank(token)) shortCodeList.add(token.trim());
                }
            } else {
                shortCodeList.add(sc);
            }
        }
        if (!shortCodeList.isEmpty()) {
            whereClauses.add('FFA_ShipperID__c IN :shortCodeList');
        }
        
        
        // Optional: guard invalid ranges (swap if from > to)
        if (createdFromDate != null && createdToDate != null && createdFromDate > createdToDate) {
            Date tmp = createdFromDate;
            createdFromDate = createdToDate;
            createdToDate = tmp;
            createdFromStart = DateTime.newInstance(createdFromDate, Time.newInstance(0, 0, 0, 0));
            createdToEnd = DateTime.newInstance(createdToDate, Time.newInstance(23, 59, 59, 999));
        }
        
        String whereSoql = (whereClauses.isEmpty()) ? '' : (' WHERE ' + String.join(whereClauses, ' AND '));
        
        // Include Meter Point in SELECT so we can populate "mprn" in DTO
        String baseSoql =
            'SELECT ' +
            '  Id, WorkOrderNumber, Status, ' +
            '  FFA_JobCode__c, FFA_JobDescription__c, ' +
            '  FFA_ShipperID__c, FFA_ShipperName__c, ' +
            '  FFA_MeterPointReferenceNumber__c, ' +
            '  CreatedDate ' + 
            'FROM WorkOrder' + whereSoql +
            ' ORDER BY CreatedDate DESC ' + 
            ' LIMIT 50000';
        
        List<WorkOrder> listRecords = Database.query(baseSoql);
        
        List<WorkOrderRowDTO> out = new List<WorkOrderRowDTO>();
        for (WorkOrder w : listRecords) {
            WorkOrderRowDTO dto = new WorkOrderRowDTO();
            dto.id = w.Id;
            // Match your grid's "name" column to display WorkOrderNumber as the primary text
            dto.WorkOrderNumber = w.WorkOrderNumber;
            dto.nameUrl = '/lightning/r/WorkOrder/' + w.Id + '/view';
            // MPRN from WorkOrder (custom field)
            dto.mprn = w.FFA_MeterPointReferenceNumber__c;
            
            // Job code & subcode mapping
            dto.jobCode = w.FFA_JobCode__c;
            dto.jobDescription = w.FFA_JobDescription__c;
            
            // Status & supplier/shipper mapping
            dto.status = w.Status;
            dto.SupplierId = w.FFA_ShipperID__c;
            dto.SupplierName = w.FFA_ShipperName__c;
            
            // CreatedDate -> Date only (like your request DTO)
            dto.createdDate = (w.CreatedDate != null)
                ? Date.newInstance(w.CreatedDate.year(), w.CreatedDate.month(), w.CreatedDate.day())
                : null;
            
            out.add(dto);
        }
        
        return out;
    }
    
    
    // Optional: derive a composite job string (if you need a single column)
    private static String deriveJobCode(WorkOrder w) {
        List<String> parts = new List<String>();
        if (String.isNotBlank(w.FFA_JobCode__c)) parts.add(w.FFA_JobCode__c.trim());
        if (String.isNotBlank(w.FFA_JobDescription__c)) parts.add(w.FFA_JobDescription__c.trim());
        return parts.isEmpty() ? null : String.join(parts, ' / ');
    }
    
    public class WorkOrderRowDTO {
        @AuraEnabled public String id;
        @AuraEnabled public String WorkOrderNumber;           // WorkOrderNumber
        @AuraEnabled public String nameUrl;        // /lightning/r/WorkOrder/{Id}/view
        @AuraEnabled public String mprn;           // FFA_MeterPointReferenceNumber__c
        @AuraEnabled public String jobCode;        // FFA_JobCode__c
        @AuraEnabled public String jobDescription;     // FFA_JobDescription__c
        @AuraEnabled public String status;         // Status
        @AuraEnabled public Date   createdDate;    // Date only
        @AuraEnabled public String SupplierId;      // FFA_ShipperID__c
        @AuraEnabled public String SupplierName;    // FFA_ShipperName__c (if you need to show it)
    }
    
}