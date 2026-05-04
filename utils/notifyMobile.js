// utils/notifyMobile.js — Desktop utility
const MOBILE_BASE_URL = 'https://m-tms.thedesigns.live';
const MOBILE_SECRET   = 'tms_mobile_bridge_2026';

function notifyMobile(type = 'tasks') {
    const endpoints = {
        tasks:   `${MOBILE_BASE_URL}/api/notify-task-update`,
        profile: `${MOBILE_BASE_URL}/api/notify-profile-update`,
        members: `${MOBILE_BASE_URL}/api/notify-members-update`,
        roles: `${MOBILE_BASE_URL}/api/notify-roles-update`,
    };
    const endpoint = endpoints[type] || endpoints.tasks;

    fetch(endpoint, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'x-mobile-secret': MOBILE_SECRET,
            'x-source': 'desktop',
        },
        body: JSON.stringify({ event: type }),
    })
    .then(r => r.json())
    .then(d => { if (!d.success) console.warn('[notifyMobile] failed:', d); })
    .catch(err => console.error('[notifyMobile] error:', err.message));
}

module.exports = { notifyMobile };