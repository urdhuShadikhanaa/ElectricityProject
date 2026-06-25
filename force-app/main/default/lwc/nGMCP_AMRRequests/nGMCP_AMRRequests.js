import { LightningElement, track } from 'lwc';

export default class NgmcpAmrRequestComponent extends LightningElement {
  // ====== UI selection ======
  @track selectedType = null;            // {label:'AMR', id:'AMR'}
  @track selectedTypeLabel = '';         // 'AMR'
  @track selectedSubType = null;         // {label:'Install'|'Site Visit'|'Remove', id:'AMR_Install'...}
  @track selectedSubTypeLabel = '';      // subtype label
  @track state = {};                     // answers
  @track errors = {};                    // not rendered in template, kept for potential parent use

  // ====== Subtypes config ======
  jobTypeSubtypes = {
    AMR: [
      { label: 'Install',    id: 'AMR_Install',   description: 'Install AMR device on meter' },
      { label: 'Site Visit', id: 'AMR_SiteVisit', description: 'Visit site for AMR-related activity' },
      { label: 'Remove',     id: 'AMR_Remove',    description: 'Remove AMR device from meter' },
    ],
  };

  // ====== Questions per subtype ======
  // Implemented exactly per your spec (note: Site Visit & Remove have End Consumer Email twice)
  questionConfig = {
    AMR_Install: [
      { label: 'Annual Consumption AQ (KWH)', type: 'text',   key: 'annualConsumption', maxLength: 10 },
      {
        label: 'Service Level',               type: 'select', key: 'serviceLevel',
        options: [
          { label: 'Select Service Level', value: '' },
          'Platinum(P)', 'Copper(C)', 'Bronze(B)', 'Silver Class(T)',
        ],
      },
      { label: 'Site Contact Name',           type: 'text',   key: 'siteContactName',    maxLength: 80 },
      { label: 'Site Contact Number',         type: 'text',   key: 'siteContactNumber',  maxLength: 20 },
      { label: 'End Consumer Email',          type: 'text',   key: 'consumerEmail',      maxLength: 120 },
      { label: 'Access Instructions',         type: 'text',   key: 'accessInstructions', maxLength: 200 },
      { label: 'MAM ID',                      type: 'text',   key: 'mamId',              maxLength: 30 },
      { label: 'Meter Dials',                 type: 'text',   key: 'meterDials',         maxLength: 15 },
      { label: 'Meter YOM',                   type: 'text',   key: 'meterYom',           maxLength: 4 },
      {
        label: 'Meter Unit Of Measure',       type: 'select', key: 'meterUom',
        options: [{ label: 'Select Unit of Measure', value: '' }, 'SCMH', 'SCFH'],
      },
      { label: 'Meter Reading Factor',        type: 'text',   key: 'meterReadingFactor', maxLength: 10 },
      { label: 'Correction Factor',           type: 'text',   key: 'correctionFactor',   maxLength: 10 },

      { label: 'Converter Fitted Indicator',  type: 'radio',  key: 'converterFitted',    options: ['Yes', 'No'] },

      // Shown only when converterFitted = Yes
      { label: 'Converter Serial Number',     type: 'text',   key: 'converterSerial',          maxLength: 30,
        condition: (state) => state.converterFitted === 'Yes' },
      { label: 'Converter Dials',             type: 'text',   key: 'converterDials',           maxLength: 15,
        condition: (state) => state.converterFitted === 'Yes' },
      { label: 'Converter Reading Factor',    type: 'text',   key: 'converterReadingFactor',   maxLength: 10,
        condition: (state) => state.converterFitted === 'Yes' },
    ],

    AMR_SiteVisit: [
      { label: 'Site Contact Name',  type: 'text', key: 'siteContactName', maxLength: 80 },
      { label: 'End Consumer Email', type: 'text', key: 'consumerEmail1',  maxLength: 120 },
      { label: 'End Consumer Email', type: 'text', key: 'consumerEmail2',  maxLength: 120 },
    ],

    AMR_Remove: [
      { label: 'Site Contact Name',  type: 'text', key: 'siteContactName', maxLength: 80 },
      { label: 'End Consumer Email', type: 'text', key: 'consumerEmail1',  maxLength: 120 },
      { label: 'End Consumer Email', type: 'text', key: 'consumerEmail2',  maxLength: 120 },
    ],
  };

  // ====== Template-safe getters for classes ======
  get typeCardClassAMR() {
    return `card-radio ${this.selectedTypeLabel === 'AMR' ? 'selected' : ''}`;
  }

  get subTypesWithClass() {
    const base = this.jobTypeSubtypes['AMR'] || [];
    return base.map(s => ({
      ...s,
      cssClass: `card-radio ${this.selectedSubTypeLabel === s.label ? 'selected' : ''}`,
    }));
  }

  // ====== Dynamic question builder ======
  get dynamicQuestions() {
    const subtypeId = this.selectedSubType?.id;
    const questions = this.questionConfig[subtypeId] || [];
    return questions.map((q) => {
      const currentValue = this.state[q.key] ?? '';

      // Normalize select/radio options (label/value pairs)
      const toPair = (opt) => (typeof opt === 'string' ? { label: opt, value: opt } : opt);
      const selectOptions = (q.type === 'select'
        ? (q.options || []).map((opt) => {
            const p = toPair(opt);
            return { ...p, selected: p.value === currentValue };
          })
        : []);
      const radioOptions = (q.type === 'radio'
        ? (q.options || []).map((opt) => {
            const p = toPair(opt);
            return { ...p, checked: p.value === currentValue };
          })
        : []);
      const visible = q.condition ? q.condition(this.state) : true;

      return {
        ...q,
        required: q.required ?? true,
        isSelect: q.type === 'select',
        isRadio:  q.type === 'radio',
        isText:   q.type === 'text',
        isNumber: q.type === 'number',
        selectOptions,
        radioOptions,
        value: currentValue,
        visible,
        visibleStyle: visible ? '' : 'display:none',
      };
    });
  }

  // ====== Handlers ======
  handleTypeSelect(e) {
    const label = e.target.value; // 'AMR'
    this.selectedType = { label, id: label };
    this.selectedTypeLabel = label;

    // Reset subtype & state
    this.selectedSubType = null;
    this.selectedSubTypeLabel = '';
    this.state = {};
  }

  handleSubTypeSelect(e) {
    const label = e.target.value;
    const sub = (this.jobTypeSubtypes['AMR'] || []).find((s) => s.label === label);
    this.selectedSubType = sub || { label, id: `AMR_${label.replace(/\s+/g, '')}` };
    this.selectedSubTypeLabel = label;

    // Initialize state for the chosen subtype
    const qs = this.questionConfig[this.selectedSubType.id] || [];
    const newState = {};
    qs.forEach((q) => { newState[q.key] = q.defaultValue ?? ''; });
    this.state = newState;
  }

  handleDynamicChange(e) {
    const key = e.target.dataset.key || e.target.name;
    let value = e.detail?.value || e.target.value || '';

    // Light normalization (optional; adjust as needed)
    if (key === 'annualConsumption') {
      value = value.replace(/[^0-9.]/g, '').slice(0, 10);
    }
    if (key === 'siteContactNumber') {
      value = value.replace(/[^\d+]/g, '').slice(0, 20);
    }
    if (key === 'meterYom') {
      value = value.replace(/\D/g, '').slice(0, 4);
    }

    // Save state
    this.state[key] = value;

    // Converter conditional reset if user picks "No"
    if (key === 'converterFitted' && value === 'No') {
      this.state.converterSerial = '';
      this.state.converterDials = '';
      this.state.converterReadingFactor = '';
    }
  }
}