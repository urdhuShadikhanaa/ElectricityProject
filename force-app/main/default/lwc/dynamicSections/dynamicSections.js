import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import {
    getRelatedListsInfo,
    getRelatedListInfoBatch,
    getRelatedListRecordsBatch
} from 'lightning/uiRelatedListApi';
import buildJson from '@salesforce/apex/NGMCP_DynamicPageConfigServiceController.buildSectionConfigJsonByRtName';
import getObjectApiName from '@salesforce/apex/NGMCP_DynamicPageConfigServiceController.getObjectApiName';
// code from shreya
import STATUS_FIELD from '@salesforce/schema/NGMCP_Request__c.NGMCP_Callout_Status__c';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
  import submitCancelJob from "@salesforce/apex/NGMCP_ReplanCancelHandler.submitCancelJob";
  import submitAcceptRejectQuotation from "@salesforce/apex/NGMCP_ReplanCancelHandler.submitAcceptRejectQuotation";
  import getRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.getRequest";
  import getHolidays from '@salesforce/apex/NGMCP_HolidaysService.getHolidaysBetween';
  import USER_ID from '@salesforce/user/Id';
  const FIELDS = ['User.Email'];
  import updateNSRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.updateNSRequest";
  import uploadAndLinkFileToRequest from "@salesforce/apex/NGMCP_ReplanCancelHandler.uploadAndLinkFileToRequest";

export default class DynamicSections extends NavigationMixin(LightningElement) {
    /** Parent record context provided by the record page */
    @api recordId = '0WOdu000002hfYDGAY';        // e.g., Account Id
    @api objectApiName;
    @api recordTypeName = 'WorkOrder'; 
    @track selectedRecordId;
     @api rl;// e.g., 'Account'

    /** UI state */
    @track loading = true;
    @track errorMessage;
    
@api firstColumnMin = 220;        // px
  @api columnMinWidths = [];        // per middle column, e.g. [200,180,200,160]
  @api iconName = 'standard:related_list';


    /** Discovery state */
    @track relatedListIds = [];            // ['Contacts','Opportunities',...]
    @track infoBatchResultsById = new Map(); // id -> { displayColumns, childObjectApiName, label }

    /** Batch fetch params & results */
    @track relatedListParameters;          // reactive param for getRelatedListRecordsBatch
    @track lists = [];
    recordDisplayName;
    recordTypeId;
    activeRecordTypeDevName;
    objectInfos;
    ready = false;
    error = null;
    @api sectionConfigJson;
    @wire(buildJson, { recordTypeName: '$recordTypeName' })
    wiredJson({ data, error }) {
        console.log('wiredJso', JSON.stringify(data));
        if (data) {
            this.sectionConfigJson = data; // JSON string
        } else if (error) {
            console.error('Failed to load CMT config:', error?.body?.message || error?.message);
        }
    }            // [{ id, label, columns, rows, count, error }]
    @wire(getRecord, {
        recordId: '$recordId',
        // You can switch to a fields[] array for performance; layoutTypes returns all fields in the layout.
        layoutTypes: ['Full'],
        modes: ['View']
    })
    wiredRecord({ data, error }) {
        if (error) {
            this.setError(error);
            return;
        }
        if (data) {
            // Derive objectApiName: no need to pass it explicitly
            if (!this.objectApiName && data.apiName) {
                this.objectApiName = data.apiName; // Reactively triggers getObjectInfo
            }

            this.recordTypeId = data.recordTypeId;

            // Header name; fall back to the object apiName if Name doesn't exist
            this.recordDisplayName = this.safeGet(data, 'fields.Name.value') || data.apiName;
            //this.recordTypeName =  this.recordDisplayName;
            this.computeActiveRecordTypeName();
            this.ready = true;
            console.log('this.recordDisplayName', this.recordDisplayName);
            console.log('this.recordTypeId', this.recordTypeId);
            console.log('this.this.ready', this.ready);
        }
        this.finishIfReady();
    }
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    wiredObjectInfo({ data, error }) {
        if (error) {
            this.setError(error);
            return;
        }
        if (data) {
            this.objectInfos = data;
            this.computeActiveRecordTypeName();
        }
        this.finishIfReady();
    }
    computeActiveRecordTypeName() {
        if (!this.recordTypeId || !this.objectInfos) return;
        const rtInfo = this.objectInfos.recordTypeInfos[this.recordTypeId];
        if (rtInfo) {
            this.activeRecordTypeDevName = rtInfo.developerName;
        }
    }
    safeGet(obj, path) {
        return path.split('.').reduce((acc, key) => (acc && acc[key] != null ? acc[key] : undefined), obj);
    }
    get activeSections() {
        const cfg = this.parsedConfig;
        console.log('activeSections', JSON.stringify(cfg));
        if (!cfg) return this.defaultSections;
        const sections = (cfg[this.activeRecordTypeDevName] || cfg.Default || this.defaultSections);
        return sections.map((sec, idx) => ({ ...sec, key: `${this.activeRecordTypeDevName || 'Default'}-${idx}` }));
    }
    get parsedConfig() {
        console.log('parsedConfig', JSON.stringify(this.sectionConfigJson));
        if (!this.sectionConfigJson) return null;
        try {

            return JSON.parse(this.sectionConfigJson); // now it's a string → OK
        } catch (e) {
            this.setError({ message: `Invalid JSON in Section Config: ${e.message}` });
            return null;
        }
    }
    setError(error) {
        this.error = error;
        this.loading = false;
        this.ready = false;
        this.errorMessage = error?.body?.message || error?.message || 'Unknown error';
        // eslint-disable-next-line no-console
        console.error('[DynamicPage] error:', error);
    }
    finishIfReady() {
        // Stop spinner once we have object info and we attempted record load (data or error)
        const attemptedRecord = this.recordTypeId !== undefined || this.error !== null;
        if (this.objectInfos && attemptedRecord) {
            this.loading = false;
            this.ready = !this.error;
        }
    }

    
/**
 * 1) Discover all related lists for the object’s default layout.
 *    No recordTypeId needed; default layout is used. [ref]
 */


@wire(getRelatedListsInfo, { parentObjectApiName: '$objectApiName' })
wiredRelatedLists({ data, error }) {
  if (error) {
    this.errorMessage = error?.body?.message || error.message;
    this.loading = false;
    return;
  }
  if (!data) return;

  // Helper: returns true if value contains "history" (case-insensitive)
  const containsHistory = (val) => {
    if (!val || typeof val !== 'string') return false;
    return /history/i.test(val);
  };

  // Filter out "History" related lists
  const discovered = (data.relatedLists || [])
    .filter(rl =>
      rl?.relatedListId &&
      rl?.label &&
      !containsHistory(rl.label) &&
      !containsHistory(rl.objectApiName) &&
      !containsHistory(rl.relatedListId)
    );

  this.relatedListIds = discovered.map(rl => rl.relatedListId);

  // ✅ seed both label and child object API name here
  const seeded = new Map();
  for (const rl of discovered) {
    seeded.set(rl.relatedListId, {
      label: rl.label,
      childObjectApiName: rl.objectApiName // e.g., 'ServiceAppointment'
    });
  }
  this.infoById = seeded;

  if (!this.relatedListIds.length) {
    this.loading = false;
  }
}



/**
 * 2) Get metadata (displayColumns, childObjectApiName) for all discovered lists.
 *    Pass the array of 'relatedListNames' (same IDs we collected). [ref]
 */
@wire(getRelatedListInfoBatch, {
    parentObjectApiName: '$objectApiName',
    relatedListNames: '$relatedListIds'
  })
  wiredInfoBatch({ data, error }) {
    if (error) {
      this.errorMessage = error?.body?.message || error.message;
      this.loading = false;
      return;
    }
    if (!data) return;

    const infoById = new Map(this.infoById);
    const params = [];

    (data.results || []).forEach(item => {
      const result = item?.result;
      if (!result) return;

      const relatedListId = result.listReference?.relatedListId;
      const label = result.label;
      const seededChild = infoById.get(relatedListId)?.childObjectApiName;

      const childObjectApiName =
        result.childObjectApiName ||
        (Array.isArray(result.objectApiNames) ? result.objectApiNames[0] : null) ||
        seededChild ||
        null;

      if (!childObjectApiName) {
        // eslint-disable-next-line no-console
        console.warn(`No childObjectApiName for ${relatedListId}. Skipping fields build.`);
        return;
      }

      const displayColumns = result.displayColumns || [];
      const columns = displayColumns.map(col => ({
        label: col.label,
        fieldName: col.fieldApiName,
        type: 'text',
        sortIcon: 'utility:dash',
        ariaSort: 'none'
      }));

      const fields = displayColumns.map(col => `${childObjectApiName}.${col.fieldApiName}`);

      infoById.set(relatedListId, {
        label: label || infoById.get(relatedListId)?.label || relatedListId,
        childObjectApiName,
        displayColumns,
        columns
      });

      params.push({ relatedListId, fields, pageSize: 50 });
    });

    this.infoById = infoById;
    this.relatedListParameters = params;
  }

  @wire(getRelatedListRecordsBatch, {
    parentRecordId: '$recordId',
    relatedListParameters: '$relatedListParameters'
  })
  wiredBatch({ data, error }) {
    if (error) {
      this.errorMessage = error?.body?.message || error.message;
      this.loading = false;
      return;
    }
    if (!data) return;

    const resultById = new Map();
    (data.results || []).forEach(r => {
      const rlId = r?.result?.listReference?.relatedListId;
      if (rlId) resultById.set(rlId, r.result);
    });

    this.buildUiListsAsync(resultById)
      .then(uiLists => {
        this.lists = uiLists;
        this.loading = false;
      })
      .catch(e => {
        this.errorMessage = e?.message || 'Unable to build related lists.';
        this.loading = false;
      });
  }

  /* ========== BUILD UI (CSS Grid; flexible middle columns) ========== */
  async buildUiListsAsync(resultById) {
    const uiLists = [];

    for (const rlId of this.relatedListIds) {
      const meta = this.infoById.get(rlId) || {};
      const batch = resultById.get(rlId);

      const firstMin = Number.isFinite(this.firstColumnMin) ? this.firstColumnMin : 220;

      // Build min widths for middle columns; default to 160px if missing
      const middleMins = (meta.columns || []).map((c, idx) => {
        const w = this.columnMinWidths?.[idx];
        return Number.isFinite(w) ? w : 160;
      });

      // Flexible grid: first column fixed min, middle columns stretch (1fr) respecting minimums
      // No actions column
      const gridTemplateColumns = [
        `minmax(${firstMin}px, ${firstMin}px)`,
        ...middleMins.map(w => `minmax(${w}px, 1fr)`)
      ].join(' ');
      const gridTemplate = `grid-template-columns:${gridTemplateColumns};`;

      const label = meta.label || rlId;
      const iconName = this.iconName;

      let rows = [];
      let count = 0;
      let errorText;

      let sortBy = null;
      let sortDir = 'asc';

      if (batch?.records) {
        count = batch.count ?? batch.records.length;
        const firstColumnApi = meta.displayColumns?.[0]?.fieldApiName;

        rows = batch.records.map((rec, rowIndex) => {
          const getVal = (api) => {
            const f = rec.fields?.[api];
            return (f?.displayValue ?? f?.value ?? null);
          };

          const row = { Id: rec.id || rec.fields?.Id?.value || null };

          (meta.columns || []).forEach(col => {
            row[col.fieldName] = getVal(col.fieldName);
          });

          row.linkLabel =
            getVal('Name') ||
            (firstColumnApi ? getVal(firstColumnApi) : null) ||
            row.Id;

          row.cells = (meta.columns || []).map(col => ({
            api: col.fieldName,
            label: col.label,
            value: row[col.fieldName]
          }));

          const base = 'dt-row dt-row--data';
          row.rowClass = rowIndex % 2 === 0 ? `${base} dt-row--even` : `${base} dt-row--odd`;

          return row;
        });

        rows = await this.addRecordUrls(rows, meta.childObjectApiName);
      } else if (batch?.error) {
        errorText = batch.error?.body?.message || batch.error?.message || 'Unable to load this related list.';
      }

      const rl = {
        id: rlId,
        label,
        iconName,
        childObjectApiName: meta.childObjectApiName,
        columns: (meta.columns || []).map(c => ({ ...c, sortIcon: 'utility:dash', ariaSort: 'none' })),
        rows,
        count,
        error: errorText,

        // Sorting
        sortBy,
        sortDir,
        firstColumnAriaSort: 'none',

        // Uniform flexible grid applied to header + all rows
        gridTemplate
      };

      uiLists.push(rl);
    }

    return uiLists;
  }

  async addRecordUrls(rows, childObjectApiName) {
    const out = [];
    for (const row of rows) {
      try {
        const pageRef = {
          type: 'standard__recordPage',
          attributes: {
            recordId: row.Id,
            actionName: 'view',
            ...(childObjectApiName ? { objectApiName: childObjectApiName } : {})
          }
        };
        const url = await thisNavigationMixin.GenerateUrl;
        row.recordUrl = url || '#';
      } catch (e) {
        row.recordUrl = childObjectApiName
          ? `/lightning/r/${childObjectApiName}/${row.Id}/view`
          : `/lightning/r/record/${row.Id}/view`;
      }
      out.push(row);
    }
    return out;
  }

  /* ========== Sorting (optional) ========== */
  handleSortClick(evt) {
    const sortKey = evt.currentTarget?.dataset?.sortKey; // fieldApiName or '__link__'
    const rlId = evt.currentTarget?.dataset?.rlid;
    if (!sortKey || !rlId) return;
    this.applySort(rlId, sortKey);
  }
  handleSortKeydown(evt) {
    if (evt.key === 'Enter' || evt.key === ' ') {
      evt.preventDefault();
      this.handleSortClick(evt);
    }
  }

  applySort(rlId, sortKey) {
    const lists = [...this.lists];
    const idx = lists.findIndex(l => l.id === rlId);
    if (idx < 0) return;
    const rl = { ...lists[idx] };

    const nextDir = rl.sortBy === sortKey && rl.sortDir === 'asc' ? 'desc' : 'asc';
    rl.sortBy = sortKey;
    rl.sortDir = nextDir;

    const factor = nextDir === 'asc' ? 1 : -1;
    rl.rows = [...rl.rows].sort((a, b) => {
      const av = sortKey === '__link__' ? (a.linkLabel || '') : (a[sortKey] ?? '');
      const bv = sortKey === '__link__' ? (b.linkLabel || '') : (b[sortKey] ?? '');
      return (av > bv ? 1 : av < bv ? -1 : 0) * factor;
    });

    // Recompute zebra classes
    rl.rows = rl.rows.map((row, i) => {
      const base = 'dt-row dt-row--data';
      return { ...row, rowClass: i % 2 === 0 ? `${base} dt-row--even` : `${base} dt-row--odd` };
    });

    lists[idx] = rl;
    this.lists = lists;
  }

  /* ========== Link click -> handler (no navigation) ========== */
 
async handleLinkClick(event) {
  const isModifier =
    event.ctrlKey ||
    event.metaKey ||
    event.shiftKey ||
    event.altKey ||
    event.button === 1;

  if (!isModifier) {
    event.preventDefault();
    event.stopPropagation();

    const recordId = event.currentTarget?.dataset?.id;
    if (!recordId) {
      console.warn('No data-id found on clicked element.');
      return;
    }

    this.selectedRecordId = recordId;

    try {
      this.objectApiName = await getObjectApiName({ recordId: this.selectedRecordId });
      console.log('Link Clicked (recordId):', this.selectedRecordId);
      console.log('Resolved objectApiName:', this.objectApiName);
      // TODO: continue your flow here
    } catch (error) {
      console.error('Failed to fetch object API name', error);
    }
  }
}

  
  // Shreya code
      @track isReplanModalOpen = false;
      @track isCancelModalOpen = false;
      //@track replanCancelFlag = false;
      // ticketid;
      // ticketuid;
      action;
      requestid;
      request;
      status;
      selectedSlot = '';
      selectedDate = '';
      appointmentOptions = [];
      holidays = [];
      userId = USER_ID;
      email;
      reason = '';
      //mainFlag = true;
      appointmentDateError = 'Please select a date';
      appointmentSlotError = 'Please select a slot';
      reasonError = 'Please enter a reason';
      @track dateFlag = false;
      @track slotFlag = false;
      @track reasonFlag = false;
      @track acceptRejectFlag = false;
      quotationStatus='';
      commentError = 'Please enter comment to proceed';
      comment = '';
      @track commentFlag = false;
      @track isAccept = false;
      acceptedFormats = ['.pdf', '.png', '.jpg', '.docx', '.xlsx'];
      @track cancelChargeFlag = false;
      @track filesToUpload = [];
  
      residentialSlots = [{
     code: 'S1',
     timeframe: '08:00 - 11:00'
  }, {
     code: 'S2',
     timeframe: '10:00 - 13:00'
  }, {
     code: 'S3',
     timeframe: '12:00 - 15:00'
  }, {
     code: 'S4',
     timeframe: '14:00 - 17:00'
  }, {
     code: 'S5',
     timeframe: '16:00 - 19:00'
  }, {
     code: 'S6',
     timeframe: '18:00 - 21:00'
  }];
  
  commercialSlots = [{
     code: 'S1',
     timeframe: '08:00 - 12:00'
  }, {
     code: 'S2',
     timeframe: '10:00 - 14:00'
  }, {
     code: 'S3',
     timeframe: '12:00 - 16:00'
  }, {
     code: 'S4',
     timeframe: '14:00 - 18:00'
  }, {
     code: 'S5',
     timeframe: '16:00 - 20:00'
  }];
  
  
  // --- Residential (Weekday) Slots ---
      residentialWeekdaySlots = [
          { label: '08:00 - 11:00', value: 'S1' },
          { label: '10:00 - 13:00', value: 'S2' },
          { label: '12:00 - 15:00', value: 'S3' },
          { label: '14:00 - 17:00', value: 'S4' },
          { label: '16:00 - 19:00', value: 'S5' },
          { label: '18:00 - 21:00', value: 'S6' }
      ];
  
      // --- Commercial & Residential (Weekend / Holiday) Slots ---
      commercialAndWeekendSlots = [
          { label: '08:00 - 12:00', value: 'S1' },
          { label: '10:00 - 14:00', value: 'S2' },
          { label: '12:00 - 16:00', value: 'S3' },
          { label: '14:00 - 18:00', value: 'S4' },
          { label: '16:00 - 20:00', value: 'S5' } 
      ];
  
      @wire(getRecord, { recordId: '$userId', fields: FIELDS })
          userRecord({ error, data }) {
              if (data) {
                  this.email = data.fields.Email.value;
              }
          }
      
      handleReplanCancelJob(){
          this.replanCancelFlag = true;
          //this.mainFlag = false;
      }
      handleCancelJob() {
          this.isCancelModalOpen = true;
          this.isReplanModalOpen = false;
          this.action = 'CANCELLED';
                      
          
      }
  
      handleReplanJob() {
          this.isReplanModalOpen = true;
          this.isCancelModalOpen = false;
          this.action = 'REPLAN';
      
      }
  
      closeCancelModal(){
          this.isCancelModalOpen = false;
          this.reason = '';
          this.dateFlag = false;
          this.slotFlag = false;
          this.reasonFlag = false;
      }
      closeReplanModal(){
          this.isReplanModalOpen = false;
          this.selectedDate = '';
          this.selectedSlot = '';
          this.reason = '';
          this.dateFlag = false;
          this.slotFlag = false;
          this.reasonFlag = false;
      }
  
      connectedCallback(){
          // this.ticketid = '1966006';
          // this.ticketuid = '3242094'
          this.status = 'Commercial';
          this.requestid = 'a5Bdu000000ALROEA4';
          getRequest({requestid: this.requestid})
              .then(result => {
                  this.request = result;
                  console.log('request: ' , this.request);
              })
              .catch(error => {
                  
              });
      }
  
      handleYes() {
          console.log('handleYes triggered!');
          console.log('this.action:', this.action);
          console.log('this.selectedDate:', this.selectedDate);
          console.log('this.selectedSlot:', this.selectedSlot);
          console.log('this.reason:', this.reason);
     
          if(this.action == 'REPLAN' && (this.selectedDate == '' || this.selectedDate == null || this.selectedDate == undefined)){
              this.dateFlag = true;
          }else{
              this.dateFlag = false;
          }
           if(this.action == 'REPLAN' && (this.selectedSlot == '' || this.selectedSlot == null || this.selectedSlot == undefined)){
              this.slotFlag = true;
          }else{
              this.slotFlag = false;
          }
          if(this.reason == '' || this.reason == null || this.reason == undefined){
              this.reasonFlag = true;
          }else{
              this.reasonFlag = false;
          }
          console.log('this.dateFlag:', this.dateFlag);
          console.log('this.slotFlag:', this.slotFlag);
          console.log('this.reasonFlag:', this.reasonFlag);
          if((this.action == 'CANCELLED' && !this.reasonFlag) ||
              (this.action == 'REPLAN' && !this.reasonFlag && !this.dateFlag && !this.slotFlag)){
     
          
  
          const payload = {
              ticketuid: this.request.NGMCP_Ticketuid__c,
              ticketid: this.request.NGMCP_SR_Ticket__c,
              ngme_time: this.selectedSlot,
              target1start: this.selectedDate,
              action: this.action,
              reason: this.reason
          };
          console.log('Payload submitted:', JSON.stringify(payload)); 
          if(this.request.NGMCP_Non_Standard__c){
              console.log('updateNSRequest ');
              updateNSRequest({requestBody: JSON.stringify(payload), requestId: this.requestid,
              ticketuid: this.request.NGMCP_Ticketuid__c, reportedEmail : this.email})
              .then(result => {
                  console.log('result: ', result);
                  this.isCancelModalOpen = false;
                  this.isReplanModalOpen = false;
                  this.selectedDate = '';
                  this.selectedSlot = '';
                  this.reason = '';
                  this.dateFlag = false;
                  this.slotFlag = false;
                  this.reasonFlag = false;
                  if(this.action == 'CANCELLED'){
                      alert('Job cancelled successfully')
                  }else{
                      alert('Job replanned successfully')
                  }
                  
              })
              .catch(error => {
                  console.log('error: ', JSON.stringify(error));
                  alert('Error: ' + error);
              });    
          }
          else{
              console.log('submitCancelJob ');
          submitCancelJob({requestBody: JSON.stringify(payload), requestId: this.requestid,
              ticketuid: this.request.NGMCP_Ticketuid__c, reportedEmail : this.email
          })
              .then(result => {
                  console.log('result: ', result);
                  this.isCancelModalOpen = false;
                  this.isReplanModalOpen = false;
                  this.selectedDate = '';
                  this.selectedSlot = '';
                  this.reason = '';
                  this.dateFlag = false;
                  this.slotFlag = false;
                  this.reasonFlag = false;
                  if(this.action == 'CANCELLED'){
                      alert('Job cancelled successfully')
                  }else{
                      alert('Job replanned successfully')
                  }
                  
              })
              .catch(error => {
                  console.log('error: ', JSON.stringify(error));
                  alert('Error: ' + error.body.message);
              });
          }
          }
      }
  
      handleSlotChange(event) {
          console.log('event.detail.value:', event.detail.value);
          this.selectedSlot = this.status == 'Commercial' ? this.handleCommercialTime(event.detail.value) : this.handleResidentialTime(event.detail.value);
          console.log('selectedSlot:', this.selectedSlot);
          this.slotFlag = false;
      }
  
  
    handleDateChange(event) {
          console.log('handleDateChange triggered!');
          this.dateFlag = false;
          const selectedDate = event.detail.date;
          console.log('Selected date from child:', selectedDate);
          this.selectedDate = selectedDate;
          console.log('this.selectedDate:', this.selectedDate);
          console.log('typeof this.updateAppointmentSlots:', typeof this.updateAppointmentSlots);
          console.log('About to call updateAppointmentSlots...');
          this.updateAppointmentSlots();
      }
  
      updateAppointmentSlots() {
      console.log('updateAppointmentSlots actually running now.');
      console.log('this.status:', this.status);
  
          // Check that both status and date are available
          if (!this.selectedDate || !this.status) {
              this.appointmentOptions = [];
              return;
          }
  
          const statusLower = this.status.toLowerCase();
          const selected = new Date(this.selectedDate);
          const day = selected.getDay(); // 0 = Sunday, 6 = Saturday
          const isWeekend = (day === 0 || day === 6);
  
          // Normalize date formats for holiday comparison
          const selectedDateOnly = selected.toISOString().split('T')[0];
          const isHoliday = this.holidays.some(h => h === selectedDateOnly);
  
          console.log('Status:', statusLower);
          console.log('Selected Date:', selectedDateOnly);
          console.log('Is Weekend:', isWeekend);
          console.log('Is Holiday:', isHoliday);
  
          // --- Main Logic ---
          if (statusLower === 'residential') {
              if (!isWeekend && !isHoliday) {
                  this.appointmentOptions = this.residentialWeekdaySlots;
              } else {
                  this.appointmentOptions = this.commercialAndWeekendSlots;
              }
          } else if (statusLower === 'commercial') {
              this.appointmentOptions = this.commercialAndWeekendSlots;
          } else {
              this.appointmentOptions = [];
          }
  
          console.log('Rendered Slots:', JSON.stringify(this.appointmentOptions));
      }
  
      @wire(getHolidays)
      wiredHolidays({ data, error }) {
          if (data) {
              console.log('Raw Holidays:', data);
              
              console.log('Holidays:', JSON.stringify(data));
             //this.holidays = data.map(h => h.ActivityDate.split('T')[0]);
              console.log('Normalized Holidays:', this.holidays);
          } else if (error) {
              console.error('Error fetching holidays:', error);
          }
      }
  
      handleInputChange(event){
          this.reason = event.target.value;
          if(this.reason == null || this.reason == '' || this.reason == undefined){
              this.reasonFlag = true;
          }else{
              this.reasonFlag = false;
          }
      }
  
      handleAcceptQuotation(event){
          this.quotationStatus = event.target.name;
          console.log('this.quotationStatus: ',this.quotationStatus);
          this.acceptRejectFlag = true;
          if(event.target.name == 'Accept'){
              this.isAccept = true;
          }else{
              this.isAccept = false;
          }
      }
  
      closeAcceptRejectModal(){
          this.acceptRejectFlag = false;
          this.comment = '';
          this.commentFlag = false;
      }
  
      handleComment(event){
          this.comment = event.target.value;
          console.log('comment: ', this.comment);
          if(this.comment == null || this.comment == '' || this.comment == undefined){
              this.commentFlag = true;
          }else{
              this.commentFlag = false;
          }
      }
  
      handleQuotation(){
          console.log('handleQuotation triggered');
          console.log('comment: ', this.comment);
          if(this.comment == null || this.comment == '' || this.comment == undefined){
              this.commentFlag = true;
          }else{
              this.commentFlag = false;
              const payload = {
  
                  ticketid: '1380428',
                  status: this.quotationStatus == 'Accept' ? 'ACCEPTED' : 'REJECTED',
                  comment: this.comment
              };
              console.log('Payload submitted:', JSON.stringify(payload));
  
              submitAcceptRejectQuotation({requestBody: JSON.stringify(payload), 
                  requestId: this.requestid, 
              })
              .then(result => {
                  console.log('result: ', result);
                  this.acceptRejectFlag = false;
                  this.comment = '';
                  this.commentFlag = false;
                  
                  alert('Quotation ' + payload.status.toLowerCase() + ' successfully')
              })
              .catch(error => {
                  console.log('error: ', JSON.stringify(error));
                  alert('Error: ' + error.body.message);
              });
          }
      }
  
      handleCommercialTime(slot){
         console.log('Inside handleCommercialTime: ', slot);
         let message = '';
         switch (slot) {
          case 'S1':
              message = '08:00 - 12:00'
              break;
          case 'S2':
              message = '10:00 - 14:00'
              break;
          case 'S3':
              message = '12:00 - 16:00'
              break;
          case 'S4':
              message = '14:00 - 18:00'
              break;
          case 'S5':
              message = '16:00 - 20:00'
              break;  
          default:
              break;
         }
      return message;
      }
  
      handleResidentialTime(slot){
         console.log('Inside handleResidentialTime: ', slot);
         let message = '';
         switch (slot) {
          case 'S1':
              message = '08:00 - 11:00'
              break;
          case 'S2':
              message = '10:00 - 13:00'
              break;
          case 'S3':
              message = '12:00 - 15:00'
              break;
          case 'S4':
              message = '14:00 - 17:00'
              break;
          case 'S5':
              message = '16:00 - 19:00'
              break;
          case 'S6':
              message = '18:00 - 21:00'
              break;       
          default:
              break;
         }
      return message;
      }
  
      handleUploadFinished(event) {
          // Get the list of uploaded files
          const uploadedFiles = event.detail.files;
          console.log('uploadedFiles: ', uploadedFiles);
          // You can perform further actions with the uploaded files here
      }
  
      handleCancel(){
          if(this.reason == '' || this.reason == null || this.reason == undefined){
              this.reasonFlag = true;
          }else{
              this.reasonFlag = false;
              const twoDaysLaterISO = new Date();
              twoDaysLaterISO.setDate(twoDaysLaterISO.getDate() + 2);
              const formatted = twoDaysLaterISO.toISOString().slice(0, 10); 
              console.log('formatted', formatted); //this.request.NGMCP_Job_SubType__c
              if(this.request.NGMCP_Target_Start__c < formatted && this.request.NGMCP_Job_SubType__c == 'Adversarial Removal'){
                  this.cancelChargeFlag = true
              }else{
                  this.cancelChargeFlag = false
                  this.handleYes();
              }
          }
         
          console.log('this.reasonFlag', this.reasonFlag);
          console.log('this.cancelChargeFlag', this.cancelChargeFlag);
      }
  
      async handleFileChange(event) {
          this.filesToUpload = [...event.target.files];
          if (!this.requestid) {
              alert('Request Id is missing.');
              return;
          }
          try {
              const results = [];
              for (const file of this.filesToUpload) {
                  const base64 = await this.readFileAsBase64(file);
                  const docId = await uploadAndLinkFileToRequest({
                      requestId: this.requestid,
                      fileName: file.name,
                      base64Data: base64
                  });
                  results.push({ name: file.name, documentId: docId });
              }
              console.log('Uploaded files:', JSON.stringify(results));
              //this.showToast('Success', `Uploaded ${results.length} file(s).`, 'success');
              alert('File uploaded successfully!');
              this.filesToUpload = [];
          } catch (e) {
              console.error(e);
              alert('Error uploading file: ' + e);
          }
      }
  
      readFileAsBase64(file) {
          return new Promise((resolve, reject) => {
              const reader = new FileReader();
              reader.onload = () => {
                  // Data URL -> strip the prefix (e.g., "data:application/pdf;base64,")
                  const base64 = reader.result.split(',')[1];
                  resolve(base64);
              };
              reader.onerror = reject;
              reader.readAsDataURL(file);
          });
      }
  
         showToast(title, message, variant) {
          this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
      }
      setButtonVisibility() {
        const status = this.stat || '';
        // Replan + Cancel when status = In Progress / New
        const isNewOrInProgress =
            status === 'In Progress' || status === 'New' ;
        // Completion Details when status = Complete / Further Work
        const isCompleteOrFurtherWork =
            status === 'Complete' || status === 'Further Work';
        this.showReplan = isNewOrInProgress;
        this.showCancel = isNewOrInProgress;
        this.showCompletion = isCompleteOrFurtherWork ;
    }


}