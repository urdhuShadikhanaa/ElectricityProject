public with sharing class NGMCP_ServicePartnerController {
    @AuraEnabled(cacheable=true)
public static String getServicePartnerStatus(String postCode) {
    // Check null or empty input
    if (String.isBlank(postCode)) {
        return null;
    }

    // Clean and extract the outcode (anything before space)
    String cleanedInput = postCode.trim().toUpperCase();
    String inputOutcode = cleanedInput.contains(' ')
        ? cleanedInput.substringBefore(' ')
        : cleanedInput;


    // Query Patch_Book__c once (bulk-safe)
    List<Patch_Book__c> patches = [
        SELECT Choose_Status__c, Postal_Outcode__c
        FROM Patch_Book__c
        WHERE Postal_Outcode__c != null with user_mode
    ];

    if (patches.isEmpty()) {
        return null;
    }

    // Compare "outcode" portion for match
    for (Patch_Book__c p : patches) {
        if (p.Postal_Outcode__c != null) {
            String patchCode = p.Postal_Outcode__c.trim().toUpperCase();
            String patchOutcode = patchCode.contains(' ')
                ? patchCode.substringBefore(' ')
                : patchCode;

            if (patchOutcode == inputOutcode) {
                return p.Choose_Status__c;
            }
        }
    }

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
            WHERE Id = :UserInfo.getUserId()].Profile.Name;
        
        // Return true if profile is in label list
        return ngmProfileList.contains(userProfile);
    }
    
}