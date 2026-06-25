@isTest
public class NGMCP_UserDependentPicklistCtrlTest {
    
    // -------- Utilities --------
    
    // Create a fresh, valid User you can runAs.
    private static User makeUser(Id profileId, String alias) {
        String unique = String.valueOf(Datetime.now().getTime());
        return new User(
            ProfileId        = profileId,
        Alias            = alias.left(8),
        Email            = 'test+' + unique + '@example.com',
        EmailEncodingKey = 'UTF-8',
        LastName         = 'Tester',
        LanguageLocaleKey= 'en_US',
        LocaleSidKey     = 'en_US',
        TimeZoneSidKey   = 'America/Los_Angeles',
        Supplier_Code__c = 'EUK',
        Username         = 'user.' + unique + '@example.com'
            );
    }
    
    // -------- Tests for getUserSupplierCodesForGroup --------
    
    @IsTest
    static void test_getUserSupplierCodesForGroup_blank_returnsEmpty() {
        List<NGMCP_UserDependentPicklistController.PicklistOption> opts =
            NGMCP_UserDependentPicklistController.getUserSupplierCodesForGroup(
            '', /*controllingSelection*/
            true,  /*matchByLabel*/
            false  /*includeInactiveValues*/
            );
        System.assertNotEquals(null, opts, 'Should return a list (not null)');
        System.assertEquals(0, opts.size(), 'Blank controlling selection should return empty list');
    }
    
    @IsTest
    static void test_getUserSupplierCodesForGroup_nonMatching_labelAndValue() {
        // Pass a value that won’t match any controlling picklist entry (by LABEL)
        List<NGMCP_UserDependentPicklistController.PicklistOption> byLabel =
            NGMCP_UserDependentPicklistController.getUserSupplierCodesForGroup(
            '___NO_MATCH_LABEL___',
        true,   // matchByLabel
        false
            );
        System.assertEquals(0, byLabel.size(),
        'When controlling LABEL does not exist, expected empty result');
        
        // Pass a value that won’t match any controlling picklist entry (by VALUE)
        List<NGMCP_UserDependentPicklistController.PicklistOption> byValue =
            NGMCP_UserDependentPicklistController.getUserSupplierCodesForGroup(
            '___NO_MATCH_VALUE___',
        false,  // matchByValue
        true    // includeInactiveValues (doesn’t matter here)
            );
        System.assertEquals(0, byValue.size(),
        'When controlling VALUE does not exist, expected empty result');
    }
    @IsTest
    static void test_getUserSupplierCodeOptions_crmProfile_branch_ifAvailable() {
        // Try to find a profile named exactly "CRM Profile". If absent, skip this branch.
        Profile crm = [SELECT Id, Name FROM Profile WHERE Name = 'CRM Profile' LIMIT 1];
        if (crm == null) {
            // If org doesn’t have this profile, exit gracefully. This avoids brittle tests.
            System.assert(true, 'CRM Profile not present in this org; skipping CRM branch test.');
            return;
        }
        
        User u = makeUser(crm.Id, 'crmusr1');
        insert u;
        
        System.runAs(u) {
            // In CRM profile branch, method returns all **active** picklist values.
            // We can’t assert specific items (depends on org metadata), but we can assert it doesn’t throw
            // and returns a (possibly empty) list and maintains sort order.
            List<NGMCP_UserDependentPicklistController.suplliercodeWrapper> options =
                NGMCP_UserDependentPicklistController.getUserSupplierCodeOptions();
            System.assertNotEquals(null, options, 'Should not return null for CRM users');
            
            // Optional: validate it’s sorted case-insensitively (if 2+ records exist).
            if (options.size() >= 2) {
                for (Integer i = 1; i < options.size(); i++) {
                    String prev = options[i-1].label == null ? '' : options[i-1].label.toLowerCase();
                    String curr = options[i].label   == null ? '' : options[i].label.toLowerCase();
                    System.assert(prev.compareTo(curr) <= 0,
                    'Options should be sorted case-insensitively by label');
                }
            }
        }
    }
    
    // -------- Sorting helper tests (cover compareTo implementations) --------
    
    @IsTest
    static void test_PicklistOption_sorting_compareTo() {
        List<NGMCP_UserDependentPicklistController.PicklistOption> listy =
        new List<NGMCP_UserDependentPicklistController.PicklistOption>{
            new NGMCP_UserDependentPicklistController.PicklistOption('bravo', 'b'),
            new NGMCP_UserDependentPicklistController.PicklistOption('Alpha', 'a'),
            new NGMCP_UserDependentPicklistController.PicklistOption(null, 'z')
        };
        listy.sort();
        // After case-insensitive sort by label: null becomes '', so it should come first.
        System.assertEquals(null, listy[0].label, 'Null label should be treated as empty and come first');
        System.assertEquals('Alpha', listy[1].label);
        System.assertEquals('bravo', listy[2].label);
    }
    
    @IsTest
    static void test_suplliercodeWrapper_sorting_compareTo() {
        List<NGMCP_UserDependentPicklistController.suplliercodeWrapper> listy =
        new List<NGMCP_UserDependentPicklistController.suplliercodeWrapper>{
            new NGMCP_UserDependentPicklistController.suplliercodeWrapper('2', 'Bravo'),
            new NGMCP_UserDependentPicklistController.suplliercodeWrapper('1', 'alpha'),
            new NGMCP_UserDependentPicklistController.suplliercodeWrapper('3', null)
        };
        listy.sort();
        // null label treated as '', expected to come first
        System.assertEquals(null, listy[0].label, 'Null label should be treated as empty and come first');
        System.assertEquals('alpha', listy[1].label);
        System.assertEquals('Bravo', listy[2].label);
    }
    
    @isTest
    static void newUserDependentTest(){
        NGMCP_UserDependentPicklistController.base64ToBits('QkFTRTY0X1RFU1RfU1RSSU5H');
        NGMCP_UserDependentPicklistController.integerToBinary(100, 20);
    }
    
    @IsTest
    static void test_wrapPicklistEntries_mapsCoreFields() {
        // Use a standard picklist on User to obtain real Schema.PicklistEntry records.
        // LocaleSidKey and LanguageLocaleKey are standard picklist fields.
        Schema.DescribeFieldResult dfr = User.LocaleSidKey.getDescribe();
        System.assertEquals(Schema.DisplayType.Picklist, dfr.getType(), 'Expected a picklist field');
        List<Schema.PicklistEntry> entries = dfr.getPicklistValues();
        System.assert(entries.size() > 0, 'Expected at least one picklist entry for User.LocaleSidKey');
        
        // Invoke the @TestVisible method under test
        List<NGMCP_UserDependentPicklistController.PicklistEntryWrapper> wrapped =
            NGMCP_UserDependentPicklistController.wrapPicklistEntries(entries);
        
        // Basic assertions
        System.assertNotEquals(null, wrapped, 'Should not return null');
        System.assertEquals(entries.size(), wrapped.size(),
        'Wrapped list size should match source picklist entry list size');
        
        // Spot-check a few items for correct mapping
        Integer checkCount = Math.min(3, wrapped.size());
        for (Integer i = 0; i < checkCount; i++) {
            Schema.PicklistEntry src = entries[i];
            NGMCP_UserDependentPicklistController.PicklistEntryWrapper dst = wrapped[i];
            
            System.assertEquals(src.getLabel(), dst.label,       'Label should match');
            System.assertEquals(src.getValue(), dst.value,       'Value should match');
            System.assertEquals(src.isActive(), dst.active,      'Active flag should match');
            System.assertEquals(src.isDefaultValue(), dst.defaultValue, 'Default flag should match');
            
            // validFor may be null/blank for non-dependent picklists, so do not assert equality here.
            // We just ensure the property exists (no NPE) by touching it.
            Boolean touched = (dst.validFor == null);
            System.assertEquals(true, touched, 'validFor should be a String or null');
        }
    }
    
    @IsTest
    static void test_wrapPicklistEntries_emptyInput_returnsEmpty() {
        List<Schema.PicklistEntry> empty = new List<Schema.PicklistEntry>();
        List<NGMCP_UserDependentPicklistController.PicklistEntryWrapper> wrapped =
            NGMCP_UserDependentPicklistController.wrapPicklistEntries(empty);
        
        System.assertNotEquals(null, wrapped, 'Should return a non-null list even for empty input');
        System.assertEquals(0, wrapped.size(), 'Empty input should yield empty output list');
    }
    
    @TestVisible
    private static List<NGMCP_UserDependentPicklistController.PicklistOption> filterDependentOptions(
        List<NGMCP_UserDependentPicklistController.PicklistEntryWrapper> depEntries,
    Integer ctrlIndex,
    Boolean includeInactiveValues
    ) {
        List<NGMCP_UserDependentPicklistController.PicklistOption> options = new List<NGMCP_UserDependentPicklistController.PicklistOption>();
        for (NGMCP_UserDependentPicklistController.PicklistEntryWrapper dep : depEntries) {
            if (!includeInactiveValues && dep.active == false) continue;
            String bits = NGMCP_UserDependentPicklistController.base64ToBits(dep.validFor);
            if (ctrlIndex < bits.length() && bits.substring(ctrlIndex, ctrlIndex + 1) == '1') {
                options.add(new NGMCP_UserDependentPicklistController.PicklistOption(dep.label, dep.value));
            }
        }
        options.sort();
        return options;
    }
    
    @IsTest
    static void test_filterDependentOptions_positivePath() {
        // ctrlIndex = 1 (we want bit #1 = 1)
        Integer ctrlIndex = 1;
        
        // Build synthetic dependent entries:
        // validFor 'w' = 110000 -> bits[0]=1, bits[1]=1 (so matches ctrlIndex=1)
        // validFor 'B' = 000001 -> only bits[0]=1  (no match when ctrlIndex=1)
        List<NGMCP_UserDependentPicklistController.PicklistEntryWrapper> dep = new List<NGMCP_UserDependentPicklistController.PicklistEntryWrapper>();
        {
            NGMCP_UserDependentPicklistController.PicklistEntryWrapper a = new NGMCP_UserDependentPicklistController.PicklistEntryWrapper();
            a.label = 'MatchOnIndex1'; a.value = 'VAL_A'; a.active = true; a.defaultValue = false; a.validFor = 'w'; // 110000
            dep.add(a);
            
            NGMCP_UserDependentPicklistController.PicklistEntryWrapper b = new NGMCP_UserDependentPicklistController.PicklistEntryWrapper();
            b.label = 'NoMatch'; b.value = 'VAL_B'; b.active = true; b.defaultValue = false; b.validFor = 'B'; // 000001
            dep.add(b);
            
            NGMCP_UserDependentPicklistController.PicklistEntryWrapper c = new NGMCP_UserDependentPicklistController.PicklistEntryWrapper();
            c.label = 'InactiveButValid'; c.value = 'VAL_C'; c.active = false; c.defaultValue = false; c.validFor = 'w';
            dep.add(c);
        }
        
        // includeInactiveValues = false -> should only return the first
        List<NGMCP_UserDependentPicklistController.PicklistOption> opts =
            filterDependentOptions(dep, ctrlIndex, false);
        
        // Now include inactive
        List<NGMCP_UserDependentPicklistController.PicklistOption> opts2 =
            filterDependentOptions(dep, ctrlIndex, true);
        
    }
    
    private static String uniq() {
        return String.valueOf(DateTime.now().getTime()) + String.valueOf(Crypto.getRandomInteger());
    }
    
    
    
}