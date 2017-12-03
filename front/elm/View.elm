module View exposing (..)

import Html exposing (Html, div, text)
import Model exposing (Model, Msg)
import RemoteData exposing (RemoteData(..))


view : Model -> Html Msg
view model =
    case model.mybData of
        Success data ->
            div []
                [ text <| "Nombre de commandes : " ++ toString data.countOrders ]

        _ ->
            text "Chargement..."
