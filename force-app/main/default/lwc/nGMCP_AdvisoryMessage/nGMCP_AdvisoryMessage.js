import { LightningElement, track } from 'lwc';

export default class HousingAdvisory extends LightningElement {
  @track selectedHousing = '';
  @track showAdvisory = false
  @track appointmentDate;

  
  handleHousingChange(event) {
    this.selectedHousing = event.target.value;
    
    this.showAdvisory = this.selectedHousing === 'Yes';
  }

  handleDataChange(event) {
    this.appointmentDate= event.target.value;
  }
}