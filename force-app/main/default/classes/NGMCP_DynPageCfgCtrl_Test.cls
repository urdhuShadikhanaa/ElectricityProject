@IsTest(seeAllData=true)
private class NGMCP_DynPageCfgCtrl_Test {

    /**
     * Covers: buildSectionConfigJsonByRtName() — blank parameter throws AuraHandledException.
     * Do NOT assert on the message text (AuraHandledException often returns "Script-thrown exception" in tests).
     * Ensure only ONE start/stop per method.
     */
    @IsTest
    static void test_buildSectionConfigJsonByRtName_blank_throws() {
        Boolean threw = false;

        Test.startTest();
        try {
            NGMCP_DynamicPageConfigServiceController.buildSectionConfigJsonByRtName('');
        } catch (AuraHandledException ex) {
            threw = true; // Correct exception type was thrown
        }
        Test.stopTest();

        System.assert(threw, 'Expected AuraHandledException for blank recordTypeName');
    }

    /**
     * Covers: buildSectionConfigJsonByRtName() — executes and (if data exists) runs the loop/body.
     * No SOQL filtering on non-filterable CMDT fields; filter in Apex instead.
     */
    @IsTest
    static void test_buildSectionConfigJsonByRtName_executes_loop_when_possible() {
        // Query a batch of CMDT rows broadly (no filter on non-filterable text areas etc.)
        List<NGMCP_Dynamic_Page_Configuration__mdt> allRows = [
            SELECT NGMCP_Dynamic_Record_Page_Configuration__r.NGMCP_Record_Type_Name__c,
                   NGMCP_Sectionos__c,
                   NGMCP_Fields__c,
                   NGMCP_Sequence__c
            FROM NGMCP_Dynamic_Page_Configuration__mdt
            ORDER BY NGMCP_Sequence__c ASC, NGMCP_Sectionos__c ASC
            LIMIT 200
        ];

        // Find a candidate row that will drive the loop body (non-blank label & fields & parent RT name)
        String candidateRtName;
        Boolean haveCandidate = false;
        for (NGMCP_Dynamic_Page_Configuration__mdt r : allRows) {
            String rtName = r.NGMCP_Dynamic_Record_Page_Configuration__r.NGMCP_Record_Type_Name__c;
            if (!String.isBlank(rtName)
                && !String.isBlank(r.NGMCP_Sectionos__c)
                && !String.isBlank(r.NGMCP_Fields__c)) {
                candidateRtName = rtName;
                haveCandidate = true;
                break;
            }
        }

        String rtNameToUse = haveCandidate ? candidateRtName : 'Default';

        Test.startTest();
        String jsonStr = NGMCP_DynamicPageConfigServiceController.buildSectionConfigJsonByRtName(rtNameToUse);
        Test.stopTest();

        System.assertNotEquals(null, jsonStr, 'JSON should not be null');

        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
        System.assert(root.containsKey('Default'), 'Root should contain key "Default"');

        List<Object> sections = (List<Object>) root.get('Default');
        System.assertNotEquals(null, sections, 'Sections list should not be null');

        if (haveCandidate) {
            System.assert(sections.size() > 0, 'Expected at least one section for candidate record type');

            Map<String, Object> first = (Map<String, Object>) sections[0];
            System.assert(first.containsKey('label'), 'Section should contain a label');
            System.assert(first.containsKey('fields'), 'Section should contain fields');

            List<Object> fields = (List<Object>) first.get('fields');
            System.assertNotEquals(null, fields, 'Fields should not be null');
            System.assert(fields.size() > 0, 'Fields should have at least one API name');
        } else {
            // No suitable CMDT rows present — still acceptable; sections may be empty
            System.assertEquals(0, sections.size(),
                'With no candidate rows, sections can be empty and method should still succeed');
        }
    }

    /**
     * Covers: buildSectionConfigJsonForRecordId() — null Id or blank objectApiName -> Default path.
     * Single start/stop in method.
     */
    @IsTest
    static void test_buildSectionConfigJsonForRecordId_nullOrBlankContext() {
        Test.startTest();
        String j1 = NGMCP_DynamicPageConfigServiceController.buildSectionConfigJsonForRecordId(null, 'Account');
        String j2 = NGMCP_DynamicPageConfigServiceController.buildSectionConfigJsonForRecordId('001000000000000AAA', '');
        Test.stopTest();

        Map<String, Object> r1 = (Map<String, Object>) JSON.deserializeUntyped(j1);
        Map<String, Object> r2 = (Map<String, Object>) JSON.deserializeUntyped(j2);
        System.assert(r1.containsKey('Default'), 'Expected Default key when recordId is null');
        System.assert(r2.containsKey('Default'), 'Expected Default key when objectApiName is blank');
    }

    /**
     * Covers: buildSectionConfigJsonForRecordId() — valid objectApiName; may or may not have RecordType.
     * Either way, returns JSON (Default or populated).
     */
    @IsTest
    static void test_buildSectionConfigJsonForRecordId_validAccount_happyPath() {
        Account acc = new Account(Name = 'Test Acc');
        insert acc;

        Test.startTest();
        String jsonStr = NGMCP_DynamicPageConfigServiceController.buildSectionConfigJsonForRecordId(acc.Id, 'Account');
        Test.stopTest();

        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
        System.assert(root.containsKey('Default'), 'Expected root to contain Default key');
    }

    /**
     * Covers: buildSectionConfigJsonForRecordId() — invalid objectApiName -> Database.query error -> catch -> Default.
     * Ensures catch block is executed for full branch coverage.
     */
    @IsTest
    static void test_buildSectionConfigJsonForRecordId_invalidObject_catchFallback() {
        Account acc = new Account(Name = 'Test Acc 2');
        insert acc;

        Test.startTest();
        String jsonStr = NGMCP_DynamicPageConfigServiceController.buildSectionConfigJsonForRecordId(acc.Id, 'AccountX'); // invalid sObject
        Test.stopTest();

        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
        System.assert(root.containsKey('Default'), 'Expected Default key from catch fallback');
    }

    /**
     * Covers: getObjectApiName() — null and happy path.
     * Only one start/stop pair in the method.
     */
    @IsTest
    static void test_getObjectApiName_nullAndHappyPath() {
        Account acc = new Account(Name = 'Test Acc 3');
        insert acc;

        Test.startTest();
        // Null guard first
        String s1 = NGMCP_DynamicPageConfigServiceController.getObjectApiName(null);
        // Happy path
        String objName = NGMCP_DynamicPageConfigServiceController.getObjectApiName(acc.Id);
        Test.stopTest();

        System.assertEquals(null, s1, 'Null recordId should return null');
               System.assertEquals('Account', objName, 'Should resolve Account for Account Id');
    }
}