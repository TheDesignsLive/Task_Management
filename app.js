const express = require('express');
const cors = require('cors');
const path = require('path');
const con = require('./config/db'); // mysql2 promise pool
const app = express();
const PORT = 3000;

const authRoutes = require('./routers/auth.routes');
const homeroutes=require('./routers/home.routes');

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

app.get('/', (req, res) => {
  res.render('signup');
});

app.use('/', authRoutes);
app.use('/',homeroutes);


app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
