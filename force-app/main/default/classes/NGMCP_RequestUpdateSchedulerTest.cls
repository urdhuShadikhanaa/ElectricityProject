@isTest
private class NGMCP_RequestUpdateSchedulerTest {
	@testSetup
    static void createTestData(){
        NGMCP_Request__c reqIns = new NGMCP_Request__c();
        reqIns.NGMCP_SR_Ticket__c = '1966314';
        reqIns.NGMCP_Ticketuid__c = '3389739';
        insert reqIns;
        NGMCP_Request__c reqIns2 = new NGMCP_Request__c();
        reqIns2.NGMCP_SR_Ticket__c = '1966352';
        reqIns2.NGMCP_Ticketuid__c = '3408997';
        insert reqIns2;
        NGMCP_Request__c reqIns3 = new NGMCP_Request__c();
        reqIns3.NGMCP_SR_Ticket__c = '1966345';
        reqIns3.NGMCP_Ticketuid__c = '3408849';
        insert reqIns3;
        NGMCP_Request__c reqIns4 = new NGMCP_Request__c();
        reqIns4.NGMCP_SR_Ticket__c = '1966342';
        reqIns4.NGMCP_Ticketuid__c = '3408798';
        insert reqIns4;
    }
    
	@isTest
    static void testScheduledJob1() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_RequestUpdateMockCalloutTest1());
        String cronExp = '0 15 * * * ?'; 
        Test.startTest();
        	String jobId = System.schedule('TRequest Update - Every 15 mins at 15th min', cronExp, new NGMCP_RequestUpdateScheduler());
        Test.stopTest(); 

        System.assertNotEquals(null, jobId, 'Job should be scheduled successfully');
    }
    @isTest
    static void testScheduledJob2() {
        Test.setMock(HttpCalloutMock.class, new NGMCP_RequestUpdateMockCalloutTest2());
        String cronExp = '0 15 * * * ?'; 
        Test.startTest();
        	String jobId = System.schedule('TRequest Update - Every 15 mins at 15th min', cronExp, new NGMCP_RequestUpdateScheduler());
        Test.stopTest(); 

        System.assertNotEquals(null, jobId, 'Job should be scheduled successfully');
    }
    
    @isTest
    static void testBatch1(){
        
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
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }
    
    @isTest
    static void testBatch2(){
        
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
        NGMCP_RequestClass.WorkOrderClass woc1 = new NGMCP_RequestClass.WorkOrderClass();
        NGMCP_RequestClass.WOActivityClass woac1 = new NGMCP_RequestClass.WOActivityClass();
        woac1.ngme_task_code = 'TGEN';
        woac1.description = 'test date 28/12';
        woac1.taskid = 5;
        NGMCP_RequestClass.WOActivityClass woac2 = new NGMCP_RequestClass.WOActivityClass();
        woac2.ngme_task_code = 'TGEN';
        woac2.description = 'test date 30/12';
        woac2.taskid = 10;
        List<NGMCP_RequestClass.WOActivityClass> woacList1 = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList1.add(woac1);
        woacList1.add(woac2);
        woc1.woactivity = woacList1;
        woc1.wonum = '1234';
        NGMCP_RequestClass.WorkOrderClass woc2 = new NGMCP_RequestClass.WorkOrderClass();
        NGMCP_RequestClass.WOActivityClass woac3 = new NGMCP_RequestClass.WOActivityClass();
        woac3.ngme_task_code = 'TGEN';
        woac3.description = 'test date 22/12';
        NGMCP_RequestClass.WOActivityClass woac4 = new NGMCP_RequestClass.WOActivityClass();
        woac4.ngme_task_code = 'TGEN';
        woac4.description = 'test date 31/12';
        List<NGMCP_RequestClass.WOActivityClass> woacList2 = new List<NGMCP_RequestClass.WOActivityClass>();
        woacList2.add(woac3);
        woacList2.add(woac4);
        woc2.woactivity = woacList1;
        woc2.wonum = '5678';
        List<NGMCP_RequestClass.WorkOrderClass> wocList = new List<NGMCP_RequestClass.WorkOrderClass>();
        wocList.add(woc1);
        wocList.add(woc2);
        rrc.workorder = wocList;
        List<NGMCP_RequestClass.RelatedRecordClass> rrcList = new List<NGMCP_RequestClass.RelatedRecordClass>();
        rrcList.add(rrc);
        member.relatedrecord = rrcList;
        memberList.add(member);
        test.startTest();
        Database.executeBatch(new NGMCP_RequestsUpdateBatch(memberList), 20);
        test.stopTest();
    }



}