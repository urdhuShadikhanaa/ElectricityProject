import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {
    getRelatedListsInfo,
    getRelatedListInfoBatch,
    getRelatedListRecordsBatch
} from 'lightning/uiRelatedListApi';
import buildJson from '@salesforce/apex/NGMCP_DynamicPageConfigServiceController.buildSectionConfigJsonByRtName';
import getObjectApiName from '@salesforce/apex/NGMCP_DynamicPageConfigServiceController.getObjectApiName';
import FFA_SENDER from '@salesforce/schema/WorkOrder.FFA_Sender_ID__c';
//import getStatusHistory from '@salesforce/apex/NGMCP_DynamicPageConfigServiceController.getStatusHistory';
// code from shreya
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitCancelJob from "@salesforce/apex/NGMCP_ReplanCancelHandler.submitCancelJob";
import submitAcceptRejectQuotation from "@salesforce/apex/NGMCP_ReplanCancelHandler.submitAcceptRejectQuotation";
import getRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.getRequest";
import getHolidays from '@salesforce/apex/NGMCP_HolidaysService.getHolidaysBetween';
import USER_ID from '@salesforce/user/Id';
const FIELDS = ['WorkOrder.FFA_Sender_ID__c'];
import updateNSRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.updateNSRequest";
import getSA from "@salesforce/apex/NGMCP_ReplanCancelHandler.getSA";
import uploadAndLinkFileToRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.uploadAndLinkFileToRequest";
import getWorkOrderDetails from '@salesforce/apex/NGMCPSiteInformationController.getWorkOrderDetails';
import updateSiteDetails from '@salesforce/apex/NGMCPSiteInformationController.updateSiteDetails';
import { CloseActionScreenEvent } from 'lightning/actions';
import REQUEST_TYPE from '@salesforce/schema/NGMCP_Request__c.RecordType.Name';
import STATUS from '@salesforce/schema/NGMCP_Request__c.NGMCP_Callout_Status__c';
import callMaximoADIAPI from "@salesforce/apex/NGMCP_RequestController.callMaximoADIAPI";
import callMaximoSupportInfoAPI from "@salesforce/apex/NGMCP_RequestController.callMaximoSupportInfoAPI";
import callMaximoReopenAPI from "@salesforce/apex/NGMCP_RequestController.callMaximoReopenAPI";
import sendSupportInfoEmail from "@salesforce/apex/NGMCP_RequestController.sendSupportInfoEmail";
import callViewCompletionDetailsAPI from "@salesforce/apex/NGMCP_ReplanCancelHandler.callViewCompletionDetailsAPI";
import uploadFiles from '@salesforce/apex/NGMCP_RequestObjectClass.uploadFiles';
import uploadtoMAximoSystem from '@salesforce/apex/NGMCP_RequestObjectClass.uploadDocumentToMaximo';
import basePath from '@salesforce/community/basePath';
import getParentAccountFiles from "@salesforce/apex/NGMCP_RequestSearchController.getParentAccountFiles";
import cancelAMRRequest from "@salesforce/apex/NGMCP_AMRIntegrationClass.cancelAMRRequest";
import getNotesAndFiles from '@salesforce/apex/NGMCP_DynamicPageConfigServiceController.getNotesAndFiles';

const USER_FIELDS = ['User.Name', 'User.Email', 'User.Profile.Name'];
const MAX_FILE_SIZE = 4 * 1024 * 1024;
const MAX_TOTAL_ATTACHMENT_SIZE = 4 * 1024 * 1024;
const MAX_FILE_SIZE_MB = 4;
export default class DynamicSections extends NavigationMixin(LightningElement) {
    @api recordId;
    @track wororderNumber;
    @api homecontainerFlag;
    @api showdownloadRams;
    @api rams;
    @api objectApiName;
    @api recordTypeName;
    @api NGMCP_Site_contact_details__c;
    @track selectedRecordId;
    @api rl;
    @track ticketId;
    @track historyData;
    @track error;
    @track statuslist = [];
    @track loading = true;
    @track errorMessage;
    @track siteId;
    @track title = '';
    @track nameVal = '';
    @track phone = '';
    @track access = '';
    @track showActionButton = false;
    @track Replanerror = false;
    @track cancelerror = false;
    @track showFormModal = false;
    @track showPopup = false;
    @track popupTitle = '';
    @track popupMessage = '';
    @track ReplanRequest = '';
    @track CancelRequest = '';
    @track isLoading = false;
    @track reports = false;
    closeOnOk = false;
    @api reportContainerFlag;
    @api firstColumnMin = 220;
    @api columnMinWidths = [];
    @api iconName = 'standard:related_list';
    @track isQuotationModel = false;
    @track relatedListIds = [];
    @track infoBatchResultsById = new Map();
    @track relatedListParameters;
    @track lists = [];
    recordDisplayName;
    recordTypeId;
    activeRecordTypeDevName;
    objectInfos;
    ready = false;
    error = null;
    showCompletion = false;
    showquotation = false;
    showAcceptReject = false;
    showReplan = false;
    showCancel = false;
    showCancelConfirm = false;
    isAMRFLow = false;
    showSuccessModal = false;
    showdisplayname;
    @track amrRequestId = '';
    files = [];
    totalCount = 0;

    // 23 march change enquiry
    @track showDatePicker = false;
    @track datePickerKey = 0;
    @track holidaysLoaded = false;
    @track isEnquiry = false;
    @track enquiryWorkingOffset = null;
    @track datepickerWrFlag = false;
    @track profileName;
    // 23 march end enquiry
    @api sectionConfigJson;
    @wire(buildJson, { recordTypeName: '$recordTypeName' })
    wiredJson({ data, error }) {
        if (data) {
            this.sectionConfigJson = data;
        } else if (error) {
            console.error('Failed to load CMT config:', error?.body?.message || error?.message);
        }
    }

    @wire(getNotesAndFiles, { recordId: '$recordId' })
    wiredFiles({ data }) {
        if (data) {
            const cleanedBasePath = basePath.split('/').slice(0, 2).join('/');
            this.files = data.map(f => ({
                ContentDocumentId: f.ContentDocumentId,
                Title: f.ContentDocument.Title,
                FileType: f.ContentDocument.FileType,
                CreatedBy: f.ContentDocument.CreatedBy?.Name,
                downloadUrl: `${window.location.origin}${cleanedBasePath}/sfc/servlet.shepherd/version/download/${f.ContentDocument.LatestPublishedVersionId}`

            }));
            this.totalCount = this.files.length;
        }
    }


    @wire(getRecord, {
        recordId: '$recordId',
        layoutTypes: ['Full'],
        modes: ['View']
    })
    wiredRecord({ data, error }) {
        if (error) {
            this.setError(error);
            return;
        }
        if (data) {
            if (!this.objectApiName && data.apiName) {
                this.objectApiName = data.apiName;
            }
            this.recordTypeId = data.recordTypeId;
            this.recordDisplayName = this.safeGet(data, 'fields.Name.value') || data.apiName;
            if (data.apiName === 'NGMCP_Request__c') {
                this.ticketId = this.safeGet(data, 'fields.NGMCP_SR_Ticket__c.value');
            } else if (data.apiName === 'WorkOrder') {
                this.wororderNumber = this.safeGet(data, 'fields.WorkOrderNumber.value');
            }
            this.computeActiveRecordTypeName();
            this.ready = true;
            this.showdisplayname = this.recordDisplayName && !this.wororderNumber;
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
    computeActiveRecordTypeName() {
        if (!this.recordTypeId || !this.objectInfos) return;
        const rtInfo = this.objectInfos.recordTypeInfos[this.recordTypeId];
        if (rtInfo) {
            this.activeRecordTypeDevName = rtInfo.developerName;
        }
    }
    safeGet(obj, path) {
        return path.split('.').reduce((acc, key) => (acc && acc[key] != null ? acc[key] : undefined), obj);
    }
    get activeSections() {
        const cfg = this.parsedConfig;
        if (!cfg) return this.defaultSections;
        const sections = (cfg[this.activeRecordTypeDevName] || cfg.Default || this.defaultSections);
        return sections.map((sec, idx) => ({ ...sec, key: `${this.activeRecordTypeDevName || 'Default'}-${idx}` }));
    }
    get parsedConfig() {
        if (!this.sectionConfigJson) return null;
        try {
            return JSON.parse(this.sectionConfigJson); // now it's a string → OK
        } catch (e) {
            this.setError({ message: `Invalid JSON in Section Config: ${e.message}` });
            return null;
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
    finishIfReady() {
        // Stop spinner once we have object info and we attempted record load (data or error)
        const attemptedRecord = this.recordTypeId !== undefined || this.error !== null;
        if (this.objectInfos && attemptedRecord) {
            this.loading = false;
            this.ready = !this.error;
        }
    }
    /**
     * 1) Discover all related lists for the object’s default layout.
     *    No recordTypeId needed; default layout is used. [ref]
     */
    @wire(getRelatedListsInfo, { parentObjectApiName: '$objectApiName' })
    wiredRelatedLists({ data, error }) {
        if (error) {
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
        // If parent is NGMCP_Request__c, DO NOT filter out History
        const skipHistoryFilter = (this.objectApiName === 'NGMCP_Request__c');
        const discovered = (data.relatedLists || []).filter(rl => {
            if (!(rl?.relatedListId && rl?.label)) return false;
            if (!skipHistoryFilter) {
                // Apply the original "exclude history" checks
                if (containsHistory(rl.label)) return false;
                if (containsHistory(rl.objectApiName)) return false;
                if (containsHistory(rl.relatedListId)) return false;
            }
            return true;
        });
        this.relatedListIds = discovered.map(rl => rl.relatedListId);
        const seeded = new Map();
        for (const rl of discovered) {
            seeded.set(rl.relatedListId, {
                label: rl.label,
                childObjectApiName: rl.objectApiName
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
                console.warn(`No childObjectApiName for ${relatedListId}. Skipping fields build.`);
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
                columns = [
                    { label: 'Date', fieldName: 'date', type: 'text', sortIcon: 'utility:dash', ariaSort: 'none' },
                    { label: 'Field', fieldName: 'field', type: 'text', sortIcon: 'utility:dash', ariaSort: 'none' },
                    { label: 'User', fieldName: 'user', type: 'text', sortIcon: 'utility:dash', ariaSort: 'none' },
                    { label: 'Original Value', fieldName: 'oldValue', type: 'text', sortIcon: 'utility:dash', ariaSort: 'none' },
                    { label: 'New Value', fieldName: 'newValue', type: 'text', sortIcon: 'utility:dash', ariaSort: 'none' }
                ];
                fields = [
                    `${childObjectApiName}.CreatedDate`,
                    `${childObjectApiName}.Field`,
                    `${childObjectApiName}.OldValue`,
                    `${childObjectApiName}.NewValue`,
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
                displayColumns,
                columns,
                specialHistory: isHistoryForRequest
            });
            params.push({ relatedListId, fields, pageSize: 50 });
        });
        this.infoById = infoById;
        this.relatedListParameters = params;
    }
    @wire(getRelatedListRecordsBatch, {
        parentRecordId: '$recordId',
        relatedListParameters: '$relatedListParameters'
    })
    wiredBatch({ data, error }) {
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
                        if (f === 'NGMCP_Resolution_Date__c') {
                            value = this.normalizeToDDMMYYYY(value);
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
                        // Optional: log when CreatedBy is missing (helps debugging API shape)
                        if (!rec?.fields?.CreatedBy?.value) {
                            console.warn(
                                '[HistoryRow] Missing CreatedBy value | rlId=%s rowIndex=%d recId=%s | raw CreatedBy=',
                                rlId,
                                rowIndex,
                                rec?.id,
                                rec?.fields?.CreatedBy
                            );
                        }
                        row.user = (firstName || lastName)
                            ? `${firstName} ${lastName}`.trim()
                            : 'System';
                        // row.user     =
                        //     rec?.fields?.CreatedBy?.value?.fields?.FirstName?.value ||
                        //     'System';
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
        if (!Array.isArray(rows) || rows.length === 0) {
            return rows || [];
        }
        const isFormResponse = childObjectApiName === 'axsy_forms__Form_Response__c';
        const updated = [];
        for (const row of rows) {
            try {
                const pageRef = {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        actionName: 'view',
                        ...(childObjectApiName ? { objectApiName: childObjectApiName } : {})
                    }
                };
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
                row.recordUrl = childObjectApiName && childObjectApiName !== FORM_RESPONSE_OBJECT
                    ? `${basePath}/lightning/r/${childObjectApiName}/${row.Id}/view`
                    : `/${row.Id}`;
            }

            updated.push(row);
        }
        return updated;
    }

    /* ========== Sorting (optional) ========== */
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
    // Shreya code
    @track isReplanModalOpen = false;
    @track isCancelModalOpen = false;
    action;
    requestid;
    request;
    status;
    @track isModalOpen = false;
    @track reOpenAdditionalInfoFlag = false;
    @track reOpenAdditionalInfoMessage = '';
    @track showProvideAdditionalButton = false;
    @track showProvideSupportingButton = false;
    @track showReopenQueryButton = false;
    @track modalHeader = "";
    @track comments = "";
    actionType = "";
    selectedSlot = '';
    selectedSlotAfterSwtich = '';
    selectedDate = '';
    appointmentOptions = [];
    holidays = [];
    userId = USER_ID;
    email;
    @track user = {};
    reason = '';
    //mainFlag = true;
    appointmentDateError = 'Please select a date';
    appointmentSlotError = 'Please select a slot';
    reasonError = 'Please enter a reason';
    @track dateFlag = false;
    @track slotFlag = false;
    @track reasonFlag = false;
    @track acceptRejectFlag = false;
    quotationStatus = '';
    quotationStatusToDisplay = '';
    commentError = 'Please enter comment to proceed';
    comment = '';
    @track commentFlag = false;
    @track isAccept = false;
    acceptedFormats = ['.pdf', '.png', '.jpg', '.docx', '.xlsx'];
    @track cancelChargeFlag = false;
    @track cancelInitialFlag = false;
    @track cancelReasonFlag = false;
    @track replanInitialFlag = false;
    @track replanReasonFlag = false
    @track replanCancelMessage = '';
    @track replanCancelMessageFlag = false;
    @track quotationMessage = '';
    @track quotationMessageFlag = false;
    @track showReasonFlag = false;
    @track showCommentFlag = false;
    @track acceptRejectInitialFlag = false;
    @track acceptRejectCommentFlag = false;
    @track disableSubmit = false;
    @track filesToUpload = [];
    completionDetails = [];
    @track isCompletionModalOpen = false;
    commentLabel = '';
    commentPlaceholder = '';
    @track uploadedFiles = []; // for UI display
    uploadedFilePayload = []; // ready for API call
    @track fileError = "";
    residentialSlots = [{
        code: 'S1',
        timeframe: '08:00 - 11:00(S1)'
    }, {
        code: 'S2',
        timeframe: '10:00 - 13:00(S2)'
    }, {
        code: 'S3',
        timeframe: '12:00 - 15:00(S3)'
    }, {
        code: 'S4',
        timeframe: '14:00 - 17:00(S4)'
    }, {
        code: 'S5',
        timeframe: '16:00 - 19:00(S5)'
    }, {
        code: 'S6',
        timeframe: '18:00 - 21:00(S6)'
    }];
    commercialSlots = [{
        code: 'S1',
        timeframe: '08:00 - 12:00(S1)'
    }, {
        code: 'S2',
        timeframe: '10:00 - 14:00(S2)'
    }, {
        code: 'S3',
        timeframe: '12:00 - 16:00(S3)'
    }, {
        code: 'S4',
        timeframe: '14:00 - 18:00(S4)'
    }, {
        code: 'S5',
        timeframe: '16:00 - 20:00(S5)'
    }];
    // --- Residential (Weekday) Slots ---
    residentialWeekdaySlots = [
        { label: '08:00 - 11:00(S1)', value: 'S1' },
        { label: '10:00 - 13:00(S2)', value: 'S2' },
        { label: '12:00 - 15:00(S3)', value: 'S3' },
        { label: '14:00 - 17:00(S4)', value: 'S4' },
        { label: '16:00 - 19:00(S4)', value: 'S5' },
        { label: '18:00 - 21:00(S6)', value: 'S6' }
    ];
    // --- Commercial & Residential (Weekend / Holiday) Slots ---
    commercialAndWeekendSlots = [
        { label: '08:00 - 12:00(S1)', value: 'S1' },
        { label: '10:00 - 14:00(S2)', value: 'S2' },
        { label: '12:00 - 16:00(S3)', value: 'S3' },
        { label: '14:00 - 18:00(S4)', value: 'S4' },
        { label: '16:00 - 20:00(S5)', value: 'S5' }
    ];
    columnsToExport = [
        { label: 'Notification Number', field: 'ticketid' },
        { label: 'Notification status', field: 'status' },
        { label: 'Job type', field: 'jobtype' },
        { label: 'Job Start/End date', field: 'statusdate' },
        { label: 'Asset Class Code', field: 'assetclass' },
        { label: 'Data Code', field: 'datacode' },
        { label: 'Meter Status Code', field: 'meterstatus' },
        { label: 'Conversion Factor', field: 'conversion' },
        { label: 'Installed on Stream', field: 'is' },
        { label: 'Model name', field: 'modelname' },
        { label: 'Manufacturer Serial Number', field: 'serialno' },
        { label: 'Manufacturer Code', field: 'manufcode' },
        { label: 'Manufacturer Year', field: 'manufyear' },
        { label: 'Meter Type', field: 'metertype' },
        { label: 'Meter Imperial Indicator', field: 'metrictype' },
        { label: 'Meter Mechanism/Payment Type', field: 'paytype' },
        { label: 'Meter Num Dials', field: 'dialcount' },
        { label: 'Qmax', field: 'qmax' },
        { label: 'Meter Location Code', field: 'loccode' },
        { label: 'Location Notes', field: 'locnotes' },
        { label: 'Meter Reading Date', field: 'meterreadingdate' },
        { label: 'Meter Reading', field: 'meterreading' },
        { label: 'Converter Read as Converted (as found)', field: 'confnd' },
        { label: 'Converter Read as Unconverted (as found)', field: 'unconfnd' },
        { label: 'Converter Read as Converted (as left)', field: 'conlft' },
        { label: 'Converter Read as Unconverted (as left)', field: 'unconlft' }
    ];
    @wire(getRecord, { recordId: '$userId', fields: USER_FIELDS })
    userRecord({ error, data }) {
        if (data) {
            this.email = data.fields.Email.value;
            this.user = data.fields;
            this.profileName = data.fields.Profile.value.fields.Name.value;
        }
    }
    @wire(getRecord, { recordId: '$recordId', fields: [REQUEST_TYPE, STATUS] })
    recordHandler({ data }) {
        if (data) {
            this.requestType = data.fields.Request_Type__c.value;
        }
    }
    handleReplanCancelJob() {
        this.replanCancelFlag = true;
        //this.mainFlag = false;
    }
    handleCancelJob() {
        if (this.isAMRFLow) {
            this.isCancelModalOpen = true;
            this.cancelInitialFlag = true;
            this.cancelReasonFlag = false;
        }
        if (this.statuslist || (!this.statuslist && this.isAMRFLow)) {
            this.isCancelModalOpen = true;
            this.isReplanModalOpen = false;
            this.cancelInitialFlag = true;
            this.cancelChargeFlag = false;
            this.cancelReasonFlag = false;
            if (this.CancelRequest == 'Cancel') {
                this.action = 'CANCELLED';
            } else if (this.CancelRequest == 'Request Cancel') {
                this.action = 'REQUESTED CANCEL';
            }
            //this.action = 'CANCELLED';
            this.cancelerror = false;
            // this.isCancelModalOpen = true;
        } else {
            this.cancelerror = true;
        }
    }

    calculateEnquiryMinDate() {
        let current = new Date();
        current.setHours(0, 0, 0, 0);

        let addedDays = 0;

        while (addedDays < 7) {
            current.setDate(current.getDate() + 1);

            const day = current.getDay();
            const iso = current.toISOString().split('T')[0];

            const isWeekend = day === 0 || day === 6;
            const isHoliday = this.holidays?.includes(iso);

            if (!isWeekend && !isHoliday) {
                addedDays++;
            }
        }

        return current.toISOString().split('T')[0];
    }
    handleReplanJob() {
        if (this.statuslist) {
            this.Replanerror = false;
            this.isReplanModalOpen = true;
            this.isCancelModalOpen = false;
            this.replanInitialFlag = true;
            this.replanReasonFlag = false;
            if (this.ReplanRequest == 'Replan') {
                this.action = 'REPLAN';
            } else if (this.ReplanRequest == 'Request Replan') {
                this.action = 'REQUESTED REPLAN';
            }
            this.isCancelModalOpen = true;
        } else {
            this.Replanerror = true;
        }
    }
    closeCancelModal() {
        this.isCancelModalOpen = false;
        this.reason = '';
        this.dateFlag = false;
        this.slotFlag = false;
        this.reasonFlag = false;
    }
    closeReplanerror() {
        this.Replanerror = false;
        this.cancelerror = false;
    }
    closeReplanModal() {
        this.isReplanModalOpen = false;
        this.replanInitialFlag = false;
        this.isCancelModalOpen = false;
        this.selectedDate = '';
        this.selectedSlot = '';
        this.reason = '';
        this.dateFlag = false;
        this.slotFlag = false;
        this.reasonFlag = false;
    }
    connectedCallback() {
        this.loadDetails();
        getRequest({ requestid: this.recordId })
            .then(result => {
                this.request = result;
                // 11 march sla date
                // ===============================
                // CWR SLA-based appointment logic
                // ===============================
                if (this.recordTypeName === 'Customer Work Request') {
                    this.CWR = true;
                    this.status = this.request.NGMCP_Industry__c == 'D' ? 'Residential' : this.request.NGMCP_Industry__c == 'I' ? 'Commercial' : '';
                    const today = new Date();
                    today.setHours(0, 0, 0, 0);

                    let minDate = null;

                    if (this.request.NGMCP_SLA_Date__c) {
                        const slaDate = new Date(this.request.NGMCP_SLA_Date__c);
                        slaDate.setHours(0, 0, 0, 0);

                        if (slaDate > today) {
                            minDate = slaDate;
                        }
                    }
                    // If SLA date is null or in past → next working day
                    if (!minDate) {
                        minDate = new Date(today);
                        minDate.setDate(minDate.getDate() + 1);

                        // Skip weekends
                        while (minDate.getDay() === 0 || minDate.getDay() === 6) {
                            minDate.setDate(minDate.getDate() + 1);
                        }
                    }

                    // ISO yyyy-MM-dd (required by datepicker)
                    this.minAppointmentDate = minDate.toISOString().split('T')[0];
                }


                else {
                    this.CWR = false;
                    this.minAppointmentDate = null;
                    if (this.recordTypeName == 'Urgent Work Request') {
                        this.status = this.request.NGMCP_Industry__c == 'D' ? 'Residential' : this.request.NGMCP_Industry__c == 'I' ? 'Commercial' : '';
                    }
                    else {
                        this.status = this.request.NGMCP_Market_Sector_Code__c == 'D' ? 'Residential' : this.request.NGMCP_Market_Sector_Code__c == 'I' ? 'Commercial' : '';
                    }
                }
                // 11 march end sla date
                // --- Enquiry (D+5 working days) rule ---


                const rtDevName = this.request?.RecordType?.DeveloperName;

                // Reset defaults
                this.minAppointmentDate = null;
                this.datepickerWrFlag = false;
                this.enquiryWorkingOffset = null;

                // ✅ ENQUIRY REPLAN FIX (FINAL)
                if (rtDevName === 'NGMCP_Enquiry') {
                    this.datepickerWrFlag = true; // blocks weekends & holidays
                    this.minAppointmentDate = this.calculateEnquiryMinDate();
                }

                // ✅ CWR (existing SLA logic untouched)
                if (rtDevName === 'NGMCP_Customer_Work_Request') {
                    this.datepickerWrFlag = true;
                }
                if (this.recordTypeName === 'AMR' && this.request.NGMCP_Status__c === 'Submitted') {
                    this.isAMRFLow = true;
                    //this.setButtonVisibility(); 
                } else {
                    this.isAMRFLow = false;
                    //this.fetchSA(); // Existing flow
                }
                this.fetchSA();
            })
            .catch(error => {
                this.request = null;
            });
    }

    fetchSA() {
        getSA({ requestid: this.recordId })
            .then(result => {
                this.statuslist = result;
                this.setButtonVisibility();
            })
            .catch(error => {
                this.statuslist = null;
            });
    }
    handleYes() {
        this.isLoading = true;
        if ((this.action == 'REPLAN' || this.action == 'REQUESTED REPLAN') && (this.selectedDate == '' || this.selectedDate == null || this.selectedDate == undefined)) {
            this.dateFlag = true;
        } else {
            this.dateFlag = false;
        }
        if ((this.action == 'REPLAN' || this.action == 'REQUESTED REPLAN') && (this.selectedSlot == '' || this.selectedSlot == null || this.selectedSlot == undefined)) {
            this.slotFlag = true;
        } else {
            this.slotFlag = false;
        }
        if (this.request.NGMCP_Non_Standard__c == true && (this.reason == '' || this.reason == null || this.reason == undefined)) {
            this.reasonFlag = true;
        } else {
            this.reasonFlag = false;
        }
        if (((this.action == 'CANCELLED' || this.action == 'REQUESTED CANCEL') && !this.reasonFlag) ||
            ((this.action == 'REPLAN' || this.action == 'REQUESTED REPLAN') && !this.reasonFlag && !this.dateFlag && !this.slotFlag)) {
            const payload = {
                ticketuid: this.request.NGMCP_Ticketuid__c,
                ticketid: this.request.NGMCP_SR_Ticket__c,
                ngme_time: this.selectedSlotAfterSwtich,
                target1start: this.selectedDate,
                action: this.action,
                reason: this.reason
            };
            if (this.action == 'CANCELLED' || this.action == 'REQUESTED CANCEL') {
                payload.ngme_cancel = this.email;
            }
            if (this.action == 'REPLAN' || this.action == 'REQUESTED REPLAN') {
                payload.ngme_replannedby = this.email;
            }
            if (this.ReplanRequest == 'Request Replan' || this.CancelRequest == 'Request Cancel') {
                updateNSRequest({
                    requestBody: JSON.stringify(payload), requestId: this.recordId,
                    ticketuid: this.request.NGMCP_Ticketuid__c, reportedEmail: this.email
                })
                    .then(result => {
                        this.isCancelModalOpen = false;
                        this.isReplanModalOpen = false;
                        this.selectedDate = '';
                        this.selectedSlot = '';
                        this.reason = '';
                        this.dateFlag = false;
                        this.slotFlag = false;
                        this.reasonFlag = false;
                        if (this.action == 'CANCELLED') {
                            this.replanCancelMessage = 'Job Cancelled Successfully';
                        }
                        else if (this.action == 'REQUESTED CANCEL') {
                            this.replanCancelMessage = 'Cancellation Request Submitted Successfully';
                        }
                        else if (this.action == 'REPLAN') {
                            this.replanCancelMessage = 'Job Replanned Successfully';
                        }
                        else if (this.action == 'REQUESTED REPLAN') {
                            this.replanCancelMessage = 'Replan Request Submitted Successfully';
                        }
                        this.replanCancelMessageFlag = true;
                        this.isLoading = false;
                    })
                    .catch(error => {
                        if (this.action == 'CANCELLED' || this.action == 'REQUESTED CANCEL') {
                            this.replanCancelMessage = 'Error occoured while cancelling the job ';
                        } else {
                            this.replanCancelMessage = 'Error occoured while replanning the job ';
                        }
                        this.replanCancelMessageFlag = true;
                        this.isLoading = false;
                    });
            }
            else if (this.ReplanRequest == 'Replan' || this.CancelRequest == 'Cancel') {
                submitCancelJob({
                    requestBody: JSON.stringify(payload), requestId: this.recordId,
                    ticketuid: this.request.NGMCP_Ticketuid__c, reportedEmail: this.email
                })
                    .then(result => {
                        this.isCancelModalOpen = false;
                        this.isReplanModalOpen = false;
                        this.selectedDate = '';
                        this.selectedSlot = '';
                        this.reason = '';
                        this.dateFlag = false;
                        this.slotFlag = false;
                        this.reasonFlag = false;
                        if (this.action == 'CANCELLED') {
                            this.replanCancelMessage = 'Job Cancelled Successfully';
                        }
                        else if (this.action == 'REQUESTED CANCEL') {
                            this.replanCancelMessage = 'Cancellation Request Submitted Successfully';
                        }
                        else if (this.action == 'REPLAN') {
                            this.replanCancelMessage = 'Job Replanned Successfully';
                        }
                        else if (this.action == 'REQUESTED REPLAN') {
                            this.replanCancelMessage = 'Replan Request Submitted Successfully';
                        }
                        this.replanCancelMessageFlag = true;
                        this.isLoading = false;
                    })
                    .catch(error => {
                        if (this.action == 'CANCELLED' || this.action == 'REQUESTED CANCEL') {
                            this.replanCancelMessage = 'Error occoured while cancelling the job ';
                        } else {
                            this.replanCancelMessage = 'Error occoured while replanning the job ';
                        }
                        this.replanCancelMessageFlag = true;
                        //could be removed 
                        this.isCancelModalOpen = false;
                        this.isReplanModalOpen = false;
                        this.selectedDate = '';
                        this.selectedSlot = '';
                        this.reason = '';
                        this.dateFlag = false;
                        this.slotFlag = false;
                        this.reasonFlag = false;
                        this.isLoading = false;
                    });
            }
        }
    }
    handleSlotChange(event) {
        this.selectedSlot = event.detail.value;
        this.selectedSlotAfterSwtich = this.status == 'Commercial' ? this.handleCommercialTime(event.detail.value) : this.handleResidentialTime(event.detail.value);
        if (this.selectedSlotAfterSwtich == null || this.selectedSlotAfterSwtich == '' || this.selectedSlotAfterSwtich == undefined) {
            this.selectedSlotAfterSwtich = event.detail.value;
        }
        this.slotFlag = false;
    }
    handleDateChange(event) {
        this.dateFlag = false;
        const selectedDate = event.detail.date;
        this.selectedDate = selectedDate;
        this.updateAppointmentSlots();
    }
    updateAppointmentSlots() {
        if (!this.selectedDate || !this.status) {
            this.appointmentOptions = [];
            return;
        }

        // --- Enquiry: use Technical Query screen slots uniformly ---
        if (this.recordTypeName === 'Enquiry') {
            this.appointmentOptions = [
                { label: '08:00 - 17:00 (AT)', value: '08:00 - 17:00' },
                { label: '08:00 - 13:00 (AM)', value: '08:00 - 13:00' },
                { label: '12:00 - 20:00 (PM)', value: '12:00 - 20:00' }
            ]; // same set used in Technical Query
            return;
        }

        if (
            this.recordTypeName == 'Customer Work Request' &&
            this.request?.NGMCP_Non_Standard__c == false &&
            this.request?.NGMCP_MIcro_Buisness__c == 'Yes' &&
            this.status == 'Commercial'

        ) {
            this.appointmentOptions = [
                { label: '08:00 - 12:00 (AM)', value: '08:00 - 12:00' },
                { label: '12:00 - 16:00 (PM)', value: '12:00 - 16:00' }
            ];
            return; // 
        }
        if (
            this.recordTypeName == 'Customer Work Request' &&
            this.request?.NGMCP_Non_Standard__c == false &&
            this.request?.NGMCP_MIcro_Buisness__c == 'No' &&
            this.status == 'Commercial'

        ) {
            this.appointmentOptions = [
                { label: '08:00 - 20:00 (AT)', value: '08:00 - 20:00' },
                { label: '08:00 - 13:00 (AM)', value: '08:00 - 13:00' },
                { label: '12:00 - 20:00 (PM)', value: '12:00 - 20:00' }
            ];
            return; // 
        }
        if (
            this.recordTypeName == 'Customer Work Request' &&
            this.request?.NGMCP_Non_Standard__c == false &&
            this.status == 'Residential'

        ) {
            this.appointmentOptions = [
                { label: '08:00 - 20:00 (AT)', value: '08:00 - 20:00' },
                { label: '08:00 - 12:00 (AM)', value: '08:00 - 12:00' },
                { label: '12:00 - 16:00 (PM)', value: '12:00 - 16:00' },
                { label: '08:00 - 10:00 (S1)', value: '08:00 - 10:00' },
                { label: '10:00 - 12:00 (S2)', value: '10:00 - 12:00' },
                { label: '12:00 - 14:00 (S3)', value: '12:00 - 14:00' },
                { label: '14:00 - 16:00 (S4)', value: '14:00 - 16:00' },
                { label: '16:00 - 18:00 (S5)', value: '16:00 - 18:00' },
                { label: '18:00 - 20:00 (S6)', value: '18:00 - 20:00' }
            ];
            return; // 
        }
        if (
            this.recordTypeName === 'Customer Work Request' &&
            this.request?.NGMCP_Non_Standard__c === true
        ) {
            this.appointmentOptions = [
                { label: '08:00 - 13:00 (AM)', value: '08:00 - 13:00' },
                { label: '12:00 - 20:00 (PM)', value: '12:00 - 20:00' },
                { label: '08:00 - 20:00 (AT)', value: '08:00 - 20:00' }
            ];
            return; // 
        }

        const statusLower = this.status.toLowerCase();
        const selected = new Date(this.selectedDate);
        const day = selected.getDay(); // 0 = Sunday, 6 = Saturday
        const isWeekend = (day === 0 || day === 6);
        // Normalize date formats for holiday comparison
        const selectedDateOnly = selected.toISOString().split('T')[0];
        const isHoliday = this.holidays.some(h => h === selectedDateOnly);
        // --- Main Logic ---
        if (statusLower === 'residential') {
            if (!isWeekend && !isHoliday) {
                this.appointmentOptions = this.residentialWeekdaySlots;
            } else {
                this.appointmentOptions = this.commercialAndWeekendSlots;
            }
        } else if (statusLower === 'commercial') {
            this.appointmentOptions = this.commercialAndWeekendSlots;
        } else {
            this.appointmentOptions = [];
        }
    }
    @wire(getHolidays)
    wiredHolidays({ data, error }) {
        if (data) {
            this.holidays = data.map(d => d.ActivityDate.split('T')[0]);
            this.holidaysLoaded = true;

            // ✅ If Enquiry & Replan is open, clamp min date again
            if (this.datepickerWrFlag && !this.minAppointmentDate) {
                this.minAppointmentDate = this.calculateEnquiryMinDate();
            }
        } else if (error) {
            console.error('Error fetching holidays', error);
        }
    }
    handleInputChange(event) {
        this.reason = event.target.value;
        if (this.reason == null || this.reason == '' || this.reason == undefined) {
            this.reasonFlag = true;
        } else {
            this.reasonFlag = false;
        }
    }
    handleAcceptQuotation(event) {
        this.quotationStatus = event.target.name;
        this.quotationStatusToDisplay = event.target.name.toLowerCase();
        this.acceptRejectFlag = true;
        if (event.target.name == 'Accept') {
            this.isAccept = true;
        } else {
            this.isAccept = false;
        }
        this.acceptRejectInitialFlag = true;
        this.acceptRejectCommentFlag = false;
    }
    closeAcceptRejectModal() {
        this.acceptRejectFlag = false;
        this.comment = '';
        this.commentFlag = false;
    }
    handleComment(event) {
        this.comment = event.target.value;
        if (this.comment == null || this.comment == '' || this.comment == undefined) {
            this.commentFlag = true;
        } else {
            this.commentFlag = false;
        }
    }
    async handleQuotation() {
        if (!this.validateCombinedAttachmentSize()) {

            return;
        }
        this.isLoading = true;
        if (this.comment == null || this.comment == '' || this.comment == undefined) {
            this.commentFlag = true;
        } else {
            this.commentFlag = false;
            if (this.quotationStatus == 'Accept' && this.uploadedFilePayload?.length > 0) {
                const isUploaded = await uploadFiles({
                    recordId: this.request.Id,
                    files: JSON.stringify(this.uploadedFilePayload)
                });
                if (!isUploaded) {
                    return;
                }
            }
            const payload = {
                ticketid: this.request.NGMCP_SR_Ticket__c,
                status: this.quotationStatus == 'Accept' ? 'ACCEPTED' : 'REJECTED',
                comment: this.comment
            };
            submitAcceptRejectQuotation({
                requestBody: JSON.stringify(payload),
                requestId: this.recordId,
            })
                .then(result => {
                    if (this.quotationStatus == 'Accept') {
                        const parsed = typeof result === "string" ? JSON.parse(result) : result;
                        if (parsed?.ticketid) {
                            if (this.uploadedFilePayload?.length > 0) {
                                /*if (!this.validateCombinedAttachmentSize()) {
      
                                    return;
                                }*/
                                uploadtoMAximoSystem({
                                    files: JSON.stringify(this.uploadedFilePayload),
                                    srticket: parsed.ticketid,
                                    uid: parsed.ticketuid,
                                    doctype: 'WRA'
                                })
                                    .then(result1 => {
                                        this.quotationMessage = 'Quotation accepted successfully';
                                        this.acceptRejectFlag = false;
                                        this.comment = '';
                                        this.commentFlag = false;
                                        this.acceptRejectFlag = false;
                                        this.quotationMessageFlag = true;
                                        this.isLoading = false;
                                        this.uploadedFilePayload = [];
                                    })
                                    .catch(error => {
                                        this.quotationMessage = 'Error occoured while accepting the quotation ' + JSON.stringify(error);
                                        this.acceptRejectFlag = false;
                                        this.quotationMessageFlag = true;
                                        this.isLoading = false;
                                        this.uploadedFilePayload = [];
                                    });
                            } else {
                                this.quotationMessage = 'Quotation accepted successfully';
                                this.acceptRejectFlag = false;
                                this.comment = '';
                                this.commentFlag = false;
                                this.acceptRejectFlag = false;
                                this.quotationMessageFlag = true;
                                this.isLoading = false;
                            }
                        }
                    } else {
                        this.quotationMessage = 'Quotation rejected successfully';
                        this.acceptRejectFlag = false;
                        this.comment = '';
                        this.commentFlag = false;
                        this.acceptRejectFlag = false;
                        this.quotationMessageFlag = true;
                        this.isLoading = false;
                    }
                })
                .catch(error => {
                    if (this.quotationStatus == 'Accept') {
                        this.quotationMessage = 'Error occoured while accepting the quotation ' + JSON.stringify(error);
                    } else {
                        this.quotationMessage = 'Error occoured while rejecting the quotation ' + JSON.stringify(error);
                    }
                    this.acceptRejectFlag = false;
                    this.quotationMessageFlag = true;
                    this.isLoading = false;
                });
        }
    }
    handleCommercialTime(slot) {
        let message = '';
        switch (slot) {
            case 'S1':
                message = '08:00 - 12:00'
                break;
            case 'S2':
                message = '10:00 - 14:00'
                break;
            case 'S3':
                message = '12:00 - 16:00'
                break;
            case 'S4':
                message = '14:00 - 18:00'
                break;
            case 'S5':
                message = '16:00 - 20:00'
                break;
            default:
                break;
        }
        return message;
    }
    handleResidentialTime(slot) {
        let message = '';
        switch (slot) {
            case 'S1':
                message = '08:00 - 11:00'
                break;
            case 'S2':
                message = '10:00 - 13:00'
                break;
            case 'S3':
                message = '12:00 - 15:00'
                break;
            case 'S4':
                message = '14:00 - 17:00'
                break;
            case 'S5':
                message = '16:00 - 19:00'
                break;
            case 'S6':
                message = '18:00 - 21:00'
                break;
            default:
                break;
        }
        return message;
    }
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        // You can perform further actions with the uploaded files here
    }
    handleCancel() {
        if (this.request.NGMCP_Non_Standard__c == true && (this.reason == '' || this.reason == null || this.reason == undefined)) {
            this.reasonFlag = true;
        } else {
            this.reasonFlag = false;
            const twoDaysLaterISO = new Date();
            twoDaysLaterISO.setDate(twoDaysLaterISO.getDate() + 2);
            const formatted = twoDaysLaterISO.toISOString().slice(0, 10);

            if (this.request.NGMCP_Target_Start__c <= formatted && this.request.NGMCP_Job_SubType__c == 'DEBTM') {
                this.cancelChargeFlag = true
                this.cancelInitialFlag = false;
                this.cancelReasonFlag = false;
            } else {
                this.cancelChargeFlag = false;
                this.cancelInitialFlag = false;
                this.cancelReasonFlag = true;
                this.handleYes();
            }
        }
    }
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
    setButtonVisibility() {
        ;
        if (this.recordTypeName == 'WorkOrder' && this.NGMCP_Site_contact_details__c == 'Yes') {
            this.showActionButton = true;
        }
        else {
            this.showActionButton = false;
        }
        if ((this.recordTypeName == 'Urgent Work Request'
            || this.recordTypeName == 'Customer Work Request'
            || (this.recordTypeName == 'Enquiry' && this.request.NGMCP_Enquiry_Type__c == 'Technical Query')) &&
            (this.request.NGMCP_Status__c != 'closed'
                && this.request.NGMCP_Status__c != 'CANCELLED'
                && this.request.NGMCP_Status__c != 'Cancelled'
                && this.request.NGMCP_Status__c != 'Resolved'
                && this.request.NGMCP_Status__c != 'Rejected')
            && this.request.Work_Orders__r
            && this.request.Work_Orders__r.length > 0
        ) {
            if ((this.request.NGMCP_Non_Standard__c == true || (this.request.NGMCP_Enquiry_Type__c == 'Technical Query'
                && (this.request.NGMCP_Meter_Type__c == 'Rotary Displacement' || this.request.NGMCP_Meter_Type__c == 'Turbine')))) {
                this.ReplanRequest = 'Request Replan'
                this.CancelRequest = 'Request Cancel'
            } else {
                this.ReplanRequest = 'Replan'
                this.CancelRequest = 'Cancel'
            }
            this.showReplan = true;
            this.showCancel = true;
        }
        if ((this.recordTypeName == 'Urgent Work Request'
            || this.recordTypeName == 'Customer Work Request'
            || this.recordTypeName == 'Enquiry' || this.recordTypeName == 'AMR') &&
            (this.request.NGMCP_Status__c != 'Closed'
                && this.request.NGMCP_Status__c != 'CANCELLED'
                && this.request.NGMCP_Status__c != 'Cancelled'
                && this.request.NGMCP_Status__c != 'Resolved'
                && this.request.NGMCP_Status__c != 'Rejected'
                && this.request.NGMCP_Status__c != 'Additional Information Requested'
                && this.request.NGMCP_Status__c != 'Reminder for Additional Information')) {
            this.showProvideSupportingButton = true;
        } else {
            this.showProvideSupportingButton = false;
        }
        if ((this.recordTypeName == 'Urgent Work Request'
            || this.recordTypeName == 'Customer Work Request'
            || (this.recordTypeName == 'Enquiry' && this.request.NGMCP_Enquiry_Type__c == 'Technical Query')) &&
            (this.request.NGMCP_Status__c == 'closed' || this.request.NGMCP_Status__c == 'Resolved')) {
            this.showCompletion = true;
        }

        if (this.recordTypeName === 'AMR' && this.request.NGMCP_Status__c === 'Submitted') {
            this.showCancelConfirm = true;
            this.showCancel = true;
            this.CancelRequest = 'Cancel';
        }
        if (this.request.NGMCP_Quotation_Status__c == "Waiting for Customer's Quote Approval" || this.request.NGMCP_Quotation_Status__c == 'ACCEPTED' || this.request.NGMCP_Quotation_Status__c == 'REJECTED') {
            this.showquotation = true;
        }
        else {
            this.showquotation = false;
        }
        if (this.request.NGMCP_Quotation_Status__c == "Waiting for Customer's Quote Approval") {
            this.showAcceptReject = true;
        } else {
            this.showAcceptReject = false;
        }
        let adiExpDate = null;
        if (this.request.NGMCP_ADI_expries_on__c != null && this.request.NGMCP_ADI_expries_on__c != '' && this.request.NGMCP_ADI_expries_on__c != undefined) {
            let parts = this.request.NGMCP_ADI_expries_on__c.split('/');
            let day = parseInt(parts[0], 10);
            let month = parseInt(parts[1], 10) - 1; // Month is 0-based in JS
            let year = parseInt(parts[2], 10);
            adiExpDate = new Date(year, month, day);
        }
        let today = new Date();
        if ((this.request.NGMCP_Status__c == 'Additional Information Requested' ||
            this.request.NGMCP_Status__c == 'Reminder for Additional Information')
            && adiExpDate != null
            && adiExpDate > today
            && this.recordTypeName == 'Enquiry') {
            this.showProvideAdditionalButton = true;
        } else {
            this.showProvideAdditionalButton = false;
        }
        let count = 0;
        if (this.request.NGMCP_Resolution_Date__c != null && this.request.NGMCP_Resolution_Date__c != '' && this.request.NGMCP_Resolution_Date__c != undefined) {
            while (this.request.NGMCP_Resolution_Date__c <= today) {
                let dayOfWeek = this.request.NGMCP_Resolution_Date__c.getDay();
                if (dayOfWeek >= 1 && dayOfWeek <= 5) {
                    count++;
                }
                this.request.NGMCP_Resolution_Date__c.setDate(this.formatDateToDDMMYYYY(this.request.NGMCP_Resolution_Date__c.getDate() + 1));
            }
        }
        if (this.request.NGMCP_Status__c == 'Resolved'
            && this.recordTypeName == 'Enquiry'
            && this.request.NGMCP_Resolution_Date__c != null
            && this.request.NGMCP_Resolution_Date__c != ''
            && this.request.NGMCP_Resolution_Date__c != undefined
            && count < 10
        ) {
            this.showReopenQueryButton = true;
        }
        else {
            this.showReopenQueryButton = false;
        }
    }
    proceedForReason() {
        this.isLoading = true;
        if (this.statuslist) {
            if (this.request.NGMCP_Non_Standard__c == true || this.action == 'REQUESTED CANCEL') {
                this.cancelInitialFlag = false;
                this.cancelReasonFlag = true;
                this.cancelChargeFlag = false;
                this.isLoading = false;
            } else {
                const twoDaysLaterISO = new Date();
                twoDaysLaterISO.setDate(twoDaysLaterISO.getDate() + 2);
                const formatted = twoDaysLaterISO.toISOString().slice(0, 10);
                if (this.request.NGMCP_Target_Start__c <= formatted && this.request.NGMCP_Job_SubType__c == 'DEBTM') {
                    this.cancelChargeFlag = true;
                    this.cancelInitialFlag = false;
                    this.cancelReasonFlag = false;
                    this.isLoading = true;
                } else {
                    this.cancelChargeFlag = false;
                    this.cancelInitialFlag = true;
                    this.cancelReasonFlag = false;
                    this.handleYes();
                }
                this.isLoading = true;
            }
            this.Replanerror = false;
        }
        else {
            this.Replanerror = true;
            this.cancelInitialFlag = false;
            this.cancelReasonFlag = false;
            this.cancelChargeFlag = false;
            this.isLoading = false;
        }
    }
    proceedToReplanReason() {
        this.isLoading = true;
        if ((this.action == 'REPLAN' || this.action == 'REQUESTED REPLAN') && (this.selectedDate == '' || this.selectedDate == null || this.selectedDate == undefined)) {
            this.dateFlag = true;
        } else {
            this.dateFlag = false;
        }
        if ((this.action == 'REPLAN' || this.action == 'REQUESTED REPLAN') && (this.selectedSlot == '' || this.selectedSlot == null || this.selectedSlot == undefined)) {
            this.slotFlag = true;
        } else {
            this.slotFlag = false;
        }
        if (this.statuslist) {
            if ((this.action == 'REPLAN' || this.action == 'REQUESTED REPLAN') && !this.dateFlag && !this.slotFlag) {
                this.replanReasonFlag = true;
                this.replanInitialFlag = false;
                this.isLoading = false;
            }
            else {
                this.replanInitialFlag = true;
                this.replanReasonFlag = false;
                this.isLoading = false;
            }
            this.Replanerror = false;
        }
    }
    closereplanCancelMessageFlag() {
        this.replanCancelMessageFlag = false;
    }
    closequotationMessageFlag() {
        this.quotationMessageFlag = false;
    }
    loadDetails() {
        getWorkOrderDetails({ recordId: this.recordId })
            .then(res => {
                console.log('res: ', JSON.stringify(res));
                this.siteId = res.siteId;
                this.title = res.title;
                this.nameVal = res.name;
                this.phone = res.phone;
                this.access = res.access;
                this.NGMCP_Site_contact_details__c = res.flag;
                this.setButtonVisibility();
            })
            .catch(error=>{
                console.log('Error in getWorkOrderDetails now: ', JSON.stringify(error));
            })
    }
    openFormModal() {
        this.showFormModal = true;
        this.title = '';
        this.nameVal = '';
        this.phone = '';
        this.access = '';
    }
    closeFormModal() {
        this.showFormModal = false;
        this.title = '';
        this.nameVal = '';
        this.phone = '';
        this.access = '';
    }
    handleChange(e) {
        const field = e.target.dataset.field;
        if (field === 'title') this.title = e.target.value;
        if (field === 'name') this.nameVal = e.target.value;
        if (field === 'phone') this.phone = e.target.value;
        if (field === 'access') this.access = e.target.value;
    }
    validate() {
        let valid = true;
        this.template.querySelectorAll('lightning-input, lightning-textarea')
            .forEach(i => { if (!i.reportValidity()) valid = false; });
        return valid;
    }
    async handleSubmit() {
        this.isLoading = true;
        if (!this.validate()) return;
        const wrapper = {
            Id: this.siteId,
            FFA_Title__c: this.title,
            FFA_Surname__c: this.nameVal,
            FFA_ContactTelephoneNumber__c: this.phone,
            FFA_AccessInstructions__c: this.access,
        };
        try {
            let res = await updateSiteDetails({ input: wrapper, workOrderId: this.recordId });
            if (res === 'SUCCESS') {
                this.showSuccessPopup('Success', 'Site contact details updated.');
                this.showFormModal = false;
                this.loadDetails();
                this.title = '';
                this.nameVal = '';
                this.phone = '';
                this.access = '';
                this.isLoading = false;
            }
        } catch (error) {
            this.showErrorPopup('Failed to update Site record.');
            this.title = '';
            this.nameVal = '';
            this.phone = '';
            this.access = '';
            this.isLoading = false;
        }
    }
    showSuccessPopup(title, msg) {
        this.popupTitle = title;
        this.popupMessage = msg;
        this.closeOnOk = true;
        this.showPopup = true;
    }
    showErrorPopup(msg) {
        this.popupTitle = 'Error';
        this.popupMessage = msg;
        this.closeOnOk = false;
        this.showPopup = true;
    }
    closePopup() {
        this.showPopup = false;
        if (this.closeOnOk) {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }
    handleAcceptRejectYes() {
        this.acceptRejectInitialFlag = false;
        this.acceptRejectCommentFlag = true;
    }
    openSupportingInfoModal() {
        this.modalHeader = "Provide Supporting  Information";
        this.commentLabel = 'Please provide support information (Additional Information or Access Instructions or Contact Details)';
        this.commentPlaceholder = 'Enter the supporting information';
        this.actionType = "SUP";
        this.isModalOpen = true;
    }
    openAdditionalInfoModal() {
        this.modalHeader = "Provide Additional Information";
        this.commentLabel = 'Response to additional information requested';
        this.commentPlaceholder = 'Enter response to additional information requested';
        this.actionType = "ADI";
        this.isModalOpen = true;
    }
    openReopenModal() {
        this.modalHeader = "Reopen Query";
        this.commentLabel = 'Reason for reopening query';
        this.commentPlaceholder = 'Enter reason for reopening query';
        this.actionType = "REOPEN";
        this.isModalOpen = true;
    }
    handleComments(event) {
        this.comments = event.target.value;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    async handleCommentSubmit() {
        if (!this.validateCombinedAttachmentSize()) {

            return;
        }
        this.isLoading = true; //  START LOADING
        if (this.uploadedFilePayload?.length > 0) {
            const isUploaded = await uploadFiles({
                recordId: this.request.Id,
                files: JSON.stringify(this.uploadedFilePayload)
            });
            if (!isUploaded) {
                console.error('File upload failed');
                return;
            }
        }
        if (this.modalHeader == "Reopen Query") {
            const payload = {
                ticketuid: this.request.NGMCP_Ticketuid__c,
                ticketid: this.request.NGMCP_SR_Ticket__c,
                ngme_time: '',
                target1start: '',
                action: 'RESUBMIT',
                reason: this.comments,
                ngme_resubmitedby: this.email
            }
            callMaximoReopenAPI({
                requestBody: JSON.stringify(payload), requestId: this.recordId,
                ticketuid: this.request.NGMCP_Ticketuid__c
            })
                .then(result => {
                    const parsed = typeof result === "string" ? JSON.parse(result) : result;
                    const doctype = this.request.NGMCP_Enquiry_Type__c == 'Technical Query' ? 'FMD' : 'AQD';
                    if (parsed?.ticketid) {
                        if (this.uploadedFilePayload?.length > 0) {
                            /*if (!this.validateCombinedAttachmentSize()) {
      
                                    return;
                                }*/
                            uploadtoMAximoSystem({
                                files: JSON.stringify(this.uploadedFilePayload),
                                srticket: parsed.ticketid,
                                uid: parsed.ticketuid,
                                doctype: doctype
                            })
                                .then(result1 => {
                                    this.modalHeader = '';
                                    this.comments = '';
                                    this.isModalOpen = false;
                                    this.reOpenAdditionalInfoFlag = true;
                                    this.reOpenAdditionalInfoMessage = 'Query reopened successfully';
                                    this.isLoading = false;
                                    this.uploadedFilePayload = [];
                                })
                                .catch(error => {
                                    this.modalHeader = '';
                                    this.comments = '';
                                    this.isModalOpen = false;
                                    this.reOpenAdditionalInfoFlag = true;
                                    this.reOpenAdditionalInfoMessage = 'Error occoured while doc upload in reopening query' + JSON.stringify(error);
                                    this.isLoading = false;
                                    this.uploadedFilePayload = [];
                                });
                        } else {
                            this.modalHeader = '';
                            this.comments = '';
                            this.isModalOpen = false;
                            this.reOpenAdditionalInfoFlag = true;
                            this.reOpenAdditionalInfoMessage = 'Query reopened successfully';
                            this.isLoading = false;
                        }
                    }
                })
                .catch(error => {
                    this.modalHeader = '';
                    this.comments = '';
                    this.isModalOpen = false;
                    this.reOpenAdditionalInfoFlag = true;
                    this.reOpenAdditionalInfoMessage = 'Error occoured while reopening query' + JSON.stringify(error);
                    this.isLoading = false;
                });
        }
        else if (this.modalHeader == "Provide Supporting  Information") {
            const payload = {
                ticketuid: this.request.NGMCP_Ticketuid__c,
                ticketid: this.request.NGMCP_SR_Ticket__c
            }
            const worklog = {
                logtype: 'CLIENTNOTE',
                recordkey: this.request.NGMCP_SR_Ticket__c,
                class: 'SR',
                language: 'EN',
                description_longdescription: this.comments
            }
            payload.worklog = worklog;
            if (this.recordTypeName != 'AMR') {
                callMaximoSupportInfoAPI({
                    requestBody: JSON.stringify(payload), requestId: this.recordId,
                    ticketuid: this.request.NGMCP_Ticketuid__c
                })
                    .then(result => {
                        const parsed = typeof result === "string" ? JSON.parse(result) : result;
                        const doctype = (this.request.RecordType?.DeveloperName == 'NGMCP_Customer_Work_Request' || this.request.RecordType?.DeveloperName == 'NGMCP_Urgent_Work_Request') ? 'PHT' :
                            (this.request.NGMCP_Enquiry_Type__c == 'Technical Query' ? 'FMD' : 'AQD');
                        if (parsed?.ticketid) {
                            if (this.uploadedFilePayload?.length > 0) {
                                /*if (!this.validateCombinedAttachmentSize()) {
      
                                    return;
                                }*/
                                uploadtoMAximoSystem({
                                    files: JSON.stringify(this.uploadedFilePayload),
                                    srticket: parsed.ticketid,
                                    uid: parsed.ticketuid,
                                    doctype: doctype
                                })
                                    .then(result1 => {
                                        this.modalHeader = '';
                                        this.comments = '';
                                        this.isModalOpen = false;
                                        this.reOpenAdditionalInfoFlag = true;
                                        this.reOpenAdditionalInfoMessage = 'Supporting information submitted successfully';
                                        this.isLoading = false;
                                        this.uploadedFilePayload = [];
                                    })
                                    .catch(error => {
                                        this.modalHeader = '';
                                        this.comments = '';
                                        this.isModalOpen = false;
                                        this.reOpenAdditionalInfoFlag = true;
                                        this.reOpenAdditionalInfoMessage = 'Error occoured while submitting supporting information : ' + JSON.stringify(error);
                                        this.isLoading = false;
                                        this.uploadedFilePayload = [];
                                    });
                            } else {
                                this.modalHeader = '';
                                this.comments = '';
                                this.isModalOpen = false;
                                this.reOpenAdditionalInfoFlag = true;
                                this.reOpenAdditionalInfoMessage = 'Supporting information submitted successfully';
                                this.isLoading = false;
                            }
                        }
                    })
                    .catch(error => {
                        this.modalHeader = '';
                        this.comments = '';
                        this.isModalOpen = false;
                        this.reOpenAdditionalInfoFlag = true;
                        this.reOpenAdditionalInfoMessage = 'Error occoured while submitting additional information: ' + JSON.stringify(error);
                        this.isLoading = false;
                    });
            }
            else if (this.recordTypeName === 'AMR') {
                this.isLoading = true;
                const commentToSend = (this.comments || '').trim();
                if (!commentToSend) {
                    this.isLoading = false;
                    this.reOpenAdditionalInfoFlag = true;
                    this.reOpenAdditionalInfoMessage = 'Please enter supporting information before submitting.';
                    return;
                }

                const fields = {
                    Id: this.recordId,
                    NGMCP_SInfo_response_from_cutomer_portal__c: commentToSend
                };
                const recordInput = { fields };

                try {
                    const result = await updateRecord(recordInput);
                    sendSupportInfoEmail({
                        requestId: this.recordId,
                        reqName: (this.request && this.request.name) ? this.request.name : null,
                        mprn: this.NGMCP_MPRN__c,
                        supportInfoText: commentToSend
                    });
                    this.modalHeader = '';
                    this.comments = '';
                    this.isModalOpen = false;
                    this.reOpenAdditionalInfoFlag = true;
                    this.reOpenAdditionalInfoMessage = 'Supporting information submitted successfully';
                } catch (e) {
                    console.error('AMR submit error', e);
                    this.reOpenAdditionalInfoFlag = true;
                    this.reOpenAdditionalInfoMessage = 'Error occurred while submitting Supporting information';
                } finally {
                    this.isLoading = false;
                }
            }

        }
        else {
            const payload = {
                ticketuid: this.request.NGMCP_Ticketuid__c,
                ticketid: this.request.NGMCP_SR_Ticket__c
            }
            const worklog = {
                logtype: 'answer',
                createby: this.user.name,
                recordkey: this.request.NGMCP_SR_Ticket__c,
                class: 'SR',
                language: 'EN',
                description_longdescription: this.comments
            }
            payload.worklog = worklog;
            callMaximoADIAPI({
                requestBody: JSON.stringify(payload), requestId: this.recordId,
                ticketuid: this.request.NGMCP_Ticketuid__c
            })
                .then(result => {
                    const parsed = typeof result === "string" ? JSON.parse(result) : result;
                    const doctype = this.request.NGMCP_Enquiry_Type__c == 'Technical Query' ? 'FMD' : 'AQD';
                    if (parsed?.ticketid) {
                        if (this.uploadedFilePayload?.length > 0) {
                            /*if (!this.validateCombinedAttachmentSize()) {
      
                                    return;
                                }*/
                            uploadtoMAximoSystem({
                                files: JSON.stringify(this.uploadedFilePayload),
                                srticket: this.request.NGMCP_SR_Ticket__c,
                                uid: this.request.NGMCP_Ticketuid__c,
                                doctype: doctype
                            })
                                .then(result1 => {
                                    this.modalHeader = '';
                                    this.comments = '';
                                    this.isModalOpen = false;
                                    this.reOpenAdditionalInfoFlag = true;
                                    this.reOpenAdditionalInfoMessage = 'Additional information submitted successfully';
                                    this.isLoading = false;
                                    this.uploadedFilePayload = [];
                                })
                                .catch(error => {
                                    this.modalHeader = '';
                                    this.comments = '';
                                    this.isModalOpen = false;
                                    this.reOpenAdditionalInfoFlag = true;
                                    this.reOpenAdditionalInfoMessage = 'Error occoured while submitting additional information';
                                    this.isLoading = false;
                                    this.uploadedFilePayload = [];
                                });
                        } else {
                            this.modalHeader = '';
                            this.comments = '';
                            this.isModalOpen = false;
                            this.reOpenAdditionalInfoFlag = true;
                            this.reOpenAdditionalInfoMessage = 'Additional information submitted successfully';
                            this.isLoading = false;
                        }
                    }
                })
                .catch(error => {
                    this.modalHeader = '';
                    this.comments = '';
                    this.isModalOpen = false;
                    this.reOpenAdditionalInfoFlag = true;
                    this.reOpenAdditionalInfoMessage = 'Error occoured while submitting additional information';
                    this.isLoading = false;
                });
        }
    }
    closereOpenAdditionalInfoFlag() {
        this.reOpenAdditionalInfoFlag = false;
    }
    handleCompletion() {
        this.isLoading = true;
        callViewCompletionDetailsAPI({ ticketid: this.request.NGMCP_SR_Ticket__c })
            .then(result => {
                this.completionDetails = [];
                if (result != null && result != '' && result != undefined) {
                    const data = JSON.parse(result);
                    if (data != null && data != '' && data != undefined && data.workorders != null && data.workorders != '' && data.workorders != undefined) {

                        this.completionDetails = data.workorders;
                        this.isLoading = false;
                    }
                }
                this.isCompletionModalOpen = true;
            })
            .catch(error => {
                this.isLoading = false;
            });
    }
    handleCloseCompletionModal() {
        this.isCompletionModalOpen = false;
    }
    handleViewQuotation() {
        this.isQuotationModel = true;
    }
    handleCloseQuotationModal() {
        this.isQuotationModel = false;
    }
    handleDetailExport() {
        const csv = this.buildCsv(this.completionDetails, this.columnsToExport);
        // Add BOM so Excel handles UTF-8 correctly (especially for special characters)
        const BOM = '\uFEFF';
        const blob = new Blob([BOM + csv], { type: 'application/octet-stream' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        let srnum = this.request.NGMCP_SR_Ticket__c;
        a.download = `${srnum} Completion Details.csv`;
        document.body.appendChild(a);
        a.click();
        // Cleanup
        setTimeout(() => {
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }, 0);
    }
    buildCsv(rows = [], columns = []) {
        // Header
        const header = columns.map(c => this.escapeCsv(c.label)).join(',');
        // Data
        const lines = rows.map(row => {
            return columns.map(col => {
                const value = row?.[col.field];
                return this.escapeCsv(value);
            }).join(',');
        });
        // Use CRLF for best Excel compatibility
        return [header, ...lines].join('\r\n');
    }
    escapeCsv(value) {
        // Normalize undefined/null → empty cell
        if (value === undefined || value === null) return '""';
        // Stringify everything
        let s = String(value);
        // Replace any double quotes with doubled quotes per CSV spec
        s = s.replace(/"/g, '""');
        // Wrap in quotes to protect commas/newlines
        return `"${s}"`;
    }
    handleDragOver(event) {
        event.preventDefault();
        event.currentTarget.classList.add("drag-over");
    }
    handleDragLeave(event) {
        event.preventDefault();
        event.currentTarget.classList.remove("drag-over");
    }
    handleFileDrop(event) {
        event.preventDefault();
        event.currentTarget.classList.remove("drag-over");
        const files = event.dataTransfer.files;
        this.processFiles(files);
    }
    handleFileChange(event) {
        const files = event.target.files;
        this.processFiles(files);
        event.target.value = "";
    }
    handleBrowseClick() {
        this.template.querySelector(".file-input").click();
    }
    processFiles(fileList) {
        this.fileError = '';
        if (!fileList || fileList.length === 0) return;

        const duplicateFiles = [];
        const readPromises = [];

        Array.from(fileList).forEach((file) => {

            // Prevent duplicates
            if (this.uploadedFiles.some(f => f.name === file.name)) {
                duplicateFiles.push(file.name);
                return;
            }

            // Size validation
            if (file.size > MAX_FILE_SIZE) {
                const maxMB = (MAX_FILE_SIZE / 1024 / 1024).toFixed(0);
                this.showTemporaryError(
                    `File "${file.name}" exceeds ${maxMB} MB limit.`
                );
                return;
            }

            // Wrap FileReader in Promise
            const filePromise = new Promise((resolve) => {
                const reader = new FileReader();

                reader.onload = () => {
                    const base64Data = reader.result.split(',')[1];

                    resolve({
                        ui: {
                            name: file.name,
                            size: file.size,
                            sizeDisplay: this.formatFileSize(file.size),
                            isImage: file.type.startsWith('image/'),
                            previewUrl: file.type.startsWith('image/') ? reader.result : null
                        },
                        payload: {
                            name: file.name,
                            type: file.type,
                            size: file.size,
                            dType: "PHT",
                            base64: base64Data
                        }
                    });
                };

                reader.readAsDataURL(file);
            });

            readPromises.push(filePromise);
        });

        //  Wait for ALL files to be read
        Promise.all(readPromises).then(results => {

            results.forEach(res => {
                this.uploadedFiles = [...this.uploadedFiles, res.ui];
                this.uploadedFilePayload = [...this.uploadedFilePayload, res.payload];
            });
        });

        // Duplicate file warning
        if (duplicateFiles.length > 0) {
            this.showTemporaryError(
                duplicateFiles.length === 1
                    ? `File "${duplicateFiles[0]}" is already uploaded.`
                    : `Files "${duplicateFiles.join('", "')}" are already uploaded.`
            );
        }
    }
    // Utility function to show error temporarily
    showTemporaryError(message, duration = 3000) {
        this.fileError = message;
        setTimeout(() => {
            this.fileError = "";
        }, duration);
    }
    formatDateToDDMMYYYY(dateInput) {
        const date = new Date(dateInput);
        if (isNaN(date)) {
            console.error("Invalid date input");
            return null;
        }
        const day = String(date.getDate()).padStart(2, "0");
        const month = String(date.getMonth() + 1).padStart(2, "0");
        const year = date.getFullYear();
        return `${day}/${month}/${year}`;
    }
    // --- Delete uploaded file ---
    handleFileDelete(event) {
        this.fileError = '';
        const name = event.currentTarget.dataset.name;
        this.uploadedFiles = this.uploadedFiles.filter((f) => f.name !== name);
        this.uploadedFilePayload = this.uploadedFilePayload.filter(
            (f) => f.name !== name
        );
    }
    getTotalUploadedFileSize() {
        return (this.uploadedFilePayload || []).reduce(
            (total, file) => total + (file?.size || 0),
            0
        );
    }

    validateCombinedAttachmentSize() {
        const totalSize = this.getTotalUploadedFileSize();
        if (totalSize > MAX_TOTAL_ATTACHMENT_SIZE) {
            this.fileError = `Combined size of attachments (${this.formatFileSize(totalSize)}) exceeds ${MAX_FILE_SIZE_MB} MB limit. Please amend and submit.`;
            return false;
        }
        return true;
    }
    formatFileSize(bytes) {
        if (bytes < 1024) return `${bytes} B`;
        else if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
        else return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
    }
    handleDownloadFiles() {
        if (!this.recordId) {
            console.warn('No Work Order selected');
            return;
        }
        this.isLoading = true;
        getParentAccountFiles({ workOrderId: this.recordId })
            .then(files => (files || []).forEach(f => f?.Id && this.downloadFile(f.Id)))
            .catch(error => {
                console.error('Download failed', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    downloadFile(contentVersionId) {
        // Experience Cloud SAFE
        const url =
            `${basePath}/sfc/servlet.shepherd/version/download/${contentVersionId}`;
        // IMPORTANT: _self (not _blank)
        window.open(url, '_self');
    }

    //Latest added code for Download RAMS
    @wire(getRecord, { recordId: '$recordId', fields: [FFA_SENDER] })
    wiredSender({ error, data }) {
        if (data) {
            const sender = data.fields.FFA_Sender_ID__c.value;
            this.showdownloadRams = sender === 'PHOENIX';
        }
    }
    handleCancelYes() {
        if (this.isAMRFLow) {
            this.isLoading = true;
            this.handleCancelConfirm();
            this.isCancelModalOpen = false;
            return;
        }
        this.proceedForReason();
    }
    handleCancelConfirm() {
        this.isLoading = true;
        cancelAMRRequest({ requestId: this.recordId })
            .then(result => {
                this.isCancelModalOpen = false;
                this.selectedDate = '';
                this.selectedSlot = '';
                this.reason = '';
                this.dateFlag = false;
                this.slotFlag = false;
                this.reasonFlag = false;
                this.replanCancelMessage = 'Job cancelled successfully';
                this.replanCancelMessageFlag = true;
                this.isLoading = false;
            })
            .catch(error => {
                this.replanCancelMessage = 'Error occoured while cancelling the job ';
                this.replanCancelMessageFlag = true;
                this.isLoading = false;
            });
    }

    handleCancelNo() {
        this.isCancelModalOpen = false;
    }

    normalizeToDDMMYYYY(value) {
        if (!value) return value;
        let dateObj = null;
        // Case 1: Already ISO or contains time
        if (!isNaN(Date.parse(value))) {
            dateObj = new Date(value);
        }
        // Case 2: dd/mm/yyyy or dd-mm-yyyy
        else if (/^\d{2}[\/-]\d{2}[\/-]\d{4}$/.test(value)) {
            const parts = value.split(/[\/-]/);
            dateObj = new Date(parts[2], parts[1] - 1, parts[0]);
        }
        // Case 3: yyyy-mm-dd
        else if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
            const parts = value.split('-');
            dateObj = new Date(parts[0], parts[1] - 1, parts[2]);
        }
        if (!dateObj || isNaN(dateObj.getTime())) {
            return value; // Not a valid date → return original
        }
        const day = String(dateObj.getDate()).padStart(2, '0');
        const month = String(dateObj.getMonth() + 1).padStart(2, '0');
        const year = dateObj.getFullYear();
        return `${day}/${month}/${year}`;
    }
    handleBackButton() {
        if (this.homecontainerFlag) {
            window.location.reload();
        } else if (this.reportContainerFlag) {
            const event = new CustomEvent('reportback');
            this.dispatchEvent(event);
        } else {
            const event = new CustomEvent('backbutton');
            this.dispatchEvent(event);
        }
    }
    handleDownloadFiles() {
        const payload = {
            selectedRecordId: this.recordId,
        };
        this.dispatchEvent(
            new CustomEvent('downloadrams', {
                detail: payload,
                bubbles: true,
                composed: true
            })
        );

    }

    handledynamicPageResponse(event) {
        this.handleBackButton();
    }

}