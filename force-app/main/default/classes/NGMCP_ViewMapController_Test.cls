@IsTest(SeeAllData=true)
private class NGMCP_ViewMapController_Test {

    // Utility: Create a minimal NGMCP_Request__c record
    private static NGMCP_Request__c createRequest() {
        NGMCP_Request__c r = new NGMCP_Request__c();
        // TODO: Set required fields if your org enforces any.
        insert r;
        return r;
    }

    @IsTest
    static void test_getSectionedFieldData_resilient() {
        // Arrange
        NGMCP_Request__c req = createRequest();

        // (Optional) probe: see if CMDT exists for 'Urgent Work Request'
        // NOTE: No DML on CMDT; just a read.
        List<NGMCP_View_WR__mdt> existingMeta = [
            SELECT Record_Type_Name__c, SectionName__c, All_fields__c
            FROM NGMCP_View_WR__mdt
            WHERE Record_Type_Name__c = 'Urgent Work Request'
            ORDER BY SectionName__c
        ];

        Test.startTest();
        List<Object> cards = NGMCP_ViewMapController.getSectionedFieldData(req.Id);
        Test.stopTest();

        if (existingMeta.isEmpty()) {
            // If no CMDT rows, controller should return an empty list
            System.assertEquals(0, cards.size(),
                'With no CMDT rows for "Urgent Work Request", result must be empty.');
            return;
        }

        // If CMDT rows do exist, validate structure in a generic way
        System.assert(cards != null, 'Cards should not be null when metadata exists.');
        System.assert(cards.size() == existingMeta.size(),
            'Number of sections should match metadata rows.');

        // Generic structural checks for first card
        Map<String, Object> firstCard = (Map<String, Object>) cards[0];
        System.assert(firstCard.containsKey('sectionName'),
            'Card must contain sectionName.');
        System.assert(firstCard.containsKey('fields'),
            'Card must contain fields.');

        // Fields array for first section
        List<Object> fields = (List<Object>) firstCard.get('fields');
        System.assertNotEquals(null, fields, 'Fields list should not be null.');
        // We can’t guarantee exact list of fields (depends on CMDT content),
        // but we can validate shape of field entries if any are present.
        if (!fields.isEmpty()) {
            Map<String, Object> field0 = (Map<String, Object>) fields[0];
            System.assert(field0.containsKey('api'), 'Field entry should have api.');
            System.assert(field0.containsKey('label'), 'Field entry should have label.');
            System.assert(field0.containsKey('value'), 'Field entry should have value (may be null if field blank).');

            // Basic label sanity: label is a non-null String (could be empty on blank api)
            Object lbl = field0.get('label');
            System.assert(lbl == null || lbl instanceof String,
                'Label must be a string or null.');
        }
    }

    @IsTest
    static void test_getSectionedFieldData_returnsEmptyWhenNoMetadata() {
        // This test just verifies behavior when no metadata matches the hardcoded filter.
        // Since we cannot delete CMDT in tests, we only assert that the method
        // gracefully handles the empty CMDT scenario when it occurs.

        // Arrange
        NGMCP_Request__c req = createRequest();

        // Only run this assertion path if the org has no CMDT for the hardcoded filter.
        Boolean noMetaForFilter = [
            SELECT count()
            FROM NGMCP_View_WR__mdt
            WHERE Record_Type_Name__c = 'Urgent Work Request'
        ] == 0;

        if (!noMetaForFilter) {
            // If metadata exists, skip this test to avoid false failure.
            // You’ll still get coverage from the other test.
            System.assert(true, 'Metadata exists in this org; skipping empty-case assertion.');
            return;
        }

        Test.startTest();
        List<Object> cards = NGMCP_ViewMapController.getSectionedFieldData(req.Id);
        Test.stopTest();

        System.assertEquals(0, cards.size(),
            'With no CMDT rows for "Urgent Work Request", result must be empty.');
    }
}