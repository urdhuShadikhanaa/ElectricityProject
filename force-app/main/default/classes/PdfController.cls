public with sharing class PdfController {
   
 @AuraEnabled
    public static Id uploadFile(String base64Data, String filename) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.Title = filename;
        cv.PathOnClient = filename;
        insert cv;

        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        return cv.ContentDocumentId;
    }

    @AuraEnabled
    public static String getFileUrl(Id contentDocumentId) {
        return [SELECT FileExtension, Title FROM ContentDocument WHERE Id = :contentDocumentId].Title;
    }


}