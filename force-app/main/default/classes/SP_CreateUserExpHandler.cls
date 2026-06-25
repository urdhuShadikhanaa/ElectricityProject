public class SP_CreateUserExpHandler {
    /*
    public static String SGN = 'FFA SP Users Scotia Gas Network';
    public static String WWU = 'FFA SP Users Wales and West Utilities';
    public static String NTP = 'FFA SP Users Network Plus';
    public static String PENSPEN = 'FFA SP Users Penspen';
    */
    @InvocableMethod(label='Create FFA User')
    public static void createFFAUser(List<Id> cids){
        if(!cids.isEmpty()){
            Id cid = Id.valueOf(cids[0]);
            createFFAServiceEngineer(cid);
        }else{
            system.debug('Input list is Empty -> List<Id> cids');
        }
        
    }
    
    @future
    public static void createFFAServiceEngineer(Id cid){
        try{
            String ffaProfile = 'FFA Service Provider Engineer';
        
            //Id cid = Id.valueOf(cids[0]);
            Contact con = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id =:cid][0];
            
            Profile profileFFA = [select id, name from profile where name =: ffaProfile];
            List<user> ulist = [select id, name, username from user where username =: con.email];

            system.debug('Username already exists->'+JSON.serialize(ulist));
            
            User u = new User();
            u.LastName = con.LastName;
            u.FirstName = con.FirstName;
            u.Email = con.Email;
            u.ContactId = con.Id;
            u.Alias = aliasFormula(con.LastName);
            u.Username = con.Email;
            u.LocaleSidKey = 'en_US';
            u.TimeZoneSidKey = 'Europe/London';
            u.ProfileId = profileFFA.id;
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'ISO-8859-1';
            
            insert u;
            
            system.debug('User created successfully'+u.Id);
            //assignPublicGroup(u.Id);
            
        }catch(DmlException e){
            system.debug('User creation failed with error->'+e.getMessage());
        }

        
    }
    
    public static String aliasFormula(String lname){
        
        Integer year1 = system.today().year();
        String year2 = String.valueOf(year1);
        
        String alias = lname+year2;
        alias = alias.left(8);
        
        return alias;
        
    }    

}