import { LightningElement, track } from 'lwc';
import hasRetrospectivePermission from '@salesforce/apex/NGMCP_UwrRetrospectiveJobHandler.hasRetrospectivePermission';

export default class UwrRetrospective extends LightningElement {
    @track isRetrospectiveYes = false;
    @track isRetrospectiveNo = true;
    @track showAppointmentFields = true;
    @track showRetrospectiveQuestion = false;

    @track appointmentDate = '';
    @track appointmentSlot = '';
    @track availableSlots = ['09:00 AM', '10:00 AM', '11:00 AM', '01:00 PM', '02:00 PM'];

    today;
    dateMin;
    dateMax;
    @track showDateError = false;

    connectedCallback() {
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const day = String(now.getDate()).padStart(2, '0');
        this.today = `${year}-${month}-${day}`;

        // Default for "No" → future dates only
        this.dateMin = this.today;
        this.dateMax = '';

        // Check permission
        hasRetrospectivePermission()
            .then(result => {
                this.showRetrospectiveQuestion = result;
            })
            .catch(error => {
                console.error('Permission check failed:', error);
            });
    }

    handleRetrospectiveChange(event) {
        const value = event.target.value;
        this.isRetrospectiveYes = value === 'Yes';
    
        this.showAppointmentFields = value === 'No';

        if (this.isRetrospectiveYes) {
            this.appointmentDate = '';
            this.appointmentSlot = '';
            this.dateMin = ''; // allow past dates
            this.dateMax = this.today;
        } else {
            this.dateMin = this.today; // allow future dates
            this.dateMax = '';
        }
    }

    handleDateChange(event) {
        const inputValue = event.target.value;
        if ((this.isRetrospectiveNo && inputValue < this.today) ||
            (this.isRetrospectiveYes && inputValue > this.today)) {
            this.appointmentDate = '';
            this.showDateError = true;
        } else {
            this.appointmentDate = inputValue;
            this.showDateError = false;
        }
    }

    handleSlotChange(event) {
        this.appointmentSlot = event.target.value;
    }

    get formattedAppointmentDate() {
        if (!this.appointmentDate) return '';
        const [year, month, day] = this.appointmentDate.split('-');
        return `${day}/${month}/${year}`;
    }

    get payloadForMaximo() {
        if (this.isRetrospectiveYes) {
            return {}; // Do not send date & slot
        }
        return {
            appointmentDate: this.formattedAppointmentDate,
            appointmentSlot: this.appointmentSlot
        };
    }
}