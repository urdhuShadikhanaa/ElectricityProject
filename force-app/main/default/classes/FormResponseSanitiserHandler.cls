/**
 * Runs without sharing intentionally — this handler executes as a system process
 * via an async batch job and must clone records and copy files regardless of the
 * triggering user's record-level access.
 */
public without sharing class FormResponseSanitiserHandler {

    private static final Integer RESPONSE_DATA_MAX_LENGTH = 131072;

    private static List<String> writableFieldNamesCache;
    private static List<String> updateableFieldNamesCache;

    public static void process(Set<Id> responseIds) {
        // Query 1: re-query with Form relationship and all writable fields
        List<String> fieldNames = getWritableFieldNames();
        Set<String> fieldNamesLower = new Set<String>();
        for (String fn : fieldNames) {
            fieldNamesLower.add(fn.toLowerCase());
        }
        if (!fieldNamesLower.contains('axsy_forms__form__c')) {
            fieldNames.add('axsy_forms__Form__c');
        }
        if (!fieldNamesLower.contains('axsy_forms__form_version__c')) {
            fieldNames.add('axsy_forms__Form_Version__c');
        }
        if (!fieldNamesLower.contains('axsy_forms__response_data__c')) {
            fieldNames.add('axsy_forms__Response_Data__c');
        }
        String fieldList = String.join(fieldNames, ', ')
            + ', axsy_forms__Form__r.Internal_View_Only__c';

        String query = 'SELECT Id, ' + fieldList
            + ' FROM axsy_forms__Form_Response__c WHERE Id IN :responseIds';
        List<axsy_forms__Form_Response__c> fullRecords = Database.query(query);

        // Step 1: classify into no-strip vs needs-sanitisation
        List<axsy_forms__Form_Response__c> noStripUpdates = new List<axsy_forms__Form_Response__c>();
        List<axsy_forms__Form_Response__c> toSanitise = new List<axsy_forms__Form_Response__c>();
        // formId -> set of trimmed section names
        Map<Id, Set<String>> internalSectionsByForm = new Map<Id, Set<String>>();

        for (axsy_forms__Form_Response__c r : fullRecords) {
            String internalViewOnly = (String) r.getSObject('axsy_forms__Form__r')
                ?.get('Internal_View_Only__c');

            if (String.isBlank(internalViewOnly)) {
                noStripUpdates.add(new axsy_forms__Form_Response__c(
                    Id = r.Id,
                    Customer_Visible__c = true
                ));
            } else {
                toSanitise.add(r);
                Id formId = r.axsy_forms__Form__c;
                if (!internalSectionsByForm.containsKey(formId)) {
                    Set<String> sectionNames = new Set<String>();
                    for (String name : internalViewOnly.split('\n')) {
                        String trimmed = name.trim();
                        if (String.isNotBlank(trimmed)) {
                            sectionNames.add(trimmed.toLowerCase());
                        }
                    }
                    internalSectionsByForm.put(formId, sectionNames);
                }
            }
        }

        // DML 1: mark no-strip records as customer visible
        if (!noStripUpdates.isEmpty()) {
            update noStripUpdates;

            // Delete stale customer copies that are no longer needed
            Set<Id> noStripIds = new Set<Id>();
            for (axsy_forms__Form_Response__c r : noStripUpdates) {
                noStripIds.add(r.Id);
            }
            List<axsy_forms__Form_Response__c> staleCopies = [
                SELECT Id
                FROM axsy_forms__Form_Response__c
                WHERE Original_Form_Response__c IN :noStripIds
            ];
            if (!staleCopies.isEmpty()) {
                delete staleCopies;
            }
        }

        if (toSanitise.isEmpty()) {
            return;
        }

        // Set Customer_Visible__c = false on originals that need sanitisation.
        // NOTE: This DML re-fires FormResponseSanitiser trigger, but the trigger's
        // Status__c transition check filters it out (Status__c is not changing).
        List<axsy_forms__Form_Response__c> stripVisibilityUpdates =
            new List<axsy_forms__Form_Response__c>();
        for (axsy_forms__Form_Response__c r : toSanitise) {
            stripVisibilityUpdates.add(new axsy_forms__Form_Response__c(
                Id = r.Id,
                Customer_Visible__c = false
            ));
        }
        if (!stripVisibilityUpdates.isEmpty()) {
            update stripVisibilityUpdates;
        }

        // Step 2: partition by Form Version presence
        List<axsy_forms__Form_Response__c> withVersion = new List<axsy_forms__Form_Response__c>();
        List<axsy_forms__Form_Response__c> withoutVersion = new List<axsy_forms__Form_Response__c>();

        for (axsy_forms__Form_Response__c r : toSanitise) {
            if (r.axsy_forms__Form_Version__c != null) {
                withVersion.add(r);
            } else {
                withoutVersion.add(r);
            }
        }

        // responseId -> set of IDs (section + element) to strip
        Map<Id, Set<String>> idsToStripByResponse = new Map<Id, Set<String>>();
        for (axsy_forms__Form_Response__c r : toSanitise) {
            idsToStripByResponse.put(r.Id, new Set<String>());
        }

        // Step 3a: version path
        if (!withVersion.isEmpty()) {
            collectIdsFromVersionJson(withVersion, internalSectionsByForm, idsToStripByResponse);
        }

        // Step 3b: draft path
        if (!withoutVersion.isEmpty()) {
            collectIdsFromJunctionObjects(withoutVersion, internalSectionsByForm, idsToStripByResponse);
        }

        // Step 4: retrieve response data
        Map<Id, String> responseDataMap = getResponseData(toSanitise);

        // Step 5: strip keys
        Map<Id, String> sanitisedJsonMap = new Map<Id, String>();
        for (axsy_forms__Form_Response__c r : toSanitise) {
            Set<String> keysToRemove = idsToStripByResponse.get(r.Id);
            String responseJson = responseDataMap.get(r.Id);
            sanitisedJsonMap.put(r.Id, stripKeys(responseJson, keysToRemove));
        }

        // Step 6: create/update customer copies
        cloneAndUpsertCopies(toSanitise, sanitisedJsonMap, fieldNames);
    }

    // ---- Step 3a: Form Version JSON path ----

    private static void collectIdsFromVersionJson(
        List<axsy_forms__Form_Response__c> responses,
        Map<Id, Set<String>> internalSectionsByForm,
        Map<Id, Set<String>> idsToStripByResponse
    ) {
        // Deduplicate: multiple responses may share a Form Version
        // Map formVersionId -> list of response records that use it
        Map<Id, List<axsy_forms__Form_Response__c>> responsesByVersion
            = new Map<Id, List<axsy_forms__Form_Response__c>>();
        for (axsy_forms__Form_Response__c r : responses) {
            Id versionId = r.axsy_forms__Form_Version__c;
            if (!responsesByVersion.containsKey(versionId)) {
                responsesByVersion.put(versionId, new List<axsy_forms__Form_Response__c>());
            }
            responsesByVersion.get(versionId).add(r);
        }

        Set<Id> versionIds = responsesByVersion.keySet();

        // Query ContentDocumentLink for Form Version JSON
        List<ContentDocumentLink> cdls = [
            SELECT ContentDocument.LatestPublishedVersionId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :versionIds
                AND ContentDocument.Title = 'Form Data'
                AND ContentDocument.FileExtension = 'json'
        ];

        if (cdls.isEmpty()) {
            return;
        }

        // Map latestVersionId -> formVersionId (LinkedEntityId)
        Map<Id, Id> contentVersionToFormVersion = new Map<Id, Id>();
        Set<Id> contentVersionIds = new Set<Id>();
        for (ContentDocumentLink cdl : cdls) {
            Id cvId = cdl.ContentDocument.LatestPublishedVersionId;
            contentVersionIds.add(cvId);
            contentVersionToFormVersion.put(cvId, cdl.LinkedEntityId);
        }

        // Query ContentVersion bodies one at a time to limit heap usage
        for (Id cvId : contentVersionIds) {
            ContentVersion cv = [
                SELECT Id, VersionData
                FROM ContentVersion
                WHERE Id = :cvId
            ];
            Id formVersionId = contentVersionToFormVersion.get(cv.Id);
            List<axsy_forms__Form_Response__c> relatedResponses
                = responsesByVersion.get(formVersionId);
            if (relatedResponses == null || relatedResponses.isEmpty()) {
                continue;
            }

            // All related responses share the same Form, so use the first to get form ID
            Id formId = relatedResponses[0].axsy_forms__Form__c;
            Set<String> internalSections = internalSectionsByForm.get(formId);
            if (internalSections == null || internalSections.isEmpty()) {
                continue;
            }

            // Parse the Form Version JSON
            Set<String> collectedIds;
            try {
                String jsonBody = cv.VersionData.toString();
                collectedIds = parseVersionJsonForIds(jsonBody, internalSections);
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN,
                    'FormResponseSanitiserHandler: Failed to parse Form Version JSON for version '
                    + formVersionId + ': ' + e.getMessage());
                continue;
            }

            // Apply collected IDs to all responses using this version
            for (axsy_forms__Form_Response__c r : relatedResponses) {
                idsToStripByResponse.get(r.Id).addAll(collectedIds);
            }
        }
    }

    private static Set<String> parseVersionJsonForIds(
        String jsonBody, Set<String> internalSectionNames
    ) {
        Set<String> ids = new Set<String>();

        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
        Map<String, Object> sections = (Map<String, Object>) root.get('sections');
        if (sections == null) {
            return ids;
        }

        for (String sectionId : sections.keySet()) {
            Map<String, Object> section = (Map<String, Object>) sections.get(sectionId);
            String sectionName = (String) section.get('name');

            if (sectionName != null && internalSectionNames.contains(sectionName.trim().toLowerCase())) {
                // Collect the section ID itself
                ids.add(sectionId);

                // Collect all element IDs from ESAs
                Map<String, Object> esas
                    = (Map<String, Object>) section.get('elementSectionAssociations');
                if (esas != null) {
                    for (String esaId : esas.keySet()) {
                        Map<String, Object> esa = (Map<String, Object>) esas.get(esaId);
                        String elementId = (String) esa.get('elementId');
                        if (elementId != null) {
                            ids.add(elementId);
                        }
                    }
                }
            }
        }

        return ids;
    }

    // ---- Step 3b: Draft (junction object) path ----

    private static void collectIdsFromJunctionObjects(
        List<axsy_forms__Form_Response__c> responses,
        Map<Id, Set<String>> internalSectionsByForm,
        Map<Id, Set<String>> idsToStripByResponse
    ) {
        // Deduplicate: multiple responses may share the same Form
        Map<Id, List<axsy_forms__Form_Response__c>> responsesByForm
            = new Map<Id, List<axsy_forms__Form_Response__c>>();
        for (axsy_forms__Form_Response__c r : responses) {
            Id formId = r.axsy_forms__Form__c;
            if (!responsesByForm.containsKey(formId)) {
                responsesByForm.put(formId, new List<axsy_forms__Form_Response__c>());
            }
            responsesByForm.get(formId).add(r);
        }

        Set<Id> formIds = responsesByForm.keySet();

        // Query FSA -> Section
        List<axsy_forms__Form_Section_Association__c> fsas = [
            SELECT axsy_forms__Form__c,
                   axsy_forms__Form_Section__c,
                   axsy_forms__Form_Section__r.Name
            FROM axsy_forms__Form_Section_Association__c
            WHERE axsy_forms__Form__c IN :formIds
        ];

        // Filter to matching sections and collect section IDs
        // formId -> set of collected IDs (sections + elements)
        Map<Id, Set<String>> collectedIdsByForm = new Map<Id, Set<String>>();
        Set<Id> matchingSectionIds = new Set<Id>();

        for (axsy_forms__Form_Section_Association__c fsa : fsas) {
            Id formId = fsa.axsy_forms__Form__c;
            Set<String> internalNames = internalSectionsByForm.get(formId);
            if (internalNames == null) {
                continue;
            }

            String sectionName = fsa.axsy_forms__Form_Section__r.Name;
            if (sectionName != null && internalNames.contains(sectionName.trim().toLowerCase())) {
                matchingSectionIds.add(fsa.axsy_forms__Form_Section__c);

                if (!collectedIdsByForm.containsKey(formId)) {
                    collectedIdsByForm.put(formId, new Set<String>());
                }
                collectedIdsByForm.get(formId).add((String) fsa.axsy_forms__Form_Section__c);
            }
        }

        if (matchingSectionIds.isEmpty()) {
            return;
        }

        // Query ESA -> Element for matching sections
        List<axsy_forms__Form_Section_Element_Association__c> esas = [
            SELECT axsy_forms__Form_Section__c, axsy_forms__Form_Element__c
            FROM axsy_forms__Form_Section_Element_Association__c
            WHERE axsy_forms__Form_Section__c IN :matchingSectionIds
        ];

        // Build sectionId -> formId reverse lookup
        Map<Id, Id> sectionToForm = new Map<Id, Id>();
        for (axsy_forms__Form_Section_Association__c fsa : fsas) {
            if (matchingSectionIds.contains(fsa.axsy_forms__Form_Section__c)) {
                sectionToForm.put(fsa.axsy_forms__Form_Section__c, fsa.axsy_forms__Form__c);
            }
        }

        for (axsy_forms__Form_Section_Element_Association__c esa : esas) {
            Id formId = sectionToForm.get(esa.axsy_forms__Form_Section__c);
            if (formId != null && collectedIdsByForm.containsKey(formId)) {
                collectedIdsByForm.get(formId)
                    .add((String) esa.axsy_forms__Form_Element__c);
            }
        }

        // Apply collected IDs to responses
        for (Id formId : collectedIdsByForm.keySet()) {
            Set<String> ids = collectedIdsByForm.get(formId);
            List<axsy_forms__Form_Response__c> relatedResponses = responsesByForm.get(formId);
            if (relatedResponses != null) {
                for (axsy_forms__Form_Response__c r : relatedResponses) {
                    idsToStripByResponse.get(r.Id).addAll(ids);
                }
            }
        }
    }

    // ---- Step 4: Retrieve response data ----

    private static Map<Id, String> getResponseData(
        List<axsy_forms__Form_Response__c> responses
    ) {
        Set<Id> responseIds = new Set<Id>();
        Map<Id, String> resultMap = new Map<Id, String>();

        for (axsy_forms__Form_Response__c r : responses) {
            responseIds.add(r.Id);
            // Default to the field value; may be overridden by content document
            resultMap.put(r.Id, r.axsy_forms__Response_Data__c);
        }

        // Check for overflow content documents
        List<ContentDocumentLink> cdls = [
            SELECT ContentDocument.LatestPublishedVersionId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :responseIds
                AND ContentDocument.Title LIKE 'form_response_%'
                AND ContentDocument.FileExtension = 'json'
        ];

        if (cdls.isEmpty()) {
            return resultMap;
        }

        Map<Id, Id> contentVersionToResponse = new Map<Id, Id>();
        Set<Id> contentVersionIds = new Set<Id>();
        for (ContentDocumentLink cdl : cdls) {
            Id cvId = cdl.ContentDocument.LatestPublishedVersionId;
            contentVersionIds.add(cvId);
            contentVersionToResponse.put(cvId, cdl.LinkedEntityId);
        }

        // Query ContentVersion bodies one at a time to limit heap usage
        for (Id cvId : contentVersionIds) {
            ContentVersion cv = [
                SELECT Id, VersionData
                FROM ContentVersion
                WHERE Id = :cvId
            ];
            Id responseId = contentVersionToResponse.get(cv.Id);
            if (responseId != null) {
                try {
                    resultMap.put(responseId, cv.VersionData.toString());
                } catch (Exception e) {
                    System.debug(LoggingLevel.WARN,
                        'FormResponseSanitiserHandler: Failed to read content document for response '
                        + responseId + ': ' + e.getMessage());
                }
            }
        }

        return resultMap;
    }

    // ---- Step 5: Strip keys ----

    private static String stripKeys(String jsonData, Set<String> keysToRemove) {
        if (String.isBlank(jsonData) || keysToRemove == null || keysToRemove.isEmpty()) {
            return jsonData;
        }

        try {
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
            for (String key : keysToRemove) {
                parsed.remove(key);
            }
            return JSON.serialize(parsed);
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN,
                'FormResponseSanitiserHandler: Failed to parse response JSON: '
                + e.getMessage());
            return jsonData;
        }
    }

    // ---- Step 6: Clone and upsert copies ----

    private static void cloneAndUpsertCopies(
        List<axsy_forms__Form_Response__c> originals,
        Map<Id, String> sanitisedJsonMap,
        List<String> fieldNames
    ) {
        Set<Id> originalIds = new Set<Id>();
        for (axsy_forms__Form_Response__c r : originals) {
            originalIds.add(r.Id);
        }

        // Query existing customer copies keyed by original Id
        Map<Id, axsy_forms__Form_Response__c> existingCopyByOriginal
            = new Map<Id, axsy_forms__Form_Response__c>();
        for (axsy_forms__Form_Response__c copy : [
            SELECT Id, Original_Form_Response__c
            FROM axsy_forms__Form_Response__c
            WHERE Original_Form_Response__c IN :originalIds
        ]) {
            existingCopyByOriginal.put(copy.Original_Form_Response__c, copy);
        }

        List<axsy_forms__Form_Response__c> toInsert = new List<axsy_forms__Form_Response__c>();
        List<axsy_forms__Form_Response__c> toUpdate = new List<axsy_forms__Form_Response__c>();
        Map<Integer, String> overflowInserts = new Map<Integer, String>();
        Map<Id, String> overflowUpdates = new Map<Id, String>();
        Set<Id> copiesNowWithoutOverflow = new Set<Id>();
        List<String> updateFieldNames = getUpdateableFieldNames();

        for (axsy_forms__Form_Response__c original : originals) {
            String sanitisedJson = sanitisedJsonMap.get(original.Id);
            axsy_forms__Form_Response__c existingCopy = existingCopyByOriginal.get(original.Id);
            Boolean isUpdate = (existingCopy != null);

            axsy_forms__Form_Response__c copyRecord;
            if (isUpdate) {
                copyRecord = new axsy_forms__Form_Response__c(Id = existingCopy.Id);
                for (String fieldName : updateFieldNames) {
                    copyRecord.put(fieldName, original.get(fieldName));
                }
            } else {
                copyRecord = new axsy_forms__Form_Response__c();
                for (String fieldName : fieldNames) {
                    copyRecord.put(fieldName, original.get(fieldName));
                }
            }

            // Set control fields
            copyRecord.put('Customer_Visible__c', true);
            copyRecord.put('Original_Form_Response__c', original.Id);
            copyRecord.put('Original_Response_Key__c', (String) original.Id);
            copyRecord.put('axsy_forms__Status__c', 'Customer Ready');

            // Handle response data
            Boolean needsOverflow = (sanitisedJson != null
                && sanitisedJson.length() > RESPONSE_DATA_MAX_LENGTH);

            // Set expected attachment count: file elements + overflow doc if present
            Integer expectedAttachments = collectFileTitles(sanitisedJson).size();
            if (needsOverflow) {
                expectedAttachments++;
            }
            copyRecord.put('axsy_forms__Expected_Attachment_Count__c', expectedAttachments);

            if (needsOverflow) {
                copyRecord.put('axsy_forms__Response_Data__c', null);
                if (isUpdate) {
                    overflowUpdates.put(existingCopy.Id, sanitisedJson);
                } else {
                    overflowInserts.put(toInsert.size(), sanitisedJson);
                }
            } else {
                copyRecord.put('axsy_forms__Response_Data__c', sanitisedJson);
                if (isUpdate) {
                    copiesNowWithoutOverflow.add(existingCopy.Id);
                }
            }

            if (isUpdate) {
                toUpdate.add(copyRecord);
            } else {
                toInsert.add(copyRecord);
            }
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
        // Temporarily revert existing copies to Draft so the validation rule
        // (PRIORVALUE(Status__c) = 'Customer Ready') does not block the update.
        // The managed-package trigger only allows Response_Data__c updates when
        // the record is in Draft status.
        if (!toUpdate.isEmpty()) {
            List<axsy_forms__Form_Response__c> statusResets = new List<axsy_forms__Form_Response__c>();
            for (axsy_forms__Form_Response__c copy : toUpdate) {
                statusResets.add(new axsy_forms__Form_Response__c(
                    Id = copy.Id,
                    axsy_forms__Status__c = 'Draft'
                ));
            }
            update statusResets;
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }

        // Overflow content document reconciliation for updated copies
        List<ContentVersion> contentVersions = new List<ContentVersion>();

        // Insert-path overflow (same as before)
        for (Integer idx : overflowInserts.keySet()) {
            axsy_forms__Form_Response__c insertedCopy = toInsert[idx];
            contentVersions.add(buildContentVersion(
                insertedCopy.Id,
                'form_response_' + insertedCopy.Id,
                overflowInserts.get(idx)
            ));
        }

        // Update-path: query existing overflow docs on updated copies
        Set<Id> updatedCopyIds = new Set<Id>();
        for (axsy_forms__Form_Response__c u : toUpdate) {
            updatedCopyIds.add(u.Id);
        }

        Set<Id> overflowDocsToDelete = new Set<Id>();
        if (!updatedCopyIds.isEmpty()) {
            for (ContentDocumentLink cdl : [
                SELECT LinkedEntityId, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :updatedCopyIds
                    AND ContentDocument.Title LIKE 'form_response_%'
                    AND ContentDocument.FileExtension = 'json'
            ]) {
                // Delete old overflow doc if copy still needs overflow (replace)
                // or no longer needs overflow (cleanup)
                if (overflowUpdates.containsKey(cdl.LinkedEntityId)
                    || copiesNowWithoutOverflow.contains(cdl.LinkedEntityId)) {
                    overflowDocsToDelete.add(cdl.ContentDocumentId);
                }
            }
        }

        if (!overflowDocsToDelete.isEmpty()) {
            delete [SELECT Id FROM ContentDocument WHERE Id IN :overflowDocsToDelete];
        }

        // Insert new overflow content versions (for both insert and update paths)
        for (Id copyId : overflowUpdates.keySet()) {
            contentVersions.add(buildContentVersion(
                copyId,
                'form_response_' + copyId,
                overflowUpdates.get(copyId)
            ));
        }

        if (!contentVersions.isEmpty()) {
            insert contentVersions;
        }

        // Step 7: copy file CDLs to customer copies
        Map<Id, Id> originalToCopyId = new Map<Id, Id>();
        for (axsy_forms__Form_Response__c inserted : toInsert) {
            originalToCopyId.put(
                (Id) inserted.get('Original_Form_Response__c'),
                inserted.Id
            );
        }
        for (axsy_forms__Form_Response__c updated : toUpdate) {
            originalToCopyId.put(
                (Id) updated.get('Original_Form_Response__c'),
                updated.Id
            );
        }
        copyFilesToCustomerCopies(originalToCopyId, sanitisedJsonMap);
    }

    private static ContentVersion buildContentVersion(
        Id linkedEntityId, String title, String jsonBody
    ) {
        ContentVersion cv = new ContentVersion();
        cv.Title = title;
        cv.PathOnClient = title + '.json';
        cv.VersionData = Blob.valueOf(jsonBody);
        cv.FirstPublishLocationId = linkedEntityId;
        return cv;
    }

    // ---- Step 7: Copy file CDLs to customer copies ----

    private static void copyFilesToCustomerCopies(
        Map<Id, Id> originalToCopyId,
        Map<Id, String> sanitisedJsonMap
    ) {
        if (originalToCopyId.isEmpty()) {
            return;
        }

        Set<Id> allCopyIds = new Set<Id>(originalToCopyId.values());

        // Query existing non-overflow CDLs on ALL copies (needed for stale CDL cleanup)
        Map<Id, Set<Id>> existingCdlsByCopy = new Map<Id, Set<Id>>();
        List<ContentDocumentLink> existingCopyCdls = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :allCopyIds
                AND (NOT ContentDocument.Title LIKE 'form_response_%')
        ];
        for (ContentDocumentLink cdl : existingCopyCdls) {
            if (!existingCdlsByCopy.containsKey(cdl.LinkedEntityId)) {
                existingCdlsByCopy.put(cdl.LinkedEntityId, new Set<Id>());
            }
            existingCdlsByCopy.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
        }

        // Collect file titles from each sanitised JSON
        Map<Id, Set<String>> fileTitlesByOriginal = new Map<Id, Set<String>>();
        Set<Id> originalsWithFiles = new Set<Id>();

        for (Id originalId : originalToCopyId.keySet()) {
            Set<String> titles = new Set<String>(collectFileTitles(sanitisedJsonMap.get(originalId)));
            fileTitlesByOriginal.put(originalId, titles);
            if (!titles.isEmpty()) {
                originalsWithFiles.add(originalId);
            }
        }

        // Build the set of required ContentDocumentIds per copy
        Map<Id, Set<Id>> requiredDocIdsByCopy = new Map<Id, Set<Id>>();
        Map<Id, List<Id>> contentDocIdsByOriginal = new Map<Id, List<Id>>();

        if (!originalsWithFiles.isEmpty()) {
            // Query CDLs on original responses, excluding overflow JSON files
            List<ContentDocumentLink> originalCdls = [
                SELECT ContentDocumentId, LinkedEntityId, ContentDocument.Title
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :originalsWithFiles
                    AND (NOT ContentDocument.Title LIKE 'form_response_%')
            ];

            // Filter CDLs to those whose title matches a referenced file
            for (ContentDocumentLink cdl : originalCdls) {
                Id origId = cdl.LinkedEntityId;
                Set<String> requiredTitles = fileTitlesByOriginal.get(origId);
                if (requiredTitles != null && requiredTitles.contains(cdl.ContentDocument.Title)) {
                    if (!contentDocIdsByOriginal.containsKey(origId)) {
                        contentDocIdsByOriginal.put(origId, new List<Id>());
                    }
                    contentDocIdsByOriginal.get(origId).add(cdl.ContentDocumentId);
                }
            }

            // Map required docs per copy for stale CDL detection
            for (Id origId : contentDocIdsByOriginal.keySet()) {
                Id copyId = originalToCopyId.get(origId);
                requiredDocIdsByCopy.put(copyId, new Set<Id>(contentDocIdsByOriginal.get(origId)));
            }
        }

        // Insert new CDLs for files not yet linked to copies
        List<ContentDocumentLink> cdlsToInsert = new List<ContentDocumentLink>();
        for (Id origId : contentDocIdsByOriginal.keySet()) {
            Id copyId = originalToCopyId.get(origId);
            List<Id> contentDocIds = contentDocIdsByOriginal.get(origId);
            Set<Id> alreadyLinked = existingCdlsByCopy.get(copyId);

            for (Id contentDocId : contentDocIds) {
                if (alreadyLinked != null && alreadyLinked.contains(contentDocId)) {
                    continue;
                }
                cdlsToInsert.add(new ContentDocumentLink(
                    ContentDocumentId = contentDocId,
                    LinkedEntityId = copyId,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                ));
            }
        }

        if (!cdlsToInsert.isEmpty()) {
            insert cdlsToInsert;
        }

        // Delete stale CDLs: files on the copy that are no longer referenced
        List<ContentDocumentLink> cdlsToDelete = new List<ContentDocumentLink>();
        for (ContentDocumentLink cdl : existingCopyCdls) {
            Id copyId = cdl.LinkedEntityId;
            Set<Id> requiredDocs = requiredDocIdsByCopy.get(copyId);
            if (requiredDocs == null || !requiredDocs.contains(cdl.ContentDocumentId)) {
                cdlsToDelete.add(cdl);
            }
        }

        if (!cdlsToDelete.isEmpty()) {
            delete cdlsToDelete;
        }
    }

    private static List<String> collectFileTitles(String jsonData) {
        List<String> titles = new List<String>();
        if (String.isBlank(jsonData)) {
            return titles;
        }

        try {
            Object parsed = JSON.deserializeUntyped(jsonData);
            collectFileTitlesRecursive(parsed, titles);
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN,
                'FormResponseSanitiserHandler: Failed to collect file titles: '
                + e.getMessage());
        }

        return titles;
    }

    private static void collectFileTitlesRecursive(Object node, List<String> titles) {
        if (node instanceof Map<String, Object>) {
            Map<String, Object> mapNode = (Map<String, Object>) node;

            // Check if this object is a file descriptor (has a non-blank title)
            Object titleObj = mapNode.get('title');
            if (titleObj instanceof String && String.isNotBlank((String) titleObj)) {
                titles.add((String) titleObj);
                return;
            }

            // Otherwise recurse into child values
            for (Object child : mapNode.values()) {
                collectFileTitlesRecursive(child, titles);
            }
        } else if (node instanceof List<Object>) {
            for (Object item : (List<Object>) node) {
                collectFileTitlesRecursive(item, titles);
            }
        }
    }

    // ---- Utility: writable field names ----

    private static List<String> getWritableFieldNames() {
        if (writableFieldNamesCache != null) {
            return writableFieldNamesCache;
        }

        writableFieldNamesCache = new List<String>();
        Map<String, Schema.SObjectField> fieldMap
            = Schema.SObjectType.axsy_forms__Form_Response__c.fields.getMap();

        Set<String> excludeFields = new Set<String>{
            'customer_visible__c',
            'original_form_response__c',
            'axsy_forms__status__c',
            'original_response_key__c'
        };

        for (String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult dfr = fieldMap.get(fieldName).getDescribe();
            Schema.DisplayType fieldType = dfr.getType();
            if (dfr.isPermissionable()
                && !dfr.isCalculated()
                && !dfr.isAutoNumber()
                && fieldType != Schema.DisplayType.LOCATION
                && fieldType != Schema.DisplayType.ADDRESS
                && !excludeFields.contains(fieldName.toLowerCase())) {
                writableFieldNamesCache.add(fieldName);
            }
        }

        return writableFieldNamesCache;
    }

    private static List<String> getUpdateableFieldNames() {
        if (updateableFieldNamesCache != null) {
            return updateableFieldNamesCache;
        }

        updateableFieldNamesCache = new List<String>();
        Map<String, Schema.SObjectField> fieldMap
            = Schema.SObjectType.axsy_forms__Form_Response__c.fields.getMap();

        Set<String> excludeFields = new Set<String>{
            'customer_visible__c',
            'original_form_response__c',
            'axsy_forms__status__c',
            'original_response_key__c'
        };

        for (String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult dfr = fieldMap.get(fieldName).getDescribe();
            Schema.DisplayType fieldType = dfr.getType();
            if (dfr.isPermissionable()
                && !dfr.isCalculated()
                && !dfr.isAutoNumber()
                && fieldType != Schema.DisplayType.LOCATION
                && fieldType != Schema.DisplayType.ADDRESS
                && !excludeFields.contains(fieldName.toLowerCase())) {
                updateableFieldNamesCache.add(fieldName);
            }
        }

        return updateableFieldNamesCache;
    }
}