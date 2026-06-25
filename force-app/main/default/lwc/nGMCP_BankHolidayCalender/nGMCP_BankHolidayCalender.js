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
  @track housing = null;

  get housingOptions() {
    return [
      { label: 'Yes', value: 'Yes' },
      { label: 'No', value: 'No' }
    ];
  }

  handleHousingChange(event) {
    this.housing = event.detail.value;
    if (this.housing === 'No') {
      this.selectedDateIso = '';
    }
  }

  get showAdvisory() {
    return this.housing === 'Yes' && !!this.selectedDateIso;
  }

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
    const d = new Date(this.selectedDateIso);
    return d.toLocaleDateString(undefined, { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' });
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

    const todayIso = new Date().toISOString().slice(0, 10);
    const days = [];
    let cursor = new Date(gridStart);
    let keyIdx = 0;
    while (cursor <= gridEnd) {
      const iso = cursor.toISOString().slice(0,10);
      const isWeekend = (cursor.getDay() === 0 || cursor.getDay() === 6);
      const inMonth = (cursor.getMonth() === this.currentMonth);
      const isPast = iso < todayIso;
      days.push({
        key: keyIdx++,
        day: cursor.getDate(),
        iso,
        isWeekend,
        inMonth,
        isPast,
        cssClass: 'day' + (inMonth ? '' : ' other-month'),
        isDisabled: isPast || isWeekend
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
    const todayIso = new Date().toISOString().slice(0, 10);
    this.calendarDays = this.calendarDays.map(cd => {
      const cssExtras = [];
      const isHoliday = this.holidaySet.has(cd.iso);
      const isWeekend = cd.isWeekend;
      const isPast = cd.iso < todayIso;

      if (isHoliday || isWeekend || isPast) {
        cssExtras.push('disabled');
        cd.isDisabled = true;
      }
      if (isHoliday) cssExtras.push('holiday');
      if (isWeekend) cssExtras.push('weekend');

      cd.cssClass = 'day' + (cd.inMonth ? '' : ' other-month') + (cssExtras.length ? ' ' + cssExtras.join(' ') : '');
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
    const target = e.currentTarget || e.target;
    const iso = target.dataset.date;
    const isDisabled = target.classList.contains('disabled');

    if (!iso || isDisabled) return;

    this.selectedDateIso = iso;
    this.isCalendarOpen = false;
    this.dispatchEvent(new CustomEvent('dateselected', { detail: { date: iso } }));
  }
}