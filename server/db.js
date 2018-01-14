var sqlite3 = require("sqlite3").verbose();
var db = new sqlite3.Database("../db/mmi.db");

db.serialize(function() {
    db.run(
        "CREATE TABLE if not exists myb_data (id integer primary key, countOrders integer default NULL, countUsers integer default NULL, prodEvents integer default 0, avgCart integer default NULL, va integer default NULL, createdAt datetime DEFAULT CURRENT_TIMESTAMP, todayOrders integer default 0, todayUsers integer default 0);"
    );
});

module.exports = db;
