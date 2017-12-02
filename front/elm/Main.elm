module Main exposing (..)

import Html exposing (Html, div, text, program)
import Ports exposing (InfoForElm(..))
import Time exposing (Time, second)
import Task exposing (Task)
import GraphQL.Request.Builder exposing (..)
import GraphQL.Client.Http as GraphQLClient
import RemoteData exposing (RemoteData(..))


type alias Model =
    { mybData : GraphQLData MybData }


type alias GraphQLData a =
    RemoteData GraphQLClient.Error a


type alias MybData =
    { countOrders : Int }


init : ( Model, Cmd Msg )
init =
    { mybData = NotAsked } ! []



-- MESSAGES


type Msg
    = NoOp
    | InfoFromOutside InfoForElm
    | Tick Time
    | ReceiveQueryResponse (GraphQLData MybData)



-- VIEW


view : Model -> Html Msg
view model =
    case model.mybData of
        Success data ->
            div []
                [ text <| "count orders: " ++ toString data.countOrders ]

        _ ->
            text "Nothing yet"



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

        Tick newTime ->
            let
                debug =
                    Debug.log "newTime"
            in
                model ! [ fetchDataCmd ]

        ReceiveQueryResponse response ->
            { model | mybData = response } ! []


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
            )
        )
        |> queryDocument
        |> request {}


sendQueryRequest : Request Query a -> Task GraphQLClient.Error a
sendQueryRequest request =
    GraphQLClient.sendQuery "http://localhost:3003/graphql" request



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every (10 * second) Tick
        , Ports.getInfoFromOutside InfoFromOutside (always NoOp)
        ]



-- MAIN


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
