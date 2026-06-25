import { LightningElement, track, wire } from 'lwc';

import getCwrQuestions from '@salesforce/apex/ngmcpChargableJob.getCwrQuestions';

import getPricesByProductCodes from '@salesforce/apex/ngmcpChargableJob.getPricesByProductCodes';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class nGMCP_ChargableJob extends LightningElement {

  @track questions = [];

  @track prices = [];

   @wire(getCwrQuestions)
   wiredQuestions({ error, data }) {
       if (data) {
           this.questions = data.map(q => {
               if (q.type === 'Picklist') {
                   q.options = q.picklistValues.map(v => ({ label: v, value: v }));
               }
               return q;
           });
       } else if (error) {
           console.error(error);
       }
   }

  loading = true;

  connectedCallback() {

    this.loadQuestions();

  }

  async loadQuestions() {

    try {

      this.loading = true;

      const res = await getCwrQuestions();

      this.questions = res.map(q => ({

        ...q,

        isText: q.type === 'Text',

        isLongText: q.type === 'LongText',

        isNumber: q.type === 'Number',

        isDate: q.type === 'Date',

        isCheckbox: q.type === 'Checkbox',

        isPicklist: q.type === 'Picklist',

        answerValue: q.type === 'Checkbox' ? false : '',

        picklistOptions: Array.isArray(q.picklistValues)? q.picklistValues.map(v => ({ label: v, value: v })): []

      }));

    } catch (err) {

      this.showToast('Error', this.getErrorMessage(err), 'error');

    } finally {

      this.loading = false;

    }

  }

  handleChange(event) {

    const api = event.target.dataset.api;

    const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;

    this.questions = this.questions.map(q =>

      q.apiName === api ? { ...q, answerValue: value } : q

    );

  }

  async handleFetchPrice() {

    const productField = this.questions.find(q => ['Product_Code', 'ProductCode'].includes(q.apiName));

    const productCode = productField?.answerValue;

    if (!productCode) {

      this.showToast('Info', 'Enter a Product Code first.', 'info');

      return;

    }

    try {

      this.loading = true;

      const res = await getPricesByProductCodes({ productCodes: [productCode] });

      this.prices = res;

    } catch (err) {

      this.showToast('Error', this.getErrorMessage(err), 'error');

    } finally {

      this.loading = false;

    }

  }

  handleSubmit() {

    const answers = {};

    this.questions.forEach(q => (answers[q.apiName] = q.answerValue));

    this.dispatchEvent(new CustomEvent('submit', { detail: { answers, prices: this.prices } }));

    this.showToast('Success', 'Form submitted successfully.', 'success');

  }

  showToast(title, message, variant) {

    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));

  }

  getErrorMessage(err) {

    return err?.body?.message || err?.message || JSON.stringify(err);

  }

}