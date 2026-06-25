@isTest
private class NGMCP_RequestsUpdateBatchTest {
	
    @isTest
    static void createTestData(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'WCUSTQAPPR';
        woc.status_description = 'Test waiting approval';
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'TGEN';
        woac.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woc.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        member.worklog = wlList;
        memberList.add(member);
        
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData2(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQAPPR';
        woc.status_description = 'Test waiting approval';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'TGEN';
        woac.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woc.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData3(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQREJ';
        woc.status_description = 'Test waiting approval';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'AMD';
        woac.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woc.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData4(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQREJ';
        woc.status_description = 'Test waiting approval';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'OIX';
        woac.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woc.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData5(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQREJ';
        woc.status_description = 'Test waiting approval';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'COM';
        woac.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woc.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
     @isTest
    static void createTestData6(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQREJ';
        woc.status_description = 'Test waiting approval';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'SV';
        woac.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woc.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData7(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQREJ';
        woc.status_description = 'Test waiting approval';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'Test';
        woac.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woc.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData8(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQREJ';
        woc.status_description = 'Test waiting approval';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'TGEN';
        woac.taskid = 10;
        woac.description = 'test date 28/12';
        NGMCP_RequestClass.WOActivityClass woac2 = new NGMCP_RequestClass.WOActivityClass();
        woac2.ngme_task_code = 'TGEN';
        woac2.taskid = 20;
        woac2.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woacList.add(woac2);
        woc.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData9(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQREJ';
        woc.status_description = 'Test waiting approval';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'AMD';
        woac.taskid = 10;
        woac.description = 'test date 28/12';
        NGMCP_RequestClass.WOActivityClass woac2 = new NGMCP_RequestClass.WOActivityClass();
        woac2.ngme_task_code = 'AMD';
        woac2.taskid = 20;
        woac2.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woacList.add(woac2);
        woc.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData10(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQREJ';
        woc.status_description = 'Test waiting approval';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'OIX';
        woac.taskid = 10;
        woac.description = 'test date 28/12';
        NGMCP_RequestClass.WOActivityClass woac2 = new NGMCP_RequestClass.WOActivityClass();
        woac2.ngme_task_code = 'OIX';
        woac2.taskid = 20;
        woac2.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woacList.add(woac2);
        woc.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData11(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQREJ';
        woc.status_description = 'Test waiting approval';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'COM';
        woac.taskid = 10;
        woac.description = 'test date 28/12';
        NGMCP_RequestClass.WOActivityClass woac2 = new NGMCP_RequestClass.WOActivityClass();
        woac2.ngme_task_code = 'COM';
        woac2.taskid = 20;
        woac2.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woacList.add(woac2);
        woc.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData12(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQREJ';
        woc.status_description = 'Test waiting approval';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'ATP';
        woac.taskid = 10;
        woac.description = 'test date 28/12';
        NGMCP_RequestClass.WOActivityClass woac2 = new NGMCP_RequestClass.WOActivityClass();
        woac2.ngme_task_code = 'ATP';
        woac2.taskid = 20;
        woac2.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woacList.add(woac2);
        woc.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData13(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQREJ';
        woc.status_description = 'Test waiting approval';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'test';
        woac.taskid = 10;
        woac.description = 'test date 28/12';
        NGMCP_RequestClass.WOActivityClass woac2 = new NGMCP_RequestClass.WOActivityClass();
        woac2.ngme_task_code = 'test';
        woac2.taskid = 20;
        woac2.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woacList.add(woac2);
        woc.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData14(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQAPPR';
        woc.status_description = 'Test waiting approval';
        woc.wonum = '1000';
        NGMCP_RequestClass.WorkOrderClass woc2 = new NGMCP_RequestClass.WorkOrderClass();
        woc2.status = 'CUSTQAPPR';
        woc2.status_description = 'Test waiting approval';
        woc2.wonum = '2000';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'TGEN';
        woac.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woc.woactivity = woacList;
        woc2.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        wocList.add(woc2);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData15(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQREJ';
        woc.status_description = 'Test waiting approval';
        woc.wonum = '1000';
        NGMCP_RequestClass.WorkOrderClass woc2 = new NGMCP_RequestClass.WorkOrderClass();
        woc2.status = 'CUSTQREJ';
        woc2.status_description = 'Test waiting approval';
        woc2.wonum = '2000';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'AMD';
        woac.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woc.woactivity = woacList;
        woc2.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        wocList.add(woc2);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData16(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'WCUSTQAPPR';
        woc.status_description = 'Test waiting approval';
        woc.wonum = '1000';
        NGMCP_RequestClass.WorkOrderClass woc2 = new NGMCP_RequestClass.WorkOrderClass();
        woc2.status = 'WCUSTQAPPR';
        woc2.status_description = 'Test waiting approval';
        woc2.wonum = '2000';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'OIX';
        woac.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woc.woactivity = woacList; 
        woc2.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        wocList.add(woc2);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData17(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQREJ';
        woc.status_description = 'Test waiting approval';
        woc.wonum = '1000';
        NGMCP_RequestClass.WorkOrderClass woc2 = new NGMCP_RequestClass.WorkOrderClass();
        woc2.status = 'CUSTQREJ';
        woc2.status_description = 'Test waiting approval';
        woc2.wonum = '2000';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'COM';
        woac.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woc.woactivity = woacList;
        woc2.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        wocList.add(woc2);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
     @isTest
    static void createTestData18(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQREJ';
        woc.status_description = 'Test waiting approval';
        woc.wonum = '1000';
        NGMCP_RequestClass.WorkOrderClass woc2 = new NGMCP_RequestClass.WorkOrderClass();
        woc2.status = 'CUSTQREJ';
        woc2.status_description = 'Test waiting approval';
        woc2.wonum = '2000';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'SV';
        woac.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woc.woactivity = woacList;
        woc2.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        wocList.add(woc2);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    @isTest
    static void createTestData19(){
        
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
        
        List<NGMCP_RequestClass.MemberClass> memberList = new List<NGMCP_RequestClass.MemberClass>();
        NGMCP_RequestClass.MemberClass member = new NGMCP_RequestClass.MemberClass();
        member.ticketid = '1966342';
        member.ticketuid = '3408798';
        member.ngme_resub = true;
        NGMCP_RequestClass.RelatedRecordClass rrc = new NGMCP_RequestClass.RelatedRecordClass();
        NGMCP_RequestClass.WorkOrderClass woc = new NGMCP_RequestClass.WorkOrderClass();
        woc.status = 'CUSTQREJ';
        woc.status_description = 'Test waiting approval';
        woc.wonum = '1000';
        NGMCP_RequestClass.WorkOrderClass woc2 = new NGMCP_RequestClass.WorkOrderClass();
        woc2.status = 'CUSTQREJ';
        woc2.status_description = 'Test waiting approval';
        woc2.wonum = '2000';
        NGMCP_RequestClass.WorkLogClass wlc = new NGMCP_RequestClass.WorkLogClass();
        wlc.logtype = 'REMINDER';
        wlc.ngme_adi_expdate = '2026-02-09T09:17:00+00:00';
        NGMCP_RequestClass.WorkLogClass wlc2 = new NGMCP_RequestClass.WorkLogClass();
        wlc2.logtype = 'REMINDER';
        wlc2.ngme_adi_expdate = '2026-02-09T08:17:00+00:00';
        List<NGMCP_RequestClass.WorkLogClass> wlList = new List<NGMCP_RequestClass.WorkLogClass>();
        wlList.add(wlc);
        wlList.add(wlc2);
        member.worklog = wlList;
        NGMCP_RequestClass.WOActivityClass woac = new NGMCP_RequestClass.WOActivityClass();
        woac.ngme_task_code = 'Test';
        woac.description = 'test date 28/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList.add(woac);
        woc.woactivity = woacList;
        woc2.woactivity = woacList;
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc);
        wocList.add(woc2);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        member.commoditygroup = 'QRT';
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
}