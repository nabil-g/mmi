var express = require('express')
var app = express()

// app.get('/', (req, res) => res.send('Hello World!'))
app.get('/test', function(req, res, next) {
  res.json({ message: 'Hello World' });
});
app.post('/testpost', function(req, res, next) {
	res.json({ message: 'Hello World' });
});

app.listen(3003, function() {
  console.log('Listening on port 3003!');
});

// app.ws('/hello', function(websocket, request) {
//   console.log('A client connected!');
//
//   websocket.on('message', function(message) {
//     console.log(`A client sent a message: ${message}`);
//     websocket.send('Hello, world!');
//   });
// });
