module Styles exposing (..)

import Style as S
import Style.Color as SC
import Style.Font as SF
import Color
import Element as E


type Styles
    = None
    | Layout


type Variations
    = Large
    | Largest
    | Bold
    | Light


stylesheet : S.StyleSheet Styles Variations
stylesheet =
    S.styleSheet
        [ S.style None
            [ S.variation Largest [ SF.size 66 ]
            , S.variation Large [ SF.size 44 ]
            , S.variation Bold [ SF.weight 700 ]
            , S.variation Light [ SF.weight 300 ]
            ]
        , S.style Layout
            [ SC.background <| Color.black
            , SC.text <| Color.white
            , SF.size 32
            , SF.typeface [ SF.font "Roboto" ]
            ]
        ]


type alias Elem msg =
    E.Element Styles Variations msg
