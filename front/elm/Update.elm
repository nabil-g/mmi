module Update exposing (..)

import Date exposing (fromTime)
import Model exposing (Model, Msg(..), fetchLastTweet, fetchMybDataCmd, fetchWeather)
import Ports exposing (InfoForOutside(..))
import RemoteData exposing (RemoteData(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        FetchMybData ->
            model ! [ fetchMybDataCmd ]

        UpdateDateTime time ->
            { model | datetime = Just <| fromTime time } ! []

        ReceiveQueryResponse response ->
            let
                cmd =
                    case ( response, model.mybData ) of
                        ( Success newData, Success currentData ) ->
                            if newData.countOrders > currentData.countOrders then
                                Ports.sendInfoOutside PlayCashRegister
                            else
                                Cmd.none

                        ( _, _ ) ->
                            Cmd.none
            in
            { model | mybData = response } ! [ cmd ]

        FetchWeather ->
            model ! [ fetchWeather ]

        FetchLastTweet ->
            model ! [ fetchLastTweet ]

        ReceiveWeather response ->
            case response of
                Ok w ->
                    { model | weather = { currently = w.currently } } ! []

                Err e ->
                    Debug.log "ERROR when fetching weather"
                        model
                        ! []

        ReceiveTweets response ->
            case response of
                Ok tweets ->
                    { model | lastTweet = List.head tweets } ! []

                Err e ->
                    Debug.log ("ERROR when fetching last tweet" ++ toString e)
                        model
                        ! []
