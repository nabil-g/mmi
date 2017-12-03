var Elm = require( '../elm/Main' );
var app = Elm.Main.fullscreen(window.options);

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

