public  class getlivecscusers {
     Integer count = 0;
          
    public PageReference incrementCounter() {
        count++;
        return null;
    }
        public Integer getCount() {
        return count;
    }

public list <User> getList ()

{

List <user> userlist = Database.query('Select Id, Name, Availability_Status__c, On_a_call__c, Visual_Availiability__c, Call_centre_user__c, logged_in__c From User WHERE logged_in__c = true and Call_centre_user__c = true') ;

return userlist;
}
}