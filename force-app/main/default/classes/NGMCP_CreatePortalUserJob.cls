// ===== START =====
public with sharing class NGMCP_CreatePortalUserJob implements Queueable {
    
    /* ================================
    WRAPPER TO HOLD EVENT DATA
        ================================ */
    public class UserEventWrapper {
        public Id contactId;
        public String role;
        public String username;
        public String email;
        public String supplierCode;
        public String supplierGroup;
        
        public UserEventWrapper(
            Id contactId,
        String role,
        String username,
        String email,
        String supplierCode,
        String supplierGroup
        ) {
            this.contactId     = contactId;
            this.role          = role;
            this.username      = username;
            this.email         = email;
            this.supplierCode  = supplierCode;
            this.supplierGroup = supplierGroup;
        }
    }
    
    /* ================================
    NEW: ERROR WRAPPER
        ================================ */
    public class UserErrorWrapper {
        public UserEventWrapper event;
        public String errorMessage;
        public Id userId;
        
        public UserErrorWrapper(UserEventWrapper event, String errorMessage) {
            this.event = event;
            this.errorMessage = errorMessage;
        }
        public UserErrorWrapper(UserEventWrapper event, Id userId) {
            this.event = event;
            this.userId = userId;
            this.errorMessage = null;
        }
    }
    
    /* ================================
    INSTANCE DATA
        ================================ */
        private List<UserEventWrapper> events;
    private String actionType;
    private Integer retryCount;
    private  Blob failureCsv;
    private  Blob successCsv;
    
    public NGMCP_CreatePortalUserJob(List<UserEventWrapper> events) {
        this.events = events;
    }
    
    public NGMCP_CreatePortalUserJob(List<UserEventWrapper> events, String actionType) {
        this.events = events;
        this.actionType = actionType;
    }
    public NGMCP_CreatePortalUserJob(List<UserEventWrapper> events, String actionType, Integer retryCount) {
        this.events = events;
        this.actionType = actionType;
        this.retryCount = retryCount;
    }
    
    /* ================================
    EXECUTION
        ================================ */
    public void execute(QueueableContext qc) {
        
        if (events == null || events.isEmpty()) {
            return;
        }
        
        /* -------------------------------
        1) Resolve Profiles
            -------------------------------- */
        Map<String, Id> roleToProfileId = new Map<String, Id>();
        List<String> profileNames = new List<String>{
            System.Label.NGMCP_Gas_Supplier_Manager_Profile,
            System.Label.NGMCP_Gas_Supplier_Agent_Profile
        }; 
        for (Profile p : [
            SELECT Id, Name
            FROM Profile
            WHERE Name IN :profileNames WITH USER_MODE
        ]) {
            roleToProfileId.put(p.Name, p.Id);
        }
        
        /* -------------------------------
        2) Collect Contacts
            -------------------------------- */
            Set<Id> contactIds = new Set<Id>();
        for (UserEventWrapper e : events) {
            if (e != null && e.contactId != null) {
                contactIds.add(e.contactId);
            }
        }
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, FirstName, LastName
            FROM Contact
            WHERE Id IN :contactIds WITH USER_MODE
        ]);
        
        /* -------------------------------
        3) Picklist Canonical Maps
            -------------------------------- */
            Map<String, String> supplierCodeCanonicalMap  =
            buildCanonicalPicklistMap(User.Supplier_Code__c);
        Map<String, String> supplierGroupCanonicalMap =
            buildCanonicalPicklistMap(User.Supplier_Group__c);
        
        Boolean allowRawFallbackForCode  =
            !isRestrictedPicklist(User.Supplier_Code__c);
        Boolean allowRawFallbackForGroup =
            !isRestrictedPicklist(User.Supplier_Group__c);
        
        /* -------------------------------
        CREATE USERS
            -------------------------------- */
        if (actionType == 'create') {
            
            List<User> usersToInsert = new List<User>();
            List<UserErrorWrapper> failedUsers = new List<UserErrorWrapper>();
            List<UserEventWrapper> retryEvents = new List<UserEventWrapper>();
            List<UserErrorWrapper> successWrappers = new List<UserErrorWrapper>();
            for (UserEventWrapper e : events) {
                if (e == null) continue;                
                Contact c = contactMap.get(e.contactId);
                if (c == null) continue;
                
                String profileName =
                    e.role == 'Manager'
                    ? 'NGMCP_Gas Supplier Manager'
                    : 'NGMCP_Gas Supplier Agent';
                
                Id profileId = roleToProfileId.get(profileName);
                if (profileId == null){
                    continue;
                } 
                
                usersToInsert.add(new User(
                    FirstName         = String.isBlank(c.FirstName) ? 'Community User' : c.FirstName,
                LastName          = String.isBlank(c.LastName)  ? 'Community User' : c.LastName,
                Username          = e.username,
                Email             = e.email,
                Alias             = safeAlias(e.username),
                CommunityNickname = generateNickname(e.username),
                TimeZoneSidKey    = 'Europe/London',
                LocaleSidKey      = 'en_US',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey  = 'UTF-8',
                ProfileId         = profileId,
                ContactId         = c.Id,
                Supplier_Code__c  =
                    toCanonicalPicklist(e.supplierCode,
                supplierCodeCanonicalMap,
                allowRawFallbackForCode),
                Supplier_Group__c =
                    toCanonicalPicklist(e.supplierGroup,
                supplierGroupCanonicalMap,
                allowRawFallbackForGroup),
                IsActive          = true
                    ));
            }
            
            if (!usersToInsert.isEmpty()) {
                List<User> successfulUsers = new List<User>();
                Database.SaveResult[] results =
                    Database.insert(usersToInsert, false, AccessLevel.USER_MODE);
                
                for (Integer i = 0; i < results.size(); i++) {
                    if (results[i].isSuccess()) {
                        Id userId = results[i].getId();
                        usersToInsert[i].Id = userId;
                        successfulUsers.add(usersToInsert[i]);
                        
                        successWrappers.add(
                            new UserErrorWrapper(events[i], results[i].getId())
                            );
                    } else {
                        for (Database.Error err : results[i].getErrors()) {
                            failedUsers.add(
                                new UserErrorWrapper(
                                events[i],
                            err.getStatusCode() + ' - ' + err.getMessage()
                                )
                                );
                        }
                    }
                }
                
                
                /* ================================
                NEW: ERROR CSV + EMAIL
                    ================================ */
                if (!failedUsers.isEmpty()) {
                    failureCsv = buildCsv(failedUsers, true);
                }
                
                if (!successWrappers.isEmpty()) {
                    successCsv = buildCsv(successWrappers, false);
                }
                
                sendEmail(
                    failureCsv,
                successCsv,
                failedUsers.size(),
                successWrappers.size()
                    );
                /* ================================
                NEW: PUBLIC GROUP CREATION
                    ================================ */
                if(!successfulUsers.isEmpty()){
                    if (!Test.isRunningTest()) {
                        System.enqueueJob(new NGMCP_CreateGroupsforPortalUsers(successfulUsers));
                    }
                }
                if (!retryEvents.isEmpty() && retryCount < 2) {
                    System.enqueueJob(
                        new NGMCP_CreatePortalUserJob(
                        retryEvents,
                    'create',
                    retryCount + 1
                        )
                        );
                }
            }
        }else if(actionType == 'Deactivate' || actionType == 'Reactivate'){
            if (!Schema.sObjectType.User.fields.IsActive.isUpdateable()) {
                throw new SecurityException('You do not have permission to activate/deactivate users.');
            }
            
            /* Deactivate users by Username (trimmed, case-insensitive compare on IN is fine) */
            Set<String> uNames = new Set<String>();
            for (UserEventWrapper e : events) {
                String uname = e.username.trim().toLowerCase();
                if (!String.isBlank(uname)){
                    uNames.add(uname);
                } 
            }
            
            if (uNames.isEmpty()) {
                return;
            }
            
            List<User> usersToDeactivate = [
                SELECT Id, IsActive,Username
                FROM User
                WHERE Username IN :uNames WITH USER_MODE
            ];
            
            if (usersToDeactivate.isEmpty()) {
                return;
            }
            
            for (User u : usersToDeactivate) {
                u.IsActive = actionType == 'Reactivate'? true:false;
            }
            
            Database.SaveResult[] ur = Database.update(usersToDeactivate,  false);
            for (Integer i = 0; i < ur.size(); i++) {
                Database.SaveResult sr = ur[i];
                User u = usersToDeactivate[i];
                if (sr.isSuccess() && actionType == 'Reactivate') {
                    try {
                        System.resetPassword(sr.getId(), true);
                    } catch (Exception ex) {
                        System.debug(LoggingLevel.ERROR,
                        'Password reset failed for ' + u.Username + ' | ' + ex.getMessage());
                    }
                } else {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'User deactivate failed. Id=' + usersToDeactivate[i].Id +
                            ' | ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }
            }
            
        }
        else if(actionType == 'Change'){            
            if (!Schema.sObjectType.User.fields.IsActive.isUpdateable()) {
                throw new SecurityException('You do not have permission to Change users.');
            }
            
            Set<String> usernames = new Set<String>();
            for (UserEventWrapper e : events) {
                if (!String.isBlank(e.username)) {
                    usernames.add(e.username.trim().toLowerCase());
                }
            }
            if (usernames.isEmpty()){
                 return;
            }
            
            // Fetch Users in bulk
            Map<String, User> userByUsername = new Map<String, User>();
            for (User u : [SELECT Id, Username, Supplier_Code__c, ProfileId FROM User WHERE Username IN :usernames WITH USER_MODE]) {
                userByUsername.put(u.Username.toLowerCase(), u);
            }
            List<User> usersToUpdate = new List<User>();            
            for (UserEventWrapper e : events) {
                
                if (String.isBlank(e.username)){
                    continue;
                } 
                User u = userByUsername.get(e.username.trim().toLowerCase());
                if (u == null) {
                    continue;
                }
                u.Supplier_Code__c = e.supplierCode;
                u.ProfileId = e.role;                
                usersToUpdate.add(u);
            }
            // Bulk update with partial success
            if (!usersToUpdate.isEmpty()) {
                Database.SaveResult[] results =
                    Database.update(usersToUpdate, false);
                
                for (Integer i = 0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) {
                        for (Database.Error err : results[i].getErrors()) {
                            System.debug(LoggingLevel.ERROR,
                            'User Change failed. UserId=' + usersToUpdate[i].Id +
                                ' | ' + err.getStatusCode() +
                                ' - ' + err.getMessage());
                        }
                    }
                }
            }
        }
    }
    
    /* ================================
    NEW: CSV + EMAIL
        ================================ */
    private static Blob buildCsv(List<UserErrorWrapper> records, Boolean isFailure) {
        
        String csv;
        
        if (isFailure) {
            csv = 'ContactId,Role,Username,Email,SupplierCode,SupplierGroup,ErrorMessage\n';
        } else {
            csv = 'ContactId,Role,Username,Email,SupplierCode,SupplierGroup,UserId\n';
        }
        
        for (UserErrorWrapper w : records) {
            List<String> row = new List<String>{
                String.valueOf(w.event.contactId),
                w.event.role,
                w.event.username,
                w.event.email,
                w.event.supplierCode,
                w.event.supplierGroup
            };
            
            if (isFailure) {
                row.add('"' + w.errorMessage.replace('"','""') + '"');
            } else {
                row.add(String.valueOf(w.userId));
            }
            
            csv += String.join(row, ',') + '\n';
        }
        
        return Blob.valueOf(csv);
    }
    /* ================================
    NEW: CSV + EMAIL
        ================================ */
    private void sendEmail(
        Blob failureCsv, 
        Blob successCsv, 
        Integer failureCount, 
        Integer successCount) {
        
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        
        // Attach failure CSV if provided
        if (failureCsv != null && failureCsv.size() > 0) {
            Messaging.EmailFileAttachment failureAtt = new Messaging.EmailFileAttachment();
            failureAtt.setFileName('Portal_User_Creation_Failures.csv');
            failureAtt.setBody(failureCsv);
            failureAtt.setContentType('text/csv');
            attachments.add(failureAtt);
        }
        
    }
    
    private static List<String> parseEmails(String raw) {
        if (String.isBlank(raw)){
            return new List<String>();
        }
        Set<String> uniq = new Set<String>();
        for (String s : raw.split(';')) {
            String e = s != null ? s.trim() : null;
            if (String.isNotBlank(e)){
                uniq.add(e);
            }
        }
        return new List<String>(uniq);
    }
    
    /* ================================
    EXISTING HELPERS (UNCHANGED)
        ================================ */
        private static Map<String, String> buildCanonicalPicklistMap(
    Schema.SObjectField fieldRef) {
        
        Map<String, String> m = new Map<String, String>();
        for (Schema.PicklistEntry pe :
        fieldRef.getDescribe().getPicklistValues()) {
            m.put(pe.getValue().toLowerCase(), pe.getValue());
        }
        return m;
    }
    
    private static Boolean isRestrictedPicklist(
    Schema.SObjectField fieldRef) {
        return fieldRef.getDescribe().isRestrictedPicklist();
    }
    
    private static String toCanonicalPicklist(
    String input,
    Map<String, String> canonicalMap,
    Boolean allowFallbackRaw) {
        
        if (String.isBlank(input)){
            return null;
        } 
        List<String> out = new List<String>();
        
        for (String s : input.split(';')) {
            String k = s.trim().toLowerCase();
            if (canonicalMap.containsKey(k)) {
                out.add(canonicalMap.get(k));
            }
        }
        return !out.isEmpty()
            ? String.join(out, ';')
            : (allowFallbackRaw ? input : null);
    }
    
    private static String generateNickname(String username) {
        String s =
            String.isBlank(username)
            ? 'user' + Crypto.getRandomInteger()
            : username.replaceAll('[^A-Za-z0-9]', '');
        return s.length() > 40 ? s.substring(0, 40) : s;
    }
    
    private static String safeAlias(String username) {
        String s =
            String.isBlank(username)
            ? 'user'
            : username.replaceAll('[^A-Za-z]', '');
        return s.length() > 8 ? s.substring(0, 8) : s;
    }
}
// ===== END =====