import { LightningElement, track } from 'lwc';
import getActiveNGMCPAnnouncements from '@salesforce/apex/NGMCP_PortalBannerController.getActiveNGMCPAnnouncements';
import { getBannerClass } from './ngmcpPortalBannerHelper';

export default class NgmcpPortalBanner extends LightningElement {
    @track NGMCPAnnouncements = [];

    connectedCallback() {
        getActiveNGMCPAnnouncements()
            .then(result => {
                if (result && result.length > 0) {
                    const today = new Date();
                    this.NGMCPAnnouncements = result
                        .filter(banner => banner.NGMCP_IsActive__c)
                        .map(banner => ({
                            ...banner,
                            bannerClass: getBannerClass(banner.NGMCP_Severity__c),
                            visible: true // Add visibility flag per banner
                        }));
                }
            })
            .catch(error => {
                console.error('Error fetching banner data:', error);
            });
    }

    get showBanner() {
        return this.NGMCPAnnouncements.some(b => b.visible);
    }

    handleAlertClose(event) {
        const bannerKey = event.target.dataset.key;
        this.NGMCPAnnouncements = this.NGMCPAnnouncements.map(banner => {
            if (banner.DeveloperName === bannerKey) {
                return { ...banner, visible: false };
            }
            return banner;
        });
    }
}