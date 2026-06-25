import { LightningElement, track } from 'lwc';

export default class UrgentWorkRequest extends LightningElement {
    @track startImmediately = '';
    @track jobType = '';
    @track errorMessage = '';

    yesNoOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];

    jobTypeOptions = [
        { label: 'Commercial', value: 'Commercial' },
        { label: 'Residential', value: 'Residential' }
    ];

    get showTypeSelection() {
        return this.startImmediately === 'Yes';
    }

    handleStartImmediatelyChange(event) {
        this.startImmediately = event.detail.value;
        this.errorMessage = '';
    }

    handleJobTypeChange(event) {
        this.jobType = event.detail.value;
        this.errorMessage = '';
    }

    handleSubmit() {
        this.errorMessage = '';

        if (this.startImmediately === 'Yes') {
            if (!this.jobType) {
                this.errorMessage = 'Please select a job type.';
                return;
            }

            const now = new Date();
            const day = now.getDay(); // 0 = Sunday, 6 = Saturday
            const hour = now.getHours();

            let isValidTime = false;

            if (this.jobType === 'Commercial') {
                isValidTime = hour >= 9 && hour < 17;
            } else if (this.jobType === 'Residential') {
                const isWeekend = day === 0 || day === 6;
                if (isWeekend) {
                    isValidTime = hour >= 9 && hour < 17;
                } else {
                    isValidTime = hour >= 8 && hour < 20;
                }
            }

            if (!isValidTime) {
                this.errorMessage = `The current time is outside the allowed window for ${this.jobType} jobs.`;
                return;
            }
        }

        // Proceed with submission logic
        alert('Form submitted successfully!');
    }
}