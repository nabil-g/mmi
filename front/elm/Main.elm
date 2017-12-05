module Main exposing (..)

import Html exposing (program)
import Ports exposing (InfoForElm(..))
import Time exposing (Time, second, minute)
import Task
import RemoteData exposing (RemoteData(..))
import View exposing (view)
import Model exposing (Msg(..), fetchDataCmd, Model, update)


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    { mybData = NotAsked
    , datetime = Nothing
    }
        ! [ fetchDataCmd, Task.perform UpdateDateTime Time.now ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every (10 * second) <| always FetchData
        , Ports.getInfoFromOutside InfoFromOutside (always NoOp)
        , Time.every minute UpdateDateTime
        ]
