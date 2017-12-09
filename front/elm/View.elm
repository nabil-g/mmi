module View exposing (..)

import Html exposing (Html)
import Model exposing (Model, Msg)
import RemoteData exposing (RemoteData(..))
import Element exposing (viewport, el, column, row, text, empty)
import Element.Attributes exposing (..)
import Styles as S exposing (Variations, Styles, Elem)
import Utils exposing (dateToStringFr, timeToStringFr)
import Date exposing (Date)


view : Model -> Html Msg
view model =
    viewport (S.stylesheet) <|
        el S.Layout [ height fill, width fill, padding 30 ] <|
            case model.mybData of
                Success data ->
                    row S.None
                        []
                        [ el S.None [ width <| fillPortion 3 ] <|
                            column S.None
                                [ spacing 15 ]
                                [ el S.None
                                    []
                                  <|
                                    row S.None
                                        [ spacing 15 ]
                                        [ text <| "Nombre de commandes : " ++ toString data.countOrders
                                        , text <| " - " ++ toString data.todayOrders ++ " aujourd'hui"
                                        ]
                                , el S.None
                                    []
                                    (text <| "Panier moyen : " ++ toString data.avgCart ++ " €")
                                , el S.None
                                    []
                                    (text <| "Volume d'affaire : " ++ toString data.va ++ " €")
                                , el S.None [] <|
                                    row S.None
                                        [ spacing 15 ]
                                        [ text <| "Nombre d'inscrits : " ++ toString data.countUsers
                                        , text <| " - " ++ toString data.todayUsers ++ " aujourd'hui"
                                        ]
                                , el S.None
                                    []
                                    (text <| "Manifs en prod : " ++ toString data.prodEvents)
                                ]
                        , el S.None [ width <| fillPortion 1 ] <| viewDatetime model.datetime
                        ]

                _ ->
                    text "Chargement..."


viewDatetime : Maybe Date -> Elem Msg
viewDatetime datetime =
    case datetime of
        Nothing ->
            empty

        Just d ->
            column S.None
                [ spacing 15 ]
                [ el S.None [] <| text <| dateToStringFr d
                , el S.None [ vary S.Large True ] <| text <| timeToStringFr d
                ]
