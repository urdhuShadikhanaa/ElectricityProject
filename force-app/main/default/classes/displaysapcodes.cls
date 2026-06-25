public with sharing class displaysapcodes {
 
 @AuraEnabled
 public static List <SAP_Codes_and_Items__c> fetchSAPCodes(String searchKeyWord) {
  String searchKey = searchKeyWord + '%';
  List <SAP_Codes_and_Items__c> returnList = new List <SAP_Codes_and_Items__c> ();
  List <SAP_Codes_and_Items__c> lstOfSAPCodes = [select id, Name, Description__c from SAP_Codes_and_Items__c
                                   where Name LIKE: searchKey LIMIT 500];
 
  for (SAP_Codes_and_Items__c SAP: lstOfSAPCodes) {
   returnList.add(SAP);
  }
  return returnList;
 }
}