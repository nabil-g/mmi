module View exposing (..)

import Html exposing (Html)
import Model exposing (Model, Weather, MybData, Msg, Tweet)
import RemoteData exposing (RemoteData(..))
import Element exposing (..)
import Element.Attributes exposing (..)
import Styles as S exposing (Variations, Styles, Elem)
import Utils exposing (..)
import Date exposing (Date)
import Round
import FormatNumber as FN
import FormatNumber.Locales exposing (Locale, frenchLocale)


view : Model -> Html Msg
view model =
    viewport (S.stylesheet (isBigPortrait model.device)) <|
        el S.Layout [ height <| percent 100, clipX, clipY, width fill ] <|
            case model.mybData of
                Success data ->
                    column S.None
                        [ spacingXY 0
                            (if isBigPortrait model.device then
                                200
                             else
                                30
                            )
                        ]
                        [ viewHeader model
                        , viewCountsMybData data
                        , viewMoneyMybData data model.device
                        , viewTweet model.lastTweet
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
                            [ el S.None [ vary S.Bold True, vary S.Largest True ] <| text (Round.round 1 model.weather.currently.temperature ++ "°")
                            , viewWeatherIcon model.weather.currently.icon
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
                [ el S.None [ vary S.Bold True, vary S.Larger True ] <| text (ucfirst (dayOfWeek d))
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
    image S.WeatherIcon [ paddingLeft 5 ] { src = getSvgIcon icon, caption = "" }


viewCountsMybData : MybData -> Elem Msg
viewCountsMybData data =
    el S.None [] <|
        row S.None
            []
            [ el S.None [ width <| percent 50 ] <| column S.None [ spacing 50 ] [ viewUsers data, viewOrders data ]
            ]


viewMoneyMybData : MybData -> Device -> Elem Msg
viewMoneyMybData data device =
    el S.None [ center ] <|
        row S.None
            [ spacing
                (if isBigPortrait device then
                    100
                 else
                    40
                )
            ]
            [ el S.None [ vary S.Large True ] <| html <| icon "zmdi zmdi-shopping-cart zmdi-hc-4x"
            , el S.None [] <|
                column S.None
                    [ spacing 15 ]
                    [ el S.None [ vary S.Larger True, vary S.Bold True ] <|
                        (data.va
                            |> toFloat
                            |> (\i -> i / 100)
                            |> FN.format { frenchLocale | decimals = 0 }
                            |> (\i -> i ++ " €")
                            |> text
                        )
                    , el S.None [] <|
                        row S.None
                            [ spacing 40, verticalCenter ]
                            [ el S.None [ vary S.Large True ] <| html <| icon "zmdi zmdi-shopping-basket zmdi-hc-lg"
                            , el S.None [ vary S.Larger True, vary S.Light True ] <|
                                (data.avgCart
                                    |> FN.format { frenchLocale | decimals = 0 }
                                    |> (\i -> i ++ " €")
                                    |> text
                                )
                            ]
                    ]
            ]


viewUsers : MybData -> Elem Msg
viewUsers data =
    el S.None [] <|
        row S.None
            [ spacing 30, verticalCenter, width fill ]
            [ el S.None [ width <| fillPortion 1, vary S.Largest True, vary S.Bold True ] <| el S.None [ alignRight ] <| text (toString data.todayUsers)
            , el S.None [ width <| fillPortion 2 ] <|
                column S.None
                    []
                    [ el S.None [ vary S.Large True, vary S.Bold True ] <|
                        (data.countUsers
                            |> toFloat
                            |> FN.format { frenchLocale | decimals = 0 }
                            |> text
                        )
                    , el S.None [ vary S.Light True ] <| text "Inscrits"
                    ]
            ]


viewOrders : MybData -> Elem Msg
viewOrders data =
    el S.None [] <|
        row S.None
            [ spacing 30, verticalCenter, width fill ]
            [ el S.None [ width <| fillPortion 1, vary S.Largest True, vary S.Bold True ] <| el S.None [ alignRight ] <| text (toString data.todayOrders)
            , el S.None [ width <| fillPortion 2 ] <|
                column S.None
                    []
                    [ el S.None [ vary S.Large True, vary S.Bold True ] <|
                        (data.countOrders
                            |> toFloat
                            |> FN.format { frenchLocale | decimals = 0 }
                            |> text
                        )
                    , el S.None [ vary S.Light True ] <| text "Commandes"
                    ]
            ]


viewTweet : Maybe Tweet -> Elem Msg
viewTweet tweet =
    case tweet of
        Nothing ->
            el S.None [] <| text "..."

        Just t ->
            el S.None [ width fill ] <|
                row S.None
                    [ spacing 40, verticalCenter ]
                    [ case t.media of
                        photo :: [] ->
                            el S.None [] <|
                                decorativeImage S.None
                                    [ inlineStyle [ ( "width", (toString (photo.size.width * 0.5)) ++ "px" ), ( "height", (toString (photo.size.height * 0.5)) ++ "px" ) ] ]
                                    { src = photo.mediaUrl }

                        _ ->
                            el S.None [] <| html <| icon "zmdi zmdi-twitter zmdi-hc-5x"
                    , textLayout S.None [ vary S.Light True ] [ paragraph S.None [] [ text (t.text) ] ]
                    ]


getSvgIcon : String -> String
getSvgIcon icon =
    let
        path =
            case icon of
                "clear-day" ->
                    "Sun"

                "clear-night" ->
                    "Moon"

                "rain" ->
                    "Cloud-Rain"

                "snow" ->
                    "Cloud-Snow-Alt"

                "sleet" ->
                    "Cloud-Hail"

                "hail" ->
                    "Cloud-Hail-Alt"

                "wind" ->
                    "Wind"

                "fog" ->
                    "Cloud-Fog"

                "cloudy" ->
                    "Cloud"

                "partly-cloudy-day" ->
                    "Cloud-Sun"

                "partly-cloudy-night" ->
                    "Cloud-Moon"

                "thunderstorm" ->
                    "Cloud-Lightning"

                "tornado" ->
                    "Tornado"

                _ ->
                    "Sun"
    in
        "img/" ++ path ++ ".svg"
