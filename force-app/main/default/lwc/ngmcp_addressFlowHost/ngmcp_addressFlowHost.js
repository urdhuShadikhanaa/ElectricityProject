import { LightningElement } from 'lwc';

export default class Ngmcp_addressFlowHost extends LightningElement {
    handleAddressChange(event) {
        this.dispatchEvent(
            new CustomEvent('addresschange', {
                detail: event.detail,
                bubbles: true,
                composed: true
            })
        );
    }
}