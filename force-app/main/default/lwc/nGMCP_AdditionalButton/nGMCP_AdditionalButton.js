import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
const WO_FIELDS = [ 'WorkOrder.NGMCP_Site_contact_details__c','WorkOrder.FFA_SiteID__c'];
export default class ngmcp_AdditionalButtons extends LightningElement {
   @api recordId = '0WOdu000002hfYDGAY';
   siteId;
   showFormModal = false;
   showPopup = false;
   popupTitle = '';
   popupMessage = '';
   closeOnOk = false;
   // Fetch Work Order → get SiteId
   @wire(getRecord, { recordId: '$recordId', fields: WO_FIELDS })
   wiredWO({ data }) {
       if (data) this.siteId = data.fields.FFA_SiteID__c.value;
   }
   // Open the form modal
   openFormModal() {
       this.showFormModal = true;
   }
   // Close form modal
   closeFormModal() {
       this.dispatchEvent(new CloseActionScreenEvent());
   }
   validate() {
       let valid = true;
       this.template.querySelectorAll('lightning-input, lightning-textarea')
           .forEach(input => {
               if (!input.reportValidity()) valid = false;
           });
       return valid;
   }
   async handleSubmit() {
       if (!this.validate()) return;
       Console.log('validate', this.validate);
       Console.log('title', this.siteId);
       if (!this.siteId) {
           this.showErrorPopup('Work Order has no linked Site.');
           return;
       }
       const titleVal = this.template.querySelector('[data-field="title"]').value;
       Console.log('title', titleVal);
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
           await updateRecord({
               fields: {
                   Id: this.recordId,
                   NGMCP_Site_contact_details__c : 'No'
               }
           });
           this.showSuccessPopup(
               'Success',
               'Site contact details updated.'
           );
       } catch (error) {
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