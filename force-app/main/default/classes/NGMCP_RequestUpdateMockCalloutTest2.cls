@isTest
global class NGMCP_RequestUpdateMockCalloutTest2 implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        String resBody =
            '{'+
  '"member": ['+
    '{'+
      '"ngme_resub": false,'+
      '"commodity": "REPFQTU",'+
      '"status_description": "Acknowledged",'+
      '"classstructureid": "1008",'+
      '"ticketuid": 3408997,'+
      '"commoditygroup": "QRT",'+
      '"class_description": "Service Request",'+
      '"targetstart": "2025-12-31T12:00:00+00:00",'+
      '"description": "SR created with existing MPRN and associated Meter",'+
      '"changedate": "2025-12-17T09:00:21+00:00",'+
      '"targetfinish": "2025-12-31T16:00:00+00:00",'+
      '"ngme_justify": false,'+
      '"assetnum": "20945600",'+
      '"actualstart": "2025-12-13T16:36:45+00:00",'+
      '"location": "10836902",'+
      '"locations": ['+
        '{'+
          '"ngme_lf_mksctcd": "I",'+
          '"ngme_mktseccode": "I",'+
          '"ngme_lf_mksctcd_description": "Industrial & Commercial",'+
          '"ngme_mktseccode_description": "Industrial & Commercial",'+
          '"siteid": "RNL",'+
          '"location": "10836902"'+
        '}'+
      '],'+
      '"worklog": ['+
       '{'+
          '"modifyby": "TEST_CO_APPR2",'+
          '"logtype": "QUESTION",'+
          '"description_longdescription": "ADI testing for Worklog",'+
          '"pluspeststat_description": "Pending Customer Review",'+
          '"pluspeststat": "PENDING",'+
          '"createdate": "2025-12-17T08:59:44+00:00",'+
          '"worklogid": 919885,'+
          '"ngme_adi_expdate": "2025-12-19T08:59:00+00:00",'+
          '"logtype_description": "Liferay Question"'+
        '}'+
      '],'+
      '"class": "SR",'+
      '"np_statusmemo": "Change SR status to ACKNOWLEDGED",'+
      '"ticketid": "1966352",'+
      '"status": "IN PROGRESS"'+
    '},'+
    '{'+
      '"ngme_resub": false,'+
      '"commodity": "EXTOFLP",'+
      '"status_description": "New",'+
      '"classstructureid": "1008",'+
      '"ticketuid": 3408849,'+
      '"commoditygroup": "CWR",'+
      '"class_description": "Service Request",'+
      '"targetstart": "2025-12-31T16:00:00+00:00",'+
      '"description": "SR created with existing MPRN and associated Meter",'+
      '"changedate": "2025-12-17T09:01:46+00:00",'+
      '"relatedrecord": ['+
        '{'+
          '"relatedrecwonum": "1364972",'+
          '"relatedrecordid": 3336484,'+
          '"workorder": ['+
            '{'+
              '"targstartdate": "2025-12-31T16:00:00+00:00",'+
              '"ngme_ofmat_result_description": "Defective/Erroneous",'+
              '"status_description": "Waiting on approval",'+
              '"reportdate": "2025-12-13T16:25:14+00:00",'+
              '"ngme_ofmat_result": "DEFECTIVE",'+
              '"siteid": "SCO",'+
              '"changedate": "2025-12-17T09:01:49+00:00",'+
              '"targcompdate": "2025-12-31T18:00:00+00:00",'+
              '"status": "WAPPR",'+
              '"wonum": "1364972"'+
            '}'+
          ']'+
       '}'+
      '],'+
      '"targetfinish": "2025-12-31T20:00:00+00:00",'+
      '"ngme_justify": false,'+
      '"assetnum": "19647793",'+
      '"location": "1070814207",'+
      '"locations": ['+
        '{'+
          '"ngme_lf_mksctcd": "I",'+
          '"ngme_mktseccode": "I",'+
          '"ngme_lf_mksctcd_description": "Industrial & Commercial",'+
          '"ngme_mktseccode_description": "Industrial & Commercial",'+
          '"siteid": "SCO",'+
          '"location": "1070814207"'+
        '}'+
      '],'+
      '"class": "SR",'+
      '"np_statusmemo": "",'+
      '"ticketid": "1966345",'+
      '"status": "OPEN"'+
    '},'+
    '{'+
      '"ngme_resub": false,'+
      '"commodity": "EXCFT65",'+
      '"status_description": "Approve the SR",'+
      '"classstructureid": "1008",'+
      '"ticketuid": 3408798,'+
      '"commoditygroup": "UWR",'+
      '"class_description": "Service Request",'+
      '"targetstart": "2025-12-31T14:00:00+00:00",'+
      '"description": "SR created with existing MPRN and associated Meter",'+
      '"changedate": "2025-12-17T09:05:13+00:00",'+
      '"relatedrecord": ['+
        '{'+
          '"relatedrecwonum": "1364961",'+
          '"relatedrecordid": 3336391,'+
          '"workorder": ['+
            '{'+
              '"targstartdate": "2025-12-31T14:00:00+00:00",'+
              '"status_description": "Further Work Required",'+
              '"actstart": "2025-12-17T09:05:15+00:00",'+
              '"reportdate": "2025-12-13T16:17:39+00:00",'+
              '"siteid": "SCO",'+
              '"changedate": "2025-12-17T09:05:24+00:00",'+
              '"targcompdate": "2025-12-31T18:00:00+00:00",'+
              '"woactivity": ['+
                '{'+
                  '"apptrequired": false,'+
                  '"plusgqualitycritical": false,'+
                  '"parent": "1364961",'+
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
                  '"plusprevnum": 0,'+
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
                  '"pluspcustomer": "EFG",'+
                  '"plusdisprereq": false,'+
                  '"estatapprtoolcost": 0,'+
                  '"ngme_ocr_ft": false,'+
                  '"hasfollowupwork": false,'+
                  '"ngme_picofreg": false,'+
                  '"pluspagreement": "2126",'+
                  '"plusgmpoverride": false,'+
                  '"actservcost": 0,'+
                  '"flowactionassist": false,'+
                  '"ignorediavail": false,'+
                  '"reqasstdwntime": false,'+
                  '"estmatcost": 0,'+
                  '"pluspporeq": false,'+
                  '"targcompdate": "2025-12-31T18:00:00+00:00",'+
                  '"pluspallowquote": false,'+
                  '"plusgtestcert": false,'+
                  '"status": "COMP",'+
                  '"template": false,'+
                  '"commodity": "EXCFT65",'+
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
                  '"vendor": "SGN_SCO",'+
                  '"assetnum": "20567004",'+
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
                  '"statusdate": "2025-12-17T09:04:41+00:00",'+
                  '"downtime": false,'+
                  '"workorderid": 1331860,'+
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
                  '"respondby": "2025-12-17T19:17:59+00:00",'+
                  '"plusglesslearned": false,'+
                  '"estatapprlabcost": 0,'+
                  '"pluspallowquotelabor": false,'+
                  '"plusppricesched": "1P",'+
                  '"ignoresrmavail": true,'+
                  '"plusgauditreq": false,'+
                  '"plusgmigrationreq": false,'+
                  '"outtoolcost": 0,'+
                  '"estatapproutlabhrs": 0,'+
                  '"plusgcomcrit": false,'+
                  '"ngme_mtrxch": false,'+
                  '"estatapprintlabcost": 0,'+
                  '"firstapprstatus": "COMP",'+
                  '"plusgcontinplan": false,'+
                  '"plusghighrisk": false,'+
                  '"totalworkunits": 1,'+
                  '"plusgassactivity": false,'+
                  '"suspendflow": false,'+
                  '"plusgcapex": false,'+
                  '"status_description": "Completed",'+
                  '"woisswap": false,'+
                  '"ngme_ffa_fc_a2": false,'+
                  '"plusghassafetycrit": false,'+
                  '"ngme_ffa_fc_a1": false,'+
                  '"actintlabhrs": 0,'+
                  '"woacceptscharges": true,'+
                  '"repairlocflag": false,'+
                  '"changedate": "2025-12-17T09:04:49+00:00",'+
                  '"ngme_task_code_description": "New meter procurement ETA",'+
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
                  '"targstartdate": "2025-12-31T14:00:00+00:00",'+
                  '"plusgtgtdatemod": false,'+
                  '"plusdsabotage": false,'+
                  '"flowcontrolled": false,'+
                  '"ams": false,'+
                  '"actstart": "2025-12-17T09:04:41+00:00",'+
                  '"reportdate": "2025-12-16T11:17:59+00:00",'+
                  '"ngme_microbusiness": false,'+
                  '"description": "ETA 22/12",'+
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
                  '"wogroup": "1364961",'+
                  '"location": "1054529901",'+
                  '"actfinish": "2025-12-17T09:04:41+00:00",'+
                  '"estintlabcost": 0,'+
                  '"plusglock": false,'+
                  '"plusgsafetycrit": false,'+
                  '"haschildren": false,'+
                  '"ngme_bfltdrwng": false'+
                '},'+
                '{'+
                  '"apptrequired": false,'+
                  '"plusgqualitycritical": false,'+
                  '"parent": "1364961",'+
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
                  '"plusprevnum": 0,'+
                  '"ngme_remdreq": false,'+
                  '"ngme_siteworkswo": false,'+
                  '"estatapprmatcost": 0,'+
                  '"taskid": 20,'+
                  '"plusgdefmeasreq": false,'+
                  '"wopriority": 1,'+
                  '"pluscloop": false,'+
                  '"plusgdocsattached": false,'+
                  '"plusgtemp": false,'+
                  '"actmatcost": 0,'+
                  '"actlabhrs": 0,'+
                  '"nestedjpinprocess": false,'+
                  '"pluspcustomer": "EFG",'+
                  '"plusdisprereq": false,'+
                  '"estatapprtoolcost": 0,'+
                  '"ngme_ocr_ft": false,'+
                  '"hasfollowupwork": false,'+
                  '"ngme_picofreg": false,'+
                  '"pluspagreement": "2126",'+
                  '"plusgmpoverride": false,'+
                  '"actservcost": 0,'+
                  '"flowactionassist": false,'+
                  '"ignorediavail": false,'+
                  '"reqasstdwntime": false,'+
                  '"estmatcost": 0,'+
                  '"pluspporeq": false,'+
                  '"targcompdate": "2025-12-31T18:00:00+00:00",'+
                  '"pluspallowquote": false,'+
                  '"plusgtestcert": false,'+
                  '"status": "WAPPR",'+
                  '"template": false,'+
                  '"commodity": "EXCFT65",'+
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
                  '"vendor": "SGN_SCO",'+
                  '"assetnum": "20567004",'+
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
                  '"statusdate": "2025-12-17T09:04:56+00:00",'+
                  '"downtime": false,'+
                  '"workorderid": 1333286,'+
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
                  '"respondby": "2025-12-18T17:04:56+00:00",'+
                  '"plusglesslearned": false,'+
                  '"estatapprlabcost": 0,'+
                  '"pluspallowquotelabor": false,'+
                  '"plusppricesched": "1P",'+
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
                  '"changedate": "2025-12-17T09:05:13+00:00",'+
                  '"ngme_task_code_description": "New meter procurement ETA",'+
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
                  '"targstartdate": "2025-12-31T14:00:00+00:00",'+
                  '"plusgtgtdatemod": false,'+
                  '"plusdsabotage": false,'+
                  '"flowcontrolled": false,'+
                  '"ams": false,'+
                  '"reportdate": "2025-12-17T09:04:56+00:00",'+
                  '"ngme_microbusiness": false,'+
                  '"description": "order ETA 25/12",'+
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
                  '"wogroup": "1364961",'+
                  '"location": "1054529901",'+
                  '"estintlabcost": 0,'+
                  '"plusglock": false,'+
                  '"plusgsafetycrit": false,'+
                  '"haschildren": false,'+
                  '"ngme_bfltdrwng": false'+
                '}'+
              '],'+
              '"status": "HOLD",'+
              '"wonum": "1364961"'+
            '}'+
          ']'+
        '}'+
      '],'+
      '"targetfinish": "2025-12-31T18:00:00+00:00",'+
      '"ngme_justify": false,'+
      '"assetnum": "20567004",'+
      '"actualstart": "2025-12-13T16:17:39+00:00",'+
      '"location": "1054529901",'+
      '"locations": ['+
        '{'+
          '"ngme_lf_mksctcd": "I",'+
          '"ngme_mktseccode": "I",'+
          '"ngme_lf_mksctcd_description": "Industrial & Commercial",'+
          '"ngme_mktseccode_description": "Industrial & Commercial",'+
          '"siteid": "SCO",'+
          '"location": "1054529901"'+
        '}'+
      '],'+
      '"class": "SR",'+
      '"np_statusmemo": "",'+
      '"ticketid": "1966342",'+
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