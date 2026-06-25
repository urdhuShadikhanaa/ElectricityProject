public without sharing class NGMCP_HelpcentreController {
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getLibraryFiles(String libraryName) {
        System.debug('libraryName'+libraryName);
        // Step 1: Get Library Id
        ContentWorkspace workspace = [
            SELECT Id
            FROM ContentWorkspace
            WHERE Name = :libraryName 
            LIMIT 1
        ];
        System.debug('ContentWorkspace'+workspace);
        // Step 2: Fetch Files
        List<ContentDocument> docs = [
            SELECT Id, Title, FileType, CreatedDate, LatestPublishedVersionId
            FROM ContentDocument
            WHERE Id IN (
                SELECT ContentDocumentId
                FROM ContentWorkspaceDoc
                WHERE ContentWorkspaceId = :workspace.Id 
            )
        ];
        System.debug('docs'+docs);
        return docs;
    }
 }