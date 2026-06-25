import { LightningElement, track} from 'lwc';

export default class NGMCP_CommonSideWizard extends LightningElement {

    @track requestsExpanded = false;

    get requestsArrow() {
        return this.requestsExpanded ? '▼' : '▶';
    }

    toggleRequests() {
        this.requestsExpanded = !this.requestsExpanded;
    }

    handleMenuClick(event) {
        const menu = event.target.dataset.menu;
        console.log('Clicked:', menu);
    }

}