public with sharing class NGMCP_HomeProfileController {
    @AuraEnabled(cacheable=true)
    public static String getUserProfileName(){
        return[
            SELECT Id, Profile.Name
        	FROM User
        	WHERE Id = :UserInfo.getUserId()
        	LIMIT 1 
        ].Profile.Name;
    }  
    
}