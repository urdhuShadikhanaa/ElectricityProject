public class NGMCP_ResetEmailService {
   public static void send(String username) {
       User u = [
           SELECT Email
           FROM User
           WHERE Username = :username
           LIMIT 1
       ];
       String resetUrl =
           'https://ngmetering--cprtadev.sandbox.my.site.com' +
           '/customerportal/secur/forgotpassword.jsp';
       Messaging.SingleEmailMessage mail =
           new Messaging.SingleEmailMessage();
       mail.setToAddresses(new String[] { u.Email });
       mail.setSubject('Reset your password');
       // ✅ HTML body
       mail.setHtmlBody(
           '<p>Your account has been reactivated.</p>' +
           '<p><a href="' + resetUrl + '">Reset your password</a></p>'
       );
       // ✅ Plain text fallback (CRITICAL)
       mail.setPlainTextBody(
           'Your account has been reactivated.\n\n' +
           'Reset your password:\n' +
           resetUrl
       );
       Messaging.sendEmail(
           new Messaging.SingleEmailMessage[] { mail }
       );
   }
}