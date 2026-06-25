import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import Status from '@salesforce/schema/Case.Status';
import CreatedById from '@salesforce/schema/Case.CreatedById';
import CaseNumber from '@salesforce/schema/Case.CaseNumber';
import CreatedDate from '@salesforce/schema/Case.CreatedDate';
import CATEGORY from '@salesforce/schema/Case.Category__c';
import SUBCATEGORY from '@salesforce/schema/Case.Sub_Category__c';
import MPRN from '@salesforce/schema/Case.CRM_MPRN__c';
import DESC from '@salesforce/schema/Case.Description';
import HOUSE from '@salesforce/schema/Case.CRM_House_Name_Number_Site_Name__c';
import STREET from '@salesforce/schema/Case.CRM_Street__c';
import CITY from '@salesforce/schema/Case.CRM_City_County__c';
import POSTCODE from '@salesforce/schema/Case.CRM_Post_code__c';
import CUSTOMERNAME from '@salesforce/schema/Case.CRM_End_Consumer_Name__c';
import EMAIL from '@salesforce/schema/Case.CRM_End_Consumer_Email_Address__c';
import PHONE from '@salesforce/schema/Case.CRM_End_Consumer_Contact_Number__c';
import RESIDENCE from '@salesforce/schema/Case.Residence_Type__c';
import TITLE from '@salesforce/schema/Case.CRM_End_Consumer_Title__c';

// 👇 Add this: relationship field import for Created By Name
import CREATEDBYNAME from '@salesforce/schema/Case.CreatedBy.Name';

import getFiles from '@salesforce/apex/nGMCP_ComplaintViewController.getFiles';
import IsCompetitorProduct from '@salesforce/schema/Asset.IsCompetitorProduct';

export default class NGMCP_ComplaintView extends LightningElement {
    @track recordId;
    @track caseRecord;
    @track files = [];

    // 👇 Include CREATEDBYNAME here so we can read the name
    fields = [
        Status, CreatedById, CREATEDBYNAME, CaseNumber, CreatedDate,
        CATEGORY, SUBCATEGORY, MPRN, DESC, HOUSE, STREET, CITY, POSTCODE,
        CUSTOMERNAME, EMAIL, PHONE, RESIDENCE, TITLE
    ];

    @wire(CurrentPageReference)
    captureURLParams(ref) {
        const rid = ref?.state?.recordId || ref?.attributes?.recordId;
        if (rid) {
            this.recordId = rid;
        } else {
            const path = window.location.pathname || '';
            const parts = path.split('/').filter(Boolean);
            const last = parts[parts.length - 1];
            if (last && /^[a-zA-Z0-9]{15,18}$/.test(last)) {
                this.recordId = last;
            }
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    wiredRecord({ data, error }) {
        if (data) this.caseRecord = data;
        // if (error) console.error(error);
    }

    @wire(getFiles, { recordId: '$recordId' })
    wiredFiles({ data, error }) {
        if (data) {
            this.files = data.map(f => ({
                id: f.ContentDocument?.LatestPublishedVersionId,
                name: f.ContentDocument?.Title,
                extension: f.ContentDocument?.FileExtension,
                url: `/sfc/servlet.shepherd/version/download/${f.ContentDocument?.LatestPublishedVersionId}`
            }));
        }
        // if (error) console.error(error);
    }

    getValue(fieldSchema) {
        return getFieldValue(this.caseRecord, fieldSchema) || '';
    }

    get CaseNumber()   { return this.getValue(CaseNumber); }
    get status()       { return this.getValue(Status); }
    get createdById()  { return this.getValue(CreatedById); }
    get category()     { return this.getValue(CATEGORY); }
    get subCategory()  { return this.getValue(SUBCATEGORY); }
    get mprn()         { return this.getValue(MPRN); }
    get description()  { return this.getValue(DESC); }
    get house()        { return this.getValue(HOUSE); }
    get street()       { return this.getValue(STREET); }
    get city()         { return this.getValue(CITY); }
    get postcode()     { return this.getValue(POSTCODE); }
    get customerName() { return this.getValue(CUSTOMERNAME); }
    get email()        { return this.getValue(EMAIL); }
    get phone()        { return this.getValue(PHONE); }
    get residence()    { return this.getValue(RESIDENCE); }
    get TITLE()        { return this.getValue(TITLE); }

    // ✅ Created By Name (not Id)
    get createdByName() {
        return getFieldValue(this.caseRecord, CREATEDBYNAME) || '';
    }

    // ✅ Created Date (Date only) – formatted in JS
    get createdDateOnly() {
        const raw = getFieldValue(this.caseRecord, CreatedDate);
        if (!raw) return '';
        // raw is an ISO string; format to date only
        const dt = new Date(raw);
        return new Intl.DateTimeFormat('en-GB', {
            year: 'numeric', month: '2-digit', day: '2-digit'
        }).format(dt);
    }

    // If you still want the raw CreatedDate for lightning-formatted-date-time usage in template
    get createdDateRaw() {
        return getFieldValue(this.caseRecord, CreatedDate) || null;
    }
}