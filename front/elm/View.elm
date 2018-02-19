module View exposing (..)

import Html exposing (Html)
import Model exposing (Model, Weather, MybData, Msg, Tweet)
import RemoteData exposing (RemoteData(..))
import Element exposing (..)
import Element.Attributes exposing (..)
import Styles exposing (..)
import Utils exposing (..)
import Date exposing (Date)
import Round
import FormatNumber as FN
import FormatNumber.Locales exposing (Locale, frenchLocale)


view : Model -> Html Msg
view model =
    viewport (stylesheet (isBigPortrait model.device)) <|
        el Layout [ height <| percent 100, clipX, clipY, width fill ] <|
            case model.mybData of
                Success data ->
                    column None
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
    el None [] <|
        row None
            [ width fill, spread ]
            [ el None [ alignLeft ] <|
                column None
                    [ spacing 80 ]
                    [ viewDate model.datetime
                    , viewSaint
                    ]
            , el None [ vary Large True, alignRight ] <|
                column None
                    []
                    [ viewTime model.datetime
                    , el None [] <|
                        row None
                            [ verticalCenter ]
                            [ el None [ vary Bold True, vary Larger True ] <| text (Round.round 1 model.weather.currently.temperature ++ "°")
                            , viewWeatherIcon model.weather.currently.icon
                            ]
                    ]
            ]


viewDate : Maybe Date -> Elem Msg
viewDate datetime =
    case datetime of
        Nothing ->
            empty

        Just d ->
            el None [] <|
                column None
                    []
                    [ el None [ vary Bold True, vary Larger True ] <| text (ucfirst (dayOfWeek d))
                    , el None [ vary Light True, vary Large True ] <| text <| dayAndMonth d
                    ]


viewSaint : Elem Msg
viewSaint =
    el None [ vary Bold True ] <|
        row None
            [ spacing 30 ]
            [ el None [] <| html <| icon "zmdi zmdi-chevron-right zmdi-hc-lg"
            , el None [] <| text "St Gabin"
            ]


viewTime : Maybe Date -> Elem Msg
viewTime datetime =
    case datetime of
        Nothing ->
            empty

        Just d ->
            el None [ vary Light True, vary Extralarge True ] <| text <| timeToStringFr d


viewWeatherIcon : String -> Elem Msg
viewWeatherIcon icon =
    image WeatherIcon [ paddingLeft 5 ] { src = getSvgIcon icon, caption = "" }


viewCountsMybData : MybData -> Elem Msg
viewCountsMybData data =
    el None [] <|
        row None
            []
            [ el None [ width <| percent 50, center ] <|
                column None
                    [ spacing 50 ]
                    [ viewUsers data
                    , viewOrders data
                    ]
            , el Border [ vary Left True, width <| percent 50, center ] <|
                column None
                    [ spacing 50, paddingLeft 50 ]
                    [ viewProdEvents data
                    , viewAds data
                    ]
            ]


viewProdEvents : MybData -> Elem Msg
viewProdEvents data =
    el None [] <|
        row None
            [ spacing 30, verticalCenter, width fill ]
            [ el None [ width <| fillPortion 1, vary Largest True, vary Bold True ] <| el None [ alignRight ] <| text (toString data.prodEvents)
            , el None [ width <| fillPortion 2 ] <|
                column None
                    []
                    [ el None [ vary Large True, vary Bold True ] <|
                        (data.totalEvents
                            |> toFloat
                            |> FN.format { frenchLocale | decimals = 0 }
                            |> text
                        )
                    , el None [ vary Light True ] <| text "Prod"
                    ]
            ]


viewAds : MybData -> Elem Msg
viewAds data =
    el None [] <|
        row None
            [ spacing 30, verticalCenter, width fill ]
            [ el None [ width <| fillPortion 1, vary Largest True, vary Bold True ] <| el None [ alignRight ] <| text ("+" ++ toString data.todayAds)
            , el None [ width <| fillPortion 2 ] <|
                column None
                    []
                    [ el None [ vary Large True, vary Bold True ] <|
                        (data.ads
                            |> toFloat
                            |> FN.format { frenchLocale | decimals = 0 }
                            |> text
                        )
                    , el None [ vary Light True ] <| text "Annonces"
                    ]
            ]


viewMoneyMybData : MybData -> Device -> Elem Msg
viewMoneyMybData data device =
    el None [ center ] <|
        row None
            [ spacing
                (if isBigPortrait device then
                    100
                 else
                    40
                )
            ]
            [ el None [ vary Large True ] <| html <| icon "zmdi zmdi-shopping-cart zmdi-hc-4x"
            , el None [] <|
                column None
                    [ spacing 15 ]
                    [ el None [ vary Larger True, vary Bold True ] <|
                        (data.va
                            |> toFloat
                            |> (\i -> i / 100)
                            |> FN.format { frenchLocale | decimals = 0 }
                            |> (\i -> i ++ " €")
                            |> text
                        )
                    , el None [] <|
                        row None
                            [ spacing 40, verticalCenter ]
                            [ el None [ vary Large True ] <| html <| icon "zmdi zmdi-shopping-basket zmdi-hc-lg"
                            , el None [ vary Larger True, vary Light True ] <|
                                (data.avgCart
                                    |> toString
                                    |> flip (++) " €"
                                    |> text
                                )
                            ]
                    ]
            ]


viewUsers : MybData -> Elem Msg
viewUsers data =
    el None [] <|
        row None
            [ spacing 30, verticalCenter, width fill ]
            [ el None [ width <| fillPortion 1, vary Largest True, vary Bold True ] <| el None [ alignRight ] <| text ("+" ++ toString data.todayUsers)
            , el None [ width <| fillPortion 2 ] <|
                column None
                    []
                    [ el None [ vary Large True, vary Bold True ] <|
                        (data.countUsers
                            |> toFloat
                            |> FN.format { frenchLocale | decimals = 0 }
                            |> text
                        )
                    , el None [ vary Light True ] <| text "Inscrits"
                    ]
            ]


viewOrders : MybData -> Elem Msg
viewOrders data =
    el None [] <|
        row None
            [ spacing 30, verticalCenter, width fill ]
            [ el None [ width <| fillPortion 1, vary Largest True, vary Bold True ] <| el None [ alignRight ] <| text ("+" ++ toString data.todayOrders)
            , el None [ width <| fillPortion 2 ] <|
                column None
                    []
                    [ el None [ vary Large True, vary Bold True ] <|
                        (data.countOrders
                            |> toFloat
                            |> FN.format { frenchLocale | decimals = 0 }
                            |> text
                        )
                    , el None [ vary Light True ] <| text "Commandes"
                    ]
            ]


viewTweet : Maybe Tweet -> Elem Msg
viewTweet tweet =
    case tweet of
        Nothing ->
            el None [] <| text "..."

        Just t ->
            el None [ width fill ] <|
                row None
                    [ spacing 40, verticalCenter ]
                    [ case t.media of
                        photo :: [] ->
                            el None [] <|
                                decorativeImage None
                                    [ inlineStyle [ ( "width", (toString (photo.size.width * 0.5)) ++ "px" ), ( "height", (toString (photo.size.height * 0.5)) ++ "px" ) ] ]
                                    { src = photo.mediaUrl }

                        _ ->
                            el None [] <| html <| icon "zmdi zmdi-twitter zmdi-hc-5x"
                    , textLayout None [ vary Light True ] [ paragraph None [] [ text (t.text) ] ]
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
