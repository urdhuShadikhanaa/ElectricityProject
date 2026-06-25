import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getConsentMessage from '@salesforce/apex/NGMCP_gdprMessage.getConsentMessage';

export default class ngmcpGDPRConsent extends LightningElement {
    consentMessage = '';
    agree = false;

    @wire(getConsentMessage)
    wiredMessage({ error, data }) {
        if (data) {
            this.consentMessage = data;
        } else {
            this.consentMessage = 'Please agree to the GDPR Consent';
        }
    }

    handleCheckbox(event) {
        this.agree = event.target.checked;
    }

    handleSubmit(event) {
        event.preventDefault();
        if (this.agree) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'GDPR Consent Accepted',
                    variant: 'success'
                })
            );
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please agree to the GDPR Consent',
                    variant: 'error'
                })
            );
        }
    }

    get isSubmitDisabled() {
        return !this.agree;
    }
}