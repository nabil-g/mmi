module Styles exposing (..)

import Style as S
import Style.Color as SC
import Style.Font as SF
import Style.Border as SB
import Color
import Element as E


type Styles
    = None
    | Layout
    | WeatherIcon
    | Border


type Variations
    = Large
    | Larger
    | Largest
    | Extralarge
    | Bold
    | Light
    | Left


stylesheet : Bool -> S.StyleSheet Styles Variations
stylesheet isBigPortrait =
    S.styleSheet
        [ S.style None
            [ S.variation Largest
                [ SF.size
                    (if isBigPortrait then
                        130
                     else
                        65
                    )
                ]
            , S.variation Larger
                [ SF.size
                    (if isBigPortrait then
                        94
                     else
                        47
                    )
                ]
            , S.variation Large
                [ SF.size
                    (if isBigPortrait then
                        64
                     else
                        32
                    )
                ]
            , S.variation Extralarge
                [ SF.size
                    (if isBigPortrait then
                        180
                     else
                        90
                    )
                ]
            , S.variation Bold [ SF.weight 700 ]
            , S.variation Light [ SF.weight 300 ]
            ]
        , S.style Layout
            [ SC.background <| Color.black
            , SC.text <| Color.white
            , SF.size
                (if isBigPortrait then
                    40
                 else
                    20
                )
            , SF.typeface [ SF.font "Roboto" ]
            ]
        , S.style WeatherIcon
            [ S.prop "width" "220px"
            , S.prop "height" "220px"
            , S.prop "margin" "-40px"
            ]
        , S.style Border
            [ SC.border Color.white
            , SB.solid
            , S.variation Left [ SB.left 1 ]
            ]
        ]


type alias Elem msg =
    E.Element Styles Variations msg
