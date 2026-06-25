import { LightningElement, track } from 'lwc';
//import { createComplaint } from '@salesforce/apex/NGMCP_ComplaintController.createComplaint';
import createComplaint from '@salesforce/apex/NGMCP_ComplaintController.createComplaint';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NGMCP_PEMS from '@salesforce/resourceUrl/NGMCP_PEMS';
import NGMCP_U6 from '@salesforce/resourceUrl/NGMCP_U6';
import NGMCP_U6_U160 from '@salesforce/resourceUrl/NGMCP_U6_U160';
import NGMCP_MeterPickup from '@salesforce/resourceUrl/NGMCP_MeterPickup';
import NGMCP_PEMS_FLOW from '@salesforce/resourceUrl/NGMCP_PEMS_FLOW';
import NGMCP_Standard_Work_Req from '@salesforce/resourceUrl/NGMCP_Standard_Work_Req';
import CaseNumber from '@salesforce/schema/Case.CaseNumber';
import NGMCP_PJ001 from '@salesforce/resourceUrl/NGMCP_PJ001';
import NGMCP_Only_numbers from '@salesforce/label/c.NGMCP_Only_numbers';
import NGMCP_Maximum_length_10 from '@salesforce/label/c.NGMCP_Maximum_length_10';
import { NavigationMixin } from 'lightning/navigation';
const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB
export default class nGMCP_Complaint extends NavigationMixin(LightningElement) {
    @track uploadedFiles = [];          // UI list (images + CSVs)
    @track uploadedFilePayload = [];    // Payloads for images (and optional CSV)
    @track fileName = '';
    @track fileError
    @track q1;
    @track q2;
    @track q3;
    @track backHome;
    @track inputName = '';
    @track radioVal;
    @track caseType;
    @track NGMCP_mprn = '';
    @track textVal;
    @track message = '';
    @track base64Files = [];
    @track fileNames = [];
    @track inputHouse;
    @track inputStreet;
    @track inputTown;
    @track inputPostcode;
    @track inputEmail;
    @track inputPhone;
    @track showModal = false;
    @track modalTitle = '';
    @track modalMessage = '';
    @track isSuccess = false;
    @track isLoading = false;
    @track isSearchDisabled = true; 
    pageReference;
    //@track allcomplaints;
    pdfurl1 = NGMCP_PEMS;
    pdfurl2 = NGMCP_U6;
    pdfurl3 = NGMCP_U6_U160;
    pdfurl4 = NGMCP_MeterPickup;
    pdfurl5 = NGMCP_PEMS_FLOW;
    pdfurl6 = NGMCP_Standard_Work_Req;
    pdfurl7 = NGMCP_PJ001;
    @track downloadLink;
    @track downloadlabel;
    // navigateToObjectHome() {
    //     // Navigate to the Account home page
    //     this.pageReference = {
    //     type: 'comm__namedPage',
    //     attributes: {
    //         name: 'Case_List__c'        }
    // };
    // this[NavigationMixin.Navigate](this.pageReference);
    // // Navigate to the specified pagethis[NavigationMixin.Navigate](this.pageReference)
    // }
    //recordPageUrl;
    // connectedCallback() {
    //     // Generate a URL to a User record page
    //     this[NavigationMixin.GenerateUrl]({
    //         type: 'standard__recordPage',
    //         attributes: {
    //             recordId: '005B0000001ptf1IAE',
    //             actionName: 'view',
    //         },
    //     }).then((url) => {
    //         this.recordPageUrl = url;
    //     });
    // }
    clearFieldValidation(field) {
    field.setCustomValidity('');
    field.reportValidity();
    }
 
    get question1Options() {
        return [
            { label: 'None', value: 'None' },
            { label: 'Broken Appointment', value: 'Broken Appointment' },
            { label: 'Disconnection of Supply/Appliance', value: 'Disconnection of Supply/Appliance' },
            { label: 'Issue following NGM Work Request', value: 'Issue following NGM Work Request' },
            { label: 'Damage to Property', value: 'Damage to Property' },
            { label: 'Meter Exchange not recorded', value: 'Meter Exchange not recorded' },
            { label: 'Safety Issue', value: 'Safety Issue' },
            { label: 'Engineer Behavior', value: 'Engineer Behavior' },
            { label: 'NGM Staff Behavior', value: 'NGM Staff Behavior' }
        ];
    }
    get question2Options() {
        if (this.q1 === 'Select') {
            return [
                // { label: 'Select', value: 'Select' },
                { label: 'General Query', value: 'General Query' }
            ];
        } else if (this.q1 === 'Request For Information') {
            return [
                // { label: 'Select', value: 'Select' },
                { label: 'General Query', value: 'General Query' }
            ];
        } else if (this.q1 === 'Commercial Standard Work Request') {
            return [
                // { label: 'Select', value: 'Select' },
                { label: 'Standard Work-Install', value: 'Standard Work-Install', message: "Request for meter install for DD/MM/YY at HH:MM" },
                { label: 'Standard Work-Theft of Gas Exchange', value: 'Standard Work-Theft of Gas Exchange', message: " Request for Theft of Gas exchange for DD/MM/YY at HH:MM" },
                { label: 'Standard Work-Exchanges(NGM Meter or 3rd Party Meter)', value: 'Standard Work-Exchanges(NGM Meter or 3rd Party Meter)', message: " Request for 3rd party exchange request for DD/MM/YY at HH:MM" },
                { label: 'Replan Request-REPLAN', value: 'Replan Request-REPLAN', message: " Hi Team, Please replan the following; Job notification number: XXXXXXXXXX New date and time: DD/MM/YY at HH:MM" },
                { label: 'Standard Work-Pick-Up', value: 'Standard Work-Pick-Up', message: " Request for U16+ meter pick up for DD/MM/YY at HH:MM" },
                { label: 'Standard Work-Removal', value: 'Standard Work-Removal', message: " Request for meter removal for DD/MM/YY at HH:MM" },
                { label: 'Replan Request-NEW LINE', value: 'Replan Request-NEW LINE', message: "  Hi Team, Please raise a new line for the following; Job notification number: XXXXXXXXXX New date and time: DD/MM/YY at HH:MM" },
                { label: 'Change of Site Contact Details', value: 'Change of Site Contact Details', message: " Hi Team, Please update the following job with new site contact details as follows; Job notification number: New contact name: New contact number:" },
                { label: 'Standard Work-OFMAT', value: 'Standard Work-OFMAT', message: " Request for damage meter exchange for DD/MM/YY at HH:MM" }
            ];
        } else if (this.q1 === 'Metering Data Queries') {
            return [
                // { label: 'Select', value: 'Select' },
                { label: 'Correction Factor Query', value: 'Correction Factor Query', message: " Hi Team, Can you please check the correction factor for this site? Meter Point Reference Number: Annual Quantity: Current Correction Factor:" },
                { label: 'Missing ONJOB', value: 'Missing ONJOB', message: " Hi Team, Please can you send missing ONJOB for the following; MPRN: Job Reference:" },
                { label: 'Incorrect ONJOB', value: 'Incorrect ONJOB', message: " Hi Team, We have received an ONJOB from NGM that we believe to be incorrect. Please investigate and revert with your findings. ONJOB flow received: Please provide the correct flow as applicable." },
                { label: 'Request Job Card', value: 'Request Job Card', message: " Hi Team, Please can you send us the job card so we can update the exchange and correct the industry database. Meter Point Reference Number: Meter Serial Number:" },
                { label: 'Confirmation of MAM', value: 'Confirmation of MAM', message: " Hi Team, Please can you confirm you are the MAM for this meter. Meter Point Reference Number: Meter Serial Number:" }
            ];
        } 
        // else if (this.q1 === 'Engineer Hire' && this.q3 == 'Select') {
        //     return [
        //         { label: 'Select', value: 'Select' }]
        // }
        else if (this.q1 === 'Engineer Hire' && this.q3 == 'U6') {
            return [
                // { label: 'Select', value: 'Select' },
                { label: 'Timeslot Change', value: 'Timeslot Change', message: " Hi Team, Please amend timeslot for the attached as follows; From: To:" },
                { label: 'Whole-Run Cancellation', value: 'Whole-Run Cancellation', message: " Hi Team, Please cancel the attached booking as it is no longer required." },
                { label: 'Agent Change', value: 'Agent Change', message: " Hi Team, Please see attached agent change" },
                { label: 'Additional Job', value: 'Additional Job', message: " Hi Team, Please see the attached, the highlighted job is to be added to the run." },
                { label: 'New Requests', value: 'New Requests', message: " Hi Team, Please see attached new booking request." },
                { label: 'Single Job Cancellation', value: 'Single Job Cancellation', message: " Hi Team, Please cancel the job highlighted in yellow within the attached." },
                { label: 'Query', value: 'Query' }
            ];
        } else if (this.q1 === 'Engineer Hire' && this.q3 == 'U16') {
            return [
                // { label: 'Select', value: 'Select' },
                { label: 'Adversarial Work Request', value: 'Adversarial Work Request', message: " Hi Team, Please see attached a new adversarial booking request for; Date: DD/MM/YY Time: HH:MM Agent name: Agent contact number:" },
                { label: 'Adversarial Work Request-Update Agent Details', value: 'Adversarial Work Request-Update Agent Details', message: " Hi Team, Please update job with the below details: Job notification numbers: XXXXXXXXXX New agent details; Contact name: Contact number:" }
            ];
        } else if (this.q1 === 'Engineer Hire' && this.q3 == 'U25') {
            return [
                // { label: 'Select', value: 'Select' },
                { label: 'Adversarial Work Request', value: 'Adversarial Work Request', message: " Hi Team, Please see attached a new adversarial booking request for; Date: DD/MM/YY Time: HH:MM Agent name: Agent contact number:" },
                { label: 'Adversarial Work Request-Update Agent Details', value: 'Adversarial Work Request-Update Agent Details', message: " Hi Team, Please update job with the below details: Job notification numbers: XXXXXXXXXX New agent details; Contact name: Contact number:" }
            ];
        } else if (this.q1 === 'Engineer Hire' && (this.q3 == 'U40'|| this.q3 == 'U65')) {
            return [
                // { label: 'Select', value: 'Select' },
                { label: 'Adversarial Work Request', value: 'Adversarial Work Request', message: " Hi Team, Please see attached a new adversarial booking request for; Date: DD/MM/YY Time: HH:MM Agent name: Agent contact number:" },
                { label: 'Adversarial Work Request-Update Agent Details', value: 'Adversarial Work Request-Update Agent Details', message: " Hi Team, Please update job with the below details: Job notification numbers: XXXXXXXXXX New agent details; Contact name: Contact number:" },
            ];
        } else if (this.q1 === 'Engineer Hire' && this.q3 == 'U100') {
            return [
                // { label: 'Select', value: 'Select' },
                { label: 'Adversarial Work Request', value: 'Adversarial Work Request', message: " Hi Team, Please see attached a new adversarial booking request for; Date: DD/MM/YY Time: HH:MM Agent name: Agent contact number:" },
                { label: 'Adversarial Work Request-Update Agent Details', value: 'Adversarial Work Request-Update Agent Details', message: " Hi Team, Please update job with the below details: Job notification numbers: XXXXXXXXXX New agent details; Contact name: Contact number:" },
            ];
        } else if (this.q1 === 'Engineer Hire' && this.q3 == 'U160') {
            return [
                // { label: 'Select', value: 'Select' },
                { label: 'Adversarial Work Request', value: 'Adversarial Work Request', message: " Hi Team, Please see attached a new adversarial booking request for; Date: DD/MM/YY Time: HH:MM Agent name: Agent contact number:" },
                { label: 'Adversarial Work Request-Update Agent Details', value: 'Adversarial Work Request-Update Agent Details', message: " Hi Team, Please update job with the below details: Job notification numbers: XXXXXXXXXX New agent details; Contact name: Contact number:" },
            ];
         }
        else if (this.q1 === 'TFM') {
            return [
                { label: 'Update Required', value: 'Update Required' , message: " Hi Team, Please provide a status update (procuring parts/equipment, planned, requires further work etc.) on progress for the following job; Job notification number:" },
                { label: 'Replan Request-REPLAN', value: 'Replan Request-REPLAN' , message: " Hi Team, Please replan the following; Job notification number: XXXXXXXXXX New date and time: DD/MM/YY at HH:MM" }
            ];
        } else if (this.q1 === 'TQ') {
            return [
                { label: 'Update Required', value: 'Update Required', message: " Hi Team, Please provide a status update (procuring parts/equipment, planned, requires further work etc.) on progress for the following job; Job notification number:" },
                { label: 'Replan Request-REPLAN', value: 'Replan Request-REPLAN' , message: " Hi Team, Please replan the following; Job notification number: XXXXXXXXXX New date and time: DD/MM/YY at HH:MM" },
                { label: 'Replan Request-NEW LINE', value: 'Replan Request-NEW LINE', message: " Hi Team, Please raise a new line for the following; Job notification number: XXXXXXXXXX New date and time: DD/MM/YY at HH:MM" }
            ];
        } else if (this.q1 === 'Post Emergency Meter Exchange(PEMS)s') {
            return [
                { label: 'Residential', value: 'Residential', message: " Hi Team, Please see attached PEMs document and kindly send ONJOB flows for each one." },
                { label: 'Residential Ad-hocs', value: 'Residential Ad-hocs', message: " Hi Team, Please see attached PEMs document and kindly send ONJOB flows for each one." },
                { label: 'Commercial', value: 'Commercial', message: " Hi Team, Please see attached PEMs document and kindly send ONJOB flows for each one." }
            ];
        }
        return [];
    }
    get casetypeoptions() {
        return [
            { label: 'Complaint', value: 'Complaint' },
            { label: 'Issue', value: 'Issue' },
        ];
    }
    get question3options() {
        return [
            { label: 'MPRN', value: 'MPRN' },
            { label: 'Job Number', value: 'Job Number' },
            { label: 'N/A', value: 'N/A' }
        ];
    }
    get ResidenceOptions() {
        return [
            //{ label: 'Select', value: 'Select' },
            { label: 'Commercial', value: 'Commercial' },
            { label: 'Residential', value: 'Residential' }];
    }
    showQuestion2() {
        return this.q1 === 'Request For Information' || this.q1 === 'Commercial Standard Work Request' ||
            this.q1 === 'Metering Data Queries' || this.q1 === 'Engineer Hire' && this.q3 == 'Select' ||
            this.q1 === 'TFM' || this.q1 === 'TQ' || this.q1 === 'Post Emergency Meter Exchange(PEMS)s';
    }
    get showQuestion3() {
        if (this.q1 === 'Engineer Hire') {
            return [
                // { label: 'Select', value: 'Select' },
                { label: 'U6', value: 'U6' },
                { label: 'U16', value: 'U16' },
                { label: 'U25', value: 'U25' },
                { label: 'U40', value: 'U40' },
                { label: 'U65', value: 'U65' },
                { label: 'U100', value: 'U100' },
                { label: 'U160', value: 'U160' }
            ];
        }
    }
    titleOptions = [
        { label: 'Mr', value: 'Mr' },
        { label: 'Ms', value: 'Ms' },
        { label: 'Mrs', value: 'Mrs' },
        { label: 'Dr', value: 'Dr' }
    ];
    handleTitleChange(event) {
        this.clearFieldValidation(event.target);
        this.inputTitle = event.target.value;
    }
    // myComponent.js
    handleChangename(event) {
        this.clearFieldValidation(event.target);
        this.inputName = event.target.value;
        this.showPatternError = !event.target.validity.valid
        /* const value = event.target.value;
         const sanitizedValue = value.replace(/[^a-zA-Z\s]/g, '');
         this.inputName = sanitizedValue;
         // An alternative is to use this validation in a form submission handler
         const inputField = this.template.querySelector('lightning-input');
         if (inputField.checkValidity()) {
             // The input is valid, do something
         } else {
             inputField.reportValidity();
         }*/
    }
    handleChangephone(event) {
        this.clearFieldValidation(event.target);
        console.log('Phone input changed:', event.target.value);
        const input = event.target.value.trim();
        console.log('Phone input', input);
        // Remove all non-digit characters
        const onlyNumbers = input.replace(/\D/g, '');
        console.log('Phone input to:', onlyNumbers);
        // Update the phone property with cleaned input
        this.inputPhone = onlyNumbers;
        console.log('Phone input as', this.inputPhone);
        // Reference to the input field
        const inputField = event.target;
        // Validate: must be 10 or 11 digits only
        if (onlyNumbers.length >= 10 && onlyNumbers.length <= 11) {
            inputField.setCustomValidity(''); // Clear error
        } else {
            inputField.setCustomValidity('Phone number must be numberic and be 10 or 11 digits.');
        }
        inputField.reportValidity(); // Show error below the field
    }
    handleChangecode(event) {
        this.clearFieldValidation(event.target);
        console.log('code input1', event.target.value);
        const input = event.target.value.trim();
        // Remove all non-digit characters
        const onlyNumbers = input.replace(/\D/g, '');
        console.log('code input2', onlyNumbers);
        // Update the phone property with cleaned input
        this.inputPostcode = input;
        console.log('code input3', this.inputPostcode);
    }
    //     // Reference to the input field
    //     const inputField = event.target;
    //     // Validate: must be 10 
    //     if (onlyNumbers.length == 10 || onlyNumbers.length == 0) {
    //         inputField.setCustomValidity(''); // Clear error
    //     } else {
    //         inputField.setCustomValidity('');
    //     }
    //     inputField.reportValidity(); // Show error below the field
    // }
    handleChangeEmail(event) {
        this.clearFieldValidation(event.target);
        const input = event.target.value.trim();
        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(input)) {
            event.target.setCustomValidity("Please validate the Email Provided");
        } else {
            event.target.setCustomValidity(""); // Clear error
        }
        event.target.reportValidity();
        this.inputEmail = input;
    }
    handleChange(event) {
        this.clearFieldValidation(event.target);
        const { name, value } = event.target;
        this[name] = value;
        if (name === 'q1') {
            this.q2 = null;
            this.q3 = null;
            this.message = '';
            this.downloadLink = null;
        } else if (name === 'q3') {
            this.q2 = null;
            this.message = '';
            this.downloadLink = null;
        } else if (name === 'q2') {
            const selected = this.question2Options.find(opt => opt.value === value);
            this.message = selected && selected.message ? selected.message : '';
            // set download link based on mapping
            this.updateDownloadLink();
        }
    }
            /* ---------- GETTER ---------- */
           get hasUploadedFiles() {
               return this.uploadedFiles.length > 0;
           }
           /* ---------- BROWSE ---------- */
           handleBrowseClick() {
               this.template.querySelector('.file-input').click();
           }
           /* ---------- FILE SELECT ---------- */
            handleFileChange(event) {
                this.fileError = '';
                // if (!event.target.files || event.target.files.length === 0) return;
                const files = event.target.files;
                this.processFiles(files);
                // Clear so same file can be re-selected later
                event.target.value = '';
            }

           /* ---------- DRAG DROP ---------- */
           handleDragOver(event) {
               event.preventDefault();
           }
           handleDragLeave(event) {
               event.preventDefault();
           }
           handleFileDrop(event) {
               event.preventDefault();
               this.fileError = '';
               //if (!event.dataTransfer.files || event.dataTransfer.files.length === 0) return;
               this.processFiles(event.dataTransfer.files);
           }
           /* ---------- DELETE FILE ---------- */
           handleFileDelete(event) {
               const fileName = event.currentTarget.dataset.name;
               this.uploadedFiles =
                   this.uploadedFiles.filter(file => file.name !== fileName);
               this.uploadedFilePayload =
                   this.uploadedFilePayload.filter(file => file.name !== fileName);
           }
           /* ---------- MAIN FILE PROCESS ---------- */
           async processFiles(fileList) {
               this.fileError = '';
               if (!fileList || fileList.length === 0) return;
               const duplicateFiles = [];
               const oversizedFiles = [];
               const files = Array.from(fileList);
               const tasks = files.map(async file => {
                   /* Duplicate Check */
                   if (this.uploadedFiles.some(f => f.name === file.name)) {
                       duplicateFiles.push(file.name);
                       return;
                   }
                   /* Size Check */
                   if (file.size > MAX_FILE_SIZE) {
                       oversizedFiles.push(file.name);
                       return;
                   }
                   try {
                       const isImage = file.type.startsWith('image/');
                       let previewUrl = null;
                       let base64 = null;
                       if (isImage) {
                           previewUrl = await this.readFileAsDataURL(file);
                           base64 = previewUrl.split(',')[1];
                       } else {
                           const dataUrl = await this.readFileAsDataURL(file);
                           base64 = dataUrl.split(',')[1];
                       }
                       /* UI Object */
                       const uiFile = {
                           name: file.name,
                           size: file.size,
                           sizeDisplay: this.formatFileSize(file.size),
                           isImage,
                           previewUrl
                       };
                       /* Payload Object */
                       const payload = {
                           name: file.name,
                           type: file.type,
                           size: file.size,
                           base64
                       };
                       this.uploadedFiles = [...this.uploadedFiles, uiFile];
                       this.uploadedFilePayload = [...this.uploadedFilePayload, payload];
                   } catch (error) {
                       console.error(error);
                       this.showTemporaryError(`Error reading ${file.name}`);
                   }
               });
               await Promise.all(tasks);
               /* Error Handling */
               if (oversizedFiles.length) {
                   this.showTemporaryError(`Files exceed size limit: ${oversizedFiles.join(', ')}`);
               }
               if (duplicateFiles.length) {
                   this.showTemporaryError(`Duplicate files: ${duplicateFiles.join(', ')}`);
               }
           }
           /* ---------- FILE READER ---------- */
           readFileAsDataURL(file) {
               return new Promise((resolve, reject) => {
                   const reader = new FileReader();
                   reader.onload = () => resolve(reader.result);
                   reader.onerror = () => reject(reader.error);
                   reader.readAsDataURL(file);
               });
           }
           /* ---------- FILE SIZE FORMAT ---------- */
           formatFileSize(bytes) {
               if (bytes < 1024) return bytes + ' B';
               if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB';
               return (bytes / 1048576).toFixed(1) + ' MB';
           }
           /* ---------- ERROR ---------- */
           showTemporaryError(message) {
               this.fileError = message;
               setTimeout(() => {
                   this.fileError = '';
               }, 3000);
   }
   
    // update downloadLink based on q1 & q2 (mapping from your screenshot)
    updateDownloadLink() {
        this.downloadLink = null;
        // Commercial Standard Work Request -> many map to pdfurl6
        if (this.q1 === 'Commercial Standard Work Request' &&
            (this.q2 === 'Standard Work-Install' ||
                this.q2 === 'Standard Work-Theft of Gas Exchange' ||
                this.q2 === 'Standard Work-Exchanges(NGM Meter or 3rd Party Meter)' ||
                this.q2 === 'Replan Request-REPLAN' ||
                this.q2 === 'Standard Work-Removal' ||
                this.q2 === 'Replan Request-NEW LINE' ||
                this.q2 === 'Change of Site Contact Details' ||
                this.q2 === 'Standard Work-OFMAT')) {
            this.downloadLink = this.pdfurl6;
            this.downloadlabel = 'Blank Standard Work Request'
        }
        else if (this.q1 === 'Commercial Standard Work Request' && this.q2 === 'Standard Work-Pick-Up') {
            this.downloadLink = this.pdfurl3;
            this.downloadlabel = 'Blank Meter Pickup U6-U160'
        }
        else if (this.q1 === 'Engineer Hire' && this.q3 === 'U16') {
            this.downloadLink = this.pdfurl3;
            this.downloadlabel = 'Blank adversarial form U6-160'
        }
        else if (this.q1 === 'Engineer Hire' && (this.q3 === 'U6' ||
            this.q3 === 'U25' ||
            this.q3 === 'U40' ||
            this.q3 === 'U65' ||
            this.q3 === 'U100' ||
            this.q3 === 'U160')) {
            this.downloadLink = this.pdfurl2;
            this.downloadlabel = 'Blank adversarial form U6'
        }
        // Post Emergency -> pdfurl5
        else if (this.q1 === 'Post Emergency Meter Exchange(PEMS)s' &&
            (this.q2 === 'Residential' || this.q2 === 'Residential Ad-hocs' || this.q2 === 'Commercial')) {
            this.downloadLink = this.pdfurl5;
            this.downloadlabel = 'Blank PEMS Flow'
        }
    }
    NGMCP_handlemprnChanges(event) {
        const inputval = event.target.value;
        if(this.radioVal == 'MPRN'){
            this.NGMCP_mprn = inputval;
        }
        else if(this.radioVal == 'Job Number'){
            this.CRM_Related_Job_Number__c = inputval;
        }else if(this.radioVal == 'N/A'){ 
            this.NGMCP_mprn = '';
            this.CRM_Related_Job_Number__c = '';
        }
        console.log('Radio value:', this.radioVal);
        console.log('Handler fired');
        console.log('Input value:', event.target.value);
        console.log('Updated MPRN:', this.NGMCP_mprn);
    }
    validateMPRN() {
        this.NGMCP_errorMessage = "";
        const NGMCP_regex = /^[0-9]+$/; // only numbers
        let errors = [];
        // Rule 1: Cannot start with 0
        // if (this.NGMCP_mprn.startsWith("0")) {
        //   errors.push(
        //     NGMCP_Cannot_start_with_0
        //   );
        // }
        // Rule 2: Cannot start with space
        // if (this.NGMCP_mprn.startsWith(" ")) {
        //   errors.push(
        //     NGMCP_Cannot_start_with_space
        //   );
        // }
        // Rule 3: Cannot end with space
        // if (this.NGMCP_mprn.endsWith(" ")) {
        //   errors.push(
        //     NGMCP_Cannot_end_with_space
        //   );
        // }
        // Rule 4: Only numbers
        if (
            !NGMCP_regex.test(this.NGMCP_mprn) &&
            !this.NGMCP_mprn.startsWith(" ") &&
            !this.NGMCP_mprn.endsWith(" ")
            && this.NGMCP_mprn.length > 0) {
            errors.push(
                NGMCP_Only_numbers
            );
        }
        // Rule 5: Maximum length 10
        if (this.NGMCP_mprn.length > 10) {
            errors.push(NGMCP_Maximum_length_10);
        }
        // if (this.NGMCP_mprn.length == 0) {
        //   errors.push("Please enter MPRN");
        // }
        // Combine all error messages
        const uniqueErrors = [...new Set(errors)];
        this.NGMCP_errorMessage = uniqueErrors.join("\n");
        if (this.NGMCP_errorMessage) {
            return false;
        } else {
            return true;
        }
    }
    openPdfInNewTab() {
        if (this.downloadLink) {
            window.open(this.downloadLink, '_blank');
        }
    }
    openPreviousComplaints() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'list'
            },
            state: {
                filterName: "Recent",
            },
        });
    }
    handleCancel(){
    this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
            name: 'Home' 
        }
    });

    }
    async handleSubmit() {
        const allInputs = this.template.querySelectorAll(
            'lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group'
        );
        let allValid = true;
        allInputs.forEach(input => {
            // only validate fields that are visible and required
            if (input.required && input.offsetParent !== null) {
                input.reportValidity();
                if (!input.checkValidity()) {
                    allValid = false;
                }
            }
        });

       /* if (this.showQuestion2 && this.uploadedFilePayload.length === 0) {
        this.fileError = 'Please upload at least one file.';
        return;
        } else {
        this.fileError = '';
        }*/

        //this.isSearchDisabled = !allValid;
        if (!allValid) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Missing Information',
                    message: 'Please fill in all mandatory fields before submitting.',
                    variant: 'error'
                })
            );
            return;
        }
        this.isLoading = true;
        console.log('Mprn****' + this.NGMCP_mprn);
        const payload = {
            RecordType: this.caseType,
            Case_Type__c: this.caseType,
            CRM_Complaint_Subject__c: this.q1,
            // Sub_Category__c: this.q2,
            CRM_MPRN__c: this.NGMCP_mprn,
            CRM_Related_Job_Number__c: this.CRM_Related_Job_Number__c,
            Description: this.textVal,
            CRM_House_Name_Number_Site_Name__c: this.inputHouse,
            CRM_Street__c: this.inputStreet,
            CRM_City_County__c: this.inputCity,
            CRM_Post_code__c: this.inputPostcode,
            CRM_End_Consumer_Title__c: this.inputTitle,
            CRM_End_Consumer_Name__c: this.inputName,
            CRM_End_Consumer_Contact_Number__c: this.inputPhone,
            CRM_End_Consumer_Email_Address__c: this.inputEmail,
            CRM_Commercial_Residential__c: this.inputResidence,
            //CRM_MPRN__c: this.NGMCP_mprn
        };
        console.log('payload', JSON.stringify(payload));
        this.base64Files = this.uploadedFilePayload.map(f => f.base64);
        this.fileNames = this.uploadedFilePayload.map(f => f.name);
        try {
            const result = await createComplaint({
                answers: JSON.stringify(payload),
                base64Files: this.base64Files,
                fileNames: this.fileNames
            });
            console.log('Case Details' , JSON.stringify(result));
            this.isLoading = false;
           // console.log('Complaint created successfully. ID: ' +this.getValue(CaseNumber));
            if (result) {
                this.isLoading = false;
                this.isSuccess = true;
                this.modalTitle = 'Complaint Created';
                if (this.caseType === 'Complaint') {
                this.modalTitle = 'Complaint Created';
                this.modalMessage = `Complaint created successfully. Case ID: ${result}`;
                } else if (this.caseType === 'Issue') {
                this.modalTitle = 'Issue Created';
                this.modalMessage = `Issue created successfully. Case ID: ${result}`;
                }
                // if(this.caseType == 'Complaint'){
                //     this.modalTitle = 'Complaint Created';
                //     this.modalMessage = `Complaint created successfully. Case ID: ${result}`;
                // }elseif(this.caseType == 'Issue'){
                //     this.modalTitle = 'Issue Created';
                //     this.modalMessage = `Issue created successfully. Case ID: ${result}`;
                // }
                //this.modalMessage = `Complaint created successfully. Case ID: ${result}`;
                this.showModal = true;
            }
            this.resetForm();
        } catch (error) {
            console.error('Error creating complaint:', error);
            this.isLoading = false;
            this.isSuccess = false;
            this.modalTitle = 'Error';
            this.modalMessage = 'Failed to create complaint. Please try again.';
            this.showModal = true;
        }
    }
    resetForm() {
        // Reset UI fields
        const fields = this.template.querySelectorAll(
            'lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group'
        );
        fields.forEach(field => {
            field.value = null;
        });
        // Reset standard field inside lightning-record-edit-form
        const recordForm = this.template.querySelector('lightning-record-edit-form');
        if (recordForm) {
            recordForm.reset();
        }
        // Reset JS variables
        this.name = '';
        this.email = '';
        this.phone = '';
        this.address = '';
        this.fileDataList = [];
        this.fileNameList = [];
        this.uploadedFiles = [];
        this.uploadedFilePayload = [];
        this.base64Files = [];
        this.fileNames = [];
    }
    closeModal() {
        this.showModal = false;
        this.NGMCP_mprn = '';
        this.CRM_Related_Job_Number__c = '';
    }
}