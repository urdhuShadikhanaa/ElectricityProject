// ************************************************************************************************
//   Name : NG_SRE_CaseTriggerHandlerTest
//   Created By : SRE Team - Wipro
//   Created Date : 26/11/2024
//   Description : Test Class to code coverage for NG_CaseTriggerHandler
// ************************************************************************************************
@isTest
public class NG_SRE_CaseTriggerHandlerTest {
    
    // Test the handlingWithInsertAndUpdate method
    @isTest
    static void testHandlingWithInsertAndUpdate() {
        // Step 1: Create test data
        RecordType caseRecordTypeId = [select id,Name,SobjectType from RecordType where Name='stock' and SobjectType = 'Case']; 
       

        // Create a Stock_Order__c record
        Stock_Order__c stockOrder = new Stock_Order__c(
            Name = 'SO-001',            
            Job_Reference_if_applicable__c = 'REF-001'
        );
        insert stockOrder;

        // Create a Case record with the subject matching the stock order name
        Case caseRecord = new Case();
            caseRecord.Subject = 'SO-001';  // Should match Stock Order name
            caseRecord.RecordTypeId = caseRecordTypeId.Id; // 'stock' RecordType
            caseRecord.Origin = 'Phone';
        
        insert caseRecord;

        // Step 2: Invoke the method
        Test.startTest();
        List<Case> caseList = [SELECT Id, Subject, RecordTypeId,Origin FROM Case WHERE Id = :caseRecord.Id];
        NG_SRE_CaseTriggerHandler.handlingWithInsertAndUpdate(caseList);
        Test.stopTest();

        // Step 3: Assert the results

        // Verify the Stock Order is linked to the Case via the Stock_Order__c field
        Case updatedCase = [SELECT Id, Stock_Order__c,Origin FROM Case WHERE Id = :caseRecord.Id];
        System.assertNotEquals(null, updatedCase.Stock_Order__c, 'Stock Order should be linked to the Case');
        System.assertEquals(stockOrder.Id, updatedCase.Stock_Order__c, 'Stock Order Id should match');

        // Verify that the Stock Order is updated with the Case reference
        Stock_Order__c updatedStockOrder = [SELECT Id, Case__c FROM Stock_Order__c WHERE Id = :stockOrder.Id];
        System.assertNotEquals(null, updatedStockOrder.Case__c, 'Stock Order should have the Case reference');
        System.assertEquals(caseRecord.Id, updatedStockOrder.Case__c, 'Case Id should match in Stock Order');
    }

    // Test the method when no matching Stock Orders exist
    @isTest
    static void testHandlingWithNoMatchingStockOrder() {
       
        RecordType caseRecordTypeId = [select id,Name,SobjectType from RecordType where Name='stock' and SobjectType = 'Case']; 

        // Create a Case record with no matching Stock Order
        Case caseRecord = new Case(
            Subject = 'NonExistingStockOrder',  // Should not match any Stock Order
            RecordTypeId = caseRecordTypeId.Id,  // 'stock' RecordType
            Origin = 'Phone'
        );
        insert caseRecord;

        // Step 2: Invoke the method
        Test.startTest();
        List<Case> caseList = [SELECT Id, Subject, RecordTypeId,Origin FROM Case WHERE Id = :caseRecord.Id];
        NG_SRE_CaseTriggerHandler.handlingWithInsertAndUpdate(caseList);
        Test.stopTest();

        // Step 3: Assert the results

        // Verify that no Stock Order is linked to the Case
        Case updatedCase = [SELECT Id, Stock_Order__c,Origin FROM Case WHERE Id = :caseRecord.Id];
        System.assertEquals(null, updatedCase.Stock_Order__c, 'Stock Order should not be linked to the Case');
    }
}