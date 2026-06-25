import { LightningElement } from 'lwc';
import NGMCP_HC1 from '@salesforce/resourceUrl/NGMCP_UserManagementHowdoyouamendausercompressed';
import NGMCP_HC2 from '@salesforce/resourceUrl/NGMCP_UserManagementHowdoyoucreateausercompressed';
import NGMCP_HC3 from '@salesforce/resourceUrl/NGMCP_UserManagementHowdoyoudeactivateausercompressed';
import NGMCP_HC4 from '@salesforce/resourceUrl/NGMCP_UserManagementHowdoyoureactivateausercompressed';
import NGMCP_HC5 from '@salesforce/resourceUrl/NGMCP_UWRHowdoyouconfirmthejobisraisedandmonitorviajobnumbercompressed';
import NGMCP_HC6 from '@salesforce/resourceUrl/NGMCP_UWRHowdoyouRaiseaWindonRequestonaNGMMetercompressed';
import NGMCP_HC7 from '@salesforce/resourceUrl/NGMCP_UWRHowdoyouraiseanurgentworkrequestonaNGMMetercompressed';
import NGMCP_HC8 from '@salesforce/resourceUrl/NGMCP_UWRHowdoyouraiseanurgentworkrequestonaNonNGMMetercompressed';
import NGMCP_HC9 from '@salesforce/resourceUrl/NGMCP_UWRHowdoyouvalidatecontactinfoaddaccessinstructionsanduploadafile';
import NGMCP_HC10 from '@salesforce/resourceUrl/NGMCP_UWRHowdoyoubookdifferenttimeslotsstartnowselectdateandtimecompressed';
import NGMCP_HC11 from '@salesforce/resourceUrl/NGMCP_Howdoyoudownloadmonthlypackslikeportfolioreportscompressed';
import NGMCP_HC12 from '@salesforce/resourceUrl/NGMCP_Howdoyoudownloadreportscompressed';
import NGMCP_HC13 from '@salesforce/resourceUrl/NGMCP_TQHowdoyoucreateTechnicalQuerycompressed';
import NGMCP_HC14 from '@salesforce/resourceUrl/NGMCP_TQHowdoyoumonitorstatusofQuerycompressed';
import NGMCP_HC15 from '@salesforce/resourceUrl/NGMCP_TQHowdoyoureplanorCanceltheTechnicalQuerycompressed';
import NGMCP_HC16 from '@salesforce/resourceUrl/NGMCP_HomeScreenHowdoyoueditAddressdetailscompressed';
import NGMCP_HC17 from '@salesforce/resourceUrl/NGMCP_HomeScreenHowdoyounavigatetheHomeScreencompressed';
// import NGMCP_HC18 from '@salesforce/resourceUrl/NGMCP_HowdoyoueditAddressdetails';
// import NGMCP_HC19 from '@salesforce/resourceUrl/NGMCP_Howdoyounavigatethehomescreen';
// import NGMCP_HC20 from '@salesforce/resourceUrl/NGMCP_HowdoyousearchandvalidateMPRN';
import NGMCP_HC21 from '@salesforce/resourceUrl/NGMCP_HomeScreenHowdoyousearchMPRNbyPostCodeandMSNcompressed';
import NGMCP_HC22 from '@salesforce/resourceUrl/NGMCP_HomeScreenHowtologintothecustomerportalcompressed';
import NGMCP_HC23 from '@salesforce/resourceUrl/NGMCP_NSHowdoyoucreateNonStandardjobandUploadfilescompressed';
import NGMCP_HC24 from '@salesforce/resourceUrl/NGMCP_HomeScreenHowdoyousearchandvalidateMPRNcompressed';
//import NGMCP_HC25 from '@salesforce/resourceUrl/NGMCP_HowdoyouRequestcancelaNonStandardJob';
//import NGMCP_HC26 from '@salesforce/resourceUrl/NGMCP_HowdoyouRequestreplanaNonStandardJob';
import NGMCP_HC27 from '@salesforce/resourceUrl/NGMCP_NSHowdoyouseestatusupdateinportalforanonstandardjobcompressed';
import NGMCP_HC28 from '@salesforce/resourceUrl/NGMCP_AMRHowdoyouraiseAMRremovethroughcustomerportalcompressed';
import NGMCP_HC29 from '@salesforce/resourceUrl/NGMCP_AMRHowdoyouraiseAMRstopthroughcustomerportalcompressed';
import NGMCP_HC30 from '@salesforce/resourceUrl/NGMCP_AMRHowdoyouraiseinstallAMRthroughcustomerportalcompressed';
import NGMCP_HC31 from '@salesforce/resourceUrl/NGMCP_HowdoyouraiseanAppointmentthroughportalcompressed';
import NGMCP_HC32 from '@salesforce/resourceUrl/NGMCP_HowdoyouraiseaDeappointmentthroughportalcompressed';
import NGMCP_HC33 from '@salesforce/resourceUrl/NGMCP_Howdoyouraisecomplaintscompressed';
import NGMCP_HC34 from '@salesforce/resourceUrl/NGMCP_CWRHowdoyouconfirmthejobisraisedandmonitorviajobnumbercompressed';
import NGMCP_HC35 from '@salesforce/resourceUrl/NGMCP_CWRHowdoyouraiseaWorkrequestforInstallRotarymetercompressed';
import NGMCP_HC36 from '@salesforce/resourceUrl/NGMCP_CWRHowdoyouraiseaWorkrequestforInstallU6metercompressed';
import NGMCP_HC37 from '@salesforce/resourceUrl/NGMCP_CWRHowdoyouraiseaWorkrequestforInstallU16meterwithhousingcompressed';
import NGMCP_HC38 from '@salesforce/resourceUrl/NGMCP_CWRHowdoyouraiseaWorkrequestforRemovalofU25meterwithoutpurgingcompressed';
import NGMCP_HC39 from '@salesforce/resourceUrl/NGMCP_CWRHowdoyouraiseaworkrequestforRemoveU40withpurgingcompressed';
import NGMCP_HC40 from '@salesforce/resourceUrl/NGMCP_CWRHowdoyouraisespecificationchangewherethejobisfreeofchargecompressed';
import NGMCP_HC41 from '@salesforce/resourceUrl/NGMCP_DQHowdoyoucreateDataQuery';
import NGMCP_HC42 from '@salesforce/resourceUrl/NGMCP_DQHowdoyoumonitorstatusofDataQuerycompressed';
import NGMCP_HC43 from '@salesforce/resourceUrl/NGMCP_DQHowdoyoureopenQueryinPortalcompressed';
import NGMCP_HC44 from '@salesforce/resourceUrl/NGMCP_DQHowdoyouupdateADIresponseintheportalcompressed';
import NGMCP_HC45 from '@salesforce/resourceUrl/NGMCP_DQHowdoyouviewReminderinPortalcompressed';
import NGMCP_HC46 from '@salesforce/resourceUrl/NGMCP_DQHowdoyouviewresolutioninportalcompressed';
import NGMCP_HC47 from '@salesforce/resourceUrl/NGMCP_NSHowdoyouDownloadacceptquotationanduploadthequotationresponsecompressed';
//import NGMCP_HC48 from '@salesforce/resourceUrl/NGMCP_HomeScreenHowtologintothecustomerportalcompressed';
import NGMCP_HC49 from '@salesforce/resourceUrl/NGMCP_NSHowdoyouRequesttocancelaNonStandardJobcompressed';
import NGMCP_HC50 from '@salesforce/resourceUrl/NGMCP_NSHowdoyouRequesttoreplanaNonStandardJobcompressed';



import { NavigationMixin } from 'lightning/navigation';

export default class NGMCP_Helpcentre extends NavigationMixin(LightningElement) {
    labels = {
        Help_Centre1: NGMCP_HC1,
        Help_Centre2: NGMCP_HC2,
        Help_Centre3: NGMCP_HC3,
        Help_Centre4: NGMCP_HC4,
        Help_Centre5: NGMCP_HC5,
        Help_Centre6: NGMCP_HC6,
        Help_Centre7: NGMCP_HC7,
        Help_Centre8: NGMCP_HC8,
        Help_Centre9: NGMCP_HC9,
        Help_Centre10: NGMCP_HC10,
        Help_Centre11: NGMCP_HC11,
        Help_Centre12: NGMCP_HC12,
        Help_Centre13: NGMCP_HC13,
        Help_Centre14: NGMCP_HC14,
        Help_Centre15: NGMCP_HC15,
        Help_Centre16: NGMCP_HC16,
        Help_Centre17: NGMCP_HC17,
        // Help_Centre18: NGMCP_HC18,
        // Help_Centre19: NGMCP_HC19,
        // Help_Centre20: NGMCP_HC20,
        Help_Centre21: NGMCP_HC21,
        Help_Centre22: NGMCP_HC22,
        Help_Centre23: NGMCP_HC23,
        Help_Centre24: NGMCP_HC24,
        // Help_Centre25: NGMCP_HC25,
        // Help_Centre26: NGMCP_HC26,
        Help_Centre27: NGMCP_HC27,
        Help_Centre28: NGMCP_HC28,
        Help_Centre29: NGMCP_HC29,
        Help_Centre30: NGMCP_HC30,
        Help_Centre31: NGMCP_HC31,
        Help_Centre32: NGMCP_HC32,
        Help_Centre33: NGMCP_HC33,
        Help_Centre34: NGMCP_HC34,
        Help_Centre35: NGMCP_HC35,
        Help_Centre36: NGMCP_HC36,
        Help_Centre37: NGMCP_HC37,
        Help_Centre38: NGMCP_HC38,
        Help_Centre39: NGMCP_HC39,
        Help_Centre40: NGMCP_HC40,
        Help_Centre41: NGMCP_HC41,
        Help_Centre42: NGMCP_HC42,
        Help_Centre43: NGMCP_HC43,
        Help_Centre44: NGMCP_HC44,
        Help_Centre45: NGMCP_HC45,
        Help_Centre46: NGMCP_HC46,
        Help_Centre47: NGMCP_HC47,
        // Help_Centre48: NGMCP_HC48,
        Help_Centre49: NGMCP_HC49,
        Help_Centre50: NGMCP_HC50,
        
    };
    Hc1Url = NGMCP_HC1;
    Hc2Url = NGMCP_HC2;
    Hc3Url = NGMCP_HC3;
    Hc4Url = NGMCP_HC4;
    Hc5Url = NGMCP_HC5;
    Hc6Url = NGMCP_HC6;
    Hc7Url = NGMCP_HC7;
    Hc8Url = NGMCP_HC8;
    Hc9Url = NGMCP_HC9;
    Hc10Url = NGMCP_HC10;
    Hc11Url = NGMCP_HC11;
    Hc12Url = NGMCP_HC12;
    Hc13Url = NGMCP_HC13;
    Hc14Url = NGMCP_HC14;
    Hc15Url = NGMCP_HC15;
    Hc16Url = NGMCP_HC16;
    Hc17Url = NGMCP_HC17;
    // Hc18Url = NGMCP_HC18;
    // Hc19Url = NGMCP_HC19;
    // Hc20Url = NGMCP_HC20;
    Hc21Url = NGMCP_HC21;
    Hc22Url = NGMCP_HC22;
    Hc23Url = NGMCP_HC23;
    Hc24Url = NGMCP_HC24;
    // Hc25Url = NGMCP_HC25;
    // Hc26Url = NGMCP_HC26;
    Hc27Url = NGMCP_HC27;
    Hc28Url = NGMCP_HC28;
    Hc29Url = NGMCP_HC29;
    Hc30Url = NGMCP_HC30;
    Hc31Url = NGMCP_HC31;
    Hc32Url = NGMCP_HC32;
    Hc33Url = NGMCP_HC33;
    Hc34Url = NGMCP_HC34;
    Hc35Url = NGMCP_HC35;
    Hc36Url = NGMCP_HC36;
    Hc37Url = NGMCP_HC37;
    Hc38Url = NGMCP_HC38;
    Hc39Url = NGMCP_HC39;
    Hc40Url = NGMCP_HC40;
    Hc41Url = NGMCP_HC41;
    Hc42Url = NGMCP_HC42;
    Hc43Url = NGMCP_HC43;
    Hc44Url = NGMCP_HC44;
    Hc45Url = NGMCP_HC45;
    Hc46Url = NGMCP_HC46;
    Hc47Url = NGMCP_HC47;
    // Hc48Url = NGMCP_HC48;
    Hc49Url = NGMCP_HC49;
    Hc50Url = NGMCP_HC50;
    
    
   openPdfInNewTab() {
       window.open(encodeURI(this.Hc1Url), '_blank');
       window.open(encodeURI(this.Hc2Url), '_blank');
       window.open(encodeURI(this.Hc3Url), '_blank');
       window.open(encodeURI(this.Hc4Url), '_blank');
       window.open(encodeURI(this.Hc5Url), '_blank');
       window.open(encodeURI(this.Hc6Url), '_blank');
       window.open(encodeURI(this.Hc7Url), '_blank');
       window.open(encodeURI(this.Hc8Url), '_blank');
       window.open(encodeURI(this.Hc9Url), '_blank');
       window.open(encodeURI(this.Hc10Url), '_blank');
       window.open(encodeURI(this.Hc11Url), '_blank');
       window.open(encodeURI(this.Hc12Url), '_blank');
       window.open(encodeURI(this.Hc13Url), '_blank');
       window.open(encodeURI(this.Hc14Url), '_blank');
       window.open(encodeURI(this.Hc15Url), '_blank');
       window.open(encodeURI(this.Hc16Url), '_blank');
       window.open(encodeURI(this.Hc17Url), '_blank');
    //    window.open(encodeURI(this.Hc18Url), '_blank');
    //    window.open(encodeURI(this.Hc19Url), '_blank');
    //    window.open(encodeURI(this.Hc20Url), '_blank');
       window.open(encodeURI(this.Hc21Url), '_blank');
       window.open(encodeURI(this.Hc22Url), '_blank');
       window.open(encodeURI(this.Hc23Url), '_blank');
       window.open(encodeURI(this.Hc24Url), '_blank');
    //    window.open(encodeURI(this.Hc25Url), '_blank');
    //    window.open(encodeURI(this.Hc26Url), '_blank');
       window.open(encodeURI(this.Hc27Url), '_blank');
       window.open(encodeURI(this.Hc28Url), '_blank');
       window.open(encodeURI(this.Hc29Url), '_blank');
       window.open(encodeURI(this.Hc30Url), '_blank');
       window.open(encodeURI(this.Hc31Url), '_blank');
       window.open(encodeURI(this.Hc32Url), '_blank');
       window.open(encodeURI(this.Hc33Url), '_blank');
       window.open(encodeURI(this.Hc34Url), '_blank');
       window.open(encodeURI(this.Hc35Url), '_blank');
       window.open(encodeURI(this.Hc36Url), '_blank');
       window.open(encodeURI(this.Hc37Url), '_blank');
       window.open(encodeURI(this.Hc38Url), '_blank');
       window.open(encodeURI(this.Hc39Url), '_blank');
       window.open(encodeURI(this.Hc40Url), '_blank');
       window.open(encodeURI(this.Hc41Url), '_blank');
       window.open(encodeURI(this.Hc42Url), '_blank');
       window.open(encodeURI(this.Hc43Url), '_blank');
       window.open(encodeURI(this.Hc44Url), '_blank');
       window.open(encodeURI(this.Hc45Url), '_blank');
       window.open(encodeURI(this.Hc46Url), '_blank');
       window.open(encodeURI(this.Hc47Url), '_blank');
    //    window.open(encodeURI(this.Hc48Url), '_blank');
       window.open(encodeURI(this.Hc49Url), '_blank');
       window.open(encodeURI(this.Hc50Url), '_blank');
        
   }
}