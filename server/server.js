var express = require('express')
var bodyParser = require('body-parser')
var app = express()
var mysql = require('mysql')
const { buildSchema } = require('graphql');
const graphqlHTTP = require('express-graphql');
const schema = require('./schema.js');

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

//
// let schema = buildSchema(`
//   type Query {
//     postTitle: String,
//     blogTitle: String
//   }
// `);
//
// // Root provides a resolver function for each API endpoint
// let root = {
//   postTitle: () => {
//     return 'Build a Simple GraphQL Server With Express and NodeJS';
//   },
//   blogTitle: () => {
//     return 'scotch.io';
//   }
// };


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


app.use('/graphql', graphqlHTTP({
  schema: schema,
  rootValue: root,
  graphiql: true //Set to false if you don't want graphiql enabled
}));


app.listen(3003, function() {
  console.log('Listening on port 3003!');
});


