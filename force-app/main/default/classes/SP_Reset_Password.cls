public class SP_Reset_Password {
 @InvocableMethod(label='Reset Passwords')
    public static void ResetUserPasswords(List<Id> userIds){
    //public static void ResetUserPasswords(Id userIds){
                
        Id idList = Id.valueOf(userIds[0]);
        List<User> users = [SELECT Id, Name, isActive FROM User WHERE isActive = true AND Id =:idList];
        
        if(!users.isEmpty()){
        for(User u : users){
        
            System.resetPassword(u.Id, true);
      
        }
        }
    }
}