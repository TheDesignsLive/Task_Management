// utils/notifyMobile.js — Desktop utility
// ✅ When desktop changes a task, this pings the mobile server
// Mobile then emits socket event to all its connected React clients

const MOBILE_BASE_URL = 'https://m-tms.thedesigns.live';
const MOBILE_SECRET   = 'tms_mobile_bridge_2026';

function notifyMobile() {
    // ✅ Fire and forget
    fetch(`${MOBILE_BASE_URL}/api/notify-task-update`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'x-mobile-secret': MOBILE_SECRET,
        },
        body: JSON.stringify({ event: 'update_tasks' }),
    })
    .then(r => r.json())
    .then(d => { if (!d.success) console.warn('[notifyMobile] failed:', d); })
    .catch(err => console.error('[notifyMobile] error:', err.message));
}

module.exports = { notifyMobile };