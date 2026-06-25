@isTest
public class NGMCP_ComplaintControllerTest {

    @testSetup
    static void setupData() {
        System.assertNotEquals(
            null,
            getComplaintRecordTypeName(),
            'Complaint RecordType must exist before running tests.'
        );
    }

    private static String getComplaintRecordTypeName() {
        List<RecordType> complaintRecordTypes = [
            SELECT Name
            FROM RecordType
            WHERE DeveloperName = 'Complaint'
            AND SObjectType = 'Case'
            LIMIT 1
        ];
        return complaintRecordTypes.isEmpty() ? null : complaintRecordTypes[0].Name;
    }

    private static Map<String, Object> getSampleCaseMap() {
        Map<String, Object> casePayload = new Map<String, Object>();
        casePayload.put('RecordType', getComplaintRecordTypeName());
        casePayload.put('Category__c', 'Request For Information');
        casePayload.put('Sub_Category__c', 'General Query');
        casePayload.put('Residence_Type__c', 'Residential');
        casePayload.put('CRM_MPRN__c', 'MPRN12345');
        casePayload.put('Description', 'Test Description');
        casePayload.put('CRM_House_Name_Number_Site_Name__c', 'House 10');
        casePayload.put('CRM_Street__c', 'Main Street');
        casePayload.put('CRM_City_County__c', 'Hyderabad');
        casePayload.put('CRM_Post_code__c', '500001');
        casePayload.put('CRM_End_Consumer_Name__c', 'John Doe');
        return casePayload;
    }

    private static String getSampleJsonPayload() {
        return JSON.serialize(getSampleCaseMap());
    }

    private static String getBase64ForText(String text) {
        return EncodingUtil.base64Encode(Blob.valueOf(text));
    }

    @isTest
    static void testCreateComplaint_NoFiles() {
        String answers = getSampleJsonPayload();

        Test.startTest();
        String caseNumber = NGMCP_ComplaintController.createComplaint(
            answers,
            new List<String>(),
            new List<String>()
        );
        Test.stopTest();

        System.assertNotEquals(null, caseNumber, 'Case should be created');

        Case createdCase = [
            SELECT Category__c, Sub_Category__c, Residence_Type__c, Origin, Status
            FROM Case
            WHERE CaseNumber = :caseNumber
            LIMIT 1
        ];

        System.assertEquals('Request For Information', createdCase.Category__c);
        System.assertEquals('General Query', createdCase.Sub_Category__c);
        System.assertEquals('Residential', createdCase.Residence_Type__c);
        System.assertEquals('Portal', createdCase.Origin);
        System.assertEquals('New', createdCase.Status);
    }

    @isTest
    static void testCreateComplaint_WithFiles() {
        String answers = getSampleJsonPayload();
        List<String> base64 = new List<String>{ getBase64ForText('FileContent') };
        List<String> names = new List<String>{ 'file1.txt' };

        Test.startTest();
        String caseNumber = NGMCP_ComplaintController.createComplaint(
            answers,
            base64,
            names
        );
        Test.stopTest();

        System.assertNotEquals(null, caseNumber, 'Case should be created');

        Id caseId = [
            SELECT Id
            FROM Case
            WHERE CaseNumber = :caseNumber
            LIMIT 1
        ].Id;

        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :caseId
        ];

        System.assertEquals(1, contentDocumentLinks.size(), 'File should attach successfully');
    }
}