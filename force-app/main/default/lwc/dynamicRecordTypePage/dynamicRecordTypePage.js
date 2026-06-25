import { LightningElement, api, wire } from 'lwc';
import { getRecordUi, getObjectInfo } from 'lightning/uiRecordApi';

export default class DynamicRecordTypePage extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api title = 'Dynamic Sections by Record Type';
    @api sectionConfigJson;

    loading = true;
    ready = false;
    error = null;
    errorMessage;

    recordDisplayName;
    recordTypeId;
    activeRecordTypeDevName;

    objectInfos;

    @wire(getRecordUi, {
        recordIds: '$recordId',
        layoutTypes: ['Full'],
        modes: ['View']
    })
    wiredRecordUi({ data, error }) {
        if (error) {
            this.setError(error);
            return;
        }
        if (data && data.records && data.records[this.recordId]) {
            const rec = data.records[this.recordId];
            this.recordTypeId = rec.recordTypeId;
            this.recordDisplayName = this.safeGet(rec, 'fields.Name.value')
                || this.safeGet(rec, 'apiName');
            this.computeActiveRecordTypeName();
        }
        this.finishIfReady();
    }

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

    get activeSections() {
        const cfg = this.parsedConfig;
        if (!cfg) return [];
        const sections = (cfg[this.activeRecordTypeDevName] || cfg.Default || []);
        return sections.map((sec, idx) => ({
            ...sec,
            key: `${this.activeRecordTypeDevName}-${idx}`
        }));
    }

    get showNoConfig() {
        const cfg = this.parsedConfig;
        return this.ready && (!cfg || (this.activeSections.length === 0));
    }

    get parsedConfig() {
        if (!this.sectionConfigJson) return null;
        try {
            return JSON.parse(this.sectionConfigJson);
        } catch (e) {
            this.setError({ message: `Invalid JSON in sectionConfigJson: ${e.message}` });
            return null;
        }
    }

    computeActiveRecordTypeName() {
        if (!this.recordTypeId || !this.objectInfos) return;
        const rtInfo = this.objectInfos.recordTypeInfos[this.recordTypeId];
        if (rtInfo) {
            this.activeRecordTypeDevName = rtInfo.developerName;
        }
    }

    finishIfReady() {
        if (this.objectInfos && (this.recordTypeId || this.error)) {
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
        console.error('DynamicRecordTypePage error:', error);
    }

    safeGet(obj, path) {
        return path.split('.').reduce((acc, key) => (acc && acc[key] != null ? acc[key] : undefined), obj);
    }
}