const mysql = require("mysql2");


const pool = mysql.createPool({
  host: "localhost",
  user: "u213405511_dilip",
  password: "Dilip@8133",
  database: "u213405511_tmsDB",
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
