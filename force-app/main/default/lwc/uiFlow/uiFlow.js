import { LightningElement, track } from 'lwc';

export default class WorkRequestComponent extends LightningElement {
    @track pressureTier = 'Low Pressure';
    @track outletPressure = 21;
    @track peakLoad = '';
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

    uiConfig = {
        requestTypes: [
            {
                label: 'Work Request',
                helpText: 'Choose job type and subtype',
                jobTypes: [
                    { label: 'Install' },
                    { label: 'Exchange' },
                    { label: 'Remove' },
                    { label: 'MeterMove' },
                    { label: 'OtherVisits' }
                ]
            }
        ]
    };

    jobTypeSubtypes = {
        Install: ["Meter", "Converter", "Housing"],
        Exchange: ["Specification Change", "Accuracy Test", "GPS", "Housings", "Converter", "Third Party"],
        Remove: ["Meters", "Pickup", "Converter"],
        MeterMove: ["Reposition", "Relocation"],
        OtherVisits: ["Damaged", "Debt Management", "Post Commissioning Checks", "Pressure Change", "Reconnect", "Site Visit", "Theft of Gas Exchange"]
    };

    qmaxTable = [
        { model: 'U6', qmax: 64 },
        { model: 'U16', qmax: 171 },
        { model: 'U25', qmax: 267 },
        { model: 'U40', qmax: 427 },
        { model: 'U65', qmax: 693 },
        { model: 'U100', qmax: 1067 },
        { model: 'U160', qmax: 1706 }
    ];

    questionConfig = {
        // ✅ Specification Change
        'Specification Change': [
            { label: 'Please confirm the Service Pressure Tier', type: 'select', options: ['Low Pressure', 'MP35', 'MP65', 'MP105', 'MP180', 'MP270', 'Intermediate Pressure', 'High Pressure'], key: 'pressureTier', defaultValue: 'Low Pressure' },
            
            { label: 'Please confirm the required metering outlet pressure (mbar)', type: 'text'},
            { label: 'Please provide the expected peak hourly load (kWh)', type: 'text', key: 'peakLoad' },

            // GT1 logic
            { label: 'Is the new meter going into the existing or new service location?', type: 'radio', options: ['Existing', 'New'], key: 'serviceLocation' },
            { label: 'Do you have GT1/Service Quotation?', type: 'radio', options: ['Yes', 'No'], key: 'gt1', condition: (state) => state.serviceLocation === 'New' },

// ✅ Place error message right after GT1 question
            { label: 'This job requires a GT1 to be completed by the network provider and the GT1 survey attached, therefore it cannot be raised. If you have any further questions please contact 0800 001 4340.', type: 'error', key: 'gt1Error', condition: (state) => state.serviceLocation === 'New' && state.gt1 === 'No' },

            { label: 'Please attach GT1/Service Quotation document', type: 'file', key: 'gt1File', condition: (state) => state.serviceLocation === 'New' && state.gt1 === 'Yes' },

            // Housing logic
            { label: 'Is housing required?', type: 'radio', options: ['Yes', 'No'], key: 'housingRequired' },
            { label: 'Please select type of housing required', type: 'radio', options: ['Free Standing', 'Wall Mounted'], key: 'housingType', condition: (state) => state.housingRequired === 'Yes' },
            { label: 'Is a base Required?', type: 'radio', options: ['Yes', 'No'], key: 'baseRequired', condition: (state) => state.housingRequired === 'Yes' && state.housingType === 'Free Standing' },

            // Additional logic
            { label: 'Are there any special electric interfaces required?', type: 'radio', options: ['Yes', 'No'], key: 'electricInterface' },
           { label: 'Change Payment Type?', type: 'radio', options: ['Yes', 'No'], key: 'changePaymentType' },
            { label: 'Required Meter Payment Type', type: 'radio', options: ['Credit', 'Pre-payment'], key: 'paymentMethod', condition: (state) => state.changePaymentType === 'Yes' },
            { label: 'Is a meter by-pass required?', type: 'radio', options: ['Yes', 'No'], key: 'meterBypass' },
            { label: 'Is a converter required?', type: 'radio', options: ['Yes', 'No'], key: 'converterRequired' },
            { label: 'Is a twin stream pressure reduction installation required?', type: 'radio', options: ['Yes', 'No'], key: 'twinStream' },
            { label: 'Do you require an AMR device?', type: 'radio', options: ['Yes', 'No'], key: 'amrDevice' }
        ],

        // ✅ Meter
        'Meter': [
            { label: 'Please confirm the Service Pressure Tier', type: 'select', options: ['Low Pressure', 'MP35', 'MP65', 'MP105', 'MP180', 'MP270', 'Intermediate Pressure', 'High Pressure'], key: 'pressureTier', defaultValue: 'Low Pressure' },
            
            { label: 'Please confirm the required metering outlet pressure (mbar)', type: 'text', key: 'outletPressure', defaultValue: 21 },
            { label: 'Please provide the expected peak hourly load (kWh)', type: 'text', key: 'peakLoad' },

            // New logic
            { label: 'Select Payment Method Required for New Meter', type: 'radio', options: ['Credit', 'Pre-payment'], key: 'paymentMethod' },
            { label: 'Do you have GT1/Service Quotation?', type: 'radio', options: ['Yes', 'No'], key: 'gt1' },
            { label: 'Please attach GT1/Service Quotation document', type: 'file', key: 'gt1File', condition: (state) => state.gt1 === 'Yes' },

            // Housing logic
            { label: 'Is housing required?', type: 'radio', options: ['Yes', 'No'], key: 'housingRequired' },
            { label: 'Please select type of housing required', type: 'radio', options: ['Free Standing', 'Wall Mounted'], key: 'housingType', condition: (state) => state.housingRequired === 'Yes' },
            { label: 'Is a base Required?', type: 'radio', options: ['Yes', 'No'], key: 'baseRequired', condition: (state) => state.housingRequired === 'Yes' && state.housingType === 'Free Standing' },

            // Additional logic
            { label: 'Are there any special electric interfaces required?', type: 'radio', options: ['Yes', 'No'], key: 'electricInterface' },
            { label: 'Is a meter by-pass required?', type: 'radio', options: ['Yes', 'No'], key: 'meterBypass' },
            { label: 'Is a converter required?', type: 'radio', options: ['Yes', 'No'], key: 'converterRequired' },
            { label: 'Is a twin stream pressure reduction installation required?', type: 'radio', options: ['Yes', 'No'], key: 'twinStream' },
            { label: 'Do you require an AMR device?', type: 'radio', options: ['Yes', 'No'], key: 'amrDevice' }
        ],

            'Meters' : [

             { label: 'Please confirm the Service Pressure Tier', type: 'select', options: ['Low Pressure', 'MP35', 'MP65', 'MP105', 'MP180', 'MP270', 'Intermediate Pressure', 'High Pressure'], key: 'pressureTier', defaultValue: 'Low Pressure' },
             
    { 
        label: 'Please note the Removal job will require purging. Do you require NGM to carry out purging?', 
        type: 'radio', 
        options: ['Yes', 'No'], 
        key: 'purgingRequired' 
    },
    
],

        'Pickup': [
    {
        label: 'What Equipment is required to be picked up?',
        type: 'radio',
        options: ['Yes', 'No'],
        key: 'pickupRequired'
    },
    {
        label: 'Provide Final Read',
        type: 'text',
        key: 'finalRead',
        condition: (state) => state.pickupRequired === 'Yes'
    },
    {
        label: 'Is the meter pickup address different from above?',
        type: 'radio',
        options: ['Yes', 'No'],
        key: 'isDifferentAddress',
        defaultValue: 'No',
        condition: (state) => state.pickupRequired === 'Yes'
    },
    {
        label: 'Please enter Alternative Pickup Address',
        type: 'address', // Custom type for multiple fields
        fields: ['Building Name', 'Building Number', 'Street', 'Dependant Locality', 'Post Town', 'Post Code'],
        key: 'alternativeAddress',
        condition: (state) => state.isDifferentAddress === 'Yes'
    }
],
             

        // ✅ Third Party
        'Third Party': [
            { label: 'Please confirm the Service Pressure Tier', type: 'select', options: ['Low Pressure', 'MP35', 'MP65', 'MP105', 'MP180', 'MP270', 'Intermediate Pressure', 'High Pressure'], key: 'pressureTier', defaultValue: 'Low Pressure' },
            { label: 'Please confirm the existing Asset Details', type: 'select', options: ['Manufacturer', 'Serial Number', 'Model', 'Year of Manufacturer', 'Meter Payment Method', 'Meter Type', 'Imperial/Metric Indicator', 'No. of Dials'], key: 'assetDetails' },
            
            { label: 'Please confirm the required metering outlet pressure (mbar)', type: 'text', key: 'outletPressure', defaultValue: 21 },
            { label: 'Please provide the expected peak hourly load (kWh)', type: 'text', key: 'peakLoad' },

            // GT1 logic
            { label: 'Is the new meter going into the existing or new service location?', type: 'radio', options: ['Existing', 'New'], key: 'serviceLocation' },
            { label: 'Do you have GT1/Service Quotation?', type: 'radio', options: ['Yes', 'No'], key: 'gt1', condition: (state) => state.serviceLocation === 'New' },
            { label: 'Please attach GT1/Service Quotation document', type: 'file', key: 'gt1File', condition: (state) => state.gt1 === 'Yes' },
            { label: 'This job requires a GT1 survey attached. Please contact 0800 001 4340 for assistance.', type: 'error', key: 'gt1Error', condition: (state) => state.gt1 === 'No' },

            // Housing logic
            { label: 'Is housing required?', type: 'radio', options: ['Yes', 'No'], key: 'housingRequired' },
            { label: 'Please select type of housing required', type: 'radio', options: ['Free Standing', 'Wall Mounted'], key: 'housingType', condition: (state) => state.housingRequired === 'Yes' },
            { label: 'Is a base Required?', type: 'radio', options: ['Yes', 'No'], key: 'baseRequired', condition: (state) => state.housingRequired === 'Yes' && state.housingType === 'Free Standing' },

            // Additional logic
            { label: 'Change Payment Type?', type: 'radio', options: ['Yes', 'No'], key: 'changePaymentType' },
            { label: 'Required Meter Payment Type', type: 'radio', options: ['Credit', 'Pre-payment'], key: 'paymentMethod', condition: (state) => state.changePaymentType === 'Yes' },
            { label: 'Is a meter by-pass required?', type: 'radio', options: ['Yes', 'No'], key: 'meterBypass' },
            { label: 'Is a converter required?', type: 'radio', options: ['Yes', 'No'], key: 'converterRequired' },
            { label: 'Are there any special electric interfaces required?', type: 'radio', options: ['Yes', 'No'], key: 'electricInterface' },
            { label: 'Is a twin stream pressure reduction installation required?', type: 'radio', options: ['Yes', 'No'], key: 'twinStream' },
            { label: 'Do you require an AMR device?', type: 'radio', options: ['Yes', 'No'], key: 'amrDevice' }
        ],

        'Housing': [
        // Question 1: Service Pressure Tier (Dropdown)
        { label: 'Please confirm the Service Pressure Tier', type: 'select', options: ['Low Pressure', 'MP35', 'MP65', 'MP105', 'MP180', 'MP270', 'Intermediate Pressure', 'High Pressure'], key: 'pressureTier', defaultValue: 'Low Pressure' },

        // Question 2: Required Metering Outlet Pressure (Text)
        { 
            label: 'Please confirm the required metering outlet pressure (mbar)', 
            type: 'text', 
            key: 'outletPressure' 
        },

        // Question 3: Expected Peak Hourly Load (Text)
        { 
            label: 'Please provide the expected peak hourly load (kWh)', 
            type: 'text', 
            key: 'peakLoad' 
        },

        // Question 4: Meter Housing Size (Dropdown)
        { 
            label: 'Please select the appropriate meter housing size', 
            type: 'select', 
            options: ['U6', 'U16', 'U25', 'U40', 'U65', 'U100', 'U160', 'Rotary', 'Turbine'], 
            key: 'housingSize' 
        },

        // Question 5: Meter Housing Type (Text)
        
{ 
            label: 'Please select the appropriate meter housing type', 
            type: 'radio', 
            options: ['Free Standing', 'Wall Mounted'], 
            key: 'housingType' 
        }

    ],

            'Housings': [
        

        // Question 5: Meter Housing Type (Text)
        
{ 
            label: 'Please select the appropriate meter housing type', 
            type: 'radio', 
            options: ['Free Standing', 'Wall Mounted'], 
            key: 'housingType' 
        }

    ],
            



        // ✅ MeterMove Subtypes
        'Reposition': [
            { label: 'Is the meter to be moved within two meters of the existing Service pipe/ECV?', type: 'radio', options: ['Yes', 'No'], key: 'withinTwoMeters' },
            { label: 'Please provide photos of the existing meter position and desired location', type: 'file', key: 'existingMeterPhotos' }
        ],
        'Relocation': [
            { label: 'Please provide photos of the existing meter position and desired location', type: 'file', key: 'existingMeterPhotos' },
            { label: 'Please attach the Service Quotation for the new Service location', type: 'file', key: 'serviceQuotation' }
        ],

        // ✅ OtherVisits Subtypes
        'Damaged': [
            { label: 'Is housing required?', type: 'radio', options: ['Yes', 'No'], key: 'housingRequired' },
            { label: 'Please select type of housing required', type: 'radio', options: ['Free Standing', 'Wall Mounted'], key: 'housingType', condition: (state) => state.housingRequired === 'Yes' },
            { label: 'Is the damage limited to the meter itself?', type: 'radio', options: ['Yes', 'No', "Don't Know"], key: 'damageLimited' },
           // ✅ Damaged subtype questions

    {
        label: 'Do you have a crime reference number?',
        type: 'radio',
        options: ['Yes', 'No'],
        key: 'hasCrimeRef'
    },
    {
        label: 'Crime Reference Number',
        type: 'text',
        key: 'crimeRefNumber',
        condition: (state) => state.hasCrimeRef === 'Yes'
    },

        ],
        'Debt Management': [
            
{
        label: 'Which Debt Management service do you require?',
        type: 'radio',
        options: ['Discontinuance', 'Adversarial Removal'],
        key: 'debtServiceType'
    },

            { label: 'Please note the Removal job will require purging. Do you require NGM to carryout purging?', type: 'radio', options: ['Yes', 'No'], key: 'debtManagementVisit' }
        ],
        'Pressure Change': [
            { label: 'Do you require a pressure increase / pressure decrease?', type: 'text', key: 'pressureChangeValue', maxLength: 4 },
            { label: 'Do you require a pressure increase / pressure decrease?', type: 'radio', options: ['Increase', 'Decrease'], key: 'pressureChangeType' }
        ],
        'Reconnect': [
            { label: 'Required Payment Type', type: 'radio', options: ['Credit', 'Pre-payment'], key: 'requiredPaymentType' },
            { label: 'Reconnect after Debt?', type: 'radio', options: ['Yes', 'No'], key: 'reconnectAfterDebt' }
        ],
        'Site Visit': [
    {
        label: 'Select Asset Type',
        type: 'select',
        options: ['Select Asset Type','Meter', 'Converter', 'Isolation'],
        key: 'assetType'
    },
    {
        label: 'What is the reason for site visit?',
        type: 'select',
        key: 'siteVisitReason',
        options: [], // Will be dynamically populated
        condition: (state) => !!state.assetType // Show only after assetType is selected
    }
],

      'Pickup': [
    {
        label: 'What Equipment is required to be picked up?',
        type: 'radio',
        options: ['Meter', 'Converter'],
        key: 'pickupEquipment'
    },
    {
        label: 'Provide Final Read',
        type: 'text',
        key: 'finalRead',
        condition: (state) => state.pickupEquipment === 'Meter' // ✅ Show only if Meter selected
    },
    {
        label: 'Is the meter pickup address different from above?',
        type: 'radio',
        options: ['Yes', 'No'],
        key: 'isDifferentAddress',
        defaultValue: 'No' // ✅ Default selection
    },
    {
        label: 'Building Name',
        type: 'text',
        key: 'buildingName',
        condition: (state) => state.isDifferentAddress === 'Yes'
    },
    {
        label: 'Building Number',
        type: 'text',
        key: 'buildingNumber',
        condition: (state) => state.isDifferentAddress === 'Yes'
    },
    {
        label: 'Street',
        type: 'text',
        key: 'street',
        condition: (state) => state.isDifferentAddress === 'Yes'
    },
    {
        label: 'Dependant Locality',
        type: 'text',
        key: 'dependentLocality',
        condition: (state) => state.isDifferentAddress === 'Yes'
    },
    {
        label: 'Post Town',
        type: 'text',
        key: 'postTown',
        condition: (state) => state.isDifferentAddress === 'Yes'
    },
    {
        label: 'Post Code',
        type: 'text',
        key: 'postCode',
        condition: (state) => state.isDifferentAddress === 'Yes'
    }
]
    };


    get dynamicQuestions() {
    const subtype = this.selectedSubType?.label;
    if (!subtype) return [];
    return this.questionConfig[subtype]?.map(q => ({
        ...q,
        visible: q.condition ? q.condition(this.state) : true, // ✅ Pass state
        radioOptions: q.options?.map(opt => ({ label: opt, value: opt })),
        isSelect: q.type === 'select',
        isNumber: q.type === 'number',
        isRadio: q.type === 'radio',
        isFile: q.type === 'file',
        isText: q.type === 'text',
        isTextarea: q.type === 'textarea',
        isDate: q.type === 'date',
        isError: q.type === 'error',
        value: this.state[q.key] || '' // ✅ Bind current value
    })) || [];
}

    handleRequestSelect(event) {
        this.selectedRequest = this.uiConfig.requestTypes.find(req => req.label === event.target.value);
        this.selectedJob = null;
        this.selectedSubType = null;
        this.filteredSubTypes = [];
        this.meterSuggestions = [];
    }

    handleJobSelect(event) {
    const selectedJobLabel = event.target.value;
    this.selectedJob = selectedJobLabel;
    this.selectedSubType = null;
    this.filteredSubTypes = this.jobTypeSubtypes[selectedJobLabel] || [];
    this.meterSuggestions = [];

    // ✅ Reset all dynamic state values
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

    handleSubTypeSelect(event) {
    const selectedSubTypeLabel = event.target.value;
    this.selectedSubType = { label: selectedSubTypeLabel };
    this.meterSuggestions = [];
    

    // ✅ Reset dynamic state values when switching subtype
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

    
if (selectedSubTypeLabel === 'Pickup') {
        this.state.isDifferentAddress = 'No'; // Default selection
    }

}
    handleDynamicChange(event) {
        const key = event.target.dataset.key || event.target.name;
        const value = event.detail?.value || event.target.value;
        this[key] = value;

        this.state = { ...this.state, [key]: value };

        // ✅ Housing logic
        
if (key === 'housingRequired') {
    this.housingRequired = value;
    this.state.housingRequired = value;

    // Reset dependent fields when housingRequired changes
    if (value === 'No') {
        this.housingType = null;
        this.state.housingType = null;
        this.baseRequired = null;
        this.state.baseRequired = null;
    }
}

if (key === 'housingType') {
    this.housingType = value;
    this.state.housingType = value;

    // Reset baseRequired when housingType changes
    if (value !== 'Free Standing') {
        this.baseRequired = null;
        this.state.baseRequired = null;
    }
}
        // ✅ GT1 logic

        
        if (key === 'serviceLocation') {
    // Reset GT1-related state whenever serviceLocation changes
    this.gt1 = null;
    this.state.gt1 = null;
    this.showGt1Upload = false;
    this.showGt1Error = false;
}

if (key === 'gt1') {
    this.showGt1Upload = (value === 'Yes');
    this.showGt1Error = (value === 'No');
}

        // ✅ Meter logic
        if (key === 'outletPressure') {
            if (value.length > 4) {
                event.target.value = value.slice(0, 4);
            }
            this.outletPressure = value;
            if (Number(value) > 21) {
                this.meterSuggestions = ['Rotary', 'Turbine'];
            } else {
                this.calculateMeterSize(Number(this.peakLoad || 0));
            }
        }

        if (key === 'pickupRequired') {
    this.pickupRequired = value;
}
if (key === 'isDifferentAddress') {
    this.isDifferentAddress = value;
}

        
if (key === 'changePaymentType') {
        this.changePaymentType = value;
    }


        if (key === 'peakLoad') {
            this.peakLoad = value;
            this.calculateMeterSize(Number(value));
        }

      if (key === 'changePaymentType') {
    this.changePaymentType = value;
        }
        if (key === 'serviceLocation' && value === 'Existing') {
    this.changePaymentType = null; // Reset when switching back
}


            
 if (key === 'assetType') {
        let reasonOptions = [];
        if (value === 'Meter') {
            reasonOptions = ['Site Visit for Enquiry/Complaint', 'Ad-Hoc'];
        } else if (value === 'Converter') {
            reasonOptions = ['Converter Re-Syncing'];
        } else if (value === 'Isolation') {
            reasonOptions = ['Install EMS to Isolation'];
        }

        // Update questionConfig dynamically
        const siteVisitQuestions = this.questionConfig['Site Visit'];
        const reasonQuestion = siteVisitQuestions.find(q => q.key === 'siteVisitReason');
        if (reasonQuestion) {
            reasonQuestion.options = reasonOptions;
        }
    }


    }

    calculateMeterSize(load) {
        if (!load || load <= 0) {
            this.meterSuggestions = [];
            this.selectedMeterSize = null;
            return;
        }

        if (load > 1706) {
            this.meterSuggestions = ['Rotary', 'Turbine'];
            this.selectedMeterSize = null;
        } else {
            const filtered = this.qmaxTable.filter(item => item.qmax >= load);
            this.meterSuggestions = [...filtered.map(item => item.model)];
            this.selectedMeterSize = filtered.length ? filtered[0].model : null;
        }
    }

    handleMeterSizeSelect(event) {
        this.selectedMeterSize = event.target.value;
    }

    handleGetPrice() {
        alert('Price calculation logic goes here!');
    }
}