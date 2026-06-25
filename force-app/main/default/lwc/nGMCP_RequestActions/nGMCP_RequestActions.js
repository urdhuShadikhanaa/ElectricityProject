import { LightningElement, api, track } from 'lwc';
import updateRecordAndCallAPI from '@salesforce/apex/NGMCP_RequestController.updateStatusAndCallAPI';
export default class nGMCP_RequestActions extends LightningElement {
   @api recordId;
   @api status;
   @api requestType;
   @track isModalOpen = false;
   @track modalHeader = '';
   @track comments = '';
   actionType = '';
   get showProvideAdditionalButton() {
       return (
           (this.requestType === 'Data Queries' || this.requestType === 'Technical Queries') &&
           this.status === 'Additional Information Required'
       );
   }
   get showReopenQueryButton() {
       return (
           (this.requestType === 'Data Queries' || this.requestType === 'Technical Queries') &&
           this.status === 'Resolved'
       );
   }
   openAdditionalInfoModal() {
       this.modalHeader = 'Provide Additional Information';
       this.actionType = 'ADI';
       this.isModalOpen = true;
   }
   openReopenModal() {
       this.modalHeader = 'Reopen Query';
       this.actionType = 'REOPEN';
       this.isModalOpen = true;
   }
   handleComments(event) {
       this.comments = event.target.value;
   }
   closeModal() {
       this.isModalOpen = false;
   }
   handleSubmit() {
       if(!this.comments){
           alert('Comments are mandatory');
           return;
       }
       updateRecordAndCallAPI({
           recordId: this.recordId,
           comments: this.comments,
           actionType: this.actionType
       })
       .then(() => {
           this.isModalOpen = false;
           location.reload();
       })
       .catch(err => {
           console.error(err);
       });
   }
}