import { LightningElement, api, track } from 'lwc';
import downloadDocuments from '@salesforce/apex/NGMCP_IBMMaximoIntegrationClass.downloadDocuments';

export default class NGMCP_maximoFileDownloadComponent extends LightningElement {
     @api srNumber;// = '1966667';
    
      @track viewRows = [];
      @track loading = false;
      
      @track error;
    
      connectedCallback() {
        this.loadDocuments();
      }
    
      get hasRows() {
        return Array.isArray(this.viewRows) && this.viewRows.length > 0;
      }
    
      async loadDocuments() {
        this.loading = true;
        this.error = null;
        try {
          const result = await downloadDocuments({ srNumber: this.srNumber });
          const rows = [];
    
          let mi = 0;
          result?.member?.forEach(member => {
            let di = 0;
            member?.doclinks?.forEach(doc => {
              const base64 = (doc?.documentdata || '').trim();
              if (!base64) { di++; return; }    
              // Decode a small head segment to infer MIME safely
              const headSegment = base64.substring(0, Math.min(base64.length, 128));
              const decodedHead = atob(headSegment);
    
              const mime = this.inferMime(decodedHead, doc);
              const fileName = this.suggestFileName(doc, mime);
              const shortCode = (doc?.ngme_doctype || '').trim();
              if (shortCode !== 'QOT') { di++; return; }
              const description = (doc?.ngme_doctype_description || '').trim();    
              rows.push({
                key: `${mi}-${di}`,
                shortCode,
                description,
                fileName,
                mime,
                base64
              });
              di++;
            });
            mi++;
          });
    
          this.viewRows = rows;
        } catch (e) {
          this.error = e?.body?.message || e?.message || 'Failed to load documents';
          this.viewRows = [];
        } finally {
          this.loading = false;
        }
      }
    
      /**
       * Infer MIME type using binary signature and fallback to extension.
       * Office Open XML files (docx/xlsx/pptx) are ZIP containers (`PK` signature).
       */
      inferMime(decodedHead, doc) {
        try {
          if (decodedHead.startsWith('\x89PNG')) return 'image/png';
          if (decodedHead.startsWith('\xFF\xD8')) return 'image/jpeg';
          if (decodedHead.startsWith('GIF8')) return 'image/gif';
          if (decodedHead.startsWith('%PDF')) return 'application/pdf';
    
          if (decodedHead.startsWith('PK')) {
            const name = (doc?.description || doc?.ngme_doctype_description || doc?.document || '').toLowerCase();
            if (name.endsWith('.docx')) return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            if (name.endsWith('.xlsx')) return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
            if (name.endsWith('.pptx')) return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
            return 'application/zip'; // when extension unknown
          }
    
          const name = (doc?.description || doc?.ngme_doctype_description || doc?.document || '').toLowerCase();
          if (name.endsWith('.txt')) return 'text/plain';
          if (name.endsWith('.csv')) return 'text/csv';
          if (name.endsWith('.json')) return 'application/json';
          if (name.endsWith('.xml')) return 'application/xml';
    
          return 'application/octet-stream';
        } catch {
          return 'application/octet-stream';
        }
      }
    
     
    /**
     * Return a clean display/download name:
     *  - remove 'cos:doclinks/' prefix
     *  - reduce any path to basename
     *  - DO NOT append extension or MIME-based suffix
     */
    suggestFileName(doc) {
      const stripPrefix = (txt) => (txt || '').replace(/^cos:doclinks\//i, '').trim();
    
      const basename = (p) => {
        try {
          if (!p) return null;
          const s = stripPrefix(p);
          const parts = s.split('/');
          return parts[parts.length - 1] || null;
        } catch {
          return null;
        }
      };
    
      // Preferred sources: description → urlname basename → document → 'Document'
      let name =
        stripPrefix(doc?.description) ||
        basename(doc?.urlname) ||
        (doc?.document || '').trim() ||
        'Document';
    
      // If the resulting value itself looks like a path, reduce to basename
      const maybeBase = basename(name);
      if (maybeBase) name = maybeBase;
    
      // IMPORTANT: do not append any extension/content based on MIME
      return name;
    }
      extFromMime(mime) {
        switch (mime) {
          case 'image/png': return '.png';
          case 'image/jpeg': return '.jpg';
          case 'image/gif': return '.gif';
          case 'application/pdf': return '.pdf';
          case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document': return '.docx';
          case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': return '.xlsx';
          case 'application/vnd.openxmlformats-officedocument.presentationml.presentation': return '.pptx';
          case 'application/zip': return '.zip';
          case 'text/plain': return '.txt';
          case 'text/csv': return '.csv';
          case 'application/json': return '.json';
          case 'application/xml': return '.xml';
          default: return '';
        }
      }
    
      /**
       * Decode Base64 -> bytes -> Blob -> Object URL -> trigger browser download.
       * For Office/ZIP, force `application/octet-stream` to bypass LWS MIME restrictions.
       */
      handleDownload(evt) {
        console.log('handleDownload');
        const key = evt.currentTarget.dataset.key;
        console.log('keDetailsy',JSON.stringify(evt));
        console.log('key',key);
        const row = this.viewRows.find(r => r.key === key);
        if (!row) return;
    
        try {
          const binary = atob(row.base64);
          const bytes = new Uint8Array(binary.length);
          for (let i = 0; i < binary.length; i++) {
            bytes[i] = binary.charCodeAt(i);
          }
    
          const isOfficeOrZip =
            row.mime === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
            row.mime === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
            row.mime === 'application/vnd.openxmlformats-officedocument.presentationml.presentation' ||
            row.mime === 'application/zip';
    
          const effectiveMime = isOfficeOrZip ? 'application/octet-stream' : row.mime;
    
          const blob = new Blob([bytes], { type: effectiveMime });
          const url = URL.createObjectURL(blob);
    
          const a = document.createElement('a');
          a.href = url;
          a.download = row.fileName; // include .docx/.xlsx extension
          a.rel = 'noopener';
          a.target = '_self'; // safer in LWS
          a.style.display = 'none';
          document.body.appendChild(a);
          a.click();
    
          setTimeout(() => {
            URL.revokeObjectURL(url);
            document.body.removeChild(a);
          }, 1000);
        } catch (e) {
          this.error = e?.message || 'Download failed';
        }
      }
}