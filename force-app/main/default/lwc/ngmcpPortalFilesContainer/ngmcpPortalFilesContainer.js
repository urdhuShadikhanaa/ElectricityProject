import { LightningElement } from 'lwc';
import basePath from '@salesforce/community/basePath';
import getFiles from '@salesforce/apex/ngmcp_PortalFilesController.getFiles';

export default class NgmcpPortalFilesContainer extends LightningElement {

   // recordId = '001du00000BZcDrAAL'; //  Your Document Account Id
    rows = [];
 
    connectedCallback() {
        getFiles({ recordId: this.recordId })
            .then(data => {
                this.rows = data.map(row => ({
                    ...row,
                    downloadUrl: `${basePath}/sfc/servlet.shepherd/document/download/${row.documentId}`
                }));
            })
            .catch(error => {
                console.error(error);
            });
    }
}