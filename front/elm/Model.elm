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
    { width : Int
    , height : Int
    }


type alias GraphQLData a =
    RemoteData GraphQLClient.Error a


type alias MybData =
    { countOrders : Int
    , todayOrders : Int
    , avgCart : Float
    , va : Int
    , countUsers : Int
    , todayUsers : Int
    , prodEvents : Int
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
            { model | mybData = Debug.log "response" response } ! []

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


fetchWeather : Cmd Msg
fetchWeather =
    Http.get "http://localhost:3003/forecast/45.7701213,4.829064300000027?lang=fr&units=si&exclude=minutely,alerts,flags" decodeWeather
        |> Http.send ReceiveWeather


fetchLastTweet : Cmd Msg
fetchLastTweet =
    Http.get "http://localhost:3003/last_tweet" decodeTweets
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
                |> with (field "avgCart" [] float)
                |> with (field "va" [] int)
                |> with (field "countUsers" [] int)
                |> with (field "todayUsers" [] int)
                |> with (field "prodEvents" [] int)
            )
        )
        |> queryDocument
        |> request {}


sendQueryRequest : Request Query a -> Task GraphQLClient.Error a
sendQueryRequest request =
    GraphQLClient.sendQuery "http://localhost:3003/graphql" request


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
        |> P.required "text" D.string
        |> P.requiredAt [ "entities", "media" ] (D.list decodeMedia)


decodeMedia : D.Decoder Media
decodeMedia =
    P.decode Media
        |> P.required "media_url_https" D.string
        |> P.requiredAt [ "sizes", "small" ] decodeSize


decodeSize : D.Decoder ImageSize
decodeSize =
    P.decode ImageSize
        |> P.required "w" D.int
        |> P.required "h" D.int
