import { LightningElement, track, api } from 'lwc';
import submitAppntDeappnt from "@salesforce/apex/NGMCP_AppointmentDeappointmentHandler.submitAppntDeappnt";
import createAppntDeappntRecord from "@salesforce/apex/NGMCP_AppointmentDeappointmentHandler.createAppntDeappntRecord";
import getSupplierInfo from "@salesforce/apex/NGMCP_AppointmentDeappointmentHandler.getSupplierInfo";
import getRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.getRequest";
//import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
//const FIELDS = ['User.Email'];
export default class NGMCP_AppointDeappoint extends LightningElement {
    @track selectedMain;
    @track selectedAppType;
    @track selectedDeType;
    @api jobMode;
    hasAutoSelected = false;

    meterLinkCode

    // 21 jan change
    // state you likely already have:
    @track effectiveDate; // 'YYYY-MM-DD'
    minDate;       // optional
    maxDate;       // optional
    holidays = []; // optional: ['2026-01-26','2026-03-08', ...]

    // 21 jan change end here

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
    @track isLoading = false;
    @track isModal = false;
    @track successMessage //= SUCCESS_MESSAGE;
    @track serviceTicketid //= SERVICETICKET_ID;
    @track srNumber;
    @track consent = false;
    @track consentMessage = '';

    @track tileErrorFlag = false;       // controls the banner visibility
    @track tileErrorMessage = '';       // text of the banner

    @track mainTileErrorFlag = false;
    @track mainTileErrorMessage = '';

    @track appTileErrorFlag = false;
    @track appTileErrorMessage = '';

    @track deappTileErrorFlag = false;
    @track deappTileErrorMessage = '';
    @track consentMessageFlag = false;
    userId = USER_ID;
    @api shortCode;
    @api residentialSiteValue;
    @track addressInput = {
        buildingNumber: '', buildingName: '', dependentLocality: '',
        street: '', postalTown: '', postalCode: ''
    };

    //  @api requestSource;   // 'APPOINT' | 'DEAPPOINT'
    _requestSource;
    selectedMain;
    hasAutoSelectedMainOption = false;

    // 27 jan change

    // --- New Supplier Short Code (for Deappointment -> COS) ---
    @track newSupplierShortCode; // will hold the 3-char code (e.g., 'EUK')

    @api
    set requestSource(value) {
        console.log('[GRANDCHILD] requestSource setter fired:', value);

        this._requestSource = value;

        if (!value || this.hasAutoSelectedMainOption) {
            return;
        }

        const mapped = this.mapRequestSource(value);
        console.log('[GRANDCHILD] mapped value =', mapped);

        if (mapped) {
            this.selectedMain = mapped;
            this.hasAutoSelectedMainOption = true;
        }
    }

    get requestSource() {
        return this._requestSource;
    }



    // Dropdown options to show "CODE␠␠Name"
    newSupplierShortCodeOptions = [
        { value: 'EUK', label: 'EUK  Axpo UK Ltd' },
        { value: 'BSH', label: 'BSH  Barrow Shipping Ltd' },
        { value: 'BPG', label: 'BPG  BP Gas Marketing Ltd' },
        { value: 'BGT', label: 'BGT  British Gas' },
        { value: 'BSA', label: 'BSA  British Gas Business Ltd' },
        { value: 'BGB', label: 'BGB  British Gas Business Ltd' },
        { value: 'TIL', label: 'TIL  British Gas' },
        { value: 'BGF', label: 'BGF  British Gas Trading Ltd' },
        { value: 'BTA', label: 'BTA  British Gas' },
        { value: 'BRO', label: 'BRO  Brook Green Trading Ltd' },
        { value: 'CIL', label: 'CIL  Cellini Energy Supplier Ltd - T/A Rebel Energy Ltd' },
        { value: 'TEN', label: 'TEN  Ceres Energy Limited' },
        { value: 'QNT', label: 'QNT  Corona Energy Retail' },
        { value: 'VCT', label: 'VCT  Corona Energy Retail' },
        { value: 'SLG', label: 'SLG  Corona Energy Retail' },
        { value: 'GLZ', label: 'GLZ  Corona Energy Retail' },
        { value: 'COU', label: 'COU  Coulomb Energy Supply' },
        { value: 'CGP', label: 'CGP  Crown Gas and Power Ltd' },
        { value: 'CRW', label: 'CRW  Crown Oil Ltd' },
        { value: 'DGP', label: 'DGP  DGP Energy Ltd' },
        { value: 'EGD', label: 'EGD  E (Gas and Electricity) Ltd' },
        { value: 'KIN', label: 'KIN  E.ON UK PLC' },
        { value: 'EAS', label: 'EAS  E.ON UK PLC' },
        { value: 'UNI', label: 'UNI  E.ON UK PLC' },
        { value: 'SGL', label: 'SGL  E.ON UK PLC' },
        { value: 'EMI', label: 'EMI  E.ON UK PLC' },
        { value: 'EOD', label: 'EOD  E.ON NEXT' },
        { value: 'ECO', label: 'ECO  Economy Gas Ltd' },
        { value: 'REC', label: 'REC  Ecotricity Limited (The Renewable Energy Company)' },
        { value: 'SOG', label: 'SOG  EDF Energy Customers Ltd' },
        { value: 'LEP', label: 'LEP  EDF Energy Customers Ltd' },
        { value: 'LEI', label: 'LEI  EDF Energy Customers Ltd' },
        { value: 'LED', label: 'LED  EDF Energy Customers Ltd' },
        { value: 'SBR', label: 'SBR  EDF Energy Customers Ltd' },
        { value: 'EDS', label: 'EDS  EDF Energy Customers Ltd' },
        { value: 'EDN', label: 'EDN  EDF Energy Customers Ltd' },
        { value: 'EDB', label: 'EDB  EDF Energy Business Energy Ltd' },
        { value: 'EGM', label: 'EGM  EE Solutions Ltd' },
        { value: 'VES', label: 'VES  Engie Gas Shipper Ltd' },
        { value: 'VLN', label: 'VLN  Engie Gas Shipper Ltd' },
        { value: 'ESA', label: 'ESA  ENI' },
        { value: 'STA', label: 'STA  EQUINOR UK LIMITED' },
        { value: 'BPO', label: 'BPO  Evolve Energy' },
        { value: 'FLE', label: 'FLE  Flexitricity Limited' },
        { value: 'FGB', label: 'FGB  Flogas Britain Ltd' },
        { value: 'VYU', label: 'VYU  Flogas Enterprise Solutions Ltd' },
        { value: 'FOX', label: 'FOX  Foxglove Energy Supply Ltd' },
        { value: 'OTM', label: 'OTM  Foxglove Energy Supply Ltd' },
        { value: 'AEL', label: 'AEL  Gas Plus Supply Limited' },
        { value: 'GEG', label: 'GEG  Good Energy Gas Ltd' },
        { value: 'GGL', label: 'GGL  Good Energy Gas Ltd' },
        { value: 'GNL', label: 'GNL  Green Energy Ltd' },
        { value: 'HEP', label: 'HEP  Hartree Partners Power & Gas Company Limited' },
        { value: 'HET', label: 'HET  Home Energy Trading Ltd' },
        { value: 'IEO', label: 'IEO  Ineos Energy Trading Limited' },
        { value: 'TRM', label: 'TRM  Jellyfish Energy Limited' },
        { value: 'MRB', label: 'MRB  Marble Power Ltd' },
        { value: 'MAX', label: 'MAX  Maxen Power' },
        { value: 'BNG', label: 'BNG  National Gas (formerly UK National Gas Ltd)' },
        { value: 'NGD', label: 'NGD  Npower Gas Ltd' },
        { value: 'PSS', label: 'PSS  Npower Gas Ltd' },
        { value: 'HBL', label: 'HBL  Octopus Energy Ltd' },
        { value: 'OCT', label: 'OCT  Octopus Energy Ltd' },
        { value: 'OPA', label: 'OPA  Opal Gas Limited' },
        { value: 'OGS', label: 'OGS  Opus Gas Supply Ltd' },
        { value: 'OSO', label: 'OSO  OSSO Gas Limited' },
        { value: 'OVO', label: 'OVO  Ovo Gas Ltd' },
        { value: 'LUM', label: 'LUM  Ovo Gas Ltd' },
        { value: 'SPQ', label: 'SPQ  OVO Gas Ltd' },
        { value: 'PSL', label: 'PSL  P3P Energy Supply Limited' },
        { value: 'PZT', label: 'PZT  Pozitive Energy Ltd' },
        { value: 'RGG', label: 'RGG  Regent Gas Ltd' },
        { value: 'RGN', label: 'RGN  Regent Gas Ltd' },
        { value: 'BEN', label: 'BEN  Ruby Gas Limited' },
        { value: 'NPW', label: 'NPW  Npower Gas Ltd' },
        { value: 'RST', label: 'RST  RWE Supply & Trading GMBH' },
        { value: 'SCP', label: 'SCP  Scottish Power' },
        { value: 'SCT', label: 'SCT  Scottish Power' },
        { value: 'GMT', label: 'GMT  SEFE Energy Ltd' },
        { value: 'SBP', label: 'SBP  Sembcorp Utilities (UK) Ltd' },
        { value: 'HUD', label: 'HUD  Shell Energy UK Limited' },
        { value: 'DLE', label: 'DLE  Smartest Energy Business Ltd' },
        { value: 'DUE', label: 'DUE  Smartest Energy Business Ltd' },
        { value: 'STL', label: 'STL  So Energy Trading Ltd' },
        { value: 'ALA', label: 'ALA  Square1 Energy Limited' },
        { value: 'SOP', label: 'SOP  OVO Gas Ltd' },
        { value: 'SHH', label: 'SHH  OVO Gas Ltd' },
        { value: 'ATL', label: 'ATL  SSE Energy Solutions' },
        { value: 'STH', label: 'STH  OVO Gas Ltd' },
        { value: 'SHE', label: 'SHE  OVO Gas Ltd' },
        { value: 'EFG', label: 'EFG  TotalEnergies Gas & Power Limited' },
        { value: 'AAS', label: 'AAS  TotalEnergies Gas & Power Limited' },
        { value: 'HDL', label: 'HDL  Tru Energy' },
        { value: 'UKG', label: 'UKG  UK Gas Supply' },
        { value: 'UHC', label: 'UHC  UK Healthcare Corporation Ltd' },
        { value: 'DGT', label: 'DGT  UK Healthcare Corporation Ltd' },
        { value: 'BUN', label: 'BUN  Unify Energy Limited' },
        { value: 'UGP', label: 'UGP  United Gas & Power Ltd' },
        { value: 'UGA', label: 'UGA  United Gas & Power Ltd' },
        { value: 'UEL', label: 'UEL  Utilita Energy Ltd' },
        { value: 'SLD', label: 'SLD  Valda Energy Limited' },
        { value: 'KEL', label: 'KEL  Kensington Power Limited (Yu)' },
        { value: 'KNP', label: 'KNP  Kensington Power Limited (Yu)' }
    ];

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

    // 4 feb change end here for mandatory error gone

    // 27 jan change end here

    // Main options
    mainOptions = [
        { label: 'Appointment', value: 'Appointment', helpText: 'Book a new appointment' },
        { label: 'Deappointment', value: 'Deappointment', helpText: 'Cancel an existing appointment' }
    ];

    // Appointment types
    appointmentOptions = [
        { label: 'Change of Supplier', value: 'COS', helpText: 'Change of Supplier' },
        { label: 'New Meter Fitted', value: 'FIX', helpText: 'New Meter Fitted' },
        { label: 'New Connection', value: 'NEWCN', helpText: 'New Connection' },
        { label: 'Found Meter', value: 'FNDAS', helpText: 'Found Meter' }
    ];

    // Deappointment types
    deappointmentOptions = [
        { label: 'Change Of Agent', value: 'CA', helpText: 'Change Of Agent' },
        { label: 'Disconnection', value: 'DE', helpText: 'Disconnection' },
        { label: 'Demolition', value: 'DEMO', helpText: 'Demolition' },
        { label: 'Change Of Supplier', value: 'COS', helpText: 'Change Of Supplier' },
        { label: 'Change Of Tenancy', value: 'COT', helpText: 'Change Of Tenancy' },
        { label: 'Duplicate', value: 'DPL', helpText: 'Duplicate' },
        { label: 'End Of Tenancy', value: 'EOT', helpText: 'End Of Tenancy' },
        { label: 'Customer Removed Meter', value: 'CM', helpText: 'Customer Removed Meter' },
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
        { label: 'Test Location 1', value: 'Loc1' },
        { label: 'Test Location 2', value: 'Loc2' }
    ];

    statusOptions = [
        { label: 'Test Status 1', value: 'Status1' },
        { label: 'Test Status 2', value: 'Status2' }
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
        { label: 'Test Meter Type 1', value: 'MeterType1' },
        { label: 'Test Meter Type 2', value: 'MeterType2' }
    ];

    capacityOptions = [
        { label: 'Test Capacity 1', value: 'Capacity1' },
        { label: 'Test Capacity 2', value: 'Capacity2' }
    ];

    mechanismOptions = [
        { label: 'Test Mechanism 1', value: 'Mechanism1' },
        { label: 'Test Mechanism 2', value: 'Mechanism2' }
    ];

    collarOptions = [
        { label: 'Test Collar 1', value: 'Collar1' },
        { label: 'Test Collar 2', value: 'Collar2' }
    ];

    // Register Details dropdowns
    digitOptions = [
        { label: 'Test Digits 1', value: 'Digits1' },
        { label: 'Test Digits 2', value: 'Digits2' }
    ];

    factorOptions = [
        { label: 'Test Factor 1', value: 'Factor1' },
        { label: 'Test Factor 2', value: 'Factor2' }
    ];

    unitOptions = [
        { label: 'Test Unit 1', value: 'Unit1' },
        { label: 'Test Unit 2', value: 'Unit2' }
    ];

    // Dynamic classes for radio cards
    get mainOptionsWithClass() {
        return this.mainOptions.map(opt => ({
            ...opt,
            className: this.selectedMain === opt.value
                ? 'radio-card selected'
                : 'radio-card',
            checked: this.selectedMain === opt.value,
            isSelected: this.selectedMain === opt.value
        }));
    }

    get appointmentOptionsWithClass() {
        return this.appointmentOptions.map(opt => ({
            ...opt,
            className:
                this.selectedAppType === opt.value
                    ? 'radio-card selected'
                    : 'radio-card',
            checked: this.selectedAppType === opt.value
        }));
    }



    // get appointmentOptionsWithClass() {
    //     return this.appointmentOptions.map(opt => ({
    //         ...opt,
    //         className: this.selectedAppType === opt.value ? 'radio-card selected' : 'radio-card',
    //         checked: this.selectedAppType === opt.value
    //     }));
    // }

    // get deappointmentOptionsWithClass() {
    //     return this.deappointmentOptions.map(opt => ({
    //         ...opt,
    //         className: this.selectedDeType === opt.value ? 'radio-card selected' : 'radio-card',
    //         checked: this.selectedDeType === opt.value
    //     }));
    // }

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

    // Event handlers

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
        console.log('selectedAppType', this.selectedAppType);
        const allAddressFilled = this.checkAllAddressFieldsFilled();
        const allAssetFilled = this.checkAllAssetFieldsFilled();
        if (this.selectedAppType !== ''){

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
    }




    get showCommonFields() {
        const hasAppointmentSubtype =
            this.selectedMain === 'Appointment' && !!this.selectedAppType;
        const hasDeappointmentSubtype =
            this.selectedMain === 'Deappointment' && !!this.selectedDeType;

        return hasAppointmentSubtype || hasDeappointmentSubtype;
    }

    // 9 feb change

    // Map UI labels to single-letter payload codes
    mapMeterLinkCode(label) {
        switch (label) {
            case 'Free Standing': return 'F';
            case 'Prime': return 'P';
            case 'Sub': return 'S';
            default: return 'F'; // safe default
        }
    }

    // 9 feb change end here

    // Common field handlers
    handleMeterLinkChange(event) {
        // detail.value is the selected combobox value
        this.meterLinkCode = event.detail.value;

        // 4 feb change for mandatory

        const err = this.template.querySelector('[data-error-for="meterLinkCode"]');
        if (err) err.hidden = true;

        // 4 feb change end here for mandatory

        // Optional: debug
        // console.log('meterLinkCode:', this.meterLinkCode);
    }

    handleEffectiveDateChange(event) {

        this.effectiveDate = event.detail.value;
        // Optional: debug
        // console.log('effectiveDate:', this.effectiveDate);
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

        // 4 feb change for mandatory


        // Block native submit and run validation first
        if (event && event.preventDefault) event.preventDefault();
        const isValid = this.validateBeforeSubmit();
        if (!isValid) {
            this.isLoading = false;
            return;
        }


        // 4 feb change end here for mandatory

        console.log('Inside handleSubmitDeappointment');
        console.log('this.consent: ', this.consent);
        console.log('effectivedate: ', this.effectiveDate);
        this.supplierContract = '';
        if (this.consent == true) {
            this.consentMessage = '';
            this.consentMessageFlag = false;

            this.isLoading = true;
            const fileIdentifier = 'AP' + Math.floor(100000000000 + Math.random() * 900000000000);
            console.log('fileIdentifier: ', fileIdentifier);
            console.log('selectedMain: ', this.selectedMain);
            console.log('suppliercode: ', this.suppliercode);
            console.log('selectedAppType: ', this.selectedAppType);
            console.log('selectedDeType: ', this.selectedDeType);

            if (this.suppliercode != null && this.suppliercode != '' && this.suppliercode != undefined) {
                console.log('inside suppliercode if');
                const supplierInfo = await getSupplierInfo({ customer: this.suppliercode });    //this.fetchSupplierContract(this.suppliercode) ;
                console.log('inside suppliercode if Contract: ', supplierInfo);
                if (supplierInfo != null && supplierInfo != '' && supplierInfo != undefined) {
                    if (supplierInfo.NGMCP_Rental_Contract__c != null && supplierInfo.NGMCP_Rental_Contract__c != '' && supplierInfo.NGMCP_Rental_Contract__c != undefined) {

                        this.supplierContract = supplierInfo.NGMCP_Rental_Contract__c;
                    }
                }
            }
            console.log('Contract: ', this.supplierContract);
            const meterSectorCode = this.metadataRecord && this.metadataRecord.length > 0 &&
                this.metadataRecord[0].metadatalist && this.metadataRecord[0].metadatalist.length > 0 &&
                this.metadataRecord[0].metadatalist[0].NGMCP_Market_Sector_Code__c ?
                this.metadataRecord[0].metadatalist[0].NGMCP_Market_Sector_Code__c :
                this.metadataRecord && this.metadataRecord.metadatalist &&
                    this.metadataRecord.metadatalist.length > 0 &&
                    this.metadataRecord.metadatalist[0].NGMCP_Market_Sector_Code__c ?
                    this.metadataRecord.metadatalist[0].NGMCP_Market_Sector_Code__c : this.residentialSiteValue == 'Yes' ? 'D' : 'I';
            console.log('meterSectorCode: ', meterSectorCode);
            const mprnList = this.mprn.split(' - ');
            console.log('mprnList: ', mprnList);
            console.log('addressInput: ', this.addressInput);
            console.log('isCOSDe: ', this.isCOSDe);
            console.log('newSupplierShortCode: ', this.newSupplierShortCode);
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
                    //ngme_from_date: this.convertDateFormatNoSpaces(this.effectiveDate)
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
            console.log('isFix: ', this.isFIX);
            console.log('isFNDAS: ', this.isFNDAS);
            if (this.isFIX || this.isFNDAS) {
                const ngme_addrs =
                {
                    ngme_type_code: "MTRPT",
                    ngme_record_identifier: "ADDRS",
                    ngme_sub_building_no: "",
                    ngme_building_no: this.buildingNumber,
                    ngme_dependent_through: "",
                    ngme_throughfare: this.street,
                    ngme_double_locality: "",
                    ngme_dependent_locality: this.dependentLocality,
                    ngme_post_town: this.postalTown,
                    ngme_county: "",
                    ngme_post_code: this.postCode
                };
                payload.ngme_trans.ngme_mtpnt.ngme_addrs = ngme_addrs;
            }
            console.log('Payload: ', JSON.stringify(payload));

            try {
                // Step 1: Create record
                const requestRecordId = await createAppntDeappntRecord({
                    requestBody: JSON.stringify(payload)
                });

                console.log(' Request Record ID:', requestRecordId);

                // Step 2: Submit request if record creation succeeded
                if (requestRecordId) {
                    const response = await submitAppntDeappnt({
                        requestBody: JSON.stringify(payload),
                        requestId: requestRecordId
                    });

                    console.log(' Apex response:', response);
                    const parsed = typeof response === "string" ? JSON.parse(response) : response;
                    console.log(' parsed response:', parsed);
                    if (parsed) {
                        this.successMessage = this.selectedMain == 'Appointment' ? 'The appointment request has been created successfully' : 'The deappointment request has been created successfully'
                        this.serviceTicketid = 'The reference number is ';
                        const req = await getRequest({ requestid: requestRecordId });
                        console.log('req: ', req);

                        this.srNumber = req.Name;
                        this.isModal = true;
                    }

                    // TODO: Show success toast or navigate
                } else {
                    console.warn(' No request record ID returned.');
                }
            } catch (error) {
                console.log('Error during Apex callout:', error);
                console.error('error:', JSON.stringify(error));
                const str = error.body.message;
                console.log('str: ', str);
                const matches = [...str.matchAll(/%(.*?)%/g)].map(m => m[1]);
                console.log('matches: ', matches);
                if (matches) {
                    this.successMessage = 'Request could not be submitted as ' + matches;
                }
                else {
                    this.successMessage = 'Request could not be submitted as ' + JSON.stringify(error);
                }
                console.log('successMessage: ', this.successMessage);
                this.serviceTicketid = '';
                this.srNumber = '';
                this.isModal = true;

            } finally {
                // Stop loading
                this.isLoading = false;
                console.log('Submission process completed.');
            }
        }
        else {
            this.consentMessage = 'consent is required';
            this.consentMessageFlag = true;
        }

    }
    /*
        convertDateFormatNoSpaces(date){
            
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0'); 
            const day = String(date.getDate()).padStart(2, '0');
    
            return `${year}${month}${day}`;
    
        }
     */
    convertDateFormatNoSpaces(dateInput) {
        // If it's already a Date, use it. If it's a string, convert it.
        const date = (dateInput instanceof Date) ? dateInput : new Date(dateInput);

        if (isNaN(date.getTime())) {
            console.error("Invalid date:", dateInput);
            return null;
        }

        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');

        return `${year}${month}${day}`;
    }


    connectedCallback() {
        console.log('userId: ', this.userId);
        console.log('shortCode: ', this.shortCode);
        console.log('residentialSiteValue: ', this.residentialSiteValue);
        if (this.residentialSiteValue == null || this.residentialSiteValue == '' || this.residentialSiteValue == undefined) {
            this.residentialSiteValue = 'No';
        }
        console.log('residentialSiteValue after: ', this.residentialSiteValue);

        // this.addressDetails = {"buildingNumber":"334","buildingName":"BURTON GROUP","street":"OXFORD STREET","dependentLocality":"N/A","postalTown":"LONDON","postCode":"W1C 1JG"};
        // this.assetDetails = [{"label":"Manufacturer","value":"PC COMPTEURS"},{"label":"Model","value":"800/150"},{"label":"Manufacturer Serial no.","value":"0315429"},{"label":"Meter Type","value":"Rotary Displacement"},{"label":"No. of Dials","value":7},{"label":"Payment Mechanism","value":"Credit"},{"label":"Year of Manufacture","value":"1978"},{"label":"Location","value":"Other"},{"label":"Install Date","value":"01-01-1978"},{"label":"Measuring Capacity","value":1000}]
        console.log("Address before: ", JSON.stringify(this.addressDetails));
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
        // this.metadataRecord = [{"metadatalist":[{"NGMCP_Meter_Model_Size__c":"Non U6","NGMCP_Market_Sector_Code__c":"I","Id":"m0Pdu000003w5R0EAI","NGMCP_UWR_Job_Code__c":"EXCFTTU","NGMCP_Portal_Category__c":"Faulty Turbine"}],"assetnum":"21086273","location":"10091406","suppliercode":"QU2","ngme_industry":"I"}]
        // this.mprn = "10091406";
        this.postCode = this.addressDetails.postCode;
        this.buildingNumber = this.addressDetails.buildingNumber;
        this.buildingName = this.addressDetails.buildingName;
        this.street = this.addressDetails.street;
        this.postalTown = this.addressDetails.postalTown;
        this.dependentLocality = this.addressDetails.dependentLocality;
        console.log("Metadata Record: ", JSON.stringify(this.metadataRecord));
        //console.log("Status: ", this.status);
        //console.log("Payment Mechanism: ", this.paymentMechanism);
        console.log('postCode: ', this.postCode);
        console.log('MPRN: ', this.mprn);
        if (this.metadataRecord && this.metadataRecord.length > 0 && this.metadataRecord[0].suppliercode) {
            this.suppliercode = this.metadataRecord[0].suppliercode;
        } else if (this.metadataRecord && this.metadataRecord.suppliercode) {
            this.suppliercode = this.metadataRecord.suppliercode;
        }
        console.log("suppliercode: ", this.suppliercode);
        if (this.suppliercode == null || this.suppliercode == '' || this.suppliercode == undefined) {
            this.suppliercode = this.shortCode;
        }
        console.log("suppliercode: ", this.suppliercode);
        //this.fetchEnquiryCodes();
        //console.log('Enquiry codes: ', this.enquiryCodes);

        // 21 jan change

        const today = new Date();
        const y = today.getFullYear();
        const m = String(today.getMonth() + 1).padStart(2, '0');
        const d = String(today.getDate()).padStart(2, '0');

        this.minDate = `${y}-${m}-${d}`;         // block past dates (optional)

        // --- Default Meter Link Code to "Free Standing" ---
        this.meterLinkCode = 'Free Standing';  // 9 feb change



        // 21 jan change end here
    }

    // 21 jan change

    // 2) New handler for the holiday picker event
    handleDateSelected(event) {
        // Expect the child to send { detail: { value: 'YYYY-MM-DD' } }
        const iso = event?.detail?.date;
        if (!iso) return;
        this.effectiveDate = iso //?? event.target?.value;
        console.log('Selected date: ', this.effectiveDate);

        // 4 feb change for mandatory

        const err = this.template.querySelector('[data-error-for="effectiveDate"]');
        if (err) err.hidden = true;

        // 4 feb change end here for mandatory
    }

    // If you want to keep backward compatibility with your old <lightning-input>:
    handleEffectiveDateChange(event) {
        this.effectiveDate = event.detail?.value ?? event.target?.value;

        // 4 feb change for mandatory

        const err = this.template.querySelector('[data-error-for="effectiveDate"]');
        if (err) err.hidden = true;

        // 4 feb change end here for mandatory
    }



    // 21 jan change end here

    fetchSupplierContract(supplier) {

        getSupplierInfo({ customer: supplier })
            .then(result => {
                console.log('Result: ', result);
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
                console.log('Error: ', error);
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
        console.log('this.consent: ', this.consent);
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
        console.log('this.addressInput: ', this.addressInput);

        // 4 feb change for mandatory

        // Hide that field’s error
        const key = event.target.dataset.field || event.target.name;
        const err = this.template.querySelector(`[data-error-for="${CSS.escape(key)}"]`);
        if (err) err.hidden = !!(event.target.value ?? '').toString().trim();
        event.target.classList.remove('invalid');

        // 4 feb mandatory end here
    }

    // 4 feb change for mandatory

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

        // 4) Subtype-specific required sets

        // Appointment → FIX or FNDAS → Address is mandatory
        if (this.selectedMain === 'Appointment' && (this.isFIX || this.isFNDAS)) {
            const need = ['buildingNumber', 'buildingName', 'dependentLocality', 'street', 'postalTown', 'postalCode'];
            need.forEach(k => {
                // prefer DOM when present; fall back to this.addressInput
                const el = this.template.querySelector(`.text-input[data-field="${CSS.escape(k)}"], .text-input[name="${CSS.escape(k)}"]`);
                const domVal = el ? (el.value ?? '').trim() : '';
                const val = domVal || (this.addressInput?.[k] ?? '').toString().trim();
                const empty = !val;
                if (empty) {
                    ok = false;
                    if (el) el.classList.add('invalid');
                    toggleErr(k, true);
                    firstEl = firstEl || el;
                } else {
                    if (el) el.classList.remove('invalid');
                    toggleErr(k, false);
                }
            });
        }

        // Deappointment → COS → New Supplier Short Code required
        if (this.selectedMain === 'Deappointment' && this.isCOSDe) {
            const empty = !this.newSupplierShortCode || !String(this.newSupplierShortCode).trim();
            if (empty) {
                ok = false;
                toggleErr('newSupplierShortCode', true);
                const el = this.template.querySelector('[data-field="newSupplierShortCode"].text-input') ||
                    this.template.querySelector('lightning-combobox[data-field="newSupplierShortCode"]');
                firstEl = firstEl || el;
            } else {
                toggleErr('newSupplierShortCode', false);
            }
        }

        // 5) Consent
        if (!this.consent) {
            ok = false;
            this.consentMessage = 'consent is required';
            this.consentMessageFlag = true;
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

    // Clears the inline error as soon as a user types/selects
    handlePlainTyping(event) {
        const field = event.target.dataset.field || event.target.name;
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
        console.log(' Auto selecting main option:', mode);
        console.log('AppointDeappoint rendered');
        console.log('requestSource =', this.requestSource);

        if (this.requestSource && !this.hasAutoSelected) {
            const mapped = this.mapRequestSource(this.requestSource);
            console.log('Mapped request type =', mapped);
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
        return this.assetDetails.every(field => field.value && field.value.trim() !== '');
    }

    checkAllAddressFieldsFilled() {
        const list = this.addressDetails;
        if (!list?.length) return true;
        const normalize = (v) => (v == null ? '' : String(v)).replace(/\u200B/g, '').trim();
        const map = Object.create(null);
        for (const f of list) {
            if (!f?.apiName) continue;
            map[f.apiName] = normalize(f.value);
            const mustAllBeFilled = ['street', 'postalTown', 'postCode'];
            const mustHaveOneOf = ['buildingName', 'buildingNumber'];

            const isNonEmpty = (k) => !!map[k];
            const hasAllRequired = mustAllBeFilled.every(isNonEmpty);
            const hasOneBuilding = mustHaveOneOf.some(isNonEmpty);
            console.log('hasAllRequired', hasAllRequired);
            console.log('hasOneBuilding', hasOneBuilding);
            console.log('hasOneBuconditionilding', hasAllRequired && hasOneBuilding);
            return hasAllRequired && hasOneBuilding;
        }
    }
}