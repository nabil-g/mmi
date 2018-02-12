"use strict";

var Elm = require( '../elm/Main' );
// var ephemeris = require('../elm/libs/ephemeris.js');
var app = Elm.Main.fullscreen({width: window.innerWidth, height: window.innerHeight});

app.ports.infoForOutside.subscribe(function(elmData) {
    var tag = elmData.tag;
    switch (tag) {
        case "playCashRegister":
            var audio = new Audio('http://54.36.52.224:42424/sounds/cashregister.mp3');
            audio.play();
        default:
            console.log("Unrecognized type");
            break;
    }
});

