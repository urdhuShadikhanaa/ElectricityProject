public with sharing class NGMCP_UserDependentPicklistController {
    
    // Wrapper to surface hidden 'validFor' after JSON serialization of Schema.PicklistEntry
    public class PicklistEntryWrapper {
        public String label;
        public String value;
        public Boolean active;
        public Boolean defaultValue;
        public String validFor; // Base64 bitset mapping to controlling entries
    }
    
    // DTO for LWC or Aura components
    public class PicklistOption implements Comparable {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public PicklistOption(String l, String v) { label = l; value = v; }
        
        // Case-insensitive ordering for UI
        public Integer compareTo(Object o) {
            PicklistOption other = (PicklistOption) o;
            String a = (label == null) ? '' : label;
            String b = (other == null || other.label == null) ? '' : other.label;
            return a.toLowerCase().compareTo(b.toLowerCase());
        }
    }
    
    /**
     * Returns dependent picklist options (label/value pairs) for a controlling selection on User.
     *
     * @param controllingSelection  The controlling field selection to match (label or value).
     * @param matchByLabel          true to match by LABEL; false to match by VALUE.
     * @param includeInactiveValues Include inactive dependent entries? (usually false)
     */
    @AuraEnabled(cacheable=true)
    public static List<PicklistOption> getUserSupplierCodesForGroup(
    String controllingSelection,
    Boolean matchByLabel,
    Boolean includeInactiveValues
    ) {
        if (String.isBlank(controllingSelection)){
            return new List<PicklistOption>();
        } 
        
        // 1) Describe the User fields
        Schema.DescribeFieldResult ctrlDFR = User.Supplier_Group__c.getDescribe();
        Schema.DescribeFieldResult depDFR  = User.Supplier_Code__c.getDescribe();
        if (ctrlDFR.getType() != Schema.DisplayType.Picklist) {
            throw new AuraHandledException('Supplier_Group__c must be a picklist.');
        }
        
        // 2) Build index (label/value -> position) for controlling entries
        List<Schema.PicklistEntry> ctrlEntries = ctrlDFR.getPicklistValues();
        Map<String, Integer> ctrlKeyToIndex = new Map<String, Integer>();
        for (Integer i = 0; i < ctrlEntries.size(); i++) {
            String key = matchByLabel ? ctrlEntries[i].getLabel() : ctrlEntries[i].getValue();
            ctrlKeyToIndex.put(key, i);
        }
        
        if (!ctrlKeyToIndex.containsKey(controllingSelection)) {
            return new List<PicklistOption>();
        }
        Integer ctrlIndex = ctrlKeyToIndex.get(controllingSelection);
        
        // 3) Wrap dependent entries to expose 'validFor'
        List<PicklistEntryWrapper> depEntries =
            wrapPicklistEntries(depDFR.getPicklistValues());
        
        // 4) Filter dependent entries by validFor at the controlling index
        List<PicklistOption> options = new List<PicklistOption>();
        for (PicklistEntryWrapper dep : depEntries) {
            if (!includeInactiveValues && dep.active == false) continue;
            String bits = base64ToBits(dep.validFor);
            if (ctrlIndex < bits.length() && bits.substring(ctrlIndex, ctrlIndex + 1) == '1') {
                options.add(new PicklistOption(dep.label, dep.value));
            }
        }        
        options.sort();
        return options;
    }
    
    // ---- Helpers ----
    @TestVisible
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> entries) {
        String rawJson = JSON.serialize(entries);
        return (List<PicklistEntryWrapper>) JSON.deserialize(rawJson, List<PicklistEntryWrapper>.class);
    }
    
    // Convert Base64 (each char = 6 bits) into a contiguous bit string like "010011..."
    @TestVisible
    private static String base64ToBits(String base64) {
        if (String.isBlank(base64)) {
            return '';
        }
       final String alphabet = System.Label.NGMCP_SupplierGroup_Regex;
        String bits = '';
        for (Integer i = 0; i < base64.length(); i++) {
            String ch = base64.substring(i, i + 1);
            Integer idx = alphabet.indexOf(ch);
            // treat '=' padding (or unknown char) as 0s
            if (idx == -1) {
                bits += '000000';
            } else {
                bits += integerToBinary(idx, 6);
            }
        }
        return bits;
    }
    
    // Integer -> fixed width binary string (left padded with zeros)
    @TestVisible
    private static String integerToBinary(Integer n, Integer width) {
        String tmp = '';
        Integer v = (n == null) ? 0 : n;
        while (v > 0) {
            // Use Math.mod instead of '%' to avoid parser issues
            tmp = String.valueOf(Math.mod(v, 2)) + tmp;
            v = v / 2;
        }
        while (tmp.length() < width) tmp = '0' + tmp;
        if (tmp.length() > width) tmp = tmp.substring(tmp.length() - width);
        return tmp;
    }
    
    public class suplliercodeWrapper implements Comparable {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        
        public suplliercodeWrapper(String value, String label) {
            this.value = value;
            this.label = label;
        }
        
        // ONLY purpose: enable List.sort()
        public Integer compareTo(Object other) {
            suplliercodeWrapper o = (suplliercodeWrapper) other;
            
            String thisLabel  = label  == null ? '' : label;
            String otherLabel = o.label == null ? '' : o.label;
            
            // Apex-safe, case-insensitive comparison
            return thisLabel.toLowerCase().compareTo(otherLabel.toLowerCase());
        }
    }
    
    /**
     * Returns options based on the user's profile:
     *  - If Profile.Name == 'CRM'  -> return ALL active picklist values for User.Supplier_Code__c
     *  - Else                      -> return only the values currently selected on that user's field
     *
     * Uses current user (UserInfo.getUserId()).
     */
    
    @AuraEnabled(cacheable=true)
    public static List<suplliercodeWrapper> getUserSupplierCodeOptions() {
        Schema.DescribeFieldResult dfr = User.Supplier_Code__c.getDescribe();
        List<Schema.PicklistEntry> allEntries = dfr.getPicklistValues();

        Map<String, String> valueToLabel = new Map<String, String>();
        for (Schema.PicklistEntry pe : allEntries) {
            valueToLabel.put(pe.getValue(), pe.getLabel());
        }

        List<suplliercodeWrapper> options = new List<suplliercodeWrapper>();

        if (isCrmProfileUser()) {
            for (Schema.PicklistEntry e : allEntries) {
                if (e.isActive()) {
                    options.add(new suplliercodeWrapper(e.getValue(), e.getLabel()));
                }
            }
            options.sort();
            return options;
        }

        if (!Schema.sObjectType.User.fields.Supplier_Code__c.isAccessible()) {
            return options;
        }

        User u = [
            SELECT Supplier_Code__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            WITH USER_MODE
            LIMIT 1
        ];

        String raw = u.Supplier_Code__c;
        if (String.isBlank(raw)) {
            return options;
        }

        for (String token : raw.split(';')) {
            String v = token == null ? null : token.trim();
            if (!String.isBlank(v)) {
                String label = valueToLabel.containsKey(v)
                    ? valueToLabel.get(v)
                    : v;
                options.add(new suplliercodeWrapper(v, label));
            }
        }

        options.sort();
        return options;
    }

    @TestVisible
    private static Boolean isCrmProfileUser() {
        if (!Schema.sObjectType.Profile.isAccessible()) {
            return false;
        }

        List<Profile> profiles = [
            SELECT Name
            FROM Profile
            WHERE Id = :UserInfo.getProfileId()
            WITH USER_MODE
            LIMIT 1
        ];

        if (profiles.isEmpty() || String.isBlank(profiles[0].Name)) {
            return false;
        }

        return profiles[0].Name.equalsIgnoreCase(
            System.Label.NGMCP_CRMProfiles.trim()
        );
    }
    
    
}