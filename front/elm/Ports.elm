port module Ports exposing (..)

import Json.Decode as D
import Json.Encode as E
import Json.Decode.Pipeline as P


type alias GenericOutsideData =
    { tag : String
    , data : E.Value
    }


type InfoForOutside
    = PlayCashRegister


port infoForOutside : GenericOutsideData -> Cmd msg


sendInfoOutside : InfoForOutside -> Cmd msg
sendInfoOutside info =
    case info of
        PlayCashRegister ->
            infoForOutside { tag = "playCashRegister", data = E.null }
