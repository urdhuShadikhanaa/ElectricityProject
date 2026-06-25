import { LightningElement, api } from 'lwc';
import { mapAvfcToPortalAddress } from 'c/ngmAddressMapper';

export default class NgmAddressVerification extends LightningElement {
    @api autoStart = false;

    showSearch = false;
    searchReady = false;
    retryCount = 0;

    connectedCallback() {
        if (this.autoStart) {
            this.startSearch();
        }
    }

    @api
    startSearch() {
        this.showSearch = true;
        this.searchReady = false;
        this.retryCount = 0;
    }

    handleVerifyClick() {
        this.startSearch();
    }

    renderedCallback() {
        if (this.showSearch && !this.searchReady) {
            this.openSearchPanel();
        }
    }

    openSearchPanel() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        window.setTimeout(() => {
            const avfc = this.template.querySelector(
                'pw_avfc-address-verification-flow-base-component'
            );

            if (!avfc) {
                this.scheduleRetry();
                return;
            }

            const roots = [];
            if (avfc.shadowRoot) {
                roots.push(avfc.shadowRoot);
            }
            roots.push(avfc);

            for (const root of roots) {
                const elements = root.querySelectorAll('a, button, span, div, label');
                for (const element of elements) {
                    const text = (element.textContent || '').trim();
                    if (text === 'Verify Address') {
                        element.click();
                        this.searchReady = true;
                        return;
                    }
                }
            }

            this.scheduleRetry();
        }, 200);
    }

    scheduleRetry() {
        if (this.searchReady || this.retryCount >= 15) {
            return;
        }

        this.retryCount += 1;
        this.openSearchPanel();
    }

    handleAddressChange(event) {
        const address = event.detail?.address || event.detail;
        const portalAddress = mapAvfcToPortalAddress(address);

        this.showSearch = false;
        this.searchReady = false;

        this.dispatchEvent(
            new CustomEvent('addressverified', {
                detail: portalAddress,
                bubbles: true,
                composed: true
            })
        );
    }
}