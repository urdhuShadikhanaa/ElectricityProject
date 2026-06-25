import { LightningElement, track, wire, api } from "lwc";
import getAllMeterModelConfigs from "@salesforce/apex/NGMCP_WorkRequestController.getAllMeterModelConfigs";
import getAllHousingModelConfigs from "@salesforce/apex/NGMCP_WorkRequestController.geAlltHousingModels";
import getPrice from "@salesforce/apex/NGMCP_WorkRequestController.getPrice";
import validateDeuplicateRequest from '@salesforce/apex/NGMCP_WorkRequestController.validateDeuplicateRequest';
//import success from "@salesforce/resourceUrl/success";
// Salesforce Experience Cloud limit ~10 MB per file
const MAX_FILE_SIZE = 10 * 1024 * 1024;
//  4 Feb change for Third Party and Install Meter 
const GT1_VALIDATION_SUBTYPES = new Set([
  'Exchange_SpecificationChange',
  'Exchange_ThirdParty',
  'Install_Meter'
]);
/* Unified inline message for any failure */
const GT1_UNIFIED_WARNING =
  'GT1 peak hourly load kWh may not be sufficient for requested usage and/or valid date has expired. ' +
  'Please note that any incorrect information may result in the request being delayed or an aborted visit.';
// 4 feb change end here 
export default class NGMCP_workRequestComponent extends LightningElement {

  @track showWorkRequest = true; // default is false
  @track outletPressure = 21;
  @track peakLoad = "";
  @api meterSize;
  @track serviceLocation;
  @track housingRequired;
  @track housingType;
  @track selectedMeterSize;
  @track selectedRequest;
  @track selectedJob;
  @track selectedSubType;
  @track filteredSubTypes = [];
  @track meterSuggestions = [];
  @track showGt1Upload = false;
  @track showGt1Error = false;
  @track changePaymentType;
  @track isPickupSubtype = false;
  @track showFinalRead = false;
  @track showAddressFields = false;
  @track state = {};
  @track debounceTimeout;
  @track selectedRequestType = '';
  @track selectedJobType = '';
  @track selectedSubTypeLabel = '';
  @track priceMessageFlag = false;
  @track priceMessage;
  @track meterModels = [];
  @track housingModels = [];
  @track selectJob = false;
  @track selectSubType = false;
  @track priceButtonFlag = false;
  @track jobSubType;
  @track showMeterErrorMessage = false;
  @track errorMessage = '';
  @track allUploadedPayloads = [];
  @api addressDetails;
  @api assetDetails;
  @api thirdParty;
  @api pressuretierBrand;
  @track mainJobMessage;
  @track additionalMessage;
  @track uploadedFiles = []; // for UI display
  uploadedFilePayload = []; // ready for API call
  @track isTable = true;
  @track uploadedFilesByKey = {};      // 9 jan change
  uploadedFilePayloadByKey = {};       // 9 jan change
  @track fileError = "";
  @track errors = {};   // mandatory required 28//11
  @track isLocked = false; // 10 dec change
  // 18 dec change
  @track _residentialU6Site = false;
  @track _residentialU6Provided = false; // NEW: whether parent supplied Yes/No
  @track _rerenderNudge = 0; // optional nudge to force recompute
  @api mprnInput;
  @track isModel = false;
  @track duplicateMessage;
  @track vatMessage;
  @api haszoo2;
  @api
  get residentialU6Site() {
    return this._residentialU6Site;
  }

  set residentialU6Site(val) {
    const isYes = (val === true || val === 'true' || val === 'Yes');
    const isNo = (val === false || val === 'false' || val === 'No');

    // mark whether a value was actually provided (Yes OR No)
    this._residentialU6Provided = (isYes || isNo);




    // Keep your original boolean value for business logic (Yes = true, No/Not provided = false)
    const boolVal = isYes;
    const prev = this._residentialU6Site;
    this._residentialU6Site = boolVal;
    // 6 jan change
    //  If we are in Install â†’ Meter AND Residential U6 = Yes, apply hard defaults
    if (boolVal && this.selectedSubType?.id === 'Install_Meter') {
      this.applyResidentialU6YesDefaults();
    }
    // 6 jan change end here
    // 5 jan change
    // When user selects "No" for Residential U6, hide & clear dependent answers
    if (!this._residentialU6Site) {
      if (!this.state) this.state = {};
      this.state.isNewConnection = null;
      this.state.isReconnection = null;
      this.state.isReconnectionDebt = null;

      if (!this.errors) this.errors = {};
      this.errors.isNewConnection = '';
      this.errors.isReconnection = '';
      this.errors.isReconnectionDebt = '';
      this.errors = { ...this.errors }; // force re-render
    }
    // 5 jan change end here
    // NEW: Auto-set "Is it a new connection?" for Install → Meter whenever parent U6 changes
    if (this.selectedSubType?.id === 'Install_Meter') {
      const newConn = this._residentialU6Provided ? 'Yes' : 'No';
      this.state = this.state || {};
      this.state.isNewConnection = newConn;
      this.errors = { ...(this.errors || {}), isNewConnection: '' };
    }

    // --- NEW: When U6 = No, remove this key from state+errors so it's not sent later ---
if (this._residentialU6Provided === true && this._residentialU6Site === false) {
  if (!this.state) this.state = {};
  delete this.state.isNewConnection;
  
  delete this.state.isReconnection;  // 7 march
  delete this.state.isReconnectionDebt;  // 7 march


  if (!this.errors) this.errors = {};
  delete this.errors.isNewConnection;
  delete this.state.isReconnection;  // 7 march
  delete this.state.isReconnectionDebt;  // 7 march

  // Optional: keep a small tombstone set if your payload builder needs it
  this._removedKeys = this._removedKeys || new Set();
  this._removedKeys.add('isNewConnection');
}
    this._rerenderNudge = Date.now(); // bump a tracked value to ensure re-render
    console.log('[Child] residentialU6Site set ->', this._residentialU6Site);
    const isInstallMeter =
      (this.selectedSubType?.id === 'Install_Meter') ||
      (this.selectedSubType?.label?.trim().toLowerCase() === 'meter');
  }
  // 18 dec change end here
  @api
  get status() {
    return this._status;
  }
  set status(value) {
    this._status = value;
    console.log('Status received:', this._status);
    // 4 march
    if (this.isIndependentResidentialInstall()) {
  this.applyIndependentResidentialDefaults();
  this._rerenderNudge = Date.now();
}
  // 4 march end
  }

  @api
  get paymentMechanism() {
    return this._paymentMechanism;
  }
  set paymentMechanism(value) {
    this._paymentMechanism = value;
    console.log('Payment Mechanism received:', this._paymentMechanism);
    // 8 jan change
    // // âœ… If we are on the targeted subtype, prefill state and nudge re-render
    //  const targeted = new Set(['Exchange_LikeForLike']);
    //  if (targeted.has(this.selectedSubType?.id) &&
    //      (value === 'Credit' || value === 'Pre payment')) {
    //    if (!this.state) this.state = {};
    //    this.state.paymentMethod = value;
    //    this._rerenderNudge = Date.now();
    //  }

    // If we are already on a targeted subtype, prefill now
    const validPm = (value === 'Credit' || value === 'Pre Payment');
    if (!validPm) return;
    const id = this.selectedSubType?.id;
    if (id === 'Exchange_LikeForLike') {
      this.state.paymentMethod = value;
      this._rerenderNudge = Date.now();
    }
    if (id === 'OtherVisits_Reconnect') {
      this.state.requiredPaymentType = value;
      this._rerenderNudge = Date.now();
    }
    if (id === 'Exchange_MeterType') {
      this.state.newMeterPaymentMethod = (value === 'Credit') ? 'Pre Payment' : 'Credit';
      this._rerenderNudge = Date.now();
    }
    // 8 jan change end here
  }
  @api
  get pressuretier() {
    return this._pressureTier;
  }

  set pressuretier(value) {
    this._pressureTier = value;
    console.log('pressureTier received:', this._pressureTier);
    // 3/12 modify by adil for pressure Tier
    //  Make dynamic state reflect the site value immediately
    if (!this.state) this.state = {};
    this.state.pressureTier = value;
    this.applyMediumPressureBrand();  // 15 jan change 
    // (Optional) trigger rerender nudges if your UI needs it
    this.errors = { ...this.errors };
  }
  // 15 jan change
  get pressuretierBrand() {
    return this._pressuretierBrand;
  }
  set pressuretierBrand(value) {
    this._pressuretierBrand = value;
    console.log('Pressure Tier Brand received:', value);

    // Apply brand to medium pressure value if needed
    this.applyMediumPressureBrand();
  }
  // 15 jan change end here
  // 3/12 modify by adil end here
  _status;
  _paymentMechanism;
  _pressureTier     // 3/12 modify by adil
  error;
  @wire(getAllMeterModelConfigs)
  wiredConfigs({ error, data }) {
    if (data) {
      this.meterModels = data;
      console.log("this.meterModels", JSON.stringify(this.meterModels));
      // 19 dec change
      // If we're already in Yes â†’ Install â†’ Meter, populate dropdown now
      const yesFlow = (this.selectedSubType?.id === 'Install_Meter') && this._residentialU6Site;
      if (yesFlow && this.state?.peakLoad === '64') {
        Promise.resolve().then(() => this.filterMeterModels());
      }
      // 19 dec change end here
    } else if (error) {
      this.error = error;
    }
  }
  @wire(getAllHousingModelConfigs)
  wiredHousingConfigs({ error, data }) {
    if (data) {
      // Convert list of records into a Map
      this.housingModelMap = new Map(
        data.map(item => [item.DeveloperName, item.NGMCP_Housing_Model__c])
      );
      console.log('Housing Model Map:', JSON.stringify([...this.housingModelMap]));
    } else if (error) {
      this.error = error;
    }
  }

  // get showRequestedOnBehalf() {
  //   // If parent/user has not selected Yes/No yet, show the field; otherwise hide it.
  //   return this._residentialU6Provided !== true;
  // }

  connectedCallback() {
    console.log("pressureBrand >", this.pressuretierBrand);
    console.log("Mprn >", this.mprnInput);
    console.log("haszoo2", this.haszoo2);
    // Initialize state and errors
    this.state = {};
    this.errors = {};
    console.log('meterSize****' + this.meterSize);
    // Optional: Pre-populate keys from questionConfig
    Object.keys(this.questionConfig).forEach(subType => {
      this.questionConfig[subType].forEach(q => {
        this.state[q.key] = q.defaultValue || '';
        this.errors[q.key] = '';
      });
    });
    const selectedValue = 'Work Request';
    this.updateRequestTypesClass();
    this.uiConfig.requestTypes = this.uiConfig.requestTypes.map(req => {
      return {
        ...req,
        cssClass: req.label === this.selectedRequestType
          ? "card-radio selected"
          : "card-radio"
      };
    });

    this.selectedRequest = this.uiConfig.requestTypes.find(req => req.label === selectedValue);
    console.log('connectedcallback  this.thirdpartyFlag ', this.thirdParty);

    if (this.thirdParty && this.selectedRequest) {
      const isResidential = (this._status ?? '').trim().toLowerCase() === 'residential';

      this.selectedRequest.jobTypes =
        this.selectedRequest.jobTypes.filter(j => {
          const lbl = j.label?.trim().toLowerCase();
          if (lbl === 'meter move') return false;          // always hide Meter Move
          if (isResidential && lbl === 'other visits') return false; // hide Other Visits only in Residential
          return true;
        });
    }

    console.log(' this.selectedRequest  this. this.selectedRequest ', JSON.stringify(this.selectedRequest));
    this.selectedJob = null;
    this.selectedSubType = null;
    this.filteredSubTypes = [];
    this.meterSuggestions = [];
  }
  // refresh sybtype code 28/11 start here
  // Refresh subtypes when a new Job Type is chosen
  refreshSubtypesForJob(jobLabel, { autoOpenFirst = false } = {}) {
    // 1) Get subtype list for the job; make a fresh copy to ensure reactivity
    const list = this.jobTypeSubtypes[jobLabel] || [];
    this.filteredSubTypes = list.map(s => ({ ...s })); // new array, new objects
    // 2) Clear current subtype selection, questions, state, and errors
    this.selectedSubType = null;
    this.selectedSubTypeLabel = '';
    this.state = {};
    this.errors = {};
    this.priceMessageFlag = false;
    this.priceMessage = '';
    // 3) Optional: auto-open first subtype
    if (autoOpenFirst && this.filteredSubTypes.length > 0) {
      const first = this.filteredSubTypes[0];
      this.selectedSubType = { ...first };
      this.selectedSubTypeLabel = first.label;
      // Initialize state keys for the first subtypeâ€™s questions
      const qs = this.questionConfig[first.id] || [];
      const initState = {};
      qs.forEach(q => { initState[q.key] = q.defaultValue ?? ''; });
      this.state = initState;
      // Force re-render by immutably reassigning tracked props
      this.filteredSubTypes = this.filteredSubTypes.map(s => ({ ...s }));
      this.errors = { ...this.errors };
    } else {
      // Force re-render even if not auto-opening
      this.filteredSubTypes = this.filteredSubTypes.map(s => ({ ...s }));
      this.errors = { ...this.errors };
    }
  }
  // refresh subtype code 28/11 end here
  // required mandatory field code 28/11
  // ==== REQUIRED / VISIBILITY HELPERS (INSERT NEAR TOP OF CLASS) ====
  isEmptyValue(val) {
    if (val === null || val === undefined) return true;
    if (typeof val === 'string' && val.trim() === '') return true;
    if (Array.isArray(val) && val.length === 0) return true;
    return false;
  }

  // GT1 parent condition used across subtypes
  isGt1Required(state) {
    const gt1RequiredTiers = ["Medium Pressure", "Intermediate Pressure", "High Pressure"];
    const specialMeterSizes = ["Rotary", "Turbine"];
    const tier = state?.pressureTier;
    const loc = state?.serviceLocation; // "Existing" | "New"
    const size = state?.MeterSize;
    return gt1RequiredTiers.includes(tier) && loc === "New" && specialMeterSizes.includes(size);
  }
  // 29 jan change
  // 4 feb change for third party and meter
  // === GT1 content parsing helpers (Spec Change only) ===
  // Convert base64 file payload to printable text (best-effort for .doc/.docx/.pdf text)
  toPrintableTextFromBase64(b64) {
    try {
      const bin = atob(b64);
      // keep tabs/newlines/spaces and ASCII printables; collapse whitespace
      return bin.replace(/[^\x09\x0A\x0D\x20-\x7E]/g, ' ').replace(/\s+/g, ' ').trim();
    } catch (e) {
      return '';
    }
  }
  /**
   * Parse textual GT1 content to extract:
   *  - gtValidDate: Date (or null)
   *  - spevKwh: number (or null)
   */
  parseGt1DocFields(text) {
    const out = { gtValidDate: null, spevKwh: null };
    if (!text) return out;

    // SERVICE PIPE ENERGY VALUE (NEW CLIENT RULE)
    // Expected format: "Service pipe energy value confirmed or available"
    // followed by "SPEVnom/max = <number> kWh"

    // 4 feb change for new field
    // === SERVICE PIPE ENERGY VALUE (SPEVnom/max) — tolerant text parser ===
    // Example (from your sample doc):
    // "Service pipe energy value confirmed or available   SPEVnom/max* = 600 kWh"
    // This parser tolerates: extra 'v' after SPEV, asterisk, colon instead of equals,
    // strange Unicode equals, and extra spaces/newlines.

    // === SERVICE PIPE ENERGY VALUE (SPEVnom/max) — very tolerant text parser ===
    // Example (from your GT1): "Service pipe energy value confirmed or available  SPEVnom/max* = 600 kWh"
    // Tolerates: extra 'v' after SPEV, optional asterisk, colon/various equals, Unicode dashes,
    // non-breaking spaces and newlines before the number and before 'kWh'.

    let scope = text;
    // Prefer to scope from the heading
    const hdrIdx = text.toLowerCase().indexOf('service pipe energy value');
    if (hdrIdx >= 0) {
      scope = text.slice(hdrIdx, Math.min(text.length, hdrIdx + 1000));
    }
    // 1) Strict-ish pattern: SPEV (optional v) + nom/max (+/- spaces) + (:=* etc) + number + kWh
    let mSpev =
      /SPEV\s*[vV]?\s*(?:nom\s*\/\s*max|nom\/max|nom\s*max|max)\s*[\s:*=–—-]{0,4}\s*([0-9][0-9,.\s]*)\s*kwh/i
        .exec(scope) ||
      /SPEV\s*[vV]?\s*(?:nom\s*\/\s*max|nom\/max|nom\s*max|max)\s*[\s:*=–—-]{0,4}\s*([0-9][0-9,.\s]*)\s*kwh/i
        .exec(text);

    // 2) Fallback: once we see "SPEV", take the next number before "kWh" in a small window
    if (!mSpev) {
      const spevIdx = scope.toLowerCase().indexOf('spev');
      const win = spevIdx >= 0 ? scope.slice(spevIdx, Math.min(scope.length, spevIdx + 400)) : scope;
      mSpev = /([0-9][0-9,.\s]*)\s*kwh/i.exec(win);
    }

    if (mSpev) {
      const raw = (mSpev[1] || '').replace(/[\u00A0,\s]+/g, ''); // also strip NBSP
      const num = parseFloat(raw);
      if (Number.isFinite(num)) out.spevKwh = num;
    }
    // 4 feb change for new field end here


    // GT valid Date: support dd/mm/yyyy, dd-mm-yyyy, yyyy-mm-dd, "dd Mon yyyy"
    const dateIdx = text.toLowerCase().indexOf('gt valid date');
    let dateScope = text;
    if (dateIdx >= 0) dateScope = text.slice(dateIdx, Math.min(text.length, dateIdx + 200));
    const datePatterns = [
      /(\d{1,2}[\/-]\d{1,2}[\/-]\d{2,4})/,     // dd/mm/yyyy | dd-mm-yyyy
      /(\d{4}-\d{2}-\d{2})/,                   // yyyy-mm-dd
      /(\d{1,2}\s+[A-Za-z]{3,9}\s+\d{2,4})/    // dd Mon yyyy
    ];
    for (const re of datePatterns) {
      const m = re.exec(dateScope) || re.exec(text);
      if (m) {
        const s = m[1];
        let dt;
        if (/^\d{4}-\d{2}-\d{2}$/.test(s)) {
          dt = new Date(s + 'T00:00:00');
        } else if (/^\d{1,2}[\/-]\d{1,2}[\/-]\d{2,4}$/.test(s)) {
          // normalize dd/mm/yyyy-ish
          const [dd, mm, yy] = s.split(/[\/-]/);
          const day = dd.padStart(2, '0');
          const mon = mm.padStart(2, '0');
          const yyyy = yy.length === 2 ? ('20' + yy) : yy;
          dt = new Date(`${yyyy}-${mon}-${day}T00:00:00`);
        } else {
          dt = new Date(s);
        }
        if (!isNaN(dt)) { out.gtValidDate = dt; break; }
      }
    }

    return out;
  }
  // === Legacy .doc tolerant scan (Spec Change only) ===
  /**
   * Scan the decoded binary string for SPEV number in very tolerant way:
   * allows junk/control bytes between characters (e.g. S\x00P\x07E\x00V).
   * Returns a Number or null.
   */
  scanSpevFromBinary(binStr) {

    // === Legacy .doc tolerant scan for "SPEVnom/max = <number> kWh" ===
    // Allow junk/control bytes between characters, optional 'v' after SPEV,
    // optional *, :, various equals; capture the number before 'kWh'.
    const re =
      /S[\s\S]*?P[\s\S]*?E[\s\S]*?V[\s\S]*?(?:[\s\S]*?[vV])?[\s\S]*?n[\s\S]*?o[\s\S]*?m[\s\S]*?\/[\s\S]*?m[\s\S]*?a[\s\S]*?x[\s\S]*?[\s:*=–—-]{0,4}[\s\S]*?([0-9][0-9,.\s]*)[\s\S]*?k[\s\S]*?w[\s\S]*?h/i;

    const m = binStr.match(re);
    if (!m) return null;
    const raw = (m[1] || '').replace(/[\u00A0,\s]+/g, '');
    const num = parseFloat(raw);
    return Number.isFinite(num) ? num : null;

  }
  /**
   * Tolerant scan for "GT valid Date" from the same binary string.
   * Supports dd/mm/yyyy, dd-mm-yyyy, yyyy-mm-dd, and "dd Mon yyyy".
   * Returns Date or null.
   */
  scanGtValidDateFromBinary(binStr) {
    const labelIdx = binStr.toLowerCase().indexOf('gt valid date');
    const window = labelIdx >= 0 ? binStr.slice(labelIdx, labelIdx + 600) : binStr.slice(0, 1200);
    const pats = [
      /(\d{1,2}[\/-]\d{1,2}[\/-]\d{2,4})/,
      /(\d{4}-\d{2}-\d{2})/,
      /(\d{1,2}\s+[A-Za-z]{3,9}\s+\d{2,4})/
    ];
    for (const re of pats) {
      const m = window.match(re) || binStr.match(re);
      if (m) {
        const s = m[1];
        let dt;
        if (/^\d{4}-\d{2}-\d{2}$/.test(s)) dt = new Date(s + 'T00:00:00');
        else if (/^\d{1,2}[\/-]\d{1,2}[\/-]\d{2,4}$/.test(s)) {
          const [dd, mm, yy] = s.split(/[\/-]/);
          const YYYY = yy.length === 2 ? ('20' + yy) : yy;
          dt = new Date(`${YYYY}-${mm.padStart(2, '0')}-${dd.padStart(2, '0')}T00:00:00`);
        } else dt = new Date(s);
        if (!isNaN(dt)) return dt;
      }
    }
    return null;
  }
  // 29 jan change end 
  // 28 jan change for upgrade model
  // --- Add once inside the class ---
  // From smallest to largest
  SIZE_ORDER = ["U6", "U16", "U25", "U40", "U65", "U100", "U160", "Rotary", "Turbine"];
  /** Get rank or -1 if unknown */
  rankSize(size) {
    if (!size) return -1;
    return this.SIZE_ORDER.indexOf(String(size).trim());
  }
  /** True if newSize is larger than the parent meterSize passed into the component */
  isUpgradeFromOriginal(newSize) {
    const base = this.rankSize(this.meterSize);     // <-- parent prop from createrequest
    const next = this.rankSize(newSize);            // <-- current (recommended/selected) size
    return base >= 0 && next >= 0 && next > base;
  }
  // 28 jan change for upgrade model

  // Optional: visibility helper for housing type
  isHousingTypeVisible(state) {
    const hideFor = ["U6", "U25", "U40", "U65", "U100", "U160", "Rotary", "Turbine"];
    if (hideFor.includes(state?.MeterSize)) return false;
    return state?.MeterSize === "U16" && state?.housingRequired === "Yes";
  }
  // ==== REQUIRED / VISIBILITY HELPERS ====
  isEmptyValue(val) {
    if (val === null || val === undefined) return true;
    if (typeof val === 'string' && val.trim() === '') return true;
    if (Array.isArray(val) && val.length === 0) return true;
    return false;
  }
  // GT1 parent condition used across subtypes (recommended: ANDs)
  isGt1Required(state) {
    const gt1RequiredTiers = ["Medium Pressure", "Intermediate Pressure", "High Pressure"];
    const specialMeterSizes = ["Rotary", "Turbine"];
    const tier = state?.pressureTier;
    const loc = state?.serviceLocation; // "Existing" | "New"
    const size = state?.MeterSize;
    return gt1RequiredTiers.includes(tier) && loc === "New" && specialMeterSizes.includes(size);
  }

  // Optional: visibility helper for housing type
  isHousingTypeVisible(state) {
    const hideFor = ["U6", "U25", "U40", "U65", "U100", "U160", "Rotary", "Turbine"];
    if (hideFor.includes(state?.MeterSize)) return false;
    return state?.MeterSize === "U16" && state?.housingRequired === "Yes";
  }
  clearErrorsForInvisibleQuestions() {
    const allQs = this.dynamicQuestions || [];
    const invisibleKeys = allQs.filter(q => !q.visible).map(q => q.key);
    if (!this.errors) this.errors = {};
    invisibleKeys.forEach(k => { this.errors[k] = ''; });
    // 30 jan change here for housing issue
    // --- ADD: clear values for hidden housing fields to avoid stale state ---
    invisibleKeys.forEach((k) => {
      if (['housingType', 'baseRequired', 'HModel'].includes(k)) {
        this.state[k] = (k === 'HModel') ? '' : null;
      }
    });
    this.state = { ...this.state }; // bump re-render after value changes
    // 30 jan change end here for housing issue
    // <-- FORCE RERENDER
    this.errors = { ...this.errors };
  }
  // mandatory required 28/11 continue below
   // 4 march
    // NEW: are we on Install→Meter, independent (U6 Yes/No not provided), and status=Residential?
isIndependentResidentialInstall() {
  return this.selectedSubType?.id === 'Install_Meter'
      && this._residentialU6Provided !== true
      && this._status === 'Residential';
}

// Normalize incoming payment to your radio options ("Credit", "Pre payment")
normalizePaymentMethod(val) {
  const s = String(val || '').trim().toLowerCase();
  if (s === 'credit') return 'Credit';
  if (s === 'pre payment' || s === 'prepayment' || s === 'pre-payment') return 'Pre payment';
  return 'Credit';
}
  // 4 march end


  // ==== VALIDATION (INSERT BELOW HELPERS) ====

  // modify validatevisible 29/11 for show get price button validation

  // ==== VALIDATION (robust for select placeholders & radios) ====

  validateVisibleQuestions() {
    if (!this.errors) this.errors = {};
    const missingKeys = [];

    const questions = (this.dynamicQuestions || []).filter(q => q.visible);

    const PLACEHOLDER_LABELS = new Set([
      "Select the Pressure Tier",
      "Please select the Medium Pressure",
      "Select Asset Type",
      "Please select reason for Site Visit",
      "Select"
    ]);

    questions.forEach(q => {
      // --- Conditional required for finalRead (Meter pickup only) ---
      let required = (q.required ?? true);
      if (q.key === 'finalRead') {
        required = (this.state.pickupEquipment === 'Meter');
      }

      let isEmpty = false;

      if (!required) {
        // Optional question: skip empty check unless you want pattern enforcement anyway
        // (We will still pattern-check if a value is present)
      } else {
        // Required checks by type
        if (q.isRadio) {
          const checked = this.template.querySelectorAll(`input[name="${q.key}"]:checked`);
          isEmpty = !(checked && checked.length > 0);
        } else if (q.isSelect) {
          const el = this.template.querySelector(`select[data-key="${q.key}"]`);
          const selVal = el ? el.value : this.state[q.key];
          const selLab = el && el.selectedOptions && el.selectedOptions[0]
            ? el.selectedOptions[0].textContent.trim()
            : "";
          isEmpty = (selVal === "" || PLACEHOLDER_LABELS.has(selLab));
        } else if (q.isFile) {
          // files optional unless q.required is explicitly true
          //   isEmpty = false;  // 20 jan change comment this part

          // 20 jan change

          const bucket = this.uploadedFilePayloadByKey?.[q.key] || [];
          isEmpty = (q.required === true) && bucket.length === 0;
          // 20 jan change end here
          // 29 jan change

          // Spec Change: also block when GT1 content has an error (mismatch / past date)
          // 30 Jan change: make GT1 warnings non-blocking for Spec Change
          // GT1: show inline warnings but do NOT block upload/Get Price for these three subtypes

          // 4 feb change for thirdparty and meter
          if (q.key === 'gt1File'
            && GT1_VALIDATION_SUBTYPES.has(this.selectedSubType?.id)
            && this.errors?.gt1File) {

          }
          // 4 feb change end here
          // 29 jan change end here
        } else {
          const val = this.state[q.key];
          isEmpty = (val === null || val === undefined || (typeof val === 'string' && val.trim() === '') || (Array.isArray(val) && val.length === 0));
        }
      }
      // Set required error
      if (required && isEmpty) {
        //    this.errors[q.key] = (q.key === 'finalRead')  // 20 jan change comment 3 line
        //     ? 'Final Read is required'
        //     : 'This field is required.';

        // 20 jan change
        this.errors[q.key] =

          q.key === 'finalRead' ? 'Final Read is required'
            : q.isFile ? 'Please attach the required document.'
              : 'This field is required.';
        // 20 jan change end here
        missingKeys.push(q.key);
      } else {
        this.errors[q.key] = '';
      }
      // --- Additional pattern enforcement for finalRead ---
      if (q.key === 'finalRead') {
        const val = (this.state.finalRead ?? '').trim();
        if (val !== '' && !/^[0-9]{4,5}$/.test(val)) {
          this.errors.finalRead = 'Final Read must be 4 or 5 digits';
          // We treat pattern failure as blocking as well:
          if (!missingKeys.includes('finalRead')) {
            missingKeys.push('finalRead');
          }
        }
      }
    });

    // FORCE RERENDER
    this.errors = { ...this.errors };

    const isValid = missingKeys.length === 0;
    return { isValid, missingKeys };
  }
  // mandatory required field 28/11 end here
  uiConfig = {
    requestTypes: [
      {
        label: "Work Request",
        helpText: "Choose job type and subtype",

        jobTypes: [
          { label: "Install", description: "Request to install an asset onto a metering installation" },
          { label: "Exchange", description: "Request to exchange an asset on a metering installation" },
          { label: "Remove", description: "Request to remove an asset on a metering installation" },
          { label: "Meter Move", description: "Request to move an asset on a metering installation" },
          { label: "Other Visits", description: "Request for other work activities on the metering installation" }
        ]
      }
    ],
  };

  jobTypeSubtypes = {
    Install: [
      { label: "Meter", id: "Install_Meter", description: "Request to install an NGM meter at a new meter point" },
      { label: "Converter", id: "Install_Converter", description: "Request to install an Converter to an existing NGM installation" },
      { label: "Housing", id: "Install_Housing", description: "Request to install Meter Housing" }
    ],
    Exchange: [
      { label: "Specification Change", id: "Exchange_SpecificationChange", description: "Request for a Meter Upgrage/Downgrade in size or change to meter type (Credit/Pre-Pay)" },
      { label: "Accuracy Test", id: "Exchange_AccuracyTest", description: "Request to exchange for a Meter accuracy test" },
      { label: "GPS", id: "Exchange_GPS", description: "Request to exchange a Non-Pulsing Meter" },
      { label: "Housing", id: "Exchange_Housing", description: "Request to exchange the Meter Housing" },
      { label: "Converter", id: "Exchange_Converter", description: "Exchange or maintain a converter." },
      { label: "Third Party", id: "Exchange_ThirdParty", description: "Request to exchange a 3rd Party Meter to an NGM Meter" },
      { label: "Faulty(On Gas)", id: "Exchange_FaultyOnGas", description: "Request to exchange a faulty NGM Meter (On Gas)" },
      { label: "Like For Like", id: "Exchange_LikeForLike", description: "Request to exchange the Meter like for like" },
      { label: "Exchange Meter Type", id: "Exchange_MeterType", description: "Request to change the Meter type from Pre-Pay to Credit or Credit to Pre-Pay" }

    ],
    Remove: [
      { label: "Meter", id: "Remove_Meter", description: "Remove an existing meter from the site." },
      { label: "Pickup", id: "Remove_Pickup", description: "Request to pick up an NGM Meter which has already been disconnected from the service" },
      { label: "Converter", id: "Remove_Converter", description: "Request to remove the Converter" }
    ],
    "Meter Move": [
      { label: "Reposition", id: "MeterMove_Reposition", description: "Request to reposition an NGM Meter (within 2 metres of existing service point)" },
      { label: "Relocation", id: "MeterMove_Relocation", description: "Request to Relocate an NGM meter to an alternative Service Point" }
    ],
    "Other Visits": [
      { label: "Damaged", id: "OtherVisits_Damaged", description: "Request to exchange a damaged NGM Meter" },
      { label: "Adversarial removal", id: "OtherVisits_Adversarial_Removal", description: "Request to remove the Meter under Warrant" },
      { label: "Post Commissioning Checks", id: "OtherVisits_PostCommissioningChecks", description: "Request for Post Comissioning Checks following metering works on site." },
      { label: "Pressure Change", id: "OtherVisits_PressureChange", description: "Request for an Increase or Decrease to the metering pressure on site" },
      { label: "Reconnect", id: "OtherVisits_Reconnect", description: "Request to reconnect an NGM Meter at an existing meter point" },
      { label: "Site Visit", id: "OtherVisits_SiteVisit", description: "Request for a Site Visit" },
      { label: "Theft of Gas Exchange", id: "OtherVisits_TheftOfgasExchange", description: "Request to exchange the meter following suspected Theft of Gas (TOG)" },
      { label: "Change Of Tenancy", id: "OtherVisits_ChangeOfTenancy", description: "Request to clear debt and load emergency credit following a change of tenancy" },
      { label: "Service Engineer Hire (TSE)", id: "OtherVisits_ServiceEngineerHire", description: "Request to hire service engineer" },
      { label: "Post Emergency Meter Works", id: "OtherVisits_PostEmergencyMeterWorks", description: "Request to update National Gas systems post emergency meter works" }
    ]
  };

  qmaxTable = [
    { model: "U6", qmax: 64 },
    { model: "U16", qmax: 171 },
    { model: "U25", qmax: 267 },
    { model: "U40", qmax: 427 },
    { model: "U65", qmax: 693 },
    { model: "U100", qmax: 1067 },
    { model: "U160", qmax: 1706 },
  ];
  // 20 jan change
  // --- Site Visit: reasons per Asset Type (client-approved) ---
  SITE_VISIT_REASONS = {
    'Meter': [
      { label: 'Site visit for enquiry/complaint', value: 'Site visit for enquiry/complaint' },
      { label: 'Ad-hoc', value: 'Ad-hoc' }
    ],
    'Converter': [
      { label: 'Converter Re-syncing', value: 'Converter Re-syncing' }
    ],
    'Isolation': [
      { label: 'Install EMS to Isolation', value: 'Install EMS to Isolation' }
    ]
  };
  // 20 jan change end here
  questionConfig = {
    "Exchange_SpecificationChange": [
      {
        label: "Please confirm the Service Pressure Tier",


        type: "select",
        key: "pressureTier",
        options: [
          { label: "Select the Pressure Tier", value: "" }, // mandatory required 28/11
          "Low Pressure",
          "Medium Pressure",
          "Intermediate Pressure",
          "High Pressure"
        ],
        //    defaultValue: this.pressuretier,
      },
      {
        label: "Select Medium Pressure Value",
        type: "select",
        key: "mediumPressureValue",
        options: ["Please select the Medium Pressure", "MP35", "MP65", "MP105", "MP180", "MP270"],
        condition: (state) => state.pressureTier === "Medium Pressure"
      },
      {
        label: "Please confirm the required metering outlet pressure (mbar)",
        type: "text",
        key: "outletPressure",
        maxLength: 4,
        pattern: "^[0-9]{1,4}$", // Only digits, up to 4
        messageWhenPatternMismatch: "Enter a valid number (0-9999)",
        defaultValue: "21"
      },
      {
        label: "Please provide the expected peak hourly load (kWh)",
        type: "text",
        key: "peakLoad",
        maxLength: 8,
        pattern: "^[0-9]{1,8}$", // Only digits, up to 8
        messageWhenPatternMismatch: "Enter a valid number (0-99999999)",
      },
      {
        label:
          "Based on your initial inputs, we believe the following meter size would meet your requirements.",
        type: "select",
        key: "MeterSize",
        required: false,
        options: [],
      },

      // GT1 logic
      // GT1 logic 27/11
      {
        label: "Is the new meter going into the existing or new service location?",
        type: "radio",
        options: ["Existing", "New"],
        key: "serviceLocation",
      },

      {
        label: "Do you have GT1/Service Quotation?",
        type: "radio",
        options: ["Yes", "No"],
        key: "gt1",

        condition: (state) => {
          const pressureTier = state?.pressureTier;
          const serviceLocation = state?.serviceLocation;
          const meterSize = state?.MeterSize;
          const gt1RequiredTiers = ["Medium Pressure", "Intermediate Pressure", "High Pressure"];
          const specialMeterSizes = ["Rotary", "Turbine"];
          const upgrade = this.isUpgradeFromOriginal(meterSize);  // 28 jan change for upgrade model
          // Show only if GT1 is required
          return (
            gt1RequiredTiers.includes(pressureTier) ||
            serviceLocation === "New" ||
            specialMeterSizes.includes(meterSize) || upgrade   // 28 jan change for upgrade model
          );
        },
      },
      {
        label: "Please attach GT1/Service Quotation document",
        type: "file",
        key: "gt1File",

        condition: (state) => {
          const pressureTier = state?.pressureTier;
          const serviceLocation = state?.serviceLocation;
          const meterSize = state?.MeterSize;

          const gt1RequiredTiers = ["Medium Pressure", "Intermediate Pressure", "High Pressure"];
          const specialMeterSizes = ["Rotary", "Turbine"];

          const upgrade = this.isUpgradeFromOriginal(meterSize); // 28 jan change for upgrade model

          const gt1Required =
            gt1RequiredTiers.includes(pressureTier) ||
            serviceLocation === "New" ||
            specialMeterSizes.includes(meterSize) || upgrade;

          return gt1Required && state?.gt1 === "Yes";
        },
      },
      {
        label:
          "This job requires a GT1 to be completed by the network provider and the GT1 survey attached, therefore it cannot be raised. If you have any further questions please contact 0800 001 4340.",
        type: "error",
        key: "gt1Error",
        required: false,  // mandatory required field 28/11
        condition: (state) => {
          const pressureTier = state?.pressureTier;
          const serviceLocation = state?.serviceLocation;
          const meterSize = state?.MeterSize;

          const gt1RequiredTiers = ["Medium Pressure", "Intermediate Pressure", "High Pressure"];
          const specialMeterSizes = ["Rotary", "Turbine"];

          const upgrade = this.isUpgradeFromOriginal(meterSize);  // 28 jan change for upgrade model

          const gt1Required =
            gt1RequiredTiers.includes(pressureTier) ||
            serviceLocation === "New" ||
            specialMeterSizes.includes(meterSize) || upgrade;

          // Show error only when GT1 is REQUIRED and user answered "No"
          return gt1Required && state?.gt1 === "No";
        },
      },
      // NEW: Existing installation location (visible when serviceLocation = "New")
      {
        label: "Existing Meter Installation location?",
        type: "select",
        key: "existingInstallationLocation",
        options: ["Select", "In the Main Building", "Meter Compound", "Meter House"],
        condition: (state) => state?.serviceLocation === "New"
      },
      // 27/11 end here
      // Housing logic
      {
        label: "Is housing required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "housingRequired",
        condition: (state) => {
          const meterSize = state.MeterSize;
          const gt1RequiredSizes = [
            "U16",
            "U25",
            "U40",
            "U65",
            "U100",
            "U160",
            "Rotary",
            "Turbine",
          ];
          // Hide for U6
          if (meterSize === "U6") {
            return false;
          }
          // Show for U16 and greater
          if (gt1RequiredSizes.includes(meterSize)) {
            return true;
          }
          return false;
        },
      },
      {
        label: "Please select type of housing required",
        type: "radio",
        options: ["Free Standing", "Wall Mounted"],
        key: "housingType",
        condition: (state) => {
          const meterSize = state.MeterSize;
          const gt1RequiredSizes = [
            "U25",
            "U40",
            "U65",
            "U100",
            "U160",
            "Rotary",
            "Turbine",
          ];
          // Hide for U6
          if (meterSize === "U6") {
            return false;
          }
          // Show only for U16 when housingRequired = Yes
          if (meterSize === "U16" && state.housingRequired === "Yes") {
            return true;
          }
          // Hide for sizes greater than U16
          if (gt1RequiredSizes.includes(meterSize)) {
            return false;
          }
          return false;
        },
      },
      {
        label: "Housing Model",
        type: "text",
        key: "HModel",
        required: false,
        disabled: true,
        readOnly: true,
        condition: (state) =>
          state.housingRequired === "Yes" &&
          !["U6", "Rotary", "Turbain"].includes(state.MeterSize)
      },
      {
        label: "Is a base Required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "baseRequired",
        condition: (state) =>
          state.housingRequired === "Yes" &&
          state.housingType === "Free Standing",
      },
      // Additional logic
      {
        label: "Are there any special electric interfaces required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "electricInterface",
      },
      {
        label: "Change Payment Type?",
        type: "radio",
        options: ["Yes", "No"],
        key: "changePaymentType",
        condition: (state) => state.MeterSize === "U6"
      },
      {
        label: "Required Meter Payment Type",
        type: "radio",
        options: ["Credit", "Pre payment"],
        key: "paymentMethod",
        condition: (state) => state.MeterSize === "U6" && state.changePaymentType === "Yes"
      },
      {
        label: "Is a meter by-pass required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "meterBypass",
      },
      {
        label: "Is a converter required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "converterRequired",
      },
      {
        label: "Is a twin stream pressure reduction installation required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "twinStream",
      },
      {
        label: "Do you require an AMR device?",
        type: "radio",
        options: ["Yes", "No"],
        key: "amrDevice",
      },
    ],
    // 6 jan change  NEW: Exchange â†’ Like for Like
    "Exchange_LikeForLike": [
      {
        label: "Select Payment Method Required for New Meter",
        type: "radio",
        options: ["Credit", "Pre Payment"],
        key: "paymentMethod",

      },
    ],
    // 6 jan change NEW: Exchange â†’ Exchange Meter type
    "Exchange_MeterType": [
      {
        label: "Select Payment Method Required for New Meter",
        type: "radio",
        options: ["Credit", "Pre Payment"],
        key: "newMeterPaymentMethod",
        // Mandatory; no condition
      }
    ],

    "Exchange_AccuracyTest": [
      // In questionConfig["Exchange_AccuracyTest"] array:
      {
        label: "Is this a Smart Meter?",
        type: "radio",
        options: ["Yes", "No"],
        key: "isSmartMeter",
        //  Only show when MPRN is Residential
        condition: () => this._status === "Residential"
      },
      {
        label: "Unfortunately, we do not provide an OFMAT service for Smart Meters. Please contact the MAM/MAP of the meter.",
        type: "error",
        key: "smartMeterOfmatError",
        required: false,
        //  Show only when Residential AND user answers Yes
        condition: (state) => this._status === "Residential" && state.isSmartMeter === "Yes"
      },
    ],
    "Install_Meter": [
      {
        label: "Please confirm the Service Pressure Tier",
        type: "select",
        key: "pressureTier",
        options: [
          { label: "Select the Pressure Tier", value: "" },  // mandatory required field 28/11
          "Low Pressure",
          "Medium Pressure",
          "Intermediate Pressure",
          "High Pressure"
        ],
        defaultValue: this.pressuretier,
      },
      {
        label: "Select Medium Pressure Value",
        type: "select",
        key: "mediumPressureValue",
        options: ["Please select the Medium Pressure", "MP35", "MP65", "MP105", "MP180", "MP270"],
        condition: (state) => state.pressureTier === "Medium Pressure"
      },
      {
        label: "Please confirm the required metering outlet pressure (mbar)",
        type: "text",
        key: "outletPressure",
        maxLength: 4,
        pattern: "^[0-9]{1,4}$", // Only digits, up to 4
        messageWhenPatternMismatch: "Enter a valid number (0-9999)",
        defaultValue: "21",
      },
      {
        label: "Please provide the expected peak hourly load (kWh)",
        type: "text",
        key: "peakLoad",
        maxLength: 8,
        pattern: "^[0-9]{1,8}$", // Only digits, up to 8
        messageWhenPatternMismatch: "Enter a valid number (0-99999999)",
      },
      {
        label:
          "Based on your initial inputs, we believe the following meter size would meet your requirements.",
        type: "select",
        key: "MeterSize",
        required: false,
        options: [],
      },
      // New logic
      // 15 jan change
      {
        label: "Select Payment Method Required for New Meter",
        type: "radio",
        options: ["Credit", "Pre payment"],
        key: "paymentMethod",
        // Show rules:
        // - Residential = Yes  -> always show (any size)
        // - Residential = No   -> show when a size is chosen
        condition: (state) => {
          if (this._residentialU6Site === true) return true;
          return !!state.MeterSize;
        },
        required: true,
        // No default here; weâ€™ll set 'Credit' at runtime only when the field must be locked
        defaultValue: null
      },
      // 15 jan change end here
      {
        label: "Do you have GT1/Service Quotation?",
        type: "radio",
        options: ["Yes", "No"],
        key: "gt1",

        condition: (state) => {
          if (state.MeterSize === "U6" && state.pressureTier === "Low Pressure") {
            return false;
          }
          const meterSize = state.MeterSize;
          const pressureTier = state.pressureTier;

          const gt1RequiredSizes = [
            "U16",
            "U25",
            "U40",
            "U65",
            "U100",
            "U160",
            "Rotary",
            "Turbine",
          ];
          // Condition 1: Meter size >= U16
          if (gt1RequiredSizes.includes(meterSize)) {
            return true;
          }
          // Condition 2: Meter size = U6 AND pressure tier is Intermediate or High Pressure
          if (
            meterSize === "U6" &&
            (pressureTier === "Intermediate Pressure" ||
              pressureTier === "High Pressure")
          ) {
            return true;
          }
          return false;
        },
      },
      {
        label: "Please attach GT1/Service Quotation document",
        type: "file",
        key: "gt1File",

        condition: (state) => {
          // Hide if MeterSize = U6 AND pressureTier = Low Pressure
          if (state.MeterSize === "U6" && state.pressureTier === "Low Pressure") {
            return false;
          }
          const meterSize = state.MeterSize;
          const pressureTier = state.pressureTier;
          const gt1RequiredSizes = [
            "U16", "U25", "U40", "U65", "U100", "U160", "Rotary", "Turbine"
          ];
          const gt1Visible =
            gt1RequiredSizes.includes(meterSize) ||
            (meterSize === "U6" &&
              (pressureTier === "Intermediate Pressure" || pressureTier === "High Pressure"));
          // Show file upload only if GT1 is required AND user selected Yes
          return gt1Visible && state.gt1 === "Yes";
        }
      },
      {
        label: "This job requires a GT1 to be completed by the network provider and the GT1 survey attached, therefore it cannot be raised. If you have any further questions please contact 0800 001 4340.",
        type: "error",
        key: "gt1Error",
        required: false,
        condition: (state) => {
          // Hide if MeterSize = U6 AND pressureTier = Low Pressure
          if (state.MeterSize === "U6" && state.pressureTier === "Low Pressure") {
            return false;
          }
          const meterSize = state.MeterSize;
          const pressureTier = state.pressureTier;
          const gt1RequiredSizes = [
            "U16", "U25", "U40", "U65", "U100", "U160", "Rotary", "Turbine"
          ];
          const gt1Required =
            gt1RequiredSizes.includes(meterSize) ||
            (meterSize === "U6" &&
              (pressureTier === "Intermediate Pressure" || pressureTier === "High Pressure"));

          // Show error if GT1 is required AND user selected No
          return gt1Required && state.gt1 === "No";
        }
      },
      // Housing logic
      {
        label: "Is housing required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "housingRequired",
        condition: (state) => {
          if (state.MeterSize === "U6" && state.pressureTier === "Low Pressure") {
            return false;
          }
          const meterSize = state.MeterSize;
          const gt1RequiredSizes = [
            "U16",
            "U25",
            "U40",
            "U65",
            "U100",
            "U160",
            "Rotary",
            "Turbine",
          ];
          // Hide for U6
          if (meterSize === "U6") {
            return false;
          }
          // Show for U16 and greater
          if (gt1RequiredSizes.includes(meterSize)) {
            return true;
          }
          return false;
        },
      },
      {
        label: "Please select type of housing required",
        type: "radio",
        options: ["Free Standing", "Wall Mounted"],
        key: "housingType",
        condition: (state) => {
          if (state.MeterSize === "U6" && state.pressureTier === "Low Pressure") {
            return false;
          }
          const meterSize = state.MeterSize;
          const housingRequired = state.housingRequired;
          // Define rules dynamically
          const rules = {
            hideFor: ["U6", "U25", "U40", "U65", "U100", "U160", "Rotary", "Turbine"],
            showOnly: [{ size: "U16", housingRequired: "Yes" }]
          };
          // Hide if meterSize is in hideFor list
          if (rules.hideFor.includes(meterSize)) return false;
          // Show if any rule in showOnly matches
          return rules.showOnly.some(rule =>
            rule.size === meterSize && rule.housingRequired === housingRequired
          );
        }
      },

      {
        label: "Housing Model",
        type: "text",
        key: "HModel",
        disabled: true,
        readOnly: true,
        required: false,
        condition: (state) => {
          if (state.MeterSize === "U6" && state.pressureTier === "Low Pressure") {
            return false;
          }
          return state.housingRequired === "Yes" &&
            !["U6", "Rotary", "Turbain"].includes(state.MeterSize);
        }
      },
      {
        label: "Is a base Required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "baseRequired",
        condition: (state) => {
          // Hide if U6 + Low Pressure
          if (state.MeterSize === "U6" && state.pressureTier === "Low Pressure") {
            return false;
          }
          return state.housingRequired === "Yes" &&
            state.housingType === "Free Standing";
        }
      },

      // Additional logic
      {
        label: "Are there any special electric interfaces required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "electricInterface",
        condition: (state) => {
          if (state.MeterSize === "U6" && state.pressureTier === "Low Pressure") {
            return false;
          }
          return true; // Always show otherwise
        }
      },
      {
        label: "Is a meter by-pass required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "meterBypass",
        condition: (state) => {
          if (state.MeterSize === "U6" && state.pressureTier === "Low Pressure") {
            return false;
          }
          return true;
        }
      },
      {
        label: "Is a converter required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "converterRequired",
        condition: (state) => {
          if (state.MeterSize === "U6" && state.pressureTier === "Low Pressure") {
            return false;
          }
          return true;
        }
      },
      {
        label: "Is a twin stream pressure reduction installation required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "twinStream",
        condition: (state) => {
          if (state.MeterSize === "U6" && state.pressureTier === "Low Pressure") {
            return false;
          }
          return true;
        }
      },
      {
        label: "Do you require an AMR device?",
        type: "radio",
        options: ["Yes", "No"],
        key: "amrDevice",
        condition: (state) => {
          if (state.MeterSize === "U6" && state.pressureTier === "Low Pressure") {
            return false;
          }
          return true;
        }
      },
      // 18 dec  change
      //  Add/keep these three questions in the Install_Meter array
      // In questionConfig["Install_Meter"] array:
      // In questionConfig["Install_Meter"] array:
      // In questionConfig["Install_Meter"] array (keep them in THIS order):
      {
        label: "Is it a new connection?",
        type: "radio",
        options: ["Yes", "No"],
        key: "isNewConnection",
        //  Only when Residential U6 site = Yes
        // (The question is independent of MeterSize; clientâ€™s rule is driven by residentialU6 flag.)
        //  condition: () => this._residentialU6Site === true
        // condition: () => true // Always visible; value + lock handled at runtime
        condition: () => (this._residentialU6Site === true) || (this._residentialU6Provided !== true)
      },
      {
        label: "Is this a reconnection request?",
        type: "radio",
        options: ["Yes", "No"],
        key: "isReconnection",
        condition: (state) => state.isNewConnection === "No",
      },
      {
        label: "Is it a reconnection after debt?",
        type: "radio",
        options: ["Yes", "No"],
        key: "isReconnectionDebt",
        // Show ONLY when reconnection = Yes
        condition: (state) => state.isReconnection === "Yes"
      }
      // 18 dec change end here
    ],
    "Remove_Meter": [
      {
        label: "Please confirm the Service Pressure Tier",
        type: "select",
        key: "pressureTier",
        options: [
          "Select the Pressure Tier",
          "Low Pressure",
          "Medium Pressure",
          "Intermediate Pressure",
          "High Pressure"
        ],
        defaultValue: this.pressuretier,
      },
      {
        label: "Select Medium Pressure Value",
        type: "select",
        key: "mediumPressureValue",
        options: ["Please select the Medium Pressure", "MP35", "MP65", "MP105", "MP180", "MP270"],
        condition: (state) => state.pressureTier === "Medium Pressure"
      },
      {
        label:
          "Please note the Removal job will require purging. Do you require NGM to carry out purging?",
        type: "radio",
        options: ["Yes", "No"],
        key: "purging",
        condition: () => this.meterSize !== "U6" // Hide when meter size is U6
      },
      // 3/12 modify by adil
      {
        label: "Please provide the purging certificate",
        type: "file",
        key: "purgingCertificateFile",
        required: true,                           // <-- mandatory
        // show only when the user selected No
        condition: (state) => state.purging === "No"
      }
      // 3/12 modify by adil end here
    ],
    "Exchange_ThirdParty": [
      {
        label: "Please confirm the Service Pressure Tier",
        type: "select",
        key: "pressureTier",
        options: [
          { label: "Select the Pressure Tier", value: "" },   // mandatory required 28/11
          "Low Pressure",
          "Medium Pressure",
          "Intermediate Pressure",
          "High Pressure"
        ],
        defaultValue: this.pressuretier,
      },
      {
        label: "Select Medium Pressure Value",
        type: "select",
        key: "mediumPressureValue",
        options: ["Please select the Medium Pressure", "MP35", "MP65", "MP105", "MP180", "MP270"],
        condition: (state) => state.pressureTier === "Medium Pressure"
      },
      {
        label: "Please confirm the required metering outlet pressure (mbar)",
        type: "text",
        key: "outletPressure",
        maxLength: 4,
        pattern: "^[0-9]{1,4}$", // Only digits, up to 4
        messageWhenPatternMismatch: "Enter a valid number (0-9999)",
        defaultValue: "21"
      },
      {
        label: "Please provide the expected peak hourly load (kWh)",
        type: "text",
        key: "peakLoad",
        maxLength: 8,
        pattern: "^[0-9]{1,8}$", // Only digits, up to 8
        messageWhenPatternMismatch: "Enter a valid number (0-99999999)",
      },
      {
        label:
          "Based on your initial inputs, we believe the following meter size would meet your requirements.",
        type: "select",
        key: "MeterSize",
        required: false,
        options: [],
      },
      // GT1 logic
      {
        label:
          "Is the new meter going into the existing or new service location?",
        type: "radio",
        options: ["Existing", "New"],
        key: "serviceLocation",
      },
      {
        label: 'Do you have GT1/Service Quotation?',
        type: 'radio',
        options: ['Yes', 'No'],
        key: 'gt1',
        condition: (state) => {
          const pressureTier = state?.pressureTier;
          const serviceLocation = state?.serviceLocation;
          const meterSize = state?.MeterSize;
          const gt1RequiredTiers = ['Medium Pressure', 'Intermediate Pressure', 'High Pressure'];
          const specialMeterSizes = ['Rotary', 'Turbine'];
          const upgrade = this.isUpgradeFromOriginal(meterSize);  // 28 jan change for upgrade model
          // Show GT1 question only when GT1 is required
          return (
            gt1RequiredTiers.includes(pressureTier) ||
            serviceLocation === 'New' ||
            specialMeterSizes.includes(meterSize) || upgrade
          );
        }
      },
      {
        label: 'Please attach GT1/Service Quotation document',
        type: 'file',
        key: 'gt1File',
        condition: (state) => {
          const pressureTier = state?.pressureTier;
          const serviceLocation = state?.serviceLocation;
          const meterSize = state?.MeterSize;
          const gt1RequiredTiers = ['Medium Pressure', 'Intermediate Pressure', 'High Pressure'];
          const specialMeterSizes = ['Rotary', 'Turbine'];
          const upgrade = this.isUpgradeFromOriginal(meterSize);  // 28 jan change for upgrade model
          const gt1Required =
            gt1RequiredTiers.includes(pressureTier) ||
            serviceLocation === 'New' ||
            specialMeterSizes.includes(meterSize) || upgrade;

          return gt1Required && state?.gt1 === 'Yes';
        }
      },
      {
        label:
          'This job requires a GT1 to be completed by the network provider and the GT1 survey attached, therefore it cannot be raised. If you have any further questions please contact 0800 001 4340.',
        type: 'error',
        key: 'gt1Error',
        required: false,
        condition: (state) => {
          const pressureTier = state?.pressureTier;
          const serviceLocation = state?.serviceLocation;
          const meterSize = state?.MeterSize;
          const gt1RequiredTiers = ['Medium Pressure', 'Intermediate Pressure', 'High Pressure'];
          const specialMeterSizes = ['Rotary', 'Turbine'];
          const upgrade = this.isUpgradeFromOriginal(meterSize);  // 28 jan change for upgrade model
          const gt1Required =
            gt1RequiredTiers.includes(pressureTier) ||
            serviceLocation === 'New' ||
            specialMeterSizes.includes(meterSize) || upgrade;
          // Show error ONLY when GT1 is required AND user selected "No"
          return gt1Required && state?.gt1 === 'No';
        }
      },
      // NEW: Existing installation location (visible when serviceLocation = "New")
      {
        label: "Existing Meter Installation location?",
        type: "select",
        key: "existingInstallationLocation",
        options: ["Select", "In the Main Building", "Meter Compound", "Meter House"],
        condition: (state) => state?.serviceLocation === "New"
      },
      // 28/11 end here
      // Housing logic
      {
        label: "Is housing required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "housingRequired",
        condition: (state) => {
          const meterSize = state.MeterSize;
          const gt1RequiredSizes = [
            "U16",
            "U25",
            "U40",
            "U65",
            "U100",
            "U160",
            "Rotary",
            "Turbine",
          ];
          // Hide for U6
          if (meterSize === "U6") {
            return false;
          }
          // Show for U16 and greater
          if (gt1RequiredSizes.includes(meterSize)) {
            return true;
          }
          return false;
        },
      },
      {
        label: "Please select type of housing required",
        type: "radio",
        options: ["Free Standing", "Wall Mounted"],
        key: "housingType",
        condition: (state) => {
          const meterSize = state.MeterSize;
          const gt1RequiredSizes = [
            "U25",
            "U40",
            "U65",
            "U100",
            "U160",
            "Rotary",
            "Turbine",
          ];

          // Hide for U6
          if (meterSize === "U6") {
            return false;
          }

          // Show only for U16 when housingRequired = Yes
          if (meterSize === "U16" && state.housingRequired === "Yes") {
            return true;
          }
          // Hide for sizes greater than U16
          if (gt1RequiredSizes.includes(meterSize)) {
            return false;
          }
          return false;
        },
      },
      {
        label: "Housing Model",
        type: "text",
        key: "HModel",
        disabled: true,
        readOnly: true,
        required: false,
        condition: (state) =>
          state.housingRequired === "Yes" &&
          !["U6", "Rotary", "Turbain"].includes(state.MeterSize)
      },
      {
        label: "Is a base Required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "baseRequired",
        condition: (state) =>
          state.housingRequired === "Yes" &&
          state.housingType === "Free Standing",
      },
      // Additional logic
      {
        label: "Change Payment Type?",
        type: "radio",
        options: ["Yes", "No"],
        key: "changePaymentType",
        condition: (state) => state.MeterSize === "U6"
      },
      {
        label: "Required Meter Payment Type",
        type: "radio",
        options: ["Credit", "Pre payment"],
        key: "paymentMethod",
        condition: (state) => state.changePaymentType === "Yes" && state.MeterSize === "U6"
      },
      {
        label: "Are there any special electric interfaces required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "electricInterface",
      },
      {
        label: "Is a meter by-pass required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "meterBypass",
      },
      {
        label: "Is a converter required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "converterRequired",
      },
      {
        label: "Is a twin stream pressure reduction installation required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "twinStream",
      },
      {
        label: "Do you require an AMR device?",
        type: "radio",
        options: ["Yes", "No"],
        key: "amrDevice",
      },
    ],
    "Install_Housing": [
      // Question 1: Service Pressure Tier (Dropdown)
      {
        label: "Please confirm the Service Pressure Tier",
        type: "select",
        key: "pressureTier",
        options: [
          { label: "Select the Pressure Tier", value: "" }, // mandatory required 28/11
          "Low Pressure",
          "Medium Pressure",
          "Intermediate Pressure",
          "High Pressure"
        ],
        defaultValue: this.pressuretier,
      },
      {
        label: "Select Medium Pressure Value",
        type: "select",
        key: "mediumPressureValue",
        options: ["Please select the Medium Pressure", "MP35", "MP65", "MP105", "MP180", "MP270"],
        condition: (state) => state.pressureTier === "Medium Pressure"
      },
      // Question 2: Required Metering Outlet Pressure (Text)
      {
        label: "Please confirm the required metering outlet pressure (mbar)",
        type: "text",
        key: "outletPressure",
        defaultValue: "21"
      },
      // Question 3: Expected Peak Hourly Load 
      {
        label: "Please provide the expected peak hourly load (kWh)",
        type: "text",
        key: "peakLoad",
      },
      // Question 4: Meter Housing Size 
      {
        label: "Please select the appropriate meter housing size",
        type: "select",
        options: [],
        key: "MeterSize",
        required: false,
      },
      // Question 5: Meter Housing Type (Text)
      {
        label: "Please select the appropriate meter housing type",
        type: "radio",
        options: ["Free Standing", "Wall Mounted"],
        key: "housingType",
        condition: (state) => state.MeterSize === "U16"
      },
    ],
    "Exchange_Housing": [
      // Question 5: Meter Housing Type (Text)
      {
        label: "Please select the appropriate meter housing type",
        type: "radio",
        options: ["Free Standing", "Wall Mounted"],
        key: "housingType",
        condition: () => this.meterSize === "U16"
      },
    ],
    "MeterMove_Reposition": [
      {
        label:
          "Is the meter to be moved within two meters of the existing Service pipe/ECV?",
        type: "radio",
        options: ["Yes", "No"],
        key: "withinTwoMeters",
        required: true
      },
      {
        label:
          "Please provide photos of the existing meter position and desired location",
        type: "file",
        key: "existingMeterPhotos_Reposition",
        required: true,
        condition: () => this._status === 'Commercial'
      },
    ],
    "MeterMove_Relocation": [
      {
        label:
          "Please provide photos of the existing meter position and desired location",
        type: "file",
        key: "existingMeterPhotos_Relocation",
        condition: () => this._status === 'Commercial'
      },
      {
        label:
          "Please attach the GT1 document or Service Quotation for the new Service location",
        type: "file",
        key: "serviceQuotation",
      },
    ],
    "OtherVisits_Damaged": [
      {
        label: "Is housing required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "housingRequired",
        // Show ONLY for U16
        condition: () => this.meterSize !== "U6" // Hide when meter size is U6
      },
      {
        label: "Please select type of housing required",
        type: "radio",
        options: ["Free Standing", "Wall Mounted"],
        key: "housingType",
        // Show ONLY for U16 AND when the first question is answered Yes
        condition: (state) => this.meterSize === "U16" && state.housingRequired === "Yes"
      },
      // â€¦ the rest of Damaged questions â€¦
      {
        label: "Is the damage limited to the meter itself?",
        type: "radio",
        options: ["Yes", "No", "Don't Know"],
        key: "damageLimited",
      },
      {
        label: "Do you have a crime reference number?",
        type: "radio",
        options: ["Yes", "No"],
        key: "hasCrimeRef",
      },
      {
        label: "Crime Reference Number",
        type: "text",
        key: "crimeRefNumber",
        maxLength: 20,
        pattern: "^[A-Za-z0-9]{1,20}$",
        messageWhenPatternMismatch: "Crime Reference Number must be alphanumeric and up to 20 characters.",
        condition: (state) => state.hasCrimeRef === "Yes"
      },
    ],
    "OtherVisits_ServiceEngineerHire": [
      {
        label:
          "Please upload the request file ",
        type: "file",
        key: "existingMeterPhotos_SEH",
        required: true
      },
    ],
    "OtherVisits_PostEmergencyMeterWorks": [
      {

        label:
          "Please upload the request file",
        type: "file",
        key: "existingMeterPhotos_PEMW",
        required: true
      },
    ],
    // 3/12 modify by adil
    "OtherVisits_TheftOfgasExchange": [

      {
        label: "Please confirm the Service Pressure Tier",
        type: "select",
        key: "pressureTier",
        options: [
          { label: "Select the Pressure Tier", value: "" },  // placeholder (required)
          "Low Pressure",
          "Medium Pressure",
          "Intermediate Pressure",
          "High Pressure"
        ],
        defaultValue: this.pressuretier   // keeps site/context default if you pass it
      },
      {
        label: "Select Medium Pressure Value",
        type: "select",
        key: "mediumPressureValue",
        options: ["Please select the Medium Pressure", "MP35", "MP65", "MP105", "MP180", "MP270"],
        condition: (state) => state.pressureTier === "Medium Pressure"
      },
    ],
    "OtherVisits_Adversarial_Removal": [
      {
        label: "Please confirm the Service Pressure Tier",
        type: "select",
        key: "pressureTier",
        options: [
          { label: "Select the Pressure Tier", value: "" },  // placeholder (required)
          "Low Pressure",
          "Medium Pressure",
          "Intermediate Pressure",
          "High Pressure"
        ],
        defaultValue: this.pressuretier   // keeps site/context default if you pass it
      },
      {
        label: "Select Medium Pressure Value",
        type: "select",
        key: "mediumPressureValue",
        options: ["Please select the Medium Pressure", "MP35", "MP65", "MP105", "MP180", "MP270"],
        condition: (state) => state.pressureTier === "Medium Pressure"
      },
      {

        label:
          "Please note the Removal job will require purging. Do you require NGM to carryout purging?",
        type: "radio",
        options: ["Yes", "No"],
        key: "purging",
        required: true,
        // â¬‡ï¸ NEW: default to Yes and lock it
        defaultValue: "Yes",
        disabled: true,   // will be honored by dynamicQuestions mapping
        readOnly: true    // extra guard for inputs that respect readOnly
      },
      // File upload (required when purging = No)
      {
        label: "Please provide the purging certificate",
        type: "file",
        key: "purgingCertificateFile",
        required: true,
        condition: (state) => state.purging === "No"
      },
      // â¬‡ï¸ Info text BELOW the file upload (same condition)
      {
        label: "Please note that entire installation will be removed.",
        type: "info",
        key: "adversarialRemovalNotice",
        required: false,

      }
    ],
    // 3/12 modify by adil end here

    "OtherVisits_PressureChange": [
      {
        label: "Please confirm the required metering outlet pressure (mbar)",
        type: "text",
        key: "outletPressure",
        maxLength: 4,
        pattern: "^[0-9]{1,4}$", // Only digits, up to 4
        messageWhenPatternMismatch: "Enter a valid number (0-9999)",
        defaultValue: "21"
      },
      {
        label: "Do you require a pressure increase / pressure decrease?",
        type: "radio",
        options: ["Increase", "Decrease"],
        key: "pressureChangeType",
      },
    ],
    "OtherVisits_Reconnect": [
      {
        label: "Required Payment Type",
        type: "radio",
        options: ["Credit", "Pre Payment"],
        key: "requiredPaymentType",
      },
      {
        label: "Reconnect after Debt?",
        type: "radio",
        options: ["Yes", "No"],
        key: "reconnectAfterDebt",
      },
    ],
    "OtherVisits_SiteVisit": [
      {
        label: "Select Asset Type",
        type: "select",
        options: ["Select Asset Type", "Meter", "Converter", "Isolation"],
        key: "assetType",
      },
      {
        label: "What is the reason for site visit?",
        type: "select",
        key: "siteVisitReason",
        options: [], // Will be dynamically populated
        condition: (state) =>
          state.assetType && state.assetType !== "Select Asset Type"
      },
    ],
    "Remove_Pickup": [
      {
        label: "What Equipment is required to be picked up?",
        type: "radio",
        options: ["Meter", "Converter"],
        key: "pickupEquipment",
      },
      {
        label: "Provide Final Read",
        type: "text",
        key: "finalRead",
        maxLength: 5,
        pattern: "^[0-9]{4,5}$",
        required: false,
        messageWhenPatternMismatch: "Final Read must be 4 or 5 digits (no letters or symbols)",
        // Show ONLY when pickupEquipment is Meter
        // (Optionally also gate by meter size if thatâ€™s a requirement)
        condition: (state) => state.pickupEquipment === "Meter",
        condition: (state) => state.pickupEquipment === "Meter" && this.meterSize === "U6"
      },
      {
        label: "Is the pickup address different from above?",
        type: "radio",
        options: ["Yes", "No"],
        key: "isDifferentAddress",
        defaultValue: "No", //
        condition: () => this.meterSize === "U6"
      },
      {
        label: "Building Name",
        type: "text",
        key: "buildingName",
        condition: (state) => state.isDifferentAddress === "Yes",
      },
      {
        label: "Building Number",
        type: "text",
        key: "buildingNumber",
        condition: (state) => state.isDifferentAddress === "Yes",
      },
      {
        label: "Street",
        type: "text",
        key: "street",
        condition: (state) => state.isDifferentAddress === "Yes",
      },
      {
        label: "Dependant Locality",
        type: "text",
        key: "dependentLocality",
        condition: (state) => state.isDifferentAddress === "Yes",
      },
      {
        label: "Post Town",
        type: "text",
        key: "postTown",
        condition: (state) => state.isDifferentAddress === "Yes",
      },
      {
        label: "Post Code",
        type: "text",
        key: "postCode",
        condition: (state) => state.isDifferentAddress === "Yes",
      },
    ],
  };

  // modify on 10 dec

  // Add this getter
  get disableGetPrice() {
    // If locked, or the price button shouldn't be shown/enabled, return true
    return this.isLocked || !this.priceButtonFlag;
  }
  // If you had inline logical ops in template, avoid them with getters
  get uploadBoxClass() {
    // When locked, add a disabled class for visual + pointer-block
    return this.isLocked ? 'upload-box disabled' : 'upload-box';
  }
  // modify on 10 dec end here
  // 3/12 modify full method by Adil for pressure change
  get dynamicQuestions() {
    const subtypeId = this.selectedSubType?.id;
    let questions = this.questionConfig[subtypeId] || [];
    // 8 jan change
    // Subtypes that should inherit & lock payment method from MPRN
    const targetedSubtypesForPaymentLock = new Set(['Exchange_LikeForLike']);
    const lockPaymentFromMprn =
      targetedSubtypesForPaymentLock.has(this.selectedSubType?.id) &&
      (this._paymentMechanism === 'Credit' || this._paymentMechanism === 'Pre Payment');
    // 8 jan change end here
    // 18 dec change
    const isInstallMeter =
      (subtypeId === 'Install_Meter') ||
      (this.selectedSubType?.label?.trim().toLowerCase() === 'meter');
    //const restrictYesFlow = isInstallMeter && this._residentialU6Site;
    const yesFlowActive = isInstallMeter && this._residentialU6Site;
    // 15 jan change
    // NEW flags for payment behaviour (Install â†’ Meter only)
    const resYes = isInstallMeter && this._residentialU6Site === true;            // Residential = Yes
    const resNoU6 = isInstallMeter && this._residentialU6Site === false
      && (this.state?.MeterSize || '') === 'U6';                                   // Residential = No AND U6
    const resNoNonU6 = isInstallMeter && this._residentialU6Site === false
      && !!this.state?.MeterSize && this.state.MeterSize !== 'U6';                // Residential = No AND Non-U6
    // 15 jan change end here
    // 4 march
    // NEW: Independent Residential (Status from MPRN, U6 Yes/No not provided)
      const indepRes = isInstallMeter
      && (this._residentialU6Provided !== true)
      && (this._status === 'Residential');
        // 4 march end
    // --- When Yes-flow is active, keep ONLY these 6 in this order
    if (yesFlowActive) {
      const order = [
        'pressureTier',
        'outletPressure',
        'peakLoad',
        'MeterSize',
        'paymentMethod',
        'isNewConnection',
        'isReconnection',
        'isReconnectionDebt'
      ];
      const allow = new Set(order);
      // 1) Prepopulate defaults for the Yes-flow

      // if (!this.state) this.state = {};

      // Peak load must be 64

      // this.state.peakLoad = '64';

      // Payment default to Credit

      //  if (!this.state.paymentMethod) this.state.paymentMethod = 'Credit';
      // 2) Filter only the allowed questions
      const filtered = questions.filter(q => allow.has(q.key));
      // 3) Sort by the requested order
      questions = filtered.sort((a, b) => order.indexOf(a.key) - order.indexOf(b.key));
      console.log('[Child] YES flow: Install_Meter ordered keys =',
        questions.map(q => q.key).join(', '));
    } else {
      console.log('[Child] NO flow / other subtype: full questions count =', questions.length);
    }
    // 18 dec change end here
    const addrKeys = new Set([
      'buildingName',
      'buildingNumber',
      'street',
      'dependentLocality',
      'postTown',
      'postCode'
    ]);
    // 6 jan change
    // ðŸ”’ Keys that must be read-only when Residential U6 = Yes under Install â†’ Meter
    const readonlyKeysYesFlow = new Set(['peakLoad', 'MeterSize', 'outletPressure']);
    // 6 jan change end here
    // 8 jan change
    // --- PAYMENT METHOD LOCKS DRIVEN BY MPRN (parent value) ---
    const validPm = (this._paymentMechanism === 'Credit' || this._paymentMechanism === 'Pre Payment');

    // Subtypes that should mirror MPRN (same value) and be locked
    const lockSamePmSubtypes = new Set(['Exchange_LikeForLike', 'OtherVisits_Reconnect']); //  add Reconnect here

    // Subtypes that should invert MPRN (opposite value) and be locked
    const lockInversePmSubtypes = new Set(['Exchange_MeterType']); //  invert on Meter Type

    const lockSame = lockSamePmSubtypes.has(this.selectedSubType?.id) && validPm;
    const lockInverse = lockInversePmSubtypes.has(this.selectedSubType?.id) && validPm;

    // Decide the value to force per subtype
    const pmFromMprn = this._paymentMechanism; // 'Credit' | 'Pre payment'
    const pmInverse = (pmFromMprn === 'Credit') ? 'Pre Payment'
      : (pmFromMprn === 'Pre Payment') ? 'Credit'
        : pmFromMprn;
    // 8 jan change end here
    // 26 jan change
    // Show guidance table only for these three subtypes

    const TABLE_SUBTYPES = new Set([
      'Install_Meter',
      'Exchange_SpecificationChange',
      'Exchange_ThirdParty'
    ]);

    if (TABLE_SUBTYPES.has(subtypeId)) {
      // Create a synthetic question object for the table
      const guidanceQ = {
        key: '__guidance_table__',
        type: 'info',         // not an input
        // label: 'Sizing Guidance', // optional heading
        isTable: true,         // <-- custom flag for template
        visible: true,
        required: false
      };

      // Place it at the end, or insert at any index you prefer
      questions = [...questions, guidanceQ];
    }
    // 26 jan change end here

    return questions.map((q) => { // 7 jan change

      // 7 march
     
// REMOVE only for dependent No (U6 explicitly answered = No)
 if (
   this.selectedSubType?.id === 'Install_Meter'
   && this._residentialU6Provided === true
   && this._residentialU6Site === false
   && (q.key === 'isNewConnection' || q.key === 'isReconnection' || q.key === 'isReconnectionDebt')
 ) {
   return null; // do not render these three questions at all
 }

    // 7 march end
      const reconLock = (this.selectedSubType?.id === 'Install_Meter'
        && this.state?.isNewConnection === 'No');
      // 7 jan change end here
      // 19 dec change
      // Normalize SELECT options
      let normalizedSelectOptions = [];

      
      // Current value from state
      let currentValue = this.state[q.key];
      const isBlank =
        currentValue === undefined ||
        currentValue === null ||
        (typeof currentValue === 'string' && currentValue.trim() === '') ||
        (Array.isArray(currentValue) && currentValue.length === 0);

      // --- Inject runtime default for pressureTier (so first render has a value) ---
      if (isBlank && q.key === 'pressureTier') {
        const siteTier = this._pressureTier ?? this.pressuretier;
        if (siteTier && typeof siteTier === 'string' && siteTier.trim() !== '') {
          currentValue = siteTier;                   // e.g., "Low Pressure"
          this.state[q.key] = currentValue;          // persist for conditions/validation
        }
      }
      // 15 jan change
      if (q.key === 'mediumPressureValue') {
        const tierIsMedium = this.state?.pressureTier === 'Medium Pressure';
        const brand = this._pressuretierBrand;
        const blank =
          currentValue === undefined ||
          currentValue === null ||
          String(currentValue).trim() === '';
        if (tierIsMedium && brand && blank) {
          currentValue = brand;
          this.state[q.key] = brand;
        }
      }
      // 15 jan change end here

      // --- Normalize SELECT options AFTER currentValue is set ---
      //let normalizedSelectOptions = [];
      if (q.type === 'select') {
        normalizedSelectOptions = (q.options || []).map((opt) => {
          const normalized =
            typeof opt === 'string'
              ? { label: opt, value: opt }
              : { label: opt.label, value: opt.value };
          return {
            ...normalized,
            selected: normalized.value === currentValue
          };
        });
        // 4 march
        // NEW: Independent Residential — force MeterSize to U6
if (indepRes && q.key === 'MeterSize') {
  currentValue = 'U6';
  this.state[q.key] = 'U6';
}
  // 4 march end

    
      }
      // --- Normalize RADIO options (checked) ---
      let normalizedRadioOptions = [];
      if (q.type === 'radio') {
        normalizedRadioOptions = (q.options || []).map((opt) => {
          const normalized =
            typeof opt === 'string'
              ? { label: opt, value: opt }
              : { label: opt.label, value: opt.value };
          return { ...normalized, checked: normalized.value === currentValue };
        });
        // 4 march
        // NEW: Independent Residential — mirror Payment Method from Asset Details
if (this.selectedSubType?.id === 'Install_Meter'
    && q.key === 'paymentMethod'
    && this._residentialU6Provided !== true) {
  const pm = this.normalizePaymentMethod(this._paymentMechanism);
  currentValue = pm;
  this.state[q.key] = pm;
  normalizedRadioOptions = (q.options ?? []).map(opt => {
    const value = (typeof opt === 'string') ? opt : (opt.value ?? opt.label);
    const label = (typeof opt === 'string') ? opt : (opt.label ?? opt.value);
    return { label, value, checked: value === pm };
  });
}
  // 4 march end
  // 5 march
    // 5 Mar — Dependent “No” + Non-U6 (Install → Meter): force Credit
if (resNoNonU6 && q.key === 'paymentMethod') {
  const credit = 'Credit';
  currentValue = credit;
  this.state[q.key] = credit;
  normalizedRadioOptions = (q.options ?? []).map(opt => {
    const value = (typeof opt === 'string') ? opt : (opt.value ?? opt.label);
    const label = (typeof opt === 'string') ? opt : (opt.label ?? opt.value);
    return { label, value, checked: value === credit };
  });
}
  // 5 march end
        // 8 jan change
        // âœ… LikeForLike + Reconnect: mirror MPRN value
        if (lockSame && (q.key === 'paymentMethod' || q.key === 'requiredPaymentType')) {
          const pm = pmFromMprn;               // same as MPRN
          currentValue = pm;
          this.state[q.key] = pm;
          normalizedRadioOptions = (q.options ?? []).map(opt => {
            const value = (typeof opt === 'string') ? opt : (opt.value ?? opt.label);
            const label = (typeof opt === 'string') ? opt : (opt.label ?? opt.value);
            return { label, value, checked: value === pm };
          });
        }
        // âœ… Meter Type: inverse of MPRN value
        if (lockInverse && q.key === 'newMeterPaymentMethod') {
          const pm = pmInverse;                 // opposite of MPRN
          currentValue = pm;
          this.state[q.key] = pm;
          normalizedRadioOptions = (q.options ?? []).map(opt => {
            const value = (typeof opt === 'string') ? opt : (opt.value ?? opt.label);
            const label = (typeof opt === 'string') ? opt : (opt.label ?? opt.value);
            return { label, value, checked: value === pm };
          });
        }
        // 15 jan change
        // ðŸ”’ Force Credit when locked (Residential=Yes OR Residential=No & Non-U6)
        // if (q.key === 'paymentMethod' && (resYes || resNoNonU6)) {
        //   const credit = 'Credit';
        //   currentValue = credit;
        //   this.state[q.key] = credit;
        //   normalizedRadioOptions = (q.options ?? []).map(opt => {
        //     const label = typeof opt === 'string' ? opt : (opt.label ?? opt.value);
        //     const value = typeof opt === 'string' ? opt : (opt.value ?? opt.label);
        //     return { label, value, checked: value === credit };
        //   });
        // }
        // 15 jan change end here

        //  Force paymentMethod to the MPRN value & show it checked
        // if (q.key === 'paymentMethod' && lockPaymentFromMprn) {
        //   const pm = this._paymentMechanism; // 'Credit' or 'Pre payment'
        //   currentValue = pm;
        //   this.state.paymentMethod = pm;     // keep state aligned
        //   normalizedRadioOptions = (q.options ?? []).map(opt => {
        //     const value = typeof opt === 'string' ? opt : (opt.value ?? opt.label);
        //     const label = typeof opt === 'string' ? opt : (opt.label ?? opt.value);
        //     return { label, value, checked: value === pm };
        //   });
        // }
        // 8 jan change end here

        // 7 jan change


        // âœ… When reconnection is visible, force the UI to show "Yes" checked
        if (q.key === 'isReconnection' && reconLock) {
          currentValue = 'Yes';
          this.state[q.key] = 'Yes';
          normalizedRadioOptions = (q.options ?? []).map(opt => {
            const label = typeof opt === 'string' ? opt : (opt.label ?? opt.value);
            const value = typeof opt === 'string' ? opt : (opt.value ?? opt.label);
            return { label, value, checked: value === 'Yes' };
          });
        }
        // 7 jan change end here

        // 6 jan change


        // existing code above:
        const yesFlowActive = isInstallMeter && this._residentialU6Site;

        // ... inside the map, after you build normalizedRadioOptions:
        // if (yesFlowActive && q.key === 'paymentMethod') {
        //   // Force current value to Credit
        //   const credit = 'Credit';
        //   currentValue = credit;
        //   this.state[q.key] = credit;

        //   // Ensure radio options reflect Credit checked
        //   normalizedRadioOptions = (q.options ?? []).map(opt => {
        //     const label = typeof opt === 'string' ? opt : opt.label ?? opt.value;
        //     const value = typeof opt === 'string' ? opt : opt.value ?? opt.label;
        //     return {
        //       label,
        //       value,
        //       checked: value === credit
        //     };
        //   });
        // }
        // 6 jan change end here
        // NEW: Force value for "isNewConnection" in Install → Meter
        if (this.selectedSubType?.id === 'Install_Meter' && q.key === 'isNewConnection') {
          const newConn = this._residentialU6Provided ? 'Yes' : 'No';
          currentValue = newConn;
          this.state[q.key] = newConn;
          normalizedRadioOptions = (q.options ?? []).map(opt => {
            const value = (typeof opt === 'string') ? opt : (opt.value ?? opt.label);
            const label = (typeof opt === 'string') ? opt : (opt.label ?? opt.value);
            return { label, value, checked: value === newConn };
          });
        }
      }

      // Files logic (unchanged)
      const files =
        q.type === 'file' &&
          this.uploadedFilesByKey &&
          Array.isArray(this.uploadedFilesByKey[q.key]) &&
          this.uploadedFilesByKey[q.key].length > 0
          ? this.uploadedFilesByKey[q.key]
          : null;

      // 20 jan change

      // Inline message logic (non-invasive)
      const uploadedCount = (this.uploadedFilePayloadByKey?.[q.key] || []).length;
      const requiredNow = (q.type === 'file') && (q.required === true);
      const missingNow = requiredNow && uploadedCount === 0;

      // 20 jan change end here

      // Address maxLength
      const addrKeys = new Set([
        'buildingName', 'buildingNumber', 'street',
        'dependentLocality', 'postTown', 'postCode'
      ]);
      const isAddr = addrKeys.has(q.key);
      const addrMax = q.key === 'postCode' ? 10 : 40;

      // 4 march
      // NEW: Independent Residential — force text values
if (indepRes && q.key === 'outletPressure') {
  currentValue = '21';
  this.state[q.key] = '21';
}
if (indepRes && q.key === 'peakLoad') {
  currentValue = '64';
  this.state[q.key] = '64';
}
  // 4 march end
      return {
        ...q,
        required: q.required ?? true,
        visible: q.condition ? q.condition(this.state) : true,
        selectOptions: normalizedSelectOptions,
        radioOptions: normalizedRadioOptions,
        isSelect: q.type === 'select',
        isNumber: q.type === 'number',
        isRadio: q.type === 'radio',
        isFile: q.type === 'file',
        isText: q.type === 'text',
        isTextarea: q.type === 'textarea',
        isDate: q.type === 'date',
        isError: q.type === 'error',
        isGt1File: q.key === 'gt1File',   // 19 jan change
        isRequiredFileMissing: this.hasTriedGetPrice && missingNow,   // 20 jan change
        isInfo: q.type === 'info',
        value: currentValue ?? '',
        error: this.errors ? this.errors[q.key] : '',
        inputClass: this.errors && this.errors[q.key] ? 'input-error' : '',
        maxLength: isAddr ? addrMax : q.maxLength,
        files,
        // 10 dec change
        // When locked, force appropriate disabled/readOnly per input type
        // disabled: this.isLocked || q.disabled === true || q.isFile || q.isRadio || q.isSelect, // 6 june change comment this
        // readOnly: this.isLocked || q.readOnly === true || q.isText || q.isTextarea || q.isNumber || q.isDate   // 6 june change comment this
        // 6 june change
        // Do not auto-disable by type; only honor explicit disabled or lock
        //disabled: (this.isLocked || q.disabled === true),

         disabled: (
  this.isLocked
  || q.disabled === true
  || (reconLock && q.key === 'isReconnection')
  || (lockSame && (q.key === 'paymentMethod' || q.key === 'requiredPaymentType'))
  || (lockInverse && (q.key === 'newMeterPaymentMethod'))
  // NEW: Independent Residential locks
  || (indepRes && q.key === 'MeterSize')
  || (this.selectedSubType?.id === 'Install_Meter' && q.key === 'paymentMethod' && this._residentialU6Provided !== true)
  // Keep "Is it a new connection?" non-editable; value controlled by parent U6 radio
  || (this.selectedSubType?.id === 'Install_Meter' && q.key === 'isNewConnection') || (resNoNonU6 && q.key === 'paymentMethod') // 5 Mar: Dependent “No” + Non-U6 → lock payment
),


readOnly: (
  this.isLocked
  || q.readOnly === true
  || (yesFlowActive && readonlyKeysYesFlow.has(q.key))
  // NEW: Independent Residential → make text fields read-only
  || (indepRes && (q.key === 'outletPressure' || q.key === 'peakLoad'))
),
        // 6 june change end here
        // 10 dec change end here
      };
    }) .filter(Boolean);
    
  }

  // 28 jan change

  // Keep your existing @track isTable = true;
  get isTableVisible() {
    const id = this.selectedSubType?.id;
    const TABLE_SUBTYPES = new Set([
      'Install_Meter',
      'Exchange_SpecificationChange',
      'Exchange_ThirdParty'
    ]);
    // Only show when table is globally enabled AND subtype is allowed
    return this.isTable && TABLE_SUBTYPES.has(id);
  }

  // 28 jan change end here

  // 3/12 modify full method by adil end here

  highlightSelected(event, sectionSelectors) {
    const selectors = Array.isArray(sectionSelectors) ? sectionSelectors : [sectionSelectors];

    selectors.forEach(sel => {
      this.template.querySelectorAll(`${sel} .card-radio`).forEach(el => {
        el.classList.remove('selected');
      });
    });

    event.target.closest('.card-radio')?.classList.add('selected');
  }

  // 19 jan change


  // shows message only after clicking Show Price
  hasTriedGetPrice = false;

  // GT1 upload required only when GT1 = Yes
  get isGt1UploadRequired() {
    return this.state?.gt1 === 'Yes';
  }

  // Show message ONLY for GT1 file upload
  get showGt1UploadError() {
    const files = this.uploadedFilePayloadByKey?.gt1File || [];
    return this.hasTriedGetPrice && this.isGt1UploadRequired && files.length === 0;
  }


  get isGt1FileQuestion() {
    return this.currentQuestionKey === 'gt1File';
  }


  // 19 jan change end here


  // 28 jan change for GT1 upgrade

  // --- Add near other helpers ---
  // Order of meter models from smallest to largest
  SIZE_ORDER = ["U6", "U16", "U25", "U40", "U65", "U100", "U160", "Rotary", "Turbine"];

  /** Get numeric rank; returns -1 if unknown */
  rankSize(size) {
    if (!size) return -1;
    const val = String(size).trim();
    return this.SIZE_ORDER.indexOf(val);
  }

  /** Did we upgrade from the parent meter-size to the new (recommended) size? */
  isUpgradeFromOriginal(newSize) {
    const base = this.rankSize(this.meterSize);   // <-- parent value from <c-... meter-size=...>
    const next = this.rankSize(newSize);
    return base >= 0 && next >= 0 && next > base;
  }

  // 28 jan change end here for Gt1 upgrade


  handleRequestSelect(event) {
    this.highlightSelected(event, '.card-group');  // highlight
    const selectedValue = event.target.value;
    this.updateRequestTypesClass();
    this.uiConfig.requestTypes = this.uiConfig.requestTypes.map(req => {
      return {
        ...req,
        cssClass: req.label === this.selectedRequestType
          ? "card-radio selected"
          : "card-radio"
      };
    });

    this.selectedRequest = this.uiConfig.requestTypes.find(req => req.label === selectedValue);
    this.selectedJob = null;
    this.selectedSubType = null;
    this.filteredSubTypes = [];
    this.meterSuggestions = [];
  }

  // 22 jan change



  // Hide Get Price for these two Other Visits subtypes only
  get isNonPricedOtherVisit() {
    const id = this.selectedSubType?.id;
    return id === 'OtherVisits_ServiceEngineerHire'
      || id === 'OtherVisits_PostEmergencyMeterWorks';
  }

  // 22 jan change end here

  // refresh subtype 28/11 start here
  handleJobSelect(event) {
    console.log('metersize***', this.meterSize);
    console.log('Status***', this._status);
    this.showMeterErrorMessage = false;
    this.uploadedFilePayloadByKey = [];
    this.uploadedFilesByKey = [];
    this.errorMessage = '';
    this.selectJob = true;
    this.priceButtonFlag = (this.selectJob && this.selectSubType) ? true : false;

    // 1) Highlight selected card
    this.highlightSelected(event, '.card-group');

    // 2) Track selected job type
    const selectedJobLabel = event.target.value;
    // const selectedJobLabel = event.currentTarget.dataset.value;
    console.log('selectedJobLabel >>', selectedJobLabel);
    this.selectedJobType = selectedJobLabel;
    this.selectedJob = selectedJobLabel;
    console.log('selectedJobLabel >>', selectedJobLabel);
    this.selectedRequest = {
      ...this.selectedRequest,
      jobTypes: this.selectedRequest.jobTypes.map(job => ({
        ...job,
        isChecked: job.label === selectedJobLabel,
        className:
          job.label === selectedJobLabel
            ? 'card-radio selected'
            : 'card-radio'
      }))
    };

    console.log('selectedRequest >>', this.selectedRequest);
    this.updateRequestTypesClass();

    const list = this.jobTypeSubtypes[selectedJobLabel] || [];
    // 4) Refresh subtypes
    const eqLabel = (item, label) => (item.label || '').toLowerCase() === label.toLowerCase();

    let filtered = [];
    if (this.thirdParty) {
      // Apply explicit per-job rules (no Map)     

      if (selectedJobLabel === 'Install') {
        // Meter only
        filtered = list.filter(item => eqLabel(item, 'Meter') || item.id === 'Install_Meter');

      } else if (selectedJobLabel === 'Exchange') {
        console.log('this._status', this._status);
        const sresidental = (this._status === 'Residential');
        // Third Party only
        filtered = list.filter(item => eqLabel(item, 'Third Party') || item.id === 'Exchange_ThirdParty' || eqLabel(item, 'Accuracy Test') || item.id === 'Exchange_AccuracyTest' || (sresidental && (eqLabel(item, 'Exchange Meter Type') || item.id === 'Exchange_MeterType' || eqLabel(item, 'Like for Like') || item.id === 'Exchange_LikeForLike')));
      } else if ((selectedJobLabel ?? '').trim().toLowerCase() === 'other visits') {
        const status = (this._status ?? '').trim().toLowerCase();
        const isCommercial = status === 'commercial';

        const isAdversarial = (item) =>((eqLabel(item, 'Adversarial removal') ||
          item.id === 'OtherVisits_Adversarial_Removal') && (this.meterSize || '').toUpperCase() !== 'U6');

        const isTheft = (item) =>
          eqLabel(item, 'Theft of Gas Exchange') ||
          item.id === 'OtherVisits_TheftOfGasExchange'; // ensure correct casing!

        if (isCommercial) {
          // Show ONLY these two for commercial
          filtered = list.filter(item => isAdversarial(item) || isTheft(item));
        }
      } else if (selectedJobLabel === 'Remove') {
        // Meter + Pickup
        filtered = list.filter(item =>
          eqLabel(item, 'Meter') || item.id === 'Remove_Meter' ||
          eqLabel(item, 'Pickup') || item.id === 'Remove_Pickup'
        );
      } else {
        // For any other job types (if present), default to no subtypes
        filtered = [];
      }

      // Clone for LWC reactivity
      this.filteredSubTypes = filtered.map(s => ({ ...s }));

    } else if (!this.thirdParty && (selectedJobLabel === 'Install' && this._status == 'Residential')) {
      console.log('Inside the loop');
      filtered = list.filter(item => eqLabel(item, 'Meter'));
      this.filteredSubTypes = filtered.map(s => ({ ...s }));
      console.log('this.filteredSubTypes', this.filteredSubTypes);
    } else if (!this.thirdParty && (selectedJobLabel === 'Remove')) {
      const includeConverter = (this._status === 'Commercial' && this.haszoo2);
      filtered = list.filter(item =>
        eqLabel(item, 'Meter') || item.id === 'Remove_Meter' ||
        eqLabel(item, 'Pickup') || item.id === 'Remove_Pickup' ||
        (includeConverter && (eqLabel(item, 'Converter') || item.id === 'Remove_Converter'))
      );
      this.filteredSubTypes = filtered.map(s => ({ ...s }));
    } else if (selectedJobLabel === 'Meter Move' && (this.meterSize === 'U6' || this._status == 'Residential')) {
      const reposition = list.filter(item => eqLabel(item, 'Reposition'));
      this.filteredSubTypes = reposition.map(s => ({ ...s }));
    } else if (selectedJobLabel === 'Meter Move' && (this._status === 'Commercial' || this.meterSize != 'U6')) {
      filtered = list.filter(item => eqLabel(item, 'Reposition') ||
        eqLabel(item, 'Relocation'));
      this.filteredSubTypes = filtered.map(s => ({ ...s }));
    } else if (!this.thirdParty && selectedJobLabel === 'Other Visits') {
      const isCommercial = this._status === 'Commercial';
      const isResidential = this._status === 'Residential';
      const meterSize = (this.meterSize || '').toUpperCase();
      const notU6 = meterSize !== 'U6';
      const payMech = this._paymentMechanism === 'Pre Payment';

      // Helper: allow by label OR by known id when present
      const isDamaged = (it) => eqLabel(it, 'Damaged') || it.id === 'OtherVisits_Damaged';
      const isAdversarialRemoval = (it) => eqLabel(it, 'Adversarial removal') || it.id === 'OtherVisits_Adversarial_Removal';
      const isPostCommissionChecks = (it) => eqLabel(it, 'Post Commissioning Checks') || it.id === 'OtherVisits_PostCommissioningChecks';
      const isPressureChange = (it) => eqLabel(it, 'Pressure Change') || it.id === 'OtherVisits_PressureChange';
      const isReconnect = (it) => eqLabel(it, 'Reconnect') || it.id === 'OtherVisits_Reconnect';
      const isSiteVisit = (it) => eqLabel(it, 'Site Visit') || it.id === 'OtherVisits_SiteVisit';
      const isTheftOfGasExchange = (it) => eqLabel(it, 'Theft of Gas Exchange') || it.id === 'OtherVisits_TheftOfgasExchange';
      const isChangeOfTenancy = (it) => eqLabel(it, 'Change Of Tenancy') || it.id === 'OtherVisits_ChangeOfTenancy';
      const isServiceEngineerHire = (it) => eqLabel(it, 'Service Engineer Hire') || it.id === 'OtherVisits_ServiceEngineerHire';
      const isPostEmergencyWorks = (it) => eqLabel(it, 'Post Emergency Meter Works') || it.id === 'OtherVisits_PostEmergencyMeterWorks';

      filtered = list.filter(item => {

        if (isCommercial) {
          if (isDamaged(item)) return true;
          if (isPostCommissionChecks(item)) return true;
          if (isPressureChange(item)) return true;
          if (isReconnect(item)) return true;
          if (isSiteVisit(item)) return true;
          if (isTheftOfGasExchange(item)) return true;
          if (notU6 && isAdversarialRemoval(item)) return true;
          if (isServiceEngineerHire(item) || isPostEmergencyWorks(item)) return true;
        }
        // if (isResidential && payMech && isChangeOfTenancy(item)) return true;
        if (isResidential) {
          if (isResidential && payMech && isChangeOfTenancy(item)) return true;
          if (isResidential && isDamaged(item)) return true;
        }
        return false;
      });

      this.filteredSubTypes = filtered.map(s => ({ ...s }));
    } else if (!this.thirdParty && selectedJobLabel === 'Exchange') {
      const isCommercial = this._status === 'Commercial';
      const isResidential = this._status === 'Residential';
      const hasZ002 = !!(this.haszoo2 ?? this.hasZ002);
      const isSpecChange = it => eqLabel(it, 'Specification Change') || it.id === 'Exchange_SpecificationChange';
      const isAccuracyTest = it => eqLabel(it, 'Accuracy Test') || it.id === 'Exchange_AccuracyTest';
      const isGPS = it => eqLabel(it, 'GPS') || it.id === 'Exchange_GPS';
      const isHousing = it => eqLabel(it, 'Housing') || it.id === 'Exchange_Housing';
      const isConverter = it => eqLabel(it, 'Converter') || it.id === 'Exchange_Converter';
      const isFaultyOnGas = it => eqLabel(it, 'Faulty(On Gas)') || it.id === 'Exchange_Faulty_OnGas';
      const isLikeForLike = it => eqLabel(it, 'Like For Like') || it.id === 'Exchange_LikeForLike';
      const isExchangeMeterType = it => eqLabel(it, 'Exchange Meter Type') || it.id === 'Exchange_ExchangeMeterType';
      filtered = list.filter(item => {
        if (isSpecChange(item)) return true;
        if (isAccuracyTest(item)) return true;
        if (isCommercial) {
          if (isGPS(item)) return true;
          if (isHousing(item)) return true;
          if (hasZ002 && isConverter(item)) return true;
        }
        if (isResidential) {
          if (isFaultyOnGas(item)) return true;
          if (isLikeForLike(item)) return true;
          if (isExchangeMeterType(item)) return true;
        }

        return false;
      });

      this.filteredSubTypes = filtered.map(s => ({ ...s }));
    } else {
      // Normal path: show all subtypes for the selected job
      this.filteredSubTypes = list.map(s => ({ ...s }));
    }
    // 4b) Ensure it's always an array (guard)
    if (!Array.isArray(this.filteredSubTypes)) {
      this.filteredSubTypes = [];
    }

    // 5) Clear selection and state
    this.selectedSubType = null;
    this.selectedSubTypeLabel = '';
    this.state = {};
    this.errors = {};
    this.errors = { ...this.errors }; // bump reactivity
    this.meterSuggestions = [];
    this.priceMessageFlag = false;
    this.priceMessage = '';
    this.resetUIFlags();

    // 7) Optional auto-open first
    const autoOpenFirst = false;
    if (autoOpenFirst && this.filteredSubTypes.length > 0) {
      const first = this.filteredSubTypes[0];
      this.selectedSubType = { ...first };
      this.selectedSubTypeLabel = first.label;

      const qs = this.questionConfig[first.id] || [];
      const initState = {};
      qs.forEach(q => { initState[q.key] = q.defaultValue ?? ''; });
      this.state = initState;

      this.filteredSubTypes = this.filteredSubTypes.map(s => ({ ...s }));
      this.errors = { ...this.errors };
    }

    // 8) Scroll subtypes into view
    const subGroup = this.template.querySelector('[aria-label="Subtype"]')
      || this.template.querySelector('.card-group');
    subGroup?.scrollIntoView?.({ behavior: 'smooth', block: 'start' });

    // 9) Uncheck any stale radios
    this.template.querySelectorAll('input[name="subType"]').forEach(r => { r.checked = false; });
  }



  // refresh subtype code 28/11 end here


  // 15 jan change here

  // 20 jan change


  /**
   * Populate "What is the reason for site visit?" options based on assetType.
   * Only applies to the "OtherVisits_SiteVisit" subtype.
   */
  setSiteVisitReasonsForAssetType(assetType) {
    const subtypeId = this.selectedSubType?.id;
    if (subtypeId !== 'OtherVisits_SiteVisit') return; // Guard for other subtypes

    // Placeholder + client-specified reasons for the selected type
    const placeholder = [{ label: 'Select', value: '' }];
    const reasons = this.SITE_VISIT_REASONS[assetType] || [];

    // Update questionConfig immutably so LWC re-renders
    if (this.questionConfig[subtypeId]) {
      this.questionConfig[subtypeId] = this.questionConfig[subtypeId].map(q => {
        if (q.key === 'siteVisitReason') {
          return { ...q, options: placeholder.concat(reasons) };
        }
        return q;
      });
    }

    // Reset current selection + clear any prior error on the reason field
    this.state = this.state || {};
    this.state.siteVisitReason = '';
    this.errors = this.errors || {};
    this.errors.siteVisitReason = '';
    this.errors = { ...this.errors }; // nudge re-render
  }

  // 20 jan change end here


  applyMediumPressureBrand() {
    // Ensure state exists
    if (!this.state) return;

    // Only set value when Pressure Tier is Medium Pressure
    if (this.state.pressureTier === "Medium Pressure") {

      // Set mediumPressureValue in state
      if (this._pressuretierBrand) {
        this.state.mediumPressureValue = this._pressuretierBrand;

        // Clear any validation error
        if (this.errors) {
          this.errors.mediumPressureValue = "";
          this.errors = { ...this.errors };
        }

        // Force re-render
        this.state = { ...this.state };
      }
    }
  }

  // 15 jan change end here

  checkAllAssetFieldsFilled() {

    // If assetDetails is null/undefined or empty, return true
    if (!this.assetDetails || this.assetDetails.length === 0) {
      return true;
    }

    // Otherwise, check every field has a non-empty value
    return this.assetDetails.every(field => field.value && field.value.trim() !== '');

  }

  checkAllAddressFieldsFilled() {
    const list = this.addressDetails;
    if (!list?.length) return true; // keep your original default behavior

    // Normalize: coerce to string, remove zero-width spaces, trim whitespace
    const normalize = (v) => (v == null ? '' : String(v)).replace(/\u200B/g, '').trim();

    // Build a lookup map: apiName -> normalized value
    const map = Object.create(null);
    for (const f of list) {
      if (!f?.apiName) continue;
      map[f.apiName] = normalize(f.value);
    }

    // All of these must be non-empty
    const mustAllBeFilled = ['street', 'postalTown', 'postCode'];
    // At least one of these must be non-empty
    const mustHaveOneOf = ['buildingName', 'buildingNumber'];

    const isNonEmpty = (k) => !!map[k];

    const hasAllRequired = mustAllBeFilled.every(isNonEmpty);
    const hasOneBuilding = mustHaveOneOf.some(isNonEmpty);
    console.log('hasAllRequired', hasAllRequired);
    console.log('hasOneBuilding', hasOneBuilding);
    console.log('hasOneBuconditionilding', hasAllRequired && hasOneBuilding);

    return hasAllRequired && hasOneBuilding;
  }
  async handleSubTypeSelect(event) {
    this.selectSubType = true;
    const selectedSubTypeLabel = event.target.value;
    this.jobSubType = selectedSubTypeLabel;
    this.selectedSubTypeLabel = selectedSubTypeLabel;
    this.decorateSubTypes();
    console.log('this.selectedSubTypeLabel >>>>>>>', this.selectedSubTypeLabel);
    const raw = (this.mprnInput || '').toString();
    const parts = raw.split('-').map(s => (s ? s.trim() : ''));
    const mprn = parts[0] || '';       // "10140505"
    const supplier = parts[1] || '';   // "GLZ"

    // 2) Build payload object
    const payloadObj = {
      recordTypeName: 'Customer Work Request',
      NGMCP_MPRN__c: mprn,
      NGMCP_Supplier_Id__c: supplier,
      NGMCP_Job_Type__c: this.selectedJob,
      NGMCP_Job_SubType__c: this.jobSubType,
      NGMCP_Status__c: ['Closed', 'CANCELLED', 'Cancelled', 'Resolved', 'Rejected'] // NOT IN
    };
    console.log('payload' + JSON.stringify(payloadObj));
    // 3) Call Apex (expects String payload)
    const results = await validateDeuplicateRequest({
      payload: JSON.stringify(payloadObj)
    });
    if (results.length > 0) {
      console.log('result', JSON.stringify(results));
      this.isModel = true;
      this.duplicateMessage = 'Open request with Request Number -' + results[0].Name + ' and Service Request - ' + results[0].NGMCP_SR_Ticket__c + ' already exists for the same combination.';
      console.log('Open request with Request Number -' + results[0].Name + 'and Service Request - ' + results[0].NGMCP_SR_Ticket__c + 'already exists for the same combination');
      return;
    }
    /* ---------- 19 Dec: Residential U6 hard set ---------- */
    if (
      this._residentialU6Site &&
      (this.selectedSubType?.id === 'Install_Meter' ||
        this.selectedSubType?.label?.trim().toLowerCase() === 'meter')
    ) {
      this.setHardU6ForYes();
    }

    const allAddressFilled = this.checkAllAddressFieldsFilled();
    const allAssetFilled = this.checkAllAssetFieldsFilled();

    /* ---------- Third-party appointment guards ---------- */
    console.log('this.selectedJob', this.selectedJob);
    console.log('this.jobSubType', this.jobSubType);
    console.log('this.thirdParty', this.thirdParty);
    console.log('this.allAddressFilled', !allAddressFilled);
    if (
      this.selectedJob === 'Install' &&
      this.jobSubType === 'Meter' &&
      this.thirdParty &&
      !allAddressFilled
    ) {
      this.dispatchEvent(new CustomEvent('statereponse', {
        detail: {
          state: this.state,
          appointmentFlag: true,
          jobtype: this.selectedJob,
          subJobType: this.jobSubType,
          sla: '',
          successprice: false
        },
        bubbles: true,
        composed: true
      }));
      return;
    }

    const jobTypeInput = (this.selectedJob || '').trim().toLowerCase();
    const subJobTypeInput = (this.jobSubType || '').trim().toLowerCase();

    const allowedJobTypes = ['other visits', 'exchange', 'remove'];
    const allowedSubJobTypes = [
      'meter',
      'pickup',
      'specification change',
      'third party',
      'theft of gas exchange',
      'adversarial removal'
    ];

    if (
      allowedJobTypes.includes(jobTypeInput) &&
      allowedSubJobTypes.includes(subJobTypeInput) &&
      this.thirdParty &&
      !(allAddressFilled && allAssetFilled)
    ) {
      this.dispatchEvent(new CustomEvent('statereponse', {
        detail: {
          state: this.state,
          appointmentFlag: true,
          jobtype: this.selectedJob,
          subJobType: this.jobSubType,
          sla: '',
          successprice: false
        },
        bubbles: true,
        composed: true
      }));
      return;
    }

    /* ---------- Existing meter guard ---------- */
    if (this.selectedJob === 'Install' && this.jobSubType === 'Meter' && !this.thirdParty && this._status === 'Commercial') {
      this.showMeterErrorMessage = true;
      this.errorMessage =
        'You cannot raise an Install Meter job on a MPRN where National Gas Meter already exists';
      return;
    }

    this.errorMessage = '';
    this.priceButtonFlag = this.selectJob && this.selectSubType;

    const selectedSubTypeObj = this.filteredSubTypes.find(s => s.label === selectedSubTypeLabel);
    this.selectedSubType = selectedSubTypeObj || {
      label: selectedSubTypeLabel,
      id: selectedSubTypeLabel
    };

    /* ---------- Default handling ---------- */
    if (this.selectedSubType?.id === 'Remove_Pickup' && !this.state.isDifferentAddress) {
      this.state.isDifferentAddress = 'No';
    }

    /* ---------- Rebuild state from question config ---------- */
    const questions = this.questionConfig[this.selectedSubType.id];
    if (questions) {
      const newState = {};
      questions.forEach(q => {
        const dv = q.defaultValue;
        const hasDefault = dv !== undefined && dv !== null && !(typeof dv === 'string' && dv.trim() === '');
        newState[q.key] =
          q.key === 'pressureTier'
            ? this._pressureTier ?? dv ?? null
            : hasDefault ? dv : null;
      });
      this.state = newState;

      // 4 march
      // NEW: If independent Residential, force 21 / 64 / U6 and payment from Asset Details
if (this.isIndependentResidentialInstall()) {
  this.applyIndependentResidentialDefaults();
}
    // 4 march end

      // NEW: Seed default for "Is it a new connection?" (Install → Meter only)
      if (this.selectedSubType?.id === 'Install_Meter') {
        const newConn = this._residentialU6Provided ? 'Yes' : 'No';
        this.state.isNewConnection = newConn;
        this.errors = { ...(this.errors || {}), isNewConnection: '' };
      }
      // 20 jan change


      // If entering Site Visit, seed reasons based on current assetType (if any)
      if (this.selectedSubType?.id === 'OtherVisits_SiteVisit') {
        const at = this.state?.assetType;
        if (at && at !== 'Select Asset Type') {
          this.setSiteVisitReasonsForAssetType(at);
        } else {
          this.setSiteVisitReasonsForAssetType(null);
        }
      }

      // 20 jan change end here

      this.applyMediumPressureBrand();
    }

    /* ---------- 8 Jan: Payment prefill ---------- */
    const validPm = this._paymentMechanism === 'Credit' || this._paymentMechanism === 'Pre Payment';

    if (validPm && this.selectedSubType?.id === 'Exchange_LikeForLike') {
      this.state.paymentMethod = this._paymentMechanism;
    }
    if (validPm && this.selectedSubType?.id === 'OtherVisits_Reconnect') {
      this.state.requiredPaymentType = this._paymentMechanism;
    }
    if (validPm && this.selectedSubType?.id === 'Exchange_MeterType') {
      this.state.newMeterPaymentMethod =
        this._paymentMechanism === 'Credit' ? 'Pre Payment' : 'Credit';
    }

    /* ---------- 6 Jan: Residential U6 defaults ---------- */
    if (this._residentialU6Site === true && this.selectedSubType?.id === 'Install_Meter') {
      this.applyResidentialU6YesDefaults();
    }

    /* ---------- 19 Dec: Adversarial removal ---------- */
    if (this.selectedSubType?.id === 'OtherVisits_Adversarial_Removal') {
      this.state.purging = 'Yes';
      this.errors = { ...(this.errors || {}), purging: '' };
    }

    /* ---------- Meter size / housing reset ---------- */
    const resetSubtypes = [
      'Exchange_SpecificationChange',
      'Exchange_ThirdParty',
      'Install_Housing'
    ];

    if (resetSubtypes.includes(this.selectedSubType?.id)) {
      this.state = {
        ...this.state,
        MeterSize: '',
        housingRequired: '',
        housingType: '',
        HModel: ''
      };

      if (this.questionConfig[this.selectedSubType.id]) {
        this.questionConfig[this.selectedSubType.id] =
          this.questionConfig[this.selectedSubType.id].map(q =>
            q.key === 'MeterSize'
              ? { ...q, options: [{ label: 'Select Meter Size', value: '' }] }
              : q
          );
      }

      this.errors = {
        ...(this.errors || {}),
        MeterSize: '',
        housingRequired: '',
        housingType: '',
        HModel: ''
      };
    }

    /* ---------- Clear payment flow ---------- */
    this.state.changePaymentType = null;
    this.state.paymentMethod = null;
    this.errors = {
      ...(this.errors || {}),
      changePaymentType: '',
      paymentMethod: ''
    };
  }
  resetUIFlags() {
    this.gt1 = null;
    this.showGt1Upload = false;
    this.showGt1Error = false;
    this.housingRequired = null;
    this.housingType = null;
    this.baseRequired = null;
    this.changePaymentType = null;
    this.paymentMethod = null;
    this.electricInterface = null;
    this.meterBypass = null;
    this.converterRequired = null;
    this.twinStream = null;
    this.amrDevice = null;
  }


  // 28/11

  // 17 dec change for pickup validation


  handleKeyPress(event) {
    const key = event.target?.dataset?.key || event.target?.name;
    if (!['outletPressure', 'peakLoad', 'finalRead'].includes(key)) return;
    const char = event.key;
    if (
      event.ctrlKey ||
      event.metaKey ||
      ['Backspace', 'Delete', 'ArrowLeft', 'ArrowRight', 'Tab'].includes(char)
    ) {
      return;
    }
    if (!/^\d$/.test(char)) event.preventDefault();
  }

  // 17 dec change for pickup validation
  handleDynamicChange(event) {
    if (this.isLocked) {
      event.preventDefault?.();
      return;
    }

    const key = event.target.dataset.key || event.target.name;
    let value = event.detail?.value || event.target.value;
    console.log('handleDynamicChange key****', key);
    console.log('handleDynamicChange value****', value);
    // Ensure state and errors exist
    this.state = this.state || {};
    this.errors = this.errors || {};

    /* ---------------- 7 Jan: New / Reconnection lock ---------------- */
    if (key === 'isNewConnection') {
      if (value === 'No') {
        this.state.isReconnection = 'Yes';
        this.template.querySelectorAll('input[name="isReconnection"]').forEach(r => {
          r.checked = r.value === 'Yes';
          r.disabled = true;
        });
      } else {
        this.state.isReconnection = null;
        this.state.isReconnectionDebt = null;
        this.template.querySelectorAll('input[name="isReconnection"]').forEach(r => {
          r.checked = false;
          r.disabled = false;
        });
      }
    }

    /* ---------------- 6 Jan: Yes-flow field lock ---------------- */
    const yesFlowLocked = this._residentialU6Site === true && this.selectedSubType?.id === 'Install_Meter';
    if (yesFlowLocked) {
      const lockedKeys = new Set(['peakLoad', 'MeterSize', 'paymentMethod', 'outletPressure']);
      if (lockedKeys.has(key)) return;
    }
    // NEW: Prevent user changes to "isNewConnection" in Install → Meter
    if (this.selectedSubType?.id === 'Install_Meter' && key === 'isNewConnection') {
      event.preventDefault?.();
      return;
    }

    // 7 march
    // Prevent edits to reconnection fields when U6 = No (defensive)
    if (this.selectedSubType?.id === 'Install_Meter'
    && this._residentialU6Site === false
    && (key === 'isReconnection' || key === 'isReconnectionDebt')) {
  event.preventDefault?.();
  return;
    }
    // 7 march end

    /* ---------------- 19 Dec: Adversarial removal guard ---------------- */
    if (key === 'purging' && this.selectedSubType?.id === 'OtherVisits_Adversarial_Removal') {
      this.state.purging = 'Yes';
      this.template.querySelectorAll('input[name="purging"]').forEach(r => {
        r.checked = r.value === 'Yes';
        r.disabled = true;
      });
      return;
    }

    /* ---------------- File input handling ---------------- */
    console.log('key', key);
    console.log('key?.toLowerCase().includes(file)', key?.toLowerCase().includes('file'));
    console.log('event.target.files', event.target.files);
    const isFileInput = event.target.type === 'file' || key?.toLowerCase().includes('file');
    if (isFileInput) {
      this.processFiles(event.target.files, key);
      event.target.value = '';
      return;
    }
    /* ---------------- Input sanitisation ---------------- */
    if (key === 'outletPressure') value = value.replace(/\D/g, '').slice(0, 4);
    if (key === 'peakLoad') value = value.replace(/\D/g, '').slice(0, 8);
    if (key === 'crimeRefNumber') value = value.replace(/[^A-Za-z0-9]/g, '').slice(0, 20);

    if (key === 'finalRead') {
      value = value.replace(/\D/g, '').slice(0, 5);
      this.errors.finalRead =
        value.length === 0
          ? 'Final Read is required'
          : value.length < 4
            ? 'Final Read must be at least 4 digits'
            : '';
    }

    /* ---------------- Address validation ---------------- */
    const isAddrField = ['buildingName', 'buildingNumber', 'street', 'dependentLocality', 'postTown', 'postCode'].includes(key);
    if (isAddrField && this.state.isDifferentAddress === 'Yes') {
      value = String(value || '');
      const maxLen = key === 'postCode' ? 9 : 39;
      if (event.inputType === 'insertFromPaste' && value.length > maxLen) {
        value = value.slice(0, maxLen);
      }
      this.errors[key] = value.trim() ? '' : 'This field is required.';
    }

    /* ---------------- State update ---------------- */
    this.state[key] = value;

    // 29 jan change

    // Re-check GT1 SPEV match when Peak Load changes (Spec Change only) 

    // 4 feb change
    if (key === 'peakLoad' && GT1_VALIDATION_SUBTYPES.has(this.selectedSubType?.id)) {
      const peak = parseFloat(value);
      if (Number.isFinite(peak) && this.state?._gt1ParsedSpev !== undefined) {
        this.errors.gt1File =
          (Number(this.state._gt1ParsedSpev) === peak) ? '' : GT1_UNIFIED_WARNING;
        this.errors = { ...this.errors };
      }
    }

    // 4 feb change end here
    // 29 jan change end here



    // 20 jan change


    // --- Site Visit: when Asset Type changes, refresh reasons dropdown ---
    if (this.selectedSubType?.id === 'OtherVisits_SiteVisit' && key === 'assetType') {
      if (value && value !== 'Select Asset Type') {
        this.setSiteVisitReasonsForAssetType(value);
      } else {
        // Back to placeholder: clear reasons to placeholder-only
        this.setSiteVisitReasonsForAssetType(null);
      }
    }
    // 20 jan change end here

    /* ---------------- Connection hygiene ---------------- */
    if (key === 'isNewConnection') {
      this.state.isReconnection = null;
      this.state.isReconnectionDebt = null;
      this.clearRadioGroupIfNoState('isReconnection');
      this.clearRadioGroupIfNoState('isReconnectionDebt');
    }

    if (key === 'isReconnection' && value !== 'Yes') {
      this.state.isReconnectionDebt = null;
      this.clearRadioGroupIfNoState('isReconnectionDebt');
    }

    /* ---------------- Live error clearing ---------------- */
    const isSelection = event.type === 'change' && (event.target.type === 'radio' || event.target.tagName === 'SELECT');
    if (isSelection || (value && String(value).trim())) {
      this.errors[key] = '';
      this.errors = { ...this.errors };
    }

    /* ---------------- Debounced recalculations ---------------- */
    if (key === 'outletPressure' || key === 'peakLoad') {
      clearTimeout(this.debounceTimeout);
      this.state.MeterSize = '';
      this.debounceTimeout = setTimeout(() => this.filterMeterModels(), 500);
    }

    if (['MeterSize', 'housingType', 'housingRequired'].includes(key)) {
      clearTimeout(this.debounceTimeout);
      this.debounceTimeout = setTimeout(() => this.updateHousingModel(), 500);
    }

    /* ---------------- Simple switch effects ---------------- */
    switch (key) {
      case 'outletPressure':
        this.outletPressure = value;
        break;
      case 'peakLoad':
        this.peakLoad = value;
        break;
      case 'housingRequired':
        this.housingRequired = value;
        if (value === 'No') {
          this.state.housingType = null;
          this.state.baseRequired = null;

          // 30 jan change for housing issue

          // Ensure model is cleared as soon as user selects "No"
          this.state.HModel = '';                            // <-- must be capitalized exactly as "HModel"
          if (!this.errors) this.errors = {};
          this.errors.housingType = '';
          this.errors.baseRequired = '';
          this.errors.HModel = '';
          this.errors = { ...this.errors };                  // rerender

          // Guard against the pending debounce that may still run updateHousingModel
          clearTimeout(this.debounceTimeout);
          // re-render

          // 30 jan change end here for housing issue
        }
        break;
      case 'housingType':
        this.housingType = value;
        if (value !== 'Free Standing') this.state.baseRequired = null;
        break;
      case 'pickupRequired':
        this.pickupRequired = value;
        break;
      case 'isDifferentAddress':
        this.isDifferentAddress = value;
        break;
    }

    this.clearErrorsForInvisibleQuestions();
    this.applyMediumPressureBrand();
  }



  // 18 dec change


  // Inside your class:

  clearRadioGroupIfNoState(key) {
    const v = this.state?.[key];
    const hasVal = v !== null && v !== undefined && String(v).trim() !== "";
    if (hasVal) return;
    this.template.querySelectorAll(`input[name="${key}"]`).forEach(r => { r.checked = false; });
  }





  // 18 dec change end here

  // 19 dec change here


  // Put this inside the class
  setHardU6ForYes() {
    // Only for Install â†’ Meter
    const id = 'Install_Meter';
    const isInstallMeter =
      (this.selectedSubType?.id === id) ||
      (this.selectedSubType?.label?.trim().toLowerCase() === 'meter');

    if (!isInstallMeter) return;

    // Ensure questionConfig has a U6 option so the UI can show it selected
    const arr = this.questionConfig[id] ?? [];
    const idx = arr.findIndex(q => q.key === 'MeterSize');
    if (idx > -1) {
      const hasU6 =
        Array.isArray(arr[idx].options) && arr[idx].options.some(o => (o.value ?? o) === 'U6');
      const nextOptions = hasU6 ? arr[idx].options : [{ label: 'U6', value: 'U6' }];
      arr[idx] = { ...arr[idx], options: nextOptions };
      this.questionConfig[id] = [...arr];               // immutable bump
    }

    // Hard set state so normalization marks U6 selected in the template
    if (!this.state) this.state = {};
    this.state.MeterSize = 'U6';
    this.state = { ...this.state };                     // immutable bump
  }

  // 19 dec change end here


  // updateHousingModel() {
  //   if (this.housingRequired === "Yes") {
  //     console.log('this.state.housingType:', this.state.housingType);
  //     console.log('this.state.MeterSize:', this.state.MeterSize);
  //     // Build key dynamically
  //     const key = this.state.housingType ? this.state.MeterSize + this.state.housingType.replace(/\s+/g, "_") : this.state.MeterSize;
  //     console.log('key' + key);
  //     console.log('this.housingModelMap.get(key)' + this.housingModelMap.get(key));
  //     // Update state with value from Map
  //     this.state = {
  //       ...this.state,
  //       HModel: this.housingModelMap.get(key) || ""
  //     };
  //   }
  // }

  // 30 jan change for housing issue

  updateHousingModel() {
    const isYes = this.state?.housingRequired === 'Yes'; // use dynamic state as source of truth
    if (!isYes) {
      // If user flipped to No, keep it clean
      this.state = { ...this.state, HModel: '' };
      return;
    }

    const size = this.state.MeterSize;
    const type = this.state.housingType;
    const key = type ? (size + type.replace(/\s+/g, '_')) : size;

    const resolved = this.housingModelMap?.get(key) || '';
    this.state = { ...this.state, HModel: resolved };
  }
  // 30 jan change end here housing issue

  // 6 jan change


  applyResidentialU6YesDefaults() {
    const id = 'Install_Meter';
    // Guard: only for Install â†’ Meter
    if (this.selectedSubType?.id !== id) return;

    if (!this.state) this.state = {};

    // âœ… Hard values
    this.state.peakLoad = '64';
    this.state.MeterSize = 'U6';
    this.state.paymentMethod = 'Credit';

    // âœ… Outlet pressure: keep current; if blank, default to 21
    const currentOutlet = String(this.state.outletPressure ?? this.outletPressure ?? '21');
    this.state.outletPressure = currentOutlet;

    // âœ… Ensure MeterSize select has U6 so UI shows it selected
    const arr = this.questionConfig[id] ?? [];
    const idx = arr.findIndex(q => q.key === 'MeterSize');
    if (idx > -1) {
      const hasU6 = Array.isArray(arr[idx].options) && arr[idx].options
        .some(o => (o.value ?? o) === 'U6');
      const nextOptions = hasU6 ? arr[idx].options : [{ label: 'U6', value: 'U6' }];
      arr[idx] = { ...arr[idx], options: nextOptions };
      this.questionConfig[id] = [...arr]; // immutable bump
    }

    // Clear any prior errors on these fields
    if (!this.errors) this.errors = {};
    ['peakLoad', 'MeterSize', 'paymentMethod', 'outletPressure'].forEach(k => this.errors[k] = '');
    this.errors = { ...this.errors };

    // bump reactivity
    this.state = { ...this.state };
  }

  // 4 march
    // NEW: Apply Independent-Residential defaults for Install → Meter
applyIndependentResidentialDefaults() {
  const id = 'Install_Meter';
  if (this.selectedSubType?.id !== id) return;

  this.state = this.state || {};
  this.state.outletPressure = '21';
  this.state.peakLoad      = '64';
  this.state.MeterSize     = 'U6';

  const pm = this.normalizePaymentMethod(this._paymentMechanism);
  this.state.paymentMethod = pm;

  // Ensure U6 is present in the MeterSize select
  const arr = this.questionConfig[id] ?? [];
  const idx = arr.findIndex(q => q.key === 'MeterSize');
  if (idx > -1) {
    const hasU6 = Array.isArray(arr[idx].options)
               && arr[idx].options.some(o => (o.value ?? o) === 'U6');
    const nextOptions = hasU6 ? arr[idx].options : [{ label: 'U6', value: 'U6' }];
    arr[idx] = { ...arr[idx], options: nextOptions };
    this.questionConfig[id] = [...arr];
  }

  if (!this.errors) this.errors = {};
  ['outletPressure','peakLoad','MeterSize','paymentMethod'].forEach(k => this.errors[k] = '');
  this.errors = { ...this.errors };
  this.state = { ...this.state }; // bump UI
}
  // 4 march end


  // 6 jan change end here

  filterMeterModels() {
    const kwh = parseFloat(this.state.peakLoad);
    const pressure = parseFloat(this.state.outletPressure);
    console.log("kwh:", kwh, "pressure:", pressure);

    let meterSizeOptions = [];

    if (!isNaN(kwh) && !isNaN(pressure)) {
      const matchedModels = this.meterModels.filter(
        (model) =>
          kwh >= model.NGMCP_Minimum_Kwh__c &&
          kwh <= model.NGMCP_Maximum_Kwh__c &&
          pressure >= model.NGMCP_Minimum_Outlet_Pressure__c &&
          pressure <= model.NGMCP_Maximum_Outlet_Pressure__c
      );

      meterSizeOptions = matchedModels.map((model) => ({
        label: model.NGMCP_Meter_Model__c,
        value: model.NGMCP_Meter_Model__c,
      }));

      const subtypeId = this.selectedSubType?.id; //  Use composite key
      if (subtypeId && this.questionConfig[subtypeId]) {
        this.questionConfig[subtypeId] = this.questionConfig[subtypeId].map((q) => {
          if (q.key === "MeterSize") {
            return { ...q, options: meterSizeOptions };
          }
          return q;
        });
      }

      // 19 dec change comment this.state to payment method null and add new 

      this.state = {
        ...this.state,
        MeterSize: meterSizeOptions.length ? meterSizeOptions[0].value : "",
        housingRequired: "",
        HModel: "",
        housingType: "",

        gt1: null,                  // Gt1 switch issue 29/11 

        changePaymentType: null,  // change payment change 29/11
        paymentMethod: null       // change payment change 29/11
      };

      const yesFlow = (subtypeId === 'Install_Meter') && this._residentialU6Site;  // 19 dec change comment

      // 19 dec change
      //  Only auto-select MeterSize when YES-flow (Install â†’ Meter + residentialU6Site = true)


      this.state = {
        ...this.state,
        //  MeterSize: meterSizeOptions.length ? meterSizeOptions[0].value : "",  // 6 jan comment change

        // 6 jan change

        MeterSize: yesFlow ? 'U6' : (meterSizeOptions.length ? meterSizeOptions[0].value : ''),
        housingRequired: '',
        HModel: '',
        housingType: '',
        gt1: null,
        changePaymentType: null,
        paymentMethod: yesFlow ? 'Credit' : null

        // 6 jan change end here


      };

      // 19 dec change end here



      // Gt1 switch issue 29/11 start here

      const gt1Radios = this.template.querySelectorAll('input[name="gt1"]');
      gt1Radios.forEach(r => { r.checked = false; });
      if (!this.uploadedFilesByKey) this.uploadedFilesByKey = {};
      this.uploadedFilesByKey.gt1File = [];

      // Gt1 switch issue 29/11 end here

      // change payment change 29/11 start here


      if (!this.errors) this.errors = {};

      this.errors.gt1 = '';                  // Gt1 switch issue 29/11 
      this.errors.gt1File = '';                // Gt1 switch issue 29/11 
      this.errors.changePaymentType = '';
      this.errors.paymentMethod = '';
      this.errors = { ...this.errors }; // LWC reactivity bump

      // change payment change 29/11 end here

      console.log("Updated MeterSize options:", meterSizeOptions);
      console.log("Updated State:", JSON.stringify(this.state));
    } else {
      // Reset MeterSize if inputs are invalid
      meterSizeOptions = [{ label: "Select Meter Size", value: "" }];

      const subtypeId = this.selectedSubType?.id;
      if (subtypeId && this.questionConfig[subtypeId]) {
        this.questionConfig[subtypeId] = this.questionConfig[subtypeId].map((q) => {
          if (q.key === "MeterSize") {
            return { ...q, options: meterSizeOptions };
          }
          return q;
        });
      }

      this.state = {
        ...this.state,
        MeterSize: "",
        housingRequired: "",
        HModel: "",
        housingType: "",

        gt1: null,                  // Gt1 switch issue 29/11

        changePaymentType: null,  // change payment change 29/11
        paymentMethod: null       // change payment change 29/11
      };

      // Gt1 switch issue 29/11 start here


      const gt1Radios = this.template.querySelectorAll('input[name="gt1"]');
      gt1Radios.forEach(r => { r.checked = false; });
      if (!this.uploadedFilesByKey) this.uploadedFilesByKey = {};
      this.uploadedFilesByKey.gt1File = [];

      // Gt1 switch issue 29/11 end here

      // change payment change 29/11 start here


      if (!this.errors) this.errors = {};

      this.errors.gt1 = '';             // Gt1 switch issue 29/11 
      this.errors.gt1File = '';             // Gt1 switch issue 29/11 
      this.errors.changePaymentType = '';
      this.errors.paymentMethod = '';
      this.errors = { ...this.errors }; // LWC reactivity bump

      // change payment change 29/11 end here

      console.log("Invalid inputs, resetting MeterSize:", meterSizeOptions);
      console.log("Updated State:", JSON.stringify(this.state));
    }

    // Optional: clear errors for hidden fields after meter size changes
    this.clearErrorsForInvisibleQuestions();   // gt1 switch issue 29/11
  }
  handleMeterSizeSelect(event) {

    if (this.isLocked) return;   // 10 dec change
    this.selectedMeterSize = event.target.value;

    // Reset state
    this.state.changePaymentType = null;
    this.state.paymentMethod = null;

    // Clear radio selections in DOM
    const changePaymentRadios = this.template.querySelectorAll('input[name="changePaymentType"]');
    changePaymentRadios.forEach(radio => radio.checked = false);

    const paymentMethodRadios = this.template.querySelectorAll('input[name="paymentMethod"]');
    paymentMethodRadios.forEach(radio => radio.checked = false);
  }
  async handleGetPrice() {

    // mandatory required 28/11 


    // 19 jan change

    this.hasTriedGetPrice = true;

    // 19 jan change end here
    // 9 march
    // --- 7 Mar change: Block Get Price ONLY for Accuracy Test + Residential + SmartMeter = Yes ---
if (
    this.selectedSubType?.id === 'Exchange_AccuracyTest'
    && this._status === 'Residential'
    && this.state?.isSmartMeter === 'Yes'
) {
    // optional message
    this.nonStandardMessage = 'For Smart Meters, Accuracy Test pricing is not available. Please submit the job.';
    
    console.log('[AccuracyTest] Pricing blocked because Smart Meter = Yes + Residential');
    return; //  STOP Get Price from proceeding
}
  // 9 march
    // 7 march
    // --- NEW: Ensure reconnection radios are copied from DOM to state before we validate/re-render ---
if (this.selectedSubType?.id === 'Install_Meter') {
  // "Is this a reconnection request?"
  const reconChecked = this.template.querySelector('input[name="isReconnection"]:checked');
  if (reconChecked) {
    this.state.isReconnection = reconChecked.value; // "Yes" or "No"
  }
  // "Is it a reconnection after debt?"
  const debtChecked = this.template.querySelector('input[name="isReconnectionDebt"]:checked');
  if (debtChecked) {
    this.state.isReconnectionDebt = debtChecked.value; // "Yes" or "No"
  }
}
  // 7 march end

    const { isValid, missingKeys } = this.validateVisibleQuestions();
    if (!isValid) {
      const firstKey = missingKeys[0];
      const firstEl = this.template.querySelector(`[data-key="${firstKey}"]`)
        || this.template.querySelector(`#${firstKey}`);
      if (firstEl && firstEl.focus) {
        firstEl.focus();
        firstEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }
      this.priceMessageFlag = true;
      this.priceMessage = 'Please complete all required fields.';
      return; // block Apex call until valid
    }

    // mandatory required field 28/11 end here

    try {
      console.log('Price calculation logic goes here!');
      console.log('Current state:', JSON.stringify(this.state));
      console.log('status' + this._status);
      console.log('paymentMechanism' + this._paymentMechanism);
      console.log('meterSize' + this.meterSize);
      console.log('Current state:', JSON.stringify(this.state));
      console.log('Pressure Tier:', JSON.stringify(this.pressuretier));

      // 30 jan change for housing issue

      // --- Guard: if Housing is "No", make sure state cannot leak a model ---
      if ((this.state?.housingRequired || '').trim() !== 'Yes') {
        this.state.HModel = '';                 // <-- only state change; body mapping stays untouched
      }

      // 30 jan change end here for housing issue

      const dataMap = new Map(Object.entries(this.state));


      // Decide what to send into NGMCP_Payment_Method__c
      const paymentMethodForPayload =
        (this.selectedSubType?.id === 'Exchange_MeterType')
          ? (dataMap.get('newMeterPaymentMethod') || '')
          : (dataMap.get('paymentMethod') || '');
      // this.updateHousingModel();
      // const hModel = (dataMap.get('HModel') || '').trim() || (dataMap.get('damageLimited') ? this.housingModelMap.get(this.state.housingType ? this.meterSize + this.state.housingType.replace(/\s+/g, "_") : this.state.MeterSize) : "");
      // const hModel =
      //   (dataMap.get('HModel') || '').trim() ||
      //   (dataMap.get('housingRequired')
      //     ? this.housingModelMap.get(
      //       this.state.housingType
      //         ? this.meterSize + this.state.housingType.replace(/\s+/g, "_")
      //         : this.state.MeterSize ?? this.meterSize
      //     )
      //     : ""
      //   );
      
          const isHousingYes = (dataMap.get('housingRequired') === 'Yes');
          const hModel =
          (dataMap.get('HModel') ?? '').trim()
          || (isHousingYes
        ? this.housingModelMap.get(
            this.state.housingType
              ? this.meterSize + this.state.housingType.replace(/\s+/g, "_")
              : this.state.MeterSize ?? this.meterSize
           )
        : ""
      );

      // Update state with value from Map
      //const hModel = (dataMap.get('HModel') || '').trim() || ((dataMap.get('housingRequired') || '').trim() ? this.housingModelMap.get((dataMap.get('housingRequired') || '').trim()) : null);
      console.log('Housing model', this.housingModelMap);
      console.log('housingrequired', hModel);// Prepare request body
      console.log(' this.state.hasCrimeRef',  this.state.hasCrimeRef);
      const requestBody = {
        NGMCP_Job_Type__c: this.selectedJob || '',
        NGMCP_Job_Sub_category__c: this.selectedSubType?.label || '',
        //NGMCP_Commercial_Residential__c: this.status|| '',
        NGMCP_Payment_Mechanism__c: this.paymentMechanism || '',
        NGMCP_Meter_Model__c: this.meterSize || '',
        NGMCP_Pressure_Tier__c: dataMap.get('pressureTier') || this.pressuretier || '',
        NGMCP_Meter_Size__c: dataMap.get('MeterSize') || '',
        NGMCP_Housing_Required__c: dataMap.get('housingRequired') || '',
        NGMCP_Housing_Type__c: hModel || '',
        NGMCP_Payment_Method__c: dataMap.get('paymentMethod') || '',
        NGMCP_Payment_Method__c: paymentMethodForPayload,
        //NGMCP_Debt_Management_Visit__c: dataMap.get('debtManagementVisit') || '',//NGMCP_Purging__c: dataMap.get('purging') || '',
        NGMCP_Purging__c: dataMap.get('purging') || '',
        NGMCP_Service_Location__c: dataMap.get('serviceLocation') || '',
        NGMCP_Twin_Stream__c: dataMap.get('twinStream') || '',
        NGMCP_Electric_Interface__c: dataMap.get('electricInterface') || '',
        NGMCP_Meter_Bypass__c: dataMap.get('meterBypass') || '',
        NGMCP_Converter_Required__c: dataMap.get('converterRequired') || '',
        NGMCP_Damage_Limited__c: dataMap.get('damageLimited') || '',
        NGMCP_Base_Required__c: dataMap.get('baseRequired') || '',
        NGMCP_With_in_TwoMeters__c: dataMap.get('withinTwoMeters') || '',
        NGMCP_Pickup_Equipment__c: dataMap.get('pickupEquipment') || '',
        NGMCP_Is_New_Connection__c: this.state.isNewConnection||'',
        NGMCP_Is_Reconnection__c:  this.state.isReconnection||'',
        NGMCP_Is_Reconnection_Debt__c: this.state.isReconnectionDebt||'',
        NGMCP_Crime_Reference_Number__c : this.state.hasCrimeRef||''
      };
      // 7 march
      // --- Strip "new/reconnection" keys for Install → Meter when U6 = No (dependent No) ---
if (this.selectedSubType?.id === 'Install_Meter' && this._residentialU6Provided === true && this._residentialU6Site === false) {
  delete requestBody.NGMCP_Is_New_Connection__c;
  delete requestBody.NGMCP_Is_Reconnection__c;
  delete requestBody.NGMCP_Is_Reconnection_Debt__c;
}
  // 7 march end
  // 12 march housing change
  // 7 Mar — Damaged (Commercial): if Housing required = No, remove Housing Type from price payload
if (this.selectedSubType?.id === 'OtherVisits_Damaged' && this.state?.housingRequired === 'No') {
  delete requestBody.NGMCP_Housing_Type__c;
}
  // 12 march housing change end
      console.log('Request Body:', JSON.stringify(requestBody));



      // Call the Apex method
      const response = await getPrice({ payload: JSON.stringify(requestBody) });
      const result = Array.isArray(response) && response.length > 0 ? response[0] : null;
      if (!result) {
        // Treat as non-standard if no data returned
        throw new Error('Empty price result');
      }
      console.log('Price Result:', JSON.stringify(result));
      // Safe date parser (returns Date or null)
      const toDate = (s) => {
        if (!s || typeof s !== 'string') return null;
        const d = new Date(s);
        return isNaN(d.getTime()) ? null : d;
      };

      const today = new Date();
      const validFrom = toDate(result.NGMCP_Valid_From__c);
      const validTo = toDate(result.NGMCP_Valid_To__c);

      console.log('validFrom', validFrom);
      console.log('validTo', validTo);

      // Check date range first
      const isValidDateRange = (!validFrom || today >= validFrom) && (!validTo || today <= validTo);
      console.log('isValidDateRange', isValidDateRange);
      //console.log('result', result.length);
      // Now apply your existing price logic WITH date validation
      if (isValidDateRange && result && result.NGMCP_Job_Price__c > 0) {
        this.priceMessageFlag = true;
        const price = Number(result.NGMCP_Job_Price__c).toFixed(2);
        const mainJob = Number(result.NGMCP_Main_Price__c).toFixed(2);
        const additionalService = Number(result.NGMCP_Additional_Price__c).toFixed(2);
        this.priceMessage = `Total Price is: £${price}*`;
        this.mainJobMessage = `Price for Work Request is £${mainJob} `;
        this.additionalMessage = `Price for Additional Services is £${additionalService} `;
        this.vatMessage = '*Excludes VAT';

        // Lock when paid price is returned
        this.isLocked = true;
      } else if (isValidDateRange && result.NGMCP_Job_Price__c == 0) {
        this.priceMessageFlag = true;
        this.priceMessage = 'Good News! This is a free of charge job.';
        // Lock when price is free (FOC)
        this.isLocked = true;
      } else {
        // Outside validity period → NOT valid
        this.priceMessageFlag = true;
        this.priceMessage = 'This pricing record is not valid today.';
        this.isLocked = false;
      }
      const detail = {
        state: this.state,           // Pass current state object
        appointmentFlag: true,
        jobtype: this.selectedJob,
        subJobType: this.jobSubType,
        sla: result.NGMCP_SLA_Days__c,
        successprice: true       // Pass flag as true
      };

      this.dispatchEvent(new CustomEvent('statereponse', {
        detail: detail,
        bubbles: true,      // Optional: allow event to bubble up
        composed: true      // Optional: allow event to cross shadow DOM
      }));

      console.log('Event dispatched with:', JSON.stringify(detail));


    } catch (error) {
      console.error('Error fetching price:', error);
      //const dataMap = new Map(Object.entries(this.state));
      this.priceMessageFlag = true;
      this.priceMessage = 'This is a non-standard job, please submit the job to get a quotation.'

      this.isLocked = true;   // 10 dec change
      const detail = {
        state: this.state,           // Pass current state object
        appointmentFlag: false,
        jobtype: this.selectedJob,
        subJobType: this.jobSubType,
        sla: '',
        successprice: false         // Pass flag as true
      };

      this.dispatchEvent(new CustomEvent('statereponse', {
        detail: detail,
        bubbles: true,      // Optional: allow event to bubble up
        composed: true      // Optional: allow event to cross shadow DOM
      }));
    }
  }

  renderedCallback() {
    this.dynamicQuestions.forEach(q => {
      const inputEl = this.template.querySelector(`input[data-key="${q.key}"]`);



      if (inputEl) {
        // Apply readonly style logic
        if (q.disabled || q.readOnly) {
          inputEl.classList.add('readonly-style');
        } else {
          inputEl.classList.remove('readonly-style');
        }

        // 26 jan change comment this part

        //   if (q.defaultValue && !this.state[q.key] && !inputEl.value) {
        //     inputEl.value = q.defaultValue;
        //     this.state[q.key] = q.defaultValue;
        //   }


        //   inputEl.addEventListener('input', (e) => {
        //     this.state[q.key] = e.target.value;
        //   });
        // }
        // 18 dec change

        // 26 jan change comment this part

        // 26 jan change new code


        // Only seed the state (once) for outletPressure; do not write directly to input

        // Seed only if the key is truly uninitialized (undefined/null), not when it's an empty string
        if (
          q.key === 'outletPressure' &&
          (this.state.outletPressure === undefined || this.state.outletPressure === null)
        ) {
          this.state.outletPressure = (q.defaultValue ?? '21');
        }


        // Avoid attaching duplicate input listeners every render.
        // (Optional) Attach once: mark via a data-flag.
        if (!inputEl.dataset.bound) {
          inputEl.addEventListener('input', (e) => {
            this.state[q.key] = e.target.value;
          });
          inputEl.dataset.bound = 'true';
        }

        // 26 jan change end here


      }

      if (q.isRadio && q.visible) {
        this.clearRadioGroupIfNoState(q.key);
      }


      // 18 dec change end here
    });
  }

  get requestTypesWithClass() {
    return this.uiConfig.requestTypes.map(r => ({
      ...r,
      cssClass: `card-radio ${r.label === this.selectedRequestType ? 'selected' : ''}`
    }));
  }

  get jobTypesWithClass() {
    if (!this.selectedRequest) return [];
    return this.selectedRequest.jobTypes.map(j => ({
      ...j,
      cssClass: `card-radio ${j.label === this.selectedJobType ? 'selected' : ''}`
    }));
  }

  get subTypesWithClass() {
    return (this.filteredSubTypes || []).map(s => ({
      ...s,
      cssClass: `card-radio ${s.label === this.selectedSubTypeLabel ? 'selected' : ''}`
    }));
  }



  updateRequestTypesClass() {
    this.uiConfig.requestTypes = this.uiConfig.requestTypes.map(req => {
      return {
        ...req,
        cssClass:
          req.label === this.selectedRequestType
            ? "card-radio selected"
            : "card-radio"
      };
    });
  }

  handleDragOver(event) {

    if (this.isLocked) return;    // 10 dec change
    event.preventDefault();
    event.currentTarget.classList.add("drag-over");
  }

  handleDragLeave(event) {

    if (this.isLocked) return;   // 10 dec change
    event.preventDefault();
    event.currentTarget.classList.remove("drag-over");
  }

  handleFileDrop(event) {

    if (this.isLocked) return;   // 10 dec change
    event.preventDefault();
    event.currentTarget.classList.remove("drag-over");
    const files = event.dataTransfer.files;
    this.processFiles(files);
  }

  // handleFileChange(event) {
  //   const files = event.target.files;
  //   this.processFiles(files);
  //   event.target.value = "";
  // }
  handleBrowseClick() {

    if (this.isLocked) return;  // 10 dec change
    this.template.querySelector(".file-input").click();
  }

  // 9 jan change 


  processFiles(fileList, bucketKey) {
    // Guard conditions
    if (this.isLocked || !bucketKey || !fileList || !fileList.length) return;

    console.log('fileList', fileList);
    console.log('bucketKey', bucketKey);

    this.fileError = '';

    // Initialize storage objects if missing
    this.uploadedFilesByKey = this.uploadedFilesByKey || {};
    this.uploadedFilePayloadByKey = this.uploadedFilePayloadByKey || {};

    // Snapshot FileList
    const files = Array.from(fileList);

    // Get existing bucket data
    const uiBucket = this.uploadedFilesByKey[bucketKey] || [];
    const payloadBucket = this.uploadedFilePayloadByKey[bucketKey] || [];

    const duplicateFiles = [];
    const readPromises = [];

    files.forEach(file => {
      // Prevent duplicates in the same bucket
      if (uiBucket.some(f => f.name === file.name)) {
        duplicateFiles.push(file.name);
        return;
      }

      // File size validation
      if (file.size > MAX_FILE_SIZE) {
        const maxMB = Math.round(MAX_FILE_SIZE / 1024 / 1024);
        this.showTemporaryError(
          `File "${file.name}" exceeds ${maxMB} MB limit.`
        );
        return;
      }

      // Read file asynchronously
      readPromises.push(
        new Promise(resolve => {
          const reader = new FileReader();

          reader.onload = () => {
            const base64 = reader.result.split(',')[1];
            const isImage = file.type.startsWith('image/');

            resolve({
              ui: {
                name: file.name,
                size: file.size,
                sizeDisplay: this.formatFileSize(file.size),
                isImage,
                previewUrl: isImage ? reader.result : null
              },
              payload: {
                name: file.name,
                type: file.type,
                size: file.size,
                dType: bucketKey === 'gt1File' ? 'GT1' :  bucketKey ==='purgingCertificateFile'?'PUR':'PHT',
                base64
              }
            });
          };

          reader.readAsDataURL(file);
        })
      );
    });

    // Duplicate file warning
    if (duplicateFiles.length) {
      this.showTemporaryError(
        duplicateFiles.length === 1
          ? `File "${duplicateFiles[0]}" is already uploaded.`
          : `Files "${duplicateFiles.join('", "')}" are already uploaded.`
      );
    }

    // Wait for all files to finish reading
    Promise.all(readPromises).then(results => {
      if (!results.length) return;

      this.uploadedFilesByKey = {
        ...this.uploadedFilesByKey,
        [bucketKey]: [...uiBucket, ...results.map(r => r.ui)]
      };

      this.uploadedFilePayloadByKey = {
        ...this.uploadedFilePayloadByKey,
        [bucketKey]: [...payloadBucket, ...results.map(r => r.payload)]
      };

      // 26 jan change


      if (!this.errors) this.errors = {};
      this.errors[bucketKey] = '';
      this.errors = { ...this.errors }; // reactivity

      // 26 jan change end here

      // 29 jan change

      // --- Spec Change: validate GT1 content on upload (supports legacy .doc) ---
      if (bucketKey === 'gt1File' && GT1_VALIDATION_SUBTYPES.has(this.selectedSubType?.id)) {

        const payloads = this.uploadedFilePayloadByKey?.gt1File || [];
        const filesMeta = this.uploadedFilesByKey?.gt1File || []; // to read file names/extensions

        const today = new Date(); today.setHours(0, 0, 0, 0);
        const peak = parseFloat(this.state?.peakLoad);
        const hasPeak = Number.isFinite(peak);

        let anyValid = false;
        let lastError = '';

        // 🔹 new: UI inline message controls (computed from fail reasons)
        let uiMsg = '';
        let showUiMsg = false;

        for (let i = 0; i < payloads.length; i++) {
          const p = payloads[i];
          const name = (filesMeta[i]?.name || filesMeta[i]?.fileName || p?.name || p?.fileName || '').toLowerCase();
          const looksLegacyDoc = name.endsWith('.doc');

          try {
            // Base64 (strip possible data: prefix)
            const b64full = p?.payload?.base64 ?? p?.base64 ?? '';
            const b64 = b64full.includes(',') ? b64full.split(',')[1] : b64full;

            // 1) Try plain-text parse first
            const text = this.toPrintableTextFromBase64(b64);
            let spev = null;
            let validDate = null;

            const quick = this.parseGt1DocFields(text);
            spev = quick.spevKwh;
            validDate = quick.gtValidDate;

            // 2) If not found AND it's a legacy .doc, tolerant binary scan
            if ((!Number.isFinite(spev) || !validDate) && looksLegacyDoc) {
              let bin = '';
              try { bin = atob(b64); } catch (e2) { bin = ''; }
              if (bin) {
                if (!Number.isFinite(spev) && typeof this.scanSpevFromBinary === 'function') {
                  spev = this.scanSpevFromBinary(bin);
                }
                if (!validDate && typeof this.scanGtValidDateFromBinary === 'function') {
                  validDate = this.scanGtValidDateFromBinary(bin);
                }
              }
            }

            // Build errors + track specific fail reasons for UI
            const errs = [];
            let isExpired = false;
            let isKwhMismatch = false;

            // A) Date today/future
            if (!validDate) {
              errs.push('GT1 valid date not found in the document.');
            } else {
              const d = new Date(validDate); d.setHours(0, 0, 0, 0);
              if (d < today) {
                isExpired = true;
                errs.push('GT1 valid date must be today or a future date.');
              }
            }

            // B) SPEV must match Peak Load
            if (!Number.isFinite(spev)) {
              errs.push('Energy Required SPEV (kWh) not found in the GT1 document.');
            } else if (hasPeak && spev !== peak) {
              isKwhMismatch = true;
              errs.push(`Energy Required SPEV (${spev}) must match Peak Hourly Load (${peak}).`);
            } else if (!hasPeak) {
              errs.push('Enter Peak Hourly Load (kWh) before uploading the GT1 document.');
            }

            // 🔹 compose the exact inline message your client wants
            // Unified inline message for any failure (mismatch and/or past date, or missing data)
            // after you computed: spev, validDate, isExpired, peak (UI), hasPeak, isKwhMismatch
            const hasAnyFailure =
              isExpired || isKwhMismatch || !validDate || !Number.isFinite(spev) || !hasPeak;

            // inline message below the control (your template shows it)
            if (hasAnyFailure) {
              uiMsg = GT1_UNIFIED_WARNING;
              showUiMsg = true;
            } else {
              uiMsg = '';
              showUiMsg = false;
            }

            // field-level error (non-blocking for the 3 subtypes)
            this.errors.gt1File = hasAnyFailure ? GT1_UNIFIED_WARNING : '';
            this.errors = { ...this.errors };   // <-- re-render
            this.gt1InlineMsg = uiMsg;
            this.gt1InlineVisible = hasAnyFailure && showUiMsg;

            if (errs.length === 0) {
              anyValid = true;
              const iso = (validDate instanceof Date) ? validDate.toISOString() : validDate;
              this.state = { ...this.state, _gt1ParsedSpev: spev, _gt1ParsedDate: iso };
              // Successful parse → clear inline message
              uiMsg = '';
              showUiMsg = false;
              break; // one valid file is enough
            } else {
              lastError = errs.join(' ');
            }

          } catch (e) {
            lastError = 'Unable to read the GT1 document. Please upload PDF or DOCX if possible.';
          }
        }

        // Set final error status for the file bucket (field-level error)
        this.errors.gt1File = hasAnyFailure ? GT1_UNIFIED_WARNING : '';  // 4 feb change
        this.errors = { ...this.errors };

        // 🔹 push the inline message to the template
        this.gt1InlineMsg = uiMsg;
        this.gt1InlineVisible = !anyValid && showUiMsg;

        // If invalid, remove the uploaded file(s) so it doesn’t look accepted
        // if (!anyValid) {
        //   this.uploadedFilesByKey = { ...this.uploadedFilesByKey, gt1File: [] };
        //   this.uploadedFilePayloadByKey = { ...this.uploadedFilePayloadByKey, gt1File: [] };
        // }
      }
      // 29 jan change end here

      // Debug logs after async update
      console.log('UI files:', JSON.stringify(this.uploadedFilesByKey));
      console.log('Payload files:', JSON.stringify(this.uploadedFilePayloadByKey));

    });
    // Wait for all files to be read
    Promise.all(readPromises).then(results => {
      if (!results.length) return;

      // Merge all payloads into single array
      this.allUploadedPayloads = [
        ...this.allUploadedPayloads,
        ...results.map(r => r.payload)
      ];

      // Update state AFTER async work completes
      this.state = {
        ...this.state,
        fileuploads: this.allUploadedPayloads
      };

      // 26 jan change 


      if (!this.errors) this.errors = {};
      this.errors[bucketKey] = '';
      this.errors = { ...this.errors }; // reactivity

      // 26 jan change end here

      console.log('All payload files:', JSON.stringify(this.allUploadedPayloads));
      console.log('file length', this.allUploadedPayloads.length);
      console.log('state:', JSON.stringify(this.state));
    });

    console.log('this.state', JSON.stringify(this.state));
  }

  // 9 jan change end here
  formatFileSize(bytes) {
    if (bytes < 1024) return `${bytes} B`;
    else if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    else return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }


  // Utility function to show error temporarily
  showTemporaryError(message, duration = 3000) {
    this.fileError = message;
    setTimeout(() => {
      this.fileError = "";
    }, duration);
  }

  formatDateToDDMMYYYY(dateInput) {
    const date = new Date(dateInput);

    if (isNaN(date)) {
      console.error("Invalid date input");
      return null;
    }

    const day = String(date.getDate()).padStart(2, "0");
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const year = date.getFullYear();

    return `${day}/${month}/${year}`;
  }
  // --- Delete uploaded file ---
  // handleFileDelete(event) {

  //   if (this.isLocked) return;   // 10 dec change
  //   const name = event.currentTarget.dataset.name;
  //   this.uploadedFiles = this.uploadedFiles.filter((f) => f.name !== name);
  //   this.uploadedFilePayload = this.uploadedFilePayload.filter(
  //     (f) => f.name !== name
  //   );
  // }

  // 9 jan change


  handleFileDelete(event) {
    if (this.isLocked) return;
    const name = event.currentTarget.dataset.name;
    const key = event.currentTarget.dataset.key; // bind this in the template

    if (!key) return;

    const uiBucket = this.uploadedFilesByKey[key] || [];
    const payloadBucket = this.uploadedFilePayloadByKey[key] || [];

    this.uploadedFilesByKey = {
      ...this.uploadedFilesByKey,
      [key]: uiBucket.filter((f) => f.name !== name),
    };
    this.uploadedFilePayloadByKey = {
      ...this.uploadedFilePayloadByKey,
      [key]: payloadBucket.filter((f) => f.name !== name),
    };

    // 26 jan change


    // â¬‡ï¸ NEW: if the bucket becomes empty, set error only when user already tried submit
    const nowEmpty = (this.uploadedFilePayloadByKey[key] ?? []).length === 0;
    if (!this.errors) this.errors = {};
    this.errors[key] = (this.hasTriedGetPrice && nowEmpty) ? 'Please attach the required document.' : '';
    this.errors = { ...this.errors }; // reactivity nudge

    // 26 jan change end here

  }

  // 9 jan change end here

  // 26 jan change





  // Returns the static guidance rows you want to show (edit as needed)

  // Existing helper you added
  getGuidanceRows() {
    return [
      { kwh: '0 - 64', outletMin: '0 - 21', model: 'U6' },
      { kwh: '65 - 171', outletMin: '0 - 21', model: 'U16' },
      { kwh: '172 - 267', outletMin: '0 - 21', model: 'U25' },
      { kwh: '268 - 427', outletMin: '0 - 21', model: 'U40' },
      { kwh: '428 - 693', outletMin: '0 - 21', model: 'U65' },
      { kwh: '694 - 1066', outletMin: '0 - 21', model: 'U100' },
      { kwh: '1067 - 1706', outletMin: '0 - 21', model: 'U160' },
      { kwh: '1707 - 99999', outletMin: '0 - 21', model: 'Rotary' },
      { kwh: '1707 - 99999', outletMin: '0 - 21', model: 'Turbine' },
      { kwh: '0 - 99999', outletMin: '22 - 99999', model: 'Rotary' },
      { kwh: '0 - 99999', outletMin: '22 - 99999', model: 'Turbine' }
    ];
  }

  // OPTIONAL: Choose which row to highlight based on current inputs
  getGuidanceActiveIndex() {
    const pl = Number(this.state?.peakLoad || '');
    const op = Number(this.state?.outletPressure || '');
    if (isNaN(pl) || isNaN(op)) return -1;

    const rows = this.getGuidanceRows();
    for (let i = 0; i < rows.length; i++) {
      const [pL, pH] = rows[i].kwh.split('-').map(s => Number(String(s).trim()));
      const [oL, oH] = rows[i].outletMin.split('-').map(s => Number(String(s).trim()));
      const inKwh = (!isNaN(pL) && !isNaN(pH)) ? (pl >= pL && pl <= pH) : false;
      const inOut = (!isNaN(oL) && !isNaN(oH)) ? (op >= oL && op <= oH) : false;
      if (inKwh && inOut) return i;
    }
    return -1;
  }

  //  NEW: return rows with a 'rowClass' already computed
  get guidanceRowsWithClass() {
    const rows = this.getGuidanceRows();
    const active = this.getGuidanceActiveIndex();
    return rows.map((r, i) => ({
      ...r,
      rowClass: i === active ? 'active-row' : ''
    }));
  }


  // 26 jan change end here


  resetMeterSizeForSubtype(subtypeId) {
    // 1) Reset state value
    this.state = { ...this.state, MeterSize: '' };

    // 2) Reset the select options for this subtype to a single placeholder
    const placeholder = [{ label: 'Select Meter Size', value: '' }];
    if (subtypeId && this.questionConfig[subtypeId]) {
      this.questionConfig[subtypeId] = this.questionConfig[subtypeId].map(q => {
        if (q.key === 'MeterSize') {
          return { ...q, options: placeholder };
        }
        return q;
      });
    }

    // 3) Clear any UI radio remnants tied to MeterSize (if any)
    // (usually not needed for MeterSize because it's a select, but kept for parity)

    // this.template.querySelectorAll('input[name="meterSize"]').forEach(r => { r.checked = false; });

    // 4) Clear errors related to MeterSize 
    if (!this.errors) this.errors = {};
    this.errors.MeterSize = '';
    this.errors = { ...this.errors };
  }

  isSelectedSubType(subLabel) {
    return subLabel === this.selectedSubTypeLabel;
  }

  decorateSubTypes() {
    this.filteredSubTypes = (this.filteredSubTypes || []).map(sub => ({
      ...sub,
      isSelected: sub.label === this.selectedSubTypeLabel
    }));
  }
  handleDeselectsubtype() {
    console.log('handleDeselectsubtype');
    // Modal flag should be boolean
    this.isModel = false;
    window.location.reload(true);
  }
}