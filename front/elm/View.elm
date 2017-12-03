module View exposing (..)

import Html exposing (Html, div, text)
import Model exposing (Model, Msg)
import RemoteData exposing (RemoteData(..))


view : Model -> Html Msg
view model =
    case model.mybData of
        Success data ->
            div []
                [ div []
                    [ text <| "Nombre de commandes : " ++ toString data.countOrders ]
                , div []
                    [ text <| "Nombre d'inscrits : " ++ toString data.countUsers ]
                , div []
                    [ text <| "Manifs en prod : " ++ toString data.prodEvents ]
                ]

        _ ->
            text "Chargement..."
