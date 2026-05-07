// test-backup.js
require('dotenv').config(); // works locally, ignored on Hostinger (uses panel vars)
const backupDatabase = require('./backup/backup');

(async () => {
    try {
        console.log('🧪 Running manual backup test...\n');
        await backupDatabase();
        console.log('\n✅ Test passed — backup completed successfully.');
        process.exit(0);
    } catch (err) {
        console.error('\n❌ Test FAILED:', err.message);
        process.exit(1);
    }
})();