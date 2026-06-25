import { LightningElement, track,api } from 'lwc';
import LOGO from '@salesforce/resourceUrl/NGMCP_LOGO';
import COLLAPSE_ICON from '@salesforce/resourceUrl/NGMCP_collapseIcon'; // your collapse icon
import EXPAND_ICON from '@salesforce/resourceUrl/NGMCP_expandIcon';     // your expand icon NGMCP_bellIcon
import BELL_ICON from '@salesforce/resourceUrl/NGMCP_bellIcon'; // replace with your static resource name
import USER_ICON from '@salesforce/resourceUrl/NGMCP_userIcon'; 
export default class NGMCP_VerticalWizard extends LightningElement {
    // assets
    logoUrl = LOGO;
    collapseIcon = COLLAPSE_ICON;
    expandIcon = EXPAND_ICON;
    bellIconUrl = BELL_ICON;
    userIconUrl = USER_ICON;

    // external input
    @api mprnNumber = '123456789';

    // reactive state
    @track activeMenu = 'home'; // home is active by default
    @track isRequestOpen = false; // requests submenu collapsed initially

    connectedCallback() {
        // ensure Requests submenu opens if the active menu is a Requests item
        if (this.activeMenu === 'createRequest' || this.activeMenu === 'viewRequest' || this.activeMenu === 'requests') {
            this.isRequestOpen = true;
        }
    }

    // icon getter for requests (collapse/expand)
    get requestArrowIcon() {
        return this.isRequestOpen ? this.collapseIcon : this.expandIcon;
    }

    // Active-state getters used by template
    get isHomeActive() { return this.activeMenu === 'home'; }
    get isReportsActive() { return this.activeMenu === 'reports'; }
    get isUserActive() { return this.activeMenu === 'user'; }
    get isCreateRequestActive() { return this.activeMenu === 'createRequest'; }
    get isViewRequestActive() { return this.activeMenu === 'viewRequest'; }

    // Class getters for binding to class={...} in template (include static class name)
    get homeClass() { return this.activeMenu === 'home' ? 'menu-item active' : 'menu-item'; }
    get requestsClass() { return this.activeMenu === 'requests' ? 'menu-item active' : 'menu-item'; }
    get createRequestClass() { return this.activeMenu === 'createRequest' ? 'submenu active' : 'submenu'; }
    get viewRequestClass() { return this.activeMenu === 'viewRequest' ? 'submenu active' : 'submenu'; }
    get reportsClass() { return this.activeMenu === 'reports' ? 'menu-item active' : 'menu-item'; }
    get userClass() { return this.activeMenu === 'user' ? 'menu-item active' : 'menu-item'; }

    // Menu click handler (data-id on <li> required)
    handleMenuClick(event) {
        const menuId = event.currentTarget.dataset.id;
        if (!menuId) {
            return;
        }

        // set active menu
        this.activeMenu = menuId;

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
            default: return '';
        }
    }



}