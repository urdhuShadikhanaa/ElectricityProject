const ZWSP = /\u200B/g;

const PORTAL_FIELD_BY_LABEL = {
    'Building Number': 'buildingNumber',
    'Building Name': 'buildingName',
    Street: 'street',
    'Dependent Locality': 'dependentLocality',
    'Postal Town': 'postalTown',
    'Post Code': 'postCode'
};

export function normalizeVerificationStatus(status) {
    return (status || '').replace(ZWSP, '').trim();
}

function pick(address, ...keys) {
    for (const key of keys) {
        const value = address[key];
        if (value !== undefined && value !== null && String(value).trim() !== '') {
            return String(value).trim();
        }
    }
    return '';
}

function toUpper(value) {
    return (value || '').trim().toUpperCase();
}

/**
 * Maps ProvenWorks AVFC addresschange payload to NGME portal address fields.
 */
export function mapAvfcToPortalAddress(raw) {
    const address = raw?.address || raw || {};

    let buildingNumber = pick(
        address,
        'buildingNumber',
        'buildingnumber',
        'subBuilding',
        'subbuilding'
    );
    let buildingName = pick(
        address,
        'buildingName',
        'buildingname',
        'organisation',
        'organization'
    );
    let street = pick(address, 'street');
    const street2 = pick(address, 'street2');
    const city = pick(address, 'city');
    const postalCode = pick(address, 'postalCode', 'postalcode');
    const county = pick(address, 'county');

    if (!buildingNumber && street) {
        const match = street.match(/^(\d+[A-Z]?)\s+(.+)$/i);
        if (match) {
            buildingNumber = match[1];
            street = match[2];
        }
    }

    let dependentLocality = street2;
    if (!buildingName && street2) {
        const looksLikeThoroughfare = /\b(STREET|ROAD|LANE|AVENUE|DRIVE|CLOSE|WAY|CRESCENT|GARDENS)\b/i.test(
            street2
        );
        if (!looksLikeThoroughfare) {
            buildingName = street2;
            dependentLocality = county;
        }
    }

    return {
        buildingNumber: toUpper(buildingNumber),
        buildingName: toUpper(buildingName),
        street: toUpper(street),
        dependentLocality: toUpper(dependentLocality || county),
        postalTown: toUpper(city),
        postCode: toUpper(postalCode),
        verificationStatus: normalizeVerificationStatus(pick(address, 'status'))
    };
}

export function applyPortalAddressToBuffer(buffer, portalAddress) {
    return (buffer || []).map((item) => {
        const apiKey =
            item.apiName || PORTAL_FIELD_BY_LABEL[item.label] || item.label;
        const value = portalAddress[apiKey];
        if (value !== undefined && value !== null) {
            return { ...item, value };
        }
        return item;
    });
}

export function applyPortalAddressToDetails(details, portalAddress) {
    return (details || []).map((item) => {
        const apiKey = item.apiName || PORTAL_FIELD_BY_LABEL[item.label];
        if (!apiKey) {
            return item;
        }
        const value = portalAddress[apiKey];
        if (value !== undefined && value !== null) {
            return { ...item, value };
        }
        return item;
    });
}