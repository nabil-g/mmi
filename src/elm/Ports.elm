port module Ports exposing (..)

import Json.Decode as D
import Json.Encode as E


type alias GenericOutsideData =
    { tag : String
    , data : E.Value
    }


type InfoForElm
    = StuffReceived String


port infoForElm : (GenericOutsideData -> msg) -> Sub msg


getInfoFromOutside : (InfoForElm -> msg) -> (String -> msg) -> Sub msg
getInfoFromOutside tagger onError =
    infoForElm
        (\outsideInfo ->
            case outsideInfo.tag of
                "stuffReceived" ->
                    case D.decodeValue D.string outsideInfo.data of
                        Ok data ->
                            tagger <| StuffReceived data

                        Err err ->
                            onError err

                _ ->
                    onError "Unknown message type"
        )
