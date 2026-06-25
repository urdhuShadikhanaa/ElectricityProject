import { LightningElement, track,api, wire } from 'lwc';
import LOGO from '@salesforce/resourceUrl/NGMCP_LOGO';
import COLLAPSE_ICON from '@salesforce/resourceUrl/NGMCP_collapseIcon'; // your collapse icon
import EXPAND_ICON from '@salesforce/resourceUrl/NGMCP_expandIcon';     // your expand icon NGMCP_bellIcon
import BELL_ICON from '@salesforce/resourceUrl/NGMCP_bellIcon'; // replace with your static resource name
import USER_ICON from '@salesforce/resourceUrl/NGMCP_userIcon'; 
import getUserProfileName from '@salesforce/apex/NGMCP_HomeProfileController.getUserProfileName';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import NGMCP_Home from '@salesforce/resourceUrl/NGMCP_Home';
import NGMCP_Requests from '@salesforce/resourceUrl/NGMCP_Requests';
import NGMCP_Create from '@salesforce/resourceUrl/NGMCP_CreateRequest';
import NGMCP_Bulk from '@salesforce/resourceUrl/NGMCP_BulkCreation';
import NGMCP_View from '@salesforce/resourceUrl/NGMCP_ViewRequest';
import NGMCP_SR from '@salesforce/resourceUrl/NGMCP_SRNumber';
import NGMCP_WO from '@salesforce/resourceUrl/NGMCP_WONumber';
import NGMCP_Reports from '@salesforce/resourceUrl/NGMCP_Reports';
import NGMCP_User from '@salesforce/resourceUrl/NGMCP_User';
import NGMCP_Files from '@salesforce/resourceUrl/NGMCP_MonthlyPacks';

export default class NGMCP_VerticalTabWizard extends NavigationMixin(LightningElement) {
    // assets
    logoUrl = LOGO;
    collapseIcon = COLLAPSE_ICON;
    expandIcon = EXPAND_ICON;
    bellIconUrl = BELL_ICON;
    userIconUrl = USER_ICON;
    homeIcon = NGMCP_Home;
    requestsIcon = NGMCP_Requests;
     createIcon = NGMCP_Create;
    bulkIcon = NGMCP_Bulk;
    viewIcon = NGMCP_View;
    srIcon = NGMCP_SR;
    woIcon = NGMCP_WO;
    reportsIcon = NGMCP_Reports;
    userIcon = NGMCP_User;
    filesIcon = NGMCP_Files;
    
    @track decodedAssetData;
    // external input
    // @api mprnNumber = '123456789';

    // reactive state
    @track activeMenu = 'home'; // home is active by default
    @track isRequestOpen = true; // requests submenu collapsed initially
    @track isrequestSubmenus = true; // requests submenu collapsed initially
    @track isReportsActive = false;
     showReportTab = false;
     showUserTab = false;
     showFilesTab = false;

    connectedCallback() {
        // ensure Requests submenu opens if the active menu is a Requests item
        if (this.activeMenu === 'createRequest' || this.activeMenu === 'viewRequest' || this.activeMenu === 'requests') {
            this.isRequestOpen = true;
        }
         if (this.activeMenu === 'SRNumber' || this.activeMenu === 'WONumber' || this.activeMenu === 'requests') {
            this.isrequestSubmenus = true;
        }
        this.setTabVisibility();
    }

     @wire(CurrentPageReference)
        getStateParameters(currentPageReference) {
        try {
                if (currentPageReference?.state?.data) {
                    const decodedString = atob(currentPageReference.state.data);
                    this.decodedAssetData = JSON.parse(decodedString);
                    this.errorMessage = 'No page reference available.';
                    console.log('Parent decoded data : ',JSON.stringify(this.decodedAssetData));
                    
                }
            } catch (error) {
                console.error('Error decoding data IN PARENT', error);
            }
        }

    // icon getter for requests (collapse/expand)
    get requestArrowIcon() {
        return this.isRequestOpen ? this.collapseIcon : this.expandIcon;
    }
    get sWrequestArrowIcon() {
        return (this.isrequestSubmenus) ? this.collapseIcon : this.expandIcon;
    }

    // Active-state getters used by template
    get isHomeActive() { return this.activeMenu === 'home'; }
    get isReportsActive() { return this.activeMenu === 'reports'; }
    get isRequestsActive() { return this.activeMenu === 'requests'; }
    get isUserActive() { return this.activeMenu === 'user'; }
    get isCreateRequestActive() { return this.activeMenu === 'createRequest'; }
    get isViewRequestActive() { return this.activeMenu === 'viewRequest'; }
    get isSRNumberActive() { return this.activeMenu === 'SRNumber'; }
    get isWONumberActive() { return this.activeMenu === 'WONumber'; }
    get isMonthlyPacksActive() { return this.activeMenu === 'monthlypacks'; }

    // Class getters for binding to class={...} in template (include static class name)
    get homeClass() { return this.activeMenu === 'home' ? 'menu-item active' : 'menu-item'; }
    get requestsClass() { return this.activeMenu === 'requests' ? 'menu-item active' : 'menu-item'; }
    get createRequestClass() { return this.activeMenu === 'createRequest' ? 'submenu active' : 'submenu'; }
    get viewRequestClass() { return this.activeMenu === 'viewRequest' ? 'menu-item active' : 'menu-item'; }
    get sRRequestClass() { return this.activeMenu === 'SRNumber' ? 'submenu-branch active' : 'submenu-branch'; }
    get wORequestClass() { return this.activeMenu === 'WONumber' ? 'submenu-branch active' : 'submenu-branch'; }
    get reportsClass() { return this.activeMenu === 'reports' ? 'menu-item active' : 'menu-item'; }
    get userClass() { return this.activeMenu === 'user' ? 'menu-item active' : 'menu-item'; }
    get fileClass() { return this.activeMenu === 'monthlypacks' ? 'menu-item active' : 'menu-item'; }

    // Menu click handler (data-id on <li> required)
    handleMenuClick(event) {
        const menuId = event.currentTarget.dataset.id;
        if (!menuId) {
            return;
        }

        // set active menu
        this.activeMenu = menuId;

         // HOME NAVIGATION
    if (menuId === 'home') {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
        return; 
    }

        // control Requests submenu visibility:
        // - clicking Requests toggles it
        // - clicking a Requests submenu ensures it stays open
        // - clicking other menus closes it
        if (menuId === 'requests') {
            this.isRequestOpen = !this.isRequestOpen;
        } else if (menuId === 'createRequest' || menuId === 'viewRequest') {
            this.isRequestOpen = true;
        } else {
            this.isRequestOpen = false;
        }
         if (menuId === 'viewRequest') {
            this.isrequestSubmenus = !this.isrequestSubmenus;
        } else if (menuId === 'SRNumber' || menuId === 'WONumber') {
            this.isRequestOpen = true;
            this.isrequestSubmenus = true;

        } else {
            this.isrequestSubmenus = false;
        }
        if (menuId === 'reports') {
            this.isReportsActive = true;
        }else{
            this.isReportsActive = false;
        }
        
        // No DOM classList manipulation required because classes are bound via getters.
        // If you previously used classList manipulation, remove it to avoid conflicts.
    }

    // (Optional) if you still need a single getter for content use it; HTML currently uses per-template blocks.
    get contentToDisplay() {
        switch (this.activeMenu) {
            case 'home': return 'Home content goes here.';
            case 'reports': return 'Reports content goes here.';
            case 'user': return 'User profile content goes here.';
            case 'createRequest': return 'Create Request form goes here.';
            case 'viewRequest': return 'View Request details go here.';
            case 'monthlypacks': return 'Monthly Packs content goes here.';
            default: return '';
        }
    }
setTabVisibility(){
        getUserProfileName() 
        .then(profileName => {
            console.log('Logged in profile:', profileName);
 
            if (
                profileName === 'CRM Profile' ||
                profileName === 'System Administrator' ||
                profileName === 'NGMCP_Gas Supplier Manager'
            ) {
                this.showReportsTab = true;
                this.showUserTab = true;
                this.showFilesTab = true;
            } else {
                // Gas Supplier Agent
                this.showReportsTab = false;
                this.showUserTab = false;
                this.showFilesTab = false;
            }
        })
        .catch(error => {
            console.error('Profile fetch error', error);
        });
}


}