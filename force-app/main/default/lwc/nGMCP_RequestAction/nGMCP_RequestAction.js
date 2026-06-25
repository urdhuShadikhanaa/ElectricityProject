import { LightningElement, api, track, wire } from "lwc";
import { getRecord } from 'lightning/uiRecordApi';
import REQUEST_TYPE from '@salesforce/schema/NGMCP_Request__c.RecordType.Name';
import STATUS from '@salesforce/schema/NGMCP_Request__c.NGMCP_Callout_Status__c';
import callMaximoADIAPI from "@salesforce/apex/NGMCP_RequestController.callMaximoADIAPI";
import callMaximoReopenAPI from "@salesforce/apex/NGMCP_RequestController.callMaximoReopenAPI";
import getRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.getRequest";
import USER_ID from '@salesforce/user/Id';
const FIELDS = ['User.Email', 'User.Name'];
export default class nGMCP_RequestAction extends LightningElement {
  @api recordId;
  @api status;
  @api requestType;
  @track isModalOpen = false;
  @track modalHeader = "";
  @track comments = "";
  actionType = "";
  @track request = {};
  userId = USER_ID;
  @track user = {name: '',email: ''};

  @wire(getRecord, { recordId: '$recordId', fields: [REQUEST_TYPE, STATUS] })
  recordHandler({ data }) {
   if (data) {
       this.requestType = data.fields.Request_Type__c.value;
       this.status = data.fields.Status__c.value;
   }
  }
  @wire(getRecord, { recordId: '$userId', fields: FIELDS })
        userRecord({ error, data }) {
            if (data) {
                this.user = data.fields;
            }
        }
  
  connectedCallback(){

        getRequest({requestid: this.recordId})
            .then(result => {
                this.request = result;
            })
            .catch(error => {
                
            });
    }

  get showProvideAdditionalButton() {
    return (
      (this.requestType === "Data Queries" ||
        this.requestType === "Technical Queries") &&
      this.status === "Additional Information Required"
    );
  }
  get showReopenQueryButton() {
    return (
      (this.requestType === "Data Queries" ||
        this.requestType === "Technical Queries") &&
      this.status === "Resolved"
    );
  }
  openAdditionalInfoModal() {
    this.modalHeader = "Provide Additional Information";
    this.actionType = "ADI";
    this.isModalOpen = true;
  }
  openReopenModal() {
    this.modalHeader = "Reopen Query";
    this.actionType = "REOPEN";
    this.isModalOpen = true;
  }
  handleComments(event) {
    this.comments = event.target.value;
  }
  closeModal() {
    this.isModalOpen = false;
  }
  handleSubmit() {
    if (this.modalHeader == "Reopen Query") {
      const payload = {
                    ticketuid : this.request.NGMCP_Ticketuid__c,
                    ticketid: this.request.NGMCP_SR_Ticket__c,
                    ngme_time:'',
                    target1start: '',
                    action: 'RESUBMIT',
                    reason: this.comments
               }
        callMaximoReopenAPI({requestBody: JSON.stringify(payload), requestId: this.requestid,
            ticketuid: this.request.NGMCP_Ticketuid__c
        })
            .then(result => {
            })
            .catch(error => {
            });
    }
    else{
         const payload = {
                    ticketuid : this.request.NGMCP_Ticketuid__c,
                    ticketid: this.request.NGMCP_SR_Ticket__c
               }
        const worklog = {
                    logtype : 'answer',
                    createby : this.user.name,
                    recordkey: this.request.NGMCP_SR_Ticket__c,
                    class:'SR',
                    language:'EN',
                    description_longdescription:this.comments
        }
        payload.worklog = worklog;
        callMaximoADIAPI({requestBody: JSON.stringify(payload), requestId: this.requestid,
            ticketuid: this.request.NGMCP_Ticketuid__c
        })
            .then(result => {
            })
            .catch(error => {
            });
    }
  //   updateRecordAndCallAPI({
  //     recordId: this.recordId,
  //     comments: this.comments,
  //     actionType: this.actionType,
  //   })
  //     .then(() => {
  //       this.isModalOpen = false;
  //       location.reload();
  //     })
  //     .catch((err) => {
  //       console.error(err);
  //     });
   }
}