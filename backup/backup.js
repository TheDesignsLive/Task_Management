
const mysqldump = require('mysqldump');
const fs = require('fs');
const fsPromises = require('fs/promises');
const path = require('path');
const { debugLog } = require('../utils/logger');

function getISTTime() {
    return new Date().toLocaleString("en-IN", { timeZone: "Asia/Kolkata" });
}

async function backupDatabase() {
    let filePath = null;

    try {
        debugLog("\n==============================");
        debugLog("🚀 BACKUP STARTED");
        debugLog("🕒 IST:", getISTTime());
        debugLog("==============================");

      const now = new Date();

const fileName = `backup-${
    now.getFullYear()}-${
    String(now.getMonth() + 1).padStart(2, '0')}-${
    String(now.getDate()).padStart(2, '0')}_${
    String(now.getHours()).padStart(2, '0')}-${
    String(now.getMinutes()).padStart(2, '0')}-${
    String(now.getSeconds()).padStart(2, '0')
}.sql`;

   const backupDir = path.join(__dirname, 'backup_files');

     debugLog("📁 Backup Directory:", backupDir);

        // ✅ Create folder if not exists
        if (!fs.existsSync(backupDir)) {
            fs.mkdirSync(backupDir, { recursive: true });
        }

        filePath = path.join(backupDir, fileName);

        // =========================
        // ✅ STEP 1: CREATE DUMP
        // =========================
        await mysqldump({
            connection: {
                host: process.env.DB_HOST || "srv832.hstgr.io",
                user: process.env.DB_USER || "u213405511_dilip",
                password: process.env.DB_PASS || "Dilip@8133",
                database: process.env.DB_NAME || "u213405511_tmsDB"
            },
            dumpToFile: filePath,
            dump: {
                schema: {
                    table: {
                        dropIfExist: true
                    }
                },
                data: {
                    lockTables: false
                }
            }
        });

        // =========================
        // ✅ STEP 2: VERIFY FILE
        // =========================
        const stats = await fsPromises.stat(filePath);
        const fileSize = stats.size;

        if (!fileSize || fileSize < 100) {
            debugLog("❌ Backup file is EMPTY or TOO SMALL");

            if (fs.existsSync(filePath)) {
                fs.unlinkSync(filePath);
                debugLog("🗑️ Deleted invalid backup");
            }

            return;
        }

        debugLog("✅ VALID BACKUP CREATED");
        debugLog("📦 Size:", fileSize, "bytes");

        // =========================
        // ✅ STEP 3: DELETE OLD FILES (SAFE)
        // =========================

const files = await fsPromises.readdir(backupDir);

const sqlFiles = files
    .filter(f => f.endsWith(".sql"))
    .map(f => ({
        name: f,
        time: fs.statSync(path.join(backupDir, f)).mtimeMs
    }))
    .sort((a, b) => b.time - a.time);

// Keep only latest 30
const filesToDelete = sqlFiles.slice(30);

for (const file of filesToDelete) {
    await fsPromises.unlink(path.join(backupDir, file.name));
    debugLog("🗑️ Deleted old file:", file.name);
}
        debugLog("✅ BACKUP COMPLETE\n");

    } catch (err) {
     console.error("❌ FULL ERROR:", err);
debugLog("❌ Backup Failed:", err.message);

        // ❌ If failed, remove broken file
        if (filePath && fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
            debugLog("🗑️ Removed broken file");
        }
    }
}

module.exports = backupDatabase;