module Model exposing (..)

import Ports exposing (InfoForElm(..))
import Time exposing (Time, second, minute)
import Date exposing (Date, fromTime)
import Task exposing (Task)
import GraphQL.Request.Builder exposing (..)
import GraphQL.Client.Http as GraphQLClient
import RemoteData exposing (RemoteData(..))
import Json.Decode.Pipeline as P
import Json.Decode as D
import Http


type alias Model =
    { mybData : GraphQLData MybData
    , datetime : Maybe Date
    , weather : Weather
    }


type alias Weather =
    { currently : CurrentWeather }


type alias CurrentWeather =
    { icon : String
    , summary : String
    , temperature : Float
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
    | InfoFromOutside InfoForElm
    | FetchMybData
    | UpdateDateTime Time
    | ReceiveQueryResponse (GraphQLData MybData)
    | FetchWeather
    | ReceiveWeather (Result Http.Error Weather)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        InfoFromOutside infoForElm ->
            case Debug.log "infoForElm" infoForElm of
                StuffReceived message ->
                    model ! []

        FetchMybData ->
            model ! [ fetchMybDataCmd ]

        UpdateDateTime time ->
            { model | datetime = Just <| fromTime time } ! []

        ReceiveQueryResponse response ->
            { model | mybData = Debug.log "response" response } ! []

        FetchWeather ->
            model ! [ fetchWeather ]

        ReceiveWeather response ->
            case response of
                Ok w ->
                    { model | weather = { currently = w.currently } } ! []

                Err e ->
                    Debug.log "ERROR when fetching weather"
                        model
                        ! []


fetchWeather : Cmd Msg
fetchWeather =
    Http.get "http://localhost:5051/forecast/45.7701213,4.829064300000027?lang=fr&units=si&exclude=minutely,alerts,flags" decodeWeather
        |> Http.send ReceiveWeather


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
