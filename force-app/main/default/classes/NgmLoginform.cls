global class NgmLoginform {
@AuraEnabled
    global static String login(String username, String password) {
        try {
            ApexPages.PageReference lgn = Site.login(username, password, '');
            return (lgn != null) ? lgn.getUrl() : null;
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }
}