import { LightningElement, track, api } from "lwc";
import getMetaData from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.getMeterModelSizeandcatagory";
import submitUrgentWorkRequest from '@salesforce/apexContinuation/NGMCP_IBMMaximoIntegrationClass.submitUrgentWorkRequest';
import createUrgentWorkRequestRecord from "@salesforce/apex/NGMCP_RequestObjectClass.createUrgentWorkRequestRecord";
export default class NGMCP_CreateJobRequest extends LightningElement {
  @track selectedTitle = "";
  @api metadataRecord;
  @track urgentOptions = [];
  @track selectedValue;
  @track jobTypes = [];
  @track showJobType = false;
  @api dummykey = "ACT_G4_I";
  metadata;
  @track selectedJobType = false;
  @track showAppointment = false;
  @track showcontactdetails = false;

  @track contactDetails = {
    title: "",
    name: "",
    contactNumber: "",
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
  assetnum = "2360";
  suppliercode = "LEP";
  location = "1000023705";
  affectedperson;

  connectedCallback() {
    console.log("this.dummykey", this.dummykey);
    this.getMetaData();
  }

  getMetaData() {
    getMetaData({ meterModel: this.dummykey })
      .then((result) => {
        console.log("Result:", JSON.stringify(result));
        this.metadata = result;

        const data = Array.isArray(result) ? result : [result];

        this.jobTypes = data.map((item) => ({
          value: item.NGMCP_UWR_Job_Code__c,
          label: item.NGMCP_Portal_Category__c,
          description: `${item.NGMCP_Portal_Category__c} - ${item.NGMCP_Meter_Model_Size__c} (${item.NGMCP_Market_Sector_Code__c})`,
        }));
        if (this.jobTypes.length === 1) {
          this.selectedJobType = true;
          this.job_sub_subtype = this.jobTypes[0].value;
        }
        console.log("Processed jobTypes:", JSON.stringify(this.jobTypes));
      })
      .catch((error) => {
        console.error("Error fetching metadata:", error);
      });
  }

  requestTypes = [
    {
      value: "work",
      label: "Work request",
      desc: "An ordinary request with several jobs type to choose from",
    },

    {
      value: "urgent",
      label: "Urgent Work request (Off gas)",
      desc: "An urgent work request for issues to be resolved fast.",
    },

    {
      value: "amr",
      label: "AMR request",
      desc: "With AMR, you get automatic readings directly in the portal.",
    },

    {
      value: "deappoint",
      label: "De-Appoint",
      desc: "Supporting line text lorem ipsum dolor sit amet, consectetur.",
    },
  ];

  //  jobTypes = [

  //      { value: 'faultyu6', label: 'Faulty U6', desc: 'Supporting line text lorem ipsum dolor sit amet, consectetur.', recommended: true },

  //      { value: 'windon', label: 'Wind on', desc: 'Supporting line text lorem ipsum dolor sit amet, consectetur.' }

  //   ];

  startOptions = [
    { value: "now", label: "Start now" },

    { value: "pick", label: "Pick date & time" },

    { value: "retro", label: "Restrospective" },
  ];

  titles = ["Mr", "Mrs", "Miss", "Dr"];

  // Handle card click via JS only
  handleCardClick(event) {
    const clickedCard = event.currentTarget;
    console.log("clickedCard", clickedCard);
    console.log("clickedCard.dataset.group", clickedCard.dataset.value);
    const group = clickedCard.dataset.value;
    if (clickedCard.dataset.value === "urgent") {
      this.showJobType = true;
      this.job_type = "OTVST";
      this.job_subtype = "FAULT";
      this.Source = "PORTAL";
      if (this.selectedJobType) {
        this.showAppointment = true;
      }
    } else if (clickedCard.dataset.value === "now") {
      this.showcontactdetails = true;
      const now = new Date();

      // Get date in YYYY-MM-DD format
      const currentDate = now.toISOString().split("T")[0];

      // Get time in HH:MM:SS format
      const currentTime = now.toTimeString().split(" ")[0].slice(0, 5);
      this.targetstart = currentDate;
      this.ngme_time = currentTime;
      console.log("Date:", this.targetstart); // e.g., "2025-10-23"
      console.log("Time:", this.ngme_time); // e.g., "18:52:30"
    } else if (clickedCard.dataset.value === "pick") {
    } else if (clickedCard.dataset.value === "retro") {
    } else {
      this.showJobType = false;
    }
  }

  handleInputChange(event) {
    const field = event.target.name;
    const value =
      event.target.type === "checkbox"
        ? event.target.checked
        : event.target.value;
    console.log("field", field);
    console.log("value", value);
    if (field && this.contactDetails.hasOwnProperty(field)) {
      this.contactDetails[field] = value;
    }
  }

  handleTitleChange(event) {
    this.selectedTitle = event.target.value;
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
  
async handleSubmitUrgentWorkrequest(event) {
    console.log('handleSubmitUrgentWorkrequest called');
  event.preventDefault();

  if (!this.contactDetails.consent) {
    alert('Please confirm that consent has been obtained before submitting.');
    return;
  }

  const payload = {
    reportedpriority: this.reportedpriority,
    job_type: this.job_type,
    affectedphone: this.contactDetails.contactNumber,
    description_longdescription: this.contactDetails.instructions,
    job_subtype: this.job_subtype,
    targetstart: this.targetstart,
    ngme_time: this.ngme_time,
    source: this.source,
    job_sub_subtype: this.job_sub_subtype,
    ngme_liferay_slot: 'AT',
    ngme_industry: 'D',
    assetnum: this.assetnum,
    suppliercode: this.suppliercode,
    location: this.location,
    affectedperson: `${this.contactDetails.title} ${this.contactDetails.name}`
  };

  console.log('Payload ready for Apex callout:', JSON.stringify(payload));

  try {
    const reuestRecord = await createUrgentWorkRequestRecord({ requestBody: JSON.stringify(payload)});
    console.log('reuestRecord:', reuestRecord);
    if(reuestRecord ){
      const response = await submitUrgentWorkRequest({ requestBody: JSON.stringify(payload), requestId: reuestRecord});
    console.log('Apex response:', response);
    }
    
    // Optionally show success toast or navigate
  } catch (error) {
    console.error('Error during Apex callout:', error);
    alert('Something went wrong while submitting the request.');
  }
}


  handleCategorySelect(event) {
    this.selectedValue = event.detail.value;
    console.log("selectedValue", this.selectedValue);
  }
}