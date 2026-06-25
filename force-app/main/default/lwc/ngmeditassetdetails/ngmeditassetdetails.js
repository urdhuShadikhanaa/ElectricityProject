import { LightningElement, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import NGMCP_REQUESTS_OBJECT from '@salesforce/schema/NGMCP_REQUESTS__c';
import BUILDING_NAME_FIELD from '@salesforce/schema/NGMCP_REQUESTS__c.Building_Name_Number__c';
import DEPENDENT_LOCALITY_FIELD from '@salesforce/schema/NGMCP_REQUESTS__c.Dependent_Locally__c';
import POSTAL_TOWN_FIELD from '@salesforce/schema/NGMCP_REQUESTS__c.Postal_Town__c';
import POSTAL_CODE_FIELD from '@salesforce/schema/NGMCP_REQUESTS__c.Postal_code__c';
import STREET_FIELD from '@salesforce/schema/NGMCP_REQUESTS__c.Street__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddressFormLDS extends LightningElement {
    @track buildingName = '';
    @track dependentLocality = '';
    @track postalTown = '';
    @track postalCode = '';
    @track street = '';

    handleChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    handleSave() {
        const fields = {};
        fields[BUILDING_NAME_FIELD.Building_Name_Number__c] = this.buildingName;
        fields[DEPENDENT_LOCALITY_FIELD.Dependent_Locally__c] = this.dependentLocality;
        fields[POSTAL_TOWN_FIELD.Postal_Town__c] = this.postalTown;
        fields[POSTAL_CODE_FIELD.Postal_code__c] = this.postalCode;
        fields[STREET_FIELD.Street__c] = this.street;

        const recordInput = { apiName: NGMCP_REQUESTS_OBJECT.NGMCP_REQUESTS__c, fields };

        
          
        
    }}