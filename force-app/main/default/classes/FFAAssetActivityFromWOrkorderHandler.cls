public class FFAAssetActivityFromWOrkorderHandler{
    Public Static Void astActivitiesbeforeFormResponse(set<Id> workOrderIDs){
        Try{
             System.debug('Into Handler---'+workOrderIDs);
             list<FFA_NGV_Asset__c> astActivities=new list<FFA_NGV_Asset__c>();
             list<FFA_NGV_Asset__c> Assets=[SELECT Id,Name,FFA_Serial_Number__c,FFA_Asset_Type__c,FFA_MeterRemoval__c,FFA_Meter_Removed__c,
                                           FFA_Year_of_Manufacturer__c,FFA_Manufacturer_Fix__c,Serial_Number_Fix__c,FFA_Asset_Status__c,FFA_Asset_Status_Fix__c,
                                           Converter_Removed__c,FFA_Model__c,FFA_Manufacturer__c,FFA_Activity_Type__c,FFA_Location__c,
                                           FFA_Other_Manufacturer__c,FFA_Other_Model__c,FFA_Other_Manufacturer_fix__c,FFA_Other_Model_fix__c,
                                           FFA_Year_of_Manufacturer_Fix__c,FFA_Model_Fix__c,FFA_Regulator_Removed__c,FFA_Other_Asset_Activity__c,
                                           (SELECT Field,Id,NewValue,OldValue,ParentId FROM Histories WHERE Field IN('FFA_Serial_Number__c','FFA_Manufacturer__c','FFA_Model__c','FFA_Year_of_Manufacturer__c','FFA_Asset_Status__c','FFA_Other_Manufacturer__c','FFA_Other_Model__c')),
                                           FFA_IsRegulatorOnSite__c,FFA_IsMeterOnSite__c FROM FFA_NGV_Asset__c where Work_Order__c=:workOrderIDs];
             IF(!Assets.isEmpty()){
             
                   FOR(FFA_NGV_Asset__c ngvAsset:Assets){
                       System.debug('Assets Check in---'+ngvAsset.Name);
                    // Activity Type F and E
                       IF((ngvAsset.FFA_Serial_Number__c!=null && ngvAsset.Serial_Number_Fix__c!=null) ||
                       (ngvAsset.FFA_Manufacturer__c!=null && ngvAsset.FFA_Manufacturer_Fix__c!=null) ||
                       (ngvAsset.FFA_Year_of_Manufacturer__c!=null && ngvAsset.FFA_Year_of_Manufacturer_Fix__c!=null)||
                       (ngvAsset.FFA_Model__c!=null && ngvAsset.FFA_Model_Fix__c!=null ) ||
                       (ngvAsset.FFA_Other_Model__c!=null && ngvAsset.FFA_Other_Model_fix__c!=null ) ||
                       (ngvAsset.FFA_Other_Manufacturer__c!=null && ngvAsset.FFA_Other_Manufacturer_fix__c!=null ) ){     
                            //Activity E
                            System.debug('ngvAsset.FFA_IsMeterOnSite__c---'+ngvAsset.FFA_IsMeterOnSite__c);
                            If(ngvAsset.FFA_IsRegulatorOnSite__c!='No' && ngvAsset.FFA_Asset_Type__c=='Regulator'){
                                ngvAsset.FFA_Activity_Type__c='E';
                            }else if( ngvAsset.FFA_IsMeterOnSite__c!='No' && ngvAsset.FFA_Asset_Type__c=='Meter'){
                                ngvAsset.FFA_Activity_Type__c='E';
                                System.debug('ngvAsset.FFA_IsMeterOnSite__c---'+ngvAsset.FFA_IsMeterOnSite__c);
                            }
                            else if(ngvAsset.FFA_Asset_Type__c!='Meter' && ngvAsset.FFA_Asset_Type__c!='Regulator'){
                                ngvAsset.FFA_Activity_Type__c='E';
                            }
                            else{
                                ngvAsset.FFA_Activity_Type__c='F';
                            }
                           
                       }
                    //Activity F
                       ELSE IF(ngvAsset.FFA_Serial_Number__c==null &&  ngvAsset.FFA_Manufacturer__c==null  && ngvAsset.FFA_Model__c==null && ngvAsset.FFA_Year_of_Manufacturer__c==null && ngvAsset.FFA_Other_Manufacturer__c==null && ngvAsset.FFA_Other_Model__c==null && ngvAsset.FFA_IsRegulatorOnSite__c==null && ngvAsset.FFA_IsMeterOnSite__c==null
                       && (ngvAsset.Serial_Number_Fix__c!=null || ngvAsset.FFA_Manufacturer_Fix__c!=null || ngvAsset.FFA_Year_of_Manufacturer_Fix__c!=null || ngvAsset.FFA_Model_Fix__c!=null || ngvAsset.FFA_Other_Model_fix__c!=null || ngvAsset.FFA_Other_Manufacturer_fix__c!=null)  ){
                        
                              ngvAsset.FFA_Activity_Type__c='F';
                        
                        
                      }
                      //Activity R
                      ELSE IF(ngvAsset.FFA_Meter_Removed__c!=null ||  ngvAsset.Converter_Removed__c!=null || ngvAsset.FFA_Regulator_Removed__c !=null || ngvAsset.FFA_Other_Asset_Activity__c=='Remove Asset'){
                        
                        ngvAsset.FFA_Activity_Type__c='R';
                       
                      }
                      ////Activity A
                      ELSE IF(ngvAsset.Histories!=null){
                          For(FFA_NGV_Asset__History Hist:ngvAsset.Histories){
                              IF(Hist.Field=='FFA_Serial_Number__c' && Hist.OldValue!=null && Hist.OldValue!=Hist.NewValue ){
                                  ngvAsset.FFA_Activity_Type__c='A';
                              }
                              IF(Hist.Field=='FFA_Model__c' && Hist.OldValue!=null && Hist.OldValue!=Hist.NewValue ){
                                  ngvAsset.FFA_Activity_Type__c='A';
                              }
                              IF(Hist.Field=='FFA_Model__c' && Hist.OldValue!=null && Hist.OldValue!=Hist.NewValue ){
                                  ngvAsset.FFA_Activity_Type__c='A';
                              }
                              IF(Hist.Field=='FFA_Year_of_Manufacturer__c' && Hist.OldValue!=null && Hist.OldValue!=Hist.NewValue ){
                                  ngvAsset.FFA_Activity_Type__c='A';
                              }
                              IF(Hist.Field=='FFA_Manufacturer__c' && Hist.OldValue!=null && Hist.OldValue!=Hist.NewValue ){
                                  ngvAsset.FFA_Activity_Type__c='A';
                              }
                              IF(Hist.Field=='FFA_Asset_Status__c' && Hist.OldValue!=null && Hist.OldValue!=Hist.NewValue ){
                                  ngvAsset.FFA_Activity_Type__c='A';
                              }
                              IF(Hist.Field=='FFA_Other_Manufacturer__c' && Hist.OldValue!=null && Hist.OldValue!=Hist.NewValue ){
                                  ngvAsset.FFA_Activity_Type__c='A';
                              }
                              IF(Hist.Field=='FFA_Other_Model__c' && Hist.OldValue!=null && Hist.OldValue!=Hist.NewValue ){
                                  ngvAsset.FFA_Activity_Type__c='A';
                              }
                              
                          }
                      }
                      else{
                          ngvAsset.FFA_Activity_Type__c='';
                          
                      } 
                      astActivities.add(ngvAsset);   
                   }                                  
              } 
              IF(!astActivities.isEmpty()){
              Update astActivities;
              }                              
        
        }catch(Exception e){
            System.debug(e.getMessage()+'Failed due to line num=='+e.getLineNumber());
        }
    }
}