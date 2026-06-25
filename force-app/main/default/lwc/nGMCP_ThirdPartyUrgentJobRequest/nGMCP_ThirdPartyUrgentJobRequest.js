import { LightningElement, track, api,wire } from "lwc";
import getMetaData from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.getMeterModelSizeandcatagory";
import getAllAssestMasterData from "@salesforce/apex/NGMCP_WorkRequestController.geAllAssestMasterData";
export default class NGMCP_ThirdPartyUrgentJobRequest extends LightningElement {
  @track mprn = "";
  @track shortCode = "";
  @track isMprnExists = false; // when false, show residential question
  @track isResidential = null;
  @track showEditableSections = false;
  @track status = "";
  @track metadataCache = [];
  @track jobTypes = [];
  @track manufacturerMap = new Map();
  @track error;
  @track manufactureoptions ;

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

  @wire(getAllAssestMasterData)
wiredAssetDataConfigs({ error, data }) {
    if (data) {
        this.manufacturerMap = new Map();

        data.forEach(item => {
            const key = item.NGMCP_Manufacturer_Name__c;

            if (!this.manufacturerMap.has(key)) {
                this.manufacturerMap.set(key, {
                    manufacturer: key,
                    models: [],
                    type: [],
                    fullRecords: []
                });
            }

            const manufacturerData = this.manufacturerMap.get(key);

            const modelsArray = (item.NGMCP_Meter_Model__c || "")
                .split(",")
                .map(model => model.trim())
                .filter(model => model);

            const typeArray = (item.NGMCP_Type__c || "")
                .split(",")
                .map(type => type.trim())
                .filter(type => type);

            manufacturerData.models.push(...modelsArray);
            manufacturerData.type.push(...typeArray);
            manufacturerData.fullRecords.push(item);
        });

        // Convert Map to Array for template usage
        this.manufactureoptions = Array.from(this.manufacturerMap.values());
    } else if (error) {
        this.error = error;
        console.error("Error fetching Asset Master Data:", error);
    }
}
  handleInputChange(event) {
    const { name, value } = event.target;
    this[name] = value;
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
    { label: "Manufacturer", value: "", apiName: "manufacturer" },
    { label: "Model", value: "", apiName: "model" },
    { label: "Manufacturer Serial no.", value: "", apiName: "serialNumber" },
    { label: "Meter Type", value: "", apiName: "meterType" },
  ];

  handleAddressFromChild(event) {
    const address = event.detail?.address || event.detail || {};
    this.address = {
      ...this.address,
      street: (address.street || '').trim() || this.address.street,
      dependentLocality: (address.street2 || '').trim() || this.address.dependentLocality,
      postalTown: (address.city || '').trim() || this.address.postalTown,
      postCode: (address.postalCode || address.postalcode || '').trim() || this.address.postCode
    };
    const apiUpdates = {
      street: this.address.street,
      dependentLocality: this.address.dependentLocality,
      postalTown: this.address.postalTown,
      postCode: this.address.postCode
    };
    this.addressDetails = (this.addressDetails || []).map((item) =>
      apiUpdates[item.apiName] !== undefined
        ? { ...item, value: apiUpdates[item.apiName] || item.value }
        : item
    );
  }

  handleAddressEdit(event) {
    const field = event.target.dataset.field;
    const value = event.target.value;

    this.addressDetails = this.addressDetails.map((item) =>
      item.apiName === field ? { ...item, value } : item
    );
  }

  handleAssetEdit(event) {
    const field = event.target.dataset.field;
    const value = event.target.value;

    this.assetDetails = this.assetDetails.map((item) =>
      item.apiName === field ? { ...item, value } : item
    );
  }

  handleResidentialChange(event) {
    this.isResidential = event.target.value;
    this.showEditableSections = true;
  }

  handleAddressChange(event) {
    const { name, value } = event.target;
    this.address = { ...this.address, [name]: value };
  }

  handleAssetChange(event) {
    const { name, value } = event.target;
    this.asset = { ...this.asset, [name]: value };
  }

  handleCardClick(event) {
    const selected = event.currentTarget.dataset.value;
    switch (selected) {
      case "urgent":
        const getValue = (apiName) => {
          const item = this.assetDetails.find((obj) => obj.apiName === apiName);
          return item ? item.value.trim() : "";
        };
        let modeKeyAdjustments = getValue("model")
          .replace(/[\/. " *]/g, "_")
          .replace(/_+$/, "");
        let type = getValue("meterType")
          .replace(/[\/." * -]/g, "_")
          .replace(/_+/g, "_")
          .replace(/_+$/, "");
        const mskCode = this.isResidential === "Yes" ? "D" : "I";
        const key = `${mskCode}_${modeKeyAdjustments}_${type}_Yes`;
        this.fetchMetadata(key);
        break;

      case "windon":
      case "faulty":
        break;
      case "now":
        break;

      case "pick":
        break;

      case "restro":
        break;

      default:
        break;
    }
  }
  async fetchMetadata(modelValue) {
    if (this.metadataCache[modelValue]) {
      this.status = this.metadataCache[modelValue];
      return;
    }

    try {
      const result = await getMetaData({ meterModel: modelValue });
      const category = this.getCategory(result);
      this.metadataCache[modelValue] = category;
      this.status = category;
      // Ensure result is always treated as an array
      const metadataList = Array.isArray(result) ? result : [result];
      this.jobTypes = metadataList.map((item) => ({
        value: item.NGMCP_UWR_Job_Code__c,
        label: item.NGMCP_Portal_Category__c,
        description: item.NGMCP_Job_Description__c,
        isChecked: false,
        showRecommendation: true,
        className: "radio-card",
      }));
      if (this.jobTypes.length === 1) {
        this.selectedJobType = true;
        this.job_sub_subtype = this.jobTypes[0].value;
      }
    } catch (error) {
      console.error("Error calling Apex:", error);
      this.status = "Error fetching metadata";
    } finally {
      console.log("final block calling");
    }
  }

  handleSubmitUrgentWorkrequest() {
  }

  handleCancelClick() {
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

      // ✅ Find correct asset (Z001 or Z002) just like in NGMCP_MprnDetail
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
        console.warn(
          "⚠️ No valid residential_commercialKey found to fetch metadata."
        );
        this.metaDataWrapper = {};
        return;
      }
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
      console.error(
        "❌ Error while fetching metadata in handleMprnFound:",
        error
      );
    }
  }

  // Helper to derive category
  getCategory(result) {
    try {
      if (!result) return "Unknown";
      const category = result?.[0]?.category || result.category || "Unknown";
      return category === "Residential" ? "Residential" : "Industrial";
    } catch (err) {
      console.error("Error deriving category:", err);
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
}