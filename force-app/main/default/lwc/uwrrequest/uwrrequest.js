import { LightningElement, api } from 'lwc';

const LONDON_TZ = 'Europe/London';

export default class JobScheduler extends LightningElement {
    /** Default status; can be set in App Builder */
    @api status;

    selectedDate = '';
    errorMessage = '';
    isImmediate = false;

    /** Variants computed from state to avoid duplication */
    get startImmediateVariant() {
        return this.isImmediate ? 'brand' : 'neutral';
    }
    get appointmentDateVariant() {
        return this.isImmediate ? 'neutral' : 'brand';
    }

    /** Status toggle button variants */
    get commercialBtnVariant() {
        return this.status === 'Commercial' ? 'brand' : 'neutral';
    }
    get residentialBtnVariant() {
        return this.status === 'Residential' ? 'brand' : 'neutral';
    }

    /** Toggle handlers */
    setCommercial = () => {
        this.status = 'Commercial';
        this.errorMessage = '';
    };
    setResidential = () => {
        this.status = 'Residential';
        this.errorMessage = '';
    };

    /** Immediate flow */
    handleStartImmediate() {
        this.isImmediate = true;
        this.errorMessage = '';

        if (!this.status) {
            this.selectedDate = '';
            this.errorMessage = 'Please select a status.';
            return;
        }

        const isValid = this.validateUKTime();

        if (isValid) {
            // Set selectedDate to London local date in YYYY-MM-DD
            this.selectedDate = this.getLondonDateYYYYMMDD(new Date());
        } else {
            this.selectedDate = '';
            this.errorMessage =
                'Immediate start not available as current time is outside of agreed working hours. Please book for a future date/timeslot.';
        }
    }

    /** Appointment flow */
    handleAppointmentDate() {
        this.isImmediate = false;
        this.selectedDate = '';
        this.errorMessage = '';
    }

    /** Date selection handler */
    handleDateChange(event) {
        this.selectedDate = event.detail.value;
        this.errorMessage = '';
    }

    /**
     * Validate current London time against status rules.
     * Commercial: Mon–Fri 09:00–16:59
     * Residential: Weekends 09:00–16:59; Weekdays 08:00–19:59
     */
    validateUKTime() {
        const formatter = new Intl.DateTimeFormat('en-GB', {
            timeZone: LONDON_TZ,
            hour: 'numeric',
            minute: 'numeric',
            weekday: 'short',
            hour12: false
        });

        const parts = formatter.formatToParts(new Date());
        let hour;
        let weekdayShort;

        for (const p of parts) {
            if (p.type === 'hour') hour = parseInt(p.value, 10);
            if (p.type === 'weekday') weekdayShort = p.value;
        }

        const dayMap = { Sun: 0, Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6 };
        const day = dayMap[weekdayShort];

        if (this.status === 'Commercial') {
            // Weekdays only 09:00–16:59
            return day >= 1 && day <= 5 && hour >= 9 && hour < 17;
        }

        // Residential:
        if (day === 0 || day === 6) {
            // Weekends 09:00–16:59
            return hour >= 9 && hour < 17;
        }
        // Weekdays 08:00–19:59
        return hour >= 8 && hour < 20;
    }

    /**
     * Return London local date string in YYYY-MM-DD for <lightning-input type="date">
     * Uses en-CA to get ISO-like date ordering without time, and forces London timezone.
     */
    getLondonDateYYYYMMDD(date) {
        return date.toLocaleDateString('en-CA', { timeZone: LONDON_TZ });
    }
}
``