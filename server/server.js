var express = require('express')
var bodyParser = require('body-parser')
var app = express()
var mysql = require('mysql')

// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: false }))

// parse application/json
app.use(bodyParser.json())

var connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'root',
  database: 'mmi'
})

connection.connect(function(err) {
  if (err) throw err
  console.log('You are now connected...')
})

app.get('/', function(req, res, next) {
  res.json({ message: 'fst' });
});


app.post('/mmi', function(req, res, next) {
  res.json({ message: 'blabla' });
  console.log("req", req.body);
  var amount = req.body.order;
var sql = "INSERT INTO orders (amount) VALUES ("+amount+")";
  connection.query(sql, function (err, result) {
    if (err) throw err;
    console.log("1 record inserted");
  });

});


app.listen(3003, function() {
  console.log('Listening on port 3003!');
});


