/*
** Description: This testclass is used in CRM**
*/
@isTest
private class testinboundfinanceemail {

    @isTest
    static void validateHelloWorld() {
        Account testAccount = new Account(Name = 'Test Account Name');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Test',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Handler extracts Case Id via substringBefore('CO'), so avoid Ids containing "CO".
        Case testCase = createCaseForInboundEmail(testContact.Id, testAccount.Id);
        testCase.Good_Will_Cheque_Sent__c = false;
        update testCase;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'RE: ACC ' + testCase.Id + ' CO -125';
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'clara.gaunt@nationalgrid.com';

        Test.startTest();
        Messaging.InboundEmailResult result = new inboundfinanceemail().handleInboundEmail(email, env);
        Test.stopTest();

        System.assertEquals(true, result.success, 'Inbound email handler should succeed');

        Case updatedCase = [
            SELECT Good_Will_Cheque_Sent__c
            FROM Case
            WHERE Id = :testCase.Id
        ];
        System.assertEquals(true, updatedCase.Good_Will_Cheque_Sent__c);
    }

    private static Case createCaseForInboundEmail(Id contactId, Id accountId) {
        Id complaintRecordTypeId;
        List<RecordType> complaintRecordTypes = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Case' AND DeveloperName = 'Complaint'
            LIMIT 1
        ];
        if (!complaintRecordTypes.isEmpty()) {
            complaintRecordTypeId = complaintRecordTypes[0].Id;
        }

        Case testCase;
        for (Integer attempt = 0; attempt < 25; attempt++) {
            testCase = new Case(
                ContactId = contactId,
                AccountId = accountId,
                Status = 'Working',
                Origin = 'Phone',
                RecordTypeId = complaintRecordTypeId
            );
            insert testCase;

            if (!String.valueOf(testCase.Id).contains('CO')) {
                return testCase;
            }

            delete testCase;
        }

        System.assert(false, 'Unable to create a Case Id that parses correctly from the inbound email subject.');
        return testCase;
    }
}