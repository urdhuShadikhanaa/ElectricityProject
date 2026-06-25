import { LightningElement, track } from 'lwc';
import getHolidaysBetween from '@salesforce/apex/NGMCP_HolidaysService.getHolidaysBetween';

export default class Holidaybank extends LightningElement {
  @track currentYear;
  @track currentMonth;
  @track calendarDays = [];
  @track weekDays = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
  @track holidaySet = new Set();
  @track selectedDateIso = '';
  @track isCalendarOpen = false;

  connectedCallback() {
    const today = new Date();
    this.currentYear = today.getFullYear();
    this.currentMonth = today.getMonth();
    this.buildCalendar();
  }

  get monthLabel() {
    const d = new Date(this.currentYear, this.currentMonth, 1);
    return d.toLocaleString(undefined, { month: 'long', year: 'numeric' });
  }

  get selectedDateLabel() {
    if (!this.selectedDateIso) return '';
    const date = new Date(this.selectedDateIso);
    return date.toLocaleDateString(undefined, { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' });
  }

  toggleCalendar() {
    this.isCalendarOpen = !this.isCalendarOpen;
  }

  async buildCalendar() {
    const firstOfMonth = new Date(this.currentYear, this.currentMonth, 1);
    const startDay = firstOfMonth.getDay();
    const gridStart = new Date(this.currentYear, this.currentMonth, 1 - startDay);

    const lastOfMonth = new Date(this.currentYear, this.currentMonth + 1, 0);
    const endDay = lastOfMonth.getDay();
    const gridEnd = new Date(this.currentYear, this.currentMonth + 1, 6 - endDay);

    const days = [];
    let cursor = new Date(gridStart);
    let keyIdx = 0;
    while (cursor <= gridEnd) {
      const iso = cursor.toISOString().slice(0,10);
      const isWeekend = (cursor.getDay() === 0 || cursor.getDay() === 6);
      const inMonth = (cursor.getMonth() === this.currentMonth);
      const isToday = iso === new Date().toISOString().slice(0,10);
      days.push({
        key: keyIdx++,
        day: cursor.getDate(),
        iso,
        isWeekend,
        inMonth,
        isToday,
        cssClass: 'day' + (inMonth ? '' : ' other-month'),
        disabled: false,
        tooltip: 'Select date',
        tabIndex: 0
      });
      cursor.setDate(cursor.getDate()+1);
    }

    this.calendarDays = days;

    await this.loadHolidaysForRange(gridStart, gridEnd);
    this.applyHolidayClasses();
  }

  async loadHolidaysForRange(startDate, endDate) {
    const s = startDate.toISOString().slice(0,10);
    const e = endDate.toISOString().slice(0,10);
    try {
      const result = await getHolidaysBetween({ startDate: s, endDate: e });
      this.holidaySet = new Set((result || []).map(d => d));
    } catch (err) {
      this.holidaySet = new Set();
      console.error('Failed to load holidays', err);
    }
  }

  applyHolidayClasses() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayIso = today.toISOString().slice(0, 10);

    this.calendarDays = this.calendarDays.map(cd => {
      const cssExtras = [];
      let isDisabled = false;
      let tooltip = 'Select date';
      let tabIndex = 0;

      const dateObj = new Date(cd.iso);
      const isPast = dateObj < today;
      const isToday = cd.iso === todayIso;
      const isFuture = dateObj > today;
      const isWeekend = cd.isWeekend;
      const isHoliday = this.holidaySet.has(cd.iso);

      if (isHoliday) {
        cssExtras.push('holiday');
        tooltip = 'Holiday';
      }

      if (isWeekend) {
        cssExtras.push('weekend');
        tooltip = 'Weekend';
      }

      // Disable if today OR future OR weekend OR holiday
      if (isToday || isFuture || isWeekend || isHoliday) {
        isDisabled = true;
        cssExtras.push('disabled');
        tooltip = isToday ? 'Today not selectable' : 'Not selectable';
        tabIndex = -1;
      }

      cd.cssClass = 'day' +
        (cd.inMonth ? '' : ' other-month') +
        (cssExtras.length ? ' ' + cssExtras.join(' ') : '');
      cd.disabled = isDisabled;
      cd.tooltip = tooltip;
      cd.tabIndex = tabIndex;

      return cd;
    });
  }

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

  handleSelectDate(e) {
    const iso = e.currentTarget.dataset.date;
    const cd = this.calendarDays.find(day => day.iso === iso);

    if (!iso || (cd && cd.disabled)) {
      return; // Do nothing for disabled dates
    }

    this.selectedDateIso = iso;
    this.isCalendarOpen = false;
    this.dispatchEvent(new CustomEvent('dateselected', { detail: { date: iso } }));
  }
}