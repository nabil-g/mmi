var db = require ('./db.js')


let {
  GraphQLString,
  GraphQLList,
  GraphQLInt,
  GraphQLObjectType,
  GraphQLNonNull,
  GraphQLSchema,
} = require('graphql');

const MybDataType = new GraphQLObjectType({
  name: "myb_data",
  description: "This represents myb data",
  fields: () => ({
    countOrders: {type: GraphQLInt},
  })
});

// Root Query
const MmiQueryRootType = new GraphQLObjectType({
  name: 'MmiAppSchema',
  description: "Mmi Application Schema Query Root",
  fields: () => ({
    myb_data: {
      type: MybDataType,
      description: "All myb data",
      resolve: resolveMybData
    }
  })
});

// schema declaration
const MmiAppSchema = new GraphQLSchema({
  query: MmiQueryRootType
 });


// resolver

function resolveMybData(rootValue){
  db.query('SELECT countOrders FROM myb_data ORDER BY ID DESC LIMIT 1;', function(err, rows, fields) {
    if (!err) {
      console.log('Result is: ', JSON.stringify(rows[0]));
      return rows[0];
    }
    else
      console.log('Error while performing Query.');
  });
 }

module.exports = MmiAppSchema;
