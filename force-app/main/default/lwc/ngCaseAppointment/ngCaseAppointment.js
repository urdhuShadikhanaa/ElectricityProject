import { LightningElement, track, wire} from 'lwc';
import getLatestCases from '@salesforce/apex/ngCaseAppointmentsController.getLatestCases';
import getUpcomingCases from '@salesforce/apex/ngCaseAppointmentsController.getUpcomingCases';


export default class NgCaseAppointment extends LightningElement {
    @track latestCases = [];
    @track upcomingCases = [];
    
    connectedCallback() {
        this.loadLatestCases();
        this.loadUpcomingCases();
    }

    loadLatestCases() {
        getLatestCases()
            .then(result => {
                // Map each case to include a relative date string
                this.latestCases = result.map(c => {
                    let relDate = this.formatRelativeDate(c.NG_Appointment_Date__c);
                    return { ...c, relativeApptDate: relDate };
                });
            })
            .catch(error => {
                console.error('Error fetching latest cases', error);
            });
    }

    loadUpcomingCases() {
        getUpcomingCases()
            .then(result => {
                // Map each case to include formatted date/time slot
                this.upcomingCases = result.map(c => {
                    // Assuming c.Site__r.Name is returned as Site_Name__c in the wire (alias if needed)
                    let siteName = c.CRM_House_Name_Number_Site_Name__c ? c.CRM_House_Name_Number_Site_Name__c : '';
                    let timeSlot = this.formatTimeSlot(c.NG_Appointment_Date__c, c.Appointment_Start_Time__c, c.Appointment_End_Time__c);
                    return { 
                        ...c, 
                        Site_Name: siteName, 
                        formattedTimeSlot: timeSlot 
                    };
                });
            })
            .catch(error => {
                console.error('Error fetching upcoming cases', error);
            });
    }

    // Format a date string as relative time (e.g. "2 hrs ago" or "5 Mar")
    formatRelativeDate(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        const now = new Date();
        const diffMs = now - date;
        const diffHrs = Math.floor(diffMs / (1000 * 60 * 60));
        const diffMins = Math.floor(diffMs / (1000 * 60));
        if (diffHrs >= 24) {
            // Show as "DD Mon"
            const day = String(date.getDate()).padStart(2, '0');
            const monthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
            return `${day} ${monthNames[date.getMonth()]}`;
        } else if (diffHrs >= 1) {
            return `${diffHrs} hr${diffHrs > 1 ? 's' : ''} ago`;
        } else if (diffMins >= 1) {
            return `${diffMins} min${diffMins > 1 ? 's' : ''} ago`;
        }
        return 'Just now';
    }

    // Combine date and time fields into a formatted slot: "DD/MM/YY HH:mm - HH:mm"
    formatTimeSlot(dateString, startTime, endTime) {
        if (!dateString) return '';
        const date = new Date(dateString);
        const dd = String(date.getDate()).padStart(2, '0');
        const mm = String(date.getMonth()+1).padStart(2, '0');
        const yy = String(date.getFullYear()).slice(-2);
        // Assume startTime and endTime are strings like "HH:mm:ss"
        const fmt = (time) => time ? time.substring(0,5) : '';
        return `${dd}/${mm}/${yy} ${fmt(startTime)} - ${fmt(endTime)}`;
    }

}