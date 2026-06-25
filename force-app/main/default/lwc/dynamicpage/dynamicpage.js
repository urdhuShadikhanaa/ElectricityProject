import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import buildJson from '@salesforce/apex/NGMCP_DynamicPageConfigServiceController.buildSectionConfigJsonByRtName';

export default class DynamicPage extends LightningElement {
    /**
     * You only need to provide recordId.
     * For record pages, Salesforce injects it automatically.
     * For Home/App/LWR pages, set just this property in Experience Builder.
     */
    @api recordId ;
    @api recordTypeName;

    // Auto-derived from getRecord; you don't have to set it
    @api objectApiName ='NGMCP_Request__c' ;

    @api title = 'Dynamic Sections by Record Type';

    /**
     * Optional JSON mapping. If not provided, a Default section is shown.
     * {
     *   "RecordTypeDevNameA": [{ "label":"Section A", "fields":["Name","Phone"] }],
     *   "RecordTypeDevNameB": [{ "label":"Section B", "fields":["Name","Email"] }],
     *   "Default": [{ "label":"Basic", "fields":["Name","CreatedDate"] }]
     * }
     */
   @api sectionConfigJson;
// In dynamicPage.js
/*@api sectionConfigJson = `{
  "Default": [
    {
      "label": "MPRN Details",
      "fields": ["NGMCP_MPRN__c", "NGMCP_Supplier_Id__c"]
    },
    {
      "label": "Urgent Work Request",
      "fields": [
        "NGMCP_Reportedpriority__c",
        "NGMCP_Job_Type__c",
        "NGMCP_Job_SubType__c",
        "NGMCP_Job_Sub_Sub_Type__c",
        "NGMCP_Target_Start__c",
        "NGMCP_Time__c",
        "NGMCP_Source__c",
        "NGMCP_Liferay_Slot__c",
        "NGMCP_Market_Sector_Code__c",
        "NGMCP_Asset_Number__c",
        "NGMCP_Affected_Person__c",
        "NGMCP_Affectedphone__c",
        "NGMCP_Description_Long_Description__c"
      ]
    },
    {
      "label": "Call Out Details",
      "fields": [
        "NGMCP_API_Callout__c",
        "NGMCP_Status__c",
        "NGMCP_SR_Ticket__c",
        "NGMCP_Callout_Response__c",
        "NGMCP_Error_Message__c"
      ]
    },
    {
      "label": "System Details",
      "fields": [
        "CreatedById",
        "CreatedDate",
        "LastModifiedById",
        "LastModifiedDate"
      ]
    }
  ]
}`;*/


@wire(buildJson, { recordTypeName: '$recordTypeName'})
    wiredJson({ data, error }) {
        if (data) {
            this.sectionConfigJson = data; // JSON string
        } else if (error) {
            console.error('Failed to load CMT config:', error?.body?.message || error?.message);
        }
    }


    // UI state
    loading = true;
    ready = false;
    error = null;
    errorMessage;

    // Data
    recordDisplayName;
    recordTypeId;
    activeRecordTypeDevName;
    objectInfos;

    // --- Wire record (derives objectApiName automatically) ---
    @wire(getRecord, {
        recordId: '$recordId',
        // You can switch to a fields[] array for performance; layoutTypes returns all fields in the layout.
        layoutTypes: ['Full'],
        modes: ['View']
    })
    wiredRecord({ data, error }) {
        if (error) {
            this.setError(error);
            return;
        }
        if (data) {
            // Derive objectApiName: no need to pass it explicitly
            if (!this.objectApiName && data.apiName) {
                this.objectApiName = data.apiName; // Reactively triggers getObjectInfo
            }

            this.recordTypeId = data.recordTypeId;

            // Header name; fall back to the object apiName if Name doesn't exist
            this.recordDisplayName = this.safeGet(data, 'fields.Name.value') || data.apiName;

            this.computeActiveRecordTypeName();
        }
        this.finishIfReady();
    }

    // --- Wire object info (needs objectApiName; we auto-set it above) ---
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    wiredObjectInfo({ data, error }) {
        if (error) {
            this.setError(error);
            return;
        }
        if (data) {
            this.objectInfos = data;
            this.computeActiveRecordTypeName();
        }
        this.finishIfReady();
    }

    // --- Sections / config ---
    get activeSections() {
        const cfg = this.parsedConfig;
        console.log('activeSections', JSON.stringify(cfg));
        if (!cfg) return this.defaultSections;
        const sections = (cfg[this.activeRecordTypeDevName] || cfg.Default || this.defaultSections);        
        return sections.map((sec, idx) => ({ ...sec, key: `${this.activeRecordTypeDevName || 'Default'}-${idx}` }));
    }

    get showNoConfig() {
        const cfg = this.parsedConfig;
        // Show message only if user provided cfg but it had no matching sections
        return this.ready && !!cfg && this.activeSections.length === 0;
    }

   
get parsedConfig() {
    if (!this.sectionConfigJson) return null;
    try {
        console.log('parsedConfig', JSON.stringify(this.sectionConfigJson));
        return JSON.parse(this.sectionConfigJson); // now it's a string → OK
    } catch (e) {
        this.setError({ message: `Invalid JSON in Section Config: ${e.message}` });
        return null;
    }
}


    // Default section shown when no JSON config is supplied
    get defaultSections() {
        return [
            { label: 'Details', fields: ['NGMCP_MPRN__c','NGMCP_Supplier_Id__c', 'CreatedById', 'CreatedDate'] }
        ];
    }

    // --- Helpers ---
    computeActiveRecordTypeName() {
        if (!this.recordTypeId || !this.objectInfos) return;
        const rtInfo = this.objectInfos.recordTypeInfos[this.recordTypeId];
        if (rtInfo) {
            this.activeRecordTypeDevName = rtInfo.developerName;
        }
    }

    finishIfReady() {
        // Stop spinner once we have object info and we attempted record load (data or error)
        const attemptedRecord = this.recordTypeId !== undefined || this.error !== null;
        if (this.objectInfos && attemptedRecord) {
            this.loading = false;
            this.ready = !this.error;
        }
    }

    setError(error) {
        this.error = error;
        this.loading = false;
        this.ready = false;
        this.errorMessage = error?.body?.message || error?.message || 'Unknown error';
        // eslint-disable-next-line no-console
        console.error('[DynamicPage] error:', error);
    }

    safeGet(obj, path) {
        return path.split('.').reduce((acc, key) => (acc && acc[key] != null ? acc[key] : undefined), obj);
    }
}