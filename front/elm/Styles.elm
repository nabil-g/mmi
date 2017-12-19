module Styles exposing (..)

import Style as S
import Style.Color as SC
import Style.Font as SF
import Color
import Element as E


type Styles
    = None
    | Layout
    | WeatherIcon


type Variations
    = Large
    | Larger
    | Largest
    | Bold
    | Light


stylesheet : Bool -> S.StyleSheet Styles Variations
stylesheet isBigPortrait =
    S.styleSheet
        [ S.style None
            [ S.variation Largest
                [ SF.size
                    (if isBigPortrait then
                        128
                     else
                        64
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
                        58
                     else
                        29
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
                    42
                 else
                    21
                )
            , SF.typeface [ SF.font "Roboto" ]
            ]
        , S.style WeatherIcon
            [ S.prop "width" "220px"
            , S.prop "height" "220px"
            , S.prop "margin" "-40px"
            ]
        ]


type alias Elem msg =
    E.Element Styles Variations msg
