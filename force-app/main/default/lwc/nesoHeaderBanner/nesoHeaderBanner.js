/**
 * @description       : DXP-9641 "NESO Component: Header"
 * @author            : Vivek Kumar
 * @last modified on  : 09-07-2024
 * @last modified by  : Varun Reddy
 * Modifications Log
 * Ver    Date        Author        Modification
 * 1.0    30-04-2024  Vivek Kumar   Initial Version
**/
import { LightningElement } from 'lwc';
//import NESO_DataPortal from '@salesforce/resourceUrl/NESO_DataPortal';
import companyLogo from '@salesforce/resourceUrl/NESO_Header';
import searchIcon from '@salesforce/resourceUrl/ESO_SearchIcon';
//import clearIcon from '@salesforce/resourceUrl/Neso_clearIcon';
import MobileNESOLogoImg from '@salesforce/resourceUrl/MobileNESOLogoImg';

// Import custom labels
//import searchUrl from '@salesforce/label/c.Neso_Help_Centre_Search_URL';
//import dataPortalUrl from '@salesforce/label/c.Neso_Data_Portal_URL';
import signInUrl from '@salesforce/label/c.Neso_Sign_In_URL';

export default class DataPortalButton extends LightningElement {
    //NESO_DataPortal = NESO_DataPortal;
    MobileNESOLogo = MobileNESOLogoImg;
    companyLogo = companyLogo;
    searchIcon = searchIcon;
    //searchUrl = searchUrl;
    //dataPortalUrl = dataPortalUrl;
    showPopup = false;
    searchText = '';
    searchLabelVisible = true;
    //clearIcon = clearIcon;

    connectedCallback() {
        this.handleOutsideClick = this.handleOutsideClick.bind(this);
        this.loadFont();
    }

    renderedCallback() {
        if (this.showPopup) {
            window.addEventListener('click', this.handleOutsideClick);
        } else {
            window.removeEventListener('click', this.handleOutsideClick);
        }
    }

    handleButtonClick(event) {
        event.stopPropagation(); 
        this.showPopup = !this.showPopup;
    }

    handleOutsideClick(event) {
        if (!this.template.contains(event.target)) {
            this.showPopup = false;
            window.removeEventListener('click', this.handleOutsideClick);
        }
    }

    get popupClass() {
        return this.showPopup ? 'popup show' : 'popup hide';
    }

    redirectToUrl(url) {
        console.log('url >>', url);
        window.open(url, '_blank');
    }

    redirectToSearchUrl() {
        console.log('Redirecting to search URL:', this.searchUrl); 
        const baseUrl= this.searchUrl;
        const searchTest = this.searchText ;
        const url = `${baseUrl}${encodeURIComponent(searchTest)}`;
        console.log('URL become :', url); 
        window.open(url, '_blank');
    }

    /*redirectToDataPortalUrl() {
        this.redirectToUrl(this.dataPortalUrl);
    }*/

    handleSearchKeyDown(event) {
        console.log('Key down:', event.key); 
        if (event.key === 'Enter') {
            this.redirectToSearchUrl();
        }
    }

    redirectToSignIn() {
        this.redirectToUrl(signInUrl);
    }

    handleSearchLabelClick() {
        this.template.querySelector('.search-input').focus();
    }

    handleSearchInput(event) {
        this.searchText = event.target.value;
        this.searchLabelVisible = this.searchText.length === 0;
    }

    handleSearchBlur() {
        if (this.searchText.length === 0) {
            this.searchLabelVisible = true;
        }
    }

    clearSearchText() {
        this.searchText = '';
        this.searchLabelVisible = true;
    }

    get searchLabelClass() {
        return this.searchLabelVisible ? 'search-label' : 'search-label hidden';
    }

    get clearButtonStyle() {
        return this.searchText.length === 0 ? 'display: none;' : 'cursor: pointer;';
    }

    loadFont() {
        const link = document.createElement('link');
        link.href = 'https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;700&display=swap';
        link.rel = 'stylesheet';
        document.head.appendChild(link);
    }
}