// const mysqldump = require('mysqldump');
// const { google } = require('googleapis');
// const fs = require('fs');
// const path = require('path');

// function getAuth() {
//     let raw = process.env.GOOGLE_SERVICE_ACCOUNT_JSON;
//     if (!raw) throw new Error("❌ GOOGLE_SERVICE_ACCOUNT_JSON env var is missing!");

//     raw = raw.trim();
//     let decoded;
//     try {
//         decoded = Buffer.from(raw, 'base64').toString('utf8');
//     } catch (e) {
//         throw new Error("❌ Base64 decode failed: " + e.message);
//     }

//     let credentials;
//     try {
//         credentials = JSON.parse(decoded);
//     } catch (e) {
//         console.error("❌ JSON parse failed. Decoded start:", decoded.substring(0, 150));
//         throw new Error("❌ Invalid JSON after decode: " + e.message);
//     }

//     console.log("✅ Service account loaded for:", credentials.client_email);

//     return new google.auth.GoogleAuth({
//         credentials,
//         scopes: ['https://www.googleapis.com/auth/drive']
//     });
// }

// // Your personal Google Drive folder ID (shared with the service account)
// const BACKUP_FOLDER_ID = '1sf8V2HrGj3owkPVomKnZcD_wPFoOUmLF';

// function getISTTime() {
//     return new Date().toLocaleString("en-IN", { timeZone: "Asia/Kolkata" });
// }

// async function backupDatabase() {
//     let filePath = null;

//     try {
//         console.log("\n==============================");
//         console.log("🚀 BACKUP STARTED");
//         console.log("🕒 IST:", getISTTime());
//         console.log("==============================");

//         const fileName = `backup-${Date.now()}.sql`;

//         // ✅ TEMP FILE
//       const backupDir = path.join(__dirname, '..', 'backup');

// // create folder if not exists
// if (!fs.existsSync(backupDir)) {
//     fs.mkdirSync(backupDir, { recursive: true });
// }

// filePath = path.join(backupDir, fileName);

//      await mysqldump({
//     connection: {
//         host: process.env.DB_HOST || "srv832.hstgr.io",
//         user: process.env.DB_USER || "u213405511_dilip",
//         password: process.env.DB_PASS || "Dilip@8133",
//         database: process.env.DB_NAME || "u213405511_tmsDB"
//     },
//     dumpToFile: filePath,
// });

//         console.log("✅ SQL dump created");

//         if (!fs.existsSync(filePath)) {
//             throw new Error("Dump file not created");
//         }

//         const stats = fs.statSync(filePath);
//         if (stats.size === 0) {
//             throw new Error("Dump file is empty");
//         }

//         console.log("📦 File size:", stats.size);

//         // ================= GOOGLE DRIVE UPLOAD =================
//         try {
//             const auth = getAuth();
//             const drive = google.drive({ version: 'v3', auth });

//             const response = await drive.files.create({
//                 requestBody: {
//                     name: fileName,
//                     parents: [BACKUP_FOLDER_ID],
//                 },
//                 media: {
//                     mimeType: 'application/sql',
//                     body: fs.createReadStream(filePath)
//                 },
//                 fields: 'id',
//             });

//             console.log("☁️ Uploaded to Drive:", response.data.id);

//             // ✅ delete temp only if upload success
//             fs.unlinkSync(filePath);
//             console.log("🧹 Temp file deleted");

//         } catch (driveError) {
//             console.error("❌ Drive Upload Failed:", driveError.message);

//             // ================= FALLBACK =================
//             const backupDir = path.join(__dirname, 'backup_files');

//             if (!fs.existsSync(backupDir)) {
//                 fs.mkdirSync(backupDir);
//             }

//             const finalPath = path.join(backupDir, fileName);

//             fs.renameSync(filePath, finalPath);

//             console.log("💾 Saved locally:", finalPath);
//         }

//         console.log("✅ BACKUP COMPLETE\n");

//     } catch (err) {
//         console.error("❌ Backup Failed:", err.message);

//         // If something failed before upload, still save locally
//         if (filePath && fs.existsSync(filePath)) {
//             const backupDir = path.join(__dirname, 'backup_files');

//             if (!fs.existsSync(backupDir)) {
//                 fs.mkdirSync(backupDir);
//             }

//             const finalPath = path.join(backupDir, path.basename(filePath));
//             fs.renameSync(filePath, finalPath);

//             console.log("💾 Emergency backup saved:", finalPath);
//         }
//     }
// }

// module.exports = backupDatabase;

const mysqldump = require('mysqldump');
const fs = require('fs');
const path = require('path');

function getISTTime() {
    return new Date().toLocaleString("en-IN", { timeZone: "Asia/Kolkata" });
}

async function backupDatabase() {
    let filePath = null;

    try {
        console.log("\n==============================");
        console.log("🚀 BACKUP STARTED");
        console.log("🕒 IST:", getISTTime());
        console.log("==============================");

        const fileName = `backup-${Date.now()}.sql`;

        // ✅ Save directly into backup_files folder
        const backupDir = path.join(__dirname, 'backup_files');

        if (!fs.existsSync(backupDir)) {
            fs.mkdirSync(backupDir, { recursive: true });
        }

        filePath = path.join(backupDir, fileName);

        await mysqldump({
            connection: {
                host: process.env.DB_HOST || "srv832.hstgr.io",
                user: process.env.DB_USER || "u213405511_dilip",
                password: process.env.DB_PASS || "Dilip@8133",
                database: process.env.DB_NAME || "u213405511_tmsDB"
            },
            dumpToFile: filePath,
        });

        console.log("✅ SQL dump created");
        console.log("💾 Saved at:", filePath);

        console.log("✅ BACKUP COMPLETE\n");

    } catch (err) {
        console.error("❌ Backup Failed:", err.message);
    }
}

module.exports = backupDatabase;
