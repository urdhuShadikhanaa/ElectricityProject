import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import getAllEnquiryCodes from "@salesforce/apex/NGMCP_EnquiriesHandler.getAllEnquiryCodes";
import submitDataQuery from "@salesforce/apex/NGMCP_EnquiriesHandler.submitDataQuery";
import createDataQueryRecord from "@salesforce/apex/NGMCP_EnquiriesHandler.createDataQueryRecord";
const FIELDS = ['User.Email'];
import REQUEST_HEADER from "@salesforce/label/c.NGMCP_UWR_Popup_Header";
//import SUCCESS_MESSAGE from "@salesforce/label/c.NGMCP_UWR_Success_PopUp";
//import SERVICETICKET_ID from "@salesforce/label/c.NGMCP_UWR_Service_RequestId";
import uploadFiles from '@salesforce/apex/NGMCP_RequestObjectClass.uploadFiles';
import uploadtoMAximoSystem from '@salesforce/apex/NGMCP_RequestObjectClass.uploadDocumentToMaximo';
const MAX_FILE_SIZE = 5 * 1024 * 1024; //5MB

export default class DataQueryForm extends LightningElement {
    selectedMainQuery = '';
    selectedReason = '';
    selectedAssetReason = '';
    selectedAssetType = '';
    selectedAssetIssue = '';
    instructionText = '';

    FileUploadmessage = '';
    @track FileUploadmessageFlag = false;

    
    @track formData = {};
    @api metadataRecord;
    @api assetDetails = [];
    @api addressDetails = {};
    @api createrequestFlag;
    status;
    paymentMechanism;
    postCode;
    @api mprn;

    // ✨ NEW: Contact Site details (Title, Name, Number, Email)
    @track contactDetails = {
        title: '',
        name: '',
        contactNumber: '',
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
    @track investigationMessage = 'We will look to investigate and provide a response within the agreed 20 day SLA';
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

    @wire(getRecord, { recordId: '$userId', fields: FIELDS })
    userRecord({ error, data }) {
        if (data) {
            this.email = data.fields.Email.value;
            // Prefill contact email with the current user's email
            //this.contactDetails = { ...this.contactDetails, contactEmail: this.email };
        }
    }


    // 22 dec change

    

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

// --- Contact handlers & validation ---
handleTitleChange(event) {
  this.contactDetails.title = event.detail.value;
  if (this.contactDetails.title) {
    delete this.validationErrors.title;
    this.validationErrors = { ...this.validationErrors };
  }
}

handleContactInputChange(event) {
  const field = event.target.name;
  const value = event.detail?.value ?? event.target.value;
  this.contactDetails = { ...this.contactDetails, [field]: value };

  let errors = { ...this.validationErrors };
  if (field === 'contactNumber') {
    const trimmed = value ? value.trim() : "";
    const phonePattern = /^\d{11}$/;
    if (!trimmed) {
      errors.contactNumber = "Contact number is required.";
    } else if (!phonePattern.test(trimmed)) {
      errors.contactNumber = "Please enter a valid 11-digit contact number.";
    } else { delete errors.contactNumber; }
  }
  if (field === 'name') {
    const trimmed = value ? value.trim() : "";
    if (!trimmed) {
      errors.name = "Name is required.";
    } else if (trimmed.length > 30) {
      errors.name = "Name cannot exceed 30 characters.";
    } else { delete errors.name; }
  }
  this.validationErrors = errors;
}

// 6 jan change


// Hard cap for Additional Information
MAX_ADDITIONAL_INFO = 1000;

  // Where the 1000-char cap applies

// Where the 1000-char cap applies
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

  // 14 jan change


  
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
      isAdhoc = label === 'ad-hoc' || label.includes('ad-hoc');
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

  // 14 jan change end here

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

// 6 jan change end here

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
  let ok = true;
  const errors = { ...this.validationErrors };

  if (!this.contactDetails.title) { errors.title = "Title is required."; ok = false; }
  else { delete errors.title; }

  const name = (this.contactDetails.name || "").trim();
  if (!name) { errors.name = "Name is required."; ok = false; }
  else if (name.length > 30) { errors.name = "Name cannot exceed 30 characters."; ok = false; }
  else { delete errors.name; }

  const phone = (this.contactDetails.contactNumber || "").trim();
  if (!/^\d{11}$/.test(phone)) { errors.contactNumber = "Please enter a valid 11-digit contact number."; ok = false; }
  else { delete errors.contactNumber; }

  const val = this.contactDetails.instructions || "";
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
constMaxFileSize = 5 * 1024 * 1024; // 5 MB

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
  this.fileError = "";
  if (!fileList || fileList.length === 0) return;

  const duplicateFiles = [];

  Array.from(fileList).forEach(file => {
    if (this.uploadedFiles.some(f => f.name === file.name)) {
      duplicateFiles.push(file.name);
      return;
    }
    if (file.size > this.constMaxFileSize) {
      const maxMB = (this.constMaxFileSize / 1024 / 1024).toFixed(0);
      this.showTemporaryError(`File "${file.name}" exceeds ${maxMB} MB limit.`);
      return;
    }
    const reader = new FileReader();
    reader.onload = e => {
      const base64Data = e.target.result.split(",")[1];
      const fileUI = {
        name: file.name,
        size: file.size,
        sizeDisplay: this.formatFileSize(file.size),
        isImage: file.type.startsWith("image/"),
        previewUrl: file.type.startsWith("image/") ? e.target.result : null
      };
      const filePayload = {
        name: file.name,
        type: file.type,
        size: file.size,
        base64: base64Data
      };
      this.uploadedFiles = [...this.uploadedFiles, fileUI];
      this.uploadedFilePayload = [...this.uploadedFilePayload, filePayload];
    };
    reader.readAsDataURL(file);
  });

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
  const name = event.currentTarget.dataset.name;
  this.uploadedFiles = this.uploadedFiles.filter(f => f.name !== name);
  this.uploadedFilePayload = this.uploadedFilePayload.filter(f => f.name !== name);
}
formatFileSize(bytes) {
  if (bytes < 1024) return `${bytes} B`;
  else if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  else return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

  
    


// 22 dec change end here

   instructionMap = {
        FOU: 'Found Meter that is not recorded on your system. MSN **************, Manufacturer******, Model*******,  Installed on DD/MM/YY. Please investigate.',
        adhoc: 'Instruction: Provide additional context...',
        ADQ: 'Instruction: Ensure asset details are accurate...',
        DUM1: 'An exchange took place DD/MM/YY, Old MSN was ************** final read was *****. The new MSN is **************, New Manufacturer ********, New Model**********,  new read *****.',
        MRV: 'MSN ************** was removed on DD/MM/YY with a final read of ***** by/because *****************. Please investigate',
        CAA: 'The current address is incorrect. Please amend to: (provide new address details).',
        CRO: 'Please include ALL MPRNs, addresses and asset details for each crossed MPRN',
        REP: 'We have had confirmation from the GT that our MPRN********** is a duplicate of MPRN********** supplied by ***** please remove the meter from our MPRN to allow voluntary withdrawal Date **/**/**** read****. Please note that the supplier must first contact the GT to establish if a replicate situation exists, following this the query submitted to National Gas Metering must state the GTs findings. If the supplier fails to state that they have approached the GT National Gas Metering will reject the query back to the supplier.',
        CFU: 'We believe the correction factor to be incorrect. It should be ***** based on the annual consumption ******** and ********.',
        DUM2: 'The asset details currently held by you are incorrect. The correct details are: MSN **************.,Model*****,YOM******,Manufacturer*******,Meter type*********,Payment method*******. Please investigate.',
        CRM: 'MSN ************** has severe corrosion. Please see attached photo and arrange a site visit to replace the meter.',
        MUOP: 'MSN ************** is under/over (delete as required) pulsing. This has been confirmed from the AMR / converter data.',
        MNR: 'MSN ************** is not registering consumption, gas is being used. Please arrange a site visit to replace the meter.',
        FMB: 'MSN ************** is not fixed to the bracket and needs to be secured. No deliberate damage has been caused. Please rectify.',
        WOMS: 'MSN ************** has water/condensation in the screen. Please see attached photo and arrange a site visit to replace the meter.',
        BSM: 'MSN ************** has a blank screen. Gas is being used. Please arrange a site visit to replace the meter.',
        
        LBC: 'CSN***** is showing a low battery warning. Gas is being used. Please arrange a site visit to replace the converter battery.',
        CROS: 'CSN***** reads are out of sync with the meter/AMR equipment. Please arrange a site visit to rectify.',
    CXPC: 'CSN***** is not pulsing correctly as confirmed by the AMR / converter data. Please arrange a site visit and investigate.',
    DUM5: 'Our customer states that the Asset status is different to what it shows in Maximo. Maximo shows it as **. However our customer states that is ** and has been since **/**/****. Please Investigate. Additional Information This Query code should only be used for meters that are still on site and not removed meters, this type of Query should be submitted using the ADQ code. The Asset status codes that can be challenged are LI, CA, CL, CU, SP and RT.',
    COQ: 'The Convertor for this site is currently set incorrectly. We believe it should be ***** based on the following information ********'
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
            { label: 'Annual Consumption', placeholder: 'Enter Annual Consumption' },
            { label: 'From (box) to (box)', placeholder: 'Enter From (box) to (box)' }
            
        ],

        DUM5:  [
            { label: 'Maximo Asset Status', placeholder: 'Enter Maximo Asset Status' },
            { label: 'Customer Asset Status', placeholder: 'Enter Customer Asset Status' },
            { label: 'Customer Status Date', placeholder: 'Enter Customer Status Date' }
            
        ],

        CRM:  [
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
           
            
        ],

        REP: [
            { label: 'MPRN', placeholder: 'Enter MPRN' },
            { label: 'Duplicate MPRN', placeholder: 'Enter Duplicate MPRN' },
            { label: 'Duplicate MPRN supplier', placeholder: 'Enter Duplicate MPRN supplier' },
            { label: 'Meter Removal Date', placeholder: 'Enter Meter Removal Date' },
            { label: 'Removal Reading', placeholder: 'Enter Removal Reading' },
                  
        ],
    };

    // Dynamic fields getter
    // get dynamicFields() {

        
    //     if (this.enquiryFieldsMap[this.selectedReason]) {
    //         return this.enquiryFieldsMap[this.selectedReason];
    //     }
    //     if (this.enquiryFieldsMap[this.selectedAssetReason]) {
    //         return this.enquiryFieldsMap[this.selectedAssetReason];
    //     }

    //     if (this.enquiryFieldsMap[this.selectedAssetIssue]) {
    //         return this.enquiryFieldsMap[this.selectedAssetIssue];
    //     }

       
    //     return [];
    // }

    // 21 jan change for calender

    
// Dynamic fields getter (augmented with flags)

// 22 jan change

    get dynamicFields() {
  const base =
    this.enquiryFieldsMap[this.selectedReason] ||
    this.enquiryFieldsMap[this.selectedAssetReason] ||
    this.enquiryFieldsMap[this.selectedAssetIssue] ||
    [];

  return base.map(f => {
    const label = (f.label || '').trim().toLowerCase();
    return {
      ...f,
      isremovaldate:   label === 'removal date',           // (already used in MRV)
      isexchangedate:  label === 'exchange date',          // (already used in DUM1)
      iscuststatusdate:label === 'customer status date',   // DUM5
      ismeterremovaldate: label === 'meter removal date',  // REP
      isinstallationdate: label === 'installation date'    // FOU
    };
  });
}

    
// -- Min-date getters (undefined = allow past/present/future) --
get computedMinDateForDum5() { return this.isdum5 ? undefined : this.todayIso; }
get computedMinDateForRep()  { return this.isrep  ? undefined : this.todayIso; }
get computedMinDateForFou()  { return this.isfou  ? undefined : this.todayIso; }

// Helper: today in YYYY-MM-DD (used as default elsewhere if you want)
get todayIso() {
  const t = new Date();
  const y = t.getFullYear();
  const m = String(t.getMonth() + 1).padStart(2, '0');
  const d = String(t.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

    
get dum5Key() { return `dum5-${this.formData?.custStatusDateIso || ''}`; }
get repKey()  { return `rep-${this.formData?.meterRemovalDateIso || ''}`; }
get fouKey()  { return `fou-${this.formData?.installationDateIso || ''}`; }

    
// Utility: ISO -> DD/MM/YYYY
formatIsoToDdMmYyyy(iso) {
  const d = new Date(iso);
  const dd = String(d.getDate()).padStart(2, '0');
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const yyyy = d.getFullYear();
  return `${dd}/${mm}/${yyyy}`;
}

// DUM5 – Customer Status Date
handleDum5DateSelected(event) {
  const iso = event.detail?.value;
  if (!iso) return;
  const formatted = this.formatIsoToDdMmYyyy(iso);
  this.formData = { ...this.formData, ['Customer Status Date']: formatted, custStatusDateIso: iso };
  const err = this.template.querySelector('[data-error-for="Customer Status Date"]');
  if (err) err.hidden = true;
}

// REP – Meter Removal Date
handleRepDateSelected(event) {
  const iso = event.detail?.value;
  if (!iso) return;
  const formatted = this.formatIsoToDdMmYyyy(iso);
  this.formData = { ...this.formData, ['Meter Removal Date']: formatted, meterRemovalDateIso: iso };
  const err = this.template.querySelector('[data-error-for="Meter Removal Date"]');
  if (err) err.hidden = true;
}

// FOU – Installation Date
handleFouDateSelected(event) {
  const iso = event.detail?.value;
  if (!iso) return;
  const formatted = this.formatIsoToDdMmYyyy(iso);
  this.formData = { ...this.formData, ['Installation Date']: formatted, installationDateIso: iso };
  const err = this.template.querySelector('[data-error-for="Installation Date"]');
  if (err) err.hidden = true;
}


  // 22 jan change end here

    
handleMissingDateSelected(event) {
  const iso = event.detail?.value;
  if (!iso) return;

  const d = new Date(iso);
  const dd = String(d.getDate()).padStart(2, '0');
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const yyyy = d.getFullYear();
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
        console.log('Main Query Selected:', this.selectedMainQuery);

           
        


    }
    get showDateQuerySection() { return this.selectedMainQuery === 'AST'; }
    get showAssetDataOptions() { return this.selectedReason === 'ADQ'; }
    get showTechnicalQuerySection() { return this.selectedMainQuery === 'TQUERY'; }

    // 9 feb change
get isTechnicalQuery() {
  return this.selectedMainQuery === 'TQUERY';
}

  // 9 feb change end here
    get isMeterSelected() { return this.selectedAssetType === 'MET'; }
    get isConverterSelected() { return this.selectedAssetType === 'CON'; }
    get showEnquiryForm() {
        return (
            (this.selectedReason && this.selectedReason !== 'ADQ')
            || this.selectedAssetReason
            || this.selectedAssetIssue
        );
    }

    // 22 dec change

    



    
resetFormForSelection() {

  // 5 jan change

  
// Keep state aligned with UI
this.formData.visitSite = null;
this.formData.riskAssessment = null;
this.formData.converterIssue = null;
this.formData.meterIssue = null;

// 5 jan change end here
  // Clear all sub-selections
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
// 22 dec change end here

   
    // 5 january change

    // Existing input change (keep single reactive version)
    

handleInputChange(event) {
    // Resolve the field key from data-field or name
    const field = event.target.dataset.field || event.target.name;
    if (!field) return;

    // Read value correctly for both Lightning base components and plain inputs
    const value = (event.detail && event.detail.value !== undefined)
        ? event.detail.value
        : event.target.value;

        // 6 jan change

        
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
// 6 jan change end here

    // Persist to formData (single update, no undefined overwrites)
  //  this.formData = { ...this.formData, [field]: value };   // 6 jan change comment that part
    console.log('Updated formData:', JSON.stringify(this.formData));

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

// 5  jan change end here


    }

    // 5 jan change

    
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

// 5 jan change end here

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

    // 9 feb change

    
get showApptDateAsterisk() {
  const isMeterOrConverter = (this.selectedAssetType === 'MET' || this.selectedAssetType === 'CON');
  return this.showAppointmentFields && this.isTechnicalQuery && isMeterOrConverter;
}

  // 9 feb change end here

    renderedCallback() {
        console.log('selectedMainQueryvalue:', this.selectedMainQueryvalue);
        if (this.selectedMainQueryvalue) {
            this.handleMainQueryChange();
        }
    }

    async connectedCallback() {
        console.log("Address : ", JSON.stringify(this.addressDetails));
        console.log("Asset: ", JSON.stringify(this.assetDetails));
        console.log("createjobrequestFlag: ", this.createrequestFlag);

        this.postCode = this.addressDetails.postCode;
        this.buildingNumber = this.addressDetails.buildingNumber;
        this.buildingName = this.addressDetails.buildingName;
        this.street = this.addressDetails.street;
        this.postalTown = this.addressDetails.postalTown;
        this.dependentLocality = this.addressDetails.dependentLocality;

        console.log("Metadata Record: ", JSON.stringify(this.metadataRecord));
        console.log("Status: ", this.status);
        console.log("Payment Mechanism: ", this.paymentMechanism);
        console.log('postCode: ', this.postCode);
        console.log('MPRN: ', this.mprn);

    //   this.suppliercode = this.metadataRecord[0].suppliercode;

    if (this.metadataRecord && this.metadataRecord.length > 0 && this.metadataRecord[0].suppliercode) {
        this.suppliercode = this.metadataRecord[0].suppliercode;
    } else if (this.metadataRecord && this.metadataRecord.suppliercode) {
      this.suppliercode = this.metadataRecord.suppliercode;
    }
    console.log("suppliercode: ", this.suppliercode);
        await this.fetchEnquiryCodes();

        if (this.selectedMainQueryvalue) {
            this.handleMainQueryChange();
        }
        console.log('Enquiry codes: ', this.enquiryCodes);
    }

    async fetchEnquiryCodes() {
        try {
            const data = await getAllEnquiryCodes({});
            console.log('Enquiry codes: ', data);
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
                if (category === 'Technical Query' && subCategory && !assetTypeLabels.has(subCategory) && !reason && !reasonCode) {
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

            console.log('this.mainQueryOptions: ', JSON.stringify(this.mainQueryOptions));
            console.log('this.dateQueryReasons: ', JSON.stringify(this.dateQueryReasons));
            console.log('this.assetTypeOptions: ', JSON.stringify(this.assetTypeOptions));
            console.log('this.assetDataReasons: ', JSON.stringify(this.assetDataReasons));
            console.log('this.meterIssues: ', JSON.stringify(this.meterIssues));
            console.log('this.converterIssues: ', JSON.stringify(this.converterIssues));
        } catch (error) {
            console.error('Error fetching enquiry codes: ', JSON.stringify(error));
        }
    }

    // 22 dec change

    
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
// 22 dec change end here

    // (Keep your highlightSelected/other handlers as-is)

    handleReasonChange(event) {
        // this.selectedReason = event.target.value;
        // this.dateQueryReasons.forEach(r => r.isChecked = (r.value === this.selectedReason));
        this.selectedReason = event.target.value;

      this.dateQueryReasons = this.dateQueryReasons.map(r => ({
        ...r,
        isChecked: r.value === this.selectedReason,
        isSelected: r.value === this.selectedReason
      }));

    


        this.instructionText = this.instructionMap[this.selectedReason] || '';
    
        this.formData = {};
    }
    handleAssetReasonChange(event) {
        this.selectedAssetReason = event.target.value;
      this.assetDataReasons = this.assetDataReasons.map(r => ({
        ...r,
        isChecked: r.value === this.selectedAssetReason,
        isSelected: r.value === this.selectedAssetReason
      }));

        this.instructionText = this.instructionMap[this.selectedAssetReason] || '';
        this.formData = {};
        
    }
    // handleAssetTypeChange(event) {
    //     this.selectedAssetType = event.target.value;
    //     this.assetTypeOptions.forEach(t => t.isChecked = (t.value === this.selectedAssetType));
    //     this.selectedAssetIssue = '';       
    //     this.instructionText = '';
    //     this.formData = {};
    // }

    handleAssetTypeChange(event) {
        this.selectedAssetType = event.target.value;

  this.assetTypeOptions = this.assetTypeOptions.map(t => ({
    ...t,
    isChecked: t.value === this.selectedAssetType,
    isSelected: t.value === this.selectedAssetType
  }));

  this.selectedAssetIssue = '';
  this.instructionText = '';
  this.formData = {};
}

    // handleAssetIssueChange(event) {
    //     this.selectedAssetIssue = event.target.value;

           
          
       
    //     this.instructionText = this.instructionMap[this.selectedAssetIssue] || '';

        


    //     this.formData = {};
    // }

//     handleAssetIssueChange(event) {
//       this.selectedAssetIssue = event.target.value;

//       this.meterIssues = this.meterIssues.map(issue => ({
//         ...issue,
//         isChecked: issue.value === this.selectedAssetIssue,
//         isSelected: issue.value === this.selectedAssetIssue
//       }));

//       this.instructionText =
//         this.instructionMap[this.selectedAssetIssue] || '';

//       this.formData = {};
// }


    handleAssetIssueChange(event) {
  const selectedValue = event.target.value;
  const groupName = event.target.name;

  this.selectedAssetIssue = selectedValue;

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
    this.instructionMap[selectedValue] || '';

  this.formData = {};
}
        


    async handleSubmit(event) {
        console.log('Inside handleSubmit');
        console.log('this.consent: ',this.consent);

        if((this.selectedAssetIssue == 'CRM' || this.selectedAssetIssue == 'FMB' || this.selectedAssetIssue =='WOMS' ) && this.uploadedFilePayload?.length == 0 ){
          this.FileUploadmessage = 'Please Upload a File to continue';
          this.FileUploadmessageFlag = true;
          return;
        }
        if(this.consent == true){
            this.consentMessage = '';
            this.consentMessageFlag = false;

            this.FileUploadmessage = '';
          this.FileUploadmessageFlag = false;
    
        console.log('Form submitted:', JSON.stringify(this.formData));
        console.log('MSN: ', this.formData["MSN"]);
        event.preventDefault();
        this.isLoading = true;

        // 22 dec change

        

        
 // 1) Validate Contact Site (add your other field validations here if any)
  
// If you also validate contact site:
  const contactOk = this.validateContactSite ? this.validateContactSite() : true;


        
// Required fields in AST/TQUERY sub-types
  const formOk = this.validateBeforeSubmit();


  if (!contactOk) {
    this.isLoading = false;
    return;
  }


  // 22 dec change end here

  // 4 feb change for validation

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

  // 4 feb change end here for validation

  // 2 feb change for required issue
  // Block submission when any field/radio validation fails
 if (!formOk) {
   this.isLoading = false;
   return;
 }
 // 2 feb change end here
       
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

        console.log('instructionType: ', instructionType);
        console.log('this.metadataRecord: ',this.metadataRecord);
        //console.log('Sectorcode: ', this.metadataRecord[0].metadatalist[0].NGMCP_Market_Sector_Code__c);
        console.log('location: ', this.mprn.replace(/-.*/, "").trim());
        console.log('this.instructionText: ', this.instructionText);
        this.descriptionText = this.handleInstruction(instructionType);
        console.log('this.descriptionText: ', this.descriptionText);
    if (this.formData.additionalInfo != null && this.formData.additionalInfo != '' && this.formData.additionalInfo != undefined) {
            this.descriptionText = this.descriptionText + 'Addition Info : ' + this.formData.additionalInfo;
        }
        console.log('this.descriptionText: ', this.descriptionText);
        console.log('assetDetails: ', JSON.stringify(this.assetDetails));
        
        const assetObj = this.assetDetails.reduce((acc, item) => {
            acc[item.label] = item.value;
            return acc;
        }, {});

        console.log('assetObj: ', assetObj);

        //  Include Contact Site details in payload
        const payload = {
            ngme_consname: this.contactDetails.name,
            reason: this.selectedReason == 'ADQ' ? this.selectedAssetReason : this.selectedAssetIssue,
            loccode: '',
            bldgname: this.buildingName,
            sectorcode: this.metadataRecord && this.metadataRecord.length > 0 && this.metadataRecord[0].metadatalist && this.metadataRecord[0].metadatalist.length > 0 && this.metadataRecord[0].metadatalist[0].NGMCP_Market_Sector_Code__c ? this.metadataRecord[0].metadatalist[0].NGMCP_Market_Sector_Code__c : this.metadataRecord && this.metadataRecord.metadatalist && this.metadataRecord.metadatalist.length > 0 && this.metadataRecord.metadatalist[0].NGMCP_Market_Sector_Code__c ? this.metadataRecord.metadatalist[0].NGMCP_Market_Sector_Code__c : '',
            street: this.street,
            supplier: this.suppliercode,
            notif_type: this.selectedMainQuery == 'AST' ? 'DQ' : 'TQ',
            ngme_riskassess: this.formData.riskAssessment == 'Yes' ? 'Y' : 'N',
            posttown: this.postalTown,
            ngme_constitle: this.contactDetails.title,               // ✅ Title
            description_longdescription: this.descriptionText,
            ngme_engvisit: this.formData.visitSite == 'Yes' ? 'Y' : 'N',
            targetstart: this.formData.appointmentDate,
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
        console.log('Payload submitted:', JSON.stringify(payload));
        //console.log('this.formData["Manufacturer Model"]: ',this.formData["Manufacturer Model"]);
        //console.log('this.formData["New Model"]: ',this.formData["New Model"]);//this.formData["MSN"]
        this.meterDetails.NGMCP_Model__c = assetObj["Model"];//this.formData["Manufacturer Model"] != null && this.formData["Manufacturer Model"] != '' && this.formData["Manufacturer Model"] != undefined ? this.formData["Manufacturer Model"] : this.formData["New Model"] != null && this.formData["New Model"] != '' && this.formData["New Model"] != undefined ? this.formData["New Model"] : '';
        this.meterDetails.NGMCP_Manufacturer_Serial_No__c = assetObj["Manufacturer Serial no."];//this.formData["MSN"] != null && this.formData["MSN"] != '' && this.formData["MSN"] != undefined ? this.formData["MSN"] : this.formData["New MSN"] != null && this.formData["New MSN"] != '' && this.formData["New MSN"] != undefined ? this.formData["New MSN"] : '';
        this.meterDetails.NGMCP_Meter_Type__c = assetObj["Meter Type"];
        this.meterDetails.NGMCP_Payment_Mechanism__c = assetObj["Payment Mechanism"];
        this.meterDetails.NGMCP_Year_of_Manufacture__c = assetObj["Year of Manufacture"];
        console.log('meterDetails: ', this.meterDetails);
        try {
            const requestRecordId = await createDataQueryRecord({
                requestBody: JSON.stringify(payload),
                meterDetails: this.meterDetails
            });
            console.log(' Request Record ID:', requestRecordId);

            if (requestRecordId) {


              if (this.uploadedFilePayload?.length > 0) {
                      const isUploaded = await uploadFiles({
                        recordId: requestRecordId,
                        files: JSON.stringify(this.uploadedFilePayload)
                      });
                      console.log('isUploaded: ', isUploaded);
                      if (!isUploaded) {
                        console.error('File upload failed');
                        return;
                      }
                    }
                const response = await submitDataQuery({
                    requestBody: JSON.stringify(payload),
                    requestId: requestRecordId
                });
                console.log(' Apex response:', response);
                const parsed = typeof response === "string" ? JSON.parse(response) : response;
                console.log(' parsed response:', parsed);
                if (parsed?.ticketid) {
                    const doctype = this.selectedMainQuery == 'AST' ? 'AQD' : 'FMD';
                    console.log('doctype: ', doctype);
                    if (this.uploadedFilePayload?.length > 0) {
                                                uploadtoMAximoSystem({
                                                  files: JSON.stringify(this.uploadedFilePayload),
                                                  srticket: parsed.ticketid,
                                                  uid: parsed.ticketuid,
                                                  doctype: doctype
                                                })
                                                  .then(result1 => {
                                                    console.log('result1: ', result1);
                                                    this.isModal = true;
                                                    const enquiryType = this.selectedMainQuery == 'AST' ? 'Data Query' : 'Technical Query';
                                                    this.successMessage = 'Your ' + enquiryType + ' has been successfully submitted on the '
                                                    this.serviceTicketid = 'The reference number is ';
                                                    this.srNumber = parsed.ticketid;
                                                    if (enquiryType == 'Technical Query' &&
                                                      this.formData.appointmentDate != null && this.formData.appointmentDate != '' && this.formData.appointmentDate != undefined && 
                                                      this.formData.appointmentTimeslot != null && this.formData.appointmentTimeslot != '' && this.formData.appointmentTimeslot != undefined 
                                                    ) {
                                                      const slots = this.formData.appointmentTimeslot.split('-');
                                                      console.log('slots: ', slots);
                                                      //An engineer will visit on 22/12/2025 during the appointment slot between 08:00 and 12:00
                                                      this.engineerVisitMessage = 'An engineer will visit on ' + this.formatDateToDDMMYYYY(new Date(this.formData.appointmentDate)) + ' during the appointment slot between ' + slots[0] + ' and ' + slots[1]
                                                      console.log('engineerVisitMessage: ', this.engineerVisitMessage)
                                                      
                                                      this.engineerVisitMessageFlag = true;
                                                    }
                                                    else {
                                                      this.engineerVisitMessageFlag = false;
                                                      this.engineerVisitMessage = '';
                                                    }
                                                    this.submittedDate = this.formatDateToDDMMYYYY(new Date());
                                                })
                                                .catch(error => {
                                                    console.log('error at upload: ', JSON.stringify(error));
                                                    
                                                    alert('Something went wrong while submitting the request.');
                                                });
                    }
                    else {
                    this.isModal = true;
                    const enquiryType = this.selectedMainQuery == 'AST' ? 'Data Query' : 'Technical Query';
                    this.successMessage = 'Your ' + enquiryType + ' has been successfully submitted on the '
                    this.serviceTicketid = 'The reference number is ';
                    this.srNumber = parsed.ticketid;
                    if (enquiryType == 'Technical Query' &&
                      this.formData.appointmentDate != null && this.formData.appointmentDate != '' && this.formData.appointmentDate != undefined && 
                      this.formData.appointmentTimeslot != null && this.formData.appointmentTimeslot != '' && this.formData.appointmentTimeslot != undefined 
                    ) {
                      const slots = this.formData.appointmentTimeslot.split('-');
                      console.log('slots: ', slots);
                      //An engineer will visit on 22/12/2025 during the appointment slot between 08:00 and 12:00
                      this.engineerVisitMessage = 'An engineer will visit on ' + this.formatDateToDDMMYYYY(new Date(this.formData.appointmentDate)) + ' during the appointment slot between ' + slots[0] + ' and ' + slots[1]
                      console.log('engineerVisitMessage: ', this.engineerVisitMessage)
                      
                      this.engineerVisitMessageFlag = true;
                    }
                    else {
                      this.engineerVisitMessageFlag = false;
                      this.engineerVisitMessage = '';
                    }
                    this.submittedDate = this.formatDateToDDMMYYYY(new Date());
                  }
                }
            } else {
                console.warn(' No request record ID returned.');
            }
        } catch (error) {
            console.error('Error during Apex callout:', error);
            console.error('error:', JSON.stringify(error));
            alert('Something went wrong while submitting the request.');
        } finally {
            this.isLoading = false;
            console.log('Submission process completed.');
        }
      }
      if(this.consent == false){

      
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

    const empty = !value || !String(value).trim();
    const errEl = this.template.querySelector(
      `[data-error-for="${CSS.escape(field)}"]`
    );

    if (empty) {
      allValid = false;
      firstInvalidEl = firstInvalidEl || inp;
      inp.classList.add('invalid');
      if (errEl) errEl.hidden = false;
    } else {
      inp.classList.remove('invalid');
      if (errEl) errEl.hidden = true;
    }
  });

  // 6 jan change

  
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

// 6 jan change end here

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
// 22 dec change end here

// 22 dec change



/**
 * Hide every inline error and remove invalid outline from all inputs.
 * Optionally scope to a container if you prefer (e.g., dynamic fields card).
 */
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

/**
 * Plain-input typing handler: clears all errors, updates formData,
 * and optionally re-checks the current field.
 */

  // 13 jan change


  // get showSampleInstruction() {
  //   // Treat Ad-hoc as having NO instruction
  //   const isAdhoc =
  //     this.selectedReason === 'adhoc' || this.selectedAssetReason === 'adhoc';
  //   return !isAdhoc && !!this.instructionText;
  // }





  // 13 jan change end

handlePlainTyping(event) {
  // Resolve field key
  const field = event.target.dataset.field || event.target.name;
  if (!field) return;

  // Read value from plain inputs/selects/textareas
  const value = event.target.value ?? '';

  // Update formData immediately
  this.formData = { ...this.formData, [field]: value };

  // Determine emptiness
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
        // Optionally clear contact details as well:
        // this.contactDetails = { title: '', name: '', contactNumber: '', contactEmail: this.email || '' };
    }

      handleInstruction(instruction) {
        // (unchanged – your existing message builder)
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
                message = 'An exchange took place ' + this.formData["Exchange Date"] + ', Old MSN was ' + this.formData["Old MSN"] + ' final read was ' + this.formData["Old Index"] + '. The new MSN is ' + this.formData["New MSN"] + ' new read ' + this.formData["New Index"] + '. ';
                break;
            case 'MRV':
                message = 'MSN ' + this.formData["Old MSN"] + ' was removed on ' + this.formData["Removal Date"] + ' with a final read of ' + this.formData["Old Index"] + ' by/because ***************. Please investigate ';
                break;
            case 'CFU':
                message = 'We believe the correction factor to be incorrect. It should be **** based on the annual consumption ******** and ********. ';
                break;
            case 'DUM2':
                message = 'The asset details currently held by you are incorrect. The correct details are: MSN **************.,Model*****,YOM******,Manufacturer*******,Meter type*********,Payment method*******. Please investigate. ';
                break;
            case 'CRM':
                message = 'MSN ' + this.formData["Meter Serial Number"] + ' has severe corrosion. Please see attached photo and arrange a site visit to replace the meter. ';
                break;
            case 'MUOP':
                message = 'MSN ' + this.formData["Meter Serial Number"] + ' is under/over (delete as required) pulsing. This has been confirmed from the AMR / converter data. ';
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
            case 'CROS':
                message = 'CSN ' + this.formData["Converter Serial Number"] + ' reads are out of sync with the meter/AMR equipment. Please arrange a site visit to rectify.'
                break;
            case 'CXPC': 
                message = 'CSN ' + this.formData["Converter Serial Number"] + ' is not pulsing correctly as confirmed by the AMR / converter data. Please arrange a site visit and investigate. '
                break;
            case 'CAA':
                message = 'The current address is incorrect. Please amend to: ' + this.formData["Building Name"] + ', ' + this.formData["Building Number"] + ', ' + this.formData["Street"] + ', ' + this.formData["Dependent Locality"] + ', ' + this.formData["Postal Town"] + ', ' + this.formData["Postal Code"] + '. '
                break;
            case 'CRO':
                message = 'MPRN: ' + this.formData["MPRN"] + ', Address Detail: ' + this.formData["Address Detail"] + ', Meter Detail: ' + this.formData["Meter Detail"] + '. '
                break;
            case 'DUM5':
                message = 'Our customer states that the Asset status is different to what it shows in Maximo. Maximo shows it as  ' + this.formData["Maximo Asset Status"] + '. However our customer states that is ' + this.formData["Customer Asset Status"] + '  and has been since ' + this.formData["Customer Status Date"] + ' . Please Investigate. Additional Information This Query code should only be used for meters that are still on site and not removed meters, this type of Query should be submitted using the ADQ code. The Asset status codes that can be challenged are LI, CA, CL, CU, SP and RT. '
                break;
            case 'COQ':
                message = 'The Convertor for this site is currently set incorrectly. We believe it should be ' + this.formData["Converter Serial Number"] + ' based on the following information ' + this.formData["Converter Model"] + '. '
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

  // 21 jan change here for calender

  
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


// 22 jan change

  
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


  // 22 jan change end here



get computedMinDateForRemoval() {
  // ✅ ALLOW ALL DATES only for MRV
  if (this.isMRV) return undefined;

  // default behavior (blocks past dates)
  const t = new Date();
  return `${t.getFullYear()}-${String(t.getMonth()+1).padStart(2,'0')}-${String(t.getDate()).padStart(2,'0')}`;
}



  
get computedMaxDateForRemoval() {
  return this.isMRV ? undefined : this.maxDate; // or your usual rule
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


  // 21 jan change end here for calender

  

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

        console.log('UI files:', JSON.stringify(this.uploadedFiles));
        console.log('Payload files:', JSON.stringify(this.uploadedFilePayload));
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
/*
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
    }*/
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

    handleConsentInputChange(event){
        this.consent = event.target.checked;
        console.log('this.consent: ',this.consent);
        if(event.target.checked == true){
            this.consentMessage = '';
            this.consentMessageFlag = false;
        }
        else{
            this.consentMessage = 'consent is required';
            this.consentMessageFlag = true;
        }
    }

   
}