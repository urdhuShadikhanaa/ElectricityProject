import {LightningElement,track,wire} from 'lwc';
import getLoggedInUserProfile from '@salesforce/apex/NGMCP_UserManagmentController.getLoggedInUserProfile';
import getAllSupplierGroups from '@salesforce/apex/NGMCP_UserManagmentController.getAllSupplierGroups';
//import getSupplierCodesByGroup from '@salesforce/apex/NGMCP_UserManagmentController.getSupplierCodesByGroup';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import processSingleRequest from '@salesforce/apex/NGMCP_UserManagmentController.processSingleRequest';
import processBulkCSV from '@salesforce/apex/NGMCP_UserManagmentController.processBulkCSV';
import NGMCPCreateBulk from '@salesforce/resourceUrl/NGMCPCreateBulk';
import NGMCPDeactivateBulk from '@salesforce/resourceUrl/NGMCPDeactivateBulk';
import NGMCPChangeBulk from '@salesforce/resourceUrl/NGMCPChangeBulk';
import getSupplierCodesForLoggedInUser from '@salesforce/apex/NGMCP_UserManagmentController.getSupplierCodesForLoggedInUser';
import getUserSupplierCodesForGroup from '@salesforce/apex/NGMCP_UserDependentPicklistController.getUserSupplierCodesForGroup';
import groupValuesforCRM from '@salesforce/apex/NGMCP_UserManagmentController.groupValuesforCRM';

export default class NGMCP_BulkRequest extends LightningElement {

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
    supplierGroupCodeMap = {}; // { supplierGroup : Set(supplierCodes) }
    //isTermsAccepted = false;
    bulkRecords = [];
    profileName;
    BulkDeactivate = NGMCPDeactivateBulk;
    BulkChange = NGMCPChangeBulk;
    BulkCreate = NGMCPCreateBulk;
    isSubmitDisabled = true;
    @track isCrmUser = false;
    @track supplierGroup;
    @track supplierGroupOptions = [];
    @track supplierCodeOptions = [];
    @track isLoading = false;
    @wire(getLoggedInUserProfile)
    wiredProfile({
        data,
        error
    }) {
        if(data) {
            this.profileName = data;
        } else if(error) {
            console.error(error);
        }
    }


actionOptions = [
        { label: 'AMR', value: 'AMR' },
        { label: 'Appointment', value: 'Appointment' },
        { label: 'Deappointment', value: 'Deappointment' }
    ];

    modeOptions = [
        { label: 'Single', value: 'Single' },
        { label: 'Bulk', value: 'Bulk' }
    ];

roleOptions = [
    { label: 'Agent', value: 'Agent' },
    { label: 'Manager', value: 'Manager' }
  ];

    connectedCallback() {
        this.init();
        getSupplierCodesForLoggedInUser()
            .then(result => this.supplierCodes = result);
    }

    async init() {
        const context = await getLoggedInUserProfile();
        this.isCrmUser = context.isCrmUser;
        if(this.isCrmUser) {
            await this.preloadSupplierGroupCodeMap();
            const groups = await getAllSupplierGroups();
            this.supplierGroupOptions = [{
                    label: '— None —',
                    value: ''
                },
                ...groups.map(g => ({
                    label: g,
                    value: g
                }))
            ];

        } else {
            this.supplierGroup = context.supplierGroup;
            this.loadSupplierCodesForUser();
        }
    }

    async preloadSupplierGroupCodeMap() {
        const groups = await getAllSupplierGroups();
        for(let group of groups) {
            const options = await groupValuesforCRM({
                suppliergroup: group
            });
            this.supplierGroupCodeMap[group] =
                new Set((options || []).map(o => o.value));
        }
    }

    async handleSupplierGroupChange(event) {
        this.supplierGroup = event.detail.value;
        this.formData.supplierGroup = this.supplierGroup;
        this.isLoading = true;
        console.log('this.supplierGroup', this.supplierGroup);
        console.log('handleSupplierGroupChangecalling');

        try {
            //console.log('dummy',dummy);)
            // Invoke Apex with the selected group label (UI uses labels by default)
            const options = await groupValuesforCRM({
                suppliergroup: this.supplierGroup
            });

            // Apex already returns [{label, value}] suitable for lightning-dual-listbox
            this.supplierCodeOptions = options || [];

            // Keep only selections that are still valid after the change
            const valid = new Set(this.supplierCodeOptions.map(o => o.value));
            this.selectedSupplierCodes = (this.selectedSupplierCodes || []).filter(v => valid.has(v));
        } catch (e) {
            // console.error(e);
            this.supplierCodeOptions = [];
        } finally {
            this.isLoading = false;
        }
    }
    async loadSupplierCodesForUser() {
        const codes = await getSupplierCodesForLoggedInUser();
        this.supplierCodeOptions = codes.map(c => ({
            label: c.trim(),
            value: c.trim()
        }));
    }
    handleActionChange(e) {
        this.action = e.target.value;
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
        //this.resetConsent();
        //this.updateDownloadLink();
        //this.resetSupplierCodes();
    }
    handleModeChange(e) {
        this.mode = e.target.value;
        this.bulkRecords = [];
        //this.resetConsent();
        this.resetSupplierCodes();
        this.updateDownloadLink();
    }
    openPdfInNewTab() {
        if(this.downloadLink) {
            window.open(this.downloadLink, '_blank');
        }
    }

    updateDownloadLink() {
        this.downloadLink = null;
        console.log('this.action', this.action);
        console.log('this.mode', this.mode);
        if(this.action == 'Create' && this.mode == 'Bulk') {
            this.downloadLink = this.BulkCreate;
            this.downloadlabel = 'Create Users  Bulk Template'
        } else if(this.action == 'Deactivate' && this.mode == 'Bulk') {
            this.downloadLink = this.BulkDeactivate;
            this.downloadlabel = 'Deactivate Users  Bulk Template'

        } else if(this.action == 'Change' && this.mode == 'Bulk') {
            this.downloadLink = this.BulkChange;
            this.downloadlabel = 'Change Users  Bulk Template'

        }
    }

    handleChange(e) {
        this.formData[e.target.dataset.field] = e.target.value;
    }
    get showQ2(){
        return this.action === 'Create' || this.action === 'Deactivate' || this.action === 'Change';
    }
    get showCreate() {
        return this.action === 'Create' && this.mode === 'Single';
    }
    get isCRMProfile() {
        return this.profileName === 'CRM';
    }
    get showDeactivate() {
        return this.action === 'Deactivate' && this.mode === 'Single';
    }
    get showChange() {
        return this.action === 'Change' && this.mode === 'Single';
    }
    get showBulk() {
        return this.mode === 'Bulk';
    }
    showError(message) {
                    this.modalTitle = 'Validation Error';
                    this.modalMessage = message;
                    this.showModal = true;
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
      // If SupplierCode is mandatory, flag it; otherwise skip
      // errors.push(`Row ${rowNum}: Missing Supplier Code`);
    }
  });

  if (errors.length) {
    this.isBulkCsvValid = false;
    // Keep records for debugging; comment the next line during dev
    // this.bulkRecords = [];
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
         } else {
            this.fileName = null; // Reset if no file selected
}
        const reader = new FileReader();
        reader.onload = () => {
            this.parseCSV(reader.result);
            this.validateBulkCsvInJs();
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
    //     let isValid = true;
    //     // Validate native inputs & select
    //     const fields = this.template.querySelectorAll(
    //         'input, select, lightning-combobox, lightning-dual-listbox, lightning-radio-group'
    //     );
    //     fields.forEach(field => {
    //         field.setCustomValidity('');
    //         const fieldName = field.dataset.field;
    //         if(field.required && !field.value) {
    //             field.setCustomValidity(
    //                 `${this.getFieldLabel(fieldName)} is required`
    //             );
    //         }
    //         if(field.type === 'email' && field.value) {
    //             const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    //             if(!emailRegex.test(field.value)) {
    //                 field.setCustomValidity('Enter a valid email address');
    //             }
    //         }
    //         if(!field.checkValidity()) {
    //             field.reportValidity();
    //             isValid = false;
    //         }
    //     });
    //     return isValid;
    // }
    handleSubmit() {
        if(this.mode === 'Bulk' && !this.isBulkCsvValid) {
            this.modalTitle = 'Validation Required';
            this.modalMessage = `Please upload a valid CSV before submitting`;
            this.showModal = true;
            return;
        }
        
const isValid = this.validateForm();
        if (!isValid) {
            // Stop here if invalid
            this.isLoading = false;
            return;
        }
        // ... carry on with submit logic, apex call, etc.
        this.isLoading = true;
        if(this.mode === 'Bulk') {
            processBulkCSV({
                    recordsJson: JSON.stringify(this.bulkRecords),
                    actionType: this.action
                })
                .then(errors => {
                    if(errors && errors.length > 0) {
                        this.showToast(
                            'Bulk Errors',
                            errors.join(' | '),
                            'error'
                        );
                    } else {
                        this.isLoading = false;
                        console.log('this.action', this.action);
                        switch(this.action.trim()) {
                        case 'Deactivate':
                            this.modalTitle = 'User Deactivated';
                            this.modalMessage = 'User Deactivated successfully';
                            break;
                        case 'Change':
                            this.modalTitle = 'User Changed';
                            this.modalMessage = 'User changed successfully.';
                            break;
                        default:
                            this.modalTitle = 'User Created';
                            this.modalMessage = 'User created successfully.';
                            break;
                        }

                        this.showModal = true;
                    }
                })
                .catch(error => {
                    this.isLoading = false;
                    this.handleError(error);
                });
            return;
        }

        processSingleRequest({
                actionType: this.action,
                formDetails: JSON.stringify(this.formData)
            })
            .then(userId => {
                this.isLoading = false;
                console.log('this.action', this.action);
                switch(this.action.trim()) {
                case 'Deactivate':
                    this.modalTitle = 'User Deactivated';
                    this.modalMessage = 'User Deactivated successfully';
                    break;
                case 'Change':
                    this.modalTitle = 'User Changed';
                    this.modalMessage = 'User changed successfully.';
                    break;
                default:
                    this.modalTitle = 'User Created';
                    this.modalMessage = 'User created successfully.';
                    break;
                }

                this.showModal = true;
            })
            .catch(error => {
                this.isLoading = false;
                this.handleError(error);
            });
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
        const isChecked = event.target.checked;
    }
    // resetConsent() {
    //     this.isChecked = '';
    //     this.formData.consent = '';
    // } 
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
}