import { LightningElement, track, api,wire } from "lwc";
//import submitUrgentWorkRequest from '@salesforce/apexContinuation/NGMCP_IBMMaximoIntegrationClass.submitUrgentWorkRequest';
import submitUrgentWorkRequest from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.submitUrgentWorkRequest";
import createUrgentWorkRequestRecord from "@salesforce/apex/NGMCP_RequestObjectClass.createUrgentWorkRequestRecord";
import getHolidays from '@salesforce/apex/NGMCP_HolidaysService.getHolidaysBetween';

export default class NGMCP_CreateJobRequest extends LightningElement {
  @track selectedTitle = "";
     
  @api metadataRecord;
  @api assetDetails = [];     // Array expected
   @api addressDetails = {};   // Can come as object from parent
   @api status;
   @api paymentMechanism;

     @track showWindOnOption = false;
  @track urgentOptions = [];
  @track selectedValue;
  @track jobTypes = [];
  @track selectedJobType = false;
  @track showJobType = false;
  @track showAppointment = false;
  @track showcontactdetails = false;
  @track isLoading = false;
  @track contactDetails = {
    title: "",
    name: "",
    contactNumber: "",
    instructions: "",
    consent: false,
  };
  reportedpriority = 1;
  job_type;
  affectedphone;
  description_longdescription;
  job_subtype;
  targetstart;
  ngme_time;
  source = "PORTAL";
  job_sub_subtype;
  ngme_liferay_slot = 'AT';
  ngme_industry;
  assetnum;
  suppliercode;
  location;
  affectedperson;
   @track showAppointmentFields = false;
    @track showAllAsset = false;

    @track showAllAddress = false;

   @track showAppointmentSlots = false;

   @track selectedDate;
    @track appointmentOptions = [];
    holidays = [];
    
   @track startOptions = [{
   label: 'Start now',
   value: 'now',
   isChecked: false,
   className: 'radio-card'
}, {
   label: 'Pick date & time',
   value: 'pick',
   isChecked: false,
   className: 'radio-card'
}, {
   label: 'Restrospective',
   value: 'later',
   isChecked: false,
   className: 'radio-card'
}];
residentialSlots = [{
   code: 'S1',
   timeframe: '08:00 - 11:00'
}, {
   code: 'S2',
   timeframe: '10:00 - 13:00'
}, {
   code: 'S3',
   timeframe: '12:00 - 15:00'
}, {
   code: 'S4',
   timeframe: '14:00 - 17:00'
}, {
   code: 'S5',
   timeframe: '16:00 - 19:00'
}, {
   code: 'S6',
   timeframe: '18:00 - 21:00'
}];
commercialSlots = [{
   code: 'S1',
   timeframe: '08:00 - 12:00'
}, {
   code: 'S2',
   timeframe: '10:00 - 14:00'
}, {
   code: 'S3',
   timeframe: '12:00 - 16:00'
}, {
   code: 'S4',
   timeframe: '14:00 - 18:00'
}, {
   code: 'S5',
   timeframe: '16:00 - 20:00'
}];
@track availableSlots = [];
@track showPickDateSection = false;
@track appointmentDate = '';
@track selectedSlot = '';
@track slotOptions = [];
@track showBankCalender = false;

// --- Residential (Weekday) Slots ---
    residentialWeekdaySlots = [
        { label: '08:00 - 11:00', value: 'S1' },
        { label: '10:00 - 13:00', value: 'S2' },
        { label: '12:00 - 15:00', value: 'S3' },
        { label: '14:00 - 17:00', value: 'S4' },
        { label: '16:00 - 19:00', value: 'S5' },
        { label: '18:00 - 21:00', value: 'S6' }
    ];

    // --- Commercial & Residential (Weekend / Holiday) Slots ---
    commercialAndWeekendSlots = [
        { label: '08:00 - 12:00', value: 'S1' },
        { label: '10:00 - 14:00', value: 'S2' },
        { label: '12:00 - 16:00', value: 'S3' },
        { label: '14:00 - 18:00', value: 'S4' },
        { label: '16:00 - 20:00', value: 'S5' } // assuming last slot typo (16:00–20:00)
    ];

    @wire(getHolidays)
    wiredHolidays({ data, error }) {
        if (data) {
            this.holidays = data.map(h => h.ActivityDate.split('T')[0]);
        } else if (error) {
            console.error('Error fetching holidays:', error);
        }
    }

    handleStatusChange(event) {
        this.status = event.detail.value;
        this.updateAppointmentSlots();
    }
    
    handleSlotChange(event) {
        this.selectedSlot = event.detail.value;
    }


  handleDateChange(event) {
        const selectedDate = event.detail.date;
        this.selectedDate = selectedDate;
        this.updateAppointmentSlots();
    }

    updateAppointmentSlots() {
        // Check that both status and date are available
        if (!this.selectedDate || !this.status) {
            this.appointmentOptions = [];
            return;
        }

        const statusLower = this.status.toLowerCase();
        const selected = new Date(this.selectedDate);
        const day = selected.getDay(); // 0 = Sunday, 6 = Saturday
        const isWeekend = (day === 0 || day === 6);

        // Normalize date formats for holiday comparison
        const selectedDateOnly = selected.toISOString().split('T')[0];
        const isHoliday = this.holidays.some(h => h === selectedDateOnly);
        // --- Main Logic ---
        if (statusLower === 'residential') {
            if (!isWeekend && !isHoliday) {
                this.appointmentOptions = this.residentialWeekdaySlots;
            } else {
                this.appointmentOptions = this.commercialAndWeekendSlots;
            }
        } else if (statusLower === 'commercial') {
            this.appointmentOptions = this.commercialAndWeekendSlots;
        } else {
            this.appointmentOptions = [];
        }
    }

handleStartChange(event) {
   const selectedValue = event.currentTarget.dataset.value;
   this.startOptions = this.startOptions.map(opt => ({
      ...opt,
      isChecked: opt.value === selectedValue,
      className: opt.value === selectedValue ? 'radio-card selected' : 'radio-card'
   }));
   if (selectedValue === 'pick') {
      this.showAppointmentSlots = true;
      this.loadSlots();
   } else {
      this.showAppointmentSlots = false;
   }
}
loadSlots() {
   const categoryType = this.category ? this.category.toLowerCase() : '';
   if (categoryType === 'residential') {
      this.availableSlots = this.residentialSlots;
   } else if (categoryType === 'commercial') {
      this.availableSlots = this.commercialSlots;
   } else {
      this.availableSlots = [];
   }
}
    
    // Visible subset for expand/collapse

     // ---- Asset Section ----
  get assetArray() {
     return Array.isArray(this.assetDetails) ? this.assetDetails : [];
  }

  get displayedAssetDetails() {
     return this.showAllAsset ? this.assetArray : this.assetArray.slice(0, 5);
  }

  get hasMoreAssetDetails() {
     return this.assetArray.length > 5;
  }

  get assetArrowClass() {
     return this.showAllAsset ? 'arrow down' : 'arrow right';
  }

  get assetToggleText() {
     return this.showAllAsset ? 'Less details' : 'More details';
  }

  toggleAssetExpand() {
     this.showAllAsset = !this.showAllAsset;
  }

  // ---- Address Section ----
  get addressArray() {
     // If array already, return directly
     if (Array.isArray(this.addressDetails)) {
        return this.addressDetails;
     }

     // If object, convert to array of {label, value}
     if (this.addressDetails && typeof this.addressDetails === 'object') {
        return Object.keys(this.addressDetails).map(key => ({
           label: this._toLabel(key),
           value: this.addressDetails[key] || ''
        }));
     }

     return [];
  }

  get displayedAddressDetails() {
     return this.showAllAddress ? this.addressArray : this.addressArray.slice(0, 5);
  }

  get hasMoreAddressDetails() {
     return this.addressArray.length > 5;
  }

  get addressArrowClass() {
     return this.showAllAddress ? 'arrow down' : 'arrow right';
  }

  get addressToggleText() {
     return this.showAllAddress ? 'Less details' : 'More details';
  }

  toggleAddressExpand() {
     this.showAllAddress = !this.showAllAddress;
  }

  handleCancel() {
     this.dispatchEvent(new CustomEvent('canceljob'));
  }

  // Helper: Convert camelCase / snake_case to Title Case
  _toLabel(key) {
     if (!key) return '';
     const spaced = key
        .replace(/_/g, ' ')
        .replace(/([a-z0-9])([A-Z])/g, '$1 $2');
     return spaced
        .split(' ')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ');
  }
  
  connectedCallback() {
    this.appointmentOptions  = this.status;
    const data = this.metadataRecord[0].metadatalist;
    this.assetnum = this.metadataRecord[0].assetnum;
    this.suppliercode = this.metadataRecord[0].suppliercode;
    this.location = this.metadataRecord[0].location;
    this.ngme_industry = this.metadataRecord[0].ngme_industry;
    this.jobTypes = data.map((item) => ({
      value: item.NGMCP_UWR_Job_Code__c,
      label: item.NGMCP_Portal_Category__c,
      description: `${item.NGMCP_Portal_Category__c} - ${item.NGMCP_Meter_Model_Size__c} (${item.NGMCP_Market_Sector_Code__c})`,
    }));
    if (this.jobTypes.length === 1) {
      this.selectedJobType = true;
      this.job_sub_subtype = this.jobTypes[0].value;
    }
  }
  requestTypes = [
   

    {
      value: "dq",
      label: "Data Query",
      desc: "To Raised data query to commercial and residential customer.",
    },
     
    
  ];

  DqTypes = [

   {
      value: "FME",
      label: "Found Meter Enquiry",
      desc: "An ordinary request with several jobs type to choose from",},

      
    {
      value: "MSE",
      label: "Ad-Hoc",
      desc: "An ordinary request with several jobs type to choose from",
    },

    {
      value: "ADE",
      label: "Asset Data Enquiry",
      desc: "An ordinary request with several jobs type to choose from",},

      {
      value: "AME",
      label: "Address Amendment Enquiry",
      desc: "An ordinary request with several jobs type to choose from",},

      

      {
      value: "CME",
      label: "Crossed Meter Enquiry",
      desc: "An ordinary request with several jobs type to choose from",
    },

    {
      value: "RME",
      label: "Replicated Meter Enquiry",
      desc: "An ordinary request with several jobs type to choose from",
    },
    

      

];


    // Sub-types by DQ type (edit as you need; 4–5 options per type)
  dqSubTypeConfig = {
   // MSE: [
   //   { value: 'reading_validation',  label: 'Reading Validation',  desc: 'Validate last / current readings' },
    //  { value: 'msn_verification',    label: 'MSN Verification',    desc: 'Confirm meter serial number' },
    //  { value: 'service_state',       label: 'Service State',       desc: 'In-service / Decommission status' },
    //  { value: 'site_visit_required', label: 'Site Visit Required', desc: 'Technician inspection required' }
   // ],
    ADE: [
      { value: 'Missing Exchange',            label: 'Missing Exchange',            desc: 'Update after exchange' },
      { value: 'Missing Removal',             label: 'Missing Removal',             desc: 'Update after removal' },
      { value: 'Correction Factor Challenge',   label: 'Correction Factor Challenge',   desc: 'Fix mismatched asset data' },
      { value: 'Incorrect Asset Details', label: 'Incorrect Asset Details', desc: 'Update make/model' }
    ],
   // AME: [
    //  { value: 'address_line_update', label: 'Address Line Update', desc: 'Update address lines' },
    //  { value: 'postcode_correction', label: 'Postcode Correction', desc: 'Fix postcode' },
    //  { value: 'geo_mismatch',        label: 'Geo Mismatch',        desc: 'Resolve geolocation mismatch' }
    //],
    //FME: [
    //  { value: 'found_asset_claim',   label: 'Found Asset Claim',   desc: 'Report an unexpected found meter' },
    //  { value: 'asset_linking',       label: 'Asset Linking',       desc: 'Link found meter to premise' },
     // { value: 'ownership_check',     label: 'Ownership Check',     desc: 'Verify meter ownership' }
    //],
    //CME: [
     // { value: 'swap_validation',     label: 'Swap Validation',     desc: 'Validate crossed meter swap' },
     // { value: 'billing_alignment',   label: 'Billing Alignment',   desc: 'Align billing account to meter' },
     // { value: 'site_investigation',  label: 'Site Investigation',  desc: 'Field verification required' }
    //],
    //RME: [
    //  { value: 'duplicate_serial',    label: 'Duplicate Serial',    desc: 'Two meters share one serial' },
     // { value: 'record_dedup',        label: 'Record Deduplication',desc: 'Clean duplicate meter records' },
    //  { value: 'asset_merge',         label: 'Asset Merge',         desc: 'Merge replicated assets' }
    //]
  };

  // Will be filled based on selected DQ type
  @track SubDqTypes = [];

// --------------------------
// 2) State
// --------------------------
@track selectedRequestType = '';
@track selectedDqType = '';
@track selectedSubDqType = '';

// MSE form state (textarea + 3 inputs)
@track mseForm = {
  sampleDescription: '',
  serialNumber: '',
  manufacturer: '',
  meterRead: '',
  additionalInfo: ''
};


// --------------------------
// 3) Derived UI flags
// --------------------------
//get showDqTypes() {
 // return this.selectedRequestType === 'dq';
//}

get showDqTypes() {
  // Show UI for all request types except Asset Data Enquiry
  return this.selectedRequestType && this.selectedRequestType !== 'Asset Data Enquiry';
}


// Show subtypes only for non‑MSE DQ types
get showSubDqTypes() {
  return (
    this.selectedRequestType === 'dq' &&
    !!this.selectedDqType &&
    this.selectedDqType !== 'MSE' &&           // suppress for MSE
    this.SubDqTypes.length > 0
  );
}

// Show MSE form when DQ Type is MSE
get showMseForm() {
  return this.selectedRequestType === 'dq' && this.selectedDqType === 'MSE';
}

// --------------------------
// 4) Click handler for tiles
// --------------------------
handleCardClick = (event) => {
  const group = event.currentTarget?.dataset?.group;
  const value = event.currentTarget?.dataset?.value;

  if (!group || !value) return;

  switch (group) {
    case 'requestType':
      this.selectedRequestType = value;
      // Reset downstream selections whenever parent changes
      this.selectedDqType = '';
      this.selectedSubDqType = '';
      this.SubDqTypes = [];
      this.resetMseForm();
      break;

    case 'DqTypes':
      // Only allow if DQ is the selected request type
      if (this.selectedRequestType !== 'dq') return;
      this.selectedDqType = value;
      this.selectedSubDqType = '';

      if (value === 'MSE') {
        // 🔹 MSE: no subtypes; show MSE form with default description
        this.SubDqTypes = [];
        this.mseForm.sampleDescription = this.defaultMseDescription();
      } else {
        // 🔹 Other DQ types: populate subtypes as usual
        this.SubDqTypes = this.dqSubTypeConfig[value] || [];
        // hide/clear MSE form
        this.resetMseForm();
      }
      break;

    case 'SubDqTypes':
      // Only allow if DQ and a non‑MSE DQ Type are selected
      if (this.selectedRequestType !== 'dq' || !this.selectedDqType || this.selectedDqType === 'MSE') return;
      this.selectedSubDqType = value;
      break;

    default:
      break;
  }

  // Optionally: dispatch an event upward with the current selection
  this.dispatchEvent(new CustomEvent('selectionchange', {
    detail: {
      requestType: this.selectedRequestType,
      dqType: this.selectedDqType,
      dqSubType: this.selectedSubDqType || null,
      mseForm: this.showMseForm ? { ...this.mseForm } : null
    }
  }));
};

// --------------------------
// 5) MSE helpers
// --------------------------
handleMseInputChange = (event) => {
  const { name, value } = event.target;
  if (!name) return;
  this.mseForm = { ...this.mseForm, [name]: value };
};

resetMseForm() {
  this.mseForm = {
    sampleDescription: '',
    serialNumber: '',
    manufacturer: '',
    meterRead: '',
    additionalInfo: ''
  };
}

defaultMseDescription() {
  
  return `Our 'customer/MRA' has confirmed that an exchange took place on **/**/**. The 'customer/MRA' states that the old MSN was ****** and the final reading was *****. The new asset details are MSN ******, Manufacturer *****, Model *****, Year of Manufacturer *****. Please investigate. (Please confirm with the network that the exchange was not a result of an emergency)`;
}


    

  //  jobTypes = [

  //      { value: 'faultyu6', label: 'Faulty U6', desc: 'Supporting line text lorem ipsum dolor sit amet, consectetur.', recommended: true },

  //      { value: 'windon', label: 'Wind on', desc: 'Supporting line text lorem ipsum dolor sit amet, consectetur.' }

  //   ];

  // startOptions = [
  //   { value: "now", label: "Start now" },

  //   { value: "pick", label: "Pick date & time" },

  //   { value: "retro", label: "Restrospective" },
  // ];

  titles = ["Mr", "Mrs", "Miss", "Dr"];

  // Handle card click via JS only
  handleCardClick(event) {
    const clickedCard = event.currentTarget;
    const selectedValue = clickedCard.dataset.value;
    switch (selectedValue) {
      case "urgent":
         
      this.showAppointmentFields = false;
        this.showJobType = true;
        this.job_type = "OTVST";
        this.job_subtype = "FAULT";
        this.Source = "PORTAL";

         if (
                  this.status?.toLowerCase() === 'residential' &&
                  this.paymentMechanism?.toLowerCase() === 'pre payment'
            ) {
                     this.showWindOnOption = true;
               } else {
                     this.showWindOnOption = false;
               }

        if (this.selectedJobType) {
          this.showAppointment = true;
        }
        break;

      case "now":
        this.showcontactdetails = true;
        this.showAppointmentFields = false;
        this.showBankCalender = true;
        this.showWindOnOption = false;
        const now = new Date();
        this.targetstart = now.toISOString().split("T")[0]; 
        this.ngme_time = now.toTimeString().slice(0, 5); 
        break;

      case "pick":
        this.updateAppointmentSlots();
        this.showAppointmentFields= true;
        this.showcontactdetails = true;
        this.showWindOnOption = false;
        break;

      case "retro":
        this.showAppointmentFields = false;
        this.showBankCalender = false;
        this.showcontactdetails = true;
        break;

      default:
        this.showJobType = false;
        this.showAppointmentFields =false;
        this.showcontactdetails = false;
         this.showBankCalender = false;
        break;
    }
  }

  handleInputChange(event) {
    const field = event.target.name;
    const value =
      event.target.type === "checkbox"
        ? event.target.checked
        : event.target.value;
    if (field && this.contactDetails.hasOwnProperty(field)) {
      this.contactDetails[field] = value;
    }
  }

  handleTitleChange(event) {
    this.selectedTitle = event.target.value;
  }

  handleCancelClick() {
    this.dispatchEvent(new CustomEvent("cancelcreatejob"));
  }

  handleUrgentWorkRequest(event) {
    const selected = event.target.value;
    this.showUrgentCategories = selected === "Urgent";
    if (this.showUrgentCategories) {
      this.urgentOptions = this.metadataRecord.map((item) => ({
        label: item.NGMCP_Portal_Category__c,
        value: item.NGMCP_Portal_Category__c,
      }));
    }
  }

  handleCategorySelect(event) {
    this.selectedValue = event.detail.value;
  }
 async handleSubmitUrgentWorkrequest(event) {
    event.preventDefault();

    // Start loading
    this.isLoading = true;

    // Validate consent
    if (!this.contactDetails.consent) {
        alert('Please confirm that consent has been obtained before submitting.');
        this.isLoading = false;
        return;
    }

    // Construct payload
    const payload = {
        reportedpriority: this.reportedpriority,
        job_type: this.job_type,
        affectedphone: this.contactDetails.contactNumber,
        description_longdescription: this.contactDetails.instructions,
        job_subtype: this.job_subtype,
        targetstart: this.targetstart,
        ngme_time: this.ngme_time,
        source: this.source,
        job_sub_subtype: this.job_sub_subtype,
        ngme_liferay_slot: 'AT',
        ngme_industry: this.ngme_industry,
        assetnum: this.assetnum,
        suppliercode: this.suppliercode,
        location: this.location,
        affectedperson: `${this.contactDetails.title} ${this.contactDetails.name}`
    };
    try {
        // Step 1: Create record
        const requestRecordId = await createUrgentWorkRequestRecord({
            requestBody: JSON.stringify(payload)
        });

        // Step 2: Submit request if record creation succeeded
        if (requestRecordId) {
            const response = await submitUrgentWorkRequest({
                requestBody: JSON.stringify(payload),
                requestId: requestRecordId
            });
            // TODO: Show success toast or navigate
        } else {
            console.warn(' No request record ID returned.');
        }
    } catch (error) {
        console.error('Error during Apex callout:', error);
    } finally {
        // Stop loading
        this.isLoading = false;
    }
}

 handleDragOver(event) {
        event.preventDefault();
        event.currentTarget.classList.add('drag-over');
    }

    handleDragLeave(event) {
        event.currentTarget.classList.remove('drag-over');
    }

    handleFileDrop(event) {
        event.preventDefault();
        event.currentTarget.classList.remove('drag-over');
        const files = event.dataTransfer.files;
        this.uploadFiles(files);
    }

    handleFileChange(event) {
        const files = event.target.files;
        this.uploadFiles(files);
    }

    handleBrowseClick() {
        this.template.querySelector('.file-input').click();
    }

    uploadFiles(files) {
        [...files].forEach(file => {
            // You can call Apex to upload file here
        });
    }

}