trigger LookupResponsibleTerritory on Permit_To_Work__c (before insert) {
    /* This trigger will try and find the Responsible Territory for the Site Postcode in High Risk Activity */
       
    for(Permit_To_Work__c ptw : trigger.new)
    {
        if(ptw.Site_Postcode__c != null && ptw.Site_Postcode__c.length() > 2 )
        {
            System.debug('Site Postcode: '+ptw.Site_Postcode__c);
            
            String ptwPostcodePrefix;
            
            if (ptw.Site_Postcode__c.substring(1,2).isNumeric())
            {
                /* Postcode has only single alpha at start */
            	ptwPostcodePrefix = '%|' + ptw.Site_Postcode__c.substring(0,1).toUpperCase() + '|%';    
            }
            else
            {
                /* Postcode has two alphas at start */
            	ptwPostcodePrefix = '%|' + ptw.Site_Postcode__c.substring(0,2).toUpperCase() + '|%';    
            }
            
            System.debug('Looking for territory with Postcode prefix: '+ptwPostcodePrefix);
            
            try {
                if ([Select count() From Responsible_Territory__c Where Postcode_Coverage__c like :ptwPostcodePrefix] > 0)
                {
                    Responsible_Territory__c rt = [Select ID, Name From Responsible_Territory__c Where Postcode_Coverage__c like :ptwPostcodePrefix limit 1];
                    
                    if (rt != null && rt.Id != null)
                    {
                        System.debug('Found Territory: '+rt.Name);
                        
                        ptw.territory__c = rt.Id;
                    }
                }
            }            
			catch (Exception e)
            {
                System.debug('Exception caught: '+e.getMessage());
            }
        }
    }
}