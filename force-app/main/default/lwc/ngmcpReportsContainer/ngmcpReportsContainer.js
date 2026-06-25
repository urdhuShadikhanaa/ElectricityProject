import { LightningElement, track } from 'lwc';
import getReportData from '@salesforce/apex/NgmcpReportsController.getReportData';
import { NavigationMixin } from 'lightning/navigation';
const PAGE_SIZE = 20;
export default class NgmcpReportsContainer extends NavigationMixin(LightningElement) {
    /* ================= STATE ================= */
    @track showReportTable = false;
    @track rows = [];
    @track allData = [];
    @track sortDirection = 'asc';
    @track selectedReportkey;
    @track currentReportKey;
    @track sortKey;
    @track page = 1;
    @track totalPages = 1;
    @track reportTitle = '';
    @track showListView = true;
    @track showDetailView = false;
    @track completed = false;
    @track inprogress = false;


    @track recordId;
    @track recordTypeName;
    @track objectApiName;
    @track pdfdownload = false;


    /* ================= REPORT SELECTION ================= */
    openReport(event) {
        this.selectedReportkey = event.currentTarget.dataset.id;
        console.log('Selected Report Key =>', this.selectedReportkey);
        this.page = 1;
        this.showReportTable = true;
        this.setReportTitle(this.selectedReportkey);
        this.fetchReportData();
    }
    /* ================= DATA FETCH ================= */

    fetchReportData() {
        console.log('Fetching report for =>', this.selectedReportkey);
        this.currentReportKey = this.selectedReportkey;
        getReportData({ reportKey: this.selectedReportkey })
            .then(result => {
                console.log('Apex Result =>', result);
                console.log('Result Length =>', result?.length);
                this.allData = result || [];
                this.applyView();
            })
            .catch(error => {
                console.error('Apex Error =>', error);
                this.rows = [];
                this.allData = [];
                this.totalPages = 1;
            });
    }

    /* ================= SORT ================= */
    handleSort(event) {
        const key = event.currentTarget.dataset.key;
        this.sortKey = key;
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        this.allData = [...this.allData].sort((a, b) => {
            let valA = a[key] ? a[key].toString().toLowerCase() : '';
            let valB = b[key] ? b[key].toString().toLowerCase() : '';
            return this.sortDirection === 'asc'
                ? valA.localeCompare(valB)
                : valB.localeCompare(valA);
        });
        this.page = 1;
        this.applyView();
    }
    /* ================= PAGINATION ================= */
    applyView() {
        this.totalPages = Math.max(
            1,
            Math.ceil(this.allData.length / PAGE_SIZE)
        );
        const start = (this.page - 1) * PAGE_SIZE;
        this.rows = this.allData.slice(start, start + PAGE_SIZE);
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
    get isExportDisabled() {
        return !this.allData || this.allData.length === 0;
    }
    /* ================= NAVIGATION ================= */
    //    openRecord(event) {
    //        this.recordId = event.currentTarget.dataset.id;
    //        this.objectApiName = this.recordTypeName === 'WorkOrder'
    //             ? 'WorkOrder'
    //             : 'NGMCP_Enquiry__c';
    //        this[NavigationMixin.GenerateUrl]({
    //            type: 'standard__recordPage',
    //            attributes: {
    //                recordId: recordId,
    //                actionName: 'view'
    //            }
    //        }).then(url => {
    //            window.open(url, '_self');
    //        });
    //        console.log('Navigating directly to Dynamic Page:', this.recordId);
    //    }

    openRecord(event) {
        this.recordId = event.currentTarget.dataset.id;
        console.log('event details ', JSON.stringify((event.currentTarget.dataset)))

        const selectedRecord = this.allData.find(
            rec => rec.recordId === this.recordId
        );
        if (!selectedRecord) {
            console.error('Record not found for ID:', this.recordId);
            return;
        }
        this.recordTypeName = selectedRecord.recordTypeName ?? 'WorkOrder';
        console.log('Record Type1:', this.recordTypeName);

        //  Switch views
        this.showListView = false;
        this.showDetailView = true;

    }

    goBack() {
        this.showReportTable = false;
        this.rows = [];
        this.allData = [];
        this.page = 1;
        this.totalPages = 1;
    }

    get isUserReport() {
        return this.selectedReportkey === 'USER_DETAILS';
    }
    get isAppReports() {
        return this.selectedReportkey === 'APP_AND_DEAPP';
    }
    get isWORKORDERSReport() {
        return this.selectedReportkey === 'WORKORDERS' ||
            this.selectedReportkey === 'QUOTE_STATUS';
    }
    get isEnquiryReports() {
        return this.selectedReportkey === 'TECHNICAL_QUERIES' ||
            this.selectedReportkey === 'DATA_QUERIES' ||
            this.selectedReportkey === 'ADDINFO_ENQ' ||
            this.selectedReportkey === 'WR_AND_ENQ' ||
            this.selectedReportkey === 'OPEN_TECHNICAL_QUERIES' ||
            this.selectedReportkey === 'OPEN_DATA_QUERIES'
    }
    get isshowJobCategory() {
        return this.selectedReportkey === 'WR_AND_ENQ';
    }
    get isshowQuoteStatus() {
        return this.selectedReportkey === 'QUOTE_STATUS';
    }
    get isAMRReports() {
        return this.selectedReportkey === 'ALL_AMR' || this.selectedReportkey === 'ALL_OPEN_AMR';
    }
    get isOtherReports() {
        return (
            this.selectedReportkey &&
            this.selectedReportkey !== 'USER_DETAILS' &&
            this.selectedReportkey !== 'WORKORDERS' &&
            this.selectedReportkey !== 'TECHNICAL_QUERIES' &&
            this.selectedReportkey !== 'DATA_QUERIES' &&
            this.selectedReportkey !== 'ADDINFO_ENQ' &&
            this.selectedReportkey !== 'WR_AND_ENQ' &&
            this.selectedReportkey !== 'OPEN_TECHNICAL_QUERIES' &&
            this.selectedReportkey !== 'OPEN_DATA_QUERIES' &&
            this.selectedReportkey !== 'APP_AND_DEAPP' &&
            this.selectedReportkey !== 'QUOTE_STATUS' &&
            this.selectedReportkey !== 'ALL_AMR' &&
            this.selectedReportkey !== 'ALL_OPEN_AMR'
        );
    }
    setReportTitle(reportKey) {
        switch (reportKey) {
            case 'COMPLETED_PME':
                this.reportTitle = 'Completed PME and Maintenance Jobs';
                this.completed = true;
                this.inprogress = false;
                break;
            case 'INPROGRESS_PME':
                this.reportTitle = 'Inprogress PME and Maintenance Jobs';
                this.inprogress = true;
                this.completed = false;
                break;
            case 'ADDINFO_ENQ':
                this.reportTitle = 'Enquiries Requiring Additional Information';
                break;
            case 'ADDINFO_WO':
                this.reportTitle = 'Work Orders Requiring Additional Information';
                break;
            case 'COMP_WO':
                this.reportTitle = 'Completed Work Order';
                break;
            case 'INPROGRESS_WO':
                this.reportTitle = 'Upcoming Site Visits';
                break;
            case 'USER_DETAILS':
                this.reportTitle = 'User Details Report';
                break;
            case 'TECHNICAL_QUERIES':
                this.reportTitle = 'All Technical Enquiries';
                break;
            case 'DATA_QUERIES':
                this.reportTitle = 'All Data Enquiries';
                break;
            case 'OPEN_TECHNICAL_QUERIES':
                this.reportTitle = 'All Open Technical Enquiries';
                break;
            case 'OPEN_DATA_QUERIES':
                this.reportTitle = 'All Open Data Enquiries';
                break;
            case 'WR_AND_ENQ':
                this.reportTitle = 'All Customer Work Requests and Enquiries';
                break;
            case 'WORKORDERS':
                this.reportTitle = 'All Customer Work Requests';
                break;
            case 'APP_AND_DEAPP':
                this.reportTitle = 'All Appointments and Deappointment Requests';
                break;
            case 'QUOTE_STATUS':
                this.reportTitle = 'All Quotation Status Report';
                break;
            case 'ALL_AMR':
                this.reportTitle = 'All AMR Work Requests';
                break;
            case 'ALL_OPEN_AMR':
                this.reportTitle = 'All Open AMR Work Requests';
                break;
            default:
                this.reportTitle = 'Report';
        }
    }

    reportColumnConfig = {

        USER_DETAILS: [
            { label: 'FirstName', key: 'FirstName' },
            { label: 'LastName', key: 'LastName' },
            { label: 'Email', key: 'Email' },
            { label: 'UserId', key: 'UserName' },
            { label: 'Profile', key: 'Profile' },
            { label: 'Supplier Group', key: 'supplierGroup' },
            { label: 'Supplier Code', key: 'suppliercode' },
            { label: 'IsActive', key: 'IsActive' },
            { label: 'LastLoginDate', key: 'LastLoginDate' }
        ],

        OtherReports: [
            { label: 'Work Order', key: 'name' },
            { label: 'Status', key: 'status' },
            { label: 'MPRN', key: 'mprn' },
            { label: 'Job Code', key: 'JobCode' },
            { label: 'Job Code Description', key: 'JobDescription' },
            { label: 'Completion Date', key: 'CompletionDate' },
            // { label: 'Job Category', key: 'jobcategory' },
            // { label: 'Sub Category', key: 'subcategory' },
            { label: 'Supplier Code', key: 'suppliercode' }
        ],

        APP_DEAPP_Reports: [
            { label: 'Name', key: 'name' },
            { label: 'MPRN', key: 'mprn' },
            { label: 'Supplier Code', key: 'suppliercode' },
            { label: 'Status', key: 'status' },
            { label: 'Reason Code', key: 'ReasonCode' },
            { label: 'Type Code', key: 'TypeCode' },
            { label: 'Created Date', key: 'CreatedDate' },
            { label: 'From Date', key: 'fromDate' },
            { label: 'To Date', key: 'toDate' }
        ],

        EnquiryReports: [
            { label: 'Name', key: 'name' },
            { label: 'Service Request', key: 'SRnumber' },
            { label: 'Status', key: 'status' },
            { label: 'MPRN', key: 'mprn' },
            { label: 'Supplier Code', key: 'suppliercode' },
            { label: 'Enquiry Type', key: 'EnquiryType' },
            { label: 'Enquiry Category', key: 'EnquiryCategorydescprition' },
            { label: 'Reason Code', key: 'ReasonDescription' },
            { label: 'Start Date', key: 'Startdate' },
            { label: 'End Date', key: 'Enddate' },
            { label: 'Building Name', key: 'BuildingName' },
            { label: 'Building Number', key: 'BuildingNumber' },
            { label: 'Street', key: 'Street' },
            { label: 'Dependent Locality', key: 'DependentLocality' },
            { label: 'Town', key: 'Town' },
            { label: 'PostCode', key: 'PostCode' },
            // { label: 'Customer Name', key: 'CustomerName' },
            // { label: 'Customer Number', key: 'CustomerNumber' }
        ],
        AMRReports: [
            { label: 'Name', key: 'name' },
            { label: 'MPRN', key: 'mprn' },
            { label: 'Supplier Code', key: 'suppliercode' },
            { label: 'Service Request', key: 'SRnumber' },
            { label: 'Status', key: 'status' },
            { label: 'Job Category', key: 'jobcategory' },
            { label: 'AppointmentStartDate', key: 'AppointmentStartDate' },
            { label: 'MAM ID', key: 'MAMID' },
            { label: 'Service Level', key: 'ServiceLevel' },
            { label: 'Annual Consumption', key: 'AnnualConsumption' },
            { label: 'Address', key: 'Address' },
            { label: 'Town', key: 'Town' },
            { label: 'PostCode', key: 'PostCode' },
            { label: 'Customer Name', key: 'CustomerName' },
            { label: 'Customer Number', key: 'CustomerNumber' },
            { label: 'CustomerEmail', key: 'CustomerEmail' }
        ],
        WOANDENQReports: [
            { label: 'Name', key: 'name' },
            { label: 'Status', key: 'status' },
            { label: 'MPRN', key: 'mprn' },
            { label: 'Job Category', key: 'jobcategory' },
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
        ],
        QUOTESTATUS: [
            { label: 'Request Number', key: 'name' },
            { label: 'SR Number', key: 'SRnumber' },
            { label: 'Quotation Status', key: 'QuotationStatus' },
            { label: 'MPRN', key: 'mprn' },
            { label: 'Job Category', key: 'jobcategory' },
            { label: 'Sub Category', key: 'subcategory' },
            { label: 'Supplier Code', key: 'suppliercode' },
            { label: 'Created On', key: 'CreatedOn' },
            { label: 'Building Name', key: 'BuildingName' },
            { label: 'Building Number', key: 'BuildingNumber' },
            { label: 'Street', key: 'Street' },
            { label: 'Dependent Locality', key: 'DependentLocality' },
            { label: 'Town', key: 'Town' },
            { label: 'PostCode', key: 'PostCode' },
            { label: 'Customer Name', key: 'CustomerName' },
            { label: 'Customer Number', key: 'CustomerNumber' }
        ],

        WORKORDERS: [
            { label: 'Request Number', key: 'name' },
            { label: 'SR Number', key: 'SRnumber' },
            { label: 'Status', key: 'status' },
            { label: 'MPRN', key: 'mprn' },
            { label: 'Job Category', key: 'jobcategory' },
            { label: 'Sub Category', key: 'subcategory' },
            { label: 'Supplier Code', key: 'suppliercode' },
            { label: 'Created On', key: 'CreatedOn' },
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
    getCurrentColumns() {
        // If USER_DETAILS → use its own config
        if (this.currentReportKey === 'USER_DETAILS') {
            return this.reportColumnConfig.USER_DETAILS;
        }
        else if (this.currentReportKey === 'Other_REPORTSIP') {
            return this.reportColumnConfig.WORKORDERS;
        }
        else if (this.currentReportKey === 'WORKORDERS') {
            return this.reportColumnConfig.WORKORDERS;
        }
        else if (this.currentReportKey === 'QUOTE_STATUS') {
            return this.reportColumnConfig.QUOTESTATUS;
        }
        else if (this.currentReportKey === 'TECHNICAL_QUERIES' || this.currentReportKey === 'DATA_QUERIES' || this.currentReportKey === 'ADDINFO_ENQ'
            || this.currentReportKey === 'OPEN_TECHNICAL_QUERIES' || this.currentReportKey === 'OPEN_DATA_QUERIES'
        ) {
            return this.reportColumnConfig.EnquiryReports;
        }
        else if (this.currentReportKey === 'WR_AND_ENQ') {
            return this.reportColumnConfig.WOANDENQReports;
        }
        else if (this.currentReportKey === 'APP_AND_DEAPP') {
            return this.reportColumnConfig.APP_DEAPP_Reports;
        }
        else if (this.currentReportKey === 'ALL_AMR' || this.currentReportKey === 'ALL_OPEN_AMR') {
            return this.reportColumnConfig.AMRReports;
        }

        let columns = this.reportColumnConfig.OtherReports;
        if (this.completed) {
            return columns.filter(col =>
                !['JobCode'].includes(col.key)
            );
        }
        if (this.inprogress) {
            return columns.filter(col =>
                !['CompletionDate'].includes(col.key)
            );
        }

        return columns;

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

        const bom = '\uFEFF';
        const content = csvRows.join('\r\n');
        const blob = new Blob([bom, content], { type: 'application/octet-stream' });

        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `${this.reportTitle || 'Report'}_All_Pages.csv`;
        link.target = '_self';

        document.body.appendChild(link);
        link.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true, view: window }));
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
    }
    handleReportsController(event) {
        console.log('handleReportsController');
        this.showDetailView = false;
        this.showListView = true;
    }
}