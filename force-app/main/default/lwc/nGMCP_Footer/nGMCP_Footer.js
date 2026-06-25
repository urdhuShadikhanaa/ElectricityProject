/**
 * @description       : DXP-9649    "NESO Qm Footer Changes"
 * @author            : Vivek Kumar
 * @last modified on  : 28-01-2025
 * @last modified by  : Vivek Kumar
 * Modifications Log
 * Ver    Date        Author        Modification
 * 1.0    Vivek Kumar   Initial Version
 * 2.0   Ashwin Prakash Limited Links with no social icons
**/

import { LightningElement } from 'lwc';
import NGMCP_Help_Centre from '@salesforce/label/c.NGMCP_Help_Centre';
import NGMCP_FAQs from '@salesforce/resourceUrl/NGMCPFooterFAQ';
import NGMCP_Contact_us from '@salesforce/label/c.NGMCP_Contact_us';
import NGMCP_View_AMR_Reads from '@salesforce/label/c.NGMCP_View_AMR_Reads';
import LOGO from '@salesforce/resourceUrl/NGMCP_Footer_Logo';
import NGMCP_Terms_and_Conditions from '@salesforce/resourceUrl/NGMCPFooterTC';
import { NavigationMixin } from 'lightning/navigation';
import NGMCP_emergency_service from '@salesforce/label/c.NGMCP_emergency_service';
import NGMCP_Our_Metering_Web_Site from '@salesforce/label/c.NGMCP_MeteringWebsiteURL';
import NGMCP_Complaint from '@salesforce/label/c.NGMCP_MeteringWebsiteURL';
import isGuest from '@salesforce/user/isGuest';

export default class NgmcpPortalFooter extends NavigationMixin(LightningElement) {
    logoUrl = LOGO;
    labels = {
        Help_Centre: NGMCP_Help_Centre,
        FAQs: NGMCP_FAQs,
        Contact_us: NGMCP_Contact_us,
        Terms_and_Conditions: NGMCP_Terms_and_Conditions,
        Meterting_Web_Site: NGMCP_Our_Metering_Web_Site,
        emergency_service: NGMCP_emergency_service,
        View_AMR_Reads:NGMCP_View_AMR_Reads
    };
    pdfUrl = NGMCP_Terms_and_Conditions;
    faqUrl = NGMCP_FAQs;

     isGuestUser = isGuest;

    get showRaiseComplaint() {
        return !this.isGuestUser;
    }
    
   openPdfInNewTab() {
       window.open(encodeURI(this.pdfUrl), '_blank');
       window.open(encodeURI(this.faqUrl), '_blank');
   }
   handlecomplaint() {
       this[NavigationMixin.Navigate]({
           type: 'comm__namedPage',
           attributes: {
               name: 'Complaints__c' 
           }
       });
    }
    handlehelpcentre() {
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Help_Centre__c'
            }
        }).then(url => {
            window.open(url, '_blank');
        });
    }
}