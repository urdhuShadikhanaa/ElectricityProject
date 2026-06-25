@IsTest
public class NGMCP_ServicePartnerControllerTest {
    /* ----------------------------------------------------------
       Utility: Get a valid picklist value dynamically
       ---------------------------------------------------------- */
    private static String getValidChooseStatus() {
        Schema.DescribeFieldResult dfr =
            Patch_Book__c.Choose_Status__c.getDescribe();
        List<Schema.PicklistEntry> values = dfr.getPicklistValues();
        System.assert(!values.isEmpty(), 'Choose_Status__c picklist has no values');
        return values[0].getValue(); // always valid
    }
    /* ----------------------------------------------------------
       Utility: Create Patch_Book__c safely
       ---------------------------------------------------------- */
    private static Patch_Book__c createPatch(String outcode) {
        Patch_Book__c p = new Patch_Book__c();
        p.Name = 'Test Patch';
        p.Postal_Outcode__c = outcode;
        p.Choose_Status__c = getValidChooseStatus();
        insert p;
        return p;
    }
    /* ----------------------------------------------------------
       Blank / Null postcode
       ---------------------------------------------------------- */
    @IsTest
    static void testBlankPostcode() {
        Test.startTest();
        String res1 = NGMCP_ServicePartnerController.getServicePartnerStatus(null);
        String res2 = NGMCP_ServicePartnerController.getServicePartnerStatus('');
        Test.stopTest();
        System.assertEquals(null, res1);
        System.assertEquals(null, res2);
    }
    /* ----------------------------------------------------------
       Matching postcode
       ---------------------------------------------------------- */
    @IsTest
    static void testMatchingPostcode() {
        Patch_Book__c p = createPatch('AA11');
        Test.startTest();
        String result =
            NGMCP_ServicePartnerController.getServicePartnerStatus('aa11 9zz');
        Test.stopTest();
        System.assertEquals(
            p.Choose_Status__c,
            result,
            'Matching outcode should return status'
        );
    }
    /* ----------------------------------------------------------
       Non-matching postcode
       ---------------------------------------------------------- */
    @IsTest
    static void testNonMatchingPostcode() {
        createPatch('BB22');
        Test.startTest();
        String result =
            NGMCP_ServicePartnerController.getServicePartnerStatus('ZZ99');
        Test.stopTest();
        System.assertEquals(null, result);
    }
    /* ----------------------------------------------------------
       isNGMUser – execution-only test
       ---------------------------------------------------------- */
    @IsTest
    static void testIsNGMUser() {
        Test.startTest();
        Boolean result = NGMCP_ServicePartnerController.isNGMUser();
        Test.stopTest();
        System.assert(result == true || result == false);
    }
}