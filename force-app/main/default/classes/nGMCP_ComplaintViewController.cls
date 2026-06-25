public with sharing class nGMCP_ComplaintViewController{

    @AuraEnabled(cacheable=true)

    public static List<ContentDocumentLink> getFiles(Id recordId) {

        return [

            SELECT ContentDocumentId,

                   ContentDocument.Title,

                   ContentDocument.FileExtension,

                   ContentDocument.FileType,

                   ContentDocument.LatestPublishedVersionId

            FROM ContentDocumentLink

            WHERE LinkedEntityId = :recordId

        ];

    }

}