import { LightningElement, track, wire } from 'lwc';
import getContactDetails from '@salesforce/apex/uwrContactController.getContactDetails';
import saveContactDetails from '@salesforce/apex/uwrContactController.saveContactDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UwrContactDetails extends LightningElement {
    @track contact = { name: '', contactNumber: '', email: '' };

    // Fetch existing contact details
    @wire(getContactDetails)
    wiredContact({ error, data }) {
        if (data) {
            this.contact = data;
        } else if (error) {
            this.showToast('Error', 'Failed to load contact details', 'error');
        }
    }

    handleInputChange(event) {
        const fieldName = event.target.name;
        const value = event.target.value;

        // Basic validations
        if (fieldName === 'contactNumber' && !/^\d*$/.test(value)) {
            event.target.setCustomValidity('Contact number must contain only digits.');
        } else if (fieldName === 'email' && value && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
            event.target.setCustomValidity('Please enter a valid email address.');
        } else {
            event.target.setCustomValidity('');
        }

        event.target.reportValidity();

        this.contact = { ...this.contact, [fieldName]: value };
    }

    handleSave() {
        saveContactDetails({ contactData: this.contact })
            .then(() => {
                this.showToast('Success', 'Contact details saved successfully', 'success');
            })
            .catch(() => {
                this.showToast('Error', 'Failed to save contact details', 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}