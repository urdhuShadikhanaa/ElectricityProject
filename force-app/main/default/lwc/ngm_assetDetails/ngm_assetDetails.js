import { LightningElement } from 'lwc';

export default class ngm_assetDetails extends LightningElement {
    mprn = '10010806';

    assetFields = [
        { label: 'Installation Date', value: '1997-09-12' },
        { label: 'Appointed Date', value: '2011-01-01' },
        { label: 'Location Description', value: '32 – Metropolis' },
        { label: 'Asset Type', value: 'Meter' },
        { label: 'Meter Type', value: 'Diaphragm – synthetic' },
        { label: 'Meter Model', value: 'U6 RF5' },
        { label: 'Manufacturer', value: 'Schlumberger Industries' },
        { label: 'Year of Manufacture', value: '1997' },
        { label: 'Serial Number', value: '01140415' },
        { label: 'Number of Dials', value: '4' },
        { label: 'Payment Mechanism', value: 'CR' },
        { label: 'Conversion Factor', value: '1.02264' },
        { label: 'Measuring Capacity (m³)', value: '1000' }
    ];

    addressFields = [
        { label: 'Building Name/Number', value: 'N/A' },
        { label: 'Dependant Locality', value: 'N/A' },
        { label: 'Postal Town', value: 'Aberdeen' },
        { label: 'Postal Code', value: 'AB24 5GB' },
        { label: 'Street', value: 'Old Road' }
    ];

    handleDeappoint() {
        alert('De-appoint clicked');
    }

    handleCreateQuery() {
        alert('Create Query clicked');
    }

    handleCreateJob() {
        alert('Create Job clicked');
    }
}