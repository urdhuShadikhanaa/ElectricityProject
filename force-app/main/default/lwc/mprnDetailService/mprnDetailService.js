// force‑app/main/default/lwc/mprnDetailService/mprnDetailService.js
 
// Mapping for category based on metadata keys

const categoryMap = {

    U6D: "Residential",

    "Non U6D": "Commercial",

    U6I: "Commercial",

    "Non U6I": "Commercial",

};
 
/**

* Format a date string into DD‑MM‑YYYY

* @param {string} dateStr

* @returns {string}

*/

export function formatDate(dateStr) {

    if (!dateStr) {

        return "—";

    }

    const date = new Date(dateStr);

    if (isNaN(date.getTime())) {

        return "—";

    }

    const day = String(date.getDate()).padStart(2, "0");

    const month = String(date.getMonth() + 1).padStart(2, "0");

    const year = date.getFullYear();

    return `${day}-${month}-${year}`;

}
 
/**

* Get the "category" (Residential / Commercial) from metadata

* @param {Object} metadata

* @returns {string}

*/

export function getCategory(metadata) {

    if (!metadata) {

        return "Unknown";

    }

    const key = metadata.NGMCP_Meter_Model_Size__c + metadata.NGMCP_Market_Sector_Code__c;

    return categoryMap.hasOwnProperty(key) ? categoryMap[key] : "Key not found";

}
 
/**

* Split a list of assets into meter (Z001) and converter (Z002)

* @param {Array} assets

* @returns {{ meterDetails: Array, conversionMeter: Array }}

*/

export function splitAssets(assets = []) {

    const meterDetails = [];

    const conversionMeter = [];

    for (const asset of assets) {

        if (asset.MeterType === "Z001") {

            meterDetails.push(asset);

        } else if (asset.MeterType === "Z002") {

            conversionMeter.push(asset);

        }

    }

    return { meterDetails, conversionMeter };

}
 
/**

* Build an array of asset detail objects (label + value) for UI consumption

* @param {Array} meterDetails

* @param {Object} customerDetails

* @returns {Array<{ label: string, value: any }>}

*/

export function buildAssetDetails(meterDetails = [], customerDetails = {}) {

    if (!meterDetails.length) {

        return [];

    }

    const asset = meterDetails[0];

    return [

        { label: "Manufacturer", value: asset.manufacturerFullName || "" },

        { label: "Model", value: asset.Model || "" },

        { label: "Manufacturer Serial no.", value: asset.serialNo || "" },

        { label: "Meter Type", value: asset.pulsMeterType || "" },

        { label: "No. of Dials", value: asset.noofdial ?? "" },

        { label: "Payment Mechanism", value: asset.paymentMechanism || "" },

        { label: "Year of Manufacture", value: asset.yearofmanufacture || "" },

        { label: "Location", value: customerDetails.location || "" },

        { label: "Install Date", value: formatDate(asset.InstallDate) },

        { label: "Measuring Capacity", value: asset.measuringCapacity || "" }

    ];

}
 
/**

* Build converter (Z002) detail objects (label + value)

* @param {Array} conversionMeter

* @returns {Array<{ label: string, value: any }>}

*/

export function buildConverterDetails(conversionMeter = []) {

    if (!conversionMeter.length) {

        return [];

    }

    const asset = conversionMeter[0];

    return [

        { label: "Manufacturer", value: asset.manufacturerFullName || "" },

        { label: "Model", value: asset.Model || "" },

        { label: "Manufacturer Serial no.", value: asset.serialNo || "" },

        { label: "No. of Dials", value: asset.noofdial ?? "" }

    ];

}
 
/**

* Build site (customer-level) details.

* @param {Object} customerDetails

* @returns {Array<{ label: string, value: any }>}

*/

export function buildSiteDetails(customerDetails = {}) {

    return [

        { label: "Pressure Tier", value: customerDetails.pressureTier || "" },

        { label: "Conversion Factor", value: customerDetails.conversionFactor || "" },

        { label: "Appointment Date", value: formatDate(customerDetails.appointmentDate) },

        { label: "Micro Business ?", value: customerDetails.microbusiness ?? "" }

    ];

}
 
/**

* Build metadata wrapper input for urgent work / create-job request

* @param {Array|Object} metadataList

* @param {string} assetnum

* @param {string} location

* @param {string} supplierCode

* @param {string} category

* @returns {Object}

*/

export function buildMetadataWrapper(metadataList, assetnum, location, supplierCode, category) {

    const industry = category === "Residential" ? "D" : "I";

    const list = Array.isArray(metadataList) ? metadataList : [metadataList];

    return {

        metadatalist: list,

        assetnum: assetnum,

        location: location,

        suppliercode: supplierCode,

        ngme_industry: industry

    };

}
 
/**

* Build a combined structure of all details, suitable for UI section rendering

* @param {Object} params

* @param {Array} params.meterDetails

* @param {Array} params.conversionMeter

* @param {Object} params.customerDetails

* @param {Array|Object} params.metadataList

* @returns {Array<{ sectionTitle: string, items: Array<{ label: string, value: any }> }>}

*/

export function getCombinedDetails({ meterDetails = [], conversionMeter = [], customerDetails = {}, metadataList = [] }) {

    const category = getCategory(metadataList);

    return [

        {

            sectionTitle: "Asset Details",

            items: buildAssetDetails(meterDetails, customerDetails)

        },

        {

            sectionTitle: "Converter Details",

            items: buildConverterDetails(conversionMeter)

        },

        {

            sectionTitle: "Site Details",

            items: buildSiteDetails(customerDetails)

        },

        {

            sectionTitle: "Metadata",

            items: Array.isArray(metadataList)

                ? metadataList.map((md) => ({ label: md.NGMCP_Meter_Model_Size__c || "Model Size", value: JSON.stringify(md) }))

                : [{ label: "Metadata", value: JSON.stringify(metadataList) }]

        }

    ];

}