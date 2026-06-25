import { LightningElement, wire } from 'lwc';
import getScheduleAppointmentStats from '@salesforce/apex/ngCaseAppointmentsController.getScheduleAppointmentStats';
import { loadScript } from 'lightning/platformResourceLoader';
import ChartJS from '@salesforce/resourceUrl/chartjs';

export default class NgReportDashboard extends LightningElement {
    chartJsInitialized = false;
    stats;

    @wire(getScheduleAppointmentStats)
    wiredStats({ error, data }) {
        if (data) {
            this.stats = data;
            if (this.chartJsInitialized) {
                this.renderCharts();
            }
        } else if (error) {
            console.error('Error loading stats', error);
        }
    }

    renderedCallback() {
        if (this.chartJsInitialized) return;

        loadScript(this, ChartJS)
            .then(() => {
                this.chartJsInitialized = true;
                if (this.stats) {
                    this.renderCharts();
                }
            })
            .catch(error => {
                console.error('ChartJS load error', error);
            });
    }

    renderCharts() {
        const pieCanvas = this.template.querySelector('.pie-chart').getContext('2d');
        const barCanvas = this.template.querySelector('.bar-chart').getContext('2d');
        const barCanvas1 = this.template.querySelector('.bar-chart1').getContext('2d');

        new window.Chart(pieCanvas, {
            type: 'pie',
            data: {
                labels: ['Scheduled', 'Others'],
                datasets: [{
                    label: 'Appointments',
                    data: [
                        this.stats.scheduled,
                        this.stats.total - this.stats.scheduled
                    ],
                    backgroundColor: ['#006d6f', '#2fc6c9']
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { labels: { font: { size: 12, family: 'Montserrat' } } },
                    tooltip: {
                        bodyFont: { size: 12, family: 'Montserrat' },
                        titleFont: { size: 12, family: 'Montserrat' }
                    }
                }
            }
        });

        new window.Chart(barCanvas, {
            type: 'bar',
            data: {
                labels: ['Scheduled', 'Total'],
                datasets: [{
                    label: 'Work Orders',
                    data: [this.stats.scheduled, this.stats.total],
                    backgroundColor: ['#006d6f', '#2fc6c9']
                }]
            },
            options: {
                responsive: true,
                scales: { y: { beginAtZero: true } },
                plugins: {
                    legend: { labels: { font: { size: 12, family: 'Montserrat' } } },
                    tooltip: {
                        bodyFont: { size: 12, family: 'Montserrat' },
                        titleFont: { size: 12, family: 'Montserrat' }
                    }
                }
            }
        });

        new window.Chart(barCanvas1, {
            type: 'bar',
            data: {
                labels: ['Open Queries', 'Closed Queries'],
                datasets: [{
                    label: 'Queries',
                    data: [this.stats.openQueries, this.stats.closedQueries],
                    backgroundColor: ['#006d6f', '#2fc6c9']
                }]
            },
            options: {
                responsive: true,
                scales: { y: { beginAtZero: true } },
                plugins: {
                    legend: { labels: { font: { size: 12, family: 'Montserrat' } } },
                    tooltip: {
                        bodyFont: { size: 12, family: 'Montserrat' },
                        titleFont: { size: 12, family: 'Montserrat' }
                    }
                }
            }
        });
    }
}