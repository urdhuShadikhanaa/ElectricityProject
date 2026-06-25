/*
** Description: This class is used in CRM**
*/
public class importDataFromCSVController {
public Blob csvFileBody{get;set;}
    public PageReference reset() {
        PageReference pg = new PageReference(System.CurrentPageReference().getURL());
        pg.setRedirect(true);
        return pg;
    }
public string csvAsString{get;set;}
public String[] csvFileLines{get;set;}
public List<Stock_Item__c> silist{get;set;}
  public importDataFromCSVController(){
    csvFileLines = new String[]{};
    silist = New List<Stock_Item__c>(); 
  }
  
  public void importCSVFile(){
       try{
           csvAsString = csvFileBody.toString();
           csvFileLines = csvAsString.split('\n'); 
            
           for(Integer i=1;i<csvFileLines.size();i++){
               Stock_Item__c siObj = new Stock_Item__c() ;
               string[] csvRecordData = csvFileLines[i].split(',');
               siObj.Location__c = csvRecordData[0] ;             
               siObj.np_Flange_Size__c= csvRecordData[1];
               siObj.Model__c= csvRecordData[2];
               siObj.Serial_Number__c= csvRecordData[3];   
               siObj.np_Flange_Type__c= csvRecordData[4];
               siObj.np_Flow_Direction__c= csvRecordData[5];
               siObj.np_Face_to_Face__c= csvRecordData[6];
               siObj.Old_Model__c= csvRecordData[7];
                 siObj.Year_of_Manufacture__c= csvRecordData[8];
              siObj.Electricals__c= csvRecordData[9]; 
               siObj.PO_If_applicable__c= csvRecordData[10]; 
               siObj.New_Pallet_No__c= csvRecordData[11]; 
               siObj.Number_on_Pallet__c= csvRecordData[12]; 
               siObj.np_Availability_Status__c= csvRecordData[13]; 
               siObj.Make__c= csvRecordData[14]; 
               siObj.Comment__c= csvRecordData[15];
               silist.add(siObj);   
           }
       if(silist.size()>0)
insert silist;
        }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Please make sure input csv file is correct');
            ApexPages.addMessage(errorMessage);
        }  
  }
}