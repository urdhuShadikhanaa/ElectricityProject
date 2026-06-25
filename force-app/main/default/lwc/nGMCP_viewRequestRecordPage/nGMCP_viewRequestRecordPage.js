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

export default class NGMCP_viewRequestRecordPage extends NavigationMixin(LightningElement) {
  /** Parent record context provided by the record page */
    @api recordId = '0WOdu000002hfYDGAY';        // e.g., Account Id
    objectApiName;
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
  handleLinkClick(event) {
    const isModifier =
      event.ctrlKey || event.metaKey || event.shiftKey || event.altKey || event.button === 1;
    if (!isModifier) {
      event.preventDefault();
      event.stopPropagation();
     this.recordId = event.currentTarget?.dataset?.id;
     this.selectedRecordId = event.currentTarget?.dataset?.id;
      console.log('Link Clicked:', this.selectedRecordId);
      console.log('Link Clicked:', this.objectApiName);      
    }
  }


}