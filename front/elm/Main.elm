module Main exposing (..)

import Element as E
import Html exposing (programWithFlags)
import Model exposing (..)
import RemoteData exposing (RemoteData(..))
import Task
import Time exposing (Time, hour, minute, second)
import Update exposing (update)
import View exposing (view)


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Flags =
    { width : Int
    , height : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        newDevice =
            E.classifyDevice { width = flags.width, height = flags.height }
    in
    { mybData = NotAsked
    , datetime = Nothing
    , weather = initialWeather
    , lastTweet = Nothing
    , device = newDevice
    }
        ! [ fetchMybDataCmd, Task.perform UpdateDateTime Time.now, fetchWeather, fetchLastTweet ]


initialWeather : Weather
initialWeather =
    { currently = initialCurrentWeather }


initialCurrentWeather : CurrentWeather
initialCurrentWeather =
    { icon = ""
    , summary = ""
    , temperature = 0
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every (10 * second) <| always FetchMybData
        , Time.every minute UpdateDateTime
        , Time.every (15 * minute) <| always FetchWeather
        , Time.every (15 * minute) <| always FetchLastTweet
        ]
