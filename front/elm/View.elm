module View exposing (..)

import Html exposing (Html)
import Model exposing (Model, Msg)
import RemoteData exposing (RemoteData(..))
import Element exposing (viewport, el, column, text)
import Element.Attributes exposing (..)
import Styles as S exposing (Variations, Styles)


view : Model -> Html Msg
view model =
    viewport (S.stylesheet) <|
        el S.Layout [ height fill, width fill, padding 30 ] <|
            case model.mybData of
                Success data ->
                    column S.None
                        [ spacing 15 ]
                        [ el S.None
                            []
                            (text <| "Nombre de commandes : " ++ toString data.countOrders)
                        , el S.None
                            []
                            (text <| "Panier moyen : " ++ toString data.avgCart ++ " €")
                        , el S.None
                            []
                            (text <| "Volume d'affaire : " ++ toString data.va ++ " €")
                        , el S.None
                            []
                            (text <| "Nombre d'inscrits : " ++ toString data.countUsers)
                        , el S.None
                            []
                            (text <| "Manifs en prod : " ++ toString data.prodEvents)
                        ]

                _ ->
                    text "Chargement..."
