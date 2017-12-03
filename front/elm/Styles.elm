module Styles exposing (..)

import Style as S
import Style.Color as SC
import Style.Font as SF
import Color


type Styles
    = None
    | Layout


type Variations
    = Large


stylesheet : S.StyleSheet Styles Variations
stylesheet =
    S.styleSheet
        [ S.style None []
        , S.style Layout
            [ SC.background <| Color.black
            , SC.text <| Color.white
            , SF.size 18
            ]
        ]
