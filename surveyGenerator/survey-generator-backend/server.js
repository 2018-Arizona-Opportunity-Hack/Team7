const express = require('express');
const app = express();
const parser = require('body-parser');

const pool = require('mssql')

const port = 3001;

app.use(parser.urlencoded({ extended: true }));
app.use(parser.json());

const router = express.Router();

router.get('/health', function(req, res) {
  res.json({ healthy: true });
});

router.route('/surveys')
  .get(function (req, res) {
    res
  })
  .post(function (req, res) {

  })
  .put(function (req, res) {

  })
  .delete(function (req, res) {

  })
);

app.use('/api', router);

app.listen(port);
console.log(`Listening on port ${port}`);
