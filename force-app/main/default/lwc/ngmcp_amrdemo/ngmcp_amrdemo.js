import { LightningElement, track, api, wire } from 'lwc';
import getPulsing from '@salesforce/apex/NGMCP_AmrPulsingService.getPulsing';  // 8 jan change
import submitAMR from "@salesforce/apex/NGMCP_AMRIntegrationClass.submitAMR";
import createAMR from "@salesforce/apex/NGMCP_AMRIntegrationClass.createAMR";
import getSupplierInfo from "@salesforce/apex/NGMCP_AppointmentDeappointmentHandler.getSupplierInfo";
import validateDeuplicateRequest from '@salesforce/apex/NGMCP_WorkRequestController.validateDeuplicateRequest';
//import createUrgentWorkRequestRecord from "@salesforce/apex/NGMCP_RequestObjectClass.createUrgentWorkRequestRecord";
//import submitCreattWorkRequest from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.submitCreattWorkRequest";
import submitDataQuery from "@salesforce/apex/NGMCP_EnquiriesHandler.submitDataQuery";
import createDataQueryRecord from "@salesforce/apex/NGMCP_EnquiriesHandler.createDataQueryRecord";
const MAX_FILE_SIZE = 10 * 1024 * 1024;
import getRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.getRequest";
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
const USER_FIELDS = ['User.Name', 'User.Email'];
export default class NgmcpAmrRequestComponent extends LightningElement {
  @track selectedType = null;
  @track selectedTypeLabel = '';
  @track selectedSubType = null;
  @track selectedSubTypeLabel = '';
  @track state = {};
  // 12 jan change
  // Fields that users must not be able to change from UI
  READ_ONLY_KEYS = new Set(['isPulsing']);
  // 8 jan change
  @track pulsingValue; // 'YES' or 'NO'
  @track shortCode;
  @track meterModel;
  @track meterYear;
  @track isPulsingDerived = false; // 13 feb change for pulsing
  @track msn;
  @track meterDials;
  @api supplierShortCode;
  // 10 feb change for consent message
  // --- Consent gating 
  @track consent = false;
  @track consentMessage = '';
  @track consentMessageFlag = false;
  @track duplicateMessage;
  // 10 feb change end here for consent message 
  // 8 jan change end here

  // ===== File state per subtype =====
  @track fileError = '';
  @track uploadedFilesBySubtype = {};   // { 'AMR_Install': [{ name, size, sizeDisplay, ... }], ... }
  uploadedPayloadBySubtype = {};        // { 'AMR_Install': [{ name, type, size, base64 }], ... }
  @api metadataRecord;
  @api assetDetails = [];
  @api addressDetails = {};
  @api mprn;
  postCode;
  postalTown;
  buildingName;
  buildingNumber;
  street;
  dependentLocality;
  suppliercode;
  supplierContract;
  address;
   @track isLoading = false;
   @track isModal = false;
    @track successMessage //= SUCCESS_MESSAGE;
    @track serviceTicketid //= SERVICETICKET_ID;
    @track srNumber;
    @track relatedSuccessMessage;
    @track relatedServiceTicketMessage;
    @track relatedSRnumber;
    paymentMechanism;
    meterType;
    userId = USER_ID;
    user;
    assetNum;
    industry;
    @api status;
    @api pressuretier;
    @api stateofWorkRequest;
    @track nonPulsingInstallorRemove = false;
  // 16 jan change
// ngmcpAmrRequestComponent.js
@api showInstallFieldsWhenNull = false; // <-- receives from parent
@api isResidentialU6Site; // <-- receives true/false/null from parent  // 6 feb change
get isInstall() {                       // you already have this in your file
  return this.selectedSubType?.id === 'AMR_Install';
}
//  Residential is NULL → only 2 fields
get showInstallOnlyForNull() {
    return this.isInstall && this.showInstallFieldsWhenNull;
}
//  Residential is Yes / No → normal Install flow
// 6 feb change
get showInstallNormal() {
    return this.isInstall && !this.hasExternalU6;
}
  // 6 feb change end here
  // 6 feb change
  // Show the "null-case Install" block when:
// - we are on Install, and
// - either NULL-case flag is on, or U6 is explicitly answered (true/false).
get showInstallNullBlock() {
    return this.isInstall && (this.hasExternalU6 || this.showInstallFieldsWhenNull);
}
    // Is this AMR component receiving the U6 value from a parent?
get hasExternalU6() {
    // When parent does NOT bind the prop, it remains undefined (standalone use)
    return this.isResidentialU6Site !== undefined;
}
  // 6 feb change end here
// --- OPTIONS ---
// 13 feb change for pulsing
get yesNoOptions() {
  return [
    { label: 'Yes', value: 'YES' },
    { label: 'No',  value: 'NO'  }
  ];
}
// 13 feb change end here for pulsing
get serviceLevelOptions() {
  return [
      { label: 'Platinum(P)', value: 'Platinum(P)' },
      { label: 'Copper(C)', value: 'Copper(C)' },
      { label: 'Bronze(B)', value: 'Bronze(B)' },
    { label: 'Silver Class(T)', value: 'Silver Class(T)' }
  ];
}
get meterUomOptions() {
  return [
    { label: 'SCMH', value: 'SCMH' },
    { label: 'SCFH', value: 'SCFH' }
  ];
}
// Title options (used in both templates)
get titleOptions() {
  return [
    { label: 'Mr', value: 'Mr' },
    { label: 'Ms', value: 'Ms' },
    { label: 'Mrs', value: 'Mrs' },
    { label: 'Miss', value: 'Miss' },
    { label: 'Dr', value: 'Dr' },
    { label: 'Company', value: 'Company' }
  ];
}

    get serviceLevelHelp() {
  return [
    'Platinum – daily delivery of readings plus half hourly consumption data',
    'Copper – daily delivery of readings plus hourly consumption data',
    'Gold – four deliveries per month of daily readings plus hourly consumption data',
    'Silver – two deliveries per month of daily readings',
    'Bronze – two deliveries per month of two meter readings only (middle and end of the month)'
  ].join('\n'); // line breaks inside the tooltip
}
// --- SHOW/HIDE Converter details (common for both templates) ---
get showConverterFields() {
  // show when Install AND user selected "Yes" on Converter Fitted Indicator
  return this.isInstall && this.state?.converterFitted === 'Yes';
}
  // 16 jan change end here
  jobTypeSubtypes = {
    AMR: [
      { label: 'Install', id: 'AMR_Install', description: 'Install AMR device on meter' },
      { label: 'Site Visit', id: 'AMR_SiteVisit', description: 'Visit site for AMR-related activity' },
      { label: 'Remove', id: 'AMR_Remove', description: 'Remove AMR device from meter' },
      { label: 'Stop', id: 'AMR_Stop', description: 'Stop AMR device from meter' },
    ]
  };
  // Template-safe class getters
  get typeCardClassAMR() {
    return `radio-card ${this.selectedTypeLabel === 'AMR' ? 'selected' : ''}`;
  }
  // get subTypesWithClass() {
  //   const base = this.jobTypeSubtypes['AMR'] || [];
  //   return base.map(s => ({
  //     ...s,
  //     cssClass: `radio-card ${this.selectedSubTypeLabel === s.label ? 'selected' : ''}`
  //   }));
  // }

  get subTypesWithClass() {
    const base = this.jobTypeSubtypes['AMR'] || [];
    return base.map(s => ({
      ...s,
    cssClass: `radio-card ${this.selectedSubTypeLabel === s.label ? 'selected' : ''}`,
    isSelected: this.selectedSubTypeLabel === s.label 
    }));
  }
  // Subtype helpers
  get isInstall() { return this.selectedSubType?.id === 'AMR_Install'; }
  get isSiteVisit() { return this.selectedSubType?.id === 'AMR_SiteVisit'; }
  get isRemove() { return this.selectedSubType?.id === 'AMR_Remove'; }
  get isStop() { return this.selectedSubType?.id === 'AMR_Stop'; }


  get showConverterFields() {
    return this.isInstall && this.state.converterFitted === 'Yes';
  }
  get isSelected() {
    return {
      serviceLevel: {
        Platinum: this.state.serviceLevel === 'Platinum(P)',
        Copper: this.state.serviceLevel === 'Copper(C)',
        Bronze: this.state.serviceLevel === 'Bronze(B)',
        Silver: this.state.serviceLevel === 'Silver Class(T)',
      },
      meterUom: {
        SCMH: this.state.meterUom === 'SCMH',
        SCFH: this.state.meterUom === 'SCFH',
      },
      converterFitted: {
        Yes: this.state.converterFitted === 'Yes',
        No: this.state.converterFitted === 'No',
      }
    };
  }

  // Convenience getter for current subtype file lists
  get currentSubtypeId() {
    console.log('this.selectedSubType?.id: ', this.selectedSubType?.id);
    //console.log('currentSubtypeId: ',currentSubtypeId);
    return this.selectedSubType?.id || '';
  }
  get uploadedFiles() {
    return this.uploadedFilesBySubtype[this.currentSubtypeId] || [];
  }
  get uploadedPayload() {
    return this.uploadedPayloadBySubtype[this.currentSubtypeId] || [];
  }
      // 15 jan change
get mamIdOptions() {
    return [
       
        { label: 'UNK Unknown', value: 'UNK Unknown' },
        { label: 'SGN - Scotia Gas Networks Ltd', value: 'SGN' },
        { label: 'UKMA - UK Meter Assets', value: 'UKMA' },
        { label: 'EAL - Energy Assets Ltd', value: 'EAL' },
        { label: 'ECA - SMS Meter Assets Ltd', value: 'ECA' },
        { label: 'MTX', value: 'MTX' },
        { label: 'ONS - Utility Metering Services Limited', value: 'ONS' },
        { label: 'DUM', value: 'DUM' },
        { label: 'GMT', value: 'GMT' },
        { label: 'EAL - Energy Assets Limited', value: 'EAL2' },
        { label: 'UKM - UK Power Networks Services (Contracting) Ltd', value: 'UKM' },
        { label: 'ECM - EDF Energy Customers Limited', value: 'ECM' },
        { label: 'PCM', value: 'PCM' },
        { label: 'SEL', value: 'SEL' },
        { label: 'CUST', value: 'CUST' },
        { label: 'GPL - GTC Pipelines Limited', value: 'GPL' },
        { label: 'GTC - Gas Transportation Company Limited', value: 'GTC' },
        { label: 'SSE - SSE Energy Supply Limited', value: 'SSE' },
        { label: 'EXO', value: 'EXO' },
        { label: 'ACV - Actavo Network Solutions (UK) Ltd', value: 'ACV' },
        { label: 'ASM - AES Smart Metering LTD', value: 'ASM' },
        { label: 'EPM - Amey Metering Limited', value: 'EPM' },
        { label: 'BGT - British Gas Trading Ltd', value: 'BGT' },
        { label: 'CUS - Customer Equipment', value: 'CUS' },
        { label: 'MEO - Eco Metering Solutions Limited', value: 'MEO' },
        { label: 'GUC - Last Mile Gas Limited', value: 'GUC' },
        { label: 'EML - Energy Metering Solutions Limited', value: 'EML' },
        { label: 'ESL - Eon UK Energy Services Limited', value: 'ESL' },
        { label: 'EPS - ES Pipelines Limited', value: 'EPS' },
        { label: 'EGS - Exoteric Smart Meters Ltd', value: 'EGS' },
        { label: 'FPL - Fulcrum Pipelines Limited', value: 'FPL' },
        { label: 'FMS - Future Metering Services Ltd', value: 'FMS' },
        { label: 'SEP - INDIGO PIPELINES LIMITED', value: 'SEP' },
        { label: 'LBG - Lowri Beck Services Limited', value: 'LBG' },
        { label: 'MUT - Magnum Utilities Ltd', value: 'MUT' },
        { label: 'MPS - Meter Plus Ltd', value: 'MPS' },
        { label: 'MFE - Meterfit North East Ltd', value: 'MFE' },
        { label: 'MFW - Meterfit North West Ltd', value: 'MFW' },
        { label: 'PGM - Morrison Data Services Limited', value: 'PGM' },
        { label: 'PRO - Providor Limited', value: 'PRO' },
        { label: 'SSU - SAS Utility Services Limited', value: 'SSU' },
        { label: 'SGM - SGN Commercial Services Ltd', value: 'SGM' },
        { label: 'SMS - Siemens Public Limited Company', value: 'SMS' },
        { label: 'SOE - Southern Energy Connections Ltd', value: 'SOE' },
        { label: 'SQU - Squire Energy Limited', value: 'SQU' },
        { label: 'SUF - Stark Utility Funding Limited', value: 'SUF' },
        { label: 'WML - Utilita Field Services', value: 'WML' }
    ];
}

@wire(getRecord, { recordId: '$userId', fields: USER_FIELDS })
    userRecord({ error, data }) {
        if (data) {
            
            this.user = data.fields;
            
            console.log('user: ', JSON.stringify(this.user));
        }
    }
  // 15 jan change end here
  // Type select
  handleTypeSelect(e) {
    console.log('AMR is called ');
    const label = e.target.value;
    console.log('AMR labekl check  ', label);

    if (this.selectedTypeLabel === label) {
    return;
  }
    this.selectedType = { label, id: label };
    this.selectedTypeLabel = label;

    // Reset subtype, fields, and any transient file error
    this.selectedSubType = null;
    this.selectedSubTypeLabel = '';
    this.state = {};
    this.fileError = '';
    console.log('AMR method end ');
  }
get isAMRSelected() {
  return this.selectedTypeLabel === 'AMR';
}
  // Subtype select
 async handleSubTypeSelect(e) {
    const label = e.target.value;
    const sub = (this.jobTypeSubtypes['AMR'] || []).find((s) => s.label === label);
    this.selectedSubType = sub || { label, id: `AMR_${label.replace(/\s+/g, '')}` };
    console.log('[AMR] Selected subtype inside handleSubTypeSelect:', this.selectedSubType);
    console.log('[AMR] Selected subtype inside handleSubTypeSelect:', JSON.stringify(this.selectedSubType));
    this.selectedSubTypeLabel = label;
    console.log('[AMR] selectedSubTypeLabel inside handleSubTypeSelect:', this.selectedSubTypeLabel);
    // 8 jan change

    const raw = (this.mprn || '').toString();
    const parts = raw.split('-').map(s => (s ? s.trim() : ''));
    const mprnvalue = parts[0] || '';       // "10140505"
    const supplier = parts[1] || '';   // "GLZ"
    const payloadObj = {
      recordTypeName: 'AMR',
      NGMCP_MPRN__c: mprnvalue,
      NGMCP_Supplier_Id__c: supplier,
      NGMCP_Job_Type__c: this.selectedSubType.id == 'AMR_Install' ? 'STRT' : this.selectedSubType.id == 'AMR_SiteVisit' ? 'SVST' : 'RMVE',
      NGMCP_Status__c: ['Closed', 'CANCELLED', 'Cancelled', 'Resolved', 'Rejected'] // NOT IN
    };
    console.log('payload' + JSON.stringify(payloadObj));
    // 3) Call Apex (expects String payload)
    const results = await validateDeuplicateRequest({
      payload: JSON.stringify(payloadObj)
    });
    if (results.length > 0) {
      console.log('result', JSON.stringify(results));
      this.isModal = true;
      this.duplicateMessage = 'Open request with Request Number -' + results[0].Name + ' and Service Request - ' + results[0].NGMCP_SR_Ticket__c + ' already exists for the same combination.';
      console.log('Open request with Request Number -' + results[0].Name + 'and Service Request - ' + results[0].NGMCP_SR_Ticket__c + 'already exists for the same combination');
      return;
    }
    // 13 feb change for pulsing
    // if (this.selectedSubType.id === 'AMR_Install') {
    //   this.resolvePulsing();
    // }
  // 13 feb change end here for pulsing

    // 8 jan change end here

    // Initialize state per subtype
    if (this.selectedSubType.id === 'AMR_Install') {
      this.state = {
        annualConsumption: '',
        serviceLevel: '',
        siteContactName: '',
        siteContactNumber: '',
        consumerEmail: '',
        accessInstructions: '',
        mamId: '',
        meterDials: '',
        meterYom: '',
        meterUom: '',
        meterReadingFactor: '',
        correctionFactor: '',
        converterFitted: '',
        converterSerial: '',
        converterDials: '',
        converterReadingFactor: '',
      //  isPulsing: ''                 // 8 jan change


      };

     
// Now resolve after state init
  await this.resolvePulsing();

  //  If still no value (no CMDT match / inputs missing), default to YES
  if (!this.state?.isPulsing) {
    this.state = { ...this.state, isPulsing: 'YES' };
  }
  // Ensure UI reflects final value on the first render of the Install section
  this.pulsingValue = this.state.isPulsing;   // keeps any lightning-radio-group in sync (harmless if none)

    Promise.resolve().then(() => this.syncPulsingRadios());

      console.log('[AMR] Init Install state:', JSON.stringify(this.state));


      // 8 jan change end here
    } else if (this.selectedSubType.id === 'AMR_SiteVisit') {
      this.state = {
        sv_siteContactName: '',
        sv_consumerEmail1: '',
        sv_consumerEmail2: '',
        sv_accessInstruction: '',
        sv_title: ''

      };
    } else if (this.selectedSubType.id === 'AMR_Remove') {
      this.state = {
        rm_siteContactName: '',
        rm_consumerEmail1: '',
        rm_consumerEmail2: '',
        sv_accessInstruction: '',
        sv_title: ''

      };


    } else if (this.selectedSubType.id === 'AMR_Stop') {
      this.state = {
        sv_siteContactName2: '',
        sv_consumerEmail1: '',
        sv_consumerEmail2: '',
        sv_accessInstruction4: '',
        sv_title: ''

      };


    } 
    else {
      this.state = {};
    }

    // Ensure file arrays exist for this subtype
    if (!this.uploadedFilesBySubtype[this.currentSubtypeId]) {
      this.uploadedFilesBySubtype = { ...this.uploadedFilesBySubtype, [this.currentSubtypeId]: [] };
    }
    if (!this.uploadedPayloadBySubtype[this.currentSubtypeId]) {
      this.uploadedPayloadBySubtype[this.currentSubtypeId] = [];
    }
    this.fileError = '';
  }

  
  
/**
 * Clear required message for a native radio group and remove the inline error.
 * @param {HTMLInputElement[]} group - array of radio inputs (same name)
 */
clearRadioGroupError(group) {
  if (!group || group.length === 0) return;

  // Clear browser validity on all radios in the group
   group.forEach(r => r.setCustomValidity(''));

  // Remove inline error (we anchored it to label or a dedicated span)
  // Try to remove from the "No" label (last visible radio) and from any placeholder span
  const visibleGroup = group.filter(r => r.offsetParent !== null && !r.disabled);
  const lastRadio = visibleGroup[visibleGroup.length - 1] || group[group.length - 1];

  // If we attached error to the label of the last radio:
  const lastLabel = lastRadio.closest('label') || lastRadio;
  this.clearInlineError(lastLabel);

  // If you used Option B (a dedicated slot):
  const container = lastRadio.closest('.horizontal-radio') || lastRadio.parentElement;
  const slot = container?.querySelector('.inline-error[data-error-for="converterFitted"]');
  if (slot) {
    slot.textContent = '';
    slot.style.display = 'none';
  }
}

  // 8 jan change


  get isPulsingYesChecked() { return this.state?.isPulsing === 'YES'; }
  get isPulsingNoChecked() { return this.state?.isPulsing === 'NO'; }

  // 8 jan change end here
  
// Helper: validate one native or lightning field and clear message if valid
validateAndClearSingleField(elOrCmp) {
  // Lightning base components
  if (elOrCmp && typeof elOrCmp.reportValidity === 'function' && !elOrCmp.tagName) {
    // Lightning component instance (e.g., lightning-input)
    elOrCmp.reportValidity(); // shows/clears built-in messages automatically
    return;
  }

  // Native HTML input/select/textarea
  const el = elOrCmp;
  if (!el) return;

  // Skip hidden/disabled
  if (el.offsetParent === null || el.disabled) return;

  const isRequired = el.hasAttribute('required') || el.getAttribute('aria-required') === 'true';
  const empty = !el.value || el.value.trim() === '';

  if (isRequired && empty) {
    el.setCustomValidity('This field is required');
  } else {
    el.setCustomValidity(''); // clears the required message
  }

  // Browser built-in checks for type="email"/"tel"/"number"/pattern/min/max
  const ok = el.reportValidity();

  // Inline fallback (if native popover is suppressed)
  if (ok) {
    this.clearInlineError(el);
  } else {
    this.showInlineError(el, el.validationMessage || 'This field is required');
  }
}

// 🔧 Update your existing handler
handleFieldChange(e) {
  const key = e.target.dataset.key || e.target.name || e.target.id;
  let value = e.detail?.value || e.target.value || '';

    // 12 jan change


    // 🔒 Make "Is Meter pulsing?" read-only in JS
    // Allow user change only when NOT derived; block when derived
if (key === 'isPulsing' && this.isPulsingDerived) {
  // Revert to the derived value (YES/NO)
  this.state = { ...this.state, isPulsing: this.state?.isPulsing || 'YES' };
      if (e.target && e.target.tagName) {
    e.target.value = this.state.isPulsing;
      }
  return;
    }

    // 12 jan change end here



  if (key === 'annualConsumption') {
    value = value.replace(/[^0-9.]/g, '').slice(0, 10);
  }
  if (key === 'siteContactNumber') {
    value = value.replace(/[^\d+]/g, '').slice(0, 20);
  }
  if (key === 'meterYom') {
    value = value.replace(/\D/g, '').slice(0, 4);
  }

  this.state = { ...this.state, [key]: value };

  if (key === 'converterFitted' && value === 'No') {
    this.state = {
      ...this.state,
      converterSerial: '',
      converterDials: '',
      converterReadingFactor: ''
    };
  }

  
 // ✅ If the radio group changed, clear its error immediately
  if (key === 'converterFitted') {
    const container = this.getActiveSubtypeContainer();
    if (container) {
      // Collect radios in the group by name (native radios)
      const radios = Array.from(
        container.querySelectorAll('input[type="radio"][name="converterFitted"]')
      );
      this.clearRadioGroupError(radios);
    }
  }


  // (For lightning-input this is not necessary; for native inputs it is.)
  if (e.target && e.target.tagName) {
    e.target.value = value;
    // Immediately re-validate and clear message if valid
    this.validateAndClearSingleField(e.target);
  } else {
    // lightning-input case: find by data-key and reportValidity
    const container = this.getActiveSubtypeContainer();
    if (container) {
      const cmp = container.querySelector(
        [
          `lightning-input[data-key="${key}"]`,
          `lightning-textarea[data-key="${key}"]`,
          `lightning-combobox[data-key="${key}"]`,
          `lightning-radio-group[data-key="${key}"]`
        ].join(',')
      );
           if (cmp) this.validateAndClearSingleField(cmp);
    }
  
  }
  console.log('inside handleFieldChange: ', this.state);
}

  // 8 jan change
  // 13 feb change for pulsing
  // 13 feb change for pulsing
  async resolvePulsing() {
    if (!this.shortCode || !this.meterModel || !this.meterYear) {
        this.isPulsingDerived = false;
        return;
    }
  console.log('[PULSING][INPUTS]', {
  shortCode: this.shortCode, model: this.meterModel, year: this.meterYear
});
    try {
      const result = await getPulsing({
        shortCode: this.shortCode,
        model: this.meterModel,
        year: this.meterYear
      });
    console.log('[PULSING][APEX RESULT RAW]', result);
        const normalized = (result || '').toString().trim().toUpperCase();

        if (normalized === 'YES' || normalized === 'NO') {
            this.state = { ...this.state, isPulsing: normalized };
    this.isPulsingDerived = true;
    // keep any lightning-radio-group in sync too (harmless if none)
     this.pulsingValue = this.state.isPulsing;
    // defer sync until DOM is painted
    Promise.resolve().then(() => this.syncPulsingRadios());
        } else {
    this.state = { ...this.state, isPulsing: 'YES' };
      this.isPulsingDerived = false;
     this.pulsingValue = 'YES';
     Promise.resolve().then(() => this.syncPulsingRadios());
        }
    } catch (e) {
  console.error('[PULSING][APEX ERROR]', e);
    this.state = { ...this.state, isPulsing: 'YES' };
        this.isPulsingDerived = false;
  this.pulsingValue = 'YES';
  Promise.resolve().then(() => this.syncPulsingRadios());
    }
}
// 13 feb change end here for pulsing
  // 13 feb change end here for pulsing

  // 8 jan change end here

  // 16 feb pulsing change
  // --- Keep UI radios in sync with state.isPulsing (native input radios) ---
syncPulsingRadios() {
  try {
    const yes = this.template.querySelector('#isPulsing_yes');
    const no  = this.template.querySelector('#isPulsing_no');
    if (yes && no) {
      const vYES = this.state?.isPulsing === 'YES';
      const vNO  = this.state?.isPulsing === 'NO';
      // Set properties to force the visual state
      yes.checked = vYES;
      no.checked  = vNO;
    }
  } catch (e) {
    // no-op
  }
}
  // 16 feb pulsing change end here
  // ===== Drag & Drop upload (per subtype) =====
  handleDragOver(event) {
    event.preventDefault();
    event.currentTarget.classList.add('drag-over');
  }
  handleDragLeave(event) {
    event.preventDefault();
    event.currentTarget.classList.remove('drag-over');
  }
  handleFileDrop(event) {
    event.preventDefault();
    event.currentTarget.classList.remove('drag-over');
    const files = event.dataTransfer.files;
    this.processFiles(files);
  }
  handleBrowseClick() {
    this.template.querySelector('.file-input')?.click();
  }
  handleFileInputChange(event) {
    const files = event.target.files;
    this.processFiles(files);
    event.target.value = ''; // reset picker
  }

  processFiles(fileList) {
    this.fileError = '';
    if (!fileList || fileList.length === 0) return;

    const subtypeId = this.currentSubtypeId;
    if (!subtypeId) {
      this.showTemporaryError('Please select a subtype first.');
      return;
    }

    // Ensure arrays exist
    const currentUI = [...(this.uploadedFilesBySubtype[subtypeId] || [])];
    const currentPayload = [...(this.uploadedPayloadBySubtype[subtypeId] || [])];

    const duplicateNames = [];

    Array.from(fileList).forEach((file) => {
      // Duplicate check by filename (exact match)
      if (currentUI.some((f) => f.name === file.name)) {
        duplicateNames.push(file.name);
        return;
      }

      // Size limit
      if (file.size > MAX_FILE_SIZE) {
        const maxMB = (MAX_FILE_SIZE / 1024 / 1024).toFixed(0);
        this.showTemporaryError(`File "${file.name}" exceeds ${maxMB} MB limit.`);
        return;
      }

      const reader = new FileReader();
      reader.onload = (e) => {
        const base64Data = e.target.result.split(',')[1];

        const uiObj = {
          name: file.name,
          size: file.size,
          sizeDisplay: this.formatFileSize(file.size),
          isImage: file.type?.startsWith('image/'),
          previewUrl: file.type?.startsWith('image/') ? e.target.result : null
        };

        const payloadObj = {
          name: file.name,
          type: file.type,
          size: file.size,
          base64: base64Data
        };

        // Append to subtype arrays
        currentUI.push(uiObj);
        currentPayload.push(payloadObj);

        // Persist back (reactivity)
        this.uploadedFilesBySubtype = { ...this.uploadedFilesBySubtype, [subtypeId]: currentUI };
        this.uploadedPayloadBySubtype[subtypeId] = currentPayload;
      };
      reader.readAsDataURL(file);
    });

    // Duplicate message
    if (duplicateNames.length > 0) {
      if (duplicateNames.length === 1) {
        this.showTemporaryError(`File "${duplicateNames[0]}" is already uploaded.`);
      } else {
        this.showTemporaryError(`Files "${duplicateNames.join('", "')}" are already uploaded.`);
      }
    }
  }

  handleFileDelete(event) {
    const name = event.currentTarget.dataset.name;
    const subtypeId = this.currentSubtypeId;
    if (!subtypeId || !name) return;

    const currentUI = (this.uploadedFilesBySubtype[subtypeId] || []).filter((f) => f.name !== name);
    const currentPayload = (this.uploadedPayloadBySubtype[subtypeId] || []).filter((f) => f.name !== name);

    this.uploadedFilesBySubtype = { ...this.uploadedFilesBySubtype, [subtypeId]: currentUI };
    this.uploadedPayloadBySubtype[subtypeId] = currentPayload;
  }
  showTemporaryError(message, duration = 3000) {
    this.fileError = message;
    setTimeout(() => { this.fileError = ''; }, duration);
  }
  formatFileSize(bytes) {
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }
/* =========================
   ACTIVE SUBTYPE UTILITIES
   ========================= */
/* =========================
   ACTIVE SUBTYPE UTILITIES
   ========================= */
/** Find container for visible subtype by data-subtype (preferred) */
getActiveSubtypeContainer() {
  const id = this.currentSubtypeId; // "AMR_Install" | "AMR_SiteVisit" | "AMR_Remove"
  console.log('id inside getActiveSubtypeContainer: ', id)
  console.log('template inside getActiveSubtypeContainer: ', this.template.querySelector(`div[data-subtype="${id}"]`))
  //return id ? this.template.querySelector(`div[data-subtype="${id}"]`) : null;
  return id;
}

/** Fallback: find the first visible subtype container if currentSubtypeId is not set */
getFirstVisibleSubtypeContainer() {
  const all = Array.from(this.template.querySelectorAll('div.subtype'));
  // Pick the first container that is visible and enabled
  return all.find(c => c.offsetParent !== null); // visible in DOM
}

/** Collect Lightning and native inputs inside a given container */
getInputsFrom(container) {
  if (!container) return { lightning: [], native: [], radioGroups: [] };

  // Lightning base components
  const lightning = Array.from(
    container.querySelectorAll([
      'lightning-input',
      'lightning-textarea',
      'lightning-combobox',
      'lightning-radio-group',
      'lightning-dual-listbox'
    ].join(','))
  );

  // Native inputs (exclude file inputs)
  const native = Array.from(container.querySelectorAll('input, select, textarea'))
    .filter(el => el.type !== 'file' && !el.classList.contains('file-input'));

  // Group native radios by name
  const radioGroupsMap = new Map();
  native.filter(el => el.type === 'radio').forEach(el => {
    const name = el.name || el.getAttribute('name') || el.dataset.key || 'radio_group';
    if (!radioGroupsMap.has(name)) radioGroupsMap.set(name, []);
    radioGroupsMap.get(name).push(el);
  });

  // Debug
  console.log('[AMR] Container:', container?.dataset?.subtype,
              '| lightning:', lightning.length,
              '| native:', native.length,
              '| radio groups:', radioGroupsMap.size);

  return { lightning, native, radioGroups: Array.from(radioGroupsMap.values()) };
}

/** Inline error helpers (fallback if browser popover is suppressed in LWC) */
showInlineError(el, message = 'This field is required') {
  el.classList.add('has-error');
  let hint = el.nextElementSibling;
  const isHint = hint?.classList?.contains('inline-error');
  if (!isHint) {
    hint = document.createElement('span');
    hint.className = 'inline-error';
    el.insertAdjacentElement('afterend', hint);
  }
  hint.textContent = message;
}
clearInlineError(el) {
  el.classList.remove('has-error');
  const hint = el.nextElementSibling;
  if (hint?.classList?.contains('inline-error')) hint.remove();
}

/** Validate a given container: Lightning + native + radios + files */
validateContainer(container) {
  if (!container) return false;

  let allValid = true;
  let firstInvalidEl = null;

  const { lightning, native, radioGroups } = this.getInputsFrom(container);

  // 1) Lightning components
  for (const cmp of lightning) {
    if (typeof cmp.reportValidity === 'function') {
      const ok = cmp.reportValidity();
      if (!ok && !firstInvalidEl) {
          try { cmp.focus?.(); } catch (e) { }
        firstInvalidEl = cmp;
      }
      allValid = allValid && ok;
    }
  }

  // 2) Native inputs/selects (except radios)
  for (const el of native) {
    if (el.type === 'radio') continue;

    // Skip hidden/disabled
    if (el.offsetParent === null || el.disabled) continue;

    const isRequired = el.hasAttribute('required') || el.getAttribute('aria-required') === 'true';
    const empty = !el.value || el.value.trim() === '';

    // Required message
    if (isRequired && empty) {
      el.setCustomValidity('This field is required');
    } else {
      el.setCustomValidity('');
    }

    // Browser validation (also checks type="email"/"tel"/"number"/pattern/min/max)
    const ok = el.reportValidity();

    // Inline fallback if bubble is suppressed
    if (!ok) this.showInlineError(el, el.validationMessage || 'This field is required');
    else this.clearInlineError(el);

    if (!ok && !firstInvalidEl) {
        try { el.focus(); } catch (e) { }
      firstInvalidEl = el;
    }
    allValid = allValid && ok;
  }

  // 3) Native radio groups
  
for (const group of radioGroups) {
  const visibleGroup = group.filter(r => r.offsetParent !== null && !r.disabled);
  if (visibleGroup.length === 0) continue;

  const isRequired = group.some(r => r.hasAttribute('required') || r.getAttribute('aria-required') === 'true');
  if (!isRequired) continue;

  const anyChecked = group.some(r => r.checked);

  // Find the dedicated placeholder in the same container
  const container = visibleGroup[0].closest('.horizontal-radio') || visibleGroup[0].parentElement;
  const slot = container?.querySelector('.inline-error[data-error-for="converterFitted"]');

  if (!anyChecked) {
    const firstRadio = visibleGroup[0];
    firstRadio.setCustomValidity('This field is required');
    firstRadio.reportValidity();

    if (slot) {
      slot.textContent = 'This field is required';
      slot.style.display = 'inline-block';
    }

    if (!firstInvalidEl) {
          try { firstRadio.focus(); } catch (e) { }
      firstInvalidEl = firstRadio;
    }
    allValid = false;
  } else {
    visibleGroup.forEach(r => r.setCustomValidity(''));
    if (slot) {
           slot.textContent = '';
      slot.style.display = 'none';
    }
  }
}

  // 4) Files per subtype (configure per business rule)
  const subtypeId = container.dataset?.subtype; // e.g., "AMR_SiteVisit"
  const mustHaveFiles = true; // or (subtypeId !== 'AMR_SiteVisit') if Site Visit is optional
  if (mustHaveFiles) {
    const files = this.uploadedPayloadBySubtype[subtypeId] || [];
    if (files.length === 0) {
      this.showTemporaryError('Please upload at least one file.');
      allValid = false;
    }
  }

  // 5) Scroll to first invalid field
  if (!allValid && firstInvalidEl) {
      try { firstInvalidEl.scrollIntoView({ behavior: 'smooth', block: 'center' }); } catch (e) { }
  }

  return allValid;
}

  // 10 feb change for consent message

  // Toggle consent and clear/show error instantly
  handleInputChange(event) {
    this.consent = !!event.target.checked;
    if (this.consent) {
      this.consentMessage = '';
      this.consentMessageFlag = false;
    } else {
      this.consentMessage = 'consent is required';
      this.consentMessageFlag = true;
    }
  }
  // 10 feb change end here for consent message

/** Common submit handler — now with visible-container fallback */
async handleAmrSubmit() {
  console.log('inside handleAmrSubmit: ', JSON.stringify(this.state));
  
    // 10 feb change for consent message

    // --- Consent gate (must be ticked before submit) ---
    if (!this.consent) {
      this.consentMessage = 'consent is required';
      this.consentMessageFlag = true;
      return; // Block submit without turning on spinner
    }

    // 10 feb change end here for consent message
  this.isLoading = true;
  // Try preferred container via currentSubtypeId
  let container = this.getActiveSubtypeContainer();
  console.log('container: ', container);

  // Fallback: derive active container by visibility
  if (!container) {
    container = this.getFirstVisibleSubtypeContainer();
    if (container?.dataset?.subtype && !this.currentSubtypeId) {
      // Keep file validation in sync with the visible subtype
      const visibleId = container.dataset.subtype;
      console.warn('[AMR] currentSubtypeId was empty; using visible container:', visibleId);
      // Optionally set selectedSubType to keep state aligned:
      this.selectedSubType = { id: visibleId, label: visibleId.replace('AMR_', '') };
      this.selectedSubTypeLabel = this.selectedSubType.label;
    }
  }

  if (!container) {
    // No visible subtype found -> show a single error
    this.showTemporaryError('Please select a subtype first.');
    return;
  }
/*
  const valid = this.validateContainer(container);

  if (valid) {
    console.log('[AMR] Valid:', container.dataset?.subtype);
    // eslint-disable-next-line no-alert
    alert('Form is valid (unit testing).');
  } else {
    console.warn('[AMR] Invalid:', container.dataset?.subtype);
  }
 */ 
  console.log('suppliercode: ', this.suppliercode);
  
    if (this.suppliercode != null && this.suppliercode != '' && this.suppliercode != undefined) {
        console.log('inside suppliercode if');
      //this.supplierContract = this.fetchSupplierContract(this.suppliercode);
      const supplierInfo = await getSupplierInfo({ customer: this.suppliercode });
        console.log('inside suppliercode if amrContract: ', supplierInfo);
      if (supplierInfo != null && supplierInfo != '' && supplierInfo != undefined) {
        if (supplierInfo.NGMCP_AMR_Contract__c != null && supplierInfo.NGMCP_AMR_Contract__c != '' && supplierInfo.NGMCP_AMR_Contract__c != undefined) {
                            
                        this.supplierContract = supplierInfo.NGMCP_AMR_Contract__c;
                        }
                    }
  }

  console.log('AMR Contract: ', this.supplierContract);

  if(this.supplierContract == null || this.supplierContract == '' || this.supplierContract == undefined){
    this.successMessage = 'Contract Number is not available for this supplier';
    this.serviceTicketid = '';
    this.srNumber = '';
    this.isModal = true;
    this.isLoading = false;
  }
  else{
  console.log('meterModel: ', this.meterModel);
  console.log('meterYear: ', this.meterYear);
  console.log('meterDials: ', this.meterDials);
  console.log('state: ', JSON.stringify(this.state));
  console.log('serviceLevel: ', this.state.serviceLevel);
  const mprnList = this.mprn.split(' - ');
  const createPayload = {
    NGMCP_Building_Name__c: this.buildingName,
    NGMCP_Market_Sector_Code__c: this.industry,
    NGMCP_Street__c: this.street,
    NGMCP_Affected_Person_Title__c: this.state.title,
    NGMCP_Dependent_Locality__c: this.dependentLocality
  }
  console.log('createPayload: ', JSON.stringify(createPayload));
  const payload = {
        p_ContractRef: this.supplierContract,
        p_CustomerCode: this.suppliercode,
        p_TransactionRef: this.getTransactionRef(),
        p_JobType: container == 'AMR_Install' ? 'STRT' : container == 'AMR_SiteVisit' ? 'SVST' : container == 'AMR_Remove' ? 'RMVE' : 'STOP',
        p_MPRN: mprnList[0],
        p_ServiceLevel: this.state.serviceLevel == 'Platinum(P)' ? 'P' : this.state.serviceLevel == 'Copper(C)' ? 'C' : this.state.serviceLevel == 'Bronze(B)' ? 'B' : this.state.serviceLevel == 'Silver Class(T)' ? 'T' : 'P',//mandatory in swagger for site visit
        //p_AlarmReq: 0,
        //p_UpfrontReq: "string",
        p_AnnualQuantity: '1',//mandatory in swagger for site visit
        p_EffectiveDate: new Date().toISOString().split("T")[0],
        p_CreateReason: "Test Reason",
        //p_AlarmHigh: "string",
        //p_AlarmLow: "string",
        //p_AlarmPeriod: "string",
        //p_AlarmNotification: "string",
        p_SiteContact: container == 'AMR_Install' ? this.state.siteContactNumber : container == 'AMR_SiteVisit' || container == 'AMR_Stop' ? this.state.sv_consumerEmail2 : this.state.rm_consumerEmail2,
        p_SiteName: container == 'AMR_Install' ? this.state.siteContactName : container == 'AMR_SiteVisit' ? this.state.sv_siteContactName : container == 'AMR_Stop' ? this.state.sv_siteContactName2 : this.state.rm_siteContactName,
        p_contactNo: container == 'AMR_Install' ? this.state.siteContactNumber : container == 'AMR_SiteVisit' || container == 'AMR_Stop' ? this.state.sv_consumerEmail2 : this.state.rm_consumerEmail2,
        //p_DMLogger: 0,
        //p_OpenRead: "string",
        //p_Prime: "string",
        p_Comments: this.state.accessInstructions,//container == 'AMR_Install' ? this.state.accessInstructions : this.state.sv_accessInstruction,
        p_Email: container == 'AMR_Install' ? this.state.consumerEmail : container == 'AMR_SiteVisit' || container == 'AMR_Stop' ? this.state.sv_consumerEmail1 : this.state.rm_consumerEmail1,
        //p_Retval: "string",
        p_MAMId: this.state.mamId != '' && this.state.mamId != undefined && this.state.mamId != null ? this.state.mamId : 'GTM',
        p_Address: this.address,
        p_Posttown: this.postalTown,
        p_PostCode: this.postCode,
        p_CorrectionFactor: this.state.correctionFactor ? parseInt(this.state.correctionFactor) : 0, //mandatory in mulesoft for install
        p_MeterManufacturer: this.shortCode,
        p_MeterModel: this.meterModel,
        p_MeterYOM: this.state.meterYom ? this.state.meterYom : this.meterYear.toString(),//mandatory in mulesoft for site visit
        p_MeterSerialNumber: this.msn,
        p_MeterDials: this.state.meterDials ? parseInt(this.state.meterDials) : parseInt(this.meterDials),//mandatory in mulesoft for install
        p_MeterUnitofMeasure: this.state.meterUom ? this.state.meterUom : 'UOM',//mandatory in mulesoft for site visit
        p_MeterReadingFactor: this.state.meterReadingFactor ? parseInt(this.state.meterReadingFactor) : 100,//mandatory in mulesoft for install
        p_ConverterFittedIndicator: this.state.converterFitted && this.state.converterFitted == 'Yes' ? 'Y' : 'N',//mandatory in mulesoft for site visit
        p_ConverterSerialNumber: this.state.converterSerial ? this.state.converterSerial : '0',//mandatory in mulesoft for site visit
        p_ConverterDials: this.state.converterDials ? parseInt(this.state.converterDials) : 0,//mandatory in mulesoft for install
        p_ConverterReadingFactor: this.state.converterReadingFactor ? parseInt(this.state.converterReadingFactor) : 0, //mandatory in mulesoft for install
        p_SVSTResponseSent: false,
        p_ReadFrequency: "",
        p_RequestNGMReference: "",
        p_AMRSerialNumber: container == 'AMR_Install' ? '' : "AC0003999610TA",
        p_YearofManufacture: container == 'AMR_Install' ? '' : "2020",
        p_ServiceProvider: container == 'AMR_Install' ? '' : "TEC"
    }
    console.log('Payload: ', JSON.stringify(payload));
    if((container == 'AMR_Install' && this.state.isPulsing == 'YES') || 
    container == 'AMR_SiteVisit' ||
    container == 'AMR_Stop') {
     try {
                       // Step 1: Create record
                       const requestRecordId = await createAMR({
                           requestBody: JSON.stringify(payload),
                           isPulsing : this.state.isPulsing,
                           gpsId : '',
                           amrRequest: createPayload
                       });
               
                       console.log(' Request Record ID:', requestRecordId);
               
                       // Step 2: Submit request if record creation succeeded
                       if (requestRecordId) {
                           const response = await submitAMR({
                               requestBody: JSON.stringify(payload),
                               requestId: requestRecordId
                           });
               
                           console.log(' Apex response:', response);
                           console.log('typeof response: ', typeof response);
                           const parsed = typeof response === "string" ? JSON.parse(response) : response;
                           console.log(' parsed response:', parsed);
                           console.log(' parsed response:', parsed?.obj?.p_WorkRequestID)
        if (parsed?.obj?.p_WorkRequestID) {
                                this.successMessage = 'The AMR request has been created successfully'
                                this.serviceTicketid = 'The reference number is ';
                                //const req = await getRequest({requestid: requestRecordId});
                                //console.log('req: ', req);
                                
                                this.srNumber = parsed.obj.p_WorkRequestID;
                                this.isModal = true;
                           }
        else {
                              console.error('Error during Apex callout:', parsed);
                              console.error('error:', JSON.stringify(parsed));
                              this.successMessage = 'Request could not be submitted. ' + parsed.message;
                              this.serviceTicketid = '';
                              this.srNumber = '';
                              this.isModal = true;
                           }
                           // TODO: Show success toast or navigate
                       } else {
                           console.warn(' No request record ID returned.');
                           this.successMessage = 'No request record ID returned.';
                            this.serviceTicketid = '';
                              this.srNumber = '';
                              this.isModal = true;
                       }
                   } catch (error) {
                       console.error('Error during Apex callout:', error);
                       console.error('error:', JSON.stringify(error));
                       this.successMessage = 'Request could not be submitted. ' + JSON.stringify(error);
                       this.serviceTicketid = '';
                       this.srNumber = '';
                       this.isModal = true;
                       
                   } finally {
                       // Stop loading
                       this.isLoading = false;
                       console.log('Submission process completed.');
        }
    }
    else if(container == 'AMR_Install' && this.state.isPulsing == 'NO')
    {
        console.log('Inside non-pulsing ARM install block');
        const type = {
      diaphragm: 'D',
      'rotary displacement': 'R',
      'diaphragm - synthetic': 'S',
      turbine: 'T',
      ultrasonic: 'U',
      other: 'Z'
    }
    const pressureMap = {
      'high pressure': 'HP',
      'medium pressure': 'MP',
      'low pressure': 'LP',
      'intermediate pressure': 'IP',
    };
    const normalizeLower = (s) => (s ?? '').toLowerCase();
       /* const gpsPayload = {
          reportedpriority: 2,
          job_type: 'EXCHG',
          ngme_consphone: this.state.siteContactNumber,
          description_longdescription: this.state.accessInstructions,
          job_subtype: 'GPMST',
          targetstart: '',
          ngme_time: '',
          source: 'PORTAL',
          job_sub_subtype: '',
          ngme_lf_mksctcd: this.industry,
          ngme_liferay_slot: '',
          assetnum: this.assetNum,
          suppliercode: this.suppliercode,
          location: mprnList[0],
          ngme_constitle: this.state.title,
          ngme_consemail: this.state.consumerEmail,
          building_name: this.buildingName,
          ngme_consname: this.state.siteContactName,
          mprn_pres: pressureMap[normalizeLower(this.pressuretier)] || "",
          curpayment: this.paymentMechanism == 'Credit' ?'CR' : 'PP',
          assettype: 'METER',
          newmodel: '',
          metmodel: this.meterModel,
          mettype: type[normalizeLower(this.meterType)] || "",
          status: "NEW",
          // If backend expects 'Y'/'N' for these, keep asYN here; else use raw values.
          ngme_lf_eleint: 'N',
          ngme_lf_twinpress: 'N',// this.asYN?.(this.statemap.get('twinStream')) ?? this.statemap.get('twinStream') ?? "N",
          ngme_lf_conventer: 'N',//this.asYN?.(this.statemap.get('converterRequired')) ?? this.statemap.get('converterRequired') ?? "N",
          ngme_lf_bypass: 'N',//this.asYN?.(this.statemap.get('meterBypass')) ?? this.statemap.get('meterBypass') ?? "N",

          building_no: this.buildingNumber,
          dependentloc: this.dependentLocality,
          street: this.street,
          posttown: this.postalTown,
          postcode: this.postCode,
          reportedemail: this.user.Email.value,
          reqpayment: '',// NGME_REQPAY[normalizeLower(this.statemap?.get?.('paymentMethod') ?? '')]||"",
          
          ticketspec: [
            {
              assetattrid: 'NGME_METERMF',
              alnvalue: this.shortCode
            },
            {
              assetattrid: 'NGME_MODEL',
              alnvalue: this.meterModel
            },
            {
              assetattrid: 'NGME_MFRSERIALNU',
              alnvalue: this.msn
            },
            {
              assetattrid: 'NGME_METERTYPE',
              alnvalue: type[normalizeLower(this.meterType)] || ""
            },
            {
              assetattrid: 'NGME_YOM',
              alnvalue: this.meterYear.toString()
            }
          ],
       pickuptype: '',
          housing: '',
          purging:'',
          carryout:'',
          debtservice:'',
          incdec:'',
          reason:''
        }*/
        const gpsPayload = {
            ngme_consname: this.state.siteContactName,
            reason: 'MUOP',
            loccode: '',
            bldgname: this.buildingName,
            sectorcode: this.industry,
            street: this.street,
            supplier: this.suppliercode,
            notif_type: 'TQ',
            ngme_riskassess: 'N',
            posttown: this.postalTown,
            ngme_constitle: this.state.title,               // ✅ Title
            description_longdescription: 'TQ auto created due to existing meter being identified as Non-Pulsing (following AMR Install request). Please review and raise the required GPS exchange job.',
            ngme_engvisit: 'N',
            targetstart: null,
            postcode: this.postCode,                                 // ✅ FIX casing: use postCode
            ngme_time: null,
            ngme_consphone: this.state.siteContactNumber,
            ngme_consemail: this.state.consumerEmail,      // ✅ Contact Site Number
            deplocal: this.dependentLocality,
            ngme_threshold: 'N',
            location: mprnList[0],
            reportedemail: this.user.Email.value, // ✅ Contact Email
            category: 'TQUERY',
            subcategory: 'MET'
        }
          
        console.log('GPS Payload: ', JSON.stringify(gpsPayload));
        try{
        const requestId = await createDataQueryRecord({
                    requestBody: JSON.stringify(gpsPayload),
                    meterDetails: null
                  });
        console.log('requestId: ', requestId);
        if(requestId){
        const  response = await submitDataQuery({
                    requestBody: JSON.stringify(gpsPayload),
                    requestId: requestId
                    
                  }); 
                  console.log('response: ', response);
                  const parsed = typeof response === "string" ? JSON.parse(response) : response;
                  console.log('parsed: ', parsed);
                  if(parsed?.ticketid){
                    const requestRecordId = await createAMR({
                           requestBody: JSON.stringify(payload),
                           isPulsing : this.state.isPulsing,
                           gpsId : parsed.ticketid,
                           amrRequest: createPayload
                       });
                     console.log('requestRecordId: ', requestRecordId);
                    if(requestRecordId){
                      const amr = await getRequest({
                        requestid: requestRecordId
                      });
                      console.log('amr: ', amr);
                      if(amr){
                        this.successMessage = 'The AMR Request has been created Successfully and is currently on hold due to the existing meter being non-pulsing.'
                        this.serviceTicketid = 'The reference number is ';
                        this.srNumber = amr.Name;
                        this.nonPulsingInstallorRemove = true;
                        this.relatedSuccessMessage = 'NGM will arrange for the exchange of the non-pulsing meter and process the AMR request once complete.';
                        this.relatedServiceTicketMessage = 'The reference Number is ';
                        this.relatedSRnumber = parsed.ticketid;
                        this.isModal = true;
                        this.isLoading = false
                      }
                      
                    }
                    else{
                      console.error('Error during Apex callout:');
                     
                      this.successMessage = 'Request could not be submitted. ';
                      this.serviceTicketid = '';
                      this.srNumber = '';
                      this.isModal = true;
                      this.isLoading = false;
                    }
                  }
                  else{
                    console.log('Error occured');
                    this.successMessage = 'Request could not be submitted. ';
                    this.serviceTicketid = '';
                    this.srNumber = '';
                    this.isModal = true;
                    this.isLoading = false;
                  }
        }
      }catch(error){
        console.error('Error during Apex callout:', error);
        console.error('error:', JSON.stringify(error));
        this.successMessage = 'Request could not be submitted. ' + JSON.stringify(error);
        this.serviceTicketid = '';
        this.srNumber = '';
        this.isModal = true;
        this.isLoading = false;
      }finally{
        console.log('Submission process completed.');
      }
    }
    else if(container == 'AMR_Remove'){
      try{
        const stopPayload = payload;
        stopPayload.p_JobType = 'STOP';
        console.log('stopPayload: ',JSON.stringify(stopPayload));
        const requestRecordId = await createAMR({
                           requestBody: JSON.stringify(stopPayload),
                           isPulsing : this.state.isPulsing,
                           gpsId : '',
                           amrRequest: createPayload
                       });
        console.log('requestRecordId: ',requestRecordId);     
        if(requestRecordId){
          const response = await submitAMR({
                               requestBody: JSON.stringify(stopPayload),
                               requestId: requestRecordId
                           });
          console.log(' Apex response:', response);
          console.log('typeof response: ', typeof response);
          const parsed = typeof response === "string" ? JSON.parse(response) : response;
          console.log(' parsed response:', parsed);
          console.log(' parsed response:', parsed?.obj?.p_WorkRequestID)                   
          if (parsed?.obj?.p_WorkRequestID) {
          console.log('Payload: ', JSON.stringify(payload));
          payload.p_JobType = 'RMVE';
          console.log('Payload after: ', JSON.stringify(payload));
            const removeRecordId = await createAMR({
                           requestBody: JSON.stringify(payload),
                           isPulsing : this.state.isPulsing,
                           gpsId : parsed.obj.p_WorkRequestID.toString(),
                           amrRequest: createPayload
                       });
            console.log('removeRecordId: ',removeRecordId);
            if(removeRecordId){
              const amr = await getRequest({
                        requestid: removeRecordId
                      });
                      console.log('amr: ', amr);
                      if(amr){
                        this.successMessage = 'The AMR Removal Request has been created Successfully and is currently on hold to Process the AMR Stop.'
                        this.serviceTicketid = 'The reference number is ';
                        this.srNumber = amr.Name;
                        this.nonPulsingInstallorRemove = true;
                        this.relatedSuccessMessage = 'NGM will process the AMR Stop and process the AMR Removal request once complete.';
                        this.relatedServiceTicketMessage = 'The reference Number is ';
                        this.relatedSRnumber = parsed.obj.p_WorkRequestID;
                        this.isModal = true;
                        this.isLoading = false
                      }
            }
          } 
        }         
      }
      catch(error){
        console.error('Error during Apex callout:', error);
        console.error('error:', JSON.stringify(error));
        this.successMessage = 'Request could not be submitted. ' + JSON.stringify(error);
        this.serviceTicketid = '';
        this.srNumber = '';
        this.isModal = true;
        this.isLoading = false;
      }
    }
  }
}

  connectedCallback() {
        console.log('supplierShortCode: ', this.supplierShortCode);
        console.log('isResidentialU6Site: ', this.isResidentialU6Site);
        console.log('status: ', this.status);
        console.log('pressuretier: ', this.pressuretier);
        console.log('stateofWorkRequest: ', this.stateofWorkRequest);
        
    // this.addressDetails = {"buildingNumber":"334","buildingName":"BURTON GROUP","street":"OXFORD STREET","dependentLocality":"N/A","postalTown":"LONDON","postCode":"W1C 1JG"};
    //this.assetDetails = [{"label":"Manufacturer","value":"PC COMPTEURS"},{"label":"Model","value":"800/150"},{"label":"Manufacturer Serial no.","value":"0315429"},{"label":"Meter Type","value":"Rotary Displacement"},{"label":"No. of Dials","value":7},{"label":"Payment Mechanism","value":"Credit"},{"label":"Year of Manufacture","value":"1978"},{"label":"Location","value":"Other"},{"label":"Install Date","value":"01-01-1978"},{"label":"Measuring Capacity","value":1000}]
        console.log("Address before : ", JSON.stringify(this.addressDetails));
    console.log('Array.isArray(this.addressDetails): ', Array.isArray(this.addressDetails));
        console.log('this.addressDetails.length: ', this.addressDetails.length);
    if (Array.isArray(this.addressDetails) && this.addressDetails.length > 0) {
            const addressObj = 
                this.addressDetails.reduce((acc, { apiName, value }) => {
                acc[apiName] = value;
                return acc;
                }, {});
            console.log("addressObj: ", JSON.stringify(addressObj));
            this.addressDetails = addressObj;

        }
        console.log("Address after: ", JSON.stringify(this.addressDetails));
        console.log("Asset: ", JSON.stringify(this.assetDetails));
    //this.metadataRecord = [{"metadatalist":[{"NGMCP_Meter_Model_Size__c":"Non U6","NGMCP_Market_Sector_Code__c":"I","Id":"m0Pdu000003w5R0EAI","NGMCP_UWR_Job_Code__c":"EXCFTTU","NGMCP_Portal_Category__c":"Faulty Turbine"}],"assetnum":"21086273","location":"10091406","suppliercode":"QU2","ngme_industry":"I"}]
    // this.mprn = "10091406";
        this.postCode = this.addressDetails.postCode;
        this.buildingNumber = this.addressDetails.buildingNumber;
        this.buildingName = this.addressDetails.buildingName;
        this.street = this.addressDetails.street;
        this.postalTown = this.addressDetails.postalTown;
        this.dependentLocality = this.addressDetails.dependentLocality;
        const buildingNum = this.buildingNumber ? this.buildingNumber + ' , ' : '';
        const buildingName = this.buildingName ? this.buildingName + ' , ' : '';
        const street = this.street ? this.street + ' , ' : '';
        const dependentLocality = this.dependentLocality ? this.dependentLocality + ' , ' : '';
        const postalTown = this.postalTown ? this.postalTown + ' , ' : '';
        this.address = buildingNum + buildingName + street + dependentLocality + postalTown + this.postCode;
        console.log('Address: ', this.address);
        console.log("Metadata Record: ", JSON.stringify(this.metadataRecord));
    //console.log("Status: ", this.status);
   // console.log("Payment Mechanism: ", this.paymentMechanism);
        console.log('postCode: ', this.postCode);
        console.log('MPRN: ', this.mprn);
   if (this.metadataRecord && this.metadataRecord.length > 0 && this.metadataRecord[0].suppliercode) {
        this.suppliercode = this.metadataRecord[0].suppliercode;
        this.assetNum = this.metadataRecord[0].assetnum;
        this.industry = this.metadataRecord[0].ngme_industry;
    } else if (this.metadataRecord && this.metadataRecord.suppliercode) {
      this.suppliercode = this.metadataRecord.suppliercode;
      this.assetNum = this.metadataRecord.assetnum;
      this.industry = this.metadataRecord.ngme_industry;
    }
    console.log("suppliercode: ", this.suppliercode);
    console.log("assetNum: ", this.assetNum);
    console.log("industry: ", this.industry);
    if (this.suppliercode == null || this.suppliercode == '' || this.suppliercode == undefined) {
            this.suppliercode = this.supplierShortCode;
        }
        console.log("suppliercode: ", this.suppliercode);
        //this.fetchEnquiryCodes();
        //console.log('Enquiry codes: ', this.enquiryCodes);

    // 8 jan change 


    const manufacturer = this.assetDetails.find(a => a.label === 'Manufacturer')?.value;
    const model = this.assetDetails.find(a => a.label === 'Model')?.value;
    const yom = parseInt(this.assetDetails.find(a => a.label === 'Year of Manufacture')?.value, 10);
    const msn = this.assetDetails.find(a => a.label === 'Manufacturer Serial no.')?.value;
    const dials = this.assetDetails.find(a => a.label === 'No. of Dials')?.value;
    const payment = this.assetDetails.find(a => a.label === 'Payment Mechanism')?.value;
    const mType = this.assetDetails.find(a => a.label === 'Meter Type')?.value;

    // Normalize for reliable Apex match
this.shortCode  = (manufacturer || '').trim().toUpperCase();
this.meterModel = (model || '').trim().toUpperCase();
this.meterYear  = Number.isFinite(yom) ? yom : null;

// --- BEGIN: extra normalization to avoid near-miss matches ---
const NBSP = /\u00A0/g; // non‑breaking space
const squash = s => s.replace(NBSP, ' ').replace(/\s+/g, ' ').trim();

// Collapse internal spacing and NBSPs in maker & model
this.shortCode  = squash(this.shortCode);   // e.g., 'PARKINSON  COWAN' -> 'PARKINSON COWAN'
this.meterModel = squash(this.meterModel);  // e.g., 'U6 ' -> 'U6'
// --- END: extra normalization ---

// Optional: you can keep this early call; final value will be set again after Install init
//this.resolvePulsing(); // 13 feb change for pulsing
    this.msn = msn ? msn.toUpperCase() : '';
    this.meterDials = dials;
    // 8 jan change end here
    this.paymentMechanism = payment;
    this.meterType = mType;
  }

  renderedCallback() {
  this.syncPulsingRadios();
}
  

  getTransactionRef() {
       
        const number = Math.floor(100000 + Math.random() * 900000);

        // Generate 3 random uppercase alphabets
        const letters = Array.from({ length: 3 }, () =>
            String.fromCharCode(65 + Math.floor(Math.random() * 26))
        ).join('');

        return `${number}${letters}`;
 
    }

  fetchSupplierContract(supplier) {

    getSupplierInfo({ customer: supplier })
        .then(result => {
            console.log('Result: ', result);
        if (result == null || result == '' || result == undefined) {
                return '';
            }
        else {
          if (result.NGMCP_AMR_Contract__c != null && result.NGMCP_AMR_Contract__c != '' && result.NGMCP_AMR_Contract__c != undefined) {
                    return result.NGMCP_AMR_Contract__c;
                }
          else {
                    return '';
                }
            }
            
        })
        .catch(error => {
            console.log('Error: ', error);
            return '';
        });
        
    }

  handleCancelClick() {
        this.dispatchEvent(new CustomEvent("cancelcreatejob"));
    }

}