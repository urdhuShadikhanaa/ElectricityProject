public with sharing class NGMCP_RequestClass {
    public List<MemberClass> member;
    public ResponseInfoClass responseInfo;

    public class ResponseInfoClass{
        public String href;
    }

    public class MemberClass{
        public Boolean ngme_resub;
        public String commodity;
        public String ngme_resubreason;
        public String ngme_resolutionletter;
        public String status_description;
        public Double classstructureid;
        public String ticketuid;
        public String commoditygroup;
        public String class_description;
        public String targetstart;
        public String changedate;
        public List<RelatedRecordClass> relatedrecord;
        public String targetfinish;
        public Boolean ngme_justify;
        public String assetnum;
        public String actualstart;
        public String location;
        public List<LocationClass> locations;
        public List<WorkLogClass> worklog;
        //public String class;
        public String np_statusmemo;
        public String ticketid;
        public String status;
    }

    public class WorkLogClass{
        public String modifyby;
        public String logtype;
        public String description_longdescription;
        public String createdate;
        public String description;
        public String worklogid;
        public String ngme_adi_expdate;
        public String logtype_description;
    }

    public class LocationClass{
        public String ngme_lf_mksctcd;
        public String ngme_mktseccode;
        public String ngme_lf_mksctcd_description;
        public String ngme_mktseccode_description;
        public String siteid;
        public String location;
    }

    public class RelatedRecordClass{
        public String relatedrecwonum;
        public String relatedrecordid;
        public List<WorkOrderClass> workorder;
    }

    public class WorkOrderClass{
        public String targstartdate;
        public String status_description;
        public String actstart;
        public String reportdate;
        public String siteid;
        public String changedate;
        public String targcompdate;
        public List<WOActivityClass> woactivity;
        public String status;
        public String wonum;
        public String ngme_ofmat_result_description;
        public String ngme_ofmat_result;
    }

    public class WOActivityClass{
        public Boolean apptrequired;
        public Boolean plusgqualitycritical;
        public String parent;
        public Boolean historyflag;
        public Boolean aos;
        public Double estservcost;
        public Boolean pluscismobile;
        public Boolean plusgassactivityimp; 
        public Boolean ngme_matordreq;
        public Boolean ngme_return_req;
        public Boolean sap_upg;
        public Boolean plusgccf; 
        public Boolean parentchgsstatus;
        public Boolean ngme_matordrec;
        public Boolean plusgcopyrevactrsk;
        public Boolean lms; 
        public Boolean istask;
        public Double plusprevnum;
        public Boolean ngme_remdreq;
        public Boolean ngme_siteworkswo; 
        public Double estatapprmatcost;
        public Double taskid;
        public Boolean plusgdefmeasreq;
        public Boolean pluscloop;
        public Boolean plusgdocsattached; 
        public Boolean plusgtemp;
        public Double actmatcost;
        public Double actlabhrs;
        public Boolean nestedjpinprocess;
        public String pluspcustomer;
        public Boolean plusdisprereq;
        public Double estatapprtoolcost;
        public Boolean ngme_ocr_ft;
        public Boolean hasfollowupwork;
        public Boolean ngme_picofreg;
        public String pluspagreement;
        public Boolean plusgmpoverride;
        public Double actservcost;
        public Boolean flowactionassist;
        public Boolean ignorediavail;
        public Boolean reqasstdwntime;
        public Double estmatcost;
        public Boolean pluspporeq;
        public String targcompdate;
        public Boolean pluspallowquote;
        public Boolean plusgtestcert;
        public String status;
        public Boolean template;
        public String commodity;
        public Boolean ngme_regreplace;
        public Boolean ngme_ffa_fc_c;
        public Boolean ngme_ffa_fc_b;
        public String commoditygroup;
        public Double estlabhrs;
        public Boolean ngme_housltr_fl_wo;
        public Double esttoolcost;
        public Boolean ngme_anyshw;
        public Boolean plusgimpreqd;
        public String reportedby;
        public Boolean plusglongterm;
        public Boolean los;
        public Double estoutlabcost;
        public Boolean ngme_safetycheck;
        public String assetnum;
        public Boolean ngme_housltr_tr_wo;
        public Boolean disabled;
        public Double outmatcost;
        public String ngme_task_code;
        public Boolean ngme_wobulkload;
        public Boolean plusgaarrequired;
        public Double estdur;
        public Boolean ngme_bespokeinstallation;
        public Boolean plusgactcompleted;
        public Boolean ngme_bfltother;
        public String onbehalfof;
        public Boolean plusgcrittoqual;
        public String changeby;
        public Boolean interruptible;
        public Double estlabcost;
        public Double estatapprintlabhrs;
        public String statusdate;
        public Boolean downtime;
        public String workorderid;
        public Boolean ngme_eng_reporttime;
        public Boolean ngme_urgent;
        public Boolean ngme_ns_invoiced;
        public Boolean ngme_inspcheck;
        public Boolean ngme_meter_insp;
        public Boolean plussisgis;
        public Double acttoolcost;
        public Boolean ngme_housltr_fr_wo;
        public Double actlabcost;
        public Double actoutlabcost;
        public Double estatapprlabhrs;
        public Double estatapprservcost;
        public Boolean plusglesslearned;
        public Double estatapprlabcost;
        public Boolean pluspallowquotelabor;
        public String plusppricesched;
        public Boolean ignoresrmavail;
        public Boolean plusgauditreq;
        public Boolean plusgmigrationreq;
        public Double outtoolcost;
        public Double estatapproutlabhrs;
        public Boolean plusgcomcrit;
        public Boolean ngme_mtrxch;
        public Double estatapprintlabcost;
        public String firstapprstatus;
        public Boolean plusgcontinplan;
        public Boolean plusghighrisk;
        public Double totalworkunits;
        public Boolean plusgassactivity;
        public Boolean suspendflow;
        public Boolean plusgcapex;
        public String status_description;
        public Boolean woisswap;
        public Boolean ngme_ffa_fc_a2;
        public Boolean plusghassafetycrit;
        public Boolean ngme_ffa_fc_a1;
        public Double actintlabhrs;
        public Boolean woacceptscharges;
        public Boolean repairlocflag;
        public String changedate;
        public String ngme_task_code_description;
        public Boolean plusgpostactcomp;
        public Boolean chargestore;
        public String woclass_description;
        public Boolean ngme_picofmeter;
        public Double outlabcost;
        public Boolean ngme_shadowaddchk;
        public Boolean ngme_tender_init;
        public String orgid;
        public Boolean plusgactexternal;
        public Boolean pluspbillapproved;
        public Boolean plusgactrequired;
        public String woclass;
        public Double actoutlabhrs;
        public Boolean ngme_regser;
        public Boolean ngme_mprm_viswarnot;
        public Boolean plusgreviewed;
        public Boolean plusgscheddev;
        public Boolean plusgprepactiv;
        public Boolean inctasksinsched;
        public String targstartdate;
        public Boolean plusgtgtdatemod;
        public Boolean plusdsabotage;
        public Boolean flowcontrolled;
        public Boolean ams;
        public String actstart;
        public String reportdate;
        public Boolean ngme_microbusiness;
        public String description;
        public Boolean plusgenvcrit;
        public Double estatapproutlabcost;
        public String newchildclass;
        public Boolean ngme_outsideareawork;
        public Boolean ngme_sendonjob;
        public String djpapplied;
        public Boolean pluspallowquotematerial;
        public Double estoutlabhrs;
        public Boolean plusgpass;
        public Boolean plusgfailfix;
        public Double actintlabcost;
        public Boolean ai_usefortraining;
        public Boolean ngme_battery_chg;
        public Boolean ngme_matreq;
        public Boolean pluspallowquoteservice;
        public Double estintlabhrs;
        public Boolean ngme_housltr_sr_wo;
        public Boolean ngme_mp6_checked;
        public Boolean ngme_batchnum;
        public Boolean plusgreviewreq;
        public Boolean milestone;
        public Boolean ngme_picofmeterread;
        public String wogroup;
        public String location;
        public String actfinish;
        public Double estintlabcost;
        public Boolean plusglock;
        public Boolean plusgsafetycrit;
        public Boolean haschildren;
        public Boolean ngme_bfltdrwng;
    }

    public static NGMCP_RequestClass parse(String json){
        try{
        System.debug('return from request class****'+ (NGMCP_RequestClass) System.JSON.deserialize(json, NGMCP_RequestClass.class));
        return (NGMCP_RequestClass) System.JSON.deserialize(json, NGMCP_RequestClass.class);
        }
        catch(Exception e){
            System.debug('Error in parsing request class: '+e.getMessage() + ' @line:' + e.getLineNumber());
            return null;
        }
    }
}