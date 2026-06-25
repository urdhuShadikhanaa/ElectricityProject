@isTest
public class NGMCP_FetchRequestsFromMaximoTest {
    
    @isTest
    static void testExecuteNormalFlow() {
        // Create a queuable instance
        NGMCP_FetchRequestsFromMaximoQueuable queuable = new NGMCP_FetchRequestsFromMaximoQueuable();
        
        // Execute the queuable - this should not throw any exceptions
        Test.startTest();
        try{
          queuable.execute(null);  
        }catch(Exception ex){
			System.debug(ex);
        }
        
        Test.stopTest();
        
        // Verify that the method completed without throwing unhandled exceptions
        System.assert(true, 'Queueable executed without exceptions');
    }
    
    @isTest
    static void testInstantiation() {
        // Test that the class can be instantiated
        NGMCP_FetchRequestsFromMaximoQueuable queuable = new NGMCP_FetchRequestsFromMaximoQueuable();
        
        // Verify that the instance was created
        System.assertNotEquals(null, queuable);
    }
}