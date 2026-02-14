const express = require('express');
const router = express.Router();
const con = require('../config/db');
const multer = require('multer');
const path = require('path');

// upload config
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'public/uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});
const upload = multer({ storage });

// UPDATE MEMBER
router.post('/edit-member/:id', upload.single('profile_pic'), async (req, res) => {
  try {
    const id = req.params.id;

    const role_id = req.body.role_id;
    const name = req.body.name;
    const email = req.body.email;
    const phone = req.body.phone;
    const password = req.body.password;

    let sql, values;

    if (req.file) {
      const profile_pic = '/uploads/' + req.file.filename;

      if (password) {
        sql = `UPDATE users SET role_id=?, name=?, email=?, phone=?, password=?, profile_pic=? WHERE id=?`;
        values = [role_id, name, email, phone, password, profile_pic, id];
      } else {
        sql = `UPDATE users SET role_id=?, name=?, email=?, phone=?, profile_pic=? WHERE id=?`;
        values = [role_id, name, email, phone, profile_pic, id];
      }
    } else {
      if (password) {
        sql = `UPDATE users SET role_id=?, name=?, email=?, phone=?, password=? WHERE id=?`;
        values = [role_id, name, email, phone, password, id];
      } else {
        sql = `UPDATE users SET role_id=?, name=?, email=?, phone=? WHERE id=?`;
        values = [role_id, name, email, phone, id];
      }
    }

    await con.query(sql, values);

    res.send(`
      <script>
        window.location='/view_member';
      </script>
    `);

  } catch (err) {
    console.log(err);
    res.send(`
      <script>
        alert('Database Error');
        window.location='/view_member';
      </script>
    `);
  }
});

module.exports = router;
