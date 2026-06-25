import { LightningElement, track, api, wire } from "lwc";
//import submitUrgentWorkRequest from '@salesforce/apexContinuation/NGMCP_IBMMaximoIntegrationClass.submitUrgentWorkRequest';
import submitUrgentWorkRequest from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.submitUrgentWorkRequest";
import createUrgentWorkRequestRecord from "@salesforce/apex/NGMCP_RequestObjectClass.createUrgentWorkRequestRecord";
import getHolidays from "@salesforce/apex/NGMCP_HolidaysService.getHolidaysBetween";
import getServicePartnerStatus from "@salesforce/apex/NGMCP_ServicePartnerController.getServicePartnerStatus";
import isNGMUser from "@salesforce/apex/NGMCP_ServicePartnerController.isNGMUser";
import REQUEST_HEADER from "@salesforce/label/c.NGMCP_UWR_Popup_Header";
import SUCCESS_MESSAGE from "@salesforce/label/c.NGMCP_UWR_Success_PopUp";
import SERVICETICKET_ID from "@salesforce/label/c.NGMCP_UWR_Service_RequestId";
import ENGINEER_VISIT_MSG_STARTNOW from "@salesforce/label/c.NGMCP_UWR_EngineerDetails_for_StartNOw";
import ENGINEER_VISIT_MSG from "@salesforce/label/c.NGMCP_UWR_Engineer_Message_for_Appointment";
import getPreviousUrgentWorkRequestHistoryForMPRN from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.getPreviousUrgentWorkRequestHistoryForMPRN";
import getCWRFieldMapping from "@salesforce/apex/NGMCP_CustomerWorkRequestFieldMapping.getMappings";
import getCWRJobCodes from "@salesforce/apex/NGMCP_CustomerWorkRequestFieldMapping.getJobCodes";
import uploadFiles from '@salesforce/apex/NGMCP_RequestObjectClass.uploadFiles';
import uploadtoMAximoSystem from '@salesforce/apex/NGMCP_RequestObjectClass.uploadDocumentToMaximo';

// Salesforce Experience Cloud limit ~10 MB per file
const MAX_FILE_SIZE = 10 * 1024 * 1024;

export default class dummycreateJobRequestComponent extends LightningElement {
   @track selectedTitle = "";
    @api metadataRecord;
    @api assetDetails = []; // Array expected
    @api addressDetails = {}; // Can come as object from parent
    @api status;
    @api paymentMechanism;
    @track createrequestFlag = false;
    @api postCode;
    @api mprn;
    @track showWindOnOption = false;
    @track isNGMUser = false;
    @track showCautionMessage = false;
    @track showUwrRequest = false;
    @track showRestro = false;
    @track validationErrors = {};
    @track urgentOptions = [];
    @track selectedValue;
    @track jobTypes = [];
    @track selectedJobType = false;
    @track showJobType = false;
    @track showAppointment = false;
    @track showcontactdetails = false;
    @track isLoading = false;
    @track windonFlag = false; //Bug 171550: we decalre windFlag
    @track startNowFlag = false;
    @track pickupDateFlag = false; //BUG 172390
    @track retrospectiveFlag = false; //BUG 172390
    @api meterSize;
    @track enquiryFlag = false;
    @track techEnquiryFlag = false;
    @track workRequestFlag = false;
    @track deappointmentFlag = false;
    @track cwrdescription = '';
    @track stateofWorkRequest;
    @track statemap = new Map();
    @track assetLabelMap = new Map();
    appointmentType;
    windOnRequestedBy;
    isResidential;
    queryvalue;
    @track contactDetails = {
      title: "",
      name: "",
      contactNumber: "",
      emailAddress: "",
      instructions: "",
      consent: false,
    };
    reportedpriority = 1;
    job_type;
    affectedphone;
    description_longdescription;
    job_subtype;
    targetstart;
    ngme_time;
    source = "PORTAL";
    job_sub_subtype;
    ngme_liferay_slot;
    ngme_industry;
    assetnum;
    suppliercode;
    location;
    affectedperson;
    @track showAppointmentFields = false;
    @track showAllAsset = false;
  
    @track showAllAddress = false;
  
    @track showAppointmentSlots = false;
    @track showServicePartnerStatus = false;
    @track servicePartnerBoxClass;
    @track servicePartnerMessage;
    @track selectedDate;
    @track appointmentOptions = [];
    holidays = [];
  
    @track servicePartnerStatus = "";
    @track showWarningMessage = false;
    @track isNGMUser = false;
    @track disableSubmit = false;
    @track isModel = false;
    @track submittedDate;
    @track srNumber;
    @track interval;
    @track uploadedFiles = []; // for UI display
    uploadedFilePayload = []; // ready for API call
    @track fileError = "";
    @track engineerVisitMessage;
    @track requestHeader = REQUEST_HEADER;
    @track successMessage = SUCCESS_MESSAGE;
    @track serviceTicketid = SERVICETICKET_ID;
    @track hideWorkTile = false;
    @api pressuretier;
    serviceProviderError = false;
    serviceProviderErrorMessage = "";
    @track successprice;
  
    // replace your existing startOptions with this
    @track startOptions = [
      {
        label: "Start now",
        value: "now",
        isChecked: false,
        className: "radio-card",
        description:
          "For an engineer to attend within the agreed SLA upon submission of the request.",
      },
      {
        label: "Pick Date/Time",
        value: "pick",
        isChecked: false,
        className: "radio-card",
        description:
          "For an engineer to attend within the agreed SLA from the start time of the appointment slot selected.",
      },
      {
        label: "Retrospective",
        value: "restro",
        isChecked: false,
        className: "radio-card",
        description:
          "To raise a request on a past dated appointment for retrospective completion by NGM.",
      },
    ];
  
    residentialSlots = [
      {
        code: "S1",
        timeframe: "08:00 - 11:00",
      },
      {
        code: "S2",
        timeframe: "10:00 - 13:00",
      },
      {
        code: "S3",
        timeframe: "12:00 - 15:00",
      },
      {
        code: "S4",
        timeframe: "14:00 - 17:00",
      },
      {
        code: "S5",
        timeframe: "16:00 - 19:00",
      },
      {
        code: "S6",
        timeframe: "18:00 - 21:00",
      },
    ];
    commercialSlots = [
      {
        code: "S1",
        timeframe: "08:00 - 12:00",
      },
      {
        code: "S2",
        timeframe: "10:00 - 14:00",
      },
      {
        code: "S3",
        timeframe: "12:00 - 16:00",
      },
      {
        code: "S4",
        timeframe: "14:00 - 18:00",
      },
      {
        code: "S5",
        timeframe: "16:00 - 20:00",
      },
    ];
    @track availableSlots = [];
    @track showPickDateSection = false;
    @track appointmentDate = "";
    @track selectedSlot = "";
    @track selectedSlotLabel = "";
    @track slotOptions = [];
    @track showBankCalender = false;
  
    @track showFaulty = false;
    @track keepJobTypesVisible = false;
  
    maxInstructionLength = 255;
    remainingChars = this.maxInstructionLength;
  
    startNowError = "";
    startNowErrorElement;
  
    // TEMPORARY TESTING FLAG — remove after testing
    testMode = true;
    testDateTime = "2025-11-15T21:30:00Z"; // <-- Set any date/time in UTC to simulate
  
    // --- Residential (Weekday) Slots ---
    residentialWeekdaySlots = [
      { label: "08:00 - 11:00", value: "S1" },
      { label: "10:00 - 13:00", value: "S2" },
      { label: "12:00 - 15:00", value: "S3" },
      { label: "14:00 - 17:00", value: "S4" },
      { label: "16:00 - 19:00", value: "S5" },
      { label: "18:00 - 21:00", value: "S6" },
    ];
  
    // --- Commercial & Residential (Weekend / Holiday) Slots ---
    commercialAndWeekendSlots = [
      { label: "08:00 - 12:00", value: "S1" },
      { label: "10:00 - 14:00", value: "S2" },
      { label: "12:00 - 16:00", value: "S3" },
      { label: "14:00 - 18:00", value: "S4" },
      { label: "16:00 - 20:00", value: "S5" },
    ];
    workRequestResidentials = [
      { label: '08:00 - 20:00', value: 'AT' },
      { label: '08:00 - 12:00', value: 'AM' },
      { label: '12:00 - 16:00', value: 'PM' },
      { label: '08:00 - 10:00', value: 'S1' },
      { label: '10:00 - 12:00', value: 'S2' },
      { label: '12:00 - 14:00', value: 'S3' },
      { label: '14:00 - 16:00', value: 'S4' },
      { label: '16:00 - 18:00', value: 'S5' },
      { label: '18:00 - 20:00', value: 'S6' }
    ];
    ;
  
    workRequestCommercial = [
      { label: '08:00 - 20:00', value: 'AT' },
      { label: '08:00 - 13:00', value: 'AM' },
      { label: '12:00 - 20:00', value: 'PM' }
    ];
  
    @wire(getHolidays)
    wiredHolidays({ data, error }) {
      if (data) {
        console.log("wire fired", data);
        this.holidays = data.map((h) => {
          const dateObj = new Date(h);
          return dateObj.toISOString().split("T")[0];
        });
        console.log("Normalized Holidays:", this.holidays);
      } else if (error) {
        console.error("Error fetching holidays:", error);
      }
    }
  
    removeFieldError(fieldName) {
      if (this.validationErrors && this.validationErrors[fieldName]) {
        const newErrors = { ...this.validationErrors };
        delete newErrors[fieldName];
        this.validationErrors = newErrors;
      }
    }
  
    get remainingCharsLabel() {
      const n =
        typeof this.remainingChars === "number"
          ? this.remainingChars
          : this.maxInstructionLength;
      return `${n} ${n === 1 ? "character" : "characters"} remaining`;
    }
  
    get charLimitClass() {
      // when fewer than 10 chars left -> 'warning'
      return this.remainingChars < 10 ? "char-limit warning" : "char-limit";
    }
  
    @track startOptions = [
      {
        label: "Start Now",
        value: "now",
        isChecked: false,
        className: "radio-card",
        description:
          "For an engineer to attend within the agreed SLA upon submission of the request.",
      },
      {
        label: "Pick Date/Time",
        value: "pick",
        isChecked: false,
        className: "radio-card",
        description:
          "For an engineer to attend within the agreed SLA from the start time of the appointment slot selected.",
      },
      {
        label: "Retrospective",
        value: "restro",
        isChecked: false,
        className: "radio-card",
        description:
          "To raise a request on a past dated appointment for retrospective completion by NGM.",
      },
    ];
  
    // handleInstructionInput(event) {
    //   const el = event.target;
    //   let val = el.value || '';
  
    //   if (val.length > this.maxInstructionLength) {
    //     val = val.substring(0, this.maxInstructionLength);
    //     el.value = val;
    //   }
  
    //   this.contactDetails = {
    //     ...this.contactDetails,
    //     instructions: val
    //   };
  
    //   this.remainingChars = this.maxInstructionLength - val.length;
  
    //   if (val.length > this.maxInstructionLength) {
    //     this.validationErrors = {
    //       ...this.validationErrors,
    //       instructions: `Maximum ${this.maxInstructionLength} characters allowed.`
    //     };
    //   } else {
    //     if (this.validationErrors && this.validationErrors.instructions) {
    //       const { instructions, ...rest } = this.validationErrors;
    //       this.validationErrors = { ...rest };
    //     }
    //   }
    // }
  
    handleInstructionInput(event) {
      const el = event.target;
      let val = el.value || "";
  
      // Trim to max length (your existing logic)
      if (val.length > this.maxInstructionLength) {
        val = val.substring(0, this.maxInstructionLength);
        el.value = val;
      }
  
      this.contactDetails = {
        ...this.contactDetails,
        instructions: val,
      };
      this.remainingChars = this.maxInstructionLength - val.length;
  
      // Build a fresh errors object (copy existing errors)
      let errors = { ...this.validationErrors };
  
      // --- Your max‑length validation logic — unchanged ---
      if (val.length > this.maxInstructionLength) {
        errors.instructions = `Maximum ${this.maxInstructionLength} characters allowed.`;
      } else {
        if (errors.instructions && errors.instructions.includes("Maximum")) {
          const { instructions, ...rest } = errors;
          errors = { ...rest };
        }
      }
  
      // --- My addition: forbidden-character validation ---
      const forbiddenChars = /["<>]/; // Regex for ", <, >
      if (forbiddenChars.test(val)) {
        errors.instructions =
          'Invalid character detected. Characters " < > are not allowed.';
      } else {
        if (
          errors.instructions &&
          errors.instructions.includes("Invalid character")
        ) {
          const { instructions, ...rest } = errors;
          errors = { ...rest };
        }
      }
  
      // Finally, set validationErrors to the merged result
      this.validationErrors = errors;
    }
  
    handleStatusChange(event) {
      this.status = event.detail.value;
      // Reset slot and date when switching type
      this.selectedDate = null;
      this.selectedSlot = null;
      this.appointmentOptions = [];
  
      // Optional: Also reset validation messages if any
      if (this.validationErrors) {
        this.validationErrors.appointmentDate = "";
        this.validationErrors.appointmentSlot = "";
      }
  
      console.log("Switched to status:", this.status);
      this.updateAppointmentSlots();
    }
  
    handleSlotChange(event) {
      this.selectedSlot = event.detail.value;
      // Find the label from the options array
      const selectedOption = this.appointmentOptions.find(
        (option) => option.value === this.selectedSlot
      );
      this.selectedSlotLabel = selectedOption ? selectedOption.label : "";
      console.log("Slot booked***", this.selectedSlot);
      console.log("selectedSlotLabel***", this.selectedSlotLabel);
      this.ngme_time = this.selectedSlotLabel;
      this.ngme_liferay_slot = this.selectedSlot;
      this.removeFieldError("appointmentSlot");
    }
  
    // handleDateChange(event) {
    //   console.log("handleDateChange triggered!");
    //   const selectedDate = event.detail.date;
    //   console.log("Selected date from child:", selectedDate);
    //   this.removeFieldError("appointmentDate");
    //   this.selectedDate = selectedDate;
    //     this.selectedSlot = null;
    //    if (this.status && this.status.toLowerCase() !== "restro") {
    //       this.updateAppointmentSlots();
    //     } else {
    //       this.appointmentOptions = [];
    //     }
    // }
  
    // updateAppointmentSlots() {
    //   console.log("updateAppointmentSlots actually running now.");
    //   console.log("this.status:", this.status);
  
    //   if (!this.selectedDate || !this.status) {
    //     this.appointmentOptions = [];
    //     return;
    //   }
  
    //   const statusLower = this.status.toLowerCase();
    //   const selected = new Date(this.selectedDate);
    //   const day = selected.getDay(); // 0 = Sunday, 6 = Saturday
    //   const isWeekend = day === 0 || day === 6;
  
    //   const selectedDateOnly = selected.toISOString().split("T")[0];
    //   const isHoliday = this.holidays.some((h) => h === selectedDateOnly);
    //   this.targetstart = selectedDateOnly;
    //   console.log("Status:", statusLower);
    //   console.log("Selected Date:", selectedDateOnly);
    //   console.log("Is Weekend:", isWeekend);
    //   console.log("Is Holiday:", isHoliday);
    //   if (statusLower === "residential") {
    //     if (!isWeekend && !isHoliday) {
    //       this.appointmentOptions = this.residentialWeekdaySlots;
    //     } else {
    //       this.appointmentOptions = this.commercialAndWeekendSlots;
    //     }
    //   } else if (statusLower === "commercial") {
    //     this.appointmentOptions = this.commercialAndWeekendSlots;
    //   } else {
    //     this.appointmentOptions = [];
    //   }
  
    //   console.log("Rendered Slots:", JSON.stringify(this.appointmentOptions));
    // }
  
    handleDateChange(event) {
      console.log("handleDateChange triggered!");
      const selectedDate = event.detail.date;
      console.log("Selected date from child:", selectedDate);
      this.removeFieldError("appointmentDate");
      this.selectedDate = selectedDate;
      this.selectedSlot = null;
      if (this.status && this.status.toLowerCase() !== "restro") {
        this.updateAppointmentSlots();
      } else {
        this.appointmentOptions = [];
      }
    }
  
    updateAppointmentSlots() {
      if (!this.selectedDate || !this.status) {
        this.appointmentOptions = [];
        return;
      }
  
      const statusLower = this.status.toLowerCase();
      const selected = new Date(this.selectedDate);
      const day = selected.getDay();
      const isWeekend = day === 0 || day === 6;
      const selectedDateNormalized = this.selectedDate;
      const isHoliday = this.holidays.includes(selectedDateNormalized);
  
      this.targetstart = selectedDateNormalized;
      console.log("Status:", statusLower);
      console.log("Selected Date:", selectedDateNormalized);
      console.log("Is Weekend:", isWeekend);
      console.log("Is Holiday:", isHoliday);
  
      if (statusLower === "residential" && !this.workRequestFlag) {
        if (!isWeekend && !isHoliday) {
          this.appointmentOptions = this.residentialWeekdaySlots;
        } else {
          this.appointmentOptions = this.commercialAndWeekendSlots;
        }
      } else if (statusLower === "residential" && this.workRequestFlag) {
        this.appointmentOptions = this.workRequestResidentials;
      } else if (statusLower === "commercial" && !this.workRequestFlag) {
        this.appointmentOptions = this.commercialAndWeekendSlots;
      } else if (statusLower === "commercial" && this.workRequestFlag) {
        this.appointmentOptions = this.workRequestCommercial;
      } else {
        this.appointmentOptions = [];
      }
  
  
      console.log("Rendered Slots:", JSON.stringify(this.appointmentOptions));
    }
  
    // --- Helper added for DD/MM/YYYY support ---
    formatDate(dateObj) {
      let d = String(dateObj.getDate()).padStart(2, "0");
      let m = String(dateObj.getMonth() + 1).padStart(2, "0");
      let y = dateObj.getFullYear();
      return `${d}/${m}/${y}`;
    }
  
    handleStartChange(event) {
      const selectedValue = event.currentTarget.dataset.value;
      this.startOptions = this.startOptions.map((opt) => ({
        ...opt,
        isChecked: opt.value === selectedValue,
        className:
          opt.value === selectedValue ? "radio-card selected" : "radio-card",
      }));
      if (selectedValue === "pick") {
        this.showAppointmentSlots = true;
        this.loadSlots();
      } else {
        this.showAppointmentSlots = false;
      }
    }
    loadSlots() {
      const categoryType = this.category ? this.category.toLowerCase() : "";
      if (categoryType === "residential") {
        this.availableSlots = this.residentialSlots;
      } else if (categoryType === "commercial") {
        this.availableSlots = this.commercialSlots;
      } else {
        this.availableSlots = [];
      }
    }
  
    // ---- Asset Section ----
    get assetArray() {
      return Array.isArray(this.assetDetails) ? this.assetDetails : [];
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
  
    // ---- Address Section ----
    get addressArray() {
      // If array already, return directly
      if (Array.isArray(this.addressDetails)) {
        return this.addressDetails;
      }
  
      // If object, convert to array of {label, value}
      if (this.addressDetails && typeof this.addressDetails === "object") {
        return Object.keys(this.addressDetails).map((key) => ({
          label: this._toLabel(key),
          value: this.addressDetails[key] || " ",
        }));
      }
  
      return [];
    }
  
    get displayedAddressDetails() {
      //  return this.showAllAddress ? this.addressArray : this.addressArray.slice(0, 5);
      return this.showAllAddress ? this.addressArray : this.addressArray;
    }
  
    get hasMoreAddressDetails() {
      return this.addressArray.length > 5;
    }
  
    get addressArrowClass() {
      return this.showAllAddress ? "arrow down" : "arrow right";
    }
  
    get addressToggleText() {
      return this.showAllAddress ? "Less details" : "More details";
    }
  
    toggleAddressExpand() {
      this.showAllAddress = !this.showAllAddress;
    }
  
    handleCancel() {
      this.dispatchEvent(new CustomEvent("canceljob"));
    }
  
    // Helper: Convert camelCase / snake_case to Title Case
    _toLabel(key) {
      if (!key) return "";
      const spaced = key
        .replace(/_/g, " ")
        .replace(/([a-z0-9])([A-Z])/g, "$1 $2");
      return spaced
        .split(" ")
        .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
        .join(" ");
    }
  
    renderedCallback() {
      this.startNowErrorElement = this.template.querySelector(".start-now-error");
    }
  
    isStartNowAllowed() {
      const userType = this.userType;
      const today = new Date();
      const hours = today.getHours();
      const day = today.getDay(); // 0 = Sun, 6 = Sat
  
      // NGM → always allowed
      if (userType === "NGM") {
        return true;
      }
  
      const isWeekend = day === 0 || day === 6;
  
      // Working weekday
      if (!isWeekend && !this.isHoliday) {
        return hours >= 8 && hours < 20;
      }
  
      // Non-working day or holiday
      return hours >= 9 && hours < 17;
    }
  
    connectedCallback() {
      console.log("connectedCallback", JSON.stringify(this.metadataRecord));
      console.log("connectedCallback", this.status);
      console.log("connectedCallback", this.paymentMechanism);
      console.log("postCode >", this.postCode);
      console.log("postCode >", this.mprn);
      this.loadHolidays();
      this.checkNGMUser();
      this.appointmentOptions = this.status;
      console.log("appointmentOptions", this.appointmentOptions);
  
      const data = this.metadataRecord[0].metadatalist;
      this.assetnum = this.metadataRecord[0].assetnum;
      this.suppliercode = this.metadataRecord[0].suppliercode;
      this.location = this.metadataRecord[0].location;
      this.ngme_industry = this.metadataRecord[0].ngme_industry;
      this.meterSize = this.metadataRecord[0].metadatalist[0].NGMCP_Meter_Size__c;
      console.log("meterSize" + this.meterSize);
      this.jobTypes = data.map((item) => ({
        value: item.NGMCP_UWR_Job_Code__c,
        label: item.NGMCP_Portal_Category__c,
        description: item.NGMCP_Job_Description__c, //`${item.NGMCP_Portal_Category__c} - ${item.NGMCP_Meter_Model_Size__c} (${item.NGMCP_Market_Sector_Code__c})`,
        isChecked: false,
        showRecommendation: true,
        className: "radio-card",
      }));
      if (this.jobTypes.length === 1) {
        this.selectedJobType = true;
        this.job_sub_subtype = this.jobTypes[0].value;
      }
      console.log("Processed jobTypes:", JSON.stringify(this.jobTypes));
    }
  
    loadHolidays() {
      getHolidays()
        .then((data) => {
          // normalize holidays as YYYY-MM-DD for comparison
          this.holidays = data.map((h) => {
            const d = new Date(h);
            const yyyy = d.getFullYear();
            const mm = String(d.getMonth() + 1).padStart(2, "0");
            const dd = String(d.getDate()).padStart(2, "0");
            return `${yyyy}-${mm}-${dd}`;
          });
          console.log("Holidays loaded:", this.holidays);
        })
        .catch((error) => {
          console.error("Error loading holidays:", error);
          this.holidays = [];
        });
    }
  
    checkNGMUser() {
      isNGMUser()
        .then((result) => {
          this.isNGMUser = result;
          console.log("Is NGM User:", this.isNGMUser);
          // ADD DEBUG HERE
          console.log("### DEBUG — Checking NGM User Flag ###");
          if (this.isNGMUser) {
            console.log("NGM User: true");
          } else {
            console.log("NGM User: false");
          }
        })
        .catch((error) => {
          console.error("User details errore:", error);
        });
    }
  
    @track requestTypes = [
      {
        value: "work",
        label: "Work request",
        desc: "An ordinary request with several jobs type to choose from",
        isChecked: false,
        className: "radio-card",
        isHidden: false,
      },
      {
        value: "urgent",
        label: "Urgent Work request (Off gas)",
        desc: "An urgent work request for issues to be resolved fast.",
        isChecked: false,
        className: "radio-card",
        isHidden: false,
      },
      {
        value: "amr",
        label: "AMR request",
        desc: "With AMR, you get automatic readings directly in the portal.",
        isChecked: false,
        className: "radio-card",
        isHidden: false,
      },
      {
        value: "deappoint",
        label: "Appoint/De-Appoint",
        desc: "Supporting line text lorem ipsum dolor sit amet, consectetur.",
        isChecked: false,
        className: "radio-card",
        isHidden: false,
      },
      {
        value: "dataQuery",
        label: "Data Queries",
        desc: "Supporting line text lorem ipsum dolor sit amet, consectetur.",
        isChecked: false,
        className: "radio-card",
        isHidden: false,
      },
      {
        value: "tQuery",
        label: "Technical Queries",
        desc: "Supporting line text lorem ipsum dolor sit amet, consectetur.",
        isChecked: false,
        className: "radio-card",
        isHidden: false,
      },
    ];
  
    titles = ["Mr", "Mrs", "Miss", "Ms", "Dr", "Company"];
  
    // Getter to convert titles → picklist options
    get titleOptions() {
      return this.titles.map((t) => ({ label: t, value: t }));
    }
  
    handleCardClick(event) {
      const selectedValue = event.currentTarget.dataset.value;
      const clickedCard = event.currentTarget;
      console.log('clickedCard', clickedCard);
      this.template.querySelectorAll(".radio-card").forEach((card) => {
        card.classList.remove("selected");
        const radio = card.querySelector('input[type="radio"]');
        if (radio) radio.checked = false;
      });
  
      // Highlight clicked card and check radio
      clickedCard.classList.add("selected");
      const radioInput = clickedCard.querySelector('input[type="radio"]');
      console.log('radioInput', radioInput);
      if (radioInput) radioInput.checked = true;
      // ===== END: Highlight card & check radio input =====
  
      console.log("Selected:", selectedValue);
      const jobTypeOptions = ["faulty", "windon"];
      const startOptions = ["now", "pick", "restro"];
  
      const newErrors = { ...this.validationErrors };
      if (newErrors.requestType) delete newErrors.requestType;
      if (startOptions.includes(selectedValue) && newErrors.startOption)
        delete newErrors.startOption;
      if (jobTypeOptions.includes(selectedValue) && newErrors.jobType)
        delete newErrors.jobType;
      this.validationErrors = newErrors;
  
      // Handle request type selections
      if (
        !jobTypeOptions.includes(selectedValue) &&
        !startOptions.includes(selectedValue)
      ) {
        this.requestTypes = this.requestTypes.map((type) => ({
          ...type,
          isChecked: type.value === selectedValue,
          className:
            type.value === selectedValue ? "radio-card selected" : "radio-card",
        }));
      }
  
      switch (selectedValue) {
        case "work":
          this.workRequestFlag = true;
          this.showJobType = false;
          this.enquiryFlag = false;
  
          this.showJobType = false;
          this.showRestro = false;
          this.showAppointment = false;
          this.showAppointmentFields = false;
          this.showcontactdetails = false;
          this.showFaulty = false;
          this.showWindOnOption = false;
          this.showcontactdetails = false;
          this.showBankCalender = false;
          this.keepJobTypesVisible = false;
          this.showUwrRequest = false;
          this.showRestro = false;
  
          // Reset Wind On service partner status
          this.showServicePartnerStatus = false;
          this.servicePartnerStatus = null;
          this.servicePartnerMessage = null;
          this.showWarningMsg = false;
  
          // Reset job types
          /*  this.jobTypes = this.jobTypes.map((job) => ({
              ...job,
              isChecked: false,
              className: "radio-card",
            }));*/
  
          break;
        case "amr":
          this.showWorkRequestChild = false;
          this.showJobType = false;
          this.showRestro = false;
          this.showAppointment = false;
          this.showAppointmentFields = false;
          this.showcontactdetails = false;
          this.deappointmentFlag = false;
  
          break;
        case "deappoint":
          this.showWorkRequestChild = false;
          this.showJobType = false;
          this.showRestro = false;
          this.showAppointment = false;
          this.showAppointmentFields = false;
          this.showcontactdetails = false;
          this.workRequestFlag = false;
          this.enquiryFlag = false;  
          this.techEnquiryFlag = false;
          this.deappointmentFlag = true;
          break;
        case "urgent":
          this.workRequestFlag = false;
          this.cwrdescription = '';
          this.enquiryFlag = false;
          this.showAppointmentFields = false;
          this.showJobType = true;
          this.showFaulty = true;
          this.job_type = "OTVST";
          this.job_subtype = "FAULT";
          this.source = "PORTAL";
          this.keepJobTypesVisible = true;
          this.deappointmentFlag = false;
  
          // Render Wind On if Residential + Prepayment
          if (
            this.status?.toLowerCase() === "residential" &&
            this.paymentMechanism?.toLowerCase() === "pre payment"
          ) {
            this.showWindOnOption = true;
          } else {
            this.showWindOnOption = false;
          }
  
          // Reset Service Partner info when Urgent Work Request is clicked again
          this.showServicePartnerStatus = false;
          this.servicePartnerStatus = null;
          this.servicePartnerMessage = null;
          this.showWarningMsg = false;
  
          //  Auto-select the first Job Type (or specific one)
          if (this.jobTypes && this.jobTypes.length > 0) {
            const defaultJobType = this.jobTypes[0].value; // first job type
            console.log("defaultJobType >>", defaultJobType);
            this.jobTypes = this.jobTypes.map((job) => ({
              ...job,
              isChecked: job.value === defaultJobType,
              className:
                job.value === defaultJobType
                  ? "radio-card selected"
                  : "radio-card",
            }));
            this.showAppointment = true;
            this.selectedJobType = defaultJobType;
            // this.job_subtype = defaultJobType.toUpperCase();
          }
  
          //  Optional: show service partner info if needed
          if (this.selectedJobType === "windon") {
            this.fetchServicePartnerStatus();
          } else {
            this.showServicePartnerStatus = false;
          }
  
          if (this.selectedJobType) {
            this.showAppointment = true;
          }
          break;
  
        case "windon":
        case "faulty":
          this.jobTypes = this.jobTypes.map((job) => ({
            ...job,
            isChecked: job.value === selectedValue,
            className:
              job.value === selectedValue ? "radio-card selected" : "radio-card",
          }));
  
          this.keepJobTypesVisible = true;
          this.showJobType = true;
          //this.job_subtype = selectedValue.toUpperCase();
  
          // Only fetch Service Partner status for Wind On
          if (selectedValue === "windon") {
            this.fetchServicePartnerStatus();
          } else {
            this.showServicePartnerStatus = false;
          }
          break;
        case "now":
          this.appointmentType = "Start now";
          this.startOptions = this.startOptions.map((opt) => ({
            ...opt,
            isChecked: opt.value === selectedValue,
            className:
              opt.value === selectedValue ? "radio-card selected" : "radio-card",
          }));
  
          this.selectedStartOption = "now";
          this.showAppointment = true;
          const now = new Date();
          const result = this.validateStartNow();
  
          // if (!result.allowed) {
          //     this.validationErrors.startNow =
          //         "You cannot submit an immediate start urgent work request during non working hours. Please reach out to 0800 111 999 if this is needed immediately.";
  
          //     this.startNowFlag = false;
          //     return;
          // }
          if (!result.allowed) {
            this.validationErrors.startNow =
              "You cannot submit an immediate start urgent work request during non working hours. Please reach out to 0800 111 999 if this is needed immediately.";
            this.startNowFlag = false;
            // ensure UI still updates properly
            this.showAppointment = true;
            this.showRestro = false;
            this.showAppointmentFields = false;
            return;
          }
  
          delete this.validationErrors.startNow;
          this.startNowFlag = true;
  
          // Other UI flags
          this.showUwrRequest = true;
          this.showRestro = false;
          this.showcontactdetails = true;
          this.showAppointmentFields = false;
          this.showBankCalender = true;
  
          this.pickupDateFlag = false;
          this.retrospectiveFlag = false;
  
          this.selectedDate = null;
          this.selectedSlot = null;
          this.selectedSlotLabel = "";
          this.appointmentOptions = [];
          this.validationErrors.appointmentDate = null;
          this.validationErrors.appointmentSlot = null;
          this.targetstart = now.toISOString().split("T")[0];
          this.ngme_time = now.toTimeString().slice(0, 5);
          this.ngme_liferay_slot = "AT";
  
          break;
  
        case "pick":
          this.appointmentType = "Pick Date/Time";
          this.selectedStartOption = '';
          this.startNowFlag = false;
          this.startOptions = this.startOptions.map((opt) => ({
            ...opt,
            isChecked: opt.value === selectedValue,
            className:
              opt.value === selectedValue ? "radio-card selected" : "radio-card",
          }));
          console.log("pick", selectedValue);
          this.showUwrRequest = false;
          this.pickupDateFlag = true;
          this.updateAppointmentSlots();
          this.showAppointmentFields = true;
          this.showcontactdetails = true;
          this.showRestro = false;
          this.selectedSlot = null;
          this.appointmentOptions = [];
          delete this.validationErrors.startNow;
  
          break;
  
        case "restro":
          this.appointmentType = "Retrospective";
          this.selectedStartOption = '';
          this.startNowFlag = false;
          this.startOptions = this.startOptions.map((opt) => ({
            ...opt,
            isChecked: opt.value === selectedValue,
            className:
              opt.value === selectedValue ? "radio-card selected" : "radio-card",
          }));
          this.showRestro = true;
          this.showUwrRequest = false;
          this.showAppointmentFields = false;
          this.showBankCalender = false;
          this.showcontactdetails = true;
          this.retrospectiveFlag = true;
          this.selectedSlot = null;
          this.appointmentOptions = [];
          delete this.validationErrors.startNow;
  
          break;
        case "dataQuery":
          this.queryvalue ='AST';
          this.enquiryFlag = true;        
          this.workRequestFlag = false;
          this.deappointmentFlag = false;
          break;
        case "tQuery":
          this.queryvalue ='TQUERY';
          this.enquiryFlag = false;
          this.techEnquiryFlag = true;
          this.workRequestFlag = false;
          this.deappointmentFlag = false;
          break;
        
        default:
          // Reset everything else
          this.showJobType = false;
          this.showFaulty = false;
          this.showWindOnOption = false;
          this.showAppointmentFields = false;
          this.showcontactdetails = false;
          this.showBankCalender = false;
          this.keepJobTypesVisible = false;
          this.showUwrRequest = false;
          this.showRestro = false;
  
          // Reset Wind On service partner status
          this.showServicePartnerStatus = false;
          this.servicePartnerStatus = null;
          this.servicePartnerMessage = null;
          this.showWarningMsg = false;
  
          // Reset job types
          this.jobTypes = this.jobTypes.map((job) => ({
            ...job,
            isChecked: false,
            className: "radio-card",
          }));
          break;
      }
      const value = event.currentTarget.dataset.value;
      if (["urgent", "work", "amr", "deappoint"].includes(value)) {
        this.removeFieldError("requestType");
      }
      if (["now", "pick", "restro"].includes(value)) {
        this.removeFieldError("startOption");
      }
      if (["faulty", "windon"].includes(value)) {
        this.removeFieldError("jobType");
      }
      if (value === "pick" || value === "restro") {
        this.selectedDate = null;
        this.selectedSlot = null;
        this.selectedSlotLabel = "";
        this.appointmentOptions = []; // optional clear dropdown list
  
        // Clear any previous validation errors
        this.removeFieldError("appointmentDate");
        this.removeFieldError("appointmentSlot");
      }
  
      //  Remove startOption-level validation error when user selects one
      if (this.validationErrors && this.validationErrors.startOption) {
        this.removeFieldError("startOption");
      }
    }
  
    validateStartNow() {
      console.log("🔥 validateStartNow() START");
  
      try {
        // --------------------------------------------
        // 1) SAFE UK TIME — WORKS IN LOCKERSERVICE
        // --------------------------------------------
        const nowUTC = new Date();
  
        // Detect BST (DST)
        const jan = new Date(nowUTC.getFullYear(), 0, 1).getTimezoneOffset();
        const jul = new Date(nowUTC.getFullYear(), 6, 1).getTimezoneOffset();
        const stdOffset = Math.max(jan, jul);
        const currentOffset = nowUTC.getTimezoneOffset();
        const isBST = currentOffset < stdOffset;
  
        // Convert UTC → UK
        const ukTime = new Date(nowUTC.getTime() + (isBST ? 1 : 0) * 3600 * 1000);
  
        console.log("🇬🇧 UK Time (computed):", ukTime.toString());
  
        const ukHour = ukTime.getHours();
        const ukMinutes = ukTime.getMinutes();
        const nowDecimal = ukHour + ukMinutes / 60;
  
        console.log(
          "Hour:",
          ukHour,
          "Minutes:",
          ukMinutes,
          "Decimal:",
          nowDecimal
        );
  
        // -------------------------------------------------------
        // 2) Build UK ISO date
        // -------------------------------------------------------
        const yyyy = ukTime.getFullYear();
        const mm = String(ukTime.getMonth() + 1).padStart(2, "0");
        const dd = String(ukTime.getDate()).padStart(2, "0");
        const todayISO = `${yyyy}-${mm}-${dd}`;
  
        console.log("Today ISO:", todayISO);
  
        // -------------------------------------------------------
        // 3) Check weekend / holiday
        // -------------------------------------------------------
        const ukDay = ukTime.getDay(); // 0=Sun, 6=Sat
        const isWeekend = ukDay === 0 || ukDay === 6;
        const isHoliday = this.holidays?.includes(todayISO);
  
        console.log("Weekend:", isWeekend);
        console.log("Holiday:", isHoliday);
  
        // -------------------------------------------------------
        // 4) Business Rules
        // -------------------------------------------------------
        const isResidential = this.status?.toLowerCase() === "residential";
        const isCommercial = this.status?.toLowerCase() === "commercial";
  
        let startHour = 0;
        let endHour = 0;
  
        if (isResidential) {
          if (isWeekend || isHoliday) {
            startHour = 9;
            endHour = 17;
          } else {
            startHour = 8;
            endHour = 20;
          }
        } else if (isCommercial) {
          startHour = 9;
          endHour = 17;
        }
  
        console.log(`Allowed window: ${startHour} - ${endHour}`);
  
        // -------------------------------------------------------
        // 5) Final Evaluation
        // -------------------------------------------------------
        const allowed = nowDecimal >= startHour && nowDecimal <= endHour;
  
        console.log("👉 Allowed StartNow =", allowed);
  
        return { allowed };
      } catch (error) {
        console.error("❌ Error in validateStartNow():", error);
        return { allowed: false };
      }
    }
  
    handleInputChange(event) {
      const field = event.target.name;
      const value =
        event.target.type === "checkbox"
          ? event.target.checked
          : event.target.value;
  
      if (!this.contactDetails) this.contactDetails = {};
      if (field) this.contactDetails[field] = value;
  
      // Make a copy of errors so we can mutate cleanly
      let errors = { ...this.validationErrors };
  
      // --- CONTACT NUMBER VALIDATION ---
      // if (field === "contactNumber") {
      //   const trimmedValue = value ? value.trim() : "";
      //   const phonePattern = /^[0-9]{10}$/;
  
      //   if (!trimmedValue) {
      //     errors.contactNumber = "Contact number is required.";
      //   } else if (!phonePattern.test(trimmedValue)) {
      //     errors.contactNumber = "Please enter a valid 11-digit contact number.";
      //   }else if (trimmedValue.length > 11) {
      //     errors.contactNumber = "Contact Number cannot exceed 11 characters.";
      //   } else {
      //     delete errors.contactNumber;
      //   }
      // }
  
      if (field === "contactNumber") {
        const trimmedValue = value ? value.trim() : "";
        const phonePattern = /^[0-9]+$/;
  
        // Required check
        if (!trimmedValue) {
          errors.contactNumber = "Contact number is required.";
        }
        // Only numbers allowed
        else if (!phonePattern.test(trimmedValue)) {
          errors.contactNumber = "Only numbers are allowed.";
        }
        // Max 11 characters (LIVE error as soon as user types 12th)
        else if (trimmedValue.length > 11) {
          errors.contactNumber = "Please enter a valid 11-digit contact number.";
        }
        // Exact 11-digit validation
        else if (trimmedValue.length !== 11) {
          errors.contactNumber = "Please enter a valid 11-digit contact number.";
        } else {
          delete errors.contactNumber;
        }
      }
  
      // --- NAME VALIDATION ---
      if (field === "name") {
        const trimmedValue = value ? value.trim() : "";
        if (!trimmedValue) {
          errors.name = "Name is required.";
        } else if (trimmedValue.length > 30) {
          errors.name = "Name cannot exceed 30 characters.";
        } else {
          delete errors.name;
        }
      }
  
      // --- TITLE VALIDATION (NEW) ---
      if (field === "title") {
        if (!value || value === "") {
          errors.title = "Title is required.";
        } else {
          delete errors.title;
        }
      }
  
      // --- TITLE VALIDATION (NEW) ---
      if (field === "consent") {
        if (!value || value === "") {
          errors.consent = "consent is required.";
        } else {
          delete errors.consent;
        }
      }
  
      // --- EMAIL ADDRESS VALIDATION ---
      /* if (field === "emailAddress") {
         const trimmedValue = value ? value.trim() : "";
         const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
   
         if (!trimmedValue) {
           errors.emailAddress = "Email address is required.";
         } else if (!emailPattern.test(trimmedValue)) {
           errors.emailAddress = "Please validate the Email Provided";
         } else if (trimmedValue.length > 40) {
           errors.emailAddress = "Email address cannot exceed 40 characters.";
         } else {
           delete errors.emailAddress;
         }
       }*/
  
      // --- INSTRUCTIONS CHARACTER COUNTER ---
      if (field === "instructions") {
        this.remainingChars = 255 - value.length;
        if (this.remainingChars < 0) {
          this.contactDetails.instructions = value.slice(0, 255);
          this.remainingChars = 0;
        }
      }
  
      this.validationErrors = errors;
      console.log("Updated contactDetails:", JSON.stringify(this.contactDetails));
    }
  
    handleAppointmentDateChange(event) {
      this.appointmentDate = event.target.value;
  
      //  Clear validation reactively
      if (this.validationErrors.appointmentDate) {
        const newErrors = { ...this.validationErrors };
        delete newErrors.appointmentDate;
        this.validationErrors = newErrors;
      }
    }
  
    handleSlotSelect(event) {
      this.selectedSlot = event.target.value;
  
      //Clear validation reactively
      if (this.validationErrors.appointmentSlot) {
        const newErrors = { ...this.validationErrors };
        delete newErrors.appointmentSlot;
        this.validationErrors = newErrors;
      }
    }
  
    handleTitleChange(event) {
      this.contactDetails.title = event.target.value;
      if (this.contactDetails.title) {
        // Remove validation error once title is selected
        delete this.validationErrors.title;
        this.validationErrors = { ...this.validationErrors };
      }
    }
  
    handleCancelClick() {
      this.dispatchEvent(new CustomEvent("cancelcreatejob"));
    }
  
    handleUrgentWorkRequest(event) {
      const selected = event.target.value;
      this.showUrgentCategories = selected === "Urgent";
      if (this.showUrgentCategories) {
        this.urgentOptions = this.metadataRecord.map((item) => ({
          label: item.NGMCP_Portal_Category__c,
          value: item.NGMCP_Portal_Category__c,
        }));
      }
    }
  
    handleCategorySelect(event) {
      try {
        console.log("handleCategorySelect invoked");
        // Defensive checks to avoid "undefined" crashes
        if (!event || !event.target) {
          console.error("Event or target missing in handleCategorySelect");
          return;
        }
        const selectedValue =
          event.target.dataset?.value ||
          event.currentTarget.dataset?.value ||
          event.target.value ||
          "";
        // The input that fired the event
        const radioInput = event.currentTarget; // or event.target for click/change
        console.log('radioInput:', radioInput); // should NOT be null
  
        // Find the containing card (works for both <div class="radio-card"> and <label class="radio-card">)
        const clickedCard = radioInput.closest('.radio-card');
        console.log('clickedCard:', clickedCard);
  
        // If this is null, the ancestor doesn't have class="radio-card".
        // Ensure your template renders that class exactly.
        if (!clickedCard) return;
  
        // Clear previous selections
        this.template.querySelectorAll('.radio-card').forEach(card => {
          card.classList.remove('selected');
          const r = card.querySelector('input[type="radio"]');
          if (r) r.checked = false;
        });
  
        // Apply selection to the clicked card
        clickedCard.classList.add('selected');
        radioInput.checked = true;
  
        // Read the selected value
        const selectedValue1 = radioInput.dataset.value || radioInput.value;
  
        // Drive state (recommended): update jobTypes isChecked
        this.jobTypes = this.jobTypes.map(j => ({
          ...j,
          isChecked: j.value === selectedValue1,
          className: j.value === selectedValue1 ? 'radio-card selected' : 'radio-card',
        }));
        ;
  
        console.log("Selected Value:", selectedValue);
  
        if (!selectedValue) {
          console.warn("No selected value found, exiting handleCategorySelect");
          return;
        }
        if (this.keepJobTypesVisible) {
          this.showJobType = true;
          this.showFaulty = true;
        }
        if (Array.isArray(this.jobTypes)) {
          this.jobTypes = this.jobTypes.map((job) => ({
            ...job,
            isChecked: job.value === selectedValue,
            className:
              job.value === selectedValue ? "radio-card selected" : "radio-card",
          }));
        }
        this.selectedJobType = selectedValue;
        //this.job_subtype = selectedValue.toUpperCase();
  
        console.log("Updated job_subtype:", this.job_subtype);
        if (selectedValue.toLowerCase() === "windon") {
          console.log("Fetching Service Partner status for Wind On...");
          this.windonFlag = true;
          if (!this.isNGMUser) {
            this.job_sub_subtype = "WOS XX XX";
            console.log("windonQuestionFlag sub Type", this.job_sub_subtype);
          } else {
            this.windonQuestionFlag = true;
          }
          this.fetchServicePartnerStatus();
        } else {
          this.showServicePartnerStatus = false;
          this.windonQuestionFlag = false;
        }
      } catch (error) {
        console.error("Error in handleCategorySelect:", error);
      }
    }
  
    async fetchServicePartnerStatus() {
      console.log("fetchServicePartnerStatus called");
      try {
        if (!this.postCode) {
          console.warn("No post code found — skipping Service Partner check");
          this.showServicePartnerStatus = false;
          return;
        }
  
        // const cleanedCode = this.postCode.replace(/\s/g, "").toUpperCase();
        const cleanedCode = this.postCode;
        console.log("Cleaned post code:", cleanedCode);
  
        const status = await getServicePartnerStatus({ postCode: cleanedCode });
        console.log("Service Partner status:", status);
  
        if (!status) {
          this.showServicePartnerStatus = false;
          return;
        }
  
        this.showServicePartnerStatus = true;
        this.servicePartnerStatus = status;
        console.log("Service color is :", this.servicePartnerStatus);
        // Set color box class and message
        if (status.toLowerCase() === "green") {
          this.servicePartnerBoxClass = "green-box";
          this.servicePartnerMessage = "Service Partner available";
        } else if (status.toLowerCase() === "amber") {
          this.servicePartnerBoxClass = "amber-box";
          this.servicePartnerMessage =
            "Service Partner seems to be busy, please book cautiously";
        } else if (status.toLowerCase() === "red") {
          this.servicePartnerBoxClass = "red-box";
          this.servicePartnerMessage =
            "Service Partner seems to be busy, please book cautiously";
        }
      } catch (error) {
        console.error("Error fetching Service Partner status:", error);
        this.showServicePartnerStatus = false;
      }
    }
  
    get statusBoxStyle() {
      return `width: 30px; height: 30px; background-color: ${this.servicePartnerColor}; border-radius: 4px; display: inline-block; margin-right: 10px;`;
    }
  
  
  
    /* ============================
     * MAIN SUBMIT HANDLER
     * ============================ */
    async handleSubmitUrgentWorkrequest(event) {
      event.preventDefault();
      console.log("handleSubmitUrgentWorkrequest called");
  
      this.validationErrors = {};
  
      // 1️⃣ Required field validation
      if (!this.validateRequiredFields()) {
        this.scrollToError();
        return;
      }
  
      // 2️⃣ Appointment validation
      if (!this.validateAppointment()) {
        this.scrollToError();
        return;
      }
  
      // 3️⃣ Business rules (flag based)
      const allowed = await this.validateBusinessRules();
      if (!allowed) return;
  
      // 4️⃣ Consent
      if (!this.contactDetails?.consent) {
        this.validationErrors.consent =
          "Please confirm that consent has been obtained before submitting.";
        this.scrollToError();
        return;
      }
  
      // 5️⃣ Submit
      if (!this.workRequestFlag) {
        await this.submitUrgentWorkRequestFlow();
      } else {
        await this.submitcreateworkRequestFlow();
      }
  
    }
  
    /* ============================
     * FLAG CONTEXT
     * ============================ */
    get flagContext() {
      return {
        isStartNow: this.selectedStartOption === "now",
        isWindOn: this.windonFlag,
        isNGMUser: this.isNGMUser,
        partnerStatus: this.servicePartnerStatus
      };
    }
  
    /* ============================
     * REQUIRED FIELD VALIDATION
     * ============================ */
    validateRequiredFields() {
      let isValid = true;
      this.validationErrors = {};
  
      const requiredFields = [
        { name: "requestType", label: "Request type" },
        { name: "jobType", label: "Job type", visible: this.showJobType || this.showWindOnOption },
        { name: "startOption", label: "Select start", visible: this.showAppointment },
        { name: "title", label: "Title", visible: this.showcontactdetails },
        { name: "name", label: "Name", visible: this.showcontactdetails },
        { name: "contactNumber", label: "Contact number", visible: this.showcontactdetails },
        { name: "consent", label: "Consent", visible: true }
      ];
  
      requiredFields.forEach(field => {
        if (field.visible === false) return;
  
        const inputs = this.template.querySelectorAll(`[name="${field.name}"]`);
        if (!inputs || inputs.length === 0) return;
  
        let value;
        if (inputs.length > 1) {
          value = [...inputs].find(i => i.checked)?.value;
        } else {
          const input = inputs[0];
          value = input.type === "checkbox" ? input.checked : input.value;
        }
  
        if (!value) {
          this.validationErrors[field.name] = `${field.label} is required`;
          isValid = false;
        }
      });
  
      // Contact number
      if (this.contactDetails?.contactNumber) {
        const phone = this.contactDetails.contactNumber.trim();
        if (!/^[0-9]{11}$/.test(phone)) {
          this.validationErrors.contactNumber =
            "Please enter a valid 11-digit contact number.";
          isValid = false;
        }
      }
  
      // Name
      if (this.contactDetails?.name) {
        const name = this.contactDetails.name.trim();
        if (!name) {
          this.validationErrors.name = "Name is required.";
          isValid = false;
        } else if (name.length > 30) {
          this.validationErrors.name =
            "Name cannot exceed 30 characters.";
          isValid = false;
        }
      }
  
      // Email (optional)
      if (this.contactDetails?.emailAddress) {
        const email = this.contactDetails.emailAddress.trim();
        if (
          !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) ||
          email.length > 40
        ) {
          this.validationErrors.emailAddress =
            "Enter a valid email address (max 40 chars).";
          isValid = false;
        }
      }
  
      return isValid;
    }
  
    /* ============================
     * APPOINTMENT VALIDATION
     * ============================ */
    validateAppointment() {
      const shouldValidate =
        this.showRestro ||
        this.showAppointmentFields ||
        this.showAppointmentSlots ||
        this.startOption === "pick";
  
      if (shouldValidate && !this.selectedDate) {
        this.validationErrors.appointmentDate =
          "Appointment Date is required";
        return false;
      }
  
      if (shouldValidate && !this.selectedSlot) {
        this.validationErrors.appointmentSlot =
          "Appointment Slot is required";
        return false;
      }
  
      return true;
    }
  
    /* ============================
     * BUSINESS RULES (FLAGS)
     * ============================ */
    async validateBusinessRules() {
      const ctx = this.flagContext;
  
      // Start Now window
      if (ctx.isStartNow) {
        const result = this.validateStartNow();
        if (!result.allowed) {
          this.validationErrors.startNow = result.message;
          return false;
        }
      }
  
      // Wind On rules (Non NGM)
      if (!ctx.isNGMUser && ctx.isWindOn && ctx.isStartNow) {
  
        if (ctx.partnerStatus === "Amber") {
          this.showServiceError(
            "Wind On request cannot be booked via portal due to limited availability, please call NGM direct on 0800 001 4340"
          );
          return false;
        }
  
        if (ctx.partnerStatus === "Red") {
          this.showServiceError(
            "Wind On request cannot be booked via portal due to no availability, please try again later"
          );
          return false;
        }
  
        const count =
          await getPreviousUrgentWorkRequestHistoryForMPRN({
            mprnNumber: this.location
          });
  
        if (count >= 5) {
          this.showServiceError(
            "Wind On cannot be booked via portal due to request limit being exceeded in last 30 days. Please call NGM direct on 0800 001 4340"
          );
          return false;
        }
      }
  
      // NGM warning
      if (ctx.isNGMUser && ctx.isWindOn && ctx.partnerStatus !== "Green") {
        this.showCautionMessage = true;
        setTimeout(() => (this.showCautionMessage = false), 3000);
      }
  
      return true;
    }
  
    /* ============================
     * SAFE JSON PARSE
     * ============================ */
    safeParse(val) {
      if (typeof val === "string") {
        try {
          return JSON.parse(val);
        } catch (e) {
          console.error("Invalid JSON:", e);
          return val;
        }
      }
      return val;
    }
  
    /* ============================
     * BUILD ADDITIONAL INFO
     * ============================ */
    buildAdditionalInfo() {
      this.addressDetails = this.safeParse(this.addressDetails);
      this.assetDetails = this.safeParse(this.assetDetails);
  
      const mapByApi = Array.isArray(this.addressDetails)
        ? new Map(this.addressDetails.map(i => [i.apiName, i.value]))
        : new Map(Object.entries(this.addressDetails || {}));
  
      const assetLabelMap = Array.isArray(this.assetDetails)
        ? new Map(this.assetDetails.map(i => [i.label, i.value]))
        : new Map();
  
      const toIso = (s) => {
        if (!s) return "";
        const [dd, mm, yyyy] = s.split("-");
        return dd && mm && yyyy ? `${yyyy}-${mm}-${dd}` : s;
      };
  
      const fields = {
        NGMCP_Manufacturer__c: assetLabelMap.get("Manufacturer"),
        NGMCP_Model__c: assetLabelMap.get("Model"),
        NGMCP_Manufacturer_Serial_No__c:
          assetLabelMap.get("Manufacturer Serial no."),
        NGMCP_Meter_Type__c: assetLabelMap.get("Meter Type"),
        NGMCP_No_of_Dials__c: assetLabelMap.get("No. of Dials"),
        NGMCP_Payment_Mechanism__c:
          assetLabelMap.get("Payment Mechanism"),
        NGMCP_Year_of_Manufacture__c:
          assetLabelMap.get("Year of Manufacture"),
        NGMCP_LocationsId__c:
          assetLabelMap.get("Location"),
        NGMCP_Install_Date__c:
          toIso(assetLabelMap.get("Install Date")),
        NGMCP_Measuring_Capacity__c:
          assetLabelMap.get("Measuring Capacity"),
        NGMCP_Building_Number__c:
          mapByApi.get("buildingNumber"),
        NGMCP_Building_Name__c:
          mapByApi.get("buildingName"),
        NGMCP_Street__c:
          mapByApi.get("street"),
        NGMCP_Dependent_Locality__c:
          mapByApi.get("dependentLocality"),
        NGMCP_Postal_Town__c:
          mapByApi.get("postalTown"),
        NGMCP_Postal_Code__c:
          mapByApi.get("postCode"),
        NGMCP_Job_Code_Description__c:
          this.windonFlag ? "Wind On" : (this.jobTypes?.[0]?.label ?? ""),
        NGMCP_Appointment_Type__c:
          this.appointmentType,
        NGMCP_Wind_On_requested_by__c:
          this.windOnRequestedBy ?? "",
        NGMCP_Residential_U6__c:
          this.isResidential ?? ""
      };
  
      return Object.entries(fields)
        .filter(([_, v]) => v != null && String(v).trim() !== "")
        .map(([name, value]) => ({ name, value }));
    }
  
    /* ============================
     * BUILD PAYLOAD
     * ============================ */
    buildUrgentWorkPayload() {
      return {
        reportedpriority: this.reportedpriority,
        job_type: this.job_type,
        ngme_consphone: this.contactDetails.contactNumber,
        description_longdescription:
          this.contactDetails.instructions,
        job_subtype: this.job_subtype,
        targetstart: this.targetstart,
        ngme_time: this.ngme_time,
        source: this.source,
        job_sub_subtype: this.job_sub_subtype,
        ngme_liferay_slot: this.ngme_liferay_slot,
        ngme_lf_mksctcd: this.ngme_industry,
        assetnum: this.assetnum,
        suppliercode: this.suppliercode,
        location: this.location,
        ngme_constitle: this.contactDetails.title,
        ngme_consemail: this.contactDetails.emailAddress,
        building_name: this.addressDetails?.buildingName,
        ngme_consname: this.contactDetails.name,
        additionalinfo: this.buildAdditionalInfo()
      };
    }
  
    /* ============================
     * SUBMIT FLOW
     * ============================ */
   async submitUrgentWorkRequestFlow() {
  console.log(
    'uploadedFilePayload length:',
    this.uploadedFilePayload?.length
  );

  try {
    this.isLoading = true;

    // 1️⃣ Build payload
    const payload = await this.buildUrgentWorkPayload();
    console.log('Payload:', JSON.stringify(payload, null, 2));

    // 2️⃣ Create Salesforce request record
    const requestResponse =
      await createUrgentWorkRequestRecord({
        requestBody: JSON.stringify(payload),
        recordTypeValue: 'Urgent Work Request'
      });

    if (!requestResponse || !requestResponse.id) {
      console.error('Request creation failed', requestResponse);
      return;
    }

    const recordId = requestResponse.id;
    console.log('Record ID:', recordId);
    // 3️⃣ Upload files (only if files exist)
    if (this.uploadedFilePayload?.length > 0) {
      const isUploaded = await uploadFiles({
        recordId,
        files: JSON.stringify(this.uploadedFilePayload)
      });

      if (!isUploaded) {
        console.error('File upload failed');
        return;
      }
    }

    // 4️⃣ Remove internal-only data before API call
    const apiPayload = { ...payload };
    delete apiPayload.additionalinfo;

    // 5️⃣ Call external system
    const response = await submitUrgentWorkRequest({
      requestBody: JSON.stringify(apiPayload),
      requestId: recordId
    });

    const parsed =
      typeof response === 'string'
        ? JSON.parse(response)
        : response;
    console.log('parsed'+JSON.stringify(parsed.ticketid));
    console.log('parsed'+JSON.stringify(parsed.ticketuid));
    // 6️⃣ Success UI handling
    if (parsed?.ticketid) {
      const uploadRequest = await uploadtoMAximoSystem({
        files: JSON.stringify(this.uploadedFilePayload),
        srticket: parsed.ticketid,
        uid: parsed.ticketuid
      });
      console.log('uploadRequest', uploadRequest);
      this.isModel = true;
      this.srNumber = parsed.ticketid;
      this.submittedDate =
      this.formatDateToDDMMYYYY(new Date());
      this.buildEngineerVisitMessage();
    }

  } catch (e) {
    console.error('Submission failed', e);
  } finally {
    this.isLoading = false;
  }
}

    // --- Helpers (class-level) ---
  
    // Safe parse if available; otherwise passthrough
    safe(obj) {
      try { return this.safeParse ? this.safeParse(obj) : obj; } catch { return obj; }
    }
  
    // Map conversions
    toMapFromArray(arr, keyProp, valProp) {
      if (!Array.isArray(arr)) return new Map();
      return new Map(arr.map(i => [i[keyProp], i[valProp]]));
    }
    toMapFromObject(obj) {
      return new Map(Object.entries(obj || {}));
    }
    toObject(map) {
      try { return Object.fromEntries(map ?? []); } catch { return {}; }
    }
  
    // Normalizers
    normalizeLower(s) {
      return (s ?? '').toString().trim().toLowerCase();
    }
    normalizePressure(s) {
      return (s ?? '').toString().replace(/\s+/g, '').toLowerCase(); // "High Pressure" -> "highpressure"
    }
  
    // Y/N coercion
    asYN(val) {
      const v = (val ?? '').toString().trim().toLowerCase();
      if (v === 'true' || v === 'y' || v === 'yes') return 'Y';
      if (v === 'false' || v === 'n' || v === 'no') return 'N';
      return (val ?? '').toString().trim();
    }
  
    // Date flip "dd-mm-yyyy" -> "yyyy-mm-dd" (if applicable)
    toIso(s) {
      if (!s || typeof s !== 'string') return '';
      const [dd, mm, yyyy] = s.split('-');
      return (dd && mm && yyyy) ? `${yyyy}-${mm}-${dd}` : s;
    }
    // ===== VALUE RESOLVER =====
    resolveValue(mapping) {
  
      console.log('CMDT RECORD →', JSON.stringify(mapping));
      console.log('State →', JSON.stringify(this.statemap));
      console.log('ASSET→', JSON.stringify(this.assetLabelMap));
  
      switch (mapping.NGMCP_Source_Map__c) {
  
        case 'State':
          console.log('inside the assest');
          return this.statemap.get(mapping.NGMCP_Source_Key__c);
  
        case 'Asset':
          return this.assetLabelMap.get(mapping.NGMCP_Source_Key__c);
        case 'Address':
          return this.addressDetails?.[mapping.NGMCP_Source_Key__c] ?? "";
        case 'Literal':
          if (mapping.NGMCP_Salesforce_Field_API__c === 'NGMCP_Job_Type__c') {
            return this.job_type;
          }
          if (mapping.NGMCP_Salesforce_Field_API__c === 'NGMCP_Job_SubType__c') {
            return this.job_subtype;
          }
        case 'Computed':
          if (mapping.NGMCP_Salesforce_Field_API__c === 'NGMCP_Non_Standard__c') {
            return this.successprice ? "No" : "Yes";
          }
          if (mapping.NGMCP_Salesforce_Field_API__c === 'NGMCP_Quotation_Status__c') {
            return this.successprice ? " " : "Quotation In Progress";
          }
          if (mapping.NGMCP_Salesforce_Field_API__c === '	NGMCP_Asset_type__c') {
            return this.job_subtype === "Converter" ? "CONVR" : "METER";
          }
        default:
          return null;
      }
    }
    VALUE_MAP = {
      // Question 5 - NGME_LF_MXPRES
      NGME_LF_MXPRES: {
        'u6': 'U6',
        'u16': 'U16',
        'u25': 'U25',
        'u40': 'U40',
        'u65': 'U65',
        'u100': 'U100',
        'u160': 'U160',
        'rotary': 'R',
        'turbine': 'T'
      },
  
      // Question 6 - NGME_REQPAY
      NGME_REQPAY: {
        'credit': 'CR',
        'pre payment': 'PP',
        'prepayment': 'PP',
        'pre-pay': 'PP',
        'pre paid': 'PP'
      },
  
      // Question 8 - NGME_HOUSETYPE
      NGME_HOUSETYPE: {
        'free standing': 'F',
        'freestanding': 'F',
        'wall mounted': 'W'
      },
  
      // Question 18 - NGME_LFPICKUPTYPE
      NGME_LFPICKUPTYPE: {
        'converter': 'CONVR',
        'meter': 'METER'
      },
  
      // Question 26 - NGME_NMLOCATION
      NGME_NMLOCATION: {
        'existing': 'Existing',
        'new': 'New'
      },
  
      // Question 31 - NGME_NEWSERPRES
      NGME_NEWSERPRES: {
        'increase': 'INR',
        'decrease': 'DCR'
      },
  
      // Question 33 - NGME_REASITVIT
      NGME_REASITVIT: {
        'site visit for enquiry/compliant': 'SVTXXXX',
        'site visit for enquiry/complaint': 'SVTXXXX', // variant
        'ad-hoc': 'ADHOC',
        'adhoc': 'ADHOC',
        'converter re-syncing': 'NGMRSCO',
        'install ems to isolation': 'INSEM01'
          },
          
   NGME_METERTYPE: {
      'diaphragm': 'D',
      'rotary displacement': 'R',
      'diaphragm - synthetic': 'S',
      'turbine': 'T',
      'ultrasonic': 'U',
      'other': 'Z'
    }  
  
    };
  
    
    resolveticketValue(mapping) {
      console.log('CMDT RECORD →', JSON.stringify(mapping));
      console.log('State →', JSON.stringify(this.toObject(this.statemap)));
      console.log('ASSET→', JSON.stringify(this.toObject(this.assetLabelMap)));
  
      // Support both __c and __C if Apex ever returned wrong suffix
      const maximoAttrId = (mapping.NGMCP_IBMMaximo_TicketAPI__c ||
                            mapping.NGMCP_IBMMaximo_TicketAPI__C ||
                            '').toString().trim();
      console.log('MAXIMO ATTR ID', maximoAttrId);
      switch (mapping.NGMCP_Source_Map__c) {
        case 'State': {
          console.log('inside State');
          const raw = this.statemap?.get(mapping.NGMCP_Source_Key__c);
          const trimmed = typeof raw === 'string' ? raw.trim() : raw;
  
          // If we have an explicit mapping for this attribute, apply it
          const mapForAttr = this.VALUE_MAP[maximoAttrId];
          if (mapForAttr) {
            const mapped = mapForAttr[this.normalizeLower(trimmed)];
            if (mapped !== undefined) {
              return mapped; // API code
            }
          }
  
          // Fallback to Y/N mapping or pass-through
          return this.asYN(trimmed);
        }
  
        case 'Asset': {
          console.log('inside Asset');
          const raw = this.assetLabelMap?.get(mapping.NGMCP_Source_Key__c);
          const trimmed = typeof raw === 'string' ? raw.trim() : raw;
           const mapForAttr = this.VALUE_MAP[maximoAttrId];
          if (mapForAttr) {
            const mapped = mapForAttr[this.normalizeLower(trimmed)];
            if (mapped !== undefined) {
              return mapped; // API code
            }
          }
          return this.asYN(trimmed);
        }
  
        default:
          return null;
      }
    }
    // ===== MAIN PAYLOAD BUILDER (CALL ON SUBMIT) =====
    async buildCreateWorkRequestAdditionalInfo() {
  
      console.log('STATE MAP', this.toObject(this.statemap));
      console.log('ASSET MAP', this.toObject(this.assetLabelMap));
      console.log('ADDRESS MAP', this.toObject(this.addressMap));
  
      // Fetch CMDT
      const fieldMappingList = await getCWRFieldMapping();
      console.log('CMDT LIST', JSON.stringify(fieldMappingList));
  
      const fields = [];
  
      fieldMappingList.forEach(m => {
  
        let value = this.resolveValue(m);
  
        console.log(
          `Resolved ${m.NGMCP_Salesforce_Field_API__c} →`,
          value
        );
  
        if (
          value !== null &&
          value !== undefined &&
          !(typeof value === 'string' && value.trim() === '')
        ) {
          fields.push({
            name: m.NGMCP_Salesforce_Field_API__c,
            value: value
          });
        }
      });
  
      console.log('FINAL PAYLOAD', JSON.stringify(fields));
      return fields;
    }
  
    async buildticketrequest() {
      // Debug inputs
      console.log('STATE MAP', this.toObject(this.statemap));
      console.log('ASSET MAP', this.toObject(this.assetLabelMap));
      console.log('ADDRESS MAP', this.toObject(this.addressMap));
  
      // Fetch CMDT rows (make sure Apex returns NGMCP_IBMMaximo_TicketAPI__c, etc.)
      const fieldMappingList = await getCWRFieldMapping();
      console.log('CMDT LIST', JSON.stringify(fieldMappingList));
  
      // Helpers
      const isBlank = (v) =>
        v === null || v === undefined || (typeof v === 'string' && v.trim() === '');
  
      const trimIfString = (v) => (typeof v === 'string' ? v.trim() : v);
  
      const fields = [];
  
      fieldMappingList.forEach((m, idx) => {
        // Resolve value from State/Asset/Literal/Computed
        let value = this.resolveticketValue(m);
        value = trimIfString(value);
  
        // Read Maximo attribute id from CMDT and trim
        const assetattrid = trimIfString(m?.NGMCP_IBMMaximo_TicketAPI__c);
  
        // Only push valid pairs
        if (!isBlank(assetattrid) && !isBlank(value)) {
          fields.push({ assetattrid, alnvalue: value });
        }
      });
  
      console.log('FINAL PAYLOAD', JSON.stringify(fields));
      return fields;
  
    }
  
  
    async buildCreateWorkRequestPayload() {
      // Parse inputs once
      this.addressDetails = this.safe?.(this.addressDetails) ?? this.addressDetails;
      this.assetDetails = this.safe?.(this.assetDetails) ?? this.assetDetails;
      this.stateofWorkRequest = this.safe?.(this.stateofWorkRequest) ?? this.stateofWorkRequest;
  
      // Build Maps
      const addrMap = Array.isArray(this.addressDetails)
        ? this.toMapFromArray(this.addressDetails, 'apiName', 'value')
        : this.toMapFromObject(this.addressDetails);
  
      this.assetLabelMap = Array.isArray(this.assetDetails)
        ? this.toMapFromArray(this.assetDetails, 'label', 'value')
        : new Map();
  
      this.statemap = Array.isArray(this.stateofWorkRequest)
        ? this.toMapFromArray(this.stateofWorkRequest, 'label', 'value')
        : new Map(Object.entries(this.stateofWorkRequest || {})); // <-- FIXED
  
      // Safe logs for Maps
      const toObj = (m) => Object.fromEntries(m ?? []);
      console.log('Asset Label Map', JSON.stringify(toObj(this.assetLabelMap)));
      console.log('State of Work Request', JSON.stringify(toObj(this.statemap)));
      console.log('Address Details', JSON.stringify(toObj(addrMap)));
  
      // Pressure abbreviations (normalized key)
      const pressureMap = {
        highpressure: 'HP',
        mediumpressure: 'MP',
        lowpressure: 'LP',
        intermediatepressure: 'IP',
      };
      
      const metertype = {
        diaphragm: 'D',
        'rotary displacement': 'R',
        'diaphragm - synthetic': 'S',
        turbine: 'T',
        ultrasonic: 'U',
        other: 'Z'
      }
      const NGME_REQPAY = {
        'credit': 'CR',
        'pre payment': 'PP',
        'prepayment': 'PP',
        'pre-pay': 'PP',
        'pre paid': 'PP'
      }
      const normalizePressure = (s) => (s ?? '').replace(/\s+/g, '').toLowerCase();
      const mprn_pres = pressureMap[normalizePressure(this.statemap.get('pressureTier'))] || "";
      
      console.log("Pressure Tier", this.statemap.get('pressureTier'), mprn_pres);
     
  
      // Case-insensitive comparisons
      const normalizeLower = (s) => (s ?? '').toLowerCase();
      const mtype = metertype[normalizeLower(this.assetLabelMap.get('Meter Type') )] || "";
       console.log("Pressure Tier", this.assetLabelMap.get('Meter Type'), mtype);
      const jobTypeLower = normalizeLower(this.job_type);
      const jobSubTypeLower = normalizeLower(this.job_subtype);
      const jobKey = `${this.job_type}_${this.job_subtype}`.replace(/\s+/g, '');
      console.log('REQPAYMENT', NGME_REQPAY[normalizeLower(this.statemap?.get?.('paymentMethod') ?? '')]);
      console.log('ngme_lf_eleint',(this.asYN?.(this.statemap?.get?.('electricInterface')) ?? this.statemap?.get?.('electricInterface')) || "N");
      const jobcodes = await getCWRJobCodes({ jobKey: jobKey });
      console.log('Job Codes', JSON.stringify(jobcodes));
      return {
        reportedpriority: 2,
        job_type: jobcodes?.[0]?.NGMCP_Job_Category__c || '',
        ngme_consphone: this.contactDetails?.contactNumber ?? "",
        description_longdescription: this.contactDetails?.instructions ?? "",
        job_subtype: jobcodes?.[0]?.NGMCP_Job_Sub_category__c || "",
        targetstart: this.targetstart ?? "",
        ngme_time: this.ngme_time ?? "",
        source: this.source ?? "",
        job_sub_subtype: '',
        ngme_lf_mksctcd: this.ngme_industry,
        ngme_liferay_slot: this.ngme_liferay_slot ?? "",
        assetnum: this.assetnum ?? "",
        suppliercode: this.suppliercode ?? "",
        location: this.location ?? "",
        ngme_constitle: this.contactDetails?.title ?? "",
        ngme_consemail: this.contactDetails?.emailAddress ?? "",
        building_name: this.addressDetails?.buildingName ?? "",
        ngme_consname: this.contactDetails?.name ?? "",
        mprn_pres,
        curpayment: NGME_REQPAY[normalizeLower(this.statemap?.get?.('paymentMethod') ?? '')] || NGME_REQPAY[normalizeLower(this.assetLabelMap?.get?.('Payment Mechanism') ?? '')] || "",
        assettype: (jobSubTypeLower === "converter" ? "CONVR" : "METER"),
        newmodel: this.statemap.get('MeterSize') ?? "",
        metmodel: this.assetLabelMap.get('Model') ?? "",
        mettype: mtype,
        status: this.successprice? "DRAFT": "NEW",
        // If backend expects 'Y'/'N' for these, keep asYN here; else use raw values.
        ngme_lf_eleint: (this.asYN?.(this.statemap?.get?.('electricInterface')) ?? this.statemap?.get?.('electricInterface')) || "N",
        ngme_lf_twinpress:(this.asYN?.(this.statemap?.get?.('twinStream')) ?? this.statemap?.get?.('twinStream')) || "N",// this.asYN?.(this.statemap.get('twinStream')) ?? this.statemap.get('twinStream') ?? "N",
        ngme_lf_conventer: (this.asYN?.(this.statemap?.get?.('converterRequired')) ?? this.statemap?.get?.('meterBypass')) || "N",//this.asYN?.(this.statemap.get('converterRequired')) ?? this.statemap.get('converterRequired') ?? "N",
        ngme_lf_bypass: (this.asYN?.(this.statemap?.get?.('meterBypass')) ?? this.statemap?.get?.('meterBypass')) || "N",//this.asYN?.(this.statemap.get('meterBypass')) ?? this.statemap.get('meterBypass') ?? "N",
  
        building_no: this.addressDetails?.buildingNumber ?? "",
        dependentloc: this.addressDetails?.dependentLocality ?? "",
        street: this.addressDetails?.street ?? "",
        posttown: this.addressDetails?.postalTown ?? "",
        postcode: this.addressDetails?.postCode ?? "",
        REQPAYMENT : NGME_REQPAY[normalizeLower(this.statemap?.get?.('paymentMethod') ?? '')]||"",
  
        additionalinfo: await this.buildCreateWorkRequestAdditionalInfo(),
        ticketspec: await this.buildticketrequest(),
      };
    }
  
    async submitcreateworkRequestFlow() {
      try {
        this.isLoading = true;
  
        const payload = await this.buildCreateWorkRequestPayload();
        console.log("Payload:", JSON.stringify(payload, null, 2));
  
        const requestId =
          await createUrgentWorkRequestRecord({
            requestBody: JSON.stringify(payload),
            recordTypeValue: "Customer Work Request"
          });
        console.log("requestId", requestId);
        if (!requestId) return;
  
        delete payload.additionalinfo;
        console.log("Payload:", JSON.stringify(payload, null, 2));
        const response =
          await submitUrgentWorkRequest({
            requestBody: JSON.stringify(payload),
            requestId
          });
  
        const parsed =
          typeof response === "string" ? JSON.parse(response) : response;
  
        if (parsed?.ticketid) {
          this.isModel = true;
          this.srNumber = parsed.ticketid;
          this.submittedDate =
            this.formatDateToDDMMYYYY(new Date());
          this.buildEngineerVisitMessage();
        }
  
      } catch (e) {
        console.error("Submission failed", e);
      } finally {
        this.isLoading = false;
      }
    }
  
    /* ============================
     * ENGINEER VISIT MESSAGE
     * ============================ */
    buildEngineerVisitMessage() {
      if (this.startNowFlag && this.windonFlag) {
        this.engineerVisitMessage =
          ENGINEER_VISIT_MSG_STARTNOW.replace("{0}", 4);
      } else if (this.startNowFlag) {
        const interval =
          this.ngme_industry === "D" ? 3 : 4;
        this.engineerVisitMessage =
          ENGINEER_VISIT_MSG_STARTNOW.replace("{0}", interval);
      } else if (this.pickupDateFlag) {
        const [start, end] = this.ngme_time.split(" - ");
        this.engineerVisitMessage =
          ENGINEER_VISIT_MSG
            .replace("{0}", this.formatDateToDDMMYYYY(this.targetstart))
            .replace("{1}", start)
            .replace("{2}", end);
      }
    }
  
    /* ============================
     * UI HELPERS
     * ============================ */
    showServiceError(message) {
      this.serviceProviderError = true;
      this.serviceProviderErrorMessage = message;
  
      setTimeout(() => {
        this.serviceProviderError = false;
        this.serviceProviderErrorMessage = "";
      }, 3000);
    }
  
    scrollToError() {
      const el = this.template.querySelector(".error-text");
      if (el) {
        el.scrollIntoView({ behavior: "smooth", block: "center" });
      }
    }
    handleDragOver(event) {
      event.preventDefault();
      event.currentTarget.classList.add("drag-over");
    }
  
    handleDragLeave(event) {
      event.preventDefault();
      event.currentTarget.classList.remove("drag-over");
    }
  
    handleFileDrop(event) {
      event.preventDefault();
      event.currentTarget.classList.remove("drag-over");
      const files = event.dataTransfer.files;
      this.processFiles(files);
    }
  
    handleFileChange(event) {
      const files = event.target.files;
      this.processFiles(files);
      event.target.value = "";
    }
    handleBrowseClick() {
      this.template.querySelector(".file-input").click();
    }
  
    processFiles(fileList) {
    this.fileError = '';
    if (!fileList || fileList.length === 0) return;

    const duplicateFiles = [];
    const readPromises = [];

    Array.from(fileList).forEach((file) => {

        // Prevent duplicates
        if (this.uploadedFiles.some(f => f.name === file.name)) {
            duplicateFiles.push(file.name);
            return;
        }

        // Size validation
        if (file.size > MAX_FILE_SIZE) {
            const maxMB = (MAX_FILE_SIZE / 1024 / 1024).toFixed(0);
            this.showTemporaryError(
                `File "${file.name}" exceeds ${maxMB} MB limit.`
            );
            return;
        }

        // Wrap FileReader in Promise
        const filePromise = new Promise((resolve) => {
            const reader = new FileReader();

            reader.onload = () => {
                const base64Data = reader.result.split(',')[1];

                resolve({
                    ui: {
                        name: file.name,
                        size: file.size,
                        sizeDisplay: this.formatFileSize(file.size),
                        isImage: file.type.startsWith('image/'),
                        previewUrl: file.type.startsWith('image/') ? reader.result : null
                    },
                    payload: {
                        name: file.name,
                        type: file.type,
                        size: file.size,
                        documenttype : "PHT",
                        base64: base64Data,
                        
                    }
                });
            };

            reader.readAsDataURL(file);
        });

        readPromises.push(filePromise);
    });

    // ✅ Wait for ALL files to be read
    Promise.all(readPromises).then(results => {

        results.forEach(res => {
            this.uploadedFiles = [...this.uploadedFiles, res.ui];
            this.uploadedFilePayload = [...this.uploadedFilePayload, res.payload];
        });

        console.log('UI files:', JSON.stringify(this.uploadedFiles));
        console.log('Payload files:', JSON.stringify(this.uploadedFilePayload));
    });

    // Duplicate file warning
    if (duplicateFiles.length > 0) {
        this.showTemporaryError(
            duplicateFiles.length === 1
                ? `File "${duplicateFiles[0]}" is already uploaded.`
                : `Files "${duplicateFiles.join('", "')}" are already uploaded.`
        );
    }
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
      const name = event.currentTarget.dataset.name;
      this.uploadedFiles = this.uploadedFiles.filter((f) => f.name !== name);
      this.uploadedFilePayload = this.uploadedFilePayload.filter(
        (f) => f.name !== name
      );
    }
  
    formatFileSize(bytes) {
      if (bytes < 1024) return `${bytes} B`;
      else if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
      else return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
    }
  
    handleDateSelected(event) {
      const selectedDateStr = event.detail.date;
      console.log("Date selected from child:", selectedDateStr);
  
      // Convert string to Date object
      const selectedDate = new Date(selectedDateStr);
      console.log("selectedDate", selectedDate);
      // Set time and date
      this.ngme_time = selectedDate.toTimeString().slice(0, 5);
      this.targetstart = selectedDate.toISOString().split("T")[0];
    }
    handleStateResponse(event) {
      const detail = event?.detail;
      if (!detail) {
        return;
      }
  
      // Log clearly
      console.log("State response:", detail);
      console.log("State object:", JSON.stringify(detail.state));
      console.log("State.housingRequired:", detail?.state?.housingRequired);
      console.log("appointmentFlag:", detail.appointmentFlag);
      console.log("selected jobType:", detail.jobtype);
      console.log("subJobType:", detail.subJobType);
      this.stateofWorkRequest = detail.state;
      this.job_type = detail.jobtype;
      this.job_subtype = detail.subJobType;
      this.successprice = detail.successprice;
      // Normalize appointment flag to boolean (handles 'true'/'false' strings and truthy values)
      const appointmentFlag = typeof detail.appointmentFlag === 'string'
        ? detail.appointmentFlag.toLowerCase() === 'true'
        : Boolean(detail.appointmentFlag);
  
      this.showAppointmentFields = appointmentFlag;
      this.showcontactdetails = appointmentFlag;
  
      const jobTypeInput = (detail.jobtype || '').trim().toLowerCase();
      const subJobTypeInput = (detail.subJobType || '').trim().toLowerCase();
  
      const allowedJobTypes = new Set(['install', 'exchange']);
      const allowedSubJobTypes = new Set(['meter', 'specification change', 'third party']);
  
  
      const isAllowedJob = allowedJobTypes.has(jobTypeInput);
      const isAllowedSub = allowedSubJobTypes.has(subJobTypeInput);
  
      if (isAllowedJob && isAllowedSub && detail?.state?.housingRequired === "Yes") {
        this.cwrdescription = 'Date may be subject to change';
      }
    }
    handleRequesterChange(event) {
      const raw = event?.target?.value ?? "";
      const val = String(raw).trim().toLowerCase();
      this.windOnRequestedBy = val;
      console.log("Selected requester:", raw);
      console.log("windonQuestionFlag sub Type (before)", this.job_sub_subtype);
  
      if (val === "customer") {
        this.job_sub_subtype = "WOC XX XX";
      } else if (val === "supplier") {
        this.job_sub_subtype = "WOS XX XX";
      } else {
        // Optional: handle unexpected values
        this.job_sub_subtype = undefined;
      }
  
      console.log("windonQuestionFlag sub Type (after)", this.job_sub_subtype);
  
      // Optional: if you also keep requester in state for UI class/checked bindings:
      this.selectedRequester = val; // 'customer' or 'supplier'
    }
    get showsubmitSection() {
    return !(this.enquiryFlag || this.techEnquiryFlag);
}
}