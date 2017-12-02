var Elm = require( '../elm/Main' );
var app = Elm.Main.embed( document.getElementById( 'main' ) ,  window.options);

app.ports.infoForOutside.subscribe(function(elmData) {
    var tag = elmData.tag;
    switch (tag) {
        case "stuffReceived":

            break;
        default:
            console.log("Unrecognized type");
            break;
    }
});

