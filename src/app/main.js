const app = require('express')();
const port = process.env.PORT || 8000;

app.get('/', (req, res) => {
  res.status(200).json('This is version 1.0');
});

app.listen(port, () => console.log('Magic happens on port', port));

module.exports = app;
