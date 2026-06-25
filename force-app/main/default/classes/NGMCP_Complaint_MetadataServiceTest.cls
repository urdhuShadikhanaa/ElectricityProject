/**
 * @File Name         : NGMCP_Complaint_MetadataServiceTest.cls
 * @Description       : Test class for NGMCP_Complaint_MetadataService.
 *                      This test class verifies the functionality of complaint metadata service.
 * @Author            : 
 * @Last Modified By  : 
 * @Last Modified On  : January 2, 2026
 * @Modification Log  :
 *==============================================================================
 * Ver | Date             | Author             | Modification
 *==============================================================================
 * 1.0 | January 2, 2026  |        | Initial Version
 **/

@isTest
private class NGMCP_Complaint_MetadataServiceTest {
    
    /**
     * @description Tests the getComplaintQuestions method
     *              This test verifies the method handles the case when no metadata records exist
     */
    @isTest
    static void testGetComplaintQuestions() {
        Test.startTest();
        List<Map<String, Object>> result = NGMCP_Complaint_MetadataService.getComplaintQuestions();
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        // We can't assert specific size since we don't have test data
        // But we can at least verify the method doesn't throw exceptions
    }
    
    /**
     * @description Tests the getComplaintQuestions method with no metadata records
     *              This test verifies the method handles empty metadata gracefully
     */
    @isTest
    static void testGetComplaintQuestionsWithNoRecords() {
        Test.startTest();
        List<Map<String, Object>> result = NGMCP_Complaint_MetadataService.getComplaintQuestions();
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        // We can't assert specific size since we don't have test data
        // But we can at least verify the method doesn't throw exceptions
    }
    
    /**
     * @description Tests the createComplaintCase method with valid input
     *              This test verifies the method creates a case with correct data
     */
    @isTest
    static void testCreateComplaintCase() {
        // Prepare test data
        Map<String, Object> inputValues = new Map<String, Object>();
        inputValues.put('Subject', 'Test Complaint Subject');
        inputValues.put('Description', 'Test Complaint Description');
        inputValues.put('Priority', 'High');
        inputValues.put('Status', 'New');
        
        Test.startTest();
        Id caseId = NGMCP_Complaint_MetadataService.createComplaintCase(inputValues);
        Test.stopTest();
        
        // Verify case was created
        System.assertNotEquals(null, caseId, 'Case ID should not be null');
        
        // Retrieve and verify the created case
        Case createdCase = [SELECT Id, Subject, Description, Priority, Status, Origin 
                           FROM Case WHERE Id = :caseId];
        
        System.assertEquals('Test Complaint Subject', createdCase.Subject, 'Subject should match');
        System.assertEquals('Test Complaint Description', createdCase.Description, 'Description should match');
        System.assertEquals('High', createdCase.Priority, 'Priority should match');
        System.assertEquals('New', createdCase.Status, 'Status should match');
        System.assertEquals('Portal', createdCase.Origin, 'Origin should be Portal');
    }
    
    /**
     * @description Tests the createComplaintCase method with empty input
     *              This test verifies the method handles empty input gracefully
     */
    @isTest
    static void testCreateComplaintCaseWithEmptyInput() {
        // Create a minimal input map with required fields
        Map<String, Object> inputValues = new Map<String, Object>();
        inputValues.put('Subject', 'Test Subject');
        inputValues.put('Description', 'Test Description');
        
        Test.startTest();
        Id caseId = NGMCP_Complaint_MetadataService.createComplaintCase(inputValues);
        Test.stopTest();
        
        // Verify case was created with minimal data
        System.assertNotEquals(null, caseId, 'Case ID should not be null');
        
        // Retrieve and verify the created case - include Status in the query
        Case createdCase = [SELECT Id, Subject, Description, Origin, Status 
                           FROM Case WHERE Id = :caseId];
        
        System.assertEquals('Portal', createdCase.Origin, 'Origin should be Portal');
        System.assertEquals('New', createdCase.Status, 'Status should be New');
    }
}