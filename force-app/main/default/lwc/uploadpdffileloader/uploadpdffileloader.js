import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Uploadpdffileloader extends LightningElement {
  
    handleSSOLogin() {
        console.log('handlesso');
        // Azure AD SSO URL with RelayState pointing to your Salesforce org
        const ssoUrl = 'https://ngmetering--cprtaldev.sandbox.my.site.com/PocNGMeteringvforcesite/login?so=00Ddu00000AGhkn';
        console.log('ssourl'+ssoUrl);
        window.location.href = ssoUrl;
    }
           

}