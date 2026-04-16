const { google } = require("googleapis");
const fs = require("fs");
const path = require("path");

// Service Account Credentials
const serviceEmail = "social-designs-live@task-management-system-493306.iam.gserviceaccount.com";

const privateKey = `-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCqnp1GijvtJ9oT\nTWu+gpb116+PXiKrnX5j+9T5WkjzWYq2Jo48cwh9n49IIb2nsDjQrh6ca4HOdLyX\nJmhKHiH6Cf9WaQCzyA2/D/X5gWHjexKk+nvtaFqyDbuIsMVMZh4NdQjl/z7ZwTOk\nt9RiE8Krpju/UB/Qv9DS9/JUUo98OmJko2ie0qQeVRas8reePYYIcpPR8nQvVNGn\nafwZ5Rv9L9RVwjDoChh1FsN6e8+lFPnn5T/OoIq2JWGazqIk0WmHVT/TyjJ29VKg\nSmSK7q5mm7HjzwPB29jyWBzQZFoheRQWGjiPMh/G2ZFriXzrjUV7dCU5MdVww6nh\naQvhPuf5AgMBAAECggEAFRmYAB78wbulsbDno/AA7Ma/aJa+6WPI+2Lrp+mlL2kR\nqSyT9wBP2r9GiChaDLiTkiUSVoxKCYbwwq2GhLH8yC//0ocaReF157y40eIRAcGY\n4Ou0MzwuSSo/GKypvaS8TzQ7xTu/YU0ODq8INhfVAYbFiUeGo7lxAQIWRxzNr1JS\nWwxWGF/c0zRYo6pLNmQqdTMNfH32KMDSfWdkKXHqavSR0iWu51LHdth+4B+CTPey\nLqWR9yTokON8evsPS3GsO0QSzJNUbEzXk3QBX3G5YkG2/VHrQ2OhtVMMabWWJ5FE\n5O74ZdEd3Q5SMPaIEvNgObgrVTpksUlnHFPRAHw+/QKBgQDYY4Xij0HeRBlIpL21\nVygyilseWRqYXQ3+4bdwbgxZkOoydQCNJJpXqjzEwKm4OaP507avtr+B9/8S1t3M\ny6OFzXi3wzyeU5keaicNgzKT2S/RJ3ZI4QgHiTTJYAcsYFZjhA3KlA2A2pnGU/6T\nx9ZzNx2hxoTOS3TmTj0S2zOU3QKBgQDJ2j3/dN9Ucn2SmhNDPr2NYQAOLNcMZwSG\nDriZp0ev+P9uQkeCXE8bex7s5kQzJz8Wy2AIE02Q+zxyLMBIxdx6WQgUR6rR4Kg2\ncd2KG2bzwcvkjnxrhf8AX4kXAYb60QSa2TOD5pyGaAXK+PGzGoYqMU95102VjCJd\nVpNWN7rPzQKBgQDUywoegkKEEPPMPDVS3yLokKaKcZV1wAzDWbTLG22JprioZebk\n5dnh28dmtRAx2n0mcMx2f4BUj0yHekUj4B4utqDAFX7HM+6fukQtRZe3TR140RXB\nFYqP3p3KamSjfxl1Q6dMT8v3qwENyAvRx/Nb2heJv29ab1nGIaptoKJZAQKBgAa9\n+GYo9DCw5krYRJ5xYQlw3PycOM6cPkVwBnBzauyQx49aPWM4TBgh46WMB2kh/XR4\ndIuwgV2/VoSFxCJqIXQgtyleP3FlLJks8nZjdevcZEANFlDNF/heOIkBLw3/n0TA\nznywXjgLD255JDGUSDjujrYGH/xHwvoVIzS1BdNdAoGBAK4wc+aCOYa0jh7LZqo6\n6Lw3Rgafpoe3UZrwi/xObfQBYvpA8Uauoc6BQgmg6qr9SIFK++MuXP5HjGc5mQVN\nGii7flnd6BSyjpQ1smwEaWTCIG7giNr8/6foXeu2kornA+6v2A9Fw71IqLwK7VhS\nLBamFtJmNc5pYnr3Z6QeDTBN\n-----END PRIVATE KEY-----\n`;

// Auth
const auth = new google.auth.GoogleAuth({
  credentials: {
    client_email: serviceEmail,
    private_key: privateKey,
  },
  scopes: ["https://www.googleapis.com/auth/drive"],
});

const drive = google.drive({ version: "v3", auth });

async function uploadLatestSQL() {
  try {
const backupDir = path.join(__dirname, 'backup', 'backup_files');

    // 1️⃣ Read all files
    const files = fs.readdirSync(backupDir);

    // 2️⃣ Filter only .sql files
    const sqlFiles = files.filter(file => file.endsWith(".sql"));

    if (sqlFiles.length === 0) {
      console.log("❌ No .sql files found");
      return;
    }

    // 3️⃣ Get latest file (by modified time)
    let latestFile = sqlFiles[0];
    let latestTime = fs.statSync(path.join(backupDir, latestFile)).mtime;

    sqlFiles.forEach(file => {
      const filePath = path.join(backupDir, file);
      const stats = fs.statSync(filePath);

      if (stats.mtime > latestTime) {
        latestTime = stats.mtime;
        latestFile = file;
      }
    });

    const latestFilePath = path.join(backupDir, latestFile);

    console.log("📂 Latest file:", latestFile);

    // 4️⃣ Upload to Drive
    const response = await drive.files.create({
      requestBody: {
        name: latestFile,
        parents: ["1sf8V2HrGj3owkPVomKnZcD_wPFoOUmLF"], // your folder
      },
      media: {
        mimeType: "application/sql",
        body: fs.createReadStream(latestFilePath),
      },
      fields: "id",
    });

    console.log("✅ Uploaded:", response.data.id);

  } catch (error) {
    console.error("❌ Error:", error.message);
  }
}

module.exports = uploadLatestSQL;

