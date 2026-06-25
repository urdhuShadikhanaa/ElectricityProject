import { LightningElement } from 'lwc';

export default class Ngmcp_AssetportfolioPage extends LightningElement {
 

assetDetails = {
    installationDate: '1997-05-12',
    appointedDate: '2011-04-01',
    locationDescription: '32 - Meterbox',
    assetType: 'Meter',
    meterType: 'Diaphragm - synthetic',
    meterModel: 'U6 RS',
    manufacturer: 'Schlumberger Industries',
    yearOfManufacture: '1997',
    serialNumber: '01140415',
    numberOfDials: '4',
    paymentMechanism: 'CR',
    conversionFactor: '1.02264',
    measuringCapacity: '100.0 / 100.0'
  };

  addressDetails = {
    buildingName: 'N/A',
    dependentLocality: '1997',
    postalTown: 'Aberdeen',
    postalCode: 'AB24 5QB',
    street: 'Golf Road'
  };

  get assetFields() {
    return Object.entries(this.assetDetails).map(([label, value]) => ({
      label: this.formatLabel(label),
      value
    }));
  }

  get addressFields() {
    return Object.entries(this.addressDetails).map(([label, value]) => ({
      label: this.formatLabel(label),
      value
    }));
  }

  formatLabel(label) {
    return label
      .replace(/([A-Z])/g, ' $1')
      .replace(/_/g, ' ')
      .replace(/\b\w/g, c => c.toUpperCase());
  }

  handleDeappoint() {
    console.log('De-appoint clicked');
  }

  handleCreateQuery() {
    console.log('Create Query clicked');
  }

  handleCreateJob() {
    console.log('Create Job clicked');
  }


}