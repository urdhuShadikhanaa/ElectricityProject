import { LightningElement, track } from 'lwc';
import getQuestions from '@salesforce/apex/NGMCP_QuestionController.getQuestions';

export default class nGMCP_ComplainQuestionForm extends LightningElement {
    @track questions = [];
    @track error;

    connectedCallback() {
        getQuestions()
            .then(result => {
                // Add flags for input type
                this.questions = result.map(q => ({
                    ...q,
                    isText: q.Input_Type__c === 'Text',
                    isCheckbox: q.Input_Type__c === 'Checkbox',
                    isRadio: q.Input_Type__c === 'Radio'
                }));
            })
            .catch(error => {
                this.error = error.body.message;
            });
    }

    get radioOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }
}