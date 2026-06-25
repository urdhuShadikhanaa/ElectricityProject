public class NgmcpAddressEmailQueueable implements Queueable {

    private List<Ngmcp_request__c> records;

    public NgmcpAddressEmailQueueable(List<Ngmcp_request__c> records){

        this.records = records;

    }

    public void execute(QueueableContext context){

        String labelValue = System.Label.NGMCP_Address_Amendent;

        if (String.isBlank(labelValue)) return;

        List<String> recipients = new List<String>();

        for (String email : labelValue.split(',')) {

            if (String.isNotBlank(email)) {

                recipients.add(email.trim());

            }

        }

        if (recipients.isEmpty()) return;

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for (Ngmcp_request__c rec : records) {

            Messaging.SingleEmailMessage mail =

                new Messaging.SingleEmailMessage();

            mail.setToAddresses(recipients);

            mail.setSubject('Address Amendment Notification');

            String body =

                'An address amendment has been actioned via the NGM Customer Portal for MPRN '

                + rec.NGMCP_MPRN__c

                + '\n\nPlease review in case of any follow up action.';

            mail.setPlainTextBody(body);

            mails.add(mail);

        }

        if (!mails.isEmpty()) {

            Messaging.sendEmail(mails);

        }

    }

}