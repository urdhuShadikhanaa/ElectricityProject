public class NGMCP_DocumentDownloadWrapper {
    
    @AuraEnabled public List<ClsMember> member;
    @AuraEnabled public ClsResponseInfo responseInfo;
    
    public class ClsMember {
        @AuraEnabled public String ngme_consname;
        @AuraEnabled public String ngme_meter;
        @AuraEnabled public Boolean ngme_toggle_off;
        @AuraEnabled public Boolean ngme_lr_read;
        @AuraEnabled public String ngme_access_instruction;
        @AuraEnabled public String class_description;
        @AuraEnabled public String langcode;
        @AuraEnabled public Boolean ngme_dum_mprn;
        @AuraEnabled public String ngme_s_bldngname;
        @AuraEnabled public Boolean ngme_srdata;
        @AuraEnabled public Boolean ngme_lf_bypass;
        
        @AuraEnabled public List<ClsDocLinks> doclinks;
        
        @AuraEnabled public String ticketid;
        @AuraEnabled public String ngme_constitle;
        @AuraEnabled public Boolean ngme_lf_eleint;
        @AuraEnabled public String ngme_consphone;
        @AuraEnabled public Boolean ngme_sendonupd;
        @AuraEnabled public Boolean plusgrecordable;
        @AuraEnabled public Boolean ngme_toggle_on;
        @AuraEnabled public Boolean hasld;
        @AuraEnabled public Boolean ngme_toggle;
        @AuraEnabled public Boolean ngme_lf_twinpress;
        @AuraEnabled public Boolean ngme_lf_conventer;
        @AuraEnabled public Boolean origfromalert;
    }
    
    public class ClsDocLinks {
        @AuraEnabled public Integer docinfoid;
        @AuraEnabled public String doctype;
        @AuraEnabled public String ngme_doctype_description;
        
        // ⚠️ Base64 – handle carefully in UI
        @AuraEnabled public String documentdata;
        @AuraEnabled  public String ngme_doctype;
        @AuraEnabled public String weburl;
        @AuraEnabled public String document;
        @AuraEnabled public String description;
        @AuraEnabled public Integer ownerid;
        @AuraEnabled public String ownertable;
        
    }
    
    public class ClsResponseInfo {
        @AuraEnabled public Integer totalCount;
    }
    
    public static NGMCP_DocumentDownloadWrapper parse(String json){
		return (NGMCP_DocumentDownloadWrapper) System.JSON.deserialize(json, NGMCP_DocumentDownloadWrapper.class);
	}
}