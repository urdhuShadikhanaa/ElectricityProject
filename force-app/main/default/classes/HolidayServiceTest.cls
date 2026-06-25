@IsTest
private class HolidayServiceTest {

    /** Utility to create Holiday records safely */
    private static Holiday makeHoliday(String name, Date day) {
        Holiday h = new Holiday();
        h.Name = name;
        h.ActivityDate = day;
        return h;
    }

    @IsTest
    static void testNullParamsReturnEmpty() {
        Test.startTest();
        // Both null → empty
        List<Date> result1 = HolidayService.getHolidaysBetween(null, null);
        System.assertNotEquals(null, result1, 'Should return a non-null list when inputs are null');
        System.assertEquals(0, result1.size(), 'Null inputs should yield an empty list');

        // One null → empty
        List<Date> result2 = HolidayService.getHolidaysBetween(Date.today(), null);
        System.assertEquals(0, result2.size(), 'Null endDate should yield an empty list');

        List<Date> result3 = HolidayService.getHolidaysBetween(null, Date.today());
        System.assertEquals(0, result3.size(), 'Null startDate should yield an empty list');
        Test.stopTest();
    }

    @IsTest
    static void testSwappedDatesAndFutureHolidaysReturned() {
        Date today = Date.today();

        // Take a baseline snapshot of existing holidays on/after today in the org
        List<Date> baseline = HolidayService.getHolidaysBetween(today, today);
        Integer baselineCount = baseline.size();

        // Arrange: create past and future holidays (only future/today should be returned by the service)
        Date dPast    = today.addDays(-1); // excluded by the service query
        Date dToday   = today;             // included
        Date dPlus5   = today.addDays(5);  // included
        Date dPlus10  = today.addDays(10); // included

        insert new List<Holiday>{
            makeHoliday('Past Holiday', dPast),
            makeHoliday('Today Holiday', dToday),
            makeHoliday('Future +5', dPlus5),
            makeHoliday('Future +10', dPlus10)
        };

        Test.startTest();
        // Act: pass endDate < startDate to trigger the swap branch
        Date startDate = today.addDays(10);
        Date endDate   = today.addDays(1);
        List<Date> result = HolidayService.getHolidaysBetween(startDate, endDate);
        Test.stopTest();

        // Expectation:
        // - All baseline holidays (>= today) still present
        // - Our 3 non-past dates also included
        Integer expectedMinSize = baselineCount + 3; // today, +5, +10

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(
            result.size() >= expectedMinSize,
            'Should contain at least baseline holidays plus our 3 future/today dates. ' +
            'Expected at least: ' + expectedMinSize + ', Actual: ' + result.size()
        );

        // Validate our inserted dates are present / excluded as per the service logic
        Set<Date> resultSet = new Set<Date>(result);
        System.assert(resultSet.contains(dToday),  'Should contain today\'s holiday we inserted');
        System.assert(resultSet.contains(dPlus5),  'Should contain +5 day holiday we inserted');
        System.assert(resultSet.contains(dPlus10), 'Should contain +10 day holiday we inserted');
        System.assert(!resultSet.contains(dPast),  'Should NOT contain past holiday we inserted');
    }

    @IsTest
    static void testNoHolidaysReturnsBaselineOnly() {
        Date today = Date.today();

        // Baseline snapshot before inserting anything in this test
        List<Date> baseline = HolidayService.getHolidaysBetween(today, today);
        Integer baselineCount = baseline.size();

        Test.startTest();
        List<Date> result = HolidayService.getHolidaysBetween(today, today.addDays(30));
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should not be null');
        // Because the service ignores input range and returns holidays >= today,
        // the result should equal the baseline (we inserted nothing here).
        System.assertEquals(
            baselineCount,
            result.size(),
            'With no inserts in this test, size should match baseline holidays (>= today)'
        );
    }
}