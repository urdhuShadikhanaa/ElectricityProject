public with sharing class HolidayController {
    @AuraEnabled(cacheable=true)
    public static List<BankHoliday_mdt__mdt> getBankHolidays() {
        return [SELECT Holiday_Date__c, Holiday_Name__c FROM BankHoliday_mdt__mdt];
    }
}