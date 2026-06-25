import { LightningElement, track, wire, api } from "lwc";
import homeIcon from "@salesforce/resourceUrl/homeIcon";
import commercialsIcon from "@salesforce/resourceUrl/commercialsIcon";
import reportsIcon from "@salesforce/resourceUrl/reportsIcon";
import settingsIcon from "@salesforce/resourceUrl/settingsIcon";
import backgroundImage from "@salesforce/resourceUrl/ngBackgroundImage";
import getCurrentUser from "@salesforce/apex/ngCaseAppointmentsController.getCurrentUser";
import fetchAssetDetails from "@salesforce/apex/ngCaseAppointmentsController.fetchAssetDetails";
import getTodaysAppointments from "@salesforce/apex/ngCaseAppointmentsController.getTodaysAppointments";
import callAssetDetailsAPI from "@salesforce/apex/NGMCP_LoginController.callAssetDetailsAPI";
import callSerialNumberAssetDetailsAPI from "@salesforce/apex/NGMCP_LoginController.callSerialNumberAssetDetailsAPI";
import callPostalNumberAssetDetailsAPI from "@salesforce/apex/NGMCP_LoginController.callpostalAssetDetailsAPI";
import { NavigationMixin } from "lightning/navigation";
export default class Ngmcp_postalcodecomponent extends LightningElement {
  @track selectedTab = "home";
  userName;
  mprn;
  customer = null;
  serialNumber;
  postalcodevalue;
  @track appointments = [];
  @track hasAppointments = false;
  @track selectedCode = "";
  @track isModalOpen = false;
  @api filteredRecords = [];
  @track selectedRecordId = null;
  @track controlboolean = false;
  @track isLoading = false;

  shordcodeMprns = [
    { id: 1, ShortCode: "poc", MPRN: "123456789" },
    { id: 2, ShortCode: "poc", MPRN: "123456789" },
    { id: 3, ShortCode: "pod", MPRN: "123456788" },
    { id: 4, ShortCode: "pod", MPRN: "123456780" },
    { id: 5, ShortCode: "poe", MPRN: "123456789" },
  ];

  // get supplierOptions() {
  //     return [
  //         { label: 'BGT', value: 'BGT' },
  //         { label: 'BSA', value: 'BSA' },
  //         { label: 'BGF', value: 'BGF' },
  //         { label: 'BGB', value: 'BGB' },
  //         { label: 'SCP', value: 'SCP' },
  //         { label: 'SCT', value: 'SCT' },
  //         { label: 'OCT', value: 'OCT' },
  //         { label: 'OVO', value: 'OVO' },
  //         { label: 'KIN', value: 'KIN' }
  //     ];
  // }

  handleCodeChange(event) {
    this.selectedCode = event.target.value;
    console.log("Selected Supplier Code:", this.selectedCode);
  }

  connectedCallback() {
    this.loadAppointments();
  }

  loadAppointments() {
    getTodaysAppointments()
      .then((data) => {
        if (data && data.length > 0) {
          console.log("data appointments >>", data);
          this.hasAppointments = true;
          this.appointments = data.map((appt) => ({
            ...appt,
            formattedStart: this.formatDateTime(appt.SchedStartTime),
            formattedEnd: this.formatDateTime(appt.SchedEndTime),
          }));
        } else {
          this.hasAppointments = false;
        }
      })
      .catch((error) => {
        this.hasAppointments = false;
        console.error("Error fetching appointments:", error);
      });
  }

  formatDateTime(dateStr) {
    if (!dateStr) return "";
    const dt = new Date(dateStr);
    return `${dt.toLocaleDateString()} ${dt.toLocaleTimeString([], {
      hour: "2-digit",
      minute: "2-digit",
    })}`;
  }

  @wire(getCurrentUser)
  wiredUser({ error, data }) {
    if (data) {
      this.userName = data.Name;
    } else if (error) {
      console.error("Error fetching user name", error);
    }
  }

  backgroundStyle = `background-image: url(${backgroundImage}); background-size: cover; background-position: center;`;
  get tabs() {
    const tabList = [
      { name: "home", label: "Home", icon: homeIcon },
      // { name: 'commercials', label: 'Commercials', icon: commercialsIcon },
      { name: "reports", label: "Reports", icon: reportsIcon },
      { name: "settings", label: "Settings", icon: settingsIcon },
    ];

    return tabList.map((tab) => ({
      ...tab,
      class: this.selectedTab === tab.name ? "tab-item selected" : "tab-item",
    }));
  }

  handleTabClick(event) {
    this.selectedTab = event.currentTarget.dataset.tab;
    console.log(">>> ", this.selectedTab);
    if (this.selectedTab === "reports") {
      this.loadAppointments();
    }
  }

  handleInputChange(event) {
    this.mprn = event.target.value;
    console.log("mprn >>", this.mprn);
  }

  async handleSearch() {

    const isMprnOrSelectedCode =
      this.mprn &&
      (this.selectedCode || true) && // optional, always true
      !this.serialNumber &&
      !this.postalcodevalue;

    const isSerialNumberOnly = this.serialNumber && !this.postalcodevalue;
    let conditionKey = isMprnOrSelectedCode ? "mprnOrSelectedCode" : isSerialNumberOnly ? "serialNumber" : this.postalcodevalue ? "postalCode" : " ";
    console.log("conditionKey>>", conditionKey);
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

  get isHomeTab() {
    return this.selectedTab === "home";
  }

  get isReportTab() {
    return this.selectedTab === "reports";
  }

  get isSettingTab() {
    return this.selectedTab === "settings";
  }

  get backgroundStyle() {
    return `background-image: url(); background-size: cover; background-position: center;`;
  }

  handleSelection(event) {
    this.selectedRecordId = event.target.value;
    console.log("selectedRecordId", this.selectedRecordId);
  }

  closeModal() {
    this.isModalOpen = false;
  }

  confirmSelection() {
    console.log("selectedRecordId", this.selectedRecordId);
    console.log('this.filteredRecords >>', JSON.stringify(this.filteredRecords));
    const selected = this.filteredRecords.find(
      (record) =>
        record.AppointmentFromDate?.trim() === this.selectedRecordId?.trim()
    );

    if (selected) {
      // You can handle the selected record here (e.g., show toast, pass to parent, etc.)
      console.log("Selected Record:", JSON.stringify(selected));
      const baseUrl = window.location.origin;
      const url = `${baseUrl}/customerportal/assetdetail`;
      console.log("Redirecting to:", url);
      //window.location.href = url;
      //lert(`You selected: ${selected.customer}`);
    } else {
      alert("Please select a record.");
    }
    this.closeModal();
  }

  handleserialnumberChage(event) {
    this.serialNumber = event.target.value;
    console.log("mprn >>", this.serialNumber);
  }

  async handleAssetDetailsCallout(type) {
    console.log(`${type} API call started`);
    this.isLoading = true;

    let payload = {};
    let apiFunction;

    if (type === "mprn") {
      payload = {
        mprn: this.mprn,
        customer: this.selectedCode || "",
      };
      apiFunction = callAssetDetailsAPI;
    } else if (type === "serial") {
      if (!this.serialNumber) return;
      payload = {
        serailNumber: this.serialNumber,
      };
      apiFunction = callSerialNumberAssetDetailsAPI;
    } else if (type === "postal") {
      if (!this.postalcodevalue) return;
      payload = {
        postalcodevalue: this.postalcodevalue,
        customer: this.selectedCode || "",
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
      let combinedWrapper = [];

      members.forEach((member) => {
        const customers = member?.pluspcustassoc || [];
        const customerSerialNumber = member?.asset || [];
        const validCustomers = customers.filter(
          (cust) => cust.ngme_effective_to_date?.trim() === "9999-12-31T00:00:00+00:00"
        );
        const validasset = customerSerialNumber.filter(
          (asset) => asset.assettype?.trim() === "Z001"
        );
        console.log("validCustomers>>", validCustomers);
        console.log("validasset>>", JSON.stringify(validasset));
        console.log("validasset>>", validasset.length);
        const serialNumber = validasset.length > 0 ? validasset[0].serialnum : "";
        const modelNUmber = validasset.length > 0 ? validasset[0].pluscmodelnum : "";
        const combined = validCustomers.map((cust) => ({
          MPRN: member.location,
          Customer: cust.customer,
          AppointmentFromDate: this.formatDateToDDMMYYYY(cust.ngme_effective_from_date),
          Address: `${member.ngme_c_bldngname}, ${member.ngme_c_prncpstreet}, ${member.ngme_c_st}`,
          Model: modelNUmber,
          MSN: serialNumber,
        }));

        combinedWrapper.push(...combined);
      });

      this.filteredRecords = combinedWrapper;
      this.isModalOpen = this.filteredRecords.length > 1 || this.filteredRecords.length === 0;

      console.log("Filtered Records:", this.filteredRecords);
      console.log("Modal Open:", this.isModalOpen);
    } catch (error) {
      console.error(`Error in ${type} callout:`, error);
      this.filteredRecords = [];
    } finally {
      this.isLoading = false;
    }
  }
  handlePostalCodeChanges(event) {
    this.postalcodevalue = event.target.value;
    console.log("Postalcode >>", this.postalcodevalue);
  }
  
formatDateToDDMMYYYY(dateString) {
    const date = new Date(dateString);
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0'); // Months are 0-based
    const year = date.getFullYear();
    return `${day}/${month}/${year}`;
}

}