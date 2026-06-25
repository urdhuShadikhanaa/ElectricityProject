// NGMCP_DocLinksController.cls
public with sharing class NGMCP_DocLinksController {
    public class DocRow {
        @AuraEnabled public String code;                // optional category (e.g., QRF/ARF)
        @AuraEnabled public String label;               // display label
        @AuraEnabled public String fileName;            // clickable link text
        @AuraEnabled public String contentDocumentId;   // used to build shepherd URL
        @AuraEnabled public String url;                 // optional external/internal URL if not using Files
        @AuraEnabled public Boolean isImage;            // for inline preview
    }
    
    @AuraEnabled(cacheable=true)
    public static List<DocRow> getRows(Id parentId) {
        List<DocRow> rows = new List<DocRow>();
        if (parentId == null){
            return rows;
        }
        
        // Fetch Files linked to this record
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :parentId WITH USER_MODE
        ];
        if (links.isEmpty()){
            return rows;
        }
        
        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink l : links){
            docIds.add(l.ContentDocumentId);
        }
        
        List<ContentDocument> docs = [
            SELECT Id, Title, FileType
            FROM ContentDocument
            WHERE Id IN :docIds WITH USER_MODE
        ];
        
        for (ContentDocument cd : docs) {
            DocRow r = new DocRow();
            r.fileName = cd.Title;
            r.label = inferLabel(cd.Title);       // customize as needed
            r.code = inferCode(cd.Title);         // customize as needed
            r.contentDocumentId = cd.Id;
            r.isImage = isImageType(cd.FileType);
            rows.add(r);
        }
        
        // Sort rows with case-insensitive comparator (fixed: no compareToIgnoreCase)
        rows.sort(new DocRowComparator());
        return rows;
    }
    
    // -------- Helpers --------
    @TestVisible
    private static Boolean isImageType(String fileType) {
        if (fileType == null){
            return false;
        }
        String f = fileType.toLowerCase();
        return f == 'png' || f == 'jpg' || f == 'jpeg' || f == 'gif' || f == 'bmp' || f == 'tif' || f == 'tiff';
    }
    @TestVisible
    private static String inferLabel(String title) {
        if (String.isBlank(title)){
            return 'Document';
        }
        String t = title.toLowerCase();
        if (t.contains('qrf')) {
            return 'Quotation Reference Letter';
        }
        if (t.contains('arf')){
            return 'Asset Reference File';
        }
        return 'Document';
    }
    @TestVisible
    private static String inferCode(String title) {
        if (String.isBlank(title)) {
            return null;
        }
        String t = title.toLowerCase();
        if (t.contains('qrf')){
            return 'QRF';
        } 
        if (t.contains('arf')){
            return 'ARF';
        }
        return null;
    }
    
    // Case-insensitive comparator without compareToIgnoreCase
    public class DocRowComparator implements System.Comparator<DocRow> {
        public Integer compare(DocRow a, DocRow b) {
            String la = (a.label == null) ? '' : a.label;
            String lb = (b.label == null) ? '' : b.label;
            
            // Normalize to lowercase for case-insensitive comparison
            Integer cmp = la.toLowerCase().compareTo(lb.toLowerCase());
            if (cmp != 0) return cmp;
            
            String fa = (a.fileName == null) ? '' : a.fileName;
            String fb = (b.fileName == null) ? '' : b.fileName;
            
            return fa.toLowerCase().compareTo(fb.toLowerCase());
        }
    }
}