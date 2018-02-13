module Model exposing (..)

import Time exposing (Time, second, minute)
import Date exposing (Date, fromTime)
import Task exposing (Task)
import GraphQL.Request.Builder exposing (..)
import GraphQL.Client.Http as GraphQLClient
import RemoteData exposing (RemoteData(..))
import Json.Decode.Pipeline as P
import Json.Decode as D
import Http
import Element as E
import Ports exposing (InfoForOutside(..))


type alias Model =
    { mybData : GraphQLData MybData
    , datetime : Maybe Date
    , weather : Weather
    , lastTweet : Maybe Tweet
    , device : E.Device
    }


type alias Weather =
    { currently : CurrentWeather }


type alias CurrentWeather =
    { icon : String
    , summary : String
    , temperature : Float
    }


type alias Tweet =
    { createdAt : String
    , text : String
    , media : List Media
    }


type alias Media =
    { mediaUrl : String
    , size : ImageSize
    }


type alias ImageSize =
    { width : Float
    , height : Float
    }


type alias GraphQLData a =
    RemoteData GraphQLClient.Error a


type alias MybData =
    { countOrders : Int
    , todayOrders : Int
    , avgCart : Int
    , va : Int
    , countUsers : Int
    , todayUsers : Int
    , totalEvents : Int
    , prodEvents : Int
    , ads : Int
    , todayAds : Int
    }



-- MESSAGES


type Msg
    = NoOp
    | FetchMybData
    | UpdateDateTime Time
    | ReceiveQueryResponse (GraphQLData MybData)
    | FetchWeather
    | FetchLastTweet
    | ReceiveWeather (Result Http.Error Weather)
    | ReceiveTweets (Result Http.Error (List Tweet))
    | ResetDayDataAtMidnight Time
    | ResetDayDataResponse (Result Http.Error Bool)



-- UPDATE


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

        ResetDayDataAtMidnight time ->
            let
                cmd =
                    if Date.hour (fromTime time) == 1 then
                        resetDayData
                    else
                        Cmd.none
            in
                model ! [ cmd ]

        ResetDayDataResponse response ->
            model ! []


fetchWeather : Cmd Msg
fetchWeather =
    Http.get "http://54.36.52.224:42425/forecast/45.7701213,4.829064300000027?lang=fr&units=si&exclude=minutely,alerts,flags" decodeWeather
        -- Http.get "http://localhost:42425/forecast/45.7701213,4.829064300000027?lang=fr&units=si&exclude=minutely,alerts,flags" decodeWeather
        |> Http.send ReceiveWeather


fetchLastTweet : Cmd Msg
fetchLastTweet =
    Http.get "http://54.36.52.224:42425/last_tweet" decodeTweets
        -- Http.get "http://localhost:42425/last_tweet" decodeTweets
        |> Http.send ReceiveTweets


fetchMybDataCmd : Cmd Msg
fetchMybDataCmd =
    fetchMybData
        |> sendQueryRequest
        |> Task.attempt (RemoteData.fromResult >> ReceiveQueryResponse)


fetchMybData : Request Query MybData
fetchMybData =
    extract
        (field "myb_data"
            []
            (object MybData
                |> with (field "countOrders" [] int)
                |> with (field "todayOrders" [] int)
                |> with (field "avgCart" [] int)
                |> with (field "va" [] int)
                |> with (field "countUsers" [] int)
                |> with (field "todayUsers" [] int)
                |> with (field "totalEvents" [] int)
                |> with (field "prodEvents" [] int)
                |> with (field "ads" [] int)
                |> with (field "todayAds" [] int)
            )
        )
        |> queryDocument
        |> request {}


resetDayData : Cmd Msg
resetDayData =
    Http.get "http://54.36.52.224:42425/reset_day" D.bool
        -- Http.get "http://localhost:42425/reset_day" D.bool
        |> Http.send ResetDayDataResponse


sendQueryRequest : Request Query a -> Task GraphQLClient.Error a
sendQueryRequest request =
    GraphQLClient.sendQuery "http://54.36.52.224:42425/graphql" request



-- GraphQLClient.sendQuery "http://localhost:42425/graphql" request


decodeWeather : D.Decoder Weather
decodeWeather =
    P.decode Weather
        |> P.required "currently" decodeWeatherCurrently


decodeWeatherCurrently : D.Decoder CurrentWeather
decodeWeatherCurrently =
    P.decode CurrentWeather
        |> P.required "icon" D.string
        |> P.required "summary" D.string
        |> P.required "temperature" D.float


decodeTweets : D.Decoder (List Tweet)
decodeTweets =
    D.list decodeTweet


decodeTweet : D.Decoder Tweet
decodeTweet =
    P.decode Tweet
        |> P.required "created_at" D.string
        |> P.required "full_text" decodeTweetText
        |> P.requiredAt [ "entities", "media" ] (D.list decodeMedia)


decodeTweetText : D.Decoder String
decodeTweetText =
    D.string
        |> D.andThen
            (\s ->
                let
                    ind =
                        String.indexes "http" s
                in
                    case List.head (List.reverse ind) of
                        Just lastIndex ->
                            s
                                |> String.length
                                |> flip (-) lastIndex
                                |> flip String.dropRight s
                                |> D.succeed

                        _ ->
                            D.succeed s
            )


decodeMedia : D.Decoder Media
decodeMedia =
    P.decode Media
        |> P.required "media_url_https" D.string
        |> P.requiredAt [ "sizes", "small" ] decodeSize


decodeSize : D.Decoder ImageSize
decodeSize =
    P.decode ImageSize
        |> P.required "w" D.float
        |> P.required "h" D.float
