public with sharing class NGMCP_UserManagmentController {
    /* =========================================================
    CONSTANTS & LIGHTWEIGHT CACHES
        ========================================================= */
    private static final String PROFILE_MANAGER = 'NGMCP_Gas Supplier Manager';
    private static final String PROFILE_AGENT   = 'NGMCP_Gas Supplier Agent';
    
    // Cache for logged-in user (per transaction)
    private static User loggedInUser;
    
    // Cache for Profile Name -> Id
    private static Map<String, Id> PROFILE_NAME_TO_ID;
    
    /* =========================================================
    USER CONTEXT (CACHED)
        ========================================================= */
    private static User getLoggedInUser() {
        if (loggedInUser == null) {
            loggedInUser = [
                SELECT Id, Email, Profile.Name, Supplier_Group__c, Supplier_Code__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ];
        }
        return loggedInUser;
    }
    
    private static Boolean isCRMProfile() {
        String pName = getLoggedInUser().Profile.Name;
        return pName != null && pName.toLowerCase().contains('crm');
    }
    
    /* =========================================================
    PROFILE HELPERS
        ========================================================= */
    private static void ensureProfileCacheLoaded(Set<String> names) {
        if (PROFILE_NAME_TO_ID == null) PROFILE_NAME_TO_ID = new Map<String, Id>();
        Set<String> missing = new Set<String>();
        for (String n : names) {
            if (String.isBlank(n)) {
                continue;
            }
            if (!PROFILE_NAME_TO_ID.containsKey(n)){
                missing.add(n);
            } 
        }
        if (!missing.isEmpty()) {
            for (Profile p : [SELECT Id, Name FROM Profile WHERE Name IN :missing]) {
                PROFILE_NAME_TO_ID.put(p.Name, p.Id);
            }
        }
    }
    
    private static Id getProfileIdByRoleLabel(String roleLabel) {
        // Role label -> Profile name mapping
        String profileName = (roleLabel == 'Manager') ? PROFILE_MANAGER : PROFILE_AGENT;
        ensureProfileCacheLoaded(new Set<String>{ profileName });
        return PROFILE_NAME_TO_ID.get(profileName);
    }
    
    /* =========================================================
    USER CONTEXT API (LWC)
        ========================================================= */
        @AuraEnabled(cacheable=true)
    public static Map<String, Object> getLoggedInUserProfile() {
        User u = getLoggedInUser();
        return new Map<String, Object>{
            'isCrmUser'      => isCRMProfile(),
            'supplierGroup'  => u.Supplier_Group__c,
            'supplierCode'   => u.Supplier_Code__c
        };
    }
    
    /* =========================================================
    SUPPLIER HELPERS (READ APIs)
        ========================================================= */
        @AuraEnabled(cacheable=true)
    public static List<String> getAllSupplierGroups() {
        List<String> result = new List<String>();
        Schema.DescribeFieldResult dfr = User.Supplier_Group__c.getDescribe();
        for (Schema.PicklistEntry entry : dfr.getPicklistValues()) {
            result.add(entry.getValue()); // Use getLabel() if labels are desired
        }
        return result;
    }
    
    /* @AuraEnabled(cacheable=true)
    public static List<String> getSupplierCodesByGroup(String supplierGroup) {
        return String.isBlank(supplierGroup)
            ? new List<String>()
            : new List<String>(fetchSupplierCodesByGroup(supplierGroup));
    }
    
    // Backward compatibility method (delegates to canonical method)
    @AuraEnabled(cacheable=true)
    public static List<String> getSupplierCodesByGroups(String supplierGroup) {
        return getSupplierCodesByGroup(supplierGroup);
    }*/
    
    @AuraEnabled
    public static Map<String, Object> getUserSupplierContext(String username) {
        // Return same shape as before; now robust to "not found"
        List<User> users = [
            SELECT Supplier_Group__c, Supplier_Code__c
            FROM User
            WHERE Username = :username WITH USER_MODE
            LIMIT 1
        ];
        if (users.isEmpty()) {
            // Previously this threw a QueryException; AuraHandledException is cleaner for LWC
            throw new AuraHandledException('User not found');
        }
        User u = users[0];
        List<String> userCodes = (u.Supplier_Code__c == null) ? new List<String>() : u.Supplier_Code__c.split(';');
        return new Map<String, Object>{
            'supplierGroup'       => u.Supplier_Group__c,
            'userSupplierCodes'   => userCodes
        };
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getSupplierCodesForLoggedInUser() {
        User u = getLoggedInUser();
        if (String.isBlank(u.Supplier_Code__c)) {
            return new List<String>();
        }
        Set<String> codes = new Set<String>();
        codes.addAll(u.Supplier_Code__c.split(';'));
        return new List<String>(codes);
    }
    
    /*  // Canonical supplier code fetcher (de-duplicated as Set)
    private static Set<String> fetchSupplierCodesByGroup(String supplierGroup) {
        Set<String> codes = new Set<String>();
        if (String.isBlank(supplierGroup)) return codes;
        
        for (User u : [
            SELECT Supplier_Code__c
            FROM User
            WHERE Supplier_Group__c = :supplierGroup
            AND Supplier_Code__c != null
        ]) {
            codes.addAll(u.Supplier_Code__c.split(';'));
        }
        return codes;
    }*/
    
    /* =========================================================
    SINGLE REQUEST ROUTER
        ========================================================= */
        @AuraEnabled
    public static String processSingleRequest(String actionType, String formDetails) {
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(formDetails);
        switch on actionType {
            when 'Create'     { return createUser(data); }
            when 'Deactivate' { return deactivateUser(data); }
            when 'Change'     { return changeUser(data); }
            when 'Reactivate' { return reactivateUser(data); }
            when else {
                throw new AuraHandledException('Invalid action type');
            }
        }
    }
    
    /* =========================================================
    CREATE USER (SINGLE)
        ========================================================= */
    private static String createUser(Map<String, Object> data) {
        
        // Enforce Experience Cloud context
        if (Site.getSiteId() == null) {
            throw new AuraHandledException('Must be executed from Experience Cloud');
        }
        
        User creator = getLoggedInUser();
        String supplierGroup =
            isCRMProfile()
            ? (String) data.get('supplierGroup')
            : creator.Supplier_Group__c;
        Id accountId = NGMCP_Account_Owner__mdt.getInstance('DefaultOwner').NGMCP_Account_OwnerId__c;
        NGMCP_User_Management__e evt = new NGMCP_User_Management__e(
        NGMCP_First_Name__c      = (String) data.get('firstName'),
        NGMCP_Last_Name__c       = (String) data.get('lastName'),
        NGMCP_Email__c           = (String) data.get('email'),
        NGMCP_Role__c            = (String) data.get('role'),
        NGMCP_User_Name__c       = (String) data.get('email') + '.' + System.currentTimeMillis(),
        NGMCP_Suppler_Code__c    = (String) data.get('supplierCode'),
        NGMCP_Supplier_Group__c  = supplierGroup,
        NGMCP_Action__c = 'Create',
        NGMCP_Requester_Email__c = UserInfo.getUserEmail(),
        NGMCP_Account_owneId__c = accountId
            );
        Database.SaveResult sr = EventBus.publish(evt);
        if (!sr.isSuccess()) {
            for (Database.Error err : sr.getErrors()) {
            }
        }
        return 'SUCCESS';
    }
    
    
    /* =========================================================
    CHANGE USER (SINGLE)
        ========================================================= */
    private static String changeUser(Map<String, Object> data) {
        NGMCP_User_Management__e evt = new NGMCP_User_Management__e(
            NGMCP_User_Name__c = String.isBlank((String)data.get('userName')) ? null : ((String)data.get('userName')).trim(),
        NGMCP_Role__c = getProfileIdByRoleLabel((String) data.get('role')),
        NGMCP_Suppler_Code__c = (String) data.get('supplierCode'),
        NGMCP_Action__c = 'Change',
        NGMCP_Requester_Email__c = UserInfo.getUserEmail()
            );
        Database.SaveResult sr = EventBus.publish(evt);
        if (!sr.isSuccess()) {
            for (Database.Error err : sr.getErrors()) {
            }
        }
        return 'SUCCESS';
    }
    
    /* =========================================================
    DEACTIVATE USER (SINGLE)
        ========================================================= */
        
    private static String deactivateUser(Map<String, Object> data) {
        NGMCP_User_Management__e evt = new NGMCP_User_Management__e(
            NGMCP_User_Name__c = String.isBlank((String)data.get('userName')) ? null : ((String)data.get('userName')).trim(),
        NGMCP_Action__c = 'Deactivate',
        NGMCP_Requester_Email__c = UserInfo.getUserEmail()
            );
        Database.SaveResult sr = EventBus.publish(evt);
        if (!sr.isSuccess()) {
            for (Database.Error err : sr.getErrors()) {
            }
        }
        return 'SUCCESS';
    }
    
    /* =========================================================
    REACTIVATE USER (SINGLE)
        ========================================================= */
    private static String reactivateUser(Map<String, Object> data) {
        NGMCP_User_Management__e evt = new NGMCP_User_Management__e(
            NGMCP_User_Name__c = String.isBlank((String)data.get('userName')) ? null : ((String)data.get('userName')).trim(),
        NGMCP_Action__c = 'Reactivate',
        NGMCP_Requester_Email__c = UserInfo.getUserEmail()
            );
        Database.SaveResult sr = EventBus.publish(evt);
        if (!sr.isSuccess()) {
            for (Database.Error err : sr.getErrors()) {
            }
        }
        return 'SUCCESS';
    }
    
    /* =========================================================
    BULK CSV ENTRY POINT
        ========================================================= */
        @AuraEnabled
    public static void processBulkCSV(String actionType, String recordsJson) {
        List<Object> rows = (List<Object>) JSON.deserializeUntyped(recordsJson);
        
        if (rows.isEmpty()) {
            throw new AuraHandledException('CSV file is empty');
        }
        
        if (actionType == 'Create') {
            bulkCreateUsers(rows);
        } else if (actionType == 'Deactivate') {
            bulkDeactivateUsers(rows);
        } else if (actionType == 'Reactivate') {
            bulkReactivateUsers(rows);
        } else if (actionType == 'Change') {
            bulkChangeUsers(rows);
        } else {
            throw new AuraHandledException('Invalid action type');
        }
    }
    
    /* =========================================================
    BULK CREATE USERS
        ========================================================= */
    private static void bulkCreateUsers(List<Object> rows) {
        
        
        if (rows == null || rows.isEmpty()){
            return;
        }
        
        List<NGMCP_User_Management__e> events =
            new List<NGMCP_User_Management__e>();
        
        for (Object o : rows) {
            
            Map<String, Object> r = (Map<String, Object>) o;
            
            String email = (String) r.get('Email');
            if (String.isBlank(email)) {
                continue;
            }
            Id accountId = NGMCP_Account_Owner__mdt.getInstance('DefaultOwner').NGMCP_Account_OwnerId__c;
            events.add(new NGMCP_User_Management__e(
                NGMCP_First_Name__c      = (String) r.get('FirstName'),
            NGMCP_Last_Name__c       = (String) r.get('LastName'),
            NGMCP_Email__c           = email,
            NGMCP_Role__c            = (String) r.get('Role'),
            NGMCP_User_Name__c       = email + '.' + String.valueOf(System.currentTimeMillis()),
            NGMCP_Suppler_Code__c    = (String) r.get('SupplierCode'),
            NGMCP_Supplier_Group__c  = (String) r.get('SupplierGroup'),
            NGMCP_Action__c          = 'Create',
            NGMCP_Requester_Email__c = UserInfo.getUserEmail(),
            NGMCP_Account_owneId__c = accountId
                ));
        }
        if (events.isEmpty()){
            return;
        }
        
        // Publish platform events (partial success)
        Database.SaveResult[] results = EventBus.publish(events);
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                for (Database.Error err : results[i].getErrors()) {
                }
            }
        }
    }
    
    
    /* =========================================================
    BULK DEACTIVATE
        ========================================================= */
    private static void bulkDeactivateUsers(List<Object> rows) {
        
        if (rows == null || rows.isEmpty()){
             return;
        }
        
        List<NGMCP_User_Management__e> events =
            new List<NGMCP_User_Management__e>();
        
        for (Object o : rows) {
            
            Map<String, Object> r = (Map<String, Object>) o;
            
            String username = (String) r.get('UserName');
            if (String.isBlank(username)) {
                continue;
            }
            
            events.add(new NGMCP_User_Management__e(
                NGMCP_User_Name__c = username.trim(),
            NGMCP_Action__c    = 'Deactivate',
            NGMCP_Requester_Email__c  = UserInfo.getUserEmail()
                ));
        }
        
        if (events.isEmpty()) return;
        
        // Publish platform events (partial success)
        Database.SaveResult[] results = EventBus.publish(events);
        
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                for (Database.Error err : results[i].getErrors()) {

                }
            }
        }
    }
    
    
    /* =========================================================
    BULK REACTIVATE
        ========================================================= */
    private static void bulkReactivateUsers(List<Object> rows) {
        
        if (rows == null || rows.isEmpty()) return;
        
        List<NGMCP_User_Management__e> events =
            new List<NGMCP_User_Management__e>();
        
        for (Object o : rows) {
            Map<String, Object> r = (Map<String, Object>) o;
            
            String username = (String) r.get('UserName');
            if (String.isBlank(username)) {
                continue;
            }
            
            events.add(new NGMCP_User_Management__e(
                NGMCP_User_Name__c        = username.trim(),
            NGMCP_Action__c           = 'Reactivate',
            NGMCP_Requester_Email__c  = UserInfo.getUserEmail()
                ));
        }
        
        if (events.isEmpty()){
             return;
        }
        
        Database.SaveResult[] results = EventBus.publish(events);
        
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                for (Database.Error err : results[i].getErrors()) {

                }
            }
        }
    }
    /* =========================================================
    BULK CHANGE
        ========================================================= */
    private static void bulkChangeUsers(List<Object> rows) {
        
        if (rows == null || rows.isEmpty()) return;
        
        List<NGMCP_User_Management__e> events =
            new List<NGMCP_User_Management__e>();
        
        for (Object o : rows) {
            Map<String, Object> r = (Map<String, Object>) o;
            
            String username     = (String) r.get('UserName');
            String role         = getProfileIdByRoleLabel((String) r.get('Role'));
            String supplierCode = (String) r.get('SupplierCode');
            
            if (String.isBlank(username)) {

                continue;
            }
            
            events.add(new NGMCP_User_Management__e(
                NGMCP_User_Name__c        = username.trim(),
            NGMCP_Role__c             = role,
            NGMCP_Suppler_Code__c     = supplierCode,
            NGMCP_Action__c           = 'Change',
            NGMCP_Requester_Email__c  = UserInfo.getUserEmail()
                ));
        }
        
        if (events.isEmpty()) return;
        
        Database.SaveResult[] results = EventBus.publish(events);
        
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                for (Database.Error err : results[i].getErrors()) {
                }
            }
        }
    }
    
    /* =========================================================
    HELPERS
        ========================================================= *
    private static Map<String, Id> getAccountsBySupplierCodes(Set<String> names) {
        Map<String, Id> result = new Map<String, Id>();
        if (names == null || names.isEmpty()) return result;
        
        // Existing accounts
        for (Account a : [SELECT Id, Name FROM Account WHERE Name IN :names]) {
            result.put(a.Name, a.Id);
        }
        
        // Create missing accounts
        Set<String> missing = new Set<String>(names);
        missing.removeAll(result.keySet());
        
        if (!missing.isEmpty()) {
            List<Account> toInsert = new List<Account>();
            for (String n : missing) {
                toInsert.add(new Account(Name = n));
            }
            insert toInsert;
            for (Account a : toInsert) result.put(a.Name, a.Id);
        }
        return result;
    }
    
    private static Account getOrCreateAccount(String name) {
        if (String.isBlank(name)) {
            // Create a generic account if name is somehow blank (preserving behavior is subjective; you had non-null flow)
            // Keeping the original behavior: if name is blank, still attempt lookup then create.
        }
        List<Account> acc = [SELECT Id FROM Account WHERE Name = :name LIMIT 1];
        if (!acc.isEmpty()) return acc[0];
        
        Account ac = new Account(Name = name);
        insert ac;
        return ac;
    }*/
    
    @AuraEnabled
    public static Map<String, Object> getSupplierDataByUsername(String username) {
        if (String.isBlank(username)) {
            throw new AuraHandledException('Username is required');
        }
        List<User> users = [
            SELECT Supplier_Group__c, Supplier_Code__c
            FROM User
            WHERE Username = :username WITH USER_MODE
            LIMIT 1
        ];
        if (users.isEmpty()) {
            throw new AuraHandledException('User not found');
        }
        User u = users[0];
        List<String> supplierCodes = (u.Supplier_Code__c == null) ? new List<String>() : u.Supplier_Code__c.split(';');
        return new Map<String, Object>{
            'supplierGroup' => u.Supplier_Group__c,
            'supplierCodes' => supplierCodes
        };
    }
    
    private static String normalizeSupplierCode(Object v) {
        return v == null ? null : String.valueOf(v).trim().toUpperCase();
    }
    
    @AuraEnabled
    public static List<NGMCP_UserDependentPicklistController.PicklistOption> groupValuesforCRM(String suppliergroup){
        try {

            List<NGMCP_UserDependentPicklistController.PicklistOption> options =
                NGMCP_UserDependentPicklistController.getUserSupplierCodesForGroup(suppliergroup, true, false);

            return options;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}