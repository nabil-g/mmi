var express = require("express");
var bodyParser = require("body-parser");
var app = express();
var cors = require("cors");
var db = require("./db.js");
const { buildSchema } = require("graphql");
const graphqlHTTP = require("express-graphql");
const schema = require("./schema.js");
var request = require("request");

var whitelist = ["http://localhost:3002", "http://54.36.52.224:42424"];
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

// ROUTES ////////////////
//////////////////////////

app.post("/mmi", function(req, res, next) {
    res.json({ message: "OK" });
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

app.use(
    "/graphql",
    graphqlHTTP({
        schema: schema,
        rootValue: global,
        graphiql: true,
    })
);

app.get("/forecast/:coords", function(req, res, next) {
    request.get(
        {
            url: `https://api.darksky.net/forecast/537e53749d634ff0707fa5acadb2eab3/${
                req.params.coords
            }`,
            qs: req.query,
            json: true,
            headers: { "User-Agent": "request" },
        },
        (error, response, body) => {
            if (error) {
                console.log("Error:", error);
            } else if (response.statusCode !== 200) {
                console.log("Status:", response.statusCode);
            } else {
                res.send(body);
            }
        }
    );
});

app.get("/last_tweet", function(req, res, next) {
    request.get(
        {
            url: "https://api.twitter.com/1.1/statuses/user_timeline.json",
            oauth: {
                consumer_key: "dC3j3ePjUib6m2fdZvTKPS7Mb",
                consumer_secret:
                    "lojT6tjtND5O6KJsWZr1xbQNR76SifTpDo0pz0ID47M3ke0mva",
            },
            qs: {
                user_id: "740520993911898113",
                count: 1,
                tweet_mode: "extended",
            },
            json: true,
            headers: { "User-Agent": "request" },
        },
        (error, response, body) => {
            if (error) {
                console.log("Error:", error);
            } else if (response.statusCode !== 200) {
                console.log("Status:", response.statusCode);
            } else {
                res.send(body);
            }
        }
    );
});

app.listen(42425, function() {
    console.log("Listening on port 42425!");
});

// MYB DATA //////////////
//////////////////////////

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
    var newAvgCart = Math.round(newVa / 100 / newCountOrders);
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
    var set = "";
    for (var item in newData) {
        if (!newData.hasOwnProperty(item)) {
            continue;
        }
        set += item + "=" + newData[item] + ", ";
    }

    var sql = 'UPDATE "myb_data" SET ' + set.slice(0, -2) + " WHERE id= " + id;
    db.run(sql, (err, results) => {
        if (err) console.log("err", err);
        console.log("Today data updated");
    });
}

function insertNewData(newData) {
    var keys = [];
    var values = [];
    for (var item in newData) {
        if (!newData.hasOwnProperty(item)) {
            continue;
        }

        keys.push(item);
        values.push(newData[item]);
    }
    var sql =
        "INSERT INTO myb_data(" +
        keys.join(",") +
        ") VALUES (" +
        values.join(",") +
        ")" +
        ";";
    db.run(sql, (err, results) => {
        if (err) console.log("err", err);
        console.log("New today data inserted");
    });
}

function getLastData() {
    return new Promise((resolve, reject) => {
        let sql =
            "SELECT id, countOrders, prodEvents, countUsers, todayOrders, todayUsers, avgCart, va, DATE(createdAt) as createdAt FROM myb_data  ORDER BY ID DESC LIMIT 1;";
        db.all(sql, (err, results) => {
            if (err) reject(err);
            resolve(results[0]);
        });
    });
}
