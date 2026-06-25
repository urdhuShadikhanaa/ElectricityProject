public with sharing class displaycontracthousing {
 
 @AuraEnabled
 public static List <Non_Meter_Items__c> fetchContracts(String searchKeyWord) {
  String searchKey = '%'+ searchKeyWord + '%';
  List <Non_Meter_Items__c> returnList = new List <Non_Meter_Items__c> ();
  List <Non_Meter_Items__c> lstOfContracts = [select id, Name, np_Make__c, Supplier__r.Name, amalgam_for_search__c, Supplier_Price__c,	Mounting__c, Housing_Type__c, np_Model__c, 	For_Meter_Installation_Size__c, Pressure_Tier__c, Classification__c from Non_Meter_Items__c
                                   where amalgam_for_search__c LIKE: searchKey AND Classification__c = 'Housing'];
 
  for (Non_Meter_Items__c Con: lstOfContracts) {
   returnList.add(Con);
  }
  return returnList;
 }
}