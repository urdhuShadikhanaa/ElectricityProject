public with sharing class NGMCP_GetAssetDetailsClass {
    @AuraEnabled public Cls_member[] member;
    @AuraEnabled public Cls_responseInfo responseInfo;

    public class Cls_member {
        @AuraEnabled public String ngme_c_ss;
        @AuraEnabled public String ngme_c_st;
        @AuraEnabled public String ngme_lf_mksctcd;
        @AuraEnabled public String ngme_pssrband;
        @AuraEnabled public String ngme_pssrband_description;
        @AuraEnabled public cls_pluspcustassoc[] pluspcustassoc;
        @AuraEnabled public String ngme_mktseccode;
        @AuraEnabled public String ngme_lf_mksctcd_description;
        @AuraEnabled public String ngme_mktseccode_description;
        @AuraEnabled public Double ngme_conversionfactor;
        @AuraEnabled public String pluspcustomer;
        @AuraEnabled public String ngme_c_depndlocality;
        @AuraEnabled public String ngme_c_loccode;
        @AuraEnabled public String ngme_c_prncpstreet;
        @AuraEnabled public String ngme_c_spc;
        @AuraEnabled public String ngme_c_loccode_description;
        @AuraEnabled public String ngme_c_county;
        @AuraEnabled public String ngme_prsrtier;
        @AuraEnabled public String ngme_c_sitebn;
        @AuraEnabled public String siteid;
        @AuraEnabled public String location;
        @AuraEnabled public String ngme_c_bldngname;
        @AuraEnabled public String ngme_prsrtier_description;
        @AuraEnabled public cls_asset[] asset;
        @AuraEnabled public Integer locationsid;
        @AuraEnabled public Boolean ngme_microbusiness;
        @AuraEnabled public Boolean ngme_amrtag;
        // Added Additional parameter under the UAT Bug:192729 
        @AuraEnabled public boolean ngme_pald;
        @AuraEnabled public String ngme_pald_customer;
        @AuraEnabled public String ngme_pald_startdate;
        @AuraEnabled public String ngme_pald_enddate;
        //end UAT Bug: 192729
    }

    public class cls_pluspcustassoc {
        @AuraEnabled public String ngme_deapp_type;
        @AuraEnabled public Integer ownerid;
        @AuraEnabled public String ownertable;
        @AuraEnabled public String type;
        @AuraEnabled public Boolean isprimary;
        @AuraEnabled public String ngme_deapp_type_description;
        @AuraEnabled public String ngme_effective_to_date;
        @AuraEnabled public Boolean ngme_faux_rental;
        @AuraEnabled public String ngme_effective_from_date;
        @AuraEnabled public Boolean ngme_primarycust;
        @AuraEnabled public String ngme_namedsupl;
        @AuraEnabled public String type_description;
        @AuraEnabled public String customer;
        
    }

    public class cls_asset {
		@AuraEnabled public String status_description;	//LIVE
		@AuraEnabled public String installdate;	//2014-10-01T00:00:00+00:00
		@AuraEnabled public String serialnum;	//REG250693
		@AuraEnabled public String assettype_description;	//Regulator
		@AuraEnabled public String assettag;	//000000000011087689
		@AuraEnabled public String devicetype;	//R_UNKNOWN
		@AuraEnabled public String manufacturer;	//UNK
		@AuraEnabled public Integer ngme_qmax;	//0
		@AuraEnabled public String ngme_yearfrom;	//1900
		@AuraEnabled public cls_companies[] companies;
		@AuraEnabled public String ngme_mafcode_description;	//UNKNOWN
		@AuraEnabled public String ngme_metrictype;	//M
		@AuraEnabled public String ngme_yearto;	//9999
		@AuraEnabled public String ngme_yom;	//1911
		@AuraEnabled public String assetnum;	//16398311
		@AuraEnabled public String ngme_mafcode;	//UNK
		@AuraEnabled public String ngme_metrictype_description;	//METRIC
		@AuraEnabled public String assettype;	//Z003
		@AuraEnabled public String pluscmodelnum;	//UNKNOWN
		@AuraEnabled public String status;	//LI
        @AuraEnabled public double ngme_measurecapacity;
        @AuraEnabled public String ngme_pymttype_description;	//LI
        @AuraEnabled public double plusddialcount;
        @AuraEnabled public String plusdmetertype_description;
	}
	class cls_companies {
		@AuraEnabled public String name;	//UNKNOWN
		@AuraEnabled public String company;	//UNK
		@AuraEnabled public String orgid;	//NGM
	}

    public class Cls_responseInfo {
        @AuraEnabled public String href;
    }

    public static NGMCP_GetAssetDetailsClass parse(String json){
        System.debug('return from asset details****'+ (NGMCP_GetAssetDetailsClass) System.JSON.deserialize(json, NGMCP_GetAssetDetailsClass.class));
        return (NGMCP_GetAssetDetailsClass) System.JSON.deserialize(json, NGMCP_GetAssetDetailsClass.class);
    }
}