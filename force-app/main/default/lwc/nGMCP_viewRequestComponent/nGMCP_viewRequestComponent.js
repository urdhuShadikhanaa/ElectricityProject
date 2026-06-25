import { LightningElement, track, wire, api } from "lwc";
import search from "@salesforce/apex/NGMCP_RequestSearchController.search";
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import ngAssets from "@salesforce/resourceUrl/NGMCP_SearchMPRN";
import FFA_SENDER from '@salesforce/schema/WorkOrder.FFA_Sender_ID__c';
import getUserSupplierCodeOptions from "@salesforce/apex/NGMCP_UserDependentPicklistController.getUserSupplierCodeOptions";
const FIELDS = ['WorkOrder.FFA_Sender_ID__c'];
const PAGE_SIZE = 10;

export default class RequestSearchPanel extends LightningElement {

  /* =========================
     API & STATE
  ========================== */
  @api requestLoggerFlag = false;
  @api filltersFlag = false;
  @api parentFlag = false;
  @api showdownloadRams;
  @api filters = {
    mprn: "",
    sr: "",
    createdFrom: "",
    createdTo: "",
    shortCode: ""
  };
  @track wororderNumber;
  @track sortKey = "createdDate";
  @track sortDir = "desc";
  @track page = 1;

  @track selectedRecordId;
  @track recordTypeName;

  @track options = [];
  @track shortCodes = [];

  @track allData = [];
  @track isTableLoading = true;
  error;

  homepageAssets = ngAssets;

  columns = [
    { key: "name", label: "Request Number" },
    { key: "srNumber", label: "Service Request" },
    { key: "recordType", label: "Record Type" },
    { key: "mprn", label: "MPRN" },
    { key: "jobCode", label: "Job Code" },
    { key: "jobSubCode", label: "Job Sub Code" },
    { key: "shortCode", label: "Supplier Code" },
    { key: "status", label: "Status" },
    { key: "createdDate", label: "Created Date" }
  ];


     @wire(getRecord, { recordId: '$recordId', fields: [FFA_SENDER] })
    wiredSender({ error, data }) {
       if (data) {
           const sender = data.fields.FFA_Sender_ID__c.value;
           console.log('Sender:', sender);
           this.showdownloadRams = sender === 'PHOENIX';
           console.log('showdownloadRams:', this.showdownloadRams);
       }
        }

         wiredRecord({ data, error }) {
        if (error) {
            this.setError(error);
            return;
        }
        if (data) {
            // Derive objectApiName: no need to pass it explicitly
            if (!this.objectApiName && data.apiName) {
                this.objectApiName = data.apiName; // Reactively triggers getObjectInfo
            }            
            this.recordTypeId = data.recordTypeId;
            // Header name; fall back to the object apiName if Name doesn't exist
            this.recordDisplayName = this.safeGet(data, 'fields.Name.value') || data.apiName;
            if (data.apiName === 'NGMCP_Request__c') {
                this.ticketId = this.safeGet(data, 'fields.NGMCP_SR_Ticket__c.value');
            } else if (data.apiName === 'WorkOrder') {
                this.wororderNumber = this.safeGet(data, 'fields.WorkOrderNumber.value');
            }
            //this.recordTypeName =  this.recordDisplayName;
            this.computeActiveRecordTypeName();
            this.ready = true;
            console.log('this.recordDisplayName', this.recordDisplayName);
            console.log('this.recordTypeId', this.recordTypeId);
            console.log('this.this.ready', this.ready);
            console.log('this.ticketId', this.ticketId);
            console.log('wororderNumber:', this.wororderNumber);
        }
        this.finishIfReady();
    }
  /* =========================
     SUPPLIER CODES
  ========================== */
  @wire(getUserSupplierCodeOptions)
  wiredOptions({ data, error }) {
    if (data) {
      this.options = data.map(o => ({ label: o.label, value: o.value }));
      this.shortCodes = [...new Set(this.options.map(o => o.value))];

      const csv = this.shortCodes.join(",");
      console.log('parentFlag', this.requestLoggerFlag);
      console.log('parentFlag',JSON.stringify(this.filters));

      if (!this.requestLoggerFlag && !this.parentFlag) {
            if (this.filters?.shortCode !== csv) {
                this.isTableLoading = true;
                this.filters = {
                    ...this.filters,
                    shortCode: csv
                };
            }
        }
    } else if (error) {
      this.options = [];
      console.error(error);
    }
  }

  /* =========================
     SEARCH (WIRE)
  ========================== */
  @wire(search, {
    mprn: "$filters.mprn",
    sr: "$filters.sr",
    createdFrom: "$filters.createdFrom",
    createdTo: "$filters.createdTo",
    shortCode: "$filters.shortCode"
  })
  wiredData({ data, error }) {
    this.isTableLoading = false;
    if (data) {
      this.error = undefined;

      if (this.requestLoggerFlag) {
        this.filltersFlag = true;
      }

      if (data.length === 1 && !this.requestLoggerFlag) {
        this.selectedRecordId = data[0].id;
        this.recordTypeName = data[0].recordType;
      } else {
        this.allData = data.map(d => ({
          ...d,
          nameUrl: d.nameUrl || `/lightning/r/NGMCP_Request__c/${d.id}/view`,
          recordTypeUrl: d.recordTypeUrl || "#"
        }));
        this.page = 1;
      }
    } else if (error) {
      this.error = error;
      this.allData = [];
      console.error(error);
    }
  }

  /* =========================
     ROW SELECTION
  ========================== */
  handleSelectRecord(event) {
    console.log('handleSelectRecord');
    console.log('dataset', event.currentTarget?.dataset);
    const recordId = event.currentTarget?.dataset?.id;

    if (!recordId) return;

    this.selectedRecordId = recordId;

    const rec = this.allData.find(r => r.id === recordId);
    if (rec) {
      this.recordTypeName = rec.recordType;
    }
    console.log('recordTypeName', this.recordTypeName);
  }

  /* =========================
     FILTER INPUTS
  ========================== 
 handleInput(event) {
  const key = event.target?.dataset?.key;
  const value = event.target?.value;
  const isEmpty = value == null || (typeof value === 'string' && value.trim() === '');
  if (key === 'shortCode') {
    const shortcodeValues = Array.isArray(this.shortCodes) && this.shortCodes.length
      ? this.shortCodes.join(',')
      : '';
    this.filters = {
      ...this.filters,
      shortCode: isEmpty ? shortcodeValues : value.trim?.() ?? value
    };
  } else {
    this.filters = { ...this.filters, [key]: value };
  }

  this.page = 1;
}*/


  /* =========================
     SEARCH BUTTON
  ========================== */
  async handleSearch() {
    this.isTableLoading = true;
    try {
      const data = await search({
        mprn: this.filters.mprn,
        sr: this.filters.sr,
        createdFrom: this.filters.createdFrom,
        createdTo: this.filters.createdTo,
        shortCode: this.filters.shortCode
      });

      this.allData = data.map(d => ({
        ...d,
        nameUrl: d.nameUrl || `/lightning/r/NGMCP_Request__c/${d.id}/view`,
        recordTypeUrl: d.recordTypeUrl || "#"
      }));

      this.page = 1;
    } catch (e) {
      this.error = e;
      this.allData = [];
      console.error(e);
    } finally {
      this.isTableLoading = false;
    }
  }

  /* =========================
     SORTING
  ========================== */
  handleSort(event) {
    const key = event.currentTarget.dataset.key;
    console.log("handleSort", key);
    if (this.sortKey == key) {
      this.sortDir = this.sortDir === "asc" ? "desc" : "asc";
    } else {
      this.sortKey = key;
      this.sortDir = "asc";
    }
    this.page = 1;
  }

  /* =========================
     PAGINATION
  ========================== */
  get totalPages() {
    return Math.max(1, Math.ceil(this.filteredData.length / PAGE_SIZE));
  }

  get isPrevDisabled() {
    return this.page <= 1;
  }

  get isNextDisabled() {
    return this.page >= this.totalPages;
  }

  prevPage() {
    if (this.page > 1) this.page--;
  }

  nextPage() {
    if (this.page < this.totalPages) this.page++;
  }

  /* =========================
     DATA PIPELINE
  ========================== */
  get filteredData() {
    let data = [...this.allData];

    if (this.filters.shortCode) {
      const allowed = this.filters.shortCode.split(",");
      data = data.filter(r => allowed.includes(r.shortCode));
    }

    return data;
  }

  get sortedData() {
    const mult = this.sortDir === "asc" ? 1 : -1;
    return [...this.filteredData].sort((a, b) => {
      const va = a[this.sortKey];
      const vb = b[this.sortKey];

      if (this.sortKey == "createdDate") {
        return (new Date(va) - new Date(vb)) * mult;
      }

      return (va || "").toString().localeCompare((vb || "").toString()) * mult;
    });
  }

  get rows() {
    const start = (this.page - 1) * PAGE_SIZE;
    return this.sortedData.slice(start, start + PAGE_SIZE).map(r => {
      const status = (r.status || "").toLowerCase();
      return {
        ...r,
        statusCellClass:
          status === "completed"
            ? "grid-cell status-completed"
            : status === "in progress"
              ? "grid-cell status-inprogress"
              : "grid-cell status-default",
        createdDate: this.formatDate(r.createdDate)
      };
    });
  }

  /* =========================
     UTILS
  ========================== */
  formatDate(value) {
    if (!value) return "";
    const d = new Date(value);
    return `${String(d.getDate()).padStart(2, "0")}/${String(
      d.getMonth() + 1
    ).padStart(2, "0")}/${d.getFullYear()}`;
  }
  handleInput = (evt) => {
    const key = evt.target.dataset.key;
    const val = evt.target.value; // value from <input type="date"> is 'YYYY-MM-DD'
    this.isTableLoading = true;
    this.filters = { ...this.filters, [key]: val };

    // Mark input as having value so CSS can show native date text
    if (val && val.trim() !== '') {
      evt.target.classList.add('has-value');
    } else {
      evt.target.classList.remove('has-value');
    }
  };

  handleFocusDate = (evt) => {
   evt.target.classList.add('is-focused');
};
handleBlurDate = (evt) => {
   const input = evt.target;
   input.classList.remove('is-focused');
   if (!input.value) {
       input.classList.remove('has-value');
   }
};
// handleInput = (evt) => {
//    const key = evt.target.dataset.key;
//    const val = evt.target.value;
//    this.filters = { ...this.filters, [key]: val };
//    if (val) {
//        evt.target.classList.add('has-value');
//    } else {
//        evt.target.classList.remove('has-value');
//    }
// };

  // handleFocusDate = (evt) => {
  //   // Hide overlay placeholder while focusing
  //   const span = evt.target.nextElementSibling;
  //   if (span && span.classList.contains('placeholder')) {
  //     span.style.display = 'none';
  //   }
  // };

  // handleBlurDate = (evt) => {
  //   const span = evt.target.nextElementSibling;
  //   // If empty on blur, show overlay placeholder back
  //   if (!evt.target.value) {
  //     evt.target.classList.remove('has-value');
  //     if (span && span.classList.contains('placeholder')) {
  //       span.style.display = '';
  //     }
  //   }
  // };
  openCalendar = (evt) => {
    // Find the input inside the clicked chip container
    const container = evt.currentTarget;
    const input = container.querySelector('input[type="date"]');
    if (!input) return;

    // Focus first (required by some browsers)
    input.focus();

    // If showPicker is supported (Chrome/Edge), use it
    if (typeof input.showPicker === 'function') {
      try {
        input.showPicker();
      } catch (e) {
        // Fallback below if showPicker throws
        this._openDatePickerFallback(input);
      }
    } else {
      // Fallback for browsers without showPicker (e.g., older Safari/Firefox)
      this._openDatePickerFallback(input);
    }
  };

  _openDatePickerFallback(input) {
    // Try a gentle key event that often opens the date UI in some browsers
    try {
      const e = new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true });
      input.dispatchEvent(e);
    } catch (_) {
      // As a last resort: keep focus; user can press Enter/Space or click the icon
    }
  }
  handleInput(event) {
    if (event && event.isComposing) return;

    const target = event?.target;
    const key = target?.dataset?.key;
    if (!key) return;

    let raw = target.value;

    if (target.type === 'date') {
      if (raw == null) {
        raw = '';
      } else if (typeof raw !== 'string') {
        raw = '';
      } else {
        raw = raw.trim();
        if (!/^\d{4}-\d{2}-\d{2}$/.test(raw)) raw = '';
      }
    } else {
      if (raw == null) {
        raw = '';
      } else if (typeof raw === 'string') {
        raw = raw.trim();
      } else if (Number.isNaN(raw)) {
        raw = '';
      }
    }

    if (key === 'shortCode') {
      const shortcodeValues =
        Array.isArray(this.shortCodes) && this.shortCodes.length
          ? this.shortCodes.join(',')
          : '';
      const isEmpty = raw === '';

      Promise.resolve().then(() => {
        this.isTableLoading = true;
        const next = { ...(this.filters || {}) };
        next.shortCode = isEmpty ? shortcodeValues : raw;
        this.filters = next;
        this.page = 1;
      });
    } else {
      Promise.resolve().then(() => {
        this.isTableLoading = true;
        const next = { ...(this.filters || {}) };
        next[key] = raw;
        this.filters = next;
        this.page = 1;
      });
    }
  }
  handleBackResponse(){
    this.selectedRecordId = null;
  }
  handleBackBUtton(){
    window.location.reload();
  }

}