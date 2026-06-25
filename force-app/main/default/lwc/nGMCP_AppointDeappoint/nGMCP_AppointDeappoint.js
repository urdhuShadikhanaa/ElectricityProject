const SEP = '\u00A0\u00A0\u00A0';
import { LightningElement, track, api } from 'lwc';
import submitAppntDeappnt from "@salesforce/apex/NGMCP_AppointmentDeappointmentHandler.submitAppntDeappnt";
import createAppntDeappntRecord from "@salesforce/apex/NGMCP_AppointmentDeappointmentHandler.createAppntDeappntRecord";
import getSupplierInfo from "@salesforce/apex/NGMCP_AppointmentDeappointmentHandler.getSupplierInfo";
import getAMRAssetDetails from "@salesforce/apex/NGMCP_AMRIntegrationClass.getAMRAssetDetails";
import submitAMR from "@salesforce/apex/NGMCP_AMRIntegrationClass.submitAMR";
import createAMR from "@salesforce/apex/NGMCP_AMRIntegrationClass.createAMR";
import getRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.getRequest";
import USER_ID from '@salesforce/user/Id';
export default class NGMCP_AppointDeappoint extends LightningElement {
    @track selectedMain;
    @track selectedAppType;
    @track selectedDeType;
    @api jobMode;
    hasAutoSelected = false;
    @track amrassetdetails;
    meterLinkCode
    @track AmrContract;
    @track address;
    @api marketSectorCode;
    @api wrapperRec
    @track effectiveDate; // 'YYYY-MM-DD'
    minDate;       // optional
    maxDate;       // optional
    holidays = []; // optional: ['2026-01-26','2026-03-08', ...]
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
    @api thirdPartyAssetDetails;  // 16 march api change
    @api customer;
    @track isLoading = false;
    @track isModal = false;
    @track successMessage //= SUCCESS_MESSAGE;
    @track serviceTicketid //= SERVICETICKET_ID;
    @track srNumber;
    @track consent = false;
    @track consentMessage = '';
    @api thirdParty;
    @track tileErrorFlag = false;       // controls the banner visibility
    @track tileErrorMessage = '';       // text of the banner
    @track mainTileErrorFlag = false;
    @track mainTileErrorMessage = '';
    @track appTileErrorFlag = false;
    @track appTileErrorMessage = '';
    @track locationCodeFlag = false;
    @track deappTileErrorFlag = false;
    @track deappTileErrorMessage = '';
    @track consentMessageFlag = false;
    userId = USER_ID;
    // Ensure 'state' is always defined so state.title is safe
    state = { title: '' };  // 19 march
    @api shortCode;
    @api mprnsupplier;
    // @api residentialSiteValue;

    @api
    set residentialSiteValue(value) {
        this._residentialSiteValue = value;
        const hasAnswer = value === 'Yes' || value === 'No';
        //  Safety: reset FNDAS if question becomes unanswered
        if (!hasAnswer && this.selectedAppType === 'FNDAS') {
            this.selectedAppType = null;
        }
    }
    get residentialSiteValue() {
        return this._residentialSiteValue;
    }

    @track addressInput = {
        buildingNumber: '', buildingName: '', dependentLocality: '',
        street: '', postalTown: '', postalCode: ''
    };

    _requestSource;
    selectedMain;
    hasAutoSelectedMainOption = false;
    @track newSupplierShortCode; // will hold the 3-char code (e.g., 'EUK')
    @api appointmentFlag;
    @api
    set requestSource(value) {
        this._requestSource = value;
        if (!value || this.hasAutoSelectedMainOption) {
            return;
        }
        const mapped = this.mapRequestSource(value);
        if (mapped) {
            this.selectedMain = mapped;
            this.hasAutoSelectedMainOption = true;
        }
    }

    get requestSource() {
        return this._requestSource;
    }

    newSupplierShortCodeOptions = [
        { value: 'AAS', label: 'AAS' + SEP + 'TotalEnergies Gas & Power Limited' },
        { value: 'AEL', label: 'AEL' + SEP + 'Gas Plus Supply Limited' },
        { value: 'ALA', label: 'ALA' + SEP + 'Square1 Energy Limited' },
        { value: 'ATL', label: 'ATL' + SEP + 'SSE Energy Solutions' },
        { value: 'BEN', label: 'BEN' + SEP + 'Ruby Gas Limited' },
        { value: 'BGB', label: 'BGB' + SEP + 'British Gas Business Ltd' },
        { value: 'BGF', label: 'BGF' + SEP + 'British Gas Trading Ltd' },
        { value: 'BPO', label: 'BPO' + SEP + 'Evolve Energy' },
        { value: 'BRO', label: 'BRO' + SEP + 'Brook Green Trading Ltd' },
        { value: 'BSA', label: 'BSA' + SEP + 'British Gas Business Ltd' },
        { value: 'CGP', label: 'CGP' + SEP + 'Crown Gas and Power Ltd' },
        { value: 'DGP', label: 'DGP' + SEP + 'DGP Energy Ltd' },
        { value: 'DLE', label: 'DLE' + SEP + 'Smartest Energy Business Ltd' },
        { value: 'DUE', label: 'DUE' + SEP + 'Smartest Energy Business Ltd' },
        { value: 'ECO', label: 'ECO' + SEP + 'Economy Gas Ltd' },
        { value: 'EDB', label: 'EDB' + SEP + 'EDF Energy Business Energy Ltd' },
        { value: 'EDS', label: 'EDS' + SEP + 'EDF Energy Customers Ltd' },
        { value: 'EFG', label: 'EFG' + SEP + 'TotalEnergies Gas & Power Limited' },
        { value: 'EOD', label: 'EOD' + SEP + 'E.ON NEXT' },
        { value: 'GEG', label: 'GEG' + SEP + 'Good Energy Gas Ltd' },
        { value: 'GGL', label: 'GGL' + SEP + 'Good Energy Gas Ltd' },
        { value: 'GLZ', label: 'GLZ' + SEP + 'Corona Energy Retail' },
        { value: 'GMT', label: 'GMT' + SEP + 'SEFE Energy Ltd' },
        { value: 'GNL', label: 'GNL' + SEP + 'Green Energy Ltd' },
        { value: 'HBL', label: 'HBL' + SEP + 'Octopus Energy Ltd' },
        { value: 'HDL', label: 'HDL' + SEP + 'Tru Energy' },
        { value: 'HEP', label: 'HEP' + SEP + 'Hartree Partners Power & Gas Company Limited' },
        { value: 'HET', label: 'HET' + SEP + 'Home Energy Trading Ltd' },
        { value: 'HUD', label: 'HUD' + SEP + 'Shell Energy UK Limited' },
        { value: 'IEO', label: 'IEO' + SEP + 'Ineos Energy Trading Limited' },
        { value: 'KEL', label: 'KEL' + SEP + 'Kensington Power Limited (Yu)' },
        { value: 'KNP', label: 'KNP' + SEP + 'Kensington Power Limited (Yu)' },
        { value: 'MAX', label: 'MAX' + SEP + 'Maxen Power' },
        { value: 'NGD', label: 'NGD' + SEP + 'Npower Gas Ltd' },
        { value: 'OCT', label: 'OCT' + SEP + 'Octopus Energy Ltd' },
        { value: 'OPA', label: 'OPA' + SEP + 'Opal Gas Limited' },
        { value: 'OSO', label: 'OSO' + SEP + 'OSSO Gas Limited' },
        { value: 'OTM', label: 'OTM' + SEP + 'Foxglove Energy Supply Ltd' },
        { value: 'OVO', label: 'OVO' + SEP + 'Ovo Gas Ltd' },
        { value: 'PSL', label: 'PSL' + SEP + 'P3P Energy Supply Limited' },
        { value: 'PZT', label: 'PZT' + SEP + 'Pozitive Energy Ltd' },
        { value: 'QNT', label: 'QNT' + SEP + 'Corona Energy Retail' },
        { value: 'REC', label: 'REC' + SEP + 'Ecotricity Limited (The Renewable Energy Company)' },
        { value: 'RGN', label: 'RGN' + SEP + 'Regent Gas Ltd' },
        { value: 'RST', label: 'RST' + SEP + 'RWE Supply & Trading GMBH' },
        { value: 'SBP', label: 'SBP' + SEP + 'Sembcorp Utilities (UK) Ltd' },
        { value: 'SCP', label: 'SCP' + SEP + 'Scottish Power' },
        { value: 'SCT', label: 'SCT' + SEP + 'Scottish Power' },
        { value: 'SLD', label: 'SLD' + SEP + 'Valda Energy Limited' },
        { value: 'SLG', label: 'SLG' + SEP + 'Corona Energy Retail' },
        { value: 'SOP', label: 'SOP' + SEP + 'OVO Gas Ltd' },
        { value: 'SPQ', label: 'SPQ' + SEP + 'OVO Gas Ltd' },
        { value: 'STH', label: 'STH' + SEP + 'OVO Gas Ltd' },
        { value: 'STL', label: 'STL' + SEP + 'So Energy Trading Ltd' },
        { value: 'UEL', label: 'UEL' + SEP + 'Utilita Energy Ltd' },
        { value: 'UGA', label: 'UGA' + SEP + 'United Gas & Power Ltd' },
        { value: 'UGP', label: 'UGP' + SEP + 'United Gas & Power Ltd' },
        { value: 'UKG', label: 'UKG' + SEP + 'UK Gas Supply' },
        { value: 'VCT', label: 'VCT' + SEP + 'Corona Energy Retail' },
        { value: 'VES', label: 'VES' + SEP + 'Engie Gas Shipper Ltd' },
        { value: 'VYU', label: 'VYU' + SEP + 'Flogas Enterprise Solutions Ltd' }
    ];

    // --- Deappointment → Change of Agent: MAM Id ---
    mamId = null;

    mamIdOptions = [
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

    //  SHOW "MAM Id" only when Deappointment → Change of Agent (CA) is selected
    get isChangeOfAgentDe() {
        return this.isDeappointment && this.selectedDeType === 'CA';
    }
    // 4 feb change for mandatory in one field

    handleNewSupplierShortCodeChange(event) {
        // Update value
        this.newSupplierShortCode = event.detail.value;
        // Persist to formData (helps the generic validator fallback)
        this.formData = { ...(this.formData || {}), newSupplierShortCode: this.newSupplierShortCode };
        // Hide the inline error immediately
        const container = event.target.closest('.custom-contact-field-section, .form-group, .field') || this.template;
        const err = container.querySelector('[data-error-for="newSupplierShortCode"]')
            || this.template.querySelector('[data-error-for="newSupplierShortCode"]');
        if (err) err.hidden = !!(this.newSupplierShortCode && String(this.newSupplierShortCode).trim());
        // Remove red outline if added
        if (event.target && event.target.classList) {
            event.target.classList.remove('invalid');
        }
    }

    handleMamIdChange(event) {
        this.mamId = event.detail.value || null;
        const err = this.template.querySelector('[data-error-for="mamId"]');
        if (err) err.hidden = !!this.mamId;
    }

    // Main options
    mainOptions = [
        { label: 'Appointment', value: 'Appointment', helpText: 'To submit an appointment request on a given MPRN' },
        { label: 'Deappointment', value: 'Deappointment', helpText: 'To submit a deappointment request on a given MPRN' }
    ];

    // Appointment types
    appointmentOptions = [
        { label: 'Change of Supplier (COS)', value: 'COS', helpText: 'Appointment request when a new supplier takes over responsibility for an MPRN.' },
        { label: 'New Meter Fitted (FIX)', value: 'FIX', helpText: 'Appointment request when a new gas meter is installed at an MPRN. ' },
        { label: 'New Connection (NEWCN)', value: 'NEWCN', helpText: 'Appointment request when a brand‑new gas connection and meter point (MPRN) is being created or activated for the first time.' },
        { label: 'Found Meter (FNDAS)', value: 'FNDAS', helpText: 'Appointment request when a meter is discovered at a site (“found meter”) but is not yet part of NGM’s recorded asset base.' },
        { label: 'Change of Agent (CA)', value: 'CA', helpText: 'Appointment request (Change of MAM) when a new NGM gas meter is installed at an MPRN following a 3rd party exchange.' },
    ];

    // Deappointment types
    deappointmentOptions = [
        { label: 'Change Of Agent (CA)', value: 'CA', helpText: 'Deappointment request to notify that NGM is no longer responsible for the meter due to a change of MAM/MEM.' },
        { label: 'Disconnection (DE)', value: 'DE', helpText: 'Deappointment request for a meter because it has been disconnected or removed.' },
        { label: 'Demolition (DEMO)', value: 'DEMO', helpText: 'Deappointment request when a premises associated with an MPRN is scheduled to be demolished or has already been demolished.' },
        { label: 'Change Of Supplier (COS)', value: 'COS', helpText: 'Deappointment request to end current supplier relationship against MPRN due to new supplier taking ownership.' },
        { label: 'Change Of Tenancy (COT)', value: 'COT', helpText: 'Deappointment request when an existing tenant vacates a property and the supplier’s association with the MPRN must be removed' },
        { label: 'Duplicate (DPL)', value: 'DPL', helpText: 'Used when a duplicate de‑appointment request is submitted for the same MPRN. ' },
        { label: 'End Of Tenancy (EOT)', value: 'EOT', helpText: 'Deappointment request when a tenant’s occupancy at a property ends and the supplier’s association with the MPRN must be removed.' },
        { label: 'Customer Removed Meter (CM)', value: 'CM', helpText: 'Deappointment request to notify when a gas meter has been removed by the customer, meaning the supplier must end the meter rental and remove their association with the MPRN.' },
        { label: 'AMR', value: 'AMR', helpText: 'Deappoint AMR' }
    ];

    // Global dropdown for Meter Link Code
    meterLinkOptions = [
        { label: 'Free Standing', value: 'Free Standing' },
        { label: 'Prime', value: 'Prime' },
        { label: 'Sub', value: 'Sub' }
    ];

    // Asset Details dropdowns
    modelOptions = [
        { label: 'Test Model 1', value: 'Model1' },
        { label: 'Test Model 2', value: 'Model2' }
    ];

    locationOptions = [
        { label: '0\u00A0\u00A0\u00A0Unknown', value: '00' },
        { label: '01\u00A0\u00A0\u00A0Cellar', value: '01' },
        { label: '02\u00A0\u00A0\u00A0Understairs', value: '02' },
        { label: '03\u00A0\u00A0\u00A0Hall', value: '03' },
        { label: '04\u00A0\u00A0\u00A0Kitchen', value: '04' },
        { label: '05\u00A0\u00A0\u00A0Bathroom', value: '05' },
        { label: '06\u00A0\u00A0\u00A0Garage', value: '06' },
        { label: '07\u00A0\u00A0\u00A0Canteen', value: '07' },
        { label: '08\u00A0\u00A0\u00A0Cloakroom', value: '08' },
        { label: '09\u00A0\u00A0\u00A0Cupboard', value: '09' },
        { label: '10\u00A0\u00A0\u00A0Domestic Science', value: '10' },
        { label: '11\u00A0\u00A0\u00A0Front Door', value: '11' },
        { label: '12\u00A0\u00A0\u00A0Hall Cupboard', value: '12' },
        { label: '13\u00A0\u00A0\u00A0Kitchen Cupboard', value: '13' },
        { label: '14\u00A0\u00A0\u00A0Kitchen Under Sink', value: '14' },
        { label: '15\u00A0\u00A0\u00A0Landing', value: '15' },
        { label: '16\u00A0\u00A0\u00A0Office', value: '16' },
        { label: '17\u00A0\u00A0\u00A0Office Cupboard', value: '17' },
        { label: '18\u00A0\u00A0\u00A0Outside W/C', value: '18' },
        { label: '19\u00A0\u00A0\u00A0Pantry', value: '19' },
        { label: '20\u00A0\u00A0\u00A0Porch', value: '20' },
        { label: '21\u00A0\u00A0\u00A0Public Bar', value: '21' },
        { label: '22\u00A0\u00A0\u00A0Rear of Shop', value: '22' },
        { label: '23\u00A0\u00A0\u00A0Saloon Bar', value: '23' },
        { label: '24\u00A0\u00A0\u00A0Shed', value: '24' },
        { label: '25\u00A0\u00A0\u00A0Shop Front', value: '25' },
        { label: '26\u00A0\u00A0\u00A0Shop Window', value: '26' },
        { label: '27\u00A0\u00A0\u00A0Staff Room', value: '27' },
        { label: '28\u00A0\u00A0\u00A0Store Room', value: '28' },
        { label: '29\u00A0\u00A0\u00A0Toilet', value: '29' },
        { label: '30\u00A0\u00A0\u00A0Under Counter', value: '30' },
        { label: '32\u00A0\u00A0\u00A0Meterbox', value: '32' },
        { label: '98\u00A0\u00A0\u00A0Other', value: '98' },
        { label: '99\u00A0\u00A0\u00A0Outside', value: '99' }
    ];

    statusOptions = [
        { label: 'CA\u00A0\u00A0\u00A0Capped', value: 'CA Capped' },
        { label: 'CD\u00A0\u00A0\u00A0Closed(Bypass)', value: 'CD Closed(Bypass)' },
        { label: 'CL\u00A0\u00A0\u00A0Clamped', value: 'CL Clamped' },
        { label: 'DM\u00A0\u00A0\u00A0Damaged', value: 'DM Damaged' },
        { label: 'FA\u00A0\u00A0\u00A0Faulty', value: 'FA Faulty' },
        { label: 'IN\u00A0\u00A0\u00A0Inactive', value: 'IN Inactive' },
        { label: 'LI\u00A0\u00A0\u00A0Live', value: 'LI Live' },
        { label: 'OP\u00A0\u00A0\u00A0Open(Bypass)', value: 'OP Open(Bypass)' },
        { label: 'PD\u00A0\u00A0\u00A0Phone Line Down', value: 'PD Phone Line Down' },
        { label: 'RE\u00A0\u00A0\u00A0Removed', value: 'RE Removed' },
        { label: 'UN\u00A0\u00A0\u00A0Unknown', value: 'UN Unknown' },
        { label: 'AC\u00A0\u00A0\u00A0Active', value: 'AC Active' }
    ];

    manufacturerOptions = [
        { label: 'Test Manufacturer 1', value: 'Man1' },
        { label: 'Test Manufacturer 2', value: 'Man2' }
    ];

    paymentOptions = [
        { label: 'Credit', value: 'Credit' },
        { label: 'Pre-Payment', value: 'Pre-Payment' }
    ];

    // Meter Details dropdowns
    meterTypeOptions = [
        { label: 'L\u00A0\u00A0\u00A0Leather Diaphgram', value: 'L Leather Diaphgram' },
        { label: 'S\u00A0\u00A0\u00A0Synthetic Diaphgram', value: 'S Synthetic Diaphgram' },
        { label: 'U\u00A0\u00A0\u00A0Ultrasonic', value: 'U Ultrasonic' },
        { label: 'T\u00A0\u00A0\u00A0Turbine', value: 'T Turbine' },
        { label: 'R\u00A0\u00A0\u00A0Rotary', value: 'R Rotary' },
        { label: 'D\u00A0\u00A0\u00A0Diaphragm', value: 'D Diaphragm' }
    ];

    capacityOptions = [
        { label: 'Select', value: 'Select' }
    ];

    mechanismOptions = [
        { label: 'CM\u00A0\u00A0\u00A0Coin Meter', value: 'CM' },
        { label: 'CR\u00A0\u00A0\u00A0Credit', value: 'CR' },
        { label: 'ET\u00A0\u00A0\u00A0Electronic Token Meter', value: 'ET' },
        { label: 'MT\u00A0\u00A0\u00A0Mechanical Token Meter', value: 'MT' },
        { label: 'TH\u00A0\u00A0\u00A0Thrift', value: 'TH' },
        { label: 'U\u00A0\u00A0\u00A0Unknown', value: 'U' },
        { label: 'PP\u00A0\u00A0\u00A0PREPAYMENT', value: 'PP' }
    ];

    collarOptions = [
        { label: 'B\u00A0\u00A0\u00A0Broken', value: 'B Broken' },
        { label: 'I\u00A0\u00A0\u00A0Intact', value: 'I Intact' }
    ];

    // Dynamic classes for radio cards
    get mainOptionsWithClass() {        
        const appointFlag =
            this.appointmentFlag === true || this.appointmentFlag === 'true';       
        const mapped = (this.mainOptions || []).map(opt => {           
            const isHidden =
                (!appointFlag && opt.value === 'Deappointment') ||
                (appointFlag && opt.value === 'Appointment');           
            const isSelected = this.selectedMain === opt.value;           
            const className = isSelected ? 'radio-card selected' : 'radio-card';            
            const checked = isSelected;            
            const hiddenStyle = isHidden ? 'display:none !important;' : '';
            return {
                ...opt,
                isHidden,
                hiddenStyle,   // <— add this
                className,
                checked,
                isSelected
            };
        });        
        return mapped;
    }
    get appointmentOptionsWithClass() {
        const hasResidentialAnswer =
            this.residentialSiteValue === 'Yes' ||
            this.residentialSiteValue === 'No';
        return this.appointmentOptions
            .filter(opt => {
                // ✅ Hide Found Meter until Yes/No is selected
                if (opt.value === 'FNDAS' && !hasResidentialAnswer) {
                    return false;
                }
                return true;
            })
            .map(opt => ({
                ...opt,
                className:
                    this.selectedAppType === opt.value
                        ? 'radio-card selected'
                        : 'radio-card',
                checked: this.selectedAppType === opt.value
            }));
    }

    get deappointmentOptionsWithClass() {
        return this.deappointmentOptions.map(opt => ({
            ...opt,
            className: this.selectedDeType === opt.value
                ? 'radio-card selected'
                : 'radio-card',
            checked: this.selectedDeType === opt.value,
            isSelected: this.selectedDeType === opt.value
        }));
    }

    handleCardClick(event) {
        this.selectedMain = event.currentTarget.querySelector('input').value;
        this.selectedAppType = null;
        this.selectedDeType = null;
        const err = this.template.querySelector('[data-error-for="jobType"]');
        if (err) err.hidden = true;
        this.mainTileErrorFlag = false; this.mainTileErrorMessage = '';
        this.appTileErrorFlag = false; this.appTileErrorMessage = '';
        this.deappTileErrorFlag = false; this.deappTileErrorMessage = '';
    }

    handleAppCardClick(event) {
        this.selectedAppType = event.currentTarget.querySelector('input').value;
        const allAddressFilled = this.checkAllAddressFieldsFilled();
        const allAssetFilled = this.checkAllAssetFieldsFilled();
        const isFoundAsset = this.selectedAppType === 'FNDAS';
        const isInvalid =
            this.thirdParty &&
            (
                isFoundAsset
                    ? !(allAddressFilled && allAssetFilled)
                    : !allAddressFilled
            );
        if (isInvalid) {
            this.dispatchEvent(
                new CustomEvent('validation', {
                    detail: this.selectedAppType,
                    bubbles: true,
                    composed: true
                })
            );
            return;
        }
        const err = this.template.querySelector('[data-error-for="appointmentType"]');
        if (err) err.hidden = true;

        this.appTileErrorFlag = false; this.appTileErrorMessage = '';
    }

    handleDeCardClick(event) {
        this.selectedDeType =
            event.currentTarget.dataset.value ||
            event.currentTarget.querySelector('input').value;
        const err = this.template.querySelector('[data-error-for="deappointmentType"]');
        if (err) err.hidden = true;

        this.deappTileErrorFlag = false; this.deappTileErrorMessage = '';
        if (value !== 'CA') {
            this.mamId = null;
            const mamErr = this.template.querySelector('[data-error-for="mamId"]');
            if (mamErr) mamErr.hidden = true;
        }

    }

    get showCommonFields() {
        const hasAppointmentSubtype =
            this.selectedMain === 'Appointment' && !!this.selectedAppType;
        const hasDeappointmentSubtype =
            this.selectedMain === 'Deappointment' && !!this.selectedDeType;

        return hasAppointmentSubtype || hasDeappointmentSubtype;
    }

    // Map UI labels to single-letter payload codes
    mapMeterLinkCode(label) {
        switch (label) {
            case 'Free Standing': return 'F';
            case 'Prime': return 'P';
            case 'Sub': return 'S';
            default: return 'F'; // safe default
        }
    }

    // Common field handlers
    handleMeterLinkChange(event) {
        // detail.value is the selected combobox value
        this.meterLinkCode = event.detail.value;
        const err = this.template.querySelector('[data-error-for="meterLinkCode"]');
        if (err) err.hidden = true;    
    }

    handleEffectiveDateChange(event) {
        this.effectiveDate = event.detail.value;  
    }

    // Conditional getters
    get isAppointment() {
        return this.selectedMain === 'Appointment';
    }

    get isDeappointment() {
        return this.selectedMain === 'Deappointment';
    }

    get isFIX() {
        return this.selectedAppType === 'FIX';
    }

    get isFNDAS() {
        return this.selectedAppType === 'FNDAS';
    }

    get isCOSDe() {
        return this.selectedDeType === 'COS';
    }

    async handleSubmitDeappointment(event) {  
        if(this.isFNDAS == true && this.formData == undefined){
            this.locationCodeFlag = true;
            return;
        }
        else{
            this.locationCodeFlag = false;
        }

        if (event && event.preventDefault) event.preventDefault();
        const isValid = this.validateBeforeSubmit();
        if (!isValid) {
            this.isLoading = false;
        return;
        }

        if (this.selectedMain === 'Deappointment') {
            this.supplierContract = '';
        }

        this.isLoading = true;
        const fileIdentifier = 'AP' + Math.floor(100000000000 + Math.random() * 900000000000);     
        const mprnList = this.mprn.split(' - ');   
        const mprnsup = this.mprnsupplier != null && this.mprnsupplier != '' && this.mprnsupplier != undefined ? this.mprnsupplier.split(' - ') : null;        
        if(this.suppliercode == null || this.suppliercode == '' || this.suppliercode == undefined){
            this.suppliercode = mprnList != undefined && mprnList != null && mprnList != '' && mprnList.length > 1 ? mprnList[1] : mprnsup != undefined && mprnsup != null && mprnsup != '' ? mprnsup[1] : '';
        }
        
        if (this.suppliercode != null && this.suppliercode != '' && this.suppliercode != undefined) {   
            const supplierInfo = await getSupplierInfo({ customer: this.suppliercode });   
            if (supplierInfo != null && supplierInfo != '' && supplierInfo != undefined) {
                if (supplierInfo.NGMCP_Rental_Contract__c != null && supplierInfo.NGMCP_Rental_Contract__c != '' && supplierInfo.NGMCP_Rental_Contract__c != undefined) {
                    this.supplierContract = supplierInfo.NGMCP_Rental_Contract__c;
                }
                if (supplierInfo.NGMCP_AMR_Contract__c != null && supplierInfo.NGMCP_AMR_Contract__c != '' && supplierInfo.NGMCP_AMR_Contract__c != undefined) {
                    this.AmrContract = supplierInfo.NGMCP_AMR_Contract__c;
                }
            }
        }
                
        var meterSectorCode = '';

        if((meterSectorCode == null || meterSectorCode == '' || meterSectorCode == undefined) && this.customer != null && this.customer != undefined){
           if(this.customer.MarketselectorCode != null && this.customer.MarketselectorCode != '' && this.customer.MarketselectorCode != undefined){
                meterSectorCode = this.customer.MarketselectorCode;
           } 
        }
        
        if((meterSectorCode == null || meterSectorCode == '' || meterSectorCode == undefined) && this.metadataRecord != null && this.metadataRecord != undefined){
            if(this.metadataRecord.ngme_industry != null && this.metadataRecord.ngme_industry != '' && this.metadataRecord.ngme_industry != undefined){
                meterSectorCode = this.metadataRecord.ngme_industry;
            }
        }
        
        if((meterSectorCode == null || meterSectorCode == '' || meterSectorCode == undefined) && this.wrapperRec != null && this.wrapperRec != undefined){
           if(this.wrapperRec.MarketselectorCode != null && this.wrapperRec.MarketselectorCode != '' && this.wrapperRec.MarketselectorCode != undefined){
                meterSectorCode = this.wrapperRec.MarketselectorCode;
           } 
        }
        
        if((meterSectorCode == null || meterSectorCode == '' || meterSectorCode == undefined) && this.residentialSiteValue != null && this.residentialSiteValue != undefined && this.residentialSiteValue != ''){   
            if(this.residentialSiteValue == 'Yes'){        
                meterSectorCode = 'D';
            }
            else{       
                meterSectorCode = 'I';
            }
        }

        if (this.selectedMain == 'Deappointment' && this.selectedDeType == 'AMR') {
            if (this.amrassetdetails == '' || this.amrassetdetails == null || this.amrassetdetails == undefined) {
                this.successMessage = 'We cannot submit the Deappointment as AMR does not exist on this MPRN.';
                this.serviceTicketid = '';
                this.srNumber = '';
                this.isModal = true;
                this.isLoading = false;
            } else {
                const createPayload = {
                    NGMCP_Building_Name__c: this.buildingName,
                    NGMCP_Market_Sector_Code__c: this.industry,
                    NGMCP_Street__c: this.street,
                    NGMCP_Affected_Person_Title__c: this.state?.title ?? '',
                    NGMCP_Dependent_Locality__c: this.dependentLocality
                }
                
                const payload = {
                    p_ContractRef: this.AmrContract,
                    p_CustomerCode: this.suppliercode,
                    p_TransactionRef: this.getTransactionRef(),
                    p_JobType: 'DEAP',
                    p_MPRN: mprnList != undefined && mprnList != null && mprnList != '' ? mprnList[0] : this.mprn,
                    p_ServiceLevel: this.amrassetdetails.serviceLevelCode == '' || this.amrassetdetails.serviceLevelCode == null || this.amrassetdetails.serviceLevelCode == undefined ? '' : this.amrassetdetails.serviceLevelCode,
                    p_AnnualQuantity: '1',//mandatory in swagger for site visit
                    p_EffectiveDate: new Date().toISOString().split("T")[0],
                    p_CreateReason: "Test Reason",
                    p_SiteContact: '.',
                    p_SiteName: this.buildingName,
                    p_contactNo: '.',
                    p_Comments: '',
                    p_Email: '',
                    p_MAMId:
                        this.amrassetdetails.mam == '' || this.amrassetdetails.mam == null || this.amrassetdetails.mam == undefined ? 'GTM' : this.amrassetdetails.mam,
                    p_Address: this.address,
                    p_Posttown: this.postalTown,
                    p_PostCode: this.postCode,
                    p_CorrectionFactor: 0, //mandatory in mulesoft for install
                    p_MeterManufacturer:
                        this.amrassetdetails.meterManufacturer == '' || this.amrassetdetails.meterManufacturer == null || this.amrassetdetails.meterManufacturer == undefined ? '' : this.amrassetdetails.meterManufacturer,
                    p_MeterModel:
                        this.amrassetdetails.meterModel == '' || this.amrassetdetails.meterModel == null || this.amrassetdetails.meterModel == undefined ? '' : this.amrassetdetails.meterModel,
                    p_MeterYOM:
                        this.amrassetdetails.yearofManufacturer == '' || this.amrassetdetails.yearofManufacturer == null || this.amrassetdetails.yearofManufacturer == undefined ? '' : this.amrassetdetails.yearofManufacturer,
                    p_MeterSerialNumber:
                        this.amrassetdetails.meterSerialNumber == '' || this.amrassetdetails.meterSerialNumber == null || this.amrassetdetails.meterSerialNumber == undefined ? '' : this.amrassetdetails.meterSerialNumber,
                    p_MeterDials:
                        this.amrassetdetails.numberofDials == '' || this.amrassetdetails.numberofDials == null || this.amrassetdetails.numberofDials == undefined ? '' : this.amrassetdetails.numberofDials,
                    p_MeterUnitofMeasure: 'UOM',//mandatory in mulesoft for site visit
                    p_MeterReadingFactor:
                        this.amrassetdetails.readingFactor == '' || this.amrassetdetails.readingFactor == null || this.amrassetdetails.readingFactor == undefined ? '' : this.amrassetdetails.readingFactor,
                    p_ConverterFittedIndicator:
                        this.amrassetdetails.converterFitted == '' || this.amrassetdetails.converterFitted == null || this.amrassetdetails.converterFitted == undefined ? '' : this.amrassetdetails.converterFitted,
                    p_ConverterSerialNumber:
                        this.amrassetdetails.converterSerialNumber == '' || this.amrassetdetails.converterSerialNumber == null || this.amrassetdetails.converterSerialNumber == undefined ? '' : this.amrassetdetails.converterSerialNumber,
                    p_ConverterDials:
                        this.amrassetdetails.converterNumberofDials == '' || this.amrassetdetails.converterNumberofDials == null || this.amrassetdetails.converterNumberofDials == undefined ? 0 : parseInt(this.amrassetdetails.converterNumberofDials),
                    p_ConverterReadingFactor:
                        this.amrassetdetails.converterReadingFactor == '' || this.amrassetdetails.converterReadingFactor == null || this.amrassetdetails.converterReadingFactor == undefined ? 0 : parseInt(this.amrassetdetails.converterReadingFactor),
                    p_SVSTResponseSent: false,
                    p_ReadFrequency: "",
                    p_RequestNGMReference: "",
                    p_AMRSerialNumber:
                        this.amrassetdetails.amrSerialNumber == '' || this.amrassetdetails.amrSerialNumber == null || this.amrassetdetails.amrSerialNumber == undefined ? '' : this.amrassetdetails.amrSerialNumber,
                    p_YearofManufacture:
                        this.amrassetdetails.amrYearofManufacturer == '' || this.amrassetdetails.amrYearofManufacturer == null || this.amrassetdetails.amrYearofManufacturer == undefined ? '' : this.amrassetdetails.amrYearofManufacturer,
                    p_ServiceProvider: ''
                }
                
                try {
                    // Step 1: Create record
                    const requestRecordId = await createAMR({
                        requestBody: JSON.stringify(payload),
                        isPulsing: 'YES',
                        gpsId: '',
                        amrRequest: createPayload
                    });
                    // Step 2: Submit request if record creation succeeded
                    if (requestRecordId) {
                        const response = await submitAMR({
                            requestBody: JSON.stringify(payload),
                            requestId: requestRecordId
                        });  

                        const parsed = typeof response === "string" ? JSON.parse(response) : response;
                        
                        if (parsed?.obj?.p_WorkRequestID) {
                            this.successMessage = 'The AMR request has been created successfully'
                            this.serviceTicketid = 'The reference number is ';
                            //const req = await getRequest({requestid: requestRecordId});
                            this.srNumber = parsed.obj.p_WorkRequestID;
                            this.isModal = true;
                        }
                        else {
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
                    this.successMessage = 'Request could not be submitted. ' + JSON.stringify(error);
                    this.serviceTicketid = '';
                    this.srNumber = '';
                    this.isModal = true;
                } finally {
                    // Stop loading
                    this.isLoading = false;                  
                }
            }
        } else {           
            // 18 march change
            // ===== APPOINTMENT: enforce Supplier ID & real Contract BEFORE payload =====
            if (this.selectedMain === 'Appointment') {
                // 1) Ensure Supplier ID is set (metadata -> fallback to shortCode)
                if (!this.suppliercode) {
                    if (this.metadataRecord?.[0]?.suppliercode) {
                        this.suppliercode = this.metadataRecord[0].suppliercode;
                    } else if (this.metadataRecord?.suppliercode) {
                        this.suppliercode = this.metadataRecord.suppliercode;
                    } else if (this.shortCode) {
                        this.suppliercode = this.shortCode;
                    }
                }
                // 2) If contract empty, fetch it synchronously and set it (DO NOT fallback to "NA")
                if (!this.supplierContract && this.suppliercode) {
                    try {
                        const sc = String(this.suppliercode).trim().toUpperCase();
                        const supplierInfo = await getSupplierInfo({ customer: sc });                     
                        // Business rule: FIX/FNDAS/NEWCN use Rental Contract (adjust if your backend needs different)
                        if (supplierInfo && supplierInfo.NGMCP_Rental_Contract__c) {
                            this.supplierContract = supplierInfo.NGMCP_Rental_Contract__c;
                        }
                        // If your backend requires AMR contract for some appointment subtype, add mapping here:
                        if (!this.supplierContract && supplierInfo && supplierInfo.NGMCP_AMR_Contract__c) {
                            this.supplierContract = supplierInfo.NGMCP_AMR_Contract__c;
                        }
                    } catch (e) {
                        console.warn('getSupplierInfo failed in Appointment ensure:', e);
                    }
                }   
                // 3) FINAL guard: If still no contract, stop and show a clear error (do NOT send "NA")
                if (!this.supplierContract || String(this.supplierContract).trim().toUpperCase() == 'NA') {
                    this.isLoading = false;
                    this.successMessage = `Request could not be submitted as Supplier Contract Reference is missing for Supplier ${this.suppliercode || '(unknown)'}.`;
                    this.serviceTicketid = '';
                    this.srNumber = '';
                    this.isModal = true;
                    return; // hard stop -> prevents "NA" in payload
                }               
            }
            // ===== END ENFORCEMENT BLOCK =====
            // 18 march end
            const payload = {
                ngme_file_type: 'ONAGE',
                ngme_creation_date: this.convertDateFormatNoSpaces(new Date()),
                ngme_originator_id: this.suppliercode,
                ngme_recipient_role: 'MAM',
                ngme_status: 'NEW',
                ngme_transaction_count: 1,
                ngme_integration_type: 'INBOUND',
                ngme_creation_time: this.getCurrentTimeHHMMSS(),
                ngme_reqrecdate: this.formatYYYYMMDD(this.convertDateFormatNoSpaces(new Date())),
                ngme_record_count: 3,
                ngme_record_identifier: 'HEADR',
                ngme_recipient_id: 'GTM',
                ngme_trans: {
                    ngme_reason_code: this.selectedMain == 'Appointment' ? this.selectedAppType : this.selectedDeType,
                    ngme_reference: mprnList[0],
                    ngme_type_code: this.selectedMain == 'Appointment' ? 'APPNT' : 'DEAPP',
                    ngme_sector_code: meterSectorCode, //this.metadataRecord && this.metadataRecord.length > 0 && this.metadataRecord[0].metadatalist && this.metadataRecord[0].metadatalist.length > 0 && this.metadataRecord[0].metadatalist[0].NGMCP_Market_Sector_Code__c ? this.metadataRecord[0].metadatalist[0].NGMCP_Market_Sector_Code__c : this.metadataRecord && this.metadataRecord.metadatalist && this.metadataRecord.metadatalist.length > 0 && this.metadataRecord.metadatalist[0].NGMCP_Market_Sector_Code__c ? this.metadataRecord.metadatalist[0].NGMCP_Market_Sector_Code__c : '',
                    ngme_record_identifier: 'TRANS',
                    ngme_contract_ref: this.supplierContract,
                    ngme_mtpnt: {
                        ngme_record_identifier: 'MTPNT',
                        ngme_mkprt: {
                            ngme_record_identifier: 'MKPRT',
                            ngme_role_code: 'MAM',
                            ngme_abbrv_name: 'GTM'
                        },
                        ngme_link_code: this.mapMeterLinkCode(this.meterLinkCode),  // 9 feb change
                        ngme_referencenum: mprnList[0]
                    },
                },
                ngme_originator_role: 'SUP',
                ngme_file_identifier: fileIdentifier,
                ngme_source_system: 'PORTAL',
                ngme_file_usage_code: 'PRDCT'
            }
            if (this.selectedMain == 'Appointment') {
                payload.ngme_trans.ngme_from_date = this.convertDateFormatNoSpaces(this.effectiveDate);
            }
            else if (this.selectedMain == 'Deappointment') {
                payload.ngme_trans.ngme_to_date = this.convertDateFormatNoSpaces(this.effectiveDate);
                if (this.isCOSDe) {
                    payload.ngme_trans.ngme_mtpnt.ngme_mkprt.ngme_role_code = 'SUP';
                    payload.ngme_trans.ngme_mtpnt.ngme_mkprt.ngme_abbrv_name = this.newSupplierShortCode;
                }
            }
            
            // --- Address: send ONLY for Appointment → (FIX or FNDAS) ---
            // 18 March — Address (Appointment → FIX/FNDAS only)
            if (this.selectedMain === 'Appointment' && (this.isFIX || this.isFNDAS || this.selectedAppType == 'NEWCN' || this.selectedAppType == 'CA')) {  
                // Helper to pick first non-empty string
                const pick = (primary, ...fallbacks) => {
                    for (const v of [primary, ...fallbacks]) {
                        const s = (v ?? '').toString().trim();
                        if (s) return s;
                    }
                    return '';
                };
                const A = this.addressDetails || {};
                const get = (...keys) => {
                    for (const k of keys) {
                        const v = A[k];
                        if (v !== undefined && String(v).trim()) return String(v).trim();
                    }
                    return '';
                };
                // Use let so we can normalize/derive values
                let bn = pick(
                    this.buildingNumber,
                    get('buildingNumber', 'building_no', 'buildingNo', 'NGMCP_Building_Number__c', 'NGMCP_Building_No__c'),
                    this.addressInput?.buildingNumber
                );
                let st = pick(
                    this.street,
                    get('street', 'throughfare', 'through_fare', 'NGMCP_Street__c', 'NGMCP_Throughfare__c'),
                    this.addressInput?.street
                );
                const dl = pick(
                    this.dependentLocality,
                    get('dependentLocality', 'dependent_locality', 'double_locality', 'NGMCP_Dependent_Locality__c', 'NGMCP_Double_Locality__c'),
                    this.addressInput?.dependentLocality
                );
                const pt = pick(
                    this.postalTown,
                    get('postalTown', 'post_town', 'town', 'NGMCP_Postal_Town__c'),
                    this.addressInput?.postalTown
                );
                let pc = pick(
                    this.postCode,
                    get('postCode', 'postalCode', 'post_code', 'postcode', 'NGMCP_Post_Code__c'),
                    this.addressInput?.postalCode
                ); 
                // If building number is missing but street begins with a number (e.g., "37A HIGH STREET"),
                // derive bn from the leading token and clean street accordingly.
                if (!bn && st) {
                    const m = st.match(/^\s*(\d+[A-Z]?)\b\s*(.*)$/i); // captures 37 / 37A etc.
                    if (m) {
                        bn = m[1];
                        st = m[2] || st; // remainder is the street name
                    }
                }
                // Secondary fallback: derive number from buildingName if present
                if (!bn) {
                    const bName = (this.buildingName || A.buildingName || '').toString();
                    const m2 = bName.match(/\b(\d+[A-Z]?)\b/);
                    if (m2) bn = m2[1];
                }
                // Optional: normalize postcode to UK style (adds a space before the last 3 chars)
                if (pc) {
                    const raw = pc.replace(/\s+/g, '').toUpperCase();
                    pc = raw.replace(/(.+)(\w{3})$/, '$1 $2');
                }
                if((bn == null || bn == '' || bn == undefined) && this.addressDetails != null && this.addressDetails != undefined){
                    if(this.addressDetails["Building Number"] != null && this.addressDetails["Building Number"] != '' && this.addressDetails["Building Number"] != undefined){
                        bn = this.addressDetails["Building Number"];
                    }
                    else{
                        bn = '';
                    }    
                }
                if((st == null || st == '' || st == undefined) && this.addressDetails != null && this.addressDetails != undefined){
                    if(this.addressDetails["Street"] != null && this.addressDetails["Street"] != '' && this.addressDetails["Street"] != undefined){
                        st = this.addressDetails["Street"];
                    }
                    else{
                        st = '';
                    }   
                }
                let dl2 = '';
                let pt2 = '';
                let pc2 = '';
                if((dl == null || dl == '' || dl == undefined) && this.addressDetails != null && this.addressDetails != undefined){   
                    if(this.addressDetails["Dependent Locality"] != null && this.addressDetails["Dependent Locality"] != '' && this.addressDetails["Dependent Locality"] != undefined){        
                        const addr = JSON.parse(JSON.stringify(this.addressDetails));
                        dl2 = this.addressDetails["Dependent Locality"];   
                    }   
                }
                if((pt == null || pt == '' || pt == undefined) && this.addressDetails != null && this.addressDetails != undefined){
                    if(this.addressDetails["Postal Town"] != null && this.addressDetails["Postal Town"] != '' && this.addressDetails["Postal Town"] != undefined){
                        pt2 = this.addressDetails["Postal Town"];
                    }  
                }
                if((pc == null || pc == '' || pc == undefined) && this.addressDetails != null && this.addressDetails != undefined){
                    if(this.addressDetails["Post Code"] != null && this.addressDetails["Post Code"] != '' && this.addressDetails["Post Code"] != undefined){
                        pc2 = this.addressDetails["Post Code"];
                    }   
                }
                // Guard: if any essential address piece is missing, stop (prevents server NPE)
                if (!bn || !st || (!pt && !pt2)|| (!pc && !pc2)) {
                    this.isLoading = false;
                    this.successMessage = 'Request could not be submitted as Address details are incomplete (building number, street, town, or postcode missing).';
                    this.serviceTicketid = '';
                    this.srNumber = '';
                    this.isModal = true;
                    return;
                }
                const ngme_addrs = {
                    ngme_type_code: 'MTRPT',
                    ngme_record_identifier: 'ADDRS',
                    ngme_sub_building_no: '',
                    ngme_building_no: bn ,
                    ngme_dependent_through: '',
                    ngme_throughfare: st ,
                    ngme_double_locality: '',
                    ngme_dependent_locality: dl != null && dl != '' && dl != undefined ? dl : dl2 ,
                    ngme_post_town: pt != null && pt != '' && pt != undefined ? pt : pt2,
                    ngme_county: '',
                    ngme_post_code: pc != null && pc != '' && pc != undefined ? pc : pc2,
                };
                // Attach to payload
                payload.ngme_trans.ngme_mtpnt.ngme_addrs = ngme_addrs;
                // Debug proof for manager   
            }
            // 18 march end
            // --- FNDAS: build ngme_asset safely (Appointment → FNDAS only) ---
            // --- FNDAS: build ngme_asset safely with fallback from assetDetails (Appointment → FNDAS only) ---
            if (this.isFNDAS) {
                // primary source
                let td = this.thirdPartyAssetDetails;
                // ====== FALLBACK: derive from assetDetails array when thirdPartyAssetDetails is missing ======
                if (!td && Array.isArray(this.assetDetails) && this.assetDetails.length > 0) {
                    // Normalize label/value array to a lookup by lowercased label
                    const toMap = (arr) => {
                        const m = {};
                        arr.forEach(({ label, value }) => {
                            if (!label) return;
                            m[label.toString().trim().toLowerCase()] = (value ?? '').toString().trim();
                        });
                        return m;
                    };
                    const m = toMap(this.assetDetails);
                    // Helper to pick first non-empty from candidate label keys
                    const pickByLabel = (...labels) => {
                        for (const key of labels) {
                            const v = m[key.toLowerCase()];
                            if (v !== undefined && v !== '') return v;
                        }
                        return '';
                    };
                    // Build td-equivalent from labels seen in your org
                    // (based on the example array in your file: Manufacturer, Model, Manufacturer Serial no., Meter Type, No. of Dials, Payment Mechanism, Year of Manufacture, Measuring Capacity)  [1](https://wipro365-my.sharepoint.com/personal/mo20632198_wipro_com/Documents/Microsoft%20Copilot%20Chat%20Files/appoint%20js%203%20march.txt)
                    td = {
                        paymentmechanism: pickByLabel('Payment Mechanism', 'paymentmechanism', 'Pay Method', 'Meter Mechanism'),
                        metertype: pickByLabel('Meter Type', 'metertype', 'Type'),
                        capacity: pickByLabel('Measuring Capacity', 'capacity', 'Measure Capacity'),
                        serialNumber: pickByLabel('Manufacturer Serial no.', 'Serial Number', 'Meter Serial Number', 'serialnumber', 'serialNumber'),
                        factor: pickByLabel('Factor', 'Multiplication Factor') || 1,
                        yearofmanufaturer: pickByLabel('Year of Manufacture', 'YOM', 'Year') || pickByLabel('Year of manufacturer', 'yearofmanufacturer'),
                        // dials can be provided as a number or in a nested object later
                        dials: pickByLabel('No. of Dials', 'Dials', 'Digits'),
                        meterModel: pickByLabel('meterModel'),
                    };   
                }
                // ====== END FALLBACK ======
                // Hard guard – require at least basic asset info
                if (!td || typeof td !== 'object') {
                    this.isLoading = false;
                    this.successMessage = 'Request could not be submitted as Found Meter (FNDAS) asset details are missing.';
                    this.serviceTicketid = '';
                    this.srNumber = '';
                    this.isModal = true;
                    return;
                }
                // Helpers + mappings
                const normalizeLower = (s) => (s ?? '').toString().trim().toLowerCase();
                const typeMap = {
                    'diaphragm': 'D',
                    'rotary displacement': 'R',
                    'diaphragm - synthetic': 'S',
                    'turbine': 'T',
                    'ultrasonic': 'U',
                    'other': 'Z'
                };
                // Read values safely with fallbacks
                const payCode = normalizeLower(td.paymentmechanism) === 'credit' ? 'CR' : 'PP';
                const meterTypeCode = typeMap[normalizeLower(td.metertype)] || '';
                // Dials may be a number or an object; both are handled
                const digits = (td.dials && typeof td.dials === 'object' && (td.dials.no_of_digit || td.dials.digits))
                    ? (td.dials.no_of_digit || td.dials.digits)
                    : (Number.isInteger(td.dials) || /^\d+$/.test(td.dials) ? parseInt(td.dials, 10) : '');
                // Unit may be nested or a flat label; fallback to empty if unknown
                const unit = (td.dials && typeof td.dials === 'object' && td.dials.metric_Imperial)
                    ? td.dials.metric_Imperial
                    : (td.unit || td.measure_unit || '');
                const factor = (td.factor ?? 1);
                const capacity = (td.capacity ?? '');
                const serial = (td.serialNumber ?? '');
                const yom = (td.yearofmanufaturer ?? td.yearofmanufacturer ?? '');
                const model = (td.meterModel ?? '');
                const manufacturerCode = (td.manufacturerCode ?? '');
                // Minimal validation for essential fields (avoid server-side NPEs)
                if (!serial || !meterTypeCode) {
                    this.isLoading = false;
                    this.successMessage = 'Request could not be submitted as FNDAS meter details are incomplete (serial/type missing).';
                    this.serviceTicketid = '';
                    this.srNumber = '';
                    this.isModal = true;
                    return;
                }
                // Build ngme_asset (constants left as-is per your current implementation)
                const ngme_asset = {
                    ngme_record_identifier: 'ASSET',
                    ngme_pay_method_code: payCode,
                    ngme_trans_type_code: 'APPNT',
                    ngme_class_code: 'METER',
                    ngme_model_code: model,
                    ngme_manufacture_code: this.thirdPartyAssetDetails && this.thirdPartyAssetDetails.manufacturer_code ? this.thirdPartyAssetDetails.manufacturer_code : '',
                    ngme_manufacture_year: yom,
                    ngme_serial_no: serial,
                    ngme_location_code: this.formData.locationCode,
                    ngme_location_notes: '',
                    ngme_status_code: 'LI',
                    ngme_meter: {
                        ngme_record_identifier: 'METER',
                        ngme_type_code: meterTypeCode,
                        ngme_mechanism_code: payCode,
                        ngme_measure_capacity: capacity,
                        ngme_status_code: ''
                    },
                    ngme_regst: {
                        ngme_record_identifier: 'REGST',
                        ngme_type_code: 'METER',
                        ngme_no_of_digit: digits,
                        ngme_measure_unit: this.thirdPartyAssetDetails && this.thirdPartyAssetDetails.metric_Imperial ? this.thirdPartyAssetDetails.metric_Imperial : '',
                        ngme_multiplication_factor: factor
                    }
                };
                // Attach to payload
                payload.ngme_trans.ngme_mtpnt.ngme_asset = ngme_asset;
                // Debug (to prove we’re sending what backend expects)
            }
            
            try {
                // Step 1: Create record
                const requestRecordId = await createAppntDeappntRecord({
                    requestBody: JSON.stringify(payload)
                });
                // Step 2: Submit request if record creation succeeded
                if (requestRecordId) {
                    const response = await submitAppntDeappnt({
                        requestBody: JSON.stringify(payload),
                        requestId: requestRecordId
                    });   
                    const parsed = typeof response === "string" ? JSON.parse(response) : response;
                    if (parsed) {
                        this.successMessage = this.selectedMain == 'Appointment' ? 'The appointment request has been created successfully' : 'The deappointment request has been created successfully'
                        this.serviceTicketid = 'The reference number is ';
                        const req = await getRequest({ requestid: requestRecordId });
                        this.srNumber = req.Name;
                        this.isModal = true;
                    }
                    // TODO: Show success toast or navigate
                } else {
                    console.warn(' No request record ID returned.');
                }
            } catch (error) { 
                const str = error.body.message;
                const matches = [...str.matchAll(/%(.*?)%/g)].map(m => m[1]); 
                if (matches) {
                    this.successMessage = 'Request could not be submitted as ' + matches;
                }
                else {
                    this.successMessage = 'Request could not be submitted as ' + JSON.stringify(error);
                }   
                this.serviceTicketid = '';
                this.srNumber = '';
                this.isModal = true;
            } finally {
                this.isLoading = false;   
            }
        }
    }

    getTransactionRef() {
        const number = Math.floor(100000 + Math.random() * 900000);
        // Generate 3 random uppercase alphabets
        const letters = Array.from({ length: 3 }, () =>
            String.fromCharCode(65 + Math.floor(Math.random() * 26))
        ).join('');
        return `${number}${letters}`;
    }
    convertDateFormatNoSpaces(dateInput) {
        // If it's already a Date, use it. If it's a string, convert it.
        const date = (dateInput instanceof Date) ? dateInput : new Date(dateInput);
        if (isNaN(date.getTime())) {
            return null;
        }
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');

        return `${year}${month}${day}`;
    }

    connectedCallback() {
        const mprnOnly = (this.mprn || '').toString().split(' - ')[0]?.trim();
        if (mprnOnly) {
            getAMRAssetDetails({ Mprn: mprnOnly })
                .then((raw) => {
                    const body = typeof raw === 'string' ? JSON.parse(raw) : raw;
                    const rec = body?.obj?.[0];
                    this.amrassetdetails = rec;   
                    // Normalize MAM Id to a single key: "mam"
                    const normalizeMam = (o) => {
                        if (!o || typeof o !== 'object') return '';
                        // direct key variants first
                        const direct = [
                            o.mam, o.MAM, o.MAMId, o.mamId, o.MAM_ID, o.mam_id, o.MAMID,
                            o.MAMCode, o.mamCode, o.MAMShortCode, o.mamShortCode, o['MAM Short Code']
                        ].map(v => (v ?? '').toString().trim()).find(Boolean);
                        if (direct) return direct;
                        // deep scan for a string under keys containing "mam" + ("id"|"code")
                        const stack = [o]; const seen = new Set();
                        while (stack.length) {
                            const cur = stack.pop();
                            if (!cur || typeof cur !== 'object' || seen.has(cur)) continue;
                            seen.add(cur);
                            for (const [k, v] of Object.entries(cur)) {
                                if (typeof v === 'string') {
                                    const s = v.trim();
                                    if (s && /mam/i.test(k) && /(id|code)/i.test(k)) return s;
                                } else if (v && typeof v === 'object') {
                                    stack.push(v);
                                }
                            }
                        }
                        return '';
                    };
                    const mam = normalizeMam(rec);
                    //this.amrassetdetails = { ...rec, mam };   // <-- always adds ".mam"    
                })
                .catch(err => {
                    this.amrassetdetails = null;
                });
        } else {
            console.warn('[AMR] Skipping getAMRAssetDetails: no MPRN available in connectedCallback');
        }
        if (Array.isArray(this.addressDetails) && this.addressDetails.length > 0) {
            const addressObj =
                this.addressDetails.reduce((acc, { label, value }) => {
                    acc[label] = value;
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
        const buildingNum = this.buildingNumber ? this.buildingNumber + ' , ' : '';
        const buildingName = this.buildingName ? this.buildingName + ' , ' : '';
        const street = this.street ? this.street + ' , ' : '';
        const dependentLocality = this.dependentLocality ? this.dependentLocality + ' , ' : '';
        const postalTown = this.postalTown ? this.postalTown + ' , ' : '';
        this.address = buildingNum + buildingName + street + dependentLocality + postalTown + this.postCode;    
        if (this.metadataRecord && this.metadataRecord.length > 0 && this.metadataRecord[0].suppliercode) {
            this.suppliercode = this.metadataRecord[0].suppliercode;
        } else if (this.metadataRecord && this.metadataRecord.suppliercode) {
            this.suppliercode = this.metadataRecord.suppliercode;
        }   
        if (this.suppliercode == null || this.suppliercode == '' || this.suppliercode == undefined) {
            this.suppliercode = this.shortCode;
        }
        if((this.suppliercode == null || this.suppliercode == '' || this.suppliercode == undefined) && this.mprn != null && this.mprn != '' && this.mprn != undefined && this.mprn.includes('-')){
            const mprnList = this.mprn.split(' - ');
            this.suppliercode = mprnList[1];
        }
        const today = new Date();
        const y = today.getFullYear();
        const m = String(today.getMonth() + 1).padStart(2, '0');
        const d = String(today.getDate()).padStart(2, '0');
        this.minDate = `${y}-${m}-${d}`;         // block past dates (optional)
        // --- Default Meter Link Code to "Free Standing" ---
        this.meterLinkCode = 'Free Standing';  // 9 feb change
    }

    handleDateSelected(event) {
        // Expect the child to send { detail: { value: 'YYYY-MM-DD' } }
        const iso = event?.detail?.date;
        if (!iso) return;
        this.effectiveDate = iso //?? event.target?.value;
        const err = this.template.querySelector('[data-error-for="effectiveDate"]');
        if (err) err.hidden = true;
    }

    // If you want to keep backward compatibility with your old <lightning-input>:
    handleEffectiveDateChange(event) {
        this.effectiveDate = event.detail?.value ?? event.target?.value;
        // 4 feb change for mandatory
        const err = this.template.querySelector('[data-error-for="effectiveDate"]');
        if (err) err.hidden = true;
        // 4 feb change end here for mandatory
    }

    fetchSupplierContract(supplier) {
        getSupplierInfo({ customer: supplier })
            .then(result => {            
                if (result == null || result == '' || result == undefined) {
                    return '';
                }
                else {
                    if (result.NGMCP_Rental_Contract__c != null && result.NGMCP_Rental_Contract__c != '' && result.NGMCP_Rental_Contract__c != undefined) {
                        return result.NGMCP_Rental_Contract__c;
                    }
                    else {
                        return '';
                    }
                }
            })
            .catch(error => {    
                return '';
            });
    }
    formatYYYYMMDD(dateStr) {
        return (
            dateStr.substring(0, 4) + '-' +
            dateStr.substring(4, 6) + '-' +
            dateStr.substring(6, 8)
        );
    }

    getCurrentTimeHHMMSS() {
        const now = new Date();
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        const seconds = String(now.getSeconds()).padStart(2, '0');
        return `${hours}${minutes}${seconds}`;
    }

    handleCancelClick() {
        this.dispatchEvent(new CustomEvent("cancelcreatejob"));
    }

    handleInputChange(event) {
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

    handleAddressChange(event) {
        this.addressInput = { ...this.addressInput, [event.target.name]: event.target.value };
        const key = event.target.dataset.field || event.target.name;
        const err = this.template.querySelector(`[data-error-for="${CSS.escape(key)}"]`);
        if (err) err.hidden = !!(event.target.value ?? '').toString().trim();
        event.target.classList.remove('invalid');
    }

    // --- VALIDATION START (add below handleAddressChange and above autoSelectMainOption) ---
    validateBeforeSubmit() {
        let ok = true;
        let firstEl = null;
        // 0) Utility to show/hide one inline error
        const toggleErr = (key, show) => {
            const err = this.template.querySelector(`[data-error-for="${CSS.escape(key)}"]`);
            if (err) err.hidden = !show;
        };
        // 1) Required plain inputs/selects/combos that you flagged in HTML:
        //    .text-input + data-required="true"
        const inputs = this.template.querySelectorAll('.text-input');
        inputs.forEach(inp => {   
            if (inp.offsetParent === null) return; // skip hidden
            const required = inp.dataset.required === 'true';
            if (!required) return;
            const key = inp.dataset.field || inp.name;
            //const val = (inp.value ?? '').toString().trim();
            const val = (
                (inp.value !== undefined ? inp.value : '') ||
                (this.formData && this.formData[key]) ||
                ''
            ).toString().trim();
            const empty = !val;
            if (empty) {
                ok = false;
                firstEl = firstEl || inp;
                inp.classList.add('invalid');
                toggleErr(key, true);
            } else {
                inp.classList.remove('invalid');
                toggleErr(key, false);
            }
        });
        // 2) Radio/tile groups (require EXACT names in HTML)
        //    - jobType          (Appointment vs Deappointment)
        //    - appointmentType  (COS/FIX/NEWCN/FNDAS)
        //    - deappointmentType(CA/DE/DEMO/COS/...)
        const checkGroup = (name) => {
            const radios = this.template.querySelectorAll(`input[type="radio"][name="${CSS.escape(name)}"]`);
            if (!radios.length) return;
            // Only validate visible groups
            const visible = Array.from(radios).some(r => r.offsetParent !== null);
            if (!visible) return;
            const anyChecked = Array.from(radios).some(r => r.checked);
            if (!anyChecked) {
                ok = false;
                firstEl = firstEl || radios[0];
                toggleErr(name, true);
            } else {
                toggleErr(name, false);
            }
        };

        checkGroup('jobType');
        if (this.selectedMain === 'Appointment') checkGroup('appointmentType');
        if (this.selectedMain === 'Deappointment') checkGroup('deappointmentType');

        // 3) Common “Effective Date” & “Meter Link Code”
        //    These two are common fields shown when any subtype is selected.
        //    - effectiveDate comes from custom picker/ <lightning-input>
        //    - meterLinkCode comes from combobox handler
        const commonVisible = this.showCommonFields; // use your getter
        if (commonVisible) {
            // Effective Date: allow either ISO date in this.effectiveDate or filled input proxy
            const effEmpty = !this.effectiveDate || !String(this.effectiveDate).trim();
            // 1 june change
            //  Deappointment specific Effective Date mandatory (for all types)
        if (this.selectedMain === 'Deappointment') {
    const effEmpty = !this.effectiveDate || !String(this.effectiveDate).trim();
    if (effEmpty) {
        ok = false;
        toggleErr('effectiveDate', true);
        const dp =
            this.template.querySelector('c-ngmcp-date-picker-with-holidays') ||
            this.template.querySelector('[data-field="effectiveDate"]');
        firstEl = firstEl || dp;
    } else {
        toggleErr('effectiveDate', false);
    }
}
        // 1 june change end
            if (effEmpty) {
                ok = false;
                toggleErr('effectiveDate', true);
                // Try focusing the date picker if present:
                const dp = this.template.querySelector('c-ngmcp-date-picker-with-holidays') ||
                    this.template.querySelector('input[data-field="effectiveDate"]');
                firstEl = firstEl || dp;
            } else {
                toggleErr('effectiveDate', false);
            }
            // Meter Link Code: value is in this.meterLinkCode (set by handleMeterLinkChange)
            const mlcEmpty = !this.meterLinkCode || !String(this.meterLinkCode).trim();
            if (mlcEmpty) {
                ok = false;
                toggleErr('meterLinkCode', true);
                const mlc = this.template.querySelector('[data-field="meterLinkCode"].text-input');
                firstEl = firstEl || mlc;
            } else {
                toggleErr('meterLinkCode', false);
            }
        }
        // Deappointment → COS → New Supplier Short Code required
       // 1 june change for COS
if (this.selectedMain === 'Deappointment' && this.isCOSDe) {
    // 🔹 New Supplier Short Code validation
    const supplierEmpty = !this.newSupplierShortCode || !String(this.newSupplierShortCode).trim();
    if (supplierEmpty) {
        ok = false;
        toggleErr('newSupplierShortCode', true);
        const el =
            this.template.querySelector('[data-field="newSupplierShortCode"].text-input') ||
            this.template.querySelector('lightning-combobox[data-field="newSupplierShortCode"]');
        firstEl = firstEl || el;
    } else {
        toggleErr('newSupplierShortCode', false);
    }
    // 🔹 Effective Date validation (FOR COS also)
    const effEmpty = !this.effectiveDate || !String(this.effectiveDate).trim();
    if (effEmpty) {
        ok = false;
        toggleErr('effectiveDate', true);
        const dp =
            this.template.querySelector('c-ngmcp-date-picker-with-holidays') ||
            this.template.querySelector('[data-field="effectiveDate"]');
        firstEl = firstEl || dp;
    } else {
        toggleErr('effectiveDate', false);
    }
}
        // Deappointment -> Change Of Agent (CA) -> MAM Id required
        if (this.selectedMain === 'Deappointment' && this.selectedDeType === 'CA') {
    const mamEmpty = !this.mamId || !String(this.mamId).trim();
    if (mamEmpty) {
        ok = false;
        toggleErr('mamId', true);
        const el = this.template.querySelector('[data-field="mamId"].text-input') ||
            this.template.querySelector('lightning-combobox[data-field="mamId"]');
        firstEl = firstEl || el;
    } else {
        toggleErr('mamId', false);
    }
}
        // --- Tile banner message logic (scoped to each grid) ---
        this.mainTileErrorFlag = false; this.mainTileErrorMessage = '';
        this.appTileErrorFlag = false; this.appTileErrorMessage = '';
        this.deappTileErrorFlag = false; this.deappTileErrorMessage = '';
        if (!this.selectedMain) {
            // Show under "Select Job Type"
            this.mainTileErrorMessage = 'Please select Appointment or Deappointment.';
            this.mainTileErrorFlag = true;
        } else if (this.selectedMain === 'Appointment' && !this.selectedAppType) {
            // Show under "Select Appointment Type"
            this.appTileErrorMessage = 'Please select an Appointment Type.';
            this.appTileErrorFlag = true;
        } else if (this.selectedMain === 'Deappointment' && !this.selectedDeType) {
            // Show under "Select Deappointment Type"
            this.deappTileErrorMessage = '.';
            this.deappTileErrorFlag = true;
        }
        // 6) Scroll to first error
        if (!ok && firstEl) {
            try { firstEl.scrollIntoView({ behavior: 'smooth', block: 'center' }); firstEl.focus && firstEl.focus(); } catch (e) { }
        }
        return ok;
    }
    // --- VALIDATION END ---
    handlePlainTyping(event) {
    // Clears the inline error as soon as a user types/selects    
        const field = event.target.dataset.field || event.target.name;
        if(field == 'locationCode'){        
            if(event.target.value == '' || event.detail.value == '' || event.target.value == undefined || event.detail.value == undefined || event.target.value == null || event.detail.value == null){
                this.locationCodeFlag = true;
            }
            else{
                this.locationCodeFlag = false;
            }
        }
        if (!field) return;
        // Read value from input/combobox/textarea/radio-group
        const value =
            (event.detail && event.detail.value !== undefined)
                ? event.detail.value
                : (event.target.value ?? '');
        // Persist if you want these in formData (safe; does not change payload)
        this.formData = { ...(this.formData || {}), [field]: value }; 
        // Hide this field’s inline error (nearest container first)
        const group =
            event.target.closest('.field, .form-group, .custom-contact-field-section') || this.template;
        const err = group.querySelector(`[data-error-for="${CSS.escape(field)}"]`)
            || this.template.querySelector(`[data-error-for="${CSS.escape(field)}"]`);
        if (err) err.hidden = !!String(value).trim();
        // Remove red outline if validator added it
        event.target.classList && event.target.classList.remove('invalid');
    }
    // 4 feb change end here for mandatory

    autoSelectMainOption(mode) {  
        if (this.requestSource && !this.hasAutoSelected) {
            const mapped = this.mapRequestSource(this.requestSource);
            if (mapped) {
                this.selectedMain = mapped;
                this.hasAutoSelected = true;
            }
        }
    }

    mapRequestSource(source) {
        switch (source) {
            case 'APPOINT':
                return 'Appointment';
            case 'DEAPPOINT':
                return 'Deappointment';
            default:
                return null;
        }
    }
    checkAllAssetFieldsFilled() {
        if (!this.assetDetails || this.assetDetails.length === 0) {
            return true;
        }
        return this.assetDetails.every(
            field => field.value
        );
    }
    checkAllAddressFieldsFilled() {
        const address = this.addressDetails;
        if (!address) return false;
        const normalize = (v) =>
            (v == null ? '' : String(v))
                .replace(/\u200B/g, '')
                .trim();
        const street = normalize(address.street);
        const postalTown = normalize(address.postalTown);
        const postCode = normalize(address.postCode);
        const buildingName = normalize(address.buildingName);
        const buildingNumber = normalize(address.buildingNumber);
        const hasAllRequired =
            street !== '' &&
            postalTown !== '' &&
            postCode !== '';
        const hasOneBuilding =
            buildingName !== '' ||
            buildingNumber !== '';
        const isPostCodeValid =
            postCode !== '' && this.isValidUKPostcode(postCode);
        const isValid = hasAllRequired && hasOneBuilding && isPostCodeValid;
        return isValid;
    }
    isValidUKPostcode(postcode) {
    if (!postcode) return false;
    const regex =
      /^(?:[A-Z]{1,2}[0-9][0-9A-Z]?|[A-Z][0-9][A-Z]) [0-9][A-Z]{2}$/;
    return regex.test(postcode.trim());
  }
}