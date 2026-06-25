/*
** Description: This class is used in CRM**
*/
public with sharing class displaymprnsummary {

 
 @AuraEnabled
 public static List <MPRN_Summary__c> fetchMPRNS(String searchKeyWord) {
  String searchKey = searchKeyWord + '%';
  List <MPRN_Summary__c> returnList = new List <MPRN_Summary__c> ();
  List <MPRN_Summary__c> lstMPRNS = [select id, Name, 	Most_Recent_Job__c, Gas_Supplier_of_most_recent_job__c,Related_Complaints__c,Related_Complaints__r.CRM_Case_Reference_Number_HyperLink__c, Work_Order__c,Work_Order__r.WorkOrderNumber, Most_Recent_Complaint_Ref__c,	Current_Meter_Model__c, 	Current_MSN__c, text_reference__c, Address__c from MPRN_Summary__c
                                   where Name LIKE: searchKey LIMIT 1000];
 
  for (MPRN_Summary__c MS: lstMPRNS) {
   returnList.add(MS);
  }
  return returnList;
 }
}