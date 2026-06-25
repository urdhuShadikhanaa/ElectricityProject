import { LightningElement, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';

export default class WelcomeMessage extends LightningElement {
    userId = USER_ID;
    userName = 'Guest';
    currentDateTime;
    greeting;

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
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: true
        });

        const hour = now.getHours();
        if (hour < 12) {
            this.greeting = 'Good Morning';
        } else if (hour < 17) {
            this.greeting = 'Good Afternoon';
        } else {
            this.greeting = 'Good Evening';
        }
    }
}