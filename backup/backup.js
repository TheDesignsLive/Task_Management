const mysqldump = require('mysqldump');
const { google } = require('googleapis');
const fs = require('fs');
const path = require('path');
const con = require('../config/db');

function debugLog(msg, data = "") {
    console.log("🟢 [BACKUP DEBUG]", msg, data);
}

// ✅ LOCAL FILE PATH (CORRECT)
const serviceAccountPath = path.join(__dirname, '../service-account.json');

if (!fs.existsSync(serviceAccountPath)) {
    throw new Error("❌ service-account.json NOT FOUND");
}

debugLog("Service Account Path", serviceAccountPath);

const auth = new google.auth.GoogleAuth({
    keyFile: serviceAccountPath,
    scopes: ['https://www.googleapis.com/auth/drive']
});

const drive = google.drive({ version: 'v3', auth });

const BACKUP_FOLDER_ID = '1sf8V2HrGj3owkPVomKnZcD_wPFoOUmLF';

function getISTTime() {
    return new Date().toLocaleString("en-IN", {
        timeZone: "Asia/Kolkata"
    });
}

async function backupDatabase() {
    try {
        console.log("\n==============================");
        console.log("🚀 BACKUP STARTED");
        console.log("🕒 UTC:", new Date().toString());
        console.log("🕒 IST:", getISTTime());
        console.log("==============================");

        const [rows] = await con.query("SELECT COUNT(*) as count FROM tasks");

        debugLog("Task count", rows[0].count);

        if (rows[0].count === 0) {
            debugLog("Backup skipped (empty DB)");
            return;
        }

        const fileName = `backup-${Date.now()}.sql`;
        const filePath = path.join(__dirname, fileName);

        debugLog("Dump path", filePath);

        await mysqldump({
            connection: {
                host: process.env.DB_HOST,
                user: process.env.DB_USER,
                password: process.env.DB_PASS,
                database: process.env.DB_NAME,
            },
            dumpToFile: filePath,
        });

        debugLog("SQL dump created");

        const stats = fs.statSync(filePath);
        debugLog("File size", stats.size);

        const response = await drive.files.create({
            requestBody: {
                name: fileName,
                parents: [BACKUP_FOLDER_ID],
            },
            media: {
                body: fs.createReadStream(filePath)
            },
            supportsAllDrives: true,     // 🔥 IMPORTANT FIX
        });

        debugLog("Uploaded to Drive", response.data.id);

        fs.unlinkSync(filePath);
        debugLog("Local file deleted");

    } catch (err) {
        console.error("❌ BACKUP FAILED:", err.message);
    }
}

module.exports = backupDatabase;
