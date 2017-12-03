var express = require("express");
var bodyParser = require("body-parser");
var app = express();
var cors = require("cors");
var db = require("./db.js");
const { buildSchema } = require("graphql");
const graphqlHTTP = require("express-graphql");
const schema = require("./schema.js");
var async = require("async");

var whitelist = ["http://localhost:3002"];
var corsOptions = {
    origin: function(origin, callback) {
        var originIsWhitelisted = whitelist.indexOf(origin) !== -1;
        callback(null, originIsWhitelisted);
    },
    credentials: true,
};
app.use(cors(corsOptions));

// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: false }));

// parse application/json
app.use(bodyParser.json());

app.get("/", function(req, res, next) {
    res.json({ message: "bla" });
});

app.post("/mmi", function(req, res, next) {
    res.json({ message: "blabla" });
    var params = req.body;
    console.log("req", params);

    if (params.new_user) {
        var result = getLastData()
            .then(function(lastRow) {
                var newData = {
                    countOrders: lastRow.countOrders,
                    countUsers: lastRow.countUsers + parseInt(params.new_user),
                };
                insertNewData(newData);
            })
            .catch(e => console.log(e));
    } else if (params.new_order && params.amount) {
        var result = getLastData()
            .then(function(lastRow) {
                var newCountOrders = lastRow.countOrders + 1;
                var newVa = lastRow.va + parseFloat(params.amount);
                var newData = {
                    countOrders: newCountOrders,
                    countUsers: lastRow.countUsers,
                    va: newVa,
                    avgCart: newVa / newCountOrders,
                    prodEvents: lastRow.prodEvents,
                };

                insertNewData(newData);
            })
            .catch(e => console.log(e));
    }
});

function insertNewData(newData) {
    db.query("INSERT INTO myb_data SET ?", newData, (err, results) => {
        if (err) console.log("err", err);
        console.log("1 row inserted");
    });
}

function getLastData() {
    return new Promise((resolve, reject) => {
        let sql = "SELECT * FROM myb_data ORDER BY ID DESC LIMIT 1";
        db.query(sql, (err, results) => {
            if (err) reject(err);
            resolve(results[0]);
        });
    });
}

app.use(
    "/graphql",
    graphqlHTTP({
        schema: schema,
        rootValue: global,
        graphiql: true,
    })
);

app.listen(3003, function() {
    console.log("Listening on port 3003!");
});
