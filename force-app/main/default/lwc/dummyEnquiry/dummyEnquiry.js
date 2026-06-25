import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import getAllEnquiryCodes from "@salesforce/apex/NGMCP_EnquiriesHandler.getAllEnquiryCodes";
import submitDataQuery from "@salesforce/apex/NGMCP_EnquiriesHandler.submitDataQuery";
import createDataQueryRecord from "@salesforce/apex/NGMCP_EnquiriesHandler.createDataQueryRecord";
const FIELDS = ['User.Email'];

export default class DummyEnquiry extends LightningElement {
    selectedMainQuery = '';
    selectedReason = '';
    selectedAssetReason = '';
    selectedAssetType = '';
    selectedAssetIssue = '';
    instructionText = '';
     @track formData = {}; //

    @api metadataRecord;
    @api assetDetails = [];
    @api addressDetails = {};
    @api createrequestFlag;
    status;
    paymentMechanism;
    postCode;
    @api mprn;
    @track contactDetails = { title: "", name: "", contactNumber: "", contactEmail: this.email };
    suppliercode;
    userId = USER_ID;
    @api selectedMainQueryvalue;
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
    enquiryCodes = [];
    mainQueryOptions = [];
    dateQueryReasons = [];
    assetDataReasons = [];
    assetTypeOptions = [];
    meterIssues = [];
    converterIssues = [];

    @wire(getRecord, { recordId: '$userId', fields: FIELDS })
    userRecord({ error, data }) {
        if (data) {
            this.email = data.fields.Email.value;
        }
    }
    instructionMap = {
        FOU: 'Found Meter that is not recorded on your system...',
        adhoc: 'Instruction: Provide additional context...',
        ADQ: 'Instruction: Ensure asset details are accurate...',
        DUM1: 'An exchange took place DD/MM/YY...',
        MRV: 'MSN ************** was removed...',
        CFU: 'We believe the correction factor...',
        DUM2: 'The asset details currently held...',
        CRM: 'Meter is corroded or rusty...',
        MUOP: 'Meter is under pulsing...',
        MNR: 'Meter is not registering usage...',
        FMB: 'Meter bracket is faulty...',
        WOMS: 'Water condensation observed...',
        BSM: 'Meter screen is blank...',
        DUM4: 'Other meter-related issue...',
        LBC: 'Converter shows low battery warning...',
        CROS: 'Converter reads are inconsistent...',
        CXPC: 'Converter is not pulsing...'
    };

    enquiryFieldsMap = {
        FOU: [
            { label: 'MSN', placeholder: 'Enter Meter Serial Number' },
            { label: 'Manufacturer Model', placeholder: 'Enter Model' },
            { label: 'Installation Date', placeholder: 'DD/MM/YYYY' }
        ],
        CAA: [
            { label: 'Building Name', placeholder: 'Enter Building Name' },
            { label: 'Building Number', placeholder: 'Enter Number' },
            { label: 'Street', placeholder: 'Enter Street' },
            { label: 'Dependent Locality', placeholder: 'Enter Locality' },
            { label: 'Postal Town', placeholder: 'Enter Town' },
            { label: 'Postal Code', placeholder: 'Enter Postal Code' }
        ],
        CRO: [
            { label: 'MPRN', placeholder: 'Enter MPRN' },
            { label: 'Address Detail', placeholder: 'Enter Address' },
            { label: 'Meter Detail', placeholder: 'Enter Meter Info' }
        ],
        MRV: [
            { label: 'Old MSN', placeholder: 'Enter Old MSN' },
            { label: 'Old Index', placeholder: 'Enter Old Index' },
            { label: 'Removal Date', placeholder: 'DD/MM/YYYY' }
        ],
        DUM1: [
            { label: 'Old MSN', placeholder: 'Enter Old MSN' },
            { label: 'Old Index', placeholder: 'Enter Old Index' },
            { label: 'New MSN', placeholder: 'Enter New MSN' },
            { label: 'New Manufacturer', placeholder: 'Enter Manufacturer' },
            { label: 'New Model', placeholder: 'Enter Model' },
            { label: 'New Index', placeholder: 'Enter New Index' },
            { label: 'Exchange Date', placeholder: 'DD/MM/YYYY' }
        ]
    };



    
// Dynamic fields getter
    get dynamicFields() {
        if (this.enquiryFieldsMap[this.selectedReason]) {
            return this.enquiryFieldsMap[this.selectedReason];
        }
        if (this.enquiryFieldsMap[this.selectedAssetReason]) {
            return this.enquiryFieldsMap[this.selectedAssetReason];
        }
        return [];
    }

    
        
handleMainQueryChange(event) {
        this.selectedMainQuery = this.selectedMainQueryvalue? this.selectedMainQueryvalue: event.target.value;
        console.log('Main Query Selected:', this.selectedMainQuery);
    }
    get showDateQuerySection() {
        return this.selectedMainQuery === 'AST';
    }

    get showAssetDataOptions() {
        return this.selectedReason === 'ADQ';
    }

    get showTechnicalQuerySection() {
        return this.selectedMainQuery === 'TQUERY';
    }

    get isMeterSelected() {
        return this.selectedAssetType === 'MET';
    }

    get isConverterSelected() {
        return this.selectedAssetType === 'CON';
    }

    get showEnquiryForm() {
        return (
            (this.selectedReason && this.selectedReason !== 'ADQ') ||
            this.selectedAssetReason ||
            this.selectedAssetIssue
        );
    }


   handleInputChange(event) {
    const field = event.target.dataset.field || event.target.name;
    this.formData = { ...this.formData, [field]: event.target.value }; // ✅ Reactive update
    console.log('Updated formData:', JSON.stringify(this.formData));
}

get showAppointmentFields() {
    return (this.formData && this.formData.visitSite ? this.formData.visitSite : 'No') === 'Yes';
}
renderedCallback() {
    console.log('selectedMainQueryvalue:', this.selectedMainQueryvalue);
    if(this.selectedMainQueryvalue){
            this.handleMainQueryChange();
        }
}
    async connectedCallback() {
     //   this.addressDetails = {"buildingNumber":"334","buildingName":"BURTON GROUP","street":"OXFORD STREET","dependentLocality":"N/A","postalTown":"LONDON","postCode":"W1C 1JG"};
      //  this.assetDetails = [{"label":"Manufacturer","value":"PC COMPTEURS"},{"label":"Model","value":"800/150"},{"label":"Manufacturer Serial no.","value":"0315429"},{"label":"Meter Type","value":"Rotary Displacement"},{"label":"No. of Dials","value":7},{"label":"Payment Mechanism","value":"Credit"},{"label":"Year of Manufacture","value":"1978"},{"label":"Location","value":"Other"},{"label":"Install Date","value":"01-01-1978"},{"label":"Measuring Capacity","value":1000}]
        console.log("Address : ", JSON.stringify(this.addressDetails));
        console.log("Asset: ", JSON.stringify(this.assetDetails));
        console.log("createjobrequestFlag: ", this.createrequestFlag);
      //  this.metadataRecord = [{"metadatalist":[{"NGMCP_Meter_Model_Size__c":"Non U6","NGMCP_Market_Sector_Code__c":"I","Id":"m0Pdu000003w5R0EAI","NGMCP_UWR_Job_Code__c":"EXCFTTU","NGMCP_Portal_Category__c":"Faulty Turbine"}],"assetnum":"21086273","location":"10091406","suppliercode":"QU2","ngme_industry":"I"}]
        //this.mprn = "10091406";
        this.postCode = this.addressDetails.postCode;
        this.buildingNumber = this.addressDetails.buildingNumber;
        this.buildingName = this.addressDetails.buildingName;
        this.street = this.addressDetails.street;
        this.postalTown = this.addressDetails.postalTown;
        this.dependentLocality = this.addressDetails.dependentLocality;
        console.log("Metadata Record: ", JSON.stringify(this.metadataRecord));
        console.log("Status: ", this.status);
        console.log("Payment Mechanism: ", this.paymentMechanism);
        console.log('postCode: ', this.postCode);
        console.log('MPRN: ', this.mprn);
        this.suppliercode = this.metadataRecord[0].suppliercode;
        await this.fetchEnquiryCodes();
        if(this.selectedMainQueryvalue){
            this.handleMainQueryChange();
        }
        console.log('Enquiry codes: ', this.enquiryCodes);
    }
    async fetchEnquiryCodes() {
        try {
            const data = await getAllEnquiryCodes({});
            console.log('Enquiry codes: ', data);
            this.enquiryCodes = Array.isArray(data) ? data : [];

            // Optional: Pre-build sets of labels for faster de-duping in this run
            const mainQueryLabels = new Set(this.mainQueryOptions.map(i => i.label));
            const dateQueryLabels = new Set(this.dateQueryReasons.map(i => i.label));
            const assetTypeLabels = new Set(this.assetTypeOptions.map(i => i.label));
            const assetDataLabels = new Set(this.assetDataReasons.map(i => i.label));
            const meterLabels = new Set(this.meterIssues.map(i => i.label));
            const converterLabels = new Set(this.converterIssues.map(i => i.label));

            for (const ec of this.enquiryCodes) {
                const category = ec?.NGMCP_Enquiry_Category__c;
                const categoryCode = ec?.NGMCP_Enquiry_Category_Code__c;
                const subCategory = ec?.NGMCP_Enquiry_Sub_Category__c;
                const subCategoryCode = ec?.NGMCP_Enquiry_Sub_Category_Code__c;
                const reason = ec?.NGMCP_Enquiry_Reason__c;
                const reasonCode = ec?.NGMCP_Enquiry_Reason_Code__c;

                // Guard against missing fields
                if (!category) continue;

                // 1) Main Query Options
                if (!mainQueryLabels.has(category)) {
                    this.mainQueryOptions = [
                        ...this.mainQueryOptions,
                        {
                            label: category,
                            value: categoryCode,
                            description:
                                'To raise data query to commercial and residential customer',
                            isChecked: false
                        }
                    ];
                    mainQueryLabels.add(category);
                }

                // 2) Asset Data Query → dateQueryReasons
                if (category === 'Asset Data Query' && subCategory && !dateQueryLabels.has(subCategory)) {
                    this.dateQueryReasons = [
                        ...this.dateQueryReasons,
                        {
                            label: subCategory,
                            value: subCategoryCode,
                            description:
                                'An ordinary request with several jobs type to choose from',
                            isChecked: false
                        }
                    ];
                    dateQueryLabels.add(subCategory);
                }

                // 3) Technical Query → assetTypeOptions
                if (category === 'Technical Query' && subCategory && !assetTypeLabels.has(subCategory)) {
                    this.assetTypeOptions = [
                        ...this.assetTypeOptions,
                        {
                            label: subCategory,
                            value: subCategoryCode,
                            description:
                                'An ordinary request with several jobs type to choose from',
                            isChecked: false
                        }
                    ];
                    assetTypeLabels.add(subCategory);
                }

                // 4) Asset Data Enquiry → assetDataReasons
                if (subCategory === 'Asset Data Enquiry' && reason && !assetDataLabels.has(reason)) {
                    this.assetDataReasons = [
                        ...this.assetDataReasons,
                        {
                            label: reason,
                            value: reasonCode,
                            description:
                                'An ordinary request with several jobs type to choose from',
                            isChecked: false
                        }
                    ];
                    assetDataLabels.add(reason);
                }

                // 5) Meter → meterIssues
                if (subCategory === 'Meter' && reason && !meterLabels.has(reason)) {
                    this.meterIssues = [
                        ...this.meterIssues,
                        {
                            label: reason,
                            value: reasonCode,
                            description:
                                'An ordinary request with several jobs type to choose from',
                            isChecked: false
                        }
                    ];
                    meterLabels.add(reason);
                }

                // 6) Converter → converterIssues
                if (subCategory === 'Converter' && reason && !converterLabels.has(reason)) {
                    this.converterIssues = [
                        ...this.converterIssues,
                        {
                            label: reason,
                            value: reasonCode,
                            description:
                                'An ordinary request with several jobs type to choose from',
                            isChecked: false
                        }
                    ];
                    converterLabels.add(reason);
                }
            }

            // Debug logs
            console.log('this.mainQueryOptions: ', JSON.stringify(this.mainQueryOptions));
            console.log('this.dateQueryReasons: ', JSON.stringify(this.dateQueryReasons));
            console.log('this.assetTypeOptions: ', JSON.stringify(this.assetTypeOptions));
            console.log('this.assetDataReasons: ', JSON.stringify(this.assetDataReasons));
            console.log('this.meterIssues: ', JSON.stringify(this.meterIssues));
            console.log('this.converterIssues: ', JSON.stringify(this.converterIssues));
        } catch (error) {
            console.error('Error fetching enquiry codes: ', JSON.stringify(error));
            // Optionally surface a toast
            // this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: error?.body?.message || 'Failed to fetch enquiry codes', variant: 'error' }));
        }
    }   

highlightSelected(event, sectionSelectors) {
    const selectors = Array.isArray(sectionSelectors) ? sectionSelectors : [sectionSelectors];

    // Remove selection within all provided sections
    selectors.forEach(sel => {
        this.template.querySelectorAll(`${sel} .card-radio`).forEach(el => {
            el.classList.remove('selected');
        });
    });

    // Select the clicked one
    event.target.closest('.card-radio')?.classList.add('selected');
}


   /* handleMainQueryChange(event) {
        this.selectedMainQuery = this.selectedMainQueryvalue? this.selectedMainQueryvalue: event.target.value;
        console.log('this.selectedMainQuery',this.selectedMainQuery);
        
        this.mainQueryOptions.forEach(opt => opt.isChecked = (opt.value === this.selectedMainQuery));
        this.selectedReason = '';
        this.selectedAssetReason = '';
        this.selectedAssetType = '';
        this.selectedAssetIssue = '';
        this.instructionText = '';
        this.formData = {};

         //this.highlightSelected(event, '.section-card:nth-of-type(1)')
    }*/

    handleReasonChange(event) {
        this.selectedReason = event.target.value;
        this.dateQueryReasons.forEach(r => r.isChecked = (r.value === this.selectedReason));
        this.instructionText = this.instructionMap[this.selectedReason] || '';
        this.formData = {};

        this.highlightSelected(event, '.section-card:nth-of-type(2)');
    }

    handleAssetReasonChange(event) {
        this.selectedAssetReason = event.target.value;
        this.assetDataReasons.forEach(r => r.isChecked = (r.value === this.selectedAssetReason));
        this.instructionText = this.instructionMap[this.selectedAssetReason] || '';
        this.formData = {};

        this.highlightSelected(event, '.section-card:nth-of-type(3)');
    }

    handleAssetTypeChange(event) {
        this.selectedAssetType = event.target.value;
        this.assetTypeOptions.forEach(t => t.isChecked = (t.value === this.selectedAssetType));
        this.selectedAssetIssue = '';
        this.instructionText = '';
        this.formData = {};

        this.highlightSelected(event, '.section-card:nth-of-type(4)');
    }

    handleAssetIssueChange(event) {
        this.selectedAssetIssue = event.target.value;
        this.instructionText = this.instructionMap[this.selectedAssetIssue] || '';
        this.formData = {};

        this.highlightSelected(event, ['.section-card:nth-of-type(4)', '.section-card:nth-of-type(5)', '.section-card:nth-of-type(6)']);

    }

    handleInputChange(event) {
        const field = event.target.dataset.field || event.target.name;
        this.formData[field] = event.target.value;
    }

    async handleSubmit(event) {
        console.log('Inside handleSubmit');
        console.log('Form submitted:', JSON.stringify(this.formData));
        console.log('MSN: ', this.formData["MSN"]);
        event.preventDefault();
        
         var instructionType = '';
        //this.instructionText
       
       console.log('this.selectedMainQuery: ',this.selectedMainQuery);
       if(this.selectedMainQuery == 'AST'){
            instructionType = this.selectedReason;
       }
       else{
            instructionType = this.selectedAssetReason;
       }
       console.log('instructionType: ',instructionType);
       console.log('this.instructionText: ',this.instructionText);
       this.descriptionText = this.handleInstruction(instructionType);
       console.log('this.descriptionText: ',this.descriptionText);
        //payload for apex callout
        const payload = {
        ngme_consname: this.contactDetails.name,
        reason: this.selectedReason == 'ADQ' ? this.selectedAssetReason : this.selectedAssetIssue,
        loccode: '',
        bldgname: this.buildingName,
        sectorcode: '',
        street: this.street,
        supplier: this.suppliercode,
        notif_type: this.selectedMainQuery == 'AST' ? 'DQ' : 'TQ',
        ngme_riskassess: this.formData.riskAssessment == 'Yes' ? 'Y' : 'N',
        posttown: this.postalTown,
        ngme_constitle: this.contactDetails.title,
        description_longdescription: this.descriptionText,
        ngme_engvisit: this.formData.visitSite == 'Yes' ? 'Y' : 'N',
        targetstart: this.formData.appointmentDate,
        postcode: this.postcode,
        ngme_time: this.formData.appointmentTimeslot,
        affectedphone: this.contactDetails.contactNumber,
        deplocal: this.dependentLocality,
        ngme_threshold: 'N',
        location: this.mprn,
        reportedemail: this.email, 
        category: this.selectedMainQuery,
        subcategory: this.selectedMainQuery == 'AST' ? this.selectedReason : this.selectedAssetType
    };
    console.log('Payload submitted:', JSON.stringify(payload));   
       
    
       try {
               // Step 1: Create record
               const requestRecordId = await createDataQueryRecord({
                   requestBody: JSON.stringify(payload)
               });
       
               console.log(' Request Record ID:', requestRecordId);
       
               // Step 2: Submit request if record creation succeeded
               if (requestRecordId) {
                   const response = await submitDataQuery({
                       requestBody: JSON.stringify(payload),
                       requestId: requestRecordId
                   });
       
                   console.log(' Apex response:', response);
       
                   // TODO: Show success toast or navigate
               } else {
                   console.warn(' No request record ID returned.');
               }
           } catch (error) {
               console.error('Error during Apex callout:', error);
               console.error('error:' , JSON.stringify(error));
               alert('Something went wrong while submitting the request.');
           } finally {
               // Stop loading
               this.isLoading = false;
               console.log('Submission process completed.');
           }
               
    }

    handleCancel() {
        this.selectedMainQuery = '';
        this.selectedReason = '';
        this.selectedAssetReason = '';
        this.selectedAssetType = '';
        this.selectedAssetIssue = '';
        this.instructionText = '';
        this.formData = {};
    }

    handleInstruction(instruction){
       console.log('Inside handleInstruction');
       let message = '';
       switch (instruction) {
        case 'FOU':
            message = 'Found Meter that is not recorded on your system. MSN ' + this.formData["MSN"] + ', Installed on ' + this.formData["Installation Date"] + '. Please investigate. ' + this.formData.additionalInfo;
            break;
        case 'adhoc':
            message = ''
            break;
        case 'ADQ':
            message = ''
            break;
        case 'DUM1':
            message = 'An exchange took place ' + this.formData["Exchange Date"] +', Old MSN was ' + this.formData["Old MSN"] + ' final read was ' + this.formData["Old Index"] +'. The new MSN is ' + this.formData["New MSN"] + ' new read ' + this.formData["New Index"] +'. '  + this.formData.additionalInfo;
            break;
        case 'MRV':
            message = 'MSN ' + this.formData["Old MSN"] + ' was removed on ' + this.formData["Removal Date"] + ' with a final read of ' + this.formData["Old Index"] + ' by/because *****************. Please investigate '  + this.formData.additionalInfo;
            break;
        case 'CFU':
            message = 'We believe the correction factor to be incorrect. It should be ***** based on the annual consumption ******** and ********. '  + this.formData.additionalInfo;
            break;
        case 'DUM2':
            message = 'The asset details currently held by you are incorrect. The correct details are: MSN **************. Please investigate. '  + this.formData.additionalInfo;
            break;
        case 'CRM':
            message = 'MSN ' + this.formData["MSN"] + ' has severe corrosion. Please see attached photo and arrange a site visit to replace the meter. ' + this.formData.additionalInfo;
            break;
        case 'MUOP':
            message = 'MSN ' + this.formData["MSN"] + ' is under/over (delete as required) pulsing. This has been confirmed from the AMR / converter data. ' + this.formData.additionalInfo;
            break;
        case 'MNR':
            message = 'MSN ' + this.formData["MSN"] + ' is not registering consumption, gas is being used. Please arrange a site visit to replace the meter. ' + this.formData.additionalInfo;
            break;
        case 'FMB':
            message = 'MSN ' + this.formData["MSN"] + ' is not fixed to the bracket and needs to be secured. No deliberate damage has been caused. Please rectify. ' + this.formData.additionalInfo;
            break;
        case 'WOMS':
            message = 'MSN ' + this.formData["MSN"] + ' has water/condensation in the screen. Please see attached photo and arrange a site visit to replace the meter. ' + this.formData.additionalInfo;
            break;
        case 'BSM':
            message = 'MSN ' + this.formData["MSN"] + ' has a blank screen. Gas is being used. Please arrange a site visit to replace the meter. ' + this.formData.additionalInfo;
            break;
        case 'DUM4':
            message = this.formData.additionalInfo
            break;
        case 'LBC':
            message = '' + this.formData.additionalInfo;
            break;
        case 'CROS':
            message = '' + this.formData.additionalInfo;
            break; 
        case 'CXPC':
            message = '' + this.formData.additionalInfo;
            break;  
        default:
            break;
       }
    return message;
    }

}