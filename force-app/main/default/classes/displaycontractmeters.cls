public with sharing class displaycontractmeters {
 
 @AuraEnabled
 public static List <Non_Meter_Items__c> fetchContracts(String searchKeyWord) {
  String searchKey = '%'+ searchKeyWord + '%';
  List <Non_Meter_Items__c> returnList = new List <Non_Meter_Items__c> ();
  List <Non_Meter_Items__c> lstOfContracts = [select id, Name, np_Make__c, Supplier__r.Name, Supplier_Price__c,	Flange_Type__c, amalgam_for_search__c, 	np_Alternative_Model_Name_s__c, Face_to_Face_Dimension_mm__c, np_Model__c,	Flange_Size__c, Classification__c from Non_Meter_Items__c
                                   where meter_amalgam_for_search__c LIKE: searchKey AND Classification__c = 'Meter'];
 
  for (Non_Meter_Items__c Con: lstOfContracts) {
   returnList.add(Con);
  }
  return returnList;
 }
}