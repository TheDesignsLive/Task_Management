require('dotenv').config();
const { google } = require('googleapis');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

// Google Auth
const auth = new google.auth.GoogleAuth({
    keyFile: path.join(__dirname, '../service-account.json'),
    scopes: ['https://www.googleapis.com/auth/drive']
});

const drive = google.drive({ version: 'v3', auth });

// CONFIG
const BACKUP_FOLDER_ID = '1sf8V2HrGj3owkPVomKnZcD_wPFoOUmLF';
const DB_NAME = process.env.DB_NAME;

// MAIN FUNCTION
async function backupDatabase() {
    try {
        const fileName = `backup-${Date.now()}.sql`;
        const filePath = path.join(__dirname, fileName);

        // 1. CREATE MYSQL BACKUP
  const dbUser = process.env.DB_USER;
const dbPass = process.env.DB_PASS ? `-p${process.env.DB_PASS}` : "";

const command = `mysqldump -h ${process.env.DB_HOST} -u ${dbUser} ${dbPass} ${DB_NAME} > "${filePath}"`;

        exec(command, async (err) => {
            if (err) {
                console.error("Backup Error:", err);
                return;
            }

            // 2. CHECK FILE SIZE
            const stats = fs.statSync(filePath);
            if (stats.size === 0) {
                console.log("❌ Empty backup file");
                return;
            }

            console.log("✅ Backup created");

            // 3. UPLOAD TO GOOGLE DRIVE
            const response = await drive.files.create({
                requestBody: {
                    name: fileName,
                    parents: [BACKUP_FOLDER_ID]
                },
                media: {
                    body: fs.createReadStream(filePath)
                }
            });

            console.log("✅ Uploaded:", response.data.id);

            // 4. DELETE LOCAL FILE
            fs.unlinkSync(filePath);

            // 5. KEEP ONLY 30 FILES
            await cleanOldBackups();

        });

    } catch (error) {
        console.error("Backup Failed:", error);
    }
}

// DELETE OLD FILES
async function cleanOldBackups() {
    const res = await drive.files.list({
        q: `'${BACKUP_FOLDER_ID}' in parents`,
        orderBy: 'createdTime asc',
        fields: 'files(id, name)'
    });

    const files = res.data.files;

    if (files.length > 30) {
        const deleteCount = files.length - 30;

        for (let i = 0; i < deleteCount; i++) {
            await drive.files.delete({
                fileId: files[i].id
            });
            console.log("🗑 Deleted:", files[i].name);
        }
    }
}

module.exports = backupDatabase;