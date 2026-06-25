public class displaycontractreg {
 
 @AuraEnabled
 public static List <Non_Meter_Items__c> fetchContracts(String searchKeyWord) {
  String searchKey = '%'+ searchKeyWord + '%';
  List <Non_Meter_Items__c> returnList = new List <Non_Meter_Items__c> ();
  List <Non_Meter_Items__c> lstOfContracts = [select id, Name, np_Make__c, Supplier__r.Name, amalgam_for_search__c, Supplier_Price__c,Regulator_Valve_Category__c, Regulator_Valve_Classification_1__c, np_Model__c,  Reg_and_Valve_Classification__c from Non_Meter_Items__c
                                   where amalgam_for_search__c LIKE: searchKey AND Reg_and_Valve_Classification__c LIKE '%Regulator%'];
 
  for (Non_Meter_Items__c Con: lstOfContracts) {
   returnList.add(Con);
  }
  return returnList;
 }
}