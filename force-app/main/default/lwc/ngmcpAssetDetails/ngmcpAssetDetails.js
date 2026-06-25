import editAddress from '@salesforce/apex/NGMCP_EditAddress.editAddress';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
import {
    CurrentPageReference
} from 'lightning/navigation';
export default class NGMCP_MprnDetail extends LightningElement {
    @track isEditing = false;
    @track selectedTab = 'Overview';
    @track assetDetails = [];
    @track address = {
        buildingNumber: 'N/A',
        buildingName: 'N/A',
        street: 'N/A',
        dependentLocality: 'N/A',
        postalTown: 'N/A',
        postCode: 'N/A'
    };

    // store raw decoded data
    _decodedData;

    // fields
    mprn;
    customer;
    appointmentDate;
    model;
    msn;
    meterType;
    manufacturer;
    yearOfManufacture;
    location;
    installDate;
    conversionFactor;
    paymentMechanism;
    measuringCapacity;
    noofdial;
    buildingNumber;
    buildingName;
    street;
    dependentLocality;
    postalTown;
    postalCode;

    @api
    set decodedData(value) {
        this._decodedData = value;
        try {
            let actualData = value;
            if (Array.isArray(value) && value.length > 0 && typeof value[0] === 'object') {
                actualData = value[0];
            }
            if (!actualData || typeof actualData !== 'object') {
                console.error('Invalid data format. Expected an object or an array of objects.');
                     return;
                }
                this.mprn = actualData.MPRN;
                this.customer = actualData.Customer;
                this.model = actualData.Model;
                this.msn = actualData.MSN;
                this.meterType = actualData.MeterType;
                this.manufacturer = actualData.manufacturer;
                this.yearOfManufacture = actualData.yearofmanufacture;
                this.location = actualData.location;
                this.installDate = actualData.InstallDate;
                this.conversionFactor = actualData.conversionFactor;
                this.appointmentDate = actualData.appointmentDate;
                this.paymentMechanism = actualData.paymentMechanism;
                this.measuringCapacity = actualData.measuringCapacity;
                this.noofdial = actualData.noofdial;
                this.buildingNumber = actualData.buildingNumber;
                this.buildingName = actualData.buildingName;
                this.street = actualData.street;    
                this.dependentLocality = actualData.dependentLocality;
                this.postalTown = actualData.postalTown;    
                this.postalCode = actualData.postalCode || 'N/A';   

                const addrParts = (actualData.Address || '').split(',').map(s => s.trim());
                this.address = {
                    buildingNumber: addrParts[0] || '',
                    buildingName: addrParts[1] || '',
                    street: addrParts[2] || '',
                    dependentLocality: addrParts[3] || '',
                    postalTown: addrParts[4] || '',
                    postCode: addrParts[5] || ''
                };
                this.assetDetails = [
                    {
                        label: 'Meter Model',
                        value: this.model || '—'
                    },
                    {
                        label: 'Serial no.',
                        value: this.msn || '—'
                    },
                    {
                        label: 'Manufacturer',
                        value: this.manufacturer || '—'
                    },
                     {
                        label: 'Year of Manufacture',
                        value: this.yearOfManufacture || '—'
                    },
                    {
                        label: 'Location',
                        value: this.location || '—'
                    },                 
                   
                    {
                        label: 'Installation Date',
                        value: this.formatDate(this.installDate)
                    },
                    {
                        label: 'Payment Type',
                        value: this.paymentMechanism || '—'
                    },
                    {
                        label: 'No. of Dial',
                        value: this.noofdial || '—'
                    },
                    {
                        label: 'Measuring Capacity',
                        value: this.measuringCapacity || '—'
                    },

                    {
                        label: 'Conversion Factor',
                        value: this.conversionFactor || '—'
                    },
                    {
                        label: 'Appointment Date',
                        value: this.formatDate(this.appointmentDate)
                    }  
                    
                ].map((item, index) => ({
                    ...item,
                    rowClass: index === 9 ? 'row' : 'row with-border'
                }));

                this.errorMessage = null;
        } catch (error) {
            this.errorMessage = `Error decoding data: ${error.message}`;
            console.error('Full error:', error);
        }
    }


    get decodedData() {
        return this._decodedData;
    }

    formatDate(dateStr) {
        if (!dateStr) return '—';
        try {
            const date = new Date(dateStr);
            const day = String(date.getDate()).padStart(2, '0');
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const year = date.getFullYear();
            return `${day}-${month}-${year}`;
        } catch {
            return '—';
        }
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        const value = event.target.value;
        if (field && this.address.hasOwnProperty(field)) {
            this.address[field] = value;
        }
    }


    handleEdit = () => {
    this.isEditing = true;

    }
    handleSave() {
    this.isEditing = true;

    const { buildingName, street, dependentLocality, postalTown, postalCode } = this.address;

    editAddress({
        buildingName,
        street,
        dependentLocality,
        postalTown,
        postCode: postalCode,
        location: this.location,
        serialNum: this.serialNum,
        assetNum: this.assetNum
    })
    .then(result => {
        this.showToast('Success', result, 'success');
    })
    .catch(error => {
        console.error('Apex error:', error);
        this.showToast('Error', error.body.message, 'error');
    });
}

    handleCancel() {
        this.isEditing = false;
    }

    getRowClass(index) {
        return index === this.assetDetails.length - 1 ? 'row' : 'row with-border';
    }

    // Tab Selection 
    get isOverview() {
        return this.selectedTab === 'Overview';
    }
    get overviewClass() {
        return this.selectedTab === 'Overview' ? 'tab active' : 'tab';
    }
    get requestLogClass() {
        return this.selectedTab === 'Request' ? 'tab active' : 'tab';
    }
    get workOrderLogClass() {
        return this.selectedTab === 'WorkOrder' ? 'tab active' : 'tab';
    }
    get amrClass() {
        return this.selectedTab === 'AMR' ? 'tab active' : 'tab';
    }

    selectOverview = () => this.selectedTab = 'Overview';
    selectRequestLog = () => this.selectedTab = 'Request';
    selectWorkOrderLog = () => this.selectedTab = 'WorkOrder';
    selectAMR = () => this.selectedTab = 'AMR';
}