import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitCancelJob from "@salesforce/apex/NGMCP_ReplanCancelHandler.submitCancelJob";
import submitAcceptRejectQuotation from "@salesforce/apex/NGMCP_ReplanCancelHandler.submitAcceptRejectQuotation";
import getRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.getRequest";
import getHolidays from '@salesforce/apex/NGMCP_HolidaysService.getHolidaysBetween';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
const FIELDS = ['User.Email'];
import updateNSRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.updateNSRequest";
import uploadAndLinkFileToRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.uploadAndLinkFileToRequest";
export default class ReplanCancel extends LightningElement {

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
        this.requestid = 'a5Bdu000000ALROEA4';
        getRequest({requestid: this.requestid})
            .then(result => {
                this.request = result;
                console.log('request: ' , this.request);
            })
            .catch(error => {
                
            });
    }

    handleYes() {
        console.log('handleYes triggered!');
        console.log('this.action:', this.action);
        console.log('this.selectedDate:', this.selectedDate);
        console.log('this.selectedSlot:', this.selectedSlot);
        console.log('this.reason:', this.reason);
   
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
        console.log('this.dateFlag:', this.dateFlag);
        console.log('this.slotFlag:', this.slotFlag);
        console.log('this.reasonFlag:', this.reasonFlag);
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
        console.log('Payload submitted:', JSON.stringify(payload)); 
        if(this.request.NGMCP_Non_Standard__c){
            console.log('updateNSRequest ');
            updateNSRequest({requestBody: JSON.stringify(payload), requestId: this.requestid,
            ticketuid: this.request.NGMCP_Ticketuid__c, reportedEmail : this.email})
            .then(result => {
                console.log('result: ', result);
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
                console.log('error: ', JSON.stringify(error));
                alert('Error: ' + error);
            });    
        }
        else{
            console.log('submitCancelJob ');
        submitCancelJob({requestBody: JSON.stringify(payload), requestId: this.requestid,
            ticketuid: this.request.NGMCP_Ticketuid__c, reportedEmail : this.email
        })
            .then(result => {
                console.log('result: ', result);
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
                console.log('error: ', JSON.stringify(error));
                alert('Error: ' + error.body.message);
            });
        }
        }
    }

    handleSlotChange(event) {
        console.log('event.detail.value:', event.detail.value);
        this.selectedSlot = this.status == 'Commercial' ? this.handleCommercialTime(event.detail.value) : this.handleResidentialTime(event.detail.value);
        console.log('selectedSlot:', this.selectedSlot);
        this.slotFlag = false;
    }


  handleDateChange(event) {
        console.log('handleDateChange triggered!');
        this.dateFlag = false;
        const selectedDate = event.detail.date;
        console.log('Selected date from child:', selectedDate);
        this.selectedDate = selectedDate;
        console.log('this.selectedDate:', this.selectedDate);
        console.log('typeof this.updateAppointmentSlots:', typeof this.updateAppointmentSlots);
        console.log('About to call updateAppointmentSlots...');
        this.updateAppointmentSlots();
    }

    updateAppointmentSlots() {
    console.log('updateAppointmentSlots actually running now.');
    console.log('this.status:', this.status);

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

        console.log('Status:', statusLower);
        console.log('Selected Date:', selectedDateOnly);
        console.log('Is Weekend:', isWeekend);
        console.log('Is Holiday:', isHoliday);

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

        console.log('Rendered Slots:', JSON.stringify(this.appointmentOptions));
    }

    @wire(getHolidays)
    wiredHolidays({ data, error }) {
        if (data) {
            console.log('Raw Holidays:', data);
            
            console.log('Holidays:', JSON.stringify(data));
           //this.holidays = data.map(h => h.ActivityDate.split('T')[0]);
            console.log('Normalized Holidays:', this.holidays);
        } else if (error) {
            console.error('Error fetching holidays:', error);
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
        console.log('this.quotationStatus: ',this.quotationStatus);
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
        console.log('comment: ', this.comment);
        if(this.comment == null || this.comment == '' || this.comment == undefined){
            this.commentFlag = true;
        }else{
            this.commentFlag = false;
        }
    }

    handleQuotation(){
        console.log('handleQuotation triggered');
        console.log('comment: ', this.comment);
        if(this.comment == null || this.comment == '' || this.comment == undefined){
            this.commentFlag = true;
        }else{
            this.commentFlag = false;
            const payload = {

                ticketid: '1380428',
                status: this.quotationStatus == 'Accept' ? 'ACCEPTED' : 'REJECTED',
                comment: this.comment
            };
            console.log('Payload submitted:', JSON.stringify(payload));

            submitAcceptRejectQuotation({requestBody: JSON.stringify(payload), 
                requestId: this.requestid, 
            })
            .then(result => {
                console.log('result: ', result);
                this.acceptRejectFlag = false;
                this.comment = '';
                this.commentFlag = false;
                
                alert('Quotation ' + payload.status.toLowerCase() + ' successfully')
            })
            .catch(error => {
                console.log('error: ', JSON.stringify(error));
                alert('Error: ' + error.body.message);
            });
        }
    }

    handleCommercialTime(slot){
       console.log('Inside handleCommercialTime: ', slot);
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
       console.log('Inside handleResidentialTime: ', slot);
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
        console.log('uploadedFiles: ', uploadedFiles);
        // You can perform further actions with the uploaded files here
    }

    handleCancel(){
        if(this.reason == '' || this.reason == null || this.reason == undefined){
            this.reasonFlag = true;
        }else{
            this.reasonFlag = false;
            const twoDaysLaterISO = new Date();
            twoDaysLaterISO.setDate(twoDaysLaterISO.getDate() + 2);
            const formatted = twoDaysLaterISO.toISOString().slice(0, 10); 
            console.log('formatted', formatted); //this.request.NGMCP_Job_SubType__c
            if(this.request.NGMCP_Target_Start__c < formatted && this.request.NGMCP_Job_SubType__c == 'Adversarial Removal'){
                this.cancelChargeFlag = true
            }else{
                this.cancelChargeFlag = false
                this.handleYes();
            }
        }
       
        console.log('this.reasonFlag', this.reasonFlag);
        console.log('this.cancelChargeFlag', this.cancelChargeFlag);
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
            console.log('Uploaded files:', JSON.stringify(results));
            //this.showToast('Success', `Uploaded ${results.length} file(s).`, 'success');
            alert('File uploaded successfully!');
            this.filesToUpload = [];
        } catch (e) {
            console.error(e);
            alert('Error uploading file: ' + e);
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

    

}