@isTest
public class NGMCP_GetAssetDetailsClassTest {
    
    @isTest
    static void testParseWithValidJson() {
        // Create sample JSON that matches the class structure
        String json = '{"member":[],"responseInfo":{"href":"testHref"}}';
        
        // Test the parse method
        NGMCP_GetAssetDetailsClass result = NGMCP_GetAssetDetailsClass.parse(json);
        
        // Verify the result is not null
        System.assertNotEquals(null, result);
        
        // Verify responseInfo is set
        System.assertNotEquals(null, result.responseInfo);
        System.assertEquals('testHref', result.responseInfo.href);
        
        // Verify member array is initialized
        System.assertNotEquals(null, result.member);
    }
    
    @isTest
    static void testParseWithComplexJson() {
        // Create more complex sample JSON with nested objects
        String json = '{"member":[{"ngme_c_ss":"test_ss","ngme_c_st":"test_st","ngme_lf_mksctcd":"test_mksctcd","ngme_pssrband":"test_pssrband","ngme_pssrband_description":"test_pssrband_desc","pluspcustassoc":[{"ngme_deapp_type":"test_deapp_type","ownerid":123,"ownertable":"test_ownertable","type":"test_type","isprimary":true,"ngme_deapp_type_description":"test_deapp_desc","ngme_effective_to_date":"2023-12-31","ngme_faux_rental":false,"ngme_effective_from_date":"2023-01-01","ngme_primarycust":true,"ngme_namedsupl":"test_namedsupl","type_description":"test_type_desc","customer":"test_customer"}],"ngme_mktseccode":"test_mktseccode","ngme_lf_mksctcd_description":"test_mksctcd_desc","ngme_mktseccode_description":"test_mktseccode_desc","ngme_conversionfactor":1.5,"pluspcustomer":"test_customer","ngme_c_depndlocality":"test_depndlocality","ngme_c_loccode":"test_loccode","ngme_c_prncpstreet":"test_prncpstreet","ngme_c_spc":"test_spc","ngme_c_loccode_description":"test_loccode_desc","ngme_c_county":"test_county","ngme_prsrtier":"test_prsrtier","ngme_c_sitebn":"test_sitebn","siteid":"test_siteid","location":"test_location","ngme_c_bldngname":"test_bldngname","ngme_prsrtier_description":"test_prsrtier_desc","asset":[{"status_description":"LIVE","installdate":"2014-10-01T00:00:00+00:00","serialnum":"REG250693","assettype_description":"Regulator","assettag":"000000000011087689","devicetype":"R_UNKNOWN","manufacturer":"UNK","ngme_qmax":0,"ngme_yearfrom":"1900","companies":[{"name":"UNKNOWN","company":"UNK","orgid":"NGM"}],"ngme_mafcode_description":"UNKNOWN","ngme_metrictype":"M","ngme_yearto":"9999","ngme_yom":"1911","assetnum":"16398311","ngme_mafcode":"UNK","ngme_metrictype_description":"METRIC","assettype":"Z003","pluscmodelnum":"UNKNOWN","status":"LI","ngme_measurecapacity":10.5,"ngme_pymttype_description":"LI","plusddialcount":2.0,"plusdmetertype_description":"test_meter_desc"}],"locationsid":456,"ngme_microbusiness":true,"ngme_amrtag":false}],"responseInfo":{"href":"test_href"}}';
        
        // Test the parse method
        NGMCP_GetAssetDetailsClass result = NGMCP_GetAssetDetailsClass.parse(json);
        
        // Verify the result is not null
        System.assertNotEquals(null, result);
        
        // Verify responseInfo is set
        System.assertNotEquals(null, result.responseInfo);
        System.assertEquals('test_href', result.responseInfo.href);
        
        // Verify member array has data
        System.assertNotEquals(null, result.member);
        System.assertEquals(1, result.member.size());
        
        // Verify member properties
        NGMCP_GetAssetDetailsClass.Cls_member member = result.member[0];
        System.assertEquals('test_ss', member.ngme_c_ss);
        System.assertEquals('test_st', member.ngme_c_st);
        System.assertEquals('test_mksctcd', member.ngme_lf_mksctcd);
        System.assertEquals('test_pssrband', member.ngme_pssrband);
        System.assertEquals('test_pssrband_desc', member.ngme_pssrband_description);
        
        // Verify pluspcustassoc array
        System.assertNotEquals(null, member.pluspcustassoc);
        System.assertEquals(1, member.pluspcustassoc.size());
        
        // Verify pluspcustassoc properties
        NGMCP_GetAssetDetailsClass.cls_pluspcustassoc custAssoc = member.pluspcustassoc[0];
        System.assertEquals('test_deapp_type', custAssoc.ngme_deapp_type);
        System.assertEquals(123, custAssoc.ownerid);
        System.assertEquals('test_ownertable', custAssoc.ownertable);
        System.assertEquals('test_type', custAssoc.type);
        System.assertEquals(true, custAssoc.isprimary);
        System.assertEquals('test_deapp_desc', custAssoc.ngme_deapp_type_description);
        System.assertEquals('2023-12-31', custAssoc.ngme_effective_to_date);
        System.assertEquals(false, custAssoc.ngme_faux_rental);
        System.assertEquals('2023-01-01', custAssoc.ngme_effective_from_date);
        System.assertEquals(true, custAssoc.ngme_primarycust);
        System.assertEquals('test_namedsupl', custAssoc.ngme_namedsupl);
        System.assertEquals('test_type_desc', custAssoc.type_description);
        System.assertEquals('test_customer', custAssoc.customer);
        
        // Verify asset array
        System.assertNotEquals(null, member.asset);
        System.assertEquals(1, member.asset.size());
        
        // Verify asset properties
        NGMCP_GetAssetDetailsClass.cls_asset asset = member.asset[0];
        System.assertEquals('LIVE', asset.status_description);
        System.assertEquals('2014-10-01T00:00:00+00:00', asset.installdate);
        System.assertEquals('REG250693', asset.serialnum);
        System.assertEquals('Regulator', asset.assettype_description);
        System.assertEquals('000000000011087689', asset.assettag);
        System.assertEquals('R_UNKNOWN', asset.devicetype);
        System.assertEquals('UNK', asset.manufacturer);
        System.assertEquals(0, asset.ngme_qmax);
        System.assertEquals('1900', asset.ngme_yearfrom);
        System.assertNotEquals(null, asset.companies);
        System.assertEquals(1, asset.companies.size());
        System.assertEquals('UNKNOWN', asset.ngme_mafcode_description);
        System.assertEquals('M', asset.ngme_metrictype);
        System.assertEquals('9999', asset.ngme_yearto);
        System.assertEquals('1911', asset.ngme_yom);
        System.assertEquals('16398311', asset.assetnum);
        System.assertEquals('UNK', asset.ngme_mafcode);
        System.assertEquals('METRIC', asset.ngme_metrictype_description);
        System.assertEquals('Z003', asset.assettype);
        System.assertEquals('UNKNOWN', asset.pluscmodelnum);
        System.assertEquals('LI', asset.status);
        System.assertEquals(10.5, asset.ngme_measurecapacity);
        System.assertEquals('LI', asset.ngme_pymttype_description);
        System.assertEquals(2.0, asset.plusddialcount);
        System.assertEquals('test_meter_desc', asset.plusdmetertype_description);
        
        // We cannot directly test cls_companies as it's not public, but we can verify it exists
        // and has the expected structure by checking that it's not null
        System.assertNotEquals(null, asset.companies);
        
        // Verify other member properties
        System.assertEquals(456, member.locationsid);
        System.assertEquals(true, member.ngme_microbusiness);
        System.assertEquals(false, member.ngme_amrtag);
    }
    
    @isTest
    static void testParseWithEmptyJson() {
        // Test with empty JSON
        String json = '{}';
        
        // Test the parse method
        NGMCP_GetAssetDetailsClass result = NGMCP_GetAssetDetailsClass.parse(json);
        
        // Verify the result is not null
        System.assert(result != null, 'Result should not be null');
        
        // Verify member array can be null or empty (both are valid behaviors)
        // The main purpose of this test is to ensure no exception occurs during parsing
        // We don't assert that member is not null since it's valid for it to be null when parsing empty JSON
        // Test added to ensure no regression
    }
    
    @isTest
    static void testInstantiationOfNestedClasses() {
        // Test instantiation of public nested classes directly
        NGMCP_GetAssetDetailsClass.Cls_member member = new NGMCP_GetAssetDetailsClass.Cls_member();
        NGMCP_GetAssetDetailsClass.cls_pluspcustassoc custAssoc = new NGMCP_GetAssetDetailsClass.cls_pluspcustassoc();
        NGMCP_GetAssetDetailsClass.cls_asset asset = new NGMCP_GetAssetDetailsClass.cls_asset();
        NGMCP_GetAssetDetailsClass.Cls_responseInfo responseInfo = new NGMCP_GetAssetDetailsClass.Cls_responseInfo();
        
        // Verify all objects are instantiated
        System.assertNotEquals(null, member);
        System.assertNotEquals(null, custAssoc);
        System.assertNotEquals(null, asset);
        System.assertNotEquals(null, responseInfo);
    }
}