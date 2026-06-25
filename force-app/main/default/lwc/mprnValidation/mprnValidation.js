import { LightningElement, track } from 'lwc';
export default class MprnValidation extends LightningElement {
    @track NGMCP_mprn = '';
    @track NGMCP_errorMessage = '';
    agree = false;

    NGMCP_handleInput(event) {
        this.NGMCP_mprn = event.target.value;
        this.validateMPRN();
    }
    NGMCP_handleChange(event) {
        this.NGMCP_mprn = event.target.value;
        this.validateMPRN();
  }

  validateMPRN() {
        this.NGMCP_errorMessage = '';
        const NGMCP_regex = /^[0-9]+$/; // only numbers
        let errors = [];
        // Rule 1: Cannot start with 0
        if (this.NGMCP_mprn.startsWith('0')) {
            errors.push('Leading zeros are not allowed in MPRN. Please correct and re-submit.');
        }
        // Rule 2: Cannot start with space
        if (this.NGMCP_mprn.startsWith(' ')) {
            errors.push('MPRN should not start/end with a space. Please correct and re-submit.');
        }
        // Rule 3: Cannot end with space
        if (this.NGMCP_mprn.endsWith(' ')) {
            errors.push('MPRN should not start/end with a space. Please correct and re-submit.');
        }
        // Rule 4: Only numbers
        if (!NGMCP_regex.test(this.NGMCP_mprn) && !this.NGMCP_mprn.startsWith(' ') && !this.NGMCP_mprn.endsWith(' ')) {
            errors.push('Only numbers can be accepted in MPRN. Please correct and re-submit.');
        }
        // Rule 5: Maximum length 10
        if (this.NGMCP_mprn.length > 10) {
            errors.push('MPRN cannot exceed 10 digits. Please correct and re-submit');
        }
        // Combine all error messages
        const uniqueErrors = [...new Set(errors)];
        this.NGMCP_errorMessage = uniqueErrors.join('\n');
    }

validateAllFields() {
    const mprnInput = this.template.querySelector('#mprnInput');
    //const postalCodeInput = this.template.querySelector('#postalCode');
    //const serialNumberInput = this.template.querySelector('#serialNumber');

    let isValid = true;

    if (mprnInput && !mprnInput.value) {
        mprnInput.setCustomValidity('MPRN is required');
        isValid = false;
    } else if (mprnInput) {
        mprnInput.setCustomValidity('');
    }
}
}