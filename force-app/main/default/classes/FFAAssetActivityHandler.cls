/*    SAP-FFA ACTIVITY FACTORS               
      Author: VENKAT PATTAPU                        
      Company: Wipro Technologies                  
      Created Date: 01/07/2019                     
      Details: Class will be Invoked from Trigger and it will Update Activity type
                of Asset based on different conditions.
                       
*/
/////////////////////////////////////////////////
/* Code Updates:                                */
/////////////////////////////////////////////////
public class FFAAssetActivityHandler{ 

    public static void doProcessActivityTypes(list<FFA_NGV_Asset__c> newAssets,Map<id,FFA_NGV_Asset__c>OldAssetdata,Boolean updateEvent){
        set<Id> AssetIDs=new set<Id>();
        for(FFA_NGV_Asset__c NGVAssets:newAssets){
            AssetIDs.add(NGVAssets.id);
        }
        list<FFA_NGV_Asset__c> AssetsList=[SELECT Id,FFA_Serial_Number__c,FFA_Asset_Type__c,FFA_MeterRemoval__c,FFA_Meter_Removed__c,
                                           FFA_Year_of_Manufacturer__c,FFA_Manufacturer_Fix__c,Serial_Number_Fix__c,FFA_Asset_Status__c,FFA_Asset_Status_Fix__c,
                                           Converter_Removed__c,FFA_Model__c,FFA_Manufacturer__c,FFA_Activity_Type__c,FFA_Location__c,
                                           FFA_Other_Manufacturer__c,FFA_Other_Model__c,FFA_Other_Manufacturer_fix__c,FFA_Other_Model_fix__c,
                                           FFA_Year_of_Manufacturer_Fix__c,FFA_Model_Fix__c,FFA_Regulator_Removed__c,FFA_Other_Asset_Activity__c, Work_Order__r.FFA_Sender_ID__c,
                                           FFA_IsRegulatorOnSite__c,FFA_IsMeterOnSite__c, Work_Order__r.Status FROM FFA_NGV_Asset__c WHERE ID=:AssetIDs ]; 
        system.debug('MM: List of Assets: ' + AssetsList);
        system.debug('--->'+ updateEvent);
        list<FFA_NGV_Asset__c> updateAssetActivities=new list<FFA_NGV_Asset__c>();
            
            /*If Asset serialNo and SerialNoFIX is not empty then ActivityType consider as 'E' -Exchanged 
            /*If Asset contains only Fix related fileds the ActivityType considered as 'F'-Installed
            /*If Asset contains Meter Removal or Converter Removal then it would be treated as 'R'-Removed
            /*If any Asset fields such as Srno, Manufacturer, Year of Manufacturer, Model updated then it will be considered as
              Activity Type 'A'- Amend */
        system.debug('MM: AssetsList.isEmpty() ' + AssetsList.isEmpty());              
        if(!AssetsList.isEmpty()){
            for(FFA_NGV_Asset__c NGVAssets: AssetsList){
                system.debug('MM: FFAAssetActivityHelper - WO Status: ' + NGVAssets.Work_Order__r.Status); 
                if((NGVAssets.FFA_Serial_Number__c!=null && NGVAssets.Serial_Number_Fix__c!=null) ||
                   (NGVAssets.FFA_Manufacturer__c!=null && NGVAssets.FFA_Manufacturer_Fix__c!=null) ||
                   (NGVAssets.FFA_Year_of_Manufacturer__c!=null && NGVAssets.FFA_Year_of_Manufacturer_Fix__c!=null)||
                   (NGVAssets.FFA_Model__c!=null && NGVAssets.FFA_Model_Fix__c!=null ) ||
                   (NGVAssets.FFA_Other_Model__c!=null && NGVAssets.FFA_Other_Model_fix__c!=null ) ||
                   (NGVAssets.FFA_Other_Manufacturer__c!=null && NGVAssets.FFA_Other_Manufacturer_fix__c!=null ) ){
                        If(NGVAssets.FFA_IsRegulatorOnSite__c!='No' && NGVAssets.FFA_Asset_Type__c=='Regulator'){
                            NGVAssets.FFA_Activity_Type__c='E';
                            system.debug('MM: Condition 1.1 True: ' + NGVAssets.FFA_Activity_Type__c);
                        }else if( NGVAssets.FFA_IsMeterOnSite__c!='No' && NGVAssets.FFA_Asset_Type__c=='Meter'){
                            NGVAssets.FFA_Activity_Type__c='E';
                            system.debug('MM: Condition 1.2 True: ' + NGVAssets.FFA_Activity_Type__c);
                        }
                        else if(NGVAssets.FFA_Asset_Type__c!='Meter' && NGVAssets.FFA_Asset_Type__c!='Regulator'){
                            NGVAssets.FFA_Activity_Type__c='E';
                            system.debug('MM: Condition 1.3 True: ' + NGVAssets.FFA_Activity_Type__c);
                        }
                        else{
                             NGVAssets.FFA_Activity_Type__c='F';
                             system.debug('MM: Condition 1.4 True: ' + NGVAssets.FFA_Activity_Type__c);
                        }
                        updateAssetActivities.add(NGVAssets);
                    }
                   else if(NGVAssets.FFA_Serial_Number__c==null &&  NGVAssets.FFA_Manufacturer__c==null  && NGVAssets.FFA_Model__c==null && NGVAssets.FFA_Year_of_Manufacturer__c==null && NGVAssets.FFA_Other_Manufacturer__c==null && NGVAssets.FFA_Other_Model__c==null && NGVAssets.FFA_IsRegulatorOnSite__c==null && NGVAssets.FFA_IsMeterOnSite__c==null
                            && (NGVAssets.Serial_Number_Fix__c!=null || NGVAssets.FFA_Manufacturer_Fix__c!=null || NGVAssets.FFA_Year_of_Manufacturer_Fix__c!=null || NGVAssets.FFA_Model_Fix__c!=null || NGVAssets.FFA_Other_Model_fix__c!=null || NGVAssets.FFA_Other_Manufacturer_fix__c!=null)  ){
                        NGVAssets.FFA_Activity_Type__c='F';
                                
                        system.debug('MM: Condition 2 True: ' + NGVAssets.FFA_Activity_Type__c);        
                        updateAssetActivities.add(NGVAssets);
                    }
                    else if(NGVAssets.FFA_Meter_Removed__c!=null ||  NGVAssets.Converter_Removed__c!=null || NGVAssets.FFA_Regulator_Removed__c !=null || NGVAssets.FFA_Other_Asset_Activity__c=='Remove Asset'){
                        NGVAssets.FFA_Activity_Type__c='R';
                        
                        system.debug('MM: Condition 3 True: ' + NGVAssets.FFA_Activity_Type__c);
                        updateAssetActivities.add(NGVAssets);
                    }
             /*22/09/2020: ---- CR/Bug Fix Start: handles the missing asset data in SAP scenario ---- */  
                    else if (OldAssetdata == null && NGVAssets.Work_Order__r.Status != 'New'
                             && (
                                 (NGVAssets.FFA_IsRegulatorOnSite__c=='No' && NGVAssets.FFA_Asset_Type__c=='Regulator')
                                 || ( NGVAssets.FFA_IsMeterOnSite__c=='No' && NGVAssets.FFA_Asset_Type__c=='Meter')
                                )
                             && (NGVAssets.FFA_Model_Fix__c!=null 
                                                      || NGVAssets.Serial_Number_Fix__c!=null 
                                                      || NGVAssets.FFA_Year_of_Manufacturer_Fix__c!=null
                                                      || NGVAssets.FFA_Manufacturer_Fix__c!=null
                                                      || NGVAssets.FFA_Asset_Status_Fix__c!=null
                                                      || NGVAssets.FFA_Other_Manufacturer_Fix__c!=null
                                                      || NGVAssets.FFA_Other_Model_Fix__c!=null)
                                                   )
                    {
                        NGVAssets.FFA_Activity_Type__c='F';
                        system.debug('MM: Condition 1.5 True: ' + NGVAssets.FFA_Activity_Type__c);
                        updateAssetActivities.add(NGVAssets);
                    }                 
                    
                    else if (OldAssetdata == null && NGVAssets.Work_Order__r.Status != 'New'
                             && (NGVAssets.FFA_Model__c!=null 
                                                      || NGVAssets.FFA_Serial_Number__c!=null 
                                                      || NGVAssets.FFA_Year_of_Manufacturer__c!=null
                                                      || NGVAssets.FFA_Manufacturer__c!=null
                                                      || NGVAssets.FFA_Asset_Status__c!=null
                                                      || NGVAssets.FFA_Other_Manufacturer__c!=null
                                                      || NGVAssets.FFA_Other_Model__c!=null))
                    {
                        NGVAssets.FFA_Activity_Type__c='A';
                        system.debug('MM: Condition 1.6 True: ' + NGVAssets.FFA_Activity_Type__c);
                        updateAssetActivities.add(NGVAssets);
                    }  
                
                
             /*22/09/2020: ------ CR/Bug Fix End ------ */
                
                   else if(updateEvent==true ){
                       /*19/10/2020: ---- Bug Fix Start: handles partial missing asset data from SAP scenario ---- */
						/*
                          if((NGVAssets.FFA_Model__c!=OldAssetdata.get(NGVAssets.Id).FFA_Model__c && OldAssetdata.get(NGVAssets.Id).FFA_Model__c!=null)
                          ||(NGVAssets.FFA_Serial_Number__c!=OldAssetdata.get(NGVAssets.Id).FFA_Serial_Number__c && OldAssetdata.get(NGVAssets.Id).FFA_Serial_Number__c!=null)
                          ||(NGVAssets.FFA_Year_of_Manufacturer__c!=OldAssetdata.get(NGVAssets.Id).FFA_Year_of_Manufacturer__c && OldAssetdata.get(NGVAssets.Id).FFA_Year_of_Manufacturer__c!='')
                          ||(NGVAssets.FFA_Manufacturer__c!=OldAssetdata.get(NGVAssets.Id).FFA_Manufacturer__c && OldAssetdata.get(NGVAssets.Id).FFA_Manufacturer__c!=null)
                          ||(NGVAssets.FFA_Asset_Status__c!=OldAssetdata.get(NGVAssets.Id).FFA_Asset_Status__c && OldAssetdata.get(NGVAssets.Id).FFA_Asset_Status__c!='')
                          ||(NGVAssets.FFA_Other_Manufacturer__c!=OldAssetdata.get(NGVAssets.Id).FFA_Other_Manufacturer__c)
                          ||(NGVAssets.FFA_Other_Model__c!=OldAssetdata.get(NGVAssets.Id).FFA_Other_Model__c)){
                          */
                          if(
                             (NGVAssets.FFA_Model__c!=OldAssetdata.get(NGVAssets.Id).FFA_Model__c)
                          		||(NGVAssets.FFA_Serial_Number__c!=OldAssetdata.get(NGVAssets.Id).FFA_Serial_Number__c)
                          		||(NGVAssets.FFA_Year_of_Manufacturer__c!=OldAssetdata.get(NGVAssets.Id).FFA_Year_of_Manufacturer__c)
                          		||(NGVAssets.FFA_Manufacturer__c!=OldAssetdata.get(NGVAssets.Id).FFA_Manufacturer__c)
                          		||(NGVAssets.FFA_Asset_Status__c!=OldAssetdata.get(NGVAssets.Id).FFA_Asset_Status__c)
                          		||(NGVAssets.FFA_Other_Manufacturer__c!=OldAssetdata.get(NGVAssets.Id).FFA_Other_Manufacturer__c)
                          		||(NGVAssets.FFA_Other_Model__c!=OldAssetdata.get(NGVAssets.Id).FFA_Other_Model__c)
                            ){
							/*19/10/2020: ------ Bug Fix End --- --- */
                                
                            NGVAssets.FFA_Activity_Type__c='A';
                           
                            system.debug('MM: Condition 4 True: ' + NGVAssets.FFA_Activity_Type__c);  
                            updateAssetActivities.add(NGVAssets);
                            }
                      
                     }
                    else{
                    NGVAssets.FFA_Activity_Type__c='';
                    system.debug('MM: Condition 5 - Else: ' + NGVAssets.FFA_Activity_Type__c);    
                    updateAssetActivities.add(NGVAssets);
                    system.debug('---Empty');
                    }
                }
        }
        if(!updateAssetActivities.isEmpty()){
        update updateAssetActivities;
        }
    }
}