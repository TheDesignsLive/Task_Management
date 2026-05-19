// export_master.js
// REPLACE YOUR ENTIRE export_master.js WITH THIS FILE
const express = require("express");
const mysqldump = require("mysqldump");

const router = express.Router();

router.get("/backup/download", async (req, res) => {
    try {

        // ✅ ALWAYS EXPORTS FROM HOSTINGER — even when running locally
        const result = await mysqldump({
            connection: {
                host:     "srv832.hstgr.io",
                user:     "u213405511_dilip",
                password: "Dilip@8133",
                database: "u213405511_tmsDB",
            },
            dump: {
                schema: {
                    table: {
                        dropIfExist: true,
                    },
                },
                data: {
                    format: false,      // false = compact INSERT — safer for import
                    verbose: false,
                    lockTables: false,
                },
            },
            dumpToFile: false,
        });

        // ✅ FIX: result.dump.schema and result.dump.data are STRINGS, not objects
        // Your old code used for...in on them which produced nothing (empty export)
        const schemaSQL  = result.dump.schema  || "";
        const dataSQL    = result.dump.data    || "";
        const triggerSQL = result.dump.trigger || "";

        const sqlContent =
`-- ====================================
-- TMS DATABASE FULL BACKUP
-- Generated: ${new Date().toISOString()}
-- Database: u213405511_tmsDB (Hostinger)
-- ====================================

SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
SET NAMES utf8mb4;

${schemaSQL}

${dataSQL}

${triggerSQL}

SET FOREIGN_KEY_CHECKS=1;
`;

        const fileName = `tms-backup-${Date.now()}.sql`;

        res.setHeader("Content-Type", "application/octet-stream");
        res.setHeader("Content-Disposition", `attachment; filename="${fileName}"`);

        return res.send(sqlContent);

    } catch (err) {
        console.error("Backup Error:", err.message);
        return res.status(500).json({ success: false, message: err.message });
    }
});

module.exports = router;