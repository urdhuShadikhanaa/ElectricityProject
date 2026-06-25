import { LightningElement, track, api, wire } from "lwc";
import getMetaData from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.getMeterModelSizeandcatagory";
import getAllAssestMasterData from "@salesforce/apex/NGMCP_WorkRequestController.geAllAssestMasterData";
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
import getPayemntMechanism from "@salesforce/apex/NGMCP_WorkRequestController.getTypeandPaymentMechanism";
import getThirdPartyAssest from "@salesforce/apex/NGMCP_WorkRequestController.getThirdPartyAsset";
import getCWRFieldMapping from "@salesforce/apex/NGMCP_CustomerWorkRequestFieldMapping.getMappings";
import getCWRJobCodes from "@salesforce/apex/NGMCP_CustomerWorkRequestFieldMapping.getJobCodes";
import submitCreattWorkRequest from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.submitCreattWorkRequest";
import NONSTANDARDPRICE from "@salesforce/label/c.NGMCP_Non_Standard_Price_Message";
import uploadFiles from '@salesforce/apex/NGMCP_RequestObjectClass.uploadFiles';
import uploadtoMAximoSystem from '@salesforce/apex/NGMCP_RequestObjectClass.uploadDocumentToMaximo';
import validateDeuplicateRequest from '@salesforce/apex/NGMCP_WorkRequestController.validateDeuplicateRequest';
import USER_ID from '@salesforce/user/Id';
//import EMAIL_FIELD from '@salesforce/schema/User.Email';
const FIELDS = ['User.Email', 'User.Profile.Name', 'User.Email'];
import { getRecord } from 'lightning/uiRecordApi';
import NGMCP_CRMProfileslabel from '@salesforce/label/c.NGMCP_CRMProfiles';

// UWR attachment limits: 5 MB per file, 5 MB combined total on submit
const MAX_FILE_SIZE = 4 * 1024 * 1024;
const MAX_TOTAL_ATTACHMENT_SIZE = 4 * 1024 * 1024;
const MAX_FILE_SIZE_MB = 4;
const debounce = (fn, delay = 150) => {
  let t;
  return (...args) => {
    clearTimeout(t);
    t = setTimeout(() => fn(...args), delay);
  };
};
export default class NGMCP_ThirdPartyEditableJobRequest extends LightningElement {
  // @api mprn = "";
  @api shortCode;
  @track isMprnExists = false; // when false, show residential question
  // @track status = "Residential";
  @track showEditableSections = false;
  @track metadataCache = [];
  @api metadataRecord;
  @track jobTypes = [];
  @track manufacturerMap = new Map();
  @track error;
  @track manufactureoptions;
  @track isResidential; // default value
  @track status;
  @track manufacturerValue;
  @track modelTypeToMechanism;
  @track meterModel;
  @track meterType;
  @track serialnumber;
  @track cwrdescription = ""; // 'Date may be subject to change';
  @track thirdpartyFlag = true;
  @track invalidappointmentSlot = false;
  @track meterSize;
  @track paymentMechanism;
  @track successprice;
  @track stateofWorkRequest;
  @track assetLabelMap;
  @track statemap;
  @track paymentmechanism;
  @track appointmentType;
  @track wRSLA;
  @track mprnsupplier;
  @track duplicateMessage;
  @api validateShortcode;
  @track microbusiness;
  @track microbusinessInvalid = false;
  @track microbusinessErrorMessage = '';
  @track faultMaxvalue = 120;
  @track faultReasonValue;
  @track faultRemainingChars;
  @track residentialSiteValue = null;             // 16 jan change
  @track showAmrInstallFieldsWhenNull = true;
  @track yearOptions;
  @track yearofmanufaturer;
  @track thriadPartyAssetDetails = {};
  @track jobcodeCommerical;
  @track JobSubCodeCommerical;
  @api hasExistingAddress;
  @track stateResponseFlag = false;

  @track address = {
    buildingNumber: "",
    buildingName: "",
    street: "",
    dependentLocality: "",
    postalTown: "",
    postCode: "",
  };

  @track asset = {
    manufacturer: "",
    model: "",
    serialNumber: "",
  };
  @track finalAddressDetails;
  @track selectedTitle = "";

  @api assetDetails = []; // Array expected
  @api addressDetails = {}; // Can come as object from parent
  @api status;
  @api paymentMechanism;
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
  @track startNowWeekendOrHolidayFlag = false;
  @track pickupDateFlag = false; //BUG 172390
  @track retrospectiveFlag = false; //BUG 172390
  @track errorFlag = false;
  @track enquiryFlag = false;
  @track queryvalue;
  @track nonNgmUserMessage = "";
  @track urgentworkrequestFlag = false;
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
  @track manufactureoptionList;

  @api wrapperRec;
  @track showAllAddress = false;

  @track showAppointmentSlots = false;
  @track showServicePartnerStatus = false;
  @track servicePartnerBoxClass;
  @track servicePartnerMessage;
  @track selectedDate;
  @track profile = false;  // 16 june change
  @track userId = USER_ID;
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
  @track workRequestFlag = false;
  initialized = false;
  @track wRSLA;
  @track requestTypeValues;
  isRequestTypeLocked = false;
  @track supplierInfo;

  @track errorMessage = "";
  // selectedShortCode;
  @api
  validateSupplier(shortCode) {
    this.selectedShortCode = shortCode;
    const requestTypesToValidate = [
      "work",
      "urgent",
      "amr",
      "deappoint",
      "dataQuery",
      "tQuery"
    ];

    //  EXACT CONDITION YOU WANT
    if (
      this.selectedRequestType &&
      requestTypesToValidate.includes(this.selectedRequestType) &&
      !shortCode
    ) {
      this.showShortCodeError = true;
    } else {
      this.showShortCodeError = false;
    }
  }

  @api
  revalidateOnSupplierChange(shortCode) {
    this.selectedShortCode = shortCode;
    const requestTypesToValidate = [
      "work",
      "urgent",
      "amr",
      "deappoint",
      "dataQuery",
      "tQuery"
    ];

    if (
      this.selectedRequestType &&
      requestTypesToValidate.includes(this.selectedRequestType) &&
      !shortCode
    ) {
      this.showShortCodeError = true;
    } else {
      this.showShortCodeError = false;
    }
  }

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
  workRequestCommercialwithmicrobusiness = [
    { label: '08:00 - 12:00(AM)', value: 'AM' },
    { label: '12:00 - 16:00(PM)', value: 'PM' }
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
  @track profileName;


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

  workRequestResidentials = [
    { label: "08:00 - 20:00(AT)", value: "AT" },
    { label: "08:00 - 12:00(AM)", value: "AM" },
    { label: "12:00 - 16:00(PM)", value: "PM" },
    { label: "08:00 - 10:00(S1)", value: "S1" },
    { label: "10:00 - 12:00(S2)", value: "S2" },
    { label: "12:00 - 14:00(S3)", value: "S3" },
    { label: "14:00 - 16:00(S4)", value: "S4" },
    { label: "16:00 - 18:00(S5)", value: "S5" },
    { label: "18:00 - 20:00(S6)", value: "S6" },
  ];
  workRequestCommercial = [
    { label: "08:00 - 20:00(AT)", value: "AT" },
    { label: "08:00 - 13:00(AM)", value: "AM" },
    { label: "12:00 - 20:00(PM)", value: "PM" },
  ];

  // --- Commercial & Residential (Weekend / Holiday) Slots ---
  commercialAndWeekendSlots = [
    { label: "08:00 - 12:00(S1)", value: "S1" },
    { label: "10:00 - 14:00(S2)", value: "S2" },
    { label: "12:00 - 16:00(S3)", value: "S3" },
    { label: "14:00 - 18:00(S4)", value: "S4" },
    { label: "16:00 - 20:00(S5)", value: "S5" },
  ];

  @wire(getRecord, { recordId: '$userId', fields: FIELDS })
  userRecord({ error, data }) {
    if (data) {
      this.email = data.fields.Email.value;
      this.profileName = data.fields?.Profile?.value?.fields?.Name?.value;
      this.profile = this.profileName === 'NGMCP_Gas Supplier Agent' || this.profileName === 'NGMCP_Gas Supplier Manager';
      this.userEmail = data.fields.Email.value;
      if (this.profileName === NGMCP_CRMProfileslabel) {
        this.updateAddressDetails();
      }
    }
  }
  @wire(getAllAssestMasterData)
  wiredAssetDataConfigs({ error, data }) {
    if (data) {
      this.manufacturerMap = new Map();

      data.forEach((item) => {
        const key = item.NGMCP_Manufacturer_Name__c;

        if (!this.manufacturerMap.has(key)) {
          this.manufacturerMap.set(key, {
            manufacturer: key,
            models: [],
            type: [],
            fullRecords: [],
          });
        }

        const manufacturerData = this.manufacturerMap.get(key);

        const modelsArray = (item.NGMCP_Meter_Model__c || "")
          .split(",")
          .map((model) => model.trim())
          .filter((model) => model);

        /* const typeArray = (item.NGMCP_Type__c || "")
                .split(",")
                .map(type => type.trim())
                .filter(type => type);*/

        manufacturerData.models.push(...modelsArray);
        // manufacturerData.type.push(...typeArray);
        manufacturerData.fullRecords.push(item);
      });

      // Remove duplicates and sort
      this.manufacturerMap.forEach((data) => {
        data.models = [...new Set(data.models)].sort();
        data.type = [...new Set(data.type)].sort();
      });

      //  Update assetDetails for Manufacturer dropdown
      const manufacturerOptions = Array.from(this.manufacturerMap.keys()).map(
        (m) => ({ label: m.toUpperCase(), value: m })
      );
      this.manufactureoptionList = manufacturerOptions;
      this.assetDetails = this.assetDetails.map((item) => {
        if (item.apiName === "manufacturer") {
          return { ...item, options: manufacturerOptions };
        }
        if (item.apiName === "yearofmanufaturer") {
          return { ...item, options: this.yearOptions };
        }
        return item;
      });


    } else if (error) {
      this.error = error;
    }
  }

  @wire(getHolidays)
  wiredHolidays({ data, error }) {
    if (data) {
      this.holidays = data.map((h) => {
        const dateObj = new Date(h);
        return dateObj.toISOString().split("T")[0];
      });

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

  get isWindOnSelected() {
    return this.selectedJobType === 'windon';
  }

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

  /*handleStatusChange(event) {
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

    if ((currentMinutes >= endMinutes) && (slotDateStr === this.selectedDate) && !['COT ET XX', 'ECR PR XX'].includes(this.stateofWorkRequest?.serviceType)) {
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
  // @track startOptions = [
  //     {
  //         label: 'Start Now',
  //         value: 'now',
  //         isChecked: false,
  //         className: 'radio-card',
  //         description: 'For an engineer to attend within the agreed SLA upon submission of the request.'
  //     },
  //     {
  //         label: 'Pick Date/Time',
  //         value: 'pick',
  //         isChecked: false,
  //         className: 'radio-card',
  //         description: 'For an engineer to attend within the agreed SLA from the start time of the appointment slot selected.'
  //     },
  //     {
  //         label: 'Retrospective',
  //         value: 'restro',
  //         isChecked: false,
  //         className: 'radio-card',
  //         description: 'To raise a request on a past dated appointment for retrospective completion by NGM.'
  //     }
  // ];

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
    }
    else if (statusLower === "commercial" && this.workRequestFlag) {
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

  renderedCallback() {
    this.startNowErrorElement = this.template.querySelector(".start-now-error");
    if (this.initialized) return;
  }
  updateAddressDetails() {
    if (!this.hasExistingAddress) {
      return;
    }
    this.addressDetails = this.addressDetails.map(field => ({
      ...field,
      value: this.hasExistingAddress[field.apiName] || ''
    }));
  }
  connectedCallback() {
    this.mprnsupplier = this.mprn + '-' + this.shortCode;
    this.supplierInfo = this.shortCode;
    this.loadHolidays();
    this.checkNGMUser();
  }
  get visibleStartOptions() {
    if (this.isNGMUser) {
      return this.startOptions;
    }
    // If you want pure hide:
    return this.startOptions.filter((o) => o.value !== "restro");

    // If you want to use date rule for non-NGM:
    // return this.startOptions.filter(o => o.value !== 'restro' || this.allowRetrospective);
  }
  renderedCallback() {

  }
  buildYearOptions(start, end) {
    if (end < start) return [];
    const opts = [];
    for (let y = start; y <= end; y++) {
      const s = String(y);
      opts.push({ label: s, value: s });
    }
    return opts;
  }
  get isYes() {
    return this.isResidential === "Yes";
  }

  get isNo() {
    return this.isResidential === "No";
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
      })
      .catch((error) => {
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
      desc: "To support customers who are currently 'off-supply' due to a gas meter fault (Residential PP/CR meter fault or Commercial TFM).",
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
    /* {
       value: "tQuery",
       label: "Technical Queries (TQ)",
       desc: "To query a suspected fault on an NGM Asset.",
       isChecked: false,
       className: "radio-card",
       isHidden: false,
     },*/
  ];

  titles = ["Mr", "Mrs", "Miss", "Ms", "Dr", "Company"];

  // Getter to convert titles → picklist options
  get titleOptions() {
    return this.titles.map((t) => ({ label: t, value: t }));
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

    // 19 june

    if (field === "requestonbehalfof") {
  const trimmedValue = value ? value.trim() : "";

  // OPTIONAL → only validate if user enters value
  if (trimmedValue && trimmedValue.length > 50) {
    errors.requestonbehalfof = "Maximum 50 characters allowed.";
  } else {
    delete errors.requestonbehalfof;
  }
}

    // 19 june change end
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

  addressDetails = [
    {
      label: "Building Number",
      value: "",
      apiName: "buildingNumber",
      maxLength: 40,
    },
    {
      label: "Building Name",
      value: "",
      apiName: "buildingName",
      maxLength: 40,
    },
    { label: "Street", value: "", apiName: "street", maxLength: 40 },
    {
      label: "Dependent Locality",
      value: "",
      apiName: "dependentLocality",
      maxLength: 40,
    },
    { label: "Postal Town", value: "", apiName: "postalTown", maxLength: 40 },
    { label: "Post Code", value: "", apiName: "postCode", maxLength: 10 },
  ];

  assetDetails = [
    {
      label: "Manufacturer",
      value: "",
      apiName: "manufacturer",
      isDropdown: true,
      options: [],
    },
    {
      label: "Model",
      value: "",
      apiName: "model",
      isDropdown: true,
      options: [],
    },
    {
      label: "Manufacturer Serial no.",
      value: "",
      apiName: "serialNumber",
      isDropdown: false,
      maxLength: 14,
    },
    {
      label: "Meter Type",
      value: "",
      apiName: "meterType",
      isDropdown: true,
      options: [],
    },
    {
      label: "Payment Mechanism",
      value: "",
      apiName: "paymentMechanism",
      isDropdown: true,
      options: [],
    },
    {
      label: "Year of Manufacturer",
      value: "",
      apiName: "yearofmanufaturer",
      isDropdown: true,
      options: [],
    },
  ];
  makeKey(model, type) {
    const m = (model || "").trim().toLowerCase();
    const t = (type || "").trim().toLowerCase();
    return `${m}|${t}`;
  }
  toOptions(list) {
    return (list || []).map((v) => ({ label: v, value: v }));
  }
  setField(apiName, patch) {
    this.assetDetails = this.assetDetails.map((item) =>
      item.apiName === apiName ? { ...item, ...patch } : item
    );
  }

  setFieldValidity(el, value) {
    const fieldName = el.dataset.field;
    const errorEl = this.template.querySelector(
      `[data-error-for="${fieldName}"]`
    );

    const hasValue = !!(value && value.trim());

    if (!hasValue) {
      // Native validity (for programmatic checks and form submission)
      el.setCustomValidity("This is a required field");
      // Your visible error span
      if (errorEl) {
        errorEl.textContent = "This is a required field";
        errorEl.classList.add("shown");
      }
    } else {
      el.setCustomValidity("");
      if (errorEl) {
        errorEl.textContent = "";
        errorEl.classList.remove("shown");
      }
    }

    // Try to show native UI (may be suppressed in LWC, but still good to call)
    el.reportValidity();
  }

  validateAllFields() {
    let allValid = true;
    const fields = this.template.querySelectorAll(".input-field");

    fields.forEach((el) => {
      const value = el.value;
      this.setFieldValidity(el, value);

      if (!value || !value.trim()) {
        allValid = false;
        el.setAttribute("data-invalid", "true");
      } else {
        el.removeAttribute("data-invalid");
      }
    });

    // Optional: focus first invalid
    if (!allValid) {
      const firstInvalid = this.template.querySelector(
        '.input-field[data-invalid="true"]'
      );
      firstInvalid?.focus();
    }

    return allValid;
  }

  async handleAssetEdit(event) {
    const field = event?.target?.dataset?.field;
    const value = event?.target?.value ?? "";

    const el = event.target;

    if (!this.ensureResidentialSelected()) {
      const now = Date.now();

      this.assetDetails = this.assetDetails.map((item) =>
        item.apiName === field && item.isDropdown
          ? { ...item, value: "" } // clear to placeholder
          : item
      );

      return; // ignore change
    }

    this.setFieldValidity(el, value);

    // Optional: update your model
    const apiName = el.dataset.field;
    const idx = this.assetDetails.findIndex((f) => f.apiName === apiName);
    if (idx > -1) {
      this.assetDetails[idx].value = value;
    }

    // Update the changed field’s value first
    this.setField(field, { value });

    switch (field) {
      case "manufacturer":
        this.manufacturerValue = value;
        this.thriadPartyAssetDetails = {
          ...this.thriadPartyAssetDetails,
          manufacturer: this.manufacturerValue
        };

        // Build fresh model options from your map
        const selectedData = this.manufacturerMap?.get(value);
        const modelOptions = this.toOptions([...(selectedData?.models || [])]);

        // Reset dependent dropdowns in assetDetails
        const now = Date.now();
        this.assetDetails = this.assetDetails.map((item) => {
          if (item.apiName === "model") {
            return {
              ...item,
              options: modelOptions, // fresh options
              value: "", // clear selection to default
              domKey: `model-${now}`, //  force re-render (optional)
            };
          }
          if (item.apiName === "meterType") {
            return {
              ...item,
              options: [],
              value: "",
              domKey: `meterType-${now}`,
            };
          }
          if (item.apiName === "paymentMechanism") {
            return {
              ...item,
              options: [],
              value: "",
              domKey: `paymentMechanism-${now}`,
            };
          }
          if (item.apiName === "yearofmanufaturer") {
            return {
              ...item,
              options: [],
              value: "",
              domKey: `yearofmanufaturer-${now}`,
            };
          }
          return item;
        });


        // Clear internal state used by logic (if applicable)
        this.modelTypeMechanisms = new Map();
        this.meterModel = null;
        this.metertype = null;

        // (Optional) Ensure the DOM reflects cleared value even if something cached
        requestAnimationFrame(() => {
          const el = this.template?.querySelector('select[data-field="model"]');
          if (el) el.value = "";
        });

        break;

      case "model": {
        this.meterModel = value;
        this.thriadPartyAssetDetails = {
          ...this.thriadPartyAssetDetails,
          meterModel: this.meterModel
        };
        if (!this.manufacturerValue || !this.meterModel) {
          this.setField("meterType", { options: [], value: "" });
          this.setField("paymentMechanism", { options: [], value: "" });
          this.setField("yearofmanufaturer", { options: [], value: "" });
          this.modelTypeMechanisms = new Map();
          break;
        }

        try {
          const payload = {
            NGMCP_Manufacturer_Name__c: this.manufacturerValue,
            NGMCP_Meter_Model__c: this.meterModel,
          };
          this.modelTypeMechanisms = new Map();
          this.setField("meterType", {
            options: [],
            value: null,
            key: Date.now(),
          });
          this.setField("paymentMechanism", {
            options: [],
            value: null,
            key: Date.now(),
          });
          this.setField("yearofmanufaturer", {
            options: [],
            value: null,
            key: Date.now(),
          });
          const result = await getPayemntMechanism({
            payload: JSON.stringify(payload),
          });


          const typeSet = new Set();
          const map = new Map(); // local builder for `${model}|${type}` -> Set(mechanisms)

          (result || []).forEach((r) => {
            const type = (r.NGMCP_Type__c || "").trim();
            const model = (r.NGMCP_Meter_Model__c || this.meterModel).trim();
            let mechanism = (r.NGMCP_Payment_Mechanism__c || "").trim();
            if (!type) return;

            typeSet.add(type);

            // Support comma-separated mechanisms
            const mechs = mechanism.includes(",")
              ? mechanism
                .split(",")
                .map((s) => s.trim())
                .filter(Boolean)
              : mechanism
                ? [mechanism]
                : [];

            if (mechs.length) {
              const key = this.makeKey(model, type);
              const existing = map.get(key);
              if (existing) {
                mechs.forEach((m) => existing.add(m));
              } else {
                map.set(key, new Set(mechs));
              }
            }
          });

          this.modelTypeMechanisms = map;

          // Update dropdowns
          this.setField("meterType", {
            options: this.toOptions([...typeSet]),
            value: "",
          });
          this.setField("paymentMechanism", { options: [], value: "" });
          this.setField("yearofmanufaturer", { options: [], value: "" });
        } catch (e) {
          this.modelTypeMechanisms = new Map();
          this.setField("meterType", { options: [], value: "" });
          this.setField("paymentMechanism", { options: [], value: "" });
          this.setField("yearofmanufaturer", { options: [], value: "" });
        }
        break;
      }
      case "meterType":
        this.metertype = value;
        const currentTime = Date.now();
        // 1) Hard reset Payment Mechanism immediately (no previous selection shown)
        this.assetDetails = this.assetDetails.map((item) => {
          if (item.apiName === "paymentMechanism") {
            return {
              ...item,
              options: [], // clear options
              value: "", // clear selection to default
              domKey: `pm-${currentTime}`, // force re-render (optional)
            };
          }
          if (item.apiName === "yearofmanufaturer") {
            return {
              ...item,
              options: [], // clear options
              value: "", // clear selection to default
              domKey: `ym-${currentTime}`, // force re-render (optional)
            };
          }
          return item;
        });

        // 2) If no model or no mechanism map, stop here (it stays cleared)
        if (!this.meterModel || !this.modelTypeMechanisms?.size) {
          break;
        }
        const payload = {
          NGMCP_Manufacturer_Name__c: this.manufacturerValue,
          NGMCP_Model__c: this.meterModel,
          NGMCP_Type__c: this.metertype
        };
        const result = await getThirdPartyAssest({
          payload: JSON.stringify(payload),
        });
        this.yearOptions = this.buildYearOptions(result[0].NGMCP_Year_From__c, result[0].NGMCP_Year_To__c);
        this.thriadPartyAssetDetails = {
          ...this.thriadPartyAssetDetails,
          metertype: this.metertype,
          metric_Imperial: result[0].NGMCP_Metric_Imperial__c,
          dials: result[0].NGMCP_Dials__c,
          capacity: result[0].NGMCP_Capacity__c,
          factor: result[0].NGMCP_Factor__c,
          year: result[0].NGMCP_Year_From__c,
          manufacturer_code: result[0].NGMCP_Manufacturer_Code__c,
        };
        // 3) Compute key and normalize mechanisms
        const key = this.makeKey(this.meterModel, this.metertype);
        const raw = this.modelTypeMechanisms.get(key);

        let mechanisms = [];
        if (raw instanceof Set) {
          mechanisms = Array.from(raw);
        } else if (Array.isArray(raw)) {
          mechanisms = raw;
        } else if (typeof raw === "string") {
          mechanisms = raw
            .split(",")
            .map((s) => s.trim())
            .filter(Boolean);
        }

        mechanisms = Array.from(
          new Set(mechanisms.map((s) => (s || "").trim()).filter(Boolean))
        );
        const mechanismOptions = this.toOptions(mechanisms);

        // 4) Load fresh options but keep selection cleared (no auto-select)
        this.assetDetails = this.assetDetails.map((item) => {
          if (item.apiName === "paymentMechanism") {
            return {
              ...item,
              options: mechanismOptions,
              value: "", // keep cleared
              domKey: `pm-${Date.now()}`, // bump key to re-render
            };
          }
          if (item.apiName === "yearofmanufaturer") {
            return {
              ...item,
              options: this.yearOptions,
              value: "", // keep cleared
              domKey: `ym-${Date.now()}`, // bump key to re-render
            };
          }
          return item;
        });

        requestAnimationFrame(() => {
          const el = this.template?.querySelector(
            'select[data-field="paymentMechanism"]'
          );
          if (el) el.value = ""; // force to default option
        });

        break;
      case "serialNumber":
        this.serialnumber = value;
        this.thriadPartyAssetDetails = {
          ...this.thriadPartyAssetDetails,
          serialNumber: this.serialnumber
        };
        break;
      case "paymentMechanism":
        this.paymentmechanism = value;
        this.thriadPartyAssetDetails = {
          ...this.thriadPartyAssetDetails,
          paymentmechanism: this.paymentmechanism
        };
        break;
      case "yearofmanufaturer":
        this.yearofmanufaturer = value;
        this.thriadPartyAssetDetails = {
          ...this.thriadPartyAssetDetails,
          yearofmanufaturer: this.yearofmanufaturer
        };
        break;
      default:
        // No-op
        break;
    }

  }

  handleUrgentWorkRequest(event) {
    const selected = event.target.value;
  }

  handleCategorySelect(event) {
    try {

      if (!this.ensureResidentialSelected()) {
        return; // ignore change
      }

      // Defensive checks to avoid "undefined" crashes
      if (!event || !event.target) {
        return;
      }
      const selectedValue =
        event.target.dataset?.value ||
        event.currentTarget.dataset?.value ||
        event.target.value ||
        "";
      if (!selectedValue) {
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


      if (selectedValue.toLowerCase() === "windon") {

        this.windonFlag = true;
        this.fetchServicePartnerStatus();
      } else {
        this.showServicePartnerStatus = false;
      }
    } catch (error) {
    }
  }
  handleResidentialChange(event) {
    const selected = event.target.value; // "Yes" or "No"
    this.isResidential = selected; // store Yes/No (optional)
    // Correct conversion
    this.status = selected === "Yes" ? "Residential" : "Commercial";
    this.showEditableSections = true;
    this.errorMessage = "";
    // 18 dec change
    this.isResidentialU6Site = (selected === "Yes");
    // 16 jan change
    //  NEW: Maintain both the raw value and a boolean "is-null" flag for AMR
    this.residentialSiteValue = selected;
    this.showAmrInstallFieldsWhenNull = !(selected === "Yes" || selected === "No");
    // 18 dec change end here    
    this.requestTypes = this.requestTypes.map(type => {
      if (type.value === "amr") {
        return { ...type, isHidden: selected === "Yes" };
      }
      return type;
    });
  }
  // 9 feb  change
  ensureResidentialSelected(context = '') {
    // If Yes/No is not chosen
    if (!this.isResidential) {
      // Always show the inline error whenever this is called
      this.errorMessage = "This field is required.";
      // Only block the action on submit, allow tile navigation to continue
      return context === 'SUBMIT' ? false : true;
    }
    // If chosen, make sure the error is cleared
    this.errorMessage = "";
    return true;
  }
  // 9 feb change end here


  handleAddressChange(event) {
    const { name, value } = event.target;
    this.address = { ...this.address, [name]: value };
  }

  handleAssetChange(event) {
    const { name, value } = event.target;
    this.asset = { ...this.asset, [name]: value };
  }

  // ---------------------------
  // DEBUG VERSION for Option 1
  // ---------------------------

  @api
  set metadataList(value) {
    this._metadataList = value;
    if (value) {
      this.initializeMetadata();
    }
  }

  get metadataList() {
    return this._metadataList;
  }

  initializeMetadata() {
    if (!this._metadataList) {
      return;
    }
    // Example fields — update based on your actual structure
  }

  prepareJobTypes(key) {
    this.fetchMetadata(key).then(() => {
      // FIX: enable appointment section ONLY AFTER jobTypes load
      if (this.jobTypes && this.jobTypes.length > 0) {
        if (!(this.workRequestFlag || this.enquiryFlag || this.techEnquiryFlag || this.deappointmentFlag || this.amrFlag))
          this.showAppointment = true;
      }
    });
  }
  /** Build cross-field context once, from the model */
  /** --------------------------
  * Address context
  * -------------------------*/
  getAddressContext() {
    const getVal = (key) =>
      (this.addressDetails?.find((f) => f.field === key)?.value ?? "").trim();
    return {
      buildingName: getVal("buildingName"),
      buildingNumber: getVal("buildingNumber"),
      street: getVal("street"),
      postalTown: getVal("postalTown"),
      postCode: getVal("postCode")
    };
  }

  /** --------------------------
   * Revalidate sibling building field
   * -------------------------*/
  revalidateSiblingBuilding(inputEl, values) {
    const field = inputEl?.dataset?.field;
    if (field !== "buildingName" && field !== "buildingNumber") return;

    const siblingField =
      field === "buildingName" ? "buildingNumber" : "buildingName";

    const siblingEl = this.template.querySelector(
      `input.address-input[data-field="${siblingField}"]`
    );
    if (!siblingEl) return;
    const currentValue = (inputEl.value ?? "").trim();
    const siblingValue = (siblingEl.value ?? "").trim();

    //  FIX: If either has value → clear both errors and STOP
    if (currentValue || siblingValue) {
      this.setInlineError(inputEl, "");
      this.setInlineError(siblingEl, "");
      siblingEl.setCustomValidity("");
      return;
    }
    // Only validate when BOTH are empty
    const sidx = Number(siblingEl.dataset.index);
    const svalue = (this.addressDetails[sidx]?.value ?? "").trim();
    this.validateField(siblingEl, siblingField, svalue, values);
  }

  /** --------------------------
   * Event handlers
   * -------------------------*/
  handleAddressEdit(event) {
    const inputEl = event.target;
    const idx = Number(inputEl.dataset.index);
    let value = (inputEl.value ?? "");
    if (inputEl.dataset.field === "postCode") {
      value = value.toUpperCase();
      inputEl.value = value;
    }
    value = value.trim();
    const item = this.addressDetails[idx];
    if (item) item.value = value;
    this.debouncedValidate(inputEl, value);
  }

  handleAddressBlur(event) {
    const inputEl = event.target;
    // Allow focus to move first
    window.setTimeout(() => {
      const value = (inputEl.value ?? "").trim();
      const field = inputEl?.dataset?.field;
      const values = this.getAddressContext();

      this.validateField(inputEl, field, value, values);
      this.revalidateSiblingBuilding(inputEl, values);
    }, 0);
  }

  /** --------------------------
   * Debounced validation (PASSIVE)
   * -------------------------*/
  debouncedValidate = debounce((inputEl, value) => {
    const values = this.getAddressContext();
    const field = inputEl?.dataset?.field;

    this.validateField(inputEl, field, value, values);

    //  REMOVED reportValidity (was stealing focus)
    // inputEl.reportValidity();

    this.revalidateSiblingBuilding(inputEl, values);
  });

  /** --------------------------
   * Bulk validation (submit only)
   * -------------------------*/
  validateAddress() {
    let allValid = true;

    // Read your model/context (may be stale)
    const values = this.getAddressContext?.() ?? {};
    // Helper: normalize string values
    const normalize = (v) => (v == null ? '' : String(v)).replace(/\u200B/g, '').trim();
    // Helper: read a field safely:
    // 1) prefer values[field]
    // 2) fallback to live DOM input value
    const getFieldValue = (field) => {
      const fromModel = normalize(values[field]);
      if (fromModel) return fromModel;
      const inputEl = this.template.querySelector(`input[data-field="${field}"]`);
      return normalize(inputEl?.value);
    };
    // ---------- Building rules ----------
    const buildingNameEl = this.template.querySelector('input[data-field="buildingName"]');
    const buildingNumberEl = this.template.querySelector('input[data-field="buildingNumber"]');

    const buildingNameVal = getFieldValue('buildingName');
    const buildingNumberVal = getFieldValue('buildingNumber');
    const hasBuildingValue = !!buildingNameVal || !!buildingNumberVal;
    if (!hasBuildingValue) {
      const msg = 'Enter either Building Name or Building Number.';
      if (buildingNameEl) {
        this.setInlineError(buildingNameEl, msg);
        buildingNameEl.reportValidity?.();
      }
      if (buildingNumberEl) {
        this.setInlineError(buildingNumberEl, msg);
        buildingNumberEl.reportValidity?.();
      }
      allValid = false;
    } else {
      if (buildingNameEl) this.setInlineError(buildingNameEl, '');
      if (buildingNumberEl) this.setInlineError(buildingNumberEl, '');
    }
    // ---------- Mandatory fields ----------
    const mandatoryFields = ['street', 'postalTown', 'postCode'];
    mandatoryFields.forEach((field) => {
      const inputEl = this.template.querySelector(`input[data-field="${field}"]`);
      const val = getFieldValue(field);

      if (!val) {
        if (inputEl) this.setInlineError(inputEl, 'This Field is mandatory.');
        allValid = false;
      } else {
        if (inputEl) this.setInlineError(inputEl, '');
      }
    });
    const postCodeEl = this.template.querySelector('input[data-field="postCode"]');
    const postCodeVal = getFieldValue('postCode');

    if (postCodeVal && !this.isValidUKPostcode(postCodeVal)) {
      if (postCodeEl) {
        this.setInlineError(
          postCodeEl,
          'Enter a valid UK Post Code (e.g. EC1A 1BB).'
        );
        // postCodeEl.reportValidity?.();
      }
      allValid = false;
    }
    return allValid;
  }

  /** --------------------------
   * Field validator (unchanged signature)
   * -------------------------*/
  validateField(inputEl, maybeFieldOrValue, maybeValueOrValues, maybeValues) {
    let field, value, values;
    if (typeof maybeValues !== "undefined") {
      field = maybeFieldOrValue;
      value = (maybeValueOrValues ?? "").trim();
      values = maybeValues;
    } else {
      field = inputEl?.dataset?.field;
      value = (maybeFieldOrValue ?? "").trim();
      values = this.getAddressContext();
    }
    const effective = {
      buildingName:
        field === "buildingName" ? value : (values.buildingName ?? "").trim(),
      buildingNumber:
        field === "buildingNumber" ? value : (values.buildingNumber ?? "").trim(),
      street:
        field === "street" ? value : (values.street ?? "").trim(),
      postalTown:
        field === "postalTown" ? value : (values.postalTown ?? "").trim(),
      postCode:
        field === "postCode" ? value : (values.postCode ?? "").trim()
    };

    let message = "";

    /*  Building Name / Number paired rule */
    if (
      (field === "buildingName" || field === "buildingNumber") &&
      !(effective.buildingName || effective.buildingNumber)
    ) {
      message = "Enter either Building Name or Building Number.";
    }

    /*  Individual mandatory fields */
    if (
      !message &&
      (field === "street" ||
        field === "postalTown" ||
        field === "postCode") &&
      !effective[field]
    ) {
      message = "This Field is mandatory.";
    }
    if (
      !message &&
      field === "postCode" &&
      effective.postCode &&
      !this.isValidUKPostcode(effective.postCode)
    ) {
      message = "Enter a valid UK Post Code (e.g. EC1A 1BB).";
    }
    this.setInlineError(inputEl, message);
  }
  isValidUKPostcode(postcode) {
    if (!postcode) return false;

    const regex =
      /^(?:[A-Z]{1,2}[0-9][0-9A-Z]?|[A-Z][0-9][A-Z]) [0-9][A-Z]{2}$/;

    return regex.test(postcode.trim());
  }
  /** --------------------------
   * Inline error renderer
   * -------------------------*/
  setInlineError(inputEl, message) {
    if (!inputEl) return;

    if (message) {
      inputEl.classList.add("has-error");
    } else {
      inputEl.classList.remove("has-error");
    }

    const errorSpan = inputEl.nextElementSibling;
    if (errorSpan && errorSpan.classList.contains("error-text")) {
      errorSpan.textContent = message || "";
    }

    inputEl.setCustomValidity(message || "");
  }


  async handleCardClick(event) {
    const selectedValue = event.currentTarget.dataset.value;
    const clickedCard = event.currentTarget;
    this.selectedRequestType = selectedValue;
    const requestTypesToValidate = [
      "work",
      "urgent",
      "amr",
      "deappoint",
      "dataQuery",
      "tQuery"
    ];

    // 9 feb change
    if (!this.isResidential) {
      // Show the red error message under the question
      this.errorMessage = "This field is required.";

      // Prevent the tile from being selected
      const radio = event.currentTarget.querySelector('input[type="radio"]');
      if (radio) {
        radio.checked = false; // visually keep it unselected
      }

      // Stop this click from flowing further
      event.preventDefault?.();
      event.stopPropagation?.();

      return; // <-- BLOCK the rest of handleCardClick logic
    }
    // --- BLOCKING MODE end ---

    if (requestTypesToValidate.includes(selectedValue)) {

      const validationEvent = new CustomEvent('checkshortcode', {
        detail: { requestType: selectedValue },
        bubbles: true,
        composed: true,
        cancelable: true
      });

      const notCancelled = this.dispatchEvent(validationEvent);
      if (!notCancelled) {
        const radio = event.currentTarget.querySelector('input[type="radio"]');
        if (radio) radio.checked = false;

        event.preventDefault();
        event.stopPropagation();

        return;
      }
    }

    // const selectedValue = event.currentTarget.dataset.value;

    if (selectedValue !== 'urgent') {
      this.errorFlag = false;
      this.nonNgmUserMessage = '';
    }
    this.requestTypeValues = ["work", "urgent", "amr", "deappoint", "dataQuery", "tQuery"];
    if (this.isRequestTypeLocked && this.requestTypeValues.includes(selectedValue)) {
      return;
    }
    if (["work", "amr", "deappoint", "dataQuery", "tQuery"].includes(selectedValue)) {
      this.resetRequestModeFlags();
      this.resetWindOnState();
      this.resetUrgentUI();
      this.resetContactDetailsState();
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
    // ===== END: Highlight card & check radio input =====


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

    if (this.isResidential === "Yes") {
      this.status = "Residential";
    } else if (this.isResidential === "No") {
      this.status = "Commercial";
    } else {
      this.status = "";
    }
    switch (selectedValue) {
      case "work":
        this.stateResponseFlag = false;
        this.resetUrgentStartOptions();
        this.urgentworkrequestFlag = false;
        this.workRequestFlag = true;
        this.techEnquiryFlag = false;
        this.enquiryFlag = false;
        this.amrFlag = false;
        this.deappointmentFlag = false;
        // -----------------------------------------------------
        // 1️ Generate KEY first (BEFORE prepareJobTypes)
        // -----------------------------------------------------
        const getValue = (apiName) => {
          const item = this.assetDetails.find(
            (obj) => obj.apiName === apiName
          );
          return item ? item.value.trim() : "";
        };

        let modeKeyAdjustments = getValue("model")
          .replace(/[\/. " *]/g, "_")
          .replace(/_+$/, "");

        let type = getValue("meterType")
          .replace(/[\/." * -]/g, "_")
          .replace(/_+/g, "_")
          .replace(/_+$/, "");

        let paymentMechanism = getValue("paymentMechanism");
        this.paymentMechanism = paymentMechanism;


        const mskCode =
          this.isResidential?.toLowerCase() === "residential" ||
            this.isResidential?.toLowerCase() === "yes"
            ? "D"
            : "I";

        const key = `${mskCode}_${modeKeyAdjustments}_${type}_Yes`;
        this.prepareJobTypes(key);

        this.showJobType = false;
        this.showWorkRequestChild = false;
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
        break;

      case "amr":
        if (!(this.validateAddress() && this.validateAllFields())) {
          const selectedValue = null;
          this.requestTypes = this.requestTypes.map((item) => ({
            ...item,
            isChecked: item.value === selectedValue,
          }));
          return;
        }
        if (["work", "amr", "urgent", "deappoint", "dataQuery", "tQuery"].includes(selectedValue)) {
          this.setRequestType(selectedValue);
          return;
        }
        this.urgentworkrequestFlag = false;
        // this.showWorkRequestChild = false;
        // this.techEnquiryFlag = false;
        // this.enquiryFlag = false;
        // this.workRequestFlag = false;
        // this.showJobType = false;
        // this.showRestro = false;
        // this.showAppointment = false;
        // this.showAppointmentFields = false;
        // this.showcontactdetails = false;
        // this.deappointmentFlag = false;
        // this.amrFlag = true;
        // this.errorFlag = false;
        this.nonNgmUserMessage = '';
        this.prepareJobTypesFromAsset();
        break;

      case "deappoint":
        this.resetUrgentStartOptions();
        this.urgentworkrequestFlag = false;
        this.showWorkRequestChild = false;
        this.techEnquiryFlag = false;
        this.workRequestFlag = false;
        this.enquiryFlag = false;
        this.showJobType = false;
        this.showRestro = false;
        this.showAppointment = false;
        this.showAppointmentFields = false;
        this.showcontactdetails = false;
        this.deappointmentFlag = true;
        this.amrFlag = false;
        this.errorFlag = false;
        this.nonNgmUserMessage = '';
        this.prepareJobTypesFromAsset();
        break;

      case "urgent":
        this.urgentworkrequestFlag = true;
        this.workRequestFlag = false;
        this.amrFlag = false;
        this.techEnquiryFlag = false;
        this.enquiryFlag = false;
        this.amrFlag = false;
        this.deappointmentFlag = false;
        this.cwrdescription = "";
        if (!this.validateAddress()) {
          const selectedValue = null;
          this.requestTypes = this.requestTypes.map((item) => ({
            ...item,
            isChecked: item.value === selectedValue,
          }));
          return;
        }
        const isValid = this.validateAllFields();
        if (!isValid) {
          const firstInvalid = this.template.querySelector(
            '.input-field[data-invalid="true"]'
          );
          firstInvalid?.focus();

          const selectedValue = null;
          this.requestTypes = this.requestTypes.map((item) => ({
            ...item,
            isChecked: item.value === selectedValue,
          }));
          return;
        }


        if (!this.isNGMUser && this.status == "Commercial") {
          this.errorFlag = true;
          this.nonNgmUserMessage =
            "You cannot submit an urgent work request on a Commercial Non - National Gas Metering site. Please reach out to 0800 001 4340 if this is needed immediately.";

        } else {
          this.showAppointmentFields = false;
          this.showJobType = true;
          this.showFaulty = true;
          this.job_type = "OTVST";
          this.job_subtype = "FAULT";
          this.source = "PORTAL";
          this.keepJobTypesVisible = true;



          // Wind On logic
          if (
            this.isResidential?.toLowerCase() === "residential" ||
            (this.isResidential?.toLowerCase() === "yes" &&
              this.paymentMechanism?.toLowerCase() === "pre payment")
          ) {
            this.showWindOnOption = true;
          } else {
            this.showWindOnOption = false;
          }
          // reset service partner info
          this.showServicePartnerStatus = false;
          this.servicePartnerStatus = null;
          this.servicePartnerMessage = null;
          this.showWarningMsg = false;

          // -----------------------------------------------------
          // 1️ Generate KEY first (BEFORE prepareJobTypes)
          // -----------------------------------------------------
          const getValue = (apiName) => {
            const item = this.assetDetails.find(
              (obj) => obj.apiName === apiName
            );
            return item ? item.value.trim() : "";
          };

          let modeKeyAdjustments = getValue("model")
            .replace(/[\/. " *]/g, "_")
            .replace(/_+$/, "");

          let type = getValue("meterType")
            .replace(/[\/." * -]/g, "_")
            .replace(/_+/g, "_")
            .replace(/_+$/, "");
          const mskCode =
            this.isResidential?.toLowerCase() === "residential" ||
              this.isResidential?.toLowerCase() === "yes"
              ? "D"
              : "I";

          const key = `${mskCode}_${modeKeyAdjustments}_${type}_Yes`;



          this.prepareJobTypes(key);

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

            this.selectedJobType = defaultJobType;
            this.showAppointment = true;
          }
          const raw = (this.mprnsupplier || '').toString();
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

          if (this.selectedJobType) {
            this.showAppointment = true;
          }
        }
        break;

      case "windon":
      case "faulty":
        this.jobTypes = this.jobTypes.map((job) => ({
          ...job,
          isChecked: job.value === selectedValue,
          className:
            job.value === selectedValue
              ? "radio-card selected"
              : "radio-card",
        }));

        this.keepJobTypesVisible = true;
        this.showJobType = true;
        this.errorFlag = false;
        this.nonNgmUserMessage = '';

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
            opt.value === selectedValue
              ? "radio-card selected"
              : "radio-card",
        }));

        this.selectedStartOption = "now";
        this.showAppointment = true;

        // const now = new Date();
        const result = this.validateStartNow();

        if (!result.allowed && !this.isNGMUser) {
          this.validationErrors.startNow =
            "You cannot submit an immediate start urgent work request during non working hours. Please reach out to 0800 001 4340 if this is needed immediately.";
          this.startNowFlag = false;
          this.startNowWeekendOrHolidayFlag = false;
          this.showAppointment = true;
          this.showRestro = false;
          this.showAppointmentFields = false;
          this.errorFlag = false;
          this.nonNgmUserMessage = '';
          return;
        }

        delete this.validationErrors.startNow;
        this.startNowFlag = true;
        this.startNowWeekendOrHolidayFlag = !!result.isWeekendOrHoliday;

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
        // this.targetstart = now.toISOString().split("T")[0];
        // this.ngme_time = now.toTimeString().slice(0, 5);
        this.ngme_liferay_slot = "AT";
        break;

      case "pick":


        this.appointmentType = "Pick Date/Time";
        this.selectedStartOption = "";
        this.startNowFlag = false;
        this.startNowWeekendOrHolidayFlag = false;

        this.startOptions = this.startOptions.map((opt) => ({
          ...opt,
          isChecked: opt.value === selectedValue,
          className:
            opt.value === selectedValue
              ? "radio-card selected"
              : "radio-card",
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
        this.selectedStartOption = "";
        this.startNowFlag = false;
        this.startNowWeekendOrHolidayFlag = false;

        this.startOptions = this.startOptions.map((opt) => ({
          ...opt,
          isChecked: opt.value === selectedValue,
          className:
            opt.value === selectedValue
              ? "radio-card selected"
              : "radio-card",
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
        if (!this.validateAddress()) {
          const selectedValue = null;
          this.requestTypes = this.requestTypes.map((item) => ({
            ...item,
            isChecked: item.value === selectedValue,
          }));
          return;
        }
        this.resetUrgentStartOptions();
        this.queryvalue = "AST";
        this.enquiryFlag = true;
        this.workRequestFlag = false;
        this.techEnquiryFlag = false;
        this.deappointmentFlag = false;
        this.amrFlag = false;
        this.prepareJobTypesFromAsset();
        break;

      case "tQuery":
        this.resetUrgentStartOptions();
        this.queryvalue = "TQUERY";
        this.enquiryFlag = false;
        this.workRequestFlag = false;
        this.techEnquiryFlag = true;
        this.deappointmentFlag = false;
        this.amrFlag = false;
        this.prepareJobTypesFromAsset();
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
        this.showServicePartnerStatus = false;
        this.servicePartnerStatus = null;
        this.servicePartnerMessage = null;
        this.showWarningMsg = false;
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
      this.removeFieldError("appointmentDate");
      this.removeFieldError("appointmentSlot");
    }

    if (this.validationErrors && this.validationErrors.startOption) {
      this.removeFieldError("startOption");
    }
  }

  async fetchMetadata(modelValue) {
    try {
      const result = await getMetaData({ meterModel: modelValue });
      // Ensure result is always treated as an array
      const metadataList = Array.isArray(result) ? result : [result];

      this.jobTypes = metadataList.map((item) => ({
        value: item.NGMCP_UWR_Job_Code__c,
        label: item.NGMCP_Portal_Category__c,
        description: item.NGMCP_Job_Description__c,
        isChecked: true,
        showRecommendation: true,
        className: "radio-card selected",
        suppliercode: this.shortCode
      }));
      if (this.jobTypes.length === 1) {
        this.selectedJobType = true;
        this.job_sub_subtype = this.jobTypes[0].value;
      }
      this.metadataRecord = this.jobTypes;
      const meterSize = metadataList[0]?.NGMCP_Meter_Size__c;
      this.meterSize = meterSize;
    } catch (error) {
      this.status = this.workRequestFlag ? this.status : "Error fetching metadata";
    } finally {

    }
  }
  /* =========================================================
     COMMON HELPERS
  ========================================================= */

  prepareJobTypesFromAsset() {
    if (!this.assetDetails || this.assetDetails.length === 0) {
      return;
    }

    const getValue = (apiName) => {
      const item = this.assetDetails.find(obj => obj.apiName === apiName);
      return item ? item.value?.trim() : "";
    };

    let modeKeyAdjustments = getValue("model")
      .replace(/[\/. " *]/g, "_")
      .replace(/_+$/, "");

    let type = getValue("meterType")
      .replace(/[\/." * -]/g, "_")
      .replace(/_+/g, "_")
      .replace(/_+$/, "");

    this.paymentMechanism = getValue("paymentMechanism");
    const mskCode =
      this.isResidential?.toLowerCase() === "residential" ||
        this.isResidential?.toLowerCase() === "yes"
        ? "D"
        : "I";
    const key = `${mskCode}_${modeKeyAdjustments}_${type}_Yes`;
    this.prepareJobTypes(key);
  }

  resetServicePartner() {
    this.showServicePartnerStatus = false;
    this.servicePartnerStatus = null;
    this.servicePartnerMessage = null;
    this.showWarningMsg = false;
  }

  resetJobTypes() {
    this.jobTypes = this.jobTypes.map(job => ({
      ...job,
      isChecked: false,
      className: "radio-card"
    }));
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
      const isResidential = ((this.status?.toLowerCase() === "residential") || (this.status?.toLowerCase() === "d"));
      const isCommercial = ((this.status?.toLowerCase() === "commercial") || (this.status?.toLowerCase() === "i"));

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
      console.log('nowDecimal',nowDecimal);
      console.log('startHour',startHour);
      console.log('endHour',endHour);
      console.log('isWeekendOrHoliday',isWeekendOrHoliday);
      return { allowed, isWeekendOrHoliday };
    } catch (error) {
      return { allowed: false, isWeekendOrHoliday: false };
    }
  }
  /* ===========================
 * MAIN SUBMIT HANDLER
 * =========================== */
  async handleSubmitUrgentWorkrequest(event) {

    event.preventDefault();

    // if (!this.ensureResidentialSelected()) return;

    if (!this.ensureResidentialSelected('SUBMIT')) return;   // 9 feb change

    if (!this.validateMicrobusiness() && (this.workRequestFlag && this.status?.toLowerCase() === "commercial" && this.successprice)) {
      return;
    }
    this.resetValidation();

    if (!this.validateForm()) return;

    if (!this.validateStartNowOption()) return;
    if (this.invalidappointmentSlot) {
      this.validationErrors.appointmentSlot =
        "This slot cannot be selected as it has already started, please select a valid slot";
      return;
    }

    if (!this.validateCombinedAttachmentSize()) {
      this.scrollToFirstError();
      return;
    }

    //if (!this.validatePartnerStatus()) return;

    //if (!this.validateConsent()) return;
    if (!this.workRequestFlag) {
      await this.submitWorkRequest();
    } else {
      await this.submitcreateworkRequestFlow();
    }
  }
  safeParse = val => {
    if (typeof val === "string") {
      try {
        return JSON.parse(val);
      } catch {
        return {};
      }
    }
    return val || {};
  }
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
    return val ?? '';
  }

  // Date flip "dd-mm-yyyy" -> "yyyy-mm-dd" (if applicable)
  toIso(s) {
    if (!s || typeof s !== 'string') return '';
    const [dd, mm, yyyy] = s.split('-');
    return (dd && mm && yyyy) ? `${yyyy}-${mm}-${dd}` : s;
  }
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
      if (this.status === "D" && this.job_type === 'Remove' && this.job_subtype === 'Pickup' && this.meterSize === 'U6') {
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

      // Exchange -> Specification Change on a Residential MPRN with a new model other than U6
      // must use the Commercial API and Commercial JSON format instead of the Residential one.
      const treatAsCommercial = this.isResidentialExchangeAsCommercial;
      if (this.status === "D" && !treatAsCommercial) {
        if (payload.REQPAYMENT && Array.isArray(payload.ticketspec)) {
          payload.ticketspec = payload.ticketspec.filter(item => item.assetattrid !== 'NGME_REQPAY');
        }
        if (!(this.job_type === 'Remove' && this.job_subtype === 'Pickup' && this.meterSize === 'U6')) {
          response = await submitCreattWorkRequest({
            requestBody: JSON.stringify(payload),
            requestId: requestId.id,
            industry: this.status
          });
        }
      } else if (this.status === "I" || treatAsCommercial) {
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
        // endpoint, even when the underlying MPRN is Residential (Exchange / Spec Change / non-U6).
        response = await submitCreattWorkRequest({
          requestBody: JSON.stringify(payload),
          requestId: requestId.id,
          industry: treatAsCommercial ? "I" : this.status
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
        this.isModel = true;
        this.srNumber = parsed?.ticketid ? `SR-${parsed.ticketid}` : '';;
        this.submittedDate =
          this.formatDateToDDMMYYYY(new Date());
        this.buildEngineerVisitMessage();
      }

    } catch (e) {
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
    const industry = this.ngme_industry || (this.status === "Residential" || this.status === "D" ? "D" : "I");
    console.log('industry',industry);
    if (industry !== "D") {
      return 4;
    }
    const result = this.validateStartNow();
    console.log('condition',result.allowed && !result.isWeekendOrHoliday);
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
  normalizeAddressArray(details) {
    if (!details) return [];

    if (Array.isArray(details)) {
      const first = details[0];
      const looksLikePairs = first && typeof first === 'object' && 'apiName' in first && 'value' in first;
      if (looksLikePairs) {
        return details;
      }
      // If array of plain objects, merge and convert to pairs
      const merged = Object.assign({}, ...details.filter(x => x && typeof x === 'object'));
      return Object.entries(merged).map(([apiName, value]) => ({ apiName, value }));
    }

    if (typeof details === 'string') {
      try {
        const parsed = JSON.parse(details);
        return this.normalizeAddressArray(parsed);
      } catch (e) {
        return [];
      }
    }

    if (typeof details === 'object' && details !== null) {
      return Object.entries(details).map(([apiName, value]) => ({ apiName, value }));
    }

    return [];
  }

  buildAddressMap(details) {
    const addressArray = this.normalizeAddressArray(details);
    const map = new Map(addressArray.map(i => [i.apiName, i.value]));
    // Log as object (JSON.stringify(Map) -> {})
    // eslint-disable-next-line no-console

    return map;
  }
  async buildCreateWorkRequestPayload() {
    const addressMap = this.buildAddressMap(this.addressDetails);
    this.finalAddressDetails = Object.fromEntries(addressMap);
    this.stateofWorkRequest = this.safe?.(this.stateofWorkRequest) ?? this.stateofWorkRequest;
    this.statemap = Array.isArray(this.stateofWorkRequest)
      ? this.toMapFromArray(this.stateofWorkRequest, 'label', 'value')
      : new Map(Object.entries(this.stateofWorkRequest || {})); // <-- FIXED

    const toObj = (m) => {
      if (m instanceof Map) {
        return Object.fromEntries(m);
      }
      if (typeof m === 'object' && m !== null) {
        return m;
      }
      return {};
    };
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

    this.status = this.status === "Residential" ? "D" : "I";
    // Case-insensitive comparisons
    const normalizeLower = (s) => (s ?? '').toLowerCase();
    const mtype = metertype[normalizeLower(this.metertype)] ? metertype[normalizeLower(this.metertype)] : this.metertype;

    const jobTypeLower = normalizeLower(this.job_type);
    const jobSubTypeLower = normalizeLower(this.job_subtype);
    const jobKey = `${this.job_type}_${this.job_subtype}`.replace(/\s+/g, '');
    const jobcodes = await getCWRJobCodes({
      jobCategory: this.job_type,
      jobSubCategory: this.job_subtype,
      category: this.isResidentialExchangeAsCommercial ? "Commercial" : this.status === "D" ? "Residential" : "Commercial"
    });
    let jobCode;
    let subCategory;
    const isInstall = this.job_type === 'Install';
    const isMeter = this.job_subtype === 'Meter';
    const statusVal = String(this.status ?? '').trim().toLowerCase();
    const isResi = ['residential', 'd'].includes(statusVal);
    //const isResi = (String(this.status ?? '').trim().toLowerCase() === 'residential');
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
      job_type: jobCode,//jobcodes?.[0]?.NGMCP_Job_Category__c || '',
      ngme_consphone: this.contactDetails?.contactNumber ?? "",
      description_longdescription: this.contactDetails?.instructions ?? "",
      job_subtype: subCategory,//jobcodes?.[0]?.NGMCP_Job_Sub_category__c || "",
      targetstart: this.targetstart ?? "",
      ngme_time: this.ngme_time ? (this.ngme_time.includes("(") ? this.ngme_time.replace(/\(.*?\)/g, "").trim() : this.ngme_time.trim()) : "",
      source: this.source ?? "",
      job_sub_subtype: '',
      ngme_lf_mksctcd: this.isResidentialExchangeAsCommercial ? 'I' : this.status,
      ngme_liferay_slot: this.ngme_liferay_slot ?? "",
      assetnum: this.assetnum ?? "",
      suppliercode: this.shortCode ?? "",
      location: this.mprn ?? "",
      ngme_constitle: this.contactDetails?.title ?? "",
      ngme_consemail: this.contactDetails?.emailAddress ?? "",
      building_name: addressMap.get('buildingName') ?? '',
      ngme_consname: this.contactDetails?.name ?? "",
      mprn_pres,
      curpayment: NGME_REQPAY[normalizeLower(this.paymentmechanism ?? '')] || "",
      assettype: (jobSubTypeLower === "converter" ? "CONVR" : "METER"),
      newmodel: this.statemap.get('MeterSize') ?? "",
      metmodel: this.meterModel ?? "",
      mettype: mtype,
      status: "NEW",
      // If backend expects 'Y'/'N' for these, keep asYN here; else use raw values.
      ngme_lf_eleint: (this.asYN?.(this.statemap?.get?.('electricInterface')) ?? this.statemap?.get?.('electricInterface')) || "N",
      ngme_lf_twinpress: (this.asYN?.(this.statemap?.get?.('twinStream')) ?? this.statemap?.get?.('twinStream')) || "N",// this.asYN?.(this.statemap.get('twinStream')) ?? this.statemap.get('twinStream') ?? "N",
      ngme_lf_conventer: (this.asYN?.(this.statemap?.get?.('converterRequired')) ?? this.statemap?.get?.('meterBypass')) || "N",//this.asYN?.(this.statemap.get('converterRequired')) ?? this.statemap.get('converterRequired') ?? "N",
      ngme_lf_bypass: (this.asYN?.(this.statemap?.get?.('meterBypass')) ?? this.statemap?.get?.('meterBypass')) || "N",//this.asYN?.(this.statemap.get('meterBypass')) ?? this.statemap.get('meterBypass') ?? "N",

      building_no: addressMap.get('buildingNumber') ?? '',
      dependentloc: addressMap.get('dependentLocality') ?? '',
      street: addressMap.get('street') ?? '',
      posttown: addressMap.get('postalTown') ?? '',
      postcode: addressMap.get('postCode') ?? '',
      reportedemail: this.userEmail,
      reqpayment: NGME_REQPAY[normalizeLower(this.statemap?.get?.("paymentMethod") || this.statemap?.get?.("newMeterPaymentMethod"))] ?? "",
      microbusiness: this.microbusiness == "Y" ? "Y" : "N",
      additionalinfo: await this.buildCreateWorkRequestAdditionalInfo(),
      ticketspec: await this.buildticketrequest(),
    };
  }
  async buildCreateWorkRequestAdditionalInfo() {
    // Parse inputs defensively
    this.addressDetails = this.buildAddressMap(this.addressDetails);

    this.stateofWorkRequest = this.safe(this.stateofWorkRequest);

    this.statemap = Array.isArray(this.stateofWorkRequest)
      ? this.toMapFromArray(this.stateofWorkRequest, 'label', 'value')
      : new Map(Object.entries(this.stateofWorkRequest || {}));


    // Fetch CMDT
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
  // ===== VALUE RESOLVER =====

  resolveValue(mapping) {

    // Defensive initialization
    this.assetValuesByApi = {
      NGMCP_Current_Meter_Model__c: this.meterModel,
      NGMCP_Current_Meter_Type__c: this.metertype,
      NGMCP_Current_Meter_Manufacturer__c: this.manufacturerValue,
      NGMCP_Current_Meter_Serialnumber__c: this.serialnumber,
      NGMCP_Payment_Mechanism__c: this.paymentmechanism,
      NGMCP_Current_Meter_YOM__c: this.yearofmanufaturer,
    };
    switch (mapping?.NGMCP_Source_Map__c) {
      case 'State': {
        // Ensure statemap is a Map and exists
        const key = mapping?.NGMCP_Source_Key__c;
        return this.statemap?.get ? this.statemap.get(key) : undefined;
      }

      case 'Asset': {
        // Decide which keying convention you want; here using Salesforce Field API
        const api = mapping?.NGMCP_Salesforce_Field_API__c;
        return this.assetValuesByApi?.[api];
      }

      case 'Address': {
        const key = mapping?.NGMCP_Source_Key__c;
        const [k1, k2] = (key || '').split(',').map(s => s?.trim());

        const value =
          this.finalAddressDetails?.[k1] ||
          this.finalAddressDetails?.[k2] || '';
        return value;
      }

      case 'Literal': {
        const api = mapping?.NGMCP_Salesforce_Field_API__c;
        if (api === 'NGMCP_Job_Type__c') {
          return this.job_type;
        }
        if (api === 'NGMCP_Job_SubType__c') {
          return this.job_subtype;
        }
        // No match -> return null to avoid fall-through
        return null;
      }

      case 'Computed': {
        const api = mapping?.NGMCP_Salesforce_Field_API__c;

        if (api === 'NGMCP_Non_Standard__c') {
          // If successprice is truthy => standard ("No" non-standard), else non-standard ("Yes")
          return this.successprice ? 'No' : 'Yes';
        }

        if (api === 'NGMCP_Quotation_Status__c') {
          return this.successprice ? '' : 'Quotation In Progress';
        }

        if (api === 'NGMCP_Asset_type__c') { // removed leading tab
          return this.job_subtype === 'Converter' ? 'CONVR' : 'METER';
        }
        if (mapping.NGMCP_Salesforce_Field_API__c === 'NGMCP_MIcro_Buisness__c') {
          return this.microbusiness === 'Y' ? "Yes" : "No";
        }

        return null;
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

    this.assetValuesByApi = {
      NGMCP_Current_Meter_Model__c: this.meterModel,
      NGMCP_Current_Meter_Type__c: this.metertype,
      NGMCP_Current_Meter_Manufacturer__c: this.manufacturerValue,
      NGMCP_Current_Meter_Serialnumber__c: this.serialnumber,
      NGMCP_Payment_Mechanism__c: this.paymentmechanism,
    };
    // Support both __c and __C if Apex ever returned wrong suffix
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

        const api = mapping?.NGMCP_Salesforce_Field_API__c;
        const raw = this.assetValuesByApi?.[api];;
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
  // When an Exchange -> Specification Change Work Request is raised on a Residential MPRN
  // (status === 'D') but the newly selected meter model is anything other than U6
  // (e.g. a U6 -> U16 upgrade), it must be submitted through the Commercial Maximo API
  // using the Commercial JSON format instead of the Residential one. This is intentionally
  // limited to Exchange / Specification Change so no other functionality is affected.
  // NOTE: in this component `this.status` is normalised to the industry code ('D'/'I')
  // inside buildCreateWorkRequestPayload before this getter is consulted.
  get isResidentialExchangeAsCommercial() {
    const isExchange = (this.job_type ?? '').toString().trim().toLowerCase() === 'exchange';
    const jobSubtype = (this.job_subtype ?? '').toString().trim().toLowerCase();
    const isSpecificationChange = jobSubtype === 'specification change';
    const isThirdParty = jobSubtype === 'third party';
    const isSpecOrThirdParty = isSpecificationChange || isThirdParty;
    const newModel = (this.stateofWorkRequest?.MeterSize ?? '').toString().trim().toUpperCase();
    return isExchange && isSpecOrThirdParty && newModel !== '' && newModel !== 'U6';
  }
  async buildticketrequest() {
    // Debug inputs
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
    if (this.status?.toLowerCase() === "i" || this.isResidentialExchangeAsCommercial) {
      fields.push(
        { assetattrid: trimIfString('NGME_JOBDETAIL'), alnvalue: trimIfString(this.jobcodeCommerical) },
        { assetattrid: trimIfString('NGME_JOBTYPE'), alnvalue: trimIfString(this.JobSubCodeCommerical) }
      );
    }
    return fields;
  }
  /* ===========================
   * VALIDATION HELPERS
   * =========================== */

  resetValidation() {
    this.validationErrors = {};
  }

  validateForm() {
    const isValid = this.validateRequiredFields();
    if (!isValid) {
      return;
    }

    this.validateAppointmentDateAndSlot();
    this.validateContactDetails();

    if (Object.keys(this.validationErrors).length > 0) {
      this.validationErrors = { ...this.validationErrors };
      this.scrollToFirstError();
      return false;
    }
    return true;
  }

  validateRequiredFields() {
    let isValid = true;

    const requiredFields = [
      { name: "requestType", label: "Request type", visible: true },
      {
        name: "jobType",
        label: "Job type",
        visible: this.showJobType || this.showWindOnOption,
      },
      {
        name: "startOption",
        label: "Select start",
        visible: this.showAppointment,
      },
      { name: "title", label: "Title", visible: this.showcontactdetails },
      { name: "name", label: "Name", visible: this.showcontactdetails },
      
      {
        name: "contactNumber",
        label: "Contact number",
        visible: this.showcontactdetails,
      },
      { name: "consent", label: "Consent", visible: true },
      {
        name: "faultReason",
        label: "Fault reason",
        visible: this.faultReason
      }
    ];

    // Clear previous required errors (optional but clean)
    let errors = { ...this.validationErrors };

    requiredFields.forEach((field) => {
      if (!field.visible) return;

      // Special handling for faultReason (uses tracked value)
      if (field.name === "faultReason") {
        if (!this.faultReasonValue) {
          errors.faultReason = "This field is required.";
          isValid = false;
        } else {
          delete errors.faultReason;
        }
        return;
      }

      const inputs = this.template.querySelectorAll(
        `[name="${field.name}"]`
      );
      if (!inputs.length) return;

      let value;
      if (inputs.length > 1) {
        value = Array.from(inputs).find((i) => i.checked)?.value;
      } else {
        value =
          inputs[0].type === "checkbox"
            ? inputs[0].checked
            : inputs[0].value;
      }

      if (!value) {
        errors[field.name] = `${field.label} is required`;
        isValid = false;
      } else {
        delete errors[field.name];
      }
    });

    this.validationErrors = errors;
    return isValid;
  }

  validateAppointmentDateAndSlot() {
    const shouldValidate =
      this.showRestro ||
      this.showAppointmentFields ||
      this.showAppointmentSlots ||
      this.startOption === "pick";

    if (shouldValidate && !this.selectedDate) {
      this.validationErrors.appointmentDate =
        "Appointment Date is required";
    }

    if (shouldValidate && !this.selectedSlot) {
      this.validationErrors.appointmentSlot =
        "Appointment Slot is required";
    }
  }

  validateContactDetails() {
    const { contactNumber, name } = this.contactDetails || {};

    if (contactNumber) {
      const phone = contactNumber.trim();
      if (!/^[0-9]{11}$/.test(phone)) {
        this.validationErrors.contactNumber =
          "Please enter a valid 11-digit contact number.";
      }
    }

    if (name) {
      const trimmedName = name.trim();
      if (!trimmedName) {
        this.validationErrors.name = "Name is required.";
      } else if (trimmedName.length > 30) {
        this.validationErrors.name =
          "Name cannot exceed 30 characters.";
      }
    }
  }

  validateStartNowOption() {
    if (this.selectedStartOption !== "now") return true;

    const result = this.validateStartNow();
    this.startNowWeekendOrHolidayFlag = !!result.isWeekendOrHoliday;

    if (!result.allowed && !this.isNGMUser) {
      this.validationErrors.startNow =
        result.message ||
        "You cannot submit an immediate start urgent work request during non working hours. Please reach out to 0800 001 4340 if this is needed immediately.";

      this.startNowFlag = false;
      this.startNowWeekendOrHolidayFlag = false;
      this.scrollToFirstError();
      return false;
    }

    delete this.validationErrors.startNow;
    return true;
  }

  validatePartnerStatus() {
    if (!this.windonFlag) return true;

    if (!this.isNGMUser && this.servicePartnerStatus !== "Green") {
      return false;
    }

    this.showCautionMessage =
      this.isNGMUser && this.servicePartnerStatus !== "Green";
    return true;
  }

  validateConsent() {
    if (!this.contactDetails?.consent) {
      alert(
        "Please confirm that consent has been obtained before submitting."
      );
      return false;
    }
    return true;
  }

  scrollToFirstError() {
    const el = this.template.querySelector(".error-text");
    if (el) {
      el.scrollIntoView({ behavior: "smooth", block: "center" });
    }
  }

  /* ===========================
   * SUBMISSION FLOW
   * =========================== */

  async submitWorkRequest() {

    this.isLoading = true;

    try {
      const payload = this.buildPayload();

      const requestRecordId =
        await createUrgentWorkRequestRecord({
          requestBody: JSON.stringify(payload),
          recordTypeValue: "Urgent Work Request",
        });

      if (!requestRecordId) {
        throw new Error("No request record ID returned");
      }

      if (this.uploadedFilePayload?.length > 0) {
        const isUploaded = await uploadFiles({
          recordId: requestRecordId.id,
          files: JSON.stringify(this.uploadedFilePayload)
        });

        if (!isUploaded) {
          return;
        }
      }
      delete payload.additionalinfo;
      const response = await submitUrgentWorkRequest({
        requestBody: JSON.stringify(payload),
        requestId: requestRecordId.id,
      });

      await this.handleSuccessResponse(response);
    } catch (error) {
    } finally {
      this.isLoading = false;

    }
  }

  getAddressArray() {
    if (!this.addressDetails) return [];

    if (Array.isArray(this.addressDetails)) return this.addressDetails;

    if (typeof this.addressDetails === 'string') {
      try {
        return JSON.parse(this.addressDetails);
      } catch {
        return [];
      }
    }
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

    // 3) Build map for assetDetails
    let assetMap;
    if (Array.isArray(this.assetDetails)) {
      // If array of one detail object, use the first; else merge keys if needed
      const first = this.assetDetails[0] || {};
      assetMap = new Map(Object.entries(first));
    } else if (this.assetDetails && typeof this.assetDetails === "object") {
      assetMap = new Map(Object.entries(this.assetDetails));
    } else {
      assetMap = new Map();
    }

    const toIsoDateFromDDMMYYYY = (s) => {
      if (!s || typeof s !== "string") return "";

      // If ISO format with time, extract before 'T'
      if (s.includes("T")) {
        return s.split("T")[0]; // "2005-01-24"
      }

      // If DD-MM-YYYY, convert to YYYY-MM-DD
      const parts = s.split("-");
      if (parts.length === 3) {
        const [dd, mm, yyyy] = parts;
        if (yyyy.length === 4) {
          // Already YYYY-MM-DD
          return s;
        } else {
          // Convert DD-MM-YYYY → YYYY-MM-DD
          return `${yyyy}-${mm}-${dd}`;
        }
      }

      return s; // fallback
    };

    const installDateIso = toIsoDateFromDDMMYYYY(assetMap.get("InstallDate"));

    //Build additionalFields with correct mapping
    const additionalFields = {
      NGMCP_Manufacturer__c: this.manufacturerValue,
      NGMCP_Model__c: this.meterModel,
      NGMCP_Manufacturer_Serial_No__c: this.serialnumber,
      NGMCP_Meter_Type__c: this.metertype,
      NGMCP_No_of_Dials__c: assetMap.get("noofdial"),
      NGMCP_Payment_Mechanism__c: this.paymentmechanism,
      NGMCP_Year_of_Manufacture__c: this.yearofmanufaturer,
      NGMCP_LocationsId__c: assetMap.get("locationId"),
      NGMCP_Install_Date__c: installDateIso,
      NGMCP_Measuring_Capacity__c: assetMap.get("measuringCapacity"),
      NGMCP_Building_Number__c: mapByApi.get("buildingNumber"),
      NGMCP_Building_Name__c: mapByApi.get("buildingName"),
      NGMCP_Street__c: mapByApi.get("street"),
      NGMCP_Dependent_Locality__c: mapByApi.get("dependentLocality"),
      NGMCP_Postal_Town__c: mapByApi.get("postalTown"),
      NGMCP_Postal_Code__c: mapByApi.get("postCode"),
      NGMCP_Job_Code_Description__c: this.windonFlag ? 'Wind On' : (this.jobTypes?.[0]?.label ?? ''),
      NGMCP_Appointment_Type__c: this.appointmentType,
      NGMCP_Wind_On_requested_by__c: this.windOnRequestedBy ?? "",
      NGMCP_Residential_U6__c: this.isResidential ?? "",
      NGMCP_Reported_Email__c: this.contactDetails.requestonbehalfof ?? "",
    };

    // Convert to array, remove empty values
    return Object.entries(additionalFields)
      .filter(([_, value]) => value != null && String(value).trim() !== "")
      .map(([name, value]) => ({ name, value }));
  }
  /* ===========================
   * PAYLOAD BUILDER
   * =========================== */

  buildPayload() {
    const addressArray = this.getAddressArray();

    const addressMap = new Map(
      addressArray.map(item => [item.apiName, item.value])
    );

    this.status = this.status === "Residential" ? "D" : "I";
    if (this.startNowFlag) {
      const now = new Date();
      this.targetstart = now.toISOString().split("T")[0];
      this.ngme_time = now.toTimeString().slice(0, 5);
    }
    return {
      reportedpriority: this.reportedpriority,
      job_type: this.job_type,
      job_subtype: this.job_subtype,
      job_sub_subtype: this.job_sub_subtype,
      source: this.source,
      suppliercode: this.shortCode,
      location: this.mprn,

      ngme_consphone: this.contactDetails.contactNumber,
      ngme_consname: this.contactDetails.name,
      ngme_constitle: this.contactDetails.title,
      ngme_consemail: this.contactDetails.emailAddress,
      description_longdescription: this.contactDetails.instructions,

      targetstart: this.targetstart,
      ngme_time: this.ngme_time.includes("(") ? this.ngme_time.replace(/\(.*?\)/g, "").trim() : this.ngme_time,
      ngme_liferay_slot: this.ngme_liferay_slot,
      ngme_lf_mksctcd: this.status,

      building_name: addressMap.get("buildingName") ?? "",
      building_no: addressMap.get("buildingNumber") ?? "",
      street: addressMap.get("street") ?? "",
      dependentloc: addressMap.get("dependentLocality") ?? "",
      posttown: addressMap.get("postalTown") ?? "",
      postcode: addressMap.get("postCode") ?? "",
      reportedemail: this.userEmail,
      faultreason: this.faultReasonValue || "",
      additionalinfo: this.buildAdditionalInfo(),
      ticketspec: [
        {
          assetattrid: "NGME_METERMF",
          alnvalue: this.manufacturerValue,
        },
        {
          assetattrid: "NGME_MFRSERIALNU",
          alnvalue: this.serialnumber,
        },
      ],
    };
  }


  /* ===========================
   * SUCCESS HANDLER
   * =========================== */

  async handleSuccessResponse(response) {
    const parsed =
      typeof response === "string"
        ? JSON.parse(response)
        : response;

    const ticketId = parsed?.ticketid ? `SR-${parsed.ticketid}` : '';

    if (!ticketId) return;
    if (this.uploadedFilePayload?.length > 0) {
      const uploadRequest = await uploadtoMAximoSystem({
        files: JSON.stringify(this.uploadedFilePayload),
        srticket: parsed.ticketid,
        uid: parsed.ticketuid,
        doctype: 'GT1'
      });

    }
    this.isModel = true;
    this.srNumber = ticketId;
    this.submittedDate =
      this.formatDateToDDMMYYYY(new Date());

    if (this.startNowFlag) {
      this.interval = this.getStartNowSlaHours();

      this.engineerVisitMessage =
        ENGINEER_VISIT_MSG_STARTNOW.replace(
          "{0}",
          this.interval
        );
    } else if (this.pickupDateFlag) {
      const [startTime, endTime] =
        this.ngme_time.split(" - ");

      this.engineerVisitMessage =
        ENGINEER_VISIT_MSG.replace(
          "{0}",
          this.formatDateToDDMMYYYY(this.targetstart)
        )
          .replace("{1}", startTime)
          .replace("{2}", endTime);
    }
  }


  handleCancelClick() {

    this.dispatchEvent(new CustomEvent("cancelcreatejob"));
  }

  async handleMprnFound(event) {
    try {
      const { combinedWrapper, metadata, assets, address } = event.detail;
      if (!combinedWrapper || combinedWrapper.length === 0) return;

      const record = combinedWrapper[0];

      this.mprn = record.MPRN;
      this.assetDetails = assets || record.Assets;
      this.address = address || record.Address;
      this.status = record.status;
      this.paymentMechanism = record.paymentMechanism;
      this.postCode = record.postCode;

      //  Find correct asset (Z001 or Z002) just like in NGMCP_MprnDetail
      const meterDetails = this.assetDetails.filter(
        (a) => a.MeterType === "Z001"
      );
      const conversionMeter = this.assetDetails.filter(
        (a) => a.MeterType === "Z002"
      );

      const key =
        meterDetails.length > 0
          ? meterDetails[0].residential_commercialKey
          : conversionMeter.length > 0
            ? conversionMeter[0].residential_commercialKey
            : null;

      if (!key) {
        this.metaDataWrapper = {};
        return;
      }



      //  Fetch metadata using the key
      const result = await getMetaData({ meterModel: key });

      const categoryMap = {
        U6D: "Residential",
        "Non U6D": "Commercial",
        U6I: "Commercial",
        "Non U6I": "Commercial",
      };

      const meta = Array.isArray(result) ? result[0] : result;
      const metaKey =
        meta?.NGMCP_Meter_Model_Size__c + meta?.NGMCP_Market_Sector_Code__c;
      const category = categoryMap[metaKey] || "Unknown";
      const industry = category === "Residential" ? "D" : "I";



      const metadataList = Array.isArray(result) ? result : [result];
      const selectedAsset = meterDetails[0] || conversionMeter[0];

      //  Build metaDataWrapper (same structure as NGMCP_MprnDetail)
      this.metaDataWrapper = {
        metadatalist: metadataList,
        assetnum: selectedAsset?.assetnum || "",
        location: this.mprn,
        suppliercode: record.Customer || selectedAsset?.suppliercode || "EOD",
        ngme_industry: industry,
      };

      // Show Create Job Request
      this.showSearch = false;
      this.showEditableJob = false;
      this.showCreateJob = true;
    } catch (error) {
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
          "Service Partner seems to be busy, please book cautiously";
      } else if (status.toLowerCase() === "red") {
        this.servicePartnerBoxClass = "red-box";
        this.servicePartnerMessage =
          "Service Partner seems to be busy, please book cautiously";
      }
    } catch (error) {
      this.showServicePartnerStatus = false;
    }
  }

  getCategory(result) {
    const code = result?.NGMCP_Market_Sector_Code__c?.toUpperCase();

    switch (code) {
      case "D":
        return "Residential";
      case "I":
        return "Commercial";
      default:
        return "Unknown";
    }
  }

  // When MPRN not found
  handleMprnNotFound(event) {
    this.metaDataWrapper = event.detail?.metadata || {};
    this.showSearch = false;
    this.showCreateJob = false;
    this.showEditableJob = true;
  }

  // When Create Job is cancelled
  handleCancelJob() {
    this.showCreateJob = false;
    this.showEditableJob = false;
    this.showSearch = true;
  }

  handleDragOver(event) {
    event.preventDefault();
    event.stopPropagation();
    event.currentTarget.classList.add("drag-over");
  }

  handleDragLeave(event) {
    event.preventDefault();
    event.stopPropagation();
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
      this.fileError = `Combined size of attachments (${this.formatFileSize(totalSize)}) exceeds ${MAX_FILE_SIZE_MB} MB limit. Please amend and submit`;
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
    if (detail.jobtype === 'Install' /*&& detail.subJobType === 'Meter'*/ && !detail.successprice) {
      if (!this.validateAddress()) {
        const selectedValue = null;
        this.requestTypes = this.requestTypes.map((item) => ({
          ...item,
          isChecked: item.value === selectedValue,
        }));
        this.workRequestFlag = false;
        this.isRequestTypeLocked = false;
        this.stateResponseFlag = false;
        return;
      }
    }

    const jobTypeInput = (detail.jobtype || "").trim().toLowerCase();
    const subJobTypeInput = (detail.subJobType || "").trim().toLowerCase();


    if (jobTypeInput === "install" && subJobTypeInput === "meter") {
      const meterSize = (detail?.state?.MeterSize || "").trim();

      // Map meter sizes to API codes
      const meterMap = {
        U6: "D",
        U16: "D",
        U25: "D",
        U40: "D",
        U65: "D",
        U100: "D",
        U160: "D",
        Rotary: "R",
        Turbine: "T",
      };

      // Assign portal description and API code
      this.metertypeDescription = meterSize || null;
      this.metertype = meterMap[meterSize] || null;

      /*Optional warning if meter size is present but has no mapping
      if (!this.metertype && meterSize) {
        console.warn(
          `No API code found for meter size "${meterSize}". Expected one of: U6, U16, U25, U40, U65, U100, U160, Rotary, Turbine`
        );
      }*/
    }


    const allowedJobTypes = new Set(["exchange", "other visits", "remove"]);
    const allowedSubJobTypes = new Set([
      "pickup",
      "specification change",
      "theft of gas exchange",
      "third party",
      "adversarial removal"
    ]);

    const isAllowedJob = allowedJobTypes.has(jobTypeInput);
    const isAllowedSub = allowedSubJobTypes.has(subJobTypeInput);
    if (
      isAllowedJob &&
      /*isAllowedSub &&*/
      !detail.successprice
    ) {
      if (!(this.validateAddress() && this.validateAllFields())) {
        const selectedValue = null;
        this.requestTypes = this.requestTypes.map((item) => ({
          ...item,
          isChecked: item.value === selectedValue,
        }));
        this.workRequestFlag = false;
        this.isRequestTypeLocked = false;
        this.stateResponseFlag = false;
        return;
      }
    }

    if (
      isAllowedJob &&
      isAllowedSub &&
      detail?.state?.housingRequired === "Yes"
    ) {
      this.cwrdescription = "Date may be subject to change";
    }

    // Normalize appointment flag to boolean (handles 'true'/'false' strings and truthy values)
    /*const appointmentFlag =
      typeof detail.appointmentFlag === "string"
        ? detail.appointmentFlag.toLowerCase() === "true"
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
  }

  get isRequestTypeSelected() {
    return (
      this.enquiryFlag ||
      this.techEnquiryFlag ||
      this.deappointmentFlag ||
      this.amrFlag ||
      this.workRequestFlag ||
      this.urgentworkrequestFlag
    );
  }

  get showsubmitSection() {
    if (!this.isRequestTypeSelected) {
      return false;
    }

    return !(this.enquiryFlag || this.techEnquiryFlag || this.deappointmentFlag || this.amrFlag || (this.workRequestFlag && !this.stateResponseFlag));
  }

  get windOnCardClass() {
    return this.isWindOnSelected
      ? "radio-card selected"
      : "radio-card";
  }

  get isCustomerSelected() {
    return this.windOnRequestedBy === 'customer';
  }

  get isSupplierSelected() {
    return this.windOnRequestedBy === 'supplier';
  }

  resetUrgentStartOptions() {
    this.selectedStartOption = null;
    this.startNowFlag = false;
    this.startNowWeekendOrHolidayFlag = false;
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
    this.startNowWeekendOrHolidayFlag = false;
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
      emailAddress: "",
      requestonbehalfof: ""
    };

    // 3️ Clear validation errors
    this.validationErrors = {
      ...this.validationErrors,
      title: null,
      name: null,
      instructions: null,
      contactNumber: null,
      emailAddress: null,
      requestonbehalfof: null
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
    this.stateResponseFlag = false;

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
  get falseServiceNowFlg() {
    return !!(this.startNowFlag || this.duplicateMessage);
  }

  handleRequestTypeChange(event) {
    const requestType = event.detail.value;
    const validationEvent = new CustomEvent('validateshortcodebeforetype', {
      detail: { requestType: requestType }
    });
    this.dispatchEvent(validationEvent);
  }

  validateShortCodeForSelectedRequest() {
    const requestTypesToValidate = [
      "work",
      "urgent",
      "amr",
      "deappoint",
      "dataQuery",
      "tQuery"
    ];

    // No request type selected → no validation
    if (!this.selectedRequestType) {
      this.showShortCodeError = false;
      return true;
    }

    // Request type selected but supplier empty → error
    if (
      requestTypesToValidate.includes(this.selectedRequestType) &&
      !this.selectedShortCode
    ) {
      this.showShortCodeError = true;
      return false;
    }

    this.showShortCodeError = false;
    return true;
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
  handleAdressAssetValidation(event) {
    const isFoundAsset = event.detail === 'FNDAS';

    const isInvalid = isFoundAsset
      ? !(this.validateAddress() && this.validateAllFields())
      : !this.validateAddress();

    if (isInvalid) {
      const selectedValue = null;

      this.requestTypes = this.requestTypes.map(item => ({
        ...item,
        isChecked: item.value === selectedValue
      }));

      this.deappointmentFlag = false;
      this.isRequestTypeLocked = false;
      return;
    }
  }


}