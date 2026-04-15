// ❌ No dotenv (using Hostinger environment variables)
// require('dotenv').config();

const mysqldump = require('mysqldump');
const { google } = require('googleapis');
const fs = require('fs');
const path = require('path');
const con = require('../config/db');

// ================= GOOGLE AUTH =================
const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

if (!serviceAccountPath) {
    console.error("❌ GOOGLE_APPLICATION_CREDENTIALS not set");
}

const auth = new google.auth.GoogleAuth({
    keyFile: serviceAccountPath || path.join(__dirname, '../service-account.json'),
    scopes: ['https://www.googleapis.com/auth/drive']
});
const drive = google.drive({ version: 'v3', auth });

// ================= DRIVE FOLDER =================
const BACKUP_FOLDER_ID = '1sf8V2HrGj3owkPVomKnZcD_wPFoOUmLF';

// ================= BACKUP FUNCTION =================
async function backupDatabase() {
    try {
        console.log("🚀 Backup Triggered...");

        // Check if DB has tasks
        const [rows] = await con.query("SELECT COUNT(*) as count FROM tasks");

        if (rows[0].count === 0) {
            console.log("❌ DB Empty, backup skipped");
            return;
        }

        const fileName = `backup-${Date.now()}.sql`;
        const filePath = path.join(__dirname, fileName);

        // ================= MYSQL DUMP =================
        await mysqldump({
            connection: {
                host: process.env.DB_HOST || "srv832.hstgr.io",   
                user: process.env.DB_USER || "u213405511_dilip",  
                password: process.env.DB_PASS || "Dilip@8133",    
                database: process.env.DB_NAME || "u213405511_tmsDB",
            },
            dumpToFile: filePath,
        });

        console.log("✅ Backup file created");

        if (!fs.existsSync(filePath)) {
            console.log("❌ File not found");
            return;
        }

        const stats = fs.statSync(filePath);
        console.log("📦 File size:", stats.size);

        if (stats.size === 0) {
            console.log("❌ Empty backup file");
            return;
        }

        // ================= UPLOAD TO GOOGLE DRIVE =================
        const response = await drive.files.create({
            requestBody: {
                name: fileName,
                parents: [BACKUP_FOLDER_ID],
                supportsAllDrives: true
            },
            media: {
                body: fs.createReadStream(filePath)
            }
        });

        console.log("✅ Uploaded to Drive:", response.data.id);

        // delete local file
        fs.unlinkSync(filePath);

    } catch (err) {
        console.error("❌ Backup Failed:", err.message || err);
    }
}

module.exports = backupDatabase;
