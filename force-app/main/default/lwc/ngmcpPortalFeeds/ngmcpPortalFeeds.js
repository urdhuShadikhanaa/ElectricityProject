import { LightningElement } from 'lwc';
import NGMCP_Help_Centre from '@salesforce/label/c.NGMCP_Help_Centre';
import NGMCP_FAQs from '@salesforce/label/c.NGMCP_FAQs';
import NGMCP_Contact_us from '@salesforce/label/c.NGMCP_Contact_us';
import NGMCP_Terms_and_Conditions from '@salesforce/label/c.NGMCP_Terms_and_Conditions';
import NGMCP_emergency_service from '@salesforce/label/c.NGMCP_emergency_service';
import NGMCP_Our_Metering_Web_Site from '@salesforce/label/c.NGMCP_emergency_service';
export default class NgmcpPortalFooter extends LightningElement {
    labels = {
        Help_Centre: NGMCP_Help_Centre,
        FAQs: NGMCP_FAQs,
        Contact_us: NGMCP_Contact_us,
        Terms_and_Conditions: NGMCP_Terms_and_Conditions,
        Meterting_Web_Site: NGMCP_Our_Metering_Web_Site,
        emergency_service: NGMCP_emergency_service
    };
}