public class NGMCP_HelpcentreControllerTest_Helper {
    // simple delegating wrapper used by tests to call the AuraEnabled method
    @TestVisible
    public static List<ContentDocument> callGetLibraryFiles(String libraryName) {
        return NGMCP_HelpcentreController.getLibraryFiles(libraryName);
    }
}