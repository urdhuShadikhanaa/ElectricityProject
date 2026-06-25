global with sharing class NGMCP_LockedUserEmailScheduler implements Schedulable {

    private static final Set<String> TARGET_PROFILE_NAMES =
        new Set<String>{'NGMCP_Gas Supplier Agent', 'NGMCP_Gas Supplier Manager'};

    private static final String ORG_WIDE_EMAIL = System.Label.Box_Email;

    global void execute(SchedulableContext sc) {
        System.debug(LoggingLevel.ERROR, '=== Scheduler execute started ===');
        processLockedOrFrozenUsers(15, false);
        resetEmailFlagForUnlockedUsers();
        System.debug(LoggingLevel.ERROR, '=== Scheduler execute finished ===');
    }

    @TestVisible
    public static void processLockedOrFrozenUsers() {
        processLockedOrFrozenUsers(10, false);
    }

    
    public static void processLockedOrFrozenUsers(Integer lookbackMinutes, Boolean ignoreProfileFilter) {
        System.debug(LoggingLevel.ERROR, '=== processLockedOrFrozenUsers START ===');
        System.debug(LoggingLevel.ERROR, 'lookbackMinutes = ' + lookbackMinutes);
        System.debug(LoggingLevel.ERROR, 'ignoreProfileFilter = ' + ignoreProfileFilter);
        System.debug(LoggingLevel.ERROR, 'System.now() = ' + System.now());
        System.debug(LoggingLevel.ERROR, 'TARGET_PROFILE_NAMES = ' + TARGET_PROFILE_NAMES);

        Datetime windowStart = System.now().addMinutes(-lookbackMinutes);
        System.debug(LoggingLevel.ERROR, 'windowStart = ' + windowStart);

        // Find UserLogin records changed in the last X mins and currently locked/frozen
        List<UserLogin> recentLockedLogins = [
            SELECT UserId, IsFrozen, IsPasswordLocked, LastModifiedDate
            FROM UserLogin
            WHERE (IsFrozen = true OR IsPasswordLocked = true)
        ];

        System.debug(LoggingLevel.ERROR, 'recentLockedLogins count = ' + recentLockedLogins.size());
        for (UserLogin ul : recentLockedLogins) {
            System.debug(LoggingLevel.ERROR,
                'UserLogin -> UserId=' + ul.UserId +
                ', IsFrozen=' + ul.IsFrozen +
                ', IsPasswordLocked=' + ul.IsPasswordLocked +
                ', LastModifiedDate=' + ul.LastModifiedDate
            );
        }

        if (recentLockedLogins.isEmpty()) {
            System.debug(LoggingLevel.ERROR, 'EXIT: No UserLogin records found in time window.');
            return;
        }

        Set<Id> userIds = new Set<Id>();
        for (UserLogin ul : recentLockedLogins) {
            if (ul.UserId != null) {
                userIds.add(ul.UserId);
            }
        }

        System.debug(LoggingLevel.ERROR, 'userIds count = ' + userIds.size());
        System.debug(LoggingLevel.ERROR, 'userIds = ' + userIds);

        if (userIds.isEmpty()) {
            System.debug(LoggingLevel.ERROR, 'EXIT: No UserIds collected from UserLogin.');
            return;
        }

        List<User> targetUsers;

        if (ignoreProfileFilter) {
            targetUsers = [
                SELECT Id, FirstName, Email, IsActive, Lock_Email_Sent__c,
                       Profile.Name, ProfileId, Manager.Name
                FROM User
                WHERE Id IN :userIds
                AND IsActive = true
                AND Email != null
                AND Lock_Email_Sent__c = false
            ];
        } else {
            targetUsers = [
                SELECT Id, FirstName, Email, IsActive, Lock_Email_Sent__c,
                       Profile.Name, ProfileId, Manager.Name
                FROM User
                WHERE Id IN :userIds
                AND IsActive = true
                AND Email != null
                AND Lock_Email_Sent__c = false
                AND Profile.Name IN :TARGET_PROFILE_NAMES
            ];
        }

        System.debug(LoggingLevel.ERROR, 'targetUsers count = ' + targetUsers.size());
        for (User usr : targetUsers) {
            System.debug(LoggingLevel.ERROR,
                'Target User -> Id=' + usr.Id +
                ', Email=' + usr.Email +
                ', IsActive=' + usr.IsActive +
                ', Lock_Email_Sent__c=' + usr.Lock_Email_Sent__c +
                ', Profile.Name=' + usr.Profile.Name +
                ', ProfileId=' + usr.ProfileId +
                ', Manager=' + (usr.Manager != null ? usr.Manager.Name : null)
            );
        }

        if (targetUsers.isEmpty()) {
            System.debug(LoggingLevel.ERROR,
                'EXIT: No eligible users after filters. Check profile names, Lock_Email_Sent__c, IsActive, Email.');
            return;
        }

        Id orgWideEmailId;
        List<OrgWideEmailAddress> oweaList = [
            SELECT Id, Address
            FROM OrgWideEmailAddress
            WHERE Address = :ORG_WIDE_EMAIL
            LIMIT 1
        ];

        System.debug(LoggingLevel.ERROR, 'OWEA count = ' + oweaList.size());

        if (!oweaList.isEmpty()) {
            orgWideEmailId = oweaList[0].Id;
            System.debug(LoggingLevel.ERROR, 'Using OrgWideEmailAddressId = ' + orgWideEmailId);
        } else {
            System.debug(LoggingLevel.ERROR, 'No matching Org Wide Email found for ' + ORG_WIDE_EMAIL);
        }

        Map<Id, UserLogin> loginByUserId = new Map<Id, UserLogin>();
        for (UserLogin ul : recentLockedLogins) {
            if (!loginByUserId.containsKey(ul.UserId)) {
                loginByUserId.put(ul.UserId, ul);
            }
        }

        System.debug(LoggingLevel.ERROR, 'loginByUserId size = ' + loginByUserId.size());

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<User> usersToUpdate = new List<User>();

        for (User usr : targetUsers) {
            UserLogin ul = loginByUserId.get(usr.Id);

            if (ul == null) {
                System.debug(LoggingLevel.ERROR, 'Skipping user ' + usr.Id + ' because no matching UserLogin found.');
                continue;
            }

            String statusText = ul.IsFrozen ? 'frozen' : 'locked';

            String managerText = (usr.Manager != null && usr.Manager.Name != null)
                ? 'Please reach out to your manager, ' + usr.Manager.Name + ', for reactivating your portal account.'
                : 'Please reach out to your manager for reactivating your portal account.';

            String greetingName = String.isBlank(usr.FirstName) ? 'User' : usr.FirstName;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ usr.Email });
            mail.setSubject('Your portal account has been ' + statusText);
            mail.setPlainTextBody(
                'Dear ' + greetingName + ',\n\n' +
                'Your account has been ' + statusText + ' due to incorrect login attempts.\n\n' +
                managerText + '\n\n' +
                'Regards,\nSupport Team'
            );
            mail.setSaveAsActivity(false);

            if (orgWideEmailId != null) {
                mail.setOrgWideEmailAddressId(orgWideEmailId);
            }

            emails.add(mail);

            usr.Lock_Email_Sent__c = true;
            usersToUpdate.add(usr);

            System.debug(LoggingLevel.ERROR,
                'Prepared email for UserId=' + usr.Id +
                ', Email=' + usr.Email +
                ', Status=' + statusText
            );
        }

        System.debug(LoggingLevel.ERROR, 'emails prepared count = ' + emails.size());
        System.debug(LoggingLevel.ERROR, 'usersToUpdate count = ' + usersToUpdate.size());

        if (!emails.isEmpty()) {
            System.debug(LoggingLevel.ERROR, 'Calling Messaging.sendEmail...');
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails, false);

            System.debug(LoggingLevel.ERROR, 'sendEmail results count = ' + results.size());

            for (Integer i = 0; i < results.size(); i++) {
                Messaging.SendEmailResult r = results[i];

                if (r.isSuccess()) {
                    System.debug(LoggingLevel.ERROR, 'Email send SUCCESS for index ' + i);
                } else {
                    System.debug(LoggingLevel.ERROR, 'Email send FAILED for index ' + i);
                    for (Messaging.SendEmailError err : r.getErrors()) {
                        System.debug(LoggingLevel.ERROR,
                            'Error index ' + i +
                            ' -> StatusCode=' + err.getStatusCode() +
                            ', Message=' + err.getMessage()
                        );
                    }
                }
            }
        } else {
            System.debug(LoggingLevel.ERROR, 'No emails prepared, so sendEmail not called.');
        }

        if (!usersToUpdate.isEmpty()) {
            System.debug(LoggingLevel.ERROR, 'Updating users to set Lock_Email_Sent__c = true');
            update usersToUpdate;
            System.debug(LoggingLevel.ERROR, 'User update completed.');
        } else {
            System.debug(LoggingLevel.ERROR, 'No users to update.');
        }

        System.debug(LoggingLevel.ERROR, '=== processLockedOrFrozenUsers END ===');
    }

    @TestVisible
    public static void resetEmailFlagForUnlockedUsers() {
        System.debug(LoggingLevel.ERROR, '=== resetEmailFlagForUnlockedUsers START ===');

        List<User> flaggedUsers = [
            SELECT Id, Lock_Email_Sent__c, Profile.Name
            FROM User
            WHERE Lock_Email_Sent__c = true
            AND Profile.Name IN :TARGET_PROFILE_NAMES
        ];

        System.debug(LoggingLevel.ERROR, 'flaggedUsers count = ' + flaggedUsers.size());

        if (flaggedUsers.isEmpty()) {
            System.debug(LoggingLevel.ERROR, 'EXIT: No flagged users found.');
            return;
        }

        Set<Id> flaggedUserIds = new Set<Id>();
        for (User u : flaggedUsers) {
            flaggedUserIds.add(u.Id);
        }

        System.debug(LoggingLevel.ERROR, 'flaggedUserIds = ' + flaggedUserIds);

        List<UserLogin> stillLocked = [
            SELECT UserId, IsFrozen, IsPasswordLocked
            FROM UserLogin
            WHERE UserId IN :flaggedUserIds
            AND (IsFrozen = true OR IsPasswordLocked = true)
        ];

        System.debug(LoggingLevel.ERROR, 'stillLocked count = ' + stillLocked.size());

        Set<Id> stillLockedUserIds = new Set<Id>();
        for (UserLogin ul : stillLocked) {
            stillLockedUserIds.add(ul.UserId);
            System.debug(LoggingLevel.ERROR,
                'Still locked -> UserId=' + ul.UserId +
                ', IsFrozen=' + ul.IsFrozen +
                ', IsPasswordLocked=' + ul.IsPasswordLocked
            );
        }

        List<User> usersToReset = new List<User>();
        for (User u : flaggedUsers) {
            if (!stillLockedUserIds.contains(u.Id)) {
                u.Lock_Email_Sent__c = false;
                usersToReset.add(u);
                System.debug(LoggingLevel.ERROR, 'Resetting flag for UserId=' + u.Id);
            }
        }

        System.debug(LoggingLevel.ERROR, 'usersToReset count = ' + usersToReset.size());

        if (!usersToReset.isEmpty()) {
            update usersToReset;
            System.debug(LoggingLevel.ERROR, 'Flag reset update completed.');
        } else {
            System.debug(LoggingLevel.ERROR, 'No users needed flag reset.');
        }

        System.debug(LoggingLevel.ERROR, '=== resetEmailFlagForUnlockedUsers END ===');
    }
}