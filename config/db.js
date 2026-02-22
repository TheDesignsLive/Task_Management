const mysql = require("mysql2");


const pool = mysql.createPool({
 host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "u213405511_dilip",
  password: process.env.DB_PASS || "Dilip@8133",
  database: process.env.DB_NAME || "u213405511_tmsDB",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});


pool.getConnection((err, conn) => {
  if (err) {
    console.error("❌ Database connection failed:", err.message);
    return;
  }
  console.log("✅ MySQL Connected Successfully");
  conn.release(); 
});

module.exports = pool.promise();
