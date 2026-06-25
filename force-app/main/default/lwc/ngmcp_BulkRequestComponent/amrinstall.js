/**
 * Validate mandatory fields across a list of records.
 *
 * @param {Array<Object>} records - e.g., [{ 'Customer': 'BRO', 'Trans Ref': '...' }, ...]
 * @param {Array<string>} mandatoryFields - e.g., ['Customer', 'Trans Ref', ...]
 * @param {Object} [options]
 * @param {boolean} [options.caseInsensitive=true] - Match field names case-insensitively.
 * @param {boolean} [options.trimValues=true] - Trim string values before checking emptiness.
 * @param {boolean} [options.whitespaceEmpty=true] - Treat whitespace-only values as empty.
 * @param {number}  [options.lineOffset=2] - Human readable line number base (CSV rows start at 2).
 * @returns {{
 *   ok: boolean,
 *   rowErrors: Array<{ index:number, line:number, missing:string[], ref?:string }>,
 *   checkedFields: string[]
 * }}
 */
export function validateAMRInstallBulkUpload(records, mandatoryFields, options = {}) {
    const {
        caseInsensitive = true,
        trimValues = true,
        whitespaceEmpty = true,
        lineOffset = 2
    } = options;

    const toKey = s => {
        const v = String(s ?? '');
        return caseInsensitive ? v.toLowerCase().trim() : v.trim();
    };

    const safeRecords = Array.isArray(records) ? records : [];
    console.log('safeRecords in amrinstall.js: ', safeRecords);
    console.log('safeRecords in amrinstall.js: ', JSON.stringify(safeRecords));
    const safeMandatory = Array.isArray(mandatoryFields) ? mandatoryFields : [];
    console.log('safeMandatory in amrinstall.js: ', safeMandatory);
    console.log('safeMandatory in amrinstall.js: ', JSON.stringify(safeMandatory));
    const rowErrors = [];

    safeRecords.forEach((row, idx) => {
        // Normalize keys for case-insensitive lookups
        const normRow = {};
        Object.keys(row || {}).forEach(k => {
            normRow[toKey(k)] = row[k];
        });

        const missing = [];
        for (const field of safeMandatory) {
            const key = toKey(field);
            let val = normRow[key];

            // Normalize value
            if (val === null || val === undefined) {
                val = '';
            } else if (typeof val === 'string') {
                val = trimValues ? val.trim() : val;
            } else if (val === 0 || val === false) {
                // treat as non-empty valid values
            } else {
                val = String(val);
                if (trimValues) val = val.trim();
            }

            const isEmpty = whitespaceEmpty ? String(val).length === 0 : val === '';
            if (isEmpty) {
                missing.push(field);
            }
        }
        console.log('missing in amrinstall.js: ', missing);
        console.log('missing in amrinstall.js: ', JSON.stringify(missing));
        if (missing.length > 0) {
            // Include a handy reference like Trans Ref (if present) to identify the row
            //const ref = row['Trans Ref'] || row['trans ref'] || row['TransRef'] || '';
            rowErrors.push({
                index: idx,                 // 0-based index in your array
                line: idx + lineOffset,     // human-readable (CSV header = line 1, so data starts at 2)
                missing,
                //ref
            });
        }
    });

    console.log('rowErrors in amrinstall.js: ', rowErrors);
    console.log('rowErrors in amrinstall.js: ', JSON.stringify(rowErrors));
    console.log('rowErrors.length in amrinstall.js: ', rowErrors.length);

    return {
        ok: rowErrors.length === 0,
        rowErrors
        //checkedFields: [...safeMandatory]
    };
}