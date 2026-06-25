import { LightningElement, wire, track } from 'lwc';
import fetchAssetDetails from '@salesforce/apex/ngCaseAppointmentsController.fetchAssetById';
//import assetImage from '@salesforce/resourceUrl/ngAssetDetail';
import fetchAMRByAssetId from '@salesforce/apex/ngCaseAppointmentsController.fetchAMRByAssetId';
import fetchAssetAttachments from '@salesforce/apex/ngCaseAppointmentsController.fetchAssetAttachments';
import getWorkOrdersByAssetId from '@salesforce/apex/ngCaseAppointmentsController.getWorkOrdersByAssetId';
import getRegulatorsByAssetId from '@salesforce/apex/ngCaseAppointmentsController.getRegulatorsByAssetId';
import getQueryLogsByAssetId from '@salesforce/apex/ngCaseAppointmentsController.getQueryLogsByAssetId';
import fetchAssetHistoryByAssetId from '@salesforce/apex/ngCaseAppointmentsController.fetchAssetHistoryByAssetId';


export default class NgAssetDetailPage extends LightningElement {
    @track asset = {};
    @track selectedTab = 'Overview';
    assetId;
    assetImage = assetImage;
    @track amrList = [];
    assetFiles = [];
    jobLogList = [];
    isJobLogAvailable = false;
    @track regulatorList = [];
    isRegulatorAvailable = false;
    @track queryList = [];
    @track isQueryAvailable = false;
    @track assetHistoryList = [];
    @track isHistoryAvailable = false;


    connectedCallback() {
        const url = new URL(window.location.href);
        console.log('url >>', url);
        const mprn = url.searchParams.get('assetId');
        console.log('mprn >>', mprn);
        if (mprn) {
            fetchAssetDetails({ assetId: mprn })
                .then(result => {
                    console.log('result >>', result);
                    this.asset = result;
                    this.assetId = result.Id;
                    console.log('this.assetId >>',this.assetId );
                    console.log('selectedTab', this.selectedTab);
                    this.loadAMR(); 
                    this.loadJobLogs();
                    this.loadRegulators();
                    this.loadQueryLog();
                    this.loadAssetHistory();
                })
                .catch(error => {
                    console.error(error);
                });
        }
    }


    loadQueryLog() {
        getQueryLogsByAssetId({ assetId: this.assetId })
            .then(result => {
                this.queryList = result.map(item => {
                    return {
                        ...item,
                        formattedStart: this.formatDate(item.NG_Appointment_Start_Time__c),
                        formattedFinish: this.formatDate(item.NG_Appointment_End_Time__c),
                        formattedResolve: this.formatDate(item.NG_Appointment_Date__c)
                    };
                });
                this.isQueryAvailable = this.queryList.length > 0;
            })
            .catch(error => {
                console.error('Error loading query logs:', error);
                this.isQueryAvailable = false;
            });
    }

    formatDate(dateStr) {
        if (!dateStr) return '';
        const date = new Date(dateStr);
        const month = date.getMonth() + 1;
        const day = date.getDate();
        const year = date.getFullYear();
        return `${month}/${day}/${year}`;
    }

    loadJobLogs() {
        console.log('job logs invoked >>', this.assetId);
        getWorkOrdersByAssetId({ assetId: this.assetId })
            .then(result => {
                console.log('job logs >>', result);
                if (result && result.length > 0) {
                    this.jobLogList = result.map(job => {
                        return {
                            ...job,
                            formattedStart: this.formatDate(job.FFA_UnplannedPolicyStartDate__c),
                            formattedEnd: this.formatDate(job.FFA_UnplannedPolicyEndDate__c),
                            formattedCompletion: this.formatDate(job.FFA_CompletionDateAndTime__c)
                        };
                    });
                    this.isJobLogAvailable = true;
                } else {
                    this.isJobLogAvailable = false;
                }
            })
            .catch(error => {
                console.error('Error fetching job logs:', error);
                this.isJobLogAvailable = false;
            });
    }

    formatDate(dateStr) {
        if (!dateStr) return '';
        const dt = new Date(dateStr);
        const pad = n => n.toString().padStart(2, '0');
        return `${pad(dt.getDate())}/${pad(dt.getMonth() + 1)}/${dt.getFullYear()} ${pad(dt.getHours())}:${pad(dt.getMinutes())}`;
    }

    handleTabClick(event) {
        this.selectedTab = event.currentTarget.dataset.tab;
        if (this.selectedTab === 'AMR') {
            this.loadAMR();
        }
        if (this.selectedTab === 'Photos') {
            this.loadAssetAttachments();
        }
        if(this.selectedTab === 'Regulator'){
            this.loadRegulators();
        }
        if(this.selectedTab === 'JobsLog'){
            this.loadJobLogs();
        }
    }

    loadAMR() {
        fetchAMRByAssetId({ assetId: this.assetId })
            .then(result => {
                this.amrList = result.map(amr => {
                    const dateObj = new Date(amr.Timestamp__c);

                    const month = dateObj.getMonth() + 1;
                    const day = dateObj.getDate();
                    const year = dateObj.getFullYear();

                    const hours = dateObj.getHours().toString().padStart(2, '0');
                    const minutes = dateObj.getMinutes().toString().padStart(2, '0');

                    const formattedDate = `${month}/${day}/${year} ${hours}:${minutes}`;

                    return {
                        ...amr,
                        formattedDate
                    };
                });
                console.log('amrList >>',this.amrList);
            })
            .catch(error => {
                console.error('Error fetching AMR:', error);
            });
    }

    loadAssetAttachments() {
        console.error('loadAssetAttachments called'); 
        console.error('this.assetId >>',this.assetId );
        fetchAssetAttachments({ assetId: this.assetId })
            .then(result => {
                console.log('result >> ', result);
                this.assetFiles = result.map(file => ({
                    // ...file,
                    // fileUrl: `/sfc/servlet.shepherd/version/download/${file.ContentDcoument.LatestPublishedVersionId}`
                    Id: file.ContentDocumentId,
                    Title: file.Title,
                    ContentDownloadUrl: `/sfc/servlet.shepherd/document/download/${file.ContentDocumentId}`

                }));
            })
            .catch(error => {
                console.error('Error loading asset files:', error);
            });
    }
    
    loadRegulators() {
        getRegulatorsByAssetId({ assetId: this.assetId })
            .then(result => {
                console.log('Regulators >> ', result.length);
                if(result && result.length > 0) {
                    this.regulatorList = result;
                    this.isRegulatorAvailable = true;
                }else{
                    this.isRegulatorAvailable = false;
                }
                
            })
            .catch(error => {
                this.isRegulatorAvailable = false;
                console.error('Error loading regulators:', error);
                this.regulatorList = [];
            });
    }

    loadAssetHistory() {
        fetchAssetHistoryByAssetId({ assetId: this.assetId })
            .then(result => {
                this.assetHistoryList = result.map(item => ({
                    ...item,
                    formattedInstallDate: item.Installation_date__c ? new Date(item.Installation_date__c).toLocaleDateString() : '',
                    formattedRemovalDate: item.Removal_date__c ? new Date(item.Removal_date__c).toLocaleDateString() : ''
                }));
                this.isHistoryAvailable = this.assetHistoryList.length > 0;
            })
            .catch(error => {
                console.error('Error fetching Asset History:', error);
            });
    }

    handleEdit() {
        console.log('Edit Address clicked');
    }

    //Asset Details + address
    get overviewTabClass() {
        return this.selectedTab === 'Overview' ? 'tab active' : 'tab';
    }

    //Static data for AMR as it is
    get amrTabClass() {
        return this.selectedTab === 'AMR' ? 'tab active' : 'tab';
     }

     //static data
     get regulatorTabClass() {
        return this.selectedTab === 'Regulator' ? 'tab active' : 'tab';
    }

    // static data from case
    get photosTabClass() {
        return this.selectedTab === 'Photos' ? 'tab active' : 'tab';
    }

    //work order details
    get jobsLogTabClass() {
        return this.selectedTab === 'JobsLog' ? 'tab active' : 'tab';
    }

    //static data
    get queriesLogTabClass() {
        return this.selectedTab === 'QueriesLog' ? 'tab active' : 'tab';
    }

    //work order history
    get meterHistoryTabClass() {
        return this.selectedTab === 'MeterHistory' ? 'tab active' : 'tab';
    }
    get isOverview() {
        return this.selectedTab === 'Overview';
    }

    get isAMR() {
        return this.selectedTab === 'AMR';
    }
    get isRegulator() {
        return this.selectedTab === 'Regulator';
    }
    get isPhotos() {
        return this.selectedTab === 'Photos';
    }
    get isJobsLog() {
        return this.selectedTab === 'JobsLog';
    }
    get isQueriesLog() {
        return this.selectedTab === 'QueriesLog';
    }
    get isMeterHistory() {
        return this.selectedTab === 'MeterHistory';
    }

    get isAMRAvailable() {
        return this.amrList && this.amrList.length > 0;
    }
}