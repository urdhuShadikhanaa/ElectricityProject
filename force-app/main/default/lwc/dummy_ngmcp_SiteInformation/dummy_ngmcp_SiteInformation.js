import { LightningElement, api, track } from 'lwc';
import getWorkOrderDetails from '@salesforce/apex/NGMCPSiteInformationController.getWorkOrderDetails';
import updateSiteDetails from '@salesforce/apex/NGMCPSiteInformationController.updateSiteDetails';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class NgmcpSiteContact extends LightningElement {
   @api recordId;
   @track siteId;
   @track title = '';
   @track nameVal = '';
   @track phone = '';
   @track access = '';
   @track showActionButton = false;
   @track showFormModal = false;
   @track showPopup = false;
   @track popupTitle = '';
   @track popupMessage = '';
   closeOnOk = false;
   connectedCallback() {
       this.loadDetails();
   }
   loadDetails() {
       getWorkOrderDetails({ recordId: this.recordId })
       .then(res => {
           this.siteId = res.siteId;
           this.title = res.title;
           this.nameVal = res.name;
           this.phone = res.phone;
           this.access = res.access;
           // show button only if flag = Yes
           this.showActionButton = (res.flag === 'Yes');
       })
       .catch(err => {
           console.error(err);
           this.showErrorPopup('Unable to load Work Order details.');
       });
   }
   openFormModal() {
       this.showFormModal = true;
   }
   closeFormModal() {
       this.showFormModal = false;
   }
   handleChange(e) {
       const field = e.target.dataset.field;
       if (field === 'title') this.title = e.target.value;
       if (field === 'name') this.nameVal = e.target.value;
       if (field === 'phone') this.phone = e.target.value;
       if (field === 'access') this.access = e.target.value;
   }
   validate() {
       let valid = true;
       this.template.querySelectorAll('lightning-input, lightning-textarea')
           .forEach(i => { if (!i.reportValidity()) valid = false; });
       return valid;
   }
   

async handleSubmit() {
    if (!this.validate()) return;

    const wrapper = {
        workOrderId: this.recordId,   // ensure this.recordId is set
        siteId: this.siteId,          // ensure this.siteId is set
        title: this.title,
        name: this.nameVal,
        phone: this.phone,
        access: this.access
    };
    console.log('wrapper', JSON.stringify(wrapper));

    try {
        const res = await updateSiteDetails({ input: JSON.stringify(wrapper) }); // <-- critical
        if (res === 'SUCCESS') {
            this.showSuccessPopup('Success', 'Site contact details updated.');
            this.showFormModal = false;
            this.loadDetails();
        } else {
            this.showErrorPopup('Unexpected response from server.');
        }
    } catch (error) {
        console.error(error);
        const msg =
            (error && error.body && error.body.message) ? error.body.message :
            (error && error.message) ? error.message :
            'Failed to update Site record.';
        this.showErrorPopup(msg);
    }
}


   showSuccessPopup(title, msg) {
       this.popupTitle = title;
       this.popupMessage = msg;
       this.closeOnOk = true;
       this.showPopup = true;
   }
   showErrorPopup(msg) {
       this.popupTitle = 'Error';
       this.popupMessage = msg;
       this.closeOnOk = false;
       this.showPopup = true;
   }
   closePopup() {
       this.showPopup = false;
       if (this.closeOnOk) {
           this.dispatchEvent(new CloseActionScreenEvent());
       }
   }
}