public with sharing class NGMServicePartnerController {
    @AuraEnabled(cacheable=true)
    public static String getServicePartnerStatus(String postCode) {
        // Null or empty check
        if (String.isBlank(postCode)) {
            System.debug('No postCode provided');
            return null;
        }
        
        // Clean the postcode (remove spaces and uppercase)
        String cleanedCode = postCode.replaceAll('\\s', '').toUpperCase();
        
        // Query Patch_Book__c (bulk-safe)
        List<Patch_Book__c> patches = [
            SELECT Choose_Status__c, Postal_Outcode__c
            FROM Patch_Book__c
            WHERE Postal_Outcode__c != null
        ];
        
        // Fallback if no records found
        if (patches.isEmpty()) {
            System.debug('No Patch_Book__c records found');
            return null;
        }
        
        // Compare cleaned postcodes in Apex (since we can’t use REPLACE in SOQL)
        for (Patch_Book__c p : patches) {
            if (p.Postal_Outcode__c != null) {
                String patchCode = p.Postal_Outcode__c.replaceAll('\\s', '').toUpperCase();
                if (patchCode == cleanedCode) {
                    System.debug('Match found: ' + p.Choose_Status__c);
                    return p.Choose_Status__c; // Return the status (Green, Amber, Red)
                }
            }
        }
        
        System.debug('No matching postcode found');
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isNGMUser() {
        // Fetch label value
        String ngmProfiles = Label.NGMCP_NGMUserProfiles;
        
        // Split and trim profile names
        List<String> ngmProfileList = new List<String>();
        for (String p : ngmProfiles.split(',')) {
            ngmProfileList.add(p.trim());
        }
        
        // Get the logged-in user's profile name
        String userProfile = [
            SELECT Profile.Name 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ].Profile.Name;
        
        // Return true if profile is in label list
        return ngmProfileList.contains(userProfile);
    }
    
}