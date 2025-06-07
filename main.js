
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('YO Docker+node app');
});

app.listen(8000, () => {
  console.log('Server is running on port 8000');
});

