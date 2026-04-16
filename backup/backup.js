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
