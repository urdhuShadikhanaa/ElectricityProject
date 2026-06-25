import { LightningElement, api } from 'lwc';

export default class UwrSubmitPopup extends LightningElement {
    @api srNumber;                 // optional: 'SR-1234'
    @api jobType = 'Residential';  // 'Residential' | 'Commercial'
    @api baseTime;                 // optional: ISO or 'YYYY-MM-DDTHH:mm'

    statusMsg = 'Component loaded';
    showModal = false;
    confirmMessage = '';

    connectedCallback() {
        // Prove JS loaded
        // eslint-disable-next-line no-console
        console.log('[uwrSubmitPopup] connectedCallback');
        this.statusMsg = 'Ready';
    }

    pad(n) { return String(n).padStart(2, '0'); }

    get srForMessage() {
        const val = (this.srNumber ?? '').toString().trim();
        return val || 'SR-Number';
    }

    hoursFor(jobType) {
        const j = (jobType || '').toLowerCase();
        return j === 'residential' ? 3 : 4;
    }

    toDate(val) {
        if (!val) return new Date();
        if (val instanceof Date) return val;
        return new Date(val);
    }

    fmt(d) {
        return {
            dd: this.pad(d.getDate()),
            mm: this.pad(d.getMonth() + 1),
            yyyy: d.getFullYear(),
            hh: this.pad(d.getHours()),
            mi: this.pad(d.getMinutes())
        };
    }

    handleSubmit = () => {
        try {
            // eslint-disable-next-line no-console
            console.log('[uwrSubmitPopup] handleSubmit clicked');
            this.statusMsg = 'Submit clicked';

            // Prevent double modal if user double-clicks
            if (this.showModal) {
                return;
            }

            const sr = this.srForMessage;
            const hours = this.hoursFor(this.jobType);
            const base = this.toDate(this.baseTime || new Date());
            const { dd, mm, yyyy, hh, mi } = this.fmt(base);

            const msg =
                `An urgent work request "${sr}" has been submitted ` +
                `and is planned to complete in "${hours}" hours on ${dd}/${mm}/${yyyy} from ${hh}:${mi} ` +
                `(This should be based on slot or time submitted)`;

            // ---- SHOW MODAL INSTEAD OF ALERT ----
            this.confirmMessage = msg;
            this.showModal = true;

            // Optional: improve accessibility by focusing modal after render
            requestAnimationFrame(() => {
                const modal = this.template.querySelector('.slds-modal');
                if (modal && typeof modal.focus === 'function') {
                    modal.focus();
                }
            });

            this.statusMsg = 'Message';
        } catch (e) {
            this.statusMsg = 'Error - open console';
            // eslint-disable-next-line no-console
            console.error('[uwrSubmitPopup] Error in handleSubmit', e);
        }
    };

    // For the modal buttons/backdrop
    closeModal = () => {
        this.showModal = false;
        this.confirmMessage = '';
        this.statusMsg = 'Not Submitted';
    };

    confirmModal = () => {
        // Optional: fire a custom event so parent can react
        this.dispatchEvent(new CustomEvent('confirmed', {
            detail: {
                srNumber: this.srForMessage,
                jobType: this.jobType,
                baseTime: this.toDate(this.baseTime),
                plannedHours: this.hoursFor(this.jobType)
            },
            bubbles: true,
            composed: true
        }));

        this.showModal = false;
        this.confirmMessage = '';
        this.statusMsg = 'Saved Successfully';
    };
}