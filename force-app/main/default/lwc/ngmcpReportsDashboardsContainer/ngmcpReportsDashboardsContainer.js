import { LightningElement ,track} from 'lwc';

export default class ReportsDashboardContainer extends LightningElement {
    @track activeTab='reports';
    @track iframeUrl='/lightning/o/Report/home';

    get reportsTabClass(){
        return this.activeTab === 'reports' ? 'tab active' : 'tab';

    }
    get dashboardTabClass(){
        return this.activeTab === 'dashboard' ? 'tab active' : 'tab';
    }

    showReports(){
        this.activeTab='reports';
        this.iframeUrl='/lightning/o/Report/home';
    }
    showDashboard(){
        this.activeTab='dashboard';
        this.iframeUrl='/lightning/o/Dashboard/home';
    }
}