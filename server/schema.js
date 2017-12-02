/* Here a simple schema is constructed without using the GraphQL query language.
  e.g. using 'new GraphQLObjectType' to create an object type
*/

let {
  // These are the basic GraphQL types need in this tutorial
  GraphQLString,
  GraphQLList,
  GraphQLInt,
  GraphQLObjectType,
  // This is used to create required fileds and arguments
  GraphQLNonNull,
  // This is the class we need to create the schema
  GraphQLSchema,
} = require('graphql');

const MybDataType = new GraphQLObjectType({
  name: "myb_data",
  description: "This represents myb data",
  fields: () => ({
    countOrders: {type: GraphQLInt},
  })
});

// This is the Root Query
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

// This is the schema declaration
const MmiAppSchema = new GraphQLSchema({
  query: MmiQueryRootType
  // If you need to create or updata a datasource,
  // you use mutations. Note:
  // mutations will not be explored in this post.
  // mutation: BlogMutationRootType
});


// resolver

export async function resolveMybData(rootValue, {name} ){
connection.query('SELECT  * FROM myb_data ORDER BY ID DESC LIMIT 1';, function(err, rows, fields) {
  if (!err)
    console.log('The solution is: ', rows[0]);
  else
    console.log('Error while performing Query.');
});
 }

module.exports = MmiAppSchema;
