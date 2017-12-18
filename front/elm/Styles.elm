module Styles exposing (..)

import Style as S
import Style.Color as SC
import Style.Font as SF
import Color
import Element as E


type Styles
    = None
    | Layout
    | Image


type Variations
    = Large
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
                        66
                     else
                        33
                    )
                ]
            , S.variation Large
                [ SF.size
                    (if isBigPortrait then
                        44
                     else
                        22
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
                    32
                 else
                    16
                )
            , SF.typeface [ SF.font "Roboto" ]
            ]
        , S.style Image
            []
        ]


type alias Elem msg =
    E.Element Styles Variations msg
