/*
Class: NGMCP_IBMMaximoIntegrationClass
    Description:
    Apex service class that encapsulates IBM Maximo REST API integrations used by NGMCP.
    Exposes AuraEnabled methods for LWC/Aura to:
    - Fetch asset details by MPRN + optional customer
    - Fetch asset details by Serial Number
    - Fetch asset details by Postal Code + customer
    - Update address for a given Location (PATCH override)
    - Submit an Urgent Work Request (SR create)
    - Process Continuation callback responses
    - Get Meter Model size/category metadata
    Integration:
    - Named Credential(s): NGMCP_Maximo_Integration, NGMCP_Maximo_Named_Credential
    - HTTP: GET for lookups, POST with x-method-override=PATCH for updates
    Considerations:
    - Methods are AuraEnabled to be callable from Lightning.
    - HTTP callouts require appropriate Remote Site/NAMED credential config.
    - Timeouts are set to 120s for potentially slow downstream systems.
    - Error handling throws AuraHandledException for UI-friendly surfacing.
    - Minimal heap usage; responses are parsed on demand.
    Author: Patan Shabbir Ali Khan
    Created: 2025-10-27
    Last Modified: 2025-10-27
     */
public with sharing class NGMCP_IBMMaximoIntegrationClass {
    /**
     * Calls the Maximo API to retrieve asset details based on MPRN and optional customer ID.
     *
     * @param mprn The Meter Point Reference Number.
     * @param customer The customer identifier (optional).
     * @return Parsed asset details from the Maximo API response.
     * @throws AuraHandledException if the API call fails.
     */
    @AuraEnabled
    /**
     * Retrieve asset details from Maximo based on MPRN and optional customer id.
     * - If customer is blank/null, query is executed with empty customer filter.
     * - Encodes where/select clauses to ensure safe URL construction.
     *
     * Governor limits:
     * - Single HTTP callout per invocation of this method.
     *
     * @param mprn     Meter Point Reference Number (required).
     * @param customer Customer identifier (optional; empty string used when null/blank).
     * @return Parsed NGMCP_GetAssetDetailsClass instance from response body.
     * @throws AuraHandledException on non-200 response.
     */
    public static NGMCP_GetAssetDetailsClass callAssetDetailsAPI(String mprn, String customer) {
        //NGMCP_GetAssetDetailsClass responseValue ;
        String relativePath;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        // Build relative path based on presence of optional customer
        if(!String.isEmpty(mprn) && (String.isEmpty(customer) || customer == null)){
            customer ='';
            relativePath = '?relativeuri=1'
                + '&lean=1'
                + '&ignorekeyref=1'
                + '&ignorecollectionref=1'
                + '&oslc.where=' + EncodingUtil.urlEncode('LOCATION="' + mprn + '"', 'UTF-8')
                + '&oslc.select=' + EncodingUtil.urlEncode('*', 'UTF-8')
                + '&pluspcustassoc.pluspcustassoc.where=' + EncodingUtil.urlEncode('customer="' + customer + '"', 'UTF-8')
                + '&ignorers=1';
        } else if(!String.isEmpty(mprn) && !String.isEmpty(customer) && customer != null){
            relativePath = '?relativeuri=1'
                + '&lean=1'
                + '&ignorekeyref=1'
                + '&ignorecollectionref=1'
                + '&oslc.where=' + EncodingUtil.urlEncode('LOCATION="' + mprn + '"', 'UTF-8')
                + '&oslc.select=' + EncodingUtil.urlEncode('*', 'UTF-8')
                + '&pluspcustassoc.pluspcustassoc.where=' + EncodingUtil.urlEncode('customer="' + customer + '"', 'UTF-8')
                + '&ignorers=1';
        }
        // Configure endpoint via Named Credential to avoid storing secrets in code
        request.setEndpoint('callout:NGMCP_Maximo_Integration' + relativePath);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        HttpResponse response = http.send(request);
        // Handle response
        if (response.getStatusCode() == 200) {
            return NGMCP_GetAssetDetailsClass.parse(response.getBody());
        } else {
            // Surface a user-friendly exception to Lightning consumers
            throw new AuraHandledException('Failed to fetch MPRN data: ' + response.getStatus());
        }
        
    }
    
    /**
     * Calls the Maximo API to retrieve asset details based on a serial number.
     *
     * @param serailNumber The serial number of the asset.
     * @return Parsed asset details from the Maximo API response.
     * @throws AuraHandledException if the API call fails.
     */
    @AuraEnabled
    public static NGMCP_GetAssetDetailsClass callSerialNumberAssetDetailsAPI(String serailNumber) {
        //NGMCP_GetAssetDetailsClass responseValue ;
        String relativePath;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        if(!String.isEmpty(serailNumber) && serailNumber != null){
            relativePath = '?relativeuri=1' +
                '&lean=1' +
                '&ignorekeyref=1' +
                '&ignorecollectionref=1' +
                '&oslc.where=ASSET.SERIALNUM%3D%22' + EncodingUtil.urlEncode(serailNumber, 'UTF-8') + '%22' +
                '&oslc.select=*' +
                '&ignorers=1';
        }
        request.setEndpoint('callout:NGMCP_Maximo_Integration' + relativePath);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            return NGMCP_GetAssetDetailsClass.parse(response.getBody());
        } else {
            throw new AuraHandledException('Failed to fetch MPRN data: ' + response.getStatus());
        }
        
    }
    
    /**
     * Calls the Maximo API to retrieve asset details based on postal code and customer ID.
     *
     * @param postalcodevalue The postal code to search assets by.
     * @param customer The customer identifier.
     * @return Parsed asset details from the Maximo API response.
     * @throws AuraHandledException if the API call fails.
     */
    @AuraEnabled
    public static NGMCP_GetAssetDetailsClass callpostalAssetDetailsAPI(String postalcodevalue, String customer) {
        //NGMCP_GetAssetDetailsClass responseValue ;
        String relativePath;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        if(!String.isEmpty(postalcodevalue) && postalcodevalue != null){
            
            relativePath = '?relativeuri=1' +
                '&lean=1' +
                '&ignorekeyref=1' +
                '&ignorecollectionref=1' +
                '&oslc.where=NGME_C_SPC%3D%22' + EncodingUtil.urlEncode(postalcodevalue, 'UTF-8') + '%22' +
                '&oslc.select=*' +
                '&pluspcustassoc.pluspcustassoc.where=' + EncodingUtil.urlEncode('customer="' + customer + '"', 'UTF-8')+
                '%22'+
                '&ignorers=1';
        }
        request.setEndpoint('callout:NGMCP_Maximo_Integration' + relativePath);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        HttpResponse response = http.send(request);
        Integer statusCode = response.getStatusCode();
        if (statusCode == 200) {
            return NGMCP_GetAssetDetailsClass.parse(response.getBody());
        } else {
            throw new AuraHandledException('Failed postcallout: ' + response.getStatus());
        }
        
    }
    @AuraEnabled
    /**
     * Update address for a given Location via Maximo REST API.
     * Uses POST with x-method-override=PATCH and patchtype=MERGE headers to perform a merge update.
     *
     * DML:
     * - On success, updates NGMCP_Request__c record to Completed and stores a success message.
     *
     * @param requestBody     JSON string body to patch (must be valid and non-empty).
     * @param locationId      Location identifier (string numeric) used to form resource path.
     * @param adreesRequestId NGMCP_Request__c Id to update status on success.
     * @return Success message string.
     * @throws AuraHandledException on non-2xx responses.
     */
    public static String addressUpdateAPI(String requestBody, String locationId, Id adreesRequestId) {
        String relativePath = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Build relative path if locationId is provided
        if (!String.isBlank(locationId)) {
            Double d = Double.valueOf(locationId);
            Integer locationInteger = d.intValue();
            relativePath = '/' + locationInteger
                + '?relativeuri=1'
                + '&lean=1'
                + '&ignorekeyref=1'
                + '&ignorecollectionref=1';
        }
        
        request.setEndpoint('callout:NGMCP_Maximo_Integration' + relativePath);
        request.setMethod('POST');
        request.setHeader('x-method-override', 'PATCH');
        request.setHeader('patchtype', 'MERGE');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);
        request.setTimeout(120000);
        
        Integer maxRetries = 3;
        Integer attempt = 0;
        
        HttpResponse response;
        Integer lastStatusCode;
        Boolean isSuccess = false;
        while (attempt < maxRetries) {
            attempt++;
            response = http.send(request);
            lastStatusCode = response.getStatusCode();
            
            if (lastStatusCode == 200 || lastStatusCode == 204) {
                isSuccess = true;
                break;
            }
            
            // Retry only for 412
            if (lastStatusCode == 412) {
                continue;
            }
            
            // Any other error: break and throw after loop (optional), or throw here
            break;
        }
        if (isSuccess) {
            List<NGMCP_Request__c> updateRequest = [
            SELECT Id, NGMCP_Callout_Status__c, NGMCP_Callout_Response__c
            FROM NGMCP_Request__c
            WHERE Id = :adreesRequestId
              AND NGMCP_Callout_Status__c = 'In Progress'
            WITH USER_MODE
            LIMIT 1
        ];
            
            if (!updateRequest.isEmpty()) {
                updateRequest[0].NGMCP_Callout_Status__c = 'Completed';
                updateRequest[0].NGMCP_Callout_Response__c = 'Address updated successfully!';                
                Database.update(updateRequest, false, AccessLevel.USER_MODE);
            }
            
            return 'Address updated successfully!';
        }
        
        // If retries exhausted or non-retry status
        if (lastStatusCode == 412) {
            throw new AuraHandledException(
                'Failed after ' + maxRetries + ' attempts. Last Status: ' + lastStatusCode
                );
        }
        
        throw new AuraHandledException('Failed to update address. Status: ' + lastStatusCode);
    }
        /* =========================================================
     * PUBLIC METHODS
     * ========================================================= */
    
    /**
     * Submit an Urgent Work Request (Service Request create) to Maximo.
     */
    @AuraEnabled
    public static Object submitUrgentWorkRequest(String requestBody, Id requestId) {
        String relativePath =
            '/NGME_SR_CRT?relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1&ignorers=1';
        
        return submitWorkRequest(requestBody, requestId, relativePath);
    }
    
    /**
     * Submit Creatt Work Request based on Industry
     */
    @AuraEnabled
    public static Object submitCreattWorkRequest(String requestBody, Id requestId, String industry) {
        
        String relativePath =
            (industry == 'D')
            ? '/NGME_SR_CRT?relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1&ignorers=1'
            : '/NGME_SR_PHOCRT?relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1&ignorers=1';
        return submitWorkRequest(requestBody, requestId, relativePath);
    }
    
    // ============================================
    // SEND EMAIL (CALLED FROM LWC)
    // ============================================
    @AuraEnabled
    public static void sendAddressUpdateEmail(
        String mprn
        //    String srNumber,
    //    String jobCode
    ) {
        try {
            //  Fetch Recipients From Custom Label
            String labelValue = System.Label.NGMCP_Address_Amendent;
            if (String.isBlank(labelValue)) {
                return;
            }
            // Convert to List
            List<String> recipients = new List<String>();
            for (String email : labelValue.split(',')) {
                if (String.isNotBlank(email)) {
                    recipients.add(email.trim());
                }
            }
            if (recipients.isEmpty()) {
                return;
            }
            //  Build Email Body
            String emailBody;
            if (String.isNotBlank(mprn)) {
                emailBody =
                    'An address amendment has been actioned via the NGM Customer Portal for MPRN '
                    + mprn
                    //    + ' // SR '
                //    + srNumber
                //    + ' // Job Code '
                //    + jobCode
                + '\n\nPlease review in case of any follow up action.';
            } else {
                emailBody =
                    'An address amendment has been actioned via the NGM Customer Portal for MPRN '
                    + mprn
                    //    + ' // Job Code '
                //    + jobCode
                + '\n\nPlease review in case of any follow up action.';
            }
            // 🔹 Create Email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(recipients);
            mail.setSubject('Address Amendment Notification');
            mail.setPlainTextBody(emailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
            throw new AuraHandledException('Email sending failed: ' + e.getMessage());
        }
    }
    // ======================================================
    // OVERLOADED METHOD - CALLED FROM TRIGGER (BULK SAFE)
    // ======================================================
    public static void sendAddressUpdateEmail(List<NGMCP_Request__c> requests) {
        if (requests == null || requests.isEmpty()) {
            return;
        }
        for (NGMCP_Request__c req : requests) {
            // Null safety check (important)
            if (req == null) {
                continue;
            }
            String mprn     = req.NGMCP_MPRN__c;
            //String srNumber = req.NGMCP_SR_Number__c;
            //String jobCode  = req.NGMCP_Job_Code__c;
            // Optional: Skip if MPRN is missing (adjust based on your logic)
            if (String.isBlank(mprn)) {
                continue;
            }
            // Call existing LWC method
            sendAddressUpdateEmail(
                mprn
                // srNumber,
            // jobCode
            );
        }
    }
    
    /* =========================================================
     * CORE CALLOUT LOGIC
     * ========================================================= */
    
    private static Object submitWorkRequest(String requestBody, Id requestId, String relativePath) {
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        try {
            // Prepare request
            request.setEndpoint('callout:NGMCP_Maximo_Named_Credential' + relativePath);
            request.setMethod('POST');
            request.setHeader('properties', 'ticketid, ticketuid, AMRFlag');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(requestBody);
            request.setTimeout(120000);
            
            // Execute callout
            Long startTime = System.currentTimeMillis();
            HttpResponse response = http.send(request);
            Long duration = System.currentTimeMillis() - startTime;
            
            Integer statusCode = response.getStatusCode();
            String responseBody = response.getBody();
            Map<String, Object> result =
                (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            
            // Fetch request record
            NGMCP_Request__c req = fetchRequestRecord(requestId);
            if (req == null) {
                return responseBody;
            }
            
            // Handle response
            if (statusCode == 200 || statusCode == 201) {
                handleSuccess(req, result, responseBody);
            } else {
                handleError(req, result);
            }
            
            Database.update (new List<NGMCP_Request__c> {req}, false);
            
            return responseBody;
            
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected error occurred: ' + e.getMessage());
        }
    }
    
    /* =========================================================
     * HELPER METHODS
     * ========================================================= */
    
    /**
     * Fetch request record in "In Progress" state
     */
    private static NGMCP_Request__c fetchRequestRecord(Id requestId) {
        
        List<NGMCP_Request__c> reqList = [
            SELECT Id,
                   NGMCP_Callout_Status__c,
                   NGMCP_Callout_Response__c,
                   NGMCP_SR_Ticket__c,
                   NGMCP_Ticketuid__c,
                   NGMCP_Error_Message__c
            FROM NGMCP_Request__c
            WHERE Id = :requestId
              AND NGMCP_Callout_Status__c = 'In Progress' WITH USER_MODE
            LIMIT 1
        ];
        
        return reqList.isEmpty() ? null : reqList[0];
    }
    
    /**
     * Handle successful response
     */
    private static void handleSuccess(
        NGMCP_Request__c req,
    Map<String, Object> result,
    String responseBody
    ) {
        req.NGMCP_Callout_Status__c = 'Completed';
        req.NGMCP_Callout_Response__c = responseBody;
        req.NGMCP_SR_Ticket__c = (String) result.get('ticketid');
        req.NGMCP_Ticketuid__c = String.valueOf(result.get('ticketuid'));
    }
    
    /**
     * Handle error response
     */
    @TestVisible
    private static void handleError(
        NGMCP_Request__c req,
    Map<String, Object> result
    ) {
        Map<String, Object> errorMap =
            (result != null) ? (Map<String, Object>) result.get('Error') : null;
        
        req.NGMCP_Callout_Status__c = 'Error';
        req.NGMCP_Error_Message__c =
            (errorMap != null && errorMap.containsKey('message'))
            ? (String) errorMap.get('message')
            : 'Unknown error occurred';
    }
    
    /* @description Retrieves the meter model size and market sector code from custom metadata
     *              based on the provided meter model name.
     *
     * @param meterModel The name of the meter model to filter.
     * @return A string in the format "SizeCategory" or null if not found or input is blank.
     */
    @AuraEnabled
    /**
     * Retrieve Meter Model size, market sector code, UWR job code, and portal category from custom metadata.
     * Returns null on blank input or on exception.
     *
     * @param meterModel DeveloperName of the metadata record to fetch.
     * @return NGMCP_MeterModelJobCodeMatrix__mdt record or null.
     */
    public static NGMCP_MeterModelJobCodeMatrix__mdt getMeterModelSizeandcatagory(String meterModel) {
        // Return null if input is blank
        if (String.isBlank(meterModel)) {
            return null;
        }
        
        try {
            // Query only required fields from the custom metadata
            NGMCP_MeterModelJobCodeMatrix__mdt meterJob = [
            SELECT  NGMCP_Meter_Size__c, NGMCP_Meter_Model_Size__c, NGMCP_Market_Sector_Code__c, NGMCP_UWR_Job_Code__c, NGMCP_Portal_Category__c,NGMCP_Job_Description__c
            FROM NGMCP_MeterModelJobCodeMatrix__mdt
            WHERE DeveloperName = :meterModel WITH USER_MODE
            LIMIT 1
        ];
            return meterJob;
        } catch (Exception e) {
            // Log error for debugging and return null
            return null;
        }
    }
    
    
    @AuraEnabled
    public static Integer getPreviousUrgentWorkRequestHistoryForMPRN(String mprnNumber) {
        // Return null if input is blank (or consider returning 0)
        if (String.isBlank(mprnNumber)) {
            return null;
        }
        try {
            Integer countOfMprn = [
            SELECT COUNT()
            FROM NGMCP_Request__c
            WHERE RecordType.DeveloperName = 'NGMCP_Urgent_Work_Request'
              AND NGMCP_MPRN__c = :mprnNumber AND NGMCP_Callout_Status__c ='Completed' 
              AND CreatedDate = LAST_N_DAYS:30 WITH USER_MODE
        ];
            return countOfMprn;
        } catch (Exception e) {
            // You can return 0 instead of null depending on your contract with callers
            return null;
        }
    }
    @AuraEnabled
    public static NGMCP_DocumentDownloadWrapper downloadDocuments(String srNumber) {
        
        if (String.isBlank(srNumber)) {
            throw new AuraHandledException('SR Number is required');
        }
        
        String relativePath =
            '/NGME_DOCLINKS_DL' +
            '?relativeuri=1' +
            '&lean=1' +
            '&ignorekeyref=1' +
            '&ignorecollectionref=1' +
            '&inlinedoc=1' +
            '&oslc.where=ticketid=%22' +
            EncodingUtil.urlEncode(srNumber, 'UTF-8') +
            '%22' +
            '&oslc.select=*';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:NGMCP_Maximo_Named_Credential' + relativePath);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() != 200) {
            System.debug('getStatusCode'+res.getStatusCode());
            throw new AuraHandledException(
                'Maximo document download failed: ' + res.getStatus()
                );
        }
        
        return NGMCP_DocumentDownloadWrapper.parse(res.getBody());
    }
    
    
}