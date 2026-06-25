import { LightningElement, track } from 'lwc';

export default class CwrAccessInstructions extends LightningElement {

    @track accessInstructions = '';

    @track showError = false;

    handleChange(event) {

        this.accessInstructions = event.target.value;

        if (this.accessInstructions.length > 255) {

            this.showError = true;

        } else {

            this.showError = false;

        }

    }

}