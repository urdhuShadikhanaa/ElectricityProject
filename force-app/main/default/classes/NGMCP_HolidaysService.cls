/**
* @description Returns a list of future holiday dates starting from today.
*              Cacheable method – safe for use in LWC wire adapters.
* @return List<Date> List of holiday dates (ActivityDate)
*/
public with sharing class NGMCP_HolidaysService {
    @AuraEnabled(cacheable = true)
    public static List<Date> getHolidaysBetween() {

        // Query only required fields using selective filter
        List<Holiday> holidayRecords = [
            SELECT ActivityDate
            FROM Holiday
            WHERE ActivityDate >= :Date.today()
            AND ActivityDate != NULL
            with USER_MODE
            ORDER BY ActivityDate ASC
        ];

        // Convert to date list
        List<Date> holidayDates = new List<Date>();

        for (Holiday h : holidayRecords) {
            if (h.ActivityDate != null) {
                holidayDates.add(h.ActivityDate);
            }
        }

        return holidayDates;
    }
}