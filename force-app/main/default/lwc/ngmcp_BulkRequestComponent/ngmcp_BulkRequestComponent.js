import {LightningElement,track,wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import NGMCPAMRInstall from '@salesforce/resourceUrl/NGMCP_AMRInstall';
import NGMCPAMRSiteVisit from '@salesforce/resourceUrl/NGMCP_AMRSiteVisit';
import NGMCPAMRRemove from '@salesforce/resourceUrl/NGMCP_AMRRemove';
import NGMCPAMRStop from '@salesforce/resourceUrl/NGMCP_AMRStop';
import NGMCPDeappCOS from '@salesforce/resourceUrl/NGMCP_DeappCOS';
import NGMCPDeappCA from '@salesforce/resourceUrl/NGMCP_DeappCA';
import NGMCPDeappCM from '@salesforce/resourceUrl/NGMCP_DeappCM';
import NGMCPDeappCOT from '@salesforce/resourceUrl/NGMCP_DeappCOT';
import NGMCPDeappDE from '@salesforce/resourceUrl/NGMCP_DeappDE';
import NGMCPDeappDEMO from '@salesforce/resourceUrl/NGMCP_DeappDEMO';
import NGMCPDeappDPL from '@salesforce/resourceUrl/NGMCP_DeappDPL';
import NGMCPDeappEOT from '@salesforce/resourceUrl/NGMCP_DeappEOT';
import NGMCPAppntCOS from '@salesforce/resourceUrl/NGMCP_AppntCOS';
import NGMCPAppntFIX from '@salesforce/resourceUrl/NGMCP_AppntFIX';
import NGMCPAppntCA from '@salesforce/resourceUrl/NGMCP_AppntCA';
import NGMCPAppntNEWCN from '@salesforce/resourceUrl/NGMCP_AppntNEWCN';
import NGMCPAppntFNDAS from '@salesforce/resourceUrl/NGMCP_AppntFNDAS';
import NGMCP_PEMS_And_TSC from '@salesforce/resourceUrl/NGMCP_PEMS_And_TSC';
import NGMCP_PEMS from '@salesforce/resourceUrl/NGMCP_PEMS_File';
import startBulkProcess from '@salesforce/apex/NGMCP_AMRBulkController.startBulkProcess';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
const FIELDS = ['User.Email'];
import { validateAMRInstallBulkUpload } from './amrinstall';
import getUserSupplierCodeOptions from '@salesforce/apex/NGMCP_UserDependentPicklistController.getUserSupplierCodeOptions';
import uploadFile from '@salesforce/apex/NGMCP_AMRBulkController.uploadFile';
import getRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.getRequest";

export default class NgmcpBulkRequestComponent extends LightningElement {

    @track action = '';
    isReadOnly = true;
    @track mode = '';
    @track formData = {};
    @track supplierCodes = [];
    @track showModal = false;
    @track modalTitle = '';
    @track modalMessage = '';
    @track downloadLink;
    @track downloadlabel;
    @track isBulkCsvValid = false;
    supplierGroupCodeMap = {}; 
    showResult = false;
    bulkRecords = [];
    profileName;
    AMRInstall = NGMCPAMRInstall;
    AMRRemove = NGMCPAMRRemove;
    AMRSiteVisit = NGMCPAMRSiteVisit;
    AMRStop = NGMCPAMRStop
    DeappointmentCOS = NGMCPDeappCOS;
    DeappointmentCA = NGMCPDeappCA;
    DeappointmentCM = NGMCPDeappCM;
    DeappointmentCOT = NGMCPDeappCOT;
    DeappointmentDE = NGMCPDeappDE;
    DeappointmentDEMO = NGMCPDeappDEMO;
    DeappointmentDPL = NGMCPDeappDPL;
    DeappointmentEOT = NGMCPDeappEOT;
    AppointmentCOS = NGMCPAppntCOS;
    AppointmentFIX = NGMCPAppntFIX;
    AppointmentCA = NGMCPAppntCA
    AppointmentNEWCN = NGMCPAppntNEWCN;
    AppointmentFNDAS = NGMCPAppntFNDAS;
    PEMSAndTSC = NGMCP_PEMS_And_TSC
    PEMS = NGMCP_PEMS
    isSubmitDisabled = true;
    @track isCrmUser = false;
    @track supplierGroup;
    @track supplierGroupOptions = [];
    @track supplierCodeOptions = [];
    @track modeOptions = [];
    @track isLoading = false;
    userId = USER_ID;
    email;
    validationResult = {};
    @track consentError = false;
    @track isChecked = false;
    @track options = [];
    @track NGMCP_errorMessage = "";
    @track PEMSAndTSCFlag = false;
    @track selectedShortCode = '';
    fileName;
    base64Data;
    file;
    pemsTscFile;
    mandatoryColumnsInAMRInstall = ['Customer', 'Trans Ref', 'Contract Ref', 'Job Type', 'MPRN', 'Service Level', 'Alarm Req', 'Upfront Payment', 'AQ (KWH)', 'Site Name', 'Site Contact', 'Contact Mechanism Value', 'DM logger ind', 'Opening read required'];
    
@wire(getRecord, { recordId: '$userId', fields: FIELDS })
    userRecord({ error, data }) {
        if (data) {
            this.email = data.fields.Email.value;
        }
    }

@wire(getUserSupplierCodeOptions)
  wiredOptions({ data, error }) {
    
    this.isLoading = false;
    if (data) {
      this.options = data.map(o => ({ value: o.value, label: o.label }));
     // this.options.sort();
      this.NGMCP_errorMessage = '';
    } else if (error) {
      this.options = [];
      this.NGMCP_errorMessage = JSON.stringify(error);
    }
    
  }

actionOptions = [
        { label: 'AMR', value: 'AMR' },
        { label: 'Appointment', value: 'Appointment' },
        { label: 'Deappointment', value: 'Deappointment' },
        { label: 'Service Engineer Hire (TSE)', value: 'Service Engineer Hire' },
        { label: 'Post Emergency Meter Works (PEMS)', value: 'Post Emergency Meter Works' }
    ];

    modeMap = {
        AMR: [
            { label: 'Install', value: 'STRT' },
            { label: 'Remove', value: 'RMVE' },
            { label: 'Site Visit', value: 'SVST' },
            { label: 'Stop', value: 'STOP' }
        ],
        Appointment: [
            { label: 'Change of Supplier (COS)', value: 'COS' },
            { label: 'Change of Agent (CA)', value: 'CA' },
            { label: 'New Connection (NEWCN)', value: 'NEWCN' },
            { label: 'New Meter Fitted (FIX)', value: 'FIX' },
            { label: 'Found Asset (FNDAS)', value: 'FNDAS' }
        ],
        Deappointment: [
            { label: 'Change of Agent (CA)', value: 'CA' },
            { label: 'Disconnection (DE)', value: 'DE' },
            { label: 'Demolition (DEMO)', value: 'DEMO' },
            { label: 'Change of Supplier (COS)', value: 'COS' },
            { label: 'Change of Tenancy (COT)', value: 'COT' },
            { label: 'Duplicate (DPL)', value: 'DPL' },
            { label: 'End of Tenancy (EOT)', value: 'EOT' },
            { label: 'Customer Removed Meter (CM)', value: 'CM' }
        ]
    }

    handleActionChange(e) {
        this.action = e.target.value; 
        if(this.action == 'AMR' || this.action == 'Appointment' || this.action == 'Deappointment'){
            this.PEMSAndTSCFlag = false;
            this.modeOptions = this.modeMap[this.action] || [];
            this.mode = null;
            this.formData = {};
            this.bulkRecords = [];
            const modeRadios = this.template.querySelectorAll('input[name="mode"]');
            if(modeRadios) {
                modeRadios.forEach(radio => {
                    radio.checked = false;
                });
            }
            this.downloadlabel = '';
        }
        else{
           this.PEMSAndTSCFlag = true;
        }
    }
    handleModeChange(e) {    
        this.mode = e.target.value;    
        this.bulkRecords = [];
        this.updateDownloadLink();
    }

    handleShortCodeChange(event) { 
        const selectedCode = event.target.value;
        this.selectedShortCode = selectedCode;
        this.bulkRecords = [];
        this.updateDownloadLink(); 
    }

    updateDownloadLink() {
        this.downloadLink = null;  
        if(this.action == 'AMR' ) {
            if(this.mode == 'STRT'){
                this.downloadLink = this.AMRInstall;
                this.downloadlabel = 'AMR Install Bulk Template'
            }
            else if(this.mode == 'RMVE'){
                this.downloadLink = this.AMRRemove;
                this.downloadlabel = 'AMR Remove Bulk Template'
            }
            else if(this.mode == 'SVST'){
                this.downloadLink = this.AMRSiteVisit;
                this.downloadlabel = 'AMR Site Visit Bulk Template'
            }
            else if(this.mode == 'STOP'){
                this.downloadLink = this.AMRStop;
                this.downloadlabel = 'AMR Stop Bulk Template'
            }
        } 
        if(this.action == 'Deappointment'){
            if(this.mode == 'COS'){
                this.downloadLink = this.DeappointmentCOS;
                this.downloadlabel = 'Deappointment Change of Supplier Bulk Template'
            }
            if(this.mode == 'CA'){
                this.downloadLink = this.DeappointmentCA;
                this.downloadlabel = 'Deappointment Change of Agent Bulk Template'
            }
            if(this.mode == 'CM'){
                this.downloadLink = this.DeappointmentCM;
                this.downloadlabel = 'Deappointment Customer Removed meter Bulk Template'
            }
            if(this.mode == 'COT'){
                this.downloadLink = this.DeappointmentCOT;
                this.downloadlabel = 'Deappointment Change of Tenancy Bulk Template'
            }
            if(this.mode == 'DE'){
                this.downloadLink = this.DeappointmentDE;
                this.downloadlabel = 'Deappointment Disconnection Bulk Template'
            }
            if(this.mode == 'DEMO'){
                this.downloadLink = this.DeappointmentDEMO;
                this.downloadlabel = 'Deappointment Demolition Bulk Template'
            }
            if(this.mode == 'DPL'){
                this.downloadLink = this.DeappointmentDPL;
                this.downloadlabel = 'Deappointment Duplicate Bulk Template'
            }
            if(this.mode == 'EOT'){
                this.downloadLink = this.DeappointmentEOT;
                this.downloadlabel = 'Deappointment End of Tenancy Bulk Template'
            }
        }
        if(this.action == 'Appointment'){
            if(this.mode == 'COS'){
                this.downloadLink = this.AppointmentCOS;
                this.downloadlabel = 'Appointment Change of Supplier Bulk Template'
            }
            if(this.mode == 'CA'){
                this.downloadLink = this.AppointmentCA;
                this.downloadlabel = 'Appointment Change of Agent Bulk Template'
            }
            if(this.mode == 'NEWCN'){
                this.downloadLink = this.AppointmentNEWCN;
                this.downloadlabel = 'Appointment New Connection Bulk Template'
            }
            if(this.mode == 'FIX'){
                this.downloadLink = this.AppointmentFIX;
                this.downloadlabel = 'Appointment New Meter Fitted Bulk Template'
            }
            if(this.mode == 'FNDAS'){
                this.downloadLink = this.AppointmentFNDAS;
                this.downloadlabel = 'Appointment Found Meter Bulk Template'
            }
        }
        if(this.action == 'Service Engineer Hire'){
            this.downloadLink = this.PEMSAndTSC;
            this.downloadlabel = 'Service Engineer Hire Template'
        }
        if(this.action == 'Post Emergency Meter Works'){
           this.downloadLink = this.PEMS; 
           this.downloadlabel = 'Post Emergency Meter Works Template'
        }
    }

    get showQ2(){
        return this.action === 'AMR' || this.action === 'Appointment' || this.action === 'Deappointment';
    }
   
validateBulkCsvInJs() {
  const errors = [];
  // Optional: enable case-insensitive comparison
  const normalize = (v) =>
    (v ?? '').toString().trim();
  const normalizeCase = (v) =>
    this.caseInsensitive ? normalize(v).toLowerCase() : normalize(v);
  // Precompute CRM group -> Set of codes
  const groupToCodeSet = {};
  if (this.isCrmUser) {
    for (const [rawGroup, codesArrOrSet] of Object.entries(this.supplierGroupCodeMap || {})) {
      const key = normalizeCase(rawGroup);
      let arr = Array.isArray(codesArrOrSet)
        ? codesArrOrSet
        : (codesArrOrSet instanceof Set ? Array.from(codesArrOrSet) : []);
      groupToCodeSet[key] = new Set(arr.map(normalizeCase));
    }
  } else {
    // Non-CRM: allowed codes set from options
    const options = (this.supplierCodeOptions || []).map(o => (o && o.value !== undefined ? o.value : o));
    this._nonCrmAllowedCodeSet = new Set(options.map(normalizeCase));
  }
  const currentUserGroupNorm = normalizeCase(this.supplierGroup);
  (this.bulkRecords || []).forEach((row, index) => {
    const rowNum = index + 2; // assuming row 1 is the header row
    const rawGroup = row?.['SupplierGroup'];
    const rawCodes = row?.['SupplierCode'];
    // Guard: missing essential fields
    if (rawGroup === undefined) {
      errors.push(`Row ${rowNum}: Missing "SupplierGroup" column or value`);
      return;
    }
    const group = normalizeCase(rawGroup);
    // ---- NON-CRM (GSM) USER ----
    if (!this.isCrmUser && group !== currentUserGroupNorm) {
      errors.push(
        `Row ${rowNum}: Non-CRM user cannot upload Supplier Group "${normalize(rawGroup)}"`
      );
      return;
    }
    // ---- CRM USER ----
    if (this.isCrmUser && !groupToCodeSet[group]) {
      errors.push(`Row ${rowNum}: Invalid Supplier Group "${normalize(rawGroup)}"`);
      return;
    }
    // ---- SUPPLIER CODE VALIDATION ----
    if (rawCodes) {
      // Support separators: ; or , just in case
      const parts = rawCodes.split(/[;,]/).map(normalizeCase).filter(Boolean);
      if (parts.length === 0) {
        // If empty after trimming, you may decide whether this is an error or not
        return;
      }
      // Select correct valid set
      const validSet = this.isCrmUser ? groupToCodeSet[group] : this._nonCrmAllowedCodeSet;
      parts.forEach((codeRaw) => {
        // codeRaw is already normalized & case-processed
        if (!validSet.has(codeRaw)) {
          // show original group/code in the message (un-normalized)
          errors.push(
            `Row ${rowNum}: Supplier Code "${codeRaw}" does not belong to "${normalize(rawGroup)}"`
          );
        }
      });
    } else {
    }
  });
  if (errors.length) {
    this.isBulkCsvValid = false;
    this.modalTitle = 'CSV Validation Failed';
    this.modalMessage = `Error in Validation:\n- ${errors.join('\n- ')}`;
    this.showModal = true;
    return;
  } else {
    this.isBulkCsvValid = true;
    this.modalTitle = 'CSV Validation Successful';
    this.modalMessage = 'All records are valid';
    this.showModal = true;
    return;
  }
}

    handleFileUpload(e) {
         const file = e.target.files[0];
         if (file) {
    this.fileName = file.name; // Set file name
    if (!file.name.toLowerCase().endsWith('.csv')) {

    this.modalTitle = 'Incorrect File Format';
    this.modalMessage = 'Please upload a CSV file';
    this.showModal = true;
    return;
}
         } else {
            this.fileName = null; // Reset if no file selected
}
        const reader = new FileReader();
        reader.onload = () => {
            this.parseCSV(reader.result);
            this.modalTitle = 'Success';
            this.modalMessage = 'File uploaded successfully';
            this.showModal = true;
            return;
        };
        reader.readAsText(e.target.files[0]);
    }
    
    parseCSV(csv) {
        const lines = csv.split('\n');   
        const headers = lines[0].split(',');    
        this.bulkRecords = lines
            .slice(1)
            .filter(l => l.trim())
            .map(line => {
                let obj = {};
                const values = line.split(',');
                headers.forEach((header, i) => {
                    obj[header.trim()] = values[i] ? values[i].trim() : '';
                });
                return obj;
            });        
    }
    getFieldLabel(field) {
        const labels = {
            firstName: 'First Name',
            lastName: 'Last Name',
            email: 'Email',
            role: 'Role',
            supplierGroup: 'Supplier Group',
            selectedSupplierCodes: 'Supplier Codes'
            //csvFile: 'CSV File'
        };
        return labels[field] || 'This field';
    }

    validateForm() {
         let isValid = true;
   const fields = this.template.querySelectorAll(
       'lightning-input, lightning-combobox , lightning-dual-listbox, lightning-radio-group'
   );
   fields.forEach(field => {
       // Force validation UI
       field.reportValidity();
       if (field.type === 'email') {
           const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
           if (!field.value) {
               field.setCustomValidity('Email is required');
               isValid = false;
           }
           else if (!emailRegex.test(field.value)) {
               field.setCustomValidity('Enter a valid email address');
               isValid = false;
           }
           else {
               field.setCustomValidity('');
           }
       }
       // Logical validation
       if (!field.checkValidity()) {
           isValid = false;
       }
   });
   return isValid;
}
    
    handleError(error) {
        let message = 'Unknown error';
        if(error?.body?.message) {
            message = error.body.message;
        } else if(error?.message) {
            message = error.message;
        }
        console.error('Apex Error => ', JSON.stringify(error));
        this.showToast('Error', message, 'error');
    }
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
    toast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
    handleBulkDeactivate() {
        bulkDeactivateUsers({
                userIds: this.selectedUserIds // MUST be Ids
            })
            .then(result => {
                if(result.length === 0) {

                } else {
                    this.modalTitle = 'User Deactivated';
                    this.modalMessage = `User Deactivated successfully `;
                    this.showModal = true;
                }
            })
            .catch(error => {
                this.modalTitle = 'Error';
                this.modalMessage = error.body?.message || 'Unknown error';
                this.showModal = true;
            });

    }
    handleConsentChange(event) {
        this.isChecked = event.target.checked;
        if(this.isChecked) {
            this.consentError = false;
        } else {
            this.formData.consent = true;
        }
    }
    
    resetForm() {
   const fields = this.template.querySelectorAll(
       'lightning-input, lightning-combobox, lightning-dual-listbox'
   );
   fields.forEach(f => {
       f.value = null;
       f.setCustomValidity('');
   });
   // existing resets...
}
    handleSupplierCodeMultiChange(event) {
        this.selectedSupplierCodes = [...event.detail.value]; // copy to trigger reactivity
        this.formData.supplierCode = this.selectedSupplierCodes.join(';');
    }
    resetSupplierCodes() {
        this.selectedSupplierCodes = [];
    }
    closeModal() {
        this.showModal = false;
    }

    validateJS(){    
        this.validationResult = {};
        if(this.action == 'AMR' ) {
            
            if(this.mode == 'Install'){
                const result = validateAMRInstallBulkUpload(this.bulkRecords, this.mandatoryColumnsInAMRInstall, {
                caseInsensitive: true,
                lineOffset: 2 // If CSV (header line is 1). Use 1 if plain array without headers.
                });          
                this.validationResult = result;
            }
            else if(this.mode == 'Remove'){              
            }
            else if(this.mode == 'Site Visit'){               
            }
        }       
        if(this.validationResult != null && this.validationResult != '' && this.validationResult != undefined){
            if(this.validationResult.rowErrors.length > 0){
                this.isBulkCsvValid = false;
                this.modalTitle = 'CSV Validation Failed';
                this.modalMessage = this.validationResult.rowErrors.map(e => `Row ${e.line}: Missing ${e.missing.join(', ')}`).join('\n');
                this.showModal = true;
                return;
            }
            else {
                this.isBulkCsvValid = true;
                this.modalTitle = 'CSV Validation Successful';
                this.modalMessage = 'All records are valid';
                this.showModal = true;
                return;
            }
        }
    }

    async handleSubmit(){
        if(!this.isChecked){
            this.consentError = true;
        }
        else{
            this.consentError = false;
            this.isLoading = true;
            if(this.action == 'AMR' || this.action == 'Appointment' || this.action == 'Deappointment'){
                try {
                        const payloadJson = JSON.stringify(this.bulkRecords); // your prepared list of records                       
                        const jobId = await startBulkProcess({ payloadJson : payloadJson,
                            action: this.action,
                            mode: this.mode, user : this.userId });
                            
                            this.modalTitle = 'Bulk Job Started';
                            //this.modalMessage = 'Async Apex Job Id: ' + jobId;
                            this.modalMessage = 'Request submitted successfully.'
                            this.showModal = true;
                            this.isLoading = false;
                } 
                catch (e) {    
                        console.log('Error in submission: ',JSON.stringify(e) )   ;                
                        this.modalTitle = 'Failed to start bulk job';
                        this.modalMessage = 'Error:: ' + JSON.stringify(e);
                        this.showModal = true; 
                        this.isLoading = false;   
                }       
                finally {                  
                }
            }
            else{    
                if (!this.base64Data) {
                    console.error('No file selected');
                    this.modalTitle = '';
                    this.modalMessage = 'No file selected';
                    this.showModal = true; 
                    this.isLoading = false;
                    return;
                }   
                uploadFile({
                    fileName: this.pemsTscFile,
                    base64Data: this.base64Data,
                    shortCode: this.selectedShortCode,
                    action: this.action
                })
                .then(result => {          
                    getRequest({ requestid: result })
                    .then(result => {
                        this.request = result;    
                        this.modalTitle = '';
                        this.modalMessage = 'Request ' + this.request.Name + ' has been created successfully';
                        this.showModal = true; 
                        this.isLoading = false;
                        return;
                    })
                    .catch(error => {    
                        this.request = null;
                        this.modalTitle = '';
                        this.modalMessage = 'Request could not be created';
                        this.showModal = true; 
                        this.isLoading = false;
                        return;
                    });
                })
                .catch(error => {   
                    this.request = null;
                    this.modalTitle = '';
                    this.modalMessage = 'Request could not be created';
                    this.showModal = true; 
                    this.isLoading = false;
                    return;    
                });
            }
        }
    }
    
    handleFileChange(event) {
        if (event.target.files.length > 0) {
            this.file = event.target.files[0]; 
            if (this.file.size > 3000000) {
                this.modalTitle = '';
                this.modalMessage = 'File size exceeds limit';
                this.showModal = true; 
                return;
            }
                this.pemsTscFile = this.file.name;
                const reader = new FileReader();
                reader.onload = () => {
                    let base64 = reader.result.split(',')[1];
                    this.base64Data = base64;
                };
                reader.readAsDataURL(this.file);
        }
    }
}