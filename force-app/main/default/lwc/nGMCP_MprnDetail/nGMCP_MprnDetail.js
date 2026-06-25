import { LightningElement, track, api, wire } from "lwc";
import getMetaData from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.getMeterModelSizeandcatagory";
import addressUpdate from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.addressUpdateAPI";
import sendAddressUpdateEmail from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.sendAddressUpdateEmail";
import insertAddress from "@salesforce/apex/NGMCP_RequestObjectClass.createAddressUpdateRecord";
import addressErrormessage from "@salesforce/label/c.NGMCP_AddressErrormessage";
import getWorkOrderId from "@salesforce/apex/NGMCP_RequestSearchController.getWorkOrderId";
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import getUserSupplierCodeOptions from "@salesforce/apex/NGMCP_UserDependentPicklistController.getUserSupplierCodeOptions";
const USER_FIELDS = ['User.Name', 'User.Email', 'User.Profile.Name'];
import NGMCP_CRMProfileslabel from '@salesforce/label/c.NGMCP_CRMProfiles';
import NGMCP_MPRN_Deatils_Error_Message from '@salesforce/label/c.NGMCP_MPRN_Deatils_Error_Message';
import NGMCP_NO_Meter_Error_Message from '@salesforce/label/c.NGMCP_NO_Meter_Error_Message';
import baseCommunity from '@salesforce/community/basePath';
export default class NGMCP_MprnDetail extends LightningElement {
  @track isEditing = false;
  @track selectedTab = "Overview";
  @track assetDetails = [];
  // Add near your other @track fields
  @track converterDetails = [];   // <-- lower camel to match template binding
  @track converterSerialNo = '';  // <-- lower camel to match template binding
  @track conversionMeter = [];
  @track isCreateJobVisible = false;
  @track paymentMechanism;
  @api pressuretierBrand;
  @track postCode;
  @track mprn;
  @track showViewRequest;
  @track isLogger = false;
  @track options;
  @track shortCodes;
  @track mprnErrorMessage = NGMCP_MPRN_Deatils_Error_Message;
  @track noAssetdetailsErrorMessage = NGMCP_NO_Meter_Error_Message;
  userId = USER_ID;
  email;
  profileName;
  tempAddress;
  @track filters = {
    mprn: null,
    sr: null,
    createdFrom: null,
    createdTo: null,
    shortCode: null,
  };
  @track woFilters = {
    mprn: null,
    wo: null,
    createdFrom: null,
    createdTo: null,
    shortCode: null,
  };
  @track workOrderrequestFlag = false;
  @track recordtype;
  @track address = {
    buildingNumber: " ",
    buildingName: " ",
    street: " ",
    dependentLocality: " ",
    postalTown: " ",
    postCode: " ",
  };
  @track metaDataWrapper = [];

  categoryMap = {
    U6D: "Residential",
    "Non U6D": "Commercial",
    U6I: "Commercial",
    "Non U6I": "Commercial",
  };

  // store raw decoded data
  _decodedData;

  // fields
  msn;
  tempBuildingNumber;

  tempBuildingName;
  tempStreet;
  tempDependentLocality;
  tempPostalTown;
  tempPostCode;
  status;
  metadataCache = {};
  assetnum;
  customerDetails;
  ConverterDetails = [];
  siteDetails = [];
  meterDetails = [];
  @track isLoading = false;
  @track showSuccessMessage = false;
  @track messageText = "";
  @track showSiteDetails = false;
  @track showConverterDetails = false;
  @track showAllAsset = false;
  @track errorMessage = false; // BUG: 172765
  @api requestSource;
  @track renderthecomponent = false;
  @wire(getRecord, { recordId: '$userId', fields: USER_FIELDS })
  userRecord({ error, data }) {
    if (data) {
      this.email = data.fields.Email.value;
      this.user = data.fields;
      this.profileName = data.fields.Profile.value.fields.Name.value;
      if (
        !this.meterDetails[0] &&
        this.profileName !== NGMCP_CRMProfileslabel
      ) {
        sessionStorage.setItem(
          'mprnSearchState',
          JSON.stringify({
            mprn: this.customerDetails.MPRN,
            supplier: this.customerDetails.Customer,
            errorMessage: this.noAssetdetailsErrorMessage
          })
        );

        window.location.replace(baseCommunity);
        return;
      } else {
        this.renderthecomponent = true;
      }
    }
  }
  @wire(getUserSupplierCodeOptions)
  wiredOptions({ data, error }) {
    if (data) {
      this.options = data.map(o => ({ label: o.label, value: o.value }));
      this.shortCodes = [...new Set(this.options.map(o => o.value))];
    } else if (error) {
      this.options = [];
    }
  }
  @api
  set decodedData(value) {
    this._decodedData = value;
    try {
      let actualData =
        Array.isArray(value) && value.length > 0 && typeof value[0] === "object"
          ? value[0]
          : value;

      if (!actualData || typeof actualData !== "object") {
        return;
      }

      // Extract customer-level details
      this.customerDetails = {
        MPRN: actualData.MPRN,
        Customer: actualData.Customer,
        Address: actualData.Address,
        AppointmentFromDate: actualData.AppointmentFromDate,
        MprnCustomer: actualData.MprnCustomer,
        MarketselectorCode: actualData.MarketselectorCode,
        buildingNumber: actualData.buildingNumber,
        buildingName: actualData.buildingName,
        street: actualData.street,
        dependentLocality: actualData.dependentLocality,
        postalTown: actualData.postalTown,
        postCode: actualData.postCode,
        location: actualData.location,
        conversionFactor: actualData.conversionFactor,
        locationsId: actualData.locationsId,
        amrtag: actualData.amrtag,
        microbusiness: actualData.microbusiness,
        siteid: actualData.siteid,
        appointmentDate: actualData.appointmentDate,
        pressureTier: actualData.pressureTier,
        presureBrand: actualData.presureBrand,
        hasZ002: actualData.hasZ002,
        appointmentFlag: actualData.appointmentFlag,
        amrflag: actualData.amrflag,
        paldflag: actualData.paldflag,
        paldCustomer: actualData.paldCustomer,
        paldEndDate: actualData.paldEndDate,
      };
      this.address = {
        buildingNumber: actualData.buildingNumber || " ",
        buildingName: actualData.buildingName || " ",
        street: actualData.street || " ",
        dependentLocality: actualData.dependentLocality || " ",
        postalTown: actualData.postalTown || " ",
        postCode: actualData.postCode || " ",
      };
      this.mprn = actualData.MPRN;
      this.postCode = this.customerDetails.postCode;
      this.postCode = this.customerDetails.postCode;

      // Separate assets by MeterType
      const allAssets = actualData.Assets || [];
      this.meterDetails = allAssets.filter(
        (asset) => asset.MeterType === "Z001"
      );
      this.conversionMeter = allAssets.filter(
        (asset) => asset.MeterType === "Z002"
      );
      // Fetch metadata based on available asset type
      const key =
        this.meterDetails.length > 0
          ? this.meterDetails[0].residential_commercialKey
          : this.conversionMeter.length > 0
            ? this.conversionMeter[0].residential_commercialKey
            : null;

      if (key) {
        this.fetchMetadata(key);
        this.errorMessage = null;
      } else {
        this.status = this.customerDetails.MarketselectorCode == "D" ? "Residential" : "Commerical";
      }
      this.assetnum =
        this.meterDetails.length > 0
          ? this.meterDetails[0].assetnum
          : this.conversionMeter.length > 0
            ? this.conversionMeter[0].assetnum
            : null;
      this.msn =
        this.meterDetails.length > 0
          ? this.meterDetails[0].serialNo
          : this.conversionMeter.length > 0
            ? this.conversionMeter[0].serialNo
            : null;
    } catch (error) {
      this.errorMessage = `Error decoding data: ${error.message}`;
    }
  }

  connectedCallback() {
    document.title = "Home | National Gas Metering";
  }

  _applied = false;

  renderedCallback() {
    if (!this._applied) {
      this._applied = true;
      Promise.resolve().then(() => {
        document.title = "Home | National Gas Metering";
      });
      setTimeout(() => {
        document.title = "Home | National Gas Metering";
      }, 0);
    }

  }

  get decodedData() {
    return this._decodedData;
  }

  formatDate(dateStr) {
    if (!dateStr) return "—";
    try {
      const date = new Date(dateStr);
      const day = String(date.getDate()).padStart(2, "0");
      const month = String(date.getMonth() + 1).padStart(2, "0");
      const year = date.getFullYear();
      return `${day}-${month}-${year}`;
    } catch {
      return "—";
    }
  }

  handleInputChange(event) {
    const field = event.target.dataset.field;
    let value = field !== 'postal' ? (event.target.value ?? '').trim() : (event.target.value ?? '');

    // Uppercase postcode only
    if (field === 'postal') {
      value = value.toUpperCase();
      event.target.value = value;
    }

    switch (field) {
      case 'building':
        this.tempBuildingNumber = value;
        break;
      case 'buildingName':
        this.tempBuildingName = value;
        break;
      case 'street':
        this.tempStreet = value;
        break;
      case 'dependent':
        this.tempDependentLocality = value;
        break;
      case 'town':
        this.tempPostalTown = value;
        break;
      case 'postal':
        // validate only after reasonable length
        if (value.length >= 5 && !this.isValidUKPostcode(value)) {
          this.showInlineError(
            'postal',
            'Enter a valid UK Post Code (e.g. EC1A 1BB)'
          );
        } else {
          this.clearFieldError('postal');
        }
        this.tempPostCode = value.trim();
        break;

      default:
        break;
    }

    // Clear error for non‑postal fields
    if (field !== 'postal') {
      this.clearFieldError(field);
    }
  }
  handleEdit = () => {
    this.isEditing = !this.isEditing;
    if (this.isEditing) {
      // Deep copy ALL fields from customerDetails into a temp object
      this.tempAddress = JSON.parse(JSON.stringify(this.customerDetails));
    } else {
      // Leaving edit mode → discard temp
      this.tempAddress = null;
    }

  };
  // Returns the input using your existing data-field attributes
  getInput(field) {
    return this.template.querySelector(`input[data-field="${field}"]`);
  }

  // Removes all inline error <span>s and clears error styling
  clearAllInlineErrors() {
    // 1) remove message spans
    this.template.querySelectorAll('.form-field .error-msg').forEach((el) => el.remove());
    // 2) remove error class from form-field and input
    this.template.querySelectorAll('.form-field').forEach((ff) => ff.classList.remove('has-error'));
    this.template.querySelectorAll('input[data-field]').forEach((inp) => inp.classList.remove('input-error'));
  }

  // Creates/updates an inline error <span> just below the input
  showInlineError(field, message) {
    const input = this.getInput(field);
    if (!input) return;

    // Add red border
    input.classList.add('input-error');

    // Add error class to the container
    const formField = input.closest('.custom-input-element-section') || input.parentElement;
    if (formField) {
      formField.classList.add('has-error');

      // Remove any existing error message for this field
      const existing = formField.querySelector('.error-msg');
      if (existing) existing.remove();

      // Create new message below the input
      if (message) {
        const span = document.createElement('span');
        span.className = 'error-msg';
        span.textContent = message;
        formField.appendChild(span);
      }
    }
  }

  // Clears the inline error just for a single field (call from oninput)
  clearFieldError(field) {
    // Helper: clear message + styles for a single data-field
    const clearOne = (dataField) => {
      const el = this.template.querySelector(`input[data-field="${dataField}"]`);
      if (!el) return;
      el.classList.remove('input-error');

      const formField = el.closest('.form-field') || el.parentElement;
      if (!formField) return;

      formField.classList.remove('has-error');
      const existing = formField.querySelector('.error-msg');
      if (existing) existing.remove();
    };

    // Special handling for the conditional pair: building OR buildingName
    if (field === 'building' || field === 'buildingName') {
      const bInput = this.template.querySelector('input[data-field="building"]');
      const bnInput = this.template.querySelector('input[data-field="buildingName"]');

      const hasAny =
        ((bInput?.value ?? '').trim().length > 0) ||
        ((bnInput?.value ?? '').trim().length > 0);

      // If either has value, clear BOTH error messages and red borders
      if (hasAny) {
        clearOne('building');
        clearOne('buildingName');
      }
      // If neither has value, keep the errors visible (do nothing)
      return;
    }

    // Default: for non-conditional fields, clear only if it now has a value
    const input = this.template.querySelector(`input[data-field="${field}"]`);
    if (!input) return;

    const hasValue = ((input.value ?? '').trim().length > 0);
    if (hasValue) {
      clearOne(field);
    }
  }
  isValidUKPostcode(postcode) {
    if (!postcode) return false;

    const regex =
      /^(?:[A-Z]{1,2}[0-9][0-9A-Z]?|[A-Z][0-9][A-Z]) [0-9][A-Z]{2}$/;

    return regex.test(postcode.trim());
  }

  async handleSave() {
    this.isEditing = false;
    this.isLoading = true;

    const draft = {
      buildingNumber: this.tempBuildingNumber ?? this.customerDetails.buildingNumber,
      buildingName: this.tempBuildingName ?? this.customerDetails.buildingName,
      street: this.tempStreet ?? this.customerDetails.street,
      dependentLocality: this.tempDependentLocality ?? this.customerDetails.dependentLocality, // optional
      postalTown: this.tempPostalTown ?? this.customerDetails.postalTown,
      postCode: this.tempPostCode ?? this.customerDetails.postCode
    };
    Object.keys(draft).forEach(k => draft[k] = (draft[k] ?? '').trim());
    this.clearAllInlineErrors();
    let hasError = false;

    // Conditional mandatory: Building Number OR Building Name
    if (!draft.buildingNumber && !draft.buildingName) {
      this.customerDetails.buildingNumber = "";
      this.customerDetails.buildingName = "";
      this.showInlineError('building', 'Enter Building Number or Building Name');
      this.showInlineError('buildingName', 'Enter Building Number or Building Name');
      hasError = true;
    }


    const nullifyTempByDataField = {
      street: () => { this.customerDetails.street = ''; },
      town: () => { this.customerDetails.postalTown = ''; },
      postal: () => { this.customerDetails.postCode = ''; }
    };

    [
      { field: 'street', data: 'street', message: 'This field is mandatory' },
      { field: 'postalTown', data: 'town', message: 'This field is mandatory' },
      { field: 'postCode', data: 'postal', message: 'This field is mandatory' }
    ].forEach(r => {
      const val = (draft[r.field] ?? '').trim();
      if (!val) {
        // make ONLY the corresponding temp field empty
        nullifyTempByDataField[r.data]?.();

        // show inline error under the corresponding input
        this.showInlineError(r.data, r.message);

        hasError = true;
      }
    });

    if (hasError) {
      // stay in edit mode; do not proceed to uppercase/API
      this.customerDetails.buildingNumber = draft.buildingNumber ?? "";
      this.customerDetails.buildingName = draft.buildingName ?? "";
      this.customerDetails.street = draft.street ?? "";
      this.customerDetails.postalTown = draft.postalTown ?? "";
      this.customerDetails.postCode = draft.postCode ?? "";
      this.customerDetails.dependentLocality = draft.dependentLocality ?? "";
      this.isEditing = true;
      this.isLoading = false;
      return;
    }

    if (draft.postCode && !this.isValidUKPostcode(draft.postCode)) {
      this.showInlineError(
        'postal',
        'Enter a valid UK Post Code (e.g. EC1A 1BB).'
      );
      hasError = true;
    }
    if (hasError) {
      // stay in edit mode; do not proceed to uppercase/API
      this.customerDetails.buildingNumber = draft.buildingNumber ?? "";
      this.customerDetails.buildingName = draft.buildingName ?? "";
      this.customerDetails.street = draft.street ?? "";
      this.customerDetails.postalTown = draft.postalTown ?? "";
      this.customerDetails.postCode = draft.postCode ?? "";
      this.customerDetails.dependentLocality = draft.dependentLocality ?? "";
      this.isEditing = true;
      this.isLoading = false;
      return;
    }
    this.tempBuildingNumber = (
      this.tempBuildingNumber ?? this.customerDetails.buildingNumber
    )?.toUpperCase();
    this.tempBuildingName = (
      this.tempBuildingName ?? this.customerDetails.buildingName
    )?.toUpperCase();
    this.tempStreet = (
      this.tempStreet ?? this.customerDetails.street
    )?.toUpperCase();
    this.tempDependentLocality = (
      this.tempDependentLocality ?? this.customerDetails.dependentLocality
    )?.toUpperCase();
    this.tempPostalTown = (
      this.tempPostalTown ?? this.customerDetails.postalTown
    )?.toUpperCase();
    this.tempPostCode = (
      this.tempPostCode ?? this.customerDetails.postCode
    )?.toUpperCase();
    const serialNum = this.msn || "";
    // Prepare request body
    const requestBody = {
      ngme_c_st: this.tempPostalTown,
      ngme_s_st: this.tempPostalTown,
      ngme_c_prncpstreet: this.tempStreet,
      ngme_s_prncpstreet: this.tempStreet,
      ngme_c_depndlocality: this.tempDependentLocality,
      ngme_s_depndlocality: this.tempDependentLocality,
      ngme_c_spc: this.tempPostCode,
      ngme_s_spc: this.tempPostCode,
      siteid: this.customerDetails.siteid,
      location: this.customerDetails.MPRN,
      ngme_suppname: this.customerDetails.Customer,
      locationsid: this.customerDetails.locationsId,
      ngme_c_sitebn: this.tempBuildingNumber,
      ngme_s_sitebn: this.tempBuildingNumber,
      ngme_c_bldngname: this.tempBuildingName,
      ngme_s_bldngname: this.tempBuildingName,
      ngme_addramendportal: 1,
      asset: [
        {
          serialnum: serialNum,
          assetnum: this.assetnum,
        },
      ],
    };
    // try {
    //   const insertrecord = await insertAddress({
    //     requestBody: JSON.stringify(requestBody),
    //     locationId: this.customerDetails.locationsId,
    //   });
    //   console.log("insertrecord:", insertrecord);
    //   console.log("requestBody:", JSON.stringify(requestBody));
    //   if (insertrecord) {
    //     const result = await addressUpdate({
    //       requestBody: JSON.stringify(requestBody),
    //       locationId: this.customerDetails.locationsId,
    //       adreesRequestId: insertrecord,
    //     });
    //     if (result) {
    //       this.customerDetails.buildingNumber = this.tempBuildingNumber;
    //       this.customerDetails.buildingName = this.tempBuildingName;
    //       this.customerDetails.street = this.tempStreet;
    //       this.customerDetails.dependentLocality = this.tempDependentLocality;
    //       this.customerDetails.postalTown = this.tempPostalTown;
    //       this.customerDetails.postCode = this.tempPostCode;
    //       this.isLoading = false;
    //       this.messageText = result;
    //       this.showSuccessMessage = true;
    //       // Hide after 3 seconds
    //       setTimeout(() => {
    //         this.showSuccessMessage = false;
    //       }, 3000);
    //     }

    //     console.log("Result from Apex:", result);
    //   }
    // } catch (error) {
    //   console.error("Error saving address:", error);
    //   this.messageText = addressErrormessage;
    //   this.errorMessage = true; // BUG: 172765
    //   // Hide after 3 seconds
    //   setTimeout(() => {
    //     this.errorMessage = false;
    //   }, 3000);
    // } finally {
    //   this.isLoading = false;
    // }
    //     try {

    //     console.log('Calling insertAddress...');

    //     const insertrecord = await insertAddress({

    //         requestBody: JSON.stringify(requestBody),

    //         locationId: this.customerDetails.locationsId,

    //     });

    //     console.log('Insert Response:', insertrecord);

    //     if (insertrecord) {

    //         console.log('Calling addressUpdate...');

    //         const result = await addressUpdate({

    //             requestBody: JSON.stringify(requestBody),

    //             locationId: this.customerDetails.locationsId,

    //             adreesRequestId: insertrecord,

    //         });

    //         console.log('Update Response:', result);

    //         if (result) {

    //             //  CALL EMAIL FROM LWC

    //             console.log('Calling addressUpdate...');

    //             await sendAddressUpdateEmail({
    //                   mprn: this.customerDetails.MPRN,
    //                   srNumber: this.customerDetails.SRNumber, // null if not available
    //                   jobCode: this.customerDetails.JobCode
    //             });

    //             console.log('Email method completed.');

    //             // Update UI

    //             this.customerDetails.buildingNumber = this.tempBuildingNumber;

    //             this.customerDetails.buildingName = this.tempBuildingName;

    //             this.customerDetails.street = this.tempStreet;

    //             this.customerDetails.dependentLocality = this.tempDependentLocality;

    //             this.customerDetails.postalTown = this.tempPostalTown;

    //             this.customerDetails.postCode = this.tempPostCode;

    //             this.messageText = result;

    //             this.showSuccessMessage = true;

    //             setTimeout(() => {

    //                 this.showSuccessMessage = false;

    //             }, 3000);

    //         }

    //     }

    // } catch (error) {

    //     console.error('Full Error:', JSON.stringify(error));

    //     this.messageText = error?.body?.message || 'Something went wrong';

    //     this.errorMessage = true;

    //     setTimeout(() => {

    //         this.errorMessage = false;

    //     }, 3000);

    // } finally {

    //     this.isLoading = false;

    // }

    try {
      const insertrecord = await insertAddress({

        requestBody: JSON.stringify(requestBody),

        locationId: this.customerDetails.locationsId,

      });
      if (!insertrecord) {
        throw new Error('Insert Address failed.');
      }
      const result = await addressUpdate({

        requestBody: JSON.stringify(requestBody),

        locationId: this.customerDetails.locationsId,

        adreesRequestId: insertrecord,

      });
      if (!result) {

        throw new Error('Address update failed.');

      }
      try {
        await sendAddressUpdateEmail({

          mprn: this.customerDetails.MPRN,

          srNumber: this.customerDetails.SRNumber, // pass null if not available

          jobCode: this.customerDetails.JobCode

        });
      } catch (emailError) {
        console.error('Email failed but save succeeded:', emailError);

      }
      this.customerDetails.buildingNumber = this.tempBuildingNumber;

      this.customerDetails.buildingName = this.tempBuildingName;

      this.customerDetails.street = this.tempStreet;

      this.customerDetails.dependentLocality = this.tempDependentLocality;

      this.customerDetails.postalTown = this.tempPostalTown;

      this.customerDetails.postCode = this.tempPostCode;

      this.messageText = result;

      this.showSuccessMessage = true;

      setTimeout(() => {

        this.showSuccessMessage = false;

      }, 3000);

    } catch (error) {

      this.messageText =

        error?.body?.message ||

        error?.message ||

        'Something went wrong while saving.';

      this.errorMessage = true;

      setTimeout(() => {

        this.errorMessage = false;

      }, 3000);

    } finally {

      this.isLoading = false;

    }

  }
  handleCancel() {
    this.isEditing = false;
    this.customerDetails.buildingNumber = this.tempAddress.buildingNumber;
    this.customerDetails.buildingName = this.tempAddress.buildingName;
    this.customerDetails.street = this.tempAddress.street;
    this.customerDetails.dependentLocality = this.tempAddress.dependentLocality;
    this.customerDetails.postalTown = this.tempAddress.postalTown;
    this.customerDetails.postCode = this.tempAddress.postCode;
    this.tempPostCode = "";
    this.tempPostalTown = "";
    this.tempDependentLocality = "";
    this.tempStreet = "";
    this.tempBuildingName = "";
    this.tempBuildingNumber = "";
  }

  getRowClass(index) {
    return index === this.assetDetails.length - 1 ? "row" : "row with-border";
  }

  // Tab Selection
  get isOverview() {
    return this.selectedTab === "Overview";
  }
  get overviewClass() {
    return this.selectedTab === "Overview"
      ? "tab active slds-p-vertical_small slds-p-horizontal_large"
      : "tab slds-p-vertical_small slds-p-horizontal_large";
  }
  get requestLogClass() {
    return this.selectedTab === "Request"
      ? "tab active slds-p-vertical_small slds-p-horizontal_large"
      : "tab slds-p-vertical_small slds-p-horizontal_large";
  }
  get workOrderLogClass() {
    return this.selectedTab === "WorkOrder"
      ? "tab active slds-p-vertical_small slds-p-horizontal_large"
      : "tab slds-p-vertical_small slds-p-horizontal_large";
  }
  get amrClass() {
    return this.selectedTab === "AMR"
      ? "tab active slds-p-vertical_small slds-p-horizontal_large"
      : "tab slds-p-vertical_small slds-p-horizontal_large";
  }
  selectRequestLog() {
    this.selectedTab = "Request";
    const isCRMProfile = this.profileName === NGMCP_CRMProfileslabel;
    this.isLogger = true;
    this.showViewRequest = true;
    this.filters = {
      ...this.filters,
      mprn: this.customerDetails?.MPRN,
      shortCode: isCRMProfile
        ? this.shortCodes.join(',')
        : this.customerDetails?.Customer ?? null,
    };
  }
  async selectWorkOrderLog() {
    const isCRMProfile = this.profileName === NGMCP_CRMProfileslabel;
    this.selectedTab = "WorkOrder";
    this.isLogger = true;
    this.showViewRequest = false;
    this.workOrderrequestFlag = true;
    this.woFilters = {
      ...this.woFilters,
      mprn: this.customerDetails.MPRN,
      shortCode: isCRMProfile
        ? this.shortCodes.join(',')
        : this.customerDetails?.Customer ?? null,
    };
  }
  selectOverview = () => (this.selectedTab = "Overview");
  // selectRequestLog = () => (this.selectedTab = "Request");
  // selectWorkOrderLog = () => (this.selectedTab = "WorkOrder");
  selectAMR = () => (this.selectedTab = "AMR");

  async fetchMetadata(modelValue) {
    if (this.metadataCache[modelValue]) {
      this.status = this.metadataCache[modelValue];
      await this.buildAssetDetails();
      await this.buildConverterDetails();
      await this.buidsiteDetails();
      return;
    }

    try {
      const result = await getMetaData({ meterModel: modelValue });
      const category = this.getCategory(result);
      this.metadataCache[modelValue] = category;
      this.status = category;
      // Ensure result is always treated as an array
      const metadataList = Array.isArray(result) ? result : [result];
      const industry = category === "Residential" ? "D" : "I";
      // Combine metadata with additional fields
      const urgentworkRequestInput = {
        metadatalist: metadataList,
        assetnum: this.assetnum,
        location: this.customerDetails.MPRN,
        suppliercode: this.customerDetails.Customer,
        ngme_industry: industry,
      };

      this.metaDataWrapper.push(urgentworkRequestInput);
    } catch (error) {
      this.status = this.customerDetails.MarketselectorCode == "D" ? "Residential" : "Commerical";
    } finally {
      await this.buildAssetDetails();
      await this.buildConverterDetails();
      await this.buidsiteDetails();
    }
  }

  getCategory(metadata) {
    const key =
      metadata.NGMCP_Meter_Model_Size__c + metadata.NGMCP_Market_Sector_Code__c;
    return this.categoryMap.hasOwnProperty(key)
      ? this.categoryMap[key]
      : "Key not found";
  }
  buildConverterDetails() {
    const asset = this.conversionMeter?.[0];
    if (asset) {
      // 1) Panel array (kept as-is to avoid any UI change)
      this.ConverterDetails = [
        { label: "Manufacturer", value: asset.manufacturerFullName || " ", maskKey: true },
        { label: "Model", value: asset.Model || " ", maskKey: true },
        { label: "Manufacturer Serial no.", value: asset.serialNo || " ", maskKey: true },
        { label: "No. of Dials", value: asset.noofdial ?? " ", maskKey: true },
      ];
      this.showConverterDetails = this.ConverterDetails.length > 0;

      // 2) Lower-case values that you PASS to CreateJobRequest/EnquiryDetails
      this.converterSerialNo = (asset.serialNo || '').toString().trim();
      this.converterDetails = [
        { label: "Manufacturer", value: asset.manufacturerFullName || " ", maskKey: true },
        { label: "Model", value: asset.Model || " ", maskKey: true },
        { label: "Manufacturer Serial no.", value: this.converterSerialNo || " ", maskKey: true },
        { label: "No. of Dials", value: asset.noofdial ?? " ", maskKey: true },
      ];
      this.converterDetails = (this.converterDetails || []).map(item => ({
        ...item,
        shouldMask: this.shouldMaskData && item.maskKey
      }));
      this.ConverterDetails = (this.ConverterDetails || []).map(item => ({
        ...item,
        shouldMask: this.shouldMaskData && item.maskKey
      }));
      //console.log('this.ConverterDetails', JSON.stringify(this.ConverterDetails));
    } else {
      this.ConverterDetails = [];
      this.converterDetails = [];   // also clear the lower-case pass-through
      this.converterSerialNo = '';
      this.showConverterDetails = false;
    }
  }
  buidsiteDetails() {
    this.siteDetails = [
      { label: "Pressure Tier", value: this.customerDetails.pressureTier },
      {
        label: "Conversion Factor",
        value: this.customerDetails.conversionFactor,
      },
      {
        label: "Appointment Date",
        value: this.formatDate(this.customerDetails.appointmentDate),
      },
      {
        label: "Micro Business ?",
        value: this.customerDetails.microbusiness,
      },
      {
        label: "AMR Installed?",
        value: this.customerDetails.amrflag,
      },
    ];
    this.showSiteDetails = this.siteDetails.length > 0 && this.customerDetails.appointmentFlag;
  }

  buildAssetDetails() {
    if (this.meterDetails?.length > 0) {
      const asset = this.meterDetails[0]; // or loop if you want to show all
      this.assetDetails = [
        { label: "Manufacturer", value: asset.manufacturerFullName, maskKey: false },
        { label: "Model", value: asset.Model, maskKey: false },
        { label: "Manufacturer Serial no.", value: asset.serialNo, maskKey: false },
        { label: "Meter Type", value: asset.meterTypeDesc ?? asset.pulsMeterType, maskKey: true },
        { label: "Payment Mechanism", value: asset.paymentMechanism, maskKey: true },
        { label: "No. of Dials", value: asset.noofdial, maskKey: true },
        { label: "Year of Manufacture", value: asset.yearofmanufacture, maskKey: true },
        { label: "Location", value: this.customerDetails.location || "", maskKey: true },
        { label: "Install Date", value: this.formatDate(asset.InstallDate), maskKey: true },
        { label: "Measuring Capacity", value: asset.measuringCapacity, maskKey: true }
      ];
      this.paymentMechanism = asset.paymentMechanism;
    }
  }

  handleCreateJobClick(event) {
    const requestSource = event.currentTarget.dataset.request;
    this.selectedCreateRequestType = requestSource;
    this.isCreateJobVisible = true;
  }


  handleCancelJob() {
    this.isCreateJobVisible = false;
  }

  get assetArray() {
    return Array.isArray(this.assetDetails)
      ? this.assetDetails.map(item => ({
        ...item,
        shouldMask: this.shouldMaskData && item.maskKey
      }))
      : [];
  }

  get displayedAssetDetails() {
    return this.showAllAsset ? this.assetArray : this.assetArray.slice(0, 5);
  }

  get hasMoreAssetDetails() {
    return this.assetArray.length > 5;
  }

  get assetArrowClass() {
    return this.showAllAsset ? "arrow down" : "arrow right";
  }

  get assetToggleText() {
    return this.showAllAsset ? "Less details" : "More details";
  }

  toggleAssetExpand() {
    this.showAllAsset = !this.showAllAsset;
  }
  get technicalQueryHide() {
    return this.customerDetails.appointmentFlag && this.status !== 'Residential'
  }
  get isDeappointAllowed() {
    const d = this.customerDetails;
    return (d.paldflag
      ? (
        d.Customer === d.paldCustomer &&
        new Date(d.paldEndDate) >= new Date()
      )
        ? false : d.appointmentFlag
      : d.appointmentFlag);

  }
  get hasDisplayedAssetDetails() {
    return this.displayedAssetDetails && Object.keys(this.displayedAssetDetails).length > 0;
  }

  get shouldMaskData() {
    return !this.isDeappointAllowed && !this.paldCustomerFlag && this.profileName !== NGMCP_CRMProfileslabel;
  }
  get isHideEditButtonForNonCRM() {
    this.profileName !== NGMCP_CRMProfileslabel
  }
  get paldCustomerFlag() {
    const d = this.customerDetails;
    return (d.paldflag
      ? (
        d.Customer === d.paldCustomer &&
        new Date(d.paldEndDate) >= new Date()
      ) : false);
  }
}