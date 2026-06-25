public class NGMCP_AppntDeappFuture {

    @future(callout=true)
    public static void callExternalAPI(
        Id bulkRequestId,
        Id requestId,
        String payload,
        Id userId,
        String action,
        Integer index,
        Integer totalSize,
        Set<Id> brIds
    ) {
        String status;
        String responseMsg;
		Set<Id> brIdsSet = brIds;
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(
                'callout:NGMCP_Maximo_Named_Credential' +
                '/NGME_LIRY_APPT_DAPPT' +
                '?relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1'
            );
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(payload);
            req.setTimeout(120000);
			System.debug('Payload: '+payload);
            System.debug('req: '+req);
            HttpResponse res = new Http().send(req);
			System.debug('res: '+res);
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {

                Map<String, Object> result =
                    (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
				System.debug('result: '+result);
                String ticket = String.valueOf(result.get('ngme_headerid'));
				System.debug('ticket: '+ticket);
                status = 'Completed';
                NGMCP_Request__c newReq = [Select Id, Name FROM NGMCP_Request__c where Id =: requestId];
                System.debug('newReq: '+newReq);
                if(action == 'Appointment'){
                            responseMsg = 'The appointment request has been created successfully.\n' +
                        'The reference number is ' + newReq.Name;
                        }
                        if(action == 'Deappointment'){
                          responseMsg = 'The deappointment request has been created successfully.\n' +
                        'The reference number is ' + newReq.Name;
                        }
				System.debug('responseMsg: '+responseMsg);
                update new NGMCP_Request__c(
                    Id = requestId,
                    NGMCP_Callout_Status__c = 'Completed',
                    NGMCP_Callout_Response__c = res.getBody(),
                    NGMCP_Header_Id__c = ticket,
                    NGMCP_Status__c = 'Submitted'
                );
            }
            else {
                status = 'Failed';
                responseMsg = 'Submit error: ' + res.getBody();
                System.debug('responseMsg: '+responseMsg);
                update new NGMCP_Request__c(
                Id = requestId,
                NGMCP_Callout_Status__c   = 'Completed',
                        NGMCP_Callout_Response__c = res.getBody()
                        );
            }

        } catch (Exception e) {
            status = 'Submission Failed';
            responseMsg = 'Submit exception: ' + e.getMessage();
            System.debug('responseMsg: '+responseMsg);
            update new NGMCP_Request__c(
                Id = requestId,
                NGMCP_Callout_Status__c   = 'Completed',
                        NGMCP_Callout_Response__c = responseMsg
                        );
        }

        update new NGMCP_Bulk_Request__c(
            Id = bulkRequestId,
            NGMCP_Status__c = status,
            NGMCP_Response__c = responseMsg,
            NGMCP_Request_Id__c = requestId
        );

        // ✅ Send CSV ONLY ON LAST RECORD
        if (index == totalSize - 1) {
            System.debug('inside if: ');
            sendFinalEmail(userId, action, brIdsSet);
        }
    }

    // ✅ CSV restored EXACTLY as required
    private static void sendFinalEmail(
        Id userId,
        String action,
        Set<Id> brIds
    ) {

        // ✅ REQUIRED METHOD
        String csv = NGMCP_AMRBulkController.buildCsv(new List<Id>(brIds));
		System.debug('csv: '+csv);
        User u = [SELECT Id FROM User WHERE Id = :userId];
		System.debug('user: '+u);
        Messaging.SingleEmailMessage mail =
            new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(u.Id);
        mail.setSaveAsActivity(false);
        mail.setSubject(action + ' Bulk Results');
        mail.setPlainTextBody('Please find the attached results.');

        Messaging.EmailFileAttachment att =
            new Messaging.EmailFileAttachment();
        att.setFileName(action + '_Bulk_Result.csv');
        att.setContentType('text/csv');
        att.setBody(Blob.valueOf(csv));

        mail.setFileAttachments(
            new Messaging.EmailFileAttachment[] { att }
        );

        Messaging.sendEmail(
            new Messaging.SingleEmailMessage[] { mail }
        );
        System.debug('sendEmail: '+Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false));
    }
}