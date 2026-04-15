const mysqldump = require('mysqldump');
const { google } = require('googleapis');
const fs = require('fs');
const path = require('path');

function getAuth() {
    let raw = process.env.GOOGLE_SERVICE_ACCOUNT_JSON;
    if (!raw) throw new Error("❌ GOOGLE_SERVICE_ACCOUNT_JSON env var is missing!");

    raw = raw.trim();
    let decoded;
    try {
        decoded = Buffer.from(raw, 'base64').toString('utf8');
    } catch (e) {
        throw new Error("❌ Base64 decode failed: " + e.message);
    }

    let credentials;
    try {
        credentials = JSON.parse(decoded);
    } catch (e) {
        console.error("❌ JSON parse failed. Decoded start:", decoded.substring(0, 150));
        throw new Error("❌ Invalid JSON after decode: " + e.message);
    }

    console.log("✅ Service account loaded for:", credentials.client_email);

    return new google.auth.GoogleAuth({
        credentials,
        scopes: ['https://www.googleapis.com/auth/drive']
    });
}

// Your personal Google Drive folder ID (shared with the service account)
const BACKUP_FOLDER_ID = '1sf8V2HrGj3owkPVomKnZcD_wPFoOUmLF';

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

        const auth = getAuth();
        const drive = google.drive({ version: 'v3', auth });

        // Verify the folder is accessible (it will be after you share it)
        try {
            const folder = await drive.files.get({
                fileId: BACKUP_FOLDER_ID,
                fields: 'id,name',
                supportsAllDrives: false  // ✅ We're using personal Drive
            });
            console.log("✅ Google Drive folder verified:", folder.data.name);
        } catch (e) {
            console.error("❌ Cannot access Drive folder:", e.message);
            console.error("👉 Did you share the folder with the service account email?");
            return;
        }

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

        // ✅ THE FIX: Upload using your personal Drive quota via folder sharing
        const response = await drive.files.create({
            requestBody: {
                name:    fileName,
                parents: [BACKUP_FOLDER_ID],
            },
            media: {
                mimeType: 'application/octet-stream',
                body:     fs.createReadStream(filePath)
            },
            fields: 'id, name, size',
            // ✅ Do NOT set supportsAllDrives: true — keep it as personal Drive
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
