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
import submitCreattWorkRequest from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.submitCreattWorkRequest";
import NONSTANDARDPRICE from "@salesforce/label/c.NGMCP_Non_Standard_Price_Message";
import uploadFiles from '@salesforce/apex/NGMCP_RequestObjectClass.uploadFiles';
import uploadtoMAximoSystem from '@salesforce/apex/NGMCP_RequestObjectClass.uploadDocumentToMaximo';
import USER_ID from '@salesforce/user/Id';
import EMAIL_FIELD from '@salesforce/schema/User.Email';

import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = ['User.Email', 'User.Profile.Name'];
import validateDeuplicateRequest from '@salesforce/apex/NGMCP_WorkRequestController.validateDeuplicateRequest';
import addressErrormessage from "@salesforce/label/c.NGMCP_AddressErrormessage";
import addressUpdate from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.addressUpdateAPI";
import insertAddress from "@salesforce/apex/NGMCP_RequestObjectClass.createAddressUpdateRecord";
import NGMCP_CRMProfileslabel from '@salesforce/label/c.NGMCP_CRMProfiles';
// UWR attachment limits: 4 MB per file, 4 MB combined total on submit
const MAX_FILE_SIZE = 4 * 1024 * 1024;
const MAX_TOTAL_ATTACHMENT_SIZE = 4 * 1024 * 1024;
const MAX_FILE_SIZE_MB = 4;

export default class NGMCP_CreateJobRequest extends LightningElement {
  @track selectedTitle = "";
  @api mapRequestSourcemetadataRecord;
  @api assetDetails = []; // Array expected

  @track faultMaxvalue = 120;
  @track faultReasonValue;
  @track faultRemainingChars;
  // @api converterDetails = [];    // array of { label, value }
  //  @api converterSerialNo = '';   // explicit converter serial (preferred)

  _converterDetails = [];
  _converterSerialNo = '';

  @api
  get converterDetails() {
    return this._converterDetails;
  }
  set converterDetails(val) {
    if (Array.isArray(val)) {
      this._converterDetails = [...val];
    } else if (val && typeof val === 'object') {
      this._converterDetails = Object.entries(val).map(([label, value]) => ({
        label,
        value
      }));
    } else {
      this._converterDetails = [];
    }
  }

  @api
  get converterSerialNo() {
    return this._converterSerialNo;
  }
  set converterSerialNo(val) {
    this._converterSerialNo = (val ?? '').toString().trim();
  }

  // chang end
  @api addressDetails = {}; // Can come as object from parent
  @track urgentworkrequestFlag = false;
  @track invalidappointmentSlot = false;
  @api isDeappointAllowed;
  @api status;
  @api paymentMechanism;
  @api pressuretierBrand;
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
  @api shouldMaskData;
  @api meterSize;
  @track jobcodeCommerical;
  @track JobSubCodeCommerical;
  @api radioCardFlag;
  @api isAllowDeappointment;
  @track enquiryFlag = false;
  @track workRequestFlag = false;
  @track deappointmentFlag = false;
  @track amrFlag = false;
  @track cwrdescription = '';
  @track stateofWorkRequest;
  @track statemap = new Map();
  @track assetLabelMap = new Map();
  @track wRSLA;
  @track requestTypeValues;
  @track selectedRequestType;
  @api metadataRecord;
  @track messageText;
  @track microbusinessInvalid = false;
  @track microbusinessErrorMessage = '';
  @track showSuccessMessage;
  @track errorMessage;
  @track stateResponseFlag = false;
  isRequestTypeLocked = false;
  appointmentType;
  windOnRequesterError = false;
  windOnRequester = null;
  windOnRequestedBy;
  isResidential;
  @track contactDetails = {
    title: "",
    name: "",
    contactNumber: "",
    emailAddress: "",
    instructions: "",
    consent: false,
    requestonbehalfof: ""
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
  @track techEnquiryFlag = false;
  @track createrequestFlag = false;
  queryvalue;
  @api requestSource;
  @track duplicateMessage;
  @api haszoo2;
  @api appointmentFlag;
  hasAutoSelected = false;
  appointMode;
  @track isEditingAddress = false;
  @track editableAddressBuffer = [];
  @api msn;
  @api location;
  @api siteid;
  @api locationsid;
  @track microbusiness;
  @api customer;
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
      timeframe: "08:00 - 11:00(S1)",
    },
    {
      code: "S2",
      timeframe: "10:00 - 13:00(S2)",
    },
    {
      code: "S3",
      timeframe: "12:00 - 15:00(S3)",
    },
    {
      code: "S4",
      timeframe: "14:00 - 17:00(S4)",
    },
    {
      code: "S5",
      timeframe: "16:00 - 19:00(S5)",
    },
    {
      code: "S6",
      timeframe: "18:00 - 21:00(S6)",
    },
  ];
  commercialSlots = [
    {
      code: "S1",
      timeframe: "08:00 - 12:00(S1)",
    },
    {
      code: "S2",
      timeframe: "10:00 - 14:00(S2)",
    },
    {
      code: "S3",
      timeframe: "12:00 - 16:00(S3)",
    },
    {
      code: "S4",
      timeframe: "14:00 - 18:00(S4)",
    },
    {
      code: "S5",
      timeframe: "16:00 - 20:00(S5)",
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
  @track userEmail;
  @track profile;
  @track userId = USER_ID;
  maxInstructionLength = 255;
  //remainingChars = this.maxInstructionLength;

  startNowError = "";
  startNowErrorElement;

  // TEMPORARY TESTING FLAG — remove after testing
  testMode = true;
  testDateTime = "2025-11-15T21:30:00Z"; // <-- Set any date/time in UTC to simulate

  // --- Residential (Weekday) Slots ---
  residentialWeekdaySlots = [
    { label: "08:00 - 11:00(S1)", value: "S1" },
    { label: "10:00 - 13:00(S2)", value: "S2" },
    { label: "12:00 - 15:00(S3)", value: "S3" },
    { label: "14:00 - 17:00(S4)", value: "S4" },
    { label: "16:00 - 19:00(S5)", value: "S5" },
    { label: "18:00 - 21:00(S6)", value: "S6" },
  ];

  // --- Commercial & Residential (Weekend / Holiday) Slots ---
  commercialAndWeekendSlots = [
    { label: "08:00 - 12:00(S1)", value: "S1" },
    { label: "10:00 - 14:00(S2)", value: "S2" },
    { label: "12:00 - 16:00(S3)", value: "S3" },
    { label: "14:00 - 18:00(S4)", value: "S4" },
    { label: "16:00 - 20:00(S5)", value: "S5" },
  ];
  workRequestResidentials = [
    { label: '08:00 - 20:00(AT)', value: 'AT' },
    { label: '08:00 - 12:00(AM)', value: 'AM' },
    { label: '12:00 - 16:00(PM)', value: 'PM' },
    { label: '08:00 - 10:00(S1)', value: 'S1' },
    { label: '10:00 - 12:00(S2)', value: 'S2' },
    { label: '12:00 - 14:00(S3)', value: 'S3' },
    { label: '14:00 - 16:00(S4)', value: 'S4' },
    { label: '16:00 - 18:00(S5)', value: 'S5' },
    { label: '18:00 - 20:00(S6)', value: 'S6' }
  ];
  ;

  workRequestCommercial = [
    { label: '08:00 - 20:00(AT)', value: 'AT' },
    { label: '08:00 - 13:00(AM)', value: 'AM' },
    { label: '12:00 - 20:00(PM)', value: 'PM' }
  ];
  workRequestCommercialwithmicrobusiness = [
    { label: '08:00 - 12:00(AM)', value: 'AM' },
    { label: '12:00 - 16:00(PM)', value: 'PM' }
  ];

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [EMAIL_FIELD]
  })
  wiredUser({ data }) {
    if (data) {
      this.userEmail = data.fields.Email.value;
    }
  }

  @wire(getRecord, { recordId: '$userId', fields: FIELDS })
  userRecord({ error, data }) {
    if (data) {
      this.email = data.fields.Email.value;
      const profileName = data.fields?.Profile?.value?.fields?.Name?.value;
      this.profile = profileName === 'NGMCP_Gas Supplier Agent' || profileName === 'NGMCP_Gas Supplier Manager';
      // Prefill contact email with the current user's email
      //this.contactDetails = { ...this.contactDetails, contactEmail: this.email };
    }
  }
  @wire(getHolidays)
  wiredHolidays({ data, error }) {
    if (data) {
      this.holidays = data.map((h) => {
        const dateObj = new Date(h);
        return dateObj.toISOString().split("T")[0];
      });
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
    const n = this.remainingChars ?? this.maxInstructionLength;
    return `${n} ${n === 1 ? 'character' : 'characters'} remaining`;
  }
  get remainingfaultCharsLabel() {
    const n = this.faultRemainingChars ?? this.faultMaxvalue;
    return `${n} ${n === 1 ? 'character' : 'characters'} remaining`;
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

  handleInstructionInput(event) {
    const el = event.target;
    const fieldName = el.name;
    let val = el.value || "";
    const maxLength =
      fieldName === 'faultReason'
        ? this.faultMaxvalue
        : this.maxInstructionLength;

    // Trim to max length (your existing logic)
    if (val.length > maxLength) {
      val = val.substring(0, maxLength);
      el.value = val;
    }
    if (fieldName === 'faultReason') {
      this.faultReasonValue = val;
      this.faultRemainingChars = maxLength - val.length;
      if (this.faultReasonValue.length > 0) {
        delete this.validationErrors.faultReason;
      }
    } else {
      this.contactDetails = {
        ...this.contactDetails,
        instructions: val
      };
      this.remainingChars = maxLength - val.length;
    }
    // Build a fresh errors object (copy existing errors)
    let errors = { ...this.validationErrors };

    // --- Your max‑length validation logic — unchanged ---
    if (val.length > this.maxLength) {
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
    this.updateAppointmentSlots();
  }
  /*handleSlotChange(event) {
    this.selectedSlot = event.detail.value;

    // clear error when user changes
    delete this.validationErrors.appointmentSlot;

    const selectedOption = this.appointmentOptions.find(
      (option) => option.value === this.selectedSlot
    );

    this.selectedSlotLabel = selectedOption ? selectedOption.label : "";

    console.log("Selected Slot:", this.selectedSlotLabel);

    /* ---------------------------
       Current UK time → minutes
    --------------------------- 
    const nowUKStr = new Date().toLocaleTimeString("en-GB", {
      timeZone: "Europe/London",
      hour12: false,
      hour: "2-digit",
      minute: "2-digit"
    });

    const [curH, curM] = nowUKStr.split(":").map(Number);
    const currentMinutes = curH * 60 + curM;

    /* ---------------------------
       Parse slot
    --------------------------- 
    const timePart = this.selectedSlotLabel.split("(")[0];
    const [startStr, endStr] = timePart.split("-").map(t => t.trim());

    const [eh, em] = endStr.split(":").map(Number);
    const endMinutes = eh * 60 + em;

    console.log("Current:", currentMinutes);
    console.log("End:", endMinutes);

    /* ---------------------------
       Validation (FIXED)
       block ONLY if slot finished
    --------------------------- 
    const slotDateStr = new Date().toISOString().slice(0, 10);
    console.log('slotDateStr', slotDateStr);
    console.log('this.selectedDate', this.selectedDate);
    if ((currentMinutes >= endMinutes) && (slotDateStr === this.selectedDate)) {
      this.validationErrors.appointmentSlot =
        "This slot cannot be selected as it is already completed, please select a future slot";

      //this.selectedSlot = null;
      //this.selectedSlotLabel = null;
      return;
    }

    /* ---------------------------
       Valid
    --------------------------- 
    this.ngme_time = this.selectedSlotLabel;
    this.ngme_liferay_slot = this.selectedSlot;
  }*/
  handleSlotChange(event) {
    this.selectedSlot = event.detail.value;
    // clear error when user changes
    delete this.validationErrors.appointmentSlot;
    this.invalidappointmentSlot = false;
    const selectedOption = this.appointmentOptions.find(
      (option) => option.value === this.selectedSlot
    );
    this.selectedSlotLabel = selectedOption ? selectedOption.label : "";

    /* ---------------------------
       Current UK time → minutes
    --------------------------- */
    const nowUKStr = new Date().toLocaleTimeString("en-GB", {
      timeZone: "Europe/London",
      hour12: false,
      hour: "2-digit",
      minute: "2-digit"
    });

    const [curH, curM] = nowUKStr.split(":").map(Number);
    const currentMinutes = curH * 60 + curM;

    /* ---------------------------
       Parse slot
    --------------------------- */
    const timePart = this.selectedSlotLabel.split("(")[0];
    const [startStr, endStr] = timePart.split("-").map(t => t.trim());

    const [sh, sm] = startStr.split(":").map(Number);
    const startMinutes = sh * 60 + sm;

    const [eh, em] = endStr.split(":").map(Number);
    const endMinutes = eh * 60 + em;

    const slotDateStr = new Date().toISOString().slice(0, 10);

    if ((currentMinutes >= startMinutes) && (slotDateStr === this.selectedDate) && !['COT ET XX', 'ECR PR XX'].includes(this.stateofWorkRequest?.serviceType)) {
      this.validationErrors.appointmentSlot =
        "This slot cannot be selected as it has already started, please select a valid slot";
      this.invalidappointmentSlot = true;
      return;
    }

    if ((currentMinutes >= endMinutes) && (slotDateStr === this.selectedDate) && ['COT ET XX', 'ECR PR XX'].includes(this.stateofWorkRequest?.serviceType)) {
      this.validationErrors.appointmentSlot =
        "This slot cannot be selected as it has already started, please select a valid slot";
      this.invalidappointmentSlot = true;
      return;
    }

    /* ---------------------------
       Valid
    --------------------------- */
    this.ngme_time = this.selectedSlotLabel;
    this.ngme_liferay_slot = this.selectedSlot;
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
    const selectedDate = event.detail.date;
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
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    // selectedDate is 'YYYY-MM-DD'
    const selectedDate = new Date(this.selectedDate);
    selectedDate.setHours(0, 0, 0, 0);
    // Today + 4
    const todayPlus4 = new Date(today);
    todayPlus4.setDate(today.getDate() + 4);
    // Today + 5
    const todayPlus5 = new Date(today);
    todayPlus5.setDate(today.getDate() + 5);
    const statusLower = this.status.toLowerCase();
    const selected = new Date(this.selectedDate);
    const day = selected.getDay();
    const isWeekend = day === 0 || day === 6;
    const selectedDateNormalized = this.selectedDate;
    const isHoliday = this.holidays.includes(selectedDateNormalized);

    this.targetstart = selectedDateNormalized;

    if (statusLower === "residential" && !this.workRequestFlag) {
      if (!isWeekend && !isHoliday) {
        this.appointmentOptions = this.residentialWeekdaySlots;
      } else {
        this.appointmentOptions = this.commercialAndWeekendSlots;
      }
    } else if (statusLower === "residential" && this.workRequestFlag) {
      this.appointmentOptions =
        (
          // COT ET XX → Today to Today+4
          (
            this.stateofWorkRequest?.serviceType === 'COT ET XX' &&
            selectedDate >= today &&
            selectedDate <= todayPlus4
          ) ||

          // ECR PR XX → Tomorrow to Today+5
          (
            this.stateofWorkRequest?.serviceType === 'EXC PP CR' &&
            selectedDate > today &&
            selectedDate < todayPlus5
          )
        )
          ? this.workRequestResidentials.filter(opt => opt.value === 'AT')
          : this.workRequestResidentials;
    } else if (statusLower === "commercial" && !this.workRequestFlag) {
      this.appointmentOptions = this.commercialAndWeekendSlots;
    } else if (statusLower === "commercial" && this.workRequestFlag && this.ismicrobusinesscwr && this.microbusiness === 'Y') {
      this.appointmentOptions = this.workRequestCommercialwithmicrobusiness;
    } else if (statusLower === "commercial" && this.workRequestFlag) {
      this.appointmentOptions = this.workRequestCommercial;
    } else {
      this.appointmentOptions = [];
    }
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
    if (this.requestSource && !this.hasAutoSelected) {
      const mapped = this.getMappedRequestType(this.requestSource);
      if (mapped) {
        this.autoSelectRequestType(mapped);
        this.hasAutoSelected = true;
      }
    }
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
    console.log('maskeddata',this.shouldMaskData );
    this.loadHolidays();
    this.checkNGMUser();
    this.appointmentOptions = this.status;
    const TECH_QUERY = new Set(['tQuery']);
    const AMR = new Set(['amr']);
    const allowed = new Set(['urgent', 'deappoint']);

    const isResidential = this.status === 'Residential';
    const handleRadioCard = this.radioCardFlag === true;
    const handleAppointmentDeappointment = this.isAllowDeappointment === true;
    this.requestTypes = this.requestTypes.map(item => {
      let isHidden = item.isHidden ?? false;
      if ((isResidential && (TECH_QUERY.has(item.value) || AMR.has(item.value))) || (!handleRadioCard && !allowed.has(item.value))) {
        isHidden = true;
      }
      if (item.value === 'work' || item.value === 'dataQuery') {
        isHidden = !handleRadioCard;
      }
      if (item.value === 'urgent') {
        isHidden = false;
      }

      return {
        ...item,
        isHidden
      };
    });
    const data = this.metadataRecord[0].metadatalist;
    this.assetnum = this.metadataRecord[0].assetnum;
    this.suppliercode = this.metadataRecord[0].suppliercode;
    this.location = this.metadataRecord[0].location;


    this.ngme_industry = this.metadataRecord[0].ngme_industry;
    this.meterSize = this.metadataRecord[0].metadatalist[0].NGMCP_Meter_Size__c;
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
      })
      .catch((error) => {
        this.holidays = [];
      });
  }

  checkNGMUser() {
    isNGMUser()
      .then((result) => {
        this.isNGMUser = result;
        if (!this.isNGMUser && this.shouldMaskData) {
          this.isEditingAddress = true;
          this.editableAddressBuffer = (this.displayedAddressDetails || []).map(i => ({
            key: i.key ?? i.label,
            label: i.label,
            value: '',
            apiName: i.apiName ?? i.key ?? i.label,
            editable: i.editable !== false,
            maxLength: i.label === 'Post Code' ? 10 : 40
          }));
          this.assetDetails = this.assetDetails.map(item => ({
            ...item,
            shouldMask: this.shouldMaskData && item.maskKey
          }))
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
      desc: "Customer initiated request for works on the meter installation.",
      isChecked: false,
      className: "radio-card",
      isHidden: false,
    },
    {
      value: "urgent",
      label: "Urgent Work request (Off gas)",
      desc: "To support customers who are currently 'off-supply' due to a gas meter fault(Residential PP/CR meter fault or Commercial TFM).",
      isChecked: false,
      className: "radio-card",
      isHidden: false,
    },
    {
      value: "amr",
      label: "AMR request",
      desc: "Request for services related to Automated Meter Readings.",
      isChecked: false,
      className: "radio-card",
      isHidden: false,
    },
    {
      value: "deappoint",
      label: "Appoint/De-Appoint",
      desc: "Request Appoint/Deappoint supply on an MPRN.",
      isChecked: false,
      className: "radio-card",
      isHidden: false,
    },
    {
      value: "dataQuery",
      label: "Data Queries (DQ)",
      desc: "To query the data NGM holds for a given MPRN.",
      isChecked: false,
      className: "radio-card",
      isHidden: false,
    },
    {
      value: "tQuery",
      label: "Technical Queries (TQ)",
      desc: "To query a suspected fault on an NGM Asset.",
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

  get isWindOnSelected() {
    return this.selectedJobType === 'windon';
  }
  async handleCardClick(event) {
    const selectedValue = event?.currentTarget?.dataset?.value;
    const clickedCard = event.currentTarget;
    this.requestTypeValues = ["work", "urgent", "amr", "deappoint", "dataQuery", "tQuery"];
    this.selectedRequestType = selectedValue;
    if (this.isRequestTypeLocked && this.requestTypeValues.includes(selectedValue)) {
      return;
    }
    if (["work", "amr", "deappoint", "dataQuery", "tQuery"].includes(selectedValue)) {
      this.resetRequestModeFlags();
      this.resetWindOnState();
      this.resetUrgentUI();
      this.resetContactDetailsState();
    }
    if (!this.isNGMUser && selectedValue === "restro") {
      return;
    }
    this.template.querySelectorAll(".radio-card").forEach((card) => {
      card.classList.remove("selected");
      const radio = card.querySelector('input[type="radio"]');
      if (radio) radio.checked = false;
    });

    // Highlight clicked card and check radio
    clickedCard.classList.add("selected");
    const radioInput = clickedCard.querySelector('input[type="radio"]');
    if (radioInput) radioInput.checked = true;
    // const jobTypeOptions = ["faulty", "windon"];
    const jobTypeOptions = ["faulty", "windon", "install", "convertor", "replace"];
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
        this.urgentworkrequestFlag = false;
        this.resetUrgentStartOptions();
        this.workRequestFlag = true;
        this.techEnquiryFlag = false;
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
        this.amrFlag = false;

        // Reset job types
        /*  this.jobTypes = this.jobTypes.map((job) => ({
            ...job,
            isChecked: false,
            className: "radio-card",
          }));*/

        break;
      case "amr":
        if (["work", "amr", "urgent", "deappoint", "dataQuery", "tQuery"].includes(selectedValue)) {
          this.setRequestType(selectedValue);
          return;
        }
        this.urgentworkrequestFlag = false;
        // this.resetUrgentStartOptions();
        // this.resetJobTypeState();      
        // this.resetWindOnState();       
        // this.resetContactDetailsState();
        //   this.showWorkRequestChild = false;
        //   this.techEnquiryFlag = false;
        //   this.enquiryFlag = false;
        //   this.showJobType = false;
        //   this.showRestro = false;
        //   this.showAppointment = false;
        //   this.showAppointmentFields = false;
        //   this.showcontactdetails = false;
        //   this.deappointmentFlag = false;
        //   this.workRequestFlag = false;
        //   this.amrFlag = true;
        break;
      case "deappoint":
        this.resetUrgentStartOptions();
        this.urgentworkrequestFlag = false;
        this.showWorkRequestChild = false;
        this.techEnquiryFlag = false;
        this.enquiryFlag = false;
        this.showJobType = false;
        this.showRestro = false;
        this.showAppointment = false;
        this.showAppointmentFields = false;
        this.showcontactdetails = false;
        this.deappointmentFlag = true;
        this.amrFlag = false;
        this.appointMode = 'DEAPPOINT';
        break;
      case "urgent":
        this.urgentworkrequestFlag = true;
        this.workRequestFlag = false;
        this.techEnquiryFlag = false;
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
        this.amrFlag = false;

        const raw = (this.mprn || '').toString();
        const parts = raw.split('-').map(s => (s ? s.trim() : ''));
        const mprnvalue = parts[0] || '';       // "10140505"
        const supplier = parts[1] || '';   // "GLZ"
        const payloadObj = {
          recordTypeName: 'Urgent Work Request',
          NGMCP_MPRN__c: mprnvalue,
          NGMCP_Supplier_Id__c: supplier,
          NGMCP_Job_Type__c: this.job_type,
          NGMCP_Job_SubType__c: this.job_subtype,
          NGMCP_Status__c: ['Closed', 'CANCELLED', 'Cancelled', 'Resolved', 'Rejected'] // NOT IN
        };
        // 3) Call Apex (expects String payload)
        const results = await validateDeuplicateRequest({
          payload: JSON.stringify(payloadObj)
        });
        if (results.length > 0 && !this.isNGMUser) {
          this.isModel = true;
          this.duplicateMessage = 'Open request with Request Number -' + results[0].Name + ' and Service Request - ' + results[0].NGMCP_SR_Ticket__c + ' already exists for the same combination.';
          return;
        }
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
          const defaultJobType = this.jobTypes[0].value;
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
        if (!this.isNGMUser && this.selectedStartOption === "restro") {
          this.selectedStartOption = null;
          this.showRestro = false;

          this.startOptions = this.startOptions.map(opt => ({
            ...opt,
            isChecked: false
          }));
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
          this.windonQuestionFlag = true;
          this.fetchServicePartnerStatus();


          // Reset the requester selection every time we come back to Wind On
          // this.windOnRequestedBy = null;
          // this.windOnRequesterError = false;
        } else {
          this.showServicePartnerStatus = false;
          this.windonQuestionFlag = false;
          // Reset Wind On radio button state when leaving
          // this.windOnRequestedBy = null;
          // this.windOnRequesterError = false;
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
        // const now = new Date();
        const result = this.validateStartNow();

        // if (!result.allowed) {
        //     this.validationErrors.startNow =
        //         "You cannot submit an immediate start urgent work request during non working hours. Please reach out to 0800 111 999 if this is needed immediately.";

        //     this.startNowFlag = false;
        //     return;
        // }
        if (!result.allowed && !this.isNGMUser) {
          this.validationErrors.startNow =
            "You cannot submit an immediate start urgent work request during non working hours. Please reach out to 0800 001 4340 if this is needed immediately.";
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
        //this.targetstart = now.toISOString().split("T")[0];
        //this.ngme_time = now.toTimeString().slice(0, 5);
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
        this.resetUrgentStartOptions();
        this.queryvalue = 'AST';
        this.enquiryFlag = true;
        this.workRequestFlag = false;
        this.techEnquiryFlag = false;
        this.deappointmentFlag = false;
        this.amrFlag = false;
        break;
      case "tQuery":
        this.resetUrgentStartOptions();
        this.queryvalue = 'TQUERY';
        this.enquiryFlag = false;
        this.workRequestFlag = false;
        this.techEnquiryFlag = true;
        this.deappointmentFlag = false;
        this.amrFlag = false;
        break;
      default:
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
        this.windonQuestionFlag = false;

        // fully reset Wind On state
        this.windOnRequestedBy = null;
        this.windOnRequesterError = false;
        this.selectedRequester = null;

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
      const ukHour = ukTime.getHours();
      const ukMinutes = ukTime.getMinutes();
      const nowDecimal = ukHour + ukMinutes / 60;

      // -------------------------------------------------------
      // 2) Build UK ISO date
      // -------------------------------------------------------
      const yyyy = ukTime.getFullYear();
      const mm = String(ukTime.getMonth() + 1).padStart(2, "0");
      const dd = String(ukTime.getDate()).padStart(2, "0");
      const todayISO = `${yyyy}-${mm}-${dd}`;
      // -------------------------------------------------------
      // 3) Check weekend / holiday
      // -------------------------------------------------------
      const ukDay = ukTime.getDay(); // 0=Sun, 6=Sat
      const isWeekend = ukDay === 0 || ukDay === 6;
      const isHoliday = this.holidays?.includes(todayISO);
      const isWeekendOrHoliday = isWeekend || isHoliday;

      // -------------------------------------------------------
      // 4) Business Rules
      // -------------------------------------------------------
      const isResidential = this.status?.toLowerCase() === "residential";
      const isCommercial = this.status?.toLowerCase() === "commercial";

      let startHour = 0;
      let endHour = 0;

      if (isResidential) {
        if (isWeekendOrHoliday) {
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
      // -------------------------------------------------------
      // 5) Final Evaluation
      // -------------------------------------------------------
      const allowed = nowDecimal >= startHour && nowDecimal <= endHour;

      return { allowed, isWeekendOrHoliday };
    } catch (error) {
      return { allowed: false, isWeekendOrHoliday: false };
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
    console.log('this.contactDetails[field]', JSON.stringify(this.contactDetails));
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
 
       if (trimmedValue.length > 40) {
         errors.emailAddress = "Email address cannot exceed 40 characters.";
       } else {
         delete errors.emailAddress;
       }
     }*/

    // EMAIL (optional)
    if (field === "emailAddress") {
      const trimmedValue = value ? value.trim() : "";

      // Optional field → clear error if empty
      if (!trimmedValue) {
        delete errors.emailAddress;
      }
      // Length validation
      else if (trimmedValue.length > 40) {
        errors.emailAddress =
          "Please enter a valid email address less than 40 chars.";
      }
      // Pattern validation
      else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(trimmedValue)) {
        errors.emailAddress =
          "Please enter a valid email address.";
      }
      // Valid email
      else {
        delete errors.emailAddress;
      }

      // 🔴 THIS LINE IS MANDATORY
      this.validationErrors = errors;
    }

    // --- INSTRUCTIONS CHARACTER COUNTER ---
    if (field === "instructions") {
      this.remainingChars = 255 - value.length;
      if (this.remainingChars < 0) {
        this.contactDetails.instructions = value.slice(0, 255);
        this.remainingChars = 0;
      }
    }
    this.validationErrors = errors;
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
      if (!event || !event.target) {
        return;
      }
      const selectedValue = event.currentTarget.dataset?.value || event.target.value;
      // const selectedValue =
      //   event.target.dataset?.value ||
      //   event.currentTarget.dataset?.value ||
      //   event.target.value ||
      //   "";
      // The input that fired the event
      const radioInput = event.currentTarget;
      // Find the containing card (works for both <div class="radio-card"> and <label class="radio-card">)
      const clickedCard = radioInput.closest('.radio-card');

      // If this is null, the ancestor doesn't have class="radio-card".
      // Ensure your template renders that class exactly.
      if (!clickedCard) return;

      if (!selectedValue) {
        return;
      }
      // Drive state (recommended): update jobTypes isChecked
      this.jobTypes = this.jobTypes.map(job => ({
        ...job,
        isChecked: job.value === selectedValue,
        className:
          job.value === selectedValue ? 'radio-card selected' : 'radio-card',
      }));
      this.selectedJobType = selectedValue;

      if (this.keepJobTypesVisible) {
        this.showJobType = true;
        this.showFaulty = true;
      }
      if (selectedValue.toLowerCase() === "windon") {
        this.windonFlag = true;
        if (!this.isNGMUser) {
          this.job_sub_subtype = "WOS XX XX";
        } else {
          this.windonQuestionFlag = true;
        }
        this.fetchServicePartnerStatus();
      } else {
        this.showServicePartnerStatus = false;
        this.windonQuestionFlag = false;
        this.windonFlag = false;
        this.job_sub_subtype = '';
      }
    } catch (error) {
      console.error("Error in handleCategorySelect:", error);
    }
  }

  async fetchServicePartnerStatus() {
    try {
      if (!this.postCode) {
        this.showServicePartnerStatus = false;
        return;
      }

      // const cleanedCode = this.postCode.replace(/\s/g, "").toUpperCase();
      const cleanedCode = this.postCode;
      const status = await getServicePartnerStatus({ postCode: cleanedCode });
      if (!status) {
        this.showServicePartnerStatus = false;
        return;
      }

      this.showServicePartnerStatus = true;
      this.servicePartnerStatus = status;
      // Set color box class and message
      if (status.toLowerCase() === "green") {
        this.servicePartnerBoxClass = "green-box";
        this.servicePartnerMessage = "Service Partner available";
      } else if (status.toLowerCase() === "amber") {
        this.servicePartnerBoxClass = "amber-box";
        this.servicePartnerMessage =
          "Wind On request cannot be booked via portal due to limited availability, please call NGM direct on 0800 001 4340";
        //"Service Partner seems to be busy, please book cautiously";
      } else if (status.toLowerCase() === "red") {
        this.servicePartnerBoxClass = "red-box";
        this.servicePartnerMessage =
          "Wind On request cannot be booked via portal due to no availability, please try again later.";
        //"Service Partner seems to be busy, please book cautiously";
      }
    } catch (error) {
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
    this.validationErrors = {};

    // Wind On requester mandatory check
    if (this.windonQuestionFlag && !this.windOnRequestedBy) {
      this.windOnRequesterError = true;
      this.scrollToError?.();
      return;
    }

    if (!this.validateMicrobusiness() && (this.workRequestFlag && this.status?.toLowerCase() === "commercial" && this.successprice)) {
      this.scrollToError();
      return;
    }
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
    if (!allowed && !this.isNGMUser) return;
    if (this.invalidappointmentSlot) {
      this.validationErrors.appointmentSlot =
        "This slot cannot be selected as it has already started, please select a valid slot";
      return;
    }
    // 4️⃣ Consent
    if (!this.contactDetails?.consent) {
      this.validationErrors.consent =
        "Please confirm that consent has been obtained before submitting.";
      this.scrollToError();
      return;
    }

    // 5️⃣ Combined attachment size
    if (!this.validateCombinedAttachmentSize()) {
      this.scrollToError();
      return;
    }

    // Email (optional but validated)
    if (this.contactDetails?.emailAddress) {
      const email = this.contactDetails.emailAddress.trim();

      if (email.length > 40) {
        this.validationErrors.emailAddress =
          "Please enter a valid email address less than 40 chars.";
        isValid = false;
      } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        this.validationErrors.emailAddress =
          "Please enter a valid email address.";
        isValid = false;
      }
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
    if (this.faultReason && !this.faultReasonValue) {
      this.validationErrors.faultReason =
        "This field is required.";
      isValid = false;
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
        return val;
      }
    }
    return val;
  }

  /* ============================
   * BUILD ADDITIONAL INFO
   * ============================ */
  buildAdditionalInfo() {
    this.assetDetails = this.safeParse(this.assetDetails);
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
      NGMCP_Manufacturer_Serial_No__c: assetLabelMap.get("Manufacturer Serial no."),
      NGMCP_Meter_Type__c: assetLabelMap.get("Meter Type"),
      NGMCP_No_of_Dials__c: assetLabelMap.get("No. of Dials"),
      NGMCP_Payment_Mechanism__c: assetLabelMap.get("Payment Mechanism"),
      NGMCP_Year_of_Manufacture__c: assetLabelMap.get("Year of Manufacture"),
      NGMCP_LocationsId__c: assetLabelMap.get("Location"),
      NGMCP_Install_Date__c: toIso(assetLabelMap.get("Install Date")),
      NGMCP_Measuring_Capacity__c: assetLabelMap.get("Measuring Capacity"),
      NGMCP_Building_Number__c: this.getAddr('buildingNumber', 'Building Number'),
      NGMCP_Building_Name__c: this.getAddr('buildingName', 'Building Name'),
      NGMCP_Street__c: this.getAddr('street', 'Street'),
      NGMCP_Dependent_Locality__c: this.getAddr('dependentLocality', 'Dependent Locality'),
      NGMCP_Postal_Town__c: this.getAddr('postalTown', 'Postal Town'),
      NGMCP_Postal_Code__c: this.getAddr('postCode', 'Post Code'),
      NGMCP_Job_Code_Description__c: this.windonFlag ? "Wind On" : (this.jobTypes?.[0]?.label ?? ""),
      NGMCP_Appointment_Type__c: this.appointmentType,
      NGMCP_Wind_On_requested_by__c: this.windOnRequestedBy ?? "",
      NGMCP_Residential_U6__c: this.isResidential ?? "",
      NGMCP_Reported_Email__c: this.contactDetails.requestonbehalfof ?? "",
    };

    return Object.entries(fields)
      .filter(([_, v]) => v != null && String(v).trim() !== "")
      .map(([name, value]) => ({ name, value }));
  }

  /* ============================
   * BUILD PAYLOAD
   * ============================ */
  buildUrgentWorkPayload() {
    if (this.startNowFlag) {
      const now = new Date();
      this.targetstart = now.toISOString().split("T")[0];
      this.ngme_time = now.toTimeString().slice(0, 5);
    }
    return {
      reportedpriority: this.reportedpriority,
      job_type: this.job_type,
      ngme_consphone: this.contactDetails.contactNumber,
      description_longdescription:
        this.contactDetails.instructions,
      job_subtype: this.job_subtype,
      targetstart: this.targetstart,
      ngme_time: this.ngme_time.includes("(") ? this.ngme_time.replace(/\(.*?\)/g, "").trim() : this.ngme_time,
      source: this.source,
      job_sub_subtype: this.job_sub_subtype || this.selectedJobType,
      ngme_liferay_slot: this.ngme_liferay_slot,
      ngme_lf_mksctcd: this.ngme_industry,
      assetnum: this.assetnum,
      suppliercode: this.suppliercode,
      location: this.location,
      ngme_constitle: this.contactDetails.title,
      ngme_consemail: this.contactDetails.emailAddress,
      building_name: this.getAddr('buildingName', 'Building Name'),
      ngme_consname: this.contactDetails.name,
      reportedemail: this.userEmail,
      faultreason: this.faultReasonValue || "",
      additionalinfo: this.buildAdditionalInfo()
    };
  }

  /* ============================
   * SUBMIT FLOW
   * ============================ */
  async submitUrgentWorkRequestFlow() {
    try {
      this.isLoading = true;

      const payload = await this.buildUrgentWorkPayload();
      const requestId =
        await createUrgentWorkRequestRecord({
          requestBody: JSON.stringify(payload),
          recordTypeValue: "Urgent Work Request"
        });

      if (!requestId) return;
      if (this.uploadedFilePayload?.length > 0) {
        const isUploaded = await uploadFiles({
          recordId: requestId.id,
          files: JSON.stringify(this.uploadedFilePayload)
        });

        if (!isUploaded) {
          return;
        }
      }
      delete payload.additionalinfo;
      console.log('payload', JSON.stringify(payload));
      const response =
        await submitUrgentWorkRequest({
          requestBody: JSON.stringify(payload),
          requestId: requestId.id
        });

      const parsed =
        typeof response === "string" ? JSON.parse(response) : response;
      if (parsed?.ticketid) {
        if (this.uploadedFilePayload?.length > 0) {
          const uploadRequest = await uploadtoMAximoSystem({
            files: JSON.stringify(this.uploadedFilePayload),
            srticket: parsed.ticketid,
            uid: parsed.ticketuid,
            doctype: 'GT1'
          });
        }
        const srvalue = parsed?.ticketid ? `SR-${parsed.ticketid}` : '';
        this.isModel = true;
        this.srNumber = srvalue;
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
    if (v === 'true' || v === 'y' || v === 'yes' || v === "1") return 'Y';
    if (v === 'false' || v === 'n' || v === 'no' || v === "0") return 'N';
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
    switch (mapping.NGMCP_Source_Map__c) {

      case 'State':
        return this.statemap.get(mapping.NGMCP_Source_Key__c);
      case 'Asset':
        return this.assetLabelMap.get(mapping.NGMCP_Source_Key__c);
      case 'Address':
        const [key1, key2] = mapping.NGMCP_Source_Key__c.split(',').map(k => k.trim());
        if (this.addressDetails?.[key1]) return this.addressDetails[key1].trim();
        if (this.addressDetails?.[key2]) return this.addressDetails[key2].trim();
        if (Array.isArray(this.addressDetails)) {
          const item = this.addressDetails.find(
            x => x.label?.trim().toLowerCase() === key2.toLowerCase()
          );
          if (item?.value) return item.value.trim();
        }

        return "";

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
        if (mapping.NGMCP_Salesforce_Field_API__c === 'NGMCP_MIcro_Buisness__c') {
          return this.microbusiness === 'Y' ? "Yes" : "No";
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
    const maximoAttrId = (mapping.NGMCP_IBMMaximo_TicketAPI__c ||
      mapping.NGMCP_IBMMaximo_TicketAPI__C ||
      '').toString().trim();
    switch (mapping.NGMCP_Source_Map__c) {
      case 'State': {
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
        if (mapping.NGMCP_Salesforce_Field_API__c === 'NGMCP_MIcro_Buisness__c') {
          return this.microbusiness ? this.asYN(this.microbusiness) : "N";
        }
        return null;
    }
  }
  // ===== MAIN PAYLOAD BUILDER (CALL ON SUBMIT) =====
  async buildCreateWorkRequestAdditionalInfo() {
    const fieldMappingList = await getCWRFieldMapping();
    const fields = [];
    fieldMappingList.forEach(m => {
      let value = this.resolveValue(m);
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
    return fields;
  }

  // When an Exchange -> Specification Change Work Request is raised on a Residential MPRN
  // (ngme_industry === 'D') but the newly selected meter model is anything other than U6
  // (e.g. a U6 -> U16 upgrade), it must be submitted through the Commercial Maximo API
  // using the Commercial JSON format instead of the Residential one. This is intentionally
  // limited to Exchange / Specification Change so no other functionality is affected.
  get isResidentialExchangeAsCommercial() {
    const isExchange = (this.job_type ?? '').toString().trim().toLowerCase() === 'exchange';
    const isSpecificationChange = (this.job_subtype ?? '').toString().trim().toLowerCase() === 'specification change';
    const newModel = (this.stateofWorkRequest?.MeterSize ?? '').toString().trim().toUpperCase();
    return isExchange && isSpecificationChange && newModel !== '' && newModel !== 'U6';
  }
  async buildticketrequest() {
    // Fetch CMDT rows (make sure Apex returns NGMCP_IBMMaximo_TicketAPI__c, etc.)
    const fieldMappingList = await getCWRFieldMapping();
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
    if (this.status?.toLowerCase() === "commercial" || this.isResidentialExchangeAsCommercial) {
      fields.push(
        { assetattrid: trimIfString('NGME_JOBDETAIL'), alnvalue: trimIfString(this.jobcodeCommerical) },
        { assetattrid: trimIfString('NGME_JOBTYPE'), alnvalue: trimIfString(this.JobSubCodeCommerical) }
      );
    }
    return fields;
  }
  resolveAddressFields() {
    const normalize = (str) => (str ?? '').replace(/[^a-z]/gi, '').toLowerCase();
    const fields = {
      building_name: '',
      building_no: '',
      dependentloc: '',
      street: '',
      posttown: '',
      postcode: ''
    };

    const assignValue = (normKey, rawValue) => {
      const value = (rawValue ?? '').toString().trim();
      if (!value) return;
      if (normKey.startsWith('building') && normKey.includes('name')) {
        fields.building_name = value;
      } else if (normKey.startsWith('building') && normKey.includes('number')) {
        fields.building_no = value;
      } else if (normKey.includes('dependent') && normKey.includes('locality')) {
        fields.dependentloc = value;
      } else if (normKey.includes('street')) {
        fields.street = value;
      } else if (normKey.includes('town')) {
        fields.posttown = value;
      } else if (normKey.includes('code')) {
        fields.postcode = value;
      }
    };

    const applySource = (entries) => {
      (entries || []).forEach(({ key, value }) => assignValue(normalize(key), value));
    };

    if (Array.isArray(this.addressDetails)) {
      applySource(this.addressDetails.map((i) => ({ key: i?.label || i?.apiName, value: i?.value })));
    } else if (this.addressDetails && typeof this.addressDetails === 'object') {
      applySource(Object.entries(this.addressDetails).map(([key, value]) => ({ key, value })));
    }

    if (Array.isArray(this.editableAddressBuffer) && this.editableAddressBuffer.length) {
      applySource(this.editableAddressBuffer.map((i) => ({ key: i?.label, value: i?.value })));
    }

    return fields;
  }
  async buildCreateWorkRequestPayload() {
    const getVal = (list, label) => {
      const item = Array.isArray(list) ? list.find(i => i?.label === label) : undefined;
      return (item?.value ?? '').toString().trim();
    };
    // Parse inputs once
    const addressFields = this.resolveAddressFields();
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
    const tierKey = normalizePressure(this.statemap.get('pressureTier'));
    const mprn_pres = (pressureMap[tierKey] ?? pressureMap[normalizePressure(this.pressuretier)]);
    // Case-insensitive comparisons
    const normalizeLower = (s) => (s ?? '').toLowerCase();
    const mtype = metertype[normalizeLower(this.assetLabelMap.get('Meter Type'))] || "";
    const jobTypeLower = normalizeLower(this.job_type);
    const jobSubTypeLower = normalizeLower(this.job_subtype);
    const jobcodes = await getCWRJobCodes({
      jobCategory: this.job_type,
      jobSubCategory: this.job_subtype,
      category: this.isResidentialExchangeAsCommercial ? "Commercial" : this.ngme_industry === "D" ? "Residential" : "Commercial"
    });
    let jobCode;
    let subCategory;
    const isInstall = this.job_type === 'Install';
    const isMeter = this.job_subtype === 'Meter';
    const isResi = (String(this.status ?? '').trim().toLowerCase() === 'residential');
    if (isInstall && isMeter && isResi) {
      const newConn = this.stateofWorkRequest.isNewConnection === 'Yes';
      const recon = this.stateofWorkRequest.isReconnection === 'Yes';
      const reconDebt = this.stateofWorkRequest.isReconnectionDebt === 'Yes';

      if (newConn) {
        jobCode = 'INSTL';
        subCategory = 'NEWCN';
      }
      else if (recon && !reconDebt) {
        jobCode = 'INSTL';
        subCategory = 'RECON';
      }
      else if (recon && reconDebt) {
        jobCode = 'INSTL';
        subCategory = 'RCNDT';
      }

    } else {
      jobCode = jobcodes?.[0]?.NGMCP_Job_Category__c || '';
      subCategory = jobcodes?.[0]?.NGMCP_Job_Sub_category__c || '';
    }
    this.jobcodeCommerical = jobCode;
    this.JobSubCodeCommerical = subCategory;
    return {
      reportedpriority: 2,
      job_type: jobCode,
      ngme_consphone: this.contactDetails?.contactNumber ?? "",
      description_longdescription: this.contactDetails?.instructions ?? "",
      job_subtype: subCategory,
      targetstart: this.targetstart ?? "",
      ngme_time: this.ngme_time ? (this.ngme_time.includes("(") ? this.ngme_time.replace(/\(.*?\)/g, "").trim() : this.ngme_time.trim()) : "",
      source: this.source ?? "",
      job_sub_subtype: '',
      ngme_lf_mksctcd: this.isResidentialExchangeAsCommercial ? 'I' : this.ngme_industry,
      ngme_liferay_slot: this.ngme_liferay_slot ?? "",
      assetnum: this.assetnum ?? "",
      suppliercode: this.suppliercode ?? "",
      location: this.location ?? "",
      ngme_constitle: this.contactDetails?.title ?? "",
      ngme_consemail: this.contactDetails?.emailAddress ?? "",
      ngme_consname: this.contactDetails?.name ?? "",
      mprn_pres,
      curpayment: NGME_REQPAY[normalizeLower(this.assetLabelMap?.get?.('Payment Mechanism') ?? '')] || "",
      assettype: (jobSubTypeLower === "converter" ? "CONVR" : "METER"),
      newmodel: this.statemap.get('MeterSize') ?? "",
      metmodel: this.assetLabelMap.get('Model') ?? "",
      mettype: mtype,
      status: "NEW",
      // If backend expects 'Y'/'N' for these, keep asYN here; else use raw values.
      ngme_lf_eleint: (this.asYN?.(this.statemap?.get?.('electricInterface')) ?? this.statemap?.get?.('electricInterface')) || "N",
      ngme_lf_twinpress: (this.asYN?.(this.statemap?.get?.('twinStream')) ?? this.statemap?.get?.('twinStream')) || "N",// this.asYN?.(this.statemap.get('twinStream')) ?? this.statemap.get('twinStream') ?? "N",
      ngme_lf_conventer: (this.asYN?.(this.statemap?.get?.('converterRequired')) ?? this.statemap?.get?.('meterBypass')) || "N",//this.asYN?.(this.statemap.get('converterRequired')) ?? this.statemap.get('converterRequired') ?? "N",
      ngme_lf_bypass: (this.asYN?.(this.statemap?.get?.('meterBypass')) ?? this.statemap?.get?.('meterBypass')) || "N",//this.asYN?.(this.statemap.get('meterBypass')) ?? this.statemap.get('meterBypass') ?? "N",
      building_name: addressFields.building_name,
      building_no: addressFields.building_no,
      dependentloc: addressFields.dependentloc,
      street: addressFields.street,
      posttown: addressFields.posttown,
      postcode: addressFields.postcode,
      reportedemail: this.userEmail,
      reqpayment: NGME_REQPAY[normalizeLower(this.statemap?.get?.("paymentMethod") || this.statemap?.get?.("newMeterPaymentMethod"))] ?? "",// NGME_REQPAY[normalizeLower(this.statemap?.get?.('paymentMethod') ?? '')]||"",
      microbusiness: this.microbusiness == "Y" ? "Y" : "N",
      additionalinfo: await this.buildCreateWorkRequestAdditionalInfo(),
      ticketspec: await this.buildticketrequest(),
    };
  }
  // submitcreateworkRequestFlow
  async submitcreateworkRequestFlow() {
    try {
      this.isLoading = true;
      let response;
      let requestId;
      const NGME_REASITVIT = {
        'site visit for enquiry/compliant': 'SVTXXXX',
        'site visit for enquiry/complaint': 'SVTXXXX', // variant
        'ad-hoc': 'ADHOC',
        'adhoc': 'ADHOC',
        'converter re-syncing': 'NGMRSCO',
        'install ems to isolation': 'INSEM01'
      };

      const payload = await this.buildCreateWorkRequestPayload();
      payload.additionalinfo.push({
        name: 'NGMCP_sla__c',
        value: this.wRSLA
      });
      payload.additionalinfo.push({
        name: 'NGMCP_Reported_Email__c',
        value: this.contactDetails.requestonbehalfof
      });
      if (this.ngme_industry === "D" && this.job_type === 'Remove' && this.job_subtype === 'Pickup' && this.meterSize === 'U6') {
        payload.additionalinfo.push({
          name: 'NGMCP_Send_Job_to_RICO__c',
          value: 'Yes'
        });
        requestId =
          await createUrgentWorkRequestRecord({
            requestBody: JSON.stringify(payload),
            recordTypeValue: "Customer Work Request"
          });
        this.isModel = true;
        this.srNumber = requestId.name;
        this.submittedDate =
          this.formatDateToDDMMYYYY(new Date());
        return;
      } else {
        requestId =
          await createUrgentWorkRequestRecord({
            requestBody: JSON.stringify(payload),
            recordTypeValue: "Customer Work Request"
          });
      }
      if (!requestId) return;
      if (this.uploadedFilePayload?.length > 0) {
        const isUploaded = await uploadFiles({
          recordId: requestId.id,
          files: JSON.stringify(this.uploadedFilePayload)
        });

        if (!isUploaded) {
          return;
        }
      }
      delete payload.additionalinfo;
      // Exchange on a Residential MPRN with a new model other than U6 must use the
      // Commercial API and Commercial JSON format instead of the Residential one.
      const treatAsCommercial = this.isResidentialExchangeAsCommercial;
      if (this.ngme_industry === "D" && !treatAsCommercial) {
        if (!(this.job_type === 'Remove' && this.job_subtype === 'Pickup' && this.meterSize === 'U6')) {
          response = await submitCreattWorkRequest({
            requestBody: JSON.stringify(payload),
            requestId: requestId.id,
            industry: this.ngme_industry
          });
        }

      } else if (this.ngme_industry === "I" || treatAsCommercial) {
        const siteVisitReason = this.statemap?.get?.('siteVisitReason')?.toLowerCase().trim();
        // Find the matching code
        const reasonCode = NGME_REASITVIT[siteVisitReason] ?? '';
        payload.pickuptype = (this.asYN?.(this.statemap?.get?.('pickupEquipment'))).toUpperCase();// this.statemap?.get?.('pickupEquipment') ?? '';
        payload.housing = (this.asYN?.(this.statemap?.get?.('housingRequired')));//this.statemap?.get?.('housingRequired') ?? '';
        payload.purging = (this.asYN?.(this.statemap?.get?.('purging')));//this.statemap?.get?.('purging') ?? '';
        payload.carryout = (this.asYN?.(this.statemap?.get?.('purging')));//this.statemap?.get?.('purging') ?? '';
        payload.debtservice = `${this.job_type}_${this.job_subtype}` === 'Other Visits_Adversarial removal' ? 'REMOVL' : '';
        payload.incdec = (this.asYN?.(this.statemap?.get?.('pressureChangeType')));//this.statemap?.get?.('pressureChangeType') ?? '';
        payload.reason = reasonCode;//this.statemap?.get?.('pressureChangeTypepressureChangeType') ?? '';
        // Force the Commercial industry code ("I") so Apex routes to the Commercial
        // endpoint, even when the underlying MPRN is Residential (Exchange / non-U6).
        response = await submitCreattWorkRequest({
          requestBody: JSON.stringify(payload),
          requestId: requestId.id,
          industry: treatAsCommercial ? "I" : this.ngme_industry
        });
      }

      const parsed =
        typeof response === "string" ? JSON.parse(response) : response;

      if (parsed?.ticketid) {
        if (this.uploadedFilePayload?.length > 0) {
          const uploadRequest = await uploadtoMAximoSystem({
            files: JSON.stringify(this.uploadedFilePayload),
            srticket: parsed.ticketid,
            uid: parsed.ticketuid,
            doctype: 'GT1'
          });
        }
        const srvalue = parsed?.ticketid ? `SR-${parsed.ticketid}` : '';
        this.isModel = true;
        this.srNumber = srvalue;
        this.submittedDate =
          this.formatDateToDDMMYYYY(new Date());
        this.buildEngineerVisitMessage();
      } else {

      }

    } catch (e) {
      console.error("Submission failed", e);
    } finally {
      this.isLoading = false;
    }
  }

  /* ============================
   * START NOW SLA (Industry D)
   * 3 hours during business hours on a working day; 4 hours otherwise
   * ============================ */
  getStartNowSlaHours() {
    if (this.windonFlag) {
      return 4;
    }
    if (this.ngme_industry !== "D") {
      return 4;
    }
    const result = this.validateStartNow();
    return result.allowed && !result.isWeekendOrHoliday ? 3 : 4;
  }

  /* ============================
   * ENGINEER VISIT MESSAGE
   * ============================ */
  buildEngineerVisitMessage() {
    if (this.startNowFlag) {
      this.engineerVisitMessage =
        ENGINEER_VISIT_MSG_STARTNOW.replace("{0}", this.getStartNowSlaHours());
    } else if (this.pickupDateFlag) {
      const [start, end] = this.ngme_time.split(" - ");
      this.engineerVisitMessage =
        ENGINEER_VISIT_MSG
          .replace("{0}", this.formatDateToDDMMYYYY(this.targetstart))
          .replace("{1}", start)
          .replace("{2}", end);
    } else if (this.workRequestFlag && this.successprice) {
      const [start, end] = this.ngme_time.split(" - ");
      this.engineerVisitMessage =
        ENGINEER_VISIT_MSG
          .replace("{0}", this.formatDateToDDMMYYYY(this.targetstart))
          .replace("{1}", start)
          .replace("{2}", end);
    } else if (this.workRequestFlag && !this.successprice) {
      this.engineerVisitMessage = NONSTANDARDPRICE;
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
    event.stopPropagation();
    event.currentTarget.classList.add("drag-over");
  }

  handleDragLeave(event) {
    event.preventDefault();
    event.stopPropagation()
    event.currentTarget.classList.remove("drag-over");
  }

  handleFileDrop(event) {
    event.preventDefault();
    event.stopPropagation();
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
              dType: "PHT",
              base64: base64Data
            }
          });
        };

        reader.readAsDataURL(file);
      });

      readPromises.push(filePromise);
    });

    //  Wait for ALL files to be read
    Promise.all(readPromises).then(results => {

      results.forEach(res => {
        this.uploadedFiles = [...this.uploadedFiles, res.ui];
        this.uploadedFilePayload = [...this.uploadedFilePayload, res.payload];
      });
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
      return null;
    }

    const day = String(date.getDate()).padStart(2, "0");
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const year = date.getFullYear();

    return `${day}/${month}/${year}`;
  }
  // --- Delete uploaded file ---
  handleFileDelete(event) {
    this.fileError = '';
    const name = event.currentTarget.dataset.name;
    this.uploadedFiles = this.uploadedFiles.filter((f) => f.name !== name);
    this.uploadedFilePayload = this.uploadedFilePayload.filter(
      (f) => f.name !== name
    );
  }

  getTotalUploadedFileSize() {
    return (this.uploadedFilePayload || []).reduce(
      (total, file) => total + (file?.size || 0),
      0
    );
  }

  validateCombinedAttachmentSize() {
    const totalSize = this.getTotalUploadedFileSize();
    if (totalSize > MAX_TOTAL_ATTACHMENT_SIZE) {
      this.fileError = `Combined size of attachments (${this.formatFileSize(totalSize)}) exceeds ${MAX_FILE_SIZE_MB} MB limit. Please amend and submit.`;
      return false;
    }
    return true;
  }

  formatFileSize(bytes) {
    if (bytes < 1024) return `${bytes} B`;
    else if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    else return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }

  handleDateSelected(event) {
    const selectedDateStr = event.detail.date;
    // Convert string to Date object
    const selectedDate = new Date(selectedDateStr);
    // Set time and date
    this.ngme_time = selectedDate.toTimeString().slice(0, 5);
    this.targetstart = selectedDate.toISOString().split("T")[0];
  }
  handleStateResponse(event) {
    this.stateResponseFlag = true;
    const detail = event?.detail;
    if (!detail) {
      return;
    }
    this.stateofWorkRequest = detail.state;
    this.job_type = detail.jobtype;
    this.job_subtype = detail.subJobType;
    this.successprice = detail.successprice;
    if (Array.isArray(detail.state.fileuploads) && detail.state.fileuploads.length > 0) {
      this.uploadedFilePayload = [
        ...this.uploadedFilePayload,
        ...detail.state.fileuploads
      ];
    }
    if (detail?.sla) {
      this.wRSLA = detail.sla;
    }
    if (!this.isRequestTypeLocked) {
      this.isRequestTypeLocked = true;
    }
    // Normalize appointment flag to boolean (handles 'true'/'false' strings and truthy values)
    /* const appointmentFlag = typeof detail.appointmentFlag === 'string'
       ? detail.appointmentFlag.toLowerCase() === 'true'
       : Boolean(detail.appointmentFlag);*/
    this.status = this.isResidentialExchangeAsCommercial ? "commercial" : this.status;
    const appointmentFlag =
      ((typeof detail?.appointmentFlag === 'string'
        ? detail.appointmentFlag.trim().toLowerCase() === 'true'
        : Boolean(detail?.appointmentFlag)));
    this.showAppointmentFields = ((String(this.status ?? '').trim().toLowerCase() === 'residential')
      && (detail?.jobtype === 'Remove')
      && (detail?.subJobType === 'Pickup')) ? false : this.status?.toLowerCase() === "commercial" ? false : appointmentFlag;
    this.showcontactdetails = true;

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
    this.windOnRequesterError = false;
    if (val === "customer") {
      this.job_sub_subtype = "WOC XX XX";
    } else if (val === "supplier") {
      this.job_sub_subtype = "WOS XX XX";
    } else {
      // Optional: handle unexpected values
      this.job_sub_subtype = undefined;
    }

    // Optional: if you also keep requester in state for UI class/checked bindings:
    this.selectedRequester = val; // 'customer' or 'supplier'
  }
  get showsubmitSection() {
    return !(this.enquiryFlag || this.techEnquiryFlag || this.deappointmentFlag || this.amrFlag || (this.workRequestFlag && !this.stateResponseFlag));
  }

  get isCustomerSelected() {
    return this.windOnRequestedBy === 'customer';
  }

  get isSupplierSelected() {
    return this.windOnRequestedBy === 'supplier';
  }

  get visibleStartOptions() {
    // Non-NGM users → hide retrospective
    if (!this.isNGMUser) {
      return this.startOptions.filter(opt => opt.value !== "restro");
    }

    // NGM users → show all
    return this.startOptions;
  }

  resetUrgentStartOptions() {
    this.selectedStartOption = null;
    this.startNowFlag = false;
    this.showRestro = false;
    this.pickupDateFlag = false;
    this.retrospectiveFlag = false;

    // clear radio selection
    if (Array.isArray(this.startOptions)) {
      this.startOptions = this.startOptions.map(opt => ({
        ...opt,
        isChecked: false,
        className: "radio-card"
      }));
    }

    // clear validation errors
    if (this.validationErrors?.startNow) {
      delete this.validationErrors.startNow;
    }
    if (this.validationErrors?.startOption) {
      delete this.validationErrors.startOption;
    }

    // clear appointment data
    this.selectedDate = null;
    this.selectedSlot = null;
    this.selectedSlotLabel = "";
    this.appointmentOptions = [];
  }

  get windOnCardClass() {
    return this.isWindOnSelected
      ? "radio-card selected"
      : "radio-card";
  }


  resetWindOnState() {

    this.windonQuestionFlag = false;
    this.windonFlag = false;
    this.windOnRequestedBy = null;
    this.windOnRequesterError = false;
    this.selectedRequester = null;
    this.job_sub_subtype = undefined;
  }

  resetUrgentUI() {
    this.showJobType = false;
    this.keepJobTypesVisible = false;
    this.showFaulty = false;
    this.showWindOnOption = false;

    this.showAppointment = false;
    this.showAppointmentFields = false;
    this.showRestro = false;
    this.showBankCalender = false;
    this.showUwrRequest = false;

    this.startNowFlag = false;
    this.pickupDateFlag = false;
    this.retrospectiveFlag = false;

    this.selectedJobType = null;
    this.selectedStartOption = null;
  }

  resetContactDetailsState() {
    // 1️ Hide section
    this.showcontactdetails = false;

    // 2 Clear contact data
    this.contactDetails = {
      title: "",
      name: "",
      instructions: "",
      contactNumber: "",
      emailAddress: ""
    };

    // 3️ Clear validation errors
    this.validationErrors = {
      ...this.validationErrors,
      title: null,
      name: null,
      instructions: null,
      contactNumber: null,
      emailAddress: null
    };

    // 4️ Clear uploads
    this.uploadedFiles = [];
    this.fileError = null;
  }

  resetJobTypeState() {
    this.showJobType = false;
    this.keepJobTypesVisible = false;
    this.showFaulty = false;
    this.showWindOnOption = false;

    this.selectedJobType = null;

    if (Array.isArray(this.jobTypes)) {
      this.jobTypes = this.jobTypes.map(job => ({
        ...job,
        isChecked: false,
        className: "radio-card"
      }));
    }

    // Wind-on specific cleanup
    this.windonQuestionFlag = false;
    this.windonFlag = false;
    this.job_sub_subtype = undefined;
  }

  requestContext = {
    type: null,        // work | amr | deappoint | urgent | dataQuery | tQuery
    jobType: null,     // install | exchange | remove | faulty | windon
    startOption: null, // now | pick | restro
  };


  setRequestType(type) {
    this.resetAllDerivedState();

    this.requestContext.type = type;

    switch (type) {
      case "work":
        this.workRequestFlag = true;
        break;

      case "amr":
        this.amrFlag = true;
        break;

      case "deappoint":
        this.deappointmentFlag = true;
        break;

      case "urgent":
        this.workRequestFlag = true;
        this.showJobType = true;
        break;

      case "dataQuery":
        this.enquiryFlag = true;
        this.queryvalue = "AST";
        break;

      case "tQuery":
        this.techEnquiryFlag = true;
        this.queryvalue = "TQUERY";
        break;
    }
  }


  resetAllDerivedState() {
    // Request flags
    this.workRequestFlag = false;
    this.amrFlag = false;
    this.deappointmentFlag = false;
    this.enquiryFlag = false;
    this.techEnquiryFlag = false;

    // Job Type UI
    this.showJobType = false;
    this.keepJobTypesVisible = false;
    this.showFaulty = false;
    this.showWindOnOption = false;

    // Job Type data
    this.requestContext.jobType = null;
    this.job_subtype = null;
    this.job_sub_subtype = null;

    if (Array.isArray(this.jobTypes)) {
      this.jobTypes = this.jobTypes.map(j => ({
        ...j,
        isChecked: false,
        className: "radio-card"
      }));
    }

    // Wind-On
    this.resetWindOnState();

    // Appointment
    this.resetUrgentStartOptions();

    // Contact
    this.resetContactDetailsState();

    // UI leftovers
    this.showAppointment = false;
    this.showAppointmentFields = false;
    this.showRestro = false;
    this.showUwrRequest = false;
  }

  resetRequestModeFlags() {
    this.workRequestFlag = false;
    this.amrFlag = false;
    this.deappointmentFlag = false;
    this.techEnquiryFlag = false;
    this.enquiryFlag = false;
    this.showWorkRequestChild = false;
  }

  resetRequestModeFlags() {
    this.workRequestFlag = false;
    this.deappointmentFlag = false;
    this.amrFlag = false;
    this.techEnquiryFlag = false;
    this.enquiryFlag = false;
    this.showWorkRequestChild = false;
  }

  autoSelectRequestType(value) {
    const allCards = this.template.querySelectorAll('.radio-card');
    allCards.forEach(card => {
      console.log('   ↳ card data-value =', card.dataset.value);
    });

    const card = this.template.querySelector(
      `.radio-card[data-value="${value}"]`
    );

    if (!card) {
      return;
    }
    this.handleCardClick({
      currentTarget: card
    });
  }
  getMappedRequestType(source) {
    const map = {
      WORK: 'work',
      OFF_GAS: 'urgent',
      DATA_QUERY: 'dataQuery',
      TECH_QUERY: 'tQuery',
      APPOINT: 'deappoint',
      DEAPPOINT: 'deappoint'
    };

    return map[source];
  }
  get falseServiceNowFlg() {
    return !!(this.startNowFlag || this.duplicateMessage);
  }
  get uwrEditFlag() {
    return ((this.workRequestFlag || this.job_subtype == "FAULT") && !this.isEditingAddress);
  }
  handleEdit = () => {
    this.isEditingAddress = true;
    this.editableAddressBuffer = (this.displayedAddressDetails || []).map(i => ({
      key: i.key ?? i.label,
      label: i.label,
      value: i.value,
      apiName: i.apiName ?? i.key ?? i.label,
      editable: i.editable !== false,
      maxLength: i.label === 'Post Code' ? 10 : 40
    }));
  }
  handleCancel() {
    this.isEditingAddress = false;
  }

  handleInputAddressChange(event) {
    const field = event.target.dataset.field;
    const value = event.target.value ?? '';
    const idx = this.editableAddressBuffer.findIndex(i => i.label === field);
    if (idx > -1) {
      this.editableAddressBuffer[idx] = { ...this.editableAddressBuffer[idx], value };
    }
    this.clearFieldError(field);
  }

  async handleSave() {
    this.isLoading = true;
    const draft = this.buildDraftFromLatest();
    this.clearAllInlineErrors();
    const hasError = this.validateDraftAndShowErrors(draft);
    if (hasError) {
      this.isEditingAddress = true;
      this.isLoading = false;
      return;
    }
    const serialNum = this.msn || "";
    // Prepare request body
    const requestBody = {
      ngme_c_st: draft.postalTown,
      ngme_s_st: draft.postalTown,
      ngme_c_prncpstreet: draft.street,
      ngme_s_prncpstreet: draft.street,
      ngme_c_depndlocality: draft.dependentLocality,
      ngme_s_depndlocality: draft.dependentLocality,
      ngme_c_spc: draft.postCode,
      ngme_s_spc: draft.postCode,
      siteid: this.siteid,
      location: this.location,
      ngme_suppname: this.suppliercode,
      locationsid: this.locationsid,
      ngme_c_sitebn: draft.buildingNumber,
      ngme_s_sitebn: draft.buildingNumber,
      ngme_c_bldngname: draft.buildingName,
      ngme_s_bldngname: draft.buildingName,
      ngme_addramendportal: 1,
      asset: [
        {
          serialnum: serialNum,
          assetnum: this.assetnum,
        },
      ],
    };
    try {
      const insertrecord = await insertAddress({
        requestBody: JSON.stringify(requestBody),
        locationId: this.locationsid,
      });
      if (insertrecord) {
        const result = await addressUpdate({
          requestBody: JSON.stringify(requestBody),
          locationId: this.locationsid,
          adreesRequestId: insertrecord,
        });
        if (result) {
          const newList = (this.displayedAddressDetails || []).map(orig => {
            const buf = (this.editableAddressBuffer || []).find(b => b.label === orig.label);
            return buf ? { ...orig, value: buf.value } : orig;
          });
          const target = this.displayedAddressDetails;
          if (Array.isArray(target)) {
            target.splice(0, target.length, ...newList);
          }
          this.addressDetails = target;
          this.isEditingAddress = false;
          this.isLoading = false;
          this.messageText = result;
          this.showSuccessMessage = true;
          // Hide after 3 seconds
          setTimeout(() => {
            this.showSuccessMessage = false;
          }, 3000);
        }
      }
    } catch (error) {
      this.messageText = addressErrormessage;
      this.errorMessage = true; // BUG: 172765
      // Hide after 3 seconds
      setTimeout(() => {
        this.errorMessage = false;
      }, 3000);
    } finally {
      this.isLoading = false;
    }

  }
  // Pull value by label first from buffer, else from addressDetails.
  buildDraftFromLatest() {
    const pick = (label) => {
      const fromEditable = (this.editableAddressBuffer || []).find(i => i.label === label)?.value;
      if (fromEditable !== undefined && fromEditable !== null) return String(fromEditable).trim();
      const fromAddr = (this.addressDetails || []).find(i => i.label === label)?.value;
      return String(fromAddr ?? '').trim();
    };

    return {
      buildingNumber: pick('Building Number'),
      buildingName: pick('Building Name'),
      street: pick('Street'),
      dependentLocality: pick('Dependent Locality'),
      postalTown: pick('Postal Town'),
      postCode: pick('Post Code')
    };
  }
  // Returns true if there is any validation error; also paints inline errors.
  validateDraftAndShowErrors(draft) {
    let hasError = false;
    if (!draft.buildingNumber && !draft.buildingName) {
      this.showInlineError('Building Number', 'Enter Building Number or Building Name');
      this.showInlineError('Building Name', 'Enter Building Number or Building Name');
      hasError = true;
    }
    const rows = [
      {
        key: 'street', ui: 'Street', nullify: () => { //this.customerDetails.street = '';
        }
      },
      {
        key: 'postalTown', ui: 'Postal Town', nullify: () => { //this.customerDetails.postalTown = ''; 
        }
      },
      {
        key: 'postCode', ui: 'Post Code', nullify: () => { //this.customerDetails.postCode = ''; 
        }
      }
    ];

    rows.forEach(r => {
      const val = (draft[r.key] || '').trim();
      if (!val) {
        r.nullify?.();
        this.showInlineError(r.ui, 'This field is mandatory');
        hasError = true;
      }
    });

    return hasError;
  }
  // If you keep a temp/customerDetails store, sync it from draft on error.
  syncCustomerDetailsFromDraft(draft) {
    this.customerDetails.buildingNumber = draft.buildingNumber || '';
    this.customerDetails.buildingName = draft.buildingName || '';
    this.customerDetails.street = draft.street || '';
    this.customerDetails.postalTown = draft.postalTown || '';
    this.customerDetails.postCode = draft.postCode || '';
    this.customerDetails.dependentLocality = draft.dependentLocality || '';
  }
  clearAllInlineErrors() {
    this.template.querySelectorAll(
      '.form-field .error-msg, .custom-input-element-section .error-msg'
    ).forEach(el => el.remove());
    this.template.querySelectorAll(
      '.form-field, .custom-input-element-section'
    ).forEach(ff => ff.classList.remove('has-error'));
    this.template.querySelectorAll('input[data-field]').forEach(inp => {
      inp.classList.remove('input-error');
    });
  }
  showInlineError(field, message) {
    const input = this.getInput(field);
    if (!input) return;
    input.classList.add('input-error');
    const formField =
      input.closest('.custom-input-element-section') ||
      input.closest('.form-field') ||
      input.parentElement;

    if (formField) {
      formField.classList.add('has-error');
      const existing = formField.querySelector('.error-msg');
      if (existing) existing.remove();
      if (message) {
        const span = document.createElement('span');
        span.className = 'error-msg slds-text-color_error';
        span.textContent = message;
        formField.appendChild(span);
      }
    }
  }
  clearFieldError(field) {
    const clearOne = (dataField) => {
      const el = this.template.querySelector(`input[data-field="${dataField}"]`);
      if (!el) return;

      el.classList.remove('input-error');

      const container =
        el.closest('.custom-input-element-section') ||
        el.closest('.form-field') ||
        el.parentElement;

      if (!container) return;

      container.classList.remove('has-error');
      const existing = container.querySelector('.error-msg');
      if (existing) existing.remove();
    };

    // Special handling for conditional pair: Building Number OR Building Name
    if (field === 'Building Number' || field === 'Building Name') {
      const b = this.template.querySelector('input[data-field="Building Number"]');
      const bn = this.template.querySelector('input[data-field="Building Name"]');

      const hasAny = ((b?.value ?? '').trim().length > 0) ||
        ((bn?.value ?? '').trim().length > 0);

      // If either has value, clear BOTH errors/borders
      if (hasAny) {
        clearOne('Building Number');
        clearOne('Building Name');
      }
      return;
    }
    const inp = this.template.querySelector(`input[data-field="${field}"]`);
    if (!inp) return;

    const hasValue = ((inp.value ?? '').trim().length > 0);
    if (hasValue) clearOne(field);
  }
  getInput(fieldLabel) {
    return this.template.querySelector(`input[data-field="${fieldLabel}"]`);
  }
  handleMicrobusinessChange = (event) => {
    this.microbusiness = event.target.value === 'Yes' ? 'Y' : 'N';
    if (this.microbusiness) {
      this.microbusinessInvalid = false;
      this.microbusinessErrorMessage = '';
    }
    this.showAppointmentFields = true;
  };
  get ismicrobusinesscwr() {
    return (this.workRequestFlag && this.status?.toLowerCase() === "commercial" && this.successprice);
  }
  getAddr(key, label) {
    if (this.addressDetails && !Array.isArray(this.addressDetails)) {
      return this.addressDetails[key] || '';
    }
    if (Array.isArray(this.addressDetails)) {
      const item = this.addressDetails.find(i => i.label === label);
      return item ? item.value : '';
    }
    return '';
  }
  get microbusinessErrorClass() {
    return this.microbusinessInvalid ? 'slds-form-element__help show' : 'slds-form-element__help hide';
  }
  validateMicrobusiness() {
    const selected = this.template.querySelector('input[name="microbusiness"]:checked');
    const isValid = !!selected;
    if (!isValid) {
      this.microbusinessInvalid = true;
      this.microbusinessErrorMessage = 'Please select Microbusiness.';
      // Optional: set focus to first radio
      const first = this.template.querySelector('input[name="microbusiness"]');
      first && first.focus();
    } else {
      this.microbusinessInvalid = false;
      this.microbusinessErrorMessage = '';
    }
    return isValid;
  }
  get faultReason() {
    return this.urgentworkrequestFlag && (this.showAppointmentFields || this.startNowFlag);
  }
  get hideCancelButton() {
    return this.shouldMaskData && this.profileName !== NGMCP_CRMProfileslabel;
  }
}