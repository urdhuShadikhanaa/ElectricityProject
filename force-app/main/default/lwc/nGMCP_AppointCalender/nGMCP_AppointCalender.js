import { LightningElement } from 'lwc';
import getHolidaysBetween from '@salesforce/apex/NGMCP_HolidaysService.getHolidaysBetween';

export default class NGMCP_AppointDemolition extends LightningElement {
    currentYear;
    currentMonth; // 0-based
    calendarDays = [];
    weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    holidaySet = new Set();
    selectedDateIso = '';
    isCalendarOpen = false;

    // ---------- lifecycle ----------
    connectedCallback() {
        const today = new Date();
        this.currentYear = today.getFullYear();
        this.currentMonth = today.getMonth();
        this.buildCalendar();
    }

    // ---------- helpers ----------
    // local yyyy-MM-dd (no UTC shift)
    toLocalIso(date) {
        const y = date.getFullYear();
        const m = String(date.getMonth() + 1).padStart(2, '0');
        const d = String(date.getDate()).padStart(2, '0');
        return `${y}-${m}-${d}`;
    }

    get monthLabel() {
        const d = new Date(this.currentYear, this.currentMonth, 1);
        return d.toLocaleString(undefined, { month: 'long', year: 'numeric' });
    }

    get selectedDateLabel() {
        return this.selectedDateIso || '';
    }

    toggleCalendar() {
        this.isCalendarOpen = !this.isCalendarOpen;
    }

    // ---------- calendar build ----------
    async buildCalendar() {
        const firstOfMonth = new Date(this.currentYear, this.currentMonth, 1);
        const startDay = firstOfMonth.getDay();
        const gridStart = new Date(this.currentYear, this.currentMonth, 1 - startDay);

        const lastOfMonth = new Date(this.currentYear, this.currentMonth + 1, 0);
        const endDay = lastOfMonth.getDay();
        const gridEnd = new Date(this.currentYear, this.currentMonth + 1, 6 - endDay);

        const todayIso = this.toLocalIso(new Date());

        const days = [];
        const cursor = new Date(gridStart);
        let keyIdx = 0;

        while (cursor <= gridEnd) {
            const iso = this.toLocalIso(cursor);
            const dow = cursor.getDay();
            const isWeekend = dow === 0 || dow === 6;
            const inMonth = cursor.getMonth() === this.currentMonth;

            // disable strictly past dates
            const isDisabled = iso < todayIso;

            days.push({
                key: keyIdx++,
                day: cursor.getDate(),
                iso,
                isWeekend,
                inMonth,
                isDisabled,
                cssClass: '' // will fill after holidays
            });

            cursor.setDate(cursor.getDate() + 1);
        }

        this.calendarDays = days;

        await this.loadHolidaysForRange(gridStart, gridEnd);
        this.applyHolidayClasses();
    }

    async loadHolidaysForRange(startDate, endDate) {
        const s = this.toLocalIso(startDate);
        const e = this.toLocalIso(endDate);
        try {
            const result = await getHolidaysBetween({ startDate: s, endDate: e });
            // Expecting array of 'yyyy-MM-dd' strings from Apex
            this.holidaySet = new Set((result || []).map(d => d));
        } catch (err) {
            // eslint-disable-next-line no-console
            console.error('Failed to load holidays', err);
            this.holidaySet = new Set();
        }
    }

    applyHolidayClasses() {
        this.calendarDays = this.calendarDays.map(cd => {
            const isHoliday = this.holidaySet.has(cd.iso);

            // Holiday overrides weekend
            const classes = ['day'];
            if (!cd.inMonth) classes.push('other-month');
            if (isHoliday) {
                classes.push('holiday');
            } else if (cd.isWeekend) {
                classes.push('weekend');
            }
            if (cd.isDisabled) {
                classes.push('disabled'); // visual cue for past dates
            }
            return { ...cd, cssClass: classes.join(' ') };
        });
    }

    // ---------- navigation ----------
    handlePrev() {
        this.changeMonth(-1);
    }
    handleNext() {
        this.changeMonth(1);
    }
    changeMonth(deltaMonths) {
        const d = new Date(this.currentYear, this.currentMonth + deltaMonths, 1);
        this.currentYear = d.getFullYear();
        this.currentMonth = d.getMonth();
        this.buildCalendar();
    }

    // ---------- selection ----------
    handleSelectDate(e) {
        const target = e.currentTarget || e.target;
        const iso = target?.dataset?.date;
        if (!iso) return;

        const cell = this.calendarDays.find(d => d.iso === iso);
        if (cell?.isDisabled) {
            return; // block past dates
        }

        this.selectedDateIso = iso;
        this.isCalendarOpen = false;

        // emit selected yyyy-MM-dd
        this.dispatchEvent(new CustomEvent('dateselected', { detail: { date: iso } }));
    }

    // If you ever allow typing in an actual date input
    handleDateSelect(event) {
        const selectedDate = event?.target?.value; // yyyy-MM-dd
        this.selectedDateIso = selectedDate || '';
        this.dispatchEvent(new CustomEvent('datechange', { detail: { date: this.selectedDateIso } }));
    }
}