module Model exposing (..)

import Ports exposing (InfoForElm(..))
import Time exposing (Time, second, minute)
import Date exposing (Date, fromTime)
import Task exposing (Task)
import GraphQL.Request.Builder exposing (..)
import GraphQL.Client.Http as GraphQLClient
import RemoteData exposing (RemoteData(..))


type alias Model =
    { mybData : GraphQLData MybData
    , datetime : Maybe Date
    }


type alias GraphQLData a =
    RemoteData GraphQLClient.Error a


type alias MybData =
    { countOrders : Int
    , avgCart : Float
    , va : Int
    , countUsers : Int
    , prodEvents : Int
    }



-- MESSAGES


type Msg
    = NoOp
    | InfoFromOutside InfoForElm
    | FetchData
    | UpdateDateTime Time
    | ReceiveQueryResponse (GraphQLData MybData)



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

        FetchData ->
            model ! [ fetchDataCmd ]

        UpdateDateTime time ->
            { model | datetime = Just <| fromTime time } ! []

        ReceiveQueryResponse response ->
            { model | mybData = Debug.log "response" response } ! []


fetchDataCmd : Cmd Msg
fetchDataCmd =
    fetchData
        |> sendQueryRequest
        |> Task.attempt (RemoteData.fromResult >> ReceiveQueryResponse)


fetchData : Request Query MybData
fetchData =
    extract
        (field "myb_data"
            []
            (object MybData
                |> with (field "countOrders" [] int)
                |> with (field "avgCart" [] float)
                |> with (field "va" [] int)
                |> with (field "countUsers" [] int)
                |> with (field "prodEvents" [] int)
            )
        )
        |> queryDocument
        |> request {}


sendQueryRequest : Request Query a -> Task GraphQLClient.Error a
sendQueryRequest request =
    GraphQLClient.sendQuery "http://localhost:3003/graphql" request