// ============================================================
// backup.js — MySQL → Local .sql → Google Drive
// Production-ready for Hostinger VPS/shared hosting
// ============================================================

const { exec } = require('child_process');
const fs = require('fs');
const fsPromises = require('fs/promises');
const path = require('path');
const { google } = require('googleapis');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

// ─── Helpers ────────────────────────────────────────────────

function getISTTime() {
    return new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' });
}

function log(msg) {
    const ts = `[${getISTTime()}]`;
    console.log(`${ts} ${msg}`);
}

function buildFileName() {
    const now = new Date(new Date().toLocaleString('en-US', { timeZone: 'Asia/Kolkata' }));
    const yyyy = now.getFullYear();
    const mm   = String(now.getMonth() + 1).padStart(2, '0');
    const dd   = String(now.getDate()).padStart(2, '0');
    const hh   = String(now.getHours()).padStart(2, '0');
    const min  = String(now.getMinutes()).padStart(2, '0');
    const ampm = now.getHours() < 12 ? 'AM' : 'PM';
    // e.g. backup-2026-05-07-02-00-AM.sql
    return `backup-${yyyy}-${mm}-${dd}-${hh}-${min}-${ampm}.sql`;
}

// ─── Google Drive Auth ───────────────────────────────────────
// Credentials are read from .env — NO service-account.json in repo

function getDriveClient() {
    const credentials = {
        type: 'service_account',
        project_id:   process.env.GDRIVE_PROJECT_ID,
        private_key_id: process.env.GDRIVE_PRIVATE_KEY_ID,
        // .env stores the key with literal \n — replace so it becomes real newlines
        private_key: (process.env.GDRIVE_PRIVATE_KEY || '').replace(/\\n/g, '\n'),
        client_email: process.env.GDRIVE_CLIENT_EMAIL,
        client_id:    process.env.GDRIVE_CLIENT_ID,
        token_uri:    'https://oauth2.googleapis.com/token',
    };

    const auth = new google.auth.GoogleAuth({
        credentials,
        scopes: ['https://www.googleapis.com/auth/drive'],
    });

    return google.drive({ version: 'v3', auth });
}

// ─── Step 1: Dump MySQL to local .sql ───────────────────────

function dumpDatabase(filePath) {
    return new Promise((resolve, reject) => {
        const host = process.env.DB_HOST;
        const user = process.env.DB_USER;
        const pass = process.env.DB_PASS;
        const name = process.env.DB_NAME;

        if (!host || !user || !pass || !name) {
            return reject(new Error('Missing DB env variables (DB_HOST, DB_USER, DB_PASS, DB_NAME)'));
        }

        // Using mysqldump binary — available on all Linux servers including Hostinger VPS
        // MYSQL_PWD avoids the "Using a password on the command line" warning
        const cmd = `MYSQL_PWD='${pass}' mysqldump --single-transaction --routines --triggers --add-drop-table -h ${host} -u ${user} ${name} > "${filePath}"`;

        log(`🛠  Running mysqldump → ${path.basename(filePath)}`);

        exec(cmd, { timeout: 5 * 60 * 1000 }, (err, stdout, stderr) => {
            if (err) {
                return reject(new Error(`mysqldump failed: ${err.message}\n${stderr}`));
            }
            resolve();
        });
    });
}

// ─── Step 2: Validate local file ────────────────────────────

async function validateFile(filePath) {
    if (!fs.existsSync(filePath)) {
        throw new Error(`File not found: ${filePath}`);
    }
    const stats = await fsPromises.stat(filePath);
    if (stats.size < 500) {          // < 500 bytes → something went wrong
        throw new Error(`Backup file too small (${stats.size} bytes) — aborting upload`);
    }
    return stats.size;
}

// ─── Step 3: Upload to Google Drive ─────────────────────────

async function uploadToDrive(filePath, fileName) {
    const drive = getDriveClient();
    const folderId = process.env.GDRIVE_FOLDER_ID;

    if (!folderId) throw new Error('GDRIVE_FOLDER_ID not set in .env');

    log(`☁️  Uploading ${fileName} to Google Drive folder ${folderId} …`);

    const fileMetadata = {
        name:    fileName,
        parents: [folderId],
    };

    const media = {
        mimeType: 'application/sql',
        body:     fs.createReadStream(filePath),
    };

    const res = await drive.files.create({
        resource:  fileMetadata,
        media,
        fields:    'id, name, size',
    });

    log(`✅ Uploaded: ${res.data.name} (Drive ID: ${res.data.id})`);
    return res.data.id;
}

// ─── Step 4: Keep only latest N files in Drive folder ────────

async function pruneOldBackups(keepCount = 30) {
    const drive    = getDriveClient();
    const folderId = process.env.GDRIVE_FOLDER_ID;

    // List all .sql files in folder, sorted oldest first
    const res = await drive.files.list({
        q:       `'${folderId}' in parents and name contains 'backup-' and trashed = false`,
        fields:  'files(id, name, createdTime)',
        orderBy: 'createdTime asc',   // oldest first
        pageSize: 100,
    });

    const files = res.data.files || [];
    log(`📂 Total backups in Drive: ${files.length}`);

    if (files.length <= keepCount) return;

    const toDelete = files.slice(0, files.length - keepCount);
    for (const f of toDelete) {
        await drive.files.delete({ fileId: f.id });
        log(`🗑️  Deleted old backup from Drive: ${f.name}`);
    }
}

// ─── Step 5: Prune local copies too ─────────────────────────

async function pruneLocalBackups(backupDir, keepCount = 30) {
    const files = await fsPromises.readdir(backupDir);
    const sqlFiles = files
        .filter(f => f.endsWith('.sql') && f.startsWith('backup-'))
        .map(f => ({ name: f, mtime: fs.statSync(path.join(backupDir, f)).mtimeMs }))
        .sort((a, b) => b.mtime - a.mtime);   // newest first

    const toDelete = sqlFiles.slice(keepCount);
    for (const f of toDelete) {
        await fsPromises.unlink(path.join(backupDir, f.name));
        log(`🗑️  Deleted old local backup: ${f.name}`);
    }
}

// ─── Main exported function ──────────────────────────────────

async function backupDatabase() {
    let filePath = null;

    try {
        log('==============================');
        log('🚀 BACKUP STARTED');
        log(`🕒 IST: ${getISTTime()}`);
        log('==============================');

        // Ensure backup directory exists
        const backupDir = path.join(__dirname, 'backup_files');
        if (!fs.existsSync(backupDir)) {
            fs.mkdirSync(backupDir, { recursive: true });
            log(`📁 Created backup directory: ${backupDir}`);
        }

        const fileName = buildFileName();
        filePath = path.join(backupDir, fileName);

        // 1. Dump
        await dumpDatabase(filePath);

        // 2. Validate
        const size = await validateFile(filePath);
        log(`✅ Backup file valid — size: ${(size / 1024).toFixed(1)} KB`);

        // 3. Upload
        await uploadToDrive(filePath, fileName);

        // 4. Prune Drive (keep 30)
        await pruneOldBackups(30);

        // 5. Prune local (keep 30)
        await pruneLocalBackups(backupDir, 30);

        log('🎉 BACKUP COMPLETE');
        log('==============================\n');

    } catch (err) {
        console.error(`❌ BACKUP ERROR: ${err.message}`);

        // Remove corrupt local file if it exists
        if (filePath && fs.existsSync(filePath)) {
            try {
                fs.unlinkSync(filePath);
                log('🗑️  Removed broken local file');
            } catch (_) { /* ignore */ }
        }

        throw err;   // re-throw so cron wrapper can log it
    }
}

module.exports = backupDatabase;