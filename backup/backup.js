require('dotenv').config();
const mysqldump = require('mysqldump');
const { google } = require('googleapis');
const fs = require('fs');
const path = require('path');

// Google Auth
const auth = new google.auth.GoogleAuth({
    keyFile: path.join(__dirname, '../service-account.json'),
    scopes: ['https://www.googleapis.com/auth/drive']
});

const drive = google.drive({ version: 'v3', auth });

const BACKUP_FOLDER_ID = '1sf8V2HrGj3owkPVomKnZcD_wPFoOUmLF';

async function backupDatabase() {
    try {
        const fileName = `backup-${Date.now()}.sql`;
        const filePath = path.join(__dirname, fileName);

        console.log("🚀 Starting LOCAL Backup...");

        // ✅ LOCAL DATABASE BACKUP
        await mysqldump({
            connection: {
                host: process.env.DB_HOST,
                user: process.env.DB_USER,
                password: process.env.DB_PASS,
                database: process.env.DB_NAME,
            },
            dumpToFile: filePath,
        });

        console.log("✅ Backup file created");

        // Check file
        if (!fs.existsSync(filePath)) {
            console.log("❌ File not created");
            return;
        }

        const stats = fs.statSync(filePath);
        console.log("📦 File size:", stats.size);

        if (stats.size === 0) {
            console.log("❌ Empty file");
            return;
        }

        // ✅ Upload to Google Drive
        const response = await drive.files.create({
            requestBody: {
                name: fileName,
                parents: [BACKUP_FOLDER_ID]
            },
            media: {
                body: fs.createReadStream(filePath)
            }
        });

        console.log("✅ Uploaded to Drive:", response.data.id);

        // Delete local file
        fs.unlinkSync(filePath);

    } catch (err) {
        console.error("❌ Backup Failed:", err);
    }
}

module.exports = backupDatabase;