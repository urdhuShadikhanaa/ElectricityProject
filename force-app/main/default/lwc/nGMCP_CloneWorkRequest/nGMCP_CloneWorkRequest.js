import { LightningElement, track, wire,api } from "lwc";
import getAllMeterModelConfigs from "@salesforce/apex/NGMCP_WorkRequestController.getAllMeterModelConfigs";
import getAllHousingModelConfigs from "@salesforce/apex/NGMCP_WorkRequestController.geAlltHousingModels";
import getPrice from "@salesforce/apex/NGMCP_WorkRequestController.getPrice";
export default class NGMCP_workRequestComponent extends LightningElement {

  @track showWorkRequest = true; // default is false
  @api status;
  @api paymentMechanism;
  @api meterSize;
  @track pressureTier = "Low Pressure";
  @track outletPressure = 21;
  @track peakLoad = "";
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
  @track priceMessageFlag= false;
  @track priceMessage;
  @track meterModels = [];
  @track meterModels = [];
  @track housingModels = [];
  error;

  @wire(getAllMeterModelConfigs)
  wiredConfigs({ error, data }) {
    if (data) {
      this.meterModels = data;
      console.log("this.meterModels", JSON.stringify(this.meterModels));
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

    // Optional: Pre-populate keys from questionConfig
    Object.keys(this.questionConfig).forEach(subType => {
        this.questionConfig[subType].forEach(q => {
            this.state[q.key] = q.defaultValue || '';
            this.errors[q.key] = '';
        });
    });
}

  uiConfig = {
    requestTypes: [
      {
        label: "Work Request",
        helpText: "Choose job type and subtype",
       
jobTypes: [
      { label: "Install", description: "Lorem ipsum dolor sit amet." },
      { label: "Exchange", description: "Lorem ipsum dolor sit amet." },
      { label: "Remove", description: "Lorem ipsum dolor sit amet." },
      { label: "Meter Move", description: "Lorem ipsum dolor sit amet." },
      { label: "Other Visits", description: "Lorem ipsum dolor sit amet." }
    ]
  }
    ],
  };

  jobTypeSubtypes = {
    Install: [
        { label: "Meter", description: "Request to install an NGM meter at a new meter point" },
        { label: "Converter", description: "Request to install an Converter to an existing NGM installation" },
        { label: "Install Housing", description: "Request to install Meter Housing" }
    ],
    Exchange: [
        { label: "Specification Change", description: "Request for a Meter Upgrage/Downgrade in size or change to meter type (Credit/Pre-Pay)" },
        { label: "Accuracy Test", description: "Request to exchange for a Meter accuracy test" },
        { label: "GPS", description: "Request to exchange a Non-Pulsing Meter" },
        { label: "Exchange Housing", description: "Request to exchange the Meter Housing" },
        { label: "Converter", description: "Exchange or maintain a converter." },
        { label: "Third Party", description: "Request to exchange a 3rd Party Meter to an NGM Meter" }
    ],
    Remove: [
        { label: "Remove Meter", description: "Remove an existing meter from the site." },
        { label: "Pickup", description: "Request to pick up an NGM Meter which has already been disconnected from the service" },
        { label: "Converter", description: "Request to remove the Converter" }
    ],
    "Meter Move" : [
        { label: "Reposition", description: "Request to reposition an NGM Meter (within 2 metres of existing service point)" },
        { label: "Relocation", description: "Request to Relocate an NGM meter to an alternative Service Point" }
    ],
    "Other Visits": [
        { label: "Damaged", description: "Request to exchange a damaged NGM Meter" },
        { label: "Adversarial removal", description: "Request to remove the Meter under Warrant" },
        { label: "Post Commissioning Checks", description: "Request for Post Comissioning Checks following metering works on site." },
        { label: "Pressure Change", description: "Request for an Increase or Decrease to the metering pressure on site" },
        { label: "Reconnect", description: "Request to reconnect an NGM Meter at an existing meter point" },
        { label: "Site Visit", description: "Request for a Site Visit" },
        { label: "Theft of Gas Exchange", description: "Request to exchange the meter following suspected Theft of Gas (TOG)" }
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
    "Specification Change": [
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
    
},

      
{
    label: "Select Medium Pressure Value",
    type: "select",
    key: "mediumPressureValue",
    options: ["Please select the Medium Pressure","MP35", "MP65", "MP105", "MP180", "MP270"],
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
        label: "Do you have GT1/Service Quotation?",
        type: "radio",
        options: ["Yes", "No"],
        key: "gt1",
        condition: (state) => {
          const pressureTier = state.pressureTier;
          const serviceLocation = state.serviceLocation;
          const meterSize = state.MeterSize;

          
const gt1RequiredTiers = [
        "Medium Pressure", 
        "Intermediate Pressure",
        "High Pressure"
    ];

    const specialMeterSizes = ["Rotary", "Turbine"];

    // Show if pressure tier is Medium, Intermediate, or High
    if (gt1RequiredTiers.includes(pressureTier)) {
        return true;
    }


          // Service location is New
          if (serviceLocation === "New") {
            return true;
          }

          // Meter size is Rotary, Turbine
          if (specialMeterSizes.includes(meterSize)) {
            return true;
          }

          return false;
        },
      },

      {
        label: "Please attach GT1/Service Quotation document",
        type: "file",
        key: "gt1File",
        condition: (state) => state.gt1 === "Yes",
      },

      {
        label:
          "This job requires a GT1 to be completed by the network provider and the GT1 survey attached, therefore it cannot be raised. If you have any further questions please contact 0800 001 4340.",
        type: "error",
        key: "gt1Error",
        condition: (state) =>
          state.serviceLocation === "New" && state.gt1 === "No",
      },

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
    options: ["Credit", "Pre-payment"],
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

    "Meter": [
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
   
},

      
{
    label: "Select Medium Pressure Value",
    type: "select",
    key: "mediumPressureValue",
    options: ["Please select the Medium Pressure","MP35", "MP65", "MP105", "MP180", "MP270"],
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
        options: [],
      },

      // New logic
      {
        label: "Select Payment Method Required for New Meter",
        type: "radio",
        options: ["Credit", "Pre-payment"],
        key: "paymentMethod",
        condition: (state) => state.MeterSize === "U6",
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
    ],

    "Remove Meter": [
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
   
},

      
{
    label: "Select Medium Pressure Value",
    type: "select",
    key: "mediumPressureValue",
    options: ["Please select the Medium Pressure","MP35", "MP65", "MP105", "MP180", "MP270"],
    condition: (state) => state.pressureTier === "Medium Pressure" 
},


      {
        label:
          "Please note the Removal job will require purging. Do you require NGM to carry out purging?",
        type: "radio",
        options: ["Yes", "No"],
        key: "purgingRequired",
      },
    ],

    Pickup: [
      {
        label: "What Equipment is required to be picked up?",
        type: "radio",
        options: ["Yes", "No"],
        key: "pickupRequired",
      },
      {
        label: "Provide Final Read",
        type: "text",
        key: "finalRead",
        condition: (state) => state.pickupRequired === "Yes",
      },
      {
    label: "Is the meter pickup address different from above?",
    type: "radio",
    options: ["Yes", "No"],
    key: "isDifferentAddress",
    value: "No", 
    condition: (state) => state.pickupRequired === "Yes"
},
      {
        label: "Please enter Alternative Pickup Address",
        type: "address", // Custom type for multiple fields
        fields: [
          "Building Name",
          "Building Number",
          "Street",
          "Dependant Locality",
          "Post Town",
          "Post Code",
        ],
        key: "alternativeAddress",
        condition: (state) => state.isDifferentAddress === "Yes",
      },
    ],

    "Third Party": [
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
    
},

      
{
    label: "Select Medium Pressure Value",
    type: "select",
    key: "mediumPressureValue",
    options: ["Please select the Medium Pressure","MP35", "MP65", "MP105", "MP180", "MP270"],
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
    label: "Do you have GT1/Service Quotation?",
    type: "radio",
    options: ["Yes", "No"],
    key: "gt1",
    condition: (state) => {
        const gt1RequiredTiers = ["Medium Pressure", "Intermediate Pressure", "High Pressure"];
        const specialMeterSizes = ["Rotary", "Turbine"];

        const pressureTier = state.pressureTier;
        const serviceLocation = state.serviceLocation;
        const meterSize = state.MeterSize;

        return (
            gt1RequiredTiers.includes(pressureTier) ||
            serviceLocation === "New" ||
            specialMeterSizes.includes(meterSize)
        );
    }
},
{
    label: "Please attach GT1/Service Quotation document",
    type: "file",
    key: "gt1File",
    condition: (state) => {
        const gt1RequiredTiers = ["Medium Pressure", "Intermediate Pressure", "High Pressure"];
        const specialMeterSizes = ["Rotary", "Turbine"];

        const pressureTier = state.pressureTier;
        const serviceLocation = state.serviceLocation;
        const meterSize = state.MeterSize;

        const parentCondition =
            gt1RequiredTiers.includes(pressureTier) ||
            serviceLocation === "New" ||
            specialMeterSizes.includes(meterSize);

        return parentCondition && state.gt1 === "Yes";
    }
},
{
    label: "This job requires a GT1 survey attached. Please contact 0800 001 4340 for assistance.",
    type: "error",
    key: "gt1Error",
    condition: (state) => {
        const gt1RequiredTiers = ["Medium Pressure", "Intermediate Pressure", "High Pressure"];
        const specialMeterSizes = ["Rotary", "Turbine"];

        const pressureTier = state.pressureTier;
        const serviceLocation = state.serviceLocation;
        const meterSize = state.MeterSize;

        const parentCondition =
            gt1RequiredTiers.includes(pressureTier) ||
            serviceLocation === "New" ||
            specialMeterSizes.includes(meterSize);

        return parentCondition && state.gt1 === "No";
    }
},
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
    options: ["Credit", "Pre-payment"],
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

    "Install Housing": [
      // Question 1: Service Pressure Tier (Dropdown)
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
    
},

      
{
    label: "Select Medium Pressure Value",
    type: "select",
    key: "mediumPressureValue",
    options: ["Select the Medium Pressure","MP35", "MP65", "MP105", "MP180", "MP270"],
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

    "Exchange Housing": [
      // Question 5: Meter Housing Type (Text)

      {
        label: "Please select the appropriate meter housing type",
        type: "radio",
        options: ["Free Standing", "Wall Mounted"],
        key: "housingType",
      },
    ],
    Reposition: [
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
    Relocation: [
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

    Damaged: [
      {
        label: "Is housing required?",
        type: "radio",
        options: ["Yes", "No"],
        key: "housingRequired",
      },
      {
        label: "Please select type of housing required",
        type: "radio",
        options: ["Free Standing", "Wall Mounted"],
        key: "housingType",
        condition: (state) => state.housingRequired === "Yes",
      },
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
    "Adversarial removal": [
      
      {
        label:
          "Please note the Removal job will require purging. Do you require NGM to carryout purging?",
        type: "radio",
        options: ["Yes", "No"],
        key: "debtManagementVisit",
      },
    ],
    "Pressure Change": [
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
    Reconnect: [
      {
        label: "Required Payment Type",
        type: "radio",
        options: ["Credit", "Pre-payment"],
        key: "requiredPaymentType",
      },
      {
        label: "Reconnect after Debt?",
        type: "radio",
        options: ["Yes", "No"],
        key: "reconnectAfterDebt",
      },
    ],
    "Site Visit": [
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

    Pickup: [
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
    messageWhenPatternMismatch: "Final Read must be 4 or 5 digits (no letters or symbols)",
    condition: (state) => state.pickupEquipment === "Meter"
},
      {
        label: "Is the meter pickup address different from above?",
        type: "radio",
        options: ["Yes", "No"],
        key: "isDifferentAddress",
        defaultValue: "No", //
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

  get dynamicQuestions() {
    const subtype = this.selectedSubType?.label;
    if (!subtype) return [];

    return (
      this.questionConfig[subtype]?.map((q) => {
        let normalizedSelectOptions = [];
        let normalizedRadioOptions = [];

        // Normalize select options
        if (q.type === "select") {
          normalizedSelectOptions = (q.options || []).map((opt) => {
            return typeof opt === "string"
              ? { label: opt, value: opt }
              : { label: opt.label, value: opt.value };
          });
        }

        

        // Normalize radio options
        if (q.type === "radio") {
          normalizedRadioOptions = (q.options || []).map((opt) => {
            return typeof opt === "string"
              ? { label: opt, value: opt }
              : { label: opt.label, value: opt.value };
          });
        }

       

        return {
          ...q,
          visible: q.condition ? q.condition(this.state) : true,
          selectOptions: normalizedSelectOptions,
          radioOptions: normalizedRadioOptions,
          isSelect: q.type === "select",
          isNumber: q.type === "number",
          isRadio: q.type === "radio",
          isFile: q.type === "file",
          isText: q.type === "text",
          isTextarea: q.type === "textarea",
          isDate: q.type === "date",
          isError: q.type === "error",
          value: this.state[q.key] || "",
        };
      }) || []
    );
  }

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

  handleJobSelect(event) {
    this.highlightSelected(event, '.card-group');  // highlight
    const selectedJobLabel = event.target.value;
     this.updateRequestTypesClass();
    this.selectedJob = selectedJobLabel;
    this.selectedSubType = null;
    this.filteredSubTypes = this.jobTypeSubtypes[selectedJobLabel] || [];
    this.meterSuggestions = [];
    this.priceMessageFlag = false;
    // Reset UI flags
    this.resetUIFlags();
  }

  handleSubTypeSelect(event) {
    this.highlightSelected(event, '.card-group'); // highlight
    const selectedSubTypeLabel = event.target.value;
    this.updateRequestTypesClass();
    this.selectedSubType = { label: selectedSubTypeLabel };
    this.meterSuggestions = [];
    this.priceMessageFlag = false;
    //  Reset all keys from questionConfig for selected subtype
    const questions = this.questionConfig[selectedSubTypeLabel];
    if (questions) {
      const newState = { ...this.state };
      questions.forEach((q) => {
        if (q.key) {
          newState[q.key] = null;
          this[q.key] = null;
        }
      });
      this.state = newState;

      
    }

    // Reset UI flags
    this.resetUIFlags();

    if (selectedSubTypeLabel === "Pickup") {
      this.state.isDifferentAddress = "No";
    }
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

  handleDynamicChange(event) {
    const key = event.target.dataset.key || event.target.name;
    let value = event.detail?.value || event.target.value;
    console.log("Key: ", key);
    console.log("Value: ", value);

    
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

    // Update state safely
    this.state[key] = value;

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

      case "serviceLocation":
        this.gt1 = null;
        this.state.gt1 = null;
        this.showGt1Upload = false;
        this.showGt1Error = false;

        if (value === "Existing") {
          this.changePaymentType = null;
        }
        break;

      case "pressureTier":
    this.state.pressureTier = value;

    const gt1RequiredTiers = ["Medium Pressure", "Intermediate Pressure", "High Pressure"];
    const specialMeterSizes = ["Rotary", "Turbine"];
    const serviceLocation = this.state.serviceLocation;
    const meterSize = this.state.MeterSize;

    const parentCondition =
        gt1RequiredTiers.includes(value) ||
        serviceLocation === "New" ||
        specialMeterSizes.includes(meterSize);

    if (!parentCondition) {
        // Reset GT1-related state when GT1 question should not be shown
        this.state.gt1 = null;
        this.showGt1Upload = false;
        this.showGt1Error = false;
    }
    break;

case "gt1":
    this.state.gt1 = value;
    this.showGt1Upload = value === "Yes";
    this.showGt1Error = value === "No";
    break;

      case "pickupRequired":
        this.pickupRequired = value;
        break;

      case "isDifferentAddress":
        this.isDifferentAddress = value;
        break;

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
        } 
else {
    reasonOptions = []; // Clear if placeholder selected
  }


        const siteVisitQuestions = this.questionConfig["Site Visit"];
        const reasonQuestion = siteVisitQuestions?.find(
          (q) => q.key === "siteVisitReason"
        );
        if (reasonQuestion) {
          reasonQuestion.options = reasonOptions;
        }
        break;

      case "finalRead":
    value = value.replace(/\D/g, "").slice(0, 5); // Only digits, max 5
    if (!this.errors) this.errors = {};
    if (!this.state) this.state = {};

    this.state.finalRead = value;

    // Validation
    if (value.length === 0) {
        this.errors.finalRead = "Final Read is required";
    } else if (value.length < 4) {
        this.errors.finalRead = "Final Read must be at least 4 digits";
    } else {
        this.errors.finalRead = "";
    }

    // Update dynamicQuestions so UI reflects error
    const question = this.dynamicQuestions.find(q => q.key === "finalRead");
    if (question) {
        question.value = value;
        question.error = this.errors.finalRead;
        question.inputClass = question.error ? 'input-error' : '';
    }
    break;
      default:
        // No additional logic needed
        break;
    }
  }

    
      


      
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

      const subtype = this.selectedSubType?.label;

      if (subtype && this.questionConfig[subtype]) {
        this.questionConfig[subtype] = this.questionConfig[subtype].map((q) => {
          if (q.key === "MeterSize") {
            return {
              ...q,
              options: meterSizeOptions,
            };
          }
          return q;
        });
      }

      this.state = {
        ...this.state,
        MeterSize: meterSizeOptions.length ? meterSizeOptions[0].value : "",
        housingRequired: "",
        HModel: "",
        housingType: "",
      };

      console.log("Updated MeterSize options:", meterSizeOptions);
      console.log("Updated State:", JSON.stringify(this.state));
    } else {
      // Reset MeterSize if inputs are invalid
      meterSizeOptions = [{ label: "  ", value: "" }]; // placeholder option

      const subtype = this.selectedSubType?.label;
      if (subtype && this.questionConfig[subtype]) {
        this.questionConfig[subtype] = this.questionConfig[subtype].map((q) => {
          if (q.key === "MeterSize") {
            return {
              ...q,
              options: meterSizeOptions,
            };
          }
          return q;
        });
      }

      this.state = {
        ...this.state,
        MeterSize: "", // matches placeholder value
        housingRequired: "",
        HModel: "",
        housingType: "",
      };

      console.log("Invalid inputs, resetting MeterSize:", meterSizeOptions);
      console.log("Updated State:", JSON.stringify(this.state));
    }

  }
handleMeterSizeSelect(event) {
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
        try {
            console.log('Price calculation logic goes here!');
            console.log('Current state:', JSON.stringify(this.state));
            console.log('status'+ this.status);
            console.log('paymentMechanism'+ this.paymentMechanism);
            console.log('meterSize'+ this.meterSize);
            console.log('Current state:', JSON.stringify(this.state));

            const dataMap = new Map(Object.entries(this.state));
            // Prepare request body
            const requestBody = {
                NGMCP_Job_Type__c: this.selectedJob || '',
                NGMCP_Job_Sub_category__c: this.selectedSubType?.label || '',
                NGMCP_Commercial_Residential__c: this.status|| '',
                NGMCP_Payment_Mechanism__c: this.paymentMechanism || '',
                NGMCP_Meter_Model__c: this.meterSize || '',
                NGMCP_Pressure_Tier__c: dataMap.get('pressureTier') || '',
                NGMCP_Meter_Size__c: dataMap.get('MeterSize') || '',                
                NGMCP_Housing_Required__c: dataMap.get('housingRequired') || '',
                NGMCP_Housing_Type__c: dataMap.get('HModel') || '',
                NGMCP_Payment_Method__c: dataMap.get('paymentMethod') || '',
                NGMCP_Debt_Management_Visit__c: dataMap.get('debtManagementVisit') || '',
                NGMCP_Service_Location__c: dataMap.get('serviceLocation') || '',
                NGMCP_Twin_Stream__c: dataMap.get('twinStream') || '',
                NGMCP_Electric_Interface__c: dataMap.get('electricInterface') || '',
                NGMCP_Meter_Bypass__c: dataMap.get('meterBypass') || '',
                NGMCP_Converter_Required__c: dataMap.get('converterRequired') || '',
                NGMCP_Damage_Limited__c: dataMap.get('damageLimited') || '',
                NGMCP_Base_Required__c: dataMap.get('baseRequired') || '',
                NGMCP_With_in_TwoMeters__c: dataMap.get('withinTwoMeters') || '',
                NGMCP_Is_New_Connection__c: '',
                NGMCP_Is_Reconnection__c: '',
                NGMCP_Is_Reconnection_Debt__c: ''
            };

            console.log('Request Body:', JSON.stringify(requestBody));

            // Call the Apex method
            const result = await getPrice({ payload: JSON.stringify(requestBody) });
            console.log('Price Result:', JSON.stringify(result));
            if(result && result.length > 0 && result[0].NGMCP_Job_Price__c > 0 ){
              this.priceMessageFlag= true;
              this.priceMessage =`Price for the job is £${result[0].NGMCP_Job_Price__c}`;
            }else if(result[0].NGMCP_Job_Price__c == 0 ){
              this.priceMessageFlag= true;
              this.priceMessage = 'Good News! This is a free of charge job.'
            }else{
               
            }

        } catch (error) {
            console.error('Error fetching price:', error);
            this.priceMessageFlag= true;
            this.priceMessage = 'This is a non-standard job, please submit the job to get a quotation.'
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




}