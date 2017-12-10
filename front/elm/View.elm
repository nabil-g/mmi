module View exposing (..)

import Html exposing (Html)
import Model exposing (Model, Weather, MybData, Msg)
import RemoteData exposing (RemoteData(..))
import Element exposing (viewport, el, column, row, text, empty, html, image)
import Element.Attributes exposing (..)
import Styles as S exposing (Variations, Styles, Elem)
import Utils exposing (..)
import Date exposing (Date)
import Round
import Svg
import Svg.Attributes as SvgA


view : Model -> Html Msg
view model =
    viewport (S.stylesheet) <|
        el S.Layout [ height fill, width fill, padding 80 ] <|
            case model.mybData of
                Success data ->
                    column S.None
                        [ spacing 300 ]
                        [ viewHeader model
                        , viewMybData data
                        ]

                _ ->
                    text "Chargement..."


viewHeader : Model -> Elem Msg
viewHeader model =
    el S.None [] <|
        row S.None
            [ width fill, spread ]
            [ el S.None [ alignLeft ] <|
                viewDate model.datetime
            , el S.None [ vary S.Large True, alignRight ] <|
                column S.None
                    []
                    [ el S.None [] <|
                        row S.None
                            []
                            [ viewWeatherIcon model.weather.currently.icon
                            , text (Round.round 1 model.weather.currently.temperature ++ " °C")
                            ]
                    , viewTime model.datetime
                    ]
            ]


viewDate : Maybe Date -> Elem Msg
viewDate datetime =
    case datetime of
        Nothing ->
            empty

        Just d ->
            column S.None
                []
                [ el S.None [ vary S.Bold True ] <| text (ucfirst (dayOfWeek d))
                , el S.None [ vary S.Light True ] <| text <| dayAndMonth d
                ]


viewTime : Maybe Date -> Elem Msg
viewTime datetime =
    case datetime of
        Nothing ->
            empty

        Just d ->
            el S.None [ vary S.Bold True, vary S.Largest True ] <| text <| timeToStringFr d


viewWeatherIcon : String -> Elem Msg
viewWeatherIcon icon =
    image S.None [] { src = "img/Cloud-Rain.svg", caption = "" }


viewMybData : MybData -> Elem Msg
viewMybData data =
    el S.None [] <|
        column S.None
            [ spacing 40 ]
            [ el S.None [] <|
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
