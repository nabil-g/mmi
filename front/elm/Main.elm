module Main exposing (..)

import Html exposing (program)
import Time exposing (Time, second, minute)
import Task
import RemoteData exposing (RemoteData(..))
import View exposing (view)
import Model exposing (Model, Weather, CurrentWeather, Msg(..), fetchMybDataCmd, update, fetchWeather)


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
    , weather = initialWeather
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
