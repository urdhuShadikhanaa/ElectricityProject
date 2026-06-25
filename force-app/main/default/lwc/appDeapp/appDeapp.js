import { LightningElement, track } from 'lwc';
import getSupplierInfo from "@salesforce/apex/NGMCP_AppointmentDeappointmentHandler.getSupplierInfo";
import submitAppntDeappnt from "@salesforce/apex/NGMCP_AppointmentDeappointmentHandler.submitAppntDeappnt";
import createAppntDeappntRecord from "@salesforce/apex/NGMCP_AppointmentDeappointmentHandler.createAppntDeappntRecord";

export default class AppointmentDeappointment extends LightningElement {
     prefillDemo = false; // set true only when you want demo values   // modify on 11 dec
    @track selectedMain;
    @track selectedAppType;
    @track selectedDeType;
    supplierInfo = {}
    metadataRecord;
        assetDetails = [];
        addressDetails = {};
        status;
        paymentMechanism;
        postCode;
        sectorCode;
        mprn;
        @track contactDetails = { title: "", name: "", contactNumber: "", contactEmail: this.email };
        suppliercode;
        
        email;
        /*@api metadataRecord;
        @api assetDetails = [];     // Array expected
        @api addressDetails = {};   // Can come as object from parent
        @api status;
        @api paymentMechanism;
        @api postCode;
        @api mprn;*/
    
        postalTown;
        buildingName;
        buildingNumber;
        street;
        dependentLocality;
        descriptionText;

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
        { label: 'Change Of Agent', value: 'COA', helpText: 'Change Of Agent' },
        { label: 'Disconnection', value: 'DE', helpText: 'Disconnection' },
        { label: 'Demolition', value: 'Demo', helpText: 'Demolition' },
        { label: 'Change Of Supplier', value: 'COS', helpText: 'Change Of Supplier' },
        { label: 'Change Of Tenancy', value: 'COT', helpText: 'Change Of Tenancy' },
        { label: 'Duplicate', value: 'DPL', helpText: 'Duplicate' },
        { label: 'End Of Tenancy', value: 'EOT', helpText: 'End Of Tenancy' },
        { label: 'Customer Removed Meter', value: 'CM', helpText: 'Customer Removed Meter' }
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
            className: this.selectedMain === opt.value ? 'radio-card selected' : 'radio-card',
            checked: this.selectedMain === opt.value
        }));
    }

    get appointmentOptionsWithClass() {
        return this.appointmentOptions.map(opt => ({
            ...opt,
            className: this.selectedAppType === opt.value ? 'radio-card selected' : 'radio-card',
            checked: this.selectedAppType === opt.value
        }));
    }

    get deappointmentOptionsWithClass() {
        return this.deappointmentOptions.map(opt => ({
            ...opt,
            className: this.selectedDeType === opt.value ? 'radio-card selected' : 'radio-card',
            checked: this.selectedDeType === opt.value
        }));
    }

    // Event handlers
    handleCardClick(event) {
        this.selectedMain = event.currentTarget.querySelector('input').value;
        this.selectedAppType = null;
        this.selectedDeType = null;
    }

    handleAppCardClick(event) {
        this.selectedAppType = event.currentTarget.querySelector('input').value;

        // Clear address when switching subtypes
        // modify on 11 dec 
  this.addressDetails = {
    buildingNumber: '',
    buildingName: '',
    dependentLocality: '',
    street: '',
    postalTown: '',
    postCode: ''
  };
            // modify on 11 dec end here
    }

    handleDeCardClick(event) {
        this.selectedDeType = event.currentTarget.querySelector('input').value;
    }

    // Fired by <c-ngm-date-picker-with-holidays> when user picks a date
handleDateSelected(event) {
  const iso = event?.detail?.date; // 'YYYY-MM-DD'
  if (!iso) return;

  // Optional: show on UI (if you have a field to echo)
  this.selectedDate = iso;

  // Store into the form payload your submit already uses
  // (you already send targetstart: this.formData.appointmentDate)
  this.formData = { ...this.formData, appointmentDate: iso };
}



    

get showCommonFields() {
    const hasAppointmentSubtype =
        this.selectedMain === 'Appointment' && !!this.selectedAppType;
    const hasDeappointmentSubtype =
        this.selectedMain === 'Deappointment' && !!this.selectedDeType;

    return hasAppointmentSubtype || hasDeappointmentSubtype;
}


// Common field handlers
handleMeterLinkChange(event) {
    // detail.value is the selected combobox value
    this.meterLinkCode = event.detail.value;
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

     connectedCallback(){
        this.addressDetails = {"buildingNumber":"334","buildingName":"BURTON GROUP","street":"OXFORD STREET","dependentLocality":"N/A","postalTown":"LONDON","postCode":"W1C 1JG"};
        if (this.prefillDemo) {
this.addressDetails = {                     // modify on 11 dec 
buildingNumber: '334',                       // modify on 11 dec 
buildingName: 'BURTON GROUP',                // modify on 11 dec 
street: 'OXFORD STREET',                 // modify on 11 dec     
dependentLocality: 'N/A',           // modify on 11 dec 
postalTown: 'LONDON',                       // modify on 11 dec 
postCode: 'W1C 1JG'                          // modify on 11 dec 
};
 }

        this.assetDetails = [{"label":"Manufacturer","value":"PC COMPTEURS"},{"label":"Model","value":"800/150"},{"label":"Manufacturer Serial no.","value":"0315429"},{"label":"Meter Type","value":"Rotary Displacement"},{"label":"No. of Dials","value":7},{"label":"Payment Mechanism","value":"Credit"},{"label":"Year of Manufacture","value":"1978"},{"label":"Location","value":"Other"},{"label":"Install Date","value":"01-01-1978"},{"label":"Measuring Capacity","value":1000}]
        console.log("Address : ", JSON.stringify(this.addressDetails));
        console.log("Asset: ", JSON.stringify(this.assetDetails));
        this.metadataRecord = [{"metadatalist":[{"NGMCP_Meter_Model_Size__c":"Non U6","NGMCP_Market_Sector_Code__c":"I","Id":"m0Pdu000003w5R0EAI","NGMCP_UWR_Job_Code__c":"EXCFTTU","NGMCP_Portal_Category__c":"Faulty Turbine"}],"assetnum":"21086273","location":"10091406","suppliercode":"BGT","ngme_industry":"I"}]
        this.mprn = "81616902";
        this.postCode = this.addressDetails.postCode;
        this.buildingNumber = this.addressDetails.buildingNumber;
        this.buildingName = this.addressDetails.buildingName;
        this.street = this.addressDetails.street;
        this.postalTown = this.addressDetails.postalTown;
        this.dependentLocality = this.addressDetails.dependentLocality;
        this.sectorCode = 'I';
        console.log("Metadata Record: ", JSON.stringify(this.metadataRecord));
        console.log("Status: ", this.status);
        console.log("Payment Mechanism: ", this.paymentMechanism);
        console.log('postCode: ', this.postCode);
        console.log('MPRN: ', this.mprn);
        this.suppliercode = this.metadataRecord[0].suppliercode;
        //this.fetchEnquiryCodes();
        //console.log('Enquiry codes: ', this.enquiryCodes);
    }

    // modify on 11 dec
    
validateAllRequired() {
  const controls = this.template.querySelectorAll(
    'lightning-input, lightning-combobox, lightning-radio-group, lightning-textarea'
  );
  let allValid = true;
  controls.forEach(ctrl => {
    const hiddenAncestor = ctrl.closest('[hidden]');
    if (hiddenAncestor) return;            // ignore hidden sections
    const ok = ctrl.checkValidity?.() ?? true;
    ctrl.reportValidity?.();               // show inline error immediately
    if (!ok) allValid = false;
  });
  
  return allValid;
}

    
handleAddrBuildingNumberChange(e) { this.addressDetails = { ...this.addressDetails, buildingNumber: e.detail.value }; }
handleAddrBuildingNameChange(e)   { this.addressDetails = { ...this.addressDetails, buildingName: e.detail.value }; }
handleAddrDependentLocalityChange(e){ this.addressDetails = { ...this.addressDetails, dependentLocality: e.detail.value }; }
handleAddrStreetChange(e)         { this.addressDetails = { ...this.addressDetails, street: e.detail.value }; }
handleAddrPostalTownChange(e)     { this.addressDetails = { ...this.addressDetails, postalTown: e.detail.value }; }
handleAddrPostalCodeChange(e)     { this.addressDetails = { ...this.addressDetails, postCode: e.detail.value }; }


// Appointment → FNDAS / FIX field bindings
model; yearManufacture; locationCode; assetStatusCode; manufacturer; manufacturerSerialNo;
paymentType; assetLocationNotes;
meterTypeCode; measuringCapacity; mechanismCode; collarStatusCode;
noOfDigits; multiplicationFactor; unitOfMeasure;

// Change handlers (minimal examples)
handleModelChange(e){ this.model = e.detail.value; }
handleYearManufactureChange(e){ this.yearManufacture = e.detail.value; }
handleLocationCodeChange(e){ this.locationCode = e.detail.value; }
handleAssetStatusCodeChange(e){ this.assetStatusCode = e.detail.value; }
handleManufacturerChange(e){ this.manufacturer = e.detail.value; }
handleManufacturerSerialNoChange(e){ this.manufacturerSerialNo = e.detail.value; }
handlePaymentTypeChange(e){ this.paymentType = e.detail.value; }
handleAssetLocationNotesChange(e){ this.assetLocationNotes = e.detail.value; }

handleMeterTypeCodeChange(e){ this.meterTypeCode = e.detail.value; }
handleMeasuringCapacityChange(e){ this.measuringCapacity = e.detail.value; }
handleMechanismCodeChange(e){ this.mechanismCode = e.detail.value; }
handleCollarStatusCodeChange(e){ this.collarStatusCode = e.detail.value; }

handleNoOfDigitsChange(e){ this.noOfDigits = e.detail.value; }
handleMultiplicationFactorChange(e){ this.multiplicationFactor = e.detail.value; }
handleUnitOfMeasureChange(e){ this.unitOfMeasure = e.detail.value; }





        
newSupplierShortCode = '';

handleNewSupplierShortCodeChange(event) {
  this.newSupplierShortCode = event.detail.value;
}

        // modify on 11 dec end here

    handleSubmitAppointment(event){

        
if (!this.validateAllRequired()) {   // modify on 11 dec
    // Optional: toast error here
    return;
}
        // modify on 11 dec end here


        console.log('Inside handleSubmit');
        console.log("selectedMain: ", this.selectedMain);
        console.log("selectedAppType: ", this.selectedAppType);
        console.log('selectedDeType: ', this.selectedDeType);
        const prefix = 'AP';
        var randomNum = Math.floor(100000000000 + Math.random() * 900000000000);
        console.log('Random number: ', randomNum);
        var prefixedNum = prefix + randomNum;
        console.log('Prefixed number: ', prefixedNum);
        const currentDateUTC = new Date().toISOString().split('T')[0];
        console.log('Current date: ', currentDateUTC);
        const creationDate = currentDateUTC.split('-').join('');
        console.log('creationDate: ', creationDate);
        const currentTime = new Date().toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit', second: '2-digit' }).split(':').join('');
        console.log('currentTime: ', currentTime);
        console.log('this.effectiveDate: ', this.effectiveDate);
        //const fromDate = this.effectiveDate.toISOString().split('T')[0]
        //console.log('fromDate: ', fromDate);
        const fromDateModified = this.effectiveDate.split('-').join('');
        console.log('fromDateModified: ', fromDateModified);
        console.log('supplierCode: ', this.suppliercode)
        getSupplierInfo({customer: this.suppliercode})
        .then(result => {
            this.supplierInfo = result;
            console.log('Supplier info: ', this.supplierInfo);

            //payload for apex callout
                const payload = {
                ngme_file_type: 'ONAGE',
                ngme_creation_date: creationDate,
                ngme_originator_id: this.suppliercode,
                ngme_recipient_role: 'MAM',
                ngme_status: 'NEW',
                ngme_transaction_count: '1',
                ngme_integration_type: 'INBOUND',
                ngme_creation_time: currentTime,
                ngme_reqrecdate: currentDateUTC,
                ngme_record_count: this.selectedAppType == 'COS' ? '3' : this.selectedAppType == 'FIX' ? '1' : '1',
                ngme_record_identifier: 'HEADR',
                ngme_recipient_id: 'GTM',
                ngme_trans: {
                    ngme_reason_code: this.selectedMain == 'Appointment' ? this.selectedAppType : this.selectedDeType,
                    ngme_reference: this.mprn,
                    ngme_type_code: this.selectedMain == 'Appointment' ? 'APPNT' : 'DEAPP',
                    ngme_sector_code: this.sectorCode,
                    ngme_record_identifier: 'TRANS',
                    ngme_contract_ref:this.supplierInfo != null ? this.supplierInfo.NGMCP_Rental_Contract__c : '',
                    ngme_mtpnt: {
                        ngme_record_identifier: 'MTPNT',
                        ngme_mkprt: {
                            ngme_record_identifier: 'MKPRT',
                            ngme_role_code: 'MAM',
                            ngme_abbrv_name: 'GTM'
                        },
                        ngme_link_code: 'F',
                        ngme_referencenum: this.mprn
                    },
                    
                },
                ngme_originator_role: 'SUP',
                ngme_file_identifier: prefixedNum,
                ngme_source_system: 'PORTAL',
                ngme_file_usage_code: 'PRDCT'
    
            };
            if(this.selectedMain == 'Appointment'){
                payload.ngme_trans.ngme_from_date = fromDateModified;
            }
            else{
                payload.ngme_trans.ngme_to_date = fromDateModified;
            }
            if(this.selectedAppType == 'FIX'){
                console.log('selectedAppType: ', this.selectedAppType);
                
               // payload.ngme_trans.ngme_mtpnt.ngme_addrs.ngme_type_code = 'MTRPT';
              const address = {
                    ngme_type_code : 'MTRPT',
                    ngme_record_identifier: 'ADDRS',
                    ngme_sub_building_no:'',
                    ngme_building_no: 'B1202',
                    ngme_dependent_through: '',
                    ngme_throughfare: 'Oxfor11d Road',
                    ngme_double_locality: '',
                    ngme_dependent_locality: 'British Business Park',
                    ngme_post_town: 'London',
                    ngme_county: '',
                    ngme_post_code: 'BD23 3SA'

               }
               console.log('address: ', address);
               payload.ngme_trans.ngme_mtpnt.ngme_addrs = address;
               
            }
            console.log('Payload submitted:', JSON.stringify(payload));   
            createAppntDeappntRecord({
                           requestBody: JSON.stringify(payload)
                       }) 
            .then(result1 =>{
                const requestRecordId = result1;
                console.log(' Request Record ID:', requestRecordId);
                submitAppntDeappnt({
                               requestBody: JSON.stringify(payload),
                               requestId: requestRecordId
                           })
                .then(result2 => {
                    console.log(' Apex response:', result2);
                })
                .catch(error => {
                    console.error('Error submitting request: ', error);
                });
            })
            .catch(error => {
                console.error('Error fetching supplier info: ', error);
            });
              
                     
        

        }).catch(error => {
            console.log('Error fetching supplier info: ', JSON.stringify(error));
        });
        
                
    }

    fetchSupplier(supplierCode){
        getSupplierInfo({customer: supplierCode})
        .then(result => {
            this.supplierInfo = result;
            console.log('Supplier info: ', this.supplierInfo);
        }).catch(error => {
            console.error('Error fetching supplier info: ', error);
        });
    }

}