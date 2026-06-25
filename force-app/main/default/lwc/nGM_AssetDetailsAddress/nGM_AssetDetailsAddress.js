import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// --- update these imports to match your org's API names ---
import ADDRESS_UPDATE_OBJECT from '@salesforce/schema/NGMCP_REQUESTS__c';
import BUILDING_FIELD from '@salesforce/schema/NGMCP_REQUESTS__c.Building_Name_Number__c';
import DEPENDENT_FIELD from '@salesforce/schema/NGMCP_REQUESTS__c.Dependent_Locally__c';
import TOWN_FIELD from '@salesforce/schema/NGMCP_REQUESTS__c.Postal_Town__c';
import POSTCODE_FIELD from '@salesforce/schema/NGMCP_REQUESTS__c.Postal_code__c';
import STREET_FIELD from '@salesforce/schema/NGMCP_REQUESTS__c.Street__c';
import RELATED_ASSET_FIELD from '@salesforce/schema/NGMCP_REQUESTS__c.Related_NGM_AssetDetails__c';

// Asset fields to display (replace if needed)
import ASSET_NAME from '@salesforce/schema/NGM_AssetDetails__c.Name';
//import MPRN from '@salesforce/schema/NGM_AssetDetails__c.MPRN__c';
import INSTALL_DATE from '@salesforce/schema/NGM_AssetDetails__c.Installation_Date__c';
import APPOINTED_DATE from '@salesforce/schema/NGM_AssetDetails__c.Appointed_Date__c';
import LOCATION_DESC from '@salesforce/schema/NGM_AssetDetails__c.Location_Description__c';
import METER_TYPE from '@salesforce/schema/NGM_AssetDetails__c.Meter_Type__c';
import MANUFACTURER from '@salesforce/schema/NGM_AssetDetails__c.Manufacturer__c';

// If your Asset stores address fields and you want to prefill them, import them too:
//import ASSET_BUILDING from '@salesforce/schema/NGM_AssetDetails__c.Building_Name_Number__c';
//import ASSET_TOWN from '@salesforce/schema/NGM_AssetDetails__c.Postal_Town__c';
//import ASSET_POSTCODE from '@salesforce/schema/NGM_AssetDetails__c.Postal_code__c';
//import ASSET_STREET from '@salesforce/schema/NGM_AssetDetails__c.Street__c';

const ASSET_FIELDS = [
    ASSET_NAME, MPRN, INSTALL_DATE, APPOINTED_DATE,
    LOCATION_DESC, METER_TYPE, MANUFACTURER,
    // optional address fields on Asset
    ASSET_BUILDING, ASSET_TOWN, ASSET_POSTCODE, ASSET_STREET
];

export default class AssetAddressEditor extends LightningElement {
    @api recordId; // Asset recordId passed from page context
    @track assetData;

    // Address inputs (editable on the right). Initialize to static defaults:
    buildingName = 'N/A';           // static default
    dependentLocally = '1997';     // example static default
    postalTown = 'Aberdeen';
    postalCode = 'AB24 5QB';
    street = 'Golf Road';

    // show spinner while saving
    saving = false;

    // Load asset record to show static asset values on left
    @wire(getRecord, { recordId: '$recordId', fields: ASSET_FIELDS })
    wiredAsset({ error, data }) {
        if (data) {
            this.assetData = data;

            // If asset has address fields and you want to prefill the form with them,
            // override the defaults here:
            const b = data.fields.Building_Name__c;
            const t = data.fields.Postal_Town__c;
            const p = data.fields.Postal_code__c;
            const s = data.fields.Street__c;
            if (b && b.value) this.buildingName = b.value;
            if (t && t.value) this.postalTown = t.value;
            if (p && p.value) this.postalCode = p.value;
            if (s && s.value) this.street = s.value;
        } else if (error) {
            // handle error if needed
            console.error('Error loading asset', error);
        }
    }

    handleInputChange(event) {
        const name = event.target.name;
        this[name] = event.target.value;
    }

    // Save: create Address_Update__c record using the current input values
    handleSave() {
        this.saving = true;

        // If you want to ALWAYS save hardcoded/static values (ignore user edits),
        // set fields to hardcoded strings here instead of using this.buildingName etc.

        const fields = {};
        fields[BUILDING_FIELD.fieldApiName] = this.buildingName;
        fields[DEPENDENT_FIELD.fieldApiName] = this.dependentLocally;
        fields[TOWN_FIELD.fieldApiName] = this.postalTown;
        fields[POSTCODE_FIELD.fieldApiName] = this.postalCode;
        fields[STREET_FIELD.fieldApiName] = this.street;
        fields[RELATED_ASSET_FIELD.fieldApiName] = this.recordId;

        const recordInput = { apiName: ADDRESS_UPDATE_OBJECT.objectApiName, fields };

        createRecord(recordInput)
            .then(() => {
                this.saving = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Address update saved',
                        variant: 'success'
                    })
                );
            })
            .catch((error) => {
                this.saving = false;
                console.error('Create failed', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error saving',
                        message: error.body ? error.body.message : 'Unknown error',
                        variant: 'error'
                    })
                );
            });
    }
}