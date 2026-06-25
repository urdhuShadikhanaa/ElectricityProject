import { LightningElement,track } from 'lwc';
// import login from '@salesforce/apex/NGMCP_LoginController.login';
import { NavigationMixin } from 'lightning/navigation';
import ResetPasswordUrl from '@salesforce/label/c.NGMCP_Restpasswordurl';
import NGMSSOPortalURL from '@salesforce/label/c.NGMCP_SSOPortalURL';
import loginBackground from '@salesforce/resourceUrl/National_Gas_Login_Banner_Img1';
// import initiateLogin from "@salesforce/apex/NGMCPPasswordlessLogin.initiateLogin";
// import verifyPasswordlessLogin from "@salesforce/apex/NGMCPPasswordlessLogin.verifyPasswordlessLogin";
import communityPath from '@salesforce/label/c.NGMCP_CommunityPath';

export default class ngmLoginForm extends NavigationMixin(LightningElement) {
    @track username = '';
    @track password = '';
    @track otp = '';
    @track showOtpScreen = false;
    @track otpError = '';
    @track loginError = '';
    @track email = '';
    @track code = '';
    @track identifier;
    @track showVerification = false;
    @track errorMessage;

    // rPasswordURL = ResetPasswordUrl;
    rPasswordURL;
    ssoURL = NGMSSOPortalURL;
    //@track ssoUrl = 'https://ngmetering--cprtaldev.sandbox.my.site.com/PocNGMeteringvforcesite/login?so=00Ddu00000AGhkn';
    backgroundStyle = loginBackground;

    @track loginOption = 'Email';
    @track email = '';
    @track phone = '';
    @track identifier ='';
    @track authorizationMethod = '';
    @track token = '';
    @track otp = '';
    showErrorMessage = false;
    errorMessage = '';
    otpPage = false;
    disableVerifyButton = false;
       

    connectedCallback(){

            let path = communityPath;

        if (!path.startsWith('/')) {
            path = '/' + path;
        }
        this.rPasswordURL = path + 'ForgotPassword';
    }
    handleUsernameChange(event) {
        this.username = event.target.value;        
    }

    // handleIdentifier(event) {
    //     this.identifier = event.target.value;
    //     this.email = event.target.value;
    //     console.log('getting Identifier value -> ', this.identifier);
    //     console.log('getting Identifier value -> ', this.email);

    // } 

    handlePasswordChange(event) {
        this.password = event.target.value;
    }

     handleEmailChange(event) {
        this.email = event.target.value;
    }

    handleCodeChange(event) {
        this.code = event.target.value;
    }

    // handleSendOtp() {
    //     console.log(' this.identifier  in handlesendOTP>>',  this.identifier);
    //     console.log('email  value -> ', this.email);
    //     this.authorizationMethod = 'Email';
    //     console.log('authorizationMethod  value -> ', this.authorizationMethod);

    //     initiateLogin({
    //         identifier : this.identifier,
    //         authorizationMethod : this.authorizationMethod
    //     })
    //     .then(result => {
    //             console.log('Result -> ', result);
    //             this.token = result;
    //             let tokenRegex = /^[A-Za-z0-9]{20}$/;
                
    //             if (this.token && this.token.match(tokenRegex)) {
    //                 console.log('Valid token!');
    //                 this.otpPage = true;
    //             } else if(result.includes('Email Sent , please click on link to enable passwordless login.')) {
    //                 this.clearErrorMessages();
    //                 this.showErrorMessage = true;
    //                 this.errorMessage = 'Email Sent , please click on link received in the email to enable passwordless login.'
    //             } else{
    //                 this.clearErrorMessages();
    //                 this.showErrorMessage = true;
    //                 this.errorMessage = 'Some Error Occurred , Please try again later.'
    //                 console.log('Invalid token!');
    //             }
    //         })
    //         .catch(error => {
    //             console.error('error -> ', error);
    //         });
    // }

    // handleVerifyOtp() {
    //     verifyPasswordlessLogin({
    //         identifier : this.identifier, 
    //         otp : this.otp, 
    //         authorizationMethod : this.authorizationMethod, 
    //         token : this.token
    //     })
    //     .then(result => {
    //         console.log('Result -> ', result);
    //         console.log('identifier verifyPasswordlessLogin-> ', this.identifier);
    //         console.log('otp verifyPasswordlessLogin-> ', this.otp);
    //         console.log('token verifyPasswordlessLogin-> ', this.token);
    //         console.log('authorizationMethod verifyPasswordlessLogin-> ', this.authorizationMethod);
            
            
    //         if(result.includes('https')){
    //             console.log('Verification successful');
    //             window.location.href = result;
    //         } else if(result.includes('Invalid verification code')) {
    //             this.clearErrorMessages();
    //             this.showErrorMessage = true;
    //             this.errorMessage = 'Invalid code, please try again.';
    //             this.disableVerifyButton = true;
    //         } else if(result.includes('Too many attempts')) {
    //             this.clearErrorMessages();
    //             this.showErrorMessage = true;
    //             this.errorMessage = 'Too many attempts, please use resend button and try again.';
    //             this.disableVerifyButton = true;
    //         } else {
    //             this.clearErrorMessages();
    //             this.showErrorMessage = true;
    //             this.errorMessage = 'Some Error Occurred , Please contact your System Administrator.';
    //             console.log('Verification failed');
    //         }
    //     }).catch(error => {
    //         console.error('error -> ', error);
    //     });
    // }

    // backButton() {
    //     this.otpPage = false;
    // }

    // clearErrorMessages() {
    //     this.errorMessage = '';
    // }

}