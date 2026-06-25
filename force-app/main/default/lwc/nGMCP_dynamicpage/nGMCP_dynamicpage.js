import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {
    getRelatedListsInfo,
    getRelatedListInfoBatch,
    getRelatedListRecordsBatch
} from 'lightning/uiRelatedListApi';
import getParentAccountFiles from "@salesforce/apex/NGMCP_RequestSearchController.getParentAccountFiles";
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import getObjectApiName from '@salesforce/apex/NGMCP_DynamicPageConfigServiceController.getObjectApiName';
import buildJson from '@salesforce/apex/NGMCP_DynamicPageConfigServiceController.buildSectionConfigJsonByRtName';
//const FIELDS = ['WorkOrder.FFA_Sender_ID__c'];
const USER_FIELDS = ['User.Name', 'User.Email', 'User.Profile.Name'];
import USER_ID from '@salesforce/user/Id';
export default class NGMCP_DynamicPage extends NavigationMixin(LightningElement) {
    /**
     * You only need to provide recordId.
     * For record pages, Salesforce injects it automatically.
     * For Home/App/LWR pages, set just this property in Experience Builder.
     */
    @api recordId;
    userId = USER_ID;
    @api oldRecordId;
    @api oldRecordTypeName;
    @api recordTypeName;
    @api objectApiName;
    @api title = 'Dynamic Sections by Record Type';
    showdownloadRams = false; // added
    @api sectionConfigJson;
    @track infoBatchResultsById = new Map();  // id -> { displayColumns, childObjectApiName, label }
    @track relatedListIds = [];
    @track relatedListParameters;
    // lists = [];
    // infoById = new Map();
    @api firstColumnMin = 220;        // px
    @api columnMinWidths = [];        // per middle column, e.g. [200,180,200,160] 
    @track selectedRecordId;     // used later
    // dateFields = new Set(); // see #2

    @track lists = [];
    // UI state
    loading = true;
    ready = false;
    error = null;
    errorMessage;
    isLoading = false; // Added for Download spinner
    // Data
    recordDisplayName;
    recordTypeId;
    activeRecordTypeDevName;
    objectInfos;
    @track email;
    @track user;
    @track profileName;
    @wire(buildJson, { recordTypeName: '$recordTypeName' })
    wiredJson({ data, error }) {
        if (data) {
            this.sectionConfigJson = data; // JSON string
        }
    }
    @wire(getRecord, { recordId: '$userId', fields: USER_FIELDS })
    userRecord({ error, data }) {
        if (data) {
            this.email = data.fields.Email.value;
            this.user = data.fields;
            this.profileName = data.fields.Profile.value.fields.Name.value;
        }
    }
    @wire(getRecord, {
        recordId: '$recordId',
        layoutTypes: ['Full'],
        modes: ['View'],
    })
    wiredRecord({ data, error }) {
        if (error) {
            this.setError(error);
            return;

        }
        if (data) {
            // PHOENIX check
            console.log('Data', JSON.stringify(data));
            const senderId = data.fields?.FFA_Sender_ID__c?.value;
            this.showdownloadRams = senderId === 'PHOENIX';
            if (!this.objectApiName && data.apiName) {
                this.objectApiName = data.apiName;
            }
            this.recordTypeId = data.recordTypeId;
            this.recordDisplayName = data.apiName === 'WorkOrder' ? this.safeGet(data, 'fields.WorkOrderNumber.value') : data.apiName === 'ServiceAppointment' ? this.safeGet(data, 'fields.AppointmentNumber.value') : this.safeGet(data, 'fields.NGMCP_Asset_Number__c.value');

            this.computeActiveRecordTypeName();
            this.ready = true;
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
    connectedcallback() {
        console.log('dynamic page recordId', this.recordId);
        console.log('object api', this.objectApiName);
        console.log('recordtype', this.recordTypeName);
    }
    // --- Sections / config ---
    get activeSections() {
        const cfg = this.parsedConfig;
        if (!cfg) return this.defaultSections;
        const sections =
            (cfg[this.activeRecordTypeDevName] ||
                cfg.Default ||
                this.defaultSections);
        return sections.map((sec, idx) => ({
            ...sec,
            key: `${this.activeRecordTypeDevName || 'Default'}-${idx}`
        }));
    }
    get showNoConfig() {
        const cfg = this.parsedConfig;
        // Show message only if user provided cfg but it had no matching sections
        return this.ready && !!cfg && this.activeSections.length === 0;
    }
    handleDownloadFiles() {
        if (!this.recordId) {
            return;
        }
        this.isLoading = true;
        getParentAccountFiles({ workOrderId: this.recordId })
            .then(files => {
                (files || []).forEach(f => {
                    if (f?.Id) {
                        this.downloadFile(f.Id);
                    }
                });
            })
            .catch(error => {
                console.error('Download failed', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    handleSortClick(evt) {
        const sortKey = evt.currentTarget?.dataset?.sortKey; // fieldApiName or '__link__'
        const rlId = evt.currentTarget?.dataset?.rlid;
        if (!sortKey || !rlId) return;
        this.applySort(rlId, sortKey);
    }
    handleSortKeydown(evt) {
        if (evt.key === 'Enter' || evt.key === ' ') {
            evt.preventDefault();
            this.handleSortClick(evt);
        }
    }
    applySort(rlId, sortKey) {
        const lists = [...this.lists];
        const idx = lists.findIndex(l => l.id === rlId);
        if (idx < 0) return;
        const rl = { ...lists[idx] };
        const nextDir = rl.sortBy === sortKey && rl.sortDir === 'asc' ? 'desc' : 'asc';
        rl.sortBy = sortKey;
        rl.sortDir = nextDir;
        const factor = nextDir === 'asc' ? 1 : -1;
        rl.rows = [...rl.rows].sort((a, b) => {
            const av = sortKey === '__link__' ? (a.linkLabel || '') : (a[sortKey] ?? '');
            const bv = sortKey === '__link__' ? (b.linkLabel || '') : (b[sortKey] ?? '');
            return (av > bv ? 1 : av < bv ? -1 : 0) * factor;
        });
        // Recompute zebra classes
        rl.rows = rl.rows.map((row, i) => {
            const base = 'dt-row dt-row--data';
            return { ...row, rowClass: i % 2 === 0 ? `${base} dt-row--even` : `${base} dt-row--odd` };
        });
        lists[idx] = rl;
        this.lists = lists;
    }
    /* ========== Link click -> handler (no navigation) ========== */
    async handleLinkClick(event) {
        event.preventDefault();
        event.stopPropagation();
        const isModifier =
            event.ctrlKey ||
            event.metaKey ||
            event.shiftKey ||
            event.altKey ||
            event.button === 1;
        if (!isModifier) {
            const recordId = event.currentTarget?.dataset?.id;
            try {
                this.objectApiName = await getObjectApiName({ recordId: event.currentTarget?.dataset?.id });
                if (this.objectApiName === 'axsy_forms__Form_Response__c') {
                    const pageRef = {
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: recordId,
                            objectApiName: 'axsy_forms__Form_Response__c',
                            actionName: 'view'
                        }
                    };
                    const url = await this[NavigationMixin.GenerateUrl](pageRef);
                    this.objectApiName = 'WorkOrder';
                    window.open(url, '_blank');
                    return;
                } else {
                    this.selectedRecordId = recordId;
                }
                // TODO: continue your flow here 
            } catch (error) {
            }
        }
    }
    downloadFile(contentVersionId) {
        // Experience Cloud SAFE
        const url = `${basePath}/sfc/servlet.shepherd/version/download/${contentVersionId}`;
        window.open(url, '_self');
    }
    get parsedConfig() {
        if (!this.sectionConfigJson) return null;
        try {
            return JSON.parse(this.sectionConfigJson); // now it's a string → OK
        } catch (e) {
            this.setError({
                message: `Invalid JSON in Section Config: ${e.message}`
            });
            return null;
        }
    }

    /**
      * 1) Discover all related lists for the object’s default layout.
      *    No recordTypeId needed; default layout is used. [ref]
      */
    @wire(getRelatedListsInfo, { parentObjectApiName: '$objectApiName' })
    wiredRelatedLists({ data, error }) {
        if (error) {
            //console.error('[getRelatedListsInfo] error:', JSON.stringify(error));
            this.errorMessage = error?.body?.message || error.message;
            this.loading = false;
            return;
        }
        if (!data) return;

        // Helper: returns true if value contains "history" (case-insensitive)
        const containsHistory = (val) => {
            if (!val || typeof val !== 'string') return false;
            return /history/i.test(val);
        };
        const skipHistoryFilter = (this.objectApiName === 'NGMCP_Request__c');
        const ALLOWED_RELATED_LISTS = [
            'ServiceAppointment',
            'FFA_NGV_Asset__c',
            'axsy_forms__Form_Response__c'
        ];
        const discovered = (data.relatedLists || []).filter(rl => {
            if (!(rl?.relatedListId && rl?.label)) return false;
            // Restrict only to allowed lists
            if (!ALLOWED_RELATED_LISTS.includes(rl.objectApiName)) {
                return false;
            }

            // Existing History filter
            if (!skipHistoryFilter) {
                if (containsHistory(rl.label)) return false;
                if (containsHistory(rl.objectApiName)) return false;
                if (containsHistory(rl.relatedListId)) return false;
            }
            return true;
        });
        this.relatedListIds = discovered.map(rl => rl.relatedListId);

        // const discovered = (data.relatedLists || []).filter(rl => {
        //     if (!(rl?.relatedListId && rl?.label)) return false;

        //     if (!skipHistoryFilter) {
        //         // Apply the original "exclude history" checks
        //         if (containsHistory(rl.label)) return false;
        //         if (containsHistory(rl.objectApiName)) return false;
        //         if (containsHistory(rl.relatedListId)) return false;
        //     }
        //     return true;
        // });

        // this.relatedListIds = discovered.map(rl => rl.relatedListId);

        // seed both label and child object API name
        const seeded = new Map();
        for (const rl of discovered) {
            seeded.set(rl.relatedListId, {
                label: rl.label,
                childObjectApiName: rl.objectApiName // e.g., 'ServiceAppointment'
            });
        }
        this.infoById = seeded;

        if (!this.relatedListIds.length) {
            this.loading = false;
        }
    }

    /**
     * 2) Get metadata (displayColumns, childObjectApiName) for all discovered lists.
     *    Pass the array of 'relatedListNames' (same IDs we collected). [ref]
     */
    // @wire(getRelatedListInfoBatch, {
    //     parentObjectApiName: '$objectApiName',
    //     relatedListNames: '$relatedListIds'
    // })
    // wiredInfoBatch({ data, error }) {
    //     if (error) {
    //         this.errorMessage = error?.body?.message || error.message;
    //         this.loading = false;
    //         return;
    //     }
    //     if (!data) return;
    //     const infoById = new Map(this.infoById);
    //     const params = [];
    //     //console.log('data', JSON.stringify(data));
    //     //console.log('data.results', JSON.stringify(data.results))
    //     (data.results || []).forEach(item => {
    //         const result = item?.result;
    //         console.log('result', JSON.stringify(result));
    //         //if (!result) return;
    //         const relatedListId = result.listReference?.relatedListId;
    //         console.log('relatedlist',JSON.stringify(relatedListId) );
    //         const label = result.label;
    //         const seededChild = infoById.get(relatedListId)?.childObjectApiName;
    //         console.log('seededChild', seededChild);
    //         console.log('label', label);
    //         // console.log('childObjectApiName', childObjectApiName);
    //         const childObjectApiName =
    //             result.childObjectApiName ||
    //             (Array.isArray(result.objectApiNames) ? result.objectApiNames[0] : null) ||
    //             seededChild ||
    //             null;
    //             console.log('childObjectApiName', childObjectApiName);
    //         if (!childObjectApiName) {
    //             console.warn(`No childObjectApiName for ${relatedListId}. Skipping fields build.`);
    //             return;
    //         }
    //         const displayColumns = result.displayColumns || [];
    @wire(getRelatedListInfoBatch, {
        parentObjectApiName: '$objectApiName',
        relatedListNames: '$relatedListIds'
    })
    wiredInfoBatch({ data, error }) {
        if (error) {
            this.errorMessage = error?.body?.message || error.message;
            this.loading = false;
            return;
        }
        if (!data) return;
        const infoById = new Map(this.infoById);
        const params = [];
        (data.results || []).forEach(item => {
            const result = item?.result;
            if (!result) return;
            const relatedListId = result.listReference?.relatedListId;
            const label = result.label;
            const seededChild = infoById.get(relatedListId)?.childObjectApiName;
            const childObjectApiName =
                result.childObjectApiName ||
                (Array.isArray(result.objectApiNames) ? result.objectApiNames[0] : null) ||
                seededChild ||
                null;
            if (!childObjectApiName) {
                return;
            }
            const displayColumns = result.displayColumns || [];
            // Detect History list for Request object
            const containsHistory = v => (typeof v === 'string') && /history/i.test(v);
            const isHistoryForRequest =
                (this.objectApiName === 'NGMCP_Request__c') &&
                (containsHistory(label) || containsHistory(childObjectApiName) || containsHistory(relatedListId));
            let columns;
            let fields;
            if (isHistoryForRequest) {
                // 🔒 Custom columns — NO "Name"
                columns = [
                    { label: 'Date', fieldName: 'date', type: 'text', sortIcon: 'utility:dash', ariaSort: 'none' },
                    { label: 'Field', fieldName: 'field', type: 'text', sortIcon: 'utility:dash', ariaSort: 'none' },
                    { label: 'User', fieldName: 'user', type: 'text', sortIcon: 'utility:dash', ariaSort: 'none' },
                    { label: 'Original Value', fieldName: 'oldValue', type: 'text', sortIcon: 'utility:dash', ariaSort: 'none' },
                    { label: 'New Value', fieldName: 'newValue', type: 'text', sortIcon: 'utility:dash', ariaSort: 'none' }
                ];
                // 🔒 Exact fields we need from UI API, including CreatedBy.Name
                fields = [
                    `${childObjectApiName}.CreatedDate`,
                    `${childObjectApiName}.Field`,
                    `${childObjectApiName}.OldValue`,
                    `${childObjectApiName}.NewValue`,
                    // `${childObjectApiName}.CreatedBy.Name`
                    `${childObjectApiName}.CreatedBy.FirstName`,
                    `${childObjectApiName}.CreatedBy.LastName`
                ];
            }
            else {
                // Non‑history → keep server suggestions
                columns = displayColumns.map(col => ({
                    label: col.label,
                    fieldName: col.fieldApiName,
                    type: 'text',
                    sortIcon: 'utility:dash',
                    ariaSort: 'none'
                }));
                fields = displayColumns.map(col => `${childObjectApiName}.${col.fieldApiName}`);
            }
            // Final safety: if anything with fieldName "Name" slipped in, drop it for History
            if (isHistoryForRequest) {
                columns = columns.filter(c => c.fieldName !== 'Name');
            }
            infoById.set(relatedListId, {
                label: label || infoById.get(relatedListId)?.label || relatedListId,
                childObjectApiName,
                displayColumns,       // keep for other parts if needed
                columns,              // what the grid actually renders
                specialHistory: isHistoryForRequest
            });
            params.push({ relatedListId, fields, pageSize: 50 });
        });
        this.infoById = infoById;
        // this.relatedListParameters = params;
        this.relatedListParameters = [...params];
    }
    @wire(getRelatedListRecordsBatch, {
        parentRecordId: '$recordId',
        relatedListParameters: '$relatedListParameters'
    })
    wiredBatch({ data, error }) {
        // console.error('[getRelatedListRecordsBatch] error:', JSON.stringify(error));
        if (error) {
            this.errorMessage = error?.body?.message || error.message;
            this.loading = false;
            return;
        }
        if (!data) return;
        const resultById = new Map();
        (data.results || []).forEach(r => {
            const rlId = r?.result?.listReference?.relatedListId;
            if (rlId) resultById.set(rlId, r.result);
        });
        this.buildUiListsAsync(resultById)
            .then(uiLists => {
                this.lists = uiLists;
                this.relatedss = uiLists; // ← temporary: keeps your old template path working
                this.loading = false;
            })
            .catch(e => {
                this.errorMessage = e?.message || 'Unable to build related lists.';
                this.loading = false;
            });
    }
    /* ========== BUILD UI (CSS Grid; flexible middle columns) ========== */
    async buildUiListsAsync(resultById) {
        const uiLists = [];
        for (const rlId of this.relatedListIds) {
            const meta = this.infoById.get(rlId) || {};
            const batch = resultById.get(rlId);
            /* ================= GRID TEMPLATE (NO TDZ) ================= */
            const firstMin = Number.isFinite(this.firstColumnMin) ? this.firstColumnMin : 220;
            const middleMins = (meta.columns || []).map((c, i) => {
                const w = this.columnMinWidths?.[i];
                return Number.isFinite(w) ? w : 160;
            });
            const gridTemplateColumns = [
                ...(meta.specialHistory ? [] : [`minmax(${firstMin}px, ${firstMin}px)`]),
                ...middleMins.map(w => `minmax(${w}px, 1fr)`)
            ].join(' ');
            const gridTemplate = `grid-template-columns:${gridTemplateColumns};`;
            /* ================= FILTER COLUMNS ================= */
            const finalColumns = (meta.columns || []).filter(col => {
                if (meta.specialHistory && col.fieldName === 'Name') return false;
                if (meta.specialHistory && col.fieldName === '__link__') return false;
                return true;
            });
            let rows = [];
            let count = 0;
            let errorText;
            if (batch?.records) {
                const isCRMProfile = this.profileName === 'CRM Profile';
                let filteredRecords = batch.records;
                if (meta.childObjectApiName === 'FFA_NGV_Asset__c' && !isCRMProfile && this.profileName) {
                    filteredRecords = batch.records.filter(rec => {
                        const assetType = rec?.fields?.FFA_Asset_Type__c?.value || '';
                        return assetType === 'Meter' || assetType === 'Converter';
                    });
                }
                count = filteredRecords.length;
                rows = filteredRecords.map((rec, rowIndex) => {
                    const getVal = (api) => {
                        const f = rec.fields?.[api];
                        let value = f?.displayValue ?? f?.value ?? '';
                        if (f === 'NGMCP_ADI_expries_on__c' || 'NGMCP_Target_Start__c' || 'NGMCP_Enquiry_start_date__c'
                            || 'NGMCP_Creation_Date__c' || 'NGMCP_Enquiry_target_end_date__c' || 'NGMCP_From_Date__c'
                            || 'NGMCP_To_Date__c ' || 'NGMCP_Request_Date__c ') {
                        }
                        return value;

                    };

                    const row = { Id: rec.id };
                    if (meta.specialHistory) {
                        // HISTORY ROW
                        row.date = getVal('CreatedDate');
                        row.field = getVal('Field');
                        const firstName =
                            rec?.fields?.CreatedBy?.value?.fields?.FirstName?.value || '';
                        const lastName =
                            rec?.fields?.CreatedBy?.value?.fields?.LastName?.value || '';
                        if (!rec?.fields?.CreatedBy?.value) {
                        }

                        row.user = (firstName || lastName)
                            ? `${firstName} ${lastName}`.trim()
                            : 'System';
                        row.oldValue = getVal('OldValue');
                        row.newValue = getVal('NewValue');
                        row.cells = finalColumns.map(col => ({
                            api: col.fieldName,
                            label: col.label,
                            value: row[col.fieldName]
                        }));
                    } else {
                        // NON-HISTORY ROW
                        finalColumns.forEach(col => {
                            row[col.fieldName] = getVal(col.fieldName);
                        });
                        row.linkLabel =
                            getVal('Name') || row.AppointmentNumber || row.WorkOrderNumber;
                        row.cells = finalColumns.map(col => ({
                            api: col.fieldName,
                            label: col.label,
                            value: row[col.fieldName]
                        }));
                    }
                    const base = 'dt-row dt-row--data';
                    row.rowClass = rowIndex % 2 === 0
                        ? `${base} dt-row--even`
                        : `${base} dt-row--odd`;
                    return row;
                });
                if (!meta.specialHistory) {
                    rows = await this.addRecordUrls(rows, meta.childObjectApiName);
                }
            } else if (batch?.error) {
                errorText = batch.error?.body?.message || batch.error?.message;
            }
            uiLists.push({
                id: rlId,
                label: meta.label || rlId,
                specialHistory: meta.specialHistory,
                columns: finalColumns,
                rows,
                count,
                error: errorText,
                gridTemplate,
                firstColumnAriaSort: 'none'
            });
        }
        return uiLists;
    }

    async addRecordUrls(rows, childObjectApiName) {
        if (!rows || !rows.length) {
            return rows;
        }
        const isFormResponse = childObjectApiName === 'axsy_forms__Form_Response__c';
        const updated = [];
        for (const row of rows) {
            try {
                // Build standard record page reference
                const pageRef = {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        actionName: 'view',
                        ...(childObjectApiName
                            ? { objectApiName: childObjectApiName }
                            : {})
                    }
                };
                // Generate URL via NavigationMixin
                const url = await this[NavigationMixin.GenerateUrl](pageRef);
                row.recordUrl = url || '#';
                if (isFormResponse) {
                    row.target = '_blank';
                    row.isFormResponse = true;
                } else {
                    row.target = '_self';
                    row.isFormResponse = false;
                }
            } catch (e) {
                // Safe fallback (Experience Cloud friendly)
                row.recordUrl = childObjectApiName
                    ? `${basePath}/lightning/r/${childObjectApiName}/${row.Id}/view`
                    : `/${row.Id}`;
            }
            updated.push(row);
        }
        return updated;
    }

    // Default section shown when no JSON config is supplied
    get defaultSections() {
        return [
            {
                label: 'Details',
                fields: [
                    'NGMCP_MPRN__c',
                    'NGMCP_Supplier_Id__c',
                    'CreatedById',
                    'CreatedDate',
                    'FFA_Sender_ID__c'
                ]
            }
        ];
    }
    // --- Helpers ---
    computeActiveRecordTypeName() {
        if (!this.recordTypeId || !this.objectInfos) return;
        const rtInfo =
            this.objectInfos.recordTypeInfos[this.recordTypeId];
        if (rtInfo) {
            this.activeRecordTypeDevName = rtInfo.developerName;
        }
    }
    finishIfReady() {
        // Stop spinner once we have object info and we attempted record load (data or error)
        const attemptedRecord =
            this.recordTypeId !== undefined || this.error !== null;
        if (this.objectInfos && attemptedRecord) {
            this.loading = false;
            this.ready = !this.error;
        }
    }
    setError(error) {
        this.error = error;
        this.loading = false;
        this.ready = false;
        this.errorMessage =
            error?.body?.message ||
            error?.message ||
            'Unknown error';
    }
    safeGet(obj, path) {
        return path
            .split('.')
            .reduce(
                (acc, key) =>
                    acc && acc[key] != null ? acc[key] : undefined,
                obj
            );
    }
    handleBackButton() {
        const payload = {
            recordId: this.oldRecordId,
            recordTypeName: this.oldRecordTypeName
        };
        this.dispatchEvent(
            new CustomEvent('dynamicbackbutton', {
                detail: payload,
                bubbles: true,
                composed: true
            })
        );
    }
}