@isTest
private class FormResponseSanitiserHandlerTest {

    private static final String INTERNAL_SECTION = 'Internal Notes';
    private static final String VISIBLE_SECTION = 'Customer Details';

    @TestSetup
    static void setupTestData() {
        // Create Form with internal sections
        axsy_forms__Form__c form = new axsy_forms__Form__c(
            Name = 'Test Sanitiser Form',
            Internal_View_Only__c = INTERNAL_SECTION
        );
        insert form;

        // Create sections
        axsy_forms__Form_Section__c internalSection = new axsy_forms__Form_Section__c(
            Name = INTERNAL_SECTION
        );
        axsy_forms__Form_Section__c visibleSection = new axsy_forms__Form_Section__c(
            Name = VISIBLE_SECTION
        );
        insert new List<axsy_forms__Form_Section__c>{ internalSection, visibleSection };

        // Create elements
        axsy_forms__Form_Element__c internalElement = new axsy_forms__Form_Element__c(
            Name = 'Internal Element 1',
            axsy_forms__Type__c = 'Text'
        );
        axsy_forms__Form_Element__c visibleElement = new axsy_forms__Form_Element__c(
            Name = 'Visible Element 1',
            axsy_forms__Type__c = 'Text'
        );
        insert new List<axsy_forms__Form_Element__c>{ internalElement, visibleElement };

        // Create FSAs (Form Section Associations)
        axsy_forms__Form_Section_Association__c fsa1 = new axsy_forms__Form_Section_Association__c(
            axsy_forms__Form__c = form.Id,
            axsy_forms__Form_Section__c = internalSection.Id
        );
        axsy_forms__Form_Section_Association__c fsa2 = new axsy_forms__Form_Section_Association__c(
            axsy_forms__Form__c = form.Id,
            axsy_forms__Form_Section__c = visibleSection.Id
        );
        insert new List<axsy_forms__Form_Section_Association__c>{ fsa1, fsa2 };

        // Create ESAs (Element Section Associations)
        axsy_forms__Form_Section_Element_Association__c esa1 =
            new axsy_forms__Form_Section_Element_Association__c(
                axsy_forms__Form_Section__c = internalSection.Id,
                axsy_forms__Form_Element__c = internalElement.Id
            );
        axsy_forms__Form_Section_Element_Association__c esa2 =
            new axsy_forms__Form_Section_Element_Association__c(
                axsy_forms__Form_Section__c = visibleSection.Id,
                axsy_forms__Form_Element__c = visibleElement.Id
            );
        insert new List<axsy_forms__Form_Section_Element_Association__c>{ esa1, esa2 };

        // Build Form Version with JSON content document
        axsy_forms__Form_Version__c formVersion = new axsy_forms__Form_Version__c(
            axsy_forms__Form__c = form.Id
        );
        insert formVersion;

        // Build Form Version JSON containing sections with section/element IDs
        String versionJson = buildVersionJson(
            internalSection.Id, INTERNAL_SECTION, internalElement.Id,
            visibleSection.Id, VISIBLE_SECTION, visibleElement.Id
        );
        ContentVersion cv = new ContentVersion(
            Title = 'Form Data',
            PathOnClient = 'Form Data.json',
            VersionData = Blob.valueOf(versionJson),
            FirstPublishLocationId = formVersion.Id
        );
        insert cv;

        // Build response JSON referencing both sections' elements
        String responseJson = '{"' + internalSection.Id + '":{"value":"internal data"},'
            + '"' + internalElement.Id + '":{"value":"internal element data"},'
            + '"' + visibleSection.Id + '":{"value":"visible data"},'
            + '"' + visibleElement.Id + '":{"value":"visible element data"}}';

        // Create Form Response (draft — no version, for junction object path testing)
        axsy_forms__Form_Response__c draftResponse = new axsy_forms__Form_Response__c(
            axsy_forms__Form__c = form.Id,
            axsy_forms__Response_Data__c = responseJson,
            Customer_Visible__c = false
        );
        insert draftResponse;

        // Create Form Response with version (for version JSON path testing)
        axsy_forms__Form_Response__c versionedResponse = new axsy_forms__Form_Response__c(
            axsy_forms__Form__c = form.Id,
            axsy_forms__Form_Version__c = formVersion.Id,
            axsy_forms__Response_Data__c = responseJson,
            Customer_Visible__c = false
        );
        insert versionedResponse;
    }

    private static String buildVersionJson(
        Id intSectionId, String intSectionName, Id intElementId,
        Id visSectionId, String visSectionName, Id visElementId
    ) {
        return '{"sections":{'
            + '"' + intSectionId + '":{"name":"' + intSectionName + '",'
            + '"elementSectionAssociations":{"esa1":{"elementId":"' + intElementId + '"}}},'
            + '"' + visSectionId + '":{"name":"' + visSectionName + '",'
            + '"elementSectionAssociations":{"esa2":{"elementId":"' + visElementId + '"}}}'
            + '}}';
    }

    // ---- Helper: get test data ----

    private static axsy_forms__Form__c getForm() {
        return [SELECT Id, Internal_View_Only__c FROM axsy_forms__Form__c LIMIT 1];
    }

    private static axsy_forms__Form_Response__c getDraftResponse() {
        return [
            SELECT Id, axsy_forms__Form__c, axsy_forms__Form_Version__c,
                   axsy_forms__Response_Data__c, Customer_Visible__c,
                   axsy_forms__Status__c
            FROM axsy_forms__Form_Response__c
            WHERE axsy_forms__Form_Version__c = null
                AND Original_Form_Response__c = null
            LIMIT 1
        ];
    }

    private static axsy_forms__Form_Response__c getVersionedResponse() {
        return [
            SELECT Id, axsy_forms__Form__c, axsy_forms__Form_Version__c,
                   axsy_forms__Response_Data__c, Customer_Visible__c,
                   axsy_forms__Status__c
            FROM axsy_forms__Form_Response__c
            WHERE axsy_forms__Form_Version__c != null
                AND Original_Form_Response__c = null
            LIMIT 1
        ];
    }

    private static List<axsy_forms__Form_Response__c> getCopies(Id originalId) {
        return [
            SELECT Id, axsy_forms__Status__c, Customer_Visible__c,
                   Original_Form_Response__c, Original_Response_Key__c,
                   axsy_forms__Response_Data__c,
                   axsy_forms__Expected_Attachment_Count__c
            FROM axsy_forms__Form_Response__c
            WHERE Original_Form_Response__c = :originalId
        ];
    }

    // ---- Tests ----

    @isTest
    static void noStripPath_blankInternalViewOnly_setsCustomerVisible() {
        // Arrange: form with no internal sections
        axsy_forms__Form__c form = getForm();
        form.Internal_View_Only__c = '';
        update form;

        axsy_forms__Form_Response__c resp = getVersionedResponse();
        resp.axsy_forms__Status__c = 'Completed - Synced';
        resp.Customer_Visible__c = false;

        Test.startTest();
        update resp;
        Test.stopTest();

        // Assert: original marked customer visible, no copy created
        axsy_forms__Form_Response__c updated = [
            SELECT Customer_Visible__c FROM axsy_forms__Form_Response__c WHERE Id = :resp.Id
        ];
        System.assertEquals(true, updated.Customer_Visible__c,
            'No-strip path should set Customer_Visible__c to true');

        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(0, copies.size(), 'No copy should be created for no-strip path');
    }

    @isTest
    static void stripPath_versionJson_createsSanitisedCopy() {
        axsy_forms__Form_Response__c resp = getVersionedResponse();
        resp.axsy_forms__Status__c = 'Completed - Synced';
        resp.Customer_Visible__c = false;

        Test.startTest();
        update resp;
        Test.stopTest();

        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size(), 'One sanitised copy should be created');

        axsy_forms__Form_Response__c copy = copies[0];
        System.assertEquals('Customer Ready', copy.axsy_forms__Status__c,
            'Copy should have status Customer Ready');
        System.assertEquals(true, copy.Customer_Visible__c,
            'Copy should be customer visible');
        System.assertEquals((String) resp.Id, copy.Original_Response_Key__c,
            'Original_Response_Key__c should match original Id');

        // Verify internal sections were stripped from response data
        if (copy.axsy_forms__Response_Data__c != null) {
            axsy_forms__Form_Section__c intSection = [
                SELECT Id FROM axsy_forms__Form_Section__c WHERE Name = :INTERNAL_SECTION LIMIT 1
            ];
            System.assert(
                !copy.axsy_forms__Response_Data__c.contains(intSection.Id),
                'Internal section ID should be stripped from copy response data'
            );
        }

        // Verify original has Customer_Visible__c = false
        axsy_forms__Form_Response__c updatedOriginal = [
            SELECT Customer_Visible__c FROM axsy_forms__Form_Response__c WHERE Id = :resp.Id
        ];
        System.assertEquals(false, updatedOriginal.Customer_Visible__c,
            'Strip-path original should have Customer_Visible__c = false');
    }

    @isTest
    static void stripPath_junctionObjects_createsSanitisedCopy() {
        axsy_forms__Form_Response__c resp = getDraftResponse();
        resp.axsy_forms__Status__c = 'Completed - Synced';
        resp.Customer_Visible__c = false;

        Test.startTest();
        update resp;
        Test.stopTest();

        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size(), 'One sanitised copy should be created for draft path');
        System.assertEquals('Customer Ready', copies[0].axsy_forms__Status__c,
            'Draft path copy should have status Customer Ready');
    }

    @isTest
    static void stripPath_customerVisibleOriginal_setToFalse() {
        // Arrange: original starts with Customer_Visible__c = true
        axsy_forms__Form_Response__c resp = getVersionedResponse();
        resp.Customer_Visible__c = true;
        resp.axsy_forms__Status__c = 'Completed - Synced';

        Test.startTest();
        // Directly invoke handler (simulating batch) to test visibility logic
        FormResponseSanitiserHandler.process(new Set<Id>{ resp.Id });
        Test.stopTest();

        axsy_forms__Form_Response__c updated = [
            SELECT Customer_Visible__c FROM axsy_forms__Form_Response__c WHERE Id = :resp.Id
        ];
        System.assertEquals(false, updated.Customer_Visible__c,
            'Strip-path should set Customer_Visible__c = false on original');
    }

    @isTest
    static void caseInsensitive_sectionMatching() {
        // Arrange: form with mixed-case internal section name
        axsy_forms__Form__c form = getForm();
        form.Internal_View_Only__c = 'INTERNAL NOTES';  // uppercase
        update form;

        axsy_forms__Form_Response__c resp = getVersionedResponse();
        resp.axsy_forms__Status__c = 'Completed - Synced';
        resp.Customer_Visible__c = false;

        Test.startTest();
        update resp;
        Test.stopTest();

        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size(),
            'Case-insensitive matching should create a sanitised copy');
    }

    @isTest
    static void copyStatus_isCustomerReady_notCompletedSynced() {
        axsy_forms__Form_Response__c resp = getVersionedResponse();
        resp.axsy_forms__Status__c = 'Completed - Synced';
        resp.Customer_Visible__c = false;

        Test.startTest();
        update resp;
        Test.stopTest();

        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size());
        System.assertNotEquals('Completed - Synced', copies[0].axsy_forms__Status__c,
            'Copy should NOT have Completed - Synced status');
        System.assertEquals('Customer Ready', copies[0].axsy_forms__Status__c,
            'Copy should have Customer Ready status');
    }

    @isTest
    static void trigger_firesOnInsertWithCorrectCriteria() {
        axsy_forms__Form__c form = getForm();

        axsy_forms__Form_Response__c resp = new axsy_forms__Form_Response__c(
            axsy_forms__Form__c = form.Id,
            axsy_forms__Status__c = 'Completed - Synced',
            Customer_Visible__c = false,
            axsy_forms__Response_Data__c = '{}'
        );

        Test.startTest();
        insert resp;
        Test.stopTest();

        // Batch should have been enqueued and executed
        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size(),
            'Trigger should fire on insert with correct criteria');
    }

    @isTest
    static void trigger_doesNotFireWhenStatusAlreadyCompletedSynced() {
        axsy_forms__Form_Response__c resp = getVersionedResponse();
        resp.axsy_forms__Status__c = 'Completed - Synced';
        resp.Customer_Visible__c = false;

        // First: create the copy via direct handler call (avoids needing two Test.startTest blocks)
        FormResponseSanitiserHandler.process(new Set<Id>{ resp.Id });

        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size(), 'First run should create one copy');

        // Second update: change a non-protected field while status stays 'Completed - Synced'
        // This should NOT re-trigger the batch (transition check filters it out)
        Test.startTest();
        resp.Customer_Visible__c = false;
        update resp;
        Test.stopTest();

        // Copy count should remain the same (trigger filtered it out)
        copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size(),
            'Trigger should not fire again when status is already Completed - Synced');
    }

    @isTest
    static void uniqueConstraint_preventsDuplicateCopies() {
        axsy_forms__Form_Response__c resp = getVersionedResponse();
        resp.axsy_forms__Status__c = 'Completed - Synced';
        resp.Customer_Visible__c = false;

        Test.startTest();
        update resp;
        Test.stopTest();

        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size(), 'Should have exactly one copy');

        // Attempt to insert a second copy with the same Original_Response_Key__c
        axsy_forms__Form_Response__c duplicateCopy = new axsy_forms__Form_Response__c(
            axsy_forms__Form__c = resp.axsy_forms__Form__c,
            Original_Form_Response__c = resp.Id,
            Original_Response_Key__c = (String) resp.Id,
            Customer_Visible__c = true
        );

        Boolean duplicateFailed = false;
        try {
            insert duplicateCopy;
        } catch (DmlException e) {
            duplicateFailed = true;
        }
        System.assertEquals(true, duplicateFailed,
            'Duplicate Original_Response_Key__c should fail on unique constraint');
    }

    @isTest
    static void reSanitisation_preservesCopyId() {
        axsy_forms__Form_Response__c resp = getVersionedResponse();
        resp.axsy_forms__Status__c = 'Completed - Synced';
        resp.Customer_Visible__c = false;

        // First: create copy via direct handler call
        FormResponseSanitiserHandler.process(new Set<Id>{ resp.Id });

        List<axsy_forms__Form_Response__c> firstCopies = getCopies(resp.Id);
        System.assertEquals(1, firstCopies.size());
        Id firstCopyId = firstCopies[0].Id;

        // Re-sanitise — should update existing copy in place
        Test.startTest();
        FormResponseSanitiserHandler.process(new Set<Id>{ resp.Id });
        Test.stopTest();

        List<axsy_forms__Form_Response__c> secondCopies = getCopies(resp.Id);
        System.assertEquals(1, secondCopies.size(), 'Should still have exactly one copy');
        System.assertEquals(firstCopyId, secondCopies[0].Id,
            'Copy ID should be preserved after update-in-place re-sanitisation');
    }

    @isTest
    static void reSanitisation_updatesDataOnCustomerReadyCopy() {
        axsy_forms__Form_Response__c resp = getVersionedResponse();

        // First sanitisation — creates a Customer Ready copy
        FormResponseSanitiserHandler.process(new Set<Id>{ resp.Id });

        List<axsy_forms__Form_Response__c> firstCopies = getCopies(resp.Id);
        System.assertEquals(1, firstCopies.size());
        Id firstCopyId = firstCopies[0].Id;
        String firstCopyData = firstCopies[0].axsy_forms__Response_Data__c;
        System.assertEquals('Customer Ready', firstCopies[0].axsy_forms__Status__c,
            'Copy should be Customer Ready after first sanitisation');

        // Modify original response data — change visible element value.
        // Must set Status to Draft in a separate DML first so the
        // managed-package validation (PRIORVALUE(Status) = Draft) allows
        // the subsequent Response_Data__c change.
        resp = getVersionedResponse();
        resp.axsy_forms__Status__c = 'Draft';
        update resp;

        resp.axsy_forms__Response_Data__c = resp.axsy_forms__Response_Data__c.replace(
            'visible element data', 'updated visible element data');
        update resp;

        // Re-sanitise — copy is Customer Ready; handler must revert to Draft first
        // to comply with the validation rule and managed-package trigger
        Test.startTest();
        FormResponseSanitiserHandler.process(new Set<Id>{ resp.Id });
        Test.stopTest();

        List<axsy_forms__Form_Response__c> secondCopies = getCopies(resp.Id);
        System.assertEquals(1, secondCopies.size());
        System.assertEquals(firstCopyId, secondCopies[0].Id,
            'Copy ID should be preserved');
        System.assertEquals('Customer Ready', secondCopies[0].axsy_forms__Status__c,
            'Copy status should be Customer Ready after re-sanitisation');
        System.assertNotEquals(firstCopyData, secondCopies[0].axsy_forms__Response_Data__c,
            'Copy response data should have changed after re-sanitisation');
    }

    @isTest
    static void overflowResponseData_createsContentDocument() {
        // To test the overflow path, response data must exceed 131,072 chars.
        // The field itself is capped at 131,072, so we attach the large JSON
        // as a ContentDocument on the original response (matching the overflow
        // naming pattern). The handler's getResponseData reads from it.
        axsy_forms__Form__c form = getForm();
        axsy_forms__Form_Response__c vResp = getVersionedResponse();

        axsy_forms__Form_Response__c resp = new axsy_forms__Form_Response__c(
            axsy_forms__Form__c = form.Id,
            axsy_forms__Form_Version__c = vResp.axsy_forms__Form_Version__c,
            Customer_Visible__c = false
        );
        insert resp;

        // Create large JSON that exceeds the field limit
        String largeValue = 'x'.repeat(140000);
        String largeJson = '{"bigfield":{"value":"' + largeValue + '"}}';

        // Attach as overflow content document on the original response
        ContentVersion cv = new ContentVersion(
            Title = 'form_response_' + resp.Id,
            PathOnClient = 'form_response_' + resp.Id + '.json',
            VersionData = Blob.valueOf(largeJson),
            FirstPublishLocationId = resp.Id
        );
        insert cv;

        // Transition to Completed - Synced to trigger the batch
        resp.axsy_forms__Status__c = 'Completed - Synced';

        Test.startTest();
        update resp;
        Test.stopTest();

        // The copy should exist
        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size(), 'Copy should be created');

        // Verify overflow content document was linked to the copy
        List<ContentDocumentLink> copyCdls = [
            SELECT ContentDocument.Title
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :copies[0].Id
                AND ContentDocument.Title LIKE 'form_response_%'
                AND ContentDocument.FileExtension = 'json'
        ];
        System.assertEquals(1, copyCdls.size(),
            'Overflow content document should be linked to the customer copy');
        System.assertEquals(1, copies[0].axsy_forms__Expected_Attachment_Count__c,
            'Expected attachment count should include the overflow response data document');
    }

    @isTest
    static void noStripPath_deletesStaleCopies() {
        // First create a copy via the strip path (direct handler call, no batch)
        axsy_forms__Form_Response__c resp = getVersionedResponse();
        resp.axsy_forms__Status__c = 'Completed - Synced';
        resp.Customer_Visible__c = false;

        FormResponseSanitiserHandler.process(new Set<Id>{ resp.Id });

        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size(), 'Should have one copy after strip path');

        // Now remove internal sections — triggers no-strip path
        axsy_forms__Form__c form = getForm();
        form.Internal_View_Only__c = '';
        update form;

        // Re-process via handler (simulates batch from FormInternalViewOnly trigger)
        Test.startTest();
        FormResponseSanitiserHandler.process(new Set<Id>{ resp.Id });
        Test.stopTest();

        copies = getCopies(resp.Id);
        System.assertEquals(0, copies.size(),
            'No-strip path should delete stale copies');

        axsy_forms__Form_Response__c updated = [
            SELECT Customer_Visible__c FROM axsy_forms__Form_Response__c WHERE Id = :resp.Id
        ];
        System.assertEquals(true, updated.Customer_Visible__c,
            'No-strip path should set Customer_Visible__c = true');
    }

    @isTest
    static void copyFilesToCustomerCopies_linksFilesToCopy() {
        // Arrange: versioned response with file reference on a visible element
        axsy_forms__Form__c form = getForm();
        axsy_forms__Form_Response__c vResp = getVersionedResponse();

        axsy_forms__Form_Element__c visElement = [
            SELECT Id FROM axsy_forms__Form_Element__c WHERE Name = 'Visible Element 1' LIMIT 1
        ];

        // Response JSON: visible element has a file reference, internal section has plain data
        axsy_forms__Form_Section__c intSection = [
            SELECT Id FROM axsy_forms__Form_Section__c WHERE Name = :INTERNAL_SECTION LIMIT 1
        ];
        axsy_forms__Form_Element__c intElement = [
            SELECT Id FROM axsy_forms__Form_Element__c WHERE Name = 'Internal Element 1' LIMIT 1
        ];
        axsy_forms__Form_Section__c visSection = [
            SELECT Id FROM axsy_forms__Form_Section__c WHERE Name = :VISIBLE_SECTION LIMIT 1
        ];

        String responseJson = '{'
            + '"' + intSection.Id + '":{"value":"internal data"},'
            + '"' + intElement.Id + '":{"value":"internal element data"},'
            + '"' + visSection.Id + '":{"value":"visible data"},'
            + '"' + visElement.Id + '":{"value":{"file1":{"title":"testfile.jpg"}}}'
            + '}';

        axsy_forms__Form_Response__c resp = new axsy_forms__Form_Response__c(
            axsy_forms__Form__c = form.Id,
            axsy_forms__Form_Version__c = vResp.axsy_forms__Form_Version__c,
            axsy_forms__Response_Data__c = responseJson,
            Customer_Visible__c = false
        );
        insert resp;

        // Attach a file to the original response
        ContentVersion fileCV = new ContentVersion(
            Title = 'testfile.jpg',
            PathOnClient = 'testfile.jpg',
            VersionData = Blob.valueOf('fake image data'),
            FirstPublishLocationId = resp.Id
        );
        insert fileCV;

        // Act
        resp.axsy_forms__Status__c = 'Completed - Synced';

        Test.startTest();
        update resp;
        Test.stopTest();

        // Assert: copy exists and has the file linked
        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size(), 'One copy should be created');

        List<ContentDocumentLink> copyCdls = [
            SELECT ContentDocument.Title
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :copies[0].Id
                AND ContentDocument.Title = 'testfile.jpg'
        ];
        System.assertEquals(1, copyCdls.size(),
            'File attachment should be linked to the customer copy');
    }

    @isTest
    static void multiSection_internalViewOnly_stripsAllSections() {
        // Arrange: form with two internal sections
        axsy_forms__Form__c form = getForm();

        // Create a second internal section
        axsy_forms__Form_Section__c secretSection = new axsy_forms__Form_Section__c(
            Name = 'Secret Section'
        );
        insert secretSection;

        axsy_forms__Form_Element__c secretElement = new axsy_forms__Form_Element__c(
            Name = 'Secret Element 1',
            axsy_forms__Type__c = 'Text'
        );
        insert secretElement;

        axsy_forms__Form_Section_Association__c fsa = new axsy_forms__Form_Section_Association__c(
            axsy_forms__Form__c = form.Id,
            axsy_forms__Form_Section__c = secretSection.Id
        );
        insert fsa;

        axsy_forms__Form_Section_Element_Association__c esa =
            new axsy_forms__Form_Section_Element_Association__c(
                axsy_forms__Form_Section__c = secretSection.Id,
                axsy_forms__Form_Element__c = secretElement.Id
            );
        insert esa;

        // Set form to have two newline-separated internal section names
        form.Internal_View_Only__c = INTERNAL_SECTION + '\nSecret Section';
        update form;

        // Get existing internal IDs
        axsy_forms__Form_Section__c intSection = [
            SELECT Id FROM axsy_forms__Form_Section__c WHERE Name = :INTERNAL_SECTION LIMIT 1
        ];
        axsy_forms__Form_Element__c intElement = [
            SELECT Id FROM axsy_forms__Form_Element__c WHERE Name = 'Internal Element 1' LIMIT 1
        ];
        axsy_forms__Form_Section__c visSection = [
            SELECT Id FROM axsy_forms__Form_Section__c WHERE Name = :VISIBLE_SECTION LIMIT 1
        ];
        axsy_forms__Form_Element__c visElement = [
            SELECT Id FROM axsy_forms__Form_Element__c WHERE Name = 'Visible Element 1' LIMIT 1
        ];

        // Build response JSON with keys for both internal sections + visible section
        String responseJson = '{'
            + '"' + intSection.Id + '":{"value":"internal data"},'
            + '"' + intElement.Id + '":{"value":"internal element data"},'
            + '"' + secretSection.Id + '":{"value":"secret data"},'
            + '"' + secretElement.Id + '":{"value":"secret element data"},'
            + '"' + visSection.Id + '":{"value":"visible data"},'
            + '"' + visElement.Id + '":{"value":"visible element data"}'
            + '}';

        // Use draft path (no version) to test via junction objects
        axsy_forms__Form_Response__c resp = new axsy_forms__Form_Response__c(
            axsy_forms__Form__c = form.Id,
            axsy_forms__Response_Data__c = responseJson,
            Customer_Visible__c = false
        );
        insert resp;

        resp.axsy_forms__Status__c = 'Completed - Synced';

        Test.startTest();
        update resp;
        Test.stopTest();

        // Assert: copy exists and neither internal section's IDs are present
        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size(), 'One copy should be created');

        String copyData = copies[0].axsy_forms__Response_Data__c;
        System.assert(!copyData.contains(intSection.Id),
            'First internal section ID should be stripped');
        System.assert(!copyData.contains(intElement.Id),
            'First internal element ID should be stripped');
        System.assert(!copyData.contains(secretSection.Id),
            'Second internal section ID should be stripped');
        System.assert(!copyData.contains(secretElement.Id),
            'Second internal element ID should be stripped');

        // Visible section data should survive
        System.assert(copyData.contains(visSection.Id),
            'Visible section ID should remain in copy');
        System.assert(copyData.contains(visElement.Id),
            'Visible element ID should remain in copy');
    }

    @isTest
    static void reSanitisation_removesStaleCDLs() {
        // Arrange: file on a visible element, then make that section internal
        axsy_forms__Form__c form = getForm();
        axsy_forms__Form_Response__c vResp = getVersionedResponse();

        axsy_forms__Form_Element__c visElement = [
            SELECT Id FROM axsy_forms__Form_Element__c WHERE Name = 'Visible Element 1' LIMIT 1
        ];
        axsy_forms__Form_Section__c intSection = [
            SELECT Id FROM axsy_forms__Form_Section__c WHERE Name = :INTERNAL_SECTION LIMIT 1
        ];
        axsy_forms__Form_Element__c intElement = [
            SELECT Id FROM axsy_forms__Form_Element__c WHERE Name = 'Internal Element 1' LIMIT 1
        ];
        axsy_forms__Form_Section__c visSection = [
            SELECT Id FROM axsy_forms__Form_Section__c WHERE Name = :VISIBLE_SECTION LIMIT 1
        ];

        // File reference on visible element
        String responseJson = '{'
            + '"' + intSection.Id + '":{"value":"internal data"},'
            + '"' + intElement.Id + '":{"value":"internal element data"},'
            + '"' + visSection.Id + '":{"value":"visible data"},'
            + '"' + visElement.Id + '":{"value":{"file1":{"title":"customer_photo.jpg"}}}'
            + '}';

        axsy_forms__Form_Response__c resp = new axsy_forms__Form_Response__c(
            axsy_forms__Form__c = form.Id,
            axsy_forms__Form_Version__c = vResp.axsy_forms__Form_Version__c,
            axsy_forms__Response_Data__c = responseJson,
            Customer_Visible__c = false
        );
        insert resp;

        // Attach file to original
        ContentVersion fileCV = new ContentVersion(
            Title = 'customer_photo.jpg',
            PathOnClient = 'customer_photo.jpg',
            VersionData = Blob.valueOf('fake image data'),
            FirstPublishLocationId = resp.Id
        );
        insert fileCV;

        // First sanitisation — file should be linked to copy
        resp.axsy_forms__Status__c = 'Completed - Synced';
        update resp;

        Test.startTest();
        FormResponseSanitiserHandler.process(new Set<Id>{ resp.Id });

        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size());
        Id copyId = copies[0].Id;

        List<ContentDocumentLink> copyCdls = [
            SELECT Id FROM ContentDocumentLink
            WHERE LinkedEntityId = :copyId
                AND ContentDocument.Title = 'customer_photo.jpg'
        ];
        System.assertEquals(1, copyCdls.size(), 'File should be linked to copy initially');

        // Now make the visible section internal too
        form.Internal_View_Only__c = INTERNAL_SECTION + '\n' + VISIBLE_SECTION;
        update form;

        // Re-sanitise — visible element (with file) is now stripped
        FormResponseSanitiserHandler.process(new Set<Id>{ resp.Id });
        Test.stopTest();

        // Copy Id preserved
        copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size());
        System.assertEquals(copyId, copies[0].Id, 'Copy ID should be preserved');

        // File CDL should be removed from copy
        copyCdls = [
            SELECT Id FROM ContentDocumentLink
            WHERE LinkedEntityId = :copyId
                AND ContentDocument.Title = 'customer_photo.jpg'
        ];
        System.assertEquals(0, copyCdls.size(),
            'Stale file CDL should be removed after section becomes internal');
    }

    @isTest
    static void reSanitisation_addsOverflowWhenDataGrows() {
        axsy_forms__Form__c form = getForm();
        axsy_forms__Form_Response__c vResp = getVersionedResponse();

        axsy_forms__Form_Response__c resp = new axsy_forms__Form_Response__c(
            axsy_forms__Form__c = form.Id,
            axsy_forms__Form_Version__c = vResp.axsy_forms__Form_Version__c,
            axsy_forms__Response_Data__c = '{"smallfield":{"value":"small"}}',
            Customer_Visible__c = false
        );
        insert resp;

        resp.axsy_forms__Status__c = 'Completed - Synced';
        update resp;

        Test.startTest();
        // First sanitisation — small data, no overflow
        FormResponseSanitiserHandler.process(new Set<Id>{ resp.Id });

        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size());
        Id copyId = copies[0].Id;

        List<ContentDocumentLink> overflowCdls = [
            SELECT Id FROM ContentDocumentLink
            WHERE LinkedEntityId = :copyId
                AND ContentDocument.Title LIKE 'form_response_%'
        ];
        System.assertEquals(0, overflowCdls.size(), 'No overflow doc initially');

        // Attach large overflow data to original
        String largeJson = '{"bigfield":{"value":"' + 'x'.repeat(140000) + '"}}';
        ContentVersion cv = new ContentVersion(
            Title = 'form_response_' + resp.Id,
            PathOnClient = 'form_response_' + resp.Id + '.json',
            VersionData = Blob.valueOf(largeJson),
            FirstPublishLocationId = resp.Id
        );
        insert cv;

        // Re-sanitise
        FormResponseSanitiserHandler.process(new Set<Id>{ resp.Id });
        Test.stopTest();

        // Copy Id preserved
        copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size());
        System.assertEquals(copyId, copies[0].Id, 'Copy Id preserved');

        // Overflow doc should now exist on copy
        overflowCdls = [
            SELECT Id FROM ContentDocumentLink
            WHERE LinkedEntityId = :copyId
                AND ContentDocument.Title LIKE 'form_response_%'
        ];
        System.assertEquals(1, overflowCdls.size(),
            'Overflow content document should be linked to copy after data grows');
    }

    @isTest
    static void queueable_processesSanitisation() {
        axsy_forms__Form_Response__c resp = getVersionedResponse();
        resp.axsy_forms__Status__c = 'Completed - Synced';
        resp.Customer_Visible__c = false;

        Test.startTest();
        System.enqueueJob(new FormResponseSanitiserQueueable(new Set<Id>{ resp.Id }));
        Test.stopTest();

        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size(),
            'Queueable fallback should create a sanitised copy');
        System.assertEquals('Customer Ready', copies[0].axsy_forms__Status__c,
            'Copy should have Customer Ready status');
    }

    @isTest
    static void reSanitisation_removesOverflowWhenDataShrinks() {
        axsy_forms__Form__c form = getForm();
        axsy_forms__Form_Response__c vResp = getVersionedResponse();

        axsy_forms__Form_Response__c resp = new axsy_forms__Form_Response__c(
            axsy_forms__Form__c = form.Id,
            axsy_forms__Form_Version__c = vResp.axsy_forms__Form_Version__c,
            Customer_Visible__c = false
        );
        insert resp;

        // Attach large overflow data to original
        String largeJson = '{"bigfield":{"value":"' + 'x'.repeat(140000) + '"}}';
        ContentVersion cv = new ContentVersion(
            Title = 'form_response_' + resp.Id,
            PathOnClient = 'form_response_' + resp.Id + '.json',
            VersionData = Blob.valueOf(largeJson),
            FirstPublishLocationId = resp.Id
        );
        insert cv;

        resp.axsy_forms__Status__c = 'Completed - Synced';
        update resp;

        Test.startTest();
        // First sanitisation — overflow data
        FormResponseSanitiserHandler.process(new Set<Id>{ resp.Id });

        List<axsy_forms__Form_Response__c> copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size());
        Id copyId = copies[0].Id;

        List<ContentDocumentLink> overflowCdls = [
            SELECT Id FROM ContentDocumentLink
            WHERE LinkedEntityId = :copyId
                AND ContentDocument.Title LIKE 'form_response_%'
        ];
        System.assertEquals(1, overflowCdls.size(), 'Overflow doc should exist initially');

        // Remove overflow from original: delete the overflow doc, set small data on field
        List<ContentDocumentLink> origOverflow = [
            SELECT ContentDocumentId FROM ContentDocumentLink
            WHERE LinkedEntityId = :resp.Id
                AND ContentDocument.Title LIKE 'form_response_%'
        ];
        if (!origOverflow.isEmpty()) {
            delete [SELECT Id FROM ContentDocument WHERE Id = :origOverflow[0].ContentDocumentId];
        }
        resp.axsy_forms__Status__c = 'Draft';
        update resp;
        resp.axsy_forms__Response_Data__c = '{"smallfield":{"value":"small"}}';
        update resp;

        // Re-sanitise
        FormResponseSanitiserHandler.process(new Set<Id>{ resp.Id });
        Test.stopTest();

        // Copy Id preserved
        copies = getCopies(resp.Id);
        System.assertEquals(1, copies.size());
        System.assertEquals(copyId, copies[0].Id, 'Copy Id preserved');

        // Overflow doc should be removed from copy
        overflowCdls = [
            SELECT Id FROM ContentDocumentLink
            WHERE LinkedEntityId = :copyId
                AND ContentDocument.Title LIKE 'form_response_%'
        ];
        System.assertEquals(0, overflowCdls.size(),
            'Overflow doc should be removed after data shrinks');

        // Response data should now be on the field
        axsy_forms__Form_Response__c updatedCopy = [
            SELECT axsy_forms__Response_Data__c
            FROM axsy_forms__Form_Response__c WHERE Id = :copyId
        ];
        System.assertNotEquals(null, updatedCopy.axsy_forms__Response_Data__c,
            'Response data should be in field after overflow removal');
    }
}