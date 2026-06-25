import { LightningElement, api } from 'lwc';
import BELL_ICON from '@salesforce/resourceUrl/NGMCP_bellIcon'; // replace with your static resource name
import USER_ICON from '@salesforce/resourceUrl/NGMCP_userIcon'; 
export default class NGMCP_BreadcrumbsHeader extends LightningElement {
    @api mprnNumber = '123456789';
    bellIconUrl = BELL_ICON;
    userIconUrl = USER_ICON;

}