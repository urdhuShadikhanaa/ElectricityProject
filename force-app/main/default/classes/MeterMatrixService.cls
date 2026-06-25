public with sharing class MeterMatrixService {
    // --- DTO returned to LWC (all as String for compile safety) ---
    public class MeterMatrixDTO {
        @AuraEnabled public String model;          // NGMCP_Meter_Model__c (e.g., G4, G10, G40)
        @AuraEnabled public String size;           // Derived size (e.g., U6, U16, U65)
        @AuraEnabled public String type;           // NGMCP_Type__c
        @AuraEnabled public String imperialMetric; // NGMCP_Imperial_Metric__c (stringified)
        @AuraEnabled public String capacity;       // NGMCP_Capacity__c (stringified)
        @AuraEnabled public String marketSector;   // NGMCP_Market_Sector_Code__c
        @AuraEnabled public String jobCode;        // NGMCP_UWR_Job_Code__c
        @AuraEnabled public String portalCategory; // NGMCP_Portal_Category__c
        @AuraEnabled public String description;    // NGMCP_Job_Description__c
    }

    // --- Utility: null-safe trim for String ---
    private static String trimStr(String s) {
        return (s == null) ? null : s.trim();
    }

    // --- Utility: null-safe stringify (works for String/Decimal/Integer/Picklist/etc.) ---
    private static String toStringSafe(Object o) {
        if (o == null) return null;
        String s;
        try {
            s = String.valueOf(o);
        } catch (Exception e) {
            return null;
        }
        return (s == null) ? null : s.trim();
    }

    /**
     * Returns one canonical row per Meter Model.
     * Size resolution:
     *   - Prefer NGMCP_Meter_Size__c if present
     *   - Else use NGMCP_Meter_Model_Size__c
     */
    @AuraEnabled(cacheable=true)
    public static List<MeterMatrixDTO> getMeterMatrix() {
        List<NGMCP_MeterModelJobCodeMatrix__mdt> rows = [
            SELECT NGMCP_Meter_Model__c,
                   NGMCP_Meter_Size__c,
                   NGMCP_Meter_Model_Size__c,
                   NGMCP_Type__c,
                   NGMCP_Imperial_Metric__c,
                   NGMCP_Capacity__c,
                   NGMCP_Market_Sector_Code__c,
                   NGMCP_UWR_Job_Code__c,
                   NGMCP_Portal_Category__c,
                   NGMCP_Job_Description__c
            FROM NGMCP_MeterModelJobCodeMatrix__mdt
            WHERE NGMCP_Meter_Model__c != null
        ];

        Map<String, MeterMatrixDTO> byModel = new Map<String, MeterMatrixDTO>();

        for (NGMCP_MeterModelJobCodeMatrix__mdt r : rows) {
            String model = trimStr(r.NGMCP_Meter_Model__c);
            if (String.isBlank(model)) continue;

            String resolvedSize = !String.isBlank(r.NGMCP_Meter_Size__c)
                                  ? trimStr(r.NGMCP_Meter_Size__c)
                                  : trimStr(r.NGMCP_Meter_Model_Size__c);

            // Prefer records that provide a resolved size
            if (!byModel.containsKey(model) || String.isNotBlank(resolvedSize)) {
                MeterMatrixDTO dto = new MeterMatrixDTO();
                dto.model         = model;
                dto.size          = resolvedSize;
                dto.type          = trimStr(r.NGMCP_Type__c);
                dto.imperialMetric= toStringSafe(r.NGMCP_Imperial_Metric__c);
                dto.capacity      = toStringSafe(r.NGMCP_Capacity__c);
                dto.marketSector  = trimStr(r.NGMCP_Market_Sector_Code__c);
                dto.jobCode       = trimStr(r.NGMCP_UWR_Job_Code__c);
                dto.portalCategory= trimStr(r.NGMCP_Portal_Category__c);
                dto.description   = trimStr(r.NGMCP_Job_Description__c);
                byModel.put(model, dto);
            }
        }

        return new List<MeterMatrixDTO>(byModel.values());
    }

    /**
     * Convenience: Model → Size map (e.g., "G4" => "U6")
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getModelToSize() {
        Map<String, String> result = new Map<String, String>();
        for (MeterMatrixDTO dto : getMeterMatrix()) {
            if (!String.isBlank(dto.model)) {
                result.put(dto.model, dto.size);
            }
        }
        return result;
    }
}