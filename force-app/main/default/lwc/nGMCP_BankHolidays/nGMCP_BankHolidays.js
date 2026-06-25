import { LightningElement, wire } from 'lwc';
import getBankHolidays from '@salesforce/apex/HolidayController.getBankHolidays';

export default class HolidayCalendar extends LightningElement {
    holidays = [];
    calendarDays = [];

    @wire(getBankHolidays)
    wiredHolidays({ error, data }) {
        if (data) {
            this.holidays = data.map(item => item.HolidayDate__c);
            this.generateCalendar();
        } else if (error) {
            console.error('Error fetching holidays:', error);
        }
    }

    generateCalendar() {
        const today = new Date();
        const year = today.getFullYear();
        const month = today.getMonth(); // current month

        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const days = [];

        for (let i = 1; i <= daysInMonth; i++) {
            const dateStr = `${year}-${String(month + 1).padStart(2, '0')}-${String(i).padStart(2, '0')}`;
            const isHoliday = this.holidays.includes(dateStr);

            days.push({
                label: i,
                date: dateStr,
                cssClass: isHoliday ? 'day holiday' : 'day'
            });
        }

        this.calendarDays = days;
    }
}