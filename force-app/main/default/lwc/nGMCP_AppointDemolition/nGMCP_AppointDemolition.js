import { LightningElement, track } from 'lwc';
import getHolidaysBetween from '@salesforce/apex/NGMCP_HolidaysService.getHolidaysBetween';


export default class NGMCP_AppointDemolition extends LightningElement {
 @track currentYear;
  @track currentMonth; // 0-based
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

  handleDateSelect(event) {
        const selectedDate = event.target.value; // from your lightning-input or calendar click
        this.selectedDateLabel = selectedDate;

        // Fire event to parent
        this.dispatchEvent(new CustomEvent('datechange', {
            detail: { date: selectedDate }
        }));
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
      days.push({
        key: keyIdx++,
        day: cursor.getDate(),
        iso,
        isWeekend,
        inMonth,
        cssClass: 'day' + (inMonth ? '' : ' other-month') + (isWeekend ? ' weekend' : '')
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
      // eslint-disable-next-line no-console
      console.error('Failed to load holidays', err);
    }
  }

  applyHolidayClasses() {
    this.calendarDays = this.calendarDays.map(cd => {
      const cssExtras = [];
      if (this.holidaySet.has(cd.iso)) cssExtras.push('holiday');
      if (cd.isWeekend) cssExtras.push('weekend');
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
    if (!iso) return;
    this.selectedDateIso = iso;
    this.isCalendarOpen = false; // close calendar after selection
    const year = selectedDate.getFullYear();
    const month = String(selectedDate.getMonth() + 1).padStart(2, '0');
    const day = String(selectedDate.getDate()).padStart(2, '0');
    const localDate = `${year}-${month}-${day}`;

    this.dispatchEvent(new CustomEvent('dateselected', { detail: { date: localDate } }));

  }
}