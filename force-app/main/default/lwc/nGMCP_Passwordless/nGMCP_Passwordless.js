import { LightningElement, track } from 'lwc';
import initiateLogin from "@salesforce/apex/NGMCPPasswordlessLogin.initiateLogin";
import verifyPasswordlessLogin from "@salesforce/apex/NGMCPPasswordlessLogin.verifyPasswordlessLogin";
import communityPath from '@salesforce/label/c.NGMCP_CommunityPath';
import { NavigationMixin } from 'lightning/navigation';
export default class NGMCP_Passwordless extends NavigationMixin(LightningElement) {
    @track loginOption = 'Email';
    @track email = '';
    @track phone = '';
    @track identifier = '';
    @track authorizationMethod = 'Email';
    @track token = '';
    @track otp = '';
    showErrorMessage = false;
    errorMessage = '';
    loginPage = true;
    otpPage = false;
    disableVerifyButton = false;
    @track password = '';
    validationErrors = {};

    handleOptionChange(event) {
        this.loginOption = event.target.value;
    }

    handleOtpChange(event) {
        this.otp = event.target.value;
        
        if (this.otp.length == 6) {
            this.disableVerifyButton = false;
            
        }
    }

    handleIdentifier(event) {
        this.identifier = event.target.value;
        this.email = event.target.value;

    }

    handlePasswordChange(event) {
        this.password = event.target.value;
    }
    handleKeyPress(event) {
        const isEnter = event.key === 'Enter' || event.keyCode === 13;
        if (isEnter) {
            event.preventDefault(); 
            this.password = event.target?.value ?? '';
            this.handleSendOtp();
        }
    }

    handlePressKey(event) {
        if (event.key === 'Enter') {
            this.handleVerifyOtp();
        }
    }
    
    handleSendOtp() {
        let errors = {};
        // Email validation
        if (!this.identifier || !this.identifier.trim()) {
            errors.email = 'Username is required.';
        }

        // Password validation
        if (!this.password || !this.password.trim()) {
            errors.password = 'Password is required.';
        }

        // If any validation errors exist, stop login
        if (Object.keys(errors).length > 0) {
            this.validationErrors = errors;
            return;
        }

        // Clear validation errors if inputs are valid
        this.validationErrors = {};
        this.authorizationMethod = 'Email';



        initiateLogin({
            identifier: this.identifier,
            authorizationMethod: this.authorizationMethod,
            password: this.password
        })
            .then(result => {
                this.showErrorMessage = false;
                this.errorMessage = '';
                this.token = result;
                if (result === 'INVALID_PASSWORD') {
                    this.showErrorMessage = true;
                    this.errorMessage = 'Invalid User name or password.';
                    return;
                }

                let tokenRegex = /^[A-Za-z0-9]{20}$/;

                if (this.token && this.token.match(tokenRegex)) {
                    // Token is valid
                    this.otpPage = true;
                    this.loginPage = false;
                } else if (result.includes('Email Sent , please click on link to enable passwordless login.')) {
                    this.clearErrorMessages();
                    this.showErrorMessage = true;
                    this.errorMessage = 'Email Sent , please click on link received in the email to enable passwordless login.'
                } else {
                    // Token is invalid
                    this.clearErrorMessages();
                    this.showErrorMessage = true;
                    this.errorMessage = 'Some Error Occurred , Please try again later.'
                    
                }
            })
            .catch(error => {
                
            });
    }

    handleVerifyOtp() {
        verifyPasswordlessLogin({
            identifier: this.identifier,
            otp: this.otp,
            authorizationMethod: this.authorizationMethod,
            token: this.token
        })
            .then(result => {
          

                if (result && result.startsWith(window.location.origin)) {
           
                    window.location.replace(result);
                
                } else if (result.includes('Invalid verification code')) {
                    this.clearErrorMessages();
                    this.showErrorMessage = true;
                    this.errorMessage = 'Invalid code, please try again.';
                    this.disableVerifyButton = true;
                } else if (result.includes('Too many attempts')) {
                    this.clearErrorMessages();
                    this.showErrorMessage = true;
                    this.errorMessage = 'Too many attempts, please use resend button and try again.';
                    this.disableVerifyButton = true;
                } else {
                    this.clearErrorMessages();
                    this.showErrorMessage = true;
                    this.errorMessage = 'Some Error Occurred , Please contact your System Administrator.';
                    
                }
            }).catch(error => {
             
            });
    }

    backButton() {
        this.resetLoginState();
        this.otpPage = false;
        this.loginPage = true;
    }

    clearErrorMessages() {
        this.errorMessage = '';
    }

    redirectToHome() {
        const baseUrl = window.location.origin;
        let path = communityPath;
        if (!path.startsWith('/')) {
            path = '/' + path;
        }

        const finalUrl = baseUrl + path;
        window.location.href = finalUrl;
    }

    resetLoginState() {
        this.identifier = '';
        this.password = '';
        this.email = '';
        this.validationErrors = {};
        this.showErrorMessage = false;
        this.errorMessage = '';
        this.token = null;
    }


}