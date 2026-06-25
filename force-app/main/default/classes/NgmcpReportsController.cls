public with sharing class NgmcpReportsController {
    
    /*======== PUBLIC METHOD CALLED FROM LWC =======*/
    @AuraEnabled(cacheable=true)
    public static List<ReportRow> getReportData(String reportKey) {
        if (String.isBlank(reportKey)) {
            return new List<ReportRow>();
        }
        
        List<String> supplierCodes = getSupplierCodes();   // multi-select parsed
        Id userId = UserInfo.getUserId();                  // get user id
        
        if (reportKey == 'USER_DETAILS') {
            return fetchUserDetailsReport(userId);
        }
        
        if (isWorkOrderReport(reportKey)) {
            return fetchWorkOrderReports(reportKey, supplierCodes, userId);
        } else {
            return fetchRequestReports(reportKey, supplierCodes);
        }
    }
    @testVisible
    /*=== WORK ORDER REPORTS ===*/
    private static List<ReportRow> fetchWorkOrderReports(String reportKey, List<String> supplierCodes, Id userId) {
        if (supplierCodes == null) supplierCodes = new List<String>();
        String baseQuery =
            'SELECT Id, WorkOrderNumber, FFA_JobDescription__c, FFA_JobCode__c, FFA_MeterPointReferenceNumber__c, Completion_Date__c,'+
            ' Status, FFA_RequestedAppointmentDate__c, Job_Category__c, FFA_ShipperID__c, NGMCP_Site_contact_details__c' +
            ' FROM WorkOrder ';
        
        List<String> conditions = new List<String>();
        User loggedInUser = getLoggedInUser();
        if (loggedInUser.Profile.Name == 'NGMCP_Gas Supplier Manager') {
            if (!supplierCodes.isEmpty()) {
                conditions.add('FFA_ShipperID__c IN :supplierCodes');  // Text field matched against List<String>
            } else {
                return new List<ReportRow>(); // No codes = no visibility
            }
        } else if (loggedInUser.Profile.Name == 'NGMCP_Gas Supplier Agent') {
            if (!supplierCodes.isEmpty()) {
                conditions.add('FFA_ShipperID__c IN :supplierCodes');
            }
            
            else {
                return new List<ReportRow>();
            }
            
        }
        
        // 1. Completed PME and Maintenance Jobs
        if (reportKey == 'COMPLETED_PME') {
            conditions.add('Status IN (\'Completed\', \'Terminated\', \'Further Work Required\')');
            conditions.add('Job_Category__c LIKE \'%NGM Initiated%\'');
        }
        // 2. Inprogress PME and Maintenance Jobs
        else if (reportKey == 'INPROGRESS_PME') {
            conditions.add('Status NOT IN (\'Completed\', \'Terminated\', \'Further Work Required\')');
            conditions.add('Job_Category__c LIKE \'%NGM Initiated%\'');
        }
        // 4. Work Orders Requiring Additional Information
        else if (reportKey == 'ADDINFO_WO') {
            conditions.add('NGMCP_Site_contact_details__c = \'Yes\'');
            
        }
        // 5. Completed Work Order - customer initiated & created by user
        else if (reportKey == 'COMP_WO') {
            Set<String> srNumbers = new Set<String>();
            for (NGMCP_Request__c r : [
                SELECT NGMCP_SR_Ticket__c
                FROM NGMCP_Request__c
                WHERE CreatedById = :UserId AND NGMCP_SR_Ticket__c != null
            ]) {
                srNumbers.add(r.NGMCP_SR_Ticket__c);
            }
            if (srNumbers.isEmpty()) {
                return new List<ReportRow>();
            }
            
            conditions.add('Status IN (\'Completed\', \'Terminated\', \'Further Work Required\')');
            conditions.add('Job_Category__c LIKE \'%Customer Initiated%\'');
            Conditions.add('NGMCP_Service_Request_Number__c IN (\''+String.join(new List<string>(srNumbers),'\',\'')+'\')');
        }
        // 6. Upcoming Site Visits
        else if (reportKey == 'INPROGRESS_WO') {
            Set<String> srNumbers = new Set<String>();
            for (NGMCP_Request__c r : [
                SELECT NGMCP_SR_Ticket__c
                FROM NGMCP_Request__c
                WHERE CreatedById = :userId AND NGMCP_SR_Ticket__c != null
            ]) {
                srNumbers.add(r.NGMCP_SR_Ticket__c);
            }
            if (srNumbers.isEmpty()) {
                return new List<ReportRow>();
            }
            
            conditions.add('Status NOT IN (\'Completed\', \'Terminated\', \'Further Work Required\',\'Cancelled\',\'CANCELLED\')');
            conditions.add('Job_Category__c LIKE \'%Customer Initiated%\'');
            Conditions.add('NGMCP_Service_Request_Number__c IN (\''+String.join(new List<string>(srNumbers),'\',\'')+'\')');
        }
        
        if (!conditions.isEmpty()) {
            baseQuery += 'WHERE ' + String.join(conditions, ' AND ');
        }
        baseQuery += ' ORDER BY CreatedDate DESC';
        
        List<WorkOrder> records = Database.query(baseQuery);
        return mapWorkOrders(records);
    }
    
    /*==== HELPERS ===*/
    private static Boolean isWorkOrderReport(String reportKey) {
        return reportKey == 'COMPLETED_PME' ||
            reportKey == 'INPROGRESS_PME' ||
            reportKey == 'ADDINFO_WO' ||
            reportKey == 'COMP_WO' ||
            reportKey == 'INPROGRESS_WO';
    }
    @testvisible
    private static List<String> getSupplierCodes() {
        User u = [
            SELECT Supplier_Code__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        List<String> codes = new List<String>();
        if (String.isNotBlank(u.Supplier_Code__c)) {
            for (String s : u.Supplier_Code__c.split(';')) {
                s = (s == null) ? null : s.trim();
                if (String.isNotBlank(s)) codes.add(s);
            }
        }
        return codes;
    }
    
    private static User getLoggedInUser() {
        return [
            SELECT Id, Profile.Name, Supplier_Code__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
    }
    @testVisible
    
    /* =====================================================
    MAPPERS
        ===================================================== */
    private static List<ReportRow> mapWorkOrders(List<WorkOrder> records) {
        List<ReportRow> rows = new List<ReportRow>();
        for (WorkOrder wo : records) {
            ReportRow r = new ReportRow();
            r.recordId = wo.Id;
            r.name = wo.WorkOrderNumber;
            r.status = wo.Status;
            r.mprn = wo.FFA_MeterPointReferenceNumber__c;
            r.jobcategory = wo.Job_Category__c;
            r.suppliercode = wo.FFA_ShipperID__c;
            r.JobDescription = wo.FFA_JobDescription__c;
            r.CompletionDate = wo.Completion_Date__c;
            r.JobCode = wo.FFA_JobCode__c;
            r.AppointmentDate = (wo.FFA_RequestedAppointmentDate__c != null) ? wo.FFA_RequestedAppointmentDate__c.format('dd/MM/yyyy') : null;
            rows.add(r);
        }
        return rows;
    }
    
    /*=== NGMCP_REQUEST REPORTS ===*/
    private static List<ReportRow> fetchRequestReports(String reportKey, List<String> supplierCodes) {
        
        String baseQuery =
            'SELECT Id, RecordType.Name,Name, NGMCP_SR_Ticket__c, NGMCP_Supplier_Id__c, NGMCP_MPRN__c, NGMCP_Status__c, CreatedById, CreatedDate,' +
            ' NGMCP_Building_Name__c, NGMCP_Building_Number__c, NGMCP_Dependent_Locality__c, NGMCP_Street__c,NGMCP_Address__c, NGMCP_Postal_Town__c, NGMCP_Postal_Code__c,' +
            ' NGMCP_Job_Type__c, NGMCP_Affected_Person__c, NGMCP_Affectedphone__c,NGMCP_Ngme_ConseMail__c,' +
            ' NGMCP_Enquiry_Reason_Code__c, NGMCP_Enquiry_Category__c,NGMCP_Enquiry_Reason_Description__c,NGMCP_Enquiry_start_date__c,NGMCP_Enquiry_target_end_date__c, NGMCP_Enquiry_Category_Description__c, NGMCP_Enquiry_Type__c,' +
            ' RecordType.DeveloperName, NGMCP_Appointment_Type__c, NGMCP_Appointment_Date__c,' +
            ' NGMCP_Quotation_Status__c,NGMCP_Type_Code__c,NGMCP_Job_SubType__c,NGMCP_Creation_Date__c,NGMCP_From_Date__c,NGMCP_To_Date__c,NGMCP_Reason_Code__c,'+
            ' NGMCP_MAM_Id__c,NGMCP_Service_Level__c,NGMCP_Target_Start__c,NGMCP_Annual_Consumption__c, (SELECT Id, WorkOrderNumber,FFA_JobCode__c, FFA_JobDescription__c, FFA_MeterPointReferenceNumber__c, Completion_Date__c FROM Work_Orders__r )' +
            ' FROM NGMCP_Request__c ';
        
        List<String> conditions = new List<String>();
        
        /* =========================================================
        PROFILE BASED ACCESS CONTROL
            ========================================================= */
            User loggedInUser = getLoggedInUser();
        if (loggedInUser.Profile.Name == 'NGMCP_Gas Supplier Manager') {
            if (!supplierCodes.isEmpty()) {
                // NGMCP_Supplier_Id__c is a Text field → use IN with List<String>
                conditions.add('NGMCP_Supplier_Id__c IN :supplierCodes');
            } else {
                return new List<ReportRow>();
            }
        } else if (loggedInUser.Profile.Name == 'NGMCP_Gas Supplier Agent') {
            //conditions.add('CreatedById = :UserInfo.getUserId()');
            
            Id currentUserId = UserInfo.getUserId();
            conditions.add('CreatedById = :currentUserId');
            
        }
        
        // 3. Enquiries Requiring Additional Information
        if (reportKey == 'ADDINFO_ENQ') {
            conditions.add('(NGMCP_Status__c LIKE \'%Additional%\' OR NGMCP_Status__c LIKE \'%Reminder%\')');
        }
        // 8. All Technical Enquiries
        else if (reportKey == 'TECHNICAL_QUERIES') {
            conditions.add('RecordType.DeveloperName IN (\'NGMCP_Enquiry\')');
            conditions.add('NGMCP_Enquiry_Type__c LIKE \'%Technical Query%\'');
        }
        // 9. All Data Enquiries
        else if (reportKey == 'DATA_QUERIES') {
            conditions.add('RecordType.DeveloperName IN (\'NGMCP_Enquiry\')');
            conditions.add('NGMCP_Enquiry_Type__c LIKE \'%Data Query%\'');
        }
        // 10. All Open Technical Enquiries
        else if (reportKey == 'OPEN_TECHNICAL_QUERIES') {
            conditions.add('RecordType.DeveloperName IN (\'NGMCP_Enquiry\')');
            conditions.add('NGMCP_Enquiry_Type__c LIKE \'%Technical Query%\'');
            conditions.add('NGMCP_Status__c NOT IN (\'RESOLVED\', \'CLOSED\',\'Cancelled\',\'CANCELLED\',\'Completed\')');
        }
        // 11. All Open Data Enquiries
        else if (reportKey == 'OPEN_DATA_QUERIES') {
            conditions.add('RecordType.DeveloperName IN (\'NGMCP_Enquiry\')');
            conditions.add('NGMCP_Enquiry_Type__c LIKE \'%Data Query%\'');
            conditions.add('NGMCP_Status__c NOT IN (\'RESOLVED\', \'CLOSED\',\'Completed\')');
        }
        // 12. All Customer Work Requests - customer/urgent
        else if (reportKey == 'WORKORDERS') {
            conditions.add('RecordType.DeveloperName IN (\'NGMCP_Customer_Work_Request\', \'NGMCP_Urgent_Work_Request\')');
        }
        // 13. All Customer Work Requests and Enquiries
        else if (reportKey == 'WR_AND_ENQ') {
            conditions.add('RecordType.DeveloperName IN (\'NGMCP_Customer_Work_Request\', \'NGMCP_Urgent_Work_Request\', \'NGMCP_Enquiry\')');
        }
        // 14. All Appointments and Deappointment Requests
        else if (reportKey == 'APP_AND_DEAPP') {
            conditions.add('RecordType.DeveloperName IN (\'NGMCP_Appointment_Deappointment\')');
        }
        //15.All Quotation Status Report
        else if (reportKey == 'QUOTE_STATUS') {
            conditions.add('RecordType.DeveloperName IN (\'NGMCP_Customer_Work_Request\')');
            conditions.add('NGMCP_Quotation_Status__c != NULL');
            conditions.add('NGMCP_Non_Standard__c = TRUE');
        }
        //16.All AMR Work Requests
        else if (reportKey == 'ALL_AMR') {
            conditions.add('RecordType.DeveloperName IN (\'AMR\')');
        }
        //17. All OPEN AMR Work Requests
        else if (reportKey == 'ALL_OPEN_AMR') {
            conditions.add('RecordType.DeveloperName IN (\'AMR\')');
            conditions.add('NGMCP_Status__c NOT IN (\'RESOLVED\', \'CLOSED\',\'Cancelled\',\'CANCELLED\',\'Completed\',\'ABORT\',\'Aborted\',\'COMLT\')');
        }
        if (!conditions.isEmpty()) {
            baseQuery += ' WHERE ' + String.join(conditions, ' AND ');
        }
        baseQuery += ' ORDER BY CreatedDate DESC';
        
        List<NGMCP_Request__c> records = Database.query(baseQuery);
        return mapRequests(records, reportKey);
    }
    
    /* =====================================================
    MAPPERS
        ===================================================== */
        @testVisible
    
    private static List<ReportRow> mapRequests(List<NGMCP_Request__c> records, String reportKey) {
        List<ReportRow> rows = new List<ReportRow>();
        for (NGMCP_Request__c r : records) {
            ReportRow row = new ReportRow();
            row.recordId = r.Id;
            row.name = r.Name;
            row.status = r.NGMCP_Status__c;
            row.mprn = r.NGMCP_MPRN__c;
            row.jobcategory = r.NGMCP_Job_Type__c;
            row.suppliercode = r.NGMCP_Supplier_Id__c;
            if (r.Work_Orders__r != null && !r.Work_Orders__r.isEmpty()) {
                row.JobCode = r.Work_Orders__r[0].FFA_JobCode__c;
                row.JobDescription = r.Work_Orders__r[0].FFA_JobDescription__c;
                row.CompletionDate = r.Work_Orders__r[0].Completion_Date__c;
            }
            //row.JobDescription = null;
            row.AppointmentDate = null;
            row.recordTypeName = r.RecordType.Name;
            
            if (reportKey == 'WORKORDERS' || reportKey == 'QUOTE_STATUS') {
                // row.CreatedOn = r.CreatedDate ;
                row.CreatedOn = (r.CreatedDate != null)
                    ? r.CreatedDate.format('dd/MM/yyyy HH:mm')
                    : null;
                row.BuildingName = r.NGMCP_Building_Name__c;
                row.BuildingNumber = r.NGMCP_Building_Number__c;
                row.Street = r.NGMCP_Street__c;
                row.DependentLocality = r.NGMCP_Dependent_Locality__c;
                row.Town = r.NGMCP_Postal_Town__c;
                row.PostCode = r.NGMCP_Postal_Code__c;
                row.CustomerName = r.NGMCP_Affected_Person__c;
                row.CustomerNumber = r.NGMCP_Affectedphone__c;
                row.QuotationStatus = r.NGMCP_Quotation_Status__c;
                row.SRnumber = r.NGMCP_SR_Ticket__c;
                row.subcategory=r.NGMCP_Job_SubType__c;
            }
            
            if (reportKey == 'DATA_QUERIES' ||
                reportKey == 'ADDINFO_ENQ' ||
                reportKey == 'TECHNICAL_QUERIES' ||
                reportKey == 'WR_AND_ENQ' ||
                reportKey == 'OPEN_DATA_QUERIES' ||
                reportKey == 'OPEN_TECHNICAL_QUERIES') {
                row.jobcategory = r.NGMCP_Job_Type__c;
                row.EnquiryType = r.NGMCP_Enquiry_Type__c;
                row.EnquiryCategorydescprition = r.NGMCP_Enquiry_Category_Description__c;
                row.ReasonDescription = r.NGMCP_Enquiry_Reason_Description__c;
                row.Startdate  = r.NGMCP_Enquiry_start_date__c;
                row.Enddate = r.NGMCP_Enquiry_target_end_date__c;
                //row.ReasonCode = r.NGMCP_Enquiry_Reason_Code__c;
                row.BuildingName = r.NGMCP_Building_Name__c;
                row.BuildingNumber = r.NGMCP_Building_Number__c;
                row.Street = r.NGMCP_Street__c;
                row.DependentLocality = r.NGMCP_Dependent_Locality__c;
                row.Town = r.NGMCP_Postal_Town__c;
                row.PostCode = r.NGMCP_Postal_Code__c;
                // row.CustomerName = r.NGMCP_Affected_Person__c;
                // row.CustomerNumber = r.NGMCP_Affectedphone__c;
                row.SRnumber = r.NGMCP_SR_Ticket__c;
            }
            if(reportKey == 'ALL_AMR'||reportKey=='ALL_OPEN_AMR'){
                row.MAMID = r.NGMCP_MAM_Id__c;
                row.SRnumber = r.NGMCP_SR_Ticket__c;
                row.AppointmentStartDate = toDdDashMmDashYyyy(r.NGMCP_Target_Start__c);
                row.ServiceLevel = r.NGMCP_Service_Level__c;
                row.AnnualConsumption = r.NGMCP_Annual_Consumption__c;
                row.Address = r.NGMCP_Address__c;
                row.Town = r.NGMCP_Postal_Town__c;
                row.PostCode = r.NGMCP_Postal_Code__c;
                row.CustomerName = r.NGMCP_Affected_Person__c;
                row.CustomerNumber = r.NGMCP_Affectedphone__c;
                row.CustomerEmail = r.NGMCP_Ngme_ConseMail__c;
            }
            
            if (reportKey == 'APP_AND_DEAPP') {
                //  row.CreatedDate = r.NGMCP_Creation_Date__c;
                
                row.CreatedDate = toDdDashMmDashYyyy(r.NGMCP_Creation_Date__c);
                row.fromDate    = toDdDashMmDashYyyy(r.NGMCP_From_Date__c);
                row.toDate      = toDdDashMmDashYyyy(r.NGMCP_To_Date__c);
                
                
                row.ReasonCode=r.NGMCP_Reason_Code__c;
                row.TypeCode = r.NGMCP_Type_Code__c;
            }
            
            rows.add(row);
        }
        return rows;
    }
    @testVisible
    
    // Converts text date in 'YYYYMMDD' or 'YYYY-MM-DD' to 'DD-MM-YYYY'.
    // Returns null for blank/invalid inputs (change to `return s;` if you prefer fallback).
    private static String toDdDashMmDashYyyy(String s) {
        if (String.isBlank(s)) return null;
        s = s.trim();
        
        if (s.length() == 8 && Pattern.matches('\\d{8}', s)) {
                                    String yyyy = s.substring(0, 4);
                                    String MM   = s.substring(4, 6);
                                    String dd   = s.substring(6, 8);
                                    if (!isValidDate(yyyy, MM, dd)) return null;
                                    return dd + '-' + MM + '-' + yyyy;
                                }
                                
                                if (s.length() == 10 && s.substring(4, 5) == '-' && s.substring(7, 8) == '-') {
                                    String yyyy = s.substring(0, 4);
                                    String MM   = s.substring(5, 7);
                                    String dd   = s.substring(8, 10);
                                    
                                    // Basic numeric checks
                                    if (!Pattern.matches('\\d{4}', yyyy) ||
                                        !Pattern.matches('\\d{2}', MM)   ||
                                    !Pattern.matches('\\d{2}', dd)) {
                                                    return null; // or return s;
                                                }
                                                
                                                if (!isValidDate(yyyy, MM, dd)) return null;
                                                return dd + '/' + MM + '/' + yyyy;
                                            }
                                            
                                            // Unsupported format
                                            return null; // or: return s;
                                        }
                                        @testVisible
                                        
                                        private static Boolean isValidDate(String yyyy, String MM, String dd) {
                                            try {
                                                Integer y = Integer.valueOf(yyyy);
                                                Integer m = Integer.valueOf(MM);
                                                Integer d = Integer.valueOf(dd);
                                                Date test = Date.newInstance(y, m, d); // throws if invalid
                                                return true;
                                            } catch (Exception e) {
                                                return false;
                                            }
                                        }
                                        
                                        /*==== USER DETAILS REPORT ====*/
                                        private static List<ReportRow> fetchUserDetailsReport(Id userId) {
                                            User loggedInUser = [
            SELECT Id, Profile.Name, Supplier_Group__c
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];
                                            
                                            List<User> users;
                                            
                                            if (loggedInUser.Profile.Name == 'System Administrator' || loggedInUser.Profile.Name == 'CRM Profile') {
                                                users = [
                SELECT Id, FirstName, LastName, Email, Username,
                       Profile.Name, Supplier_Group__c, Supplier_Code__c,
                       IsActive, LastLoginDate,ContactId,
               Contact.Email
                FROM User
                WHERE Profile.Name IN (
                    'CRM Profile',
                    'NGMCP_Gas Supplier Manager',
                    'NGMCP_Gas Supplier Agent'
                ) WITH USER_MODE
                ORDER BY CreatedDate DESC
            ];
                                            } else if (loggedInUser.Profile.Name == 'NGMCP_Gas Supplier Manager') {
                                                users = [
                SELECT Id, FirstName, LastName, Email, Username,
                       Profile.Name, Supplier_Group__c, Supplier_Code__c,
                       IsActive, LastLoginDate,
                ContactId,
               Contact.Email
                FROM User
                WHERE Supplier_Group__c = :loggedInUser.Supplier_Group__c
                ORDER BY CreatedDate DESC
            ];
                                            } else {
                                                users = new List<User>();
                                            }
                                            
                                            return mapUsersToReportRows(users);
                                        }
                                        
                                        /*==== USER MAPPER ====*/
                                        private static List<ReportRow> mapUsersToReportRows(List<User> users) {
                                            List<ReportRow> rows = new List<ReportRow>();
                                            
                                            for (User u : users) {
                                                string visibleEmail = u.Contact != null && String.isNotBlank(u.Contact.Email)
                                                    ? u.Contact.Email
                                                    : null; // or mask(u.Email)
                                                
                                                ReportRow r = new ReportRow();
                                                r.recordId = u.Id;
                                                r.FirstName = u.FirstName;
                                                r.LastName = u.LastName;
                                                r.UserName = u.Username;
                                                r.Email = visibleEmail;
                                                r.supplierGroup = u.Supplier_Group__c;
                                                r.suppliercode = u.Supplier_Code__c;
                                                r.Profile = u.Profile.Name;
                                                r.IsActive = u.IsActive;
                                                //r.LastLoginDate = (u.LastLoginDate != null) ? u.LastLoginDate.date() : null;
                                                r.LastLoginDate = (u.LastLoginDate != null) ? u.LastLoginDate.format('dd/MM/yyyy HH:mm') : null;
                                                rows.add(r);
                                            }
                                            return rows;
                                        }
                                        
                                        /* =====================================================
                                        WRAPPER
                                            ===================================================== */
                                        public class ReportRow {
                                            @AuraEnabled public Id recordId;
                                            @AuraEnabled public String name;
                                            @AuraEnabled public String WorkOrderNumber;
                                            @AuraEnabled public String status;
                                            @AuraEnabled public String mprn;
                                            @AuraEnabled public String jobcategory;
                                            @AuraEnabled public String suppliercode;
                                            @AuraEnabled public String JobDescription;
                                            @AuraEnabled public String CompletionDate;
                                            @AuraEnabled public String JobCode;
                                            @AuraEnabled public string AppointmentDate;
                                            // Data/technical Enquiry report SPECIFIC
                                            @AuraEnabled public String EnquiryType;
                                            @AuraEnabled public String ReasonCode;
                                            @AuraEnabled public String EnquiryCategorydescprition;
                                            @AuraEnabled public String ReasonDescription;
                                            @AuraEnabled public String Startdate;
                                            @AuraEnabled public String Enddate;
                                            @AuraEnabled public String EnquiryCategory;
                                            //AMR Reports
                                            @AuraEnabled public String Address;
                                            @AuraEnabled public string MAMID;
                                            @AuraEnabled public string AppointmentStartDate;
                                            @AuraEnabled public string ServiceLevel;
                                            @AuraEnabled public string AnnualConsumption;
                                            @AuraEnabled public string CustomerEmail;
                                            // only for WORKORDERS reportkey
                                            @AuraEnabled public string CreatedOn;
                                            @AuraEnabled public String SRnumber;
                                            @AuraEnabled public string subcategory;
                                            @AuraEnabled public String BuildingName;
                                            @AuraEnabled public String BuildingNumber;
                                            @AuraEnabled public String Street;
                                            @AuraEnabled public String DependentLocality;
                                            @AuraEnabled public String Town;
                                            @AuraEnabled public String PostCode;
                                            @AuraEnabled public String CustomerName;
                                            @AuraEnabled public String CustomerNumber;
                                            @AuraEnabled public String RequestType;
                                            @AuraEnabled public string TypeCode;
                                            @AuraEnabled public string fromDate;
                                            @AuraEnabled public String toDate;
                                            @AuraEnabled public string CreatedDate;
                                            @AuraEnabled public string QuotationStatus;
                                            // USER REPORT SPECIFIC
                                            @AuraEnabled public String FirstName;
                                            @AuraEnabled public String LastName;
                                            @AuraEnabled public String UserName;
                                            @AuraEnabled public String Email;
                                            @AuraEnabled public String supplierGroup;
                                            @AuraEnabled public String Profile;
                                            @AuraEnabled public Boolean IsActive;
                                            @AuraEnabled public string LastLoginDate;
                                            @AuraEnabled public string recordTypeName;
                                            
                                            public ReportRow() {}
                                        }
                                    }