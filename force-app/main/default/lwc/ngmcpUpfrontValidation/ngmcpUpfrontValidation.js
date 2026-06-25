import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ContactFormValidation extends LightningElement {
   @track title = '';
   @track contactName = '';
   @track phone = '';
   @track email = '';
   @track accessInstructions = '';
   titleOptions = [
       { label: 'Mr', value: 'Mr' },
       { label: 'Ms', value: 'Ms' },
       { label: 'Mrs', value: 'Mrs' },
       { label: 'Dr', value: 'Dr' }
   ];

   handleTitleChange(event) {
       this.title = event.target.value;
   }
   handleChange(event) {
        const value = event.target.value;
        const sanitizedValue = value.replace(/[^a-zA-Z\s]/g, '');
        this.contactName = sanitizedValue;

        // An alternative is to use this validation in a form submission handler
        const inputField = this.template.querySelector('lightning-input');
        if (inputField.checkValidity()) {
            // The input is valid, do something
        } else {
            inputField.reportValidity();
        }
    }
    
   handleEmailChange(event) {
       const input = event.target.value.trim();
       // Validate email format
       const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
       if (!emailRegex.test(input)) {
           event.target.setCustomValidity("Please validate the Email Provided");
       } else {
           event.target.setCustomValidity(""); // Clear error
       }
       event.target.reportValidity();
       this.email = input;
   }

   handlePhoneChange(event) {
    const input = event.target.value.trim();

    // Remove all non-digit characters
    const onlyNumbers = input.replace(/\D/g, '');

    // Update the phone property with cleaned input
    this.phone = onlyNumbers;

    // Reference to the input field
    const inputField = event.target;

    // Validate: must be 10 or 11 digits only
    if (onlyNumbers.length >= 10 && onlyNumbers.length <= 11) {
        inputField.setCustomValidity(''); // Clear error
    } else {
        inputField.setCustomValidity('Phone number must be numberic and be 10 or 11 digits.');
    }

    inputField.reportValidity(); // Show error below the field
}
   
    
handleAccessChange(event) {
    this.accessInstructions = event.target.value;
        if (this.accessInstructions.length > 255) {
            this.showError = true;
        } else {
            this.showError = false;
        }
}


   handleSubmit() {
       const allValid = [...this.template.querySelectorAll('lightning-input, lightning-textarea, lightning-combobox')]
           .reduce((validSoFar, inputCmp) => {
               inputCmp.reportValidity();
               return validSoFar && inputCmp.checkValidity();
           }, true);
       if (allValid) {
           this.dispatchEvent(
               new ShowToastEvent({
                   title: 'Success',
                   message: 'Form submitted successfully!',
                   variant: 'success'
               })
           );
       } else {
           this.dispatchEvent(
               new ShowToastEvent({
                   title: 'Error',
                   message: 'Please fill all required fields correctly.',
                   variant: 'error'
               })
           );
       }
   }
}