import { LightningElement, track, wire, api } from "lwc";
import workOrdersearch from "@salesforce/apex/NGMCP_RequestSearchController.workOrdersearch";
import getParentAccountFiles from "@salesforce/apex/NGMCP_RequestSearchController.getParentAccountFiles";
import { getRecord } from 'lightning/uiRecordApi';
import basePath from '@salesforce/community/basePath';
//import getParentAccountFilesByWorkOrderId from '@salesforce/apex/NGMCP_RequestSearchController.getParentAccountFilesByWorkOrderId';
import ngAssets from "@salesforce/resourceUrl/NGMCP_SearchMPRN";
import getUserSupplierCodeOptions from "@salesforce/apex/NGMCP_UserDependentPicklistController.getUserSupplierCodeOptions";
const FIELDS = ['WorkOrder.FFA_Sender_ID__c'];


const PAGE_SIZE = 20;

export default class NGMCP_viewWorkOrderComponent extends LightningElement {
  @api filters = {
    mprn: "",
    wo: "",
    createdFrom: "",
    createdTo: "",
    shortCode: ""
  };

  @api requestLoggerFlag = false;

  @track filltersFlag = false;
  @track selectedRecordId;
  @track showdownloadRams;
  @track recordTypeName = "WorkOrder";

  @track shortCodes = [];
  @track options = [];

  homepageAssets = ngAssets;

  /* ---------------- TABLE ---------------- */
  columns = [
    { key: "WorkOrderNumber", label: "Work Order" },
    { key: "jobCode", label: "Job Code" },
    { key: "jobDescription", label: "Job Description" },
    { key: "mprn", label: "MPRN" },
    { key: "SupplierId", label: "Supplier Code" },
    { key: "status", label: "Status" },
    { key: "createdDate", label: "Created Date" }
  ];

  /* ---------------- STATE ---------------- */
  allData = [];
  @track isTableLoading = true;
  @track isLoading = false;
  error;

  sortKey = "createdDate";
  sortDir = "desc";

  page = 1;

  @wire(getRecord, { recordId: '$selectedRecordId', fields: FIELDS })
  userRecord({ error, data }) {
    if (data) {
      console.log('data', JSON.stringify(data))
      this.showdownloadRams = data.fields.FFA_Sender_ID__c.value == 'PHOENIX' ? true : false;
      console.log('showdownload', this.showdownloadRams)
    }
  }
  /* =========================
     SUPPLIER CODES
  ========================== */
  @wire(getUserSupplierCodeOptions)
  wiredOptions({ data, error }) {
    if (data) {
      this.options = data;
      this.shortCodes = [...new Set(data.map(o => o.value))];

      // Default filter = ALL supplier codes
      if (!this.requestLoggerFlag) {
        this.isTableLoading = true;
        this.filters = {
          ...this.filters,
          shortCode: this.shortCodes.join(",")
        };
      }
    } else if (error) {
      console.error(error);
      this.options = [];
    }
  }

  /* =========================
     SEARCH RESULTS
  ========================== */
  @wire(workOrdersearch, {
    mprn: "$filters.mprn",
    wo: "$filters.wo",
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
      console.log('rams', data[0]);
      if (data.length === 1 && !this.requestLoggerFlag) {
        this.selectedRecordId = data[0].id;
        // this.showdownloadRams = data[0].FFA_Sender_ID__c == 'PHOENIX'
        console.log('rams', data[0].FFA_Sender_ID__c);
        return;
      }

      this.allData = data.map(d => ({
        ...d,
        createdDate: d.createdDate,
      }));

      this.page = 1;
    } else if (error) {
      this.error = error;
      this.allData = [];
      console.error(error);
    }
  }
  /* =========================
     FILTER INPUTS
  ========================== */
  /* handleInput(event) {
    const key = event?.target?.dataset?.key;
    if (!key) return;
  
    // Normalize value once; only trim if it's a string
    let value = event?.target?.value;
    if (typeof value === 'string') value = value.trim();
  
    if (key === 'shortCode') {
      const shortcodeValues =
        Array.isArray(this.shortCodes) && this.shortCodes.length
          ? this.shortCodes.join(',')
          : '';
  
      const isEmpty = value == null || (typeof value === 'string' && value.length === 0);
      Promise.resolve().then(() => {
        this.filters = {
          ...this.filters,
          shortCode: isEmpty ? shortcodeValues : value
        };
        this.page = 1;
      });
    } else {
      // Defer state update for all other keys too
      Promise.resolve().then(() => {
        this.filters = { ...this.filters, [key]: value };
        this.page = 1;
      });
    }
  }*/

  /* =========================
     ROWS (VISIBLE DATA)
  ========================== */
  get rows() {
    const filtered = this.applyClientFilters(this.allData);
    const sorted = this.applySort(filtered);
    const paged = this.applyPagination(sorted);

    return paged.map(d => {
      const statusLower = (d.status || "").toLowerCase();
      const statusClass =
        statusLower === "completed"
          ? "status-completed"
          : statusLower === "in progress"
            ? "status-inprogress"
            : "status-default";

      return {
        id: d.id,
        WorkOrderNumber: d.WorkOrderNumber,
        jobCode: d.jobCode,
        jobDescription: d.jobDescription,
        mprn: d.mprn,
        SupplierId: d.SupplierId,
        status: d.status,
        statusCellClass: `grid-cell status-cell ${statusClass}`,
        createdDateFormatted: d.createdDate
      };
    });
  }

  /* =========================
     FILTER / SORT / PAGINATION
  ========================== */

  applyClientFilters(data) {
    if (!this.filters.shortCode) return data;

    const allowed = this.filters.shortCode.split(",");
    return data.filter(r => allowed.includes(r.SupplierId));
  }

  applySort(data) {
    const mult = this.sortDir === "asc" ? 1 : -1;

    return [...data].sort((a, b) => {
      const va = a[this.sortKey];
      const vb = b[this.sortKey];

      if (this.sortKey === "mprn") {
        return ((parseInt(va, 10) || 0) - (parseInt(vb, 10) || 0)) * mult;
      }

      if (this.sortKey === "createdDate") {
        return (new Date(va) - new Date(vb)) * mult;
      }

      return (va || "").toString().localeCompare((vb || "").toString()) * mult;
    });
  }

  applyPagination(data) {
    const start = (this.page - 1) * PAGE_SIZE;
    return data.slice(start, start + PAGE_SIZE);
  }

  get totalPages() {
    return Math.max(1, Math.ceil(this.allData.length / PAGE_SIZE));
  }

  get isPrevDisabled() {
    return this.page <= 1;
  }

  get isNextDisabled() {
    return this.page >= this.totalPages;
  }

  handleDownloadFiles() {
    console.log('handleDownloadFiles');
    if (!this.selectedRecordId) {
      console.warn('No Work Order selected');
      return;
    }
    this.isLoading = true;
    // console.log('this.workOrderNumber: ', this.selectedRecordId);
    getParentAccountFiles({ workOrderId: this.selectedRecordId })
      .then(files => (files || []).forEach(f => f?.Id && this.downloadFile(f.Id)))

      .catch(error => {
        console.error('Download failed', error);
      })
      .finally(() => {
        this.isLoading = false;
      });
  }
  downloadFile(contentVersionId) {
    console.log('this.contentVersionId: ', contentVersionId);
    // Experience Cloud SAFE

    const url =
      `${basePath}/sfc/servlet.shepherd/version/download/${contentVersionId}`;

    // IMPORTANT: _self (not _blank)
    window.open(url, '_self');
  }
  /* =========================
     EVENTS
  ========================== */

  handleSort(event) {
    const key = event.currentTarget.dataset.key;
    if (this.sortKey === key) {
      this.sortDir = this.sortDir === "asc" ? "desc" : "asc";
    } else {
      this.sortKey = key;
      this.sortDir = "asc";
    }
    this.page = 1;
  }

  prevPage = () => {
    if (this.page > 1) this.page--;
  };

  nextPage = () => {
    if (this.page < this.totalPages) this.page++;
  };

  handleSelectRecord(event) {
    this.selectedRecordId = event.currentTarget.dataset.id;
  }
  connectedCallback() {
    if (!this.filters || typeof this.filters !== 'object') {
      this.filters = {};
    }

    // Normalize both date values so <input value=...> always gets a safe string
    const next = { ...(this.filters || {}) };
    const fix = (v) => (typeof v === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(v.trim())) ? v.trim() : '';
    next.createdFrom = fix(next.createdFrom);
    next.createdTo = fix(next.createdTo);
    this.filters = next;

    // After render, ensure the correct chips show has-value if inputs already have values.
    // (Allowed change inside the same function; no new functions added.)
    setTimeout(() => {
      try {
        const root = this.template;
        const inputs = root.querySelectorAll('input.chip-input-date[type="date"]');
        inputs.forEach((inp) => {
          const chip = inp.closest('.chip');
          if (chip) {
            const hasVal = typeof inp.value === 'string' && inp.value.trim();
            chip.classList.toggle('has-value', !!hasVal);
          }
        });
      } catch (_e) {
        // no-op
      }
    }, 0);
  }

  stopEvent(e) {
    e?.stopPropagation?.();
  }

  openCalendar(event) {
    event?.stopPropagation?.();
    const chipEl = event?.currentTarget;
    // Scope to the clicked chip so it works for createdFrom/createdTo independently
    const input = chipEl?.querySelector?.('input.chip-input-date[type="date"]');

    if (input) {
      Promise.resolve().then(() => {
        if (typeof input.showPicker === 'function') {
          try {
            input.showPicker();
          } catch {
            input.focus();
          }
        } else {
          input.focus();
        }
      });
    }
  }

  // handleFocusDate(event) {
  //   const chip = event?.target?.closest?.('.chip');
  //   if (chip) chip.classList.add('is-focused');
  // }

  // handleBlurDate(event) {
  //   const input = event?.target;
  //   const chip = input?.closest?.('.chip');
  //   setTimeout(() => {
  //     if (chip) {
  //       chip.classList.remove('is-focused');
  //       const hasVal = typeof input?.value === 'string' && input.value.trim();
  //       chip.classList.toggle('has-value', !!hasVal);
  //     }
  //   }, 0);
  // }

  handleFocusDate = (event) => {
    event.target.classList.add('is-focused');
  };
  handleBlurDate = (event) => {
    const input = event.target;
    input.classList.remove('is-focused');
    if (!input.value) {
      input.classList.remove('has-value');
    }
  };
  formatDate(value) {
    if (!value) return "";
    const d = new Date(value);
    return `${String(d.getDate()).padStart(2, "0")}/${String(
      d.getMonth() + 1
    ).padStart(2, "0")}/${d.getFullYear()}`;
  }
  handleInput = (event) => {
    const key = event.target.dataset.key;
    const val = event.target.value; // value from <input type="date"> is 'YYYY-MM-DD'
    this.isTableLoading = true;
    this.filters = { ...this.filters, [key]: val };

    // Mark input as having value so CSS can show native date text
    if (val && val.trim() !== '') {
      event.target.classList.add('has-value');
    } else {
      event.target.classList.remove('has-value');
    }
  };


  handleInput(event) {
    if (event && event.isComposing) return;

    const target = event?.target;
    const key = target?.dataset?.key; // "createdFrom" or "createdTo" or others
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

      // Immediately reflect UI so the placeholder hides/show correctly for each chip
      const chip = target?.closest?.('.chip');
      if (chip) chip.classList.toggle('has-value', !!raw);
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
        next[key] = raw; // updates createdFrom/createdTo or any other key
        this.filters = next;
        this.page = 1;
      });
    }
  }
  handleBackResponse() {
    this.selectedRecordId = null;
  }
  handleBackBUtton(){
    window.location.reload();
  }
  handleDownloadresponse(event) {
  console.log('handleDownloadresponse detail:', event?.detail);
  const detail = event?.detail || {};
  this.selectedRecordId =
    detail.selectedRecordId ??
    detail.payload?.selectedRecordId ??
    null;
  if (!this.selectedRecordId) {
    console.warn('Selected record id not found in event detail:', detail);
    return; 
  }
  this.handleDownloadFiles();
}
}