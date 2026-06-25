/**
 * @description       : DXP-9649	"NESO Qm Footer Changes"
 * @author            : Vivek Kumar
 * @last modified on  : 28-01-2025
 * @last modified by  : Vivek Kumar
 * Modifications Log
 * Ver    Date        Author        Modification
 * 1.0    Vivek Kumar   Initial Version
**/


import { LightningElement } from 'lwc';
import NESO_Footer from "@salesforce/resourceUrl/NESO_Footer";
import Youtube from "@salesforce/resourceUrl/ESO_Youtube";
import LinkedIn from "@salesforce/resourceUrl/ESO_LinkedIn";
import Twitter from "@salesforce/resourceUrl/ESO_Twitter";
import NesoHelpCentreLandingPage from '@salesforce/label/c.NesoHelpCentreLandingPage';
import NesoHCFooterLinksWhatWeDo from '@salesforce/label/c.Neso_HC_Footer_Links_What_we_do';
import NesoHCFooterLinksOurStrategy from '@salesforce/label/c.Neso_HC_Footer_Links_Our_strategy';
import NesoHCFooterLinksCareersWithUs from '@salesforce/label/c.Neso_HC_Footer_Links_Careers_with_us';
import NesoHCFooterLinksContactUs from '@salesforce/label/c.Neso_HC_Footer_Links_Contact_us';
import NesoHCFooterLinksReportPowerCut from '@salesforce/label/c.Neso_HC_Footer_Links_How_to_report_a_power_cut';
import NesoHCFooterLinksMediaCentre from '@salesforce/label/c.Neso_HC_Footer_Links_Media_centre';
import NesoHCFooterLinksNationalGridPLC from '@salesforce/label/c.Neso_HC_Footer_Links_National_Grid_PLC';
import NesoHCFooterLinksInvestors from '@salesforce/label/c.Neso_HC_Footer_Links_Investors';
import NesoHCFooterLinksAccessibility from '@salesforce/label/c.Neso_HC_Footer_Links_Accessibility';
import NesoHCFooterLinksPrivacyPolicy from '@salesforce/label/c.Neso_HC_Footer_Links_Privacy_policy';
import NesoHCFooterLinksCookiePolicy from '@salesforce/label/c.Neso_HC_Footer_Links_Cookie_policy';
import NesoHCFooterLinksTermsAndConditions from '@salesforce/label/c.Neso_HC_Footer_Links_Terms_and_conditions';
import NesoHCFooterLinksSecurity from '@salesforce/label/c.Neso_HC_Footer_Links_Security';
import NesoHCFooterLinksModernSlaveryStatement from '@salesforce/label/c.Neso_HC_Footer_Links_Modern_slavery_statement';
import NesoHCFooterLinksAboutNeso from '@salesforce/label/c.Neso_HC_Footer_Links_About_NESO';
import NesoHelpCentreContactUs from '@salesforce/label/c.Neso_HC_Footer_Links_Contact_us';
import NesoQmFooterLinksCorporateInformationLink from '@salesforce/label/c.NesoQmFooterLinksCorporateInformation';

export default class NesoQmFooter extends LightningElement {

    label = {
        NesoHelpCentreLandingPage,
        NesoHCFooterLinksWhatWeDo,
        NesoHCFooterLinksOurStrategy,
        NesoHCFooterLinksCareersWithUs,
        NesoHCFooterLinksContactUs,
        NesoHCFooterLinksReportPowerCut,
        NesoHCFooterLinksMediaCentre,
        NesoHCFooterLinksNationalGridPLC,
        NesoHCFooterLinksInvestors,
        NesoHCFooterLinksAccessibility,
        NesoHCFooterLinksPrivacyPolicy,
        NesoHCFooterLinksCookiePolicy,
        NesoHCFooterLinksTermsAndConditions,
        NesoHCFooterLinksSecurity,
        NesoHCFooterLinksModernSlaveryStatement,
        NesoHCFooterLinksAboutNeso,
        NesoHelpCentreContactUs,
        NesoQmFooterLinksCorporateInformationLink
    };

    NGImageLogo = NESO_Footer;
    YoutubeIMG = Youtube;
    LinkedInIMG = LinkedIn;
    TwitterIMG = Twitter;
    
    loadFont() {
        const link = document.createElement('link');
        link.href = 'https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;700&display=swap';
        link.rel = 'stylesheet';
        document.head.appendChild(link);
    }  
}