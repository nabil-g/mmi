var express = require('express')
var bodyParser = require('body-parser')
var app = express()
var cors = require('cors')
var db = require ('./db.js')
const { buildSchema } = require('graphql');
const graphqlHTTP = require('express-graphql');
const schema = require('./schema.js');

var whitelist = [
    'http://localhost:3002',
];
var corsOptions = {
    origin: function(origin, callback){
        var originIsWhitelisted = whitelist.indexOf(origin) !== -1;
        callback(null, originIsWhitelisted);
    },
    credentials: true
};
app.use(cors(corsOptions));

// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: false }))

// parse application/json
app.use(bodyParser.json())


app.get('/', function(req, res, next) {
  res.json({ message: 'bla' });
});


app.post('/mmi', function(req, res, next) {
  res.json({ message: 'blabla' });
  console.log("req", req.body);
  var amount = req.body.order;
var sql = "INSERT INTO orders (amount) VALUES ("+amount+")";
  db.query(sql, function (err, result) {
    if (err) throw err;
    console.log("1 record inserted");
  });

});


app.use('/graphql', graphqlHTTP({
  schema: schema,
  rootValue: global,
  graphiql: true
}));


app.listen(3003, function() {
  console.log('Listening on port 3003!');
});


