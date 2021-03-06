module Model exposing (..)

import Date exposing (Date)
import Element as E
import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder exposing (..)
import Http
import Json.Decode as D
import Json.Decode.Pipeline as P
import RemoteData exposing (RemoteData(..))
import Task exposing (Task)
import Time exposing (Time, minute, second)


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
