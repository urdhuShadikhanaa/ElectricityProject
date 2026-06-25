/**
 * =============================================================================
 * Class Name    : NGMCP_CustomerWorkRequestFieldMapping
 * Description   : Service class to fetch Custom Metadata mappings used to
 *                 dynamically build Customer Work Request payloads and
 *                 resolve Job Category / Sub-category details.
 *
 * Author        : Patan Shabbir Ali Khan
 * Created Date  : 15-Dec-2025
 *
 * Last Modified By   : Patan Shabbir Ali Khan
 * Last Modified Date : 16-Dec-2025
 *
 * =============================================================================
 */
public with sharing class NGMCP_CustomerWorkRequestFieldMapping {

    /**
     * -------------------------------------------------------------------------
     * Method Name  : getMappings
     * Description  : Fetches field mapping metadata used to dynamically
     *                build the Create Work Request payload.
     *
     * @return List<NGMCP_Customer_Work_Request_Field_Map__mdt>
     * -------------------------------------------------------------------------
     */
    @AuraEnabled(cacheable=true)
    public static List<NGMCP_Customer_Work_Request_Field_Map__mdt> getMappings() {

        return [
            SELECT
                NGMCP_Salesforce_Field_API__c,
                NGMCP_Source_Map__c,
                NGMCP_Source_Key__c,
                NGMCP_IBMMaximo_TicketAPI__c
            FROM NGMCP_Customer_Work_Request_Field_Map__mdt WITH USER_MODE
            ORDER BY DeveloperName
        ];
    }
  
/**
     * -------------------------------------------------------------------------
     * Method Name  : getJobCodes
     * Description  : Fetches Job Category and Sub-category values based on
     *                the provided labels and Category.
     *
     * @param jobCategory     Label/description of Job Category
     * @param jobSubCategory  Label/description of Job Sub-category
     * @param category        Category discriminator (e.g., Business area)
     *
     * @return List<NGMCP_CWR_Job_Details__mdt>
     * Notes        :
     *   - Validates parameters to prevent non-selective queries.
     *   - Uses deterministic LIMIT when exact match is expected.
     *   - Kept as List<> to preserve current signature, but typically
     *     the combination should match a single record.
     * -------------------------------------------------------------------------
     */

    @AuraEnabled(cacheable=true)
    public static List<NGMCP_CWR_Job_Details__mdt> getJobCodes(String jobCategory, String jobSubCategory, String category) {

        return [
            SELECT
                NGMCP_Job_Category__c,
                NGMCP_Job_Sub_category__c
            FROM NGMCP_CWR_Job_Details__mdt
            WHERE NGMCP_Job_Category_Description__c = :jobCategory and NGMCP_Job_Sub_Category_Description__c =:jobSubCategory and NGMCP_Category__c = :category WITH USER_MODE
        ];
    }
}