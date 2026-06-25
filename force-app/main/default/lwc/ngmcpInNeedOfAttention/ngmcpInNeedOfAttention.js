import { LightningElement, track, api } from 'lwc';
import getReportData from '@salesforce/apex/NgmcpReportsController.getReportData';
import { NavigationMixin } from 'lightning/navigation';
const PAGE_SIZE = 5;
export default class NgmcpInNeedOdAttention extends NavigationMixin(LightningElement) {
    @api reportKey;
    @track rows = [];
    @track allData = [];
    @track currentReportKey;
    @track page = 1;
    @track totalPages = 1;
    @track isLoading = true;
    @track reportTitle = '';

    //Header mapping based on report key
    headerMap = {
        ADDINFO_WO: 'Work orders in need of your attention',
        INPROGRESS_WO: 'Upcoming Site Visits',
        ADDINFO_ENQ: 'Enquiries in need of your attention'

    };
    /*================column config =============*/
    columnConfig = {
        ADDINFO_WO: [
            { label: 'WorkOrder', key: 'name', isLink: true },
            { label: 'MPRN', key: 'mprn' },
            { label: 'Job Description', key: 'JobDescription' }],

        INPROGRESS_WO: [
            { label: 'WorkOrder', key: 'name', isLink: true },
            { label: 'MPRN', key: 'mprn' },
            { label: 'Status', key: 'status' },
            { label: 'AppointmentDate', key: 'AppointmentDate' }],

        ADDINFO_ENQ: [
            { label: 'Request', key: 'name', isLink: true },
            { label: 'MPRN', key: 'mprn' },
            { label: 'Status', key: 'status' }]
    };

    connectedCallback() {
        this.setReportTitle(this.reportKey);
        this.fetchData();
    }
    fetchData() {
        this.currentReportKey = this.reportKey;
        getReportData({ reportKey: this.reportKey })
            .then(result => {
                console.log('Apex Result =>', result);
                console.log('Result Length =>', result?.length);
                this.allData = result || [];
                this.applyView();
            })
            .finally(() =>
                this.isLoading = false);

    }

    /* ================= PAGINATION ================= */
    applyView() {
        this.totalPages = Math.max(1, Math.ceil(this.allData.length / PAGE_SIZE))
        const start = (this.page - 1) * PAGE_SIZE;
        const end = start + PAGE_SIZE;
        const pageData = this.allData.slice(start, end);

        this.rows = pageData.map(row => ({
            recordId: row.recordId,
            cells: this.columns.map(col => ({
                key: col.key,
                value: row[col.key] || '',
                isLink: col.isLink || false,
                recordId: row.recordId
            }))
        }));
    }
    prevPage() {
        if (this.page > 1) {
            this.page--;
            this.applyView();
        }
    }
    nextPage() {
        if (this.page < this.totalPages) {
            this.page++;
            this.applyView();
        }
    }
    get isPrevDisabled() {
        return this.page <= 1;
    }
    get isNextDisabled() {
        return this.page >= this.totalPages;
    }
    /* ================= NAVIGATION ================= */
    openRecord(event) {
        const recordId = event.currentTarget.dataset.id;
        console.log('recordId', JSON.stringify(recordId));
        console.log('dispatchevent', JSON.stringify(this.dispatchEvent(
            new CustomEvent('needattention', {
                detail: { recordId },
                bubbles: true,
                composed: true
            })
        )));
        this.dispatchEvent(
            new CustomEvent('needattention', {
                detail: { recordId },
                bubbles: true,
                composed: true
            })
        );
    }
    //Dynamic header getter
    get headerTitle() {
        return this.headerMap[this.reportKey];
    }
    get columns() {
        return this.columnConfig[this.reportKey] || [];
    }
    get hasRows() {
        return this.rows.length > 0;
    }
    getCurrentColumns() {

        if (this.currentReportKey === 'ADDINFO_WO') {
            return this.reportColumnConfig.OtherReports;
        }
        else if (this.currentReportKey === 'INPROGRESS_WO') {
            return this.reportColumnConfig.OtherReports;
        }
        else if (this.currentReportKey === 'ADDINFO_ENQ') {
            return this.reportColumnConfig.EnquiryReports;
        }
    }
    setReportTitle(reportKey) {
        switch (reportKey) {
            case 'ADDINFO_WO':
                this.reportTitle = 'Work orders in need of your attention';
                break;
            case 'INPROGRESS_WO':
                this.reportTitle = 'Upcoming Site Visits';
                break;
            case 'ADDINFO_ENQ':
                this.reportTitle = 'Enquiries in need of your attention';
                break;
        }
    }
    reportColumnConfig = {
        OtherReports: [
            { label: 'Name', key: 'name' },
            { label: 'Status', key: 'status' },
            { label: 'MPRN', key: 'mprn' },
            { label: 'Job Category', key: 'jobcategory' },
            { label: 'Sub Category', key: 'subcategory' },
            { label: 'Supplier Code', key: 'suppliercode' }
        ],
        EnquiryReports: [
            { label: 'Name', key: 'name' },
            { label: 'Service Request', key: 'SRnumber' },
            { label: 'Status', key: 'status' },
            { label: 'MPRN', key: 'mprn' },
            { label: 'Supplier Code', key: 'suppliercode' },
            { label: 'Enquiry Type', key: 'EnquiryType' },
            { label: 'Enquiry Category', key: 'EnquiryCategory' },
            { label: 'Reason Code', key: 'ReasonCode' },
            { label: 'Building Name', key: 'BuildingName' },
            { label: 'Building Number', key: 'BuildingNumber' },
            { label: 'Street', key: 'Street' },
            { label: 'Dependent Locality', key: 'DependentLocality' },
            { label: 'Town', key: 'Town' },
            { label: 'PostCode', key: 'PostCode' },
            { label: 'Customer Name', key: 'CustomerName' },
            { label: 'Customer Number', key: 'CustomerNumber' }
        ]
    }
    exportToCSV() {
        console.log('EXPORT CLICKED');
        console.log('currentReportKey =>', this.currentReportKey);
        console.log('allData length =>', this.allData?.length);

        if (!this.allData || this.allData.length === 0) {
            console.warn('No data to export');
            return;
        }

        const columns = this.getCurrentColumns();

        if (!columns || columns.length === 0) {
            console.error('No columns found for export');
            return;
        }

        const csvRows = [];

        // Header
        csvRows.push(columns.map(col => `"${col.label}"`).join(','));

        // Data
        this.allData.forEach(row => {
            const values = columns.map(col => {
                let value = row[col.key];
                if (value === null || value === undefined) value = '';
                return `"${value.toString().replace(/"/g, '""')}"`;
            });
            csvRows.push(values.join(','));
        });

        const csvContent = csvRows.join('\n');
        const encodedUri =
            'data:text/csv;charset=utf-8,' +
            encodeURIComponent(csvContent);

        /*const blob = new Blob([csvRows.join('\n')], {
            type: 'text/csv;charset=utf-8;'
        });*/

        const link = document.createElement('a');
        link.href = encodedUri;
        link.download = `${this.reportTitle || 'Report'}_All_Pages.csv`;

        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);

    }


}