// CWR_MetadataService.cls
public with sharing class ngmcpChargableJob {
   @AuraEnabled(cacheable=true)
   public static List<Map<String, Object>> getCwrQuestions() {
       List<NGMCP_CWR_Questions__mdt> mdts = [
           SELECT DeveloperName, MasterLabel, Field_API_Name__c, Question_Label__c, Question_Type__c,
                  Picklist_Value__c, Order__c, Required__c, Active__c, Question_Text__c
           FROM NGMCP_CWR_Questions__mdt
           WHERE Active__c = TRUE
           ORDER BY Order__c NULLS LAST
       ];
       List<Map<String, Object>> result = new List<Map<String, Object>>();
       for (NGMCP_CWR_Questions__mdt m : mdts) {
           Map<String, Object> a = new Map<String, Object>();
           a.put('developerName', m.DeveloperName);
           a.put('label', m.Question_Label__c);
           a.put('apiName', m.Field_API_Name__c);
           a.put('type', m.Question_Type__c);
           //a.put('picklistValues',(m.Picklist_Values__c == null)? new List<String>(): new List<String>((List<String>) m.Picklist_Values__c.replaceAll('\\s*\\|\\s*', '|').split('\\|')));
           a.put('required', m.Required__c);
           a.put('questionText', m.Question_Text__c);
           result.add(a);
       }
       return result;
   }
   @AuraEnabled(cacheable=true)
   public static List<Map<String, Object>> getPricesByProductCodes(List<String> productCodes) {
       if (productCodes == null || productCodes.isEmpty()) return new List<Map<String, Object>>();
       // Query custom metadata
       List<Price_Config__mdt> prices = [
           SELECT DeveloperName, MasterLabel, Product_Code__c, Price__c, Active__c
           FROM Price_Config__mdt
           WHERE Active__c = TRUE AND Product_Code__c IN :productCodes
       ];
       List<Map<String, Object>> out = new List<Map<String, Object>>();
       for (Price_Config__mdt p : prices) {
           Map<String, Object> m = new Map<String, Object>();
           m.put('productCode', p.Product_Code__c);
           m.put('price', p.Price__c);
           m.put('label', p.MasterLabel);
           out.add(m);
       }
       return out;
   }
}