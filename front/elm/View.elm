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
        el S.Layout [ height fill, width fill, padding 60 ] <|
            case model.mybData of
                Success data ->
                    column S.None
                        [ spacingXY 0 320 ]
                        [ viewHeader model
                        , viewCountsMybData data
                        , viewMoneyMybData data
                        , viewTwitter
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
                            , el S.None [ vary S.Bold True, vary S.Largest True ] <| text (Round.round 1 model.weather.currently.temperature ++ "°")
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
                [ el S.None [ vary S.Bold True, vary S.Largest True ] <| text (ucfirst (dayOfWeek d))
                , el S.None [ vary S.Light True, vary S.Large True ] <| text <| dayAndMonth d
                ]


viewTime : Maybe Date -> Elem Msg
viewTime datetime =
    case datetime of
        Nothing ->
            empty

        Just d ->
            el S.None [ vary S.Light True, vary S.Largest True ] <| text <| timeToStringFr d


viewWeatherIcon : String -> Elem Msg
viewWeatherIcon icon =
    image S.None [] { src = "img/Cloud-Rain.svg", caption = "" }


viewCountsMybData : MybData -> Elem Msg
viewCountsMybData data =
    el S.None [] <|
        row S.None
            []
            [ el S.None [] <| column S.None [ spacing 50 ] [ viewUsers data, viewOrders data ]
            ]


viewMoneyMybData : MybData -> Elem Msg
viewMoneyMybData data =
    el S.None [ paddingXY 60 0 ] <|
        row S.None
            [ spacing 60 ]
            [ el S.None [ vary S.Large True ] <| html <| icon "zmdi zmdi-shopping-cart zmdi-hc-5x"
            , el S.None [] <|
                column S.None
                    [ spacing 15 ]
                    [ el S.None [ vary S.Largest True, vary S.Bold True ] <| text (Round.round 2 ((toFloat data.va) / 100) ++ " €")
                    , el S.None [ vary S.Large True, vary S.Light True ] <|
                        row S.None
                            [ spacing 20, verticalCenter ]
                            [ el S.None [] <| html <| icon "zmdi zmdi-shopping-basket zmdi-hc-2x"
                            , el S.None [] <| text (toString data.avgCart ++ " €")
                            ]
                    ]
            ]


viewUsers : MybData -> Elem Msg
viewUsers data =
    el S.None [] <|
        row S.None
            [ spacing 30 ]
            [ el S.None [ vary S.Largest True, vary S.Bold True ] <| text (toString data.todayUsers)
            , el S.None [] <|
                column S.None
                    [ spacing 5 ]
                    [ el S.None [ vary S.Large True, vary S.Bold True ] <| text (toString data.countUsers)
                    , el S.None [ vary S.Light True ] <| text "Inscrits"
                    ]
            ]


viewOrders : MybData -> Elem Msg
viewOrders data =
    el S.None [] <|
        row S.None
            [ spacing 30 ]
            [ el S.None [ vary S.Largest True, vary S.Bold True ] <| text (toString data.todayOrders)
            , el S.None [] <|
                column S.None
                    [ spacing 5 ]
                    [ el S.None [ vary S.Large True, vary S.Bold True ] <| text (toString data.countOrders)
                    , el S.None [ vary S.Light True ] <| text "Commandes"
                    ]
            ]


viewTwitter : Elem Msg
viewTwitter =
    el S.None [] <|
        row S.None
            []
            [ el S.None [] <| html <| icon "zmdi zmdi-twitter zmdi-hc-5x"
            ]
