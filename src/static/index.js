var Elm = require( '../elm/Main' );
var app = Elm.Main.embed( document.getElementById( 'main' ) ,  window.options);

var source = new EventSource("http://localhost:3003/test");
source.onmessage = function(event) {
  console.log('message incoming');
 app.ports.infoForElm.send("test test!!");
};

