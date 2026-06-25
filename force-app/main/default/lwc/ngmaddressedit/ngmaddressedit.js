import { LightningElement, api } from 'lwc';

export default class MprnOverview extends LightningElement {
    @api recordId; // Record Id passed from Experience Cloud page

    // Left side fields
    assetFields = [
        'Meter_Model__c',
        'Manufacturing_Serial_Number__c',
        'Manufacturer__c',
        'Year_of_Manufacture__c',
        'Location_Description__c',
        'Installation_Date__c',
        'Payment_Mechanism__c',
        'Meter_Type__c',
        'Number_of_Dials__c',
        'Appointed_Date__c',
        'Asset_Type__c',
        'Conversion_Factor__c'
    ];

    handleSuccess() {
        // Show toast after successful save
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Address updated successfully!',
                variant: 'success'
            })
        );
    }
}