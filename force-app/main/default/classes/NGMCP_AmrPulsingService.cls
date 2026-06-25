public with sharing class NGMCP_AmrPulsingService {

    /**
     * Returns 'YES' or 'NO' if a matching CMDT row is found for (shortCode, model, year).
     * Returns '' (empty) when no match so the LWC can default to YES.
     *
     * NOTE: Uses normalization to handle whitespace/NBSP/casing, and compares year as Decimal.
     */
    @AuraEnabled(cacheable=true)
    public static String getPulsing(String shortCode, String model, Integer year) {
        if (String.isBlank(shortCode) || String.isBlank(model) || year == null) {
            return '';
        }

        // Normalize incoming values
        String scIn = norm(shortCode);
        String mdIn = norm(model);
        Decimal yDec = Decimal.valueOf(year);

        // Pull relevant rows and compare in Apex after normalizing row values.
        // (Dataset is small ~hundreds; this is safe and resilient to hidden spaces.)
        List<NGMCP_AMRStatus__mdt> all = [
            SELECT Short_Code__c, Model__c, Year_From__c, Year_To__c, Pulsing__c
            FROM NGMCP_AMRStatus__mdt
            WHERE Model__c != null
            With USER_MODE
        ];

        // 1) Try exact Short Code (full name) + Model
        String hit = findMatch(all, scIn, mdIn, yDec);
        if (hit != null) return hit; // 'YES' or 'NO'

        // 2) Try initials fallback (e.g., "PARKINSON COWAN" -> "PC")
        String scAbbrev = abbreviate(scIn);
        if (scAbbrev != scIn) {
            hit = findMatch(all, scAbbrev, mdIn, yDec);
            if (hit != null) return hit;
        }

        // 3) No match
        return '';
    }

    // Finds a matching row by normalized Short Code + Model and checks year range (Decimal-safe).
    private static String findMatch(List<NGMCP_AMRStatus__mdt> rows, String scIn, String mdIn, Decimal yDec) {
        for (NGMCP_AMRStatus__mdt r : rows) {
            String scRow = norm(r.Short_Code__c);
            String mdRow = norm(r.Model__c);
            if (scRow == scIn && mdRow == mdIn) {
                Decimal yFrom = (r.Year_From__c == null) ? Decimal.valueOf(0)    : r.Year_From__c;
                Decimal yTo   = (r.Year_To__c   == null) ? Decimal.valueOf(9999) : r.Year_To__c;
                if (yDec >= yFrom && yDec <= yTo) {
                    return String.valueOf(r.Pulsing__c).trim().toUpperCase(); // 'YES' or 'NO'
                }
            }
        }
        return null;
    }

    // Normalization: replace NBSP, collapse whitespace, trim, uppercase.
    private static String norm(String s) {
        if (s == null) return '';
        // Replace non-breaking spaces with regular spaces
        s = s.replace('\u00A0', ' ');
        // Collapse multiple whitespace into one space
        s = s.replaceAll('\\s+', ' ');
        return s.trim().toUpperCase();
    }

    // "PARKINSON COWAN" -> "PC"
    private static String abbreviate(String s) {
        List<String> parts = s.replaceAll('[^A-Za-z0-9 ]', ' ').trim().split('\\s+');
        String out = '';
        for (String p : parts) {
            if (!String.isBlank(p)) out += p.substring(0, 1);
        }
        return out.toUpperCase();
    }
}