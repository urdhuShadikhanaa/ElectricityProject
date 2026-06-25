import { LightningElement, track, api, wire } from "lwc";
import ngAssets from "@salesforce/resourceUrl/NGMCP_SearchMPRN";
import callAssetDetailsAPI from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.callAssetDetailsAPI";
import callSerialNumberAssetDetailsAPI from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.callSerialNumberAssetDetailsAPI";
import callPostalNumberAssetDetailsAPI from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.callpostalAssetDetailsAPI";
import getWorkOrderId from "@salesforce/apex/NGMCP_RequestSearchController.getWorkOrderId";
import { NavigationMixin } from "lightning/navigation";
import dualMprn from '@salesforce/label/c.NGMCP_DualMPRN';
import errorMessage from '@salesforce/label/c.NGMCP_ErrorMesasge';
import NGMCP_Cannot_end_with_space from '@salesforce/label/c.NGMCP_Cannot_end_with_space';
import NGMCP_Cannot_start_with_space from '@salesforce/label/c.NGMCP_Cannot_start_with_space';
import NGMCP_custom_Error_Message_for_Post_MPRN from '@salesforce/label/c.NGMCP_custom_Error_Message_for_Post_MPRN';
import NGMCP_Cannot_start_with_0 from '@salesforce/label/c.NGMCP_Cannot_start_with_0';
import NGMCP_Only_numbers from '@salesforce/label/c.NGMCP_Only_numbers';
import NGMCP_Maximum_length_10 from '@salesforce/label/c.NGMCP_Maximum_length_10';
import getUserSupplierCodeOptions from '@salesforce/apex/NGMCP_UserDependentPicklistController.getUserSupplierCodeOptions';
export default class TabComponent extends NavigationMixin(LightningElement) {
  @track NGMCP_mprn = "";
  @track NGMCP_errorMessage = "";
  @track activeTab = "1";
  @track NGMCPMPRNDetails;
  @track isMPRNBtnVisible = false;
  @track isPCBtnVisible = true;
  @track isSRNumberBtnVisible = true;
  @track isMPRNVisible = true;
  @track isPostCodeVisible = false;
  @track isSNumberVisible = false;
  @track selectedRecordId = null;
  @track recordTypeName = null;
  @track woRecordId = null;
  @api filteredRecords = [];
  @track waitingMessage = false;
  @track showViewRequest = false;
  @track postalFlag = false;
  @track serailNumberFlag = false;
  @track mprnFlag = false;
  @track serialandpostcodebypass = false;
  @track validCustomersList = [];
  @track filters = {
    mprn: null,
    sr: null,
    createdFrom: null,
    createdTo: null,
    shortCode: null
  };

  searchTimeout;
  @track srNumber = '';
  @track woNumber = '';
  @track options = [];
  @track message = "Retrieving MPRN details may take a few moments. Please wait for the results to appear after search."
  homepageAssets = ngAssets;
  mprn;
  NGMCP_postcode = "";
  NGMCP_serialNumber = "";
  NGMCP_selectedCode = "";
  serialNumber;
  selectedShortCode;
  postalcodevalue;
  isvisiableConfirmButton = true;
  isDisabled = true;
  isVisiableFooterMessage = true;
  isMprnSelection = true;
  isPostCodeSelection = false;
  isSerialNumberSelection = false;
  isSearchDisabled = true;
  headerLabel = dualMprn;
  @track spinnerMessage = 'Fetching details, Please wait...';
  @track sessionData;
  //postalcodecontainerHeading;

  @track isLoading = false;
  @track isModalOpen = false;
  @wire(getUserSupplierCodeOptions)
  wiredOptions({ data, error }) {
    console.log('wire options', data, error);
    this.isLoading = false;
    if (data) {
      this.options = data.map(o => ({ value: o.value, label: o.label }));
      // this.options.sort();
      this.errorMessage = '';
    } else if (error) {
      this.options = [];
      this.errorMessage = this.normalizeError(error);
    }
    console.log(' options', this.options);
  }
  get isTab1() {
    return this.activeTab === "1";
  }

  get isTab2() {
    return this.activeTab === "2";
  }

  get isTab3() {
    return this.activeTab === "3";
  }

  get tabClass1() {
    return this.activeTab === "1"
      ? "tab slds-p-vertical_small active"
      : "tab slds-p-vertical_small";
  }

  get tabClass2() {
    return this.activeTab === "2"
      ? "tab slds-p-vertical_small active"
      : "tab slds-p-vertical_small";
  }

  get tabClass3() {
    return this.activeTab === "3"
      ? "tab slds-p-vertical_small active"
      : "tab slds-p-vertical_small";
  }
  _restored = false;
  connectedCallback() {
    this.sessionData = sessionStorage.getItem('mprnSearchState');
    console.log('savedState', JSON.stringify(this.sessionData));
    if (this.sessionData/* && !this._restored*/) {
      // this._restored = true;
      const { mprn, supplier, errorMessage } = JSON.parse(this.sessionData);
      this.NGMCP_mprn = mprn;
      this.mprn = mprn;
      this.supplierCode = supplier;
      this.NGMCP_errorMessage = errorMessage;
      setTimeout(() => {
        this.NGMCP_errorMessage = '';
      }, 15000);
      this.isSearchDisabled = false;
      sessionStorage.removeItem('mprnSearchState');
    }
  }
  renderedCallback() {
    if (this.sessionData) {
      console.log('option data', this.options);
      const selectEl = this.template.querySelector('select[name="shortcodes"]');

      console.log('by name:', selectEl);
      if (selectEl && this.supplierCode && Array.isArray(this.options) && this.options.length > 0) {
        const hasOption = Array.from(selectEl.options).some(
          opt => opt.value === this.supplierCode
        );

        if (hasOption) {
          selectEl.value = this.supplierCode;
          selectEl.dispatchEvent(new Event('change'));
        }
      }
    }
  }

  handleTabClick(event) {
    this.activeTab = event.currentTarget.dataset.tab;
    console.log("Active tab:", this.activeTab);

  }
  NGMCP_handlemprnChanges(event) {
    console.log("MPRN updated:", this.NGMCP_mprn);
    const inputValue = event.target.value;
    console.log("Input value:", inputValue);
    this.NGMCP_mprn = event.target.value;
    const isValid = this.validateMPRN();
    if (this.NGMCP_errorMessage == "") {
      this.isSearchDisabled = false;
    } else {
      this.isSearchDisabled = true;
    }
    if (isValid) {
      this.mprn = inputValue;
      console.log("MPRN updated:", this.mprn);
    } else {
      console.warn("Invalid MPRN:", inputValue);
    }
  }
  NGMCP_handlepostalcodeChanges(event) {
    this.NGMCP_postcode = event.target.value;
    console.log("Post code updated:", this.NGMCP_postcode);
    this.isSearchDisabled = false;
    if (this.NGMCP_postcode == "") {
      this.isSearchDisabled = true;
    } else {
      this.isSearchDisabled = false;
    }
    if (this.NGMCP_postcode.length == 0) {
      this.NGMCP_errorMessage = "Please enter Post code";
    } else {
      this.NGMCP_errorMessage = "";
    }
  }

  NGMCP_handleserialnmberChanges(event) {
    this.NGMCP_serialNumber = event.target.value;
    this.isSearchDisabled = false;
    console.log("Serial Number updated:", this.NGMCP_serialNumber);
    if (this.NGMCP_serialNumber == "") {
      this.isSearchDisabled = true;
    } else {
      this.isSearchDisabled = false;
    }
    if (this.NGMCP_serialNumber.length == 0) {
      this.NGMCP_errorMessage = "Please enter Serial number";
    } else {
      this.NGMCP_errorMessage = "";
    }
  }

  validateMPRN() {
    this.NGMCP_errorMessage = "";
    const NGMCP_regex = /^[0-9]+$/; // only numbers
    let errors = [];
    // Rule 1: Cannot start with 0
    if (this.NGMCP_mprn.startsWith("0")) {
      errors.push(
        NGMCP_Cannot_start_with_0
      );
    }
    // Rule 2: Cannot start with space
    if (this.NGMCP_mprn.startsWith(" ")) {
      errors.push(
        NGMCP_Cannot_start_with_space
      );
    }
    // Rule 3: Cannot end with space
    if (this.NGMCP_mprn.endsWith(" ")) {
      errors.push(
        NGMCP_Cannot_end_with_space
      );
    }
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
    if (this.NGMCP_mprn.length == 0) {
      errors.push("Please enter MPRN");
    }
    // Combine all error messages
    const uniqueErrors = [...new Set(errors)];
    this.NGMCP_errorMessage = uniqueErrors.join("\n");
    if (this.NGMCP_errorMessage) {
      return false;
    } else {
      return true;
    }
  }

  showMPRNSection() {
    this.isMPRNVisible = true;
    this.isPostCodeVisible = false;
    this.isSNumberVisible = false;
    this.isMPRNBtnVisible = false;
    this.isPCBtnVisible = true;
    this.isSRNumberBtnVisible = true;
    this.isMprnSelection = true;
    this.isPostCodeSelection = false;
    this.isSerialNumberSelection = false;
    this.NGMCP_mprn = "";
    this.NGMCP_serialNumber = "";
    this.NGMCP_postcode = "";
    this.NGMCP_errorMessage = "";
    this.waitingMessage = false;
  }

  showPostCode() {
    this.isMPRNVisible = false;
    this.isPostCodeVisible = true;
    this.isSNumberVisible = false;
    this.isMPRNBtnVisible = true;
    this.isPCBtnVisible = false;
    this.isSRNumberBtnVisible = true;
    this.isMprnSelection = false;
    this.isPostCodeSelection = true;
    this.isSerialNumberSelection = false;
    this.NGMCP_errorMessage = "";
    this.NGMCP_postcode = "";
    this.waitingMessage = true;
    //console.log('waitingMessage', this.waitingMessage);
    //this.message = "Retrieving MPRN details may take a few moments. We appreciate your Understanding.";
  }

  showSerialNumber() {
    this.isMPRNVisible = false;
    this.isPostCodeVisible = false;
    this.isSNumberVisible = true;
    this.isMPRNBtnVisible = true;
    this.isPCBtnVisible = true;
    this.isSRNumberBtnVisible = false;
    this.isMprnSelection = false;
    this.isPostCodeSelection = false;
    this.isSerialNumberSelection = true;
    this.NGMCP_errorMessage = "";
    this.NGMCP_serialNumber = "";
    this.waitingMessage = false;
  }

  handleShortCodeChange(event) {
    console.log("searching for short code");
    const selectedCode = event.target.value;
    this.selectedShortCode = selectedCode;
    console.log("Selected Short Code:", selectedCode);
  }
  async handleGlobalSearch() {
    if (!this.mprn && this.isMprnSelection) {
      this.NGMCP_errorMessage = "Please enter MPRN";
      console.log("mprn is empty" + this.NGMCP_errorMessage);
    } else if (!this.NGMCP_postcode && this.isPostCodeSelection) {
      this.NGMCP_errorMessage = "Please enter Post code";
      //this.waitingMessage = "Retrieving MPRN details may take a few moments. We appreciate your Understanding."
      console.log("post code is empty" + this.NGMCP_errorMessage);
    } else if (!this.NGMCP_serialNumber && this.isSerialNumberSelection) {
      this.NGMCP_errorMessage = "Please enter Serial number";
      console.log("serial number is empty" + this.NGMCP_errorMessage);
    } else {
      console.log('elsepart is running');
      const isMprnOrSelectedCode =
        this.mprn &&
        (this.selectedShortCode || true) && // optional, always true
        !this.NGMCP_serialNumber &&
        !this.NGMCP_postcode;

      const isSerialNumberOnly =
        this.NGMCP_serialNumber && !this.NGMCP_postcode;
      let conditionKey = isMprnOrSelectedCode
        ? "mprnOrSelectedCode"
        : isSerialNumberOnly
          ? "serialNumber"
          : this.NGMCP_postcode
            ? "postalCode"
            : " ";
      console.log("conditionKey>>", conditionKey);
      switch (conditionKey) {
        case "mprnOrSelectedCode":
          await this.handleAssetDetailsCallout("mprn");
          break;

        case "serialNumber":
          await this.handleAssetDetailsCallout("serial");
          break;

        case "postalCode":
          //this.waitingMessage = true;
          await this.handleAssetDetailsCallout("postal");
          break;

        default:
          console.warn("Unhandled search condition");
      }
    }
  }

  async handleAssetDetailsCallout(type) {
    console.log(`${type} API call started`);
    this.isLoading = true;
    this.validCustomersList = [];
    let payload = {};
    let apiFunction;

    if (type === 'mprn') {
      this.postalFlag = false;
      this.serailNumberFlag = false;
      this.mprnFlag = true;
      this.serialandpostcodebypass = false;
      payload = {
        mprn: this.mprn,
        customer: this.selectedShortCode || '',
      };
      apiFunction = callAssetDetailsAPI;
    } else if (type === 'serial') {
      if (!this.NGMCP_serialNumber) {
        this.isLoading = false; // avoid spinner lock
        return;
      }
      this.serialandpostcodebypass = this.selectedShortCode ? true : false;
      this.postalFlag = false;
      this.serailNumberFlag = true;
      this.mprnFlag = false;
      payload = {
        // NOTE: if API expects 'serialNumber', rename this key
        serailNumber: this.NGMCP_serialNumber,
      };
      apiFunction = callSerialNumberAssetDetailsAPI;
    } else if (type === 'postal') {
      if (!this.NGMCP_postcode) {
        this.isLoading = false; // avoid spinner lock
        return;
      }
      this.serialandpostcodebypass = this.selectedShortCode ? true : false;
      this.postalFlag = true;
      this.serailNumberFlag = false;
      this.mprnFlag = false;
      payload = {
        postalcodevalue: this.NGMCP_postcode,
        customer: this.selectedShortCode || '',
      };
      apiFunction = callPostalNumberAssetDetailsAPI;
    } else {
      console.warn('Invalid type');
      this.isLoading = false;
      return;
    }

    try {
      console.log('payload', JSON.stringify(payload));
      const result = await apiFunction(payload);
      console.log('result', JSON.stringify(result));

      const members = result?.member || [];
      const customerMap = new Map();
      const customerelseMap = new Map();

      // Normalize sources
      const allowedShortCodes = new Set(
        (this.options || []).map((opt) => (opt?.value ?? '').trim())
      );
      const sc = (this.selectedShortCode ?? '').trim(); // normalized once
      console.log('ShortCode', sc);
      let validCustomers = [];
      members.forEach((member) => {
        const customers = member?.pluspcustassoc || [];
        const assets = member?.asset || [];
        console.log('customers', JSON.stringify(customers));
        // Filter customers:
        // If sc exists -> only match that code (skip active/allowed checks)
        // Else -> active (to_date == 9999...) AND allowed
        validCustomers = customers.filter((cust) => {
          if (sc) {
            return this.serialandpostcodebypass ? cust.customer === sc && (cust.ngme_effective_to_date?.trim() ===
              '9999-12-31T00:00:00+00:00') : cust.customer === sc; // case-sensitive match (as-is)
          }
          const isActive =
            cust.ngme_effective_to_date?.trim() ===
            '9999-12-31T00:00:00+00:00';
          if (!isActive) return false;
          return allowedShortCodes.has(cust.customer);
        });
        console.log('validCustomers', JSON.stringify(validCustomers));
        /*  if(this.serialandpostcodebypass){
          this.validCustomersList.push(
            ...validCustomers.filter(
              cust =>
                cust.ngme_effective_to_date?.trim() ===
                '9999-12-31T00:00:00+00:00' && 
            )
          );
        }else{
          this.validCustomersList.push(...validCustomers);
        }*/

        this.validCustomersList.push(
          ...(
            this.serialandpostcodebypass
              ? validCustomers.filter(
                cust => cust.ngme_effective_to_date?.trim() === '9999-12-31T00:00:00+00:00'
              )
              : validCustomers
          )
        );

        console.log('validCustomersList', JSON.stringify(this.validCustomersList));
        const validAssets = assets.filter((asset) => {
          const t = asset.assettype?.trim();
          return t === 'Z001' || t === 'Z002';
        });

        const hasZ002 = validAssets.some(
          (a) => a.assettype?.trim() === 'Z002'
        );

        console.log('validAssets', JSON.stringify(validAssets));
        console.log('hasZ002', JSON.stringify(hasZ002));

        const addressParts = [
          member.ngme_c_sitebn,
          member.ngme_c_bldngname,
          member.ngme_c_prncpstreet,
          member.ngme_c_depndlocality,
          member.ngme_c_st,
          member.ngme_c_spc,
        ].filter(Boolean);
        const fullAddress = addressParts.join(', ').trim();

        const microbusiness = member.ngme_microbusiness ? 'Yes' : 'No';
        console.log(
          'ngme_prsrtier_description',
          member.ngme_prsrtier_description
        );

        if (validCustomers.length > 0) {
          // Build an entry per valid customer for this member
          validCustomers.forEach((cust) => {
            const key = `${member.location}_${cust.customer}`;

            if (!customerMap.has(key)) {
              customerMap.set(key, {
                MPRN: member.location,
                Customer: cust.customer, // FIXED (was missing)
                AppointmentFromDate: this.formatDateToDDMMYYYY(
                  cust.ngme_effective_from_date
                ),
                appointmentDate: cust.ngme_effective_from_date,
                Address: fullAddress,
                MprnCustomer: `${member.location} - ${cust.customer}`,
                MarketselectorCode: member.ngme_lf_mksctcd,
                buildingNumber: member.ngme_c_sitebn ?? '',
                buildingName: member.ngme_c_bldngname ?? '',
                street: member.ngme_c_prncpstreet ?? '',
                dependentLocality: member.ngme_c_depndlocality ?? '',
                postalTown: member.ngme_c_st ?? '',
                postCode: member.ngme_c_spc ?? '',
                location: member.ngme_c_loccode_description || '',
                conversionFactor: member.ngme_conversionfactor,
                locationsId: member.locationsid,
                amrtag: member.ngme_amrtag,
                microbusiness: microbusiness,
                siteid: member.siteid,
                pressureTier: member.ngme_prsrtier_description,
                presureBrand: member.ngme_pssrband,
                hasZ002: hasZ002,
                paldflag: member.ngme_pald,
                paldCustomer: member.ngme_pald_customer,
                paldEndDate: member.ngme_pald_enddate,
                appointmentFlag:
                  cust.ngme_effective_to_date?.trim() ===
                  '9999-12-31T00:00:00+00:00',
                amrflag: member.ngme_amrtag ? "Yes" : "No",
                Assets: [],
              });
            }

            const customerEntry = customerMap.get(key);

            validAssets.forEach((asset) => {
              const modelNumber = asset.pluscmodelnum || '';
              const serialNumber = asset.serialnum || '';
              const meterType = asset.assettype || '';
              const manufacturerFullName = asset.companies?.[0]?.name || '';
              const manufacturer = asset.manufacturer || '';
              const yearOfManufacture = asset.ngme_yom || '';
              const installDate = asset.installdate || '';
              const paymentMechanism =
                asset.ngme_pymttype_description || '';
              const measuringCapacity = asset.ngme_qmax || '';
              const dialCount = asset.plusddialcount || '';
              const assetNum = asset.assetnum || '';
              const pulsMeterType =
                asset.plusdmetertype_description || '';

              console.log(
                'asset.plusdmetertype_description' +
                asset.plusdmetertype_description
              );

              const modeKeyAdjustments = modelNumber
                .replace(/[\/. " *]/g, '_')
                .replace(/_+$/, '');
              const typeKey = pulsMeterType
                .replace(/[\/." * -]/g, '_')
                .replace(/_+/g, '_')
                .replace(/_+$/, '');

              customerEntry.Assets.push({
                Model: modelNumber,
                MSN: serialNumber,
                MeterModel: cust.model, // kept as in your code
                MeterType: meterType,
                serialNo: serialNumber,
                manufacturer: manufacturer,
                manufacturerFullName: manufacturerFullName,
                yearofmanufacture: yearOfManufacture,
                InstallDate: installDate,
                paymentMechanism: paymentMechanism,
                noofdial: dialCount,
                measuringCapacity: measuringCapacity,
                residential_commercialKey: `${member.ngme_lf_mksctcd}_${modeKeyAdjustments}_${typeKey}_No`,
                assetnum: assetNum,
                pulsMeterType: pulsMeterType,
              });
            });
          });
        } else if (this.validCustomersList.length === 0 && ((!this.postalFlag && !this.serailNumberFlag) || this.serialandpostcodebypass)) {
          console.log('it is entering');
          // No valid customers for this member
          // Only create a fallback row if a selected short code exists
          if (!sc) return;

          const key = `${member.location}_${sc}`;
          if (!customerelseMap.has(key)) {
            customerelseMap.set(key, {
              MPRN: member.location,
              Customer: sc,
              AppointmentFromDate: '',
              appointmentDate: '',
              Address: fullAddress,
              MprnCustomer: `${member.location} - ${sc}`,
              MarketselectorCode: member.ngme_lf_mksctcd,
              buildingNumber: member.ngme_c_sitebn ?? '',
              buildingName: member.ngme_c_bldngname ?? '',
              street: member.ngme_c_prncpstreet ?? '',
              dependentLocality: member.ngme_c_depndlocality ?? '',
              postalTown: member.ngme_c_st ?? '',
              postCode: member.ngme_c_spc ?? '',
              location: member.ngme_c_loccode_description || '',
              conversionFactor: member.ngme_conversionfactor,
              locationsId: member.locationsid,
              amrtag: member.ngme_amrtag,
              microbusiness: microbusiness,
              siteid: member.siteid,
              pressureTier: member.ngme_prsrtier_description,
              presureBrand: member.ngme_pssrband,
              hasZ002: hasZ002,
              paldflag: member.ngme_pald,
              paldCustomer: member.ngme_pald_customer,
              paldEndDate: member.ngme_pald_enddate,
              appointmentFlag: false,
              Assets: [],
            });
          }

          const customerEntry = customerelseMap.get(key);

          // NOTE: No `cust` here — use modelNumber (or leave empty) for MeterModel
          validAssets.forEach((asset) => {
            const modelNumber = asset.pluscmodelnum || '';
            const serialNumber = asset.serialnum || '';
            const meterType = asset.assettype || '';
            const manufacturerFullName = asset.companies?.[0]?.name || '';
            const manufacturer = asset.manufacturer || '';
            const yearOfManufacture = asset.ngme_yom || '';
            const installDate = asset.installdate || '';
            const paymentMechanism = asset.ngme_pymttype_description || '';
            const measuringCapacity = asset.ngme_qmax || '';
            const dialCount = asset.plusddialcount || '';
            const assetNum = asset.assetnum || '';
            const pulsMeterType = asset.plusdmetertype_description || '';

            console.log(
              'asset.plusdmetertype_description' +
              asset.plusdmetertype_description
            );

            const modeKeyAdjustments = modelNumber
              .replace(/[\/. " *]/g, '_')
              .replace(/_+$/, '');
            const typeKey = pulsMeterType
              .replace(/[\/." * -]/g, '_')
              .replace(/_+/g, '_')
              .replace(/_+$/, '');

            customerEntry.Assets.push({
              Model: modelNumber,
              MSN: serialNumber,
              MeterModel: modelNumber, // FIX: no `cust` here
              MeterType: meterType,
              serialNo: serialNumber,
              manufacturer: manufacturer,
              manufacturerFullName: manufacturerFullName,
              yearofmanufacture: yearOfManufacture,
              InstallDate: installDate,
              paymentMechanism: paymentMechanism,
              noofdial: dialCount,
              measuringCapacity: measuringCapacity,
              residential_commercialKey: `${member.ngme_lf_mksctcd}_${modeKeyAdjustments}_${typeKey}_No`,
              assetnum: assetNum,
              pulsMeterType: pulsMeterType,
            });
          });
        }
      });
      let finalMap;
      if (this.validCustomersList.length === 0) {
        finalMap = customerelseMap;
      } else {
        finalMap = customerMap;
      }
      const combinedWrapper = Array.from(finalMap.values());
      // const combinedWrapper = Array.from(customerMap.values());
      console.log('combinedWrapper >>', JSON.stringify(combinedWrapper));
      this.filteredRecords = combinedWrapper;
      console.log('filteredRecords >>', JSON.stringify(this.filteredRecords));
      console.log('validCustomers LIst before >>', JSON.stringify(this.validCustomersList));
      this.isModalOpen = this.validCustomersList.length !== 0 && combinedWrapper.length > 1;
      console.log('isModalOpen >>', JSON.stringify(this.isModalOpen));
      this.isvisiableConfirmButton = combinedWrapper.length > 0;

      if (combinedWrapper.length === 1) {
        if (this.serialandpostcodebypass) {
          this.serialandpostcodebypass = false;
        }
        const jsonString = JSON.stringify(combinedWrapper);
        const encodedData = btoa(jsonString);
        this[NavigationMixin.Navigate]({
          type: 'comm__namedPage',
          attributes: { name: 'assetDetail__c' },
          state: { data: encodedData },
        });
      } else if (this.validCustomersList.length === 0 && combinedWrapper.length > 1 && this.serialandpostcodebypass) {
        this.serialandpostcodebypass = false;
        this.NGMCP_errorMessage = NGMCP_custom_Error_Message_for_Post_MPRN;
        setTimeout(() => {
          this.NGMCP_errorMessage = '';
        }, 15000);
      } else if (combinedWrapper.length === 0) {
        this.NGMCP_errorMessage = errorMessage;
        setTimeout(() => {
          this.NGMCP_errorMessage = '';
        }, 15000);
      }
    } catch (error) {
      console.error('API call failed:', error);
      this.filteredRecords = [];
    } finally {
      this.isLoading = false;
    }
  }

  formatDateToDDMMYYYY(dateString) {
    const date = new Date(dateString);
    const day = String(date.getDate()).padStart(2, "0");
    const month = String(date.getMonth() + 1).padStart(2, "0"); // Months are 0-based
    const year = date.getFullYear();
    return `${day}-${month}-${year}`;
  }
  closeModal() {
    this.isModalOpen = false;
  }
  handleSelection(event) {
    this.selectedRecordId = event.target.value;
    this.isVisiableFooterMessage = false;
    this.isDisabled = false;
    console.log("selectedRecordId", this.selectedRecordId);
  }
  confirmSelection() {
    console.log("selectedRecordId", this.selectedRecordId);
    console.log(
      "this.filteredRecords >>",
      JSON.stringify(this.filteredRecords)
    );
    const selected = this.filteredRecords.find(
      (record) =>
        record.appointmentDate?.trim() === this.selectedRecordId?.trim()
    );

    if (selected) {
      // You can handle the selected record here (e.g., show toast, pass to parent, etc.)
      console.log("Selected Record:", JSON.stringify(selected));
      const baseUrl = window.location.origin;
      const url = `${baseUrl}/customerportal/assetdetail`;
      console.log("Redirecting to:", url);
      const jsonString = JSON.stringify(selected);
      console.log("JSON String:", jsonString);
      const encodedData = btoa(jsonString); // base64 encode
      console.log("encodedData:", encodedData);

      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: "assetDetail__c",
        },
        state: {
          data: encodedData,
        },
      });

      //window.location.href = url;
      //lert(`You selected: ${selected.customer}`);
    } else {
      alert("Please select a record.");
    }
    this.closeModal();
  }

  get processedRecords() {
    return this.filteredRecords.map(record => {
      const asset = record.Assets && record.Assets.length > 0 ? record.Assets[0] : {};
      return {
        ...record,
        assetModel: asset.Model || 'N/A',
        assetMSN: asset.MSN || 'N/A',
        assetType: asset.MeterType || 'N/A',
        manufacturer: asset.manufacturerFullName || 'N/A',
        installDate: asset.InstallDate ? new Date(asset.InstallDate).toLocaleDateString() : 'N/A'
      };
    });
  }
  handleKeyPress(event) {
    console.log('Key pressed:', event);
    if (event.key === 'Enter') {
      this.handleGlobalSearch(); // Trigger handleGlobalSearch on Enter
    }
  }
  async handlePressKey(event) {
    if (event.key === 'Enter') {
      await this.handleSearchClick(); // Trigger handleGlobalSearch on Enter
    }
  }

  handleNumberInput = (event) => {
    console.log('handle Number', event.target.value);
    const type = event.target.dataset.type; // 'sr' or 'wo'
    const value = (event.target.value || '').trim();

    // Update state
    if (type === 'sr') {
      this.woRecordId = '';
      this.srNumber = value;
      this.isSearchDisabled = false;
    } else if (type === 'wo') {
      if (this.showViewRequest)
        this.showViewRequest = false;
      this.woNumber = value;
      this.isSearchDisabled = false;
    }
  };

  async handleSearchClick(event) {
    const type = event?.currentTarget?.dataset?.type || (this.srNumber ? 'sr' : 'wo'); // 'sr' or 'wo'
    const value = type === 'sr' ? this.srNumber : this.woNumber;

    console.log('handleSearchClick -> type:', type);

    if (type === 'sr') {
      // Debounced filter update
      clearTimeout(this.searchTimeout);
      this.searchTimeout = setTimeout(() => {
        // Create a NEW object reference for reactivity
        this.filters = { ...this.filters, sr: value, shortCode: "" };
        //this.showViewRequest = true;

        // Build a consistent event payload
        const detail = {
          type: 'sr',
          responseClass: 'SRNumber',
          filters: { ...this.filters }
        };
        console.log('Parent set filters:', JSON.stringify(this.filters));
        this.dispatchEvent(new CustomEvent('response', { detail }));
      }, 250);

      return;
    }

    // ---- WO path ----
    this.showViewRequest = false;

    // Optional: Disable search while calling Apex
    const previousDisabled = this.isSearchDisabled;
    this.isSearchDisabled = true;

    try {
      console.log('Work Order search clicked for:', this.woNumber);
      const workOrderId = await getWorkOrderId({ workOrderNumber: this.woNumber });

      if (workOrderId) {
        console.log('Work Order Id:', workOrderId);

        // Update local state
        this.woRecordId = workOrderId;
        this.recordTypeName = 'WorkOrder';

        const detail = {
          type: 'wo',
          responseClass: 'WorkOrder',
          filters: '', // now includes wo
          result: { id: workOrderId, recordType: 'WorkOrder' }
        };

        this.dispatchEvent(new CustomEvent('response', { detail }));
      } else {
        console.warn('No Work Order found for number:', this.woNumber);

      }
    } catch (error) {
      console.error('Error fetching Work Order Id:', error);
    } finally {
      // Restore button state
      this.isSearchDisabled = previousDisabled;
    }
  }

  // Generic setter for any filter (call like setFilter('mprn', value))
  setFilter(key, rawValue) {
    const val = rawValue === '' ? null : rawValue;
    this.filters = { ...this.filters, [key]: val };
    console.log('Parent set filters:', JSON.stringify(this.filters));
  }

}