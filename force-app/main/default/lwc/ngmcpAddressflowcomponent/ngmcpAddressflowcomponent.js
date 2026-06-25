import { LightningElement } from 'lwc';

export default class NgmcpAddressflowcomponent extends LightningElement {
    showSearch = false;
    searchReady = false;
    retryCount = 0;
    selectedAddress = null;
    verifyFlag = true;

    get hasOutput() {
        return this.selectedAddress !== null;
    }
    connectedCallback() {
        this.handleVerifyClick();
    }
    handleVerifyClick() {
        this.showSearch = true;
        this.searchReady = false;
        this.retryCount = 0;
        this.selectedAddress = this.selectedAddress ? this.selectedAddress : null;
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
            console.log('roots', JSON.stringify(roots));
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
        console.log('handleAddressChange', JSON.stringify(address));
        this.selectedAddress = {
            street: address?.street || '',
            street2: address?.street2 || '',
            city: address?.city || '',
            state: address?.state || '',
            postalcode: address?.postalCode || '',
            country: address?.country || '',
            county: address?.county || '',
            status: (address?.status || '').replace(/\u200B/g, '').trim()
        };
        console.log('selectedAddress', JSON.stringify(this.selectedAddress));
        this.showSearch = false;
        setTimeout(() => {
            this.handleVerifyClick();
        }, 10);

        const addressEvent = new CustomEvent('addresschange', {
            detail: this.selectedAddress
        });

        this.dispatchEvent(addressEvent);

    }
}