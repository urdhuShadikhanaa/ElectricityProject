import { LightningElement, track } from 'lwc';
import getHolidaysBetween from '@salesforce/apex/NGMCP_HolidaysService.getHolidaysBetween';

export default class NGMCPAppointDemolition extends LightningElement {
  @track currentYear;
  @track currentMonth; // 0-based
  @track calendarDays = [];
  @track weekDays = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
  @track holidaySet = new Set();
  @track selectedDateIso = '';     // keep ISO internally (yyyy-MM-dd)
  @track isCalendarOpen = false;

  // ---------- lifecycle ----------
  connectedCallback() {
    const today = new Date();
    this.currentYear = today.getFullYear();
    this.currentMonth = today.getMonth();
    this.buildCalendar();

    // 27 jan change

    
 // Use 'click' (bubble) instead of 'mousedown'
    window.addEventListener('click', this.handleOutsideClick);
// 27 jan change end here

  }

  disconnectedCallback() {
    window.removeEventListener('click', this.handleOutsideClick);
  }
  // ---------- formatting helpers ----------
  // Local yyyy-MM-dd (no UTC shift)
  toLocalIso(date) {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  // ISO -> DD/MM/YYYY (for display)
  toDisplay(iso) {
    if (!iso) return '';
    const [y, m, d] = iso.split('-');
    return `${d}/${m}/${y}`;
  }

  // DD/MM/YYYY -> ISO (yyyy-MM-dd). Returns '' if invalid.
  fromDisplayToIso(ddmmyyyy) {
    if (!ddmmyyyy) return '';
    const parts = ddmmyyyy.trim().split('/');
    if (parts.length !== 3) return '';
    const [dd, mm, yyyy] = parts;
    if (!/^\d{2}$/.test(dd) || !/^\d{2}$/.test(mm) || !/^\d{4}$/.test(yyyy)) return '';

    const day = parseInt(dd, 10);
    const monthIdx = parseInt(mm, 10) - 1; // 0-based
    const year = parseInt(yyyy, 10);

    const dt = new Date(year, monthIdx, day);
    // validate constructed date (rejects 31/02/2026, etc.)
    if (dt.getFullYear() !== year || dt.getMonth() !== monthIdx || dt.getDate() !== day) return '';

    return this.toLocalIso(dt);
  }

  // ---------- UI getters ----------
  get monthLabel() {
    const d = new Date(this.currentYear, this.currentMonth, 1);
    return d.toLocaleString(undefined, { month: 'long', year: 'numeric' });
  }

  // Show DD/MM/YYYY in the input
  get selectedDateLabel() {
    return this.toDisplay(this.selectedDateIso);
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

    const days = [];
    let cursor = new Date(gridStart);
    let keyIdx = 0;

    while (cursor <= gridEnd) {
      // 🔹 Use local ISO (avoid toISOString UTC shift)
      const iso = this.toLocalIso(cursor);
      const isWeekend = (cursor.getDay() === 0 || cursor.getDay() === 6);
      const inMonth = (cursor.getMonth() === this.currentMonth);

      days.push({
        key: keyIdx++,
        day: cursor.getDate(),
        iso,            // keep ISO for logic/events
        isWeekend,
        inMonth,
        cssClass: 'day' + (inMonth ? '' : ' other-month') + (isWeekend ? ' weekend' : '')
      });

      cursor.setDate(cursor.getDate() + 1);
    }

    this.calendarDays = days;

    await this.loadHolidaysForRange(gridStart, gridEnd);
    this.applyHolidayClasses();
  }

  async loadHolidaysForRange(startDate, endDate) {
    // 🔹 Use local ISO here as well
    const s = this.toLocalIso(startDate);
    const e = this.toLocalIso(endDate);
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

     // 27 jan change

     // Returns true if the click happened inside this component (Shadow DOM safe).
_isInsideComponent(event) {
    // Prefer composed path when available
    const path = typeof event.composedPath === 'function' ? event.composedPath() : [];
    if (Array.isArray(path) && path.length) {
        // this.template.host is the custom element <c-your-component>
        if (path.includes(this.template.host)) return true;
        // Also allow any node contained by the template to count as inside
        if (path.some(n => n instanceof Node && this.template.contains(n))) return true;
    }
    // Fallback for environments with no composedPath
    return this.template.contains(event.target);
}

  // --- Add in the class:
handleOutsideClick = (event) => {
    // If click occurred INSIDE the component, do nothing
    if (this._isInsideComponent(event)) return;

    // Otherwise, close only if open
    if (this.isCalendarOpen) {
        this.isCalendarOpen = false;
    }
};

    // 27 jan change end here
  

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

  // ---------- selection from calendar click ----------
  handleSelectDate(e) {
    const target = e.currentTarget || e.target;
    const iso = target?.dataset?.date;
    if (!iso) return;

    // Update internal ISO and close the popup
    this.selectedDateIso = iso;
    this.isCalendarOpen = false;

    // Emit ISO; parent can also format if needed
    this.dispatchEvent(new CustomEvent('dateselected', { detail: { date: iso } }));
  }
  // Block any manual typing/paste/drop in the date display input
blockManualEdit(e) {
  // Allow only navigation/escape/tab for accessibility
  if (e.type === 'keydown') {
    const allowed = new Set(['Tab', 'Shift', 'ArrowLeft', 'ArrowRight', 'Home', 'End', 'Escape']);
    if (allowed.has(e.key)) return;
  }
  e.preventDefault();
}

// If something injects text (e.g., autofill), snap back to the selected date label
snapBackIfTyped(e) {
  if (!e || !e.target) return;
  e.preventDefault && e.preventDefault();
  // Keep the UI reflecting the calendar-selected date only
  e.target.value = this.selectedDateLabel;
}


  // ---------- selection when user types in input (DD/MM/YYYY) ----------
  handleDateSelect(event) {
    const typed = event?.target?.value; // expects DD/MM/YYYY
    const iso = this.fromDisplayToIso(typed);

    if (!iso) {
      // Optional: set custom validity/toast here for invalid format
      return;
    }

    this.selectedDateIso = iso;

    // Emit ISO to parent
    this.dispatchEvent(new CustomEvent('datechange', {
      detail: { date: this.selectedDateIso }
    }));
  }

  
}