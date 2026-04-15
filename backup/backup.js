const mysqldump = require('mysqldump');
const { google } = require('googleapis');
const fs = require('fs');
const path = require('path');

// ✅ Load service account from ENV (no file needed, safe for git)
function getAuth() {
    let raw = process.env.GOOGLE_SERVICE_ACCOUNT_JSON;
    if (!raw) {
        throw new Error("❌ GOOGLE_SERVICE_ACCOUNT_JSON env var is missing!");
    }

    // ✅ Fix 1: Hostinger sometimes wraps value in outer quotes — strip them
    raw = raw.trim();
    if (raw.startsWith('"') && raw.endsWith('"')) {
        raw = raw.slice(1, -1);
    }

    // ✅ Fix 2: Hostinger escapes backslashes — unescape \\n back to \n
    raw = raw.replace(/\\n/g, '\n');

    // ✅ Fix 3: Also fix any double-escaped backslashes
    raw = raw.replace(/\\\\/g, '\\');

    let credentials;
    try {
        credentials = JSON.parse(raw);
    } catch (e) {
        // ✅ Fix 4: Log first 200 chars to see exactly what is wrong
        console.error("❌ JSON parse failed. Raw value start:", raw.substring(0, 200));
        throw new Error("Invalid GOOGLE_SERVICE_ACCOUNT_JSON: " + e.message);
    }

    return new google.auth.GoogleAuth({
        credentials,
        scopes: ['https://www.googleapis.com/auth/drive']
    });
}

const BACKUP_FOLDER_ID = '1sf8V2HrGj3owkPVomKnZcD_wPFoOUmLF'; // ✅ your existing folder ID

function getISTTime() {
    return new Date().toLocaleString("en-IN", { timeZone: "Asia/Kolkata" });
}

async function backupDatabase() {
    try {
        console.log("\n==============================");
        console.log("🚀 BACKUP STARTED");
        console.log("🕒 UTC:", new Date().toString());
        console.log("🕒 IST:", getISTTime());
        console.log("==============================");

        // ✅ Test auth FIRST before dumping
        const auth = getAuth();
        const drive = google.drive({ version: 'v3', auth });

        // ✅ Verify folder is accessible
        try {
            await drive.files.get({ fileId: BACKUP_FOLDER_ID, fields: 'id,name' });
            console.log("✅ Google Drive folder verified");
        } catch (e) {
            console.error("❌ Cannot access Drive folder:", e.message);
            return;
        }

        // ✅ Use /tmp for Hostinger (writable on all plans)
        const fileName = `backup-${Date.now()}.sql`;
        const filePath = path.join('/tmp', fileName);

        console.log("📁 Temp file:", filePath);

        await mysqldump({
            connection: {
                host:     process.env.DB_HOST     || "srv832.hstgr.io",
                user:     process.env.DB_USER     || "u213405511_dilip",
                password: process.env.DB_PASS     || "Dilip@8133",
                database: process.env.DB_NAME     || "u213405511_tmsDB"
            },
            dumpToFile: filePath,
        });

        console.log("✅ SQL dump created");

        if (!fs.existsSync(filePath)) {
            console.error("❌ Dump file not found after mysqldump");
            return;
        }

        const stats = fs.statSync(filePath);
        console.log("📦 File size:", stats.size, "bytes");

        if (stats.size === 0) {
            console.error("❌ Dump file is empty — check DB credentials");
            fs.unlinkSync(filePath);
            return;
        }

        // ✅ Upload to Google Drive
        const response = await drive.files.create({
            requestBody: {
                name:    fileName,
                parents: [BACKUP_FOLDER_ID],
            },
            media: {
                mimeType: 'application/octet-stream',
                body:     fs.createReadStream(filePath)
            },
            fields: 'id, name, size'
        });

        console.log("☁️  Uploaded to Drive:");
        console.log("    ID:  ", response.data.id);
        console.log("    Name:", response.data.name);
        console.log("    Size:", response.data.size, "bytes");

        fs.unlinkSync(filePath);
        console.log("🧹 Local temp file deleted");
        console.log("✅ BACKUP COMPLETE\n");

    } catch (err) {
        console.error("❌ Backup Failed:", err.message || err);
    }
}

module.exports = backupDatabase;
