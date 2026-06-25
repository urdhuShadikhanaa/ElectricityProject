@isTest
public class testimportDataFromCSVController {
      public static String[] csvFileLines;
    public static Blob csvFileBody;
  
 static testMethod void TestFileUploader2 (){
   
      Stock_Item__c si = new Stock_Item__c();
       
       String csvRecordData = 'Location__c,np_Flange_Size__c,Model__c,Serial_Number__c,np_Flange_Type__c,np_Flow_Direction__c,np_Face_to_Face__c,Old_Model__c,Year_of_Manufacture__c,Electricals__c,PO_If_applicable__c,New_Pallet_No__c,Number_on_Pallet__c \n'+String.Valueof(si.id)+',here,100,this,12345,pn16,l to r,100,d3,1983,binder,34000,b,8';
insert si;
   String str = csvRecordData + csvRecordData;
        
       

        test.startTest();



        PageReference newImportdatabycsv = Page.Importdatabycsv;//Page reference  
        Test.setCurrentPage(newImportdatabycsv);//Set the current page 

         csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 
      ImportDataFromCSVController FileUpload = new ImportDataFromCSVController();
        FileUpload.csvFileBody = csvFileBody;
     
    
   
     FileUpload.reset();
     
 
  
   
        
        test.stopTest(); 
         } 

    static testmethod void testfileuploadNegative(){
         Stock_Item__c si = new Stock_Item__c();
       
       String csvRecordData = 'Location__c,np_Flange_Size__c,Model__c,Serial_Number__c,np_Flange_Type__c,np_Flow_Direction__c,np_Face_to_Face__c,Old_Model__c,Year_of_Manufacture__c,Electricals__c,PO_If_applicable__c,New_Pallet_No__c,Number_on_Pallet__c \n'+String.Valueof(si.id)+',here,100,this,12345,pn16,l to r,100,d3,1983,binder,34000,b,8';
insert si;
   String str = csvRecordData + csvRecordData;
        Test.startTest();       
        csvFileBody = Blob.valueOf(csvRecordData);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        ImportDataFromCSVController FileUpload = new ImportDataFromCSVController();
        FileUpload.importCSVFile();
        
        Test.stopTest();
    }
        static testmethod void testfileuploadalt(){
              Stock_Item__c si = new Stock_Item__c();
       
       String csvRecordData = 'Location__c,np_Flange_Size__c,Model__c,Serial_Number__c,np_Flange_Type__c,np_Flow_Direction__c,np_Face_to_Face__c,Old_Model__c,Year_of_Manufacture__c,Electricals__c,PO_If_applicable__c,New_Pallet_No__c,Number_on_Pallet__c,np_Availability_Status__c \n'+String.Valueof(si.id)+',here,100,this,12345,pn16,l to r,100,d3,1983,binder,34000,b,8,Available to use';
insert si;
                     
        Stock_Item__c newsi1 = new Stock_Item__c(Location__c='Nexus', Serial_Number__c='ABC');
        Stock_Item__c newsi2 = new Stock_Item__c(Location__c='Nexus', Serial_Number__c='DEF');
        insert newsi1;
    	insert newsi2;
		
        String firstRow = newsi1.Id+',54321,DummyTitle1,40,hello\n';
        String secondRow = newsi2.id+',987654,DummyTitle2,40,hello';
        String str = csvRecordData + firstRow + secondRow;
        System.debug('firstRow::::: '+firstRow);
        System.debug('secondRow::::: '+secondRow);
        System.debug('str::::: '+str);
        Test.startTest();       
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        ImportDataFromCSVController importData = new ImportDataFromCSVController();
        importData.csvFileBody = csvFileBody;
        importData.importCSVFile();
        Test.stopTest();
    } 
    }