public class submitFormCustomObjectController {
 
    
    @AuraEnabled
    public static List<Robot_Tracking_Entry__c> getRobot(Robot_Tracking_Entry__c insertRobot){
        insert insertRobot;
        
        return [select id, Performance_Month__c,NGM_AMR_Requests__c,TQ_TFM__c,dual_supplier_deappoint_process__c,Supplierless_auto_appoint_deappoint__c,market_sector_changes__c,TSEd2__c,JVOD_JNOC__c,TQ_TFM_Power_BI__c,TSE_R3__c,TSE_R_3__c,TSEd4__c, TSE_c_A__c, Finance_accruals__c,IMS__c, Aged_Debt__c,Gosp_import__c, AMR_Photos__c, Customer_Invoicing_Billing__c, DM_Reads__c, GPS_Job_Queue__c, GPS_line_Queue__c, AMR_Certificate_uploads__c, Meter_Pick_up__c, Site_Husbandry_Monitoring__c,AMR_Stop_Deap__c, Site_Husbandry_Remedials__c,NGM_Validation_report__c,NGM_TSE_SLG_1__c, Standard_Work__c,Comments__c,NGM_Report_Distribution__c,	NGM_TSE_Creation__c, NGM_meter_validations__c, Working_days__c, Adhoc_GPS_Checks_Pulsing_check__c from Robot_Tracking_Entry__c];
    }
    
}