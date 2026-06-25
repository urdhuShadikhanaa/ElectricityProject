import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
const WO_FIELDS = [ 'WorkOrder.NGMCP_Site_contact_details__c','WorkOrder.Site__c','WorkOrder.FFA_SiteID__c'];
export default class ngmcp_Siteinformation extends LightningElement {
   @api recordId = '0WOdu000002hfYDGAY';
   siteId;
   showActionButton = false;  // FIRST render condition
   showFormModal = false;
   showPopup = false;
   popupTitle = '';
   popupMessage = '';
   closeOnOk = false;
   //flag ;
  
   // Fetch Work Order → get SiteId

   @wire(getRecord, { recordId: '$recordId', fields: WO_FIELDS })
   wiredWO({ data }) {
    console.log('record',this.recordId);
        if (data) {
            const flag = data.fields.NGMCP_Site_contact_details__c.value;
            console.log('flag:', flag);
            this.siteId = data.fields.Site__c.value;
            console.log('siteId:', this.siteId);
            // Show button only when the flag is TRUE
            this.showActionButton = true;
            console.log('recordID:', this.recordId);
        }
   }
   
   // Open the form modal
   openFormModal() {
       this.showFormModal = true;
   }
   // Close form modal
   closeFormModal() {
       //this.dispatchEvent(new CloseActionScreenEvent());
       this.showFormModal = false;
   }
   validate() {
       let valid = true;
       this.template.querySelectorAll('lightning-input, lightning-textarea')
           .forEach(input => {
               if (!input.reportValidity()) valid = false;
           });
       return valid;
   }

//    showErrorPopup(msg) {
//        this.popupTitle = 'Error';
//        this.popupMessage = msg;
//        this.closeOnOk = false;
//    }

   async handleSubmit() {
    console.log('handleSubmit');
    console.log('this.validate()',this.validate());
      if (!this.validate()){
        return;
       } 
       console.log('validate', this.validate());
       console.log('title', this.siteId);
       if (!this.siteId) {
           this.showErrorPopup('Work Order has no linked Site.');
           return;
       }
       const titleVal = this.template.querySelector('[data-field="title"]').value;
       console.log('title', titleVal);
       const nameVal = this.template.querySelector('[data-field="name"]').value;
       const phoneVal = this.template.querySelector('[data-field="phone"]').value;
       const accessVal = this.template.querySelector('[data-field="access"]').value;
       try {
           await updateRecord({
               fields: {
                Id: this.siteId,
                FFA_Title__c: titleVal,
                Name: nameVal,
                FFA_ContactTelephoneNumber__c: phoneVal,
                FFA_AccessInstructions__c: accessVal
               }
           });
           console.log('recordupdate',this.NGMCP_Site_contact_details__c);
           await updateRecord({
               fields: {
                   Id: this.recordId,
                   NGMCP_Site_contact_details__c : 'No'
               }
           });
            console.log('recordupdate',this.NGMCP_Site_contact_details__c);
           this.showSuccessPopup(
               'Success',
               'Site contact details updated.'
           );
       } catch (error) {
        console.log(error.message);
           this.showErrorPopup('Update failed.');
       }
   }
   // Popup Methods
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