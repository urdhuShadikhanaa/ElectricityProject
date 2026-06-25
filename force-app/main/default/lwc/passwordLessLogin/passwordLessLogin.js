import { LightningElement, track } from 'lwc';
import initiateLogin from '@salesforce/apex/MFILoginController.initiateLogin';
import verifyLogin from '@salesforce/apex/MFILoginController.verifyLogin';
export default class PasswordLessLogin extends LightningElement {
    @track email = '';
    @track code = '';
    @track identifier;
    @track showVerification = false;
    @track errorMessage;
    // Handles email input change
    handleEmailChange(event) {
        this.email = event.target.value;
    }

    // Handles code input change
    handleCodeChange(event) {
        this.code = event.target.value;
    }

    // Initiates the passwordless login process
    async initiateLogin() {
        try {
            this.identifier = await initiateLogin({ email: this.email });
            this.showVerification = true;
            console.log('Magic link or code sent successfully.');
        } catch (error) {
            console.error('Error initiating login:', error);
            this.errorMessage = JSON.stringify(error);
        }
    }

    // Verifies the login using the code
    async verifyLogin() {
        try {
            const result = await verifyLogin({
                email: this.email,
                identifier: this.identifier,
                code: this.code,
            });

            if (result) {
                console.log('Login successful!'+result);
                window.open(result,'_self');
            } else {
                console.error('Invalid code or login failed.');
                this.errorMessage = 'Invalid code or login failed.';
            }
        } catch (error) {
            this.errorMessage = JSON.stringify(error);
            console.error('Error verifying login:', error);
        }
    }
}