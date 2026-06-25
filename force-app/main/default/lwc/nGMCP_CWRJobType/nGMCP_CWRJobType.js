import { LightningElement, track } from 'lwc';

export default class NGMCP_CWRJobType extends LightningElement {
    @track selectedRequest;
    @track selectedJob;
    @track selectedSubType;
    @track meterSuggestions = [];

    uiConfig = {
        requestTypes: [
            {
                label: 'Work Request',
                helpText: 'As ordinary work request with several jobs type to choose from',
                jobTypes: [
                    { label: 'Install' },
                    { label: 'Exchange' },
                    { label: 'Remove' },
                    { label: 'Meter Move' },
                    { label: 'Other Visits' }
                ],
                subTypes: [
                    {
                        label: 'Specification Change',
                        questions: [
                            {
                                typeDropdown: true,
                                label: 'Please confirm the Service Pressure Tier',
                                options: ['Low Pressure', 'Medium Pressure', 'Intermediate Pressure', 'High Pressure'],
                                default: 'Low Pressure'
                            },
                            {
                                typeDropdown: true,
                                label: 'Medium Pressure Range',
                                options: ['MP 35', 'MP 65', 'MP 105', 'MP 180', 'MP 270']
                            },
                            {
                                typeNumber: true,
                                label: 'Required Metering Outlet Pressure (mbar)',
                                default: 21,
                                maxLength: 4,
                                unit: 'mbar'
                            },
                            {
                                typeNumber: true,
                                label: 'Expected Peak Hourly Load (kWh)',
                                unit: 'kWh'
                            }
                        ]
                    }
                ]
            }
        ]
    };

    qmaxTable = [
        { model: 'U6', qmax: 64 },
        { model: 'U16', qmax: 171 },
        { model: 'U25', qmax: 267 },
        { model: 'U40', qmax: 427 },
        { model: 'U65', qmax: 693 },
        { model: 'U100', qmax: 1067 },
        { model: 'U160', qmax: 1706 }
    ];

    handleRequestSelect(event) {
        this.selectedRequest = this.uiConfig.requestTypes.find(req => req.label === event.target.value);
        this.selectedJob = null;
        this.selectedSubType = null;
        this.meterSuggestions = [];
    }

    handleJobSelect(event) {
        this.selectedJob = this.selectedRequest.jobTypes.find(job => job.label === event.target.value);
        this.selectedSubType = null;
        this.meterSuggestions = [];
    }

    handleSubTypeSelect(event) {
        this.selectedSubType = this.selectedRequest.subTypes.find(sub => sub.label === event.target.value);
        this.meterSuggestions = [];
    }

    handleAnswerChange(event) {
        const label = event.target.dataset.label;
        const value = event.target.value;

        if (label.includes('Outlet Pressure')) {
            if (parseInt(value, 10) > 21) {
                this.meterSuggestions = ['Rotary', 'Turbine'];
            }
        }

        if (label.includes('Peak Hourly Load')) {
            const load = parseInt(value, 10);
            if (load > 1706) {
                this.meterSuggestions = ['Rotary', 'Turbine'];
            } else {
                this.meterSuggestions = this.qmaxTable.filter(item => item.qmax >= load).map(item => item.model);
            }
        }
    }
}