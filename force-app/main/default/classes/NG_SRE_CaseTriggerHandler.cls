// ************************************************************************************************
//   Name : NG_SRE_CaseTriggerHandler
//   Created By : SRE Team - Wipro
//   Created Date : 26/11/2024
//   Description : Class to handle all trigger scenarios
// ************************************************************************************************
public class NG_SRE_CaseTriggerHandler{
    
    public static void handlingWithInsertAndUpdate(List<Case> listCase) {
        // Map to hold Stock Order Name(Order Reference) -> Stock Order Id
        Map<String, Id> stockNameToIdMap = new Map<String, Id>();
        // get Case RecordType
        RecordType caseRecordTypeId = [select id,Name,SobjectType from RecordType where Name='stock' and SobjectType = 'Case']; 
        
        // Collect Case Subjects
        List<String> caseSubjects = new List<String>();
        for (Case caseDetails : listCase) {
            if (caseDetails.Subject != null && (caseDetails.RecordTypeId == caseRecordTypeId.Id && caseDetails.Origin != 'Email - Non Standard' && caseDetails.Origin != 'Email - Siteworks')) {
                caseSubjects.add(caseDetails.Subject);                
            }
        }
        
        // Bulk query to retrieve Stock Orders matching Case Subjects
        List<Stock_Order__c> matchingStockOrders = [SELECT Id, Name, Job_Reference_if_applicable__c,np_Sub_Status__c FROM Stock_Order__c WHERE  np_Sub_Status__c !='Cancelled - Missing Data' AND np_Sub_Status__c !='Receipted' AND np_Sub_Status__c !='Cancelled - By Originator' AND np_Sub_Status__c !='Cancelled - Other' AND (Name LIKE :caseSubjects OR Job_Reference_if_applicable__c IN :caseSubjects)];
               
        for (Stock_Order__c stock : matchingStockOrders) {           
            stockNameToIdMap.put(stock.Name, stock.Id);          
        }
        
        // Link Cases to Stock Orders and prepare Stock Order updates
        List<Stock_Order__c> stockOrdersToUpdate = new List<Stock_Order__c>();
        for (Case caseObj : listCase) {
            if (caseObj.Subject != null && stockNameToIdMap.containsKey(caseObj.Subject)) {
                // Link Case to Stock Order
                caseObj.Stock_Order__c = stockNameToIdMap.get(caseObj.Subject);
                
                // Prepare Stock Order update
                Stock_Order__c stockOrder = new Stock_Order__c(
                    Id = stockNameToIdMap.get(caseObj.Subject),
                    Case__c = caseObj.Id
                );
                stockOrdersToUpdate.add(stockOrder);
            }
        }
        
        // Perform bulk update of Stock Orders
        if (!stockOrdersToUpdate.isEmpty()) {
            update stockOrdersToUpdate;
        }
    }
}