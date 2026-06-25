public with sharing class HolidayService {
    @AuraEnabled(cacheable=true)
    public static List<Date> getHolidaysBetween(Date startDate, Date endDate) {
        if (startDate == null || endDate == null) return new List<Date>();
        if (endDate < startDate) {
            Date tmp = startDate; startDate = endDate; endDate = tmp;
        }
        List<Holiday> hols = [SELECT ActivityDate FROM Holiday WHERE ActivityDate >= :Date.today() With USER_MODE];
            List<Date> result = new List<Date>();
        for (Holiday h : hols) {
            if (h.ActivityDate != null) result.add(h.ActivityDate);
        }
        return result;
    }
}