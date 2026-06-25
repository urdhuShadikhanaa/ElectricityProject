import { LightningElement, api, track } from 'lwc';
import getHolidaysBetween from '@salesforce/apex/HolidayService.getHolidaysBetween';

export default class NgmcpDatePickerWithHolidays extends LightningElement {
    @api mode = 'future'; // 'future' | 'past'
    @track isCalendarOpen = false;
    @track selectedDateLabel = ''; // shown in the input; remains blank until user picks
    @track calendarDays = [];
    @track monthLabel = '';
    @track errorMessage = '';
    @api cwrdescription;
    @track message;
    @api workRequestFlag;   // when true, enforce non-working-day blocking
    @api workingDayOffset;  // number of working days to offset for min selectable date
    @api marketSectorCode;  // e.g., "I"

    weekDays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    currentMonth;
    currentYear;
    holidaySet = new Set();
    _outsideClickHandler;

    // Enforce minimum date (computed from working-day offset OR UK cutoff rule)
    minSelectableDate = null; // ISO string like '2026-02-04'

    // Boolean getter for blocking weekends/holidays
    get blockNonWorkingDays() {
        return !!this.workRequestFlag;
    }

    connectedCallback() {
        this.message = this.cwrdescription;
        console.log('marketSectorCode', this.marketSectorCode);
        const today = new Date();
        this.currentMonth = today.getMonth();
        this.currentYear = today.getFullYear();

        if (this.workRequestFlag) {
            // Compute min date, but DO NOT select it.
            this.initAutoWorkingDate();
        } else {
            // 🔹 NEW: apply UK cutoff rule only when marketSectorCode === 'I'
            this.applyUkCutoffMinDateIfNeeded();
            this.buildCalendar();
        }
    }

    renderedCallback() {
        if (this.isCalendarOpen && !this._outsideClickHandler) {
            this._outsideClickHandler = (event) => {
                if (!this.template.contains(event.target)) {
                    this.isCalendarOpen = false;
                    this.removeOutsideClickHandler();
                }
            };
            document.addEventListener('click', this._outsideClickHandler);
        }
    }

    removeOutsideClickHandler() {
        if (this._outsideClickHandler) {
            document.removeEventListener('click', this._outsideClickHandler);
            this._outsideClickHandler = null;
        }
    }

    toggleCalendar(event) {
        event.stopPropagation();
        this.isCalendarOpen = !this.isCalendarOpen;
        if (!this.isCalendarOpen) this.removeOutsideClickHandler();
    }

    stopPropagation(event) {
        event.stopPropagation();
    }

    handlePrev() {
        if (this.currentMonth === 0) {
            this.currentMonth = 11;
            this.currentYear--;
        } else {
            this.currentMonth--;
        }
        this.buildCalendar();
    }

    handleNext() {
        if (this.currentMonth === 11) {
            this.currentMonth = 0;
            this.currentYear++;
        } else {
            this.currentMonth++;
        }
        this.buildCalendar();
    }

    // 🔹 Helper: UK "now" (Europe/London), DST-safe
    getUkNow() {
        const fmt = new Intl.DateTimeFormat('en-GB', {
            timeZone: 'Europe/London',
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false
        });

        const parts = fmt.formatToParts(new Date());
        const map = Object.fromEntries(parts.map(p => [p.type, p.value]));
        const y = Number(map.year);
        const m = Number(map.month) - 1; // 0-based months
        const d = Number(map.day);
        const hh = Number(map.hour);
        const mm = Number(map.minute);
        const ss = Number(map.second);

        // Construct a local Date using UK calendar parts.
        // We only need calendar correctness for computing ISO yyyy-mm-dd and hour checks.
        return new Date(y, m, d, hh, mm, ss, 0);
    }

    /**
     * 🔹 Apply the "from today/tomorrow" min-date rule when:
     *  - marketSectorCode === 'I'
     *  - workRequestFlag === false
     * Does not pre-select or dispatch; only sets minSelectableDate.
     */
    applyUkCutoffMinDateIfNeeded() {
        if (this.marketSectorCode === 'I' && !this.workRequestFlag) {
            const ukNow = this.getUkNow();
            const ukMidnight = new Date(ukNow.getFullYear(), ukNow.getMonth(), ukNow.getDate());
            const earliest =
                ukNow.getHours() >= 17
                    ? new Date(ukMidnight.getFullYear(), ukMidnight.getMonth(), ukMidnight.getDate() + 1)
                    : ukMidnight;

            this.minSelectableDate = this.toISODate(earliest);
        }
    }

    // Build calendar and mark disabled dates
    async buildCalendar() {
        // 🔹 Re-assert UK cutoff rule (no-op unless sector === 'I' && !workRequestFlag)
        this.applyUkCutoffMinDateIfNeeded();

        const days = [];
        const firstDay = new Date(this.currentYear, this.currentMonth, 1).getDay();
        const numDays = new Date(this.currentYear, this.currentMonth + 1, 0).getDate();

        this.monthLabel = new Date(this.currentYear, this.currentMonth).toLocaleString('default', {
            month: 'long',
            year: 'numeric'
        });

        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const start = new Date(this.currentYear, this.currentMonth, 1);
        const end = new Date(this.currentYear, this.currentMonth, numDays);
        await this.loadHolidays(start, end);

        // empty leading cells
        for (let i = 0; i < firstDay; i++) {
            days.push({ key: `empty-${i}`, day: '', cssClass: 'empty' });
        }

        // calendar cells
        for (let d = 1; d <= numDays; d++) {
            const dateObj = new Date(this.currentYear, this.currentMonth, d);
            dateObj.setHours(0, 0, 0, 0);

            const iso = this.toISODate(dateObj);
            const isWeekend = dateObj.getDay() === 0 || dateObj.getDay() === 6;
            const isHoliday = this.holidaySet.has(iso);

            let cssClass = 'day';

            // Visual hint (not disabled by itself)
            if (isWeekend || isHoliday) {
                cssClass += ' weekend';
            }

            // Disable dates before computed min date (if set)
            if (this.minSelectableDate && iso < this.minSelectableDate) {
                cssClass += ' disabled';
            }

            // Existing mode rules
            if (this.mode === 'future' && dateObj < today) {
                cssClass += ' disabled';
            }
            if (this.mode === 'past' && dateObj >= today) {
                cssClass += ' disabled';
            }

            // If blocking non-working days (for WR), also disable those
            if (this.blockNonWorkingDays && (isWeekend || isHoliday)) {
                cssClass += ' disabled';
            }

            // Optional: visual hint for the minimum date
            if (this.minSelectableDate && iso === this.minSelectableDate) {
                cssClass += ' min-date-hint';
            }

            days.push({ key: iso, day: d, iso, cssClass, isWeekend, isHoliday });
        }

        this.calendarDays = days;
    }

    async loadHolidays(startDate, endDate) {
        try {
            const result = await getHolidaysBetween({
                startDate: startDate.toISOString().slice(0, 10),
                endDate: endDate.toISOString().slice(0, 10)
            });
            this.holidaySet = new Set(result || []);
        } catch (error) {
            // eslint-disable-next-line no-console
            console.error('Holiday fetch failed', error);
            this.holidaySet = new Set();
        }
    }

    toISODate(date) {
        const y = date.getFullYear();
        const m = String(date.getMonth() + 1).padStart(2, '0');
        const d = String(date.getDate()).padStart(2, '0');
        return `${y}-${m}-${d}`;
    }

    formatDateDisplay(isoDate) {
        const [year, month, day] = isoDate.split('-');
        return `${day}/${month}/${year}`; // DD/MM/YYYY
    }

    // Keyboard accessibility: Enter/Space to pick a focused cell
    handleKeySelect(event) {
        if (event.key === 'Enter' || event.key === ' ') {
            this.handleSelectDate(event);
        }
    }

    handleSelectDate(event) {
        const iso = event.currentTarget.dataset.date;
        if (!iso) return;

        const clicked = this.calendarDays.find((d) => d.iso === iso);
        if (!clicked) return;

        // Block invalid selections
        if (
            clicked.cssClass.includes('disabled') ||
            (this.blockNonWorkingDays && (clicked.isWeekend || clicked.isHoliday)) ||
            (this.minSelectableDate && iso < this.minSelectableDate)
        ) {
            return;
        }

        // ✅ Only here do we set the label & notify parent
        this.selectedDateLabel = this.formatDateDisplay(iso);
        this.errorMessage = '';
        this.isCalendarOpen = false;
        this.removeOutsideClickHandler();

        this.dispatchEvent(new CustomEvent('dateselected', { detail: { date: iso } }));
    }

    handleManualInput(event) {
        let val = event.target.value.trim();
        val = val.replace(/[^0-9-]/g, ''); // allow digits & hyphens only
        event.target.value = val;

        if (val && !/^\d{2}-\d{2}-\d{4}$/.test(val)) {
            this.errorMessage = 'Enter valid date format: DD-MM-YYYY';
            return;
        }

        if (!val) {
            this.errorMessage = '';
            return;
        }

        const [day, month, year] = val.split('-').map(Number);
        const dateObj = new Date(year, month - 1, day);
        if (isNaN(dateObj.getTime())) {
            this.errorMessage = 'Invalid date entered.';
            return;
        }

        const today = new Date();
        today.setHours(0, 0, 0, 0);
        dateObj.setHours(0, 0, 0, 0);

        // block non-working days for WR
        if (this.blockNonWorkingDays) {
            const iso = this.toISODate(dateObj);
            const dow = dateObj.getDay();
            const isWeekend = dow === 0 || dow === 6;
            const isHoliday = this.holidaySet.has(iso);

            if (isWeekend || isHoliday) {
                this.errorMessage = isHoliday
                    ? 'Selected date is a bank holiday.'
                    : 'Weekends are not selectable.';
                return;
            }
        }

        // Enforce minSelectableDate for manual entry too
        if (this.minSelectableDate && this.toISODate(dateObj) < this.minSelectableDate) {
            this.errorMessage = 'Date cannot be earlier than the allowed minimum.';
            return;
        }

        if (this.mode === 'future' && dateObj < today) {
            this.errorMessage = 'Please select today or a future date.';
            return;
        }

        if (this.mode === 'past' && dateObj >= today) {
            this.errorMessage = 'Please select a past date only.';
            return;
        }

        this.errorMessage = '';
        this.selectedDateLabel = val; // keep entered format DD-MM-YYYY

        // Notify parent using ISO
        this.dispatchEvent(
            new CustomEvent('dateselected', { detail: { date: this.toISODate(dateObj) } })
        );
    }

    async calculateWorkingDate(startDate, offsetDays) {
        let count = 0;
        let current = new Date(startDate);
        current.setHours(0, 0, 0, 0);

        // Load enough holidays ahead (safe buffer)
        const end = new Date(current);
        end.setDate(end.getDate() + 60);
        await this.loadHolidays(current, end);

        // 🔹 If today is a weekend/holiday, move to the next working day first
        while (true) {
            const iso = this.toISODate(current);
            const day = current.getDay();
            const isWeekend = day === 0 || day === 6;
            const isHoliday = this.holidaySet.has(iso);

            if (!isWeekend && !isHoliday) break; // stop when it's a working day
            current.setDate(current.getDate() + 1); // advance to next day
        }

        // 🔹 Now apply your original offset logic (excluding current day from count)
        while (count < (offsetDays - 1)) {
            current.setDate(current.getDate() + 1);

            const iso = this.toISODate(current);
            const day = current.getDay();
            const isWeekend = day === 0 || day === 6;
            const isHoliday = this.holidaySet.has(iso);

            if (!isWeekend && !isHoliday) {
                count++;
            }
        }

        return current;
    }

    async initAutoWorkingDate() {
        const today = new Date();

        const targetDate = await this.calculateWorkingDate(today, this.workingDayOffset);
        const iso = this.toISODate(targetDate);

        // ✅ Only constrain selection; do not prefill the input or dispatch event
        this.minSelectableDate = iso;

        // Position calendar to the month of the min date so user sees where to click
        this.currentMonth = targetDate.getMonth();
        this.currentYear = targetDate.getFullYear();

        await this.buildCalendar();
    }
}