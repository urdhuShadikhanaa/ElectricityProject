import { LightningElement } from 'lwc';
import createAddressDetail from '@salesforce/apex/AddressDetailController.createAddressDetail';

export default class MeterDetailsUI extends LightningElement {
    buildingName = '';
    dependentLocality = '';
    postalTown = '';
    postalCode = '';
    street = '';

    handleChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    handleSave() {
        const fields = {
            Building_Name_Number__c: this.buildingName,
            Dependent_Locally__c: this.dependentLocality,
            Postal_Town__c: this.postalTown,
            Postal_code__c: this.postalCode,
            Street__c: this.street
        };

        createAddressDetail({ addressFields: fields })
            .then(() => {
                alert('Address saved successfully!');
            })
            .catch(error => {
                console.error('Error saving address:', error);
            });
    }
}