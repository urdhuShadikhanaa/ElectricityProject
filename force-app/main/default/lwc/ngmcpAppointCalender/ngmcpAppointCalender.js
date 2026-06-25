import { LightningElement } from 'lwc';
import getHolidaysBetween from '@salesforce/apex/NGMCP_HolidaysService.getHolidaysBetween';

export default class NgmcpAppointCalender extends LightningElement {
    currentYear;
    currentMonth; // 0-based
    calendarDays = [];
    weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    holidaySet = new Set();
    selectedDateIso = ''; // keep ISO internally
    isCalendarOpen = false;

    todayIso;

    connectedCallback() {
  const today = new Date();
  this.currentYear = today.getFullYear();
  this.currentMonth = today.getMonth();
  this.todayIso = this.toLocalIso(today);
  this.buildCalendar();

  // ---- NEW: register window-level listeners ----
  // Bind once so we can remove exactly the same reference later
  this._boundOutsideClick = this.handleOutsideClick.bind(this);

  // Use capture phase to ensure we see the click even if inner elements stopPropagation
//   window.addEventListener('click', this._boundOutsideClick, true);
       window.addEventListener('click', this._boundOutsideClick);

  // Also close on Esc for accessibility
  window.addEventListener('keydown', this._handleWindowKeydown, true);
}

    disconnectedCallback() {
  // ---- NEW: cleanup listeners to avoid leaks ----
  if (this._boundOutsideClick) {
    // window.removeEventListener('click', this._boundOutsideClick, true);
    window.removeEventListener('click', this._boundOutsideClick);
    this._boundOutsideClick = null;
  }
  window.removeEventListener('keydown', this._handleWindowKeydown, true);
}



    // ---------- helpers ----------
    // local yyyy-MM-dd (no UTC shift)
    toLocalIso(date) {
        const y = date.getFullYear();
        const m = String(date.getMonth() + 1).padStart(2, '0');
        const d = String(date.getDate()).padStart(2, '0');
        return `${y}-${m}-${d}`;
    }

    // Format ISO -> DD/MM/YYYY for display
    toDisplay(iso) {
        if (!iso) return '';
        const [y, m, d] = iso.split('-');
        return `${d}/${m}/${y}`;
    }

    // Parse DD/MM/YYYY -> ISO (returns '' if invalid)
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
        // validate constructed date components (handles invalid dates like 31/02/2026)
        if (dt.getFullYear() !== year || dt.getMonth() !== monthIdx || dt.getDate() !== day) return '';

        return this.toLocalIso(dt);
    }

    get monthLabel() {
        const d = new Date(this.currentYear, this.currentMonth, 1);
        return d.toLocaleString(undefined, { month: 'long', year: 'numeric' });
    }

    // 🔹 Show DD/MM/YYYY in the input
    get selectedDateLabel() {
        return this.toDisplay(this.selectedDateIso);
    }

    toggleCalendar(event) {
  event?.stopPropagation?.();
  this.isCalendarOpen = !this.isCalendarOpen;
}

    // disable Prev for months strictly before the current month
    get isPrevDisabled() {
        const today = new Date();
        const view = new Date(this.currentYear, this.currentMonth, 1);
        const startOfCurrentMonth = new Date(today.getFullYear(), today.getMonth(), 1);
        return view <= startOfCurrentMonth;
    }

    // Block manual typing/paste/drop in the input
blockManualEdit(e) {
  if (e.type === 'keydown') {
    // Allow only navigation/escape/tab for accessibility
    const allowed = new Set(['Tab', 'Shift', 'ArrowLeft', 'ArrowRight', 'Home', 'End', 'Escape']);
    if (allowed.has(e.key)) return;
  }
  e.preventDefault();
}

// If something injects text (e.g., autofill), snap UI back to the selected date
snapBackIfTyped(e) {
  if (!e || !e.target) return;
  e.preventDefault && e.preventDefault();
  e.target.value = this.selectedDateLabel; // keep display in sync with calendar-picked date
}

    // ---------- calendar build (unchanged logic for blocking) ----------
    async buildCalendar() {
        const firstOfMonth = new Date(this.currentYear, this.currentMonth, 1);
        const startDay = firstOfMonth.getDay();
        const gridStart = new Date(this.currentYear, this.currentMonth, 1 - startDay);

        const lastOfMonth = new Date(this.currentYear, this.currentMonth + 1, 0);
        const endDay = lastOfMonth.getDay();
        const gridEnd = new Date(this.currentYear, this.currentMonth + 1, 6 - endDay);

        const todayIso = this.todayIso;

        const days = [];
        const cursor = new Date(gridStart);
        let keyIdx = 0;

        while (cursor <= gridEnd) {
            const iso = this.toLocalIso(cursor);
            const dow = cursor.getDay();
            const isWeekend = dow === 0 || dow === 6;
            const inMonth = cursor.getMonth() === this.currentMonth;

            // block past + today
            const isDisabled = iso <= todayIso;

            days.push({
                key: keyIdx++,
                day: cursor.getDate(),
                iso,
                isWeekend,
                inMonth,
                isDisabled,
                cssClass: ''
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

            const classes = ['day'];
            if (!cd.inMonth) classes.push('other-month');
            if (isHoliday) classes.push('holiday');
            else if (cd.isWeekend) classes.push('weekend');
            if (cd.isDisabled) classes.push('disabled');
            return { ...cd, cssClass: classes.join(' ') };
        });
    }

        // ---- Outside click & Esc-to-close support (Shadow DOM safe) ----
// Prefer composedPath when available, fallback to this.template.contains
_isInsideComponent(event) {
  const path = typeof event.composedPath === 'function' ? event.composedPath() : [];
  if (Array.isArray(path) && path.length) {
    if (path.includes(this.template.host)) return true;              // <c-ngmcp-appoint-calender>
    if (path.some(n => n instanceof Node && this.template.contains(n))) return true;
  }
  return this.template.contains(event.target);
}

// Close calendar if user clicks outside the component
handleOutsideClick(event) {
  if (!this.isCalendarOpen) return;          // nothing to do
  if (this._isInsideComponent(event)) return; // ignore inside clicks
  this.isCalendarOpen = false;               // close popup
}

// Optional: Close on Escape for accessibility
_handleWindowKeydown = (e) => {
  if (!this.isCalendarOpen) return;
  if (e.key === 'Escape') {
    this.isCalendarOpen = false;
    e.preventDefault();
  }
};

    // ---------- navigation ----------
    handlePrev(event) {
  event?.preventDefault?.();
  event?.stopPropagation?.();
  if (this.isPrevDisabled) return;
  this.changeMonth(-1);
}
handleNext(event) {
  event?.preventDefault?.();
  event?.stopPropagation?.();
  this.changeMonth(1);
}
    changeMonth(deltaMonths) {
        const d = new Date(this.currentYear, this.currentMonth + deltaMonths, 1);
        this.currentYear = d.getFullYear();
        this.currentMonth = d.getMonth();
        this.buildCalendar();
    }
    
                _stopInsideClick = (event) => {
  event?.stopPropagation?.();
};
    // ---------- selection ----------
    handleSelectDate(e) {
        const target = e.currentTarget || e.target;
        const iso = target?.dataset?.date;
        if (!iso) return;

        const cell = this.calendarDays.find(d => d.iso === iso);
        if (cell?.isDisabled) return;

        this.selectedDateIso = iso;
        this.isCalendarOpen = false;

        // Emit ISO; parent can format if needed
        this.dispatchEvent(new CustomEvent('dateselected', { detail: { date: iso } }));
    }

    // If user types in DD/MM/YYYY manually
    handleDateSelect(event) {
        const typed = event?.target?.value; // expecting DD/MM/YYYY
        const iso = this.fromDisplayToIso(typed);

        if (!iso) {
            // Invalid format/content — keep what they typed but do not commit selection
            // (Optionally, show a toast or set a custom validity on the lightning-input)
            return;
        }

        // Block past & today on manual typing too
        if (iso <= this.todayIso) {
            return;
        }

        this.selectedDateIso = iso;
        this.dispatchEvent(new CustomEvent('datechange', { detail: { date: this.selectedDateIso } }));
    }
}