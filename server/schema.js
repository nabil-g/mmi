var db = require ('./db.js')


let {
  GraphQLString,
  GraphQLList,
  GraphQLInt,
  GraphQLID,
  GraphQLObjectType,
  GraphQLNonNull,
  GraphQLSchema,
} = require('graphql');

const MybData = new GraphQLObjectType({
  name: "myb_data",
  description: "This represents myb data",
  fields: () => ({
    countOrders: {type: GraphQLInt}
  })
});

// Root Query
const Query = new GraphQLObjectType({
  name: 'Query',
  description: "Mmi Application Schema Query Root",
  fields: () => ({
    myb_data: {
      type: MybData,
      resolve: (_, args) => {
        return resolveMybData().then(value => value[0]);
      },
    }
  })
});

// schema declaration
const Schema = new GraphQLSchema({
  query: Query
 });


// resolver

function resolveMybData(){
return new Promise((resolve, reject) => {
    let sql = 'SELECT countOrders FROM myb_data ORDER BY ID DESC LIMIT 1';
    // sql = mysql.format(sql, [id]);
    db.query(sql, (err, results) => {
      if (err) reject(err);
      resolve(results);
    });
  });
 }

module.exports = Schema;