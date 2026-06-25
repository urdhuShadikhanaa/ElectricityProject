public with sharing class RequestSearchController {
    public RequestSearchController() {}

    @AuraEnabled(cacheable=true)
    public static List<RequestRowDTO> search(
        String mprn,
        String sr,
        String wo,
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
            whereClauses.add('Name LIKE :srLike');
        }
        if (String.isNotBlank(wo)) {
            woLike = '%' + wo.trim() + '%';
            whereClauses.add('(NGMCP_Job_Type__c LIKE :woLike OR NGMCP_Job_SubType__c LIKE :woLike)');
        }
        if (createdFromDate != null) {
            createdFromStart = DateTime.newInstance(createdFromDate, Time.newInstance(0, 0, 0, 0));
            whereClauses.add('CreatedDate >= :createdFromStart');
        }
        if (createdToDate != null) {
            createdToEnd = DateTime.newInstance(createdToDate, Time.newInstance(23, 59, 59, 999));
            whereClauses.add('CreatedDate <= :createdToEnd');
        }
        if (String.isNotBlank(shortCode)) {
            shortCodeVal = shortCode.trim();
            whereClauses.add('NGMCP_API_Callout__c = :shortCodeVal');
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
            '  Id, Name, CreatedDate, ' +
            '  NGMCP_MPRN__c, ' +
            '  RecordTypeId, RecordType.Name, ' +
            '  NGMCP_Job_Type__c, NGMCP_Job_SubType__c, '+ 
            '  NGMCP_API_Callout__c, ' +
            '  NGMCP_Callout_Status__c ' +
            'FROM NGMCP_Request__c' + whereSoql +
            ' ORDER BY CreatedDate DESC ' +
            ' LIMIT 50000';

        List<NGMCP_Request__c> listRecords = Database.query(baseSoql);
        System.debug('listRecords'+listRecords);
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
           
            dto.status = r.NGMCP_Callout_Status__c;
            dto.createdDate = (r.CreatedDate != null)
                ? Date.newInstance(r.CreatedDate.year(), r.CreatedDate.month(), r.CreatedDate.day())
                : null;
            dto.shortCode = r.NGMCP_API_Callout__c;
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
        @AuraEnabled public String status;
        @AuraEnabled public Date createdDate;
        @AuraEnabled public String shortCode;
    }
}