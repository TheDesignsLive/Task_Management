const mysqldump = require('mysqldump');
const fs = require('fs');
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

        const fileName = `backup-${Date.now()}.sql`;

        // ✅ Save directly into backup_files folder
        const backupDir = path.join(__dirname, 'backup_files');

        if (!fs.existsSync(backupDir)) {
            fs.mkdirSync(backupDir, { recursive: true });
        }

                    // ✅ DELETE OLD FILES
            const files = fs.readdirSync(backupDir);

            files.forEach(file => {
                if (file.endsWith(".sql")) {
                    fs.unlinkSync(path.join(backupDir, file));
                    debugLog("🗑️ Deleted old file:", file);
                }
            });

              // ✅ CREATE NEW FILES
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

        debugLog("✅ SQL dump created");
        debugLog("💾 Saved at:", filePath);

        debugLog("✅ BACKUP COMPLETE\n");

    } catch (err) {
        debugLog("❌ Backup Failed:", err.message);
    }
}

module.exports = backupDatabase;
