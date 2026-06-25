import { LightningElement, track, api} from 'lwc';
import LOGO from '@salesforce/resourceUrl/NGMCP_LOGO';
import BELL_ICON from '@salesforce/resourceUrl/NGMCP_bellIcon'; 
import logoutIcon from '@salesforce/resourceUrl/NGMCP_logout'; 
import communityPath from '@salesforce/label/c.NGMCP_CommunityPath';


export default class NGMCP_HomeScreenHeader extends LightningElement {
    logoUrl = LOGO;
    bellIconUrl = BELL_ICON;
    logoutUrl = logoutIcon;
    @api mprnNumber;
// logout changes start (updated by Vivek)
handleLogout() {
    const baseUrl = window.location.origin; 
    const communityPath = '/customerportal';

    const loginUrl = `${baseUrl}${communityPath}/login`;

    const logoutUrl =
        `${communityPath}/secur/logout.jsp?retUrl=` +
        encodeURIComponent(loginUrl);

    window.location.replace(logoutUrl);
}



// logout changes end


}