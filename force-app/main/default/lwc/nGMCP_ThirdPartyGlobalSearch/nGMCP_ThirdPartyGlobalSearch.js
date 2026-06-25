import { LightningElement, track, api, wire } from "lwc";
import ngAssets from "@salesforce/resourceUrl/NGMCP_SearchMPRN";
import callAssetDetailsAPI from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.callAssetDetailsAPI";
import callSerialNumberAssetDetailsAPI from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.callSerialNumberAssetDetailsAPI";
import callPostalNumberAssetDetailsAPI from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.callpostalAssetDetailsAPI";
import { NavigationMixin } from "lightning/navigation";
import dualMprn from "@salesforce/label/c.NGMCP_DualMPRN";
import errorMessage from "@salesforce/label/c.NGMCP_ErrorMesasge";
import NGMCP_Cannot_end_with_space from "@salesforce/label/c.NGMCP_Cannot_end_with_space";
import NGMCP_Cannot_start_with_space from "@salesforce/label/c.NGMCP_Cannot_start_with_space";
import NGMCP_Cannot_start_with_0 from "@salesforce/label/c.NGMCP_Cannot_start_with_0";
import NGMCP_Only_numbers from "@salesforce/label/c.NGMCP_Only_numbers";
import NGMCP_Maximum_length_10 from "@salesforce/label/c.NGMCP_Maximum_length_10";
import NGMCP_Minimum_length_10 from "@salesforce/label/c.NGMCP_Minimum_length_10";
import getUserSupplierCodeOptions from '@salesforce/apex/NGMCP_UserDependentPicklistController.getUserSupplierCodeOptions';
export default class NGMCP_ThirdPartyGlobalSearch extends NavigationMixin(
  LightningElement
) {
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
  @api filteredRecords = [];
  @track shortCodeError = '';
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
  @track spinnerMessage = "Fetching details, Please wait...";
  //postalcodecontainerHeading;

  @track isLoading = false;
  @track isModalOpen = false;
  @wire(getUserSupplierCodeOptions)
  wiredOptions({ data, error }) {
    //this.isLoading = false;
    if (data) {
      this.options = data.map(o => ({ value: o.value, label: o.label }));
      this.options.sort();
      this.errorMessage = '';
    } else if (error) {
      this.options = [];
      this.errorMessage = this.normalizeError(error);
    }
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


  handleKeyPress(event) {
    if (event.key === 'Enter' && !this.NGMCP_errorMessage) {
      this.handleGlobalSearch(); // Trigger handleGlobalSearch on Enter
    }
  }
  async handlePressKey(event) {
    if (event.key === 'Enter') {
      await this.NGMCP_handlemprnChanges(); // Trigger handleGlobalSearch on Enter
    }
  }

  get isSearchDisabled() {
    return !this.validateMPRN();
  }

  handleTabClick(event) {
    this.activeTab = event.currentTarget.dataset.tab;
  }
  async NGMCP_handlemprnChanges(event) {
    const inputValue = event.target.value;
    this.NGMCP_mprn = event.target.value;
    const isValid = await this.validateMPRN();
    if (this.NGMCP_errorMessage == "") {
      this.isSearchDisabled = false;
    } else {
      this.isSearchDisabled = true;
    }
    if (isValid) {
      this.mprn = inputValue;
    } else {
      console.warn("Invalid MPRN:", inputValue);
    }
  }
  NGMCP_handlepostalcodeChanges(event) {
    this.NGMCP_postcode = event.target.value;
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

  // validateMPRN() {
  //   this.NGMCP_errorMessage = "";
  //   const NGMCP_regex = /^[0-9]+$/; // only numbers
  //   let errors = [];
  //   // Rule 1: Cannot start with 0
  //   if (this.NGMCP_mprn.startsWith("0")) {
  //     errors.push(NGMCP_Cannot_start_with_0);
  //   }
  //   // Rule 2: Cannot start with space
  //   if (this.NGMCP_mprn.startsWith(" ")) {
  //     errors.push(NGMCP_Cannot_start_with_space);
  //   }
  //   // Rule 3: Cannot end with space
  //   if (this.NGMCP_mprn.endsWith(" ")) {
  //     errors.push(NGMCP_Cannot_end_with_space);
  //   }
  //   // Rule 4: Only numbers
  //   if (
  //     !NGMCP_regex.test(this.NGMCP_mprn) &&
  //     !this.NGMCP_mprn.startsWith(" ") &&
  //     !this.NGMCP_mprn.endsWith(" ") &&
  //     this.NGMCP_mprn.length > 0
  //   ) {
  //     errors.push(NGMCP_Only_numbers);
  //   }
  //   // Rule 5: Maximum length 10
  //   if (this.NGMCP_mprn.length > 10) {
  //     errors.push(NGMCP_Maximum_length_10);
  //   }
  //   if (this.NGMCP_mprn.length == 0) {
  //     errors.push("Please enter MPRN");
  //   }
  //   // Combine all error messages
  //   const uniqueErrors = [...new Set(errors)];
  //   this.NGMCP_errorMessage = uniqueErrors.join("\n");
  //   if (this.NGMCP_errorMessage) {
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }

  validateMPRN() {
    this.NGMCP_errorMessage = "";
    const NGMCP_regex = /^[0-9]+$/;
    let errors = [];
    let mprn = this.NGMCP_mprn;

    // ---------------- EXISTING VALIDATIONS ----------------

    if (mprn.startsWith("0")) {
      errors.push(NGMCP_Cannot_start_with_0);
    }
    if (mprn.startsWith(" ")) {
      errors.push(NGMCP_Cannot_start_with_space);
    }
    if (mprn.endsWith(" ")) {
      errors.push(NGMCP_Cannot_end_with_space);
    }
    if (
      !NGMCP_regex.test(mprn) &&
      !mprn.startsWith(" ") &&
      !mprn.endsWith(" ") &&
      mprn.length > 0
    ) {
      errors.push(NGMCP_Only_numbers);
    }

    if (mprn.length > 10) {
      errors.push(NGMCP_Maximum_length_10);
    }
    if (mprn.length === 1) {
      errors.push(NGMCP_Minimum_length_10);
    }

    if (mprn.length === 0) {
      errors.push("Please enter MPRN");
    }

    // ----------------  NEW CHECKSUM VALIDATION ----------------
    if (errors.length === 0 && mprn.length >= 3) {
      try {
        // Step 1: Split
        let checkDigits = mprn.slice(-2);
        let baseNumber = mprn.slice(0, -2);
        // Step 2: Reverse
        let reversed = baseNumber.split('').reverse();
        // Step 3: Multiply (1,2,3...)
        let totalSum = 0;
        reversed.forEach((digit, index) => {
          totalSum += parseInt(digit) * (index + 1);
        });
        // Step 4: Modulo
        let checkValue = totalSum % 11;
        // if (checkValue === 10) {
        //     checkValue = 0; // optional rule
        // }
        // Step 5: Format 2 digits
        let calculated = checkValue.toString().padStart(2, '0');
        // Step 6: Compare
        if (calculated !== checkDigits) {
          errors.push('MPRN is not valid as per the Industry format, Please validate and reenter correct MPRN');
        }
      } catch (e) {
        errors.push('Error validating MPRN');
      }
    }

    // ---------------- FINAL ERROR HANDLING ----------------
    // const uniqueErrors = [...new Set(errors)];
    // this.NGMCP_errorMessage = uniqueErrors.join("\n");
    // return !this.NGMCP_errorMessage;
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
    this.NGMCP_errorMessage = "";
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
  }

  handleShortCodeChange(event) {
    const selectedCode = event.target.value;
    this.selectedShortCode = selectedCode;
    if (selectedCode) {
      this.validateShortCode();
    }

    this.dispatchEvent(
      new CustomEvent("shortcodechange", {
        detail: {
          selectedCode,
        },
      }));
  }
  async handleGlobalSearch() {
    if (!this.mprn && this.isMprnSelection) {
      this.NGMCP_errorMessage = "Please enter MPRN";
    } else if (!this.NGMCP_postcode && this.isPostCodeSelection) {
      this.NGMCP_errorMessage = "Please enter Post code";
    } else if (!this.NGMCP_serialNumber && this.isSerialNumberSelection) {
      this.NGMCP_errorMessage = "Please enter Serial number";
    } else {
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
      switch (conditionKey) {
        case "mprnOrSelectedCode":
          await this.handleAssetDetailsCallout("mprn");
          break;

        case "serialNumber":
          await this.handleAssetDetailsCallout("serial");
          break;

        case "postalCode":
          await this.handleAssetDetailsCallout("postal");
          break;

        default:
          console.warn("Unhandled search condition");
      }
    }
  }

  async handleAssetDetailsCallout(type) {
    this.isLoading = true;
    let isActive;
    let payload = {};
    let apiFunction;

    if (type === "mprn") {
      payload = {
        mprn: this.mprn,
        customer: this.selectedShortCode || "",
      };
      apiFunction = callAssetDetailsAPI;
    } else if (type === "serial") {
      if (!this.NGMCP_serialNumber) return;
      payload = {
        serailNumber: this.NGMCP_serialNumber,
      };
      apiFunction = callSerialNumberAssetDetailsAPI;
    } else if (type === "postal") {
      if (!this.NGMCP_postcode) return;
      payload = {
        postalcodevalue: this.NGMCP_postcode,
        customer: this.selectedShortCode || "",
      };
      apiFunction = callPostalNumberAssetDetailsAPI;
    } else {
      console.warn("Invalid type");
      this.isLoading = false;
      return;
    }

    try {
      const result = await apiFunction(payload);
      const members = result?.member || [];
      const customerMap = new Map();
      const allowedShortCodes = new Set(
        (this.options || []).map(opt => opt.value)
      );
      const sc = (this.selectedShortCode ?? '').trim(); // normalized once
      members.forEach((member) => {
        const customers = member?.pluspcustassoc || [];
        const assets = member?.asset || [];
        const validCustomers = customers.filter((cust) => {
          if (sc) {
            return cust.customer === sc; // case-sensitive match (as-is)
          }
          const isActive =
            cust.ngme_effective_to_date?.trim() ===
            '9999-12-31T00:00:00+00:00';
          if (!isActive) return false;
          return allowedShortCodes.has(cust.customer);
        });
        const validAssets = assets.filter(
          (asset) =>
            asset.assettype?.trim() === "Z001" ||
            asset.assettype?.trim() === "Z002"
        );
        const hasZ002 = Array.isArray(validAssets) &&
          validAssets.some(a => a.assettype?.trim() === "Z002");
        const addressObject = {
          buildingNumber: member.ngme_c_sitebn ?? "",
          buildingName: member.ngme_c_bldngname ?? "",
          street: member.ngme_c_prncpstreet ?? "",
          dependentLocality: member.ngme_c_depndlocality ?? "",
          postalTown: member.ngme_c_st ?? "",
          postCode: member.ngme_c_spc ?? "",
        };
        const fullAddress = Object.values(addressObject)
          .filter(Boolean)
          .join(", ")
          .trim();
        const microbusiness = member.ngme_microbusiness ? "Yes" : "No";
        if (validCustomers.length > 0) {
          validCustomers.forEach((cust) => {
            const key = `${member.location}_${cust.customer}`;
            if (!customerMap.has(key)) {
              customerMap.set(key, {
                MPRN: member.location,
                Customer: cust.customer,
                AppointmentFromDate: this.formatDateToDDMMYYYY(
                  cust.ngme_effective_from_date
                ),
                appointmentDate: cust.ngme_effective_from_date,
                Address: addressObject,
                AddressString: fullAddress,
                MprnCustomer: `${member.location} - ${cust.customer}`,
                MarketselectorCode: member.ngme_lf_mksctcd,
                buildingNumber: member.ngme_c_sitebn ?? "",
                buildingName: member.ngme_c_bldngname ?? "",
                street: member.ngme_c_prncpstreet ?? "",
                dependentLocality: member.ngme_c_depndlocality ?? "",
                postalTown: member.ngme_c_st ?? "",
                postCode: member.ngme_c_spc ?? "",
                location: member.ngme_c_loccode_description || "",
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
                appointmentFlag: cust.ngme_effective_to_date?.trim() ===
                  '9999-12-31T00:00:00+00:00',
                Assets: [],
              });
            }

            const customerEntry = customerMap.get(key);

            validAssets.forEach((asset) => {
              const modelNumber = asset.pluscmodelnum || "";
              const serialNumber = asset.serialnum || "";
              const meterType = asset.assettype || "";
              const manufacturerFullName = asset.companies?.[0]?.name || "";
              const manufacturer = asset.manufacturer || "";
              const yearOfManufacture = asset.ngme_yom || "";
              const installDate = asset.installdate || "";
              const paymentMechanism = asset.ngme_pymttype_description || "";
              const measuringCapacity = asset.ngme_qmax || "";
              const dialCount = asset.plusddialcount || "";
              const assetNum = asset.assetnum || "";
              const pulsMeterType = asset.plusdmetertype_description || "";
              let modeKeyAdjustments = modelNumber
                .replace(/[\/. "]/g, "_")
                .replace(/_+$/, "");
              let type = pulsMeterType
                .replace(/[\/." * -]/g, "_")
                .replace(/_+/g, "_")
                .replace(/_+$/, "");

              customerEntry.Assets.push({
                Model: modelNumber,
                MSN: serialNumber,
                MeterModel: cust.model,
                MeterType: meterType,
                serialNo: serialNumber,
                manufacturer: manufacturer,
                manufacturerFullName: manufacturerFullName,
                yearofmanufacture: yearOfManufacture,
                InstallDate: installDate,
                paymentMechanism: paymentMechanism,
                noofdial: dialCount,
                measuringCapacity: measuringCapacity,
                residential_commercialKey: `${member.ngme_lf_mksctcd}_${modeKeyAdjustments}_${type}_No`,
                assetnum: assetNum,
                pulsMeterType: pulsMeterType,
              });
            });
          });
        } else {
          if (!sc) return;

          const key = `${member.location}_${sc}`;
          if (!customerMap.has(key)) {
            customerMap.set(key, {
              MPRN: member.location,
              Customer: sc,
              AppointmentFromDate: '',
              appointmentDate: '',
              Address: addressObject,
              AddressString: fullAddress,
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

          const customerEntry = customerMap.get(key);
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

      const combinedWrapper = Array.from(customerMap.values());
      this.filteredRecords = combinedWrapper;
      this.isModalOpen = combinedWrapper.length > 1;
      this.isvisiableConfirmButton = combinedWrapper.length > 0;

      if (combinedWrapper.length === 1) {
        const baseUrl = window.location.origin;
        const record = combinedWrapper[0];
        const jsonString = JSON.stringify(combinedWrapper);
        const encodedData = btoa(jsonString);
        // Always include metadata + address + assets
        this.dispatchEvent(
          new CustomEvent("mprnfound", {
            detail: {
              combinedWrapper,
              encodedData,
              address: record.Address,
              assets: record.Assets,
              metadata: this.metaDataWrapper || {},
            },
          })
        );
      } else if (combinedWrapper.length === 0) {
        this.dispatchEvent(
          new CustomEvent("mprnnotfound", {
            detail: {
              metadata: this.metaDataWrapper || {},
              mprn: this.mprn,
              searchcode: this.selectedShortCode,
              thirdpartyfound: true,
            },
          })
        );
      }
    } catch (error) {
      console.error("API call failed:", error);
      this.filteredRecords = [];
      // Fire not-found event on error as well
      this.dispatchEvent(new CustomEvent("mprnnotfound"));
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
  }
  confirmSelection() {
    const selected = this.filteredRecords.find(
      (record) =>
        record.appointmentDate?.trim() === this.selectedRecordId?.trim()
    );

    if (selected) {
      const combinedWrapper = selected;
      const baseUrl = window.location.origin;
      const record = combinedWrapper;
      const jsonString = JSON.stringify(combinedWrapper);
      const encodedData = btoa(jsonString);
      this.dispatchEvent(
        new CustomEvent("mprnfound", {
          detail: {
            combinedWrapper,
            encodedData,
            address: record.Address,
            assets: record.Assets,
            metadata: this.metaDataWrapper || {},
          },
        })
      );
    } else {
      alert("Please select a record.");
    }
    this.closeModal();
  }

  get processedRecords() {
    return this.filteredRecords.map((record) => {
      const asset =
        record.Assets && record.Assets.length > 0 ? record.Assets[0] : {};
      return {
        ...record,
        assetModel: asset.Model || "N/A",
        assetMSN: asset.MSN || "N/A",
        assetType: asset.MeterType || "N/A",
        manufacturer: asset.manufacturerFullName || "N/A",
        installDate: asset.InstallDate
          ? new Date(asset.InstallDate).toLocaleDateString()
          : "N/A",
      };
    });
  }
  @api validateShortCode() {
    const isValid = !!this.selectedShortCode; // non-empty value
    this.shortCodeError = isValid ? '' : 'Please select a short code.';
    return isValid;
  }
}