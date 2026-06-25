public with sharing class displaycontractfilters {
 
 @AuraEnabled
 public static List <Non_Meter_Items__c> fetchContracts(String searchKeyWord) {
  String searchKey = '%'+ searchKeyWord + '%';
  List <Non_Meter_Items__c> returnList = new List <Non_Meter_Items__c> ();
  List <Non_Meter_Items__c> lstOfContracts = [select id, Name, np_Make__c, Supplier__r.Name, Supplier_Price__c,	Size__c, Filter_Category__c, amalgam_for_search__c, np_Model__c, Pressure_Tier__c,  Classification__c from Non_Meter_Items__c
                                   where amalgam_for_search__c LIKE: searchKey AND Classification__c = 'Filter'];
 
  for (Non_Meter_Items__c Con: lstOfContracts) {
   returnList.add(Con);
  }
  return returnList;
 }
}