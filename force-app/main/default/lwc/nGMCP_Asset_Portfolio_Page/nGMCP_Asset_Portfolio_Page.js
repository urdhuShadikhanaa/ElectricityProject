import { LightningElement , track} from 'lwc';

export default class NGMCP_Asset_Portfolio_Page extends LightningElement {
  @track activeTab = 'home';
  @track isRequestExpanded = false;

  get homeClass() {
    return this.activeTab === 'home' ? 'active' : '';
  }
  get requestClass() {
    return this.activeTab === 'request' ? 'active' : '';
  }
  get reportsClass() {
    return this.activeTab === 'reports' ? 'active' : '';
  }
  get userClass() {
    return this.activeTab === 'user' ? 'active' : '';
  }
  get createRequestClass() {
    return this.activeTab === 'createRequest' ? 'active-sub' : '';
  }
  get viewRequestClass() {
    return this.activeTab === 'viewRequests' ? 'active-sub' : '';
  }

  handleHomeClick() {
    this.activeTab = 'home';
    this.isRequestExpanded = false;
  }
  toggleRequestMenu() {
    this.isRequestExpanded = !this.isRequestExpanded;
    this.activeTab = 'request';
  }
  handleCreateRequest() {
    this.activeTab = 'createRequest';
  }
  handleViewRequests() {
    this.activeTab = 'viewRequests';
  }
  handleReportsClick() {
    this.activeTab = 'reports';
    this.isRequestExpanded = false;
  }
  handleUserClick() {
    this.activeTab = 'user';
    this.isRequestExpanded = false;
  }
}