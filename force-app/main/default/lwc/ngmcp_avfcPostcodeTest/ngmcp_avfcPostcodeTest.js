import { LightningElement, track } from 'lwc';
export default class Ngmcp_avfcPostcodeTest extends LightningElement {
   countryValue = '';
    stateValue = '';
    postalCodeValue = '';
    cityValue = '';
    streetValue = '';
    street2Value = '';
    countyValue = '';
    statusValue = '';

    // Stores the verified address returned by the AVFC
    @track verifiedAddress = {};

    handleAddressChange(event) {
        // The AVFC fires an 'addresschange' event.
        // The verified address is available at event.detail["address"].
        this.verifiedAddress = event.detail["address"];

        // From here, do whatever your use case requires:
        // - Save to a record via Apex
        // - Dispatch a custom event to a parent component
        // - Update reactive properties for display
        console.log('Verified address:', JSON.stringify(this.verifiedAddress));
    }
}