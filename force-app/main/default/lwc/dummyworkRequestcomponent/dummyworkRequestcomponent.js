import { LightningElement, track, wire, api } from "lwc";
import getAllMeterModelConfigs from "@salesforce/apex/NGMCP_WorkRequestController.getAllMeterModelConfigs";
import getAllHousingModelConfigs from "@salesforce/apex/NGMCP_WorkRequestController.geAlltHousingModels";
import getPrice from "@salesforce/apex/NGMCP_WorkRequestController.getPrice";
import success from "@salesforce/resourceUrl/success";
// Salesforce Experience Cloud limit ~10 MB per file
const MAX_FILE_SIZE = 10 * 1024 * 1024;

export default class DummyworkRequestcomponent extends LightningElement {

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
  @api addressDetails;
  @api assetDetails;
  @api thirdParty;
  @track uploadedFiles = []; // for UI display
  uploadedFilePayload = []; // ready for API call
  @track fileError = "";

  @track errors = {};   // mandatory required 28//11

  @track isLocked = false; // 10 dec change

  // 18 dec change

  

@track _residentialU6Site = false;
  @track _rerenderNudge = 0; // optional nudge to force recompute

  @api
  get residentialU6Site() {
    return this._residentialU6Site;
  }

  
set residentialU6Site(val) {
    // accept boolean, "true", or "Yes"
  //  const boolVal = (val === true || val === 'true' || val === 'Yes');  // 19 dec change comment this part
  //  this._residentialU6Site = boolVal;                                  // 19 dec change comment this part

 

  //const prev = this._residentialU6Site;
 // const boolVal = (val === true || val === 'true' || val === 'Yes');
 // this._residentialU6Site = boolVal;

 
const prev = this._residentialU6Site;
const boolVal = (val === true || val === 'true' || val === 'Yes');
 this._residentialU6Site = boolVal;


    
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
  }

  @api
  get paymentMechanism() {
    return this._paymentMechanism;
  }
  set paymentMechanism(value) {
    this._paymentMechanism = value;
    console.log('Payment Mechanism received:', this._paymentMechanism);
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

  // (Optional) trigger rerender nudges if your UI needs it
  this.errors = { ...this.errors };
}

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

       // If we're already in Yes → Install → Meter, populate dropdown now
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


  connectedCallback() {
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

      // Initialize state keys for the first subtype’s questions
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

    // <-- FORCE RERENDER
    this.errors = { ...this.errors };
  }


  // mandatory required 28/11 continue below


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
          isEmpty = false;
        } else {
          const val = this.state[q.key];
          isEmpty = (val === null || val === undefined || (typeof val === 'string' && val.trim() === '') || (Array.isArray(val) && val.length === 0));
        }
      }

      // Set required error
      if (required && isEmpty) {
        this.errors[q.key] = (q.key === 'finalRead')
          ? 'Final Read is required'
          : 'This field is required.';
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
      { label: "Faulty(On Gas)", id: "Exchange_FaultyOnGas", description: "Request to exchange a faulty NGM Meter (On Gas)" }
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
      { label: "Change Of Tenacy", id: "OtherVisits_ChangeOfTenacy", description: "Request to clear debt and load emergency credit following a change of tenancy" }
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

          // Show only if GT1 is required
          return (
            gt1RequiredTiers.includes(pressureTier) ||
            serviceLocation === "New" ||
            specialMeterSizes.includes(meterSize)
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

          const gt1Required =
            gt1RequiredTiers.includes(pressureTier) ||
            serviceLocation === "New" ||
            specialMeterSizes.includes(meterSize);

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

          const gt1Required =
            gt1RequiredTiers.includes(pressureTier) ||
            serviceLocation === "New" ||
            specialMeterSizes.includes(meterSize);

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
      {
        label: "Select Payment Method Required for New Meter",
        type: "radio",
        options: ["Credit", "Pre payment"],
        key: "paymentMethod",
    //    condition: (state) => state.MeterSize === "U6",
        defaultValue: "Credit"
      },
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

// ⬇️ Add/keep these three questions in the Install_Meter array


// In questionConfig["Install_Meter"] array:

// In questionConfig["Install_Meter"] array:

// In questionConfig["Install_Meter"] array (keep them in THIS order):
{
  label: "Is it a new connection?",
  type: "radio",
  options: ["Yes", "No"],
  key: "isNewConnection"
},
{
  label: "Is this a reconnection request?",
  type: "radio",
  options: ["Yes", "No"],
  key: "isReconnection",
  // Show whenever new connection = No
  condition: (state) => state.isNewConnection === "No"
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

          // Show GT1 question only when GT1 is required
          return (
            gt1RequiredTiers.includes(pressureTier) ||
            serviceLocation === 'New' ||
            specialMeterSizes.includes(meterSize)
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

          const gt1Required =
            gt1RequiredTiers.includes(pressureTier) ||
            serviceLocation === 'New' ||
            specialMeterSizes.includes(meterSize);

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

          const gt1Required =
            gt1RequiredTiers.includes(pressureTier) ||
            serviceLocation === 'New' ||
            specialMeterSizes.includes(meterSize);

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
      },
      {
        label:
          "Please provide photos of the existing meter position and desired location",
        type: "file",
        key: "existingMeterPhotos",
      },
    ],
    "MeterMove_Relocation": [
      {
        label:
          "Please provide photos of the existing meter position and desired location",
        type: "file",
        key: "existingMeterPhotos",
      },
      {
        label:
          "Please attach the Service Quotation for the new Service location",
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

  // … the rest of Damaged questions …


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

    // 3/12 modify by adil
   

"OtherVisits_Adversarial_Removal": [
  {
    
 label:
      "Please note the Removal job will require purging. Do you require NGM to carryout purging?",
    type: "radio",
    options: ["Yes", "No"],
    key: "purging",
    required: true,
    // ⬇️ NEW: default to Yes and lock it
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

  // ⬇️ Info text BELOW the file upload (same condition)
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
        options: ["Credit", "Pre payment"],
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
  // (Optionally also gate by meter size if that’s a requirement)
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

  // 18 dec change

  
const isInstallMeter =

 (subtypeId === 'Install_Meter') ||

 (this.selectedSubType?.label?.trim().toLowerCase() === 'meter');



  //const restrictYesFlow = isInstallMeter && this._residentialU6Site;
  const yesFlowActive = isInstallMeter && this._residentialU6Site;



  
 // --- When Yes-flow is active, keep ONLY these 6 in this order
  if (yesFlowActive) {
    const order = [
      'pressureTier',
      'outletPressure',
      'peakLoad',
      'MeterSize',
      'paymentMethod',
      'isNewConnection'
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

  return questions.map((q) => {

    // 19 dec change

    

    

    // Normalize SELECT options
    let normalizedSelectOptions = [];
    
if (q.type === 'select') {
  const currentValue = this.state[q.key]; // after you compute/assign it
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
}


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
  }

  // Files logic (unchanged)
  const files =
    q.type === 'file' &&
    this.uploadedFilesByKey &&
    Array.isArray(this.uploadedFilesByKey[q.key]) &&
    this.uploadedFilesByKey[q.key].length > 0
      ? this.uploadedFilesByKey[q.key]
      : null;

  // Address maxLength
  const addrKeys = new Set([
    'buildingName', 'buildingNumber', 'street',
    'dependentLocality', 'postTown', 'postCode'
  ]);
  const isAddr = addrKeys.has(q.key);
  const addrMax = q.key === 'postCode' ? 10 : 40;

  

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
    isInfo: q.type === 'info',
    value: currentValue ?? '',
    error: this.errors ? this.errors[q.key] : '',
    inputClass: this.errors && this.errors[q.key] ? 'input-error' : '',
    maxLength: isAddr ? addrMax : q.maxLength,
    files,
    
// 10 dec change
// When locked, force appropriate disabled/readOnly per input type
 disabled: this.isLocked || q.disabled === true || q.isFile || q.isRadio || q.isSelect,
 readOnly: this.isLocked || q.readOnly === true || q.isText || q.isTextarea || q.isNumber || q.isDate
 
 // 10 dec change end here

  };
});

}

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

  // refresh subtype 28/11 start here
  handleJobSelect(event) {
    console.log('metersize***', this.meterSize);
    this.showMeterErrorMessage = false;
    this.errorMessage = '';
    this.selectJob = true;
    this.priceButtonFlag = (this.selectJob && this.selectSubType) ? true : false;

    // 1) Highlight selected card
    this.highlightSelected(event, '.card-group');

    // 2) Track selected job type
    const selectedJobLabel = event.target.value;
    this.selectedJobType = selectedJobLabel;
    this.selectedJob = selectedJobLabel;
    this.updateRequestTypesClass();

    const list = this.jobTypeSubtypes[selectedJobLabel] || [];
    // 4) Refresh subtypes
    const eqLabel = (item, label) => (item.label || '').toLowerCase() === label.toLowerCase();

    if (this.thirdParty) {
      // Apply explicit per-job rules (no Map)
      let filtered = [];

      if (selectedJobLabel === 'Install') {
        // Meter only
        filtered = list.filter(item => eqLabel(item, 'Meter') || item.id === 'Install_Meter');

      } else if (selectedJobLabel === 'Exchange') {
        // Third Party only
        filtered = list.filter(item => eqLabel(item, 'Third Party') || item.id === 'Exchange_ThirdParty');

      } else if (selectedJobLabel === 'Other Visits') {
        // Adversarial removal + Theft of Gas Exchange
        filtered = list.filter(item =>
          eqLabel(item, 'Adversarial removal') || item.id === 'OtherVisits_Adversarial_Removal' ||
          eqLabel(item, 'Theft of Gas Exchange') || item.id === 'OtherVisits_TheftOfgasExchange'
        );

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

    } else if (selectedJobLabel === 'Meter Move' && this.meterSize === 'U6') {
      const reposition = list.filter(item => eqLabel(item, 'Reposition'));
      this.filteredSubTypes = reposition.map(s => ({ ...s }));
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

  checkAllAssetFieldsFilled() {

    // If assetDetails is null/undefined or empty, return true
    if (!this.assetDetails || this.assetDetails.length === 0) {
      return true;
    }

    // Otherwise, check every field has a non-empty value
    return this.assetDetails.every(field => field.value && field.value.trim() !== '');

  }
  checkAllAddressFieldsFilled() {
    if (!this.addressDetails || this.addressDetails.length === 0) {
      return true;
    }
    return this.addressDetails.every(field => field.value && field.value.trim() !== '');
  }

  
handleSubTypeSelect(event) {
  this.selectSubType = true;

  const selectedSubTypeLabel = event.target.value;
  this.jobSubType = selectedSubTypeLabel;

  // 19 dec change

   // If parent radio is YES and user just clicked Meter, hard-set U6 now
if (this._residentialU6Site &&
     (this.selectedSubType?.id === 'Install_Meter' ||
      (this.selectedSubType?.label?.trim().toLowerCase() === 'meter'))) {
  this.setHardU6ForYes();
 }

 // 19 dec change end here

  

  const alladdressFilled = this.checkAllAddressFieldsFilled();
  const allAssetFilled = this.checkAllAssetFieldsFilled();
  console.log('AddressDetails', JSON.stringify(alladdressFilled));
  console.log('AssetDetails', JSON.stringify(allAssetFilled));
  console.log('thirdparty', JSON.stringify(this.thirdParty));

  // Third-party appointment guard for Install -> Meter
  if (this.selectedJob === 'Install' && this.jobSubType === 'Meter' && this.thirdParty && !alladdressFilled) {
    console.log('inside the loop');
    const detail = {
      state: this.state,
      appointmentFlag: true,
      jobtype: this.selectedJob,
      subJobType: this.jobSubType,
      successprice: false
    };
    this.dispatchEvent(new CustomEvent('statereponse', {
      detail,
      bubbles: true,
      composed: true
    }));
    return;
  }

  const jobTypeInput = (this.selectedJob || '').trim().toLowerCase();
  const subJobTypeInput = (this.jobSubType || '').trim().toLowerCase();

  console.log('jobTypeInput', jobTypeInput);
  console.log('subJobTypeInput', subJobTypeInput);

  const allowedJobTypes = new Set(['other visits', 'exchange', 'remove']);
  const allowedSubJobTypes = new Set([
    'meter',
    'pickup',
    'specification change',
    'third party',
    'theft of gas exchange',
    'adversarial removal',
  ]);

  const isAllowedJob = allowedJobTypes.has(jobTypeInput);
  const isAllowedSub = allowedSubJobTypes.has(subJobTypeInput);

  console.log('isAllowedJob', isAllowedJob);
  console.log('isAllowedSub', isAllowedSub);
  console.log(!(alladdressFilled && allAssetFilled));

  if (isAllowedJob && isAllowedSub && this.thirdParty && !(alladdressFilled && allAssetFilled)) {
    console.log('inside the loop');
    const detail = {
      state: this.state,
      appointmentFlag: true,
      jobtype: this.selectedJob,
      subJobType: this.jobSubType,
      successprice: false
    };
    this.dispatchEvent(new CustomEvent('statereponse', {
      detail,
      bubbles: true,
      composed: true
    }));
    return;
  }

  console.log('Selected job' + this.selectedJob);
  console.log('JobType' + this.jobSubType);

  // Existing meter raise guard
  if (this.selectedJob === 'Install' && this.jobSubType === 'Meter' && !this.thirdParty) {
    this.showMeterErrorMessage = true;
    this.errorMessage = 'You cannot raise an Install Meter job on a MPRN where National Gas Meter already exists';
    return;
  }

  this.errorMessage = '';
  this.priceButtonFlag = (this.selectJob && this.selectSubType) ? true : false;

  console.log('selectedSubTypeLabel', selectedSubTypeLabel);
  const selectedSubTypeObj = this.filteredSubTypes.find(s => s.label === selectedSubTypeLabel);
  this.selectedSubType = selectedSubTypeObj || { label: selectedSubTypeLabel, id: selectedSubTypeLabel };

  // Default for Remove_Pickup
  if (this.selectedSubType?.id === 'Remove_Pickup') {
    if (!this.state.isDifferentAddress) {
      this.state.isDifferentAddress = 'No';
    }
  }

  // ===== Existing reset block (kept): build new state from questionConfig =====
  const questions = this.questionConfig[this.selectedSubType.id];
  if (questions) {
    const newState = {};
    questions.forEach((q) => {
      const dv = q.defaultValue;
      const hasDefault =
        dv !== undefined && dv !== null && !(typeof dv === 'string' && dv.trim() === '');
      if (q.key === 'pressureTier') {
        //  Do not change pressure tier (as requested it's working fine)
        newState[q.key] = this._pressureTier ?? dv ?? null;
      } else {
        newState[q.key] = hasDefault ? dv : null;
      }
    });
    this.state = newState;
  }
  // ===== End existing reset block =====

      // 19 dec change for adversarial removal

// After you set this.selectedSubType and rebuild this.state from questionConfig:
  if (this.selectedSubType?.id === 'OtherVisits_Adversarial_Removal') {
    // ⬇️ make sure purging is Yes in state, regardless of any prior value
    this.state.purging = 'Yes';
    // Clear any purging-related errors
    if (!this.errors) this.errors = {};
    this.errors.purging = '';
    this.errors = { ...this.errors };
    // Optional: remove any event listeners attempting to change it (not usually needed)
  }

  // 19 dec change for adversarial removal end here
  
  // (Fixes sticky MeterSize after switching Exchange: Specification Change <-> Third Party,
  //  and optionally Install: Meter <-> Install: Housing)
  {
    const meterSizeResetSubtypes = new Set([
      'Exchange_SpecificationChange',
      'Exchange_ThirdParty',
   //   'Install_Meter',         // 19 dec change comment that part
      'Install_Housing'        // include/remove per your need
    ]);

    const id = this.selectedSubType?.id;
    if (id && meterSizeResetSubtypes.has(id)) {
      // 1) Reset MeterSize and housing-related state
      this.state = {
        ...this.state,
        MeterSize: '',
        housingRequired: '',
        housingType: '',
        HModel: ''
      };

      

      // 2) Reset MeterSize options to placeholder for this subtype
      const placeholder = [{ label: 'Select Meter Size', value: '' }];
      if (this.questionConfig[id]) {
        this.questionConfig[id] = this.questionConfig[id].map(q => {
          if (q.key === 'MeterSize') {
            return { ...q, options: placeholder };
          }
          return q;
        });
      }


      
      // 3) Clear any previous errors related to MeterSize/housing
      if (!this.errors) this.errors = {};
      this.errors.MeterSize = '';
      this.errors.housingRequired = '';
      this.errors.housingType = '';
      this.errors.HModel = '';
      this.errors = { ...this.errors };
    }
  }

  // 19 dec change

 

    // 19 dec change end here



  // ✅ Clear payment flow on subtype switch (existing)
  this.state.changePaymentType = null;
  this.state.paymentMethod = null;

  if (!this.errors) this.errors = {};
  this.errors.changePaymentType = '';
  this.errors.paymentMethod = '';
  this.errors = { ...this.errors };
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

  
// Replace the current global, digit-only keypress handler
handleKeyPress(event) {
  // Identify which field this keypress belongs to
  const key = event.target?.dataset?.key || event.target?.name;

  // Fields that must remain numeric-only:
  const numericOnlyKeys = new Set([
    'outletPressure',
    'peakLoad',
    'finalRead'
  ]);

  // Allow everything for non-numeric fields (e.g., address fields)
  if (!numericOnlyKeys.has(key)) {
    return; // do not block letters/symbols
  }

  const char = event.key;

  // Allow control keys like Backspace, Delete, Arrow keys, Tab, etc.
  const allowControl =
    ['Backspace', 'Delete', 'ArrowLeft', 'ArrowRight', 'Tab'].includes(char) ||
    (event.ctrlKey || event.metaKey); // copy/paste, select all

  if (allowControl) return;

  // Only digits for numeric fields
  if (!/[0-9]/.test(char)) {
    event.preventDefault();
  }
}

// 17 dec change for pickup validation


  handleDynamicChange(event) {

    

    if (this.isLocked) { event.preventDefault?.(); return; }  // 10 dec change
    const key = event.target.dataset.key || event.target.name;
    let value = event.detail?.value || event.target.value;
    console.log("Key: ", key);
    console.log("Value: ", value);

    // 19 dec change for adversarial removal
    
 // ⬇️ Guard: never allow changing purging on Adversarial removal
  if (key === 'purging' && this.selectedSubType?.id === 'OtherVisits_Adversarial_Removal') {
    // Force back to Yes
    this.state.purging = 'Yes';
    // Reset any checked UI (if browser still toggled it)
    this.template.querySelectorAll('input[name="purging"]').forEach(r => {
      r.checked = (r.value === 'Yes');
      r.disabled = true;
    });
    return; // ignore further processing for this key
  }

   // 19 dec change for adversarial removal end here

      
const isFileInput =
    event.target.type === 'file' ||
    key?.toLowerCase().includes('file'); // e.g., 'gt1File', 'purgingCertificateFile'

    if (isFileInput) {

    const files = event.target.files;
    this.processFiles(files);
    event.target.value = "";
    }

    // GT1 logic constants
    const gt1RequiredTiers = ["Medium Pressure", "Intermediate Pressure", "High Pressure"];
    const specialMeterSizes = ["Rotary", "Turbine"];
    const pressureTier = this.state.pressureTier;
    const serviceLocation = this.state.serviceLocation;
    const meterSize = this.state.MeterSize;

    const parentCondition =
      gt1RequiredTiers.includes(pressureTier) ||
      serviceLocation === "New" ||
      specialMeterSizes.includes(meterSize);



    // Ensure state and errors exist
    if (!this.state) this.state = {};
    if (!this.errors) this.errors = {};


    if (key === "outletPressure") {
      value = value.replace(/\D/g, "").slice(0, 4);
    }

    if (key === "peakLoad") {
      value = value.replace(/\D/g, "").slice(0, 8);
    }

    if (key === "finalRead") {
      value = value.replace(/\D/g, "").slice(0, 5); // Only digits, max 5
      this.state.finalRead = value;

      // Dynamic validation
      if (value.length === 0) {
        this.errors.finalRead = "Final Read is required";
      } else if (value.length < 4) {
        this.errors.finalRead = "Final Read must be at least 4 digits";
      } else {
        this.errors.finalRead = ""; // Clear error if valid
      }
    }

    if (key === "crimeRefNumber") {
      value = value.replace(/[^A-Za-z0-9]/g, "").slice(0, 20);
    }

    // 28/11

    const isAddrField = [
      "buildingName",
      "buildingNumber",
      "street",
      "dependentLocality",
      "postTown",
      "postCode"
    ].includes(key);
    const addressActive = this.state.isDifferentAddress === "Yes";

    if (isAddrField && addressActive) {
      value = String(value || "");

      // Optional: trim pasted text if exceeds max length
      const maxLen = key === "postCode" ? 9 : 39;
      if (event.inputType === "insertFromPaste" && value.length > maxLen) {
        value = value.slice(0, maxLen);
      }

      // Required validation only
      if (value.trim().length === 0) {
        this.errors[key] = "This field is required.";
      } else {
        this.errors[key] = "";
      }

    }


    // 28/11 end here

    // Update state safely
    this.state[key] = value;


    // 18 dec change




// --- Connection/reconnection trio hygiene ---
if (key === "isNewConnection") {
  // Always reset dependents on any change to avoid auto-selection
  this.state.isReconnection = null;
  this.state.isReconnectionDebt = null;
  this.clearRadioGroupIfNoState("isReconnection");
  this.clearRadioGroupIfNoState("isReconnectionDebt");
}

if (key === "isReconnection") {
  // Debt is relevant only when reconnection = Yes
  if (value !== "Yes") {
    this.state.isReconnectionDebt = null;
       this.clearRadioGroupIfNoState("isReconnectionDebt");
  }
}

// Keep validation map reactive


    // 18 dec change end here

    // mandatory required field 28/111





    // --- LIVE ERROR CLEARING (radio/select/text etc.) ---
    if (!this.errors) this.errors = {};

    const isSelection =
      event.type === 'change' &&
      (event.target.type === 'radio' || event.target.tagName === 'SELECT');

    if (isSelection) {
      this.errors[key] = '';
      this.errors = { ...this.errors }; // force rerender
    } else {
      const v = this.state[key];
      const hasValue =
        v !== null &&
        v !== undefined &&
        (typeof v !== 'string' || v.trim() !== '') &&
        (!Array.isArray(v) || v.length > 0);
      if (hasValue) {
        this.errors[key] = '';
        this.errors = { ...this.errors }; // force rerender
      }
    }


    // mandatrory required field 28/11 end here

    console.log("Updated state: ", JSON.stringify(this.state));



    // Clear debounce if needed
    if (key === "outletPressure" || key === "peakLoad") {
      if (this.debounceTimeout) {
        clearTimeout(this.debounceTimeout);
      }
      const kwh = parseFloat(this.state.peakLoad);
      const pressure = parseFloat(this.state.outletPressure);
      console.log("kwh:", kwh, "pressure:", pressure);
      if (!isNaN(kwh) || !isNaN(pressure)) {
        this['MeterSize'] = " ";
        this.state = { ...this.state, ['MeterSize']: "" };
        console.log("this.state ", JSON.stringify(this.state));
      }
      this.debounceTimeout = setTimeout(() => {
        this.filterMeterModels();
      }, 500);
    }

    if (key === 'MeterSize' || key === 'housingType' || key === 'housingRequired') {
      if (this.debounceTimeout) {
        clearTimeout(this.debounceTimeout);
      }

      this.debounceTimeout = setTimeout(() => {
        this.updateHousingModel();
      }, 500);

    }


    switch (key) {
      case "outletPressure":
        this.outletPressure = value;
        break;

      case "peakLoad":
        this.peakLoad = value;
        break;

      case "housingRequired":
        this.housingRequired = value;
        this.state.housingRequired = value;

        if (value === "No") {
          this.housingType = null;
          this.state.housingType = null;
          this.baseRequired = null;
          this.state.baseRequired = null;
        } else if (value === "Yes") {
          this.updateHousingModel();
        }
        break;

      case "housingType":
        this.housingType = value;
        this.state.housingType = value;

        if (value !== "Free Standing") {
          this.baseRequired = null;
          this.state.baseRequired = null;
        }
        break;

      // 28/11

      case 'serviceLocation': {
        const pressureTier = this.state?.pressureTier;
        const serviceLocation = this.state?.serviceLocation;  // updated to new value
        const meterSize = this.state?.MeterSize;

        const gt1RequiredTiers = ['Medium Pressure', 'Intermediate Pressure', 'High Pressure'];
        const specialMeterSizes = ['Rotary', 'Turbine'];

        const gt1Required =
          gt1RequiredTiers.includes(pressureTier) ||
          serviceLocation === 'New' ||
          specialMeterSizes.includes(meterSize);

        // If GT1 is no longer required, reset GT1 answer & flags
        if (!gt1Required) {
          this.state.gt1 = null;
          this.showGt1Upload = false;
          this.showGt1Error = false;
          this.state.gt1ErrorFlag = false;
        } else {
          // Keep UI in sync when requirement is true
          this.showGt1Upload = (this.state.gt1 === 'Yes');
          const showErr = (this.state.gt1 === 'No');
          this.showGt1Error = showErr;
          this.state.gt1ErrorFlag = showErr;
        }

        // Your existing logic (e.g., reset paymentType on Existing) can remain:
        // if (value === 'Existing') { this.state.changePaymentType = null; }

        break;
      }
      case 'pressureTier': {
        const ms = this.state?.MeterSize;
        const tier = this.state?.pressureTier;
        const gt1RequiredSizes = ['U16', 'U25', 'U40', 'U65', 'U100', 'U160', 'Rotary', 'Turbine'];

        const installGt1Required =
          gt1RequiredSizes.includes(ms) ||
          (ms === 'U6' && (tier === 'Intermediate Pressure' || tier === 'High Pressure'));

        if (!installGt1Required) {
          this.state.gt1 = null;
          this.showGt1Upload = false;
          this.showGt1Error = false;
          this.state.gt1ErrorFlag = false;
        } else {
          this.showGt1Upload = (this.state.gt1 === 'Yes');
          this.showGt1Error = (this.state.gt1 === 'No');
          this.state.gt1ErrorFlag = this.showGt1Error;
        }
        break;
      }


      case 'gt1': {
        const gt1RequiredTiers = ['Medium Pressure', 'Intermediate Pressure', 'High Pressure'];
        const specialMeterSizes = ['Rotary', 'Turbine'];
        const parentCondition =
          gt1RequiredTiers.includes(this.state?.pressureTier) ||
          this.state?.serviceLocation === 'New' ||
          specialMeterSizes.includes(this.state?.MeterSize);

        this.state.gt1 = value;
        this.showGt1Upload = (value === 'Yes');
        const showError = parentCondition && value === 'No';
        this.showGt1Error = showError;
        this.state.gt1ErrorFlag = showError;
        break;
      }



      // 28/11 end here
      case "gt1":
        this.state.gt1 = value;
        this.showGt1Upload = value === "Yes";

        
        if (parentCondition && value === "No") {
          this.showGt1Error = true;
        } else {
          this.showGt1Error = false;
        }
        break;
        if (parentCondition && this.state.gt1 === "No") {
          this.showGt1Error = true;
        } else {
          this.showGt1Error = false;
        }


      case "pickupRequired":
        this.pickupRequired = value;
        break;

      case "isDifferentAddress":
        this.isDifferentAddress = value;
        break;


      // 28/11

      case 'MeterSize': {
        // 1) Update state earlier in the handler:
        // this.state.MeterSize = value;

        // 2) Install_Meter requirement rules (for reference; we’ll still reset GT1)
        const ms = this.state?.MeterSize;
        const tier = this.state?.pressureTier;

        const gt1RequiredSizes = ['U16', 'U25', 'U40', 'U65', 'U100', 'U160', 'Rotary', 'Turbine'];
        const installGt1Required =
          gt1RequiredSizes.includes(ms) ||
          (ms === 'U6' && (tier === 'Intermediate Pressure' || tier === 'High Pressure'));


        this.state.gt1 = null;
        this.showGt1Upload = false;
        this.showGt1Error = false;
        this.state.gt1ErrorFlag = false;

        // gt1 switch issue in install meter 29/11 start here


        // Clear GT1 radio UI selection (if any persisted in DOM)
        const gt1Radios = this.template.querySelectorAll('input[name="gt1"]');
        gt1Radios.forEach(r => { r.checked = false; });

        // Clear any previously attached GT1 files shown in UI
        if (!this.uploadedFilesByKey) this.uploadedFilesByKey = {};
        this.uploadedFilesByKey.gt1File = []; // empty list

        // Clear GT1-related errors and force rerender
        if (!this.errors) this.errors = {};
        this.errors.gt1 = '';
        this.errors.gt1File = '';
        this.errors = { ...this.errors };  // LWC reactivity bump

        // gt1 switch issue in install meter 29/11 end here

        // change payment switch issue when switvh to U6 29/11 row 2



        this.state.changePaymentType = null;
        this.state.paymentMethod = null;


        // Clear payment-related errors and force rerender
        if (!this.errors) this.errors = {};
        this.errors.changePaymentType = '';
        this.errors.paymentMethod = '';
        this.errors = { ...this.errors }; // LWC reactivity bump


        // change payment switch issue when switvh to U6 29/11  end here

        // (Optional) If requirement is true, keep UI hidden until user picks Yes/No again
        // (We do NOT auto-select anything)

        // Keep your housing model debounce if needed
        if (this.debounceHousingTimeout) clearTimeout(this.debounceHousingTimeout);
        this.debounceHousingTimeout = setTimeout(() => {
          this.updateHousingModel?.();
        }, 400);

        break;
      }



      // 27/11


      case 'pressureTier': {
        const ms = this.state?.MeterSize;
        const tier = this.state?.pressureTier;
        const gt1RequiredSizes = ['U16', 'U25', 'U40', 'U65', 'U100', 'U160', 'Rotary', 'Turbine'];

        const installGt1Required =
          gt1RequiredSizes.includes(ms) ||
          (ms === 'U6' && (tier === 'Intermediate Pressure' || tier === 'High Pressure'));

        if (!installGt1Required) {
          this.state.gt1 = null;
          this.showGt1Upload = false;
          this.showGt1Error = false;
          this.state.gt1ErrorFlag = false;
        } else {
          this.showGt1Upload = (this.state.gt1 === 'Yes');
          this.showGt1Error = (this.state.gt1 === 'No');
          this.state.gt1ErrorFlag = this.showGt1Error;
        }
        break;
      }

      // 28/11 end here

      case "changePaymentType":
        this.changePaymentType = value;
        break;

      case "assetType":
        let reasonOptions = [];
        if (value === "Meter") {
          reasonOptions = ["Please select reason for Site Visit", "Site Visit for Enquiry/Complaint", "Ad-Hoc"];
        } else if (value === "Converter") {
          reasonOptions = ["Converter Re-Syncing"];
        } else if (value === "Isolation") {
          reasonOptions = ["Install EMS to Isolation"];
        } else {
          reasonOptions = []; // Clear if placeholder selected
        }


        const subtypeId = this.selectedSubType?.id;
        if (subtypeId && this.questionConfig[subtypeId]) {
          this.questionConfig[subtypeId] = this.questionConfig[subtypeId].map((q) => {
            if (q.key === "siteVisitReason") {
              return { ...q, options: reasonOptions };
            }
            return q;
          });
        }
        break;

      case "finalRead":
        // Strip non-digits and limit to 5 characters
        value = value.replace(/\D/g, "").slice(0, 5);

        if (!this.errors) this.errors = {};
        if (!this.state) this.state = {};

        this.state.finalRead = value;

        // Validation logic
        if (value.length === 0) {
          this.errors.finalRead = "Final Read is required";
        } else if (value.length < 4) {
          this.errors.finalRead = "Final Read must be at least 4 digits";
        } else {
          this.errors.finalRead = ""; // Valid when 4 or 5 digits
        }

        // Update UI dynamically
        const question = this.dynamicQuestions.find(q => q.key === "finalRead");
        if (question) {
          question.value = value;
          question.error = this.errors.finalRead;
          question.inputClass = question.error ? "input-error" : "";
        }
        break;   // 28/11 end here
    }

    this.clearErrorsForInvisibleQuestions();    // mandatory required field 28/11
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
  // Only for Install → Meter
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


  updateHousingModel() {
    if (this.housingRequired === "Yes") {
      console.log('this.state.housingType:', this.state.housingType);
      console.log('this.state.MeterSize:', this.state.MeterSize);
      // Build key dynamically
      const key = this.state.housingType ? this.state.MeterSize + this.state.housingType.replace(/\s+/g, "_") : this.state.MeterSize;
      console.log('key' + key);
      console.log('this.housingModelMap.get(key)' + this.housingModelMap.get(key));
      // Update state with value from Map
      this.state = {
        ...this.state,
        HModel: this.housingModelMap.get(key) || ""
      };
    }
  }

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
 //  Only auto-select MeterSize when YES-flow (Install → Meter + residentialU6Site = true)
  

 this.state = {
   ...this.state,
   MeterSize: meterSizeOptions.length ? meterSizeOptions[0].value : "",  // 19 dec change comment this part

 
l
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

      const dataMap = new Map(Object.entries(this.state));
      const hModel = dataMap.get('HModel') ? dataMap.get('HModel').trim() : '';            // Prepare request body
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
        NGMCP_Is_New_Connection__c: '',
        NGMCP_Is_Reconnection__c: '',
        NGMCP_Is_Reconnection_Debt__c: ''
      };

      console.log('Request Body:', JSON.stringify(requestBody));

      // Call the Apex method
      const result = await getPrice({ payload: JSON.stringify(requestBody) });
      console.log('Price Result:', JSON.stringify(result));
      if (result && result.length > 0 && result[0].NGMCP_Job_Price__c > 0) {
        this.priceMessageFlag = true;
        const price = Number(result[0].NGMCP_Job_Price__c).toFixed(2);
        this.priceMessage = `Price for the job is £${price}`;


        
 // 🔒 LOCK here when a paid price is returned
      this.isLocked = true;           // 10 dec change


        //this.priceMessage =`Price for the job is £${result[0].NGMCP_Job_Price__c}`;
      } else if (result[0].NGMCP_Job_Price__c == 0) {
        this.priceMessageFlag = true;
        this.priceMessage = 'Good News! This is a free of charge job.'

        
// 🔒 LOCK here when price is £0 (FOC)
      this.isLocked = true;           // 10 dec change

      } 
      // we are passing the pressureTier in the state if pressureTier is not in the state     
      if (!('pressureTier' in this.state)) {
        this.state.pressureTier = this.pressuretier ?? null;
      }
      const detail = {
        state: this.state,           // Pass current state object
        appointmentFlag: true,
        jobtype: this.selectedJob,
        subJobType: this.jobSubType,
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
       if (!('pressureTier' in this.state)) {
        this.state.pressureTier = this.pressuretier ?? null;
      }
      const detail = {
        state: this.state,           // Pass current state object
        appointmentFlag: false,
        jobtype: this.selectedJob,
        subJobType: this.jobSubType,
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


        if (q.defaultValue && !this.state[q.key] && !inputEl.value) {
          inputEl.value = q.defaultValue;
          this.state[q.key] = q.defaultValue;
        }


        inputEl.addEventListener('input', (e) => {
          this.state[q.key] = e.target.value;
        });
      }
        // 18 dec change
      

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

  processFiles(fileList) {

    if (this.isLocked) return;   // 10 dec change
    this.fileError = "";
    if (!fileList || fileList.length === 0) return;

    const duplicateFiles = [];

    Array.from(fileList).forEach((file) => {
      // Prevent duplicate filenames
      if (this.uploadedFiles.some((f) => f.name === file.name)) {
        duplicateFiles.push(file.name);
        return; // skip adding this file
      }

      // Check file size
      if (file.size > MAX_FILE_SIZE) {
        const maxMB = (MAX_FILE_SIZE / 1024 / 1024).toFixed(0);
        this.showTemporaryError(
          `File "${file.name}" exceeds ${maxMB} MB limit.`
        );
        return; // skip this file
      }

      const reader = new FileReader();
      reader.onload = (e) => {
        const base64Data = e.target.result.split(",")[1];

        const fileUI = {
          name: file.name,
          size: file.size,
          sizeDisplay: this.formatFileSize(file.size),
          isImage: file.type.startsWith("image/"),
          previewUrl: file.type.startsWith("image/") ? e.target.result : null,
        };

        const filePayload = {
          name: file.name,
          type: file.type,
          size: file.size,
          base64: base64Data,
        };

        // store both UI + payload data
        this.uploadedFiles = [...this.uploadedFiles, fileUI];
        this.uploadedFilePayload = [...this.uploadedFilePayload, filePayload];
      };

      reader.readAsDataURL(file);
    });

    // After processing all files, show duplicate error if any
    if (duplicateFiles.length > 0) {
      if (duplicateFiles.length === 1) {
        this.showTemporaryError(
          `File "${duplicateFiles[0]}" is already uploaded.`
        );
      } else {
        this.showTemporaryError(
          `Files "${duplicateFiles.join('", "')}" are already uploaded.`
        );
      }
    }
  }

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
  handleFileDelete(event) {

    if (this.isLocked) return;   // 10 dec change
    const name = event.currentTarget.dataset.name;
    this.uploadedFiles = this.uploadedFiles.filter((f) => f.name !== name);
    this.uploadedFilePayload = this.uploadedFilePayload.filter(
      (f) => f.name !== name
    );
  }


    
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



}