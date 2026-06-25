import { LightningElement, track } from 'lwc';
 
export default class DemoFlow extends LightningElement {

    @track showDemo2Demo3 = false;

    @track showDemo4 = false;
 
    @track showNameQuestion = false;

    @track showAgeQuestion = false;
 
    selectedSubOption = '';
 
    @track nameValue = '';

    @track ageValue = '';
 
    demo4Key = 0;

    demo4InternalName = 'demo4_default';
 
    renderedCallback() {

        // 🔥 FORCE clear radio checked state every time Demo4 is re-rendered

        const demo4Input = this.template.querySelector("[data-demo4]");

        if (demo4Input) {

            demo4Input.checked = false;

        }

    }
 
    handleMainSelect() {

        this.showDemo2Demo3 = true;
 
        this.showDemo4 = false;

        this.showNameQuestion = false;

        this.showAgeQuestion = false;
 
        this.demo4Key++;

    }
 
    handleSub1Select(event) {

        this.selectedSubOption = event.target.value;
 
        // 🔥 dynamic internal name

        this.demo4InternalName = 'demo4_' + this.selectedSubOption;
 
        this.showDemo4 = true;
 
        this.showNameQuestion = false;

        this.showAgeQuestion = false;
 
        this.demo4Key++;  // 🔥 force rebuild

    }
 
    handleDemo4Select() {

        if (this.selectedSubOption === 'Demo2') {

            this.showNameQuestion = true;

            this.showAgeQuestion = false;

        } else if (this.selectedSubOption === 'Demo3') {

            this.showAgeQuestion = true;

            this.showNameQuestion = false;

        }

    }
 
    handleNameChange(event) {

        this.nameValue = event.target.value;

    }
 
    handleAgeChange(event) {

        this.ageValue = event.target.value;

    }

}