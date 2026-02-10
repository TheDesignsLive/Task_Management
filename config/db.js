const mysql = require("mysql2");

// Create Connection Pool (better than single connection)
const pool = mysql.createPool({
  host: "localhost",
  user: "root",
  password: "",
  database: "task_management",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Check connection once at startup
pool.getConnection((err, conn) => {
  if (err) {
    console.error("❌ Database connection failed:", err.message);
    return;
  }
  console.log("✅ MySQL Connected Successfully");
  conn.release(); // release connection back to pool
});

// Export Promise-based pool (for async/await)
module.exports = pool.promise();
