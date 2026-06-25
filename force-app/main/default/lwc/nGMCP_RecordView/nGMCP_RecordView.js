import { LightningElement, api, wire, track } from 'lwc';
// Apex – your existing method
import getSectionedFieldData from '@salesforce/apex/NGMCP_ViewMapController.getSectionedFieldData';
// UI Record API fields
import STATUS_FIELD from '@salesforce/schema/NGMCP_Request__c.NGMCP_Callout_Status__c';
import submitCancelJob from "@salesforce/apex/NGMCP_ReplanCancelHandler.submitCancelJob";
import submitAcceptRejectQuotation from "@salesforce/apex/NGMCP_ReplanCancelHandler.submitAcceptRejectQuotation";
import uploadAndLinkFileToRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.uploadAndLinkFileToRequest";
import RECORDTYPE_NAME_FIELD from '@salesforce/schema/NGMCP_Request__c.RecordType.Name';
import getRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.getRequest";
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import getHolidays from '@salesforce/apex/NGMCP_HolidaysService.getHolidaysBetween';
import USER_ID from '@salesforce/user/Id';
const USER_FIELDS = ['User.Email'];
import updateNSRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.updateNSRequest";
const FIELDS = [STATUS_FIELD, RECORDTYPE_NAME_FIELD];
export default class NGMCP_RecordView extends LightningElement {

    @track isReplanModalOpen = false;
        @track isCancelModalOpen = false;
        //@track replanCancelFlag = false;
        // ticketid;
        // ticketuid;
        action;
        requestid;
        request;
        status;
        selectedSlot = '';
        selectedDate = '';
        appointmentOptions = [];
        holidays = [];
        userId = USER_ID;
        email;
        reason = '';
         @api recordId; // will be injected when used on record page
        cards = [];
        error;
        stat;               // status value from record
        recordTypeName;     // record type name
        showReplan = false;
        showCancel = false;
        showCompletion = false;
        //mainFlag = true;
        appointmentDateError = 'Please select a date';
        appointmentSlotError = 'Please select a slot';
        reasonError = 'Please enter a reason';
        @track dateFlag = false;
        @track slotFlag = false;
        @track reasonFlag = false;
        @track acceptRejectFlag = false;
        quotationStatus='';
        commentError = 'Please enter comment to proceed';
        comment = '';
        @track commentFlag = false;
        @track isAccept = false;
        acceptedFormats = ['.pdf', '.png', '.jpg', '.docx', '.xlsx'];
        @track cancelChargeFlag = false;
        @track filesToUpload = [];
    
        residentialSlots = [{
       code: 'S1',
       timeframe: '08:00 - 11:00'
    }, {
       code: 'S2',
       timeframe: '10:00 - 13:00'
    }, {
       code: 'S3',
       timeframe: '12:00 - 15:00'
    }, {
       code: 'S4',
       timeframe: '14:00 - 17:00'
    }, {
       code: 'S5',
       timeframe: '16:00 - 19:00'
    }, {
       code: 'S6',
       timeframe: '18:00 - 21:00'
    }];
    
    commercialSlots = [{
       code: 'S1',
       timeframe: '08:00 - 12:00'
    }, {
       code: 'S2',
       timeframe: '10:00 - 14:00'
    }, {
       code: 'S3',
       timeframe: '12:00 - 16:00'
    }, {
       code: 'S4',
       timeframe: '14:00 - 18:00'
    }, {
       code: 'S5',
       timeframe: '16:00 - 20:00'
    }];
    
    
    // --- Residential (Weekday) Slots ---
        residentialWeekdaySlots = [
            { label: '08:00 - 11:00', value: 'S1' },
            { label: '10:00 - 13:00', value: 'S2' },
            { label: '12:00 - 15:00', value: 'S3' },
            { label: '14:00 - 17:00', value: 'S4' },
            { label: '16:00 - 19:00', value: 'S5' },
            { label: '18:00 - 21:00', value: 'S6' }
        ];
    
        // --- Commercial & Residential (Weekend / Holiday) Slots ---
        commercialAndWeekendSlots = [
            { label: '08:00 - 12:00', value: 'S1' },
            { label: '10:00 - 14:00', value: 'S2' },
            { label: '12:00 - 16:00', value: 'S3' },
            { label: '14:00 - 18:00', value: 'S4' },
            { label: '16:00 - 20:00', value: 'S5' } 
        ];
    
        @wire(getRecord, { recordId: '$userId', fields: FIELDS })
            userRecord({ error, data }) {
                if (data) {
                    this.email = data.fields.Email.value;
                }
            }
        
        handleReplanCancelJob(){
            this.replanCancelFlag = true;
            //this.mainFlag = false;
        }
        handleCancelJob() {
            this.isCancelModalOpen = true;
            this.isReplanModalOpen = false;
            this.action = 'CANCELLED';
                        
            
        }
    
        handleReplanJob() {
            this.isReplanModalOpen = true;
            this.isCancelModalOpen = false;
            this.action = 'REPLAN';
        
        }
    
        closeCancelModal(){
            this.isCancelModalOpen = false;
            this.reason = '';
            this.dateFlag = false;
            this.slotFlag = false;
            this.reasonFlag = false;
        }
        closeReplanModal(){
            this.isReplanModalOpen = false;
            this.selectedDate = '';
            this.selectedSlot = '';
            this.reason = '';
            this.dateFlag = false;
            this.slotFlag = false;
            this.reasonFlag = false;
        }
    
        connectedCallback(){
            // this.ticketid = '1966006';
            // this.ticketuid = '3242094'
            this.status = 'Commercial';
            this.requestid = 'a5Bdu0000008so1EAA';
            getRequest({requestid: this.requestid})
                .then(result => {
                    this.request = result;
                })
                .catch(error => {
                    
                });
        }
    
        handleYes() {
       
            if(this.action == 'REPLAN' && (this.selectedDate == '' || this.selectedDate == null || this.selectedDate == undefined)){
                this.dateFlag = true;
            }else{
                this.dateFlag = false;
            }
             if(this.action == 'REPLAN' && (this.selectedSlot == '' || this.selectedSlot == null || this.selectedSlot == undefined)){
                this.slotFlag = true;
            }else{
                this.slotFlag = false;
            }
            if(this.reason == '' || this.reason == null || this.reason == undefined){
                this.reasonFlag = true;
            }else{
                this.reasonFlag = false;
            }
            if((this.action == 'CANCELLED' && !this.reasonFlag) ||
                (this.action == 'REPLAN' && !this.reasonFlag && !this.dateFlag && !this.slotFlag)){
       
            
    
            const payload = {
                ticketuid: this.request.NGMCP_Ticketuid__c,
                ticketid: this.request.NGMCP_SR_Ticket__c,
                ngme_time: this.selectedSlot,
                target1start: this.selectedDate,
                action: this.action,
                reason: this.reason
            };
            if(this.request.NGMCP_Non_Standard__c){
                updateNSRequest({requestBody: JSON.stringify(payload), requestId: this.requestid,
                ticketuid: this.request.NGMCP_Ticketuid__c, reportedEmail : this.email})
                .then(result => {
                    this.isCancelModalOpen = false;
                    this.isReplanModalOpen = false;
                    this.selectedDate = '';
                    this.selectedSlot = '';
                    this.reason = '';
                    this.dateFlag = false;
                    this.slotFlag = false;
                    this.reasonFlag = false;
                    if(this.action == 'CANCELLED'){
                        alert('Job cancelled successfully')
                    }else{
                        alert('Job replanned successfully')
                    }
                    
                })
                .catch(error => {
                });    
            }
            else{
            submitCancelJob({requestBody: JSON.stringify(payload), requestId: this.requestid,
                ticketuid: this.request.NGMCP_Ticketuid__c, reportedEmail : this.email
            })
                .then(result => {
                    this.isCancelModalOpen = false;
                    this.isReplanModalOpen = false;
                    this.selectedDate = '';
                    this.selectedSlot = '';
                    this.reason = '';
                    this.dateFlag = false;
                    this.slotFlag = false;
                    this.reasonFlag = false;
                    if(this.action == 'CANCELLED'){
                        alert('Job cancelled successfully')
                    }else{
                        alert('Job replanned successfully')
                    }
                    
                })
                .catch(error => {
                    alert('Error: ' + error.body.message);
                });
            }
            }
        }
    
        handleSlotChange(event) {
            this.selectedSlot = this.status == 'Commercial' ? this.handleCommercialTime(event.detail.value) : this.handleResidentialTime(event.detail.value);
            this.slotFlag = false;
        }
    
    
      handleDateChange(event) {
            this.dateFlag = false;
            const selectedDate = event.detail.date;
            this.selectedDate = selectedDate;
            this.updateAppointmentSlots();
        }
    
        updateAppointmentSlots() {
    
            // Check that both status and date are available
            if (!this.selectedDate || !this.status) {
                this.appointmentOptions = [];
                return;
            }
    
            const statusLower = this.status.toLowerCase();
            const selected = new Date(this.selectedDate);
            const day = selected.getDay(); // 0 = Sunday, 6 = Saturday
            const isWeekend = (day === 0 || day === 6);
    
            // Normalize date formats for holiday comparison
            const selectedDateOnly = selected.toISOString().split('T')[0];
            const isHoliday = this.holidays.some(h => h === selectedDateOnly);
    
            // --- Main Logic ---
            if (statusLower === 'residential') {
                if (!isWeekend && !isHoliday) {
                    this.appointmentOptions = this.residentialWeekdaySlots;
                } else {
                    this.appointmentOptions = this.commercialAndWeekendSlots;
                }
            } else if (statusLower === 'commercial') {
                this.appointmentOptions = this.commercialAndWeekendSlots;
            } else {
                this.appointmentOptions = [];
            }
        }
    
        @wire(getHolidays)
        wiredHolidays({ data, error }) {
            if (data) {
            } else if (error) {
            }
        }
    
        handleInputChange(event){
            this.reason = event.target.value;
            if(this.reason == null || this.reason == '' || this.reason == undefined){
                this.reasonFlag = true;
            }else{
                this.reasonFlag = false;
            }
        }
    
        handleAcceptQuotation(event){
            this.quotationStatus = event.target.name;
            this.acceptRejectFlag = true;
            if(event.target.name == 'Accept'){
                this.isAccept = true;
            }else{
                this.isAccept = false;
            }
        }
    
        closeAcceptRejectModal(){
            this.acceptRejectFlag = false;
            this.comment = '';
            this.commentFlag = false;
        }
    
        handleComment(event){
            this.comment = event.target.value;
            if(this.comment == null || this.comment == '' || this.comment == undefined){
                this.commentFlag = true;
            }else{
                this.commentFlag = false;
            }
        }
    
        handleQuotation(){
            if(this.comment == null || this.comment == '' || this.comment == undefined){
                this.commentFlag = true;
            }else{
                this.commentFlag = false;
                const payload = {
    
                    ticketid: '1380428',
                    status: this.quotationStatus == 'Accept' ? 'ACCEPTED' : 'REJECTED',
                    comment: this.comment
                };
                submitAcceptRejectQuotation({requestBody: JSON.stringify(payload), 
                    requestId: this.requestid, 
                })
                .then(result => {
                    this.acceptRejectFlag = false;
                    this.comment = '';
                    this.commentFlag = false;
                    
                    alert('Quotation ' + payload.status.toLowerCase() + ' successfully')
                })
                .catch(error => {
                    alert('Error: ' + error.body.message);
                });
            }
        }
    
        handleCommercialTime(slot){
           let message = '';
           switch (slot) {
            case 'S1':
                message = '08:00 - 12:00'
                break;
            case 'S2':
                message = '10:00 - 14:00'
                break;
            case 'S3':
                message = '12:00 - 16:00'
                break;
            case 'S4':
                message = '14:00 - 18:00'
                break;
            case 'S5':
                message = '16:00 - 20:00'
                break;  
            default:
                break;
           }
        return message;
        }
    
        handleResidentialTime(slot){
           let message = '';
           switch (slot) {
            case 'S1':
                message = '08:00 - 11:00'
                break;
            case 'S2':
                message = '10:00 - 13:00'
                break;
            case 'S3':
                message = '12:00 - 15:00'
                break;
            case 'S4':
                message = '14:00 - 17:00'
                break;
            case 'S5':
                message = '16:00 - 19:00'
                break;
            case 'S6':
                message = '18:00 - 21:00'
                break;       
            default:
                break;
           }
        return message;
        }
    
        handleUploadFinished(event) {
            // Get the list of uploaded files
            const uploadedFiles = event.detail.files;
        }
    
        handleCancel(){
            if(this.reason == '' || this.reason == null || this.reason == undefined){
                this.reasonFlag = true;
            }else{
                this.reasonFlag = false;
                const twoDaysLaterISO = new Date();
                twoDaysLaterISO.setDate(twoDaysLaterISO.getDate() + 2);
                const formatted = twoDaysLaterISO.toISOString().slice(0, 10); 
                if(this.request.NGMCP_Target_Start__c < formatted && this.request.NGMCP_Job_SubType__c == 'Adversarial Removal'){
                    this.cancelChargeFlag = true
                }else{
                    this.cancelChargeFlag = false
                    this.handleYes();
                }
            }
        }
    
        async handleFileChange(event) {
            this.filesToUpload = [...event.target.files];
            if (!this.requestid) {
                alert('Request Id is missing.');
                return;
            }
            try {
                const results = [];
                for (const file of this.filesToUpload) {
                    const base64 = await this.readFileAsBase64(file);
                    const docId = await uploadAndLinkFileToRequest({
                        requestId: this.requestid,
                        fileName: file.name,
                        base64Data: base64
                    });
                    results.push({ name: file.name, documentId: docId });
                }
                this.filesToUpload = [];
            } catch (e) {
            }
        }
    
        readFileAsBase64(file) {
            return new Promise((resolve, reject) => {
                const reader = new FileReader();
                reader.onload = () => {
                    // Data URL -> strip the prefix (e.g., "data:application/pdf;base64,")
                    const base64 = reader.result.split(',')[1];
                    resolve(base64);
                };
                reader.onerror = reject;
                reader.readAsDataURL(file);
            });
        }
    
           showToast(title, message, variant) {
            this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
        }

    // ---------- 1. your sectioned field data from Apex ----------

    @wire(getSectionedFieldData, { recordId: 'a5Bdu0000008so1EAA' })
    wiredData({ error, data }) {
        if (data) {
            this.cards = data;
            this.error = undefined;

        } else if (error) {
            this.error = error;
            this.cards = [];

        }

    }

    // ---------- 2. get Status + RecordType using uiRecordApi ----------

    @wire(getRecord, { recordId: 'a5Bdu0000008so1EAA', fields: FIELDS })

    wiredRecord({ error, data }) {

        if (data) {
            this.stat = getFieldValue(data, STATUS_FIELD);
            this.recordTypeName = getFieldValue(data, RECORDTYPE_NAME_FIELD);
            this.setButtonVisibility();
        } else if (error) {
            this.error = error;
        }
    }

    // ---------- 3. button-visibility logic ----------
    setButtonVisibility() {
        const status = this.stat || '';
        // Replan + Cancel when status = In Progress / New
        const isNewOrInProgress =
            status === 'In Progress' || status === 'New' ;
        // Completion Details when status = Complete / Further Work
        const isCompleteOrFurtherWork =
            status === 'Complete' || status === 'Further Work';
        this.showReplan = isNewOrInProgress;
        this.showCancel = isNewOrInProgress;
        this.showCompletion = isCompleteOrFurtherWork ;
    }

}