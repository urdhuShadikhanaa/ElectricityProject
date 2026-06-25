public with sharing class ngmcp_PortalFilesController {
 
    @AuraEnabled(cacheable=true)
    public static List<FileWrapper> getFiles() {
 
        // 1. Get accounts visible to the user (sharing applies automatically)
        List<Account> accessibleAccounts = [
            SELECT Id, Name
            FROM Account WITH USER_MODE
        ];
 
        if (accessibleAccounts.isEmpty()) {
            return new List<FileWrapper>();
        }
 
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accessibleAccounts) {
            accountIds.add(acc.Id);
        }
 
        // 2. Get files linked to those accounts
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId,
                   ContentDocument.Title,
                   ContentDocument.FileType,
                   LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :accountIds WITH USER_MODE
        ];
 
        // 3. Prepare response
        List<FileWrapper> result = new List<FileWrapper>();
        for (ContentDocumentLink cdl : links) {
            result.add(new FileWrapper(
                cdl.ContentDocumentId,
                cdl.ContentDocument.Title,
                cdl.ContentDocument.FileType

            ));
        }
 
        return result;
    }
 
    public class FileWrapper {
        @AuraEnabled public String documentId;
        @AuraEnabled public String title;
        @AuraEnabled public String fileType;
 
        public FileWrapper(String docId, String title, String type) {
            this.documentId = docId;
            this.title = title;
            this.fileType = type;
        }
    }
}