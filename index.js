const mysql = require("mysql");

const con = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "test"
});

con.connect(err => {
  if(err) {
    console.log("DB Connection Error:", err);
    return;
  }
  console.log("Connected to database");
});

module.exports = con;
