const express = require("express");
const mysqldump = require("mysqldump");

const router = express.Router();

router.get("/backup/download", async (req, res) => {
    try {

        // 🔥 Generate dump in memory (NO FILE SAVE)
        const dump = await mysqldump({
            connection: {
                host: process.env.DB_HOST || "srv832.hstgr.io",
                user: process.env.DB_USER || "u213405511_dilip",
                password: process.env.DB_PASS || "Dilip@8133",
                database: process.env.DB_NAME || "u213405511_tmsDB"
            }
        });

        // 🧠 Convert dump to string
        const sqlContent = dump.dump.schema + "\n" + dump.dump.data;

        // 📥 Force download in browser
        const fileName = `backup-${Date.now()}.sql`;

        res.setHeader("Content-Type", "application/sql");
        res.setHeader("Content-Disposition", `attachment; filename=${fileName}`);

        return res.send(sqlContent);

    } catch (err) {
        console.error("❌ Export error:", err);
        res.status(500).send("Export failed");
    }
});

module.exports = router;