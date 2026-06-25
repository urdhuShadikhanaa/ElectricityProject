import { LightningElement, track } from 'lwc';
import validatePostCode from '@salesforce/apex/NGMCP_PostCodeValidator.validatePostCode';

export default class NGMCP_PostCodeValidator extends LightningElement {
    @track postCode = '';
    @track showWarning = false;

    handleChange(event) {
        this.postCode = event.target.value;
        this.showWarning = false;
    }

    handleValidate() {
        // Simulate check: only validate if not from Maximo
        const isFromMaximo = false; // Replace with actual logic if needed

        if (!isFromMaximo && this.postCode) {
            validatePostCode({ postCode: this.postCode })
                .then((isValid) => {
                    this.showWarning = !isValid;
                })
                .catch((error) => {
                    console.error('Error validating postcode:', error);
                    this.showWarning = true;
                });
        }
    }
}