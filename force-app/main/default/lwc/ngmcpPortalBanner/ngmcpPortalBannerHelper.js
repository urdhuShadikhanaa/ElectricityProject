// ngmcpPortalBannerHelper.js
export function getBannerClass(severity) {
    switch (severity) {
        case 'Critical': return 'critical-banner slds-p-horizontal_xx-large slds-p-vertical_x-small slds-grid slds-size_1-of-1 slds-m-vertical_medium';
        case 'Warning': return 'warning-banner slds-p-horizontal_xx-large slds-p-vertical_x-small slds-grid slds-size_1-of-1 slds-m-vertical_medium';
        case 'Success': return 'success-banner slds-p-horizontal_xx-large slds-p-vertical_x-small slds-grid slds-size_1-of-1 slds-m-vertical_medium';
        case 'Info': return 'info-banner slds-p-horizontal_xx-large slds-p-vertical_x-small slds-grid slds-size_1-of-1 slds-m-vertical_medium';
        default: return 'info-banner slds-p-horizontal_xx-large slds-p-vertical_x-small slds-grid slds-size_1-of-1 slds-m-vertical_medium';
    }
}