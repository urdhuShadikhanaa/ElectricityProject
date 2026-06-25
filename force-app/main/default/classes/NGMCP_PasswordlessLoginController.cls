public with sharing class NGMCP_PasswordlessLoginController {

    // ---------------------------------------------------------
    // STEP 1: Send OTP When Username Entered
    // ---------------------------------------------------------
    @AuraEnabled(cacheable=false)
        public static String sendOtpForPasswordlessLogin(String username) {
    System.debug('sendOtpForPasswordlessLogin() called with username: ' + username);

        // Validate
        if (String.isBlank(username)) {
            System.debug('username missing');
            return 'INVALID_INPUT';
        }

        List<User> users = [
            SELECT Id, Email, FirstName, IsActive
            FROM User
            WHERE Username = :username
            LIMIT 1
        ];

        System.debug('User Query Returned: ' + users);

        if (users.isEmpty()) {
            System.debug('USER_NOT_FOUND');
            return 'USER_NOT_FOUND';
        }

        User u = users[0];

        if (!u.IsActive) {
            System.debug('USER_INACTIVE');
            return 'USER_INACTIVE';
        }

        // Generate OTP
        String otp = generateOtp();
        System.debug('Generated OTP: ' + otp);

        OTP_Tracker__c tracker = new OTP_Tracker__c(
            User__c = u.Id,
            OTP__c = otp,
            Expiry__c = System.now().addMinutes(5),
            Is_Used__c = false
        );

        insert tracker;
        System.debug(' OTP Tracker Created: ' + tracker);

        // Send Email
        sendOtpEmailUsingTemplate(u, tracker);

        System.debug(' OTP email sent successfully.');

        return 'OTP_SENT';
    }

    // ---------------------------------------------------------
    // OTP GENERATOR (6 digits)
    // ---------------------------------------------------------
    @TestVisible
    private static String generateOtp() {
        Integer raw = Math.abs((Integer)Crypto.getRandomInteger());
        Integer otp = Math.mod(raw, 1000000);
        return String.valueOf(otp).leftPad(6, '0');
    }


    // ---------------------------------------------------------
    // USE EMAIL TEMPLATE TO SEND OTP
    // ---------------------------------------------------------
    @TestVisible
    private static void sendOtpEmailUsingTemplate(User u, OTP_Tracker__c tracker) {
         System.debug(' Sending OTP email to: ' + u.Email);
        try {
            EmailTemplate tmpl = [
                SELECT Id FROM EmailTemplate 
                WHERE DeveloperName = 'NGMCP_OTP_Email_Template'
                LIMIT 1
            ];
          

			 System.debug(' Email Template: ' + tmpl);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSaveAsActivity(false);
            email.setToAddresses(new List<String>{ u.Email });
            // Template Id stored in Custom Label
             email.setTemplateId(tmpl.Id);
            // Required for merge fields
            email.setTargetObjectId(u.Id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email });

        } catch (Exception ex) {
            System.debug('EMAIL_FAILED: ' + ex.getMessage());
            throw new AuraHandledException('EMAIL_FAILED: ' + ex.getMessage());
        }
    }


    // ---------------------------------------------------------
    // STEP 3: Validate OTP
    // ---------------------------------------------------------
    @AuraEnabled(cacheable=false)
    public static String validateOtp(String username, String otp) {
		System.debug('username >>'+ username);
        System.debug('otp entereed >>'+ otp);
        if (String.isBlank(username) || String.isBlank(otp)) {
            return 'INVALID_INPUT';
        }

        List<User> users = [
            SELECT Id, IsActive
            FROM User
            WHERE Username = :username
            LIMIT 1
        ];
        
        System.debug('users >>'+ users);

        if (users.isEmpty()) return 'USER_NOT_FOUND';

        User u = users[0];

        if (!u.IsActive) return 'USER_INACTIVE';

        List<OTP_Tracker__c> trackers = [
            SELECT Id, OTP__c, Expiry__c, Is_Used__c
            FROM OTP_Tracker__c
            WHERE User__c = :u.Id
            AND Is_Used__c = false
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (trackers.isEmpty()) return 'OTP_NOT_FOUND';

        OTP_Tracker__c tracker = trackers[0];

        if (System.now() > tracker.Expiry__c)
            return 'OTP_EXPIRED';

        if (tracker.OTP__c != otp)
            return 'INVALID_OTP';

        // Mark OTP as used
        tracker.Is_Used__c = true;
        update tracker;

        // Returning success so LWC can redirect to login page
        return 'OTP_VALID';
    }
}