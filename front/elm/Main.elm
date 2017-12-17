module Main exposing (..)

import Html exposing (programWithFlags)
import Time exposing (Time, second, minute)
import Task
import RemoteData exposing (RemoteData(..))
import View exposing (view)
import Model exposing (Model, Weather, CurrentWeather, Msg(..), fetchMybDataCmd, update, fetchWeather)
import Element as E


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
        , device = newDevice
        }
            ! [ fetchMybDataCmd, Task.perform UpdateDateTime Time.now, fetchWeather ]


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
        ]
