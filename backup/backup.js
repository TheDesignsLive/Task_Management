const mysqldump = require('mysqldump');
const { google } = require('googleapis');
const fs = require('fs');
const path = require('path');
const con = require('../config/db');

// const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
// const serviceAccountPath = path.join(__dirname, '../service-account.json');
const serviceAccountPath='https://srv832-files.hstgr.io/c21144ae59f048ac/files/nodejs/service-account.json';

console.log("📌 Service Account Path:", serviceAccountPath);

if (!fs.existsSync(serviceAccountPath)) {
    console.error("❌ service-account.json NOT FOUND at:", serviceAccountPath);
    process.exit(1);
}

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
        console.log("🕒 Server Time (UTC):", new Date().toString());
        console.log("🕒 IST Time:", getISTTime());
        console.log("==============================");

        const [rows] = await con.query("SELECT COUNT(*) as count FROM tasks");

        console.log("📊 Task count:", rows[0].count);

        if (rows[0].count === 0) {
            console.log("❌ DB Empty, skipping backup");
            return;
        }

        const fileName = `backup-${Date.now()}.sql`;
        const filePath = path.join(__dirname, fileName);

        console.log("📁 Backup file path:", filePath);

        await mysqldump({
            connection: {
                // host: process.env.DB_HOST,
                // user: process.env.DB_USER,
                // password: process.env.DB_PASS,
                // database: process.env.DB_NAME,

                host: process.env.DB_HOST || "srv832.hstgr.io",
                user: process.env.DB_USER|| "u213405511_dilip",
                password: process.env.DB_PASS || "Dilip@8133",
                database: process.env.DB_NAME || "u213405511_tmsDB"

            },
            dumpToFile: filePath,
        });

        console.log("✅ SQL dump created");

        if (!fs.existsSync(filePath)) {
            console.log("❌ File not found after dump");
            return;
        }

        const stats = fs.statSync(filePath);
        console.log("📦 File size:", stats.size);

        if (stats.size === 0) {
            console.log("❌ Empty backup file");
            return;
        }

        const response = await drive.files.create({
            requestBody: {
                name: fileName,
                parents: [BACKUP_FOLDER_ID],
            },
            media: {
                body: fs.createReadStream(filePath)
            }
        });

        console.log("☁️ Uploaded to Drive ID:", response.data.id);

        fs.unlinkSync(filePath);
        console.log("🧹 Local file deleted");

    } catch (err) {
        console.error("❌ Backup Failed:", err);
    }
}

module.exports = backupDatabase;
