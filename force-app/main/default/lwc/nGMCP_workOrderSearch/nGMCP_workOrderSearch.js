import { LightningElement } from "lwc";
import ngAssets from "@salesforce/resourceUrl/NGMCP_SearchMPRN";
import getWorkOrderId from "@salesforce/apex/NGMCP_RequestSearchController.getWorkOrderId";

export default class NGMCP_workOrderSearch extends LightningElement {
  homepageAssets = ngAssets;
  woNumber = "";
  isSearchDisabled = true;
  woRecordId;
  recordTypeName;
  handleNumberInput = (event) => {
    console.log("handle Number", event.target.value);
    const type = event.target.dataset.type; 
    const value = (event.target.value || "").trim();
    this.woNumber = value;
    this.isSearchDisabled = false;
  };

  async handleSearchClick(event) {
    const type = event.currentTarget.dataset.type;
    // Optional: Disable search while calling Apex
    const previousDisabled = this.isSearchDisabled;
    this.isSearchDisabled = true;

    try {
      console.log("Work Order search clicked for:", this.woNumber);
      const workOrderId = await getWorkOrderId({
        workOrderNumber: this.woNumber,
      });

      if (workOrderId) {
        console.log("Work Order Id:", workOrderId);
        this.woRecordId = workOrderId;
        this.recordTypeName = "WorkOrder";
      } else {
        console.warn("No Work Order found for number:", this.woNumber);
      }
    } catch (error) {
      console.error("Error fetching Work Order Id:", error);
    } finally {
      // Restore button state
      this.isSearchDisabled = previousDisabled;
    }
  }
}