import { LightningElement, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';

export default class HomeContainer extends LightningElement {
    userId = USER_ID;
    userName = 'Guest';
    currentDateTime;
    greeting;
    showContainerFlag = true;
    showViewRequest = false;
    filters;
    workId;
    recordtype;
    workOrderFlag = false;
    parentFlag = false;
    pdfdownload = false;
    viewRequestFlag = false;

    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            this.userName = data.fields.Name.value;
        } else if (error) {
            console.error('Error fetching user name:', error);
        }
    }

    connectedCallback() {
        this.updateDateTime();
        this.timer = setInterval(() => {
            this.updateDateTime();
        }, 1000);
    }

    disconnectedCallback() {
        clearInterval(this.timer);
    }

    updateDateTime() {
        const now = new Date();
        this.currentDateTime = now.toLocaleString('en-IN', {
            weekday: 'long',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            hour12: false
        });

        const hour = now.getHours();
        if (hour < 12) {
            this.greeting = 'Good morning';
        } else if (hour < 17) {
            this.greeting = 'Good afternoon';
        } else {
            this.greeting = 'Good evening';
        }
    }

    handleResponse(event) {
        // Safely unpack detail
        const { type, filters, responseClass, result, error, meta } = event.detail || {};

        console.log(
            'handleResponse:',
            JSON.stringify({ type, responseClass, filters, result, error, meta })
        );
        if (type == 'sr') {
            this.showContainerFlag = false;
            this.showViewRequest = true;
            this.filters = filters;
            this.parentFlag = true;
        }
        if (type == 'wo') {
            this.workId = result.id,
                this.recordtype = result.recordType,
                this.showViewRequest = false;
            this.workOrderFlag = true;
            this.showContainerFlag = false;
            this.pdfdownload = true;
        }
    }
    handleAttentionclass(event) {
        console.log('handleAttentionclass', JSON.stringify(event.detail));
        this.showContainerFlag = false;
        this.workOrderFlag = true;
        this.workId = event.detail.recordId;
        this.recordtype = event.detail.recordId.startsWith('0WO')?'WorkOrder': 'Enquiry';

        this.pdfdownload = event.detail.recordId.startsWith('0WO')
                ? true : false;
        console.log('pdfdownload', JSON.stringify(this.pdfdownload));
        console.log('recordtype', JSON.stringify(this.recordtype));
    }
}