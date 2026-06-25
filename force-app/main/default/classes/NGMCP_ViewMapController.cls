public with sharing class NGMCP_ViewMapController {
    @AuraEnabled(cacheable=true)
    public static List<Object> getSectionedFieldData(Id recordId) {
       
        // 1. Fetch the backend record → get its RecordTypeId
        NGMCP_Request__c req = [
            SELECT Id, RecordType.Name
            FROM NGMCP_Request__c
            WHERE Id = :recordId WITH USER_MODE
            LIMIT 1
        ];

        String recordTypeId = req.RecordType.Name;
        // 2. Fetch ALL CMDT rows for this record type
        List<NGMCP_View_WR__mdt> metaList = [
            SELECT Record_Type_Name__c, SectionName__c, All_fields__c
            FROM NGMCP_View_WR__mdt
            WHERE Record_Type_Name__c = 'Urgent Work Request' WITH USER_MODE
            ORDER BY SectionName__c
        ];

        // If no metadata rows
        if (metaList.isEmpty()) {
            return new List<Object>();
        }

        // 3. Gather ALL fields from all CMDT rows (clean)
        Set<String> allFields = new Set<String>();
        for (NGMCP_View_WR__mdt rec : metaList) {
            if (rec.All_fields__c != null) {
                for (String f : rec.All_fields__c.split(',')) {
                    if (!String.isBlank(f)) {
                        allFields.add(f.trim());
                    } 
                }
            }
        }
        if (allFields.isEmpty()) {
            return new List<Object>();
        }

        // 4. Build safe dynamic SOQL
        String fieldCsv = String.join(new List<String>(allFields), ',');
        String soql =
            'SELECT ' + fieldCsv +
            ' FROM NGMCP_Request__c WHERE Id = :recordId';
        // 5. Query backend record

        SObject sobj = Database.query(soql);
        // 6. Build final response (List of cards → each card has fields)
        List<Object> finalCards = new List<Object>();
        for (NGMCP_View_WR__mdt meta : metaList) {
            List<Object> fieldsForThisSection = new List<Object>();
            if (meta.All_fields__c != null) {
                for (String api : meta.All_fields__c.split(',')) {
                    if (String.isBlank(api)) continue;
                    api = api.trim();
                    Object val = null;
                    try {
                        val = sobj.get(api);
                    } catch (Exception e) {
                    }

                    fieldsForThisSection.add(new Map<String, Object>{
                        'api'   => api,
                        'label' => formatLabel(api),
                        'value' => val
                    });
                }
            }

            finalCards.add(new Map<String, Object>{
                'sectionName' => meta.SectionName__c,
                'fields'      => fieldsForThisSection
            });
        }

        return finalCards;

    }


    // Helper → Convert API Name to Pretty Label

    private static String formatLabel(String api) {
   if (String.isBlank(api)) return '';
   // Remove common prefixes like NGMCP_
   String clean = api;
   // Remove NGMCP_ prefix if present
   if (clean.startsWith('NGMCP_')) {
       clean = clean.substring(6); // remove first 6 chars
   }
   // Remove __c suffix
   clean = clean.replace('__c', '');
   // Replace remaining underscores with spaces
   clean = clean.replace('_', ' ');
   // Uppercase first letter only
   return clean.substring(0,1).toUpperCase() + clean.substring(1);
}
}