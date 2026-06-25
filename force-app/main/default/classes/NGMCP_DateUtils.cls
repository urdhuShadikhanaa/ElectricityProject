public with sharing class NGMCP_DateUtils {

    /**
     * Extract the first dd/mm from a description and return dd/mm/yyyy,
     * guaranteed to be a future date relative to "now".
     *
     * Rule:
     * - If month < current month → use next year.
     * - Else if month == current month and day <= today → use next year.
     * - Else → use current year.
     *
     * Returns null if no valid dd/mm is found or the date is invalid.
     *
     * @param description string containing a dd/mm date (e.g., "Task due on 25/12")
     * @param now optional override for current date (useful in tests)
     */
    public static String firstFutureDdMmYyyyFromDescription(String description, Date now) {
        if (String.isBlank(description)) return null;
        if (now == null) now = Date.today();

        // Find first dd/mm (1-2 digits for day/month)
        // Apex supports Java-style regex
        Pattern p = Pattern.compile('\\b(\\d{1,2})/(\\d{1,2})\\b');
        Matcher m = p.matcher(description);

        if (!m.find()) return null;

        Integer day   = Integer.valueOf(m.group(1));
        Integer month = Integer.valueOf(m.group(2));

        if (!isValidDayMonth(day, month)) return null;

        Integer targetYear = deriveFutureYear(now, day, month);

        // Validate day within month once year chosen (Feb/leap year aware)
        if (!isValidDayForMonthYear(day, month, targetYear)) return null;

        return two(day) + '/' + two(month) + '/' + String.valueOf(targetYear);
    }

    /**
     * Variant: returns ALL dd/mm/yyyy future dates found in the description.
     */
    public static List<String> allFutureDdMmYyyyFromDescription(String description, Date now) {
        List<String> results = new List<String>();
        if (String.isBlank(description)) return results;
        if (now == null) now = Date.today();

        Pattern p = Pattern.compile('\\b(\\d{1,2})/(\\d{1,2})\\b');
        Matcher m = p.matcher(description);

        while (m.find()) {
            Integer day   = Integer.valueOf(m.group(1));
            Integer month = Integer.valueOf(m.group(2));

            if (!isValidDayMonth(day, month)) continue;

            Integer targetYear = deriveFutureYear(now, day, month);
            if (!isValidDayForMonthYear(day, month, targetYear)) continue;

            results.add(two(day) + '/' + two(month) + '/' + String.valueOf(targetYear));
        }
        return results;
    }

    /** Decide future year based on current date & rule. */
    private static Integer deriveFutureYear(Date now, Integer day, Integer month) {
        Integer currentYear  = now.year();
        Integer currentMonth = now.month();
        Integer currentDay   = now.day();

        Boolean needsNextYear =
            (month < currentMonth) ||
            (month == currentMonth && day <= currentDay);

        return needsNextYear ? currentYear + 1 : currentYear;
    }

    /** Basic dd/mm validation (ignores Feb/leap until year is known). */
    private static Boolean isValidDayMonth(Integer day, Integer month) {
        if (month == null || day == null) return false;
        if (month < 1 || month > 12) return false;
        if (day   < 1 || day   > 31) return false;

        // Quick cap (Feb/leap handled later)
        // Apr, Jun, Sep, Nov → max 30
        if (day == 31 && (month == 4 || month == 6 || month == 9 || month == 11)) return false;

        return true;
    }

    /** Check day range once year is known (handles leap year for Feb). */
    private static Boolean isValidDayForMonthYear(Integer day, Integer month, Integer year) {
        Integer maxDay = 31;
        switch on month {
            when 1,3,5,7,8,10,12 {
                maxDay = 31;
            }
            when 4,6,9,11 {
                maxDay = 30;
            }
            when 2 {
                maxDay = isLeapYear(year) ? 29 : 28;
            }
        }
        return (day >= 1) && (day <= maxDay);
    }

    /** Leap year logic: divisible by 4; centuries divisible by 400. */
    private static Boolean isLeapYear(Integer year) {
        //return (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
        
		return (Math.mod(year, 4) == 0) &&
               (Math.mod(year, 100) != 0 || Math.mod(year, 400) == 0);

    }

    /** Zero-pad to 2 digits. */
    private static String two(Integer x) {
        return (x < 10 ? '0' : '') + String.valueOf(x);
    }

    public static String expandFutureDdMmToDdMmYyyy(String text, Date now) {
        if (String.isBlank(text)) return text;
        if (now == null) now = Date.today();

        final Integer currentYear  = now.year();
        final Integer currentMonth = now.month();
        final Integer currentDay   = now.day();

        // Regex for dd/mm (1–2 digits for each)
        Pattern p = Pattern.compile('\\b(\\d{1,2})/(\\d{1,2})\\b');
        Matcher m = p.matcher(text);

        String result = '';
        Integer lastPos = 0;

        while (m.find()) {
            // Append text before the match
            result += text.substring(lastPos, m.start());

            // Extract dd/mm
            Integer day   = Integer.valueOf(m.group(1));
            Integer month = Integer.valueOf(m.group(2));

            // Basic validation
            if (!isValidDayMonth(day, month)) {
                // Leave original token unchanged if invalid
                result += m.group(0);
            } else {
                // Decide year to make it a future date
                Integer year = (month < currentMonth || (month == currentMonth && day <= currentDay))
                    ? currentYear + 1
                    : currentYear;

                // Validate final day in chosen year (Feb/leap-aware)
                if (!isValidDayForMonthYear(day, month, year)) {
                    // Leave unchanged if invalid in that year
                    result += m.group(0);
                } else {
                    // Build dd/mm/yyyy
                    String dd = two(day);
                    String mm = two(month);
                    result += dd + '/' + mm + '/' + String.valueOf(year);
                }
            }

            lastPos = m.end();
        }

        // Append the remainder
        result += text.substring(lastPos);
        return result;
    }
}