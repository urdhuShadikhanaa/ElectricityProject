public with sharing class BankHolidayController {
    @AuraEnabled(cacheable=true)
    public static List<Date> getBankHolidays() {
        List<Date> holidayDates = new List<Date>();
        for (Holiday h : [SELECT ActivityDate FROM Holiday WHERE ActivityDate >= :Date.today()]) {
            holidayDates.add(h.ActivityDate);
        }
        return holidayDates;
    }
}