import { LightningElement, track } from 'lwc';
import getBankHolidays from '@salesforce/apex/BankHolidayController.getBankHolidays';

export default class NgmCalendarPopup extends LightningElement {
     @track showCalendar = false;
    @track calendarDays = [];
    holidays = [];

    connectedCallback() {
        getBankHolidays().then(result => {
            this.holidays = result;
            this.generateCalendar();
        }).catch(error => {
            console.error('Error fetching holidays', error);
        });
    }

    openCalendar() {
        this.showCalendar = true;
    }

    closeCalendar() {
        this.showCalendar = false;
    }

    generateCalendar() {
        let days = [];
        let today = new Date();
        let month = today.getMonth();
        let year = today.getFullYear();
        let daysInMonth = new Date(year, month + 1, 0).getDate();

        for (let i = 1; i <= daysInMonth; i++) {
            let date = new Date(year, month, i);
            let formatted = date.toISOString().split('T')[0];
            let isHoliday = this.holidays.includes(formatted);
            let isWeekend = (date.getDay() === 0 || date.getDay() === 6);

            days.push({
                label: i,
                date: formatted,
                class: isHoliday ? 'holiday' : isWeekend ? 'weekend' : 'normal-day',
                disabled: isHoliday || isWeekend
            });
        }
        this.calendarDays = days;
    }

    handleDateSelect(event) {
        let selectedDate = event.target.value;
        alert('Selected Date: ' + selectedDate);
        this.closeCalendar();
    }
}