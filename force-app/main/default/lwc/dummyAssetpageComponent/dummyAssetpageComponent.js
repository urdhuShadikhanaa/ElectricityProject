import { LightningElement, track, api } from "lwc";
import getMetaData from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.getMeterModelSizeandcatagory";
import addressUpdate from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.addressUpdateAPI";
import insertAddress from "@salesforce/apex/NGMCP_RequestObjectClass.createAddressUpdateRecord";
import addressErrormessage from '@salesforce/label/c.NGMCP_AddressErrormessage';
export default class DummyAssetpageComponent extends LightningElement {

      @track isEditing = false;
      @track selectedTab = "Overview";
      @track assetDetails = [];
      @track conversionMeter = [];
      @track isCreateJobVisible = false;
      @track paymentMechanism;
      @track postCode;
      @track mprn;
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
      ConverterDetails =[];
      siteDetails = [];
      meterDetails =[];
      @track isLoading = false;
      @track showSuccessMessage = false;
      @track messageText = "";
      @track showSiteDetails = false;
      @track showConverterDetails = false;
      @track showAllAsset = false;
      @track errorMessage = false;// BUG: 172765
    
@api
set decodedData(value) {
    this._decodedData = value;
    console.log('decoded****'+JSON.stringify(this._decodedData));
    try {
        const actualData = Array.isArray(value) && value.length > 0 && typeof value[0] === 'object'
            ? value[0]
            : value;

       /* if (!actualData || typeof actualData !== 'object') {
            console.error('Invalid data format. Expected an object or an array of objects.');
            this.errorMessage = 'Invalid data format received.';
            return;
        }*/

        // ✅ Use optional chaining to avoid undefined errors
        this.customerDetails = {
            MPRN: actualData?.MPRN || '',
            Customer: actualData?.Customer || '',
            Address: actualData?.Address || '',
            AppointmentFromDate: actualData?.AppointmentFromDate || '',
            MprnCustomer: actualData?.MprnCustomer || '',
            MarketselectorCode: actualData?.MarketselectorCode || '',
            buildingNumber: actualData?.buildingNumber || '',
            buildingName: actualData?.buildingName || '',
            street: actualData?.street || '',
            dependentLocality: actualData?.dependentLocality || '',
            postalTown: actualData?.postalTown || '',
            postCode: actualData?.postCode || '',
            location: actualData?.location || '',
            conversionFactor: actualData?.conversionFactor || '',
            locationsId: actualData?.locationsId || '',
            amrtag: actualData?.amrtag || '',
            microbusiness: actualData?.microbusiness || '',
            siteid: actualData?.siteid || '',
            appointmentDate: actualData?.appointmentDate || '',
            pressureTier: actualData?.pressureTier || ''
        };

        // ✅ Handle assets safely
        const allAssets = actualData?.Assets || [];
        this.meterDetails = allAssets.filter(asset => asset?.MeterType === 'Z001');
        this.conversionMeter = allAssets.filter(asset => asset?.MeterType === 'Z002');

        // ✅ Assign assetnum and msn safely
        this.assetnum = this.meterDetails[0]?.assetnum || this.conversionMeter[0]?.assetnum || null;
        this.msn = this.meterDetails[0]?.serialNo || this.conversionMeter[0]?.serialNo || null;

        // ✅ Fetch metadata if key exists
        console.log('Z001 Residential key'+this.meterDetails[0]?.residential_commercialKey);
        const key = this.meterDetails[0]?.residential_commercialKey || this.conversionMeter[0]?.residential_commercialKey || null;
        if (key) {
            this.fetchMetadata(key);
        }

    } catch (error) {
        this.errorMessage = `Error decoding data: ${error.message}`;
        console.error('Full error:', error);
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
        const value = event.target.value;
    
        console.log("Field:", field);
        console.log("Value:", value);
    
        switch (field) {
          case "building":
            this.tempBuildingNumber = value;
            break;
          case "buildingName":
            this.tempBuildingName = value;
            break;
          case "street":
            this.tempStreet = value;
            break;
          case "dependent":
            this.tempDependentLocality = value;
            break;
          case "town":
            this.tempPostalTown = value;
            break;
          case "postal":
            this.tempPostCode = value;
            break;
          default:
            console.warn(`Unhandled field: ${field}`);
        }
      }
    
      handleEdit = () => {
        this.isEditing = !this.isEditing;
      };
      async handleSave() {
        this.isEditing = false;
        this.isLoading = true;
        console.log("Saved address:");
        // Extract address fields safely    
        this.tempBuildingNumber = (this.tempBuildingNumber ?? this.customerDetails.buildingNumber)?.toUpperCase();
        this.tempBuildingName = (this.tempBuildingName ?? this.customerDetails.buildingName)?.toUpperCase();
        this.tempStreet = (this.tempStreet ?? this.customerDetails.street)?.toUpperCase();
        this.tempDependentLocality = (this.tempDependentLocality ?? this.customerDetails.dependentLocality)?.toUpperCase();
        this.tempPostalTown = (this.tempPostalTown ?? this.customerDetails.postalTown)?.toUpperCase();
        this.tempPostCode = (this.tempPostCode ?? this.customerDetails.postCode)?.toUpperCase();
    
        console.log("this.buildingNumber", this.tempBuildingNumber);
        console.log("this.buildingName", this.tempBuildingName);
        console.log("this.street", this.tempStreet);
        console.log("this.dependentLocality", this.tempDependentLocality);
        console.log("this.postalTown", this.tempPostalTown);
        console.log("this.postCode", this.tempPostCode);
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
          locationsid: this.customerDetails.locationsId,
          ngme_c_sitebn: this.tempBuildingNumber,
          ngme_s_sitebn: this.tempBuildingNumber,
          ngme_c_bldngname: this.tempBuildingName,
          ngme_s_bldngname: this.tempBuildingName,
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
            locationId: this.customerDetails.locationsId,
          });
          console.log("insertrecord:", insertrecord);
          console.log("requestBody:", JSON.stringify(requestBody));
          if (insertrecord) {
            const result = await addressUpdate({
              requestBody: JSON.stringify(requestBody),
              locationId: this.customerDetails.locationsId,
              adreesRequestId: insertrecord,
            });
            if (result) {
            this.customerDetails.buildingNumber = this.tempBuildingNumber;
            this.customerDetails.buildingName = this.tempBuildingName;
            this.customerDetails.street= this.tempStreet;
            this.customerDetails.dependentLocality= this.tempDependentLocality;
            this.customerDetails.postalTown= this.tempPostalTown;
            this.customerDetails.postCode= this.tempPostCode;
              this.isLoading = false;
              this.messageText = result;
              this.showSuccessMessage = true;
              // Hide after 3 seconds
              setTimeout(() => {
                this.showSuccessMessage = false;
              }, 3000);
            }
    
            console.log("Result from Apex:", result);
          }
        } catch (error) {
          console.error("Error saving address:", error);
             this.messageText = addressErrormessage;
              this.errorMessage = true;// BUG: 172765
              // Hide after 3 seconds
              setTimeout(() => {
                 this.errorMessage = false;
              }, 3000);
        } finally {
          this.isLoading = false;
        }
      }
      handleCancel() {
        this.isEditing = false;
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
    
      selectOverview = () => (this.selectedTab = "Overview");
      selectRequestLog = () => (this.selectedTab = "Request");
      selectWorkOrderLog = () => (this.selectedTab = "WorkOrder");
      selectAMR = () => (this.selectedTab = "AMR");
    
      async fetchMetadata(modelValue) {
        console.log("Fetching metadata for model:", modelValue);
        if (this.metadataCache[modelValue]) {
          this.status = this.metadataCache[modelValue];
          console.log("Metadata  hit for model: ", this.status);
          this.buildAssetDetails();
          this.buildConverterDetails();
          this.buidsiteDetails();
          return;
        }
    
        try {
          const result = await getMetaData({ meterModel: modelValue });
          const category = this.getCategory(result);
          console.log("category >>", category);
          this.metadataCache[modelValue] = category;
          this.status = category;
          console.log(this.status);
          // Ensure result is always treated as an array
          const metadataList = Array.isArray(result) ? result : [result];
          console.log("metadataList >>", JSON.stringify(metadataList));
          const industry = category === "Residential" ? "D" : "I";
          console.log("industry >>", industry)
          // Combine metadata with additional fields
          const urgentworkRequestInput = {
            metadatalist: metadataList,
            assetnum: this.assetnum,
            location: this.customerDetails.MPRN,
            suppliercode: this.customerDetails.Customer,
            ngme_industry: industry,
          };
    
          this.metaDataWrapper.push(urgentworkRequestInput);
          console.log("Combined Wrapper:", JSON.stringify(this.metaDataWrapper));
        } catch (error) {
          console.error("Error calling Apex:", error);
          this.status = "Error fetching metadata";
        } finally {
          console.log("final block calling");
          this.buildAssetDetails();
          this.buildConverterDetails();
          this.buidsiteDetails();
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
        this.ConverterDetails = [
          { label: "Manufacturer", value: asset.manufacturerFullName || " " },
          { label: "Model", value: asset.Model || " " },
          { label: "Manufacturer Serial no.", value: asset.serialNo || " " },
          { label: "No. of Dials", value: asset.noofdial ?? " " },
        ];
        this.showConverterDetails = this.ConverterDetails.length > 0;
        console.log("Final mapped ConverterDetails:", JSON.stringify(this.ConverterDetails));
        console.log("showConverterDetails:", this.showConverterDetails);
      } else {
        this.ConverterDetails = [];
        this.showConverterDetails = false;
        console.warn("No conversion meter data available.");
      }
    }
      buidsiteDetails(){
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
          ];
          console.log(
          "Final siteDetails:",
          JSON.stringify(this.siteDetails));
        this.showSiteDetails = this.siteDetails.length > 0;
        
        }
        
      buildAssetDetails() {
        console.log("buildAssetDetails called");
        if (this.meterDetails?.length > 0) {
          const asset = this.meterDetails[0]; // or loop if you want to show all
          this.assetDetails = [
            { label: "Manufacturer", value: asset.manufacturerFullName },
            { label: "Model", value: asset.Model },
            { label: "Manufacturer Serial no.", value: asset.serialNo },
            { label: "Meter Type", value: asset.pulsMeterType },
            { label: "No. of Dials", value: asset.noofdial },
            { label: "Payment Mechanism", value: asset.paymentMechanism },
            { label: "Year of Manufacture", value: asset.yearofmanufacture },
            { label: "Location", value: this.customerDetails.location || "" },
            { label: "Install Date", value: this.formatDate(asset.InstallDate) },       
            { label: "Measuring Capacity", value: asset.measuringCapacity },        
          ];
          this.paymentMechanism = asset.paymentMechanism;
          
        }
        console.log(
          "Final mapped assetDetails:",
          JSON.stringify(this.assetDetails)
        );
      console.log("Final mapped assetDetails:", JSON.stringify(this.assetDetails));
      console.log("Payment Mechanism:", this.paymentMechanism);
      }
    
      handleCreateJobClick() {
        console.log("handleCreateJobClick invoked");
        this.address = {
        buildingNumber: this.customerDetails.buildingNumber,
        buildingName: this.customerDetails.buildingName,
        street: this.customerDetails.street,
        dependentLocality: this.customerDetails.dependentLocality,
        postalTown: this.customerDetails.postalTown,
        postCode: this.customerDetails.postCode,
      };
       console.log('assetdetails',JSON.stringify(this.address));
        this.isCreateJobVisible = true;       
       
      }
    
      handleCancelJob() {
        this.isCreateJobVisible = false;
      }
    
      get assetArray() {
         return Array.isArray(this.assetDetails) ? this.assetDetails : [];
      }
    
      get displayedAssetDetails() {
         return this.showAllAsset ? this.assetArray : this.assetArray.slice(0, 6);
      }
    
      get hasMoreAssetDetails() {
         return this.assetArray.length > 6;
      }
    
      get assetArrowClass() {
         return this.showAllAsset ? 'arrow down' : 'arrow right';
      }
    
      get assetToggleText() {
         return this.showAllAsset ? 'Less details' : 'More details';
      }
    
      toggleAssetExpand() {
         this.showAllAsset = !this.showAllAsset;
      }
}