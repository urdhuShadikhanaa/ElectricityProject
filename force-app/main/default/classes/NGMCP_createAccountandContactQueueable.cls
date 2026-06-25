public with sharing class NGMCP_createAccountandContactQueueable implements Queueable {
    
    private final List<platforEventWrapper> rows;
    private final String actionType;
    
    // Lightweight DTO built from the Platform Event payload
    public class platforEventWrapper {
        public Id contactId;          // Ignored per new requirement (we always create a new Contact)
        public String firstName;
        public String lastName;
        public String email;
        public String username;
        public String role;
        public String supplierCode;
        public String supplierGroup;
        public String requestedEmail;
        public Id accountId; // single requester email for notifications
    }
    
    public NGMCP_createAccountandContactQueueable(List<platforEventWrapper> wrapperData, String actionType) {
        this.rows = wrapperData;
        this.actionType = actionType;
    }
    
    public void execute(QueueableContext qc) {
        if (rows == null || rows.isEmpty()) {
            return;
        }
        /* ---------------------------------------------
        1) Resolve Account by Supplier Group (name)
            - If missing, create Account(Name = Supplier Group)
            --------------------------------------------- */
        Set<String> groupNames = new Set<String>();
        Id accountId;
        for (platforEventWrapper r : rows) {
            if (!String.isBlank(r.supplierGroup)) {
                groupNames.add(r.supplierGroup.trim());
                if (r.accountId != null && accountId == null) {
                    accountId = r.accountId;
                }
            }
        }
        
        Map<String, Account> nameToAccount = new Map<String, Account>();
        if (!groupNames.isEmpty()) {
            for (Account a : [SELECT Id, Name FROM Account WHERE Name IN :groupNames WITH USER_MODE]) {
                nameToAccount.put(a.Name, a);
            }
            // Create missing
            List<Account> accToInsert = new List<Account>();
            for (String gName : groupNames) {
                if (!nameToAccount.containsKey(gName)) {
                    accToInsert.add(new Account(Name = gName, OwnerId=accountId));
                }
            }
            if (!accToInsert.isEmpty()) {
                Database.SaveResult[] ar = Database.insert(accToInsert, false);
                for (Integer i = 0; i < ar.size(); i++) {
                    if (ar[i].isSuccess()) {
                        Account a = accToInsert[i];
                        nameToAccount.put(a.Name, new Account(Id = ar[i].getId(), Name = a.Name));
                    } else {
                        for (Database.Error err : ar[i].getErrors()) {
                            System.debug(LoggingLevel.ERROR,
                            'Account insert failed: Name=' + accToInsert[i].Name + ' | ' +
                                err.getStatusCode() + ' - ' + err.getMessage());
                        }
                    }
                }
            }
        }
        
        /* ---------------------------------------------
        2) ALWAYS create Contacts (ignore if provided contactId)
            - One contact per row for the resolved Account
            --------------------------------------------- */
        List<Contact> contactsToInsert = new List<Contact>();
        // Keep the row index alongside the contact so we can map back after insert
        List<Integer> contactRowIndexes = new List<Integer>();
       Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        for (Integer i = 0; i < rows.size(); i++) {
            platforEventWrapper r = rows[i];            
            // Need a resolvable Account and an email to create a contact
            Account acc = (r.supplierGroup == null) ? null : nameToAccount.get(r.supplierGroup.trim());
            if (acc == null) {
                continue;
            }
            if (String.isBlank(r.email)) {
                continue;
            }
            
            contactsToInsert.add(new Contact(
            RecordTypeId = recordTypeId,
            FirstName = String.isBlank(r.firstName) ? 'Community User' : r.firstName,
            LastName  = String.isBlank(r.lastName)  ? 'Community User' : r.lastName,
            Email     = r.email,
            AccountId = acc.Id
                ));
            contactRowIndexes.add(i);
        }
        
        // Insert all contacts (partial success)
        List<Database.SaveResult> contactResults = new List<Database.SaveResult>();
        if (!contactsToInsert.isEmpty()) {
            contactResults = Database.insert(contactsToInsert, false);
        }
        
        /* ---------------------------------------------
        3) Build wrappers for User creation based on
            the newly inserted Contact IDs; collect failures
            --------------------------------------------- */
            List<NGMCP_CreatePortalUserJob.UserEventWrapper> userWrappers = new List<NGMCP_CreatePortalUserJob.UserEventWrapper>();
        List<FailureRow> failureRows = new List<FailureRow>();
        
        for (Integer i = 0; i < contactsToInsert.size(); i++) {
            Database.SaveResult sr = contactResults[i];
            Integer rowIndex = contactRowIndexes[i];
            platforEventWrapper r = rows[rowIndex];
            
            if (!sr.isSuccess()) {
                // Aggregate error messages for this row
                List<String> msgs = new List<String>();
                for (Database.Error err : sr.getErrors()) {
                    msgs.add(err.getStatusCode() + ' - ' + err.getMessage());
                }
                failureRows.add(new FailureRow(r, String.join(msgs, ' | ')));
                continue;
            }
            
            Id newContactId = sr.getId();
            String finalUsername = String.isBlank(r.username)
                ? r.email + '.' + String.valueOf(Datetime.now().getTime())
                : r.username;
            
            userWrappers.add(new NGMCP_CreatePortalUserJob.UserEventWrapper(
                newContactId,
            r.role,
            finalUsername,
            r.email,
            r.supplierCode,
            r.supplierGroup
                ));
        }
        
        /* ---------------------------------------------
        4) If failures exist, send ONE email to a single requester
            with a single CSV attachment of all failed rows
            --------------------------------------------- */
        if (!failureRows.isEmpty()) {
            // Find the single requester email from input rows
            String requester = null;
            for (platforEventWrapper r : rows) {
                if (!String.isBlank(r.requestedEmail)) {
                    requester = r.requestedEmail.trim();
                    break;
                }
            }
            
            if (!String.isBlank(requester)) {
                String fileName = 'Contact_Failures_' + DateTime.now().format('yyyyMMdd_HHmmss') + '.csv';
                String csvText  = buildFailureCsv(failureRows);
                Blob csvBody    = Blob.valueOf(csvText);
                
                // Optional: size guard (~8MB) to avoid attachment failures
                Integer maxBytes = 8 * 1024 * 1024;
                if (csvBody.size() <= maxBytes) {
                    Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
                    att.setFileName(fileName);
                    att.setContentType('text/csv');
                    att.setBody(csvBody);
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    OrgWideEmailAddress[] owea  = [ SELECT Id FROM OrgWideEmailAddress WHERE Address =: System.Label.NGMCP_Organisation_wide_Adrees_Email WITH USER_MODE LIMIT 1];
                    if (owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    mail.setToAddresses(new List<String>{requester});
                    mail.setSubject('NGMCP - Contact Creation Failures (' + failureRows.size() + ')');
                    mail.setPlainTextBody(
                        'Hello,' + '\n\n' +
                        'Some records failed during Contact creation. Please review the attached CSV for details.' + '\n\n' +
                        'Regards,' + '\n' +
                        'NGMCP Automation'
                        );
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[]{ att });
                    
                    try {
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
                    } catch (Exception e) {
                        System.debug(LoggingLevel.ERROR, 'Failed to send failure email to ' + requester + ' : ' + e.getMessage());
                    }
                }
            }
        }
        
        /* ---------------------------------------------
        5) Chain Queueable #2 to create Users (ONE enqueue)
            --------------------------------------------- */
        if (!userWrappers.isEmpty() ) {
            if (!Test.isRunningTest()) {
                System.enqueueJob(new NGMCP_CreatePortalUserJob(userWrappers, actionType));
            }
        }
    }
    
    /* ================================
    Failure model and CSV helpers
        ================================ */
    public class FailureRow {
        public String firstName, lastName, email, username, role, supplierCode, supplierGroup, errorMessage, requesterEmail;
        public FailureRow(platforEventWrapper r, String errMsg){
            this.firstName     = r.firstName;
            this.lastName      = r.lastName;
            this.email         = r.email;
            this.username      = r.username;
            this.role          = r.role;
            this.supplierCode  = r.supplierCode;
            this.supplierGroup = r.supplierGroup;
            this.requesterEmail= r.requestedEmail;
            this.errorMessage  = errMsg;
        }
    }
    
    // --- CSV escaping (quote + escape inner quotes) ---
    @testVisible
    private static String csv(String s) {
        if (s == null) return '""';
        String v = s.replace('"', '""');
        return '"' + v + '"';
    }
    
    // --- Build CSV using List<String> + String.join (Apex-friendly) ---
    @testVisible
    private static String buildFailureCsv(List<FailureRow> rows) {
        // Header line
        String header = String.join(new List<String>{
            'FirstName','LastName','Email','Username','Role','SupplierCode','SupplierGroup','Error'
        }, ',');
        
        // Accumulate lines (header + rows)
        List<String> lines = new List<String>();
        lines.add(header);
        
        for (FailureRow r : rows) {
            lines.add(
            String.join(new List<String>{
                csv(r.firstName),
                csv(r.lastName),
                csv(r.email),
                csv(r.username),
                csv(r.role),
                csv(r.supplierCode),
                csv(r.supplierGroup),
                csv(r.errorMessage)
            }, ',')
            );
        }
        return String.join(lines, '\n');
    }
}