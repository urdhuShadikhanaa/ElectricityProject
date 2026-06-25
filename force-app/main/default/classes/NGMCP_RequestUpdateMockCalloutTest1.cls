@isTest
global class NGMCP_RequestUpdateMockCalloutTest1 implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        String resBody =
            '{'+
  '"member": ['+
    '{'+
      '"ngme_resub": false,'+
      '"commodity": "EXCFTRO",'+
      '"status_description": "Approve the SR",'+
      '"classstructureid": "1008",'+
      '"ticketuid": 3389739,'+
      '"commoditygroup": "UWR",'+
      '"class_description": "Service Request",'+
      '"targetstart": "2025-12-08T14:46:00+00:00",'+
      '"description": "SR created with existing MPRN and associated Meter",'+
      '"changedate": "2025-12-08T12:48:09+00:00",'+
      '"relatedrecord": ['+
        '{'+
          '"relatedrecwonum": "1358165",'+
          '"relatedrecordid": 3252084,'+
          '"workorder": ['+
            '{'+
              '"targstartdate": "2025-12-08T14:46:00+00:00",'+
              '"ngme_ofmat_result_description": "Accurate",'+
              '"status_description": "Approved",'+
              '"reportdate": "2025-12-08T09:21:34+00:00",'+
              '"ngme_ofmat_result": "ACCURATE",'+
              '"siteid": "RNL",'+
              '"changedate": "2025-12-08T12:49:41+00:00",'+
              '"targcompdate": "2025-12-08T18:46:00+00:00",'+
              '"woactivity": ['+
                '{'+
                  '"apptrequired": false,'+
                  '"plusgqualitycritical": false,'+
                  '"parent": "1358165",'+
                  '"historyflag": false,'+
                  '"aos": false,'+
                  '"estservcost": 0,'+
                  '"pluscismobile": false,'+
                  '"plusgassactivityimp": false,'+
                  '"ngme_matordreq": false,'+
                  '"ngme_return_req": false,'+
                  '"sap_upg": false,'+
                  '"plusgccf": false,'+
                  '"parentchgsstatus": false,'+
                  '"ngme_matordrec": false,'+
                  '"plusgcopyrevactrsk": false,'+
                  '"lms": false,'+
                  '"istask": true,'+
                  '"plusprevnum": 3,'+
                  '"ngme_remdreq": false,'+
                  '"ngme_siteworkswo": false,'+
                  '"estatapprmatcost": 0,'+
                  '"taskid": 10,'+
                  '"plusgdefmeasreq": false,'+
                  '"wopriority": 1,'+
                  '"pluscloop": false,'+
                  '"plusgdocsattached": false,'+
                  '"plusgtemp": false,'+
                  '"actmatcost": 0,'+
                  '"actlabhrs": 0,'+
                  '"nestedjpinprocess": false,'+
                  '"pluspcustomer": "GMT",'+
                  '"plusdisprereq": false,'+
                  '"estatapprtoolcost": 0,'+
                  '"ngme_ocr_ft": false,'+
                  '"hasfollowupwork": false,'+
                  '"ngme_picofreg": false,'+
                  '"pluspagreement": "1585",'+
                  '"plusgmpoverride": false,'+
                  '"actservcost": 0,'+
                  '"flowactionassist": false,'+
                  '"ignorediavail": false,'+
                  '"reqasstdwntime": false,'+
                  '"estmatcost": 0,'+
                  '"pluspporeq": false,'+
                  '"targcompdate": "2025-12-08T18:46:00+00:00",'+
                  '"pluspallowquote": false,'+
                  '"plusgtestcert": false,'+
                  '"status": "WAPPR",'+
                  '"template": false,'+
                  '"commodity": "EXCFTRO",'+
                  '"ngme_regreplace": false,'+
                  '"ngme_ffa_fc_c": false,'+
                  '"ngme_ffa_fc_b": false,'+
                  '"commoditygroup": "UWR",'+
                  '"estlabhrs": 0,'+
                  '"ngme_housltr_fl_wo": false,'+
                  '"esttoolcost": 0,'+
                  '"ngme_anyshw": false,'+
                  '"plusgimpreqd": false,'+
                  '"reportedby": "LIFERAYUSERR",'+
                  '"plusglongterm": false,'+
                  '"los": false,'+
                  '"estoutlabcost": 0,'+
                  '"ngme_safetycheck": false,'+
                  '"vendor": "NTP",'+
                  '"assetnum": "20884870",'+
                  '"ngme_housltr_tr_wo": false,'+
                  '"disabled": false,'+
                  '"outmatcost": 0,'+
                  '"ngme_task_code": "TGEN",'+
                  '"ngme_wobulkload": false,'+
                  '"plusgaarrequired": false,'+
                  '"estdur": 0,'+
                  '"ngme_bespokeinstallation": false,'+
                  '"plusgactcompleted": false,'+
                  '"ngme_bfltother": false,'+
                  '"onbehalfof": "LIFERAYUSERR",'+
                  '"plusgcrittoqual": false,'+
                  '"changeby": "TEST_CO_APPR2",'+
                  '"interruptible": false,'+
                  '"estlabcost": 0,'+
                  '"estatapprintlabhrs": 0,'+
                  '"statusdate": "2025-12-08T12:48:38+00:00",'+
                  '"downtime": false,'+
                  '"workorderid": 1319903,'+
                  '"ngme_eng_reporttime": false,'+
                  '"ngme_urgent": false,'+
                  '"ngme_ns_invoiced": false,'+
                  '"ngme_inspcheck": false,'+
                  '"ngme_meter_insp": false,'+
                  '"plussisgis": false,'+
                  '"acttoolcost": 0,'+
                  '"ngme_housltr_fr_wo": false,'+
                  '"actlabcost": 0,'+
                  '"actoutlabcost": 0,'+
                  '"estatapprlabhrs": 0,'+
                  '"estatapprservcost": 0,'+
                  '"respondby": "2025-12-09T20:48:38+00:00",'+
                  '"plusglesslearned": false,'+
                  '"estatapprlabcost": 0,'+
                  '"pluspallowquotelabor": false,'+
                  '"plusppricesched": "PC01",'+
                  '"ignoresrmavail": true,'+
                  '"plusgauditreq": false,'+
                  '"plusgmigrationreq": false,'+
                  '"outtoolcost": 0,'+
                  '"estatapproutlabhrs": 0,'+
                  '"plusgcomcrit": false,'+
                  '"ngme_mtrxch": false,'+
                  '"estatapprintlabcost": 0,'+
                  '"plusgcontinplan": false,'+
                  '"plusghighrisk": false,'+
                  '"totalworkunits": 1,'+
                  '"plusgassactivity": false,'+
                  '"suspendflow": false,'+
                  '"plusgcapex": false,'+
                  '"status_description": "Waiting on approval",'+
                  '"woisswap": false,'+
                  '"ngme_ffa_fc_a2": false,'+
                  '"plusghassafetycrit": false,'+
                  '"ngme_ffa_fc_a1": false,'+
                  '"actintlabhrs": 0,'+
                  '"woacceptscharges": true,'+
                  '"repairlocflag": false,'+
                  '"changedate": "2025-12-08T12:49:41+00:00",'+
                  '"ngme_task_code_description": "Template Generated - New meter ordered with procurement",'+
                  '"plusgpostactcomp": false,'+
                  '"calcpriority": 1,'+
                  '"chargestore": false,'+
                  '"woclass_description": "Activity",'+
                  '"ngme_picofmeter": false,'+
                  '"outlabcost": 0,'+
                  '"ngme_shadowaddchk": false,'+
                  '"ngme_tender_init": false,'+
                  '"orgid": "NGM",'+
                  '"plusgactexternal": false,'+
                  '"pluspbillapproved": false,'+
                  '"plusgactrequired": false,'+
                  '"woclass": "ACTIVITY",'+
                  '"actoutlabhrs": 0,'+
                  '"ngme_regser": false,'+
                  '"ngme_mprm_viswarnot": false,'+
                  '"plusgreviewed": false,'+
                  '"plusgscheddev": false,'+
                  '"plusgprepactiv": false,'+
                  '"inctasksinsched": true,'+
                  '"targstartdate": "2025-12-08T14:46:00+00:00",'+
                  '"plusgtgtdatemod": false,'+
                  '"plusdsabotage": false,'+
                  '"flowcontrolled": false,'+
                  '"ams": false,'+
                  '"reportdate": "2025-12-08T12:48:38+00:00",'+
                  '"ngme_microbusiness": false,'+
                  '"description": "order id 001287A ETA 12/12/2025",'+
                  '"plusgenvcrit": false,'+
                  '"estatapproutlabcost": 0,'+
                  '"newchildclass": "ACTIVITY",'+
                  '"ngme_outsideareawork": false,'+
                  '"ngme_sendonjob": false,'+
                  '"djpapplied": "NO",'+
                  '"pluspallowquotematerial": false,'+
                  '"estoutlabhrs": 0,'+
                  '"isquickreported": 0,'+
                  '"plusgpass": false,'+
                  '"plusgfailfix": false,'+
                  '"actintlabcost": 0,'+
                  '"ai_usefortraining": false,'+
                  '"ngme_battery_chg": false,'+
                  '"ngme_matreq": false,'+
                  '"pluspallowquoteservice": false,'+
                  '"estintlabhrs": 0,'+
                  '"ngme_housltr_sr_wo": false,'+
                  '"ngme_mp6_checked": false,'+
                  '"ngme_batchnum": false,'+
                  '"plusgreviewreq": false,'+
                  '"milestone": false,'+
                  '"ngme_picofmeterread": false,'+
                  '"wogroup": "1358165",'+
                  '"location": "80105400",'+
                  '"estintlabcost": 0,'+
                  '"plusglock": false,'+
                  '"plusgsafetycrit": false,'+
                  '"haschildren": false,'+
                  '"ngme_bfltdrwng": false'+
                '}'+
              '],'+
              '"status": "APPR",'+
              '"wonum": "1358165"'+
            '},'+
            '{'+
              '"targstartdate": "2025-12-08T08:00:00+00:00",'+
              '"ngme_ofmat_result_description": "Defective/Erroneous",'+
              '"status_description": "Approved",'+
              '"reportdate": "2025-12-08T12:47:33+00:00",'+
              '"ngme_ofmat_result": "DEFECTIVE",'+
              '"siteid": "RNL",'+
              '"changedate": "2025-12-08T12:48:28+00:00",'+
              '"targcompdate": "2025-12-08T20:00:00+00:00",'+
              '"status": "APPR",'+
              '"wonum": "1358344"'+
            '}'+
          ']'+
        '},'+
        '{'+
          '"relatedrecwonum": "1358344",'+
          '"relatedrecordid": 3254194,'+
          '"workorder": ['+
            '{'+
              '"targstartdate": "2025-12-08T14:46:00+00:00",'+
              '"ngme_ofmat_result_description": "Accurate",'+
              '"status_description": "Approved",'+
              '"reportdate": "2025-12-08T09:21:34+00:00",'+
              '"ngme_ofmat_result": "ACCURATE",'+
              '"siteid": "RNL",'+
              '"changedate": "2025-12-08T12:49:41+00:00",'+
              '"targcompdate": "2025-12-08T18:46:00+00:00",'+
              '"woactivity": ['+
                '{'+
                  '"apptrequired": false,'+
                  '"plusgqualitycritical": false,'+
                  '"parent": "1358165",'+
                  '"historyflag": false,'+
                  '"aos": false,'+
                  '"estservcost": 0,'+
                  '"pluscismobile": false,'+
                  '"plusgassactivityimp": false,'+
                  '"ngme_matordreq": false,'+
                  '"ngme_return_req": false,'+
                  '"sap_upg": false,'+
                  '"plusgccf": false,'+
                  '"parentchgsstatus": false,'+
                  '"ngme_matordrec": false,'+
                  '"plusgcopyrevactrsk": false,'+
                  '"lms": false,'+
                  '"istask": true,'+
                  '"plusprevnum": 3,'+
                  '"ngme_remdreq": false,'+
                  '"ngme_siteworkswo": false,'+
                  '"estatapprmatcost": 0,'+
                  '"taskid": 10,'+
                  '"plusgdefmeasreq": false,'+
                  '"wopriority": 1,'+
                  '"pluscloop": false,'+
                  '"plusgdocsattached": false,'+
                  '"plusgtemp": false,'+
                  '"actmatcost": 0,'+
                  '"actlabhrs": 0,'+
                  '"nestedjpinprocess": false,'+
                  '"pluspcustomer": "GMT",'+
                  '"plusdisprereq": false,'+
                  '"estatapprtoolcost": 0,'+
                  '"ngme_ocr_ft": false,'+
                  '"hasfollowupwork": false,'+
                  '"ngme_picofreg": false,'+
                  '"pluspagreement": "1585",'+
                  '"plusgmpoverride": false,'+
                  '"actservcost": 0,'+
                  '"flowactionassist": false,'+
                  '"ignorediavail": false,'+
                  '"reqasstdwntime": false,'+
                  '"estmatcost": 0,'+
                  '"pluspporeq": false,'+
                  '"targcompdate": "2025-12-08T18:46:00+00:00",'+
                  '"pluspallowquote": false,'+
                  '"plusgtestcert": false,'+
                  '"status": "WAPPR",'+
                  '"template": false,'+
                  '"commodity": "EXCFTRO",'+
                  '"ngme_regreplace": false,'+
                  '"ngme_ffa_fc_c": false,'+
                  '"ngme_ffa_fc_b": false,'+
                  '"commoditygroup": "UWR",'+
                  '"estlabhrs": 0,'+
                  '"ngme_housltr_fl_wo": false,'+
                  '"esttoolcost": 0,'+
                  '"ngme_anyshw": false,'+
                  '"plusgimpreqd": false,'+
                  '"reportedby": "LIFERAYUSERR",'+
                  '"plusglongterm": false,'+
                  '"los": false,'+
                  '"estoutlabcost": 0,'+
                  '"ngme_safetycheck": false,'+
                  '"vendor": "NTP",'+
                  '"assetnum": "20884870",'+
                  '"ngme_housltr_tr_wo": false,'+
                  '"disabled": false,'+
                  '"outmatcost": 0,'+
                  '"ngme_task_code": "TGEN",'+
                  '"ngme_wobulkload": false,'+
                  '"plusgaarrequired": false,'+
                  '"estdur": 0,'+
                  '"ngme_bespokeinstallation": false,'+
                  '"plusgactcompleted": false,'+
                  '"ngme_bfltother": false,'+
                  '"onbehalfof": "LIFERAYUSERR",'+
                  '"plusgcrittoqual": false,'+
                  '"changeby": "TEST_CO_APPR2",'+
                  '"interruptible": false,'+
                  '"estlabcost": 0,'+
                  '"estatapprintlabhrs": 0,'+
                  '"statusdate": "2025-12-08T12:48:38+00:00",'+
                  '"downtime": false,'+
                  '"workorderid": 1319903,'+
                  '"ngme_eng_reporttime": false,'+
                  '"ngme_urgent": false,'+
                  '"ngme_ns_invoiced": false,'+
                  '"ngme_inspcheck": false,'+
                  '"ngme_meter_insp": false,'+
                  '"plussisgis": false,'+
                  '"acttoolcost": 0,'+
                  '"ngme_housltr_fr_wo": false,'+
                  '"actlabcost": 0,'+
                  '"actoutlabcost": 0,'+
                  '"estatapprlabhrs": 0,'+
                  '"estatapprservcost": 0,'+
                  '"respondby": "2025-12-09T20:48:38+00:00",'+
                  '"plusglesslearned": false,'+
                  '"estatapprlabcost": 0,'+
                  '"pluspallowquotelabor": false,'+
                  '"plusppricesched": "PC01",'+
                  '"ignoresrmavail": true,'+
                  '"plusgauditreq": false,'+
                  '"plusgmigrationreq": false,'+
                  '"outtoolcost": 0,'+
                  '"estatapproutlabhrs": 0,'+
                  '"plusgcomcrit": false,'+
                  '"ngme_mtrxch": false,'+
                  '"estatapprintlabcost": 0,'+
                  '"plusgcontinplan": false,'+
                  '"plusghighrisk": false,'+
                  '"totalworkunits": 1,'+
                  '"plusgassactivity": false,'+
                  '"suspendflow": false,'+
                  '"plusgcapex": false,'+
                  '"status_description": "Waiting on approval",'+
                  '"woisswap": false,'+
                  '"ngme_ffa_fc_a2": false,'+
                  '"plusghassafetycrit": false,'+
                  '"ngme_ffa_fc_a1": false,'+
                  '"actintlabhrs": 0,'+
                  '"woacceptscharges": true,'+
                  '"repairlocflag": false,'+
                  '"changedate": "2025-12-08T12:49:41+00:00",'+
                  '"ngme_task_code_description": "Template Generated - New meter ordered with procurement",'+
                  '"plusgpostactcomp": false,'+
                  '"calcpriority": 1,'+
                  '"chargestore": false,'+
                  '"woclass_description": "Activity",'+
                  '"ngme_picofmeter": false,'+
                  '"outlabcost": 0,'+
                  '"ngme_shadowaddchk": false,'+
                  '"ngme_tender_init": false,'+
                  '"orgid": "NGM",'+
                  '"plusgactexternal": false,'+
                  '"pluspbillapproved": false,'+
                  '"plusgactrequired": false,'+
                  '"woclass": "ACTIVITY",'+
                  '"actoutlabhrs": 0,'+
                  '"ngme_regser": false,'+
                  '"ngme_mprm_viswarnot": false,'+
                  '"plusgreviewed": false,'+
                  '"plusgscheddev": false,'+
                  '"plusgprepactiv": false,'+
                  '"inctasksinsched": true,'+
                  '"targstartdate": "2025-12-08T14:46:00+00:00",'+
                  '"plusgtgtdatemod": false,'+
                  '"plusdsabotage": false,'+
                  '"flowcontrolled": false,'+
                  '"ams": false,'+
                  '"reportdate": "2025-12-08T12:48:38+00:00",'+
                  '"ngme_microbusiness": false,'+
                  '"description": "order id 001287A ETA 12/12/2025",'+
                  '"plusgenvcrit": false,'+
                  '"estatapproutlabcost": 0,'+
                  '"newchildclass": "ACTIVITY",'+
                  '"ngme_outsideareawork": false,'+
                  '"ngme_sendonjob": false,'+
                  '"djpapplied": "NO",'+
                  '"pluspallowquotematerial": false,'+
                  '"estoutlabhrs": 0,'+
                  '"isquickreported": 0,'+
                  '"plusgpass": false,'+
                  '"plusgfailfix": false,'+
                  '"actintlabcost": 0,'+
                  '"ai_usefortraining": false,'+
                  '"ngme_battery_chg": false,'+
                  '"ngme_matreq": false,'+
                  '"pluspallowquoteservice": false,'+
                  '"estintlabhrs": 0,'+
                  '"ngme_housltr_sr_wo": false,'+
                  '"ngme_mp6_checked": false,'+
                  '"ngme_batchnum": false,'+
                  '"plusgreviewreq": false,'+
                  '"milestone": false,'+
                  '"ngme_picofmeterread": false,'+
                  '"wogroup": "1358165",'+
                  '"location": "80105400",'+
                  '"estintlabcost": 0,'+
                  '"plusglock": false,'+
                  '"plusgsafetycrit": false,'+
                  '"haschildren": false,'+
                  '"ngme_bfltdrwng": false'+
                '}'+
              '],'+
              '"status": "APPR",'+
              '"wonum": "1358165"'+
            '},'+
            '{'+
              '"targstartdate": "2025-12-08T08:00:00+00:00",'+
              '"ngme_ofmat_result_description": "Defective/Erroneous",'+
              '"status_description": "Approved",'+
              '"reportdate": "2025-12-08T12:47:33+00:00",'+
              '"ngme_ofmat_result": "DEFECTIVE",'+
              '"siteid": "RNL",'+
              '"changedate": "2025-12-08T12:48:28+00:00",'+
              '"targcompdate": "2025-12-08T20:00:00+00:00",'+
              '"status": "APPR",'+
              '"wonum": "1358344"'+
            '}'+
          ']'+
        '}'+
      '],'+
      '"targetfinish": "2025-12-08T18:46:00+00:00",'+
      '"ngme_justify": false,'+
      '"assetnum": "20884870",'+
      '"actualstart": "2025-12-08T09:21:34+00:00",'+
      '"location": "80105400",'+
      '"locations": ['+
        '{'+
          '"ngme_lf_mksctcd": "I",'+
          '"ngme_mktseccode": "I",'+
          '"ngme_lf_mksctcd_description": "Industrial & Commercial",'+
          '"ngme_mktseccode_description": "Industrial & Commercial",'+
          '"siteid": "RNL",'+
          '"location": "80105400"'+
        '}'+
      '],'+
      '"worklog": ['+
        '{'+
          '"modifyby": "TEST_CO_APPR2",'+
          '"logtype": "QUESTION",'+
          '"pluspeststat_description": "Pending Customer Review",'+
          '"pluspeststat": "PENDING",'+
          '"createdate": "2025-12-08T09:17:15+00:00",'+
          '"description": "ADI testing by Paulami",'+
          '"worklogid": 915616,'+
          '"ngme_adi_expdate": "2025-12-09T09:17:00+00:00",'+
          '"logtype_description": "Liferay Question"'+
        '},'+
        '{'+
          '"modifyby": "TEST_CO_APPR2",'+
          '"logtype": "QUESTION",'+
          '"pluspeststat_description": "Customer Rejected",'+
          '"pluspeststat": "REJECTED",'+
          '"createdate": "2025-12-08T11:26:19+00:00",'+
          '"description": "ADI test 2nd attempt",'+
          '"worklogid": 915617,'+
          '"ngme_adi_expdate": "2025-12-10T11:26:00+00:00",'+
          '"logtype_description": "Liferay Question"'+
        '},'+
        '{'+
          '"modifyby": "TEST_CO_APPR2",'+
          '"logtype": "QUESTION",'+
          '"pluspeststat_description": "Pending Customer Review",'+
          '"pluspeststat": "PENDING",'+
          '"createdate": "2025-12-08T12:38:41+00:00",'+
          '"description": "ADI testing by Paulami 3",'+
          '"worklogid": 915618,'+
          '"ngme_adi_expdate": "2025-12-10T12:38:00+00:00",'+
          '"logtype_description": "Liferay Question"'+
        '}'+
      '],'+
      '"class": "SR",'+
      '"np_statusmemo": "",'+
      '"ticketid": "1966164",'+
      '"status": "IN PROGRESS"'+
    '},'+
    '{'+
      '"ngme_resub": false,'+
      '"commodity": "FAUXXXX",'+
      '"status_description": "Approve the SR",'+
      '"classstructureid": "1008",'+
      '"ticketuid": 3332363,'+
      '"commoditygroup": "UWR",'+
      '"class_description": "Service Request",'+
      '"targetstart": "2025-12-10T10:00:00+00:00",'+
      '"description": "SR created with new MPRN and no Meter",'+
      '"changedate": "2025-12-08T12:46:58+00:00",'+
      '"relatedrecord": ['+
        '{'+
          '"relatedrecwonum": "1358341",'+
          '"relatedrecordid": 3254180,'+
          '"workorder": ['+
            '{'+
              '"targstartdate": "2025-12-10T10:00:00+00:00",'+
              '"status_description": "Approved",'+
              '"reportdate": "2025-12-08T12:46:10+00:00",'+
              '"siteid": "REE",'+
              '"changedate": "2025-12-08T12:47:03+00:00",'+
              '"targcompdate": "2025-12-10T14:00:00+00:00",'+
              '"status": "APPR",'+
              '"wonum": "1358341"'+
            '}'+
          ']'+
        '}'+
      '],'+
      '"targetfinish": "2025-12-10T14:00:00+00:00",'+
      '"ngme_justify": false,'+
      '"assetnum": "20902753",'+
      '"actualstart": "2025-12-08T12:46:10+00:00",'+
      '"location": "8000053401",'+
      '"locations": ['+
        '{'+
          '"ngme_lf_mksctcd": "I",'+
          '"ngme_mktseccode": "I",'+
          '"ngme_lf_mksctcd_description": "Industrial & Commercial",'+
          '"ngme_mktseccode_description": "Industrial & Commercial",'+
          '"siteid": "REE",'+
          '"location": "8000053401"'+
        '}'+
      '],'+
      '"class": "SR",'+
      '"np_statusmemo": "",'+
      '"ticketid": "1966314",'+
      '"status": "IN PROGRESS"'+
    '}'+
  '],'+
  '"responseInfo": {'+
    '"href": "api/os/NGME_LR_MX_SCH?oslc.select=*&relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1&savedQuery=SCHEDULERSRWRQUERY&ignorers=1"'+
  '}'+
'}';
       res.setBody(resBody);
        return res;
    }


}