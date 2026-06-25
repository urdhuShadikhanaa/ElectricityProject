@isTest
public class NGMCP_UDPTCtrlTest {
    
    @isTest
    static void testGetUserSupplierCodesForGroupWithNullInput() {
        // Test with null controlling selection
        List<NGMCP_UserDependentPicklistController.PicklistOption> result = 
            NGMCP_UserDependentPicklistController.getUserSupplierCodesForGroup(
                null, 
                true, 
                false
            );
        
        System.assertEquals(0, result.size(), 'Should return empty list for null controlling selection');
    }
    
    @isTest
    static void testGetUserSupplierCodesForGroupWithBlankInput() {
        // Test with blank controlling selection
        List<NGMCP_UserDependentPicklistController.PicklistOption> result = 
            NGMCP_UserDependentPicklistController.getUserSupplierCodesForGroup(
                '', 
                true, 
                false
            );
        
        System.assertEquals(0, result.size(), 'Should return empty list for blank controlling selection');
    }
    
    @isTest
    static void testGetUserSupplierCodeOptions() {
        // Test the method that doesn't require complex setup
        // This method will return whatever data the current user has
        List<NGMCP_UserDependentPicklistController.suplliercodeWrapper> result = 
            NGMCP_UserDependentPicklistController.getUserSupplierCodeOptions();
        
        // Just verify it doesn't throw an exception and returns a valid list
        // The exact count depends on the current user's data in the org
        System.assertNotEquals(null, result, 'Should not return null');
    }
}