import { LightningElement, track } from 'lwc';
import ngAssets from '@salesforce/resourceUrl/NGMCP_SearchMPRN';

export default class ngAssetPortfolio extends LightningElement {
  @track activeTab = '1';
  homepageAssets = ngAssets;

  get isTab1() {
    return this.activeTab === '1';
  }
  get isTab2() {
    return this.activeTab === '2';
  }
  get isTab3() {
    return this.activeTab === '3';
  }
  get isTab4() {
    return this.activeTab === '4';
  }

  get tabClass1() {
    return this.activeTab === '1' ? 'tab slds-p-vertical_small active' : 'tab slds-p-vertical_small';
  }
  get tabClass2() {
    return this.activeTab === '2' ? 'tab slds-p-vertical_small active' : 'tab slds-p-vertical_small';
  }
  get tabClass3() {
    return this.activeTab === '3' ? 'tab slds-p-vertical_small active' : 'tab slds-p-vertical_small';
  }
   get tabClass4() {
    return this.activeTab === '4' ? 'tab slds-p-vertical_small active' : 'tab slds-p-vertical_small';
  }

  handleTabClick(event) {
    this.activeTab = event.target.dataset.tab;
  }

}