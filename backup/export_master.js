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
            },
            dump: {
                schema: {
                    autoIncrement: true,
                    engine: true,
                    ifNotExist: true,        // CREATE TABLE IF NOT EXISTS
                },
                data: {
                    includeViewData: false,
                    verbose: false,
                    lockTables: false,       // avoids lock errors on some hosts
                    maxRowsPerInsertStatement: 100,
                },
                trigger: false              // skip triggers to avoid permission errors
            }
        });

        // 🧠 Convert dump to string — add SET commands for safe import
        const sqlContent = 
            "SET FOREIGN_KEY_CHECKS=0;\nSET SQL_MODE='NO_AUTO_VALUE_ON_ZERO';\n\n" +
            (dump.dump.schema || "") + "\n" + 
            (dump.dump.data   || "") +
            "\n\nSET FOREIGN_KEY_CHECKS=1;\n";

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