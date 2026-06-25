public with sharing class NGMCP_AppntDeappCalloutQueueable
    implements Queueable, Database.AllowsCallouts {

    @TestVisible
    private static Boolean executeChaining = true;

    private List<Id> brIds;
    private Integer index;
    private Id requestId;
    private String payload;
    private String action;
    private String mode;
    private Id userId;

    public NGMCP_AppntDeappCalloutQueueable(
        List<Id> brIds,
        Integer index,
        Id requestId,
        String payload,
        String action,
        String mode,
        Id userId
    ) {
        this.brIds = brIds;
        this.index = index;
        this.requestId = requestId;
        this.payload = payload;
        this.action = action;
        this.mode = mode;
        this.userId = userId;
    }

    public void execute(QueueableContext qc) {
        NGMCP_Bulk_Request__c br = [
            SELECT Id, NGMCP_Status__c, NGMCP_Request_Id__c, NGMCP_Service_Request_Number__c
            FROM NGMCP_Bulk_Request__c
            WHERE Id = :brIds[index]
            FOR UPDATE
        ];

        System.debug('Locked bulk request for callout: ' + br);

        // If already completed/failed by another chain, do nothing
        if (isTerminalStatus(br.NGMCP_Status__c)) {
            System.debug('Skipping callout because row is already terminal: ' + br.NGMCP_Status__c);
            return;
        }

        // If request id does not match, another chain has taken over / data changed
        if (br.NGMCP_Request_Id__c != null && br.NGMCP_Request_Id__c != requestId) {
            System.debug('Skipping callout because requestId mismatch.');
            return;
        }

        String status;
        String response;
        String reqName = '';

        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(
                'callout:NGMCP_Maximo_Named_Credential' +
                '/NGME_LIRY_APPT_DAPPT?relativeuri=1&lean=1'
            );
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(payload);
            req.setTimeout(120000);

            System.debug('HttpRequest: ' + req);

            HttpResponse res = new Http().send(req);

            System.debug('HttpResponse: ' + res);
            System.debug('Response body: ' + res.getBody());

            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                update new NGMCP_Request__c(
                    Id = requestId,
                    NGMCP_Status__c = 'Submitted',
                    NGMCP_Callout_Response__c = res.getBody(),
                    NGMCP_Callout_Status__c = 'Completed'
                );

                NGMCP_Request__c requestRec = [
                    SELECT Id, Name
                    FROM NGMCP_Request__c
                    WHERE Id = :requestId
                ];

                status = 'Completed';
                response =
                    (action == 'Appointment'
                        ? 'The appointment request has been created successfully.\n'
                        : 'The deappointment request has been created successfully.\n')
                    + 'The reference number is ' + requestRec.Name;
                reqName = requestRec.Name;
            } else {
                status = 'Failed';
                response = res.getBody();

                update new NGMCP_Request__c(
                    Id = requestId,
                    NGMCP_Callout_Response__c = res.getBody(),
                    NGMCP_Callout_Status__c = 'Completed'
                );
            }

        } catch (Exception e) {
            System.debug('Callout exception: ' + e.getMessage() + ' @line ' + e.getLineNumber());
            status = 'Failed';
            response = e.getMessage();
        }

        update new NGMCP_Bulk_Request__c(
            Id = br.Id,
            NGMCP_Status__c = status,
            NGMCP_Response__c = response,
            NGMCP_Request_Id__c = requestId,
            NGMCP_Service_Request_Number__c = reqName
        );

        // Continue chain or send final email
        if (!Test.isRunningTest() || (Test.isRunningTest() && executeChaining)) {
            if (index + 1 < brIds.size()) {
                if (!Test.isRunningTest()) {
                    System.enqueueJob(
                        new NGMCP_AppntDeappQueueable(
                            brIds,
                            index + 1,
                            action,
                            mode,
                            userId
                        )
                    );
                }
            } else {
                sendFinalEmail();
            }
        }
    }

    private void sendFinalEmail() {
        // Extra guard: send email only when all rows are terminal
        List<NGMCP_Bulk_Request__c> rows = [
            SELECT Id, NGMCP_Status__c
            FROM NGMCP_Bulk_Request__c
            WHERE Id IN :brIds
        ];

        for (NGMCP_Bulk_Request__c row : rows) {
            if (!isTerminalStatus(row.NGMCP_Status__c)) {
                System.debug('Skipping final email because not all rows are terminal yet.');
                return;
            }
        }

        String csv = NGMCP_AMRBulkController.buildCsv(brIds);
        System.debug('csv: ' + csv);

        User u = [SELECT Id FROM User WHERE Id = :userId];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(u.Id);
        mail.setSaveAsActivity(false);
        mail.setSubject(action + ' Bulk Results');
        mail.setPlainTextBody('Please find the attached results.');

        Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
        att.setFileName(action + '_Bulk_Result.csv');
        att.setContentType('text/csv');
        att.setBody(Blob.valueOf(csv));

        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { att });

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    private static Boolean isTerminalStatus(String status) {
        return status == 'Completed' ||
               status == 'Failed' ||
               status == 'Creation Failed';
    }
}