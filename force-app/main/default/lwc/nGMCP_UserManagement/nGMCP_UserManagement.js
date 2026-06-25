import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLoggedInUserProfile from '@salesforce/apex/NGMCP_UserManagmentController.getLoggedInUserProfile';
import getAllSupplierGroups from '@salesforce/apex/NGMCP_UserManagmentController.getAllSupplierGroups';
import getSupplierCodesForLoggedInUser from '@salesforce/apex/NGMCP_UserManagmentController.getSupplierCodesForLoggedInUser';
import groupValuesforCRM from '@salesforce/apex/NGMCP_UserManagmentController.groupValuesforCRM';
import getUserSupplierContext from '@salesforce/apex/NGMCP_UserManagmentController.getUserSupplierContext';
import processSingleRequest from '@salesforce/apex/NGMCP_UserManagmentController.processSingleRequest';
import processBulkCSV from '@salesforce/apex/NGMCP_UserManagmentController.processBulkCSV';
import NGMCPChangeBulk from '@salesforce/resourceUrl/NGMCPChangeBulk';
import NGMCPCreateBulk from '@salesforce/resourceUrl/NGMCPCreateBulk';
import NGMCPDeactivateBulk from '@salesforce/resourceUrl/NGMCPDeactivateBulk';
import ngAssets from "@salesforce/resourceUrl/NGMCP_SearchMPRN";

/* ===================== CONSTANTS ===================== */
const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB
const MAX_BULK_RECORDS = 10000;

const ACTION_HEADER_MAP = {
    Create: ['FirstName', 'LastName', 'Email', 'Role', 'SupplierGroup', 'SupplierCode'],
    Deactivate: ['UserName'],
    Change: ['UserName', 'SupplierCode', 'Role'],
    Reactivate: ['UserName']
};

export default class NgmcpUserManagement extends LightningElement {
    /* ===================== UI OPTIONS ===================== */
    actionOptions = [
        { label: 'Create', value: 'Create' },
        { label: 'Deactivate', value: 'Deactivate' },
        { label: 'Change', value: 'Change' },
        { label: 'Reactivate', value: 'Reactivate' }
    ];

    modeOptions = [
        { label: 'Single', value: 'Single' },
        { label: 'Bulk', value: 'Bulk' }
    ];

    roleOptions = [
        { label: 'Agent', value: 'Agent' },
        { label: 'Manager', value: 'Manager' }
    ];

    /* ===================== STATE ===================== */
    @track action = '';
    @track mode = '';
    homepageAssets = ngAssets;
    @track uploadedFiles = [];          // UI list (images + CSVs)
    @track uploadedFilePayload = [];    // Payloads for images (and optional CSV)
    @track fileName = '';
    @track formData = {
        firstName: '',
        lastName: '',
        email: '',
        userName: '',
        role: '',
        supplierCode: ''
    };
    BulkDeactivate = NGMCPDeactivateBulk;
    BulkChange = NGMCPChangeBulk;
    BulkCreate = NGMCPCreateBulk;
    @track username = '';
    @track supplierGroup;
    @track supplierGroupOptions = [];
    @track supplierCodeOptions = [];    // dual-listbox options [{label,value}]
    @track selectedSupplierCodes = [];  // dual-listbox value: string[]
    @track downloadmessage = '';
    @track downloadLink;
    @track downloadlabel;

    @track bulkRecords = [];            // parsed CSV rows (Bulk)
    @track isBulkCsvValid = false;

    @track isLoading = false;
    @track isCrmUser = false;

    @track showModal = false;
    @track modalTitle = '';
    @track modalMessage = '';

    fileError;
    consentGiven = false;

    /* ===================== TEMPLATE FLAGS ===================== */
    get showQ2() {
        return !!this.action;
    }
    get showBulk() {
        return this.mode === 'Bulk';
    }
    get showCreate() {
        return this.action === 'Create' && this.mode === 'Single';
    }
    get showDeactivate() {
        return this.action === 'Deactivate' && this.mode === 'Single';
    }
    get showReactivate() {
        return this.action === 'Reactivate' && this.mode === 'Single';
    }
    get showChange() {
        return this.action === 'Change' && this.mode === 'Single';
    }
    get isReadOnly() {
        return this.action === 'Change';
    }

    /* ===================== WIRES ===================== */
    @wire(getLoggedInUserProfile)
    async wiredProfile({ data, error }) {
        if (data) {
            this.isCrmUser = data.isCrmUser;
            await this.initContext();
        } else if (error) {
            this.handleError(error);
        }
    }

    /* ===================== INIT ===================== */
    async initContext() {
        try {
            if (this.isCrmUser) {
                const groups = await getAllSupplierGroups();
                this.supplierGroupOptions = this.normalizeOptions(groups);
            } else {
                const codes = await getSupplierCodesForLoggedInUser();
                this.supplierCodeOptions = this.normalizeOptions(codes);
            }
        } catch (e) {
            this.handleError(e);
        }
    }

    /* ===================== NORMALIZERS & HELPERS ===================== */
    normalizeOptions(input, labelKey = 'label', valueKey = 'value') {
        // Accepts: array of strings OR array of objects; returns [{label, value}]
        if (!Array.isArray(input)) return [];
        return input.map(item => {
            if (item == null) return { label: '', value: '' };
            if (typeof item !== 'object') {
                const s = String(item);
                return { label: s, value: s };
            }
            const label =
                item[labelKey] ??
                item.name ??
                item.Code ??
                item.code ??
                item.Id ??
                item.id ??
                JSON.stringify(item);
            const value =
                item[valueKey] ??
                item.value ??
                item.Code ??
                item.code ??
                item.Id ??
                item.id ??
                String(label);
            return { label: String(label), value: String(value) };
        });
    }

    isCsvFile(file) {
        return file && (file.type === 'text/csv' || /\.csv$/i.test(file.name));
    }

    readFileAsText(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => resolve(String(reader.result || ''));
            reader.onerror = () => reject(reader.error);
            reader.readAsText(file);
        });
    }

    readFileAsDataURL(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => resolve(String(reader.result || ''));
            reader.onerror = () => reject(reader.error);
            reader.readAsDataURL(file);
        });
    }

    formatFileSize(bytes) {
        if (bytes < 1024) return `${bytes} B`;
        if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
        return `${(bytes / 1024 / 1024).toFixed(1)} MB`;
    }

    showTemporaryError(msg) {
        this.fileError = msg;
        // Optional auto-clear
        // setTimeout(() => { this.fileError = ''; }, 4000);
    }

    /* ===================== HANDLERS ===================== */
    handleActionChange(e) {
        this.action = e.detail.value;
        this.mode = '';
        this.resetBulk();
        this.downloadLink = null;
        this.downloadlabel = '';
        this.downloadmessage = '';
        const keepSupplierContext = (!this.isCrmUser);
        if (keepSupplierContext) {
            if (this.supplierGroup) {
                this.formData.supplierGroup = this.supplierGroup;
            }
            if (Array.isArray(this.selectedSupplierCodes) && this.selectedSupplierCodes.length) {
                this.formData.supplierCode = this.selectedSupplierCodes.join(';');
            } else {
                delete this.formData.supplierCode;
            }
        } else {
            this.supplierGroup = '';
            this.supplierCodeOptions = [];
            this.selectedSupplierCodes = [];
            delete this.formData.supplierGroup;
            delete this.formData.supplierCode;
        }
    }

    handleModeChange(e) {
        this.mode = e.detail.value;
        this.resetBulk();
        this.updateDownloadLink();
    }

    handleChange(e) {
        const field = e.target.dataset.field;
        const value = e.target.value;
        this.formData = { ...this.formData, [field]: value };
        if (field === 'userName') this.username = value;
    }

    handleConsentChange(e) {
        this.consentGiven = e.target.checked;
    }

    async handleSearch() {
        if (!this.username) return;
        this.isLoading = true;
        try {
            const ctx = await getUserSupplierContext({ username: this.username });
            this.supplierGroup = ctx.supplierGroup;

            // Ensure selected values are strings
            this.selectedSupplierCodes = (ctx.userSupplierCodes || [])
                .map(v =>
                    typeof v === 'string'
                        ? v
                        : (v.value ?? v.code ?? v.Code ?? v.Id ?? v.id ?? '')
                )
                .filter(Boolean);

            const codes = await groupValuesforCRM({ suppliergroup: this.supplierGroup });
            this.supplierCodeOptions = this.normalizeOptions(codes);
        } catch (e) {
            this.handleError(e);
        } finally {
            this.isLoading = false;
        }
    }

    async handleSupplierGroupChange(e) {
        this.supplierGroup = e.detail.value;
        this.formData = {
            ...this.formData,
            supplierGroup: this.supplierGroup
        };
        const codes = await groupValuesforCRM({ suppliergroup: this.supplierGroup });
        this.supplierCodeOptions = this.normalizeOptions(codes);
    }

    handleSupplierCodeMultiChange(e) {
        this.selectedSupplierCodes = [...e.detail.value]; // array of strings
        this.formData.supplierCode = this.selectedSupplierCodes.join(';');
    }

    /* ===================== FILE HANDLING ===================== */
    handleBrowseClick() {
        this.template.querySelector('.file-input')?.click();
    }

    handleFileChange(e) {
        const files = e.target.files;
        this.processFiles(files);
        // Clear so same file can be re-selected later
        e.target.value = '';
    }

    handleDragOver(e) {
        e.preventDefault();
    }

    handleDragLeave(e) {
        e.preventDefault();
    }

    handleFileDrop(e) {
        e.preventDefault();
        const files = e.dataTransfer?.files;
        this.processFiles(files);
    }

    handleFileDelete(e) {
        const name = e.currentTarget?.dataset?.name;
        if (!name) return;
        this.uploadedFiles = this.uploadedFiles.filter(f => f.name !== name);
        this.uploadedFilePayload = this.uploadedFilePayload.filter(p => p.name !== name);
    }

    async processFiles(fileList) {
        this.fileError = '';
        if (!fileList || fileList.length === 0) return;

        const files = Array.from(fileList);
        const duplicateFiles = [];
        const oversizedFiles = [];

        const tasks = files.map(async (file) => {
            // A) Duplicate prevention
            if (this.uploadedFiles?.some(f => f.name === file.name)) {
                duplicateFiles.push(file.name);
                return;
            }
            // B) Size validation
            if (file.size > MAX_FILE_SIZE) {
                oversizedFiles.push(file.name);
                return;
            }

            const isCsv = this.isCsvFile(file);

            if (isCsv) {
                // C) CSV: parse + validate + add UI entry
                try {
                    this.fileName = file.name; // mirror single-file handler
                    const csvText = await this.readFileAsText(file);

                    // Parse & validate (also gates by action/header/count)
                    this.parseCSV(csvText);

                    // Add to UI list so filename shows in preview list
                    const ui = {
                        name: file.name,
                        size: file.size,
                        sizeDisplay: this.formatFileSize(file.size),
                        isImage: false,
                        previewUrl: null
                    };
                    this.uploadedFiles = [...this.uploadedFiles, ui];

                    // Optional: keep CSV payload as base64 if needed
                    // const base64 = btoa(unescape(encodeURIComponent(csvText)));
                    // const payload = { name: file.name, type: file.type || 'text/csv', size: file.size, dType: 'CSV', base64 };
                    // this.uploadedFilePayload = [...this.uploadedFilePayload, payload];
                } catch (err) {
                    this.showTemporaryError(`Failed to parse "${file.name}". Please check the CSV format.`);
                }
            } else {
                // D) Non-CSV (images/docs): read as DataURL for preview + payload
                try {
                    const dataUrl = await this.readFileAsDataURL(file);
                    const base64 = dataUrl.includes(',') ? dataUrl.split(',')[1] : '';

                    const ui = {
                        name: file.name,
                        size: file.size,
                        sizeDisplay: this.formatFileSize(file.size),
                        isImage: file.type?.startsWith('image/'),
                        previewUrl: file.type?.startsWith('image/') ? dataUrl : null
                    };

                    const payload = {
                        name: file.name,
                        type: file.type,
                        size: file.size,
                        dType: 'PHT',
                        base64
                    };

                    this.uploadedFiles = [...this.uploadedFiles, ui];
                    this.uploadedFilePayload = [...this.uploadedFilePayload, payload];
                } catch (err) {
                    this.showTemporaryError(`Could not read "${file.name}".`);
                }
            }
        });

        await Promise.all(tasks);

        // E) Show batched messages (if any)
        if (oversizedFiles.length > 0) {
            const maxMB = (MAX_FILE_SIZE / 1024 / 1024).toFixed(0);
            this.showTemporaryError(
                oversizedFiles.length === 1
                    ? `File "${oversizedFiles[0]}" exceeds ${maxMB} MB limit.`
                    : `Files "${oversizedFiles.join('", "')}" exceed ${maxMB} MB limit.`
            );
        }

        if (duplicateFiles.length > 0) {
            this.showTemporaryError(
                duplicateFiles.length === 1
                    ? `File "${duplicateFiles[0]}" is already uploaded.`
                    : `Files "${duplicateFiles.join('", "')}" are already uploaded.`
            );
        }
    }

    /* ===================== CSV PARSING & BULK VALIDATION ===================== */
    parseCSV(csvText) {
        // Normalize and split
        const rows = String(csvText || '')
            .replace(/\r/g, '')
            .split('\n')
            .filter(r => r.trim());

        if (!rows.length) {
            this.bulkRecords = [];
            this.isBulkCsvValid = false;
            this.showModalMessage('Error', 'CSV is empty');
            return;
        }

        const headers = rows.shift().split(',').map(h => h.trim());
        const expected = ACTION_HEADER_MAP[this.action];

        // Relaxed header comparison (trim + lowercase)
        const norm = arr => (arr || []).map(h => String(h).trim().toLowerCase());
        if (!expected || norm(headers).join() !== norm(expected).join()) {
            this.bulkRecords = [];
            this.isBulkCsvValid = false;
            this.showModalMessage(
                'Error',
                `Invalid CSV header for selected action "${this.action}". Expected: ${expected.join(', ')}`
            );
            return;
        }

        if (rows.length > MAX_BULK_RECORDS) {
            this.bulkRecords = [];
            this.isBulkCsvValid = false;
            this.showModalMessage('Error', `CSV exceeds ${MAX_BULK_RECORDS.toLocaleString()} record limit`);
            return;
        }

        // Simple CSV: split by comma (NOTE: quoted fields with commas are not supported here)
        const records = rows.map(r => {
            const cols = r.split(',').map(v => v.trim());
            const rec = {};
            expected.forEach((h, i) => (rec[h] = cols[i] ?? ''));
            return rec;
        });

        this.bulkRecords = records;     // Replace (to append, merge here)
        this.isBulkCsvValid = true;
    }

    resetBulk() {
        this.bulkRecords = [];
        this.isBulkCsvValid = false;
        this.fileError = null;
        // Also clear UI files when switching modes/actions if desired:
        this.uploadedFiles = [];
        this.uploadedFilePayload = [];
        this.fileName = '';
    }

    /* ===================== SUBMIT ===================== */
    validateForm() {
        let valid = true;
        this.template
            .querySelectorAll('lightning-input, lightning-combobox, lightning-dual-listbox')
            .forEach(el => {
                el.reportValidity();
                if (!el.checkValidity()) valid = false;
            });
        return valid && this.consentGiven;
    }

    async handleSubmit() {
        if (!this.validateForm()) return;
        this.isLoading = true;
        if (this.action === 'Change') {
        // If no new supplier codes provided in the form, fall back to previously fetched values
        const hasNewCodes =
            this.formData?.supplierCode && String(this.formData.supplierCode).trim().length > 0;

        const prevCodesArr = Array.isArray(this.selectedSupplierCodes)
            ? this.selectedSupplierCodes.filter(Boolean)
            : [];

        if (!hasNewCodes && prevCodesArr.length > 0) {
            this.formData = {
                ...this.formData,
                supplierCode: prevCodesArr.join(';')
            };
        }

        // If supplierGroup not provided in the form, use previously fetched one (from Search)
        if (!this.formData?.supplierGroup && this.supplierGroup) {
            this.formData = {
                ...this.formData,
                supplierGroup: this.supplierGroup
            };
        }
    }
        try {
            if (this.mode === 'Bulk') {
                if (!this.isBulkCsvValid || !this.bulkRecords?.length) {
                    this.showModalMessage('Error', 'Please upload a valid CSV for bulk processing.');
                    return;
                }
                await processBulkCSV({
                    actionType: this.action,
                    recordsJson: JSON.stringify(this.bulkRecords)
                });
                this.showModalMessage('Success', 'Bulk request processed successfully');
            } else {
                await processSingleRequest({
                    actionType: this.action,
                    formDetails: JSON.stringify(this.formData)
                });
                this.showModalMessage('Success', 'Request processed successfully');
            }
        } catch (e) {
            this.handleError(e);
        } finally {
            this.isLoading = false;
        }
    }

    /* ===================== MODAL & ERROR ===================== */
    showModalMessage(title, message) {
        this.modalTitle = title;
        this.modalMessage = message;
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
        setTimeout(() => {
          window.location.reload();
        }, 50);

    }

    handleError(error) {
        const msg = error?.body?.message || error.message || 'Unexpected error';
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: msg,
                variant: 'error'
            })
        );
    }
     openPdfInNewTab() {
        if (this.downloadLink) {
            window.open(this.downloadLink, '_blank');
        }
    }

    updateDownloadLink() {
        this.downloadLink = null;
        if (this.action == 'Create' && this.mode == 'Bulk') {
            this.downloadLink = this.BulkCreate;
            this.downloadlabel = 'Create Users Bulk Template'
            this.downloadmessage = 'Not sure of file format to be used? Download Template from here';
        } else if (this.action == 'Deactivate' && this.mode == 'Bulk') {
            this.downloadLink = this.BulkDeactivate;
            this.downloadlabel = 'Deactivate Users Bulk Template'
            this.downloadmessage = 'Not sure of file format to be used? Download Template from here';
        } else if (this.action == 'Change' && this.mode == 'Bulk') {
            this.downloadLink = this.BulkChange;
            this.downloadlabel = 'Change Users Bulk Template'
            this.downloadmessage = 'Not sure of file format to be used? Download Template from here';
        } else if (this.action == 'Reactivate' && this.mode == 'Bulk') {
            this.downloadLink = this.BulkDeactivate;
            this.downloadlabel = 'Reactivate Users Bulk Template'
            this.downloadmessage = 'Not sure of file format to be used? Download Template from here';
        }
        else {
            this.downloadLink = null;
            this.downloadlabel = '';
            this.downloadmessage = '';
        }
    }
}