module Main exposing (..)

import Html exposing (Html, div, text, program)
import Ports exposing (InfoForElm(..))


-- MODEL


type alias Model =
    { message : String }


init : ( Model, Cmd Msg )
init =
    { message = "None" } ! []



-- MESSAGES


type Msg
    = NoOp
    | InfoFromOutside InfoForElm



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ text model.message ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        InfoFromOutside infoForElm ->
            case Debug.log "infoForElm" infoForElm of
                StuffReceived message ->
                    { model | message = message } ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.getInfoFromOutside InfoFromOutside (always NoOp)



-- MAIN


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
