public with sharing class NGMCP_ComplaintController {
    @AuraEnabled
    public static String createComplaint(String answers, List<String> base64Files, List<String> fileNames) {
        try {
            /* Step 1: Deserialize input payload */
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(answers);
            
            /* Step 2: Extract Record Type */
            String recordTypeName = (String) payload.get('RecordType');
            payload.remove('RecordType');
            
            /* Step 3: Validate Record Type */
            Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
            
            if (String.isBlank(recordTypeName) || !rtMap.containsKey(recordTypeName)) {
                throw new AuraHandledException(
                    'Invalid or unavailable Case Record Type: ' + recordTypeName
                    );
            }
            
            /* Step 4: Deserialize Case fields */
            list<case> sclist = new list<case>();
            Case sc = (Case) JSON.deserialize(JSON.serialize(payload), Case.class);
            
            /* Step 5: Set controlled fields */
            sc.RecordTypeId = rtMap.get(recordTypeName).getRecordTypeId();
            sc.Origin       = 'Portal';
            sc.Subject      = 'Complaint Raised via Portal';
            sc.Status       = 'New';
            sclist.add(sc);
            if (Schema.sObjectType.case.isCreateable()) {
                Database.insert (sclist,true);
            }
            /* Step 6: Upload files (if any) */
            if (sc.Id != null && base64Files != null && fileNames != null && !base64Files.isEmpty() && base64Files.size() == fileNames.size()) {
                List<ContentVersion> contentVersions = new List<ContentVersion>();
                for (Integer i = 0; i < base64Files.size(); i++) {
                    contentVersions.add( new ContentVersion(
                        Title = fileNames[i],
                    PathOnClient = fileNames[i],
                    VersionData = EncodingUtil.base64Decode(base64Files[i]),
                    FirstPublishLocationId  = sc.Id)
                        );
                }
                
                if (Schema.sObjectType.ContentVersion.isCreateable()) {
                    insert contentVersions;
                }
            }
            case caseDetails = [SELECT Id, casenumber From case WHERE Id =: sc.Id WITH USER_MODE LIMIT 1];
            
            return caseDetails.CaseNumber;
        } catch (Exception e) {
            return null;
        }
    }
}