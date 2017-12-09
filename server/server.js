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
                handleNewUser(params, lastRow);
            })
            .catch(e => console.log(e));
    } else if (params.new_order && params.amount) {
        var result = getLastData()
            .then(function(lastRow) {
                handleNewOrder(params, lastRow);
            })
            .catch(e => console.log(e));
    }
});
function handleNewUser(params, lastRow) {
    var newData = {
        countUsers: lastRow.countUsers + parseInt(params.new_user),
    };

    var today = new Date().setHours(0, 0, 0, 0);
    var lastRowDate = new Date(lastRow.createdAt).setHours(0, 0, 0, 0);

    if (lastRowDate < today) {
        console.log("no insertion yet for today");
        // no insertion yet for today
        newData.countOrders = lastRow.countOrders;
        newData.prodEvents = lastRow.prodEvents;
        newData.va = lastRow.va;
        newData.avgCart = lastRow.avgCart;
        newData.todayUsers = 1;
        insertNewData(newData);
    } else {
        newData.todayUsers = lastRow.todayUsers + 1;
        updateTodayData(newData, lastRow.id);
    }
}

function handleNewOrder(params, lastRow) {
    var newCountOrders = lastRow.countOrders + 1;
    var newVa = lastRow.va + parseFloat(params.amount);
    var newAvgCart = newVa / newCountOrders;
    var newData = {
        countOrders: newCountOrders,
        va: newVa,
        avgCart: newAvgCart,
    };

    var today = new Date().setHours(0, 0, 0, 0);
    var lastRowDate = new Date(lastRow.createdAt).setHours(0, 0, 0, 0);

    if (lastRowDate < today) {
        console.log("no insertion yet for today");
        // no insertion yet for today
        newData.countUsers = lastRow.countUsers;
        newData.prodEvents = lastRow.prodEvents;
        newData.todayOrders = 1;
        insertNewData(newData);
    } else {
        newData.todayOrders = lastRow.todayOrders + 1;
        updateTodayData(newData, lastRow.id);
    }
}

function updateTodayData(newData, id) {
    db.query(
        "UPDATE myb_data SET ? WHERE id= ?",
        [newData, id],
        (err, results) => {
            if (err) console.log("err", err);
            console.log("Today data updated");
        }
    );
}

function insertNewData(newData) {
    db.query("INSERT INTO myb_data SET ?", newData, (err, results) => {
        if (err) console.log("err", err);
        console.log("New today data inserted");
    });
}

function getLastData() {
    return new Promise((resolve, reject) => {
        let sql =
            "SELECT id, countOrders, prodEvents, countUsers, todayOrders, todayUsers, avgCart, va, DATE(createdAt) as createdAt FROM myb_data  ORDER BY ID DESC LIMIT 1;";
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
