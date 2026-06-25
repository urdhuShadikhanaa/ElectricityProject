public with sharing class NGMCP_Complaint_MetadataService{
   @AuraEnabled(cacheable=true)
   public static List<Map<String, Object>> getComplaintQuestions() {
       List<Map<String, Object>> result = new List<Map<String, Object>>();
       for (NGMCP_Complaint_Question__mdt q : [
           SELECT DeveloperName, Question_Label__c, Input_Type__c, Picklist_Values__c, Is_Required__c FROM NGMCP_Complaint_Question__mdt ORDER BY DeveloperName
       ]) {
           Map<String, Object> record = new Map<String, Object>();
           record.put('label', q.Question_Label__c);
           //record.put('apiName', q.Field_API_Name__c);
           record.put('type', q.Input_Type__c);
           record.put('required', q.Is_Required__c);
           List<String> picklistOptions = new List<String>();
if ((q.Input_Type__c == 'Picklist' || q.Input_Type__c == 'Radio') && String.isNotBlank(q.Picklist_Values__c)) {
   // Handles commas, semicolons, and line breaks
   for (String val : q.Picklist_Values__c.split('[,;\\n]+')) {
       if (String.isNotBlank(val)) {
           picklistOptions.add(val.trim());
       }
   }
}
record.put('picklistValues', picklistOptions);
           result.add(record);
       }
       return result;
   }
   @AuraEnabled
   public static Id createComplaintCase(Map<String, Object> inputValues) {
       Case c = new Case();
       c.Origin = 'Portal';
       c.Status = 'New';
       c.Subject = (String) inputValues.get('Subject');
       c.Description = (String) inputValues.get('Description');
       // Dynamically map other values
       for (String key : inputValues.keySet()) {
           if (Schema.sObjectType.Case.fields.getMap().containsKey(key)) {
               try {
                   c.put(key, inputValues.get(key));
               } catch (Exception e) {
                   System.debug('Field mapping skipped for ' + key + ': ' + e.getMessage());
               }
           }
       }
       insert c;
       return c.Id;
   }
}