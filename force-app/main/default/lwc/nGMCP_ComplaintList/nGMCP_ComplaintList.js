import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
//import getComplaints from '@salesforce/apex/NGMCP_ComplaintController.getComplaints';

export default class Ngmcp_ComplaintStatus extends LightningElement {
   @track complaints;
   @track allComplaints;
   @track error;
   @track selectedStatus = '';
   @track fromDate;
   @track toDate;
   @track searchKey = '';
   @track isModalOpen = false;
   @track selectedRecord;
   hideOnRecordPage = false;
   previousFilter = null;
   // Status filter options
   get statusOptions() {
       return [
           { label: 'All', value: '' },
           { label: 'New', value: 'New' },
           { label: 'In Progress', value: 'In Progress' },
           { label: 'Closed', value: 'Closed' }
       ];
   }
  
@wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        const currentFilter = currentPageReference?.state?.filterName;
        console.log('Current Filter:', currentFilter);

        if (currentFilter && currentFilter !== this.previousFilter) {
            this.previousFilter = currentFilter;
            this.hideOnRecordPage = currentFilter === 'Recent';
        }
    }

   /* @wire(getComplaints)
    wiredComplaints({ data, error }) {
        if (data) {
            this.allComplaints = data.map(rec => ({
                ...rec,
                linkName: `/customerportal/case/${rec.Id}`,
                CreatedByName: rec.CreatedBy?.Name
            }));
            this.complaints = this.allComplaints;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.complaints = undefined;
        }
    }*/

   // Datatable columns
   get columns() {
       return [
           {
               label: 'Complaint Number',
               fieldName: 'linkName',
               type: 'url',
               typeAttributes: { label: { fieldName: 'CaseNumber' }, target: '_blank' }
           },
           { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
           { label: 'Created By', fieldName: 'CreatedByName', type: 'text' },
           { label: 'Status', fieldName: 'Status', type: 'text' },
           { label: 'Category', fieldName: 'Category__c', type: 'text' },
           { label: 'Subcategory', fieldName: 'Sub_Category__c', type: 'text' },
           { label: 'Customer Name', fieldName: 'CRM_End_Consumer_Name__c', type: 'text' },
           { label: 'House Name', fieldName: 'CRM_House_Name_Number_Site_Name__c', type: 'text' },
           { label: 'Street', fieldName: 'CRM_Street__c', type: 'text' },
           { label: 'City/Country', fieldName: 'CRM_City_County__c', type: 'text' },
           { label: 'Postcode', fieldName: 'CRM_Post_code__c', type: 'text' },
        // {
        //        type: 'button',
        //        fixedWidth: 140,
        //        typeAttributes: {
        //            label: 'View Details',
        //            name: 'view_details',
        //            variant: 'brand'
        //        }
        //    }
        ];
   }
   // Handlers for filters
   handleFilterChange(event) {
       this.selectedStatus = event.detail.value;
       this.applyFilters();
   }
   handleDateChange(event) {
       const label = event.target.label;
       if (label === 'From Date') this.fromDate = event.target.value;
       if (label === 'To Date') this.toDate = event.target.value;
       this.applyFilters();
   }
   handleSearchChange(event) {
       this.searchKey = event.target.value;
       this.applyFilters();
   }
   // Apply filters
   applyFilters() {
       if (!this.allComplaints) return;
       let filtered = [...this.allComplaints];
       // Filter by Status
       if (this.selectedStatus) {
           filtered = filtered.filter(rec => rec.Status === this.selectedStatus);
       }
       // Filter by Date Range
       if (this.fromDate && this.toDate) {
           filtered = filtered.filter(rec => {
               const created = new Date(rec.CreatedDate);
               return created >= new Date(this.fromDate) && created <= new Date(this.toDate);
           });
       }
       // Search by Case Number or MPRN
       if (this.searchKey) {
           const key = this.searchKey.toLowerCase();
           filtered = filtered.filter(rec =>
               (rec.CaseNumber && rec.CaseNumber.toLowerCase().includes(key)) ||
               (rec.CRM_MPRN__c && rec.CRM_MPRN__c.toLowerCase().includes(key))
           );
       }
       this.complaints = filtered;
   }
   // Modal handling
   handleRowAction(event) {
       const actionName = event.detail.action.name;
       const row = event.detail.row;
       if (actionName === 'view_details') {
           this.selectedRecord = row;
           this.isModalOpen = true;
       }
   }
   closeModal() {
       this.isModalOpen = false;
   }
}