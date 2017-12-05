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


stylesheet : S.StyleSheet Styles Variations
stylesheet =
    S.styleSheet
        [ S.style None
            [ S.variation Large [ SF.size 32 ]
            ]
        , S.style Layout
            [ SC.background <| Color.black
            , SC.text <| Color.white
            , SF.size 18
            , SF.typeface [ SF.font "Roboto" ]
            ]
        ]


type alias Elem msg =
    E.Element Styles Variations msg
