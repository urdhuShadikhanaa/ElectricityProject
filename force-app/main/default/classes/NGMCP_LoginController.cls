/**
 * @File Name : NGMCP_LoginController .cls
 * @Description :
 * @Author :P Shabbir Ali Khan
 * @Last Modified By :
 * @Last Modified On : September 30, 2025
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | September 30, 2025 |   | Initial Version
 **/

global class NGMCP_LoginController {
    @AuraEnabled
    public static String login(String username, String password) {
        try {
            ApexPages.PageReference lgn = Site.login(username, password, '');
            return (lgn != null) ? lgn.getUrl() : null;
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }
    
}