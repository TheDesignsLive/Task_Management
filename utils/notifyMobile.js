// utils/notifyMobile.js — Desktop utility
// ─── REPLACE the entire notifyMobile.js ──────────────────────────────────────
const MOBILE_BASE_URL = 'https://m-tms.thedesigns.live';
const MOBILE_SECRET   = 'tms_mobile_bridge_2026';

// ✅ Use node-fetch if native fetch not available (Node < 18)
const _fetch = typeof fetch !== 'undefined' ? fetch : (...args) => import('node-fetch').then(m => m.default(...args));

function notifyMobile(type = 'tasks', extraData = {}) {
    const endpoints = {
        tasks:                `${MOBILE_BASE_URL}/api/notify-task-update`,
        profile:              `${MOBILE_BASE_URL}/api/notify-profile-update`,
        members:              `${MOBILE_BASE_URL}/api/notify-members-update`,
        roles:                `${MOBILE_BASE_URL}/api/notify-roles-update`,
        teams:                `${MOBILE_BASE_URL}/api/notify-teams-update`,
        announcement_add:     `${MOBILE_BASE_URL}/api/notify-announcement-add`,
        announcement_edit:    `${MOBILE_BASE_URL}/api/notify-announcement-edit`,
        announcement_delete:  `${MOBILE_BASE_URL}/api/notify-announcement-delete`,
    };
    const endpoint = endpoints[type] || endpoints.tasks;

_fetch(endpoint, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'x-mobile-secret': MOBILE_SECRET,
            'x-source': 'desktop',
        },
        body: JSON.stringify({ event: type, ...extraData }),
    })
    .then(r => r.json())
    .then(d => { if (!d.success) console.warn('[notifyMobile] failed:', type, d); })
    .catch(err => console.error('[notifyMobile] error:', err.message));
}

module.exports = { notifyMobile };