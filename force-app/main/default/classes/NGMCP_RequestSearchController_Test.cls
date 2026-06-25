@IsTest
private class NGMCP_RequestSearchController_Test {

    // Returns any existing RecordType Id for NGMCP_Request__c if available; otherwise null.
    private static Id getAnyRequestRecordTypeId() {
        List<RecordType> rts = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'NGMCP_Request__c'
            LIMIT 1
        ];
        return (rts.isEmpty()) ? null : rts[0].Id;
    }

    @testSetup
    static void setupData() {
        Id reqRtId = getAnyRequestRecordTypeId();

        // --- Build request records WITHOUT inline list literal (avoids bracket glitches) ---
        List<NGMCP_Request__c> reqs = new List<NGMCP_Request__c>();
        reqs.add(new NGMCP_Request__c(
            RecordTypeId = reqRtId,
            NGMCP_MPRN__c = '9876543210',
            NGMCP_SR_Ticket__c = 'SR-001',
            NGMCP_Job_Type__c = 'INSTALL',
            NGMCP_Job_SubType__c = 'SMART',
            NGMCP_Status__c = 'Open',
            NGMCP_Supplier_Id__c = 'SC-11'
        ));
        reqs.add(new NGMCP_Request__c(
            RecordTypeId = reqRtId,
            NGMCP_MPRN__c = '1234567890',
            NGMCP_SR_Ticket__c = 'SR-ABC',
            NGMCP_Job_Type__c = 'EXCHANGE',
            NGMCP_Job_SubType__c = 'LEGACY',
            NGMCP_Status__c = 'Closed',
            NGMCP_Supplier_Id__c = 'SC-22'
        ));
        reqs.add(new NGMCP_Request__c(
            RecordTypeId = reqRtId,
            NGMCP_MPRN__c = '1230000000',
            NGMCP_SR_Ticket__c = 'SR-999',
            NGMCP_Job_Type__c = 'REMOVAL',
            NGMCP_Job_SubType__c = 'FAULT',
            NGMCP_Status__c = 'Pending',
            NGMCP_Supplier_Id__c = 'SC-22'
        ));
        insert reqs;

        // Account for WorkOrders
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Insert WorkOrders (WorkOrderNumber is auto-number)
        WorkOrder wo1 = new WorkOrder(
            Subject = 'WO One',
            Status  = 'New',
            AccountId = acc.Id,
            FFA_MeterPointReferenceNumber__c = 'MPRN-111',
            FFA_JobCode__c = 'JC-10',
            FFA_JobDescription__c = 'Install Smart',
            FFA_ShipperID__c = 'SC-11',
            FFA_ShipperName__c = 'Supplier A'
        );
        WorkOrder wo2 = new WorkOrder(
            Subject = 'WO Two',
            Status  = 'Closed',
            AccountId = acc.Id,
            FFA_MeterPointReferenceNumber__c = 'MPRN-222',
            FFA_JobCode__c = 'JC-20',
            FFA_JobDescription__c = 'Exchange Legacy',
            FFA_ShipperID__c = 'SC-22',
            FFA_ShipperName__c = 'Supplier B'
        );
        insert new List<WorkOrder>{ wo1, wo2 };
    }

    // --- Tests for search(...) on NGMCP_Request__c ---------------------------

    @IsTest
    static void testRequestSearch_WithAllFilters() {
        String fromStr = String.valueOf(Date.today().addDays(-1)); // 'YYYY-MM-DD'
        String toStr   = String.valueOf(Date.today().addDays(1));

        Test.startTest();
        try {
            List<NGMCP_RequestSearchController.RequestRowDTO> rows =
                NGMCP_RequestSearchController.search('123', 'SR-', fromStr, toStr, 'SC-22');

            System.assertNotEquals(null, rows, 'Result must not be null');
            System.assert(rows.size() >= 1, 'Expected at least one match');

            NGMCP_RequestSearchController.RequestRowDTO r = rows[0];
            System.assertNotEquals(null, r.id);
            System.assert(r.nameUrl.startsWith('/lightning/r/NGMCP_Request__c/'), 'Name URL format');
            System.assertEquals('SC-22', r.shortCode);
            System.assertNotEquals(null, r.createdDate, 'CreatedDate should be Date only');
        } finally {
            Test.stopTest();
        }
    }

    @IsTest
    static void testRequestSearch_InvalidAndSwapDates() {
        Test.startTest();
        try {
            // Part 1: invalid date string is ignored -> returns data
            List<NGMCP_RequestSearchController.RequestRowDTO> rows1 =
                NGMCP_RequestSearchController.search(null, null, 'not-a-date', null, null);
            System.assert(rows1.size() > 0, 'Invalid date should not filter out data');

            // Part 2: from > to triggers swap branch (should not throw and should return a list)
            List<NGMCP_RequestSearchController.RequestRowDTO> rows2 =
                NGMCP_RequestSearchController.search(null, null, '2100-01-10', '2100-01-01', null);
            System.assertNotEquals(null, rows2, 'Should return a list even when swapped');
        } finally {
            Test.stopTest();
        }
    }

    // --- Tests for getWorkOrderId(...) ---------------------------------------

    @IsTest
    static void testGetWorkOrderId_Blank_Throws() {
        Boolean threw = false;

        Test.startTest();
        try {
            NGMCP_RequestSearchController.getWorkOrderId('');
        } catch (AuraHandledException ahe) {
            threw = true;
            // Do NOT assert on exact message; different orgs may format slightly differently.
        } finally {
            Test.stopTest(); // one stopTest only
        }

        System.assert(threw, 'Should throw AuraHandledException for blank input');
    }

    @IsTest
    static void testGetWorkOrderId_Branches() {
        WorkOrder wo = [
            SELECT Id, WorkOrderNumber, FFA_MeterPointReferenceNumber__c
            FROM WorkOrder
            LIMIT 1
        ];

        Test.startTest();
        try {
            // Branch: non-8-digit or not starting with '0' -> uses custom MPRN field
            Id found = NGMCP_RequestSearchController.getWorkOrderId(wo.FFA_MeterPointReferenceNumber__c);
            System.assertEquals(wo.Id, found, 'Should find WO by custom MPRN field');

            // Branch: 8 digits starting with '0' -> uses WorkOrderNumber (no match expected)
            Id notFound = NGMCP_RequestSearchController.getWorkOrderId('01234567');
            System.assertEquals(null, notFound, 'Branch executed; no WO with that auto-number expected');
        } finally {
            Test.stopTest();
        }
    }

    // --- Tests for workOrdersearch(...) --------------------------------------

    @IsTest
    static void testWorkOrderSearch_WithAllFilters() {
        List<WorkOrder> wos = [
            SELECT Id, WorkOrderNumber, Status,
                   FFA_MeterPointReferenceNumber__c, FFA_JobCode__c, FFA_JobDescription__c,
                   FFA_ShipperID__c, FFA_ShipperName__c, CreatedDate
            FROM WorkOrder
            ORDER BY CreatedDate ASC
        ];
        System.assert(wos.size() >= 2, 'Setup should have 2 WOs');

        WorkOrder target = wos[0];
        String fromStr = String.valueOf(Date.today().addDays(-1));
        String toStr   = String.valueOf(Date.today().addDays(1));

        Test.startTest();
        try {
            List<NGMCP_RequestSearchController.WorkOrderRowDTO> rows =
                NGMCP_RequestSearchController.workOrdersearch(
                    target.FFA_MeterPointReferenceNumber__c,
                    target.WorkOrderNumber,
                    fromStr,
                    toStr,
                    target.FFA_ShipperID__c
                );
            System.assert(rows.size() >= 1, 'Expected at least one matching WO');

            NGMCP_RequestSearchController.WorkOrderRowDTO dto = rows[0];
            System.assertEquals(target.WorkOrderNumber, dto.WorkOrderNumber);
            System.assertEquals(target.FFA_MeterPointReferenceNumber__c, dto.mprn);
            System.assertEquals(target.FFA_JobCode__c, dto.jobCode);
            System.assertEquals(target.FFA_JobDescription__c, dto.jobDescription);
            System.assertEquals(target.Status, dto.status);
            System.assertEquals(target.FFA_ShipperID__c, dto.SupplierId);
            System.assertEquals(target.FFA_ShipperName__c, dto.SupplierName);
            System.assert(dto.nameUrl.startsWith('/lightning/r/WorkOrder/'), 'Lightning WO URL');
            System.assertNotEquals(null, dto.createdDate, 'CreatedDate should be Date (not DateTime)');
        } finally {
            Test.stopTest();
        }
    }

    @IsTest
    static void testWorkOrderSearch_SwapDatesAndLikeFilters() {
        WorkOrder anyWo = [
            SELECT Id, WorkOrderNumber, FFA_MeterPointReferenceNumber__c
            FROM WorkOrder
            LIMIT 1
        ];

        Test.startTest();
        try {
            List<NGMCP_RequestSearchController.WorkOrderRowDTO> rows =
                NGMCP_RequestSearchController.workOrdersearch(
                    anyWo.FFA_MeterPointReferenceNumber__c,
                    anyWo.WorkOrderNumber,
                    '2100-02-10',  // from > to -> swap branch
                    '2100-02-01',
                    null
                );
            System.assertNotEquals(null, rows, 'Should return a list even when swapped');
        } finally {
            Test.stopTest();
        }
    }
}