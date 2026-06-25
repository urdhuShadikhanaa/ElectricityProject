import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import getAllEnquiryCodes from "@salesforce/apex/NGMCP_EnquiriesHandler.getAllEnquiryCodes";
import submitDataQuery from "@salesforce/apex/NGMCP_EnquiriesHandler.submitDataQuery";
import createDataQueryRecord from "@salesforce/apex/NGMCP_EnquiriesHandler.createDataQueryRecord";
const FIELDS = ['User.Email', 'User.Profile.Name'];
import REQUEST_HEADER from "@salesforce/label/c.NGMCP_UWR_Popup_Header";
import uploadFiles from '@salesforce/apex/NGMCP_RequestObjectClass.uploadFiles';
import uploadtoMAximoSystem from '@salesforce/apex/NGMCP_RequestObjectClass.uploadDocumentToMaximo';
import validateDeuplicateRequest from '@salesforce/apex/NGMCP_WorkRequestController.validateDeuplicateRequest';

const MAX_FILE_SIZE = 4 * 1024 * 1024;
const MAX_TOTAL_ATTACHMENT_SIZE = 4 * 1024 * 1024;
const MAX_FILE_SIZE_MB = 4;

export default class DataQueryForm extends LightningElement {
  selectedMainQuery = '';
  selectedReason = '';
  selectedAssetReason = '';
  selectedAssetType = '';
  selectedAssetIssue = '';
  instructionText = '';
  FileUploadmessage = '';
  @track FileUploadmessageFlag = false;
    @track meterIssueError = false;  // 2 june change
    @track assetTypeError = false;  // 2 june change
    @track converterIssueError = false;   // 2 june
  @track formData = {};
  @api metadataRecord;
  @api shortCode;
  @api
  get assetDetails() {
    return this._assetDetails;
  }
  set assetDetails(val) {
    // Accept array OR object; normalize to array of {label, value, apiName?}
    if (Array.isArray(val)) {
      this._assetDetails = val;
    } else if (val && typeof val === 'object') {
      // convert { label: value } object shape (if ever received)
      this._assetDetails = Object.entries(val).map(([label, value]) => ({ label, value }));
    } else {
      this._assetDetails = [];
    }
    // Try to auto-fill MSN whenever new asset details arrive
    this.tryAutofillMsn();
    this.tryAutofillAdqIncorrectAssetDetails?.(); // adq
    this.tryAutofillAdqOldMsn?.();
  }

  _assetDetails = [];

  @api
  get converterSerialNo() { return this._converterSerialNo; }
  set converterSerialNo(val) {
    this._converterSerialNo = (val ?? '').toString().trim();
    // Try to fill as soon as a value arrives
    this.tryAutofillCsn?.();
    setTimeout(() => this.tryAutofillCsn?.(), 0); // after paint
  }
  _converterSerialNo = '';

 @api
get converterDetails() {
  console.log('converterDetails',this._converterDetails);
    return this._converterDetails;
}
set converterDetails(val) {
    // Accept array OR object; normalize to array of { label, value }
    if (Array.isArray(val)) {
        this._converterDetails = val;
    } else if (val && typeof val === 'object') {
        this._converterDetails = Object.entries(val).map(([label, value]) => ({
            label,
            value
        }));
    } else {
        this._converterDetails = [];
    }
    // Re-apply COQ visibility whenever converter details arrive
    this.applyCOQVisibility();
    setTimeout(() => this.applyCOQVisibility(), 0);
    // Keep existing COQ autofill logic
    this.tryAutofillAdqConverterEnquiry?.();
    setTimeout(() => this.tryAutofillAdqConverterEnquiry?.(), 0);
}

  @api addressDetails = {};
  @api createrequestFlag;
  @api status;
  @track _isResidentialU6Raw;            // raw 'Yes'/'No'/true/false/undefined
  @track _residentialU6Provided = false; // Yes OR No was actually provided?
  @api
  get isResidentialU6Site() {
    return this._isResidentialU6Raw;
  }
  set isResidentialU6Site(val) {
    this._isResidentialU6Raw = val;
    // Treat explicit Yes/No as "provided"; undefined/null/'' => "not provided"
    const isYes = (val === true || val === 'true' || val === 'Yes');
    const isNo = (val === false || val === 'false' || val === 'No');
    this._residentialU6Provided = (isYes || isNo);
  }

  paymentMechanism;
  postCode;
  @api mprn;
  @api ngmUser;
  @track duplicateMessage;
  @track dynamicFields = [];  // 13 feb change for disappear issue
  // ✨ NEW: Contact Site details (Title, Name, Number, Email)
  @track contactDetails = {
    title: '',
    name: '',
    contactNumber: '',
    requestedOnBehalfOf: '',
    contactEmail: ''   // will be set from current user email if available
  };

  suppliercode;
  userId = USER_ID;
  @api selectedMainQueryvalue;
  email;
  postalTown;
  buildingName;
  buildingNumber;
  street;
  dependentLocality;
  descriptionText;
  enquiryCodes = [];
  mainQueryOptions = [];
  dateQueryReasons = [];
  assetDataReasons = [];
  _allAssetDataReasons = [];
  assetTypeOptions = [];
  meterIssues = [];
  converterIssues = [];
  meterDetails = {};
  @track isModal = false;
  @track requestHeader = REQUEST_HEADER;
  @track successMessage //= SUCCESS_MESSAGE;
  @track serviceTicketid //= SERVICETICKET_ID;
  @track engineerVisitMessage;
  @track engineerVisitMessageFlag = false;
  @track investigationMessage;
  @track submittedDate;
  @track srNumber;
  @track isLoading = false;
  // --- Appointment Date validation flag (for if:true in HTML) ---
  appointmentDateError = false;  // 9 feb change
  @track uploadedFiles = []; // for UI display
  uploadedFilePayload = []; // ready for API call
  @track fileError = "";
  @track consent = false;
  @track consentMessage = '';
  @track consentMessageFlag = false;
  @api haszoo2;
  @api thirdParty;
  @track profile;
  @track profileName;

  @wire(getRecord, { recordId: '$userId', fields: FIELDS })
  userRecord({ error, data }) {
    if (data) {
      this.email = data.fields.Email.value;
      const profileName = data.fields?.Profile?.value?.fields?.Name?.value;
      
      this.profileName = profileName;
      this.profile = profileName === 'NGMCP_Gas Supplier Agent' || profileName === 'NGMCP_Gas Supplier Manager';
    }
  }

  // --- Contact Site: state & helpers ---
  titles = ["Mr", "Mrs", "Miss", "Ms", "Dr", "Company"];
  @track validationErrors = {};
  maxInstructionLength = 255;
  remainingChars = this.maxInstructionLength;

  get titleOptions() {
    return (this.titles || []).map(t => ({ label: t, value: t }));
  }

  get remainingCharsLabel() {
    const n = typeof this.remainingChars === 'number' ? this.remainingChars : this.maxInstructionLength;
    return `${n} ${n === 1 ? 'character' : 'characters'} remaining`;
  }
  get charLimitClass() { return this.remainingChars < 10 ? 'char-limit warning' : 'char-limit'; }

  // Show the section after the relevant selection
  get showContactDetailsSection() {
    const astReady =
      (this.selectedMainQuery === 'AST') &&
      ((this.selectedReason && this.selectedReason !== 'ADQ') ||
        (this.selectedReason === 'ADQ' && !!this.selectedAssetReason));
    const tqueryReady = (this.selectedMainQuery === 'TQUERY') && !!this.selectedAssetIssue;
    return astReady || tqueryReady;
  }

  // Make contact fields required only for Technical Query
  get isContactRequired() {
    return this.selectedMainQuery === 'TQUERY';
  }

  // Normalizer to compare labels safely
  normalizeLabel(s) {
    return (s ?? '')
      .toString()
      .trim()
      .toLowerCase()
      .replace(/\./g, '')        // drop dots in "no."
      .replace(/\s+/g, ' ');     // collapse spaces
  }

  // Read value by panel label from Asset Details (right-hand card)
  getAssetValueByLabel(label) { 
    const list = Array.isArray(this._assetDetails) ? this._assetDetails : []; 
    const want = this.normalizeLabel(label);
    const row = list.find(i => this.normalizeLabel(i?.label) == want);
    return (row?.value ?? '').toString().trim();
  }
  

  // Read value by panel label from Converter Details (if parent passes it)
  getConverterValueByLabel(label) {
    const list = Array.isArray(this._converterDetails) ? this._converterDetails : [];
    const want = this.normalizeLabel(label);
    // 1) exact match first
    let row = list.find(i => this.normalizeLabel(i?.label) === want);
    if (row?.value) {
        return (row.value ?? '').toString().trim();
    }
    // 2) tolerant aliases for Create Request / Home differences
    const aliases = {
        'manufacturer serial no': [
            'manufacturer serial no',
            'manufacturer serial number',
            'serial number',
            'converter serial number'
        ],
        'model': [
            'model',
            'converter model'
        ],
        'no of dials': [
            'no of dials',
            'no. of dials',
            'number of dials',
            'dials'
        ]
    };
    const aliasList =
        aliases[want] ||
        aliases[want.replace(/\./g, '')] ||
        [want];
    row = list.find(i => {
        const lbl = this.normalizeLabel(i?.label).replace(/\./g, '');
        return aliasList.some(a => this.normalizeLabel(a).replace(/\./g, '') === lbl);
    });
    return (row?.value ?? '').toString().trim();
}

  // Read Manufacturer Serial no. (from assetDetails array)
  get manufacturerSerialFromAsset() {
    const list = Array.isArray(this._assetDetails) ? this._assetDetails : [];
    // Try by apiName first, then by label text
    const row = list.find(i =>
      (i?.apiName && String(i.apiName).toLowerCase() === 'serialnumber') ||
      (i?.label && ['manufacturer serial no', 'manufacturer serial number']
        .includes(this.normalizeLabel(i.label)))
    );
    return (row?.value ?? '').toString().trim();
  }

  // converter
  // --- REPLACE your existing converter serial extractor with this ---
  // Prefer converter-details array; fall back to asset-details if needed
  get converterManufacturerSerialFromAsset() {
    const list = Array.isArray(this._converterDetails) ? this._converterDetails : [];
    const norm = s => (s ?? '').toString().trim().toLowerCase().replace(/\./g, '').replace(/\s+/g, ' ');
    const row = list.find(i => norm(i?.label).includes('manufacturer serial'));
    if (row?.value) return String(row.value).trim();
    const assets = Array.isArray(this._assetDetails) ? this._assetDetails : [];
    const row2 = assets.find(i => {
      const L = norm(i?.label);
      return L.includes('converter') && L.includes('manufacturer serial');
    });
    if (row2?.value) return String(row2.value).trim();
    const any = assets.find(i => norm(i?.label).includes('manufacturer serial'));
    return (any?.value || '').toString().trim();
  }
  // converter
  ensureCsnVisibleAndFilled() {
    const key = 'Converter Serial Number'; // <-- keep form label exactly
    // Prefer explicit prop, then details fallback
    const csn = (this.converterSerialNo || this.converterManufacturerSerialFromAsset || '').trim();
    if (!csn) return;
    // 1) Update model only if blank (never overwrite user input)
    const current = (this.formData?.[key] || '').trim();
    if (!current) {
      this.formData = { ...(this.formData || {}), [key]: csn };  
    }
    // 2) Reflect into the textbox after render (if not value-bound)
    requestAnimationFrame(() => {
      const el = this.template.querySelector(
        `[data-field="${key}"], [name="${key}"]`
      );
      if (el && !el.value) {
        el.value = csn; 
      }
    });
  }
  // (keep your normalizeLabel() and manufacturerSerialFromAsset() as you added)
  // Add this helper log method once (near other helpers)
  debugMsnSources(where) {
    const fromAsset = this.manufacturerSerialFromAsset;
    const keys = Object.keys(this.formData || {});
  }

  // --- Contact Site labels: show "(optional)" only for Data Query (AST) ---
  get contactTitleLabel() {
    return this.isContactRequired ? 'Title *' : 'Title (optional)';
  }
  get contactNameLabel() {
    return this.isContactRequired ? 'Name *' : 'Name (optional)';
  }
  get contactNumberLabel() {
    return this.isContactRequired ? 'Contact number *' : 'Contact number (optional)';
  }

  // --- Contact handlers & validation ---
  // === FIXED handleTitleChange ===
  handleTitleChange(event) {
    // Shallow-merge for consistent reactivity
    this.contactDetails = { ...this.contactDetails, title: event.detail.value };
    // Prepare a local copy of validation errors (this was missing)
    let errors = { ...this.validationErrors };
    if (this.isContactRequired) {
      if (!this.contactDetails.title) {
        errors.title = "Title is required.";
      } else {
        delete errors.title;
      }
    } else {
      // Optional under Data Query – clear any previous error
      delete errors.title;
    }
    this.validationErrors = errors;
  }

  handleContactInputChange(event) {
    const field = event.target.name;
    const value = event.detail?.value ?? event.target.value;
    this.contactDetails = { ...this.contactDetails, [field]: value };
    let errors = { ...this.validationErrors };
    if (field === 'contactNumber') {
      const trimmed = value ? value.trim() : "";
      const phonePattern = /^\d{11}$/;
      if (this.isContactRequired) {
        if (!trimmed) { errors.contactNumber = "Please enter a valid 11-digit contact number."; }
        else if (!phonePattern.test(trimmed)) { errors.contactNumber = "Please enter a valid 11-digit contact number."; }
        else { delete errors.contactNumber; }
      } else {
        if (trimmed && !phonePattern.test(trimmed)) {
          errors.contactNumber = "Please enter a valid 11-digit contact number.";
        } else { delete errors.contactNumber; }
      }
    }
    if (field === 'name') {
      const trimmed = value ? value.trim() : "";
      if (this.isContactRequired) {
        if (!trimmed) { errors.name = "Name is required."; }
        else if (trimmed.length > 30) { errors.name = "Name cannot exceed 30 characters."; }
        else { delete errors.name; }
      } else {
        if (trimmed && trimmed.length > 30) {
          errors.name = "Name cannot exceed 30 characters.";
        } else { delete errors.name; }
      }
    }
    this.validationErrors = errors;
  }

  // 6 jan change
  // Hard cap for Additional Information
  MAX_ADDITIONAL_INFO = 1000;

  isAdditionalInfoCappedContext() {
    // Data Query → Enquiry Reason
    const isDataQueryEnquiry = this.selectedMainQuery === 'AST';
    // Technical Query → Converter issue type
    const isTechnicalConverter =
      this.selectedMainQuery === 'TQUERY' && this.selectedAssetType === 'CON';
    //  Technical Query → Meter issue types to cap
    const METER_CAP_ISSUES = new Set(['BSM', 'CRM', 'FMB', 'MNR', 'MUOP', 'WOMS', 'DUM4' /*, 'OTHER_CODE' */]);
    const isTechnicalMeterCapped =
      this.selectedMainQuery === 'TQUERY' &&
      this.selectedAssetType === 'MET' &&
      METER_CAP_ISSUES.has(this.selectedAssetIssue);
    return isDataQueryEnquiry || isTechnicalConverter || isTechnicalMeterCapped;
  }

  // when: (a) Asset Data Query -> Ad-hoc, or (b) Technical Query -> Meter -> Other
  // Hide ONLY the heading "Sample Enquiry Instruction"
  // when: (a) Asset Data Query -> Ad-hoc,
  //       (b) Technical Query -> Meter -> Other,
  //       (c) Technical Query -> Converter -> Other.
  get hideInstructionTitle() {
    // --- (a) Ad-hoc under Asset Data Query ---
    let isAdhoc = false;
    if (this.selectedMainQuery === 'AST' && this.selectedReason) {
      // Try by code first (add the exact code your org uses once confirmed)
      const ADHOC_CODES = new Set(['adhoc', 'AD_HOC', 'ADH', 'ADHO']);
      if (ADHOC_CODES.has(this.selectedReason)) {
        isAdhoc = true;
      } else {
        // Fallback: match by label text from dateQueryReasons
        const reasonObj = (this.dateQueryReasons || []).find(r => r.value === this.selectedReason);
        const label = (reasonObj?.label || '').trim().toLowerCase();
        isAdhoc = label === 'adhoc' || label.includes('adhoc');
      }
    }
    // Common helper to detect "Other" by code OR label from an array of options
    const isOtherByCodeOrLabel = (selectedValue, optionsArray, extraCodes = []) => {
      if (!selectedValue) return false;
      const OTHER_CODES = new Set(['OTHER', 'OTH', 'DUM4', ...extraCodes]); // add your exact codes if you know them
      if (OTHER_CODES.has(selectedValue)) return true;
      const opt = (optionsArray || []).find(o => o.value === selectedValue);
      const label = (opt?.label || '').trim().toLowerCase();
      return label === 'other' || label === 'other issue' || label.includes('other');
    };
    // --- (b) Meter -> Other under Technical Query ---
    const isMeterOther =
      this.selectedMainQuery === 'TQUERY' &&
      this.selectedAssetType === 'MET' &&
      isOtherByCodeOrLabel(this.selectedAssetIssue, this.meterIssues);
    // --- (c) Converter -> Other under Technical Query ---
    const isConverterOther =
      this.selectedMainQuery === 'TQUERY' &&
      this.selectedAssetType === 'CON' &&
      isOtherByCodeOrLabel(this.selectedAssetIssue, this.converterIssues);
    // Hide title if any of the above applies
    return isAdhoc || isMeterOther || isConverterOther;
  }

  // HTML uses this to set <textarea maxlength=...>
  get computedAdditionalInfoMax() {
    return this.isAdditionalInfoCappedContext() ? this.MAX_ADDITIONAL_INFO : null;
  }

  // Optional live counter label
  get additionalInfoRemainingLabel() {
    if (!this.isAdditionalInfoCappedContext()) return '';
    const val = this.formData?.additionalInfo || '';
    const remaining = Math.max(0, this.MAX_ADDITIONAL_INFO - val.length);
    return `${remaining} ${remaining === 1 ? 'character' : 'characters'} remaining`;
  }

  handleInstructionInput(event) {
    const el = event.target;
    let val = el.value || "";
    if (val.length > this.maxInstructionLength) {
      val = val.substring(0, this.maxInstructionLength);
      el.value = val;
    }
    this.contactDetails = { ...this.contactDetails, instructions: val };
    this.remainingChars = this.maxInstructionLength - val.length;

    let errors = { ...this.validationErrors };
    const forbiddenChars = /["<>]/;
    if (forbiddenChars.test(val)) {
      errors.instructions = 'Invalid character detected. Characters " < > are not allowed.';
    } else if (val.length > this.maxInstructionLength) {
      errors.instructions = `Maximum ${this.maxInstructionLength} characters allowed.`;
    } else { delete errors.instructions; }
    this.validationErrors = errors;
  }

  // Call this inside handleSubmit before Apex (optional but recommended)
  validateContactSite() {
    const requireContact = this.isContactRequired;
    let ok = true;
    const errors = { ...this.validationErrors };
    // Title
    if (requireContact) {
      if (!this.contactDetails.title) { errors.title = "Title is required."; ok = false; }
      else { delete errors.title; }
    } else { delete errors.title; }
    // Name
    const name = (this.contactDetails.name ?? "").trim();
    if (requireContact) {
      if (!name) { errors.name = "Name is required."; ok = false; }
      else if (name.length > 30) { errors.name = "Name cannot exceed 30 characters."; ok = false; }
      else { delete errors.name; }
    } else {
      if (name && name.length > 30) { errors.name = "Name cannot exceed 30 characters."; ok = false; }
      else { delete errors.name; }
    }
    // Contact Number
    const phone = (this.contactDetails.contactNumber ?? "").trim();
    const phonePattern = /^\d{11}$/;
    if (requireContact) {
      if (!phone) { errors.contactNumber = "Please enter a valid 11-digit contact number."; ok = false; }
      else if (!phonePattern.test(phone)) { errors.contactNumber = "Please enter a valid 11-digit contact number."; ok = false; }
      else { delete errors.contactNumber; }
    } else {
      if (phone && !phonePattern.test(phone)) { errors.contactNumber = "Please enter a valid 11-digit contact number."; ok = false; }
      else { delete errors.contactNumber; }
    }
    // instruction safety (unchanged behavior)
    const val = this.contactDetails.instructions ?? "";
    if (val.length > this.maxInstructionLength) {
      errors.instructions = `Maximum ${this.maxInstructionLength} characters allowed.`;
      ok = false;
    } else if (/[\"<>]/.test(val)) {
      errors.instructions = 'Invalid character detected. Characters " < > are not allowed.';
      ok = false;
    } else { delete errors.instructions; }
    this.validationErrors = errors;
    return ok;
  }

  // --- Upload Photos (drag & drop + browse) ---
  @track uploadedFiles = [];
  uploadedFilePayload = [];
  fileError = "";
  handleDragOver(event) { event.preventDefault(); event.currentTarget.classList.add("drag-over"); }
  handleDragLeave(event) { event.preventDefault(); event.currentTarget.classList.remove("drag-over"); }
  handleFileDrop(event) {
    event.preventDefault();
    event.currentTarget.classList.remove("drag-over");
    const files = event.dataTransfer.files;
    this.processFiles(files);
  }
  handleFileChange(event) {
    const files = event.target.files;
    this.processFiles(files);
    event.target.value = "";
  }

  handleBrowseClick(event) {
    event.preventDefault();                      // no navigation
    const input = this.template.querySelector(".file-input");
    if (input) input.click();
  }

  processFiles(fileList) {
    this.fileError = '';
    if (!fileList || fileList.length === 0) return;
    const duplicateFiles = [];
    const readPromises = [];
    Array.from(fileList).forEach((file) => {
      // Prevent duplicates
      if (this.uploadedFiles.some(f => f.name === file.name)) {
        duplicateFiles.push(file.name);
        return;
      }
      // Size validation
      if (file.size > MAX_FILE_SIZE) {
        const maxMB = (MAX_FILE_SIZE / 1024 / 1024).toFixed(0);
        this.showTemporaryError(
          `File "${file.name}" exceeds ${maxMB} MB limit.`
        );
        return;
      }
      // Wrap FileReader in Promise
      const filePromise = new Promise((resolve) => {
        const reader = new FileReader();
        reader.onload = () => {
          const base64Data = reader.result.split(',')[1];
          resolve({
            ui: {
              name: file.name,
              size: file.size,
              sizeDisplay: this.formatFileSize(file.size),
              isImage: file.type.startsWith('image/'),
              previewUrl: file.type.startsWith('image/') ? reader.result : null
            },
            payload: {
              name: file.name,
              type: file.type,
              size: file.size,
              dType: "PHT",
              base64: base64Data
            }
          });
        };
        reader.readAsDataURL(file);
      });
      readPromises.push(filePromise);
    });
    //  Wait for ALL files to be read
    Promise.all(readPromises).then(results => {
      results.forEach(res => {
        this.uploadedFiles = [...this.uploadedFiles, res.ui];
        this.uploadedFilePayload = [...this.uploadedFilePayload, res.payload];
      });
    });
    // Duplicate file warning
    if (duplicateFiles.length > 0) {
      this.showTemporaryError(
        duplicateFiles.length === 1
          ? `File "${duplicateFiles[0]}" is already uploaded.`
          : `Files "${duplicateFiles.join('", "')}" are already uploaded.`
      );
    }
  }
  showTemporaryError(message, duration = 3000) {
    this.fileError = message;
    setTimeout(() => { this.fileError = ""; }, duration);
  }
  handleFileDelete(event) {
    this.fileError = '';
    const name = event.currentTarget.dataset.name;
    this.uploadedFiles = this.uploadedFiles.filter(f => f.name !== name);
    this.uploadedFilePayload = this.uploadedFilePayload.filter(f => f.name !== name);
  }
  formatFileSize(bytes) {
    if (bytes < 1024) return `${bytes} B`;
    else if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    else return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }
  getTotalUploadedFileSize() {
    return (this.uploadedFilePayload || []).reduce(
      (total, file) => total + (file?.size || 0),
      0
    );
  }

  validateCombinedAttachmentSize() {
    const totalSize = this.getTotalUploadedFileSize();
    if (totalSize > MAX_TOTAL_ATTACHMENT_SIZE) {
      this.fileError = `Combined size of attachments (${this.formatFileSize(totalSize)}) exceeds ${MAX_FILE_SIZE_MB} MB limit. Please amend and submit.`;
      return false;
    }
    return true;
  }

  instructionMap = {
    FOU: 'Found Meter that is not recorded on your system. MSN **************, Manufacturer******, Model*******,  Installed on DD/MM/YY. Please investigate.',
    adhoc: 'Instruction: Provide additional context...',
    ADQ: 'Instruction: Ensure asset details are accurate...',
    DUM1: 'An exchange took place DD/MM/YY, Old MSN was ************** final read was *****. The new MSN is **************, New Manufacturer ********, New Model**********,  new read *****.',
    MRV: 'MSN ************** was removed on DD/MM/YY with a final read of *****',
    CAA: 'The current address is incorrect. Please amend to: (provide new address details).',
    CRO: 'Please include ALL MPRNs, addresses and asset details for each crossed MPRN. Please also ensure Xoserve is updated prior to submitting through to NGM.',
    REP: 'We have had confirmation from the GT that our MPRN********** is a duplicate of MPRN**********  please remove the meter from our MPRN.',
    CFU: 'We believe the correction factor to be incorrect. It should be ***** based on the annual consumption ********.',
    DUM2: 'The asset details currently held by you are incorrect. The correct details are: MSN **************.,Model*****,YOM******,Manufacturer*******,Meter type*********,Payment method*******.',
    CRM: 'MSN ************** has severe corrosion. Please see attached photo and arrange a site visit to replace the meter.',
    MUOP: 'MSN ************** is under/over pulsing (state in comments). Please advise where confirmed from.',
    MNR: 'MSN ************** is not registering consumption, gas is being used. Please arrange a site visit to replace the meter.',
    FMB: 'MSN ************** is not fixed to the bracket and needs to be secured. No deliberate damage has been caused. Please rectify.',
    WOMS: 'MSN ************** has water/condensation in the screen. Please see attached photo and arrange a site visit to replace the meter.',
    BSM: 'MSN ************** has a blank screen. Gas is being used. Please arrange a site visit to replace the meter.',
    LBC: 'CSN***** is showing a low battery warning. Gas is being used. Please arrange a site visit to replace the converter battery.',
    CROS: 'CSN***** reads are out of sync with the meter/AMR equipment. Please arrange a site visit to rectify.',
    CXPC: 'CSN***** is not pulsing correctly as confirmed by (state in comments). Please arrange a site visit and investigate.',
    DUM5: 'Our customer states that the Asset status is different to what it shows in Maximo. Maximo shows it as **. However our customer states that is ** and has been since **/**/****.',
    COQ: 'The Convertor for this site is currently set incorrectly. We believe it should be of Converter serial number ***** Converter Model ******** No. of Dials *** Converter Units ****'
  };

uiInstructionMap = {
    CAA: 'Please provide the correct address for NGM to amend.',
    CRO: 'Please include ALL MPRNs, addresses and asset details for each crossed MPRN. Please also ensure Xoserve is updated prior to submitting through to NGM.',
    ADHOC: 'Please provide Enquiry Information.',
    REP: 'Please note that the supplier must first contact the GT to establish if a replicate situation exists, following this the query submitted to National Gas Metering must state the GTs findings. If the supplier fails to state that they have approached the GT National Gas Metering will reject the query back to the supplier.',
    COQ: 'Please update and correct the Converter details below and attach any picture evidence.',
    //  Correction Factor Challenge
    CFU: 'Please enter below what the correction factor should be and provide any supplementary information or evidence.',
    //  Incorrect Asset Details
    DUM2: 'Please update and correct the Meter details below and attach any picture evidence.',
    //  Meter Status Enquiry
    DUM5: 'This query code should only be used for meters that are still on site and not removed meters. The asset status codes that can be challenged are LI, CA, CL, CU, SP and RT.',
    //  Missing Exchange
    DUM1: 'Please provide the details of the missing exchange in the fields below.',
    //  Missing Removal
    MRV: 'Please provide the details of the missing removal in the fields below.'
};

  enquiryFieldsMap = {
    FOU: [
      { label: 'MSN', placeholder: 'Enter Meter Serial Number' },
      { label: 'Manufacturer Model', placeholder: 'Enter Model' },
      { label: 'Installation Date', placeholder: 'DD/MM/YYYY' }
    ],
    CAA: [
      { label: 'Building Name', placeholder: 'Enter Building Name' },
      { label: 'Building Number', placeholder: 'Enter Number' },
      { label: 'Street', placeholder: 'Enter Street' },
      { label: 'Dependent Locality', placeholder: 'Enter Locality' },
      { label: 'Postal Town', placeholder: 'Enter Town' },
      { label: 'Postal Code', placeholder: 'Enter Postal Code' }
    ],
    CRO: [
      { label: 'MPRN', placeholder: 'Enter MPRN' },
      { label: 'Address Detail', placeholder: 'Enter Address' },
      { label: 'Meter Detail', placeholder: 'Enter Meter Info' }
    ],
    MRV: [
      { label: 'Old MSN', placeholder: 'Enter Old MSN' },
      { label: 'Old Index', placeholder: 'Enter Old Index' },
      { label: 'Removal Date', placeholder: 'DD/MM/YYYY' }
    ],
    DUM1: [
      { label: 'Old MSN', placeholder: 'Enter Old MSN' },
      { label: 'Old Index', placeholder: 'Enter Old Index' },
      { label: 'New MSN', placeholder: 'Enter New MSN' },
      { label: 'New Manufacturer', placeholder: 'Enter Manufacturer' },
      { label: 'New Model', placeholder: 'Enter Model' },
      { label: 'New Index', placeholder: 'Enter New Index' },
      { label: 'Exchange Date', placeholder: 'DD/MM/YYYY' }
    ],
    DUM2: [
      { label: 'Correct Meter Serial Number', placeholder: 'Enter Correct Meter Serial Number' },
      { label: 'Correct Meter Model', placeholder: 'Enter Correct Meter Model' },
      { label: 'Correct Meter YOM', placeholder: 'Enter Correct Meter YOM' },
      { label: 'Correct Meter Manufacturer', placeholder: 'Enter Correct Meter Manufacturer' },
      { label: 'Correct Meter Type', placeholder: 'Enter Correct Meter Type' },
      { label: 'Correct Meter Payment Method', placeholder: 'Enter Correct Meter Payment Method' },
    ],
    CFU: [
      { label: 'Correction Factor', placeholder: 'Enter Correction Factor' },
      { label: 'Annual Consumption', placeholder: 'Enter Annual Consumption' }
    ],
    DUM5: [
      { label: 'Maximo Asset Status', placeholder: 'Enter Maximo Asset Status' },
      { label: 'Customer Asset Status', placeholder: 'Enter Customer Asset Status' },
      { label: 'Customer Status Date', placeholder: 'Enter Customer Status Date' }
    ],
    CRM: [
      { label: 'Meter Serial Number', placeholder: 'Enter Meter Serial Number' },
    ],
    MUOP: [
      { label: 'Meter Serial Number', placeholder: 'Enter Meter Serial Number' },
    ],
    MNR: [
      { label: 'Meter Serial Number', placeholder: 'Enter Meter Serial Number' },
    ],
    FMB: [
      { label: 'Meter Serial Number', placeholder: 'Enter Meter Serial Number' },
    ],
    WOMS: [
      { label: 'Meter Serial Number', placeholder: 'Enter Meter Serial Number' },
    ],
    BSM: [
      { label: 'Meter Serial Number', placeholder: 'Enter Meter Serial Number' },
    ],
    LBC: [
      { label: 'Converter Serial Number', placeholder: 'Enter Converter Serial Number' },
    ],
    CROS: [
      { label: 'Converter Serial Number', placeholder: 'Enter Converter Serial Number' },
    ],
    CXPC: [
      { label: 'Converter Serial Number', placeholder: 'Enter Converter Serial Number' },
    ],
    COQ: [
      { label: 'Converter Serial Number', placeholder: 'Enter Converter Serial Number' },
      { label: 'Converter Model', placeholder: 'Enter Converter Model' },
      { label: 'Number Of Dials', placeholder: 'Enter Number Of Dials' },
      { label: 'Converter Units', placeholder: 'Enter Converter Units' }
    ],
    REP: [
      { label: 'MPRN', placeholder: 'Enter MPRN' },
      { label: 'Duplicate MPRN', placeholder: 'Enter Duplicate MPRN' },
    ],
  };

  rebuildDynamicFields() {
    const base =
      this.enquiryFieldsMap[this.selectedReason] ||
      this.enquiryFieldsMap[this.selectedAssetReason] ||
      this.enquiryFieldsMap[this.selectedAssetIssue] ||
      [];
    this.dynamicFields = base.map(f => {
      const label = (f.label || '').trim().toLowerCase();
      return {
        ...f,     
        isremovaldate: label === 'removal date',
        isexchangedate: label === 'exchange date',
        iscuststatusdate: label === 'customer status date',
        ismeterremovaldate: label === 'meter removal date',
        isinstallationdate: label === 'installation date'
      };
    });  
  }
  // -- Min-date getters (undefined = allow past/present/future) --
  get computedMinDateForDum5() { return this.isdum5 ? undefined : this.todayIso; }
  get computedMinDateForRep() { return this.isrep ? undefined : this.todayIso; }
  get computedMinDateForFou() { return this.isfou ? undefined : this.todayIso; }

  // Helper: today in YYYY-MM-DD (used as default elsewhere if you want)
  get todayIso() {
    const t = new Date();
    const y = t.getFullYear();
    const m = String(t.getMonth() + 1).padStart(2, '0');
    const d = String(t.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  get dum5Key() { return `dum5-${this.formData?.custStatusDateIso || ''}`; }
  get repKey() { return `rep-${this.formData?.meterRemovalDateIso || ''}`; }
  get fouKey() { return `fou-${this.formData?.installationDateIso || ''}`; }

  // Utility: ISO -> DD/MM/YYYY
  formatIsoToDdMmYyyy(iso) {
    const d = new Date(iso);
    const dd = String(d.getDate()).padStart(2, '0');
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const yyyy = d.getFullYear();
    return `${dd}/${mm}/${yyyy}`;
  }

  // Customer Status – Date
  handleDum5DateSelected(event) {
    // Expect a date-only string like 'YYYY-MM-DD' from the date picker
    const iso = event.detail?.date || event.detail?.value;
    if (!iso) return;
    // Build 'DD/MM/YYYY' without using Date() to avoid timezone issues
    const [y, m, d] = iso.split('-');
    const formatted = `${d.padStart(2, '0')}/${m.padStart(2, '0')}/${y}`;
    // Update form state with both display and raw date-only ISO
    this.formData = {
      ...this.formData,
      ['Customer Status Date']: formatted,
      custStatusDateIso: iso
    };
    // Hide any existing error for Customer Status Date
    const err = this.template.querySelector('[data-error-for="Customer Status Date"]');
    if (err) err.hidden = true;  
  }

  // REP – Meter Removal Date
  // Meter Removal – Date
  handleRepDateSelected(event) {
    // Expect a date-only string like 'YYYY-MM-DD' from the date picker
    const iso = event.detail?.date || event.detail?.value;
    if (!iso) return;
    // Build 'DD/MM/YYYY' without using Date() to avoid timezone issues
    const [y, m, d] = iso.split('-');
    const formatted = `${d.padStart(2, '0')}/${m.padStart(2, '0')}/${y}`;
    // Update form state with both display and raw date-only ISO
    this.formData = {
      ...this.formData,
      ['Meter Removal Date']: formatted,
      meterRemovalDateIso: iso
    };
    // Hide any existing error for Meter Removal Date
    const err = this.template.querySelector('[data-error-for="Meter Removal Date"]');
    if (err) err.hidden = true;
  }

  // FOU – Installation Date
  handleFouDateSelected(event) {
    // Expecting a date-only string like 'YYYY-MM-DD' from the date picker
    const iso = event.detail?.date || event.detail?.value;
    if (!iso) return;
    // Build 'DD/MM/YYYY' without using Date() to avoid timezone issues
    const [y, m, d] = iso.split('-');
    const formatted = `${d.padStart(2, '0')}/${m.padStart(2, '0')}/${y}`;
    // Update form state with both display and raw date-only ISO
    this.formData = {
      ...this.formData,
      ['Installation Date']: formatted,
      installationDateIso: iso
    };
    // Hide any existing error for Installation Date
    const err = this.template.querySelector('[data-error-for="Installation Date"]');
    if (err) err.hidden = true;  
  }

  // 22 jan change end here
  handleMissingDateSelected(event) {  
    const iso = event.detail?.date;  
    if (!iso) return;
    const [y, m, d] = iso.split('-').map(Number);
    const date = new Date(y, m - 1, d); // Local date, no timezone shift
    const dd = String(date.getDate()).padStart(2, '0');
    const mm = String(date.getMonth() + 1).padStart(2, '0');
    const yyyy = date.getFullYear();
    const formatted = `${dd}/${mm}/${yyyy}`; 
    const isExchange = this.isdum1; 
    this.formData = {
      ...this.formData,
      [isExchange ? 'Exchange Date' : 'Removal Date']: formatted,
      [isExchange ? 'exchangeDateIso' : 'removalDateIso']: iso
    }; 
    const err = this.template.querySelector(
      `[data-error-for="${isExchange ? 'Exchange Date' : 'Removal Date'}"]`
    );
    if (err) err.hidden = true;
  }
  // 21 jan change end here
  handleMainQueryChange(event) {
    this.selectedMainQuery = this.selectedMainQueryvalue ? this.selectedMainQueryvalue : event?.target?.value;
  }
  get showDateQuerySection() { return this.selectedMainQuery === 'AST'; }
  get showAssetDataOptions() { return this.selectedReason === 'ADQ'; }
  get showTechnicalQuerySection() { return this.selectedMainQuery === 'TQUERY'; }

  // 9 feb change
  get isTechnicalQuery() {
    return this.selectedMainQuery === 'TQUERY';
  }

  // Visible when: Technical Query → Meter → one of the meter issue codes that uses "Meter Serial Number"
  // Replace old isTechMeterMsnFieldVisible with this
  get isTechMeterMsnFieldVisible() {
    const isTech = this.selectedMainQuery === 'TQUERY';
    const isMeter = this.selectedAssetType === 'MET'; // your code uses 'MET' for Meter
    if (!isTech || !isMeter) return false;
    // Accept both the code and the label for safety
    const val = (this.selectedAssetIssue || '').toString().trim();
    const code = val.toUpperCase();
    const label = (() => {
      const opt = (this.meterIssues || []).find(o => o.value === val);
      return (opt?.label || '').toString().trim().toLowerCase();
    })();
    const meterIssuesNeedingMSN = new Set(['CRM', 'MUOP', 'MNR', 'FMB', 'WOMS', 'BSM']);
    const labelsNeedingMSN = new Set([
      'corrosion', 'under/over pulsing', 'not registering', 'fixed to bracket',
      'water/condensation in the screen', 'blank screen', 'blank', 'water', 'bracket'
    ]);
    return meterIssuesNeedingMSN.has(code) || labelsNeedingMSN.has(label);
  }
  // Fill "Meter Serial Number" from Asset Details only if the field is currently empty
  // Replace the whole tryAutofillMsn with this version
  tryAutofillMsn() {
    try {
      this.debugMsnSources('tryAutofillMsn/begin');
      if (!this.isTechMeterMsnFieldVisible) return;
      const msn = (this.manufacturerSerialFromAsset || '').trim();
      if (!msn) return;
      // Candidate keys used across your codebase
      const candidateKeys = [
        'Meter Serial Number',   // used by instruction builder
        'MSN',                   // common short key
        'Correct Meter Serial Number' // appears in DUM2 contexts
      ];
      // Update formData only for keys that are currently empty
      let changed = false;
      const next = { ...(this.formData || {}) };
      candidateKeys.forEach(k => {
        const current = (next[k] || '').trim();
        if (!current) {
          next[k] = msn;
          changed = true;
        }
      });
      if (changed) {
        this.formData = next;
      }
      // Reflect into the live input AFTER render (covers timing issues)
      requestAnimationFrame(() => {
        // Try to find inputs by data-field or name (both patterns exist in your HTML)
        const selectors = candidateKeys.flatMap(k => ([
          `[data-field="${CSS.escape(k)}"]`,
          `[name="${CSS.escape(k)}"]`
        ]));
        const el = this.template.querySelector(selectors.join(', '));
        if (el && !el.value) {
          el.value = msn; // only set if blank to avoid overwriting user edits
        }
        this.debugMsnSources('tryAutofillMsn/afterRAF');
      });
    } catch (e) {
      // console.warn('MSN sync skipped:', e);
    }
  }
  // === ADQ → Asset Data Enquiry → Incorrect Asset Details (DUM2) ===
  tryAutofillAdqIncorrectAssetDetails() {
    try {
      console.log('DEBUG assetDetails inside autofill:', JSON.stringify(this._assetDetails));
      const inADQ = (this.selectedMainQuery === 'AST' && this.selectedReason === 'ADQ');
      // Allow both code match and label match (“Incorrect Asset Details”)
      const code = (this.selectedAssetReason || '').toString().trim().toUpperCase();
      const labelObj = (this.assetDataReasons || []).find(o => o.value === this.selectedAssetReason);
      const lbl = (labelObj?.label || '').toString().trim().toLowerCase();
      const isDum2 = (code === 'DUM2') || (lbl === 'incorrect asset details');
      if (!inADQ || !isDum2) return;
      // Map target form keys → source panel labels
      const pairs = [
        { target: 'Correct Meter Serial Number', label: 'Manufacturer Serial no.' },
        { target: 'Correct Meter Model', label: 'Model' },
        { target: 'Correct Meter YOM', label: 'Year of Manufacture' },
        { target: 'Correct Meter Manufacturer', label: 'Manufacturer' },
        { target: 'Correct Meter Type', label: 'Meter Type' },
        { target: 'Correct Meter Payment Method', label: 'Payment Mechanism' }
      ];
      let changed = false;
      const next = { ...(this.formData || {}) };
      pairs.forEach(({ target, label }) => {
        if (!(next[target] || '').trim()) {
          const val = this.getAssetValueByLabel(label);
          if (val) { next[target] = val; changed = true; }
        }
      });
      if((next["Correct Meter Type"] == 'Z001' || next["Correct Meter Type"] == 'Z002') && Array.isArray(this.assetDetails) &&  this.assetDetails.some(  item =>  item &&  item.label && item.label.toLowerCase() === 'puls metertype' )){
        next["Correct Meter Type"] = this.assetDetails.find(item => item.label === 'Puls MeterType')?.value;
      }
      if((this.formData["Correct Meter Type"] == 'Z001' || this.formData["Correct Meter Type"] == 'Z002') && Array.isArray(this.assetDetails) &&  this.assetDetails.some(  item =>  item &&  item.label && item.label.toLowerCase() === 'puls metertype' )){
        this.formData["Correct Meter Type"] = this.assetDetails.find(item => item.label === 'Puls MeterType')?.value;
      }  
      if (changed) this.formData = next;
      // Reflect into DOM after render (no overwrite)
      requestAnimationFrame(() => {
        pairs.forEach(({ target }) => {
          const el = this.template.querySelector(
            `[data-field="${CSS.escape(target)}"], [name="${CSS.escape(target)}"]`
          );
          if (el && !el.value && this.formData?.[target]) {
            el.value = this.formData[target];
          }
        });
      });
    } catch (e) { /* no-op */ }
  }

  tryAutofillAdqConverterEnquiry() {
    try {
        // Scope: Data Query -> Asset Data Enquiry -> Converter Enquiry
        const inADQ = (this.selectedMainQuery === 'AST' && this.selectedReason === 'ADQ');
        const code = (this.selectedAssetReason || '').toString().trim().toUpperCase();
        const labelObj = (this.assetDataReasons || []).find(o => o.value === this.selectedAssetReason);
        const lbl = (labelObj?.label || '').toString().trim().toLowerCase();
        const isConverterEnquiry = (code === 'COQ') || lbl.includes('converter');
        if (!inADQ || !isConverterEnquiry) return;
        const pairs = [
            { target: 'Converter Serial Number', convLabel: 'Manufacturer Serial no.' },
            { target: 'Converter Model', convLabel: 'Model' },
            { target: 'Number Of Dials', convLabel: 'No. of Dials' }
        ];
        let changed = false;
        const next = { ...(this.formData || {}) };
        pairs.forEach(({ target, convLabel }) => {
            const cur = (next[target] || '').trim();
            if (cur) return;
            // ONLY use converterDetails (same behavior as Home)
            let val = (this.getConverterValueByLabel?.(convLabel) || '').trim();
            // Optional: allow explicit serial prop only for serial number
            if (!val && target === 'Converter Serial Number') {
                val = (this.converterSerialNo || '').trim();
            }
            if (val) {
                next[target] = val;
                changed = true;
            }  
        });
        if (changed) {
            this.formData = next;    
        }
        // 2 june
        else {   
}
    // 2 june change end
        // Reflect into visible inputs after render (do not overwrite user-entered values)
        requestAnimationFrame(() => {
            pairs.forEach(({ target }) => {
                const el = this.template.querySelector(
                    `[data-field="${CSS.escape(target)}"], [name="${CSS.escape(target)}"]`
                );
                if (el && !el.value && this.formData?.[target]) {
                    el.value = this.formData[target];    
                }
            });
        });
    } catch (e) {
        console.warn('[ED][COQ] autofill error:', e);
    }
}

  // === ADQ → Asset Data Enquiry → Missing Exchange / Missing Removal ===
  // Prefill "Old MSN" from Asset Details → "Manufacturer Serial no."
  tryAutofillAdqOldMsn() {
    try {
      // Scope to Data Query → Asset Data Enquiry
      const inADQ = (this.selectedMainQuery === 'AST' && this.selectedReason === 'ADQ');
      if (!inADQ) return;
      // Robust subtype detection: allow code or label
      const code = (this.selectedAssetReason || '').toString().trim().toUpperCase();
      const labelObj = (this.assetDataReasons || []).find(o => o.value === this.selectedAssetReason);
      const lbl = (labelObj?.label || '').toString().trim().toLowerCase();
      const isMissingRemoval = lbl.includes('missing removal') || code === 'MISSINGREMOVAL' || code === 'MR' || code === 'MRV';
      const isMissingExchange = lbl.includes('missing exchange') || code === 'MISSINGEXCHANGE' || code === 'ME' || code === 'MEX';
      if (!isMissingRemoval && !isMissingExchange) return;
      const TARGET = 'Old MSN';
      // Do not overwrite if user already typed
      const current = (this.formData?.[TARGET] || '').trim();
      if (current) return;
      const msn = this.getAssetValueByLabel?.('Manufacturer Serial no.') || '';
      if (!msn) return;
      // Update model
      this.formData = { ...(this.formData || {}), [TARGET]: msn };
      // Reflect to the field after render (if not value-bound), without overwriting
      requestAnimationFrame(() => {
        const el = this.template.querySelector(
          `[data-field="${CSS.escape(TARGET)}"], [name="${CSS.escape(TARGET)}"]`
        );
        if (el && !el.value) el.value = msn;
      });
    } catch (e) {
      // no-op
    }
  }
  // converter

  tryAutofillCsn() {
    try {
      if (!this.isTechConverterCsnFieldVisible) return;
      // 1) Prefer explicit prop from parent
      let csn = (this.converterSerialNo || '').trim();
      // 2) Fallbacks
      if (!csn) csn = (this.converterManufacturerSerialFromAsset || '').trim();
      if (!csn) return;
      // Update only if blank (do not overwrite user input)
      const keys = ['Converter Serial Number', 'CSN'];
      let changed = false;
      const next = { ...(this.formData || {}) };
      keys.forEach(k => {
        if (!(next[k] || '').trim()) { next[k] = csn; changed = true; }
      });
      if (changed) this.formData = next;
      // Reflect to DOM after render if the input isn't value-bound
      requestAnimationFrame(() => {
        const selectors = keys.flatMap(k => ([
          `[data-field="${CSS.escape(k)}"]`,
          `[name="${CSS.escape(k)}"]`
        ]));
        const el = this.template.querySelector(selectors.join(', '));
        if (el && !el.value) el.value = csn;  
      });
    } catch (e) { /* no-op */ }
  }

  get isMeterSelected() { return this.selectedAssetType === 'MET'; }
  get isConverterSelected() { return this.selectedAssetType === 'CON'; }
  get showEnquiryForm() {
    return (
      (this.selectedReason && this.selectedReason !== 'ADQ')
      || this.selectedAssetReason
      || this.selectedAssetIssue
    );
  }

  resetFormForSelection() {
    // Keep state aligned with UI
    this.formData.visitSite = null;
    this.formData.riskAssessment = null;
    this.formData.converterIssue = null;
    this.formData.meterIssue = null;
    this.selectedAssetReason = '';
    this.selectedAssetIssue = '';
    this.selectedAssetType = '';
    // Clear instruction + form data payload
    this.instructionText = '';
    this.formData = {};
    // Optional: clear appointment selections
    delete this.formData.appointmentDate;
    delete this.formData.appointmentTimeslot;
    // Optional: uncheck visitSite / riskAssessment radios in DOM
    const radios = this.template.querySelectorAll('input[type="radio"][name="visitSite"], input[type="radio"][name="riskAssessment"]');
    radios.forEach(r => { r.checked = false; });
    // Hide any visible inline errors (dynamic section)
    this.template.querySelectorAll('.section-card.custom-additional-info-section .error-text').forEach(el => el.hidden = true);
    this.template.querySelectorAll('.section-card.custom-additional-info-section .text-input.invalid').forEach(el => el.classList.remove('invalid'));
  }

  handleInputChange(event) {
    // Resolve the field key from data-field or name
    const field = event.target.dataset.field || event.target.name;
    if (!field) return;
    // Read value correctly for both Lightning base components and plain inputs
    const value = (event.detail && event.detail.value !== undefined)
      ? event.detail.value
      : event.target.value;
    // --- Enforce 1000-char cap when context requires it ---
    if (field === 'additionalInfo' && this.isAdditionalInfoCappedContext()) {
      const capped = (value || '').slice(0, this.MAX_ADDITIONAL_INFO);
      if (value !== capped) {
        // Reflect the trimmed value back to the UI
        event.target.value = capped;
      }
      this.formData = { ...this.formData, [field]: capped };
      // Hide/show inline error (in case of pasting long text)
      const errEl = this.template.querySelector('[data-error-for="additionalInfo"]');
      if (errEl) errEl.hidden = true; // input is now within limit
    } else {
      this.formData = { ...this.formData, [field]: value };
    }
 
    // If a radio was selected, hide that group’s inline error (if present)
    if (['visitSite', 'riskAssessment', 'converterIssue', 'meterIssue'].includes(field)) {
      const group = event.target.closest('.custom-question-section') || this.template;
      const errEl = group.querySelector(`[data-error-for="${field}"]`);
      if (errEl) errEl.hidden = !!value;
    }
    // When user toggles visitSite away from 'Yes', clear appointment fields & errors
    if (field === 'visitSite' && value !== 'Yes') {
      this.formData.appointmentDate = null;
      this.formData.appointmentTimeslot = null;
      const dateErr = this.template.querySelector('[data-error-for="appointmentDate"]');
      if (dateErr) dateErr.hidden = true;
      const tsErr = this.template.querySelector('[data-error-for="appointmentTimeslot"]');
      if (tsErr) tsErr.hidden = true;
    }
  }

  handleAppointmentTimeslotChange(event) {
    // Read the selected value
    const value = (event.detail && event.detail.value !== undefined)
      ? event.detail.value
      : event.target.value;
    // Store it for submit
    this.formData = { ...this.formData, appointmentTimeslot: value };
    // Hide the inline error next to THIS select (nearest container)
    const container = event.target.closest('.form-group, .custom-timeslot-section, .appointment-slot') || this.template;
    const tsErr = container.querySelector('[data-error-for="appointmentTimeslot"]');
    if (tsErr) tsErr.hidden = !!value;
    // Also remove the red outline if you add it during validation
    event.target.classList.remove('invalid');
  }

  // ✨ NEW: Contact Site inputs handler
  handleContactChange(event) {
    const field = event.target.name; // title | name | contactNumber | contactEmail
    const value = event.target.value;
    this.contactDetails = { ...this.contactDetails, [field]: value };
    // Optional: simple numeric-only cleanup for contactNumber
    if (field === 'contactNumber' && typeof value === 'string') {
      const digits = value.replace(/\D/g, '');
      this.contactDetails = { ...this.contactDetails, contactNumber: digits };
    }
  }

  get showAppointmentFields() {
    return (this.formData && this.formData.visitSite ? this.formData.visitSite : 'No') === 'Yes';
  }

  get showApptDateAsterisk() {
    const isMeterOrConverter = (this.selectedAssetType === 'MET' || this.selectedAssetType === 'CON');
    return this.showAppointmentFields && this.isTechnicalQuery && isMeterOrConverter;
  }

  renderedCallback() {
    const mrvDp = this.template.querySelector('c-ngmcp-appoint-demolition[name="removalDate"]');
    
    if (this.selectedMainQueryvalue) {
      this.handleMainQueryChange();
    }
    try {
      // Run on every render, but it only fills when the Converter field is visible and blank
      if (this.selectedMainQuery === 'TQUERY' && this.selectedAssetType === 'CON') {
        // If you have a visibility getter for converter CSN, you can also gate on it:
        // if (this.isTechConverterCsnFieldVisible) { ... }
        this.ensureCsnVisibleAndFilled();
      }
    } catch (e) {
      // no-op
    }
    try {
      // Only for Data Query → ADQ screens
      if (this.selectedMainQuery === 'AST' && this.selectedReason === 'ADQ') {
        this.tryAutofillAdqIncorrectAssetDetails();
        this.tryAutofillAdqConverterEnquiry();
      }
    } catch (e) { /* no-op */ }

    try {
      if (this.selectedMainQuery === 'AST' && this.selectedReason === 'ADQ') {
        this.tryAutofillAdqOldMsn();
      }
    } catch (e) { /* no-op */ }
  }

  async connectedCallback() {
    if (Array.isArray(this.addressDetails) && this.addressDetails.length > 0) {
      const addressObj =
        this.addressDetails.reduce((acc, { apiName, value }) => {
          acc[apiName] = value;
          return acc;
        }, {});
      this.addressDetails = addressObj;
    }
    
    this.postCode = this.addressDetails.postCode;
    this.buildingNumber = this.addressDetails.buildingNumber;
    this.buildingName = this.addressDetails.buildingName;
    this.street = this.addressDetails.street;
    this.postalTown = this.addressDetails.postalTown;
    this.dependentLocality = this.addressDetails.dependentLocality;

    if (this.status == null || this.status == '' || this.status == undefined) {
      this.status = this.isResidentialU6Site == 'Yes' ? 'Residential' : 'Commercial';
    }

    if (this.metadataRecord && this.metadataRecord.length > 0 && this.metadataRecord[0].suppliercode) {
      this.suppliercode = this.metadataRecord[0].suppliercode;
    } else if (this.metadataRecord && this.metadataRecord.suppliercode) {
      this.suppliercode = this.metadataRecord.suppliercode;
    }
    if (this.suppliercode == null || this.suppliercode == '' || this.suppliercode == undefined) {
      this.suppliercode = this.shortCode
    }
    
    await this.fetchEnquiryCodes();

    if (this.selectedMainQueryvalue) {
      this.handleMainQueryChange();
    }
    
  }

  async fetchEnquiryCodes() {
    try {
      const data = await getAllEnquiryCodes({}); 
      this.enquiryCodes = Array.isArray(data) ? data : [];
      const mainQueryLabels = new Set(this.mainQueryOptions.map(i => i.label));
      const dateQueryLabels = new Set(this.dateQueryReasons.map(i => i.label));
      const assetTypeLabels = new Set(this.assetTypeOptions.map(i => i.label));
      const assetDataLabels = new Set(this.assetDataReasons.map(i => i.label));
      const meterLabels = new Set(this.meterIssues.map(i => i.label));
      const converterLabels = new Set(this.converterIssues.map(i => i.label));

      for (const ec of this.enquiryCodes) {
        const category = ec?.NGMCP_Enquiry_Category__c;
        const categoryCode = ec?.NGMCP_Enquiry_Category_Code__c;
        const subCategory = ec?.NGMCP_Enquiry_Sub_Category__c;
        const subCategoryCode = ec?.NGMCP_Enquiry_Sub_Category_Code__c;
        const reason = ec?.NGMCP_Enquiry_Reason__c;
        const reasonCode = ec?.NGMCP_Enquiry_Reason_Code__c;
        if (!category) continue;

        if (!mainQueryLabels.has(category)) {
          this.mainQueryOptions = [
            ...this.mainQueryOptions,
            { label: category, value: categoryCode, description: ec.NGMCP_Description__c, isChecked: false }
          ];
          mainQueryLabels.add(category);
        }
        if (category === 'Asset Data Query' && subCategory && !dateQueryLabels.has(subCategory) && !reason && !reasonCode) {
          this.dateQueryReasons = [
            ...this.dateQueryReasons,
            { label: subCategory, value: subCategoryCode, description: ec.NGMCP_Description__c, isChecked: false }
          ];
          dateQueryLabels.add(subCategory);
        }
        
        if (category === 'Technical Query' && subCategory && !assetTypeLabels.has(subCategory) && !reason && !reasonCode)
           {
          this.assetTypeOptions = [
            ...this.assetTypeOptions,
            { label: subCategory, value: subCategoryCode, description: ec.NGMCP_Description__c, isChecked: false }
          ];
          assetTypeLabels.add(subCategory);
        }
        if (subCategory === 'Asset Data Enquiry' && reason && !assetDataLabels.has(reason)) {
          this.assetDataReasons = [
            ...this.assetDataReasons,
            { label: reason, value: reasonCode, description: ec.NGMCP_Description__c, isChecked: false }
          ];
          assetDataLabels.add(reason);
        }
        if (subCategory === 'Meter' && reason && !meterLabels.has(reason)) {
          this.meterIssues = [
            ...this.meterIssues,
            { label: reason, value: reasonCode, description: ec.NGMCP_Description__c, isChecked: false }
          ];
          meterLabels.add(reason);
        }
        if (subCategory === 'Converter' && reason && !converterLabels.has(reason)) {
          this.converterIssues = [
            ...this.converterIssues,
            { label: reason, value: reasonCode, description: ec.NGMCP_Description__c, isChecked: false }
          ];
          converterLabels.add(reason);
        }
      }
      const index = this.dateQueryReasons.findIndex(item => item.label.toLowerCase() === 'adhoc');
      if (index !== -1 && this.profileName != 'CRM Profile') {
        this.dateQueryReasons.splice(index, 1);
      }
      
      if (Array.isArray(this.dateQueryReasons)) {
        this.dateQueryReasons = this.dateQueryReasons.filter(j => {
          const val = j.value;
          // If thirdParty → show only FOU
          if (this.thirdParty) {
            return val === 'FOU';
          }
          // Otherwise:
          if (val === 'FOU') return false;          // hide FME
          if (!this.ngmUser && val === 'ADHOC') return false;  // hide Ad-hoc
          return true;
        });
      }

      if (Array.isArray(this.assetTypeOptions)) {
    const status = (this.status || '').toString().toLowerCase().trim();
        this.assetTypeOptions = this.assetTypeOptions.filter(j => {
          const val = j.value;
        //  FIX: allow Meter if status contains 'comm'
          if (val === 'MET') {
            return status.includes('comm');  
        }
        //  FIX: allow converter if converter section exists
        if (val === 'CON') {
            return this.hasRealConverter();
          }
          return true;
        });
    
}     

this._allAssetDataReasons = [...this.assetDataReasons];

this.applyCOQVisibility();
 
    } catch (error) {
      console.error('Error fetching enquiry codes: ', JSON.stringify(error));
    }
  }

  /**
   * Reset the dynamic form area when the user changes any tile.
   * We don't touch the tile selections passed in (selectedReason, selectedAssetReason, etc.),
   * we only clear the form rows, inline errors, and instruction.
   */
  resetDynamicSection() {
    // clear dynamic payload
    this.formData = {};
    this.instructionText = '';
    // clear appointment bits
    delete this.formData.appointmentDate;
    delete this.formData.appointmentTimeslot;
    // clear inline errors only within the form section
    // (adjust selector to your container; this one matches your form card)
    const section = this.template.querySelector('.section-card.custom-additional-info-section') || this.template;
    section.querySelectorAll('.error-text').forEach(el => (el.hidden = true));
    section.querySelectorAll('.text-input.invalid').forEach(el => el.classList.remove('invalid'));
    // uncheck visitSite / riskAssessment radios if they’re present in DOM
    section.querySelectorAll('input[type="radio"][name="visitSite"], input[type="radio"][name="riskAssessment"]').forEach(r => { r.checked = false; });
  }

  // (Keep your highlightSelected/other handlers as-is)
  async handleReasonChange(event) {
    this.selectedReason = event.target.value;
    if (this.selectedReason != 'ADQ') {
      const raw = (this.mprn || '').toString();
      const parts = raw.split('-').map(s => (s ? s.trim() : ''));
      const mprnvalue = parts[0] || '';       // "10140505"
      const supplier = parts[1] || '';   // "GLZ"    
    }
    this.dateQueryReasons = this.dateQueryReasons.map(r => ({
      ...r,
      isChecked: r.value === this.selectedReason,
      isSelected: r.value === this.selectedReason
    }));

    this.instructionText =
    this.uiInstructionMap[this.selectedReason]
 || this.instructionMap[this.selectedReason]
 || '';

    this.formData = {};
    this.rebuildDynamicFields();  // 13 feb change 
  }
  async handleAssetReasonChange(event) {
    this.selectedAssetReason = event.target.value;
    // 1 june change
    //  Hide Enquiry Category error when selected
    const err = this.template.querySelector('[data-error-for="enquiryCategory"]');
      if (err) err.hidden = true;
      // 1 june change end
    const raw = (this.mprn || '').toString();
    const parts = raw.split('-').map(s => (s ? s.trim() : ''));
    const mprnvalue = parts[0] || '';       // "10140505"
    const supplier = parts[1] || '';   // "GLZ"
    const payloadObj = {
      recordTypeName: 'Enquiry',
      NGMCP_MPRN__c: mprnvalue,
      NGMCP_Supplier_Id__c: supplier,
      NGMCP_Enquiry_Reason_Code__c: this.selectedReason,
      NGMCP_Enquiry_Category__c: this.selectedAssetReason,
      NGMCP_Status__c: ['Closed', 'CANCELLED', 'Cancelled', 'Resolved', 'Rejected'] // NOT IN
    };
    // 3) Call Apex (expects String payload)
    const results = await validateDeuplicateRequest({
      payload: JSON.stringify(payloadObj)
    });
    if (results.length > 0) {
      this.isModal = true;
      this.duplicateMessage = 'Open request with Request Number -' + results[0].Name + ' and Service Request - ' + results[0].NGMCP_SR_Ticket__c + ' already exists for the same combination.'; 
      return;
    }
    this.assetDataReasons = this.assetDataReasons.map(r => ({
      ...r,
      isChecked: r.value === this.selectedAssetReason,
      isSelected: r.value === this.selectedAssetReason
    }));

    this.instructionText =
    this.uiInstructionMap[this.selectedAssetReason]
    || this.instructionMap[this.selectedAssetReason]
    || '';

    this.formData = {};
    this.rebuildDynamicFields();  // 13 feb change
    // Auto-fill for ADQ subtypes after tiles render
    this.tryAutofillAdqIncorrectAssetDetails();
    this.tryAutofillAdqConverterEnquiry();
    // Post-render safety
    setTimeout(() => {
      this.tryAutofillAdqIncorrectAssetDetails();
      this.tryAutofillAdqConverterEnquiry();
    }, 0);
    this.tryAutofillAdqOldMsn();
    setTimeout(() => this.tryAutofillAdqOldMsn(), 0);
  }
  async handleAssetTypeChange(event) {
    this.assetTypeError = false;   // 2 june change
    this.selectedAssetType = event.target.value;
    this.assetTypeOptions = this.assetTypeOptions.map(t => ({
      ...t,
      isChecked: t.value === this.selectedAssetType,
      isSelected: t.value === this.selectedAssetType
    }));
     const raw = (this.mprn || '').toString();
    const parts = raw.split('-').map(s => (s ? s.trim() : ''));
    const mprnvalue = parts[0] || '';       // "10140505"
    const supplier = parts[1] || '';   // "GLZ"
    const payloadObj = {
      recordTypeName: 'Enquiry',
      NGMCP_MPRN__c: mprnvalue,
      NGMCP_Supplier_Id__c: supplier,
      NGMCP_Enquiry_Reason_Code__c: this.selectedAssetType,
      NGMCP_Status__c: ['Closed', 'CANCELLED', 'Cancelled', 'Resolved', 'Rejected'] // NOT IN
    };
    // 3) Call Apex (expects String payload)
    const results = await validateDeuplicateRequest({
      payload: JSON.stringify(payloadObj)
    });
    if (results.length > 0) {
      this.isModal = true;
      this.duplicateMessage = 'Open request with Request Number -' + results[0].Name + ' and Service Request - ' + results[0].NGMCP_SR_Ticket__c + ' already exists for the same combination.';
      return;
    }
    this.selectedAssetIssue = '';
    this.instructionText = '';
    this.formData = {};
    this.rebuildDynamicFields(); // 13 feb change
    this.tryAutofillMsn();
    // In BOTH handlers, right after the existing call:
    setTimeout(() => this.tryAutofillMsn(), 0); // safety: run once after paint
    this.tryAutofillCsn();
    setTimeout(() => this.tryAutofillCsn(), 0);
  }

  async handleAssetIssueChange(event) {
      this.converterIssueError = false;  // 2 june change
    // 1 june change
    //  Hide Meter Issue error when user selects
const err = this.template.querySelector('[data-error-for="meterIssue"]');
if (err) err.hidden = true;
      // 1 june change end 
      this.meterIssueError = false;  // 2 june change 
    const selectedValue = event.target.value;
    const groupName = event.target.name;
    this.selectedAssetIssue = selectedValue;  
    const raw = (this.mprn || '').toString();
    const parts = raw.split('-').map(s => (s ? s.trim() : ''));
    const mprnvalue = parts[0] || '';       // "10140505"
    const supplier = parts[1] || '';   // "GLZ"
    const payloadObj = {
      recordTypeName: 'Enquiry',
      NGMCP_MPRN__c: mprnvalue,
      NGMCP_Supplier_Id__c: supplier,
      NGMCP_Enquiry_Category__c: this.selectedAssetIssue,
      NGMCP_Status__c: ['Closed', 'CANCELLED', 'Cancelled', 'Resolved', 'Rejected'] // NOT IN
    }; 
    // 3) Call Apex (expects String payload)
    const results = await validateDeuplicateRequest({
      payload: JSON.stringify(payloadObj)
    });
    if (results.length > 0) {  
      this.isModal = true;
      this.duplicateMessage = 'Open request with Request Number -' + results[0].Name + ' and Service Request - ' + results[0].NGMCP_SR_Ticket__c + ' already exists for the same combination.';   
      return;
    }
    if (groupName === 'meterIssue') {
      this.meterIssues = this.meterIssues.map(issue => ({
        ...issue,
        isChecked: issue.value === selectedValue,
        isSelected: issue.value === selectedValue
      }));
      // clear other list (optional but recommended)
      this.converterIssues = this.converterIssues.map(issue => ({
        ...issue,
        isChecked: false,
        isSelected: false
      }));
    }
    if (groupName === 'converterIssue') {
      this.converterIssues = this.converterIssues.map(issue => ({
        ...issue,
        isChecked: issue.value === selectedValue,
        isSelected: issue.value === selectedValue
      }));
      // clear other list
      this.meterIssues = this.meterIssues.map(issue => ({
        ...issue,
        isChecked: false,
        isSelected: false
      }));
    }
    this.instructionText =
    this.uiInstructionMap[selectedValue]
 || this.instructionMap[selectedValue]
 || '';
 
    this.formData = {};
    this.rebuildDynamicFields(); // 13 feb change
    this.tryAutofillMsn();
    setTimeout(() => this.tryAutofillMsn(), 0); // safety: run once after paint
    this.tryAutofillCsn();
    setTimeout(() => this.tryAutofillCsn(), 0);
  }

  async handleSubmit(event) {
    if ((this.selectedAssetIssue == 'CRM' || this.selectedAssetIssue == 'FMB' || this.selectedAssetIssue == 'WOMS') && this.uploadedFilePayload?.length == 0) {
      this.FileUploadmessage = 'Please Upload a File to continue';
      this.FileUploadmessageFlag = true;
      return;
    }
    if (!this.validateCombinedAttachmentSize()) {
      return;
    }
    if (this.consent == true) {
      this.consentMessage = '';
      this.consentMessageFlag = false;
      this.FileUploadmessage = '';
      this.FileUploadmessageFlag = false;
      event.preventDefault();
      this.isLoading = true;
      // 1) Validate Contact Site (add your other field validations here if any)
      // If you also validate contact site:
      const contactOk = this.validateContactSite ? this.validateContactSite() : true;
      // ✅ Asset Type validation
if (this.selectedMainQuery === 'TQUERY') {
    if (!this.selectedAssetType) {
        this.assetTypeError = true;
        this.isLoading = false;
        return;
    } else {
        this.assetTypeError = false;
    }
}
      //  Converter Issue validation
if (this.selectedMainQuery === 'TQUERY' && this.isConverterSelected) {
    if (!this.selectedAssetIssue) {
        this.converterIssueError = true;
        this.isLoading = false;
        return;
    } else {
        this.converterIssueError = false;
    }
}

if (this.selectedMainQuery === 'TQUERY' && this.isMeterSelected) {
    if (!this.selectedAssetIssue) {
        this.meterIssueError = true;
        this.isLoading = false;   // stop loading
        return;                  // stop submit immediately
    } else {
        this.meterIssueError = false;
    }
}
      // Required fields in AST/TQUERY sub-types
      const formOk = this.validateBeforeSubmit();
      if (!contactOk) {
        this.isLoading = false;
        return;
      }
      // --- Tile validations (show red line under the grids) ---
      // helper to toggle an inline error <div data-error-for="...">
      const toggleGridErr = (key, show) => {
        const err = this.template.querySelector(`[data-error-for="${CSS.escape(key)}"]`);
        if (err) err.hidden = !show;
      };
      let tilesOk = true;
      // A) Enquiry Reason Code is mandatory when Main = Asset Data Query (AST)
      if (this.selectedMainQuery === 'AST') {
        if (!this.selectedReason) {
          toggleGridErr('enquiryReason', true);
          tilesOk = false;
        } else {
          toggleGridErr('enquiryReason', false);
          // If Reason = 'ADQ' (Asset Data Enquiry), also require the Enquiry Category
          if (this.selectedReason === 'ADQ') {
            if (!this.selectedAssetReason) {
              toggleGridErr('enquiryCategory', true);       // only if you added this grid (optional)
              tilesOk = false;
            } else {
              toggleGridErr('enquiryCategory', false);
            }
          } else {
            // hide category error if grid not shown
            toggleGridErr('enquiryCategory', false);
          }
        }
      }
      // B) Asset Type is mandatory when Main = Technical Query (TQUERY)
      if (this.selectedMainQuery === 'TQUERY') {
        if (!this.selectedAssetType) {
          toggleGridErr('assetType', true);
          tilesOk = false;
        } else {
          toggleGridErr('assetType', false);
        }
      }
      // stop submit if any tile grid missing
      if (!tilesOk) {
        this.isLoading = false;
        return;
      }
      // Block submission when any field/radio validation fails
      if (!formOk) {
        this.isLoading = false;
        return;
      }
      let instructionType = '';
      if (this.selectedMainQuery === 'AST') {
        instructionType = (this.selectedReason !== 'ADQ')
          ? this.selectedReason
          : this.selectedAssetReason;
      } else if (this.selectedMainQuery === 'TQUERY') {
        //  Technical Query → use ISSUE code (Meter/Converter), e.g., CXPC
        instructionType = this.selectedAssetIssue;
      } else {
        instructionType = this.selectedAssetIssue || this.selectedAssetReason || this.selectedReason || '';
      }
      this.descriptionText = this.handleInstruction(instructionType);
      if (this.formData.additionalInfo != null && this.formData.additionalInfo != '' && this.formData.additionalInfo != undefined) {
        this.descriptionText = this.descriptionText + 'Additional Info : ' + this.formData.additionalInfo;
      }
      const assetObj = this.assetDetails.reduce((acc, item) => {
        acc[item.label] = item.value;
        return acc;
      }, {});
      //  Include Contact Site details in payload
      const payload = {
        ngme_consname: this.contactDetails.name,
        reason: this.selectedReason == 'ADQ' ? this.selectedAssetReason : this.selectedAssetIssue,
        loccode: '',
        bldgname: this.buildingName,
        bldgno: this.isfou ? this.buildingNumber : undefined,  // found meter 24 march
        sectorcode: this.metadataRecord && this.metadataRecord.length > 0 && this.metadataRecord[0].metadatalist && this.metadataRecord[0].metadatalist.length > 0 && this.metadataRecord[0].metadatalist[0].NGMCP_Market_Sector_Code__c ? this.metadataRecord[0].metadatalist[0].NGMCP_Market_Sector_Code__c : this.metadataRecord && this.metadataRecord.metadatalist && this.metadataRecord.metadatalist.length > 0 && this.metadataRecord.metadatalist[0].NGMCP_Market_Sector_Code__c ? this.metadataRecord.metadatalist[0].NGMCP_Market_Sector_Code__c : '',
        street: this.street,
        supplier: this.suppliercode,
        notif_type: this.selectedMainQuery == 'AST' ? 'DQ' : 'TQ',
        ngme_riskassess: this.formData.riskAssessment == 'Yes' ? 'Y' : 'N',
        posttown: this.postalTown,
        ngme_constitle: this.contactDetails.title,               // ✅ Title
        description_longdescription: this.descriptionText,
        ngme_engvisit: this.formData.visitSite == 'Yes' ? 'Y' : 'N',
        targetstart: this.selectedMainQuery == 'TQUERY' && this.formData.visitSite == 'No' ? '' : this.formData.appointmentDate,//new Date().toISOString().split('T')[0]
        postcode: this.postCode,                                 // ✅ FIX casing: use postCode
        ngme_time: this.formData.appointmentTimeslot,
        ngme_consphone: this.contactDetails.contactNumber,
        ngme_consemail: this.contactDetails.emailAddress,      // ✅ Contact Site Number
        deplocal: this.dependentLocality,
        ngme_threshold: 'N',
        location: this.mprn.replace(/-.*/, "").trim(),
        reportedemail: this.email, // ✅ Contact Email
        category: this.selectedMainQuery,
        subcategory: this.selectedMainQuery == 'AST' ? this.selectedReason : this.selectedAssetType
      };
      
      this.meterDetails.NGMCP_Model__c = assetObj["Model"];//this.formData["Manufacturer Model"] != null && this.formData["Manufacturer Model"] != '' && this.formData["Manufacturer Model"] != undefined ? this.formData["Manufacturer Model"] : this.formData["New Model"] != null && this.formData["New Model"] != '' && this.formData["New Model"] != undefined ? this.formData["New Model"] : '';
      this.meterDetails.NGMCP_Manufacturer_Serial_No__c = assetObj["Manufacturer Serial no."];//this.formData["MSN"] != null && this.formData["MSN"] != '' && this.formData["MSN"] != undefined ? this.formData["MSN"] : this.formData["New MSN"] != null && this.formData["New MSN"] != '' && this.formData["New MSN"] != undefined ? this.formData["New MSN"] : '';
      this.meterDetails.NGMCP_Meter_Type__c = (assetObj["Meter Type"] == 'Z001' || assetObj["Meter Type"] == 'Z002') && assetObj["Puls MeterType"] != null && assetObj["Puls MeterType"] != '' && assetObj["Puls MeterType"] != undefined ? assetObj["Puls MeterType"] : assetObj["Meter Type"];
      this.meterDetails.NGMCP_Payment_Mechanism__c = assetObj["Payment Mechanism"];
      this.meterDetails.NGMCP_Year_of_Manufacture__c = assetObj["Year of Manufacture"];
      
      try {
        const requestRecordId = await createDataQueryRecord({
          requestBody: JSON.stringify(payload),
          meterDetails: this.meterDetails,
          reportedEmail: this.contactDetails.requestedOnBehalfOf
        });
        if (requestRecordId) {
          if (this.uploadedFilePayload?.length > 0) {
            const isUploaded = await uploadFiles({
              recordId: requestRecordId,
              files: JSON.stringify(this.uploadedFilePayload)
            });
            if (!isUploaded) {
              console.error('File upload failed');
              return;
            }
          }
          const response = await submitDataQuery({
            requestBody: JSON.stringify(payload),
            requestId: requestRecordId
          });
          const parsed = typeof response === "string" ? JSON.parse(response) : response;
          if (parsed?.ticketid) {
            const doctype = this.selectedMainQuery == 'AST' ? 'AQD' : 'FMD';
            if (this.uploadedFilePayload?.length > 0) {
              uploadtoMAximoSystem({
                files: JSON.stringify(this.uploadedFilePayload),
                srticket: parsed.ticketid,
                uid: parsed.ticketuid,
                doctype: doctype
              })
                .then(result1 => { 
                  this.isModal = true;
                  const enquiryType = this.selectedMainQuery == 'AST' ? 'Data Query' : 'Technical Query';
                  this.successMessage = 'Your ' + enquiryType + ' has been successfully submitted on the '
                  this.serviceTicketid = 'The reference number is ';
                  this.srNumber = parsed.ticketid;
                  if (this.selectedMainQuery == 'AST') {
                    if (this.status == 'Residential') {
                      this.investigationMessage = 'We will look to investigate and provide a response within the agreed 4 day SLA';
                    }
                    if (this.status == 'Commercial') {
                      this.investigationMessage = 'We will look to investigate and provide a response within the agreed 10 day SLA';
                    }
                  }
                  if (enquiryType == 'Technical Query') {
                    this.investigationMessage = 'We will look to investigate and provide a response within the agreed 20 day SLA';
                    if (this.formData.appointmentDate != null && this.formData.appointmentDate != '' && this.formData.appointmentDate != undefined &&
                      this.formData.appointmentTimeslot != null && this.formData.appointmentTimeslot != '' && this.formData.appointmentTimeslot != undefined
                    ) {
                      const slots = this.formData.appointmentTimeslot.split('-');
                      //An engineer will visit on 22/12/2025 during the appointment slot between 08:00 and 12:00
                      this.engineerVisitMessage = 'An engineer will visit on ' + this.formatDateToDDMMYYYY(new Date(this.formData.appointmentDate)) + ' during the appointment slot between ' + slots[0] + ' and ' + slots[1]
                      this.engineerVisitMessageFlag = true;
                    }
                    else {
                      this.engineerVisitMessageFlag = false;
                      this.engineerVisitMessage = '';
                    }
                  }
                  this.submittedDate = this.formatDateToDDMMYYYY(new Date());
                })
                .catch(error => {
                  alert('Something went wrong while submitting the request.');
                });
            }
            else {
              this.isModal = true;
              const enquiryType = this.selectedMainQuery == 'AST' ? 'Data Query' : 'Technical Query';
              this.successMessage = 'Your ' + enquiryType + ' has been successfully submitted on the '
              this.serviceTicketid = 'The reference number is ';
              this.srNumber = parsed.ticketid;
              if (this.selectedMainQuery == 'AST') {
                if (this.status == 'Residential') {
                  this.investigationMessage = 'We will look to investigate and provide a response within the agreed 4 day SLA';
                }
                if (this.status == 'Commercial') {
                  this.investigationMessage = 'We will look to investigate and provide a response within the agreed 10 day SLA';
                }
              }
              if (enquiryType == 'Technical Query') {
                this.investigationMessage = 'We will look to investigate and provide a response within the agreed 20 day SLA';
                if (
                  this.formData.appointmentDate != null && this.formData.appointmentDate != '' && this.formData.appointmentDate != undefined &&
                  this.formData.appointmentTimeslot != null && this.formData.appointmentTimeslot != '' && this.formData.appointmentTimeslot != undefined
                ) {
                  const slots = this.formData.appointmentTimeslot.split('-');
                  //An engineer will visit on 22/12/2025 during the appointment slot between 08:00 and 12:00
                  this.engineerVisitMessage = 'An engineer will visit on ' + this.formatDateToDDMMYYYY(new Date(this.formData.appointmentDate)) + ' during the appointment slot between ' + slots[0] + ' and ' + slots[1]
                  this.engineerVisitMessageFlag = true;
                }
                else {
                  this.engineerVisitMessageFlag = false;
                  this.engineerVisitMessage = '';
                }
              }
              this.submittedDate = this.formatDateToDDMMYYYY(new Date());
            }
          }
        } else {
          console.warn(' No request record ID returned.');
        }
        this.isLoading = false;
      } catch (error) {
        console.error('Error during Apex callout:', error);
        console.error('error:', JSON.stringify(error));
        this.isLoading = false;
        alert('Something went wrong while submitting the request.');
      } 
    }
    if (this.consent == false) {
      this.consentMessage = 'consent is required';
      this.consentMessageFlag = true;
    }
  }

  validateBeforeSubmit() {
    let allValid = true;
    let firstInvalidEl = null;
    // 1) Required text/select/textarea (plain elements)
    const inputs = this.template.querySelectorAll('.text-input');
    inputs.forEach(inp => {
      if (inp.offsetParent === null) return; // skip hidden rows
      const isRequired = inp.dataset.required === 'true';
      if (!isRequired) return;
      const field = inp.dataset.field || inp.name;
      const value =
        (inp.value !== undefined) ? inp.value
          : (field ? this.formData[field] : '');
      // CHANGE starts: use let so we can override for the CAA pair rule
      let empty = !value || !String(value).trim();
      const errEl = this.template.querySelector(
        `[data-error-for="${CSS.escape(field)}"]`
      );
      // ---- CAA only (Address Amendment Enquiry): Building Name / Building Number pair rule
      let pairHandled = false;
      if (this.selectedMainQuery === 'AST'
        && this.selectedReason === 'CAA'
        && (field === 'Building Name' || field === 'Building Number')) {
        pairHandled = true;
        const otherField = (field === 'Building Name') ? 'Building Number' : 'Building Name';
        const otherEl = this.template.querySelector(
          `[data-field="${CSS.escape(otherField)}"].text-input, [name="${CSS.escape(otherField)}"].text-input`
        );
        const otherVal = (otherEl?.value ?? this.formData?.[otherField] ?? '').toString().trim();
        // Both empty → fail
        empty = !String(value || '').trim() && !otherVal;
        const msg = 'Please provide at least one of the building name or building number to submit the request';
        const errThis = this.template.querySelector(`[data-error-for="${CSS.escape(field)}"]`);
        const errOther = this.template.querySelector(`[data-error-for="${CSS.escape(otherField)}"]`);
        if (empty) {
          // Show the same message under both fields and mark both invalid
          if (errThis) { errThis.textContent = msg; errThis.hidden = false; }
          if (errOther) { errOther.textContent = msg; errOther.hidden = false; }
          inp.classList.add('invalid');
          if (otherEl) otherEl.classList.add('invalid');
        } else {
          // Either one is filled → clear both errors and remove invalid decoration
          if (errThis) { errThis.hidden = true; errThis.textContent = 'This field is required.'; }
          if (errOther) { errOther.hidden = true; errOther.textContent = 'This field is required.'; }
          inp.classList.remove('invalid');
          if (otherEl) otherEl.classList.remove('invalid');
        }
      }
      // ---- CAA pair rule end
      // Keep existing generic behavior for everything else (and for CAA fields when pair is already handled)
      if (empty) {
        allValid = false;
        firstInvalidEl = firstInvalidEl || inp;
        if (!pairHandled) {
          inp.classList.add('invalid');
          if (errEl) errEl.hidden = false;
        }
      } else {
        if (!pairHandled) {
          inp.classList.remove('invalid');
          if (errEl) errEl.hidden = true;
        }
      }
    });

    if (this.isAdditionalInfoCappedContext()) {
      const addlInfo = (this.formData?.additionalInfo || '');
      if (addlInfo.length > this.MAX_ADDITIONAL_INFO) {
        allValid = false;
        const addlEl = this.template.querySelector(
          '[data-field="additionalInfo"].text-input, [name="additionalInfo"].text-input'
        );
        const addlErr = this.template.querySelector('[data-error-for="additionalInfo"]');
        if (addlEl) addlEl.classList.add('invalid');
        if (addlErr) addlErr.hidden = false;
        firstInvalidEl = firstInvalidEl || addlEl;
      } else {
        const addlErr = this.template.querySelector('[data-error-for="additionalInfo"]');
        const addlEl = this.template.querySelector(
          '[data-field="additionalInfo"].text-input, [name="additionalInfo"].text-input'
        );
        if (addlEl) addlEl.classList.remove('invalid');
        if (addlErr) addlErr.hidden = true;
      }
    }

    // 2) Radio groups: visitSite, riskAssessment, converterIssue
    ['visitSite', 'riskAssessment', 'converterIssue'].forEach(field => {
      const plainRadios = this.template.querySelectorAll(
        `input[type="radio"][name="${CSS.escape(field)}"]`
      );
      // Only validate if the group is visible
      const anyVisible = Array.from(plainRadios).some(r => r.offsetParent !== null);
      if (!anyVisible) return;
      const anyChecked = Array.from(plainRadios).some(r => r.checked);
      const errEl = this.template.querySelector(
        `[data-error-for="${CSS.escape(field)}"]`
      );
      if (!anyChecked) {
        allValid = false;
        firstInvalidEl = firstInvalidEl || plainRadios[0];
        if (errEl) errEl.hidden = false;
      } else {
        if (errEl) errEl.hidden = true;
      }
    });
    // 3) Appointment fields required only when visitSite === 'Yes'
    if (this.formData?.visitSite === 'Yes') {
      // Date from child component: stored as formData.appointmentDate
      const dateVal = this.formData?.appointmentDate;
      const dateErr = this.template.querySelector(`[data-error-for="appointmentDate"]`);
      if (!dateVal || !String(dateVal).trim()) {
        allValid = false;
        if (dateErr) dateErr.hidden = false;
        // Try to focus the child date-picker if possible
        const dp = this.template.querySelector('c-ngmcp-date-picker-with-holidays');
        firstInvalidEl = firstInvalidEl || dp;
      } else if (dateErr) {
        dateErr.hidden = true;
      }
      // Timeslot select (plain <select>)
      const tsEl = this.template.querySelector(
        `[data-field="appointmentTimeslot"].text-input, [name="appointmentTimeslot"].text-input`
      );
      const tsErr = this.template.querySelector(`[data-error-for="appointmentTimeslot"]`);
      const tsVal = tsEl?.value || this.formData?.appointmentTimeslot;
      const tsEmpty = !tsVal || !String(tsVal).trim();
      if (tsEl) {
        if (tsEmpty) {
          allValid = false;
          firstInvalidEl = firstInvalidEl || tsEl;
          tsEl.classList.add('invalid');
          if (tsErr) tsErr.hidden = false;
        } else {
          tsEl.classList.remove('invalid');
          if (tsErr) tsErr.hidden = true;
        }
      }
    } else {
      // hide appointment errors when not required
      ['appointmentDate', 'appointmentTimeslot'].forEach(field => {
        const el = this.template.querySelector(
          `[data-field="${CSS.escape(field)}"].text-input, [name="${CSS.escape(field)}"].text-input`
        );
        const errEl = this.template.querySelector(`[data-error-for="${CSS.escape(field)}"]`);
        el && el.classList.remove('invalid');
        if (errEl) errEl.hidden = true;
      });
    }
    // 4) Scroll/focus to the first error
    if (!allValid && firstInvalidEl) {
      try {
        firstInvalidEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
        firstInvalidEl.focus && firstInvalidEl.focus();
      } catch (e) { }
    }
    return allValid;
  }

  clearAllInlineErrors(containerSelector) {
    const root = containerSelector
      ? this.template.querySelector(containerSelector)
      : this.template;
    if (!root) return;
    // Hide all error text lines
    root.querySelectorAll('.error-text').forEach(el => { el.hidden = true; });
    // Remove invalid outline from all fields
    root.querySelectorAll('.text-input.invalid').forEach(el => {
      el.classList.remove('invalid');
    });
  }

  handlePlainTyping(event) {
    const field = event.target.dataset.field || event.target.name;
    if (!field) return;
    const value = event.target.value ?? '';
    this.formData = { ...this.formData, [field]: value };
    const isEmpty = !value || !String(value).trim();
    // Find the error element that belongs to THIS field:
    // assume your field and its error <div> are wrapped by the same container.
    const group =
      event.target.closest('.form-group') ||
      event.target.closest('.custom-question-section');
    const errEl = group ? group.querySelector('.error-text') : null;
    // Toggle ONLY this field’s error
    if (isEmpty) {
      event.target.classList.add('invalid');
      if (errEl) errEl.hidden = false;
    } else {
      event.target.classList.remove('invalid');
      if (errEl) errEl.hidden = true;
    }
    // --- CAA only: live pair validation for Building Name / Building Number
    if (this.selectedMainQuery === 'AST'
      && this.selectedReason === 'CAA'
      && (field === 'Building Name' || field === 'Building Number')) {
      const otherField = (field === 'Building Name') ? 'Building Number' : 'Building Name';
      const otherEl = this.template.querySelector(
        `[data-field="${CSS.escape(otherField)}"].text-input, [name="${CSS.escape(otherField)}"].text-input`
      );
      const v1 = (this.formData?.[field] ?? '').toString().trim();
      const v2 = (this.formData?.[otherField] ?? '').toString().trim();
      const err1 = this.template.querySelector(`[data-error-for="${CSS.escape(field)}"]`);
      const err2 = this.template.querySelector(`[data-error-for="${CSS.escape(otherField)}"]`);
      const msg = 'Please provide at least one of the building name or building number to submit the request';
      if (v1 || v2) {
        // Either field has a value → clear both errors
        if (err1) { err1.hidden = true; err1.textContent = 'This field is required.'; }
        if (err2) { err2.hidden = true; err2.textContent = 'This field is required.'; }
        event.target.classList.remove('invalid');
        if (otherEl) otherEl.classList.remove('invalid');
      } else {
        // Both empty → show same message under both
        if (err1) { err1.textContent = msg; err1.hidden = false; }
        if (err2) { err2.textContent = msg; err2.hidden = false; }
        event.target.classList.add('invalid');
        if (otherEl) otherEl.classList.add('invalid');
      }
    }
  }

  // 22 dec change
  handleDateSelected(event) {
    // Expecting event.detail.date === 'YYYY-MM-DD'
    const iso = event?.detail?.date;
    if (!iso) return;
    // Optional: show selected date elsewhere in your UI
    this.selectedDate = iso;
    // ✅ Store for submit/validation
    this.formData = { ...this.formData, appointmentDate: iso };
    // ✅ Hide the "This field is required." line for appointmentDate
    const errEl = this.template.querySelector('[data-error-for="appointmentDate"]');
    if (errEl) errEl.hidden = true;
  }
  // 22 dec change end here

  handleCancel() {
    this.selectedMainQuery = '';
    this.selectedReason = '';
    this.selectedAssetReason = '';
    this.selectedAssetType = '';
    this.selectedAssetIssue = '';
    this.instructionText = '';
    this.formData = {};
  }

  handleInstruction(instruction) {
    let message = '';
    switch (instruction) {
      case 'FOU':
        message = 'Found Meter that is not recorded on your system. MSN ' + this.formData["MSN"] + ', Installed on ' + this.formData["Installation Date"] + '. Please investigate. ';
        break;
      case 'adhoc':
        message = ''
        break;
      case 'ADQ':
        message = ''
        break;
      case 'DUM1':
  message =
    'An exchange took place ' + this.formData["Exchange Date"] +
    ', Old MSN was ' + this.formData["Old MSN"] +
    ', final read was ' + this.formData["Old Index"] + '. ' +
    'The new MSN is ' + this.formData["New MSN"] +
    ', New Manufacturer ' + this.formData["New Manufacturer"] +
    ', New Model ' + this.formData["New Model"] +
    ', New read ' + this.formData["New Index"] + '. ';
  break;
      case 'MRV':
        message = 'MSN ' + this.formData["Old MSN"] + ' was removed on ' + this.formData["Removal Date"] + ' with a final read of ' + this.formData["Old Index"] + '.';
        break;
      case 'CFU':
        message = 'We believe the correction factor to be incorrect. It should be Correction Factor: '
          + this.formData["Correction Factor"]
          + ' based on the annual consumption '
          + this.formData["Annual Consumption"]
          + '. ';
        break;
      case 'DUM2':
        message = 'The asset details currently held by you are incorrect. The correct details are: MSN ' + this.formData["Correct Meter Serial Number"] + ',Model ' + this.formData["Correct Meter Model"] + ',YOM ' + this.formData["Correct Meter YOM"] + ',Manufacturer ' + this.formData["Correct Meter Manufacturer"] + ',Meter type ' + this.formData["Correct Meter Type"] + ',Payment method ' + this.formData["Correct Meter Payment Method"] + '.';
        break;
      case 'CRM':
        message = 'MSN ' + this.formData["Meter Serial Number"] + ' has severe corrosion. Please see attached photo and arrange a site visit to replace the meter. ';
        break;
      case 'MUOP':
        message = 'MSN ' + this.formData["Meter Serial Number"] + ' is under/over pulsing (state in comments). Please advise where confirmed from. ';
        break;
      case 'MNR':
        message = 'MSN ' + this.formData["Meter Serial Number"] + ' is not registering consumption, gas is being used. Please arrange a site visit to replace the meter. ';
        break;
      case 'FMB':
        message = 'MSN ' + this.formData["Meter Serial Number"] + ' is not fixed to the bracket and needs to be secured. No deliberate damage has been caused. Please rectify. ';
        break;
      case 'WOMS':
        message = 'MSN ' + this.formData["Meter Serial Number"] + ' has water/condensation in the screen. Please see attached photo and arrange a site visit to replace the meter. ';
        break;
      case 'BSM':
        message = 'MSN ' + this.formData["Meter Serial Number"] + ' has a blank screen. Gas is being used. Please arrange a site visit to replace the meter. ';
        break;
      case 'DUM4':
        message = ''
        break;
      case 'LBC':
        message = 'CSN ' + this.formData["Converter Serial Number"] + ' is showing a low battery warning. Gas is being used. Please arrange a site visit to replace the converter battery.'
        break;
      case 'CROS':
        message = 'CSN ' + this.formData["Converter Serial Number"] + ' reads are out of sync with the meter/AMR equipment. Please arrange a site visit to rectify.'
        break;
      case 'CXPC':
        message = 'CSN ' + this.formData["Converter Serial Number"] + ' is not pulsing correctly as confirmed by (state in comments). Please arrange a site visit and investigate. '
        break;
      case 'CAA':
        message = 'The current address is incorrect. Please amend to: ' + this.formData["Building Name"] + ', ' + this.formData["Building Number"] + ', ' + this.formData["Street"] + ', ' + this.formData["Dependent Locality"] + ', ' + this.formData["Postal Town"] + ', ' + this.formData["Postal Code"] + '. '
        break;
      case 'CRO':
        message = 'MPRN: ' + this.formData["MPRN"] + ', Address Detail: ' + this.formData["Address Detail"] + ', Meter Detail: ' + this.formData["Meter Detail"] + '. '
        break;
      case 'DUM5':
        message = 'Our customer states that the Asset status is different to what it shows in Maximo. Maximo shows it as  ' + this.formData["Maximo Asset Status"] + '. However our customer states that is ' + this.formData["Customer Asset Status"] + '  and has been since ' + this.formData["Customer Status Date"] + '. '
        break;
      case 'REP':
        message =
          'We have had confirmation from the GT that our MPRN ' + this.formData["MPRN"] +
          ' is a duplicate of MPRN ' + this.formData["Duplicate MPRN"] + '.' +
          ' please remove the meter from our MPRN. ';
        break;
      case 'COQ':
        message = 'The Convertor for this site is currently set incorrectly. We believe it should be of Converter Serial Number: ' + this.formData["Converter Serial Number"] + ', Converter Model:  ' + this.formData["Converter Model"] + ' , Number Of Dials: ' + this.formData["Number Of Dials"] + ' , Converter Units: ' + this.formData["Converter Units"] + '. '
        break;
      default:
        break;
    }
    return message;
  }

  // 19 jan change
  get isPhotoRequired() {
    return ['CRM', 'FMB', 'WOMS'].includes(this.selectedAssetIssue);
  }
  get showUploadError() {
    const count = Array.isArray(this.uploadedFilePayload) ? this.uploadedFilePayload.length : 0;
    return this.isPhotoRequired && count === 0;
  }
  // 19 jan change end here

  // Allow past/present/future only for Data Query → Asset Data Enquiry → Missing Removal (MRV)
  // Missing Removal (MRV)
  get ismrv() {
    return this.selectedMainQuery === 'AST'
      && this.selectedReason === 'ADQ'
      && this.selectedAssetReason === 'MRV';
  }
  // Missing Exchange
  get isdum1() {
    return this.selectedMainQuery === 'AST'
      && this.selectedReason === 'ADQ'
      && this.selectedAssetReason === 'DUM1';
  }
  // -- Context checks (AST -> ADQ -> <Reason Code>) --
  get isdum5() {   // Meter Status Enquiry
    return this.selectedMainQuery === 'AST'
      && this.selectedReason === 'ADQ'
      && this.selectedAssetReason === 'DUM5';
  }
  get isfou() {  // Found Meter Enquiry
    return this.selectedMainQuery === 'AST'
      && this.selectedReason === 'FOU';
  }
  get isrep() {  // Replicate MPRN Enquiry
    return this.selectedMainQuery === 'AST'
      && this.selectedReason === 'REP';
  }

  get computedMinDateForRemoval() {
    //  ALLOW ALL DATES only for MRV
    if (this.ismrv) return undefined;
    // default behavior (blocks past dates)
    const t = new Date();
    return `${t.getFullYear()}-${String(t.getMonth() + 1).padStart(2, '0')}-${String(t.getDate()).padStart(2, '0')}`;
  }

  get computedMaxDateForRemoval() {
    return this.ismrv ? undefined : this.maxDate; // or your usual rule
  }

  // The child will fire { detail: { value: 'YYYY-MM-DD' } } or { detail: { date: 'YYYY-MM-DD' } }
  handleRemovalDateSelected(event) {
    const iso = event?.detail?.value ?? event?.detail?.date ?? event?.target?.value;
    if (!iso) return;
    // Convert to DD/MM/YYYY because your instruction builder expects that format
    const d = new Date(iso);
    const dd = String(d.getDate()).padStart(2, '0');
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const yyyy = d.getFullYear();
    const ddmmyyyy = `${dd}/${mm}/${yyyy}`;
    // Store using the SAME key your MRV message uses ("Removal Date")
    this.formData = { ...this.formData, ['Removal Date']: ddmmyyyy, removalDateIso: iso };
    // Optional: hide inline error for this field if you show one
    const err = this.template.querySelector('[data-error-for="Removal Date"]');
    if (err) err.hidden = true;
  }

hasRealConverter() {
    if (!Array.isArray(this._converterDetails) || this._converterDetails.length === 0) {  
        return false;
    }
    // Show Converter Enquiry if converter section exists with known labels,
    // even when values are blank (client requirement)
    const expectedLabels = new Set([
        'manufacturer',
        'model',
        'manufacturer serial no.',
        'manufacturer serial no',
        'no. of dials',
        'no of dials'
    ]);
    const hasConverterSection = this._converterDetails.some(item => {
        const label = this.normalizeLabel(item?.label);
        return expectedLabels.has(label);
    });
    return hasConverterSection;
}

  // Hide Converter Enquiry (COQ) if no real converter exists
applyCOQVisibility() {
    // Wait until Asset Data Enquiry options are loaded
    if (!Array.isArray(this._allAssetDataReasons) || this._allAssetDataReasons.length === 0) {
        return;
    }
    const hasConverter = this.hasRealConverter();
    // Always rebuild from original list
    this.assetDataReasons = hasConverter
        ? [...this._allAssetDataReasons]
        : this._allAssetDataReasons.filter(r => r.value !== 'COQ');
    // If selected COQ but converter disappeared, clear only that selection
    if (!hasConverter && this.selectedAssetReason === 'COQ') {
        this.selectedAssetReason = '';
        this.instructionText = '';
        this.formData = {};
        this.rebuildDynamicFields();
    }   
}

  handleCancelClick() {
    this.dispatchEvent(new CustomEvent("cancelcreatejob"));
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
  handleDragOver(event) {
    event.preventDefault();
    event.currentTarget.classList.add("drag-over");
  }

  handleDragLeave(event) {
    event.preventDefault();
    event.currentTarget.classList.remove("drag-over");
  }

  handleFileDrop(event) {
    event.preventDefault();
    event.currentTarget.classList.remove("drag-over");
    const files = event.dataTransfer.files;
    this.processFiles(files);
  }

  handleFileChange(event) {
    const files = event.target.files;
    this.processFiles(files);
    event.target.value = "";
  }
  handleBrowseClick() {
    this.template.querySelector(".file-input").click();
  }

  processFiles(fileList) {
    this.fileError = '';
    if (!fileList || fileList.length === 0) return;
    const duplicateFiles = [];
    const readPromises = [];
    Array.from(fileList).forEach((file) => {
      // Prevent duplicates
      if (this.uploadedFiles.some(f => f.name === file.name)) {
        duplicateFiles.push(file.name);
        return;
      }
      // Size validation
      if (file.size > MAX_FILE_SIZE) {
        const maxMB = (MAX_FILE_SIZE / 1024 / 1024).toFixed(0);
        this.showTemporaryError(
          `File "${file.name}" exceeds ${maxMB} MB limit.`
        );
        return;
      }
      // Wrap FileReader in Promise
      const filePromise = new Promise((resolve) => {
        const reader = new FileReader();
        reader.onload = () => {
          const base64Data = reader.result.split(',')[1];
          resolve({
            ui: {
              name: file.name,
              size: file.size,
              sizeDisplay: this.formatFileSize(file.size),
              isImage: file.type.startsWith('image/'),
              previewUrl: file.type.startsWith('image/') ? reader.result : null
            },
            payload: {
              name: file.name,
              type: file.type,
              size: file.size,
              base64: base64Data
            }
          });
        };
        reader.readAsDataURL(file);
      });
      readPromises.push(filePromise);
    });
    //  Wait for ALL files to be read
    Promise.all(readPromises).then(results => {
      results.forEach(res => {
        this.uploadedFiles = [...this.uploadedFiles, res.ui];
        this.uploadedFilePayload = [...this.uploadedFilePayload, res.payload];
      });      
    });
    // Duplicate file warning
    if (duplicateFiles.length > 0) {
      this.showTemporaryError(
        duplicateFiles.length === 1
          ? `File "${duplicateFiles[0]}" is already uploaded.`
          : `Files "${duplicateFiles.join('", "')}" are already uploaded.`
      );
    }
  }

  // Utility function to show error temporarily
  showTemporaryError(message, duration = 3000) {
    this.fileError = message;
    setTimeout(() => {
      this.fileError = "";
    }, duration);
  }
  
  // --- Delete uploaded file ---
  handleFileDelete(event) {
    const name = event.currentTarget.dataset.name;
    this.uploadedFiles = this.uploadedFiles.filter((f) => f.name !== name);
    this.uploadedFilePayload = this.uploadedFilePayload.filter(
      (f) => f.name !== name
    );
  }

  formatFileSize(bytes) {
    if (bytes < 1024) return `${bytes} B`;
    else if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    else return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }

  handleConsentInputChange(event) {
    this.consent = event.target.checked;
    if (event.target.checked == true) {
      this.consentMessage = '';
      this.consentMessageFlag = false;
    }
    else {
      this.consentMessage = 'consent is required';
      this.consentMessageFlag = true;
    }
  }

}