import { LightningElement, track, api } from 'lwc';
import getMetaData from "@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.getMeterModelSizeandcatagory";
export default class NGMCP_ThirdPartyUrentWorkRequest extends LightningElement {
    @track showSearch = true;
    @track showCreateJob = false;
    @track showEditableJob = false;

    @api metaDataWrapper;
    @api assetDetails;
    @api address;
    @api status;
    @api paymentMechanism;
    @api postCode;
    @api pressuretier;
    @api pressuretierBrand;
    @api mprn;
    @track enquiryFlag = false;
    @track mprn;
    @track searchCode;
    @track mprnCustomer;
    @track hasz002;
    @track appointmentFlag;
    @track location;
    @track siteid;
    @track locationsid;
    @track msn;
    @track thirdpartyfound = false;
    @track isDeappointAllowed;
    @track paldCustomerFlag;
    @track wrapperRec;
    @track converterDetails = [];

    async handleMprnFound(event) {
        try {
            const { combinedWrapper, metadata, assets, address } = event.detail;
            if (!combinedWrapper || combinedWrapper.length === 0) return;

            const record = combinedWrapper.length > 1 ? combinedWrapper[0] : combinedWrapper;
            // Assign safe defaults
            const rec = Array.isArray(record) ? (record?.[0] ?? {}) : (record ?? {});

            // 2) Optional: log once to verify what's coming in
            this.wrapperRec = rec;

            // 3) Assign safely with optional chaining and nullish coalescing
            this.mprn = rec?.MPRN ?? rec?.mprn ?? '';
            //this.assetDetails = (typeof assets !== 'undefined' ? assets : (rec?.Assets ?? []));

            this.assetDetails = (typeof assets !== 'undefined'
                ? assets
                : (rec?.Assets ?? [])
            ).filter(asset => asset.MeterType === 'Z001');
            this.converterAssets = (typeof assets !== 'undefined'
                ? assets
                : (rec?.Assets ?? [])
            ).filter(asset => asset?.MeterType === 'Z002');
            this.address = (typeof address !== 'undefined' ? address : (rec?.Address ?? {}));
            this.status = rec?.status ?? rec?.Status ?? '';
            const assetsList = rec?.Assets ?? rec?.assets ?? [];

            this.paymentMechanism =
                assetsList
                    .filter(asset => asset.MeterType === 'Z001')
                    ?.[0]?.paymentMechanism ?? '';
            this.postCode = rec?.postCode ?? rec?.postcode ?? rec?.post_code ?? '';
            this.pressuretier = rec?.pressureTier ?? rec?.pressuretier ?? '';
            this.mprnCustomer = rec?.MprnCustomer ?? rec?.mprnCustomer ?? '';
            this.pressuretierBrand = rec?.presureBrand ?? rec?.presureBrand ?? '';
            this.hasz002 = rec?.hasZ002 ?? rec?.hasZ002 ?? '';
            this.appointmentFlag = rec?.appointmentFlag ?? rec?.appointmentFlag ?? '';
            this.isDeappointAllowed = rec?.paldflag
                ? (
                    rec?.Customer === rec?.paldCustomer &&
                    new Date(rec?.paldEndDate) >= new Date()
                ) ? false : rec?.appointmentFlag
                : rec?.appointmentFlag;
            this.paldCustomerFlag = rec?.paldflag
                ? (
                    rec?.Customer === rec?.paldCustomer &&
                    new Date(rec?.paldEndDate) >= new Date()
                ) : false;
            this.location = rec?.location ?? rec?.location ?? '';
            this.siteid = rec?.siteid ?? rec?.siteid ?? '';
            this.locationsid = rec?.locationsId ?? rec?.locationsId ?? '';
            //this.msn = rec?.Assets?.[0]?.MSN || "";
            this.msn =
                assetsList
                    .filter(asset => asset.MeterType === 'Z001')
                    ?.[0]?.MSN || '';
            //  Find correct asset (Z001 or Z002) just like in NGMCP_MprnDetail
            const meterDetails = this.assetDetails.filter(a => a.MeterType === "Z001");
            const conversionMeter = this.assetDetails.filter(a => a.MeterType === "Z002");
            const key =
                (meterDetails.length > 0
                    ? meterDetails[0].residential_commercialKey
                    : conversionMeter.length > 0
                        ? conversionMeter[0].residential_commercialKey
                        : null
                )?.replace(/\*/g, '');
            if (!key) {
                this.metaDataWrapper = {};
                this.status = rec?.MarketselectorCode == "D" ? "Residential" : "Commercial";
                this.showEditableJob = true;
                return;
            }
            const result = await getMetaData({ meterModel: key });
            const metadataList = Array.isArray(result) ? result : [result];
            const selectedAsset = meterDetails[0] || conversionMeter[0];
            const meta = metadataList[0] || {};
            const metaKey = meta?.NGMCP_Meter_Model_Size__c + meta?.GMCP_Market_Sector_Code__c;
            const categoryMap = {
                U6D: "Residential",
                "Non U6D": "Commercial",
                U6I: "Commercial",
                "Non U6I": "Commercial"
            };
            const category = categoryMap[metaKey] ? categoryMap[metaKey] : rec?.MarketselectorCode == "D" ? "Residential" : "Commercial";
            const industry = category === "Residential" ? "D" : "I";
            this.status = category;
            this.metaDataWrapper = {
                metadatalist: metadataList,
                assetnum: selectedAsset?.assetnum || "",
                location: this.mprn,
                suppliercode: rec?.suppliercode ?? rec?.Customer ?? selectedAsset?.suppliercode ?? "EOD",
                ngme_industry: industry
            };
            // Show the component only when all props are ready
            this.showSearch = false;
            this.showEditableJob = false;
            this.showCreateJob = true;

        } catch (error) {
            console.error(" Error while fetching metadata in handleMprnFound:", error);
        }
    }


    // Helper to derive category
    getCategory(result) {
        try {
            if (!result) return "Unknown";
            const category = result?.[0]?.category || result.category || "Unknown";
            return category === "Residential" ? "Residential" : "Industrial";
        } catch (err) {
            return "Unknown";
        }
    }

    // When MPRN not found
    handleMprnNotFound(event) {
        this.metaDataWrapper = event.detail?.metadata || {};
        this.mprn = event.detail?.mprn || "";
        this.searchCode = event.detail?.searchcode || {};
        this.showSearch = false;
        this.showCreateJob = false;
        this.showEditableJob = true;
        this.thirdpartyfound = event.detail.thirdpartyfound;
    }

    // When Create Job is cancelled
    handleCancelJob() {
        this.showCreateJob = false;
        this.showEditableJob = false;
        this.showSearch = true;
        this.thirdpartyfound = false;
    }
    handleCardClick(event) {
        const selectedValue = event.currentTarget.dataset.value;
        switch (selectedValue) {
            case "dataQuery":
                this.enquiryFlag = true;
                break;
            case "tQuery":
                this.enquiryFlag = true;
                break;
        }
    }

    handleRequestTypeValidation(event) {
        if (this.showEditableJob) {
            const globalSearchCmp = this.refs.globalSearch;
            const isValid = globalSearchCmp.validateShortCode();
            if (!isValid) {
                return; // 
            }
        }
    }

    handleSupplierChange(event) {
        this.searchCode = event.detail.shortCode;
        if (this.showEditableJob) {
            const editableCmp = this.template.querySelector(
                'c-n-g-m-c-p_-third-party-editable-job-request'
            );
            if (editableCmp) {
                editableCmp.revalidateOnSupplierChange(this.searchCode);
            }
        }
    }


    handleShortCodeValidation(event) {
        // Only validate when MPRN not present
        if (this.showEditableJob) {
            const isValid = this.refs.globalSearch.validateShortCode();
            if (!isValid) {
                event.preventDefault(); //  BLOCK CHILD
            }
        }
    }
    handleshortcodechange(event) {
        this.searchCode = event.detail.selectedCode;
        if (this.thirdpartyfound) {
            // this.template.querySelector('c-n-g-m-c-p_-third-party-editable-job-request').shortCode = event.detail.selectedCode;
        }

    }
}